-- Data Reset
TRUNCATE branches CASCADE;
TRUNCATE employee_contacts CASCADE;
TRUNCATE employees CASCADE;
TRUNCATE customer_contacts CASCADE;
TRUNCATE customers CASCADE;
TRUNCATE accounts CASCADE;
TRUNCATE cards CASCADE;
TRUNCATE loans CASCADE;
TRUNCATE transactions CASCADE;

-- Branches
INSERT INTO branches (code, name, address, city_id)
VALUES ('BR001', 'Yerevan Central Branch', '10 Mashtots Ave, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR002', 'Yerevan Kentron Branch', '25 Abovyan St, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR003', 'Yerevan Republic Square Branch', '2 Republic Square, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR004', 'Yerevan Arabkir Branch', '48 Komitas Ave, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR005', 'Yerevan Malatia Branch', '17 Isakov Ave, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR006', 'Yerevan Davtashen Branch', '5 Admiral Isakov 4th St, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR007', 'Gyumri Main Branch', '3 Vardanants St, Gyumri', (SELECT city_id FROM cities WHERE name = 'Gyumri')),
       ('BR008', 'Gyumri Central Square Branch', '12 Ryzhkov St, Gyumri',
        (SELECT city_id FROM cities WHERE name = 'Gyumri')),
       ('BR009', 'Vanadzor Main Branch', '8 Tigran Mets St, Vanadzor',
        (SELECT city_id FROM cities WHERE name = 'Vanadzor')),
       ('BR010', 'Vanadzor Trade Center Branch', '21 Grigor Lusavorich St, Vanadzor',
        (SELECT city_id FROM cities WHERE name = 'Vanadzor')),
       ('BR011', 'Vagharshapat Branch', '6 Mesrop Mashtots St, Vagharshapat',
        (SELECT city_id FROM cities WHERE name = 'Vagharshapat')),
       ('BR012', 'Abovyan Branch', '14 Yerevanyan St, Abovyan', (SELECT city_id FROM cities WHERE name = 'Abovyan')),
       ('BR013', 'Yerevan Nor Nork Branch', '33 Sasuntsi Davit St, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR014', 'Yerevan Ajapnyak Branch', '9 Gai Ave, Yerevan', (SELECT city_id FROM cities WHERE name = 'Yerevan')),
       ('BR015', 'Yerevan Erebuni Branch', '41 Erebuni St, Yerevan',
        (SELECT city_id FROM cities WHERE name = 'Yerevan'))
ON CONFLICT (code) DO NOTHING;

-- Employees
INSERT INTO employees (role, hire_date, branch_id, first_name, last_name, date_of_birth, national_id, is_active,
                       address, city_id)
SELECT
    -- role distribution: mostly frontline, few management (weighted, not uniform random)
    CASE
        WHEN gs % 15 IN (0, 1, 2, 3, 4) THEN 'teller'
        WHEN gs % 15 IN (5, 6, 7, 8) THEN 'customer_service_representative'
        WHEN gs % 15 IN (9, 10, 11) THEN 'loan_officer'
        WHEN gs % 15 = 12 THEN 'branch_manager'
        WHEN gs % 15 = 13 THEN 'operations_manager'
        ELSE 'auditor'
        END                                                                      AS role,
    CURRENT_DATE - (365 * (1 + (gs % 12)) + (gs * 7 % 300))::int                 AS hire_date,
    -- 5 employees per branch, cycling through all 15 branches in order
    (SELECT branch_id FROM branches ORDER BY code LIMIT 1 OFFSET ((gs - 1) / 5)) AS branch_id,
    (ARRAY ['Armen','Anahit','Davit','Lilit','Gagik','Narine','Vardan','Karine',
        'Hrant','Marine','Tigran','Sona','Artak','Anush','Sargis','Ani',
        'Aram','Gohar','Vahagn','Mariam','Karen','Hasmik','Ashot','Nune',
        'Levon','Diana','Suren','Rima','Grigor','Elen'])[1 + (gs % 30)]          AS first_name,
    (ARRAY ['Sargsyan','Grigoryan','Hakobyan','Petrosyan','Avetisyan','Poghosyan',
        'Harutyunyan','Manukyan','Ghazaryan','Vardanyan','Simonyan','Baghdasaryan',
        'Karapetyan','Mkrtchyan','Tovmasyan'])[1 + (gs % 15)]                    AS last_name,
    date '1965-01-01' + (gs * 137 % 14000)                                       AS date_of_birth,
    'EMPNID' || lpad(gs::text, 8, '0')                                           AS national_id,
    true                                                                         AS is_active,
    (gs * 3 + 10)::text || ' ' ||
    (ARRAY ['Mashtots Ave','Komitas Ave','Abovyan St','Tigran Mets St',
        'Isakov Ave','Sayat-Nova Ave','Baghramyan Ave'])[1 + (gs % 7)]           AS address,
    (SELECT city_id
     FROM cities
     ORDER BY city_id
     LIMIT 1 OFFSET (gs * 13) % (SELECT count(*) FROM cities))                   AS city_id
