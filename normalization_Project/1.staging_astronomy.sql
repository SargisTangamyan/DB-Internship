-- auto-generated definition
DROP TABLE IF EXISTS staging_astronomy;
create table staging_astronomy
(
    observation_code       text,
    observatory_name       text,
    observatory_country    text,
    observatory_altitude_m double precision,
    telescope_code         text,
    telescope_model        text,
    telescope_type         text,
    aperture_mm            double precision,
    observer_name          text,
    observer_email         text,
    observer_affiliation   text,
    observer_experience    text,
    object_designation     text,
    object_common_name     text,
    object_type            text,
    constellation          text,
    apparent_magnitude     double precision,
    observed_at            double precision,
    seeing_conditions      text,
    duration_minutes       double precision
);

-- Then we need to populate the whole excel file data to this table, we have written the instructions below
/*
INSTRUCTIONS FOR LOADING THE EXCEL DATA VIA DATAGRIP / PGADMIN:

To populate this table with the data from "astronomy_observation_log.xlsx":

Using DataGrip:
1. Right-click the 'staging_astronomy' table in the Database tool window.
2. Select 'Import Data from File...' and choose 'astronomy_observation_log.xlsx'.
3. In the mapping dialog, select the sheet 'observation_log'.
4. Ensure the columns map 1-to-1 (the names in the Excel match this DDL perfectly).
5. Click 'Import' (DataGrip handles all 1,520 records automatically).

Using pgAdmin:
1. Save the Excel sheet as a CSV file named 'astronomy_observation_log.csv'.
2. Right-click the 'staging_astronomy' table and select 'Import/Export data...'.
3. Set the button to 'Import', select your CSV file, set the format to 'csv', and turn on 'Header'.
4. Click 'OK' to run.
*/
