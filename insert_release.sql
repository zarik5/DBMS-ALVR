insert release version


for each (setting_name: string, behavior_changed: bool):

    serial? id = project setting.id (select setting setting.name == "<setting_name>")
    if (id == null || (!id != null && behavior_changed)):
        insert setting (new_id, setting_name)

    id = id || new_id
    insert r_contsins_s ("<release_version>", id)


JSON example:

{
    "setting1": "value1",
    "setting2": 123
}

release version example:

1.2.3-beta.1+nightly.20201211