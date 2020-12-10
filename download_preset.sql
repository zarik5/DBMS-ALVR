
get user_id_language:
select id, language from user where user.name == "<user_name>"

get pg_id (from preset_name):
select id from preset_group where preset_group.name = "<preset_name>"


get preset languages:
    input: (preset_version, preset_group_id)
    output: (language_code, language_name)

    1) select * from preset where preset.version == "<preset_version>" and preset.pg_id == <pg_id>
    2) natural join (1).version == translated_in.p_version, (1).pg_id == translated_in.pg_id
    3) natural join (2).language == language.code
    4) projection ((3).code, (3).display_name)

-- the application chooses the language from the user language and preset languages
-- output: language_code, language_name

get preset info:
    input: (user_id, preset_version, pg_id, language)
    output: (author_name, author_is_deleted, code, date, description)

    1) select * from preset where preset.version == "<preset_version>" and preset.pg_id == <pg_id>
    2) select description from translated_in where translated_in.language == <language_code>
    3) natural join (1).version == (2).p_version, (1).pg_id == (2).pg_id
    4) natural join (3).author == user.id
    5) projection ((4).name, (4).is_deleted, (4).code, (4).date, (4).description)

get setups:
    select setup from works_on where works_on.p_version == "<preset_version>" and works_on.pg_id == <pg_id>