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

CREATE TABLE public.user (
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
        FOREIGN KEY (owner) REFERENCES public.user(id),
        FOREIGN KEY (game) REFERENCES game(name)
);

CREATE TABLE preset (
    version VARCHAR(20),
    pg_id SERIAL,
    author SERIAL NOT NULL,
    code TEXT NOT NULL,
    is_yanked BOOLEAN NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        FOREIGN KEY (author) REFERENCES public.user(id),
        PRIMARY KEY (version, pg_id)
);

CREATE TABLE public.message (
    index SERIAL PRIMARY KEY,
    author SERIAL NOT NULL,
    pg_id SERIAL NOT NULL,
    is_deleted BOOLEAN NOT NULL,
    text VARCHAR(2000) NOT NULL
);

CREATE TABLE notification (
    index SERIAL PRIMARY KEY,
    userid SERIAL NOT NULL, --user became userid
    text VARCHAR(256) NOT NULL,
    is_read BOOLEAN NOT NULL,
        FOREIGN KEY (userid) REFERENCES public.user(id)
);

CREATE TABLE friend_with (
    userid SERIAL, --user became userid
    friend SERIAL,
    request_accepted BOOLEAN NOT NULL,
        FOREIGN KEY (userid) REFERENCES public.user(id),
        FOREIGN KEY (friend) REFERENCES public.user(id),
        PRIMARY KEY (userid, friend)
);

CREATE TABLE u_owns_s (
    userid SERIAL, --user became userid
    game VARCHAR(20),
    install_path VARCHAR(256) NOT NULL,
        FOREIGN KEY (userid) REFERENCES public.user(id),
        FOREIGN KEY (game) REFERENCES game(name),
        PRIMARY KEY (userid, game)
);

CREATE TABLE subscribed_to (
    userid SERIAL, --user became userid
    pg_id SERIAL,
    download_prereleases BOOLEAN NOT NULL,
        FOREIGN KEY (userid) REFERENCES public.user(id),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        PRIMARY KEY (userid, pg_id)
);

CREATE TABLE reads (
    userid SERIAL, --user became userid
    m_index SERIAL NOT NULL,
    pg_id SERIAL,
        FOREIGN KEY (userid) REFERENCES public.user(id),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        FOREIGN KEY (m_index) REFERENCES message(index),
        PRIMARY KEY (userid, pg_id)
);

CREATE TABLE u_own_g (
    userid SERIAL, --user became userid
    game VARCHAR(20),
    install_path VARCHAR(1024),
        FOREIGN KEY (userid) REFERENCES public.user(id),
        FOREIGN KEY (game) REFERENCES game(name),
        PRIMARY KEY (userid, game)
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
        FOREIGN KEY (p_version, pg_id) REFERENCES preset(version, pg_id),
        FOREIGN KEY (setting) REFERENCES setting(id),
        PRIMARY KEY (p_version, pg_id, setting)
);

CREATE TABLE translated_in (
    language CODE,
    p_version VARCHAR(20),
    pg_id SERIAL,
    description VARCHAR(256) NOT NULL,
        FOREIGN KEY (language) REFERENCES language(code),
        FOREIGN KEY (p_version, pg_id) REFERENCES preset(version, pg_id),
        PRIMARY KEY (language, p_version, pg_id)
);

CREATE TABLE works_on (
    setup VARCHAR(20),
    p_version VARCHAR(20),
    pg_id SERIAL,
        FOREIGN KEY (setup) REFERENCES setup(name),
        FOREIGN KEY (p_version, pg_id) REFERENCES preset(version, pg_id),
        PRIMARY KEY (setup, p_version, pg_id)
);

CREATE TABLE launches_with (
    game VARCHAR(20),
    pg_id SERIAL,
        FOREIGN KEY (game) REFERENCES game(name),
        FOREIGN KEY (pg_id) REFERENCES preset_group(id),
        PRIMARY KEY (game, pg_id)
);