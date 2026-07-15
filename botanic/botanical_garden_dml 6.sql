------------------------------------------------------------------------------------------------------
--Garden DML

TRUNCATE TABLE plant_families CASCADE;
TRUNCATE TABLE regions CASCADE;
TRUNCATE TABLE greenhouse_zones CASCADE;
TRUNCATE TABLE sun_exposures CASCADE;
TRUNCATE TABLE roles CASCADE;
TRUNCATE TABLE acquire_options CASCADE;
TRUNCATE TABLE health_status CASCADE;
TRUNCATE TABLE sections CASCADE;
TRUNCATE TABLE locations CASCADE;
TRUNCATE TABLE gardeners CASCADE;
TRUNCATE TABLE plant_species CASCADE;
TRUNCATE TABLE plant_exemplars CASCADE;
TRUNCATE TABLE gardeners_shift CASCADE;
TRUNCATE TABLE care_log CASCADE;
TRUNCATE TABLE care_types CASCADE;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'botanical_garden';


--1 plant_families
INSERT INTO plant_families (family_name)
SELECT DISTINCT plant_family
FROM botanical_garden
WHERE plant_family IS NOT NULL
ON CONFLICT (family_name) DO NOTHING;


-- 2 regions
INSERT INTO regions (region_name)
SELECT DISTINCT origin_region
FROM botanical_garden
WHERE origin_region IS NOT NULL
ON CONFLICT (region_name) DO NOTHING;


--3 greenhouse_zones
INSERT INTO greenhouse_zones (greenhouse_zone)
SELECT DISTINCT greenhouse_zone
FROM botanical_garden
WHERE greenhouse_zone IS NOT NULL
ON CONFLICT (greenhouse_zone) DO NOTHING;


--4 sun_exposures
INSERT INTO sun_exposures (sun_exposure)
SELECT DISTINCT sun_exposure
FROM botanical_garden
WHERE sun_exposure IS NOT NULL
ON CONFLICT (sun_exposure) DO NOTHING;


-- 5 acquire_options
INSERT INTO acquire_options (acquired_from)
SELECT DISTINCT acquired_from
FROM botanical_garden
WHERE acquired_from IS NOT NULL
ON CONFLICT (acquired_from) DO NOTHING;


--6 roles
INSERT INTO roles (role_name)
SELECT DISTINCT gardener_role
FROM botanical_garden
WHERE gardener_role IS NOT NULL
ON CONFLICT (role_name) DO NOTHING;


--7 health_status
INSERT INTO health_status (health_status)
SELECT DISTINCT health_status
FROM botanical_garden
WHERE health_status IS NOT NULL
ON CONFLICT (health_status) DO NOTHING;


--8 care_types
INSERT INTO care_types (care_type)
SELECT DISTINCT care_type
FROM botanical_garden
WHERE care_type IS NOT NULL
ON CONFLICT (care_type) DO NOTHING;


-- 9 sections
INSERT INTO sections (section_name, greenhouse_zone_id)
SELECT DISTINCT bg.section_name, gz.greenhouse_zone_id
FROM botanical_garden bg
         JOIN greenhouse_zones gz ON gz.greenhouse_zone = bg.greenhouse_zone
WHERE bg.section_name IS NOT NULL
ON CONFLICT (section_name) DO NOTHING;


-- 10 locations
INSERT INTO locations (bed_code, section_id, sun_exposure_id)
SELECT DISTINCT bg.bed_code, s.section_id, se.sun_exposure_id
FROM botanical_garden bg
         JOIN sections s ON s.section_name = bg.section_name
         JOIN sun_exposures se ON se.sun_exposure = bg.sun_exposure
WHERE bg.bed_code IS NOT NULL
ON CONFLICT (bed_code) DO NOTHING;


-- 11 gardeners
INSERT INTO gardeners (gardener_email, gardener_name, gardener_role_id)
SELECT DISTINCT bg.gardener_email, bg.gardener_name, r.role_id
FROM botanical_garden bg
         JOIN roles r ON r.role_name = bg.gardener_role
WHERE bg.gardener_email IS NOT NULL
ON CONFLICT (gardener_email) DO NOTHING;


-- 12 plant_species
INSERT INTO plant_species (scientific_name, common_name, family_id, region_id, toxic_to_pets)
SELECT DISTINCT bg.scientific_name, bg.common_name, pf.family_id, r.region_id, bg.toxic_to_pets::BOOLEAN
FROM botanical_garden bg
         JOIN plant_families pf ON pf.family_name = bg.plant_family
         JOIN regions r ON r.region_name = bg.origin_region
WHERE bg.common_name IS NOT NULL
ON CONFLICT DO NOTHING;


-- 13 plant_exemplars
INSERT INTO plant_exemplars (accession_code, specie_id, location_id, planted_date, acquire_option)
SELECT DISTINCT
    bg.accession_code,
    sp.specie_id,
    loc.location_id,
    ('1899-12-30'::date + bg.planted_date::int) AS planted_date,
    ao.acquire_option_id
FROM botanical_garden bg
         JOIN plant_species sp ON bg.common_name = sp.common_name
    AND (bg.scientific_name = sp.scientific_name )
         JOIN locations loc ON bg.bed_code = loc.bed_code
         JOIN acquire_options ao ON bg.acquired_from = ao.acquired_from
WHERE bg.accession_code IS NOT NULL
ON CONFLICT (accession_code) DO NOTHING;


-- 14 gardeners_shift (distinct gardener/location pairs)
INSERT INTO gardeners_shift (location_id, gardener_id)
SELECT DISTINCT -- Ավելացվել է DISTINCT՝ կրկնությունից խուսափելու համար
                loc.location_id,
                g.gardener_id
FROM botanical_garden bg
         JOIN locations loc ON bg.bed_code = loc.bed_code
         JOIN gardeners g ON bg.gardener_email = g.gardener_email
ON CONFLICT DO NOTHING;


-- 15 care_log
INSERT INTO care_log (shift_id, exemplar_id, health_status_id, care_date, care_type_id, water_liters, care_cost_usd)
SELECT
    gs.shift_id,
    pe.exemplar_id,
    hs.health_status_id,
    ('1899-12-30'::date + bg.care_date::int) AS care_date,
    ct.care_type_id,
    bg.water_liters,
    bg.care_cost_usd
FROM botanical_garden bg
         JOIN gardeners g ON bg.gardener_email = g.gardener_email
         JOIN locations loc ON bg.bed_code = loc.bed_code
         JOIN gardeners_shift gs ON gs.gardener_id = g.gardener_id AND gs.location_id = loc.location_id
         JOIN plant_exemplars pe ON bg.accession_code = pe.accession_code
         JOIN health_status hs ON bg.health_status = hs.health_status
         JOIN care_types ct ON bg.care_type = ct.care_type
WHERE bg.care_date IS NOT NULL
ON CONFLICT DO NOTHING;