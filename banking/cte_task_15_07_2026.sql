-- RC1 · Count 1 to 10
-- Task. Using a recursive CTE, produce the integers from 1 to 10, one per row.
WITH RECURSIVE counter(n) AS (SELECT 1

                              UNION ALL

                              SELECT n + 1
                              FROM counter
                              WHERE n < 10)
SELECT *
FROM counter;


-- RC2 · Fibonacci
-- Task. Using a recursive CTE, produce the first 10 Fibonacci numbers.
WITH RECURSIVE fibonacci(prev, curr, step) AS (SELECT 0, 1, 1

                                               UNION ALL

                                               SELECT curr, curr + prev, step + 1
                                               FROM fibonacci
                                               WHERE step < 10)
SELECT prev
FROM fibonacci;


-- RC3 · Powers of two
-- Task. Using a recursive CTE, produce the powers of two from 1 up to 1024, each with its exponent.
WITH RECURSIVE pow_two(step, pow) AS (SELECT 0, 1

                                      UNION ALL

                                      SELECT step + 1, pow * 2
                                      FROM pow_two
                                      WHERE step < 10)
SELECT step, pow
FROM pow_two;


-- RC4 · Collatz sequence
-- Task. Using a recursive CTE, produce the Collatz sequence starting at 6 until it reaches 1
-- (even -> n/2, odd -> 3n+1), numbering each step.
WITH RECURSIVE collatz(step, val) AS (SELECT 0, 6

                                      UNION ALL

                                      SELECT step + 1, CASE WHEN val % 2 = 0 THEN val / 2 ELSE val * 3 + 1 END
                                      FROM collatz
                                      WHERE val > 1)
SELECT step, val
FROM collatz;


-- RC5 · A week of dates
-- Task. Using a recursive CTE (not generate_series), produce every date
-- from 2024-03-01 to 2024-03-07 with its weekday name.
WITH RECURSIVE calendar(step, curr_date, weekday) AS
                   (SELECT 0, '2024-03-01'::date, SUBSTR(TO_CHAR('2024-03-01'::date, 'Day'), 1, 3)

                    UNION ALL

                    SELECT step + 1, curr_date + 1, substr(TO_CHAR(curr_date + 1, 'Day'), 1, 3)
                    FROM calendar
                    WHERE curr_date < '2024-03-07'::date)
SELECT step, curr_date, weekday
FROM calendar;


-- RC6 · Split a string
-- Task. Using a recursive CTE, split the string 'red,green,blue' into one row per token.
WITH RECURSIVE splitter(step, word, rest) AS
                   (SELECT 1,
                           SPLIT_PART('red,green,blue', ',', 1),
                           CASE
                               WHEN STRPOS('red,green,blue', ',') = 0 THEN ''
                               ELSE SUBSTR('red,green,blue', STRPOS('red,green,blue', ',') + 1)
                               END

                    UNION ALL

                    SELECT step + 1,
                           SPLIT_PART(rest, ',', 1),
                           CASE
                               WHEN STRPOS(rest, ',') = 0 THEN ''
                               ELSE SUBSTR(rest, STRPOS(rest, ',') + 1)
                               END
                    FROM splitter
                    WHERE rest <> '')
SELECT step, word, rest
FROM splitter;


-- RC7 · Category tree
-- Task. Using a recursive CTE, return every category with its depth and its full path from the root (e.g. 'All > Electronics > Phones'). Order by path
-- Setup
CREATE TABLE categories
(
    id        int PRIMARY KEY,
    name      text,
    parent_id int REFERENCES categories
);
INSERT INTO categories
VALUES (1, 'All', NULL),
       (2, 'Electronics', 1),
       (3, 'Phones', 2),
       (4, 'Smartphones', 3),
       (5, 'Laptops', 2),
       (6, 'Home', 1),
       (7, 'Kitchen', 6);

