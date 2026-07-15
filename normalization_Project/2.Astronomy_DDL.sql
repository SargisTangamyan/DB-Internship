-- ============================================================================
-- 1. SETUP SCHEMA AND PATH
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS astronomy;
SET search_path TO astronomy, public;

-- ============================================================================
-- 2. DDL DEFINITIONS , WE USED CASCADE DROPS TO MAKE OUR CODE RE-RUNNABLE
-- ============================================================================
DROP TABLE IF EXISTS observation CASCADE;
DROP TABLE IF EXISTS telescope CASCADE;
DROP TABLE IF EXISTS telescope_models CASCADE;
DROP TABLE IF EXISTS telescope_type CASCADE;
DROP TABLE IF EXISTS observatory CASCADE;
DROP TABLE IF EXISTS countries CASCADE;
DROP TABLE IF EXISTS observation_object CASCADE;
DROP TABLE IF EXISTS constellation CASCADE;
DROP TABLE IF EXISTS observation_object_type CASCADE;
DROP TABLE IF EXISTS observation_object_designation CASCADE;
DROP TABLE IF EXISTS observer CASCADE;
DROP TABLE IF EXISTS affiliation CASCADE;
DROP TABLE IF EXISTS experience_type CASCADE;
DROP TABLE IF EXISTS seeing_conditions CASCADE;
DROP DOMAIN IF EXISTS valid_email CASCADE;


-- Validation domain for email addresses
CREATE DOMAIN valid_email AS text
CHECK ( VALUE ~ '^[A-Za-z0-9+_%.]+@[A-Za-z0-9-]+[A-Za-z0-9]\.[A-Za-z]{2,}$');

-- Level 0 Tables (Lookups)
CREATE TABLE experience_type(
    id serial2 PRIMARY KEY,
    type varchar(32) NOT NULL UNIQUE
);

CREATE TABLE affiliation(
    id serial PRIMARY KEY,
    affiliation text UNIQUE NOT NULL
);

CREATE TABLE countries(
    id serial2 PRIMARY KEY,
    country text UNIQUE
);

CREATE TABLE telescope_type(
    id serial2 PRIMARY KEY,
    type varchar(32) NOT NULL UNIQUE
);

CREATE TABLE seeing_conditions(
    id serial2 PRIMARY KEY,
    conditions varchar(64) NOT NULL UNIQUE
);

CREATE TABLE constellation(
    id serial PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE observation_object_type(
    id serial PRIMARY KEY,
    object_type varchar(64) UNIQUE
);

CREATE TABLE observation_object_designation(
    id serial PRIMARY KEY,
    designation varchar(32) NOT NULL UNIQUE,
    name text NOT NULL UNIQUE
);

-- Level 1 Tables (Entities referencing Level 0 Lookups)
CREATE TABLE observer(
    id serial PRIMARY KEY,
    name text NOT NULL,
    email valid_email NOT NULL UNIQUE,
    affiliation_id integer REFERENCES affiliation (id) NOT NULL,
    experience integer REFERENCES experience_type (id) NOT NULL DEFAULT 1
);

CREATE TABLE observatory(
    id serial PRIMARY KEY,
    name text UNIQUE,
    country_id integer REFERENCES countries (id) NOT NULL,
    altitude integer
);

CREATE TABLE telescope_models(
    id serial PRIMARY KEY,
    model text NOT NULL UNIQUE,
    model_type_id integer REFERENCES telescope_type (id) NOT NULL,
    aperture integer NOT NULL
);

-- Constellation is nullable: Planets will store NULL instead of '-'
CREATE TABLE observation_object(
    id serial PRIMARY KEY,
    designation_id integer REFERENCES observation_object_designation (id),
    observation_object_type_id integer REFERENCES observation_object_type (id) NOT NULL,
    constellation_id integer REFERENCES constellation (id),
    apparent_magnitude numeric(2, 1) NOT NULL
);

-- Level 2 Tables (Operational Assets referencing Level 1)
CREATE TABLE telescope(
    id serial PRIMARY KEY,
    code text CHECK ( code ~ '^TSC-[0-9]{3}$' ) NOT NULL UNIQUE,
    model_id integer REFERENCES telescope_models (id) NOT NULL,
    observatory_id integer REFERENCES observatory (id) NOT NULL
);

-- Level 3 Tables (Observations Central Log Fact Table)
CREATE TABLE observation(
    observation_code serial PRIMARY KEY,
    observed_at timestamptz DEFAULT now(),
    seeing_conditions_id integer REFERENCES seeing_conditions (id) NOT NULL,
    duration integer NOT NULL,
    observer_id integer REFERENCES observer (id) NOT NULL,
    telescope_id integer REFERENCES telescope (id) NOT NULL,
    object_id integer REFERENCES observation_object (id) NOT NULL
);

