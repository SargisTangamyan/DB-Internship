CREATE OR REPLACE FUNCTION find_duplicate_combinations(
    p_table_name text,
    p_columns text[]
)
    RETURNS TABLE
            (
                combination      text,
                occurrence_count bigint
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    col_list text;
    query    text;
BEGIN
    -- quote_ident each column, then join with commas
    SELECT string_agg(quote_ident(c), ', ')
    INTO col_list
    FROM unnest(p_columns) AS c;

    query := format(
            'SELECT (%s)::text AS combination, count(*) AS occurrence_count
             FROM %I
             GROUP BY %s
             HAVING count(*) > 1
             ORDER BY count(*) DESC',
            col_list, p_table_name, col_list
             );

    RETURN QUERY EXECUTE query;
END;
$$;

DROP FUNCTION find_duplicate_combinations;

SELECT *
FROM find_duplicate_combinations('unnormalized', ARRAY ['accession_code', 'scientific_name']);


CREATE OR REPLACE FUNCTION find_shared_elements(
    p_table_name text,
    p_columns text[]
)
    RETURNS TABLE
            (
                source_column       text,
                element_value       text,
                paired_with_count   bigint,
                paired_combinations text[]
            )
    LANGUAGE plpgsql
AS
$$
DECLARE
    col            text;
    other_cols     text[];
    other_col_list text;
    query          text;
BEGIN
    FOREACH col IN ARRAY p_columns
        LOOP
            other_cols := array_remove(p_columns, col);

            SELECT string_agg(quote_ident(c), ', ')
            INTO other_col_list
            FROM unnest(other_cols) AS c;

            query := format(
                    'SELECT %L AS source_column,
                            (%I)::text AS element_value,
                            count(DISTINCT (%s)) AS paired_with_count,
                            array_agg(DISTINCT (%s)::text) AS paired_combinations
                     FROM %I
                     GROUP BY %I
                     HAVING count(DISTINCT (%s)) > 1',
                    col, col, other_col_list, other_col_list,
                    p_table_name, col, other_col_list
                     );

            RETURN QUERY EXECUTE query;
        END LOOP;
END;
$$;

SELECT *
FROM find_shared_elements('unnormalized', ARRAY ['accession_code', 'planted_date', 'acquired_from', 'plant_id', 'location_id']);