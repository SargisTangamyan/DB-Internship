-- Seeding the type, role, status tables

-- employee_roles
INSERT INTO employee_roles (code, label, sort_order)
VALUES ('teller', 'Teller', 1),
       ('customer_service_representative', 'Customer Service Representative', 2),
       ('loan_officer', 'Loan Officer', 3),
       ('branch_manager', 'Branch Manager', 4),
       ('operations_manager', 'Operations Manager', 5),
       ('auditor', 'Auditor', 6)
ON CONFLICT (code) DO NOTHING;

-- contact_types
INSERT INTO contact_types (code, label, sort_order)
VALUES ('email', 'Email', 1),
       ('phone', 'Phone', 2)
ON CONFLICT (code) DO NOTHING;

-- account_types
-- 'checking' is the DEFAULT on accounts.type — required.
INSERT INTO account_types (code, label, sort_order)
VALUES ('checking', 'Checking', 1),
       ('savings', 'Savings', 2),
       ('fixed_deposit', 'Fixed Deposit', 3),
       ('money_market', 'Money Market', 4),
       ('credit', 'Credit', 5),
       ('loan', 'Loan', 6),
       ('business', 'Business', 7)
ON CONFLICT (code) DO NOTHING;

-- account_statuses
-- 'active' is the DEFAULT on accounts.status — required.
INSERT INTO account_statuses (code, label, sort_order)
VALUES ('active', 'Active', 1),
       ('inactive', 'Inactive', 2),
       ('dormant', 'Dormant', 3),
       ('suspended', 'Suspended', 4),
       ('frozen', 'Frozen', 5),
       ('closed', 'Closed', 6),
       ('pending_approval', 'Pending Approval', 7)
ON CONFLICT (code) DO NOTHING;

-- cities
INSERT INTO cities (name, region, is_capital)
VALUES ('Yerevan', 'Yerevan', true),
       ('Gyumri', 'Shirak', false),
       ('Vanadzor', 'Lori', false),
       ('Vagharshapat', 'Armavir', false),
       ('Abovyan', 'Kotayk', false)
ON CONFLICT DO NOTHING;

-- currencies
INSERT INTO currencies (code, name, symbol, decimal_places)
VALUES ('AMD', 'Armenian Dram', '֏', 2),
       ('USD', 'US Dollar', '$', 2),
       ('EUR', 'Euro', '€', 2),
       ('RUB', 'Russian Ruble', '₽', 2)
ON CONFLICT (code) DO NOTHING;

-- payment_providers
-- Nullable on cards, but needed once you start inserting card rows with a provider.
INSERT INTO payment_providers (code, name)
VALUES ('visa_net', 'VisaNet'),
       ('mastercard_net', 'Mastercard Network'),
       ('amex_net', 'American Express Network'),
       ('arca', 'ArCa')
ON CONFLICT (code) DO NOTHING;

-- card_types
-- Referenced NOT NULL by cards.type, no default — must exist before card inserts.
INSERT INTO card_types (code, label, sort_order)
VALUES ('debit', 'Debit Card', 1),
       ('credit', 'Credit Card', 2),
       ('prepaid', 'Prepaid Card', 3),
       ('virtual', 'Virtual Card', 4),
       ('business', 'Business Card', 5)
ON CONFLICT (code) DO NOTHING;

-- card_brands
-- Referenced NOT NULL by cards.brand, no default — must exist before card inserts.
INSERT INTO card_brands (code, label, sort_order)
VALUES ('visa', 'Visa', 1),
       ('mastercard', 'Mastercard', 2),
       ('amex', 'American Express', 3),
       ('discover', 'Discover', 4),
       ('arca', 'ArCa', 5)
ON CONFLICT (code) DO NOTHING;

-- loan_statuses
-- 'pending' is the DEFAULT on loans.status — required.
INSERT INTO loan_statuses (code, label, sort_order)
VALUES ('pending', 'Pending', 1),
       ('approved', 'Approved', 2),
       ('active', 'Active', 3),
       ('delinquent', 'Delinquent', 4),
       ('paid_off', 'Paid Off', 5),
       ('defaulted', 'Defaulted', 6),
       ('rejected', 'Rejected', 7),
       ('overdue', 'Overdue', 8),
       ('cancelled', 'Cancelled', 9)
ON CONFLICT (code) DO NOTHING;

-- transaction_types
-- 'deposit', 'withdrawal', 'transfer' are hardcoded in the transactions type-shape CHECK — all three required.
INSERT INTO transaction_types (code, label, sort_order)
VALUES ('deposit', 'Deposit', 1),
       ('withdrawal', 'Withdrawal', 2),
       ('transfer', 'Transfer', 3)
ON CONFLICT (code) DO NOTHING;