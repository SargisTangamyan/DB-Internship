-- dependent tables
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS employee_contacts;
DROP TABLE IF EXISTS customer_contacts;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS branches;
DROP TABLE IF EXISTS cities;

-- look up tables
DROP TABLE IF EXISTS transaction_types;
DROP TABLE IF EXISTS loan_statuses;
DROP TABLE IF EXISTS card_brands;
DROP TABLE IF EXISTS card_types;
DROP TABLE IF EXISTS payment_providers;
DROP TABLE IF EXISTS currencies;
DROP TABLE IF EXISTS account_statuses;
DROP TABLE IF EXISTS account_types;
DROP TABLE IF EXISTS contact_types;
DROP TABLE IF EXISTS employee_roles;

-- customer_contacts
DROP INDEX IF EXISTS uq_customer_primary_contact;
DROP INDEX IF EXISTS idx_customer_contacts_customer;

-- employee_contacts
DROP INDEX IF EXISTS uq_employee_primary_contact;
DROP INDEX IF EXISTS idx_employee_contacts_employee;

-- accounts
DROP INDEX IF EXISTS idx_accounts_customer;

-- cards
DROP INDEX IF EXISTS idx_cards_account;

-- loans
DROP INDEX IF EXISTS idx_loans_customer;

-- transactions
DROP INDEX IF EXISTS idx_transactions_from_account_time;
DROP INDEX IF EXISTS idx_transactions_to_account_time;

