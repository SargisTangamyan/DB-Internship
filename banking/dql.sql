-- FILTERING
-- Find all accounts opened in the last 90 days with a balance over 100,000 USD
SELECT *
FROM accounts
WHERE open_date + INTERVAL '90 days' >= CURRENT_DATE
  AND currency_code = 'USD'
  AND balance > 100000;

-- List all customer born before 1970 who are still active
SELECT *
FROM customers
WHERE date_of_birth < DATE '1970-01-01'
  AND is_active;

-- Find all withdrawals of more than 4,000 that happened in the last 30 days
SELECT *
FROM transactions
WHERE amount > 4000
  AND type = 'withdrawal'
  AND created_at >= now() - INTERVAL '30 days';

-- Find all credit cards expiring within the next 6 months that are still active
SELECT *
FROM cards
WHERE type = 'credit'
  AND is_active
  AND expiry_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '6 months';

-- Find all transactions made through the atm channel (metadata) with an amount over 1000
SELECT *
FROM transactions
WHERE amount > 1000
  AND metadata::jsonb ->> 'channel' = 'atm';

-- List all loans with an interest rate above 15% that are neither paid_off nor defaulted
SELECT *
FROM loans
WHERE interest_rate >= 15
  AND status NOT IN ('paid_off', 'defaulted');


-- JOINS
-- List every account together with its owner's full name and the name of the branch it belongs to
SELECT c.first_name,
       c.last_name,
       b.name AS branch_name,
       a.account_id,
       a.account_number,
       a.type,
       a.balance,
       a.currency_code,
       a.open_date
FROM accounts a
         JOIN customers c
              ON a.customer_id = c.customer_id
         JOIN branches b
              ON a.branch_id = b.branch_id;

-- Show each card's last four digits, its type label and brand label (from the lookup tables, not the codes), and the account number it's linked to
SELECT c.last_four,
       ct.label AS type_label,
       cb.label AS brand_label,
       a.account_number
FROM cards c
         LEFT JOIN card_types ct
                   ON c.type = ct.code
         LEFT JOIN card_brands cb
                   ON c.brand = cb.code
         LEFT JOIN accounts a
                   ON c.account_id = a.account_id
LIMIT 10;

-- List all customers who live in the same city as the branch where they hold at least on account
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM accounts a
         JOIN customers c
              ON a.customer_id = c.customer_id
         JOIN branches b
              ON a.branch_id = b.branch_id
WHERE c.city_id = b.city_id;

-- Find all transactions (amount, type, date) involving accounts owned by the same customer (on both sides)
SELECT t.amount, t.type, t.created_at AS date
FROM transactions t
         JOIN accounts a1
              ON t.from_account_id = a1.account_id
         JOIN accounts a2
              ON t.to_account_id = a2.account_id
WHERE a1.customer_id = a2.customer_id;

-- List all employees together with their branch name, city name, and primary email address
SELECT e.employee_id, e.first_name, e.last_name, b.name AS branch_name, c.name AS city, ec.value AS email
FROM employees e
         JOIN branches b
              ON e.branch_id = b.branch_id
         JOIN cities c
              ON e.city_id = c.city_id
         JOIN employee_contacts ec
              ON e.employee_id = ec.employee_id
WHERE contact_type_id = (SELECT contact_type_id FROM contact_types WHERE code = 'email')
  AND is_primary;

-- Find all customer who have a loan at a branch in a city they do not live in
SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM customers c
         JOIN loans l
              ON c.customer_id = l.customer_id
         JOIN branches b
              ON l.branch_id = b.branch_id
WHERE c.city_id <> b.city_id;


-- GROUP BY
-- Count how many accounts exist per account type
SELECT type, COUNT(*) account_count
FROM accounts
GROUP BY type;

-- For each branch, show the number of accounts and the total balance held there
SELECT b.name, COUNT(*) AS account_count, SUM(a.balance) AS total_balance
FROM accounts a
         RIGHT JOIN branches b
                    ON a.branch_id = b.branch_id
GROUP BY b.branch_id;

-- Find all customer who own more than 3 accounts
SELECT c.customer_id, c.first_name, c.last_name, COUNT(a.account_id) AS account_count
FROM accounts a
         JOIN customers c
              ON a.customer_id = c.customer_id
GROUP BY c.customer_id
HAVING COUNT(a.account_id) > 3;

-- For each transaction type and channel (metadata), show the count and average amount
SELECT type,
       metadata::jsonb ->> 'channel' AS channel,
       COUNT(*)                      AS transaction_count,
       ROUND(AVG(amount), 2)         AS avg_amount
FROM transactions
GROUP BY type, channel;

-- Find all branches where the average loan amount exceeds 25,000,000
SELECT b.name, ROUND(AVG(l.amount), 2) AS avg_loan
FROM loans l
         JOIN branches b
              ON l.branch_id = b.branch_id
