-- Insert Operations

INSERT INTO language
VALUES -- language codes according to ISO 639-2/T
    ('eng', 'English'),
    ('zho', '\u20013\u25991'),
    ('ita', 'Italiano');

INSERT INTO game
VALUES (
        'Half-life: Alyx',
        'Half-Life: Alyx is Valve''s VR return to the Half-Life series. It''s the story of an impossible fight against a vicious alien race known as the Combine, set between the events of Half-Life and Half-Life 2. Playing as Alyx Vance, you are humanity''s only chance for survival.',
        'https://store.steampowered.com/app/546560/HalfLife_Alyx/'
    ),
    (
        'Subnautica',
        'Descend into the depths of an alien underwater world filled with wonder and peril. Craft equipment, pilot submarines and out-smart wildlife to explore lush coral reefs, volcanoes, cave systems, and more - all while trying to survive.',
        'https://store.steampowered.com/app/264710/Subnautica/'
    ),
    (
        'Google Earth VR',
        'Google Earth VR lets you explore the world from totally new perspectives in virtual reality. Stroll the streets of Tokyo, soar over the Grand Canyon, or walk around the Eiffel Tower.',
        'https://store.steampowered.com/app/348250/Google_Earth_VR/'
    );

INSERT INTO setup
VALUES ('Nvidia RTX 3080', 'Nvidia graphics card'),
    ('AMD Ryzen 7 5800', 'AMD CPU'),
    ('Nvidia GTX 1060', 'Nvidia graphics card'),
    ('AMD Radeon RX 580', 'AMD graphics card'),
    ('Oculus Quest 2', 'Oculus head mounted display'),
    ('ASUS RT1200', 'Asus router');

INSERT INTO release(version, is_yanked)
VALUES ('14.0.0-alpha.2+nightly.20201211', TRUE),
    ('14.0.0-beta.1', FALSE);

INSERT INTO setting(name)
VALUES ('video_resolution_width'),
    ('video_resolution_height'),
    ('a_button'),
    ('b_button'),
    ('bitrate'), -- was in KB
    ('bitrate'); -- was changed in bytes (the behavior changed)

INSERT INTO TAG
VALUES ('controller mappings'),
    ('encoder'),
    ('compatibility');

INSERT INTO public.user(name, password, admin_privileges, email, language, is_deleted)
VALUES (
        'zarik5',
        'postgres1',
        TRUE,
        'riccardo.zaglia5@gmail.com',
        'eng',
        FALSE
    ),
    (
        'Kernel_Panic',
        'postgres2',
        FALSE,
        'kernelpanic@gmail.com',
        'ita',
        FALSE
    ),
    (
        'canteo',
        'postgres3',
        FALSE,
        'canteo@gmail.com',
        'ita',
        FALSE
    ),
    (
        'readlnh',
        'postgres4',
        TRUE,
        'read@gmail.com',
        'zho',
        FALSE
    );

INSERT INTO preset_group(name, owner, is_public)
VALUES (
        'HL:A controller mappings for Oculus Quest',
        1,
        TRUE
    ),
    ('Performance settings for ASUS routers', 4, TRUE),
    ('My modified HL:A mappings', 2, FALSE);

INSERT INTO preset
VALUES -- version, pg_id, authorid, code, is_yanked, date
    (
        '0.0.1-alpha.1',
        1,
        1,
        '{"a_button": "/input/a","b_button": "/button/b"}',
        FALSE,
        '2020-12-09 10:23:56'
    ),
    (
        '1.0.0',
        2,
        4,
        '{"bitrate": "5000"}',
        TRUE,
        '2020-12-10 11:54:45'
    ),
    (
        '1.0.1',
        2,
        3,
        '{"bitrate": "5000000"}',
        FALSE,
        '2020-12-10 22:04:00'
    ),
    (
        '0.0.1-alpha.2',
        3,
        2,
        '{"a_button": "/input/b","b_button": "/button/a"}',
        FALSE,
        '2020-12-10 17:00:07'
    );

INSERT INTO public.message(author, pg_id, is_deleted, text)
VALUES (
        2,
        1,
        FALSE,
        'Is this preset suitable for a GTX 1070? I tried to launch the game after applying it but it seems a bit fuzzy...'
    ),
    (
        1,
        2,
        FALSE,
        'The preset will be updated ASAP since some critical issues have been found'
    ),
    (
        1,
        1,
        FALSE,
        'It is but you should lower the resolution, that GPU may be not enough for this game (which is particularly demanding, btw)'
    ),
    (
        2,
        2,
        TRUE,
        'When will be this preset updated? Since two or three days, after the last patch for the game, my pc crashes whenever I start it :thumbsdown:'
    ),
    (
        2,
        3,
        FALSE,
        '@zarik5 Hello admin, can you publish this preset?'
    );

