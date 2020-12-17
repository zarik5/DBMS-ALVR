--1) -----------------------------------------------------------------------------------------
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


-- 2)-------------------------------------------------------------------------------------------
-- Download a preset for a user by name and version. The downloaded information must contain code, description (in the preferred language by the user) and the compatible setups. For the scope of this query, the preset must be downloaded even if it is yanked, it is incompatible with the user software release or may contain setups different from the ones owned by the user.

-- get user language
SELECT language AS language_code
FROM public.user AS u
WHERE u.name = '<user_name>' AND NOT u.is_deleted;

--get preset description languages
SELECT language AS language_code
FROM translated_in AS t
    JOIN preset_group AS pg ON pg.id = t.pg_id
WHERE pg.name = '<preset_name>'
    AND p_version = '<preset_version>';

-- select best description language (<language_code>) in the java part (go in order of: user preference, English, any other description language). <language_code> cannot be null

-- get result
SELECT u.name AS author,
    u.is_deleted AS is_author_deleted,
    p.code,
    is_yanked,
    date,
    description,
    game,
    ARRAY_AGG(w.setup) AS setups
FROM preset AS p
    JOIN preset_group AS pg ON pg.id = p.pg_id
    LEFT JOIN launches_with AS lw ON lw.pg_id = pg.id
    LEFT JOIN translated_in AS t ON t.p_version = p.version
    AND t.pg_id = p.pg_id
    LEFT JOIN works_on AS w ON w.p_version = p.version
    AND w.pg_id = p.pg_id
    JOIN public.user AS u ON u.id = p.author
WHERE pg.name = '<preset_name>'
    AND p.version = '<preset_version>'
    AND (t.language = '<language_code>' OR t.language IS NULL)
GROUP BY u.name,
    u.is_deleted,
    p.code,
    is_yanked,
    date,
    description,
    game;

-- 3) --------------------------------------------------------------------------
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

-- 4) ------------------------------------------------------------------------------
-- Retrieve the number of messages of all preset groups chats, to check the traffic inside the DBMS.

SELECT COUNT(*) as messages
FROM public.message as m
WHERE m.date BETWEEN CURRENT_TIMESTAMP - INTERVAL '1 week' AND CURRENT_TIMESTAMP