insert release version


for each (setting_name: string, behavior_changed: bool):

    serial? id = project setting.id (select setting setting.name == "<setting_name>")
    if (id == null || (!id != null && behavior_changed)):
        insert setting (new_id, setting_name)

    id = id || new_id
    insert r_contsins_s ("<release_version>", id)

------------------------------------------

-- Insert a new release and information about the associated settings, making sure to handle new settings with the same name
