-- B1 · Overdraft moments
-- Task. Find every withdrawal whose amount exceeded the account balance available at that instant
-- (the running balance from all earlier transactions on that account).


-- B2 · Multi-currency customers
-- Task. Find customers who hold accounts in more than one currency. Count only the active ones
SELECT customer_id, c.first_name, c.last_name, COUNT(DISTINCT currency_code) AS currency_count
FROM accounts a
         JOIN customers c
              USING (customer_id)
WHERE status = 'active'
GROUP BY customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT currency_code) > 1
ORDER BY currency_count DESC;


-- B3 · Dormant accounts
-- Task. Find active accounts with no transaction in the last 12 months.
WITH last_activity AS (SELECT account_id, MAX(created_at) AS last_txn_at
                       FROM (SELECT from_account_id AS account_id, created_at
                             FROM transactions
                             UNION ALL
                             SELECT to_account_id, created_at
                             FROM transactions) AS both_sides
                       WHERE account_id IS NOT NULL
                       GROUP BY account_id)
SELECT a.account_number, a.open_date, COALESCE(date_part('day', now() - last_txn_at), -1) AS days_since_last_txn
FROM last_activity la
         RIGHT JOIN accounts a
                    USING (account_id)
WHERE a.status = 'active'
  AND (last_txn_at IS NULL OR last_txn_at + INTERVAL '12 months' < now());

-- B4 · Transfer chains
-- Task. Starting from a given transfer, follow the chain where each transfer's
-- destination account is the source of a later transfer, up to five hops.
WITH RECURSIVE transfer_chain(step_number,
                              transaction_id, from_account,
                              to_account, amount, visited) AS ((SELECT 0,
                                                                       transaction_id,
                                                                       from_account_id,
                                                                       to_account_id,
                                                                       amount,
                                                                       ARRAY [from_account_id, to_account_id]
                                                                FROM transactions
                                                                WHERE from_account_id IS NOT NULL
                                                                  AND to_account_id IS NOT NULL
                                                                LIMIT 1)
                                                               UNION ALL
                                                               SELECT tc.step_number + 1,
                                                                      t.transaction_id,
                                                                      t.from_account_id,
                                                                      t.to_account_id,
                                                                      t.amount,
                                                                      tc.visited || t.to_account_id
                                                               FROM transactions t
                                                                        JOIN transfer_chain tc
                                                                             ON tc.to_account = t.from_account_id
                                                               WHERE tc.step_number < 5
                                                                 AND NOT (t.to_account_id = ANY (tc.visited)))
SELECT step_number, from_account, to_account, amount
FROM transfer_chain;


-- B5 · Three largest transactions per account
-- Task. For each account, return its three largest-amount transactions. (Runs against the 1,000,000-row transactions table.)
EXPLAIN ANALYSE
SELECT a.account_number, t.created_at, t.amount
FROM accounts a
         CROSS JOIN LATERAL (
    SELECT created_at, amount
    FROM ((SELECT created_at, amount
           FROM transactions w
           WHERE a.account_id = w.from_account_id
           ORDER BY amount DESC
           LIMIT 3)

          UNION ALL

          (SELECT created_at, amount
           FROM transactions w
           WHERE w.to_account_id = a.account_id
           ORDER BY amount DESC
           LIMIT 3)) as both_sides
    ORDER BY amount DESC
    LIMIT 3
    ) AS t
ORDER BY a.account_id;


-- B6 · Above-average wealth
-- Task. Find customers whose total balance across all their accounts is strictly
-- greater than the average customer total balance.
WITH avg_balance_per_currency AS (SELECT currency_code, AVG(balance) AS avg_balance
                                  FROM accounts
                                  GROUP BY currency_code)
SELECT a.customer_id, c.first_name, c.last_name, currency_code, SUM(a.balance) AS total_balance
FROM accounts a
         JOIN avg_balance_per_currency ab
              USING (currency_code)
         JOIN customers c
              USING (customer_id)
GROUP BY a.customer_id, c.first_name, c.last_name, a.currency_code, avg_balance
HAVING SUM(a.balance) > ab.avg_balance
ORDER BY total_balance DESC;


-- B7 Loans versus cards
-- Task. Using set operations, return:
-- (a) customers with a loan but no card (EXCEPT);
SELECT customer_id, first_name, last_name
FROM (SELECT DISTINCT customer_id
      FROM loans
      EXCEPT
      SELECT DISTINCT a.customer_id
      FROM cards
               JOIN accounts a
                    USING (account_id)) AS ct
         JOIN customers
              USING (customer_id);

-- (b) customers with both (INTERSECT);
SELECT customer_id, first_name, last_name
FROM (SELECT DISTINCT customer_id
      FROM loans
      INTERSECT
      SELECT DISTINCT a.customer_id
      FROM cards
               JOIN accounts a
                    USING (account_id)) AS ct
         JOIN customers
              USING (customer_id);

-- (c) customers with either (UNION).
SELECT customer_id, first_name, last_name
FROM (SELECT DISTINCT customer_id
      FROM loans
      UNION
      SELECT DISTINCT a.customer_id
      FROM cards
               JOIN accounts a
                    USING (account_id)) AS ct
         JOIN customers
              USING (customer_id);


-- B8 · Expiring cards
-- Task. List active cards expiring within 60 days.
SELECT last_four, expiry_date, expiry_date - CURRENT_DATE AS days_remaining
FROM cards
WHERE is_active
  AND CURRENT_DATE + INTERVAL '60 days' > expiry_date;


-- B9 · Shared national IDs
-- Task. Find national IDs held by more than one customer, then list the specific customer pairs sharing each ID.
WITH RECURSIVE duplication_national_ids AS (
SELECT c.customer_id, c.first_name, c.last_name, national_id
FROM customers c
JOIN (SELECT national_id
      FROM customers
      GROUP BY national_id
      HAVING COUNT(*) > 1) AS rn
USING (national_id)
)
SELECT *
FROM duplication_national_ids d1
JOIN duplication_national_ids d2
USING (national_id)
WHERE d1.customer_id < d2.customer_id;

-- B10 · Used every transaction type
-- Task. Find customers who have made deposits, withdrawals, AND transfers (across all their accounts).
WITH customer_txn_types AS (SELECT a.customer_id, t.type
                            FROM transactions t
                                     JOIN accounts a
                                          ON a.account_id = t.from_account_id

                            UNION

                            SELECT a.customer_id, t.type
                            FROM transactions t
                                     JOIN accounts a
                                          ON a.account_id = t.to_account_id)
SELECT customer_id, c.first_name, c.last_name
FROM customer_txn_types ctt
         JOIN customers c
              USING (customer_id)
GROUP BY customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT ctt.type) = 3;


-- B11 · Read the plan
-- Task. Write "total deposits per branch for 2024", joining transactions up to the branch.
-- Run EXPLAIN (ANALYZE) on the 1,000,000-row transactions table, propose an index, and compare plans.
EXPLAIN ANALYZE
SELECT a.branch_id, b.name, a.currency_code, SUM(t.amount) AS total_deposit
FROM transactions t
         JOIN accounts a
              ON t.to_account_id = a.account_id
         JOIN branches b
              ON a.branch_id = b.branch_id
WHERE t.type = 'deposit'
  AND EXTRACT(YEAR FROM t.created_at) = 2024
GROUP BY a.branch_id, b.name, a.currency_code