-- Task
WITH RECURSIVE electronics(id, name, depth, path) AS
                   (SELECT id, name, 0, name
                    FROM categories
                    WHERE parent_id IS NULL
                    UNION ALL
                    SELECT c.id, c.name, e.depth + 1, e.path || ' > ' || c.name
                    FROM categories c
                             JOIN electronics e
                                  ON c.parent_id = e.id)
SELECT *
FROM electronics;


-- RC8 · Bill of materials
-- Setup
CREATE TABLE bom
(
    parent    text,
    component text,
    qty       int
);
INSERT INTO bom
VALUES ('Bicycle', 'Wheel', 2),
       ('Bicycle', 'Frame', 1),
       ('Bicycle', 'Handlebar', 1),
       ('Wheel', 'Rim', 1),
       ('Wheel', 'Spoke', 36),
       ('Wheel', 'Tire', 1),
       ('Frame', 'Tube', 4),
       ('Frame', 'Bolt', 8),
       ('Handlebar', 'Grip', 2),
       ('Handlebar', 'Bolt', 4);

-- Task. Using a recursive CTE, list the total quantity of each raw part
-- (a component that is not itself built from others) needed to build one Bicycle.
WITH RECURSIVE parts(parent, component, qty, depth) AS
                   (SELECT parent, component, qty, 0
                    FROM bom
                    WHERE parent NOT IN (SELECT component FROM bom)
                    UNION ALL
                    SELECT b.parent, b.component, p.qty * b.qty, p.depth + 1
                    FROM bom b
                             JOIN parts p
                                  ON b.parent = p.component)
SELECT component, SUM(qty) AS quantity
FROM parts
WHERE component NOT IN (SELECT DISTINCT parent FROM bom)
GROUP BY component
ORDER BY component;


-- RC9 · Road network — fewest hops
-- Setup
CREATE TABLE roads
(
    a text,
    b text
);
INSERT INTO roads
VALUES ('A', 'B'),
       ('B', 'C'),
       ('A', 'D'),
       ('D', 'C'),
       ('C', 'E');

-- Task. Treating roads as undirected, use a recursive CTE to return the smallest number of hops
-- from city 'A' to every reachable city. Guard against cycles.
WITH RECURSIVE undirected(a, b) AS
    (
        SELECT a, b FROM roads
                    UNION
        SELECT b, a FROM roads
    ),
    routes(dest, hop, visited) AS
                   (SELECT 'A', 0, ARRAY['A']

                    UNION ALL

                    SELECT u.b, r.hop + 1, visited || u.b
                    FROM routes r
                    JOIN undirected u
                    ON r.dest = u.a
                    WHERE NOT (u.b = ANY(r.visited))
                    )
SELECT dest, MIN(hop) AS fewest_hops
FROM routes
GROUP BY dest
ORDER BY fewest_hops, dest;


-- RC10 · Threaded comments
-- Setup.
CREATE TABLE comments
(
    id        int PRIMARY KEY,
    parent_id int,
    author    text,
    body      text
);
INSERT INTO comments
VALUES (1, NULL, 'Ana', 'Original post'),
       (2, 1, 'Ben', 'I agree'),
       (3, 1, 'Cy', 'Not sure'),
       (4, 2, 'Ana', 'Thanks'),
       (5, 3, 'Ben', 'Why?');


-- Task. Using a recursive CTE, print the whole comment thread in reply order, each comment indented according to its depth.
WITH RECURSIVE comment_reply(id, parent_id, author, body, depth) AS
    (
        SELECT id, parent_id, author, body, 0 FROM comments WHERE parent_id IS NULL

        UNION ALL

        SELECT c.id, c.parent_id, c.author, c.body, cr.depth + 1
        FROM comments c
        JOIN comment_reply cr
        ON c.parent_id = cr.id

    ) SEARCH DEPTH FIRST  BY id SET ordercol
SELECT id, parent_id, author, REPEAT(' ', depth + 1) || body, depth FROM comment_reply ORDER BY ordercol;