-- TYPE TABLES
CREATE TABLE IF NOT EXISTS employee_roles
(
    code        varchar(50) PRIMARY KEY,
    label       varchar(100) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS contact_types
(
    contact_type_id smallint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code        varchar(20) NOT NULL UNIQUE,
    label       varchar(50) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS account_types
(
    code        varchar(20) PRIMARY KEY,
    label       varchar(50) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS account_statuses
(
    code        varchar(20) PRIMARY KEY,
    label       varchar(50) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS cities
(
    city_id    integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name       text    NOT NULL,
    region     text,
    is_capital boolean NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS currencies
(
    code           char(3) PRIMARY KEY CHECK ( code ~ '^[A-Z]{3}$' ),
    name           text     NOT NULL,
    symbol         text,
    decimal_places smallint NOT NULL DEFAULT 2
);

CREATE TABLE IF NOT EXISTS payment_providers
(
    code      varchar(30) PRIMARY KEY,
    name      text    NOT NULL,
    is_active boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS card_types
(
    code        varchar(20) PRIMARY KEY,
    label       varchar(50) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS card_brands
(
    code        varchar(20) PRIMARY KEY,
    label       varchar(50) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS loan_statuses
(
    code        varchar(20) PRIMARY KEY,
    label       varchar(50) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS transaction_types
(
    code        varchar(20) PRIMARY KEY,
    label       varchar(50) NOT NULL,
    description text,
    sort_order  smallint    NOT NULL DEFAULT 0,
    is_active   boolean     NOT NULL DEFAULT true
);

-- Tables
CREATE TABLE IF NOT EXISTS branches
(
    branch_id  smallint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    code       varchar(12) NOT NULL UNIQUE,
    name       text        NOT NULL,
    address    text        NOT NULL,
    city_id    integer    NOT NULL REFERENCES cities (city_id)
        ON DELETE RESTRICT,
    is_active  boolean     NOT NULL DEFAULT true,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS employees
(
    employee_id   integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role          varchar(50) NOT NULL REFERENCES employee_roles (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    hire_date     date        NOT NULL,
    branch_id     smallint    NOT NULL REFERENCES branches (branch_id) ON DELETE RESTRICT,

    first_name    text        NOT NULL,
    last_name     text        NOT NULL,
    date_of_birth date        NOT NULL,
    national_id   text        NOT NULL UNIQUE,
    is_active     boolean     NOT NULL DEFAULT true,
    address       text        NOT NULL,
    city_id       integer    NOT NULL REFERENCES cities (city_id)
        ON DELETE RESTRICT,

    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS customers
(
    customer_id   integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    first_name    text        NOT NULL,
    last_name     text        NOT NULL,
    date_of_birth date        NOT NULL,
    national_id   text        NOT NULL UNIQUE,
    is_active     boolean     NOT NULL DEFAULT true,
    address       text        NOT NULL,
    city_id       integer    NOT NULL REFERENCES cities (city_id)
        ON DELETE RESTRICT,

    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS customer_contacts
(
    contact_id   integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id  integer     NOT NULL REFERENCES customers (customer_id) ON DELETE CASCADE,
    contact_type_id smallint NOT NULL REFERENCES contact_types (contact_type_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    value        text        NOT NULL,
    is_primary   boolean     NOT NULL DEFAULT false
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_customer_primary_contact
    ON customer_contacts (customer_id, contact_type_id)
    WHERE is_primary;

CREATE INDEX IF NOT EXISTS idx_customer_contacts_customer ON customer_contacts(customer_id);

CREATE TABLE IF NOT EXISTS employee_contacts
(
    contact_id   integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    employee_id  integer     NOT NULL REFERENCES employees (employee_id) ON DELETE CASCADE,
    contact_type_id smallint NOT NULL REFERENCES contact_types (contact_type_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    value        text        NOT NULL,
    is_primary   boolean     NOT NULL DEFAULT false
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_employee_primary_contact
    ON employee_contacts (employee_id, contact_type_id)
    WHERE is_primary;

CREATE INDEX IF NOT EXISTS idx_employee_contacts_employee ON employee_contacts(employee_id);

CREATE TABLE IF NOT EXISTS accounts
(
    account_id     bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id    integer        NOT NULL REFERENCES customers (customer_id) ON DELETE RESTRICT,
    branch_id      smallint       NOT NULL REFERENCES branches (branch_id) ON DELETE RESTRICT,
    account_number varchar(34)    NOT NULL UNIQUE,
    type           varchar(20)    NOT NULL DEFAULT 'checking' REFERENCES account_types (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    balance        numeric(15, 2) NOT NULL DEFAULT 0,
    currency_code  char(3)        NOT NULL REFERENCES currencies (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    open_date      date           NOT NULL DEFAULT CURRENT_DATE,
    status         varchar(20)    NOT NULL DEFAULT 'active' REFERENCES account_statuses (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    created_at     timestamptz    NOT NULL DEFAULT now(),
    updated_at     timestamptz    NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_accounts_customer ON accounts (customer_id);

CREATE TABLE IF NOT EXISTS cards
(
    card_id       integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    account_id    bigint      NOT NULL REFERENCES accounts (account_id) ON DELETE RESTRICT,
    last_four     char(4)     NOT NULL CHECK ( last_four ~ '^[0-9]{4}$' ),
    payment_token text        NOT NULL UNIQUE,
    provider_code varchar(30) REFERENCES payment_providers (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    type          varchar(20) NOT NULL REFERENCES card_types (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    brand         varchar(20) NOT NULL REFERENCES card_brands (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    credit_limit  numeric(15, 2) CHECK (credit_limit IS NULL OR credit_limit > 0),
    expiry_date   date        NOT NULL CHECK (expiry_date > created_at::date),
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now(),
    is_active     boolean     NOT NULL DEFAULT true,

    CONSTRAINT credit_cards_require_limit CHECK (type <> 'credit' OR credit_limit IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_cards_account ON cards (account_id);

CREATE TABLE IF NOT EXISTS loans
(
    loan_id       bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id   integer        NOT NULL REFERENCES customers (customer_id) ON DELETE RESTRICT,
    branch_id     smallint       NOT NULL REFERENCES branches (branch_id) ON DELETE RESTRICT,
    amount        numeric(15, 2) NOT NULL CHECK (amount > 0),
    interest_rate numeric(4, 2)  NOT NULL CHECK (interest_rate > 0 AND interest_rate <= 100),
    term_months   integer        NOT NULL CHECK (term_months > 0),
    start_date    date           NOT NULL DEFAULT CURRENT_DATE,
    created_at    timestamptz    NOT NULL DEFAULT now(),
    updated_at    timestamptz    NOT NULL DEFAULT now(),
    status        varchar(20)    NOT NULL DEFAULT 'pending' REFERENCES loan_statuses (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_loans_customer ON loans(customer_id);

CREATE TABLE IF NOT EXISTS transactions
(
    transaction_id  bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    amount          numeric(15, 2) NOT NULL CHECK (amount > 0),
    type            varchar(20)    NOT NULL REFERENCES transaction_types (code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    created_at      timestamptz    NOT NULL DEFAULT now(),
    description     text,
    from_account_id bigint REFERENCES accounts (account_id) ON DELETE RESTRICT,
    to_account_id   bigint REFERENCES accounts (account_id) ON DELETE RESTRICT,
    metadata        jsonb,

    CHECK (from_account_id IS DISTINCT FROM to_account_id),
    CHECK (
        (type = 'deposit' AND from_account_id IS NULL AND to_account_id IS NOT NULL) OR
        (type = 'withdrawal' AND from_account_id IS NOT NULL AND to_account_id IS NULL) OR
        (type = 'transfer' AND from_account_id IS NOT NULL AND to_account_id IS NOT NULL)
        )
);

CREATE INDEX IF NOT EXISTS idx_transactions_from_account_time ON transactions (from_account_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_to_account_time ON transactions (to_account_id, created_at DESC);