GROUP BY b.branch_id
HAVING AVG(l.amount) > 25_000_000;

-- Find all accounts that have had more than 10 outgoing transactions, showing the count and total outgoing amount
SELECT a.account_id, a.account_number, COUNT(t.transaction_id) AS transaction_count, SUM(t.amount) AS total_amount
FROM transactions t
         JOIN accounts a
              ON t.from_account_id = a.account_id
GROUP BY a.account_id
HAVING COUNT(t.transaction_id) > 10;

-- For each currency, count the accounts and sum the balances, but only show currencies with at least 300 accounts
SELECT currency_code, COUNT(*) AS account_count, SUM(balance) AS balance_total
FROM accounts
GROUP BY currency_code
HAVING COUNT(*) >= 300;


-- ORDER BY / LIMIT
-- Show the 10 most recent transactions with their type and amount
SELECT transaction_id, type, amount, created_at
FROM transactions
ORDER BY created_at DESC, transaction_id DESC
LIMIT 10;

-- Find the 5 customers with the highest combined balance across all their USD accounts
SELECT c.customer_id, c.first_name, c.last_name, SUM(a.balance) AS total_balance
FROM accounts a
         JOIN customers c
              ON a.customer_id = c.customer_id
WHERE a.currency_code = 'USD'
GROUP BY c.customer_id
ORDER BY total_balance DESC, c.customer_id
LIMIT 5;

-- Show the 3 largest transfers of the past year (calendar year), including both account number involved
SELECT a1.account_number AS from_account, a2.account_number AS to_account, t.created_at AS transfer_date, t.amount
FROM transactions t
         JOIN accounts a1
              ON t.from_account_id = a1.account_id
         JOIN accounts a2
              ON t.to_account_id = a2.account_id
WHERE t.type = 'transfer'
  AND EXTRACT(YEAR FROM t.created_at) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
ORDER BY amount DESC
LIMIT 3;

-- List 10 oldest still-active accounts (by open date).
SELECT *
FROM accounts
WHERE status = 'active'
ORDER BY open_date, account_id
LIMIT 10;

-- Rank branches by total transaction volume in AMD flowing through their accounts, top 5
SELECT b.name, SUM(total_amount) AS total
FROM (SELECT a1.branch_id, SUM(t.amount) AS total_amount
      FROM transactions t
               JOIN accounts a1
                    ON t.from_account_id = a1.account_id
      WHERE a1.currency_code = 'AMD'
      GROUP BY a1.branch_id

      UNION ALL

      SELECT a2.branch_id, SUM(t.amount) AS total_amount
      FROM transactions t
               JOIN accounts a2
                    ON t.to_account_id = a2.account_id
      WHERE a2.currency_code = 'AMD'
      GROUP BY a2.branch_id) AS bt
         JOIN branches b
              ON b.branch_id = bt.branch_id
GROUP BY b.branch_id
ORDER BY total DESC
LIMIT 5;


-- EVERYTHING COMBINED
-- For each account type, show the number of active accounts, average balance, and total balance in EUR
-- only for types averaging over 500,000 - sorted by total descending
SELECT type, COUNT(*) AS active_account_count, ROUND(AVG(balance), 2) AS avg_balance, SUM(balance) AS total_balance
FROM accounts
WHERE status = 'active'
  AND currency_code = 'EUR'
GROUP BY type
HAVING AVG(balance) > 500_000
ORDER BY total_balance DESC;

-- Find the top 10 customers by total outgoing transaction amount (in AMD) in the last 180 days, showing name, number of outgoing transaction, and the total
SELECT c.customer_id, c.first_name, c.last_name, COUNT(*) AS transaction_count, SUM(t.amount) AS total_amount
FROM transactions t
         JOIN accounts a
              ON t.from_account_id = a.account_id
         JOIN customers c
              ON a.customer_id = c.customer_id
WHERE a.currency_code = 'AMD'
  AND t.created_at >= now() - INTERVAL '180 days'
GROUP BY c.customer_id
ORDER BY total_amount DESC
LIMIT 10;

-- For each branch, show its busiest month (the calendar month with the most transactions through its accounts) and that month's count
SELECT DISTINCT ON (t2.branch_id) b.name, t2.month, t2.occurrency
FROM (SELECT branch_id, month, COUNT(*) AS occurrency
      FROM (SELECT date_trunc('month', t.created_at) AS month, a.branch_id
            FROM transactions t
                     JOIN accounts a
                          ON t.from_account_id = a.account_id

            UNION ALL

            SELECT date_trunc('month', t.created_at) AS month, a.branch_id
            FROM transactions t
                     JOIN accounts a
                          ON t.to_account_id = a.account_id) AS br
      GROUP BY branch_id, month) AS t2
JOIN branches b
ON t2.branch_id = b.branch_id
ORDER BY t2.branch_id, t2.occurrency DESC;