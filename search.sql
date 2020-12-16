-- Make a search query with one word "<word>" and get the overview information (name, latest version and release date). The results show presets where the word matches exactly a tag or is contained in the preset name or the associated game name. The results are distinct and ordered by date (the most recent first). Yanked presets are not shown as the latest presets. Only public presets are reported.

SELECT DISTINCT pg.name,
    p.version,
    p.date::date
FROM preset_group as pg
    LEFT JOIN pg_contains_t AS c ON c.pg_id = pg.id
    LEFT JOIN launches_with AS lw ON lw.pg_id = pg.id
    JOIN preset AS p ON p.pg_id = pg.id
    JOIN (
        SELECT
            pg_id,
            MAX(date) AS date
        FROM preset as p
        WHERE NOT is_yanked
        GROUP BY pg_id
    ) AS p2 ON p2.pg_id = pg.id AND p2.date = p.date
WHERE (
        pg.name LIKE '%<word>%'
        OR c.tag = '<word>'
        OR lw.game LIKE '%<word>%'
    )
    AND is_public
ORDER BY p.date::date DESC;

-- <word> -> Half-life