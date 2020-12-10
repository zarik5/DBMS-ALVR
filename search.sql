-- latest_preset:

1) we have the preset_group ID
2) select from preset preset_group.ID == preset.PG_ID AND is_yanked == FALSE
3) select max(preset.date)
4) natural join preset_group.ID == preset.PG_ID

SELECT name
    FROM preset as P INNER JOIN preset_group as PG ON PG.id = P.pg_id
    WHERE P.is_yanked == FALSE AND P.date = MAX(P.date);

-- pg_from_name:

1) select latest_preset preset_group.name == "<query>"
2) projection (id, name, is_public, version)

SELECT id, name, is_public, version
    FROM preset_group
    WHERE preset_group.name = (SELECT name
                                FROM preset as P INNER JOIN preset_group as PG ON PG.id = P.pg_id
                                WHERE P.is_yanked == FALSE AND P.date = MAX(P.date)
    );


-- pg_from_tag:

1) select pg_contains_t pg_contains_t.tag == "<tag>"
2) natural join (1).pg_id == latest_preset.id
3) projection (id, name, is_public, version)

-- pg_from_game:

1) select launches_with launches_with.game == "<game>"
2) natural join (1).pg_id == latest_preset.id
3) projection (id, name, is_public, version)

-- search:

1) union pg_from_name, pg_from_tag, pg_from_game
2) select (1).is_public == TRUE
3) projection preset_group.name, preset.version