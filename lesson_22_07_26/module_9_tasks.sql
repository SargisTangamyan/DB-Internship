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
SET enable_indexscan = off;
SET enable_bitmapscan = off;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE driver_id = 1234;
RESET enable_indexscan;
RESET enable_bitmapscan;

-- Explain. About 260 rows match one driver
-- how much work was wasted reading the rest of the table?

-- For sequential
-- Rows needed = 279
-- Rows Read = 800_000
-- cost = 13441
-- actual time = 158 ms
-- Buffers: hit = 528, read 7720

CREATE INDEX idx_trips_driver_id ON trips (driver_id);
ANALYZE trips;
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE driver_id = 1234;

-- For Bitmap
-- Rows needed = 279
-- pages read = 272
-- cost = 288.25
-- actual time 26.166
-- Buffers hit = 276

-- Explain. Why does one driver's trips now cost so few page reads?
-- The scanner doesn't pass through all the pages to look for all pages. Through bitmap scanning it finds the pages
-- that contain rows sufficing the condition and looks only inside that pages

-- 3. Date-range crossover
CREATE INDEX ON trips (requested_at);
ANALYZE trips;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE requested_at >= '2024-06-01'
  AND requested_at < '2024-06-02';
-- one day

-- Bitmap Scan
-- cost = 10118.84
-- actual time = 20.996
-- rows = 6719
-- Buffers: hit = 8255 read = 173

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE requested_at >= '2024-06-01'
  AND requested_at < '2024-07-01';
-- one month
-- Bitmap Scan
-- cost=18208.30
-- actual time 270.452
-- rows = 299541
-- Buffers: hit = 399675, read = 2
-- planning = 0.179
-- execution = 281.164


EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE requested_at >= '2024-01-01'
  AND requested_at < '2024-07-01';
-- half year

-- Index scan
-- cost = 18208.30
-- rows = 396804
-- Buffers: hit 400586
-- planning = 0.193
-- execution time = 229.489

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE requested_at >= '2024-01-01'
  AND requested_at < '2024-09-01';
-- Sequential scan
-- cost = 20248
-- rows = 533440
-- actual time = 100.268
-- removed rows: 265013
-- Buffers: shared hit: 8284
-- planning time 0.107
-- execution time: 114.918

-- Observe: Where the access method switches from index scan to bitmap heap scan to seq scan
-- as the time period increases the bitmap scanning is replaced with index scanning
-- as the majority of the elements of the page suffice to the condition and index scanning from the page is
-- less time-consuming than bitmap. After the number of the rows covers most rows the scanning is turned into
-- sequential as the majority of the rows in the pages suffice to the condition

-- Explain: Roughly what share of the year's trips makes the planner abandon the index?
-- when the number of the rows sufficing the condition is bigger than the half of the total rows


-- 4. The cost knob on a fare range
CREATE INDEX ON trips (fare);
ANALYZE trips;

EXPLAIN
SELECT *
FROM trips
WHERE fare BETWEEN 18 AND 22;
-- Index Scan
-- cost: 12757.69
-- rows: 160024

SET random_page_cost = 8;
EXPLAIN
SELECT *
FROM trips
WHERE fare BETWEEN 18 AND 22;
-- Bitmap Scan
-- cost: 15809


SET random_page_cost = 1.1;
EXPLAIN
SELECT *
FROM trips
WHERE fare BETWEEN 18 AND 22;
RESET random_page_cost;
-- Index Scan
-- cost 12757.69

-- Explain: Which storage does each value model, and why does cheap random I/O tip the choice toward the index?
-- random_page_cost = 4 for HDD
-- random_page_cost = 1.1 for SSD

-- the higher is random_page_cost the higher will the overall cost of the scanning with index
-- as index will read a row from random pages which will be more expensive than sorting by pages and passing through
-- each page maximum at once


-- 5. A common status is not worth an index
CREATE INDEX ON trips (status);
ANALYZE trips;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE status = 'completed';
SET enable_seqscan = off;
-- INDEX SCAN
-- cost: 17103.83
-- rows: 479845
-- actual time: 78.674

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE status = 'completed';
RESET enable_seqscan;

-- Explain: 'completed' is ~60% of rows — why is scanning the whole table cheaper than using the index?
-- As the vast majority of the rows should be included, scanning sequentially will cost cheaper than the index
-- scan which because of its random page reading cost can product longer execution time


