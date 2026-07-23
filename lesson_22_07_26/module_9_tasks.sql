-- Setup
DROP TABLE trips;
DROP TABLE drivers;
DROP TABLE cities;

CREATE TABLE cities
(
    city_id int PRIMARY KEY,
    name    text
);
INSERT INTO cities
SELECT g,
       (ARRAY ['Yerevan','Gyumri','Vanadzor','Dilijan','Kapan',
           'Goris','Sevan','Ashtarak','Armavir','Abovyan'])[g]
FROM generate_series(1, 10) g;

CREATE TABLE drivers
(
    driver_id    int PRIMARY KEY,
    full_name    text,
    home_city_id int REFERENCES cities
);
INSERT INTO drivers
SELECT g, 'Driver ' || g, 1 + floor(random() * 10)::int
FROM generate_series(1, 3000) g;

CREATE TABLE trips
(
    trip_id        bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    driver_id      int REFERENCES drivers,
    city_id        int REFERENCES cities,
    status         text, -- completed / cancelled / no_driver
    payment_method text, -- card / cash / wallet
    fare           numeric(8, 2),
    distance_km    numeric(6, 2),
    requested_at   timestamptz
);
INSERT INTO trips (driver_id, city_id, status, payment_method,
                   fare, distance_km, requested_at)
SELECT 1 + floor(random() * 3000)::int,
       1 + floor(random() * 10)::int,
       (ARRAY ['completed','completed','completed',
           'cancelled','no_driver'])[1 + floor(random() * 5)::int],
       (ARRAY ['card','cash','wallet'])[1 + floor(random() * 3)::int],
       round((random() * 20 + 2)::numeric, 2),
       round((random() * 30 + 0.5)::numeric, 2),
       timestamptz '2024-01-01' + (random() * 365) * interval '1 day'
FROM generate_series(1, 800000);
ANALYZE cities;
ANALYZE drivers;
ANALYZE trips;


-- Part A - Sequential vs Random I/O
-- 1) Find one driver\s trips, unindexed
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM trips WHERE driver_id = 1234;

-- Explain. About 260 rows match one driver
-- how much work was wasted reading the rest of the table?

-- For sequential
-- Rows needed = 279
-- Rows Read = 800_000
-- cost = 13441
-- actual time = 158 ms

CREATE INDEX idx_trips_driver_id ON trips(driver_id);
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM trips WHERE driver_id = 1234;

-- For Bitmap
-- Rows needed = 279
-- Rows read =