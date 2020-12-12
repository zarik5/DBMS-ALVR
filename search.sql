-- latest_preset:

1) we have the preset_group ID
2) select from preset preset_group.ID == preset.PG_ID AND is_yanked == FALSE
3) select max(preset.date)
4) natural join preset_group.ID == preset.PG_ID

SELECT *
FROM (
    SELECT *, MAX(p.date)
    FROM preset AS p
    WHERE p.is_yanked = FALSE AND p.pg_id = <pg_id>;
    GROUP BY *
)
JOIN preset_group AS pg ON pg.id = p.pg_id
WHERE pg.is_public = TRUE;

-- pg_from_name:

1) select latest_preset preset_group.name == "<query>"
2) projection (id, name, is_public, version)

SELECT pg.id, pg.name, pg.is_public, p.version
FROM (<latest_preset>)
WHERE pg.name = "<query>";

-- pg_from_tag:

1) select pg_contains_t pg_contains_t.tag == "<tag>"
2) natural join (1).pg_id == latest_preset.id
3) projection (id, name, is_public, version)

SELECT pg.id, pg.name, pg.is_public, p.version
FROM (<latest_preset>)
JOIN pg_contains_t AS c ON c.pg_id = pg.id
WHERE c.tag = "<query>";

-- pg_from_game:

1) select launches_with launches_with.game == "<game>"
2) natural join (1).pg_id == latest_preset.id
3) projection (id, name, is_public, version)

SELECT pg.id, pg.name, pg.is_public, p.version
FROM (<latest_preset>)
JOIN launches_with AS lw ON lw.pg_id = pg.id
WHERE lw.game = "<query>";

-- search:

1) union pg_from_name, pg_from_tag, pg_from_game
2) select (1).is_public == TRUE
3) projection preset_group.name, preset.version

SELECT pg.name, p.version
FROM (
    <pg_from_name>
    UNION
    <pg_from_tag>
    UNION
    <pg_from_game>
)