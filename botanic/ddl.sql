CREATE DATABASE botanic;

CREATE TABLE botanical_garden
(
    accession_code  char(9),
    common_name     varchar(50),
    scientific_name varchar(50),
    plant_family    varchar(50),
    origin_region   varchar(50),
    toxic_to_pets   boolean,
    bed_code        varchar(15),
    section_name    varchar(50),
    greenhouse_zone varchar(10),
    sun_exposure    varchar(50),
    planted_date    date,
    acquired_from   varchar(50),
    health_status   varchar(50),
    gardener_name   varchar(120),
    gardener_email  varchar(150),
    gardener_role   varchar(50),
    care_date       date,
    care_type       varchar(50),
    water_liters    numeric(4, 1),
    care_cost_usd   numeric(4, 2)
)

\copy botanical_garden FROM 'C:\Users\Sargis.Tangamyan\Downloads\botanical_garden.csv' WITH (FORMAT csv, HEADER true);

-- bed_code repeats the data of greenhouse_zone
UPDATE unnormalized
SET bed_code = substring(bed_code from char_length(greenhouse_zone) + 2);

-- moving gardener related data into a separate table
CREATE TABLE gardeners
(
    gardener_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name        varchar(50) NOT NULL,
    email       varchar(50) NOT NULL UNIQUE,
    role        varchar(50) NOT NULL
);

INSERT INTO gardeners (name, email, role)
SELECT DISTINCT gardener_name, gardener_email, gardener_role
FROM unnormalized;

CREATE TABLE gardener_roles
(
    role_id   smallint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    role_name varchar(50) NOT NULL UNIQUE
);

INSERT INTO gardener_roles (role_name)
SELECT DISTINCT role
FROM gardeners;

SELECT *
FROM gardeners
         JOIN gardener_roles
              ON gardeners.role = gardener_roles.role_name;

ALTER TABLE gardeners
    ADD COLUMN role_id smallint REFERENCES gardener_roles (role_id);
SELECT *
FROM gardeners;

UPDATE gardeners
SET role_id = (SELECT role_id FROM gardener_roles WHERE role_name = gardeners.role);
SELECT *
FROM gardeners;

SELECT *
FROM gardeners
         JOIN gardener_roles ON gardeners.role_id = gardener_roles.role_id;

ALTER TABLE gardeners
    DROP COLUMN role;
SELECT *
FROM gardeners;

SELECT COUNT(*)
FROM unnormalized
GROUP BY gardener_name, gardener_email, gardener_role;

SELECT *
FROM unnormalized
LIMIT 10;

-- Back up of initial db
SELECT *
INTO unnormalized_backup
FROM unnormalized;
SELECT *
FROM unnormalized_backup
LIMIT 10;


ALTER TABLE unnormalized
    ADD COLUMN gardener_id integer REFERENCES gardeners (gardener_id);

UPDATE unnormalized u
SET gardener_id = (SELECT gardener_id
                   FROM gardeners g
                   WHERE (u.gardener_name, u.gardener_email) = (g.name, g.email));

SELECT u.gardener_name, g.name, u.gardener_role, gr.role_name
FROM unnormalized u
         JOIN gardeners g
              ON u.gardener_id = g.gardener_id
         JOIN gardener_roles gr
              ON g.role_id = gr.role_id;

SELECT gardener_id
FROM unnormalized
LIMIT 10;
ALTER TABLE unnormalized
    DROP COLUMN gardener_name,
    DROP COLUMN gardener_email,
    DROP COLUMN gardener_role;

SELECT *
FROM information_schema.columns
WHERE table_name = 'unnormalized';

-- Creating plants table
CREATE TABLE plant_families
(
    family_id   integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    family_name varchar(30) NOT NULL UNIQUE
);

