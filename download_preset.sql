-- Download a preset for a user by name and version. The downloaded information must contain code, description (in the preferred language by the user) and the compatible setups. For the scope of this query, the preset must be downloaded even if it is yanked, it is incompatible with the user software release or may contain setups different from the ones owned by the user.

-- get user language
SELECT language AS language_code
FROM public.user AS u
WHERE u.name == '<user_name>';

--get preset description languages
SELECT language AS language_code
FROM translated_in AS t
    JOIN preset_group AS pg ON pg.id = t.pg_id
WHERE pg.name = '<preset_name>'
    AND p_version = '<preset_version>';

-- select best description language (<language_code>) in the java part (go in order of: user preference, English, any other description language). <language_code> can be NULL if the preset had no descriptions

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
    AND t.language = < language_code >
GROUP BY u.name,
    u.is_deleted,
    p.code,
    is_yanked,
    date,
    description,
    game;