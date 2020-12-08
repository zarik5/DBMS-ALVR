-- Database Creation
CREATE DATABASE alvr OWNER postgres ENCODING = 'UTF8';

--Create new domains
CREATE DOMAIN passwd AS VARCHAR(128)
    CONSTRAINT checkpw CHECK (((VALUE) :: text ~* '[A-Za-z0-9.,_%&!?]{10,}'::text));

CREATE DOMAIN email AS VARCHAR(128)
    CONSTRAINT checkemail CHECK (((VALUE) :: text ~* '^[A-Za-z0-9._!]+@[A-Za-z0-9.]+[.][A-Za-z]'::text));

CREATE DOMAIN code AS VARCHAR(64)
    CONSTRAINT checkcode CHECK (((VALUE) :: text ~* '[A-Za-z]{2,3}' ::text));

--Tables creation
CREATE TABLE language (
    code CODE PRIMARY KEY,
    display_name VARCHAR(20) NOT NULL
);

CREATE TABLE game (
    name VARCHAR(20) PRIMARY KEY,
    description VARCHAR(256) NOT NULL,
    web_page VARCHAR(256) NOT NULL
);

CREATE TABLE setup (
    name VARCHAR(20) PRIMARY KEY,
    description VARCHAR(256) NOT NULL
);

CREATE TABLE release (
    version VARCHAR(20) PRIMARY KEY,
    is_yanked BOOLEAN NOT NULL
);

CREATE TABLE setting (
    id SERIAL PRIMARY KEY,
    name VARCHAR(256) NOT NULL
);

CREATE TABLE tag (
    name VARCHAR(20) PRIMARY KEY
);

CREATE TABLE user (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    password PASSWD NOT NULL,
    admin_privileges BOOLEAN NOT NULL,
    email EMAIL NOT NULL,
    language CODE NOT NULL,
    is_deleted BOOLEAN NOT NULL,
        FOREIGN KEY (language) REFERENCES language(code)
);

CREATE TABLE preset_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    owner SERIAL NOT NULL,
    game VARCHAR(20),
    is_public BOOLEAN NOT NULL,
        FOREIGN KEY (owner) REFERENCES user(id),
        FOREIGN KEY (game) REFERENCES game(name)
);

CREATE TABLE preset (
    version VARCHAR(20),
    pg_id SERIAL,
    author SERIAL NOT NULL,
    code TEXT NOT NULL,
    is_yanked BOOLEAN NOT NULL,
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        FOREIGN KEY (author) REFERENCES user(id),
        PRIMARY KEY (version, pg_id)
);

CREATE TABLE message (
    index SERIAL PRIMARY KEY,
    author SERIAL NOT NULL,
    pg_id SERIAL NOT NULL,
    is_deleted BOOLEAN NOT NULL,
    text VARCHAR(2000) NOT NULL,
);

CREATE TABLE notification (
    index SERIAL PRIMARY KEY,
    user SERIAL NOT NULL,
    text VARCHAR(256) NOT NULL,
    is_read BOOLEAN NOT NULL,
        FOREIGN KEY (user) REFERENCES user(id)
);

CREATE TABLE friend_with (
    user SERIAL,
    friend SERIAL,
    request_accepted BOOLEAN NOT NULL,
        FOREIGN KEY (user) REFERENCES user(id),
        FOREIGN KEY (friend) REFERENCES user(id),
        PRIMARY KEY (user, friend)
);

CREATE TABLE u_owns_s (
    user SERIAL,
    game VARCHAR(20),
    install_path VARCHAR(256) NOT NULL,
        FOREIGN KEY (user) REFERENCES user(id),
        FOREIGN KEY (game) REFERENCES game(name),
        PRIMARY KEY (user, game)
);

CREATE TABLE subscribed_to (
    user SERIAL,
    pg_id SERIAL,
    download_prereleases BOOLEAN NOT NULL,
        FOREIGN KEY (user) REFERENCES user(id),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        PRIMARY KEY (user, pg_id)
);

CREATE TABLE reads (
    user SERIAL,
    m_index SERIAL NOT NULL,
    pg_id SERIAL,
        FOREIGN KEY (user) REFERENCES user(id),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        FOREIGN KEY (m_index) REFERENCES message(id),
        PRIMARY KEY (user, pg_id)
);

CREATE TABLE u_own_g (
    user SERIAL,
    game VARCHAR(20),
    install_path VARCHAR(1024),
        FOREIGN KEY (user) REFERENCES user(id),
        FOREIGN KEY (game) REFERENCES game(name),
        PRIMARY KEY (user, game)
);

CREATE TABLE pg_contains_t (
    pg_id SERIAL,
    tag VARCHAR(20),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        FOREIGN KEY (tag) REFERENCES tag(name),
        PRIMARY KEY (pg_id, tag)
);

CREATE TABLE r_contains_s (
    release VARCHAR(20),
    setting SERIAL,
        FOREIGN KEY (release) REFERENCES release(version),
        FOREIGN KEY (setting) REFERENCES setting(id),
        PRIMARY KEY (release, setting)
);

CREATE TABLE interacts_with (
    p_version VARCHAR(20),
    pg_id SERIAL,
    setting SERIAL,
        FOREIGN KEY (p_version) REFERENCES preset(version),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        FOREIGN KEY (setting) REFERENCES setting(id),
        PRIMARY KEY (p_version, pg_id, setting)
);

CREATE TABLE translated_in (
    language CODE,
    p_version VARCHAR(20),
    pg_id SERIAL,
    description VARCHAR(256) NOT NULL,
        FOREIGN KEY (language) REFERENCES language(code),
        FOREIGN KEY (p_version) REFERENCES preset(version),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        PRIMARY KEY (language, p_version, pg_id)
);

CREATE TABLE works_on (
    setup VARCHAR(20),
    p_version VARCHAR(20),
    pg_id SERIAL,
        FOREIGN KEY (setup) REFERENCES setup(name),
        FOREIGN KEY (p_version) REFERENCES preset(version),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        PRIMARY KEY (setup, p_version, pg_id)
);