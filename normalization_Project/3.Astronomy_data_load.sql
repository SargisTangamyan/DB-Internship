-- ============================================================================
-- DML TRUNCATION FOR INSTANT DATA REFRESH
-- ============================================================================
-- firstly we truncate everything, to make our code re-runnable

TRUNCATE TABLE
    observation,
    telescope,
    telescope_models,
    telescope_type,
    observatory,
    countries,
    observation_object,
    constellation,
    observation_object_type,
    observation_object_designation,
    observer,
    affiliation,
    experience_type
RESTART IDENTITY CASCADE;



-- ============================================================================
-- 3. POPULATING LOOKUP TABLES (LEVEL 0 - DEPENDENCY FREE)
-- ============================================================================

-- Affiliation
INSERT INTO affiliation (affiliation)
SELECT DISTINCT observer_affiliation
FROM staging_astronomy
WHERE observer_affiliation IS NOT NULL
ON CONFLICT (affiliation) DO NOTHING;

-- Experience Type
INSERT INTO experience_type (type)
SELECT DISTINCT observer_experience
FROM staging_astronomy
WHERE observer_experience IS NOT NULL
ON CONFLICT (type) DO NOTHING;

-- Countries
INSERT INTO countries (country)
SELECT DISTINCT observatory_country
FROM staging_astronomy
WHERE observatory_country IS NOT NULL
ON CONFLICT (country) DO NOTHING;

-- Telescope Type
INSERT INTO telescope_type (type)
SELECT DISTINCT telescope_type
FROM staging_astronomy
WHERE telescope_type IS NOT NULL
ON CONFLICT (type) DO NOTHING;

-- Seeing Conditions
INSERT INTO seeing_conditions (conditions)
SELECT DISTINCT seeing_conditions
FROM staging_astronomy
WHERE seeing_conditions IS NOT NULL
ON CONFLICT (conditions) DO NOTHING;

-- Constellations (Excludes '-' to correctly represent planet constellations as NULL)
INSERT INTO constellation (name)
SELECT DISTINCT constellation
FROM staging_astronomy
WHERE constellation IS NOT NULL AND constellation <> '-'
ON CONFLICT (name) DO NOTHING;

-- Observation Object Type
INSERT INTO observation_object_type (object_type)
SELECT DISTINCT object_type
FROM staging_astronomy
WHERE object_type IS NOT NULL
ON CONFLICT (object_type) DO NOTHING;

-- Observation Object Designation (Strict uniqueness on designation & name mapping)
INSERT INTO observation_object_designation (designation, name)
SELECT DISTINCT ON (object_designation) object_designation, object_common_name
FROM (
    SELECT DISTINCT ON (object_common_name) object_designation, object_common_name
    FROM staging_astronomy
    WHERE object_designation IS NOT NULL AND object_common_name IS NOT NULL
    ORDER BY object_common_name, object_designation
) sub
ORDER BY object_designation
ON CONFLICT (designation) DO NOTHING;


-- ============================================================================
-- 4. POPULATING SECONDARY TABLES (LEVEL 1)
-- ============================================================================

-- Observer
INSERT INTO observer (name, email, affiliation_id, experience)
SELECT DISTINCT sa.observer_name, sa.observer_email, aff.id, et.id
FROM staging_astronomy sa
JOIN affiliation aff ON aff.affiliation = sa.observer_affiliation
JOIN experience_type et ON et.type = sa.observer_experience
ON CONFLICT (email) DO NOTHING;

-- Observatory
INSERT INTO observatory (name, country_id, altitude)
SELECT DISTINCT sa.observatory_name, c.id, sa.observatory_altitude_m
FROM staging_astronomy sa
JOIN countries c ON sa.observatory_country = c.country
ON CONFLICT (name) DO NOTHING;

-- Telescope Models
INSERT INTO telescope_models (model, model_type_id, aperture)
SELECT DISTINCT sa.telescope_model, tt.id, sa.aperture_mm
FROM staging_astronomy sa
JOIN telescope_type tt ON sa.telescope_type = tt.type
ON CONFLICT (model) DO NOTHING;

-- Observation Object (LEFT JOIN maps '-' as NULL, preserving Planet observations!)
INSERT INTO observation_object (designation_id, observation_object_type_id, constellation_id, apparent_magnitude)
SELECT DISTINCT
    obd.id,
    oot.id,
    c.id AS constellation_id,
    st.apparent_magnitude
FROM staging_astronomy st
JOIN observation_object_designation obd ON st.object_designation = obd.designation
JOIN observation_object_type oot ON st.object_type = oot.object_type
LEFT JOIN constellation c ON st.constellation = c.name AND st.constellation <> '-';


-- ============================================================================
-- 5. POPULATING TELESCOPES (LEVEL 2)
-- ============================================================================

-- Telescope
INSERT INTO telescope (code, model_id, observatory_id)
SELECT DISTINCT sa.telescope_code, tm.id, obs.id
FROM staging_astronomy sa
JOIN telescope_models tm ON sa.telescope_model = tm.model
JOIN observatory obs ON sa.observatory_name = obs.name
ON CONFLICT (code) DO NOTHING;


-- ============================================================================
-- 6. POPULATING OBSERVATIONS (LEVEL 3 - FACT DATA TRANSACTION)
-- ============================================================================

-- Observation (Joined on designation & magnitude to log correct facts smoothly)
INSERT INTO observation (observed_at, seeing_conditions_id, duration, observer_id, telescope_id, object_id)
SELECT sa.observed_at, sc.id, sa.duration_minutes, obs.id, tel.id, oo.id
FROM staging_astronomy sa
JOIN seeing_conditions sc ON sc.conditions = sa.seeing_conditions
JOIN observer obs ON obs.email = sa.observer_email
JOIN telescope tel ON tel.code = sa.telescope_code
JOIN observation_object_designation ood ON ood.designation = sa.object_designation
JOIN observation_object oo ON oo.designation_id = ood.id AND oo.apparent_magnitude = sa.apparent_magnitude;