CREATE TABLE plant_origins
(
    origin_id   integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    origin_name varchar(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS plants
(
    plant_id        integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    common_name     varchar(30) NOT NULL,
    scientific_name varchar(30) NOT NULL UNIQUE,
    family_id       integer     NOT NULL REFERENCES plant_families (family_id) ON DELETE RESTRICT,
    origin_id       integer     NOT NULL REFERENCES plant_origins (origin_id) ON DELETE RESTRICT,
    toxic_to_pets   boolean     NOT NULL
);

INSERT INTO plant_families (family_name)
SELECT DISTINCT plant_family
FROM unnormalized;

INSERT INTO plant_origins (origin_name)
SELECT DISTINCT origin_region
FROM unnormalized;

SELECT *
FROM plant_origins;

INSERT INTO plants (common_name, scientific_name, toxic_to_pets, family_id, origin_id)
SELECT DISTINCT u.common_name,
                u.scientific_name,
                u.toxic_to_pets,
                pf.family_id,
                po.origin_id
FROM unnormalized u
         JOIN plant_families pf
              ON u.plant_family = pf.family_name
         JOIN plant_origins po
              ON u.origin_region = po.origin_name;

SELECT *
FROM plants;

-- updating unnormalized table with plant id instead of plant information
ALTER TABLE unnormalized
    ADD COLUMN plant_id integer REFERENCES plants (plant_id) ON DELETE RESTRICT;
UPDATE unnormalized u
SET plant_id = (SELECT plant_id
                FROM plants p
                JOIN plant_families pf
                ON p.family_id = pf.family_id
                JOIN plant_origins po
                ON po.origin_id = p.origin_id
                WHERE (u.scientific_name, u.toxic_to_pets, u.plant_family, u.origin_region) = (p.scientific_name, p.toxic_to_pets, pf.family_name, po.origin_name)
                );

SELECT * FROM unnormalized WHERE unnormalized.plant_id IS NULL;
SELECT * FROM unnormalized LIMIT 10;

SELECT * FROM plants;

-- dropping redundant columns related with plant
ALTER TABLE unnormalized
DROP COLUMN common_name,
DROP COLUMN scientific_name,
DROP COLUMN plant_family,
DROP COLUMN origin_region,
DROP COLUMN toxic_to_pets;

SELECT * FROM unnormalized ORDER BY accession_code LIMIT 50;

SELECT * FROM unnormalized ORDER BY greenhouse_zone LIMIT 50;

SELECT DISTINCT greenhouse_zone, bed_code FROM (SELECT bed_code, section_name, greenhouse_zone, count(*) AS ct
FROM unnormalized
GROUP BY bed_code, section_name, greenhouse_zone) t;

SELECT bed_code, section_name, greenhouse_zone, sun_exposure, count(*) AS ct
FROM unnormalized
GROUP BY bed_code, section_name, greenhouse_zone, sun_exposure ORDER BY section_name;

CREATE TABLE greenhouse_zones (
    greenhouse_zone_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    greenhouse_zone varchar(30) NOT NULL UNIQUE
);

INSERT INTO greenhouse_zones (greenhouse_zone)
SELECT DISTINCT unnormalized.greenhouse_zone FROM unnormalized;

SELECT * from greenhouse_zones;

CREATE TABLE sections (
    section_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    section_name varchar(30) NOT NULL UNIQUE,
    greenhouse_zone_id integer NOT NULL REFERENCES greenhouse_zones(greenhouse_zone_id)
);

SELECT section_name, greenhouse_zone FROM unnormalized GROUP BY section_name, greenhouse_zone ORDER BY section_name;

SELECT MAX(char_length(unnormalized.acquired_from)) FROM unnormalized;

INSERT INTO sections (section_name, greenhouse_zone_id)
SELECT u.section_name, gz.greenhouse_zone_id
FROM unnormalized u
JOIN greenhouse_zones gz
ON u.greenhouse_zone = gz.greenhouse_zone
GROUP BY u.section_name, gz.greenhouse_zone_id;

SELECT * FROM greenhouse_zones;
SELECT * FROM sections;

SELECT DISTINCT section_name, sun_exposure, bed_code FROM unnormalized GROUP BY section_name, sun_exposure, bed_code;


CREATE TABLE sun_exposure_types (
    sun_exposure_id smallint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    sun_exposure varchar(30) NOT NULL UNIQUE
);

INSERT INTO sun_exposure_types (sun_exposure)
SELECT DISTINCT unnormalized.sun_exposure FROM unnormalized;

SELECT * FROM sun_exposure_types;

CREATE TABLE IF NOT EXISTS locations
(
    location_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    bed_code char(3) NOT NULL UNIQUE,
    section_id integer NOT NULL REFERENCES sections(section_id),
    sun_exposure_id smallint NOT NULL REFERENCES sun_exposure_types(sun_exposure_id)
);

SELECT DISTINCT u.bed_code, s.section_id, se.sun_exposure_id
FROM unnormalized u
JOIN sections s
ON s.section_name = u.section_name
JOIN sun_exposure_types se
ON u.sun_exposure = se.sun_exposure;


SELECT * FROM locations;


ALTER TABLE unnormalized ADD COLUMN location_id INTEGER REFERENCES locations(location_id);
UPDATE unnormalized u SET location_id = (SELECT location_id FROM locations l WHERE u.bed_code = l.bed_code);

SELECT * FROM unnormalized ORDER BY location_id LIMIT 10;

ALTER TABLE unnormalized
    DROP COLUMN bed_code,
    DROP COLUMN section_name,
    DROP COLUMN greenhouse_zone,
    DROP COLUMN sun_exposure;

SELECT * FROM unnormalized LIMIT 10;
SELECT COUNT(*) FROM (SELECT accession_code FROM unnormalized GROUP BY accession_code, planted_date, acquired_from, plant_id, unnormalized.location_id, health_status) t;

DROP TABLE acquire_options;
CREATE TABLE acquire_options (
    acquire_id smallint PRIMARY KEY GENERATED ALWAYS AS IDENTITY ,
    acquired_from varchar(30) NOT NULL UNIQUE
);

INSERT INTO acquire_options (acquired_from)
SELECT DISTINCT unnormalized.acquired_from FROM unnormalized;

CREATE TABLE IF NOT EXISTS planting_details (
    planting_detail_id integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    accession_code char(9) NOT NULL UNIQUE,
    planted_date date NOT NULL,
    acquire_id smallint NOT NULL REFERENCES acquire_options(acquire_id),
    plant_id integer NOT NULL REFERENCES plants(plant_id) ON DELETE RESTRICT,
    location_id integer NOT NULL REFERENCES locations(location_id) ON DELETE RESTRICT
);

INSERT INTO planting_details (ACCESSION_CODE, PLANTED_DATE, ACQUIRE_ID, PLANT_ID, LOCATION_ID)
SELECT u.accession_code, u.planted_date, ao.acquire_id, u.plant_id, u.location_id
FROM unnormalized u
JOIN acquire_options ao
ON u.acquired_from = ao.acquired_from
GROUP BY accession_code, planted_date, ao.acquire_id, u.plant_id, u.location_id;

SELECT * FROM planting_details;

ALTER TABLE unnormalized ADD COLUMN planting_detail_id integer REFERENCES planting_details(planting_detail_id) ON DELETE RESTRICT;
SELECT * FROM unnormalized LIMIT 10;

UPDATE unnormalized u SET planting_detail_id = (SELECT p.planting_detail_id FROM planting_details p WHERE u.accession_code = p.accession_code);

SELECT * FROM unnormalized LIMIT 10;
SELECT * FROM planting_details;

ALTER TABLE unnormalized
DROP COLUMN accession_code,
DROP COLUMN planted_date,
DROP COLUMN acquired_from,
DROP COLUMN plant_id,
DROP COLUMN location_id;

SELECT u.*, location_id
FROM unnormalized u
JOIN planting_details pd
ON u.planting_detail_id = pd.planting_detail_id
ORDER BY gardener_id
LIMIT 50;