FROM generate_series(1, 75) AS gs;

CREATE OR REPLACE FUNCTION contact_type_id(p_code varchar)
RETURNS smallint AS $$
    SELECT contact_type_id FROM contact_types WHERE code = p_code;
$$ LANGUAGE sql STABLE;

-- give every employee a primary work email
INSERT INTO employee_contacts (employee_id, contact_type_id, value, is_primary)
SELECT e.employee_id,
       contact_type_id('email'),
       lower(e.first_name) || '.' || lower(e.last_name) || e.employee_id || '@gmail.com',
       true
FROM employees e
WHERE NOT EXISTS (SELECT 1
                  FROM employee_contacts c
                  WHERE c.employee_id = e.employee_id
                    AND c.contact_type_id = contact_type_id('email')
                    AND c.is_primary);

-- give every employee a primary phone number
INSERT INTO employee_contacts (employee_id, contact_type_id, value, is_primary)
SELECT e.employee_id,
       contact_type_id('phone'),
       '+374' || (10000000 + floor(random() * 90000000))::bigint::text,
       true
FROM employees e
WHERE NOT EXISTS (SELECT 1
                  FROM employee_contacts c
                  WHERE c.employee_id = e.employee_id
                    AND c.contact_type_id = contact_type_id('phone')
                    AND c.is_primary);

-- generate secondary (non-primary) emails
INSERT INTO employee_contacts (employee_id, contact_type_id, value, is_primary)
SELECT e.employee_id,
       contact_type_id('email'),
       'secondary_' || lower(e.first_name) || '.' || e.employee_id || '@gmail.com',
       false
FROM employees e
WHERE NOT EXISTS (SELECT 1
                  FROM employee_contacts c
                  WHERE c.employee_id = e.employee_id
                    AND c.contact_type_id = contact_type_id('email')
                    AND NOT c.is_primary);

-- generate secondary (non-primary) phone numbers
INSERT INTO employee_contacts (employee_id, contact_type_id, value, is_primary)
SELECT e.employee_id,
       contact_type_id('phone'),
       '+374' || (10000000 + floor(random() * 90000000))::bigint::text,
       false
FROM employees e
WHERE NOT EXISTS (SELECT 1
                  FROM employee_contacts c
                  WHERE c.employee_id = e.employee_id
                    AND c.contact_type_id = contact_type_id('phone')
                    AND NOT c.is_primary);

-- Customers
INSERT INTO customers (first_name, last_name, date_of_birth, national_id, is_active, address, city_id)
SELECT (ARRAY ['Armen','Anahit','Davit','Lilit','Gagik','Narine','Vardan','Karine',
    'Hrant','Marine','Tigran','Sona','Artak','Anush','Sargis','Ani',
    'Aram','Gohar','Vahagn','Mariam','Karen','Hasmik','Ashot','Nune',
    'Levon','Diana','Suren','Rima','Grigor','Elen','Rafael','Zara',
    'Norayr','Silva','Vahe','Astghik','Edgar','Lusine','Rubik','Meline'
    ])[1 + (gs % 40)]                                  AS first_name,
       (ARRAY ['Sargsyan','Grigoryan','Hakobyan','Petrosyan','Avetisyan','Poghosyan',
           'Harutyunyan','Manukyan','Ghazaryan','Vardanyan','Simonyan','Baghdasaryan',
           'Karapetyan','Mkrtchyan','Tovmasyan','Melkonyan','Sahakyan','Danielyan',
           'Martirosyan','Stepanyan'
           ])[1 + (gs % 20)]                           AS last_name,
       date '1945-01-01' + (gs * 977 % 29000)          AS date_of_birth, -- spreads ages roughly 16-96
       'CNID' || lpad(gs::text, 9, '0')                AS national_id,   -- guaranteed unique via gs
       (random() < 0.97)                               AS is_active,     -- ~97% active, some inactive
       (10 + (gs * 7 % 200))::text || ' ' ||
       (ARRAY ['Mashtots Ave','Komitas Ave','Abovyan St','Tigran Mets St',
           'Isakov Ave','Sayat-Nova Ave','Baghramyan Ave','Nalbandyan St',
           'Khanjyan St','Teryan St'
           ])[1 + (gs % 10)]                           AS address,
       b.lo + floor(random() * (b.hi - b.lo + 1))::int AS city_id