INSERT INTO notification(userid, text, is_read)
VALUES (3, 'Got a new message!', TRUE),
    (2, 'New updated preset!', FALSE),
    (1, '@Kernel_panic tagged you', FALSE);

INSERT INTO friend_with
VALUES (4, 3, TRUE),
    (2, 3, FALSE),
    (2, 1, TRUE);
-- Kernel_panic asked friendship with the admin zarik5 to upload an update to a preset

INSERT INTO u_owns_s
VALUES (1, 'Nvidia GTX 1060'),
    (1, 'Oculus Quest 2'),
    (2, 'ASUS RT1200'),
    (3, 'ASUS RT1200'),
    (4, 'AMD Ryzen 7 5800'),
    (4, 'Oculus Quest 2');

INSERT INTO subscribed_to
VALUES (2, 2, TRUE),
    (3, 2, FALSE),
    (4, 3, FALSE);

INSERT INTO reads
VALUES -- userid, m_index, pg_id
    (1, 1, 2),
    (2, 1, 1),
    (4, 2, 2);

INSERT INTO u_owns_g
VALUES -- userid, game, install_path
    (1, 'Half-life: Alyx', 'C:\Users\Zarik\Games\HLA'),
    (
        2,
        'Half-life: Alyx',
        'C:\Users\Kernel_Panic\Games\HLA'
    ),
    (
        3,
        'Subnautica',
        'E:\Users\canteo\Program_Files\Games\Subn'
    ),
    (
        4,
        'Google Earth VR',
        'D:\Users\readlnh\Pogram_Files\Games\GE VR'
    );

INSERT INTO pg_contains_t
VALUES (1, 'controller mappings'),
    (2, 'compatibility'),
    (3, 'controller mappings'),
    (3, 'compatibility');

INSERT INTO r_contains_s
VALUES -- release version, settingid
    ('14.0.0-alpha.2+nightly.20201211', 1),
    ('14.0.0-alpha.2+nightly.20201211', 2),
    ('14.0.0-alpha.2+nightly.20201211', 3),
    ('14.0.0-alpha.2+nightly.20201211', 4),
    ('14.0.0-alpha.2+nightly.20201211', 5),
    ('14.0.0-beta.1', 1),
    ('14.0.0-beta.1', 2),
    ('14.0.0-beta.1', 3),
    ('14.0.0-beta.1', 4),
    ('14.0.0-beta.1', 6);
-- the last setting (bitrate) was replaced

INSERT INTO interacts_with
VALUES -- p_version, pg_id, setting
    ('0.0.1-alpha.1', 1, 3),
    ('0.0.1-alpha.1', 1, 4),
    ('1.0.0', 2, 5),
    ('1.0.1', 2, 6),
    ('0.0.1-alpha.2', 3, 3),
    ('0.0.1-alpha.2', 3, 4);

INSERT INTO translated_in
VALUES -- language, p_version, pg_id, description
    (
        'eng',
        '0.0.1-alpha.1',
        1,
        'This is the first alpha release for the Half-Life:Alyx controller mappings for Oculus Quest'
    ),
    (
        'eng',
        '1.0.0',
        2,
        'Performance settings for the router ASUS RT1200'
    ),
    (
        'eng',
        '1.0.1',
        2,
        'Performance settings for the router ASUS RT1200. Changelog: the preset has been updated for ALVR 14.0.0-beta.1'
    ),
    (
        'eng',
        '0.0.1-alpha.2',
        3,
        'This is the second alpha release for the Half-Life:Alyx controller mappings for Oculus Quest'
    ),
    (
        'ita',
        '0.0.1-alpha.2',
        3,
        'Questa e'' la seconda versione alpha per la mappa dei controlli del visore Oculus Quest per il gioco Half-Life:Alyx'
    );

INSERT INTO works_on
VALUES -- setup, p_version, pg_id
    ('Oculus Quest 2', '0.0.1-alpha.1', 1),
    ('ASUS RT1200', '1.0.0', 2),
    ('ASUS RT1200', '1.0.1', 2),
    ('Oculus Quest 2', '0.0.1-alpha.2', 3);

INSERT INTO launches_with
VALUES ('Half-life: Alyx', 1),
    ('Half-life: Alyx', 3);