-- Dropping eventually existing Database
DROP DATABASE alvr;

-- Database creation
CREATE DATABASE alvr OWNER postgres ENCODING = 'UTF8';
\c alvr;

--Create new domains
CREATE DOMAIN lang_code AS VARCHAR(4) NOT NULL DEFAULT 'eng' CONSTRAINT lengthcheck CHECK ((VALUE)::text ~* '[a-z]{2,3}'::text);
CREATE DOMAIN version AS VARCHAR(64) NOT NULL;

--Tables creation
CREATE TABLE language (
    code LANG_CODE PRIMARY KEY,
    display_name VARCHAR(20) NOT NULL
);
CREATE TABLE game (
    name VARCHAR(60) PRIMARY KEY,
    description VARCHAR(1024) NOT NULL,
    web_page VARCHAR(256) NOT NULL
);
CREATE TABLE setup (
    name VARCHAR(32) PRIMARY KEY,
    description VARCHAR(256) NOT NULL
);
CREATE TABLE release (
    version VERSION PRIMARY KEY,
    is_yanked BOOLEAN NOT NULL
);
CREATE TABLE setting (
    id SERIAL UNIQUE PRIMARY KEY,
    name VARCHAR(256) NOT NULL
);
CREATE TABLE tag (name VARCHAR(20) PRIMARY KEY);

CREATE TABLE public.user (
    id SERIAL UNIQUE PRIMARY KEY,
    name VARCHAR(20) NOT NULL,
    password VARCHAR(128) NOT NULL,
    admin_privileges BOOLEAN NOT NULL,
    email VARCHAR(128) NOT NULL,
    language LANG_CODE,
    is_deleted BOOLEAN NOT NULL,
    FOREIGN KEY (language) REFERENCES language(code),
    CONSTRAINT pwd_regex CHECK (password::text ~* '[A-Za-z0-9.,_%&!?]{8,}'::text), -- passwords must be at least 8 characters long
    CONSTRAINT email_regex CHECK (email::text ~* '^[A-Za-z0-9._!]+@[A-Za-z0-9.]+[.][A-Za-z]'::text) -- characters and template constraints on emails
);
CREATE TABLE preset_group (
    id SERIAL UNIQUE PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    owner SERIAL NOT NULL,
    is_public BOOLEAN NOT NULL,
    FOREIGN KEY (owner) REFERENCES public.user(id)
);
CREATE TABLE preset (
    version version,
    pg_id SERIAL,
    author SERIAL NOT NULL,
    code TEXT NOT NULL,
    is_yanked BOOLEAN NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    PRIMARY KEY (version, pg_id),
    FOREIGN KEY (pg_id) REFERENCES preset_group(id),
    FOREIGN KEY (author) REFERENCES public.user(id)
);
CREATE TABLE public.message (
    index SERIAL UNIQUE PRIMARY KEY,
    author SERIAL NOT NULL,
    pg_id SERIAL NOT NULL,
    is_deleted BOOLEAN NOT NULL,
    text VARCHAR(2000) NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE notification (
    index SERIAL UNIQUE PRIMARY KEY,
    userid SERIAL NOT NULL,
    text VARCHAR(256) NOT NULL,
    is_read BOOLEAN NOT NULL,
    date TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    FOREIGN KEY (userid) REFERENCES public.user(id)
);
CREATE TABLE friend_with (
    userid SERIAL,
    friend SERIAL,
    request_accepted BOOLEAN NOT NULL,
    PRIMARY KEY (userid, friend),
    FOREIGN KEY (userid) REFERENCES public.user(id),
    FOREIGN KEY (friend) REFERENCES public.user(id),
    CONSTRAINT no_self_friendship CHECK (userid <> friend)
);
CREATE TABLE u_owns_s (
    userid SERIAL,
    setup VARCHAR(32),
    PRIMARY KEY (userid, setup),
    FOREIGN KEY (userid) REFERENCES public.user(id),
    FOREIGN KEY (setup) REFERENCES setup(name)
);
CREATE TABLE subscribed_to (
    userid SERIAL,
    pg_id SERIAL,
    download_prereleases BOOLEAN NOT NULL,
    PRIMARY KEY (userid, pg_id),
    FOREIGN KEY (userid) REFERENCES public.user(id),
    FOREIGN KEY (pg_id) REFERENCES preset_group(id)
);
CREATE TABLE reads (
    userid SERIAL,
    m_index SERIAL NOT NULL,
    pg_id SERIAL,
    PRIMARY KEY (userid, pg_id),
    FOREIGN KEY (userid) REFERENCES public.user(id),
    FOREIGN KEY (pg_id) REFERENCES preset_group(id),
    FOREIGN KEY (m_index) REFERENCES message(index)
);
CREATE TABLE u_owns_g (
    userid SERIAL,
    game VARCHAR(60),
    install_path VARCHAR(1024),
    PRIMARY KEY (userid, game),
    FOREIGN KEY (userid) REFERENCES public.user(id),
    FOREIGN KEY (game) REFERENCES game(name)
);
CREATE TABLE pg_contains_t (
    pg_id SERIAL,
    tag VARCHAR(20),
    PRIMARY KEY (pg_id, tag),
    FOREIGN KEY (pg_id) REFERENCES preset_group(id),
    FOREIGN KEY (tag) REFERENCES tag(name)
);
CREATE TABLE r_contains_s (
    release VARCHAR(64),
    setting SERIAL,
    PRIMARY KEY (release, setting),
    FOREIGN KEY (release) REFERENCES release(version),
    FOREIGN KEY (setting) REFERENCES setting(id)
);
CREATE TABLE interacts_with (
    p_version version,
    pg_id SERIAL,
    setting SERIAL,
    PRIMARY KEY (p_version, pg_id, setting),
    FOREIGN KEY (p_version, pg_id) REFERENCES preset(version, pg_id),
    FOREIGN KEY (setting) REFERENCES setting(id)
);
CREATE TABLE translated_in (
    language LANG_CODE,
    p_version version,
    pg_id SERIAL,
    PRIMARY KEY (language, p_version, pg_id),
    description VARCHAR(256) NOT NULL,
    FOREIGN KEY (language) REFERENCES language(code),
    FOREIGN KEY (p_version, pg_id) REFERENCES preset(version, pg_id)
);
CREATE TABLE works_on (
    setup VARCHAR(32),
    p_version version,
    pg_id SERIAL,
    PRIMARY KEY (setup, p_version, pg_id),
    FOREIGN KEY (setup) REFERENCES setup(name),
    FOREIGN KEY (p_version, pg_id) REFERENCES preset(version, pg_id)
);
CREATE TABLE launches_with (
    game VARCHAR(60),
    pg_id SERIAL,
    PRIMARY KEY (game, pg_id),
    FOREIGN KEY (game) REFERENCES game(name),
    FOREIGN KEY (pg_id) REFERENCES preset_group(id)
);