-- PART B - INDEX TYPES
-- 6. Multicolumn index & the leftmost-prefix rule
CREATE INDEX ON trips (city_id, status);
ANALYZE trips;

EXPLAIN
SELECT *
FROM trips
WHERE city_id = 3;
-- leading col
-- As city_id is the left-most column the query uses BITMAP scan

EXPLAIN
SELECT *
FROM trips
WHERE city_id = 3
  AND status = 'cancelled';
-- full key
-- As both are present in the multicolumn index, the BITMAP scan will be used

EXPLAIN
SELECT *
FROM trips
WHERE status = 'cancelled';
-- no city_id
-- If there is an index for status, it will be used, otherwise it will be defaulted to sequential scan

-- Explain. State the leftmost-prefix rule from what you saw: which column must a query pin to use this index?
-- if the column used in the condition are used in a multicolumn index and between them there is no
-- other column that is missing in the condition, the filtering will be held using only index, otherwise the index
-- rows will be filtered in their turn too


-- 7. Column order, ranges & ORDER BY
CREATE INDEX ON trips (city_id, requested_at);
ANALYZE trips;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE city_id = 3
ORDER BY requested_at
LIMIT 20;

-- Explain. Why can this index satisfy both the filter and the ORDER BY,
-- and why must requested_at be the trailing column?

-- The matching rows are found with the use of index (city_id = 3), then for ORDER BY they can take the first
-- condition meeting leaf and loop through its siblings in order till it meet a leaf not meeting the condition
-- or the number of leaves will become 20
-- if we do in the opposite way, all the rows should be ordered by requested_at, which in this case does not have an
-- index and as is the second column in the multicolumn index there will be no use in using the index without the first
-- column initially given

-- 8. Index on an expression
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE requested_at::date = DATE '2024-06-15';
-- before
-- No index => sequential scan (gather in this case as the number of rows is too big)

CREATE INDEX ON trips (((requested_at AT TIME ZONE 'UTC')::date));
ANALYZE trips;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM trips
WHERE (requested_at AT TIME ZONE 'UTC')::date = DATE '2024-06-15';
-- after

EXPLAIN
INSERT INTO trips (driver_id, city_id, status, payment_method, fare, distance_km, requested_at)
SELECT driver_id, city_id, status, payment_method, fare, distance_km, requested_at
FROM trips
LIMIT 1;

-- Explain. Why couldn't a plain index on requested_at serve this equality, and what does the expression index cost on every write?
-- If we had created a plain index without explicitly casting then the condition would not use the index as the column we are
-- using in the condition is casted and cannot be used.


-- 9. Covering index & index-only scan
EXPLAIN (ANALYZE, BUFFERS)
SELECT city_id, fare
FROM trips
WHERE driver_id = 1234; -- driver_id index + heap

CREATE INDEX ON trips (driver_id) INCLUDE (city_id, fare);
ANALYZE trips;
VACUUM trips;

EXPLAIN (ANALYZE, BUFFERS)
SELECT city_id, fare
FROM trips
WHERE driver_id = 1234;
-- Index Only Scan

-- Explain. Why can the covering index answer this query without reading the table row, and what does INCLUDE add to the leaf?
-- The main reason that index only scan is sufficient is that needed columns are stored in the leaves, so there is no need
-- in visiting the table to retrieve the values. INCLUDE adds the given columns to the leaf, so that they can be retrieved
-- from there without a need to visit the table

-- 10. Partial (filtered) index
CREATE INDEX idx_trips_problem ON trips (city_id) WHERE status <> 'completed';
ANALYZE trips;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM trips WHERE city_id = 3 AND status = 'cancelled';

-- compare index size:
SELECT pg_size_pretty(pg_relation_size('idx_trips_problem')) AS partial_size;
SELECT pg_size_pretty(pg_relation_size('trips_status_idx')) AS partial_size_status;

-- Explain. Why must the query's WHERE imply the index's predicate for the index to be usable,
-- and when does a partial index pay off?
-- The need of index's predicate is the need of engine to be sure that it doesn't miss any row.
-- Mostly partial indexes are used when some of the column data has an unequal distribution (for example 90% and 10%).
