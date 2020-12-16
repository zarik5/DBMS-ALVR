
-- Check if a preset (by name and version) is compatible with a certain software release

-- output: no rows if not compatible, otherwise one row with the number of settings 

SELECT *
FROM (
        SELECT COUNT(*) AS settings_count
        FROM interacts_with AS i
            JOIN preset_group AS pg ON pg.id = i.pg_id
        WHERE pg.name = '<preset_name>'
            AND i.p_version = '<preset_version>'
    ) AS sc
WHERE sc.settings_count = (
        SELECT COUNT(*)
        FROM interacts_with AS i
            JOIN preset_group AS pg ON pg.id = i.pg_id
            JOIN r_contains_s AS c ON c.setting = i.setting
        WHERE pg.name = '<preset_name>'
            AND i.p_version = '<preset_version>'
            AND c.release = '<release_version>'
    );
-- alternative:
SELECT *
FROM (
        SELECT COUNT(*) AS settings_count
        FROM r_contains_s AS c
        WHERE c.release = '<release_version>'
    ) AS sc
WHERE sc.settings_count = (
        SELECT COUNT(*)
        FROM (
                SELECT i.setting
                FROM interacts_with AS i
                    JOIN preset_group AS pg ON pg.id = i.pg_id
                WHERE pg.name = '<preset_name>'
                    AND i.p_version = '<preset_version>'
                UNION
                SELECT c.setting
                FROM r_contains_s AS c
                WHERE c.release = '<release_version>'
            ) AS _
    );