-- Insert Operations

-- Language
INSERT INTO language VALUES
    ('eng', 'Italian'),
    ('zho', 'Chinese'),
    ('ita', 'English'); -- language codes according to ISO 639-2/T

-- Game
INSERT INTO game VALUES
    ('Half-life: Alyx', 'Half-Life: Alyx is Valve’s VR return to the Half-Life series. It’s the story of an impossible fight against a vicious alien race known as the Combine, set between the events of Half-Life and Half-Life 2. Playing as Alyx Vance, you are humanity’s only chance for survival.', 'https://store.steampowered.com/app/546560/HalfLife_Alyx/'),
    ('Subnautica', 'Descend into the depths of an alien underwater world filled with wonder and peril. Craft equipment, pilot submarines and out-smart wildlife to explore lush coral reefs, volcanoes, cave systems, and more - all while trying to survive.', 'https://store.steampowered.com/app/264710/Subnautica/'),
    ('Google Earth VR', 'Google Earth VR lets you explore the world from totally new perspectives in virtual reality. Stroll the streets of Tokyo, soar over the Grand Canyon, or walk around the Eiffel Tower.', 'https://store.steampowered.com/app/348250/Google_Earth_VR/');

-- Setup
INSERT INTO setup VALUES
    ('Nvidia RTX 3080', 'GPU'),
    ('AMD Ryzen 7 5800', 'CPU'),
    ('Nvidia GTX 1070', 'GPU'),
    ('AMD Radeon RX 580','GPU');

-- Release
INSERT INTO release(version, is_yanked) VALUES
    ('1.2.1-beta.1.20201110', FALSE),
    ('2.3.9-20200325', TRUE),
    ('2.4.0-20200329', FALSE),
    ('3.1.3-alpha.2.20190212', TRUE),
    ('1.2.3-beta.1+nightly.20201211', TRUE);
    

-- Setting
INSERT INTO setting(name) VALUES
    ('Pippo'),
    ('Topolino'),
    ('Gastone')
    ('Pluto'); --may need real names

-- TAG
INSERT INTO TAG VALUES
    (''),
    (''); -- what kind of TAG should we put?

-- User
INSERT INTO public.user(name, password, admin_privileges, email, language, is_deleted) VALUES 
    ('Zarik', 'postgres1', TRUE, 'zarik@gmail.com', 'ita', FALSE),
    ('Kernel_Panic', 'postgres2', FALSE, 'kernelpanic@gmail.com', 'ita', FALSE),
    ('Canteo', 'postgres3', FALSE, 'canteo@gmail.com', 'eng', FALSE),
    ('readlnh', 'postgres4', TRUE, 'read@gmail.com', 'zho', FALSE);

-- Preset Group
INSERT INTO preset_group(name, owner, game, is_public) VALUES
    ('Paperino', 'Zarik', 'Subnautica', TRUE),
    ('Topolino', 'readlnh', 'Half-life: Alyx', TRUE),
    ('Test', 'Kernel_Panic', 'Subnautica', FALSE); -- may need real names

-- Preset
INSERT INTO preset VALUES
    ('', 1, 1, '"setting1": "value1","setting2": 123', FALSE, '2019-05-09 10:23:56'), -- are preset version in the same format as release?
    ('', 2, 1, '"setting1": "value1","setting2": 123', FALSE, '2018-06-09 22:04:00'), -- 
    ('', 2, 4, '"setting1": "value1","setting2": 123', TRUE, '2020-07-10 11:54:45'),
    ('', 3, 4, '"setting1": "value1","setting2": 123', FALSE, '2017-08-11 16:58:09'),
    ('', 3, 4, '"setting1": "value1","setting2": 123', FALSE, '2017-08-11 17:00:07');
    
-- Message
INSERT INTO public.message(author, pg_id, is_deleted, text) VALUES
    (2, 2, FALSE, 'Is this preset suitable for a GTX 1070? I tried to launch the game after applying it but it seems a bit fuzzy...'),
    (1, 3, FALSE, 'The preset will be updated ASAP since some critical issues have been found'),
    (1, 2, FALSE, 'It is but you should lower the resolution, that GPU may be not enough for this game (which is particularly demandind)')
    (3, 3, TRUE, 'When will be this preset updated? Since two or three days, after the last patch for the game, my pc crashes whenever I start it :thumbsdown:');

-- Notification
INSERT INTO notification(userid, text, is_read) VALUES
    (1, 'Got a new message!', TRUE),
    (2, 'New updated preset!', FALSE);

-- Friend_with
INSERT INTO friend_with VALUES
    (1, 2, TRUE),
    (2, 3, TRUE),
    (1, 4, FALSE);
    
-- u_owns_s
INSERT INTO u_owns_s VALUES 
    (1, 'Nvidia RTX 3080'),
    (2, 'Nvidia GTX 1070'),
    (3, 'AMD Radeon RX 580'),
    (4, 'AMD Ryzen 7 5800');

-- subscribed_to
INSERT INTO subscribed_to VALUES
    (1, 1, TRUE),
    (2, 1, FALSE),
    (3, 2, FALSE);

-- reads
INSERT INTO reads VALUES
    (1, 1, 2),
    (3, 2, 1);

-- u_owns_g
INSERT INTO u_owns_g VALUES
    (1, 'Half-life: Alyx','C:\Users\Zarik\Games\HLA'),
    (2, 'Subnautica','E:\Users\Kernel_Panic\Program_Files\Games\Subn'),
    (2, 'Google Earth VR', 'D:\Users\Kernel_Panic\Pogram_Files\Games\GE VR');

-- pg_contains_t
INSERT INTO pg_contains_t VALUES 
    (1, ''),
    (1, ''),
    (2, ''),
    (3, '');
    
-- r_contains_s
INSERT INTO r_contains_s VALUES
    ('1.2.1-beta.1.20201110', 1),
    ('2.3.9-20200325', 2),
    ('2.4.0-20200329', 2),
    ('3.1.3-alpha.2.20190212', 4);
    
-- interacts_with
INSERT INTO interacts_with VALUES 
    ('',1,1),
    ('',2,1),
    ('',3,2);

-- translated_in
INSERT INTO translated_in VALUES
    ('eng','',1,'This preset is magic'), --may need real descriptions
    ('eng','',1,'This preset is supposed to do something'),
    ('ita','',2,'This preset just want to die');

-- works_on
INSERT INTO works_on VALUES
    ('Nvidia RTX 3080','',1),
    ('AMD Ryzen 7 5800','',2);

-- launches_with
INSERT INTO launches_with VALUES
    ();
    