FROM generate_series(1, 1000) AS gs
         CROSS JOIN (SELECT min(city_id) lo, max(city_id) hi FROM cities) b;

-- give every customer a primary email
INSERT INTO customer_contacts (customer_id, contact_type_id, value, is_primary)
SELECT c.customer_id,
       contact_type_id('email'),
       lower(c.first_name) || '.' || lower(c.last_name) || c.customer_id || '@example.com',
       true
FROM customers c
WHERE NOT EXISTS (SELECT 1
                  FROM customer_contacts cc
                  WHERE cc.customer_id = c.customer_id
                    AND cc.contact_type_id = contact_type_id('email')
                    AND cc.is_primary);

-- give every customer a primary phone number
INSERT INTO customer_contacts (customer_id, contact_type_id, value, is_primary)
SELECT c.customer_id,
       contact_type_id('phone'),
       '+374' || (10000000 + floor(random() * 90000000))::bigint::text,
       true
FROM customers c
WHERE NOT EXISTS (SELECT 1
                  FROM customer_contacts cc
                  WHERE cc.customer_id = c.customer_id
                    AND cc.contact_type_id = contact_type_id('phone')
                    AND cc.is_primary);

-- generate secondary (non-primary) emails for a subset of customers
INSERT INTO customer_contacts (customer_id, contact_type_id, value, is_primary)
SELECT c.customer_id,
       contact_type_id('email'),
       'secondary_' || lower(c.first_name) || '.' || c.customer_id || '@example.com',
       false
FROM customers c
WHERE random() < 0.3 -- ~30% of customers have a secondary email
  AND NOT EXISTS (SELECT 1
                  FROM customer_contacts cc
                  WHERE cc.customer_id = c.customer_id
                    AND cc.contact_type_id = contact_type_id('email')
                    AND NOT cc.is_primary);

-- generate secondary (non-primary) phone numbers for a subset of customers
INSERT INTO customer_contacts (customer_id, contact_type_id, value, is_primary)
SELECT c.customer_id,
       contact_type_id('phone'),
       '+374' || (10000000 + floor(random() * 90000000))::bigint::text,
       false
FROM customers c
WHERE random() < 0.3 -- ~30% of customers have a secondary phone
  AND NOT EXISTS (SELECT 1
                  FROM customer_contacts cc
                  WHERE cc.customer_id = c.customer_id
                    AND cc.contact_type_id = contact_type_id('phone')
                    AND NOT cc.is_primary);

-- Accounts
INSERT INTO accounts (customer_id, branch_id, account_number, type, balance, currency_code, open_date, status)
SELECT c.lo + floor(random() * (c.hi - c.lo + 1))::int,
       (branches_arr.ids)[1 + floor(random() * array_length(branches_arr.ids, 1))::int],
       'ACC' || lpad(gs::text, 12, '0'),
       (types_arr.codes)[1 + floor(random() * array_length(types_arr.codes, 1))::int],
       round((random() * 2000000)::numeric, 2),
       (curr_arr.codes)[1 + floor(random() * array_length(curr_arr.codes, 1))::int],
       CURRENT_DATE - (floor(random() * 3650))::int,
       (ARRAY ['active','active','active','active','active','active',
           'active','dormant','inactive','closed'])[1 + floor(random() * 10)::int]
FROM generate_series(1, 1200) AS gs
         CROSS JOIN (SELECT min(customer_id) lo, max(customer_id) hi FROM customers) c
         CROSS JOIN (SELECT array_agg(branch_id) ids FROM branches) branches_arr
         CROSS JOIN (SELECT array_agg(code) codes FROM account_types) types_arr
         CROSS JOIN (SELECT array_agg(code) codes FROM currencies) curr_arr;

-- Cards
INSERT INTO cards (account_id, last_four, payment_token, provider_code, type, brand, credit_limit, expiry_date,
                   created_at, is_active)
SELECT a.lo + floor(random() * (a.hi - a.lo + 1))::bigint                       AS account_id,
       lpad(floor(random() * 10000)::text, 4, '0')                              AS last_four,
       'TOK' || gs || md5(random()::text || gs::text)                           AS payment_token,
       (pp_arr.codes)[1 + floor(random() * array_length(pp_arr.codes, 1))::int] AS provider_code,
       picked.type_code                                                         AS type,
       (cb_arr.codes)[1 + floor(random() * array_length(cb_arr.codes, 1))::int] AS brand,
       CASE
           WHEN picked.type_code = 'credit'
               THEN round((random() * 20000 + 500)::numeric, 2)
           END                                                                  AS credit_limit,
       picked.ts + interval '3 years'                                           AS expiry_date,
       picked.ts                                                                AS created_at,
       (random() < 0.95) AND picked.ts + interval '3 years' > now()             AS is_active
