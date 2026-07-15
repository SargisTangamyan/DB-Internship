---------------------------------------------------------------------------------
--Garden DDL

DROP TABLE IF EXISTS plant_families CASCADE;
DROP TABLE IF EXISTS regions CASCADE;
DROP TABLE IF EXISTS greenhouse_zones CASCADE;
DROP TABLE IF EXISTS sun_exposures CASCADE;
DROP TABLE IF EXISTS care_types CASCADE;
DROP TABLE IF EXISTS acquire_options CASCADE;
DROP TABLE IF EXISTS health_status CASCADE;
DROP TABLE IF EXISTS sections CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS gardeners CASCADE;
DROP TABLE IF EXISTS plant_species CASCADE;
DROP TABLE IF EXISTS plant_exemplars CASCADE;
DROP TABLE IF EXISTS gardeners_shift CASCADE;
DROP TABLE IF EXISTS care_log CASCADE;
DROP TABLE IF EXISTS roles CASCADE;


CREATE TABLE plant_families (
    family_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    family_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE regions (
    region_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    region_name VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE greenhouse_zones (
    greenhouse_zone_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    greenhouse_zone VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE sections (
    section_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    section_name VARCHAR(255) UNIQUE NOT NULL,
    greenhouse_zone_id INT NOT NULL,

    CONSTRAINT fk_sections_greenhouse_zone
        FOREIGN KEY (greenhouse_zone_id)
            REFERENCES greenhouse_zones(greenhouse_zone_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
);

CREATE TABLE sun_exposures (
    sun_exposure_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sun_exposure VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE locations (
    location_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bed_code VARCHAR(50) UNIQUE NOT NULL,
    section_id INT NOT NULL,
    sun_exposure_id INT NOT NULL,

    CONSTRAINT fk_locations_section
        FOREIGN KEY (section_id)
            REFERENCES sections(section_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    CONSTRAINT fk_locations_sun_exposure
        FOREIGN KEY (sun_exposure_id)
            REFERENCES sun_exposures(sun_exposure_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
);

CREATE TABLE acquire_options (
    acquire_option_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    acquired_from VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE roles (
    role_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE gardeners (
    gardener_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    gardener_email VARCHAR(255) UNIQUE NOT NULL,
    gardener_name VARCHAR(255) NOT NULL,
    gardener_role_id INT NOT NULL,

    CONSTRAINT fk_gardeners_role
        FOREIGN KEY (gardener_role_id)
            REFERENCES roles(role_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
);

CREATE TABLE plant_species (
    specie_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    scientific_name VARCHAR(255) NOT NULL,
    common_name VARCHAR(255) NOT NULL,
    family_id INT NOT NULL,
    region_id INT NOT NULL,
    toxic_to_pets BOOLEAN,

    CONSTRAINT fk_species_family
        FOREIGN KEY (family_id)
            REFERENCES plant_families(family_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    CONSTRAINT fk_species_region
        FOREIGN KEY (region_id)
            REFERENCES regions(region_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
);

CREATE TABLE plant_exemplars (
    exemplar_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    accession_code VARCHAR(100) UNIQUE NOT NULL,
    specie_id INT NOT NULL,
    location_id INT NOT NULL,
    planted_date DATE,
    acquire_option INT NOT NULL,

    CONSTRAINT fk_exemplar_species
        FOREIGN KEY (specie_id)
            REFERENCES plant_species(specie_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    CONSTRAINT fk_exemplar_location
        FOREIGN KEY (location_id)
            REFERENCES locations(location_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    CONSTRAINT fk_exemplar_acquire_option
        FOREIGN KEY (acquire_option)
            REFERENCES acquire_options(acquire_option_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
);

CREATE TABLE gardeners_shift (
    shift_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    location_id INT NOT NULL,
    gardener_id INT NOT NULL,

    CONSTRAINT fk_shift_location
        FOREIGN KEY (location_id)
            REFERENCES locations(location_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    CONSTRAINT fk_shift_gardener
        FOREIGN KEY (gardener_id)
            REFERENCES gardeners(gardener_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
);

CREATE TABLE care_types (
    care_type_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    care_type VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE health_status (
    health_status_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    health_status VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE care_log (
    care_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shift_id INT NOT NULL,
    exemplar_id INT NOT NULL,
    health_status_id INT NOT NULL,
    care_date DATE NOT NULL,
    care_type_id INT NOT NULL,
    water_liters DECIMAL(5,2),
    care_cost_usd DECIMAL(6,2),

    CONSTRAINT fk_care_shift
        FOREIGN KEY (shift_id)
            REFERENCES gardeners_shift(shift_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    CONSTRAINT fk_care_exemplar
        FOREIGN KEY (exemplar_id)
            REFERENCES plant_exemplars(exemplar_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    CONSTRAINT fk_care_health
        FOREIGN KEY (health_status_id)
            REFERENCES health_status(health_status_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE,
    CONSTRAINT fk_care_type
        FOREIGN KEY (care_type_id)
            REFERENCES care_types(care_type_id)
            ON DELETE RESTRICT
            ON UPDATE CASCADE
);