FROM generate_series(1, 1000) AS gs
         CROSS JOIN (SELECT min(account_id) lo, max(account_id) hi FROM accounts) a
         CROSS JOIN (SELECT array_agg(code) codes FROM payment_providers) pp_arr
         CROSS JOIN (SELECT array_agg(code) codes FROM card_types) ct_arr
         CROSS JOIN (SELECT array_agg(code) codes FROM card_brands) cb_arr
         CROSS JOIN LATERAL (
    SELECT (ct_arr.codes)[1 + floor(random() * array_length(ct_arr.codes, 1))::int] AS type_code,
           now() - (random() * interval '1500 days')                                AS ts
    WHERE gs > 0
    ) picked;

-- Loans
INSERT INTO loans (customer_id, branch_id, amount, interest_rate, term_months, start_date, status)
SELECT c.lo + floor(random() * (c.hi - c.lo + 1))::int                                    AS customer_id,
       (br_arr.ids)[1 + floor(random() * array_length(br_arr.ids, 1))::int]               AS branch_id,
       round((random() * 49900000 + 100000)::numeric, 2)                                  AS amount,
       round((random() * 19 + 1)::numeric, 2)                                             AS interest_rate,
       (ARRAY [12, 24, 36, 48, 60, 120, 180, 240, 360])[1 + floor(random() * 9)::int]     AS term_months,
       CURRENT_DATE - (floor(random() * 3650))::int                                       AS start_date,
       (ARRAY ['active','active','active','active','paid_off','paid_off',
           'pending','approved','delinquent','defaulted'])[1 + floor(random() * 10)::int] AS status
FROM generate_series(1, 50000) AS gs
         CROSS JOIN (SELECT min(customer_id) lo, max(customer_id) hi FROM customers) c
         CROSS JOIN (SELECT array_agg(branch_id) ids FROM branches) br_arr;

-- Transactions
INSERT INTO transactions (amount, type, created_at, description, from_account_id, to_account_id, metadata)
SELECT round((random() * 4999 + 1)::numeric, 2) AS amount,
       picked.type_code                         AS type,
       now() - (random() * interval '730 days') AS created_at,
       'Generated transaction #' || gs          AS description,
       CASE
           WHEN picked.type_code IN ('withdrawal', 'transfer')
               THEN picked.acc1
           END                                  AS from_account_id,
       CASE
           WHEN picked.type_code IN ('deposit', 'transfer')
               THEN picked.acc2
           END                                  AS to_account_id,
       CASE picked.type_code
           WHEN 'deposit' THEN jsonb_build_object(
                   'channel', (ARRAY ['branch','atm','mobile_app','bank_transfer'])[1 + floor(random() * 4)::int],
                   'reference', 'DEP-' || gs,
                   'teller_verified', random() < 0.4
                               )
           WHEN 'withdrawal' THEN jsonb_build_object(
                   'channel', (ARRAY ['atm','branch','pos'])[1 + floor(random() * 3)::int],
                   'atm_id', CASE
                                 WHEN random() < 0.6
                                     THEN 'ATM-' || lpad(floor(random() * 500)::text, 4, '0')
                       END,
                   'fee', round((random() * 3)::numeric, 2)
                                  )
           WHEN 'transfer' THEN jsonb_build_object(
                   'channel', (ARRAY ['mobile_app','internet_banking','branch','swift'])[1 + floor(random() * 4)::int],
                   'reference', 'TRF-' || gs,
                   'purpose_code',
                   (ARRAY ['salary','rent','invoice','personal','utilities'])[1 + floor(random() * 5)::int],
                   'is_international', random() < 0.08
                                )
           END                                  AS metadata
FROM generate_series(1, 10000) AS gs
         CROSS JOIN (SELECT min(account_id) lo, max(account_id) hi FROM accounts) a
         CROSS JOIN LATERAL (
    SELECT (ARRAY ['deposit','withdrawal','transfer'])[1 + floor(random() * 3)::int] AS type_code,
           a.lo + floor(random() * (a.hi - a.lo + 1))::bigint                        AS acc1,
           a.lo + floor(random() * (a.hi - a.lo + 1))::bigint                        AS acc2
    WHERE gs > 0
    ) picked
WHERE picked.acc1 <> picked.acc2
   OR picked.type_code <> 'transfer';