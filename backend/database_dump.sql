--
-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: archivierte_planungen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.archivierte_planungen (
    original_planung_id integer NOT NULL,
    planungphase_id integer NOT NULL,
    professor_id integer NOT NULL,
    professor_name character varying(255) NOT NULL,
    semester_id integer NOT NULL,
    semester_name character varying(255) NOT NULL,
    phase_name character varying(255) NOT NULL,
    status_bei_archivierung character varying(50) NOT NULL,
    archiviert_am timestamp without time zone NOT NULL,
    archiviert_grund character varying(50) NOT NULL,
    archiviert_von integer,
    planung_daten jsonb NOT NULL,
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: archivierte_planungen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.archivierte_planungen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: archivierte_planungen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.archivierte_planungen_id_seq OWNED BY public.archivierte_planungen.id;


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    id integer NOT NULL,
    benutzer_id integer,
    aktion character varying(100) NOT NULL,
    tabelle character varying(50),
    datensatz_id integer,
    alte_werte text,
    neue_werte text,
    ip_adresse character varying(50),
    "timestamp" timestamp without time zone NOT NULL
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: auftrag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auftrag (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    beschreibung text,
    standard_sws double precision NOT NULL,
    ist_aktiv boolean NOT NULL,
    sortierung integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: auftrag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auftrag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auftrag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auftrag_id_seq OWNED BY public.auftrag.id;


--
-- Name: benachrichtigung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.benachrichtigung (
    id integer NOT NULL,
    empfaenger_id integer NOT NULL,
    typ character varying(50) NOT NULL,
    titel character varying(255) NOT NULL,
    nachricht text,
    gelesen boolean NOT NULL,
    erstellt_am timestamp without time zone NOT NULL,
    gelesen_am timestamp without time zone
);


--
-- Name: benachrichtigung_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.benachrichtigung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: benachrichtigung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.benachrichtigung_id_seq OWNED BY public.benachrichtigung.id;


--
-- Name: benutzer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.benutzer (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(100) NOT NULL,
    password_hash character varying(255) NOT NULL,
    rolle_id integer NOT NULL,
    dozent_id integer,
    vorname character varying(100),
    nachname character varying(100),
    aktiv boolean NOT NULL,
    letzter_login timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: benutzer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.benutzer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: benutzer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.benutzer_id_seq OWNED BY public.benutzer.id;


--
-- Name: deputats_betreuung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deputats_betreuung (
    id integer NOT NULL,
    deputatsabrechnung_id integer NOT NULL,
    student_name character varying(100) NOT NULL,
    student_vorname character varying(100) NOT NULL,
    titel_arbeit character varying(500),
    betreuungsart character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    beginn_datum date,
    ende_datum date,
    sws double precision NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: deputats_betreuung_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deputats_betreuung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deputats_betreuung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deputats_betreuung_id_seq OWNED BY public.deputats_betreuung.id;


--
-- Name: deputats_einstellungen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deputats_einstellungen (
    id integer NOT NULL,
    sws_bachelor_arbeit double precision NOT NULL,
    sws_master_arbeit double precision NOT NULL,
    sws_doktorarbeit double precision NOT NULL,
    sws_seminar_ba double precision NOT NULL,
    sws_seminar_ma double precision NOT NULL,
    sws_projekt_ba double precision NOT NULL,
    sws_projekt_ma double precision NOT NULL,
    max_sws_praxisseminar double precision NOT NULL,
    max_sws_projektveranstaltung double precision NOT NULL,
    max_sws_seminar_master double precision NOT NULL,
    max_sws_betreuung double precision NOT NULL,
    warn_ermaessigung_ueber double precision NOT NULL,
    default_netto_lehrverpflichtung double precision NOT NULL,
    ist_aktiv boolean NOT NULL,
    beschreibung character varying(500),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    erstellt_von integer
);


--
-- Name: deputats_einstellungen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deputats_einstellungen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deputats_einstellungen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deputats_einstellungen_id_seq OWNED BY public.deputats_einstellungen.id;


--
-- Name: deputats_ermaessigung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deputats_ermaessigung (
    id integer NOT NULL,
    deputatsabrechnung_id integer NOT NULL,
    bezeichnung character varying(200) NOT NULL,
    sws double precision NOT NULL,
    quelle character varying(20) NOT NULL,
    semester_auftrag_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: deputats_ermaessigung_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deputats_ermaessigung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deputats_ermaessigung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deputats_ermaessigung_id_seq OWNED BY public.deputats_ermaessigung.id;


--
-- Name: deputats_lehrexport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deputats_lehrexport (
    id integer NOT NULL,
    deputatsabrechnung_id integer NOT NULL,
    fachbereich character varying(100) NOT NULL,
    fach character varying(200) NOT NULL,
    sws double precision NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: deputats_lehrexport_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deputats_lehrexport_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deputats_lehrexport_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deputats_lehrexport_id_seq OWNED BY public.deputats_lehrexport.id;


--
-- Name: deputats_lehrtaetigkeit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deputats_lehrtaetigkeit (
    id integer NOT NULL,
    deputatsabrechnung_id integer NOT NULL,
    bezeichnung character varying(200) NOT NULL,
    kategorie character varying(50) NOT NULL,
    sws double precision NOT NULL,
    wochentag character varying(20),
    wochentage json,
    ist_block boolean NOT NULL,
    quelle character varying(20) NOT NULL,
    geplantes_modul_id integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: deputats_lehrtaetigkeit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deputats_lehrtaetigkeit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deputats_lehrtaetigkeit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deputats_lehrtaetigkeit_id_seq OWNED BY public.deputats_lehrtaetigkeit.id;


--
-- Name: deputats_vertretung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deputats_vertretung (
    id integer NOT NULL,
    deputatsabrechnung_id integer NOT NULL,
    art character varying(50) NOT NULL,
    vertretene_person character varying(200) NOT NULL,
    fach_professor character varying(200) NOT NULL,
    sws double precision NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: deputats_vertretung_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deputats_vertretung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deputats_vertretung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deputats_vertretung_id_seq OWNED BY public.deputats_vertretung.id;


--
-- Name: deputatsabrechnung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deputatsabrechnung (
    id integer NOT NULL,
    planungsphase_id integer NOT NULL,
    benutzer_id integer NOT NULL,
    netto_lehrverpflichtung double precision NOT NULL,
    status character varying(50) NOT NULL,
    bemerkungen text,
    eingereicht_am timestamp without time zone,
    genehmigt_von integer,
    genehmigt_am timestamp without time zone,
    abgelehnt_am timestamp without time zone,
    ablehnungsgrund text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deputatsabrechnung_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deputatsabrechnung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deputatsabrechnung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deputatsabrechnung_id_seq OWNED BY public.deputatsabrechnung.id;


--
-- Name: dozent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dozent (
    id integer NOT NULL,
    titel character varying(50),
    vorname character varying(100),
    nachname character varying(100) NOT NULL,
    name_komplett character varying(200) NOT NULL,
    email character varying(100),
    fachbereich character varying(100),
    aktiv boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    ist_platzhalter boolean DEFAULT false NOT NULL
);


--
-- Name: dozent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dozent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dozent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dozent_id_seq OWNED BY public.dozent.id;


--
-- Name: dozent_position; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dozent_position (
    id integer NOT NULL,
    bezeichnung character varying(200) NOT NULL,
    typ character varying(20) NOT NULL,
    beschreibung text,
    fachbereich character varying(100),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT dozent_position_typ_check CHECK (((typ)::text = ANY ((ARRAY['platzhalter'::character varying, 'rolle'::character varying, 'gruppe'::character varying])::text[])))
);


--
-- Name: dozent_position_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dozent_position_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dozent_position_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dozent_position_id_seq OWNED BY public.dozent_position.id;


--
-- Name: geplante_module; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.geplante_module (
    id integer NOT NULL,
    semesterplanung_id integer NOT NULL,
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    anzahl_vorlesungen integer NOT NULL,
    anzahl_uebungen integer NOT NULL,
    anzahl_praktika integer NOT NULL,
    anzahl_seminare integer NOT NULL,
    sws_vorlesung double precision NOT NULL,
    sws_uebung double precision NOT NULL,
    sws_praktikum double precision NOT NULL,
    sws_seminar double precision NOT NULL,
    sws_gesamt double precision NOT NULL,
    mitarbeiter_ids text,
    anmerkungen text,
    raumbedarf text,
    raum_vorlesung character varying(100),
    raum_uebung character varying(100),
    raum_praktikum character varying(100),
    raum_seminar character varying(100),
    kapazitaet_vorlesung integer,
    kapazitaet_uebung integer,
    kapazitaet_praktikum integer,
    kapazitaet_seminar integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: geplante_module_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.geplante_module_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: geplante_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.geplante_module_id_seq OWNED BY public.geplante_module.id;


--
-- Name: lehrform; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lehrform (
    id integer NOT NULL,
    bezeichnung character varying(50) NOT NULL,
    kuerzel character varying(10)
);


--
-- Name: lehrform_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lehrform_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lehrform_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lehrform_id_seq OWNED BY public.lehrform.id;


--
-- Name: modul; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul (
    id integer NOT NULL,
    kuerzel character varying(20) NOT NULL,
    po_id integer NOT NULL,
    bezeichnung_de character varying(200) NOT NULL,
    bezeichnung_en character varying(200),
    untertitel character varying(200),
    leistungspunkte integer,
    turnus character varying(50),
    "gruppengröße" character varying(50),
    teilnehmerzahl character varying(50),
    anmeldemodalitaeten text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: modul_abhÃ¤ngigkeit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."modul_abhÃ¤ngigkeit" (
    id integer NOT NULL,
    modul_id integer NOT NULL,
    voraussetzung_modul_id integer NOT NULL,
    po_id integer NOT NULL,
    typ character varying(20)
);


--
-- Name: modul_abhÃ¤ngigkeit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."modul_abhÃ¤ngigkeit_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modul_abhÃ¤ngigkeit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."modul_abhÃ¤ngigkeit_id_seq" OWNED BY public."modul_abhÃ¤ngigkeit".id;


--
-- Name: modul_arbeitsaufwand; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_arbeitsaufwand (
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    kontaktzeit_stunden integer,
    selbststudium_stunden integer,
    pruefungsvorbereitung_stunden integer,
    gesamt_stunden integer
);


--
-- Name: modul_audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_audit_log (
    id integer NOT NULL,
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    geaendert_von integer,
    aktion character varying(50) NOT NULL,
    alt_dozent_id integer,
    neu_dozent_id integer,
    alte_rolle character varying(50),
    neue_rolle character varying(50),
    bemerkung text,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: modul_audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modul_audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modul_audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modul_audit_log_id_seq OWNED BY public.modul_audit_log.id;


--
-- Name: modul_dozent; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_dozent (
    id integer NOT NULL,
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    dozent_id integer,
    rolle character varying(50) NOT NULL,
    vertreter_id integer,
    zweitpruefer_id integer,
    dozent_position_id integer
);


--
-- Name: modul_dozent_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modul_dozent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modul_dozent_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modul_dozent_id_seq OWNED BY public.modul_dozent.id;


--
-- Name: modul_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modul_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modul_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modul_id_seq OWNED BY public.modul.id;


--
-- Name: modul_lehrform; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_lehrform (
    id integer NOT NULL,
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    lehrform_id integer NOT NULL,
    sws double precision NOT NULL
);


--
-- Name: modul_lehrform_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modul_lehrform_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modul_lehrform_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modul_lehrform_id_seq OWNED BY public.modul_lehrform.id;


--
-- Name: modul_lernergebnisse; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_lernergebnisse (
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    lernziele text,
    kompetenzen text,
    inhalt text
);


--
-- Name: modul_literatur; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_literatur (
    id integer NOT NULL,
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    titel text NOT NULL,
    autoren character varying(500),
    verlag character varying(200),
    jahr integer,
    isbn character varying(20),
    typ character varying(50),
    pflichtliteratur boolean,
    sortierung integer
);


--
-- Name: modul_literatur_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modul_literatur_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modul_literatur_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modul_literatur_id_seq OWNED BY public.modul_literatur.id;


--
-- Name: modul_pruefung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_pruefung (
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    pruefungsform character varying(100),
    pruefungsdauer_minuten integer,
    pruefungsleistungen text,
    benotung character varying(50)
);


--
-- Name: modul_seiten; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_seiten (
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    modulhandbuch_id integer NOT NULL,
    seite_von integer NOT NULL,
    seite_bis integer
);


--
-- Name: modul_sprache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_sprache (
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    sprache_id integer NOT NULL
);


--
-- Name: modul_studiengang; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_studiengang (
    id integer NOT NULL,
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    studiengang_id integer NOT NULL,
    semester integer,
    pflicht boolean,
    wahlpflicht boolean,
    modul_kategorie character varying(30)
);


--
-- Name: modul_studiengang_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modul_studiengang_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modul_studiengang_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modul_studiengang_id_seq OWNED BY public.modul_studiengang.id;


--
-- Name: modul_voraussetzungen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modul_voraussetzungen (
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    formal text,
    empfohlen text,
    inhaltlich text
);


--
-- Name: modulhandbuch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.modulhandbuch (
    id integer NOT NULL,
    dateiname character varying(255) NOT NULL,
    studiengang_id integer,
    po_id integer NOT NULL,
    version character varying(20),
    anzahl_seiten integer,
    anzahl_module integer,
    import_datum timestamp without time zone NOT NULL,
    hash character varying(64)
);


--
-- Name: modulhandbuch_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.modulhandbuch_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modulhandbuch_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.modulhandbuch_id_seq OWNED BY public.modulhandbuch.id;


--
-- Name: phase_submissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.phase_submissions (
    planungphase_id integer NOT NULL,
    professor_id integer NOT NULL,
    planung_id integer NOT NULL,
    eingereicht_am timestamp without time zone NOT NULL,
    status character varying(50) NOT NULL,
    freigegeben_am timestamp without time zone,
    freigegeben_von integer,
    abgelehnt_am timestamp without time zone,
    abgelehnt_von integer,
    abgelehnt_grund text,
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: phase_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.phase_submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: phase_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.phase_submissions_id_seq OWNED BY public.phase_submissions.id;


--
-- Name: planungs_templates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planungs_templates (
    id integer NOT NULL,
    benutzer_id integer NOT NULL,
    semester_typ character varying(20) NOT NULL,
    name character varying(100),
    beschreibung text,
    ist_aktiv boolean NOT NULL,
    wunsch_freie_tage text,
    anmerkungen text,
    raumbedarf text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: planungs_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planungs_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planungs_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planungs_templates_id_seq OWNED BY public.planungs_templates.id;


--
-- Name: planungsphasen; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.planungsphasen (
    semester_id integer NOT NULL,
    name character varying(255) NOT NULL,
    startdatum timestamp without time zone NOT NULL,
    enddatum timestamp without time zone,
    ist_aktiv boolean NOT NULL,
    geschlossen_am timestamp without time zone,
    geschlossen_von integer,
    geschlossen_grund text,
    semester_typ character varying(20),
    semester_jahr integer,
    anzahl_einreichungen integer NOT NULL,
    anzahl_genehmigt integer NOT NULL,
    anzahl_abgelehnt integer NOT NULL,
    id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_dates CHECK (((enddatum IS NULL) OR (enddatum > startdatum)))
);


--
-- Name: planungsphasen_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.planungsphasen_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: planungsphasen_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.planungsphasen_id_seq OWNED BY public.planungsphasen.id;


--
-- Name: pruefungsordnung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pruefungsordnung (
    id integer NOT NULL,
    po_jahr character varying(10) NOT NULL,
    gueltig_von date NOT NULL,
    gueltig_bis date,
    beschreibung text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pruefungsordnung_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pruefungsordnung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pruefungsordnung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pruefungsordnung_id_seq OWNED BY public.pruefungsordnung.id;


--
-- Name: rolle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rolle (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    beschreibung text,
    created_at timestamp without time zone
);


--
-- Name: rolle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rolle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rolle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rolle_id_seq OWNED BY public.rolle.id;


--
-- Name: semester; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.semester (
    id integer NOT NULL,
    bezeichnung character varying(50) NOT NULL,
    kuerzel character varying(10) NOT NULL,
    start_datum date NOT NULL,
    ende_datum date NOT NULL,
    vorlesungsbeginn date,
    vorlesungsende date,
    ist_aktiv boolean NOT NULL,
    ist_planungsphase boolean NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: semester_auftrag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.semester_auftrag (
    id integer NOT NULL,
    semester_id integer NOT NULL,
    auftrag_id integer NOT NULL,
    dozent_id integer NOT NULL,
    sws double precision NOT NULL,
    status character varying(20) NOT NULL,
    beantragt_von integer,
    genehmigt_von integer,
    genehmigt_am timestamp without time zone,
    anmerkung text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: semester_auftrag_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.semester_auftrag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: semester_auftrag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.semester_auftrag_id_seq OWNED BY public.semester_auftrag.id;


--
-- Name: semester_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.semester_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: semester_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.semester_id_seq OWNED BY public.semester.id;


--
-- Name: semesterplanung; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.semesterplanung (
    id integer NOT NULL,
    semester_id integer NOT NULL,
    benutzer_id integer NOT NULL,
    planungsphase_id integer,
    status character varying(50) NOT NULL,
    anmerkungen text,
    raumbedarf text,
    room_requirements text,
    special_requests text,
    gesamt_sws double precision,
    eingereicht_am timestamp without time zone,
    freigegeben_von integer,
    freigegeben_am timestamp without time zone,
    abgelehnt_am timestamp without time zone,
    ablehnungsgrund text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: semesterplanung_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.semesterplanung_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: semesterplanung_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.semesterplanung_id_seq OWNED BY public.semesterplanung.id;


--
-- Name: sprache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sprache (
    id integer NOT NULL,
    bezeichnung character varying(50) NOT NULL,
    iso_code character varying(5)
);


--
-- Name: sprache_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sprache_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sprache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sprache_id_seq OWNED BY public.sprache.id;


--
-- Name: studiengang; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.studiengang (
    id integer NOT NULL,
    kuerzel character varying(10) NOT NULL,
    bezeichnung character varying(100) NOT NULL,
    abschluss character varying(20),
    fachbereich character varying(100),
    regelstudienzeit integer,
    ects_gesamt integer,
    aktiv boolean NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: studiengang_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.studiengang_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: studiengang_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.studiengang_id_seq OWNED BY public.studiengang.id;


--
-- Name: template_module; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.template_module (
    id integer NOT NULL,
    template_id integer NOT NULL,
    modul_id integer NOT NULL,
    po_id integer NOT NULL,
    anzahl_vorlesungen integer NOT NULL,
    anzahl_uebungen integer NOT NULL,
    anzahl_praktika integer NOT NULL,
    anzahl_seminare integer NOT NULL,
    mitarbeiter_ids text,
    anmerkungen text,
    raumbedarf text,
    raum_vorlesung character varying(100),
    raum_uebung character varying(100),
    raum_praktikum character varying(100),
    raum_seminar character varying(100),
    kapazitaet_vorlesung integer,
    kapazitaet_uebung integer,
    kapazitaet_praktikum integer,
    kapazitaet_seminar integer,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: template_module_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.template_module_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: template_module_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.template_module_id_seq OWNED BY public.template_module.id;


--
-- Name: wunsch_freie_tage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wunsch_freie_tage (
    id integer NOT NULL,
    semesterplanung_id integer NOT NULL,
    wochentag character varying(20) NOT NULL,
    zeitraum character varying(20) NOT NULL,
    prioritaet character varying(20) NOT NULL,
    bemerkung text,
    grund text
);


--
-- Name: wunsch_freie_tage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wunsch_freie_tage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wunsch_freie_tage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wunsch_freie_tage_id_seq OWNED BY public.wunsch_freie_tage.id;


--
-- Name: archivierte_planungen id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivierte_planungen ALTER COLUMN id SET DEFAULT nextval('public.archivierte_planungen_id_seq'::regclass);


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: auftrag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auftrag ALTER COLUMN id SET DEFAULT nextval('public.auftrag_id_seq'::regclass);


--
-- Name: benachrichtigung id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benachrichtigung ALTER COLUMN id SET DEFAULT nextval('public.benachrichtigung_id_seq'::regclass);


--
-- Name: benutzer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benutzer ALTER COLUMN id SET DEFAULT nextval('public.benutzer_id_seq'::regclass);


--
-- Name: deputats_betreuung id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_betreuung ALTER COLUMN id SET DEFAULT nextval('public.deputats_betreuung_id_seq'::regclass);


--
-- Name: deputats_einstellungen id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_einstellungen ALTER COLUMN id SET DEFAULT nextval('public.deputats_einstellungen_id_seq'::regclass);


--
-- Name: deputats_ermaessigung id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_ermaessigung ALTER COLUMN id SET DEFAULT nextval('public.deputats_ermaessigung_id_seq'::regclass);


--
-- Name: deputats_lehrexport id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_lehrexport ALTER COLUMN id SET DEFAULT nextval('public.deputats_lehrexport_id_seq'::regclass);


--
-- Name: deputats_lehrtaetigkeit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_lehrtaetigkeit ALTER COLUMN id SET DEFAULT nextval('public.deputats_lehrtaetigkeit_id_seq'::regclass);


--
-- Name: deputats_vertretung id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_vertretung ALTER COLUMN id SET DEFAULT nextval('public.deputats_vertretung_id_seq'::regclass);


--
-- Name: deputatsabrechnung id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputatsabrechnung ALTER COLUMN id SET DEFAULT nextval('public.deputatsabrechnung_id_seq'::regclass);


--
-- Name: dozent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dozent ALTER COLUMN id SET DEFAULT nextval('public.dozent_id_seq'::regclass);


--
-- Name: dozent_position id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dozent_position ALTER COLUMN id SET DEFAULT nextval('public.dozent_position_id_seq'::regclass);


--
-- Name: geplante_module id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geplante_module ALTER COLUMN id SET DEFAULT nextval('public.geplante_module_id_seq'::regclass);


--
-- Name: lehrform id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lehrform ALTER COLUMN id SET DEFAULT nextval('public.lehrform_id_seq'::regclass);


--
-- Name: modul id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul ALTER COLUMN id SET DEFAULT nextval('public.modul_id_seq'::regclass);


--
-- Name: modul_abhÃ¤ngigkeit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."modul_abhÃ¤ngigkeit" ALTER COLUMN id SET DEFAULT nextval('public."modul_abhÃ¤ngigkeit_id_seq"'::regclass);


--
-- Name: modul_audit_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_audit_log ALTER COLUMN id SET DEFAULT nextval('public.modul_audit_log_id_seq'::regclass);


--
-- Name: modul_dozent id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent ALTER COLUMN id SET DEFAULT nextval('public.modul_dozent_id_seq'::regclass);


--
-- Name: modul_lehrform id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lehrform ALTER COLUMN id SET DEFAULT nextval('public.modul_lehrform_id_seq'::regclass);


--
-- Name: modul_literatur id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_literatur ALTER COLUMN id SET DEFAULT nextval('public.modul_literatur_id_seq'::regclass);


--
-- Name: modul_studiengang id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_studiengang ALTER COLUMN id SET DEFAULT nextval('public.modul_studiengang_id_seq'::regclass);


--
-- Name: modulhandbuch id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modulhandbuch ALTER COLUMN id SET DEFAULT nextval('public.modulhandbuch_id_seq'::regclass);


--
-- Name: phase_submissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions ALTER COLUMN id SET DEFAULT nextval('public.phase_submissions_id_seq'::regclass);


--
-- Name: planungs_templates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungs_templates ALTER COLUMN id SET DEFAULT nextval('public.planungs_templates_id_seq'::regclass);


--
-- Name: planungsphasen id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungsphasen ALTER COLUMN id SET DEFAULT nextval('public.planungsphasen_id_seq'::regclass);


--
-- Name: pruefungsordnung id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pruefungsordnung ALTER COLUMN id SET DEFAULT nextval('public.pruefungsordnung_id_seq'::regclass);


--
-- Name: rolle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rolle ALTER COLUMN id SET DEFAULT nextval('public.rolle_id_seq'::regclass);


--
-- Name: semester id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester ALTER COLUMN id SET DEFAULT nextval('public.semester_id_seq'::regclass);


--
-- Name: semester_auftrag id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester_auftrag ALTER COLUMN id SET DEFAULT nextval('public.semester_auftrag_id_seq'::regclass);


--
-- Name: semesterplanung id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesterplanung ALTER COLUMN id SET DEFAULT nextval('public.semesterplanung_id_seq'::regclass);


--
-- Name: sprache id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sprache ALTER COLUMN id SET DEFAULT nextval('public.sprache_id_seq'::regclass);


--
-- Name: studiengang id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studiengang ALTER COLUMN id SET DEFAULT nextval('public.studiengang_id_seq'::regclass);


--
-- Name: template_module id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_module ALTER COLUMN id SET DEFAULT nextval('public.template_module_id_seq'::regclass);


--
-- Name: wunsch_freie_tage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wunsch_freie_tage ALTER COLUMN id SET DEFAULT nextval('public.wunsch_freie_tage_id_seq'::regclass);


--
-- Data for Name: archivierte_planungen; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: auftrag; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (1, 'Eventmanagement', 'Koordination von Veranstaltungen und Events', 0.5, true, 1, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (2, 'Auslandsbeauftragter 1', 'Betreuung internationaler Studierender', 0.5, true, 2, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (3, 'Auslandsbeauftragter 2', 'Betreuung internationaler Studierender', 0.5, true, 3, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (4, 'BAföG', 'BAföG-Beratung und -Verwaltung', 0, true, 4, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (5, 'Datensicherheit und Netzwerk', 'IT-Sicherheit und Netzwerkverwaltung', 0, true, 5, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (6, 'Dekanin', 'Leitung des Fachbereichs', 5, true, 6, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (7, 'Digitalisierung', 'Digitalisierungsbeauftragter', 0.5, true, 7, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (8, 'Marketing', 'Marketing und Öffentlichkeitsarbeit', 2, true, 8, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (9, 'Evaluation', 'Qualitätssicherung und Evaluation', 0, true, 9, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (10, 'Gleichstellung', 'Gleichstellungsbeauftragte/r', 0, true, 10, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (11, 'Prodekan', 'Stellvertretung der Dekanin', 4.5, true, 11, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (12, 'Sicherheit', 'Sicherheitsbeauftragter', 0, true, 12, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (13, 'Studienberatung Frauen', 'Studienberatung speziell für Studentinnen', 0, true, 13, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (14, 'Studiengangsbeauftragter IS', 'Studiengangsleitung Informationssysteme', 0.5, true, 14, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (15, 'Studiengangsbeauftragter ID', 'Studiengangsleitung Interaction Design', 0.5, true, 15, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (16, 'Studiengangsbeauftragter Inf 1', 'Studiengangsleitung Informatik 1', 0.5, true, 16, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (17, 'Studiengangsbeauftragter Inf 2', 'Studiengangsleitung Informatik 2', 0, true, 17, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (18, 'Studiengangsbeauftragter WI', 'Studiengangsleitung Wirtschaftsinformatik', 0.5, true, 18, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (19, 'Stundenplanerstellung', 'Erstellung und Verwaltung des Stundenplans', 1, true, 19, '2025-11-25 21:37:48', '2025-11-25 21:37:48');
INSERT INTO public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) VALUES (20, 'Prüfungsausschuss', 'Mitglied im Prüfungsausschuss', 2, true, 20, '2025-11-25 21:37:48', '2025-11-25 21:37:48');


--
-- Data for Name: benachrichtigung; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (70, 39, 'planung_eingereicht', 'Planung für WS2026 eingereicht', 'Ihre Semesterplanung für WS2026 wurde eingereicht und wartet auf Freigabe.', false, '2026-02-01 22:36:59.188053', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (74, 1, 'planung_eingereicht', 'Neue Planung von Wolfram Conen', 'Wolfram Conen hat eine Semesterplanung für WS2026 eingereicht.', false, '2026-02-02 01:38:55.776931', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (71, 1, 'planung_eingereicht', 'Neue Planung von Leif Meier', 'Leif Meier hat eine Semesterplanung für WS2026 eingereicht.', false, '2026-02-01 22:36:59.323813', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (72, 39, 'planung_freigegeben', 'Planung für WS2026 freigegeben', 'Ihre Semesterplanung für WS2026 wurde freigegeben.', false, '2026-02-01 22:37:18.974834', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (1, 1, 'system', 'Willkommen!', 'Willkommen im Dekanat-System!', true, '2025-10-27 18:09:59.526396', '2025-10-27 18:27:52.401378');
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (2, 1, 'planung_eingereicht', 'Neue Planung eingereicht', 'Prof. Müller hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-10-27 18:09:59.526415', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (3, 1, 'erinnerung', 'Erinnerung', 'Bitte überprüfen Sie die offenen Planungen.', false, '2025-10-27 18:09:59.526417', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (4, 54, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-01 17:58:43.397081', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (5, 1, 'planung_eingereicht', 'Neue Planung von Test Professor', 'Test Professor hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-01 17:58:43.429391', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (6, 54, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-01 18:37:44.259939', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (7, 10, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-06 22:38:33.606858', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (8, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Wolfram Conen', 'Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-06 22:38:33.622845', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (9, 10, 'planung_abgelehnt', 'Planung für WS2025 abgelehnt', 'Ihre Semesterplanung für WS2025 wurde abgelehnt.

Grund: nicht vollständig ', false, '2025-11-06 22:39:03.980706', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (10, 31, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-06 22:45:04.31436', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (11, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Marcel Luis', 'Prof. Dr. Marcel Luis hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-06 22:45:04.331151', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (12, 7, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-06 23:03:07.353331', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (13, 1, 'planung_eingereicht', 'Neue Planung von Prof. Katja Becker', 'Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-06 23:03:07.368329', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (14, 32, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-06 23:19:35.71695', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (15, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Gregor Lux', 'Prof. Dr. Gregor Lux hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-06 23:19:35.729788', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (16, 7, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-06 23:45:19.781308', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (17, 32, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-06 23:45:21.928995', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (18, 11, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-07 10:13:56.375316', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (19, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Andreas Cramer', 'Prof. Dr. Andreas Cramer hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-07 10:13:56.41786', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (20, 39, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-12 11:46:15.017429', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (21, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Leif Meier', 'Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-12 11:46:15.032444', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (22, 39, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-12 11:46:30.826709', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (23, 7, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-12 14:32:48.693028', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (24, 1, 'planung_eingereicht', 'Neue Planung von Prof. Katja Becker', 'Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-12 14:32:48.719031', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (25, 7, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-12 14:32:57.560901', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (26, 10, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-12 15:15:50.361519', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (27, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Wolfram Conen', 'Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-12 15:15:50.373524', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (28, 10, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-12 15:15:56.651997', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (29, 9, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-14 13:33:20.920717', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (30, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Sebastian Büttner', 'Prof. Dr. Sebastian Büttner hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-14 13:33:20.935821', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (31, 9, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-14 13:33:31.988878', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (32, 9, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-14 14:20:48.015605', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (33, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Sebastian Büttner', 'Prof. Dr. Sebastian Büttner hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-14 14:20:48.03361', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (34, 7, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-14 14:21:34.78122', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (35, 1, 'planung_eingereicht', 'Neue Planung von Prof. Katja Becker', 'Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-14 14:21:34.817586', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (36, 7, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-14 14:22:13.095988', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (37, 9, 'planung_abgelehnt', 'Planung für WS2025 abgelehnt', 'Ihre Semesterplanung für WS2025 wurde abgelehnt.

Grund: nein', false, '2025-11-14 14:22:19.296461', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (38, 7, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-14 14:40:15.791664', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (39, 1, 'planung_eingereicht', 'Neue Planung von Prof. Katja Becker', 'Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-14 14:40:15.80368', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (40, 7, 'planung_abgelehnt', 'Planung für WS2025 abgelehnt', 'Ihre Semesterplanung für WS2025 wurde abgelehnt.

Grund: so', false, '2025-11-14 14:41:21.251568', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (41, 7, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-14 15:00:31.473604', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (42, 1, 'planung_eingereicht', 'Neue Planung von Prof. Katja Becker', 'Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-14 15:00:31.487603', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (43, 7, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-14 15:15:16.991884', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (44, 10, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-14 15:19:58.833029', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (45, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Wolfram Conen', 'Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-14 15:19:58.846012', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (46, 10, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-14 15:20:16.608547', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (47, 52, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-14 15:38:28.17199', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (48, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Katja Zeume', 'Prof. Dr. Katja Zeume hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-14 15:38:28.188004', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (49, 52, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-14 15:38:35.373799', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (50, 39, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-19 09:55:36.097305', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (51, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Leif Meier', 'Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-19 09:55:36.128014', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (52, 39, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-19 09:56:54.695282', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (53, 7, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-25 22:39:03.867759', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (54, 1, 'planung_eingereicht', 'Neue Planung von Prof. Katja Becker', 'Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-25 22:39:03.889986', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (55, 7, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-11-25 22:55:21.745478', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (56, 7, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-25 23:00:59.706166', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (57, 1, 'planung_eingereicht', 'Neue Planung von Prof. Katja Becker', 'Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-25 23:00:59.72715', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (58, 39, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-11-25 23:46:39.173121', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (59, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Leif Meier', 'Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-11-25 23:46:39.193128', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (60, 10, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-12-02 09:18:38.172094', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (61, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Wolfram Conen', 'Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-12-02 09:18:38.190203', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (62, 10, 'planung_freigegeben', 'Planung für WS2025 freigegeben', 'Ihre Semesterplanung für WS2025 wurde freigegeben.', false, '2025-12-02 09:19:29.135856', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (63, 9, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-12-05 01:32:31.486833', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (64, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Sebastian Büttner', 'Prof. Dr. Sebastian Büttner hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-12-05 01:32:31.500833', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (65, 52, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-12-05 08:44:49.495372', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (66, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Katja Zeume', 'Prof. Dr. Katja Zeume hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-12-05 08:44:49.52243', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (67, 39, 'planung_eingereicht', 'Planung für WS2025 eingereicht', 'Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.', false, '2025-12-05 09:36:33.070845', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (68, 1, 'planung_eingereicht', 'Neue Planung von Prof. Dr. Leif Meier', 'Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.', false, '2025-12-05 09:36:33.098852', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (69, 39, 'planung_abgelehnt', 'Planung für WS2025 abgelehnt', 'Ihre Semesterplanung für WS2025 wurde abgelehnt.

Grund: test', false, '2026-01-21 07:28:18.583869', NULL);
INSERT INTO public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) VALUES (73, 10, 'planung_eingereicht', 'Planung für WS2026 eingereicht', 'Ihre Semesterplanung für WS2026 wurde eingereicht und wartet auf Freigabe.', false, '2026-02-02 01:38:55.692805', NULL);


--
-- Data for Name: benutzer; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (2, 'alexanderkoch.lehrbeauftragter@w-hs.de', 'alexanderkoch.(lehrbeauftragte/r)', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 27, 'Alexander Koch', '(Lehrbeauftragte/r)', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (3, 'n.n..(lehrbeauftragter)@hochschule.de', 'n.n..(lehrbeauftragter)', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 18, 'N.N.', '(Lehrbeauftragter)', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (4, 'n.n..3d@hochschule.de', 'n.n..3d', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 19, 'N.N.', '3D', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (5, 'henning.ahlf@w-hs.de', 'henning.ahlf', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 32, 'Henning', 'Ahlf', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (6, 'laura.anderle@w-hs.de', 'laura.anderle', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 11, 'Laura', 'Anderle', true, '2025-11-06 23:20:33.736654', '2025-10-15 14:45:51', '2025-11-06 23:20:33.737654');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (7, 'katja.becker@w-hs.de', 'katja.becker', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 2, 'Katja', 'Becker', true, '2025-12-04 14:44:31.99056', '2025-10-15 14:45:51', '2025-12-04 14:44:31.991558');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (8, 'ingsebastian.buettner@w-hs.de', '-ing.sebastian.buettner', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 28, '-Ing. Sebastian', 'Büttner', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (9, 'sebastian.buettner@w-hs.de', 'sebastian.buettner', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 5, 'Sebastian', 'Büttner', true, '2025-12-05 01:16:18.884884', '2025-10-15 14:45:51', '2025-12-05 01:16:18.885902');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (11, 'andreas.cramer@w-hs.de', 'andreas.cramer', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 21, 'Andreas', 'Cramer', true, '2025-11-07 09:56:16.995045', '2025-10-15 14:45:51', '2025-11-07 09:56:16.996046');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (12, 'lehrendedesstudiengangsinformatikund.design@hochschule.de', 'lehrendedesstudiengangsinformatikund.design', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 3, 'Lehrende des Studiengangs Informatik und', 'Design', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (13, 'studiengangsbeauftrage/rinformatikund.design@hochschule.de', 'studiengangsbeauftrage/rinformatikund.design', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 4, 'Studiengangsbeauftrage/r Informatik und', 'Design', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (14, 'studiengangsbeauftragte/rinformatikund.design@hochschule.de', 'studiengangsbeauftragte/rinformatikund.design', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 10, 'Studiengangsbeauftragte/r Informatik und', 'Design', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (15, 'christian.dietrich@w-hs.de', 'christian.dietrich', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 30, 'Christian', 'Dietrich', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (16, 'alleprofessorinnenprofessorender.fachgruppe@hochschule.de', 'alleprofessorinnenprofessorender.fachgruppe', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 50, 'Alle Professorinnen Professoren der', 'Fachgruppe', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (17, 'alleprofessorinnenundprofessorender.fachgruppe@hochschule.de', 'alleprofessorinnenundprofessorender.fachgruppe', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 13, 'Alle Professorinnen und Professoren der', 'Fachgruppe', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (18, 'volker.goerick@hochschule.de', 'volker.goerick', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 37, 'Volker', 'Goerick', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (19, 'ulrike.griefahn@w-hs.de', 'ulrike.griefahn', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 23, 'Ulrike', 'Griefahn', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (20, 'dieter.hannemann@w-hs.de', 'dieter.hannemann', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 40, 'Dieter', 'Hannemann', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (21, 'alleprofessorenderfachgruppe.informatik@hochschule.de', 'alleprofessorenderfachgruppe.informatik', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 38, 'Alle Professoren der Fachgruppe', 'Informatik', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (22, 'studiengangsbeauftragte/r.informatik@hochschule.de', 'studiengangsbeauftragte/r.informatik', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 20, 'Studiengangsbeauftragte/r', 'Informatik', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (23, 'alleprofessorendesmaster-studiengangs.internet-@hochschule.de', 'alleprofessorendesmaster-studiengangs.internet-', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 46, 'Alle Professoren des Master-Studiengangs', 'Internet-', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (24, 'markus.jelonek@w-hs.de', 'markus.jelonek', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 9, 'Markus', 'Jelonek', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (25, 'henningahlfprofdrsiegbert.kern@w-hs.de', 'henningahlf,prof.dr.siegbert.kern', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 34, 'Henning Ahlf, Prof. Dr. Siegbert', 'Kern', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (26, 'siegbert.kern@w-hs.de', 'siegbert.kern', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 31, 'Siegbert', 'Kern', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (10, 'wolfram.conen@w-hs.de', 'wolfram.conen', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 1, 'Wolfram', 'Conen', true, '2026-02-02 01:38:37.963712', '2025-10-15 14:45:51', '2026-02-02 01:38:37.965711');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (1, 'dekan@hochschule.de', 'dekan', 'scrypt:32768:8:1$BjYSqfnqY4Du7JsV$7c95e16345e5337b0d6a2c2617af6e55f73f371e93a548d8444257ceb58c14a7de5ccdf74d4542aa871da83cbf5ef493c192acfbe13af29abbb796b5d91633b4', 1, 36, 'Leif', 'Meier', true, '2026-02-02 09:11:40.872233', '2025-10-15 14:45:51', '2026-02-02 09:11:40.877233');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (27, 'lehrbeauftragte/r@hochschule.de', 'lehrbeauftragte/r', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 29, NULL, 'Lehrbeauftragte/r', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (28, 'ulrikegriefahn.lehrbeauftragter@w-hs.de', 'ulrikegriefahn/.lehrbeauftragte/r', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 39, 'Ulrike Griefahn /', 'Lehrbeauftragte/r', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (29, 'lehrbeauftragter@hochschule.de', 'lehrbeauftragter', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 42, NULL, 'Lehrbeauftragter', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (30, 'uwegruenefeld/.lehrbeauftragter@hochschule.de', 'uwegruenefeld/.lehrbeauftragter', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 43, 'Uwe Grünefeld /', 'Lehrbeauftragter', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (31, 'marcel.luis@w-hs.de', 'marcel.luis', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 7, 'Marcel', 'Luis', true, '2025-11-06 22:59:05.527384', '2025-10-15 14:45:51', '2025-11-06 22:59:05.528385');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (32, 'gregor.lux@w-hs.de', 'gregor.lux', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 8, 'Gregor', 'Lux', true, '2025-11-06 23:13:05.978042', '2025-10-15 14:45:51', '2025-11-06 23:13:05.97915');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (33, 'detlef.mansel@w-hs.de', 'detlef.mansel', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 22, 'Detlef', 'Mansel', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (34, 'alleprofessorender.medieninformatik@hochschule.de', 'alleprofessorender.medieninformatik', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 48, 'Alle Professoren der', 'Medieninformatik', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (35, 'lehrendeder.medieninformatik@hochschule.de', 'lehrendeder.medieninformatik', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 45, 'Lehrende der', 'Medieninformatik', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (36, 'studiengangsbeauftrage/r.medieninformatik@hochschule.de', 'studiengangsbeauftrage/r.medieninformatik', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 47, 'Studiengangsbeauftrage/r', 'Medieninformatik', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (37, 'studiengangsbeauftragte/r.medieninformatik@hochschule.de', 'studiengangsbeauftragte/r.medieninformatik', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 44, 'Studiengangsbeauftragte/r', 'Medieninformatik', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (38, 'henningahlfprofdrleif.meier@w-hs.de', 'henningahlf,prof.dr.leif.meier', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 52, 'Henning Ahlf, Prof. Dr. Leif', 'Meier', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (40, 'christopher.morasch@w-hs.de', 'christopher.morasch', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 51, 'Christopher', 'Morasch', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (41, 'siegbertkern.nn@w-hs.de', 'siegbertkern,.n.n.', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 33, 'Siegbert Kern,', 'N.N.', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (42, 'n.n.3d@hochschule.de', 'n.n.3d', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 14, NULL, 'N.N.3D', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (43, 'tunnnorbert.pohlmann@w-hs.de', '(tunn)norbert.pohlmann', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 25, '(TU NN) Norbert', 'Pohlmann', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (44, 'n.n..swt@hochschule.de', 'n.n..swt', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 41, 'N.N.', 'SWT', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (45, 'michael.schmeing@w-hs.de', 'michael.schmeing', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 15, 'Michael', 'Schmeing', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (46, 'dozent:indes.sprachenzentrums@hochschule.de', 'dozent:indes.sprachenzentrums', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 17, 'Dozent:in des', 'Sprachenzentrums', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (47, 'leitungdes.sprachenzentrums@hochschule.de', 'leitungdes.sprachenzentrums', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 16, 'Leitung des', 'Sprachenzentrums', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (48, 'studiengangsbeauftragte/rdesjeweiligen.studiengangs@hochschule.de', 'studiengangsbeauftragte/rdesjeweiligen.studiengangs', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 12, 'Studiengangsbeauftragte/r des jeweiligen', 'Studiengangs', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (49, 'ingdiplinformhartmut.surmann@w-hs.de', '-ing.dipl.inform.hartmut.surmann', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 24, '-Ing. Dipl. Inform. Hartmut', 'Surmann', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (50, 'tobias.urban@w-hs.de', 'tobias.urban', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 35, 'Tobias', 'Urban', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (51, 'studiengangsbeauftragte/r.wirtschaftsinformatik@hochschule.de', 'studiengangsbeauftragte/r.wirtschaftsinformatik', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 26, 'Studiengangsbeauftragte/r', 'Wirtschaftsinformatik', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (52, 'katja.zeume@w-hs.de', 'katja.zeume', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 6, 'Katja', 'Zeume', true, '2025-12-05 08:43:48.133778', '2025-10-15 14:45:51', '2025-12-05 08:43:48.134793');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (53, 'alleprofessorinnenundprofessoren.der@hochschule.de', 'alleprofessorinnenundprofessoren.der', 'pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b', 3, 49, 'Alle Professorinnen und Professoren', 'der', true, NULL, '2025-10-15 14:45:51', '2025-10-15 14:45:51');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (54, 'test.professor@w-hs.de', 'prof.test', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, NULL, 'Test', 'Professor', true, '2025-11-06 13:12:34.522489', '2025-10-30 20:36:37.318177', '2025-11-06 13:12:34.523509');
INSERT INTO public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) VALUES (39, 'leif.meier@w-hs.de', 'leif.meier', 'scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36', 2, 36, 'Leif', 'Meier', true, '2026-02-01 22:35:58.464125', '2025-10-15 14:45:51', '2026-02-01 22:35:58.481295');


--
-- Data for Name: deputats_betreuung; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: deputats_einstellungen; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deputats_einstellungen (id, sws_bachelor_arbeit, sws_master_arbeit, sws_doktorarbeit, sws_seminar_ba, sws_seminar_ma, sws_projekt_ba, sws_projekt_ma, max_sws_praxisseminar, max_sws_projektveranstaltung, max_sws_seminar_master, max_sws_betreuung, warn_ermaessigung_ueber, default_netto_lehrverpflichtung, ist_aktiv, beschreibung, created_at, updated_at, erstellt_von) VALUES (1, 0.3, 0.5, 1, 0.2, 0.3, 0.2, 0.3, 5, 6, 4, 3, 5, 18, true, 'Standard-Einstellungen', '2026-01-24 11:17:53', '2026-01-24 11:17:53', NULL);


--
-- Data for Name: deputats_ermaessigung; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: deputats_lehrexport; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: deputats_lehrtaetigkeit; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deputats_lehrtaetigkeit (id, deputatsabrechnung_id, bezeichnung, kategorie, sws, wochentag, wochentage, ist_block, quelle, geplantes_modul_id, created_at) VALUES (3, 4, 'ADS - Algorithmen und Datenstrukturen  ', 'lehrveranstaltung', 4, NULL, NULL, false, 'planung', 29, '2026-02-02 01:38:59.200884');


--
-- Data for Name: deputats_vertretung; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: deputatsabrechnung; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.deputatsabrechnung (id, planungsphase_id, benutzer_id, netto_lehrverpflichtung, status, bemerkungen, eingereicht_am, genehmigt_von, genehmigt_am, abgelehnt_am, ablehnungsgrund, created_at, updated_at) VALUES (4, 19, 10, 18, 'genehmigt', NULL, '2026-02-02 01:39:10.390595', 1, '2026-02-02 01:40:09.196478', NULL, NULL, '2026-02-02 01:38:58.991957', '2026-02-02 01:40:09.20149');


--
-- Data for Name: dozent; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (19, NULL, 'N.N.', '3D', 'N.N. 3D', NULL, NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (1, 'Prof. Dr.', 'Wolfram', 'Conen', 'Wolfram Conen', 'wolfram.conen@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (2, 'Prof.', 'Katja', 'Becker', 'Katja Becker', 'katja.becker@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (6, 'Prof. Dr.', 'Katja', 'Zeume', 'Katja Zeume', 'katja.zeume@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (7, 'Prof. Dr.', 'Marcel', 'Luis', 'Marcel Luis', 'marcel.luis@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (8, 'Prof. Dr.', 'Gregor', 'Lux', 'Gregor Lux', 'gregor.lux@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (9, 'Prof. Dr.', 'Markus', 'Jelonek', 'Markus Jelonek', 'markus.jelonek@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (11, 'Prof. Dr.', 'Laura', 'Anderle', 'Laura Anderle', 'laura.anderle@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (15, 'Prof. Dr.', 'Michael', 'Schmeing', 'Michael Schmeing', 'michael.schmeing@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (21, 'Prof. Dr.', 'Andreas', 'Cramer', 'Andreas Cramer', 'andreas.cramer@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (22, 'Prof. Dr.', 'Detlef', 'Mansel', 'Detlef Mansel', 'detlef.mansel@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (23, 'Prof. Dr.', 'Ulrike', 'Griefahn', 'Ulrike Griefahn', 'ulrike.griefahn@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (5, 'Prof. Dr.-Ing.', 'Sebastian', 'Büttner', 'Sebastian Büttner', 'sebastian.buettner@w-hs.de', NULL, true, '2025-10-09 15:29:11', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (28, 'Prof. Dr.-Ing.', 'Sebastian', 'Buettner', 'Sebastian Buettner', 'ingsebastian.buettner@w-hs.de', NULL, false, '2025-10-09 15:29:15', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (30, 'Prof. Dr.', 'Christian', 'Dietrich', 'Christian Dietrich', 'christian.dietrich@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (31, 'Prof. Dr.', 'Siegbert', 'Kern', 'Siegbert Kern', 'siegbert.kern@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (32, 'Prof. Dr.', 'Henning', 'Ahlf', 'Henning Ahlf', 'henning.ahlf@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (35, 'Prof. Dr.', 'Tobias', 'Urban', 'Tobias Urban', 'tobias.urban@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (36, 'Prof. Dr.', 'Leif', 'Meier', 'Leif Meier', 'leif.meier@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (40, 'Prof. Dr.', 'Dieter', 'Hannemann', 'Dieter Hannemann', 'dieter.hannemann@w-hs.de', NULL, true, '2025-10-09 15:29:20', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (51, 'Prof. Dr.', 'Christopher', 'Morasch', 'Christopher Morasch', 'christopher.morasch@w-hs.de', NULL, true, '2025-10-09 15:29:33', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (25, 'Prof. Dr.', 'Norbert', 'Pohlmann', 'Norbert Pohlmann', 'tunnnorbert.pohlmann@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (14, NULL, NULL, 'N.N.3D', 'N.N.3D', NULL, NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (16, NULL, 'Leitung des', 'Sprachenzentrums', 'Leitung des Sprachenzentrums', 'leitungdes.sprachenzentrums@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (17, NULL, 'Dozent:in des', 'Sprachenzentrums', 'Dozent:in des Sprachenzentrums', 'dozentindes.sprachenzentrums@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (27, 'Prof. Dr.', 'Alexander', 'Koch', 'Alexander Koch', 'alexanderkoch.lehrbeauftragter@w-hs.de', '', true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (24, 'Prof. Dr.-Ing. Dipl. Inform.', 'Hartmut', 'Surmann', 'Hartmut Surmann', 'hartmut.surmann@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (37, NULL, 'Volker', 'Goerick', 'Volker Goerick', 'volker.goerick@w-hs.de', NULL, true, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (3, NULL, 'Lehrende des Studiengangs Informatik und', 'Design', 'Lehrende des Studiengangs Informatik und Design', 'lehrendedesstudiengangsinformatikund.design@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (4, NULL, 'Studiengangsbeauftrage/r Informatik und', 'Design', 'Studiengangsbeauftrage/r Informatik und Design', 'studiengangsbeauftragerinformatikund.design@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (10, NULL, 'Studiengangsbeauftragte/r Informatik und', 'Design', 'Studiengangsbeauftragte/r Informatik und Design', 'studiengangsbeauftragterinformatikund.design@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (12, NULL, 'Studiengangsbeauftragte/r des jeweiligen', 'Studiengangs', 'Studiengangsbeauftragte/r des jeweiligen Studiengangs', 'studiengangsbeauftragterdesjeweiligen.studiengangs@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (13, NULL, 'Alle Professorinnen und Professoren der', 'Fachgruppe', 'Alle Professorinnen und Professoren der Fachgruppe', 'alleprofessorinnenundprofessorender.fachgruppe@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (18, NULL, 'N.N.', '(Lehrbeauftragter)', 'N.N. (Lehrbeauftragter)', 'nn.lehrbeauftragter@w-hs.de', NULL, false, '2025-10-09 15:29:11', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (20, NULL, 'Studiengangsbeauftragte/r', 'Informatik', 'Studiengangsbeauftragte/r Informatik', 'studiengangsbeauftragter.informatik@w-hs.de', NULL, false, '2025-10-09 15:29:15', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (26, NULL, 'Studiengangsbeauftragte/r', 'Wirtschaftsinformatik', 'Studiengangsbeauftragte/r Wirtschaftsinformatik', 'studiengangsbeauftragter.wirtschaftsinformatik@w-hs.de', NULL, false, '2025-10-09 15:29:15', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (29, NULL, NULL, 'Lehrbeauftragte/r', 'Lehrbeauftragte/r', NULL, NULL, false, '2025-10-09 15:29:15', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (38, NULL, 'Alle Professoren der Fachgruppe', 'Informatik', 'Alle Professoren der Fachgruppe Informatik', 'alleprofessorenderfachgruppe.informatik@w-hs.de', NULL, false, '2025-10-09 15:29:20', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (41, NULL, 'N.N.', 'SWT', 'N.N. SWT', 'nn.swt@w-hs.de', NULL, false, '2025-10-09 15:29:20', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (42, NULL, NULL, 'Lehrbeauftragter', 'Lehrbeauftragter', NULL, NULL, false, '2025-10-09 15:29:20', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (44, NULL, 'Studiengangsbeauftragte/r', 'Medieninformatik', 'Studiengangsbeauftragte/r Medieninformatik', 'studiengangsbeauftragter.medieninformatik@w-hs.de', NULL, false, '2025-10-09 15:29:20', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (45, NULL, 'Lehrende der', 'Medieninformatik', 'Lehrende der Medieninformatik', 'lehrendeder.medieninformatik@w-hs.de', NULL, false, '2025-10-09 15:29:20', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (46, NULL, 'Alle Professoren des Master-Studiengangs', 'Internet-', 'Alle Professoren des Master-Studiengangs Internet-', 'alleprofessorendesmasterstudiengangs.internet@w-hs.de', NULL, false, '2025-10-09 15:29:22', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (47, NULL, 'Studiengangsbeauftrage/r', 'Medieninformatik', 'Studiengangsbeauftrage/r Medieninformatik', 'studiengangsbeauftrager.medieninformatik@w-hs.de', NULL, false, '2025-10-09 15:29:26', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (48, NULL, 'Alle Professoren der', 'Medieninformatik', 'Alle Professoren der Medieninformatik', 'alleprofessorender.medieninformatik@w-hs.de', NULL, false, '2025-10-09 15:29:26', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (49, NULL, 'Alle Professorinnen und Professoren', 'der', 'Alle Professorinnen und Professoren der', 'alleprofessorinnenundprofessoren.der@w-hs.de', NULL, false, '2025-10-09 15:29:26', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (34, 'Prof. Dr.', 'Henning Ahlf, Prof. Dr. Siegbert', 'Kern', 'Henning Ahlf, Prof. Dr. Siegbert Kern', 'henningahlfprofdrsiegbert.kern@w-hs.de', NULL, false, '2025-10-09 15:29:15', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (52, 'Prof. Dr.', 'Henning Ahlf, Prof. Dr. Leif', 'Meier', 'Henning Ahlf, Prof. Dr. Leif Meier', 'henningahlfprofdrleif.meier@w-hs.de', NULL, false, '2025-10-09 15:29:33', true);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (33, 'Prof. Dr.', 'Siegbert Kern,', 'N.N.', 'Siegbert Kern, N.N.', NULL, NULL, false, '2025-10-09 15:29:15', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (39, 'Prof. Dr.', 'Ulrike Griefahn /', 'Lehrbeauftragte/r', 'Ulrike Griefahn / Lehrbeauftragte/r', 'ulrikegriefahn.lehrbeauftragter@w-hs.de', NULL, false, '2025-10-09 15:29:20', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (43, 'Dr.', 'Uwe Grünefeld /', 'Lehrbeauftragter', 'Uwe Grünefeld / Lehrbeauftragter', 'uwegruenefeld.lehrbeauftragter@w-hs.de', NULL, false, '2025-10-09 15:29:20', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (53, 'Dr.', 'Uwe', 'Gruenefeld', 'Uwe Gruenefeld', 'uwe.gruenefeld@w-hs.de', NULL, true, '2026-01-27 15:35:10.224967', false);
INSERT INTO public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) VALUES (50, NULL, 'Alle Professorinnen Professoren der', 'Fachgruppe', 'Alle Professorinnen Professoren der Fachgruppe', 'alleprofessorinnenprofessorender.fachgruppe@w-hs.de', NULL, false, '2025-10-09 15:29:33', true);


--
-- Data for Name: dozent_position; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (1, 'Lehrende des Studiengangs Informatik und Design', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (2, 'Studiengangsbeauftrage/r Informatik und Design', 'rolle', 'Studiengangsbeauftragte Person', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (3, 'Studiengangsbeauftragte/r Informatik und Design', 'rolle', 'Studiengangsbeauftragte Person', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (4, 'Studiengangsbeauftragte/r des jeweiligen Studiengangs', 'rolle', 'Studiengangsbeauftragte Person', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (5, 'Alle Professorinnen und Professoren der Fachgruppe', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (6, 'N.N.', 'platzhalter', 'Noch nicht benannt / Not named', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (7, 'N.N. 3D', 'platzhalter', 'Noch nicht benannt mit Kontext', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (8, 'Studiengangsbeauftragte/r Informatik', 'rolle', 'Studiengangsbeauftragte Person', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (9, 'Studiengangsbeauftragte/r Wirtschaftsinformatik', 'rolle', 'Studiengangsbeauftragte Person', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (10, 'Lehrbeauftragte/r', 'rolle', 'Externe/r Lehrbeauftragte/r', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (11, 'Alle Professoren der Fachgruppe Informatik', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (12, 'N.N. SWT', 'platzhalter', 'Noch nicht benannt mit Kontext', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (13, 'Lehrbeauftragte/r', 'rolle', 'Externe/r Lehrbeauftragte/r', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (14, 'Studiengangsbeauftragte/r Medieninformatik', 'rolle', 'Studiengangsbeauftragte Person', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (15, 'Lehrende der Medieninformatik', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (16, 'Alle Professoren des Master-Studiengangs Internet-', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (17, 'Studiengangsbeauftrage/r Medieninformatik', 'rolle', 'Studiengangsbeauftragte Person', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (18, 'Alle Professoren der Medieninformatik', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (19, 'Alle Professorinnen und Professoren der', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (20, 'N.N.', 'platzhalter', 'Aus Multi-Personen-Eintrag extrahiert', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (21, 'Lehrbeauftragte/r', 'rolle', 'Aus Multi-Personen-Eintrag extrahiert', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (22, 'Lehrbeauftragter', 'rolle', 'Aus Multi-Personen-Eintrag extrahiert', NULL, '2026-01-27 15:35:10.224967');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (23, 'N.N. 3D', 'platzhalter', 'N.N. Platzhalter fuer 3D-Bereich', NULL, '2026-01-27 16:09:19.523375');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (24, 'Leitung des Sprachenzentrums', 'rolle', 'Leitung des Sprachenzentrums', NULL, '2026-01-27 16:09:19.523375');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (25, 'Dozent:in des Sprachenzentrums', 'rolle', 'Dozent/in am Sprachenzentrum', NULL, '2026-01-27 16:09:19.523375');
INSERT INTO public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) VALUES (26, 'Alle Professorinnen und Professoren der Fachgruppe', 'gruppe', 'Gruppenbezeichnung', NULL, '2026-01-27 16:09:19.523375');


--
-- Data for Name: geplante_module; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.geplante_module (id, semesterplanung_id, modul_id, po_id, anzahl_vorlesungen, anzahl_uebungen, anzahl_praktika, anzahl_seminare, sws_vorlesung, sws_uebung, sws_praktikum, sws_seminar, sws_gesamt, mitarbeiter_ids, anmerkungen, raumbedarf, raum_vorlesung, raum_uebung, raum_praktikum, raum_seminar, kapazitaet_vorlesung, kapazitaet_uebung, kapazitaet_praktikum, kapazitaet_seminar, created_at) VALUES (29, 20, 1, 1, 1, 1, 0, 0, 3, 1, 0, 0, 4, '[27]', NULL, NULL, NULL, NULL, NULL, NULL, 30, 20, 15, 20, '2026-02-02 01:38:49.231464');


--
-- Data for Name: lehrform; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.lehrform (id, bezeichnung, kuerzel) VALUES (1, 'Vorlesung', 'V');
INSERT INTO public.lehrform (id, bezeichnung, kuerzel) VALUES (2, 'Übung', 'Ü');
INSERT INTO public.lehrform (id, bezeichnung, kuerzel) VALUES (3, 'Praktikum', 'P');
INSERT INTO public.lehrform (id, bezeichnung, kuerzel) VALUES (4, 'Labor', 'L');
INSERT INTO public.lehrform (id, bezeichnung, kuerzel) VALUES (5, 'Seminar', 'S');
INSERT INTO public.lehrform (id, bezeichnung, kuerzel) VALUES (6, 'Projekt', 'Pr');
INSERT INTO public.lehrform (id, bezeichnung, kuerzel) VALUES (7, 'Tutorium', 'T');


--
-- Data for Name: modul; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (1, 'ADS', 1, 'Algorithmen und Datenstrukturen  ', '', '', 6, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (3, 'BAID', 1, 'Bachelorarbeit Informatik und Design', NULL, NULL, 12, 'Die Vergabe einer Bachelor-Arbeit ist jederzeit mö', 'Arbeitsaufwand: 360 Stunden', 'Nicht begrenzt', 'Siehe § 23 und § 24 BRPO', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (2, 'BFK', 1, 'Berufsfeldkompetenzen ', '', '', 3, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (4, 'CPD', 1, 'Cross-Platform Development ', '', '', 6, 'Wintersemester, jährlich', '4-6 Personen pro Projektgruppe', 'Nicht begrenzt', 'Anmeldung via Moodle Kurs', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (5, 'DBA', 1, 'Datenbanksysteme', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (6, 'EPR', 1, 'Einführung in die Programmierung', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (7, 'EXR', 1, 'Extended Reality', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30', 'Nicht begrenzt', 'Anmeldung im Moodle-Kurs', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (8, 'GPB', 1, 'Großprojekt BUILDING Sustainable Futures', NULL, NULL, 12, 'Wintersemester, jährlich', 'Projektgruppen 3-6 Studierende', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (9, 'GPD', 1, 'Großprojekt DESIGNING Sustainable Futures', NULL, NULL, 12, 'Sommersemester, jährlich', 'Projektgruppen 3-6 Studierende', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (10, 'IDKG', 1, 'Informatik und Design in Kultur und Gesellschaft', NULL, NULL, 3, 'Sommersemester, jährlich', 'Arbeitsaufwand: Kontaktzeit: 28 Zeitstunden', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (11, 'KBID', 1, 'Kolloquium zur Bachelorarbeit Informatik und Design', NULL, NULL, 3, 'Das Kolloquium zur Bachelorarbeit wird ca. 2 Woche', 'Arbeitsaufwand: 90 Stunden', 'Nicht begrenzt', 'Siehe § 19 PO und § 26 BRPO', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (12, 'LDS', 1, 'Logik und diskrete Strukturen', NULL, NULL, 6, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (42, 'LUANI', 1, 'Learning Unit: Computeranimation', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (40, 'LUBGS', 1, 'Learning Unit: Bildkonzeption und Bildgestaltung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (41, 'LUBID', 1, 'Learning Unit: Brand Identity und Design', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (27, 'LUCCO', 1, 'Learning Unit: Cloud Computing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (43, 'LUGDS', 1, 'Learning Unit: Game-Design und Gamification', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (28, 'LUGSP', 1, 'Learning Unit: Grafik und Shader Programmierung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (44, 'LUIND', 1, 'Learning Unit: Informationsdesign', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (45, 'LUIPD', 1, 'Learning Unit: Interaktive Prototypen und Demonstratoren', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (51, 'LUIUX', 1, 'Learning Unit: UI und UX Design', NULL, NULL, NULL, NULL, 'Standard', NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (29, 'LUKIF', 1, 'Learning Unit: KI Modelle und Frameworks', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (46, 'LULVL', 1, 'Learning Unit: Level Design und Generierung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (39, 'LUMOD', 1, 'Learning Unit: 3D-Modellierung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (30, 'LUNOD', 1, 'Learning Unit: NOSQL Datenbanken', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (47, 'LUNUF', 1, 'Learning Unit: Nutzerforschung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (31, 'LUPHY', 1, 'Learning Unit: Physical Computing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (48, 'LUPRM', 1, 'Learning Unit: Projektmanagement', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (32, 'LUPYP', 1, 'Learning Unit: Python Programmierung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (49, 'LUSOD', 1, 'Learning Unit: Social Design', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (33, 'LUSOT', 1, 'Learning Unit: Software Testing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (34, 'LUSPE', 1, 'Learning Unit: Spiele-Entwicklung mit 3D Game Engines', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (50, 'LUSTV', 1, 'Learning Unit: Storytelling und Visualisierung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (35, 'LUUST', 1, 'Learning Unit: Usability Testing', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (36, 'LUVIP', 1, 'Learning Unit: Visuelle Programmierung', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (52, 'LUVSP', 1, 'Learning Unit: Videoschnitt und Produktion', NULL, NULL, NULL, NULL, NULL, NULL, 'Anmeldung über Moodle Kurs', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (37, 'LUWBT', 1, 'Learning Unit: Web Technologien', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (53, 'LUWED', 1, 'Learning Unit: Webdesign', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (54, 'LUWIA', 1, 'Learning Unit: Wissenschaftliches Arbeiten', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (38, 'LUXRG', 1, 'Learning Unit: XR-Gerätetechnologie', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (13, 'MCI', 1, 'Mensch-Computer-Interaktion', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt. Praktikum: 20', 'Nicht Begrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (14, 'MGR', 1, 'Mathematische Grundlagen', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40', 'Nicht begrenzt', 'Erscheinen zum ersten Vorlesungstermin, Anmeldung', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (15, 'OPR', 1, 'Objektorientierte Programmierung', NULL, NULL, 7, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (16, 'PRB', 1, 'PRIMER to Building Sustainable Futures', NULL, NULL, 3, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (17, 'PRD', 1, 'PRIMER to Designing Sustainable Futures', NULL, NULL, 3, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (18, 'PXP', 1, 'Praxisphase', NULL, NULL, 15, 'Regulär: Sommersemester, jährlich', 'Arbeitsaufwand: Die praktische Arbeit umfasst 12 W', 'Nicht begrenzte Teilnehmerzahl', 'Explizite Anmeldung im Prüfungsamt', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (19, 'SLA', 1, 'Statistik und Lineare Algebra', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30', 'Nicht begrenzt', 'Erscheinen zum ersten Vorlesungstermin, Anmelden', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (20, 'SPB', 1, 'Projekt-Support-Modul BUILDING Sustainable Futures', NULL, NULL, 9, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über Moodle-Kurs', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (21, 'SPD', 1, 'Projekt-Support-Modul DESIGNING Sustainable Futures', NULL, NULL, 9, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über Moodle-Kurs', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (22, 'STD', 1, 'START Design', NULL, NULL, 6, 'Sommersemester, jährlich', '4-6 Personen pro Projekt', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (23, 'STI', 1, 'START Informatik', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30.', 'Nicht begrenzt', 'Anmeldung im Moodle-Kurs', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (24, 'STP', 1, 'START Projekt', NULL, NULL, 6, 'Wintersemester, jährlich', '4-6 Personen pro Gruppe', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (25, 'SWT', 1, 'Softwaretechnik', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über Moodle', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (26, 'TEID', 1, 'Technisches Englisch', NULL, NULL, 5, 'Wintersemester, jährlich', '≤ 30', '≤ 30', 'Online unter www.spz.w-hs.de im Klausurzeitraum, der', '2025-10-09 15:29:11', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (55, 'BAIN', 1, 'Bachelorarbeit Informatik', NULL, NULL, 12, 'Die Vergabe einer Bachelorarbeit ist jederzeit mög', 'Siehe § 22 BRPO', 'Wie Gruppengröße', 'Siehe § 24 BRPO', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (64, 'BKV', 1, 'Betrieb komplexer verteilter Systeme', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (83, 'BRW', 1, 'Betriebliches Rechnungswesen', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (56, 'BSY', 1, 'Betriebssysteme', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung nicht begrenzt, Übung: 30', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (65, 'BV', 1, 'Einführung in die Bildverarbeitung', NULL, NULL, 6, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Keine', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (84, 'DIM', 1, 'Digitales Marketing', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: unbegrenzt, Übung 30, Praktikum 20', 'Unbegrenzt', 'Siehe Aushänge/Bekanntmachungen des', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (66, 'DOW', 1, 'Data on the Web', NULL, NULL, 6, 'Sommersemester (jährlich)', 'Vorlesung: nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Über den dazugehörenden Moodle-Kurs', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (67, 'DSP', 1, 'Data Science in Practice', NULL, NULL, 6, 'Sommersemester, bei Bedarf', '20 Personen', 'Nicht begrenzt', 'Erscheinen zur ersten Vorlesung und Anmeldung zum', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (85, 'EBW', 1, 'Einführung in die Betriebswirtschaftslehre', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (68, 'EMI', 1, 'Einführung in die medizinische Informatik', NULL, NULL, 6, 'Sommer- oder Wintersemester, bei Bedarf', 'Nicht begrenzt', 'Nicht begrenzt', 'Erscheinen zur ersten Vorlesung und Anmeldung zum', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (69, 'ERO', 1, 'Einführung in die Robotik', NULL, NULL, 6, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Keine', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (86, 'GPM', 1, 'Geschäftsprozessmanagement', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (87, 'GWI', 1, 'Grundlagen der Wirtschaftsinformatik', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: unbegrenzt, Übung: 40', 'Unbegrenzt', 'Siehe Aushänge/Bekanntmachungen des', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (70, 'INP', 1, 'Internet-Protokolle', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (57, 'INS', 1, 'Untertitel: ---', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (71, 'ITR', 1, 'Untertitel:', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (72, 'ITS', 1, 'Grundlagen der IT Sicherheit', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (73, 'KBE', 1, 'Komponentenbasierte Softwareentwicklung', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (58, 'KBIN', 1, 'Kolloquium zur Bachelorarbeit Informatik', NULL, NULL, 3, 'Das Kolloquium zur Bachelorarbeit wird ca. 2 Woche', 'Siehe § 22 der Bachelor-Rahmenprüfungsordnung', 'Wie Gruppengröße', 'Siehe § 19 PO und § 26 BRPO', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (74, 'KI', 1, 'Künstliche Intelligenz', NULL, NULL, 6, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (75, 'KNG', 1, 'Knowledge Graphs', NULL, NULL, 6, 'Sommersemester (nach Bedarf)', 'Vorlesung: nicht begrenzt, Übung: 30, Praktikum: 2', 'Nicht begrenzt', 'Über den dazugehörenden Moodle-Kurs', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (76, 'MAD', 1, 'Mobile Application Development', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Vorlesung: keine, Praktikum: über Moodle-Kurs', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (77, 'MCC', 1, 'Mobile und Cloud Computing', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung 30, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung für Übung und Praktikum via Moodle', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (78, 'MRO', 1, 'Mobile Robotik', NULL, NULL, 6, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Keine', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (88, 'NSA', 1, 'Angewandte Netzwerksicherheit', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: nicht begrenzt', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (79, 'PAP', 1, 'Parallele Programmierung', NULL, NULL, 6, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Keine', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (89, 'PMA', 1, 'Projektmanagement', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: unbegrenzt', 'Nicht begrenzte Teilnehmerzahl', 'Siehe Aushang am Schwarzen Brett des Professors', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (90, 'PMW', 1, 'Produktion und Materialwirtschaft', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: unbegrenzt; Praktikum: 20; Übung: 30', 'Nicht begrenzt', 'siehe Lernplattform Moodle', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (80, 'PPR', 1, 'Prozedurale Programmierung', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Vorlesung: keine, Übungen und Praktikum: über', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (81, 'PRAX', 1, 'Practical Security Attacks and Exploitation', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung via Moodle', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (59, 'REN', 1, 'Rechnernetze', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung 40, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung für Übung und Praktikum via Moodle', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (60, 'SPIN', 1, 'Softwareprojekt Informatik', NULL, NULL, 12, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum:', 'Nicht begrenzt', 'Explizite Voranmeldung und Anmeldung erforderlich.', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (82, 'SWD', 1, 'Software Design', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (61, 'TENI', 1, 'Technisches Englisch für Informatiker', NULL, NULL, 5, 'Wintersemester, jährlich', '≤ 30', '≤ 30', 'Online unter www.spz.w-hs.de im Klausurzeitraum, der', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (62, 'TGI', 1, 'Technische Grundlagen der Informatik', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung 40, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung für Übung und Praktikum via Moodle', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (63, 'THI', 1, 'Theoretische Informatik', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung: 40', 'Nicht begrenzt', 'Vorlesung: keine, Übungen: über den Moodle-Kurs', '2025-10-09 15:29:15', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (114, 'AID', 1, 'Advanced Interface Design', NULL, NULL, 6, 'Wintersemester, jährlich', 'Projektgruppen mit 3-5 Studierenden', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (98, 'ASY', 1, 'Autonome Systeme', NULL, NULL, 6, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Keine', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (99, 'CV', 1, 'Computer Vision', NULL, NULL, 6, 'unregelmäßig bei Bedarf', 'Standard', 'Nicht begrenzt', 'Moodle Abfrage', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (100, 'DBT', 1, 'Datenbanktheorie', NULL, NULL, 6, 'Sommersemester (nach Bedarf)', 'Vorlesung: nicht begrenzt, Übung: 30', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (115, 'DFIR', 1, 'Digital Forensics and Incident Response', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Voraussetzungen nach Keine', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (101, 'DSC', 1, 'Data Science Principles', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (116, 'DSE', 1, 'Datenschutz und Ethik', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40', 'Nicht begrenzt', 'Siehe Aushang', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (117, 'DSM', 1, 'Designmanagement', NULL, NULL, 6, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (118, 'ECCR', 1, 'Emerging Challenges in Cybersecurity Research', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (102, 'EINT', 1, 'Entwicklung intelligenter Systeme', NULL, NULL, 6, 'Sommersemester, unregelmäßig', 'Standard', '12', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (103, 'FCO', 1, 'Future Computing', NULL, NULL, 6, 'Wintersemester, jährlich', 'Nicht begrenzt', 'Nicht begrenzt', 'Anmeldung per Email: Prof@DieterHannemann.de', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (104, 'FPR', 1, 'Funktionale Programmierung', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Voraussetzungen nach Keine', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (119, 'GAM', 1, 'Gamification', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 20', 'Nicht begrenzt', 'Anmeldung im Moodle-Kurs', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (91, 'IGE', 1, 'Informatik und Gesellschaft', NULL, NULL, 6, 'Wintersemester und Sommersemester, halbjährlich', 'Vorlesung: Nicht begrenzt, Übung: 20', 'Nicht begrenzt', 'Anmeldung beim ersten Veranstaltungstermin', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (120, 'IKA', 1, 'Interaktive Kollaborative Arbeitsumgebungen', NULL, NULL, 6, 'Sommersemester, jährlich', '4-6 pro Projektgruppe', 'Nicht begrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (105, 'INT', 1, 'Intelligente Systeme', NULL, NULL, 6, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (121, 'ISA', 1, 'Internet-Sicherheit A', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (122, 'ISB', 1, 'Internet-Sicherheit B', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (123, 'ISY', 1, 'Interaktive Systeme', NULL, NULL, 6, 'Sommersemester, unregelmäßig', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (92, 'KMIN', 1, 'Kolloquium zur Masterarbeit Informatik', NULL, NULL, 5, 'Das Kolloquium zur Masterarbeit wird ca. 2 Wochen', 'Siehe § 22 der Master-Rahmenprüfungsordnung', 'Wie Gruppengröße', 'Siehe § 16 PO und § 26 MRPO', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (106, 'LPR', 1, 'Logische Programmierung', NULL, NULL, 6, 'Sommersemester, unregelmäßig', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (93, 'MAIN', 1, 'Masterarbeit Informatik', NULL, NULL, 25, 'Die Vergabe einer Masterarbeit ist jederzeit mögli', 'Siehe § 22 der Master-Rahmenprüfungsordnung', 'Wie Gruppengröße', 'Siehe § 13 und § 14 PO', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (107, 'MAS', 1, 'Multi-Agent Systems', NULL, NULL, 6, 'Summer term, not regularly', 'Lecture: no limits, theoretical work: 40', '20', 'registration to the related Moodle-course', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (108, 'MCA', 1, 'Mobile und Cloud Computing Advanced', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung 40, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung via Moodle', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (124, 'MCTI', 1, 'Malware-Analyse und Cyber Threat Intelligence', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Voraussetzungen nach Keine', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (109, 'MGN', 1, 'Mathematische Grundlagen neuronaler Netze', NULL, NULL, 6, 'Sommersemester, nach Bedarf', 'Vorlesung: Nicht begrenzt, Übung: 40', 'Nicht begrenzt', 'Erscheinen zum ersten Kurstermin und Anmeldung', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (94, 'MPIN', 1, 'Master-Projekt Informatik', NULL, NULL, 12, 'Sommersemester, jährlich', 'Projektteams von 3 bis 8 Studierenden', 'Nicht begrenzt', 'Explizite Anmeldung erforderlich. Informationen im Info-', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (95, 'MSIN', 1, 'Master-Seminar Informatik', NULL, NULL, 6, 'Sommersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Explizite Anmeldung notwendig. Weitere Informationen', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (110, 'NSQ', 1, 'NOSQL Datenbanken', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (125, 'NUI', 1, 'Natural User Interfaces', NULL, NULL, 6, 'Sommersemester, unregelmäßig', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (126, 'PETS', 1, 'Privacy Enhancing Technologies', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (96, 'PM', 1, 'Projektmanagement', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt,', '12', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (127, 'PRMS', 1, 'Programmiermethodik und Sicherheit', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Voraussetzungen nach Keine', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (111, 'SAS', 1, 'Spezielle Kapitel Autonome Systeme', NULL, NULL, 6, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Keine', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (128, 'SRE', 1, 'Software Reverse Engineering', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2', 'Nicht begrenzt', 'Keine', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (112, 'SWE', 1, 'Software Engineering', NULL, NULL, 6, 'Summer term, not regularly', 'Lecture: no limits, theoretical work: 40', 'No limits', 'registration to the related Moodle-course', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (129, 'VDM', 1, 'Vertiefung Digitales Marketing', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40', 'Nicht begrenzt', 'Voraussetzungen nach Keine modulspezifischen Voraussetzungen', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (130, 'VIR', 1, 'Virtuelle Welten', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 30', 'Nicht begrenzt', 'Anmeldung im Moodle-Kurs', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (131, 'VSC', 1, 'Vertiefung Supply Chain Management', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: 30 Praktikum: 20', 'Nicht begrenzte Teilnehmerzahl', 's. Lernplattform', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (113, 'WKV', 1, 'Weiterführende Konzepte zum Betrieb komplexer verteilter', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (97, 'WVIN', 1, 'Wissenschaftliche Vertiefung Informatik', NULL, NULL, 12, 'Sommer- und Wintersemester, halbjährlich', 'Projektteams von 1 bis 3 Studierenden', 'Nicht begrenzt', 'Die Ausgabe eines Projektthemas kann über jede/n', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (132, 'ZMI', 1, 'Zukunftstrends in der Medieninformatik', NULL, NULL, 6, 'Sommersemester, unregelmäßig', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:20', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (133, 'ATIS', 1, 'Ausgewählte Themen aus dem Bereich Internet und Sicherheit', NULL, NULL, 6, 'Wintersemester und Sommersemester, halbjährlich', 'Vorlesung: Nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Voraussetzungen nach Keine', '2025-10-09 15:29:22', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (134, 'KMIS', 1, 'Kolloquium zur Masterarbeit Internet-Sicherheit', NULL, NULL, 5, 'Das Kolloquium zur Masterarbeit ist jederzeit mögl', 'Im Regelfall Gruppengröße 1, größere Gruppen', 'Wie Gruppengröße', 'Siehe § 16 PO und § 26 MRPO', '2025-10-09 15:29:22', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (135, 'MAIS', 1, 'Masterarbeit Internet-Sicherheit', NULL, NULL, 25, 'Die Vergabe einer Masterarbeit ist jederzeit mögli', 'Im Regelfall Gruppengröße 1, größere Gruppen', 'Wie Gruppengröße', 'Siehe § 13 und § 14 PO und § 23 MRPO', '2025-10-09 15:29:22', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (136, 'MPIS', 1, 'Master-Projekt Internet-Sicherheit', NULL, NULL, 12, 'Wintersemester, jährlich', 'Standard, i.d.R. Projektteams von 6 bis 8 Studiere', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:22', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (137, 'MSIS', 1, 'Master-Seminar Internet-Sicherheit', NULL, NULL, 6, 'Zu jedem Semester', 'Standard, i.d.R. Projektteams von 3 bis 6 Studiere', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:22', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (138, 'MVIS', 1, 'Wissenschaftliche Vertiefung Internet-Sicherheit', NULL, NULL, 12, 'Wintersemester, jährlich', 'Standard, i.d.R. Projektteams von 3 bis 6 Studiere', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:22', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (139, 'CRI', 1, 'Cross-Reality Interaction', NULL, NULL, 6, 'Sommersemester, jährlich', '4-6 pro Projektgruppe', 'unbegrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:26', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (140, 'D3D', 1, 'Design für 3D User Interfaces', NULL, NULL, 6, 'Wintersemester, jährlich', '4-6 pro Projektgruppe', 'unbegrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:26', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (141, 'KMMI', 1, 'Kolloquium zur Masterarbeit Medieninformatik', NULL, NULL, 5, 'Das Kolloquium zur Masterarbeit wird ca. 2 Wochen', 'Arbeitsaufwand: 150 Stunden', 'Nicht begrenzt', 'Siehe § 16 PO und § 26 MRPO', '2025-10-09 15:29:26', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (142, 'MMI', 1, 'Masterarbeit Medieninformatik', NULL, NULL, 25, 'Die Vergabe einer Masterarbeit ist jederzeit mögli', 'Arbeitsaufwand: 750 Stunden', 'Nicht begrenzt', 'Siehe § 13 und § 14 der Studiengangsprüfungsordnung', '2025-10-09 15:29:26', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (143, 'MPMI', 1, 'Master-Projekt Medieninformatik', NULL, NULL, 12, 'Sommersemester, jährlich', 'Projektgruppen 3-6 Studierende', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:26', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (144, 'MSMI', 1, 'Master-Seminar Medieninformatik', NULL, NULL, 6, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:26', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (145, 'WVMI', 1, 'Wissenschaftliche Vertiefung Medieninformatik', NULL, NULL, 12, 'Unregelmäßig (bei Bedarf)', 'Projektteams von 1-4 Studierenden', 'Nicht begrenzt', 'Anmeldung über den Moodle Kurs zu diesem Modul', '2025-10-09 15:29:26', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (146, 'BAWI', 1, 'Bachelorarbeit Wirtschaftsinformatik', NULL, NULL, 12, 'Die Vergabe einer Bachelorarbeit ist jederzeit mög', 'Siehe § 22 der Bachelor-Rahmenprüfungsordnung', 'Wie Gruppengröße', 'Siehe § 23 und § 24 BRPO', '2025-10-09 15:29:30', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (147, 'BNW', 1, 'Betriebssysteme und Netzwerke für WI', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: nicht begrenzt, Übung 40', 'Nicht begrenzt', 'Anmeldung für Übung via Moodle', '2025-10-09 15:29:30', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (148, 'GSC', 1, 'Grundlagen Supply Chain Management', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung: unbegrenzt; Praktikum/ Übung: 20', 'Nicht begrenzt', 'siehe Lernplattform Moodle', '2025-10-09 15:29:30', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (149, 'KBWI', 1, 'Kolloquium zur Bachelorarbeit Wirtschaftsinformatik', NULL, NULL, 3, 'Das Kolloquium zur Bachelorarbeit wird ca. 2 Woche', 'Siehe § 22 der Bachelor-Rahmenprüfungsordnung', 'Wie Gruppengröße', 'Siehe § 19 PO und § 26 BRPO', '2025-10-09 15:29:30', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (150, 'SCD', 1, 'Supply Chain Management und Digitalisierung', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: unbegrenzt; Praktikum: 20; Übung: 40', 'Nicht begrenzt', 'siehe Lernplattform Moodle', '2025-10-09 15:29:30', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (151, 'SPWI', 1, 'Softwareprojekt Wirtschaftsinformatik', NULL, NULL, 12, 'Sommersemester, jährlich', 'Vorlesung: Nicht begrenzt, Übung: 40, Praktikum:', 'Nicht begrenzt', 'Explizite Voranmeldung und Anmeldung erforderlich.', '2025-10-09 15:29:30', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (152, 'WEN', 1, 'Wirtschaftsenglisch für Wirtschaftsinformatiker', NULL, NULL, 5, 'Sommersemester, jährlich', '≤ 30', '≤ 30', 'Online unter www.spz.w-hs.de im Klausurzeitraum, der', '2025-10-09 15:29:30', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (153, 'BIN', 1, 'Business Intelligence und Big Data', NULL, NULL, 6, 'Wintersemester, jährlich', 'Vorlesung: Nicht begrenzt, Praktikum: 20', 'Nicht begrenzt', 'Anmeldung über den Moodle-Kurs zu diesem Modul', '2025-10-09 15:29:33', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (158, 'GDM', 1, 'Grundlagen des Managements', NULL, NULL, 6, 'Wintersemester', '20', '5', 'Voraussetzungen nach Keine', '2025-10-09 15:29:33', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (154, 'KMWI', 1, 'Kolloquium zur Masterarbeit Wirtschaftsinformatik', NULL, NULL, 5, 'Das Kolloquium zur Masterarbeit wird ca. 2 Wochen', 'Siehe § 22 der Master-Rahmenprüfungsordnung', 'Wie Gruppengröße', 'Siehe § 16 PO und § 26 MRPO', '2025-10-09 15:29:33', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (156, 'MAWI', 1, 'Masterarbeit Wirtschaftsinformatik', NULL, NULL, 25, 'Die Vergabe einer Masterarbeit ist jederzeit mögli', 'Siehe § 22 der Master-Rahmenprüfungsordnung', 'Wie Gruppengröße', 'Siehe § 13 und § 14 PO und § 23 MRPO', '2025-10-09 15:29:33', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (155, 'MPWI', 1, 'Master-Projekt Wirtschaftsinformatik 1', NULL, NULL, 12, 'Sommersemester, jährlich', 'Projektteams von 3 bis 8 Studierenden', 'Nicht begrenzt', 'Explizite Anmeldung erforderlich. Informationen im Info-', '2025-10-09 15:29:33', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (157, 'MSWI', 1, 'Master-Seminar Wirtschaftsinformatik', NULL, NULL, 6, 'Wintersemester, jährlich', 'Standard', 'Nicht begrenzt', 'Explizite Anmeldung notwendig. Weitere Informationen', '2025-10-09 15:29:33', '2026-02-02 03:49:08.493731');
INSERT INTO public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) VALUES (159, 'SOM', 1, 'Strategisches und operatives Management', NULL, NULL, 6, 'Sommersemester, jährlich', 'Vorlesung und Übung 20', '20', 'Keine', '2025-10-09 15:29:33', '2026-02-02 03:49:08.493731');


--
-- Data for Name: modul_abhÃ¤ngigkeit; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: modul_arbeitsaufwand; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (2, 1, 28, 62, 0, 90);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (4, 1, 56, 124, 0, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (7, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (8, 1, 56, 304, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (9, 1, 56, 304, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (10, 1, 28, 62, NULL, 90);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (51, 1, 28, 62, NULL, 90);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (16, 1, 28, 62, NULL, 90);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (17, 1, 28, 62, NULL, 90);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (18, 1, NULL, NULL, NULL, 420);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (20, 1, 84, 186, NULL, 270);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (21, 1, 84, 186, NULL, 270);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (22, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (23, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (24, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (26, 1, 60, 90, NULL, 150);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (55, 1, NULL, NULL, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (56, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (58, 1, NULL, NULL, NULL, 90);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (59, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (93, 1, NULL, NULL, NULL, 750);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (134, 1, NULL, NULL, NULL, 150);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (135, 1, NULL, NULL, NULL, 750);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (145, 1, 56, 304, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (146, 1, NULL, NULL, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (147, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (148, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (149, 1, NULL, NULL, NULL, 90);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (150, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (151, 1, 50, 310, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (152, 1, 56, 94, NULL, 150);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (153, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (109, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (94, 1, 29, 331, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (95, 1, 28, 152, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (125, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (1, 1, 56, 124, 0, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (5, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (6, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (12, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (13, 1, 70, 110, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (14, 1, 90, 90, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (15, 1, 70, 140, NULL, 210);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (19, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (25, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (64, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (83, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (65, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (84, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (66, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (67, 1, 42, 138, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (85, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (68, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (69, 1, 70, 110, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (86, 1, 70, 110, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (87, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (70, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (57, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (71, 1, 54, 124, NULL, 178);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (72, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (73, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (74, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (75, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (76, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (77, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (78, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (88, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (79, 1, 70, 110, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (89, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (90, 1, 70, 110, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (80, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (81, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (60, 1, 85, 275, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (82, 1, 70, 110, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (61, 1, 60, 90, NULL, 150);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (62, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (63, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (114, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (98, 1, 70, 110, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (99, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (115, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (117, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (118, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (102, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (119, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (120, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (105, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (123, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (106, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (124, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (96, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (127, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (111, 1, 75, 105, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (128, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (130, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (97, 1, 30, 330, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (132, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (133, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (136, 1, 56, 304, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (137, 1, 30, 150, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (138, 1, 30, 330, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (139, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (140, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (143, 1, 56, 304, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (144, 1, 28, 152, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (100, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (101, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (116, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (103, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (104, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (91, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (121, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (122, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (108, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (110, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (126, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (129, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (131, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (113, 1, 56, 124, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (158, 1, 60, 120, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (155, 1, 28, 332, NULL, 360);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (157, 1, 30, 150, NULL, 180);
INSERT INTO public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) VALUES (159, 1, 60, 120, NULL, 180);


--
-- Data for Name: modul_audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_audit_log (id, modul_id, po_id, geaendert_von, aktion, alt_dozent_id, neu_dozent_id, alte_rolle, neue_rolle, bemerkung, created_at) VALUES (1, 1, 1, 1, 'dozent_hinzugefuegt', NULL, 1, NULL, 'pruefend', NULL, '2025-11-25 22:41:02.093092');


--
-- Data for Name: modul_dozent; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (88, 55, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (98, 58, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (114, 60, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (180, 92, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (184, 94, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (186, 95, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (190, 97, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (57, 29, 1, NULL, 'Dozent', NULL, NULL, 6);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (58, 30, 1, NULL, 'Dozent', NULL, NULL, 6);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (82, 52, 1, NULL, 'Dozent', NULL, NULL, 7);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (87, 55, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (97, 58, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (113, 60, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (177, 91, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (179, 92, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (181, 93, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (183, 94, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (185, 95, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (189, 97, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 8);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (137, 71, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (156, 80, 1, NULL, 'Dozent', NULL, NULL, 10);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (178, 91, 1, NULL, 'Dozent', NULL, NULL, 10);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (182, 93, 1, NULL, 'Dozent', NULL, NULL, 11);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (209, 107, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 12);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (210, 107, 1, NULL, 'Dozent', NULL, NULL, 12);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (242, 123, 1, NULL, 'Dozent', NULL, NULL, 13);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (259, 132, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 14);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (260, 132, 1, NULL, 'Dozent', NULL, NULL, 15);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (270, 134, 1, NULL, 'Dozent', NULL, NULL, 16);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (272, 135, 1, NULL, 'Dozent', NULL, NULL, 16);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (276, 136, 1, NULL, 'Dozent', NULL, NULL, 16);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (278, 137, 1, NULL, 'Dozent', NULL, NULL, 16);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (280, 138, 1, NULL, 'Dozent', NULL, NULL, 16);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (495, 85, 1, 31, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (496, 86, 1, 31, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (497, 87, 1, 32, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (498, 87, 1, 31, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (499, 96, 1, 23, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (500, 125, 1, 53, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (501, 159, 1, 32, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (502, 159, 1, 36, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (4, 2, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (6, 3, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (16, 8, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (18, 9, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (20, 10, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (22, 11, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (32, 16, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (34, 17, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (40, 20, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (42, 21, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (50, 24, 1, NULL, 'Dozent', NULL, NULL, 1);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (5, 3, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 2);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (15, 8, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 2);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (17, 9, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 2);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (31, 16, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 2);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (33, 17, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 2);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (21, 11, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 3);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (39, 20, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 3);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (41, 21, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 3);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (35, 18, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 4);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (36, 18, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (1, 1, 1, 1, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (2, 1, 1, 1, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (3, 2, 1, 2, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (7, 4, 1, 5, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (8, 4, 1, 5, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (9, 5, 1, 6, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (10, 5, 1, 6, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (11, 6, 1, 7, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (12, 6, 1, 7, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (13, 7, 1, 8, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (14, 7, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (19, 10, 1, 9, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (23, 12, 1, 1, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (24, 12, 1, 1, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (25, 13, 1, 9, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (26, 13, 1, 9, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (27, 14, 1, 11, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (28, 14, 1, 11, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (29, 15, 1, 7, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (30, 15, 1, 7, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (37, 19, 1, 11, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (38, 19, 1, 11, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (43, 22, 1, 2, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (44, 22, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (46, 23, 1, 8, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (47, 23, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (48, 23, 1, 5, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (49, 24, 1, 2, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (51, 25, 1, 15, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (52, 25, 1, 15, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (55, 27, 1, 5, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (56, 28, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (59, 31, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (60, 32, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (61, 33, 1, 5, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (62, 34, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (63, 35, 1, 9, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (64, 36, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (65, 37, 1, 5, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (66, 38, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (67, 39, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (68, 40, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (69, 41, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (70, 42, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (71, 43, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (72, 44, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (74, 45, 1, 5, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (75, 46, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (76, 47, 1, 9, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (77, 48, 1, 9, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (78, 49, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (79, 50, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (81, 51, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (83, 53, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (84, 54, 1, 9, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (89, 56, 1, 21, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (90, 56, 1, 21, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (95, 57, 1, 21, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (96, 57, 1, 21, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (109, 59, 1, 22, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (110, 59, 1, 22, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (119, 62, 1, 22, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (120, 62, 1, 22, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (121, 63, 1, 23, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (122, 63, 1, 23, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (123, 64, 1, 21, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (124, 64, 1, 21, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (125, 65, 1, 24, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (126, 65, 1, 24, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (127, 66, 1, 6, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (128, 66, 1, 6, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (129, 67, 1, 11, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (130, 67, 1, 11, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (131, 68, 1, 11, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (132, 68, 1, 11, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (133, 69, 1, 24, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (134, 69, 1, 24, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (135, 70, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (136, 70, 1, 25, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (138, 71, 1, 27, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (139, 72, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (45, 22, 1, NULL, 'Dozent', NULL, NULL, 23);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (73, 44, 1, NULL, 'Dozent', NULL, NULL, 23);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (80, 50, 1, NULL, 'Dozent', NULL, NULL, 23);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (53, 26, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 24);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (117, 61, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 24);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (54, 26, 1, NULL, 'Dozent', NULL, NULL, 25);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (118, 61, 1, NULL, 'Dozent', NULL, NULL, 25);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (140, 72, 1, 25, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (141, 73, 1, 15, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (142, 73, 1, 15, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (143, 74, 1, 1, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (144, 74, 1, 1, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (145, 75, 1, 6, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (146, 75, 1, 6, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (149, 77, 1, 22, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (150, 77, 1, 22, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (151, 78, 1, 24, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (152, 78, 1, 24, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (153, 79, 1, 24, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (154, 79, 1, 24, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (155, 80, 1, 23, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (157, 81, 1, 30, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (158, 81, 1, 30, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (159, 82, 1, 15, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (160, 82, 1, 15, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (161, 83, 1, 31, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (162, 83, 1, 31, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (163, 84, 1, 32, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (164, 84, 1, 32, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (166, 85, 1, 31, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (168, 86, 1, 31, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (170, 87, 1, 32, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (171, 88, 1, 35, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (172, 88, 1, 35, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (173, 89, 1, 36, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (174, 89, 1, 37, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (175, 90, 1, 36, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (176, 90, 1, 36, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (187, 96, 1, 23, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (191, 98, 1, 24, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (192, 98, 1, 24, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (193, 99, 1, 24, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (194, 99, 1, 24, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (195, 100, 1, 6, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (196, 100, 1, 6, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (197, 101, 1, 11, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (198, 101, 1, 11, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (199, 102, 1, 1, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (200, 102, 1, 1, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (201, 103, 1, 40, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (202, 103, 1, 40, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (203, 104, 1, 7, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (204, 104, 1, 7, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (205, 105, 1, 1, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (206, 105, 1, 1, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (207, 106, 1, 23, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (208, 106, 1, 23, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (211, 108, 1, 22, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (212, 108, 1, 22, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (213, 109, 1, 11, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (214, 109, 1, 11, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (215, 110, 1, 6, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (216, 110, 1, 6, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (217, 111, 1, 24, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (218, 111, 1, 24, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (219, 112, 1, 15, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (220, 112, 1, 15, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (221, 113, 1, 21, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (222, 113, 1, 21, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (223, 114, 1, 2, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (224, 114, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (225, 115, 1, 30, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (226, 115, 1, 30, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (227, 116, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (228, 116, 1, 27, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (229, 117, 1, 2, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (230, 117, 1, 2, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (231, 118, 1, 35, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (232, 118, 1, 35, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (233, 119, 1, 8, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (234, 119, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (235, 120, 1, 9, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (236, 120, 1, 9, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (237, 121, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (238, 121, 1, 25, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (239, 122, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (240, 122, 1, 25, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (241, 123, 1, 9, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (243, 124, 1, 30, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (244, 124, 1, 30, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (245, 125, 1, 9, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (247, 126, 1, 35, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (248, 126, 1, 35, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (249, 127, 1, 30, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (250, 127, 1, 30, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (251, 128, 1, 30, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (252, 128, 1, 30, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (253, 129, 1, 32, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (254, 129, 1, 32, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (255, 130, 1, 8, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (256, 130, 1, 8, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (257, 131, 1, 36, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (258, 131, 1, 36, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (261, 133, 1, 30, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (262, 133, 1, 30, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (269, 134, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (271, 135, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (275, 136, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (277, 137, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (279, 138, 1, 25, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (307, 139, 1, 5, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (308, 139, 1, 5, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (309, 140, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 23);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (147, 76, 1, 5, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (377, 147, 1, 22, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (378, 147, 1, 22, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (391, 148, 1, 36, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (392, 148, 1, 36, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (413, 150, 1, 36, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (414, 150, 1, 36, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (451, 153, 1, 31, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (452, 153, 1, 31, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (489, 158, 1, 51, 'Modulverantwortlicher', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (490, 158, 1, 51, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (492, 159, 1, 32, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (493, 159, 1, 36, 'Dozent', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (494, 1, 1, 1, 'pruefend', NULL, NULL, NULL);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (316, 141, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (318, 142, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (376, 146, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (398, 149, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (418, 151, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (458, 154, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (460, 155, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (466, 157, 1, NULL, 'Dozent', NULL, NULL, 5);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (375, 146, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (397, 149, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (417, 151, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (457, 154, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (459, 155, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (463, 156, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (465, 157, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 9);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (315, 141, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 14);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (317, 142, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 14);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (320, 143, 1, NULL, 'Dozent', NULL, NULL, 15);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (319, 143, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 17);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (321, 144, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 17);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (369, 145, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 17);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (322, 144, 1, NULL, 'Dozent', NULL, NULL, 18);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (370, 145, 1, NULL, 'Dozent', NULL, NULL, 19);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (310, 140, 1, NULL, 'Dozent', NULL, NULL, 23);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (421, 152, 1, NULL, 'Modulverantwortlicher', NULL, NULL, 24);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (422, 152, 1, NULL, 'Dozent', NULL, NULL, 25);
INSERT INTO public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) VALUES (464, 156, 1, NULL, 'Dozent', NULL, NULL, 26);


--
-- Data for Name: modul_lehrform; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (3, 2, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (4, 4, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (5, 4, 1, 6, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (12, 7, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (13, 7, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (14, 8, 1, 6, 4);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (15, 9, 1, 6, 4);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (16, 10, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (26, 16, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (27, 17, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (30, 20, 1, 6, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (31, 21, 1, 6, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (32, 22, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (33, 22, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (34, 23, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (35, 23, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (36, 24, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (37, 24, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (40, 27, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (41, 27, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (42, 28, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (43, 28, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (44, 29, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (45, 29, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (46, 30, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (47, 30, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (48, 31, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (49, 31, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (50, 32, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (51, 32, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (52, 33, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (53, 33, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (54, 34, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (55, 34, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (56, 35, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (57, 35, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (58, 36, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (59, 36, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (60, 37, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (61, 37, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (62, 38, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (63, 39, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (64, 39, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (65, 40, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (66, 40, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (67, 41, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (68, 41, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (69, 42, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (70, 42, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (71, 43, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (72, 44, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (73, 44, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (74, 45, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (75, 45, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (76, 46, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (77, 46, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (78, 47, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (79, 47, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (80, 48, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (81, 48, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (82, 49, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (83, 49, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (84, 50, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (85, 50, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (86, 51, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (87, 51, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (88, 52, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (89, 52, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (90, 53, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (91, 53, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (92, 54, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (93, 54, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (96, 56, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (97, 56, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (115, 59, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (116, 59, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (117, 59, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (120, 60, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (121, 60, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (124, 62, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (125, 62, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (126, 62, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (127, 63, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (128, 63, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (136, 67, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (137, 67, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (138, 68, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (139, 68, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (152, 74, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (153, 74, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (159, 77, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (160, 77, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (161, 77, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (165, 79, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (166, 79, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (167, 79, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (168, 80, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (169, 80, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (170, 80, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (193, 94, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (194, 95, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (197, 97, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (207, 102, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (208, 102, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (226, 111, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (227, 111, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (228, 111, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (269, 133, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (270, 133, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (281, 136, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (282, 137, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (283, 138, 1, 5, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (284, 127, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (285, 127, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (286, 128, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (287, 128, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (289, 115, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (290, 115, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (293, 118, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (309, 139, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (310, 139, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (311, 140, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (312, 140, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (313, 117, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (314, 117, 1, 2, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (317, 143, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (318, 144, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (319, 130, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (320, 130, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (321, 114, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (322, 114, 1, 3, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (323, 98, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (324, 98, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (325, 98, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (326, 99, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (327, 99, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (328, 99, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (339, 119, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (340, 119, 1, 2, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (341, 120, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (342, 120, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (343, 105, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (344, 105, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (345, 105, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (352, 123, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (353, 123, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (354, 106, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (355, 106, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (356, 124, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (357, 124, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (358, 109, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (359, 109, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (362, 125, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (363, 125, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (364, 96, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (365, 96, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (366, 145, 1, 6, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (367, 132, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (368, 132, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (369, 1, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (370, 1, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (371, 147, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (372, 147, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (373, 83, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (374, 83, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (375, 5, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (376, 5, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (377, 5, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (378, 84, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (379, 84, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (380, 85, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (381, 85, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (382, 6, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (383, 6, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (384, 6, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (385, 86, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (386, 86, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (387, 148, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (388, 148, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (389, 87, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (390, 87, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (391, 71, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (392, 71, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (393, 12, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (394, 12, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (395, 13, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (396, 13, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (397, 14, 1, 1, 4);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (398, 14, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (399, 15, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (400, 15, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (401, 15, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (402, 89, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (403, 89, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (404, 90, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (405, 90, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (406, 150, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (407, 150, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (408, 19, 1, 1, 4);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (409, 19, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (410, 151, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (411, 151, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (412, 25, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (413, 25, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (414, 64, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (415, 64, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (416, 65, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (417, 65, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (418, 65, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (419, 66, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (420, 66, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (421, 69, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (422, 69, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (423, 69, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (424, 70, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (425, 70, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (426, 70, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (427, 57, 1, 1, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (428, 57, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (429, 72, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (430, 72, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (431, 72, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (432, 73, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (433, 75, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (434, 75, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (435, 75, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (436, 76, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (437, 76, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (438, 78, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (439, 78, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (440, 78, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (441, 88, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (442, 88, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (443, 81, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (444, 81, 1, 3, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (445, 82, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (446, 82, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (447, 153, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (448, 101, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (449, 101, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (450, 121, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (451, 121, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (452, 121, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (453, 157, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (454, 110, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (455, 110, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (456, 129, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (457, 129, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (458, 131, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (459, 131, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (460, 100, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (461, 103, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (462, 103, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (463, 104, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (464, 104, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (465, 104, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (466, 122, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (467, 122, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (468, 122, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (469, 108, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (470, 108, 1, 2, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (471, 108, 1, 3, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (472, 126, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (473, 113, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (474, 113, 1, 3, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (475, 159, 1, 1, 1);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (476, 159, 1, 2, 3);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (477, 116, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (478, 116, 1, 2, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (479, 91, 1, 1, 2);
INSERT INTO public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) VALUES (480, 91, 1, 2, 2);


--
-- Data for Name: modul_lernergebnisse; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (1, 1, 'Die Studierenden kennen wichtige grundlegende
Resultate und Methoden der Algorithmik und können
diese auf ausgewählte Problemstellungen anwenden.
Sie gewinnen detaillierte Einblicke in die
problemspezifische Optimierung von Algorithmen mittels
geeignet gewählter Datenstrukturen und können diese
nachvollziehen und anwenden.
Sie kennen und beherrschen die Grundzüge der
Analyse von Algorithmen und Problemen.', '', 'Wichtige Grundprobleme der Informatik und ihre Lösung
mit Algorithmen und unterstützenden Datenstrukturen
unter Berücksichtigung des Aufwandes, u.a.:
Sortieren (Quick/Heap/Bucketsort; Buckets, Priority-
Queues)
Problemlösung mittels Suche (Baumstrukturen,Tiefen-,
Breitensuche, iterative Deepening, BestFirst, A*)
Zugriffsstrukturen (Indices, Hashing)
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 5 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Greedy-Algorithmen (Kruskal, Huffman-Codierung,
Fractional Knapsack)
Grenzen der praktischen Lösbarkeit (Komplexität) von
Problemen am Beispiel von Wegeproblemen:
Algorithmik (Dijkstra-Varianten, MST) und
Approximation (TSP/MST)
Querschnittsthema: Analyse von Algorithmen (Kosten,
Optimalität, Approximierbarkeit).');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (3, 1, 'Die/der Studierende ist in der Lage, innerhalb einer
vorgegebenen Frist entweder
• eine praxisorientierte Aufgabe aus dem
Spannungsfeld Informatik und Design sowohl in
ihren fachlichen Einzelheiten als auch in den
themen- und fachübergreifenden
Zusammenhängen nach wissenschaftlichen
Methoden selbständig zu bearbeiten und zu
lösen und zu dokumentieren.', NULL, 'Es wird ein in der Regel praxisorientiertes Problem aus
den Disziplinen Informatik und Design mit den im
Studium erlernten Konzepten, Verfahren und Methoden
in begrenzter Zeit unter Anleitung eines erfahrenen
Betreuers gelöst.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (2, 1, 'Die Studierenden kennen mögliche Berufsfelder,
Arbeitszusammenhänge und Berufsperspektiven in der
Informatik und im Design und erarbeiten individuell ein
Portfolio mit eigenem Kompetenzprofil.
• Indem (nach Möglichkeit) eine
Auseinandersetzung und ein Austausch mit der
Berufspraxis stattfindet (Anforderungen an
Absolventen)
• Indem Berufsperspektiven analysiert,
recherchiert und entwickelt werden.
• Indem die Themen Konzeptentwicklung,
Verfassen von Exposés, Zeit- und
Kostenmanagement sowie Präsentation,
Reflexion/Argumentation am praktischen
Beispiel erprobt werden
• Indem die eigenen Kompetenzen,
Entwicklungsziele bzw. Karrierestrategien
herausgearbeitet und dargestellt werden
(Portfolio und Bewerbungsmappe)
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 7 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Um später die eigene Selbstdarstellung und
Selbsteinordnung der eigenen Fähigkeiten für den
Einstieg in den Beruf vorbereiten zu können.', 'Kürzel: BFK Untertitel: Berufsvorbereitung und Portfolioerstellung Studiensemester: 4. (Bachelor) Modulverantwortliche(r): Prof. Katja Becker Dozent(in): Lehrende des Studiengangs Informatik und Design Sprache: Deutsch, Englisch bei Bedarf Zuordnung zum Curriculum: IN ID WI - 4 - Lehrform / SWS: 2 SWS Übung (Seminar) Gruppengröße: Standard Arbeitsaufwand: Kontaktzeit: 28 Zeitstunden Selbststudium: 62 Zeitstunden Leistungspunkte: 3 Turnus: Sommersemester, jährlich Teilnehmerzahl: Nicht begrenzt Anmeldungsmodalitäten: Anmeldung über den Moodle-Kurs zu diesem Modul', 'Vorlesungen, Übungen und Workshops zu den Themen:
• Erstellung eines Portfolios mit eigenen
Arbeitsproben
• Bewerbungsunterlagen, -training
• Existenzgründung und Entrepreneurship
• Formulieren eines Projektexposés
• Zeitmanagement, Kostenkalkulation und
Erstellen eines Projektplans
Nach Möglichkeit werden Praxispartner aus der
Industrie in die Veranstaltung eingeladen (Vorträge zu
Teilthemen, Einblick in Berufsalltag)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (4, 1, 'Die Studierenden können einfache interaktive
Anwendungen konzeptionell und technisch so erstellen,
dass Sie auf unterschiedlichen Plattformen (z.B.
Android, iOS, Web, Windows Desktop, VR) lauffähig
sind
indem Sie
• Die Trennung zwischen Anwendungslogik und
GUI am Beispiel konkreter
Entwicklungsumgebungen (z.B. Flutter, Xamarin,
React Native) verstehen und auf den praktischen
Einsatz transferieren.
• Entsprechende Design Patterns analysieren und
diskutieren können (z.B. MVVM)
• Grundlegende Vorkenntnisse zu Usability,
Layout und Gestaltung bei der Umsetzung von
Cross-Platform Anwendungen demonstrieren
• Auch über Geräteklassen hinweg Unterschiede
und Gemeinsamkeiten analysieren und deren
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 11 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Auswirkungen auf die Entwicklung einer
plattformübergreifenden Anwendung bewerten
Um später
• bei der Planung und Konzeption komplexerer
Anwendung von vorneherein unterschiedliche
Plattformen bedienen zu können
• In Projekten im Studium oder im Beruf tiefer in
die Thematik der Cross-Platform Entwicklung
einsteigen zu können und eigenständige, neue
Anwendungen entwerfen und implementieren zu
können.', '', 'Einführung in die plattformübergreifende Entwicklung
Einführung in aktuelle Frameworks, z.B. Flutter,
Xamarin, ReactNative mit Fokus auf eines, das dann im
Projekt genutzt wird sowie die zugrundeliegenden
Programmiersprachen (z.B. Dard, C#, Javascript).
Hierbei wird auch mit Hilfe von bereitgestellten
Materialien ein hoher Selbstlernanteil integriert.
Softwaretechnische Grundlagen für
plattformübergreifende Entwicklung, z.B. Design-
Patterns wie MVVM
In Projektgruppen wird das theoretisch erlernte Wissen
direkt im Rahmen eines realitätsnahen
Semesterprojekts oder mehreren
Vorlesungsbegleitetenden kleinen Projektaufgaben in
die Praxis überführt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (32, 1, 'Die Studierenden kennen die wichtigsten
Sprachelemente der Sprache Python.
Die Studierenden können zur Lösung vorgegebener
Aufgaben (ggf. aus dem Designing-Projekt heraus) in
der Sprache Python das 3D-Modellierungssystem
Blender um spezifische Funktionalität erweitern.
Damit sind die Studierenden später in der Lage, Python-
Programme auch für andere Aufgaben und Kontexte zu
schreiben. Zudem können die Studierenden Blender um
spezielle Features (geometrische Besonderheiten,
Automatismen) erweitern und die Erweiterungen über
die Blender-GUI zugänglich machen.', NULL, 'Eigenschaften und Elemente der Sprache Python, Verwendung von Python in Blender, Beispiele für in Python geschriebene Blender-Scripte. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (26, 1, 'Die Studierenden erwerben berufsorientierte
englischsprachige Diskurs- und Handlungskompetenz
unter Berücksichtigung (inter-)kultureller Elemente.', NULL, 'Die Veranstaltung führt in die Fachsprache anhand
ausgewählter Inhalte z.B. aus folgenden Bereichen ein:
AI (Artificial Intelligence), Basic Geometric and
Mathematical Terminology, Biometric Systems,
Diagrammatic Representation, Display Technology,
Networking, Online Security Threats, Robotics, SDLC
(Software Development Life Cycle).');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (5, 1, 'Die Studierenden kennen die Grundlagen von
Datenbanksystemen und deren Einsatz in der Praxis.
Die Studierenden kennen die wesentliche
Vorgehensweise und Methoden, um
Realweltausschnitte zu modellieren und in gut
strukturierte Datenbankschemata zu überführen.
Die Studierenden sind in der Lage, Informationssysteme
unter Einsatz von Datenbankprogrammierschnittstellen
und der Datenbanksprache SQL zu entwickeln und zu
optimieren.', NULL, 'Die Veranstaltung bietet einen Einstieg in
Datenbanksysteme und deren Anwendungen in der
Praxis. Der Inhalt der Vorlesungen, Übungen und
Praktika ist wie folgt strukturiert:
• Einführung in Datenbanksysteme
• Anwendungsfälle von Datenbanksystemen in der
Praxis
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 13 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• Das Datenbankmanagementsystem und seine
Komponenten
• Datenbankschemata und Konsistenzbedingungen
• Relationale Algebra
• Grundlagen SQL und SQL-Optimierung
• (Optional) XML
• (Optional) Ausblick auf nicht-relationale und
NOSQL Datenbanken
Übungen und Praktikum enthalten praktische
Aufgaben zum Datenbankdesign und der Anwendung
von SQL.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (7, 1, 'Die Studierenden kennen und verstehen den
Anwendungshintergrund der Extended Reality (XR). Sie
kennen die zentralen Begriffe, Konzepte Technologien
und Anwendungsfelder, können Beispiele nennen und
sie gegenseitig abgrenzen
Die Studierenden kennen und verstehen die zentralen
Methoden, Verfahren und wichtige Algorithmen aus der
Computergrafik inklusive grafischer Interaktion und der
Computeranimation als Grundlage der XR. Dieses
Wissen umfasst auch mathematisch-algorithmischen
Hintergrund sowie grundlegende Kenntnisse zu einigen
relevanten physikalische und physiologische Aspekten.
Die Studierenden können auf der Basis vorgegebener
Aufgabenstellungen einfache computergrafische
Berechnungen z.B. zu Transformationen, zur
Beleuchtung und Texturierung sowie zu zeitabhängigen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Funktionen der Computeranimation ausführen. Sie
finden zu gestellten Problemen eine angemessene
Methodik oder ein algorithmisches Verfahren zur
Lösung und können die Methodik oder das Verfahren
anwenden.
Die Studierenden können Konstellationen (z.B.
Geometrie, Material, Geräteauflösung) hinsichtlich
Qualität der Visualisierung, Rechengeschwindigkeit, der
Echtzeitfähigkeit oder für die Interaktion beurteilen. Sie
kennen relevante Sonderfälle.
Die Studierenden besitzen Basiswissen aus der
Medientechnik über Signale, über den Umgang mit
Audio- und Video-Material, zu Kompressionsverfahren
sowie über Geräte zur Visualisierung und zur Benutzer-
Eingabe (inkl. Tracking).
Die Studierenden besitzen die theoretischen
Kenntnisse, um im Rahmen der Projektmodule und
Learning Units des 4. und 5. Semesters sowie im
Rahmen ihrer Bachelorarbeit 3D-Modelle,
Computeranimationen, Computerspiele und XR-
Anwendungen auf der Basis von geeigneten
Werkzeugen konzipieren und implementieren zu
können.
Die Studierenden besitzen das theoretische Rückzeug,
um auch weiterführenden und vertiefenden Stoff z.B. in
einem Masterstudium bewältigen zu können und um
forschungsorientierte Arbeiten im Studium und Beruf auf
dem Gebiet XR durchführen zu können.', NULL, 'Einführung und Zentrale Konzepte: Extended Reality
(Virtual Reality, Augmented Reality, Mixed Reality,
Tracking), XR-Anwendungen und ihre Merkmale,
Basistechnologien 3D-Computergrafik,
Computeranimation, Medientechnik
Farbe und menschliche Wahrnehmungs-Aspekte
(Mach-Band-Effekt, Aliasing in Darstellungen und im
zeitlichen Verläufen, Wahrnehmung von Bewegung)
Konzept der Rendering-Pipeline und grafische
Interaktion: 3D-Modell und seine Bestandteile, Pipeline-
Stufen, Bilder und Pixel, Rückbeziehung von Benutzer-
Eingabe auf das 3D-Modell
Geometrische Modelle, insbesondere Polygone und
Mesh-Modelle (Vertex-Konzept, Flächen und Eckpunkt-
Normalen)
Transformationen und Transformationsmatrizen:
Homogene Koordinaten, Affine Abbildungen,
Translationen, Rotationen und Skalierungen zur
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 18 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Objektmanipulation, Koordinatentransformationen für
das Rendering und beim Tracking
Projektionen und Kameras: Perspektivische
Projektionen für realistische Darstellungen,
Parallelprojektion für die interaktive 3D-Modellierung,
Virtuelle Kamera, Ansichtspipeline
Beleuchtung: Lokale Beleuchtungsmodelle (Ambiente,
diffuse, Spekulare Reflexion), Shading, Prinzipien
globaler Beleuchtung (Allgemeine
Beleuchtungsgleichung, Raytracing, diffuse Verfahren)
Texturierung: Mapping-Verfahren, Blending
Interpolationsbasierte Animation: Frame-Konzept,
Interpolation von zeitabhängigen Werten entlang von
Linien, Kurven und Pfaden Keyframe-Animation
Physikalisch basierte Animation: Kinematik, Festkörper
(freier Fall, Kollisionen)
Animationstechniken: Kinematische Ketten und
Character-Animation, Vorwärts- und Rückwärts-
Kinematik, Motion Capture, Constraints
Signale, Audio, Video, Umgang mit Audio und Video-
Material, Pre- und Postproduction,
Kompressionsverfahren, Geräte zur Visualisierung
(Monitore, XR-Brillen), zur Benutzerinteraktion
(Controller), Tracking-Sensoren.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (8, 1, 'Die Studierenden können ein digitales interaktives
Produkt mit signifikantem Software-Anteil auf Basis
eines bekannten Problems planen und implementieren,
indem sie:
• Sich in einem Projektteam organisieren und
Methoden des agilen Projektmanagements
anwenden
• Im Studium erlernte Methoden, Konzepte und
Techniken kombinieren, arrangieren, modifizieren
und anwenden
• Mögliche Lösungsansätze (z.B. in der
wissenschaftlichen Fachliteratur oder
Entwicklerblogs etc.) prüfen, bewerten und
evaluieren
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 20 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• Methoden der mensch-zentrierten Entwicklung auf
die konkrete Projektstellung anpassen und
anwenden
• Komplexe Aufgaben sinnvoll strukturieren,
dekompilieren und entsprechend den individuellen
Fachkompetenzen als Team effizient bearbeiten
• Typische Schnittstellenprobleme in der
Abstimmung und Zusammenarbeit sowohl auf
technisch-fachlicher als auch auf sozialer Ebene
mit Hilfe von Projektmanagementmethoden
bewältigen
• Zwischenergebnisse dokumentieren und
präsentieren
• Fragen der ökologischen, ökonomischen und
sozialen Nachhaltigkeit und der gesellschaftlichen
Konsequenzen diskutieren und kritisieren
um später
• Die Kenntnisse und Kompetenzen verschiedener
Module in einem realistischen Projekt zu vertiefen
und zusammenzuführen.
• Über die reinen Fachkompetenzen hinaus
Erfahrungen und Herausforderungen bei der
Zusammenarbeit im Team über einen längeren
Zeitraum mit einer komplexen Aufgabe
kennenlernen und Lösungsstrategien entwickeln
zu können
• Verantwortungsvoll Software entwickeln, welche
die Prinzipien der ökologischen, ökonomischen
und sozialen Nachhaltigkeit berücksichtigt.', NULL, 'Im Rahmen des Großprojekts BUILDING bearbeiten die
Teilnehmer in Projektgruppen eine typische größere
Aufgabenstellung aus dem Bereich der Informatik und
Design mit Schwerpunkt BUILD, das heißt Entwicklung.
In der Regel wird ein Thema pro Semester angeboten.
Die Projektteams werden durch Mentoren bei der
Projektarbeit begleitet. In regelmäßigen
Projektsitzungen werden im Rahmen einer
Qualitätssicherung die Zwischenergebnisse von den
Teams durch Präsentation und Vorführung vorgestellt
und diskutiert.
Zudem belegen Studierende thematisch passende
Learning Units, die notwendige Fachkompetenzen
vermitteln.
Im Gegensatz zum Projekt DESIGNING wird hier eine
grundlegende Problemstellung bereits weitgehend
vorgegeben. Dennoch besteht ein hoher Freiheitsgrad
hinsichtlich der möglichen Lösungsansätze. Dies
umfasst die selbstständige Durchführung des Projekts,
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 21 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
inklusive Ableitung von User Stories, Prototyping, sowie
Realisierung/Implementierung und Test bis zur
Dokumentation. Im Idealfall baut das Projekt BUILDING
auf den Ergebnissen des DESIGNING Projekts auf und
kann auf diese Vorarbeiten zu Konzept und Design
zurückgreifen.
Anwendung von grundlegenden Projektmanagement-
Methoden für Definition, Planung, Kontrolle und
Realisierung des Projekts.
Entwicklung im Team unter Beteiligung von
realen/potentiellen Anwendern und Benutzern.
Das Projektthema wird rechtzeitig vor Beginn der
Veranstaltung bekannt gemacht. Es wird versucht,
praxisnahe Projekte auch von hochschulexternen
Anwendern im Bereich Informatik und Design zu
akquirieren.
Das Großprojekt BUILDING hat je nach Themenstellung
einen Schwerpunkt im Bereich der App-Entwicklung,
Cross-Platform Entwicklung, AR/VR Entwicklung unter
Berücksichtigung von Methoden der mensch-zentrierten
Entwicklung (z.B. Evaluation).');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (55, 1, 'Die/der Studierende ist in der Lage, innerhalb einer
vorgegebenen Frist eine praxisorientierte Aufgabe aus
der praktischen Informatik sowohl in ihren fachlichen
Einzelheiten als auch in ihren themen- und
fachübergreifenden Zusammenhängen nach
wissenschaftlichen und fachpraktischen Methoden
selbstständig zu bearbeiten und zu dokumentieren.', NULL, 'Es wird ein in der Regel praxisorientiertes Problem aus
der praktischen Informatik mit den im Studium erlernten
Konzepten, Verfahren und Methoden in begrenzter Zeit
unter Anleitung eines erfahrenen Betreuers gelöst.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (56, 1, 'Die Studierenden lernen die grundlegenden Konzepte
und Verfahren von Betriebssystemen kennen. Sie
erlangen die Fähigkeit, neue Betriebssystemkonzepte
schnell begreifen, einordnen und bewerten zu können.', NULL, 'Einführung in Betriebssysteme
Prozesse
Speicherverwaltung
Dateisystem
Ein-/Ausgabe
Unix');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (9, 1, 'Die Studierenden können ein digitales interaktives
Produkt von der Problemanalyse bis hin zu einem
erlebbaren Prototypen erschaffen,
indem sie:
• Sich in einem Projektteam organisieren und
Methoden des agilen Projektmanagements
anwenden
• Im Studium erlernte Methoden, Konzepte und
Techniken kombinieren, arrangieren, modifizieren
und anwenden
• Mögliche Lösungsansätze (z.B. in der
wissenschaftlichen Fachliteratur oder
Entwicklerblogs etc.) prüfen, bewerten und
evaluieren
• Methoden der mensch-zentrierten Entwicklung auf
die konkrete Projektstellung anpassen und
anwenden
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• Komplexe Aufgaben sinnvoll strukturieren,
dekompilieren und entsprechend den individuellen
Fachkompetenzen als Team effizient bearbeiten
• Typische Schnittstellenprobleme in der Abstimmung
und Zusammenarbeit sowohl auf technisch-
fachlicher als auch auf sozialer Ebene mit Hilfe von
Projektmanagementmethoden bewältigen
• Zwischenergebnisse dokumentieren und
präsentieren
um später
• Die Kenntnisse und Kompetenzen verschiedener
Module in einem realistischen Projekt zu vertiefen
und zusammenzuführen.
• Über die reinen Fachkompetenzen hinaus
Erfahrungen und Herausforderungen bei der
Zusammenarbeit im Team über einen längeren
Zeitraum mit einer komplexen Aufgabe
kennenlernen und Lösungsstrategien entwickeln zu
können', NULL, 'Im Rahmen des Großprojekts DESIGN bearbeiten die
Teilnehmer in Projektgruppen eine typische größere
Aufgabenstellung aus dem Bereich der Informatik und
Design mit Schwerpunkt Design.
In der Regel wird ein Thema pro Semester angeboten.
Die Projektteams werden durch Mentoren bei der
Projektarbeit begleitet. In regelmäßigen
Projektsitzungen werden im Rahmen einer
Qualitätssicherung die Zwischenergebnisse von den
Teams durch Präsentation und Vorführung vorgestellt
und diskutiert.
Zudem belegen Studierende thematisch passende
Learning Units, die notwendige Fachkompetenzen
vermitteln.
Selbstständige Durchführung des Projekts von der
Problemanalyse und Nutzerforschung hin zu
Ideenfindung, Konzepterstellung, Designentwürfe. Am
Ende steht ein erlebbarer Prototyp, welcher mit
verschiedenen Mitteln erreicht werden kann
(Prototyping Werkzeug, Video Envisionment,
Physischer Prototyp, etc.).
Anwendung von grundlegenden Projektmanagement-
Methoden für Definition, Planung, Kontrolle und
Realisierung des Projekts.
Insbesondere für die Nutzerforschung sollen
reale/potentielle Anwender und Benutzer beteiligt
werden.
Die Projektthemen werden rechtzeitig vor Beginn der
Veranstaltung bekannt gemacht. Es wird versucht,
praxisnahe Projekte auch von hochschulexternen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 24 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Anwendern im Bereich Informatik und Design zu
akquirieren.
Das Großprojekt DESIGNING hat je nach
Themenstellung einen Schwerpunkt im Bereich der
Analyse, Konzeption, UI-, Interface-Gestaltung oder der
Mensch-Computer-Interaktion, wird aber zumeist
Aspekte aus mehreren Gebieten beinhalten.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (10, 1, 'Die Studierenden reflektieren fachspezifische und
gesamtgesellschaftliche Entwicklungen und Trends mit
Blick in die nähere Zukunft und die eigene Rolle in
diesem Kontext. Aktuelle Fragestellen können in die
Veranstaltung eingebracht und bearbeitet werden.
• Indem eine Auseinandersetzung mit aktuellen
Technologien Tools, technischen Trends (Hard-
und Softwareseitig), aus den Disziplinen Informatik
und Design stattfindet.
• Indem aktuelle Veröffentlichungen und
Konferenzbeiträge recherchiert und diskutiert
werden.
• Indem die Themenbereiche durch Gastvorträge,
Konferenzbesuche, Expertengespräche
aufgegriffen und diskutiert werden.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 26 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• Indem die eigene Rolle und das individuelle
Handeln im späteren Berufskontext und zukünftigen
Arbeitswelt reflektiert werden.
Um später im Beruf die Auswirkungen von
Softwareentwicklung auf die ökologische, ökonomische
und gesellschaftliche Nachhaltigkeit bewerten und
reflektieren zu können.', NULL, 'Vorlesungen, Übungen und Workshops zu den Themen:
• relevante technische, gesellschaftliche,
ökologische, ökonomisch und ethische
Fragestellungen oder Dilemmata
• aktuelle fachspezifische Fragestellungen,
Forschungsergebnisse und Veröffentlichungen aus
der Informatik und dem Design bzw. das
Verknüpfen und Integrieren unterschiedlicher
fachspezifischen Perspektiven
Nach Möglichkeit werden Praxispartner aus der
Forschung oder Praxis in die Veranstaltung eingeladen
(Experten-Gespräche und/oder Ringvorlesungen)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (65, 1, 'Die Studierenden lernen die Begriffe und Verfahren der
digitalen Bildverarbeitung und die Konzepte und
Methoden deren Programmierung kennen. Sie können
diese effektiv und strukturiert bei der Entwicklung
eigener Bildverarbeitungsprogramme einsetzen. Neben
der Programmiermethodik lernen die Studierenden die
Verwendung von Bibliotheken (OpenCV, CNN‘s)
kennen und können diese für die Entwicklung eigener
Lösungen einsetzten.', NULL, '• Grundlagen / Begriffsbildung
• Kameras
• Bildverarbeitungsoperationen
• Bildsegmentierung
• Merkmale von Objekten
• Klassifikation
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 47 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• Neuronale Netze, CNNs
• Lehrsprachen: C / C++, Python, ipython notebooks');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (11, 1, 'Die Studierenden sind in der Lage, die Ergebnisse ihrer
Bachelorarbeit in Informatik und Design, ihre fachlichen
Grundlagen, und ihre Einordnung in den aktuellen
Stand der Technik, bzw. der Forschung, in einem
Vortrag zu präsentieren.
Darüber hinaus können die Studierenden Fragen zu
inhaltlichen Details, zu fachlichen Begründungen und
Methoden sowie zu inhaltlichen Zusammenhängen
zwischen Teilbereichen ihrer Arbeit selbstständig
beantworten und diese verteidigen.
Die Studierenden können ihre Bachelorarbeit auch im
Kontext beurteilen und ihre Bedeutung für die Praxis
und die Forschung einschätzen und sind in der Lage,
auch entsprechende Fragen nach themen- und
fachübergreifenden Zusammenhängen zu beantworten.', NULL, 'Zunächst wird der Inhalt der Bachelorarbeit aus
Informatik und Design im Rahmen eines Vortrags
präsentiert. Anschließend sollen in einer Diskussion
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 28 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Fragen zum Vortrag und zur Bachelorarbeit beantwortet
werden.
Die Prüfer können weitere Zuhörer zulassen. Diese
Zulassung kann sich nur auf den Vortrag, auf den
Vortrag und einen Teil der Diskussion oder auf das
gesamte Kolloquium zur Bachelorarbeit erstrecken.
Der Vortrag soll die Problemstellung der Bachelorarbeit,
den Stand der Technik bzw. Forschung, die erzielten
Ergebnisse zusammen mit einer abschließenden
Bewertung der Arbeit sowie einen Ausblick beinhalten.
Je nach Thema können weitere Anforderungen
hinzukommen.
Die Dauer des Kolloquiums ist in § 19 der
Prüfungsordnung geregelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (12, 1, 'Die Studierenden erkennen die grundlegende
Bedeutung von diskreten Strukturen für Analyse,
Darstellung und Lösung von Problemen in der
Informatik.
Sie beherrschen die elementaren automatisierten
Beweisverfahren der Logik und können diese
anwenden.
Sie kennen die grundlegenden Begrifflichkeiten der
Graphentheorie und können Probleme entsprechend
darstellen. Ausgewählte Problemstellungen können sie
lösen.
Sie kennen und beherrschen die Grundzüge der RSA-
Verschlüsselung (Zahlentheorie), von
Entscheidungsbäume und bayes’schem Schliessen
(Data Mining / Machine Learning).', NULL, 'Historischer Abriss zur Entwicklung und Bedeutung der
Logik für die Informatik (Frege, Russell, Hilbert, Gödel,
Turing, Post) und zu den Grenzen der Berechenbarkeit.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 30 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Exkurs: boole’sche Schaltkreise als Modell des
Berechnens (inkl. Ausblick auf Funktionen und Logik).
Grundlegende Begriffe und Konzepte der Mengenlehre
(u.a. Eigenschaften von Funktionen, Abzählbarkeit)
Logische Problemformulierung und Problemlösung
(Aussagenlogik und Klassenkalkül 4/5, Datalog 1/5)
Ausgewählte diskrete Strukturen und Probleme:
Zahlentheorie (RSA), Entscheidungsbäume, diskrete
Wahrscheinlichkeiten/Naive Bayes, Graphentheorie
(Wegfindung), Kombinatorik (kombinatorische
Explosion).
Aufwand: Historie (10%), Mengen und Logik (60%),
weitere diskrete Strukturen (30%)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (42, 1, 'Die Studierenden kennen und verstehen die wichtigen
Funktionen zum Erstellen von Computeranimationen auf
statischen 3D-Modellen mit dem Werkzeug Blender,
deren Konstruktion im Modul „3D-Modellierung“ erlernt
wurde.
Die Studierenden kennen und verstehen die
Zusammenhänge zwischen der Theorie über die
Grundlagen der Computeranimation aus dem Modul
„Extended Reality“ (Physiologische Faktoren,
Temporäres Aliasing, Interpolation, Vorwärts- und
Inverse Kinematik in der Character-Animation,
Constraints) und der Praxis einer Animationserstellung
in Blender.
Die Studierenden können Animationsentwürfe für 3D-
Modelle aus dem Designing-Projekt mit Hilfe der in ANI
erworbenen Kenntnisse und auf der Basis von Blender
als Computeranimationen umsetzen und in das Build-
Projekt integrieren. Alternativ oder ergänzend zu
Aufgaben aus dem Designing-Projekt können die
Studierenden vorgegebene Aufgaben zur Erstellung von
Computeranimationen mit dem Werkzeug Blender lösen
sowie ihre Vorgehensweise erklären und begründen.
Die Studierenden sind in der Lage, ihre Kenntnisse und
Fertigkeiten der Animations-Entwicklung im Hinblick auf
schwierigere Anforderungen und andere Werkzeuge im
weiteren Studium und im Beruf zu erweitern.', NULL, 'Überblick über die Funktionen zur Erstellung von Computeranimationen mit Blender unter Bezug zum Modul „Extended Reality“. Regeln und Prinzipien „handwerklich“ guter Computeranimationen Zentrale Konzepte und Funktionen zur Animationsentwicklung mit Blender - Keyframe-Animation: Timeline, Dope Sheet Editor, Graph Editor, Pfad-Animation');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (40, 1, 'WAS
Die Studierenden kennen und verstehen Mechanismen,
Konzepte und Einsatzmöglichkeiten von Bildern/Icons
und deren gestalterische Umsetzung und Aufbereitung
mit digitalen Mitteln.
WOMIT
• Indem Basiswissen zur Farbgestaltung und -
psychologie sowie Bildaufbau und -komposition
vermittelt wird.
• Indem Bildwelten und Entwurfsaufgaben im Bereich
Bildkonzeption und Bildgestaltung in Einzelarbeit
oder in der Gruppe erarbeitet und gestalterisch
umgesetzt werden.
• Indem Konzepte und Möglichkeiten der
gestalterischen Aufbereitung von Bildern vorgestellt
und erprobt werden.
• Indem praktische Fertigkeiten im Umgang mit der
Kamera (Fotografie) und Adobe Photoshop als
Entwurfstool erlangt werden.
WOZU
Bilder sind grundlegender Bestandteil in der Konzeption
und Entwicklung von Benutzerschnittstellen. Die
Grundprinzipien der Bildgestaltung können dem
Großprojekt Anwendung finden.', NULL, 'Farbe in der Gestaltung (Farbsysteme, Farbkomposition, Farbpsychologie etc.), Experimentelle Bildgestaltung, Bildkomposition, Bildgestaltung als Teil des Assetdesigns von Web-/Softwareprojekten (Bildkonzeption, Bildoptimierung, Freistellen, Bildrandgestaltung, Hintergrundbilder, Kachelbilder), Bildtypografie, Buttondesign, Icondesign, Infografik, Reportinggrafik, Bildkonzeption, Entwicklung von Bildwelten (Foto, Illustration oder Grafik) Die Studierenden führen in Hausarbeit Gestaltungsentwürfe zu vorgegebenen Aufgaben durch. Im Praktikum finden dazu individuelle Korrekturbesprechungen statt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (41, 1, 'WAS
Die Studierenden kennen und verstehen den Nutzen
von konsistenten Erscheinungsbildern in digitalen
Anwendungen und können die visuellen und
interaktiven Komponenten eines Corporate Designs
bewusst einsetzen.
WOMIT
• Indem Grundbegriffe, Bestandteile und Richtlinien
des Brand und Corporate Designs kennengelernt
und verstanden werden.
• Indem Praxisbeispiele im Bereich Brand Identity,
Markenarchitektur usw. analysiert, reflektiert und
eigene Lösungswege entwickelt werden.
WOZU
Einheitliche und konsistente Markenerlebnisse und
Nutzererfahrungen sind sehr zentral für den Erfolg von
Produkten, Services oder Devices und damit ein
wichtiger Baustein für das Projektstudium. Das Wissen
kann in Folgeveranstaltungen angewandt werden.', NULL, 'Fachbegriffe und Abgrenzung Corporate und Brand Identity/Design, Nutzen, Funktion und Qualitätsstandards, Corporate Design-Prozess, Markenbild/-wahrnehmung, Visuelle Codes und Interactive Branding Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (27, 1, 'Die Studierenden können moderne Cloud Plattformen
und Microservicearchitekturen für die Umsetzung von
webbasierten Anwendungen zielgerichtet adaptieren
und einsetzen
Indem sie
• Die Möglichkeiten und Herausforderungen von
Cloud Computing, Virtualisierung und
Containertechnologie und Microservices
diskutieren und analysieren
• In Kleingruppen anhand konkreter Vorgaben und
unter Anleitung beispielhaft diese Technologien
anwenden und deren Eignung Beurteilen
Um später / damit sie
• Im parallelen Großprojekt in der Lage sind,
Cloud Plattformtechnologien auszuwählen und
effektiv zu integrieren
• In späteren Projekten (z.B. Abschlussarbeit) und
im Beruf moderne und komplexe
Webanwendungen und Verknüpfungen zwischen
diesen realisieren zu können', NULL, '• Rückblick Computerarchitekturen und Internettechnologien • Cloud Architekturen und Plattformen • Hypervisor, Virtualization, Container (Hyper-V, VirtualBox, Docker) • Cluster Management (Kubernetes, Rancher) • Web Services, REST API, Microservices, Serverless Computing Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (43, 1, 'Die Studierenden kennen und verstehen die
grundlegenden Begriffe und Definitionen im Kontext von
Game, Play und Gamification. Sie können Beispiele
dazu nennen und beschreiben. Sie kennen wichtige
Klassifizierungen von Games und können Game-
Eigenschaften den Klassen zuordnen.
Die Studierenden kennen die wichtigen Elemente von
Games und verstehen deren Bedeutung. Sie kennen die
wichtigsten Spielmechaniken. Sie sind in der Lage,
existierende Spiele hinsichtlich der Elemente und
Mechaniken zu analysieren.
Die Studierenden kennen eine Klassifizierung von
Spielertypen. Sie besitzen ein grundlegendes
Verständnis für wichtige psychologische Faktoren. Sie
können dieses Wissen auf Game-Klassen und Game-
Elemente beziehen.
Die Studierenden kennen wichtige Probleme, die durch
Gaming bei Benutzern entstehen können.
Die Studierenden sind in der Lage, Game-Elemente für
das Designing-Projekt mit den in der Learning Unit
erlernten Methoden zu entwerfen und im Projekt
konzeptuell einzubetten. Dies kann in Form einfacher
Entwürfe für Spielmechaniken, zur Gamifizierung oder
einfacher Spiele (Mini-Spiele, Quizzes) erfolgen.', NULL, 'Begriffe, Definitionen und Beispiele für Games, Play und Gamification. Klassifizierungen von Games (z.B. nach Genres, nach eingesetzten Ein-/Ausgabe- und Visualisierungstechnologien, Single- und Multiplayer) Elemente von Games und Spielmechaniken (z.B. Spielziel, Regeln auf unterschiedlichen Ebenen, Konflikt und Kooperation, Belohnungsstrukturen, Feedback, Levels)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (28, 1, 'Die Studierenden können einfache Spezialeffekte
angefangen von z.B. speziellen Lichteffekten oder
Oberflächen-Texturierungen bis hin zu dynamischen
Effekten wie Wasser mithilfe von Shadern
programmieren und in Unreal-Modelle importieren.
Die Studierenden sind damit in der Lage, einfache
Anforderungen nach Spezialeffekten aus dem
Designing-Projekt im Build-Projekt umzusetzen.', NULL, 'Fragment-(Pixel-)Shader, Vertex-Shader, Geometry- Shader, eine Shader-Sprache wie z.B. GLSL oder HLSL Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (44, 1, 'WAS
Die Studierenden verfügen über theoretisches Wissen
und praktische Fertigkeiten, um Informationen visuell
leicht verständlich aufzubereiten. Sie sind in der Lage,
Daten und Zusammenhänge zu abstrahieren und zu
visualisieren, sie unter Berücksichtigung der jeweiligen
Zielgruppe und des Kommunikationszusammenhangs
darzustellen.
WOMIT
• Indem sie aktuelle (Multimedia-/Visualisierungs-)
Techniken kennen und verstehen
• Indem sie Kommunikationsprozesse in analogen,
audiovisuellen und digitalen Medien, wie
Erklärfilmen, Infografiken und Illustrationen planen
und optimieren.
• Indem sie erproben, Inhalte verständlich
aufzubereiten und benutzerfreundlich zu gestalten
WOZU
Die Fähigkeit zur Visualisierung von
Benutzerschnittstellen kann in Folgeveranstaltungen
angewandt werden.', NULL, 'verständlich aufzubereiten und benutzerfreundlich zu gestalten WOZU Die Fähigkeit zur Visualisierung von Benutzerschnittstellen kann in Folgeveranstaltungen angewandt werden. Inhalt: Wahrnehmungspsychologie, Visuelle Kommunikation, Informationsdesign/Informationsvisualisierung, Datendimensionen, Diagramme, Leitsysteme, Visualisierungstechniken, Technische Illustration, Multimediale Werkzeuge aus dem Kommunikations- und Webdesign. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (45, 1, 'Die Studierenden können Prototyping Werkzeuge und
Methoden für Interaktive Anwendungen analysieren,
vergleichen und hinsichtlich ihrer Eignung für
unterschiedliche Fragestellungen bewerten
indem Sie
• Verschiedene Arten und Ausprägungen von
Prototypen in der
Softwareentwicklung/Interaktionsdesign
begreifen
• Anhand vorgegebener Aufgabenstellungen
verschiedene Werkzeuge und Methoden
ausprobieren und deren Eignung beurteilen
• Die Möglichkeiten und Restriktionen der
Werkzeuge und Methoden gegenseitig
präsentieren und kritisieren
Um später / damit sie…
• Im parallelen Großprojekt in der Lage sind,
Prototyping Werkzeuge und Methoden
auszuwählen und zielführend einzusetzen
• Diese Kompetenz im Rahmen von
Softwareentwicklungsprojekten einsetzen
können, um frühzeitig Design-Iterationen
anzustoßen.', NULL, 'Es werden zunächst verschiedene Methoden des Prototyping vorgestellt, beispielsweise high- vs. low- fidelity Prototypen, Manifestations und Filter, Vertical und Horizontal, Interactive und Static. Anschließend werde passende Werkzeuge in Kleingruppen untersucht und für konkrete Aufgabenstellungen angewendet. Beispielsweise Prototyping Tools wie Figma, aber auch Video Envisonment durch ensprechende Videoproduktion. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (51, 1, 'Die Studierenden kennen den User Experience
Workflow und die Grundlagen der Gestaltung von
grafischen Benutzeroberflächen und können die
entsprechenden Methoden und Werkzeuge
projektbezogen auswählen auf verschiedene Kontexte
anwenden.
Indem sie Grundlagenwissen zur Usability und User
Experience sowie zum User Interface Design
kennenlernen. Dazu gehört die Analyse der
Nutzer:innen, die Erstellung von Wireframes und
Prototypen und das Testen mit den jeweiligen
Nutzer:innengruppen. Ein weiterer Fokus liegt in der
Konzeption und der Gestaltung von mobilen
Anwendungen und den komplexen, responsiven
Screendesigns für gängige Ausgabemedien (Desktop,
Tablet, Smartphone und Smartwatch) mit einem
Prototypingtool wie Adobe XD, Sketch oder Figma.
Um später unterschiedliche Benutzeroberflächen an
verschiedene Schnittstellen und Zusammenhängen
nutzer:innenzentriert entwickeln und testen zu können.', NULL, 'Einführung User Experience und User Interface Design (UX Design Prozess und Workflows), User Research (z. B. Interviewtechniken), Analysetechniken (Nutzer:innen Ziele/Bedürfnisse, Personas, Journey Maps), Struktur/Navigation (User Flows, Informationsarchitektur), Interaktions Design, Designprinzipien und -patterns, Mobile UX, Interaktive Prototypen. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (46, 1, 'Die Studierenden kennen und verstehen die wichtigen
Funktionen zum Entwurf, zur interaktiven Konstruktion
und zur Generierung von Spiele-Welten auf der Basis
einer Game Engine wie Unreal.
Die Studierenden können vorgegebene Aufgaben (ggf.
mit Bezug zum Designing-Projekt) zur Erstellung von
Game Leveln mit der Unreal Engine lösen sowie ihre
Vorgehensweise erklären und begründen.
Damit sind die Studierenden später in der Lage, die
Umgebung für ein Gameplay, das im Rahmen des
Designing-Projekts oder in einem anderen Kontext
entworfen wurde, z.B. für das Build-Projekt spielbar zu
gestalten und umzusetzen.Die Studierenden können.', NULL, 'Überblick über die Unreal-Modellierungsfunktionalität zur interaktiven Level-Erstellung sowie zur Generierung von Leveln. Themen können sein: Verschiedene Arten von Content, Karten (Maps), Height Maps, Outdoor- und Indoor-Design, Strategien von Content-Generierung. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (39, 1, 'Die Studierenden kennen die wichtigsten 3D-Modellierer
am Markt und deren Haupt-Unterschiede.
Die Studierenden kennen und verstehen die wichtigen
Funktionen zum Konstruieren und Erweitern von
statischen 3D-Modellen auf der Basis eines GUI-
basierten Werkzeugs wie Blender.
Die Studierenden kennen und verstehen die
Zusammenhänge zwischen der Theorie über die
Grundlagen der Computergrafik aus dem Modul
„Extended Reality“ (Geometrische Modelle,
Transformationen, Beleuchtung, Texturierung) und der
Praxis einer 3D-Modellierung in Blender.
Die Studierenden können vorgegebene Aufgaben (ggf.
mit Bezug zum Designing-Projekt) zur Konstruktion von
3D-Modellen mit dem Werkzeug Blender lösen sowie
ihre Vorgehensweise erklären und begründen. Damit
sind sie in der Lage, im weiteren Studienverlauf und im
Beruf die häufige Anforderung nach benötigten 3D-
Modellen (oft in Form einfacher Assets) durch
Neumodellierung oder über die Anpassung schon
vorhandener importierter Modelle und Assets erfüllen zu
können.', NULL, 'Wichtige Funktionen der interaktiven 3D-Modellierung unter Bezug zum Modul „Extended Reality“. Überblick über die wichtigsten Werkzeuge am Markt (z.B. Maya, 3ds MAX, Cinema4D) und Vergleich wichtiger Eigenschaften. Überblick über die Blender-Modellierungsfunktionalität Zentrale Konzepte und Funktionen zur 3D-Modellierung mit Blender - Blender-GUI: Elemente, Properties, User- Preferences, Navigation - Grundschritte: Objektvorbereitung, Materialien einstellen, Szene beleuchten, Rendern');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (30, 1, 'Die Studierenden können NOSQL Datenbanken im
konkreten Kontext interaktiver, medienlastiger
Anwendungen auswählen, adaptieren und einsetzen
Indem sie…
• Die Möglichkeiten und Herausforderungen von
NOSQL Datenbanken verstehen und gegenüber
klassischen relationalen Datenbanken abgrenzen
können
• In Kleingruppen anhand konkreter Vorgaben und
unter Anleitung beispielhaft diese Technologien
(z.B. MongoDB) anwenden und deren Eignung
beurteilen.
Um später…
• Im parallelen Großprojekt in der Lage sind,
passende Datenbanktechnologie auszuwählen und
effektiv zu integrieren.
• In späteren Projekten (z.B. Abschlussarbeit) und im
Beruf moderne und komplexe interaktive
Anwendungen in 2D und 3D auf Eben der
Datenbank konzipieren und verstehen zu können.', NULL, '• Überblick nicht-relationale / NOSQL Datenbanken und deren Anfragesprachen. • Vor- und Nachteile der verschiedenen Formate . • Die Rolle von NOSQL Datenbanken bei der Entwicklung und dem Betrieb von interaktiven Anwendungen. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (47, 1, 'Die Studierenden können verschiedene Methoden der
Nutzerforschung vergleichen, praktizieren und kritisieren
indem Sie
• Für eine definierte Problemstellung geeignete
Methoden der Nutzerforschung auswählen
• Die entsprechende Datenerhebung vorbereiten
und beispielhaft durchführen
• Die gesammelten Daten transkribieren und in
entsprechende Design Informing Models
überführen
• Vor- und Nachteile der verschiedenen Methoden
in der Gruppe vorstellen und diskutieren
Um später
• Im parallelen Großprojekt Nutzerforschung
selbstständig konzipieren, durchführen und
analysieren zu können
• Im Beruf die Schnittstellenkompetenz aufweisen,
mit Spezialisten für Nutzerforschung
zusammenarbeiten zu können', NULL, 'Angelehnt an das parallel stattfindende Großprojekt wird eine Auswahl an Methoden der Nutzerforschung zunächst vorgestellt und anschließend durch die Studierenden seminaristisch analysiert, aufbereitet und eine beispielhafte Anwendung der Methoden konzipiert. In Kleingruppen erfolgt die praktische Anwendung und anschließende Diskussion und Analyse. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (48, 1, 'Die Studierenden kennen die gesamte Breite moderner
Methoden und Instrumente der Projektplanung und
Projektsteuerung in der Informatik mit agilen Prozessen
und können diese recherchieren, vergleichen und für
einen passenden Kontext auswählen/anwenden.
Indem Sie:
• Moderne Methoden und Instrumente der
Projektplanung und –steuerung kennen und
verstehen
• Erfolgsfaktoren und Hindernisse erfolgreicher
Teamarbeit kennenlernen und in zukünftigen
Projekten berücksichtigen können
• Einzelne Vorgehensweisen und Tools im
Bereich Projektmanagement an einem konkreten
Beispiel anwenden und reflektieren.
Um später:
• Für das Großprojekt relevante Methoden und
Instrumente zur Strukturierung und Steuerung
von Projekten anwenden und Ergebnisse
präsentieren zu können
• in kleinen Teams ergebnisorientiert zu arbeiten
und Konflikte in Projekten konstruktiv zu lösen
• sich in Teams mit Mitgliedern unterschiedlichen
Alters und unterschiedlicher Hintergründe
zurecht zu finden
• In der Lage zu sein, innerhalb eines
vorgegebenen Zeitrahmen ein abgegrenztes
Projekt planerisch umzusetzen.', NULL, 'Theoretische Grundlagen des Projektmanagements/ Projektdefinition und Projektstrukturierung werden vermittelt und gehen einher mit der praktischen Anwendung grundlegender Projektmanagement- Methoden für Definition, Planung, Kontrolle und');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (49, 1, 'WAS
Die Studierenden kennen und verstehen globales,
barrierefreies Design, das kulturelle Unterschiede und
die Konzepte der inklusiven Gestaltung berücksichtigt.
WOMIT
• Indem Grundbegriffe, Richtlinien und Normen der
interkulturellen und barrierefreien Gestaltung
kennengelernt und verstanden werden.
• Indem Fallbeispiele verschiedener Kontinente
analysiert und bewertet werden.
• Indem Fallbeispiele hinsichtlich der Konzepte des
Universal Designs/Design für Alle analysiert und
bewertet werden.
• Indem Methoden der transdisziplinären Forschung
(Human Centered Design, Service Design,
Transformation Design) am praktischen Beispiel
angewandt werden.
• Indem soziale und nachhaltige Fragestellungen im
Kontext von digitalen Anwendungen reflektiert
werden.
WOZU
Die Wirkung und Verschiedenartigkeit von Design in der
globalisierten Welt und die Wichtigkeit von
kultursensibler und inklusiver Gestaltung ist Ziel der
Veranstaltung. Vor dem Hintergrund internationaler
Zusammenarbeit mit interkulturell besetzten Teams ist
die Entwicklung eines soziokulturellen Bewusstseins,
das zu unterscheidbaren Designstilen und zur
Wertschätzung von Diversität und Gemeinsamkeiten
führt.', NULL, 'Prinzipien und Normen der barrierefreien, inklusiven Gestaltung, Gestaltungsgrundlagen (wie Wahrnehmung, Komposition, Typografie und Farbe) und Nutzungskontexte hinsichtlich interkultureller Unterschiede, Methoden des Human Centered Designs. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (33, 1, 'Die Studierenden können für ausgewählte Cross-
Platform Frameworks, wie z.B. ReactNative
Testverfahren wie Unit-Tests konzeptionell planen und
implementieren.
Indem sie
• Die grundlegenden Ansätze verschiedener
Testverfahren kennen, unterscheiden und
diskutieren
• An ausgewählten Beispielen konkrete
Implementierungen durchführen
• Ein Konzept für die Integration von
Testverfahren in das parallel stattfindenden
Building Projekt entwerfen und diskutieren
Um später
Schon in frühen Stadien Softwarearchitektur auch
hinsichtlich des notwendigen Testkonzepts zu
durchdenken und entsprechende Tests selbst zu
integrieren oder im Entwicklungsteam unterstützen zu
können.', NULL, 'Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (34, 1, 'Die Studierenden kennen grundlegende Fakten über die
Spiele-Industrie und über die professionelle Entwicklung
von Computerspielen. Sie kennen und verstehen die
wichtigsten Stufen im Entwicklungsprozess sowie die
Rollen der unterschiedlichen an einer Entwicklung
beteiligten Personen.
Die Studierenden können einfache Game-Designs, die
sie im Modul „Game-Design und Gamification“
entworfen haben, mit Hilfe von Visueller
Programmierung mit Blueprints auf Basis der Unreal
Engine umsetzen und in das Build-Projekt integrieren.
Die Studierenden sind in der Lage, ihre Kenntnisse und
Fertigkeiten der Spiele-Entwicklung im Hinblick auf
schwierigere Anforderungen, komplexere Applikationen
und andere Werkzeuge im weiteren Studium und im
Beruf zu erweitern.', NULL, '• Fakten zur Spiele-Industrie: Große Hersteller, Umsätze, Game-Engines • Professionelle Entwicklung von Spielen: Entwicklungs-Methodik, Entwicklungsprozess inkl. Teststrategien, Entwickler-Rollen • Umsetzung von Spiel-Elementen mit Unreal • Modellierung von Game Levels; Import von Assets in Unreal • Implementierung einer Spiele-Logik • Player-Perspektiven (First-Person, Third-Person), Kameras, Integration von Mitspielern • Integration von Non-Player-Characteren (NPCs) • Simulation pysikalischer Effekte in Unreal');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (50, 1, 'WAS
Die Studierenden kennen und verstehen in welchen
Kontexten Storytelling eingesetzt werden kann und sind
in der Lage auf Basis von Charakteren eine eigene
Geschichte zu entwickeln und visualisieren.
WOMIT
• Indem der Aufbau von Geschichten und
Mechanismen und Vorgehensweisen des
Storytellings vermittelt werden.
• Indem eigenständig Charaktere vor dem
Hintergrund einer Geschichte erarbeitet werden.
• Indem aus nachvollziehbaren Erzählsträngen
Storyboards erstellt werden.
• Indem Grundlagen der Visualisierung
kennengelernt und erprobt werden (Storyboard-
Gestaltung in 2D oder 3D).
• Indem Geschichten visuell umgesetzt werden und
als statische Umsetzung oder Bewegtbild-Beitrag
für digitale Produkte
WOZU
Storytelling ist ein Prinzip, um Inhalte in Präsentationen,
Web-/Appangeboten, Bewegtbild, Animationen usw.
spannungsvoll zu vermitteln. Das Wissen kann in
Folgeveranstaltungen angewandt werden.', NULL, 'in Präsentationen, Web-/Appangeboten, Bewegtbild, Animationen usw. spannungsvoll zu vermitteln. Das Wissen kann in Folgeveranstaltungen angewandt werden. Inhalt: Arten von Geschichten, Aufbau einer Geschichte, Storytelling in unterschiedlichen Kontexten, von der Idee zum Charakter zur Geschichte zum Bild, Erzähl- und Darstellungsformen, Storyboard-Aufbau und Besonderheiten in der Gestaltung, Visualisierungs- und Darstellungstechniken. Die Studierenden führen in Hausarbeit Gestaltungsentwürfe zu vorgegebenen Aufgaben durch. Im Praktikum finden dazu individuelle Korrekturbesprechungen statt. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (35, 1, 'Die Studierenden können verschiedene Methoden zur
Durchführung und Analyse von Usability Tests
vergleichen, praktizieren und kritisieren.
indem Sie
• Für eine definierte Problemstellung geeignete
Usability Test Methoden auswählen
• Einen konkreten Usability Test planen und
hierfür geeignete Methoden kombinieren und
anpassen
• Beispielhaft einen Usability Test durchführen
• Die gesammelten Daten transkribieren,
analysieren und Usability Probleme identifizieren
• Vor- und Nachteile der verschiedenen Methoden
in der Gruppe vorstellen und diskutieren
Um später
• Im parallelen Großprojekt Usability Tests
selbstständig konzipieren, durchführen und
analysieren zu können
• Im Beruf die Schnittstellenkompetenz aufweisen,
mit Spezialisten für Usability Tests
zusammenarbeiten zu können oder diese
selbstständig planen, konzipieren und
durchführen zu können.', NULL, 'Angelehnt an das parallel stattfindende Großprojekt wird eine Auswahl an Methoden zur Durchführung und Analyse von Usability Tests zunächst vorgestellt und anschließend durch die Studierenden seminaristisch analysiert, aufbereitet und eine beispielhafte Anwendung der Methoden konzipiert. In Kleingruppen erfolgt die praktische Anwendung und anschließende Diskussion und Analyse. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (36, 1, 'Die Studierenden kennen und verstehen das
Grundkonzept der Visuellen Programmierung. Sie
kennen die Unterschiede und die Vor- und Nachteile im
Vergleich zum konventionellen Programmieren. Sie
kennen die Haupteigenschaften einiger
unterschiedlicher visueller Beschreibungs- und
Programmiersprachen und die jeweiigen
Ausdrucksmöglichkeiten im Hinblick auf zu
programmierende Problemstellungen.
Die Studierenden können vorgegebene Aufgaben zu
einfachen und in Games häufig umzusetzenden
Elementen mit Unreal-Blueprints implementieren und
ihre Lösungen erklären und begründen. Damit sind sie
in der Lage, die Learning Unit „Spiele-Entwicklung mit
3D-Game-Engines“ erfolgreich absolvieren zu können.', NULL, 'Einführung in die Visuelle Programmierung, Unterschiede zur textuellen Programmierung Visuelle Modellier- und Programmiersprachen (Scratch, LabVIEW, SIMULINK) und ihre Haupteigenschaften Blueprint Editor und Überblick über Unreal Blueprints Zentrale Blueprint Konzepte und Elemente • Actors, ihre Manipulation und Actor-Klassen • Event-Graph • Game-Projekt, Game Mode • Pawn-Klassen • Input Aktionen des Spielers • Kamera • Line Traces und Kollision • Timers, Spawning Actors Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (52, 1, 'Die Studierenden können ihre (Projekt-)Arbeiten in
Form von Kurzvideos bzw. Filmbeiträgen präsentieren
und dokumentieren, in dem sie vorhandenes
Filmmaterial sichten, auswählen und bearbeiten sowie
letztendlich einen vollständigen Videobeitrag mit Ton
und Sound-Effekten/Musik veröffentlichen.
Indem sie (bereits konzipiertes und erstelltes)
Filmmaterial weiterbearbeiten, Vorgehensweisen zum
Videoschnitt, Sound Design oder der Nutzung
lizenzfreier Musik, Motion Design und Visuellen Effekten
Farbkorrektur und Color-Grading, Mastering, Export,
Archivierung kennenlernen und anwenden können.
Um später Konzeptstudien und Studienarbeiten so
aufzubereiten, dass Idee und Umsetzung von Projekten
kompakt visuell erklärbar sind, ohne umfangreiche
Aufbauten mit Hard- und Software vornehmen zu
müssen. Die Videobeiträge können langfristig
(unabhängig von System- und Softwareupdates) für das
eigene Portfolio, Tagungen und Präsentationen genutzt
werden.', NULL, 'Erfassen des Videomaterials und Auswahl von Bildfolgen für den Grobschnitt, ggf. Konzeptentwicklung anhand des vorliegenden Materials, Sounddesign oder Musikauswahl, hinzufügen von Soundeffekten und Abstimmung auf den Schnitt, die Dramaturgie und die Videolänge, Motion Design, Visuelle Effekte – Animation für das Video, wie Logo- oder Titelanimationen sowie Bildretuschen, Durchführung von Farbkorrekturen und Color Grading, zur Vereinheitlichung und Anpassung des Videomaterials an die gewünschten Stimmung sowie Vorbereitung der Veröffentlichung (Auflösung, Videoformate) durch Mastering, Export und Archivierung. Einführung in notwendige Software und Tools. Die genaue Fokussierung und');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (37, 1, 'Die Studierenden können einfache Webanwendungen
mit modernen Frameworks entwerfen, implementieren
und in einer Client/Server Architektur aufsetzen,
indem Sie
• Die grundlegenden Technologien für Client- und
serverseitige Web Anwendungen analysieren,
diskutieren und bewerten
• In Kleingruppen anhand konkreter Vorgaben und
unter Anleitung beispielhaft Webanwendungen
in all ihren Teilaspekten umsetzen
• Zugrundeliegende Entwurfsprinzipien und
Architekturdesigns verstehen und anwenden
• Ansätze für weiterführende Technologien für
Cloud Computing wiedergeben
Um später / damit sie…
• Im Großprojekt entsprechende Werkzeuge
zielgerichtet einsetzen können und sich
weiterführende Kenntnisse und Kompetenzen
hierzu selbst aneignen können
• In späteren Projekten (z.B. Abschlussarbeit) und
im Beruf Web Technologien auswählen und
implementieren zu können', 'hierzu selbst aneignen können • In späteren Projekten (z.B. Abschlussarbeit) und im Beruf Web Technologien auswählen und implementieren zu können', 'Es erfolgt zunächst eine kurze Einführung in grundlegende relevanter WWW Technologien (z.B. HTML, JavaScript, Ajax, Bootstrap, AJAX, PHP, REST). Anschließend werden in Kleingruppen zum Teil auch unterschiedliche Technologien genutzt um beispielhaft an einer Aufgabenstellung den Einsatz der Technologien kennenzulernen und die Limitationen und Möglichkeiten besser einschätzen zu können. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (53, 1, 'WAS
Die Studierenden können einen thematisch
vorgegebenen funktionstüchtigen Website-Prototypen
gestalterisch und funktionell/interaktiv entwickeln.
WOMIT
• Indem Grundlagen des Webdesigns und der
interaktiven Gestaltung vermittelt werden.
• Indem eine Analyse durchgeführt und ein Konzept
hinsichtlich Zielsetzung, Zweck, Zielgruppe,
Nutzer:innenerwartung, Tonalität, Struktur und
Navigation usw. entwickelt wird.
• Indem eine individuelle Gestaltung der Website
erarbeitet und mit einem Prototyping-Tool (z. B.
Adobe XD) inkl. Funktionalitäten umgesetzt wird.
WOZU
Die Fähigkeit zur Visualisierung von
Benutzerschnittstellen und Erstellung von Prototypen ist
zentrale Kompetenz im Studiengang und kann in
Folgeveranstaltungen angewandt werden.', NULL, '• Einführung in ein Prototyping-Tool und ein Content- Management-System (z. B. Adobe XD und WordPress) • Festlegung Projekt-/Zeitplanung & Arbeitspakete • Konkurrenzanalyse und Nutzungskontext, Zielgruppenbeschreibung (anhand von Personas) und Contentanalyse • Konzeptentwicklung, Festlegung Task- Flows/Sitestruktur und Interaktionsdesign • UI-Design-Entwicklung und Styleguide (ggf. inkl. Bildwelt) • Entwicklung eines ein individuellen Screendesigns als Entwurf oder ausgearbeiteter Gruppenentwurf, Darstellung als klickbarer Prototyp Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (54, 1, 'Die Studierenden können für eine aktuelle
wissenschaftliche Fragestellung untersuchen,
recherchieren und zusammenfassen
Indem Sie:
• Relevante wissenschaftliche Suchsysteme (z.B.
ACM, IEEE aber auch Google Scholar)
zielführend bedienen.
• Wissenschaftliche Arbeiten lesen und deren
Struktur und Schematik verstehen.
• Zentrale Kernpunkte wissenschaftlicher Arbeiten
extrahieren und mit anderen Arbeiten
kontrastieren
Um später:
• Für das Großprojekt relevante wissenschaftliche
Vorarbeiten oder Lösungsansätze in der
Literatur zu identifizieren
• Die Grundlagen wissenschaftlichen Arbeitens in
komplexere Wissenschaftsvorhaben (z.B.
Abschlussarbeiten) integrieren zu können.', NULL, 'Theoretische Grundlagen wissenschaftlichen Arbeitens werden vermittelt und gehen einher mit der praktischen Anwendung an einer durch das Großprojekt geprägten Themenstellung.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (38, 1, 'Die Studierenden kennen und verstehen die
Funktionsweise wichtiger XR-Geräte. Sie haben ein
grundlegendes Verständnis auch von deren
physikalischer Basis. Sie kennen wichtige
Leistungsparameter der einzelnen Geräteklassen.
Die Studierenden können die Zusammenhänge
zwischen der Theorie (insbes. Computergrafik und
Medientechnik) aus dem Modul „Extended Reality“ und
der Praxis einer XR-Entwicklung in Unreal herstellen.
Die Studierenden können einfache XR-Anforderungen
aus dem Designing-Projekt mit Hilfe der in XRG
erworbenen Kenntnisse und auf der Basis von Unreal
Blueprints implementieren und in das Build-Projekt
integrieren. Alternativ oder ergänzend zu Aufgaben aus
dem Designing-Projekt können die Studierenden
vorgegebene Aufgaben zur Erstellung von XR-
Anwendungen mit dem Werkzeug Unreal
implementieren sowie ihre Vorgehensweise erklären
und begründen.
Die Studierenden sind in der Lage, ihre Kenntnisse und
Fertigkeiten der XR-Entwicklung im Hinblick auf
schwierigere Anforderungen und andere Werkzeuge im
weiteren Studium und im Beruf zu erweitern.', NULL, '• Einführung: Sensoren, insbesondere Tiefensensoren, Aktoren, XR mit Smartphones • Ausgabetechnologie: Datenbrillen und Augmented- Reality-Brillen, Mixel-Reality-Brillen, Virtual-Reality- Brillen • Eingabetechnologie: Controller, Motion Capture Systeme, Tracking-Technologie, Sonstige Eingabegeräte • Programmierung einer kleinen XR-Anwendung mit der Unreal Engine');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (13, 1, '• Die Studierenden können einfache grafische
Benutzeroberflächen mit einer aktuellen
Programmiersprache für interaktive Anwendungen,
z.B. JavaFX implementieren,
o indem sie Komponenten zur Ein- und Ausgabe,
Ereignisbehandlung, Layouterzeugung,
Benutzerführung und Eingabeprüfungen
differenziert auswählen, programmatisch
verstehen und zusammenführen,
o um später diese Aspekte sowohl in komplexere
Anwendungen angepasst integrieren zu können
als auch auf andere Programmiersprachen
transferieren zu können.
• Die Studierenden können einfache
Benutzeroberflächen gestalten und kritisieren,
o indem Sie Grundlagen und Normen zur
menschlichen Wahrnehmung und Kognition mit
Grundsätzen und Normen der
Interaktionsgestaltung, Usability, User
Experience und weiteren Designprinzipien
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 32 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
verbinden und mit Möglichkeiten der Ein- und
Ausgabetechnologie zusammenführen,
o um später konzeptionell bei der Gestaltung oder
Evaluation von Benutzerobflächen Usability
Probleme bewerten und letztlich vermeiden oder
entdecken zu können.
• Die Studierenden können die Phasen mensch-
zentrierter Entwicklung auf definierte
Problemstellungen anwenden
o Indem Sie sie hierfür notwendige zentrale
Methoden auswählen, diskutieren und
differenzieren können,
o Um später diese in eigens definierte
Problemstellungen einführen und adaptieren zu
können.', NULL, '• Grundlagen mensch-zentrierter Entwicklung
sowie die hierfür zentralen verschiedenen
Phasen und Methoden.
• Theoretische Grundlagen: Sensorische
Wahrnehmung, Mentale Modelle und
Metaphern, Handlungsebenen und Modelle der
Interaktion.
• Interaktionsstile, Interaktionstechnologien und
Interaktionsprinzipien.
• Benutzerführung, Meldungen und Prüfung von
Eingaben.
• Barrierefreiheit
• Grundlagen für die Programmierung von
grafischen Benutzeroberflächen, insbesondere
Ereignisbehandlung, Layout Komponenten,
Interaktionselemente, Meldungen und
Fehlerbehandlung.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (14, 1, 'Die Studierenden kennen und verstehen grundlegende
Begriffe der Mathematik, insbesondere der Analysis,
und deren Bedeutung in der Informatik. Sie können
Rechentechniken von Hand und anhand einfacher
Programmierung (Python) anwenden und einfache
mathematische Modelle erstellen, interpretieren und
anwenden.', NULL, '• Zahlen: Zahlenräume der Mathematik und
Zahlendarstellung im Rechner
• Folgen: rekursiv und explizit definierte Folgen,
vollständige Induktion, Grenzwertbestimmung,
Konvergenzgeschwindigkeit
• Funktionen: wichtige Modellfunktionen,
Eigenschaften von Funktionen (Stetigkeit,
Differenzierbarkeit, Krümmungsverhalten,
Grenzwerte) und deren Bedeutung im Kontext von
Modellbildung und Informatik), Taylorpolynome,
Splines, exakte und numerische Integration
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 34 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• Ausblick auf Anwendungen einfacher
mathematischer Modelle in der Informatik');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (15, 1, '• Die Studierenden kennen alle wesentlichen
Konzepte der objektorientierten Programmierung
sowie typische Problemstellungen, in denen diese
sinnvoll und effektiv eingesetzt werden können.
• Sie kennen darüber hinaus die aus der funktionalen
Programmierung stammenden Konzepte der
Lambdas und Streams, und sie wissen, wann diese
vorteilhaft verwendet werden können.
• Sie beherrschen den Umgang mit den gängigen
Standardklassen (Collections, I/O) der Lehrsprache
Java und verstehen die dahinter stehenden
Konzepte.
• Die Studierenden erkennen den Sinn und die
Anwendung von Ausnahmen.
• Sie erlernen das Schreiben von Unit-Tests als
untrennbarem Bestandteil des Programmierablaufs.
Sie verstehen, dass das Schreiben von
Komponententests eine Form der Spezifikation des
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 36 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
gewünschten Verhaltens ist und darum an den
Anfang des Programmierablaufs gehört.
• Insgesamt sind die Studierenden in der Lage, zu
überschaubaren Aufgabenstellungen qualitativ gute,
wartbare und erweiterbare Softwarelösungen zu
erstellen.', NULL, 'Klassenhierarchie und Polymorphie •
Testautomatisierung mit JUnit • Collection-Klassen •
Ausnahmen • Schnittstellen • Nutzen von Schnittstellen
am Beispiel eines Entwurfsmusters • Lambda-
Ausdrücke • Streams • Ein-/Ausgabe •
Aufzählungstypen • Parallelität');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (16, 1, 'Die Studierenden können Methoden der agilen
Softwareentwicklung gegenüberstellen, diskutieren und
argumentieren
indem Sie
• Das agile Manifesto darstellen und mit klassischen
Entwicklungsmethoden kontrastieren
• Verschiedene agile Ansätze, insbesondere auch
lean UX analysieren und voneinander abgrenzen
• Für das bevorstehende Großprojekt beispielhaft
den agilen Ablauf planen und vorbereiten
• Werkzeuge und Tools zur Unterstützung
ausprobieren und vergleichen
• Limitationen und Skalierungsmöglichkeiten kennen
und klassifizieren
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 38 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Um später
• Im Großprojekt effizient und effektiv im Team
arbeiten zu können
• Im Beruf sich hinsichtlich der dort herrschenden
Entwicklungsmethoden schnell einfinden und
konstruktiv zur Verbesserung beitragen können.
Die Studierenden können, projektspezifische
grundlegende Fachkompetenzen anwenden
Indem Sie
• Die Thematik des Großprojekts analysieren und
hinsichtlich der notwendigen Fachkompetenzen
diskutieren
• Im Rahmen von kleinen Projektaufgaben und unter
zu Hilfename vorbereiteter Tutorials und
weiterführender Informationen die Notwendigkeit für
die Belegung weiterführender Learning Units oder
Selbstlernmöglichkeiten analysieren und bewerten.
Um später
• Im Großprojekt direkt einsteigen zu können
• Die Wahl für weiterführende Learning Units
informiert treffen zu können.', NULL, 'Zentrale Inhalte des PRIMER TO Building sind
Methoden, Werkzeuge und Techniken zur Projektarbeit
in komplexen Softwareprojekten. Hierzu gehört
insbesondere die agile Softwareentwicklung und das
Verständnis, wie diese auch in den Kontext mensch-
zentrierter und nachhaltiger Softwareentwicklung
eingesetzt werden kann.
Darüber hinaus werden, abhängig vom Projektthema,
spezifische Fachkompetenzen vermittelt, welche als
elementar für alle Projektteilnehmer betrachtet werden.
Wird beispielsweise im Projekt mit dem Ziel gearbeitet,
eine VR Anwendung in Unreal zu entwickeln, dann kann
im Primer eine kurze Einführung und Grundlage hierzu
vermittelt werden, welche die Studierenden in die Lage
versetzt zu entscheiden, ob und wer das weiterführende
Learning Unit besucht oder inwieweit im Selbststudium
weiterführende Kompetenzen angeeignet werden
können');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (17, 1, 'Die Studierenden können verschiedene
Designmethoden (insbesondere Analyse, Ideation,
Entwurf) gegenüberstellen, diskutieren und
argumentieren
indem Sie
• Beispielhaft und verkürzt einen Design Lifecycle
(z.B. Design Thinking Sprint) anwenden
• Verschiedene Designmethoden analysieren und
voneinander abgrenzen
• Für das bevorstehende Großprojekt beispielhaft
den Einsatz von Designmethoden planen und
vorbereiten
• Werkzeuge und Tools zur Unterstützung
ausprobieren und vergleichen
• Limitationen und Skalierungsmöglichkeiten kennen
und klassifizieren
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 40 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Um später
• Im Großprojekt effizient und effektiv im Team
arbeiten zu können
• Im Beruf sich hinsichtlich der dort herrschenden
Designmethoden schnell einfinden und konstruktiv
zur Verbesserung beitragen können.
Die Studierenden können, projektspezifische
grundlegende Fachkompetenzen anwenden
Indem Sie
• Die Thematik des Großprojekts analysieren und
hinsichtlich der notwendigen Fachkompetenzen
diskutieren
• Im Rahmen von kleinen Projektaufgaben und unter
zu Hilfename vorbereiteter Tutorials und
weiterführender Informationen die Notwendigkeit für
die Belegung weiterführender Learning Units oder
Selbstlernmöglichkeiten analysieren und bewerten.
Um später
• Im Großprojekt direkt einsteigen zu können
• Die Wahl für weiterführende Learning Units
informiert treffen zu können.', NULL, 'Zentrale Inhalte des PRIMER TO DESIGNING sind
Methoden, Werkzeuge und Techniken zur Analyse,
Ideenfindung und Entwurf in komplexen Design und
Softwareprojekten. Hierzu gehört insbesondere auch
das Verständnis, wie diese in den Kontext mensch-
zentrierter und nachhaltiger Softwareentwicklung
eingesetzt werden können.
Darüber hinaus werden, abhängig vom Projektthema,
spezifische Fachkompetenzen vermittelt, welche als
elementar für alle Projektteilnehmer betrachtet werden.
Wird beispielsweise im Projekt mit dem Ziel gearbeitet,
eine Webanwendung zu konzipieren, dann kann im
Primer eine kurze Einführung und Grundlage in
verschiedene Prototyping Werkzeuge erfolgen, welche
die Studierenden in die Lage versetzt zu entscheiden,
ob und wer das weiterführende Learning Unit besucht
oder inwieweit im Selbststudium weiterführende
Kompetenzen angeeignet werden können.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (18, 1, 'Die Praxisphase hat die Studierenden an die berufliche
Tätigkeit des Informatikers bzw. an der Schnittstelle
Wirtschaftsinformatik oder Informatik und Design durch
konkrete Aufgabenstellung und praktische Mitarbeit in
Betrieben oder anderen Einrichtungen der Berufspraxis
herangeführt. Die Studierenden haben in Ansätzen
gelernt, die im bisherigen Studium erworbenen
Kenntnisse und Fähigkeiten anzuwenden und die bei
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 43 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
der praktischen Tätigkeit gemachten Erfahrungen zu
reflektieren und auszuwerten. Während der Praxisphase
haben die Studierenden auch die verschiedenen
Aspekte der betrieblichen
Entscheidungsfindungsprozesse kennen gelernt und
Einblick in informatische, technische, organisatorische,
ökonomische und soziale Zusammenhänge des
Betriebsgeschehens erhalten.', NULL, 'Spezielle Inhalte für die Praxisphase werden nicht
vorgegeben. Es muss lediglich sichergestellt sein, dass
die Tätigkeit in der Praxisphase der Tätigkeit eines
Informatikers entspricht, bzw. eine Tätigkeit an der
Schnittstelle Wirtschaftsinformatik oder Informatik und
Design ist. Um dies sicherzustellen, wird jeder
Studierende vor und während der Praxisphase von
einem Professor oder einer Professorin des
Fachbereichs Informatik betreut. Dabei werden auch die
geplanten Tätigkeiten besprochen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (19, 1, 'Die Studierenden kennen und verstehen grundlegende
Konzepte der linearen Algebra und Statistik. Sie
beherrschen Rechentechniken und können Ergebnisse
daraus im anwendungsorientierten Kontext
interpretieren. Sie können mehrdimensionale Modelle in
der Praxis anwenden und statistische Aussagen auf
Basis vorgegebener Datensätze treffen und
interpretieren.', NULL, '• Rechnen mit Vektoren im Anschauungsraum und
abstrakten Vektorraum (Grundrechenarten,
Skalarprodukt, Kreuzprodukt)
• Lineare Gleichungssysteme und Matrizen (Gauß-
Jordan-Verfahren)
• Lineare Abbildungen und Matrizen (lineare
Abbildungen als Drehstreckungen, Determinanten,
Eigenwerte und Eigenvektoren)
• Deskriptive Statistik (Beschreibung von Daten an
Hand von Kennzahlen)
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 45 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• Diskrete Zufallsvariablen und Verteilungen
• Normalverteilung
• Statistische Tests: t-Test, z-Test
• Hauptkomponentenanalyse als Zusammenspiel von
linearer Algebra und Statistik');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (20, 1, 'Die Studierenden kennen und verstehen Entwicklungs-
Konzepte, -Verfahren, -Werkzeuge und deren
Einsatzmöglichkeiten, um komplexe
Entwicklungsprojekte erfolgreich umsetzen zu können.
Die einzelnen Teilnehmer:innen von Projektgruppen
besitzen spezielle rollenspezifische Kompetenzen und
belegen daher unterschiedliche Kombinationen von
LUs.
Indem gestalterisches Basiswissen, Konzepte und
Werkzeuge der jeweils gewählten LUs vorgestellt und
erprobt werden.
Die erworbenen gestalterischen Kompetenzen können
und sollen im Designing Projekt Anwendung finden.', 'und belegen daher unterschiedliche Kombinationen von LUs. Indem gestalterisches Basiswissen, Konzepte und Werkzeuge der jeweils gewählten LUs vorgestellt und erprobt werden. Die erworbenen gestalterischen Kompetenzen können und sollen im Designing Projekt Anwendung finden.', 'Jede Teilnehmerin / Jeder Teilnehmer wählt 3 von 6
vorgegebenen Learning Units (LU) aus. Die
vorgegebenen LU werden projektabhängig aus der Liste
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 47 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
aller möglichen LU zum Building Projekt ausgewählt.
Diese Auswahl kann jährlich variieren.
Die grundsätzlich möglichen Learning Units Building
und deren detaillierte Beschreibung finden Sie im
Anhang zum Modulkatalog.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (21, 1, 'Die Studierenden kennen und verstehen gestalterische
Mechanismen, Konzepte, Werkzeuge und deren
Einsatzmöglichkeiten, um komplexe Design-Projekte mit
digitalen Mitteln erfolgreich umsetzen zu können. Die
einzelnen Teilnehmer von Projektgruppen besitzen
spezielle rollenspezifische Kompetenzen und belegen
daher unterschiedliche Kombinationen von LUs.
Indem gestalterisches Basiswissen, Konzepte und
Werkzeuge der jeweils gewählten LUs vorgestellt und
erprobt werden.
Die erworbenen gestalterischen Kompetenzen können
und sollen im Designing Projekt Anwendung finden.', 'und belegen daher unterschiedliche Kombinationen von LUs. Indem gestalterisches Basiswissen, Konzepte und Werkzeuge der jeweils gewählten LUs vorgestellt und erprobt werden. Die erworbenen gestalterischen Kompetenzen können und sollen im Designing Projekt Anwendung finden.', 'Jede Teilnehmerin / Jeder Teilnehmer wählt 3 von 6
vorgegebenen Learning Units (LU) aus. Die
vorgegebenen LU werden projektabhängig aus der Liste
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 49 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
aller möglichen LU zum Designing Projekt ausgewählt.
Diese Auswahl kann jährlich variieren.
Die grundsätzlich möglichen Learning Units Designing
und deren detaillierte Beschreibung finden Sie im
Anhang zum Modulkatalog.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (22, 1, 'WAS
Die Studierenden kennen die Grundbegriffe und -
prinzipen der visuellen Kommunikation und Gestaltung
und vertiefen diese in der praktischen Anwendung
anhand von niedrig-komplexen Entwurfsaufgaben mit
professioneller Designsoftware (z. B. Adobe Illustrator
und InDesign).
WOMIT
• Indem Basiswissen in Komposition, Layout und
Typografie und die grundlegenden
Gestaltungsprozesse und -prinzipien, -gesetze und
-methoden erlernt werden.
• indem ein Grundverständnis für Design angelegt
und durch Schulung und Sensibilisierung der
eigenen Wahrnehmung vertieft wird.
• indem eigene Entwurfspraktiken kennengelernt und
Entwürfe im Plenum vorgestellt und reflektiert
werden.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• indem Gestaltungsbeispiele und -prozesse
insgesamt analysiert und reflektiert werden.
• in dem eigene Entwürfe und Layouts mit den
Programmen Adobe Illustrator und InDesign in
Einzel-und/oder Gruppenarbeit erarbeitet werden.
WOZU
Um die Prozesse und Instrumente des Designs in
Folgeveranstaltungen und -projekten mitzubedenken
und einzusetzen.', NULL, 'Grundbegriffe, Wirkung und Einsatzgebiete von Design,
Designprozess und Gestaltungsprinzipien,
Wahrnehmungspsychologische Grundlagen, Layout und
Komposition, Layoutraster, Typografische Grundlagen,
Typohistorie, Typologie, Typoergonomie,
Rastertypografie, Postmoderne Typografie,
Typosemantik und Farbgestaltung.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (23, 1, 'Die Studierenden kennen und verstehen das Konzept
der Von-Neumann-Architektur von Computern. Sie
besitzen eine realistische Modellvorstellung von der
Arbeitsweise eines Prozessors und von der
Zusammenarbeit mehrerer Prozessoren zur
Parallelverarbeitung.
Die Studierenden kennen und verstehen die wichtigsten
Funktionen von Betriebssystemen. Sie kennen das
Konzept von Ressourcen. Sie besitzen eine realistische
Modellvorstellung von konkurrierenden Prozessen zur
Verwaltung der Ressourcen und kennen damit
auftretende Probleme. Sie kennen und verstehen das
Konzept von Netzwerken. Sie kennen den Begriff von
Netzwerkschichten.
Die Studierenden kennen einige wichtige Begriffe und
Konzepte der theoretischen Informatik im Überblick:
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 53 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Komplexität, Berechenbarkeit, Formale Sprachen und
endliche Automaten.
Die Studierenden können Bezüge zwischen den
Hauptthemen aus der Veranstaltung herstellen.
Die Studierenden können zu allen Themen Wissens-
und Verständnisfragen beantworten.', NULL, 'Bus System, Arbeitsspeicher, Ein-/Ausgabe Einheit,
CPU, GPU, Multiprozessorsysteme.
Prozesse, Speicherverwaltung, Ein-/Ausgabe,
Dateisysteme, Netzwerktopologien, Protokolle und
Standards, Internet.
Begriffe Komplexität und Berechenbarkeit, Formale
Sprachen und Automaten im Überblick.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (24, 1, 'WAS
Die Studierenden kennen und verstehen das
Spannungsfeld Informatik und Design und entwickeln
systematisch in Gruppenarbeit eine (sozio-)technische
Anwendung mit den Projektphasen
Analyse/Nutzungskontext, Konzeption, Gestaltung und
prototypische Entwicklung (wechselnde Gewichtung je
Projektthema).
WOMIT
• indem sie domänenspezifische und
nutzer:innenorientierte Anforderungen ermitteln,
• dabei relevante gesellschaftliche, ökologische,
ökonomisch und ethische Kontexte identifizieren
und berücksichtigen,
• allgemeine Analyse-, Entwurfs-, Visualisierungs-,
Lösungsfindungs- und Umsetzungsmethoden
anwenden,
• fachspezifische Methoden und Werkzeuge (digitale
Tools) verwenden,
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 55 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
• verknüpfen und integrieren dabei die
unterschiedlichen fachspezifischen Perspektiven
• reflektieren dabei typische und konkrete
Konfliktbereiche und die Kommunikation im Team
• dokumentieren und kommunizieren
Anwender:innen adäquat.
WOZU
Um die erste Studienphase einzuleiten und ein
Grundverständnis für die Zusammenarbeit in
interdisziplinären Teams, die Lehrformen (projekt- und
problembasiertes Lernen) und Methodiken (Human
Centered Design) des Studiengangs zu legen. Der
Zugang ist spielerisch, um Interesse und Begeisterung
für den Studiengang wecken.', NULL, 'Einführung Studiengang (Ausrichtung und Funktion
sowie Perspektiven und Möglichkeiten), Einführung
Informatik und Design (Disziplin und ihre Teilgebiete,
geschichtlicher Überblick, gesellschaftliche
Rahmenbedingungen und Auswirkungen,
Aufgabenfelder und Perspektiven), Einführung
Projektarbeit (Teamarbeit, Projektmanagement und
Projektpräsentation), Einführung Human Centered
Design (Verstehen, Definieren, Ideation, Prototyping
und Testen), Benutzeroberflächen und Mensch-
Maschine-Interaktion, Einblick in die
Softwareentwicklung Joy of Programming und Rapid
Prototyping.
Regelmäßige Teilnahme, Erarbeitung eines
Gruppenprojekts, Präsentation');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (25, 1, 'Die Studierenden
• kennen den typischen Lebenszyklus eines
Softwaresystems,
• verstehen Begriffe der Softwaretechnik, wie
Anforderungen/Requirements, Architektur,
Design, DevOps, Testing,
• kennen verschiedene Vorgehensmodelle der
Softwareentwicklung und deren Phasen und
verstehen deren Vor- und Nachteile,
• kennen die grundsätzlichen Methoden des
Requirements-Engineerings,
• können Software-Design mit Hilfe von UML
entwerfen und dokumentieren
• kennen Software-Design-Prinzipien wie SOLID,
DRY und KISS,
• können verschiedene Software-
Qualitätsmerkmale (z.B. FURPS) klassifizieren
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 57 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
und ihren Wert für ein Softwaresystem
beurteilen,
• kennen und verstehen DevOps-Prinzipien.
In Übung und Praktikum analysieren die Studierenden
funktionale und nicht-funktionale Anforderungen an ein
System, wenden die gelernten Methoden zum Entwurf
und zur Implementierung von Software an und stellen
ihr Design in angemessener Dokumentation dar.', NULL, '• Einführung in die Softwaretechnik
• Vorgehensmodelle
• Requirements-Engineering
• Software-Architektur
• Software-Design und Implementierung
• Qualität
• Tests
• DevOps
• Software-Betrieb');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (64, 1, 'Die Studierenden lernen unterschiedliche Technologien
und Konzepte kennen, die für den Betrieb großer IT-
Infrastrukturen notwendig sind und bekommen erste
praktische Erfahrungen mit deren Anwendung. Sie
erlangen die Fähigkeit, neue Konzepte im Umfeld des
IT-Betriebs schnell begreifen, einordnen und bewerten
zu können.', NULL, 'Einführung
Speichernetze
Virtualisierung
System-Management');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (83, 1, 'Die Studierenden werden in die Lage versetzt:
• den Aufbau und die wesentlichen Aufgaben des
Rechnungswesens wiederzugeben und zu erläutern,
• die wesentlichen Methoden des internen und
externen Rechnungswesens anzuwenden,
• die grundsätzliche betriebswirtschaftliche
Planungssystematik in einem Unternehmen
anzuwenden,
• die Integrationsmöglichkeiten zwischen primär
betriebswirtschaftlich planerischen Funktionen,
Stammdaten und Rechnungswesen wiederzugeben,
• die erlernten betriebswirtschaftlichen Methoden und
Prozesse des Rechnungswesens in ein
Informationssystem anhand eines integrierten ERP-
Anwendungssystem am Beispiel SAP R/3 umzu-
setzen.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 85 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, '• Aufbau, Aufgaben, Methoden und gesetzliche
Grundlagen des externen Rechnungswesen
(Finanzbuchhaltung, Anlagenbuchhaltung,
Jahresabschluss)
• Aufbau, Aufgaben und Methoden des internen
Rechnungswesens (Kostenrechnung,
Ergebnisrechnung)
• Integrationsaspekte zwischen primär
betriebswirtschaftlich planerischen Funktionen,
Stammdaten und Rechnungswesen
• Einführung in die Unternehmensplanung
(Planungsprozess, Planungssystem,
Planungsinstrumente)
• Umsetzung des erlernten Wissens anhand eines
Fallbeispiels in das integrierte
Standardsoftwaresystem');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (84, 1, 'Die Studierenden
• kennen die wesentlichen Aufgaben und Ziele des
digitalen Marketings und können die
Herausforderungen der digitalen Transformation
identifizieren, um Produkte, Preise, Kommunikation
und den Vertrieb marktorientiert zu gestalten,
• verstehen den Prozess der systematischen Planung
einer digitalen Marketingstrategie, die heute
größtenteils datenbasiert konzipiert wird, damit
unternehmerischer Erfolg gewährleistet wird,
• können Methoden und Instrumente des digitalen
Marketing wie Affiliate Marketing und
Suchmaschinenmarketing unter Berücksichtigung der
markt- und unternehmensbezogenen
Rahmenbedingungen mit Hilfe von
Softwareapplikationen und -werkzeugen planen,
umsetzen und kontrollieren, um so eine operative
Durchführung unterstützen zu können,
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 87 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• kennen Methoden der Datenanalyse im Kontext des
digitalen Marketing und können Targeting sowie
Zielgruppen-/Kundenanalysen durchführen
(Klassifikation, Verhaltensanalyse und Prognosen zur
Umsatzentwicklung, Kauffrequenzen usw.), damit die
Erkenntnisse bei der Kampagnengestaltung
verwendet werden können,
• verstehen und evaluieren die Erfolgswirksamkeit von
Maßnahmen des digitalen Marketings, um die
Wirtschaftlichkeit im unternehmerischen Kontext
gewährleisten zu können,
• gestalten und optimieren Maßnahmen des Social
Media Marketing bzw. des Customer Relationsship
Managements mit Hilfe der Werkzeuge der
intergrierten Marketingkonzeption zum Aufbau und
zur Aufrechterhaltung langlebiger
Kundenbeziehungen,
• verfügen über eine initiale Kreationskompetenz für
erfolgreiches E-Mail- und Mobile-Marketing, um
innovative Maßnahmen planen und gestalten zu
können.', NULL, '1. Konzeption des Digitalen Marketing
2. Gestaltung und Aufbau von Webseiten
3. Affiliate-Marketing und Online-Werbung
4. Suchmaschinenwerbung und -optimierung
5. Social Media Marketing
6. E-Mail- und Mobile-Marketing');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (66, 1, 'Die Studierenden kennen die gängigen
Anwendungsfelder der webbasierten Datenverarbeitung
und die spezifischen Probleme die im Einsatz
auftauchen.
Dabei lernen die Studierenden ihre Kenntnisse über
relationale Datenbanksysteme mit weiterführenden
Technologien zu erweitern und auf nicht-relationale
Anwendungen zu übertragen.', NULL, 'Die Veranstaltung bietet eine Vertiefung in verschiedene
aktuelle Datenbankformate und Anfragesprachen im
Kontext von webbasierten und Cloud-basierten
Anwendungen.
• Objekt-relationales Mapping (am Beispiel aktueller
Framework-Implementierungen)
• Einführung in verschiedene Datenformate
(strukturiert, semi-strukturiert, unstrukturiert), sowie
passenden Anfrage- und Schemasprachen.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 49 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• (Wahlweise) Unstrukturierte Datenbankformate (sog.
NOSQL Datenbanken) am Beispiel
Graphdatenbanken.
• (Wahlweise) Weitere Datenbankformate (bspw.
Dokumenten-DB)
• (Wahlweise) Einführung zu Cloud Technologien für
Daten-basierte Anwendungen im Web
Die einzelnen Themen werden mit Anwendungsfällen
aus der Praxis in der Vorlesung untersucht und anhand
praktischer Beispiele im Praktikum erlernt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (67, 1, 'Die Studierenden sind nach Absolvieren des Moduls in
der Lage, eine anwendungsorientierte Fragestellung mit
Hilfe von Data Science-Methoden zu beantworten. Sie
verstehen die angewandten Methoden und deren
Einsetzbarkeit in der Praxis und können Daten,
Methoden und Ergebnisse fachfremden erläutern und
diskutieren.
Fragestellungen und Datensätze entstammen in der
Regel einem gesundheits-, gesellschafts- oder
ingenieurwissenschaftlichen Kontext.
Insbesondere sind die Studierenden in der Lage,
• Daten, Methoden und Ergebnisse mit Nicht-
Informatikern zu diskutieren,
• Daten zu bereinigen und für Analysen vorzubereiten,
• explorative und deskriptive Datenanalysen
durchzuführen
• zu entscheiden, ob eine gegebene Fragestellung am
besten mit Regressions-, Klassifikations- oder
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
Clusteringmethoden beantwortet werden kann, diese
anzuwenden und die Ergebnisse zu interpretieren.', NULL, '• Vorstellung des behandelten Datensatzes und seiner
fachlichen Hintergründe
• Datenexploration, -visualisierung und deskriptive
Analysen
• Überblick über zur Verfügung stehende Methodiken
• Formulierung geeigneter Fragestellungen und
Methodenauswahl
• Einarbeitung in die ausgewählten Methoden
• Datenanalyse
• Vorstellung und Diskussion der Ergebnisse
Programmieranteile erfolgen in Python oder R. Die
konkrete Methodenauswahl erfolgt im Kurs im Dialog
mit den Studierenden. Je nach Fragestellung wird
angestrebt, Studierende, Praktiker*innen oder
Wissenschaftler*innen anderer Fachrichtungen zu
einzelnen Kursterminen hinzuzuziehen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (68, 1, 'Die Studierenden sind nach Absolvieren des Moduls in
der Lage, das anwendungsbezogene Fachgebiet
"Medizinische Informatik" zu überblicken. Sie können
Zusammenhänge zwischen den verschiedenen
Anwendungsbereichen und Teilgebieten herstellen und
kennen die notwendigen IT-Grundlagen der
medizinischen Informatik.
Insbesondere sind die Studierenden in der Lage
• Ziele, Nutzen und Aspekte von medizinischen IT-
Anwendungen zu erklären,
• med. Vorgänge/Prozesse zu modellieren und die
Bedeutung von Prozessunterstützung durch IT zu
erklären
• zu erklären, welche medizinischen bildgebenden
Verfahren und Biosignale es gibt und welche
mathematischen Operationen bei deren Übernahme
in Rechnersysteme nötig sind,
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 53 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• Ziele und Vorgehen bei klinischen und
epidemiologischen Studien zu beschreiben und den
IT-Einsatz hierzu darzustellen
• Einfache Programme zu Teilaspekten der
medizinischen Informatik zu schreiben und
• einen ersten Überblick über rechtliche Aspekte
medizinischer Software zu geben.', NULL, '• Überblick über die Teilgebiete der medizinischen
Informatik
• Medizinische Prozesse, Dokumentation und
Informationssysteme
• Bildgebende Verfahren und Biosignale
• Klinische und epidemiologische Studien
• Einführung in rechtliche Aspekte');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (140, 1, 'Die Studierenden können 3D User Interfaces
hinsichtlich Gestaltung und Interaktion entwerfen,
indem sie entsprechende Werkzeuge und Tools
analysieren, vergleichen und anwenden können
um später für interaktive Systeme 3D Komponenten
gestalten zu können (beispielsweise VR, Spiele, AR).', NULL, '3D User Interfaces haben eine immer größere
Bedeutung. Dabei erfordert die Gestaltung sowohl von
grafischen Komponenten als auch der Interaktion eine
gänzlich andere Herangehensweise als in 2D. Dies wird
in Zukunft durch AR und VR Lösungen und das
metaverse nochmal zusätzliche Bedeutung erfahren.
In diesem Modul werden aktuelle Entwicklungen und
Methoden vorgestellt und anschließend in Kleingruppen
für eine konkrete Aufgabenstellungen
Gestaltungsentwürfe entwickelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (69, 1, 'Die Studierenden lernen die Grundlagen, Komponenten
und Begriffe von Industrierobotern und kollaborativen
Robotern kennen. Sie lernen Konzepte und Methoden
der Programmierung und können diese effektiv und
strukturiert bei der Entwicklung eigener
Steuerungsprogramme einsetzten. Sie kennen die
Gefahren und Herausforderungen beim Einsatz von
Industrierobotern und verstehen die Wichtigkeit der
Einhaltung von Vorschriften. Neben der
Programmiermethodik lernen die Studierenden die
Verwendung von Bibliotheken des Roboter Frameworks
ROS (Robot Operation System) kennen.', NULL, '• Grundlagen der Industrierobotik /
Manipulatortechnik, kollaborativer Roboter
• Begriffsbildung und Komponenten
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 55 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• Beschreibung einer Roboterstellung
• Transformation zwischen Roboter- und
Weltkoordinaten,
• Kinematic, inverse Kinematic
• Roboterprogrammierung,
• Roboterframework ROS,
• Bewegungsart und Interpolation
• Betriebssytem: Linux + ROS; Lehrsprachen sind C /
C++, Python, ipython notebooks');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (86, 1, 'Die Studierende werden in die Lage versetzt:
• die Aufgaben und den Aufbau eines
Geschäftsprozessmanagements zu erläutern,
• eine geeignete Methode zur Modellierung von
Geschäftsprozessen auszuwählen,
• Geschäftsprozesse mit den vorgestellten Methoden,
Wertschöpfungsdiagramme, ARIS und BPMN zu
modellieren und ablauforganisatorische
Schwachstellen zu analysieren,
• eine systematische Vorgehensweise zur Einführung
eines Geschäftsprozessmanagements anzuwenden,
• die Einsatzmöglichkeiten und –grenzen von
Geschäftsprozessreferenzmodellen zu verstehen,', NULL, '• Grundlagen zum Geschäftsprozessmanagement,
• Methoden der Geschäftsprozessmodellierung
(Wertschöpfungsdiagramme, ARIS, BPMN),
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 92 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Vorgehensmodell zur Einführung eines
Geschäftsprozessmanagements (Modellierung,
Analyse, Umsetzung, Kontrolle),
• Einsatz von Geschäftsprozessmodellen in der
Softwareentwicklung und Einführung von
Standardsoftware.
• Controlling im Rahmen des
Geschäftsprozessmanagements');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (87, 1, 'Die Studierenden
• kennen die grundlegenden theoretischen und
praktischen Aspekte der Wirtschaftsinformatik
und sind in der Lage diese wiederzugeben und
zu erläutern, um das spätere berufliche
Einsatzfeld der Wirtschaftsinformatik zu
verstehen,
• können die Funktionen sowie die wirtschaftliche
Bedeutung und Abgrenzung der Typen von
Informationssystemen erklären, damit sie in der
Lage sind, die Bedeutung der
Informationssysteme im Rahmen der heutigen
Geschäftsmodelle zu kennen und zu verstehen,
• kennen die Aufgabengebiete der
Wirtschaftsinformatik bei der Planung,
Entwicklung, Integration und Einführung von
Informationssystemen, um später die fachlichen
Kompetenzen zielgerichtet einsetzen zu können,
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 94 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• können unternehmerische Geschäftsprozesse im
Hinblick auf den Einsatz bzw. die Verbesserung
durch Informationssysteme analysieren und
bewerten, um damit organisatorisches
Optimierungspotenzial zu identifizieren,
• sind in der Lage die Komplexität des IT-
Managements zu erklären, damit die
Herausforderungen bei einer strategischen,
taktischen und operativen Planung und
Steuerung von IT-Fachkräften bzw. IT-Projekten
erkannt werden können,
• verstehen inhaltliche Bezüge der Module des
Studienganges im Kontext des Fachgebietes der
Wirtschaftsinformatik, um in
Folgeveranstaltungen Bezüge zwischen
einzelnen Lehrmodulen herstellen zu können.
• werden befähigt mit komplexen
betriebswirtschaftlichen und
informationstechnologischen Problemstellungen
umzugehen, um sie auf zukünftige berufliche
Situationen vorzubereiten.', 'zielgerichtet einsetzen zu können,', '1. Einführung
2. Grundlagen der Wirtschaftswissenschaften und
der Informatik
3. Informationssysteme im Kontext von Strategie
und Organisation der Wertschöpfung
4. Klassifizierung von Anwendungssystemen
5. Integrierte Informationssysteme
6. E-Commerce
7. Wissensmanagement und Zusammenarbeit
8. Informationsmanagement
9. Systementwicklung');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (29, 1, 'Die Studierenden können die frei verfügbaren
KI/Machine Learning Modelle unterscheiden und auf
ihre Einsetzbarkeit im konkreten Projektkontext
bewerten. Sie können zudem aktuelle Frameworks
unterscheiden und anwenden
Indem sie
• Die Grundlagen verschiedener ML Verfahren
kennen und unterscheiden können (z.B. Supervised
Learning, Unsupervised Learning, Reinforcement
Learning)
• Mit aktuellen Frameworks wie Pytorch oder
Tensorflow in Python kleine KI Probleme lösen
lernen.
• Die Limitierungen und Möglichkeiten von KI
Verfahren einschätzen und bewerten können.
Um später
• Im parallelen Großprojekt in begrenztem Umfang KI
Verfahren oder ML Modelle einsetzen zu können.
• Im Beruf die Potentiale für den Einsatz von KI und
ML bewerten und deren Integration begleiten zu
können.', NULL, 'Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (70, 1, '• Gutes Verständnis für die fundamentalen
Kommunikationsarchitekturen und -protokolle des
Internets.
• Erlangen von Kenntnissen über die Aufgaben,
Prinzipien, Mechanismen und Architekturen auf den
unterschiedlichen Kommunikationsebenen.
• Gewinnen von praktischen Erfahrungen über die
Kommunikationsprotokolle, Kommunikationsdienste
und -anwendungen durch Versuche und mit Hilfe von
Protokollanalysen.
• Erleben der Notwendigkeit und Wichtigkeit der
Lehrinhalte.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 57 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik', NULL, '• Einführung: Begriffe, geschichtliche Entwicklung,
Beispiele für Netzwerke, die Zukunft von Netzwerken
und des Internets
• Das ISO- und TCP/IP-Referenzmodell: Instanzen,
Dienste, Protokolle, Paketstrukturen;
Schichtenaufgaben
• Netzkoppelelemente: Repeater, Hubs, Bridges,
Switches, Router, Gateway
• Vermittlungsebene: Aufgaben der Vermittlungsebene
(IP, ARP, ICMP, Routingprotokolle);
Begriffe/Mechanismen der Vermittlungstechnik
(Warteschlangen, Routingverfahren, Traffic Shaping,
Scheduling, Call admission control); Quality of
Service in IP-Netzen (Idee, Konzept, IntServ, RSVP,
DiffServ, MLPS)
• Transportebene: Dienste und Mechanismen der
Transportschicht (TCP, UDP; RTP); Sequenz- und
Bestätigungsnummern, Prüfsumme,
Zeitüberwachung, Segmentierung, Stream-Service,
Sliding-Windows-Technik, Slow-Start, Congestion
Windows, Delayed acknowledgement, Nagle
Algorithmus
• Anwendungsebene: DNS (Domain Name Service),
SMTP (E- Mail), HTTP (World Wide Web), SIP
(Session Initiation Protocol) Pro Anwendungsdienst:
Kommandos, Nachrichten/Datentypen,
Verbindungen/Kommunikation, Besonderheiten;
Protokollanalysen und deren Bewertung
• Client-Server- und P2P-Architektur
• Struktur und Aufbau des Internets (AS, Arten von
ASe, Verbindungen, CDN, …)
• Grundlagen von Verteilten Systemen (Motivation,
Ziele, Konzepte, Beispiele, …)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (31, 1, 'Die Studierenden können ein Mikro-Controller-System
wie Ardiuno so in einer hardwarenahen Sprache wie C
programmieren, dass es auf durch Menschen
ausgelöste physische Ereignisse wie z.B. bestimmte
Bewegungen über Sensor-Steuerung definierte
Reaktionen physicher Geräte über Aktoren auslöst.
Damit sind die Studierenden später in der Lage,
einfache Projekte zu realisieren, in denen Ereignisse
der physischen Welt digital verarbeitet werden müssen,
um dann wiederum digitale oder physische Geräte
definiert steuern zu können.', NULL, 'Die Programmiersprache C, Sensoren und Aktoren, Sensor-Programmierung mit der Arduino-Plattform zur Steuerung von Leuchtdioden und anderen Geräten. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (71, 1, 'Die Studierenden werden in die Lage versetzt:
die relevanten rechtlichen Aspekte und gesetzlichen
Regelungen als Randbedingung in ihre berufliche Arbeit
einbeziehen können,
zu wissen, welche datenschutzrechtlichen Vorgaben es
bei der Speicherung personenbezogener Daten gibt
oder welche rechtlichen Regeln bei der Gestaltung und
Programmierung von Internet-Auftritten einzuhalten
sind.', NULL, 'Rechtliche Aspekte bei der Erstellung und Anwendung
von Softwareprodukten aller Art,
Internet-, Datenschutz- und Urheberrecht, die für die
behandelten Rechtsfelder maßgeblichen europäischen
und deutschen Gesetze.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (72, 1, '• Gutes Verständnis von möglichen Angriffen und
geeigneten Gegenmaßnahmen in der IT
• Erlangen von Kenntnissen über den Aufbau, die
Prinzipien, die Architektur und die Funktionsweise
von Sicherheitskomponenten und -systemen
• Sammeln von Erfahrungen bei der Ausarbeitung und
Präsentation von neuen Themen aus dem Bereich
IT-Sicherheit
• Gewinnen von praktischen Erfahrungen über die
Nutzung und die Wirkung von Sicherheitssystemen
• Erleben der Notwendigkeit und Wichtigkeit der IT-
Sicherheit', NULL, '• Einführung: IT-Sicherheitslage, Cyber-
Sicherheitsstrategien, Cyber-Sicherheitsbedürfnisse,
Angreifer – Motivationen, Kategorien und
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 62 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
Angriffsvektoren, Pareto-Prinzip: Cyber-Sicherheit,
Cyber-Sicherheitsschäden
• Kryptographie und technologische Grundlagen für
Schutzmaßnahmen: Private-Key-Verfahren, Public-
Key-Verfahren, Kryptoanalyse, Hashfunktionen,
Schlüsselgenerierung
• Sicherheitsmodule (SmartCards, TPM, high-security
und high-performence Lösungen)
• Identifikations- und Authentikationsverfahren:
Grundsätzliche Prinzipien sowie unterschiedliche
Algorithmen und Verfahren
• ID-Management (Idee, Ziel, Konzepte)
• ID-Cards (Neuer Personalausweis, Smart-eID …)
• Self-Sovereign Identity (SSI)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (73, 1, 'Die Studierenden kennen
• Begriffe der komponentenbasierten
Softwareentwicklung
• Begriffe der speziellen JEE Entwicklung (Session
Beans, Singleton, Message-Driven Beans)
• Webservices
• Begriffe im Kontext von Frameworks (Inversion of
Control IoC)
• Begriffe der Aspektorientierte Softwareentwicklung
• die folgenden Diagramme der UML:
Komponentendiagramm, Verteilungsdiagramm
• Begriffe der Softwarequalität wie Functionality,
Usability, Reliability, Portability und Supportability
(FURPS)
Die Studierenden verstehen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 64 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• den Zusammenhang der einzelnen Phasen in
verschiedenen Softwareprozessen und die jeweiligen
Vor- und Nachteile
• den Zusammenhang zwischen Anforderungen und
objektorientierten Modellen
• Die Studierenden können das Erlernte anwenden,
um
• aus unstrukturierten Anforderungen an ein System
funktionale Anforderungen zu extrahieren
• qualitative Anforderungen zu formulieren
• objektorientierte Modelle auf Basis der UML zu
erstellen für verschiedene Anwendungsdomänen', NULL, '• Einführung komponentenbasierte
Softwareentwicklung
• Java Enterprise Komponentenmodell
• Session Beans
• Singleton Bean
• Message-Driven Beans
• Webservices
• Aspektorientierte Softwareentwicklung
• Einführung in Frameworks
• Ein spezielles Framework
• UML Diagramme: Komponentendiagramm und
Verteilungsdiagramm');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (58, 1, 'Die/der Studierende ist in der Lage, die Ergebnisse der
Bachelorarbeit, ihre fachlichen und methodischen
Grundlagen, ihre fächerübergreifenden
Zusammenhänge und ihre außerfachlichen Bezüge
mündlich in begrenzter Zeit in einem Vortrag zu
präsentieren.
Darüber hinaus kann sie/er Fragen zu inhaltlichen
Details, zu fachlichen Begründungen und Methoden
sowie zu inhaltlichen Zusammenhängen zwischen
Teilbereichen ihrer/seiner Arbeit selbstständig
beantworten.
Die/der Studierende kann ihre/seine Bachelorarbeit
auch im Kontext beurteilen und ihre Bedeutung für die
Praxis einschätzen und ist in der Lage, auch
entsprechende Fragen nach themen- und
fachübergreifenden Zusammenhängen zu beantworten.', NULL, 'Zunächst wird der Inhalt der Bachelorarbeit im Rahmen
eines Vortrages präsentiert. Anschließend werden in
einer Diskussion Fragen zum Vortrag und zur
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -
Informatik (Bachelor) – PO2023 Modulkatalog
Bachelorarbeit gestellt, die von der/dem Studierenden
beantwortet werden müssen.
Der Vortrag soll mindestens die Problemstellung der
Bachelorarbeit, den gewählten Lösungsansatz, die
erzielten Ergebnisse zusammen mit einer
abschließenden Bewertung der Arbeit sowie einen
Ausblick beinhalten.
Je nach Thema können weitere Anforderungen
hinzukommen, wie z.B. die vergleichende Darstellung
alternativer oder konkurrierender Lösungsansätze, ein
Literaturüberblick oder die Darlegung des aktuellen
Standes der Wissenschaft.
Die Dauer des Kolloquiums ist in § 26 der Bachelor-
Rahmenprüfungsordnung und § 19 der
Studiengangsprüfungsordnung geregelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (74, 1, 'Die Studierenden kennen die Grundzüge der
Entwicklungsgeschichte der Künstlichen Intelligenz (KI).
Sie kennen grundlegende Begriffe der Stochastik und
des maschinellen Lernens, insbesondere der
bayes’schen Modellierung, und können diese
anwenden.
Sie sind in der Lage, typische Problemsituationen aus
den Feldern intelligentes Datamining (Klassifikation,
Lernen aus Daten, Bayes’sche Inferenz) und
Optimierung rationaler Entscheidungen (insbesondere
Planen und Entscheiden bei unsicherem Wissen) zu
modellieren und zu lösen.
Sie kennen die Grundzüge der Lösung der genannten
Probleme unter Verwendung von neuronalen Netzen.
Sie können ihre Erkenntnisse auf verwandte
Problemstellungen übertragen und sind darauf
vorbereitet, sich vertieft mit Spezialgebieten der KI-
Anwendung auseinanderzusetzen.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
Sie wissen um die Problematik der Interpretierbarkeit
von Modellen und sind darauf vorbereitet, die
inhaltichen und gesellschaftlichen Fragen, die mit dem
Einsatz von KI-Modellen und -Systemen verbunden
sind, kompetent zu diskutieren.', NULL, 'Einführendes zur Geschichte der KI und zur
Problemlösung mittels intelligenter Agenten.
Grundlegendes zur algorithmischen Problemlösung
durch exakte und heuristische Suche.
Grundlegendes zur Modellierung und Anwendung von
Wissen bei Unsicherheit: Bayes’sche Inferenz,
Sampling, Filtering, Decision Making und zugehörige
Grundlagen.
Grundlegendes zu maschinellem Lernen:
Kategorisierung (Naive Bayes, kNN, Decision Trees),
Clustering, Collaborative Filtering, Time Series Analysis
und zugehörige Grundlagen, insbesondere neuronale
Netze (NN), Deep-NN, Graph-NN.
Grundlegendes zur sequentiellen Optimierung von
Entscheidungen: Adversarial Search, MCTS, Dynamic
Programming, Reinforcement Learning (RL), Deep-RL
Einführendes zur kritischen Diskussion der
Interpretierbarkeit von Modellen des maschinellen
Lernens und der inhaltlichen und gesellschaftlichen
Konsequenzen ihres Einsatzes.
Bonusthema unter Mitarbeit der Studierenden mit
Gruppenpräsentation, z.B.: KI und Kreativität.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (75, 1, 'Die Studierenden lernen die praktische Anwendung
von „Knowledge Graphs“ in der heutigen IT-
Landschaft kennen.
Die Studierenden lernen welchen typischen
Probleme mit Knowledge Graphs gelöst werden
und welche Probleme dabei auftreten können.
Die Studierenden lernen den Umgang an einer
praktischen Graph-Datenbank Implementierung
(z.Bsp. RDF, SPARQL) kennen.
Dabei lernen die Studierenden ihre Kenntnisse
über relationale Datenbanksysteme auf eine erste
nicht-relationale Technologie zu erweitern.', NULL, 'Die Veranstaltung bietet eine Einführung in das
Thema „Knowledge Graphs“ im Kontext der
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 68 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
Vertiefung von nicht-relationalen
Datenbankformaten.
- Einführung in das Thema „Knowledge
Graphs“ anhand von aktuellen
Beispielanwendungen bzw. Problemfeldern.
- Praktische Einführung einer Graph-
Datenbank (z. Bsp. RDF und SPARQL).
- Überblick Schemasprachen für Graphen.
- Überblick Anfragesprachen für Graph-
Datenbanken und deren spezielle
Problemstellungen.
- (Wahlweise) Weitere Technologien zum
Thema und der Vergleich von Vor- und
Nachteilen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (76, 1, 'Die Studierenden können zentrale Plattformen der
mobilen Anwendungsentwicklung (Android, iOS, mobile
Web, Cross-Plattform-Frameworks) einordnen, indem
sie Gemeinsamkeiten und Unterschiede in Architektur,
Entwicklungsumgebungen und Distributionsmodellen
verstehen, um später fundierte Technologieentschei-
dungen treffen zu können.
Die Studierenden können mobile Anwendungen
konzipieren und implementieren, indem sie plattform-
spezifische APIs sowie Frameworks (z. B. für Sensor-
zugriff, lokale Datenhaltung oder Netzwerkkommunika-
tion) praktisch einsetzen, um funktionsfähige Apps für
verschiedene Plattformen zu entwickeln.
Die Studierenden können Progressive Web Apps sowie
hybride und Cross-Plattform-Lösungen umsetzen,
indem sie geeignete Frameworks wie zum Beispiel
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 70 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
React oder React Native nutzen, um die Reichweite und
Plattformunabhängigkeit von Anwendungen zu erhöhen.
Die Studierenden können benutzerfreundliche
Oberflächen gestalten, indem sie plattformspezifische
Richtlinien und Usability-Prinzipien berücksichtigen, um
Anwendungen an die Erwartungen der Nutzerinnen und
Nutzer anzupassen.
Die Studierenden können Entwicklungswerkzeuge
effizient einsetzen und sich neue Technologien und
Frameworks eigenständig erschließen, gestützt auf
einem grundlegenden Verständnis von Konzepten der
Entwicklung für mobile Plattformen.', NULL, '• Grundlagen mobiler Betriebssysteme und
Entwicklungsumgebungen (Android, iOS)
• Entwicklung nativer mobiler Anwendungen
(Android, iOS)
• Mobile Webentwicklung mit HTML5, JavaScript
und CSS sowie Progressive Web Apps (PWA)
• Cross-Plattform-Entwicklung mit Frameworks
wie React Native
• Prototyping und UI-Design mit Figma;
Gestaltung benutzerfreundlicher Oberflächen
und plattformspezifischer UI-Komponenten
• Software-Entwicklungsprozesse im Kontext
mobiler Anwendungen
• KI-gestützte Methoden und Werkzeuge in der
Softwareentwicklung
• Projektorientierte Umsetzung einer mobilen
Anwendung');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (77, 1, '• Die Studierenden kennen grundlegende Cloud
Technologien und deren Eigenschaften
• Die Studierenden verstehen die enorme Bedeutung
einer performanten Netzwerkanbindung.
• Die Studierenden erwerben in Ergänzung zu den im
Modul Rechnernetzen erworbenen Kompetenzen
zum Umgang mit Festnetzen Fähigkeiten zum
Umgang mit den für mobile Anwendungen
verwendeten relevanten Mobilfunksystemen.
• Sie können grundlegend mit den Einschränkungen
der Funkanbindung mobiler Endgeräte umgehen und
darauf aufbauend beurteilen, welchen Einfluss diese
Einschränkungen auf die Effizienz der von Ihnen zu
verantwortenden Software haben.', 'zum Umgang mit Festnetzen Fähigkeiten zum Umgang mit den für mobile Anwendungen verwendeten relevanten Mobilfunksystemen. • Sie können grundlegend mit den Einschränkungen der Funkanbindung mobiler Endgeräte umgehen und darauf aufbauend beurteilen, welchen Einfluss diese Einschränkungen auf die Effizienz der von Ihnen zu verantwortenden Software haben.', 'Grundlagen zu Cloud Computing und XaaS
Typen mobiler Netze• Bluetooth als Beispiel für ein Ad
hoc Netz• GSM/UMTSLTE als zellulares Infrastruktur-
Netz• Wireless LAN (WLAN) •LoRaWAN als IoT Netz.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 72 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
Praktikum mit Versuchen zu ausgewählten
Funksystemen');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (78, 1, 'Die Studierenden lernen die Begriffe und Komponenten
von mobilen Robotern sowie die Konzepte und
Methoden der Programmierung kennen und können
diese effektiv und strukturiert bei der Entwicklung
eigener Steuerungsprogramme einsetzen.
Sie lernen wie unterschiedliche Sensordaten fusioniert
werden und mobile Systeme navigieren sowie sich
selbst lokalisieren.
Sie kennen die Gefahren beim Umgang mit mobilen
Systemen und die Wichtigkeit der Einhaltung von
Vorschriften sowohl auf technischer als auch sozialer
Ebene.
Neben der Programmiermethodik lernen die
Studierenden die Verwendung von weiteren
Bibliotheken des Roboter Frameworks ROS (Robot
Operation System) kennen.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 74 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik', NULL, '• Roboterprogrammierung, Roboterframework ROS,
• Sensorik
• Aktuatorik
• Lokalisierung
• Kartenbau
• Navigation
• Planung
• Betriebssystem: Linux + ROS; Lehrsprache ist C /
C++, Python, ipython notebooks.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (88, 1, 'Die Studierenden verstehen verschiedenen
Angriffsvektoren und entsprechende
Schutzmechanismen in modernen Netzwerken. Konkret
verfügen die Studierenden über Kenntnisse, ein
Verständnis und Wissen in den folgenden
Themenkomplexen.
• Grundlegenden Konzepte und Prinzipien der
Netzwerksicherheit verstehen, einschließlich
Bedrohungen, Angriffsmethoden und
Schutzmöglichkeiten.
• Kenntnisse über gängige Netzwerkangriffen wie
Distributed Denial-of-Service (DDoS), Man-in-the-
Middle (MitM), Spoofing und weitere.
• Verständnis von Sicherheitsprotokollen und -
technologien zur Mitigation von Angriffsvektoren
bzw. zur Verkleinerung von Angriffsflächen.
• Bewertung von IT-Sicherheitsrisiken in Netzwerken
und von verschiedenen Angriffsvektoren
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 97 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, 'Grundlagen
• Netzwerkarchitekturen und Konzepte: TCP/IP und
ISO/OSI Referenzmodell, gängige Protokolle,
Netzwerkarchitekturen.
• Netzwerksicherheit: Einführung, Bedrohungen,
Herausforderungen.
• Analyse von Netzwerkverkehr: Erfassen und Mitlesen
von Netzwerkverkehr, gängige Tools und
Datenformate zum Mitlesen, Vorteile und
Limitierungen von verschiedenen Vorgehensweisen
Sicherheit auf der Internet- und Netzzugangsschicht
• Angriffe auf MAC und IP-Ebene: ARP- Poisoning,
MAC-Spoofing, ICMP-Flooding, Netzwerkscanner.
• Sicherheit von drahtlosen Netzwerken:
Verschlüsselung (WPA3), MAC-Adressen-Filterung
und verstecken von SSIDs, Evil-Twin Angriffe, Man-in-
the-Middle Angriffe.
Sicherheit auf der Transportebene
• Angriffe auf TCP und UDP: Portscanning, TCP
Session Hijacking, UDP-Flooding und Reflektion
Angriffe.
• Protokolle zur Verschlüsselung: Transport Layer
Security (TLS) und Datagram Transport Layer
Security (DTLS).
Sicherheit auf der Anwendungsebene
• Sicherheit von Web-Anwendungen: Cross-Site-
Request-Forgery (CSRF) und Cross-Site-Scripting
(XSS), HTTP-Sicherheitsmechanismen (z.B. Content-
Security-Policies), Command- und SQL-Injections.
• Sicherheit von DNS: DNS-Spoofing, DNSSEC, DNS-
Tunneling, DNS-Amplifikationsangriff.
• E-Mail-Sicherheit: Erkennung von SPAM,
Verschlüsselung von E-Mails, Phishing.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (79, 1, 'Die Studierenden lernen die Grundlagen und Begriffe
der parallelen Programmierung und des parallelen
Programmierparadigma kennen und können parallele
Programme entwickeln und testen. Sie lernen
sequentielle Algorithmen zu parallelisieren und
innerhalb der Grafikkarte oder MultiCore Architekturen
oder über mehrere Rechner hinweg parallel zu verteilen.
Neben der Programmiermethodik, parallelen Pattern
und dem Design lernen die Studierenden die speziellen
Probleme und Fragestellungen bei der parallelen
Programmierung kennen, insbesondere das Erkennen
von Nebenläufigkeiten und die schwierigere
Fehleranalyse.', NULL, '• Grundlagen paralleler Programmierung
• Parallele Architekturen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 76 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• Design und Analyse von parallelen Algorithmen
• Threads- OpenMP
• MPI - OpenCL
• CUDA- Parallele Pattern (Map, Reduce, Scan, Sort,
...)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (89, 1, 'Die Studierende erlernen die theoretischen Grundlagen
des Projektmanagements. Sie können Projekte
strukturieren, zeitlich und im Aufwand planen und
überwachen. Die Studierenden verstehen, dass neben
den technischen Aufgaben das Personalmanagement
(mit allen Facetten) ein sehr wesentlicher Erfolgsfaktor
für das Projektmanagement ist. Durch den praktischen
Umgang mit Projektmanagement anhand von
Fallbeispielen erlernen die Studierenden die Umsetzung
von theoretisch Erlerntem und den Einsatz von PM-
Tools.', NULL, 'Einführung in das Projektmanagement
• Projektorganisation
• Projektplanung
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 100 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Strukturierung von Projekten,
Terminplanungstechniken, Kapazitätsplanung,
Aufwandsschätzung, Projektkostenplanung
• Projektüberwachung und –steuerung
• Qualitätssicherung und Risikomanagement
• Projektabnahme und –abschluss
• Verhaltenstheoretische Elemente im
Projektmanagement (Personalmanagement)
• Projektleiter und Projektteam, Gruppenarbeit im
Projektteam, Kommunikation, Gesprächsführung,
Motivation
• Projektunterstützungswerkzeuge
Aus der Beschreibung sollte die Gewichtung der Inhalte
und ihr Niveau hervorgehen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (90, 1, 'Die Studierende werden in die Lage versetzt:
• die wesentlichen Prozesse der
Funktionsbereiche Produktion und
Materialwirtschaft zu verstehen.
• die wesentlichen Methoden und Modelltheorien
in den betrieblichen Funktionsbereichen
Produktion und Materialwirtschaft anzuwenden
und beurteilen zu können.', NULL, '• Grundlagen der Produktion und Materialwirtschaft
(Begriffsdefinition, Produktionsplanungsansätze)
• Mathematisch operative und strategische,
deterministische und stochastische Planungsmodelle
• Prozesse der Produktionsplanung und -Steuerung
sowie Materialwirtschaft
• Prognosemethoden und Risikomanagement
Angewandte Fallbeispiele und -Applikationen aus der
Unternehmenspraxis
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 102 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (80, 1, 'Die Studierenden kennen die Konzepte und Methoden
der prozeduralen Programmierung und können diese
effektiv und strukturiert bei der Entwicklung eigener
prozeduraler Programme mit der Programmiersprache
C einsetzen. Sie gehen sicher mit maschinennahen
Konzepten wie Zeigern und Speicherverwaltung sowie
mit Strukturen um. Die Studierenden sind damit in der
Lage, sich zukünftig selbstständig und zügig in weitere
prozedurale Sprachen einzuarbeiten.', NULL, '• Grundelemente von C
• Funktionen und Speicherklassen
• Präprozessor
• Adressen und Zeiger
• Dynamische Speicherverwaltung
• Strukturen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 78 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• Weitere ausgewählte Sprachelemente
• Make
• Überblick über die Erweiterungen von C zu C++');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (81, 1, '• Verständnis gängiger Verfahren zur
Systemsicherheit, Systemintegrität und zum
Softwareschutz
• Anwenden von Mechanismen zur Identifikation und
Ausnutzung von Software-Schwachstellen
• Anwenden von Angriffstechniken in
Computernetzwerken
• Erlangen von Kenntnissen im Bereich der
Schadsoftware-Erkennung und -Abwehr
• Teilnahme an einem Capture-the-Flag-Wettbewerb', NULL, 'Die Studierenden lernen die Anwendbarkeit und
Grenzen von sicherheitsrelevanten Angriffen gegen
Systeme, Netzwerkprotokolle und Software.
Dabei werden die folgenden Themen behandelt:
• Linux and Unix-like operating system basics
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 80 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• Vulnerability research
• Reconnaissance and scanning
• System security and operational security
• Software security
• Bytecode and binary code analysis
• Denial-of-Service attacks
• Web security
• Incident response
Lerneinheiten bestehen jeweils aus einer Einführung in
Form mindestens einer Vorlesungseinheit sowie
Aufgaben, die im Praktikum gelöst werden müssen.
Darüber hinaus müssen die Studierenden selbst
verwundbare Beispiele als Aufgaben entwerfen, die
beispielsweise im Rahmen eines eigenen CTF-
Wettbewerbs eingesetzt werden könnten.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (59, 1, '• Die Studierenden kennen den grundlegenden Aufbau
konvergenter Netze. Sie kennen grundlegende
Konzepte eines modernen LANs mit VLANs.
• Sie können beim Design, Aufbau und Betrieb eines
mittelgroßen LANs unter Führung eines erfahrenen
Netzadministrators eingesetzt werden.
• Darüber hinaus kennen Sie grundlegende
Eigenschaften eines WAN und des Internets.
• Sie sind in der Lage, sich effektiv in weitere Aspekte
von Netzwerken einschließlich Sicherheitsfragen und
Management einzuarbeiten. Darüber hinaus sind Sie
in der Lage, Protokolle höherer Schichten zügig zu
erlernen und in das Schichtenmodell einzuordnen.
• Lehrsprache im Praktikum ist Cisco IOS.', NULL, 'Grundbegriffe, Netztopologien , ISO/OSI-
Schichtenmodell und Internet-Architektur
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 29 -
Informatik (Bachelor) – PO2023 Modulkatalog
• Übertragungsmedien und -kanäle, Bitübertragung
und Codierung generisch und am Beispiel Ethernet
• Schicht 2 Technologie am Beispiel Ethernet, LLC und
MAC• Schicht 2 LAN Switching einschließlich VLANs
und Spanning Tree
• Internet-Adressierung sowie statisches und
dynamisches Routing als Schicht 3 Technologie,
Schicht 3 Routing im LAN
• Grundlagen zu Weitverkehrsnetzen und zum Internet
• Einführung zu TCP und UDP und well-known-Port
Anwendungsschichtprotokollen');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (82, 1, 'Die Studierenden kennen
• Architekturmuster
• Designmuster
• OSGi Komponentenmodell
Die Studierenden verstehen
• den Zusammenhang der einzelnen Phasen in
verschiedenen Softwareprozessen und die
jeweiligen Vor- und Nachteile, insbesondere den
Übergang von Analyse zu Design
Die Studierenden können das Erlernte anwenden, um
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 82 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik
• aus einem Pflichtenheft ein Design zu entwickeln
• qualitative Anforderungen an das Design zu
formulieren
• objektorientierte Designmodelle auf Basis der UML
zu erstellen', NULL, '• Einführung komponentenbasierte Einführung
Software Design
• Design Patterns (Observer, Adapter, Fassade,
Strategie, Dekorierer, Simple Fabrik, Fabrikmethode,
abstrakte Fabrik, Watchdog)
• Einführung in Architekturmuster
• MVC (Model-View-Controller) und dessen Derivate
Passive View und Supervising Controller
• Mehrschichtarchitektur
• UML Diagramme: Interaktionsübersicht,
Kommunikationsdiagramm, Paketdiagramm,
Kompositionsstrukturdiagramm,
Komponentendiagramm, Verteilungsdiagramm)
• Komponentenmodell OSGi');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (61, 1, 'Die Studierenden erwerben berufsorientierte
englischsprachige Diskurs- und Handlungskompetenz
unter Berücksichtigung (inter-)kultureller Elemente.', NULL, 'Die Veranstaltung führt in die Fachsprache anhand
ausgewählter Inhalte z.B. aus folgenden Bereichen ein :
AI (Artificial Intelligence), Basic Geometric and
Mathematical Terminology, Biometric Systems,
Diagrammatic Representation, Display Technology,
Networking, Online Security Threats, Robotics, SDLC
(Software Development Life Cycle).');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (62, 1, '• Die Studierenden kennen den grundlegenden Aufbau
und die Funktionsweise der Hardware von Rechnern.
• Die Studierenden sind in der Lage, grundlegende
Abhängigkeiten zwischen der Performanz von
Software und Hardware zu verstehen.
• Die Studierenden sind in der Lage, die
Weiterentwicklung der relevanten Hardware in Ihrem
beruflichen Umfeld zu verstehen und einzuordnen.', NULL, '• Geschichtliches, u.a. Mooresche Gesetz, Prozessor-
Generationen
• Rechner: Komponenten und Struktur ,
Funktionsweise , Buskommunikation, PC-Systeme
• Logikbausteine: Kombinatorische und sequentielle
Logik , Taktverfahren , Entwurf sequentieller
Bausteine, Entwurf einer einfachen ALU
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 41 -
Informatik (Bachelor) – PO2023 Modulkatalog
• Prozessoren, RISC-Architektur vs. CISC-Architektur,
Befehlssatzarchitekturen, Rechenleistung von
Prozessoren, Pipelining
• Speicher: Speichertechnologien, Speicherhierarchie,
Hauptspeicher, Cachespeicher
• Einfache Assemblerbeispiele als Brückenschlag zur
Software');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (63, 1, 'Die Studierenden können mit den wesentlichen
Grundbegriffen der theoretischen Informatik umgehen.
Sie sind in der Lage, die Korrektheit einfacher
Algorithmen nachzuweisen.
Sie können die Komplexität einfacher Algorithmen
formal herleiten und algorithmische Probleme
hinsichtlich ihrer Laufzeitkomplexität in Klassen
einteilen.
Die Studierenden kennen unterschiedliche formale
Berechnungsmodelle und sind in der Lage, einfache
Probleme mit ihnen zu lösen.
Sie sind in der Lage, formale Sprachen in Klassen
einzuteilen und mit Hilfe von Regelwerken zu
beschreiben sowie abstrakte Maschinenmodelle zu
definieren, um formale Sprachen zu erkennen.
Der Besuch dieses Moduls versetzt die Studierenden
insgesamt in die Lage, in ihrer zukünftigen Praxis
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 43 -
Informatik (Bachelor) – PO2023 Modulkatalog
handhabbare Probleme von nicht mehr handhabbaren
zu unterscheiden, und bei der Lösung praktischer
Probleme die Anwendbarkeit formaler Konzepte zu
erkennen und diese einzusetzen.', NULL, '• Programmverifikation
• Komplexität und Komplexitätsklassen
• Berechenbarkeit und Berechnungsmodelle
• Formale Sprachen und Chomsky-Hierarchie
• Endliche Automaten und reguläre Sprachen
• Kontextfreie Sprachen und Kellerautomaten');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (114, 1, 'Die Studierenden können verschiedene Arten von
Benutzerschnittstellen beurteilen und umsetzen, sowie
die Nutzbarmachung von (Interface-)Design im
gesellschaftlichen Kontext in eigenen Projekten
anwenden.
• indem theoretische Hintergründe und aktuelle
Themen/Forschungsergebnisse/Methoden
erarbeitet, kritisch reflektiert und in die Projektarbeit
integriert werden.
• indem ein tiefes Verständnis für die Aufgaben und
Erfolgsfaktoren bei der Durchführung eines
komplexeren Entwicklungsprojekts der
Medieninformatik in einem Team erworben wird.
• indem die Studierenden in der Lage sind,
selbständig einzeln und im Team bekannte
Methoden, Verfahren und Werkzeuge zur
Erstellung einer komplexen Anwendung in der
Medieninformatik auszuwählen und anzuwenden.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 58 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• indem die Studierenden, sich selbständig und im
Team in eine bestimmte Anwendungsdomäne so
weit einzuarbeiten, dass sie sachgerecht mit
Anwendern kommunizieren und mit diesen
Lösungen entwerfen können.
Um im weiteren Studienverlauf Interface-Design-
Prototypen mit wachsender Komplexität entwickeln und
die verknüpften Inhalte und Methoden auf andere
Domänen übertragen zu können.', NULL, 'Durchführung eines mittelgroßen und anspruchsvollen
Projekts aus dem Gebiet der Medieninformatik im
Team, vorzugsweise mit dem Schwerpunkt
Interfacegestaltung unter Berücksichtigung des
Ansatzes des „Spekulativen Designs“.
Selbstständige Durchführung des Projekts von der
Analyse über Design, Prototyping, Realisierung und
Test bis zur Dokumentation, Anwendung von
grundlegenden Projektmanagement-Methoden für
Definition, Planung, Kontrolle und Realisierung des
Projekts, Vertiefung von Kenntnissen zur Entwicklung
von Anwendungen der Medieninformatik.
Typische Projektthemen mit gesellschaftlichem Bezug:
Entwicklung elektronischer Hardwareinterfaces, z.B.
Maschinensteuerung; Entwicklung von Apps oder
Websites z. B. im Themenbereich Bienensterben,
Mental Health etc.
Die Studierenden führen das Projekt weitgehend
selbständig durch und präsentieren ihre
Meilensteinergebnisse im Plenum der Projektgruppe.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (98, 1, 'Die Studierenden lernen die Begriffe und Komponenten
von Autonomen Systemen, Multi-Agenten und
Schwarmsystemen sowie die Konzepte und Methoden
der Programmierung kennen und können diese effektiv
und strukturiert bei der Entwicklung eigener
Anwendungen einsetzen. Sie gehen sicher mit der
problemspezifischen Auswahl einer
Roboterkontrollarchitektur um und wissen, welchen
Einfluss und welche Grenzen die Architekturen
haben.Sie kennen die wichtigsten maschinellen
Lernverfahren, deren Möglichkeiten und Grenzen sowohl
auf technischer als auch sozialer Ebene. Die
Studierenden sind zudem in der Lage, sich selbstständig
und zügig in unterschiedliche Arten von
Architekturkonzepten Autonomer Systeme und deren
Programmierumgebung einzuarbeiten.', NULL, '• Einführung / Begriffsbildung Autonomer Systeme
• Kooperierende Roboter
• Adaptivität und Maschinelles Lernen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 21 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
• Fuzzy Logic, Genetische Algorithmen, Konvolutions
Netze, Generator Netze, Auto Encoder, Deep
Reinforcment Learning, Ransac, Kohnen Netze
• Wissensrepräsentation
• Roboterkontrollarchitekturen
• Lehrsprache C / C++, Python. ipython notebooks,
scikit-learn');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (99, 1, 'Die Studierenden kennen die Begriffe und Verfahren
der dreidimensionalen Datenverarbeitung sowie die
Konzepte und Methoden der Programmierung und
können diese effektiv und strukturiert bei der
Entwicklung eigener Programme einsetzen. Sie können
aus Bilddaten 3D Darstellungen erstellen und mittels
KI-Verfahren semantische Umgebungsdarstellungen
berechnen.', NULL, '• Grundlagen / Begriffsbildung
• 3D-Sensoren
• Kamerakalibrierung
• Stereo Vision
• Structure from Motion
• 3D Punktewolken
• Registrierungsverfahren
• Metrische Umgebungsmodelle
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
• Neuronale Netze,
Lehrsprachen sind C / C++, Python, ipython notebooks.
Bibliotheken: OpenCV, scikit-image, scikit-learn, PCL');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (100, 1, 'In der heutigen Zeit enthalten große IT-
Landschaften oft komplexe Datenarchitekturen, die
auf verschiedene Datenbankformate zurückgreifen
und Daten effizient dazwischen integrieren. Die
Studierenden lernen in der Veranstaltung die
Grenzen von Datenbanken im Allgemeinen
(hauptsächlich formatunabhängig) kennen.
Dabei lernen sie die theoretische Analyse von
Daten-basierten Problemen kennen. Die
gewonnenen Kenntnisse werden auf praktische
Probleme umgesetzt.', NULL, '- Überblick über aktuelle Datenarchitekturen,
aus Sicht der verwendeten Datenbanken
(mit verschiedenen Formaten) und aus Sicht
der Datenmodellierung bzw. Integration
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 25 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
- Formalisierung von Datenformaten und
Anfragen (Kalkül vs. Algebra)
- Ausdrucksstärke von Anfragesprachen für
verschiedene Formate (z.Bsp. SQL,
SPARQL, Key-Value)
- Überblick und Einführung in die
Auswertungskomplexität von Anfragen
allgemein
- (Wahlweise) Aktuelle verwandte Themen
und deren Anwendung in der Praxis (z. Bsp.
CAP Theorem, Ontologien, Knowledge
Graphs)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (115, 1, 'Die Studierenden können die Terminologie forensischer
Arbeit verstehen und anwenden. Sie sind in der Lage,
die Qualität und Manipulierbarkeit digitalforensischer
Spuren insb. auf Festspeicherdatenträgern
einzuschätzen und kennen Anwendungen, mit Hilfe
derer Spuren untersucht werden können. In einer
Gruppe Studierender kommunizieren Studierende unter
Verwendung von Fachtermini. Sie zeigen, dass sie
digitalforensische Spuren aus Installationen des
Betriebssystems Windows sachkundig erheben,
analysieren, auswerten und dokumentieren können, um
künftig bei der Aufklärung von Vorfällen mitwirken zu
können. Moderne Entwicklungen zur Beobachtung von
Systemen unter Verwendung von Virtualisierung
können sie wiedergeben und erarbeiten Limitierungen
bestehender Lösungen. Darüber hinaus verstehen sie
architekturelle Gegebenheiten von Android-basierten
Smartphones im Hinblick auf die digitalforensische
Bedeutung.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 60 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, 'Methodische Fundierung der digitalen Forensik und
forensischen Informatik • Dokumentation von
forensischen Untersuchungen • Analyse forensischer
Berichte • digitalforensische Spuren in Windows-
Installationen • Endpunktbasierte Erkennung und
Reaktion (EDR) • Einbruchserkennung • Hypervisor •
Smartphone-Forensik');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (101, 1, '• Die Studierenden haben ein fundiertes Verständnis
der theoretischen Hintergründe, Grenzen und
Einsatzszenarien von datenwissenschaftlichen
Verfahren und können diese
Fachwissenschaftler*innen und Fachfremden
erläutern.
• Sie sind in der Lage, den Einsatz
datenwissenschaftlicher Verfahren kritisch zu
hinterfragen und gewissenhaft zu planen.
• Dadurch sind sie in der Lage,
datenwissenschaftliche Verfahren sinnvoll zur
Problemlösung in verschiedenen
Anwendungsszenarien einzubringen und
einzusetzen.', NULL, 'Theoretische Grundlagen und Anwendung
verschiedener
• Regressionsverfahren
• Klassifikationsverfahren
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 27 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
• Clustering-Verfahren
• Bootstrap- und Kreuzvalidierungsverfahren
• Gütekriterien für die Ergebnisse
datenwissenschaftlicher Verfahren');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (117, 1, 'Die Studierenden können die Bedeutung und Wirkung
von Design im Unternehmenskontext einordnen und als
strategisches Instrument einsetzen. Den Studierenden
ist die Planung von Designprojekten vertraut.
• indem Designprozesse im Unternehmensbezug
analysiert werden.
• indem erprobt wird, Designprojekte in der
Unternehmenspraxis sowie als Freiberufler
professionell zu planen, kalkulieren, strukturieren
und professionell zu präsentieren.
• indem der Umgang Designmethoden und
Kreativitätstechniken gelernt wird.
• indem designtheoretisches Wissen erarbeitet und
fundierte Designargumentation geübt wird.
Um die Prozesse und Instrumente des Designs in
Folgeveranstaltungen und -projekten mitzubedenken
und einzusetzen.', NULL, 'Einführung in den Designprozess und das
Designverständnis (Designtheorie), Design im
Unternehmensbezug, Strategisches
Designmanagement (Positionierung und
Designstrategie), Corporate Designmanagement
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 64 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
(Branding), Operationales
Designmanagement/Designmethodik
(Designprojektplanung, Kreativität, Bewertung,
Präsentation); Designbüromanagement
(Designangebot, -kalkulation)
Die Studierenden bereiten selbständig Teilthemen in
Form ausführlicher Referate/Präsentationen auf, die als
Diskussionsbeitrag in der Lerngruppe dienen. Vorrangig
wird Bezug auf aktuellste Literatur genommen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (118, 1, 'Die Studierenden arbeiten sich in aktuelle und
zukunftsweisende Forschungsthemen im Bereich der
IT-Sicherheit und des Datenschutzes ein. Dazu wird in
jedem Semester ein anderes Schwerpunktthema, in
welches sich die Studierenden einarbeiten, den
aktuellen Stand der Technik verstehen und den Stand
der Forschung sukzessive erarbeiten. Dabei sollen die
Studierenden über Kenntnisse, ein Verständnis und
Wissen in den folgenden Themenkomplexen.
• Eigenständige Erarbeitung von vertieften
Kenntnissen über aktuelle Forschungsthemen in der
IT-Sicherheit und des Datenschutzes (Basierend auf
Primärliteratur).
• Kritische Auseinandersetzung mit dem aktuellen
wissenschaftlichen Diskurs bzw. neuen
Erkenntnissen in dem gewählten Themenkomplex
• Identifikation von komplexen Sicherheitsproblemen
und Entwicklung von innovativen Lösungen bzw.
Methodiken.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Präzise Präsentation und Kommunikation von
Forschungsergebnissen.', NULL, '• Die Studierenden lernen den Prozess wie in der
Wissenschaft in der Regel Publikationen bewertet
und veröffentlicht werden (peer-review) kennen.
• Definition und Vorstellung eines Themenkomplexes,
der innerhalb der Veranstaltung von den
Studierenden vertieft und aus unterschiedlichen
Blickwinkeln bearbeitet wird. Die Definition der
Themen soll dabei entlang aktueller
Veröffentlichungen auf führenden wissenschaftlichen
Konferenzen und Journalen zum Thema IT-
Sicherheit und Privatheit erfolgen.
• Die Studierenden stellen aktuelle wissenschaftliche
Veröffentlichungen in dem Themenkomplex der
Gruppe vor
• Die Studierenden diskutieren in der Gruppe die
vorgestellten Arbeiten und können diese so im
größeren Rahmen des gesamtthemenkomplexes
setzen und interpretieren.
• Die Studierenden fertigen eigene Experimente an,
um die vorgestellten Ergebnisse zu demonstrieren.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (102, 1, 'Die Studierenden können erfolgreich in Teamarbeit ein
komplexes wissenschaftsnahes Problem zur
Entwicklung intelligenter Systeme lösen.
Sie sind in der Lage, ihre Resulate kritisch und
methodisch mit SOTA-Ergebnissen zu vergleichen.
Sie sind in der Lage, ihre Ergebnis in der Veranstaltung
und in der Hochschulöffentlichkeit verständlich und
nachvollziehbar vorzustellen und im Diskurs zu
verteidigen.
Wenn möglich, nehmen sie an einem internationalen
Wettbewerb teil und lernen, im Austausch mit anderen
einen Beitrag zum wissenschaftlichen Fortschritt zu
leisten.', NULL, 'Ein laufender oder kürzlich abgeschlossener
Wettbewerb aus dem Themenkreis intelligenter
Informationsverarbeitung oder Optimierung bestimmt in
der Regel die inhaltliche Fokussierung, alternativ kann
ein aktuelles Thema aus der laufenden Forschung zu
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 29 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
intelligenten Systeme vertiefend aufgegriffen werden,
z.B. aus dem Bereich Reinforcement Learning.
In der Vergangenheit wurde in oder in Folge der
Veranstaltung erfolgreich an Wettbewerben
teilgenommen, z.B. PowerTAC (1. Platz) und TAC
(Trading Agent Competition, „Best Newcomer“), Bidding
Agent Competition (Agenten zur Optimierung von
schlüsselwortbasierten Werbekampagnen, 1. Platz)
Discovery Challenge European Conference on Machine
Learning (ECML) zu automatisierter Verschlagwortung,
(2. Platz, Kategorie Freie Schlagwortfindung offline)
Thematische Einarbeitung durch Vorlesung und
Themenvorträge. Praktische Teamarbeit zur
Konzeption und Systemrealisierung.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (85, 1, 'Die Studierende werden in die Lage versetzt:
• die wissenschaftstheoretischen Ansätze der
Betriebswirtschaftslehre zu verstehen und zu
erläutern,
• die wesentlichen Aufgaben der betrieblichen
Funktionalbereiche und deren Interdependenzen zu
verstehen,
• die vermittelten betriebswirtschaftlichen
Vorgehensweisen und Methoden anzuwenden.', NULL, '• Das Unternehmen und seine Rahmenbedingungen
• Konstitutive Entscheidungen und Ziele eines
Unternehmens
• Unternehmensführung
• Organisation
• Marketing
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 90 -
Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Personal
• Finanzwirtschaft
• Investitions- und Wirtschaftlichkeitsrechnung
• Fallbeispiele aus der Unternehmenspraxis');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (103, 1, 'Aufbauend auf Schulkenntnissen aus dem Bereich der
Naturwissenschaften verstehen die Studierenden nach
dem Studium dieses Moduls, welche Bedeutung
neuere Rechnerkonzepte für die moderne Informatik
haben. Durch die Beschäftigung mit der
naturwissenschaftlichen Methodik wurde gleichzeitig
die logisch, analytische Denkweise verbessert und
Problemlösungskompetenz entwickelt.
Dieses Modul trägt dazu bei, die Absolventen ganz
allgemein zu wissenschaftlicher Arbeit und
verantwortlichem Handeln bei der beruflichen Tätigkeit
und in der Gesellschaft zu befähigen.
Insbesondere werden durch dieses Modul die
folgenden Fertigkeiten und Kompetenzen der
Absolventen gestärkt:
Sie sind in der Lage, komplexe Aufgabenstellungen
aus einem neuen oder in der Entwicklung begriffenen
Bereich zu abstrahieren und zu formulieren sowie
Konzepte und Lösungen zu komplexen, zum Teil auch
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 31 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
unüblichen Aufgabenstellungen – ggf. unter
Einbeziehung anderer Disziplinen – zu entwickeln.
Sie haben die Kompetenz, sich systematisch und in
kurzer Zeit in neue Systeme und Methoden
einzuarbeiten, neue und aufkommende Technologien
zu untersuchen und zu bewerten sowie Wissen aus
verschiedenen Bereichen methodisch zu klassifizieren
und systematisch zu kombinieren.
Sie wissen, auf welchen Grundprinzipien
Quantencomputer beruhen und wie man mit dem
Erbgut – der DNA – rechnen kann. Dabei wird die
Biologie − im Bereich der Lebensinformatik − vor allem
verstanden als die Wissenschaft von den komplexesten
Systemen der Informations-verarbeitung, die es nur in
der Natur gibt und deren Übertragung in die Informatik
von großer Bedeutung ist.', 'der Absolventen gestärkt: Sie sind in der Lage, komplexe Aufgabenstellungen aus einem neuen oder in der Entwicklung begriffenen Bereich zu abstrahieren und zu formulieren sowie Konzepte und Lösungen zu komplexen, zum Teil auch', '• Einführung
o Lernhinweise
o Informationen
o Intelligenz
• Molecular Computing
o BioPhysik
o Molekulargenetik
o Epigenetik
o Molekulares Rechnen
• Computational Intelligence
o Neurobiologie
o Neuroinformatik
o Neuromorphie
o Fuzzy-Logik
• Neue Technologien
o Quanten
o Quanteninformatik
o Diverses');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (104, 1, 'Die Studierenden beherrschen die grundlegenden
Konzepte der funktionalen Programmierung (FP) und
können diese für kleine Aufgabenstellungen (in der
Lehrsprache Haskell) sicher anwenden. Sie kennen die
in FP möglichen Realisierungsmuster, z.B. in
Verbindung mit unendlichen Datenstrukturen oder
Monaden. Sie verstehen, dass FP für eine Vielzahl von
Problemen eine elegante, fehlervermeidende und
produktive Form der Programmierung ist. Durch
Termersetzung als Auswertungsmodell gewinnen die
Studierenden einen Einblick in symbolisches Rechnen
und erweiterten zudem ihre Sicht auf den Begriff der
Berechnung. Durch Seitenblicke auf die Sprache Java
erkennen die Studierenden schließlich, dass viele
Konzepte von FP auch in originär nicht funktionalen
Sprachen angewendet werden können. Dadurch
verbessern sie ihre Produktivität und Qualität bei der
Software-Entwicklung in solchen Sprachen.', NULL, 'Ausdrücke, Reduktion und Reduktionsstrategien •
Typen und Typklassen • Currying und Funktionen
höherer Ordnung • Listen, rekursive Datentypen • Fold
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 34 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
für Listen, laws of fold • Unendliche Datenstrukturen •
Programmieren mit lazy evaluation • Monaden •
Praxisbeispiele');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (119, 1, 'Die Studierenden kennen und verstehen die wichtigsten
Theorien zur Motivationsforschung. Sie kennen die
Voraussetzungen und Mechanismen des Lernens und
des Erwerbens von Fertigkeiten.
Die Studierenden kennen wichtige Studien und
Forschungsergebnisse zur Wirksamkeit von Serious
Games und von Gamification.
Die Studierenden kennen Vorgehensweisen für das
Management von Gamifizierungsprojekten. Sie wissen,
welche Entwicklungsdokumente zu erstellen sind und
kennen die dazu nötigen Werkzeuge. Sie kennen die
verschiedenen Rollen in einem Team und deren
Aufgaben im Entwicklungsprozess.
Die Studierenden können einen vorgegebenen
Anwendungs-Gegenstand mit den in der Veranstaltung
behandelten Methoden gamifizieren und dazu ein
detailliertes Konzept vorlegen. Sie sollen in die Lage
versetzt sein, Gamification-Konzeptionen auch für
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 68 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
berufliche oder Forschungs-Kontexte entwickeln zu
können.
Bei solchen Entwicklungen können die Studierenden
auch komplexe Sachverhalte im Hinblick auf
Gamification-Potenzial analysieren. Sie sind in der
Lage, erfolgsentscheidende Randbedingungen beim
Konzeptentwurf umfassend zu berücksichtigen.
Die Studierenden können die Anwendung einzelner
Gamifizierungs-Elemente kontextuell und vor dem
Hintergrund der Erkenntnisse der Motivations- und
Lernforschung begründen. Sie sind zudem in der Lage,
innovative Technologien in ihr Konzept
miteinzubeziehen.', NULL, 'Theorien zur Motivation (z.B. Ryan und Deci, ARCS-
Modell) und die Taxonomie der intrinsischen Motivation
von Lepper und Malone
Grundlagen des Lernens und verschiedene didaktische
Ansätze (z.B. verteiltes Üben, Scaffolding, episodisches
Gedächtnis, soziales Lernen)
Neueste Studien und Forschungsergebnisse zur
Effektivität von Games und Gamification z.B. für das
Lernen, für den Erwerb von motorischen und geistigen
Fertigkeiten, zur Problemlösung, aber auch etwa zur
Beeinflussung von Personen
Unterschiede zwischen Serious Games und
Gamification und Herausarbeitung von Vor- und
Nachteilen für deren Einsatz
Anwendung von Gamification auf unterschiedliche
Lerndomänen und in anderen Kontexten (z.B.
Unterhaltung, Nudging, Werbung)
Management von Gamification-Projekten mit agilen
Methoden wie Scrum, Rollen und ihre Aufgaben im
Entwicklungsteam
Fall-Beispiel: Gamifizierung eines
Anwendungsgegenstandes als Gruppenarbeit (z.B. ein
gymnasialer Lernstoff, ein Erste-Hilfe-Kurs, eine Folge
Trainingseinheiten zur Erreichung eines sportlichen
Zieles). Die Studierenden müssen dabei
Randbedingungen wie z.B. die besondere Förderung
leistungsschwächerer Teilnehmer berücksichtigen. Sie
sollen die allgemeinen Inhalte und die behandelten
Forschungsergebnisse aus der Lehrveranstaltung
berücksichtigen. Sie sollen zudem innovative
Technologien (z.B. moderne Smartphone-Sensorik,
XR-Brillen) in das Konzept miteinbeziehen.
Semesterbegleitend Mitarbeit an einem geteilten
Dokument zur Lehrveranstaltung. Dort werden Fragen
beantwortet und Aufgaben zum Stoff gelöst. Dabei
werden die abstrakten Konzepte des Lehrstoffes über
Beispiele konkretisiert.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 69 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (120, 1, 'Die Studierenden sind in der Lage die
Herausforderungen für die Gestaltung,
Implementierung, Evaluation und Nutzung von
interaktiven kollaborativen Arbeitsumgebungen
analysieren können.
Die Studierenden sind in der Lage, auf dieser Basis für
konkrete Problemstellungen und Arbeitssituationen
Lösungskonzepte zu gestalten und zu bewerten –
sowohl aus Sicht des Benutzers und dessen
Umgebung als auch aus technologischer Perspektive,
insbesondere auch hinsichtlich hybrider
Kollaborationsszenarien.
Die Studierenden können Evaluationskonzepte für
interaktive kollaborative Arbeitsumgebungen verstehen
und anwenden.
Durch eine erfolgreiche Absolvierung dieses Moduls
sind die Studierenden in der Lage, Softwaresysteme
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 71 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
und Technologien für interaktive kollaborative
Arbeitsumgebungen zu entwerfen und zu entwickeln.', NULL, 'Heutige Arbeitsumgebungen sind größtmöglicher
Flexibilität unterworfen. Dabei spielt die dynamische
Zusammenarbeit mehrerer Personen eine
entscheidende Rolle. Folgende Themen werden in
diesem Modul behandelt:
• Grundlagen und Grundbegriffe von Computer-
Supported Cooperative Work Systemen (CSCW)
anhand von Beispielen, Anwendungsfällen und
Vorgehensmodellen.
• Überblick der Kerndimensionen der CSCW (z.B.
Awareness, Coordination, Articulation work,
Appropriation) und deren Implikation für die
Gestaltung und Umsetzung von interaktiven
kollaborativen Arbeitsumgebungen.
• Herausforderungen und Techniken für die
technische Umsetzung von interaktiven
kollaborativen Arbeitsumgebungen
• Evaluationsmethoden für interaktive kollaborative
Arbeitsumgebungen.
In der Vorlesung werden die theoretischen Inhalte
vermittelt. Im Rahmen eines Projekts werden die
Studierenden eigene Konzepte für interaktive
kollaborative Arbeitsumgebungen entwickeln und
prototypisch umsetzen');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (105, 1, 'Die Studierenden kennen grundlegende Methoden und
Strukturen aus ausgewählten Kapiteln der künstlichen
Intelligenz und können diese zur Konstruktion
intelligenter Systeme anwenden.
Sie sind insbesondere in der Lage, durch Abstraktion
und Modellbildung Problemstellungen zu analysieren,
Zusammenhänge zu vorhandenem Wissen zu
erkennen und entsprechende Lösungsansätze zu
identifizieren und umzusetzen.
Sie sind mit der Problematik der Interpretation von
Modellen und den Risiken ihres Einsatzes vertraut und
können Ansätze, diese Risiken zu bewerten und zu
minimieren, analysieren und kritisch hinterfragen.', NULL, 'Einführendes: Geschichte der KI, ausgewählte aktuelle
Forschungsansätze.
Grundlegendes: Problemlösung mit exakter und
heuristischer Suche, Constraint
Satisfaction/Optimization. Problemmodellierung und -
lösung mit Logik und Wahrscheinlichkeiten.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 36 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
Lernen und intelligente Informationsanalyse: klassische
Verfahren (Kategorisierung, Clustering: u.a. Naive
Bayes, Decision Trees, EM), stochastische Verfahren
(Hidden Markov, POMDP), naturanaloge Verfahren
(NN, Deep-NN).
Optimierung von Handlungssequenzen: Adversarial
Search, DP und Reinforcement Learning, inkl. Deep-
RL.
Interpretierbarkeit von Modellen, ethische und
gesellschaftliche Konsequenzen des Einsatzes von
intelligenten Systemen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (121, 1, '• Gutes Verständnis von möglichen Angriffen und
geeigneten Gegenmaßnahmen im Bereich der
Internet-Infrastruktur
• Erlangen von Kenntnissen über den Aufbau, die
Prinzipien, die Architektur und die Funktionsweise
von Sicherheitskomponenten und -systemen im
Bereich Frühwarn- und Infrastruktur-
Sicherheitssystemen
• Sammeln von Erfahrungen bei der Ausarbeitung und
Präsentation von neuen Themen aus dem Bereich
Internet-Sicherheit
• Gewinnen von praktischen Erfahrungen über die
Nutzung und die Wirkung von Sicherheitssystemen
im Bereich der Internet-Infrastruktur
• Erleben der Notwendigkeit und Wichtigkeit der
Internet-Sicherheit
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 73 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, '• Cyber-Sicherheit Frühwarn- und Lagebildsysteme
• Firewall-Systeme: Definition, Elemente, Konzepte,
praktischer Einsatz, die Wirkung und die
Mög lichkeiten und Grenzen von Firewall-Systemen
• IPSec-Verschlüsselung - VPN-Systeme: Ziele,
Anwendungsformen, Konzepte, Mechanismen und
Protokolle von VPNs und Anwendungsbeispiele
• Transport Layer Security (TLS): Idee, Mechanismen,
Protokolle und Umsetzungskonzepte
• Cyber-Sicherheitsmaßnahmen-gegen-DDoS-Angriffe
• Wirtschaftlichkeit von Cyber-Sicherheitsmaßnahmen
• Social-Web-Cyber-Sicherheit
• Vertrauen und Vertrauenswürdigkeit');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (122, 1, '• Gutes Verständnis von möglichen Angriffen und
geeigneten Gegenmaßnahmen im Bereich der
Endgeräte und Anwendungen
• Erlangen von Kenntnissen über den Aufbau, die
Prinzipien, die Architektur und die Funktionsweise
von Sicherheitskomponenten und -systemen im
Bereich Trusted Computing und PKI- und
Blockchain-orientierten Sicherheitssystemen
• Sammeln von Erfahrungen bei der Ausarbeitung und
Präsentation von neuen Themen aus dem Bereich
Internet-Sicherheit
• Gewinnen von praktischen Erfahrungen über die
Nutzung und die Wirkung von Sicherheitssystemen
im Bereich Trusted Computing und PKI- und
Blockchain-orientierten Sicherheitssystemen
• Erleben der Notwendigkeit und Wichtigkeit der
Internet-Sicherheit
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 75 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, '• Digitale Signatur: Gesetzliche Grundlagen,
Mechanismen und Prinzipien, Anwendungsbeispiele
• Public-Key-Infrastruktur (PKI): Aufgaben,
Komponenten, gesetzlicher Hintergrund, Modelle,
Umsetzungskonzepte und praktische Beispiele
• Blockchain-Technologie: Aufgaben, Komponenten
und Eigenschaften, Umsetzungskonzepte und
praktische Beispiele
• Künstliche Intelligenz für Cyber-Sicherheit:
Einordnung und Definitionen, Maschinelles Lernen,
Künstliche Neuronale Netze, Anwendungen KI und
Cyber-Sicherheit, Angriffe auf maschinelles Lernen
und Herausforderungen
• Trusted Computing
- TPM (Aufbau und Funktionen)
- TC Funktionen (Trusted Boot, Binding, Sealing,
and(Remote) Attestation),
- Trusted Computing Base
- Sicherheitsplattform (Idee, Ziele, Methoden, …)
- Anwendungsbeispiele
• Trusted Network Connect (TNC)
- grundsätzliche Idee
- TNC Architektur
- T-NAC (Idee, Ziele, Methoden, …)
• E-Mail-Security: Elemente, Konzepte und praktischer
Einsatz
• Anti-Spam-System: Schäden, Quellen; Anti-Spam-
Technologien, Kopfzeilenanalyse, Textanalyse,
Blacklist, Distributed Checksum Clearinghouse
(DCC), Distributed IP Reputation System, usw.
• Botnetze: Malware, Infektionsvektoren, Botnetzen,
Schadfunktionen durch Bots und Gegenmaßnahmen');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (123, 1, 'Die Studierenden
• verstehen fortgeschrittene
Implementationskonzepte für gebrauchstaugliche
interaktive Systeme
• können Anwendungssoftware in Hinblick auf
Lokalisierung und Zugänglichkeit entwerfen
• können Interaktive Systeme so implementieren,
dass Mehrsprachigkeit und länderspezifische
Gegebenheiten unterstützt werden
• verstehen die Konzepte assistiver Techniken bei
der Entwicklung von interaktiven Systemen
• können interaktive Systeme so implementieren,
dass Zugänglichkeit / Barrierefreiheit
gewährleistet ist
• können einfache assistive Techniken in
interaktiven Systemen programmieren
• verstehen die Möglichkeiten der Anpassung des
Aussehens von interaktiven Systemen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 78 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• können das Aussehen eines interaktiven Systems
an Vorgaben eines Style Guide anpassen', NULL, '• Anforderungen der Gebrauchstauglichkeit
• Anforderungen eines „Design for all“
• Rechtliche Vorgaben für Gebrauchstauglichkeit,
Barrierefreiheit und Individualisierbarkeit
• Benutzeranalyse in Hinblick auf Sprache sowie
länderspezifische und kulturelle Unterschiede
• Benutzeranalyse in Hinblick auf besondere
Bedürfnisse
• Konzepte für Internationalisierung und Lokalisierung
• Implementation von GUIs mit Internationalisierung
und Lokalisierung (z.B. mit Java FX)
• Konzepte für Barrierefreiheit und Zugänglichkeit
Implementation von barrierefreien GUIs (z.B. mit
Java FX)
• Änderung des Aussehens eines GUI (z.B. in Java
FX)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (92, 1, 'Die/der Studierende ist in der Lage, die Ergebnisse
ihrer/seiner Masterarbeit aus der praktischen oder
technischen Informatik, ihre fachlichen Grundlagen, ihre
Einordnung in den aktuellen Stand der Technik, bzw.
der Forschung, ihre fächerübergreifenden
Zusammenhänge und ihre außerfachlichen Bezüge in
begrenzter Zeit in einem Vortrag zu präsentieren.
Darüber hinaus kann sie/er Fragen zu inhaltlichen
Details, zu fachlichen Begründungen und Methoden
sowie zu inhaltlichen Zusammenhängen zwischen
Teilbereichen ihrer/seiner Arbeit selbstständig
beantworten.
Die/der Studierende kann ihre/seine Masterarbeit auch
im Kontext beurteilen und ihre Bedeutung für die Praxis
und die Forschung einschätzen und ist in der Lage,
auch entsprechende Fragen nach themen- und
fachübergreifenden Zusammenhängen zu beantworten.', NULL, 'Zunächst wird der Inhalt der Masterarbeit aus der
praktischen oder technischen Informatik im Rahmen
eines Vortrags präsentiert. Anschließend sollen in einer
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 7 -
Informatik (Master) – PO2023 Modulkatalog
Diskussion Fragen zum Vortrag und zur Masterarbeit
beantwortet werden.
Die Prüfer können weitere Zuhörer zulassen. Diese
Zulassung kann sich nur auf den Vortrag, auf den
Vortrag und einen Teil der Diskussion oder auf das
gesamte Kolloquium zur Masterarbeit erstrecken.
Der Vortrag soll die Problemstellung der Masterarbeit,
die vergleichende Darstellung alternativer oder
konkurrierender Lösungsansätze mit Bezug zum
aktuellen Stand der Technik, bzw. Forschung, den
gewählten Lösungsansatz, die erzielten Ergebnisse
zusammen mit einer abschließenden Bewertung der
Arbeit sowie einen Ausblick beinhalten. Je nach Thema
können weitere Anforderungen hinzukommen.
Die Dauer des Kolloquiums ist in § 26 der Master-
Rahmenprüfungsordnung und § 16 der
Studiengangsprüfungsordnung geregelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (106, 1, 'Die Studierenden kennen die Konzepte der logischen
Programmierung. Sie sind in der Lage, Probleme
deklarativ zu beschreiben und hierfür logische
Programme mit der Programmiersprache Prolog zu
entwickeln.
Sie kennen die Theorie der logischen Programmierung
und können sowohl die deklarative als auch die
prozedurale Semantik logischer Programme im Detail
erläutern. Sie können die Unterschiede der
prozeduralen Semantik zur Auswertungsstrategie von
Prolog benennen und begründen, wie diese
Abweichungen zustande kommen.
Mit Kenntnissen der logischen Programmierung sind
die Teilnehmer später besser in der Lage, Probleme auf
einem höheren Abstraktionsniveau zu beschreiben und
damit die Problemanalyse vom Entwurf einer
Problemlösungsstrategie besser zu trennen.', NULL, 'Während in der imperativen Programmierung mit
Programmen alle Schritte festgelegt werden, die der
Computer in der angegebenen Reihenfolge
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 38 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
auszuführen hat, wird in der logischen Programmierung
das zu lösende Problem nur beschrieben und die
Lösungsfindung einem Auswertungssystem überlassen.
Inhalte der Vorlesung sind:
• Problemlösen mit Prolog: Auswertungsstrategie,
Unifikation, Backtracking.
• Programmiertechniken: Generate & Test,
Relationen, Datenstrukturen als Fakten,
Musterorientierte Wissensrepräsentation
• Theorie der logischen Programmierung:
Prädikatenlogik 1. Ordnung, Deklarative
Semantik, SLD-/SLDNF-Resolution
• Nicht-logische Bestandteile von Prolog: Negation
und Cut
• Sprachverarbeitung in Prolog: Grammatiken und
Parsergenerierung
• Ausblick Constraint-logische Programmierung');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (93, 1, 'Die/der Studierende ist in der Lage, innerhalb einer
vorgegebenen Frist entweder
eine schwierige und komplexe praxisorientierte
Problemstellung aus der praktischen Informatik sowohl
in ihren fachlichen Einzelheiten als auch in den themen-
und fachübergreifenden Zusammenhängen nach
wissenschaftlichen Methoden selbständig zu bearbeiten
und zu lösen oder
eine anspruchsvolle Fragestellung aus der aktuellen
Forschung auf dem Gebiet der praktischen Informatik
unter Anleitung eigenständig zu bearbeiten und
selbstständig ein neues wissenschaftliches Ergebnis zu
entwickeln.', NULL, 'Es wird eine praxisorientierte Problemstellung oder eine
Fragestellung aus der Forschung auf dem Gebiet der
praktischen Informatik mit den im Studium erworbenen
oder während der Masterarbeit neu erlernten
wissenschaftlichen Methoden in begrenzter Zeit mit
Unterstützung eines erfahrenen Betreuers gelöst.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 9 -
Informatik (Master) – PO2023 Modulkatalog');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (107, 1, 'Students know
• nature of distributed systems
• Software frameworks
• OSGi components
• Students will understand
• the notion of an agent, how agents are distinct from
other software paradigms (e.g., objects), and
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 40 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
understand the characteristics of applications that
lend themselves to an agent-oriented solution;
• the key issues associated with constructing agents
capable of intelligent autonomous action, and the
main approaches taken to developing such agents;
• the key issues and approaches to high-level
communication in multi-agent systems;
• the key issues in designing societies of agents that
can effectively cooperate in order to solve problems;
• the main application areas of agent-based solutions;
• the main techniques for automated decision-making
in multi-agent systems, including techniques for
voting, forming coalitions, allocating scarce
resources, and bargaining.
• Students are able to develop multi-agent systems
using OSGi components', NULL, '• Multi-Agent Systems
• Introduction: what is an agent: agents and objects;
agents and expert systems; agents and distributed
systems; typical application areas for agent systems.
• Intelligent Agents:
abstract architectures for agents; tasks for agents.
the design of intelligent agents: reasoning agents,
agents as reactive systems ; hybrid agents, layered
agents
• Multiagent Systems:
• ontologies: OWL, KIF, RDF;
• interaction languages and protocols: speech acts,
KQML/KIF, the FIPA framework;
• cooperation: cooperative distributed problem solving
(CDPS), partial global planning; coherence and
coordination; applications.
• Multi-Agent Decision Making
• OSGi
• OSGi components
• OSGi in MAS');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (108, 1, '• Die Studierenden kennen Cloud Technologien in
einer größeren Bandbreite und haben die Fähigkeit,
verschiedenen Cloudansätze für einen gegebene
Aufgabenstellung zu bewerten und die geeignete
auszuwählen
• Die Studierenden kennen verschieden
Mobilfunktechniken in einer größeren Bandbreite
und haben die Fähigkeit, verschiedene mobile
Anbindungsmöglichkeiten für eine gegebene
Aufgabenstellung zu bewerten und die geeigneten
auszuwählen.
• Die Studierenden erwerben die Kompetenz, neue
Entwicklungen im Bereich Cloud und Mobilfunk zu
verstehen, zu bewerten und für ihre Arbeit nutzbar
zu machen.', NULL, '• Vertiefte Betrachtung zu Cloud Technologien.
• Azure Cloud mit Anwendungsszenarien als Beispiel.
• Grundlagen zu Software Defined Networking.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 43 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
• Use Case getriebene Entwicklung von
Mobilfunknetzen und deren Ausprägung am Beispiel
5G.
• Praktikum mit Themen aus dem Bereich Cloud am
Beispiel der Azure Cloud und zu Mobile Computing
am Beispiel von LTE und 5G');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (60, 1, 'Die Studierenden sind in der Lage, durch
wissenschaftliches Vorgehen für praktische
Problemstellungen den Stand der Technik zu
recherchieren, Anforderungen zu analysieren, Lösungen
zu entwickeln und zu begründen sowie
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 33 -
Informatik (Bachelor) – PO2023 Modulkatalog
Arbeitsergebnisse professionell zu präsentieren und zu
bewerten.
Sie können die in der Vorlesung zu diesem Modul
erlernten grundlegenden Management-Methoden
zur Projektdefinition, -planung und -kontrolle bei
der Projektarbeit anwenden und sind in der Lage,
Besprechungen zu moderieren und zu protokollieren.
Die Studierenden haben ein Grundverständnis für die
Aufgaben und Erfolgsfaktoren bei der Durchführung
eines mittelgroßen Software-Projekts in einem Team.
Sie sind in der Lage das bisher im Studium Erlernte –
insbesondere Methoden, Verfahren und Werkzeuge –
anzuwenden, um ein komplexes Softwareprojekt von
der Anforderungsanalyse über Entwurf,
Implementierung und Evaluierung bis hin zur
Auslieferung selbstständig und im Team von 5 bis 8
Studierenden zu bewältigen.
Die Studierenden können komplexe Aufgaben sinnvoll
strukturieren und typische Schnittstellenprobleme so-
wohl auf technisch-fachlicher als auch auf sozialer
Ebene bewältigen.', NULL, 'Der Vorlesungsteil wird als globale Veranstaltung für
alle Teilnehmer abgehalten und führt in die Grundlagen
des wissenschaftlichen Arbeitens und des
Managements von Softwareprojekten ein.
Zum wissenschaftlichen Arbeiten gehören:
• Recherche
• Analyse
• Erstellen wissenschaftlicher Texte
• Präsentation
Der Vorlesungsteil wird als globale Veranstaltung für
alle Teilnehmer abgehalten und führt in die Grundlagen
des Managements von Softwareprojekten ein. Hierzu
gehören:
• Dateiorganisation, Protokolle
• Projektdefinition
• Projektplanung
• Konfigurationsmanagement
• Projektkontrolle und -steuerung
• Projektabschluss
Im Praktikumsteil steht die systematische Anwendung
und Zusammenführung von in
Vorgängerveranstaltungen erlerntem Wissen im
Vordergrund:
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 34 -
Informatik (Bachelor) – PO2023 Modulkatalog
• Durchführung eines mittelgroßen und
anspruchsvollen Software-Projekts
• Selbstständige Durchführung des Projekts von der
Analyse über Design, Implementierung und Test
bis zur Dokumentation
• Anwendung von grundlegenden
Projektmanagement-Methoden für Definition,
Planung, Kontrolle und Realisierung des Projekts.
• Vertiefung von Programmierkenntnissen
• Nutzung von Versionsmanagementwerkzeugen
und Ticketsystemen
• Softwareentwicklung im Team und ggf. unter
Beteiligung von externen Anwendern
• In regelmäßigen Projektsitzungen werden im
Rahmen einer Qualitätssicherung die
Zwischenergebnisse von den Teams durch
Präsentation und Vorführung vorgestellt und
diskutiert.
Die Projektthemen werden rechtzeitig vor Beginn der
Veranstaltung bekannt gemacht. Es wird versucht,
praxisnahe Projekte, ggf. auch von hochschulexternen
Anwendern der praktischen und technischen Informatik
zu akquirieren. Projektvorschläge von Studierenden
sind nach Absprache ebenfalls möglich.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (124, 1, 'Die Studierenden vertiefen die Konzepte zur Analyse
von Schadsoftware (Malware) und zur Erkennung von
Angriffswerkzeugen. Anhand realer Cyber-Angriffe
wenden sie aktuelle Methoden zur technischen Analyse
der Artefakte wie Schadsoftware-Samples oder
Netzwerkmitschnitten an. Sie erkennen auf diese Weise
die Limitierungen aktueller Methoden und entwickeln
eigene Forschungsfragen. Darüber hinaus eignen sie
sich selbst neues Wissen über das Studium
bestehender Berichte zu vergangenen Vorfällen an und
lernen Bewertungskriterien zur Einschätzung der
Berichte zu entwickeln und anzuwenden sowie kritisch
zu hinterfragen. Methode zur Attribution von Akteuren
hinter Cyber-Angriffen müssen angewendet werden
und eine geopolitische Einordnung wird betrachtet. Im
Rahmen der Veranstaltung wird abschließend anhand
eines realen Cyber-Angriffs die Analyse und die
Kommunikation der Analyse-Ergebnisse in Form eines
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 82 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
Threat Intelligence Berichts sowie einer dazugehörigen
Präsentation vertieft.', NULL, 'Malware-Analyse • Malware-Erkennung und -
Klassifikation • Signaturen • Exploit-Dokumente •
Shellcode • Unpacking und Speicherabzüge • Anti-
Analyse-Verfahren von Malware • Cyber kill chain •
Cyber Threat Intelligence • Analysis of Competing
Hypothesis • Angriffsvektoren •
Netzwerkkommunikation • Attribution • Threat Actor');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (109, 1, 'Die Studierenden haben ein fundiertes Verständnis der
mathematischen Grundlagen neuronaler Netze.
Dadurch sind sie in der Lage, Methoden des
maschinellen Lernens zu verstehen, weiterzuentwickeln
und informierte Entscheidungen bezüglich deren
Anwendung zu treffen.', NULL, '• Einführung in mehrdimensionale Analysis,
Wiederholung von Aktivierungsfunktionen
• Matrizenrechnung im Kontext neuronaler Netze
• Backpropagation, Fehlerfunktionen und
Gradientenabstiegsverfahren
• Stochastische neuronale Netze
• Exkurs: Physics informed neural networks');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (94, 1, 'Die Studierenden haben ein tieferes Verständnis für die
Aufgaben und Erfolgsfaktoren bei der Durchführung
eines mittelgroßen Software-Projekts in einem Team.
Sie sind in der Lage, das im Studium bisher Erlernte –
insbesondere Methoden, Verfahren und Werkzeuge –
anzuwenden, um ein komplexes Softwareprojekt von
der Anforderungsanalyse über Entwurf,
Implementierung und Evaluierung bis hin zur
Auslieferung selbstständig und im Team zu bewältigen.
Die Studierenden können komplexe Aufgaben sinnvoll
strukturieren und typische Schnittstellenprobleme
sowohl auf technisch-fachlicher als auch auf sozialer
Ebene bewältigen. Sie können Management-Methoden
zur Projektdefinition, -planung und -kontrolle bei der
Projektarbeit anwenden.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 11 -
Informatik (Master) – PO2023 Modulkatalog
Sie sind in der Lage, Besprechungen zu moderieren
sowie Arbeitsergebnisse professionell zu präsentieren
und zu bewerten.', NULL, 'Im Rahmen des Master-Projektes Informatik bearbeiten
die Teilnehmer eine typische größere Aufgabenstellung
aus dem Bereich der praktischen Informatik oder der
technischen Informatik in einem Projektteam. Die
Themenstellung erfolgt mit Rücksicht auf die
Kenntnisse der Studierenden.
Bei der Durchführung des Projektes steht die
systematische Anwendung und Zusammenführung des
Wissens aus dem jeweiligen Fachgebiet mit den
Methoden der Softwareentwicklung im Vordergrund:
Durchführung eines mittelgroßen und anspruchsvollen
Software-Projekts aus dem Gebiet der praktischen oder
technischen Informatik.
Selbstständige Durchführung des Projekts von der
Analyse über Design, Implementierung und Test bis zur
Dokumentation
Anwendung von grundlegenden Projektmanagement-
Methoden für Definition, Planung, Kontrolle und
Realisierung des Projekts.
Vertiefung von Kenntnissen in der Programmierung und
zu Programmiermethodiken
Softwareentwicklung im Team und ggf. unter
Beteiligung von externen Anwendern
In regelmäßigen Projektsitzungen werden im Rahmen
einer Qualitätssicherung die Zwischenergebnisse von
den Teams durch Präsentation und Vorführung
vorgestellt und diskutiert.
Die Projektthemen werden rechtzeitig vor Beginn der
Veranstaltung bekannt gemacht. Es wird versucht,
praxisnahe Projekte auch von hochschulexternen
Anwendern der praktischen und technischen Informatik
zu akquirieren. Projektvorschläge von Studierenden
sind nach Absprache ebenfalls möglich.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (95, 1, 'Die Studierenden erwerben die folgenden Fähigkeiten:
Sie sind in der Lage, sich selbstständig in aktuelle
Forschungsfragen zur Informatik auf der Basis von
Primärliteratur (Publikationen in Fachzeitschriften sowie
Tagungsbeiträge) einzuarbeiten.
Sie können Informationsrecherchen zu
forschungsorientierten Fragestellungen durchführen
und sind in der Lage, dazu eine strukturierte schriftliche
Aufbereitung des aktuellen Stands der Forschung zu
erarbeiten.
Sie können eine zusammengefasste Darstellung der
Ergebnisse zu einer Fragestellung präsentieren sowie
in der Diskussion mit allen Seminarteilnehmern sich
ergebende Fragen beantworten und aufgestellte
Thesen angemessen verteidigen.', NULL, 'In diesem Seminar werden aktuelle oder zu vertiefende
Themen aus der Informatik behandelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (110, 1, 'Die Studierenden beherrschen den theoretischen und
praktischen Umgang mit verschiedenen
Datenbankformaten und deren Anfragesprachen.
Die Studierenden sind in der Lage, NOSQL-
Datenbanken unter Einsatz des entsprechenden DB-
Supports zu benutzen und zu entwickeln.', NULL, '• Aktuelle Datenbankformate (über das relationale DB-
Modell hinaus) und deren Anwendungsfälle in der
Praxis
• Überblick nicht-relationale / NOSQL Datenbanken
und deren Anfragesprachen
• Vor- und Nachteile der verschiedenen Formate
• Wahlweise eines oder mehrerer der folgenden
Themenkomplexe: Information Retrieval,
Graphdatenbanken, Ontologien, Grenzen von
Datenbanken, wichtige Ergebnisse der DB-Theorie');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (125, 1, 'Studierende
• können den Begriff „Natural User Interface“
definieren und die Kritik daran wiedergeben
• kennen die unterschiedlichen Interaktionstechniken
bei NUIs (Gesten, Sprache etc.)
• können NUIs für bestimmte Anwendungen (z.B. im
Bereich Edutainment) konzipieren
• können Benutzerschnittstellen mit bestimmten NUI-
Interaktionstechniken implementieren.', NULL, '• Begriffsklärung „Natural User Interface“
• Gestenbasierte 2-D-Interfaces
• Gestenbasierte 3-D-Interfaces
• Sprachbasierte Interfaces
• Multimediale und multimodale Interfaces Usability
und User Experience von NUIs
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 84 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (126, 1, 'Die Studierenden lernen verschiedene Ansätze kennen,
wie Technologien entwickelt und eingesetzt werden
können, um die Privatsphäre von Nutzerinnen und
Nutzern zu steigern bzw. zu schützen. Außerdem
werden Konzepte vorgestellt, wie Technologien
privatsphärenfreundlich entwickelt werden können
(„Privacy-by-Design“). In dem Modul sollen die
Studierenden Kenntnisse, Verständnis und Wissen in
den folgenden Themenkomplexen erlernen
• Weltweite rechtliche Rahmenbedingungen bezüglich
der Sammlung, Verarbeitung und Speicherung von
personenbezogenen Daten.
• Verständnis der grundlegenden Konzepte und
Techniken zur Verbesserung der Privatsphäre.
• Fähigkeit zur Bewertung und Implementierung von
PET in verschiedenen Kontexten.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 86 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Gängige Methoden und Gegenmaßnahmen zur
Verfolgung („user tracking“) von Nutzerinnen und
Nutzern im Internet.
• Methodiken zur anonymen Kommunikation und zur
Verarbeitung von verschlüsselten Daten.
• Eigenständige Entwicklung von „Privacy Enhancing
Technologies“ basierend auf aktuellen
Forschungsthemen (basierend auf Primärliteratur).', NULL, 'Grundlagen
• Gesetzliche Rahmenbedingungen (z.B. DSGVO,
CCPA/CPRA)
• Ethische Aspekte des Datenschutzes
• Definition von Grundbegriffen (z.B. Anonymität oder
Pseudonymität)
User Tracking im Internet
• Third-party Tracking Methoden: Cookie-basiertes
Tracking, Browser-Fingerprinting, u.Ä.
• First-Party Tracking: Server-side Tracking, CNAME
Cloaking, u.Ä.
• Einwilligungserklärungen: Methodiken zur
Verwaltung von Einwilligungserklärungen, gängige
Praktiken zur Einholung von
Einwilligungserklärungen, u.Ä.
• Privatheit im Web messen: Generelle Ansätze zur
Messung des Webs, Design von Messtudien für
Webanwendungen und Testen von Webseiten
Anonyme Kommunikation
• Das Tor-Netzwerk: Architektur und Funktionsweise,
Erläuterung der verschiedenen Knotenarten (Entry
Node, Relay Node, Exit Node), Onion Routing,
Sicherheitsmerkmale und Schwachstellen
• Mixnets: Erläuterung des Konzepts von Mixnets und
deren Unterschiede zu Tor, Mix-Kaskaden, Analyse
der Sicherheitsmerkmale und Anonymitätsgarantien
von Mixnets, typische Anwendungen und
Einsatzmöglichkeiten von Mixnets
• Traffic-Analyse: Durchführung und Auswertung von
Traffic-Analysen zur Untersuchung der Anonymität,
Testen der Verbindung über das Tor-Netzwerk
Privacy by Design
• Prinzipien und Best Practices des Datenschutzes
durch Design
• Datenschutzfreundliche Architektur, Datenschutz-
Folgenabschätzung (PIA), Auditing
Kryptographische Ansätze
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 87 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Homomorphe Verschlüsselung: Grundlagen der
homomorphen Verschlüsselung; Arten und
Anwendungen (insb. teilweise homomorphe
Verschlüsselung und voll homomorphe
Verschlüsselung)
• Secure Multi-Party Computation (SMPC): Konzepte
und Protokolle der sicheren
Mehrparteienberechnung (z.B. Yao''s Garbled
Circuits oder Secret Sharing)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (127, 1, 'Die Studierenden beherrschen die grundlegenden
Konzepte der Speichersicherheit (Memory Safety) und
kennen Methoden und Techniken, um effizient
zuverlässige Software hoher Qualität für sich schnell
ändernde und wachsende Anforderungen zu erstellen.
Dies gilt insbesondere für Anwendungen mit hohen
Anforderungen an Sicherheit und Verlässlichkeit.
Beispielhafte Umsetzungen erfolgen mit modernen
Programmiersprachen, etwa Rust. Darüber hinaus
wenden sie Techniken zum Aufbau von sicheren IT-
Infrastrukturen an.', NULL, 'Test-Driven Design • Memory Safety • Inversion of
Control • Convention over Configuration • Programming
by Contract • Nebenläufige Programmierung •
Software-Schwachstellen durch
Speicherschutzverletzungen • System-
Schutzmechanismen • Type Safety •
Speicherzugriffsfehler • Garbage Collection •
Generische Programmierung • Fehlerbehandlung
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 89 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (111, 1, 'Die Studierenden lernen erweiterte Algorithmen und
Bibliotheken von Autonomen Systemen, Multi-Agenten
und Schwarmsystemen sowie die Konzepte und
Methoden der Programmierung kennen und können
diese effektiv und strukturiert bei der Entwicklung eigener
Anwendungen einsetzen. Sie gehen sicher mit der
problemspezifischen Auswahl von Verfahren des
maschinellen Lernens um und wissen, welchen Einfluss
und welche Grenzen die Architekturen haben. Die
Studierenden sind zudem in der Lage, sich selbstständig
und zügig in unterschiedliche Arten von erweiterten
Algorithmen Autonomer Systeme und deren
Programmierumgebung einzuarbeiten.', NULL, '• Transfer Learning
• Rettungsrobotik
• Kooperierende Roboter – Fliegende Roboter
• Adaptivität und Maschinelles Lernen
• Generator Netze, Auto Encoder, Deep Reinforcment
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 49 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
Learning, LSTMs, Omni Depth, Ensemble Learning,
StyleGAN
• Wissensrepräsentation – Roboterkontrollarchitekturen
• Lehrsprache C / C++, Python. ipython notebooks,
scikit-learn');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (128, 1, 'Die Studierenden beherrschen die grundlegenden
Konzepte des Software Reverse Engineering und
können einige statische und dynamische Methoden zur
Programmanalyse zur Lösung überschaubarer,
praktischer Aufgaben sicher anwenden. Sie kennen
gewisse Elemente von Maschinensprachen, insb. Intel
x86, amd64 oder ARM, sowie zur Umsetzung gewisser
Hochsprachen-Idiome in Maschinencode-
Entsprechungen. Durch exemplarische Anwendung der
Methoden werden praktische Erfahrungen zur
Schadsoftware-Analyse gesammelt und ein
grundlegendes Verständnis zur Vorgehensweise von
Cyber-Angreifern erlangt. Darüber hinaus erfahren sie
die Grenzen der Programmanalyse beispielsweise bei
obfuskiertem Binärcode und können abstrakte
Repräsentationen von Programmen, etwa in
Kontrollflussgraphen, erstellen und zur Problemlösung
nutzen. Gegebenenfalls werden die Kenntnisse im
Rahmen eines Capture-The-Flag-Wettbewerbs
angewendet und vertieft.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 91 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, 'Maschinensprache und Assemblersprache für die Intel
x86-Architektur • Wiederholung wichtiger
Betriebssystemaspekte am Beispiel von Windows oder
Linux • Methoden zur statischen Code-Analyse •
Disassemblierung • Erkennung von C-
Hochsprachenkonzepten in Maschinencode •
Kontrollflusskonstrukte und Kontrollflussgraphen •
Dekompilation • Abbildung von C++-
Hochsprachenkonzepten (Vererbung, Virtual Function
Calls) in Maschinencode • Methoden zur dynamischen
Code-Analyse • Debugging • Hooking • Binary
Instrumentation • Emulation • Grundlagen der
Schadsoftware-Analyse');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (112, 1, '• Students know
• Software frameworks and their structure
• Architectural patterns
• Quality and process improvement
• Students understand
• how software frameworks are the basis for reuse
and advanced software development
• Students are able to
• develop large software systems using frameworks
and other reuse oriented software engineering
methods
• Students can use this knowledge to evaluate proper
methods and tools for a given context for optimized
development of large software systems
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik', NULL, '• Advanced Software Engineering
• Reuse as a foundation for the development of large
software systems
• Frameworks
• Structure of frameworks
• Inversion of Control (IoC)
• Meta-frameworks
• Model-driven software engineering (MDSE)
• Model driven architecture (MDA)
• Domain Specific Languages (DSL)
• Object Constraint Language (OCL)
• Software families / software product lines
• Software architecture
• Software quality management
• Process improvement
• Introduction into formal specification
• Future directions of Software Development
• The future of the internet
• Enterprise 2.0');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (129, 1, 'Die Studierenden:
• können Strategien und integrierte Konzepte im Sinne
des Multi-, Cross- und Omni-Channel-Marketing auf
Grundlage der unternehmerischen
Rahmenbedingungen entwickeln bzw. gestalten und
umsetzen, um in einer durch VUKA geprägten Welt
erfolgsorientierte Marketingkonzepte zu realisieren.
• sind in der Lage die diversen und sich ständig
verändernden An- und Herausforderungen der
Marketing-Intelligence durch den zielgerichteten
Einsatz analytischer Methoden zu bewältigen, damit
sie befähigt werden, die Erkenntnisorientierung der
Datenanalyse in den Vordergrund des
unternehmerischen Handelns zu stellen.
• kennen die aktuelle Technologielandschaft und
erforderlichen IT-Architekturen zur Umsetzung von
analytischen Prozessen sowie zur Durchführung und
Kontrolle entsprechender digitaler
Marketingkampagnen, um Softwarewerkzeuge und
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 93 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
informationstechnologische Hilfsmittel gemäß der
Anforderungen begründet auszuwählen,
• verstehen die qualitativen und quantitativen
Methoden zur analytischen Auswertung und können
diese zielorientiert einsetzen und interpretieren, um
logische Schlussfolgerungen und unternehmerische
Handlungsmöglichkeiten im Kontext des digitalen
Marketing ableiten zu können,
• kreieren und kontrollieren strategische Konzepte
sowie sowie operative Prozesse des digitalen
Marketings auf Basis von analytischen und
zielorientierten Vorgehensweisen, damit sie die
Wirtschaftlichkeitsorientierung im Unternehmen
fachlich vertreten können,
• verstehen die Technologie und den Aufbau
moderner CRM-Systeme und sind in der Lage
analytische Softwareapplikationen anzubinden, um
Kundenbeziehungen datenbasiert auszuwerten und
entsprechendes Optimierungspotenzial bei der
Gestaltung und Pflege von Kundenbeziehungen zu
identifizieren,
• können Probleme im Hinblick auf Datenqualität
erkennen und kennen rechtliche
Rahmenbedingungen von datengetriebenen
Marketingkonzepten bzw. Geschäftsmodellen, um
die analytischen Methoden einwandfrei anwenden
zu können und ein rechtskonformes
unternehmerisches Handeln zu gewährleisten.', NULL, '1. Entscheidungsgrundlagen im Digitalen Marketing
1.1 Markt- und kundenorientiertes
Entscheidungsverhalten
1.2 Verbesserung der Entscheidungsqualität im
digitalen Marketing
1.3 Nachfrageseite von digitalen
Marketinginformationen
1.4 Anbieterseite von digitalen
Marketinginformationen
1.5 Herausforderungen eines zielgerichteten,
digitalen Marketing-Controllings
2. Digitales Multi-, Cross- und Omni-Channel-Marketing
2.1 Online-, Social Media- und Mobiles-Marketing
2.2 Etablierung einer digitalen Marketing-Strategie
2.3 Steuerungsinstrumente
3. Datenanalyse im digitalen Marketing
3.1 Datenquellen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 94 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
3.2 Datenverfügbarkeit und Datenbeschaffenheit
3.3 Grundlegende Analyseverfahren und -
methoden
4. Digitale Marketing Intelligence
4.1 Qualitative Ansätze
4.2 Quantitative Ansätze
4.3 Data Warehouses im digitalen Marketing
4.4 Ansätze des Data Mining
4.5 Big Data Marketing – Chancen und
Herausforderungen
5. Customer Relationship Management (CRM) im
Kontext der digitalen Medien
5.1 Ziele und Aufgaben im CRM
5.2 CRM-Strategie
5.3 Komponenten von CRM-Systemen
5.4 Anforderungen an die einzelnen CRM-
Komponenten
5.5 Systematische und zielgerichtete
Wirkungskontrolle mit Hilfe von CRM-Systemen');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (130, 1, 'Die Studierenden kennen den Stand der Technik auf
dem Gebiet Extended Reality (XR) sowie wichtige
Einsatzfelder und Anwendungen. Sie kennen
Forschungsarbeiten und Studien zu den Vor- und
Nachteilen der Verwendung von VR-/MR-/AR-
Technolgien für bestimmte Anwendungsfelder
gegenüber herkömmlichen Formen der
Benutzerkommunikation.
Die Studierenden kennen den Stand der Forschung auf
einem speziellen Teilgebiet der XR.
Die Studierenden können XR-Anwendungen mit einem
Werkzeug wie Unreal oder Unity entwickeln und
beherrschen insbesondere die mathematisch-
algorithmischen Probleme im Bereich von 3D-
Rotationen und unter simultaner Bewegung in
mehreren unterschiedlichen Koordinatensystemen. Sie
kennen praktische Arbeiten in diesem Bereich und
deren Probleme.
Die Studierenden kennen und verstehen globale
Beleuchtungsverfahren zur Erzeugung
hochrealistischer Visualisierungen. Sie kennen die
zugehörigen mathematischen und physikalischen
Grundlagen und die algorithmischen Umsetzungen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 97 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
wichtiger Verfahren. Sie kennen die Unterschiede
zwischen diesen Verfahren und können die
gegenseitigen Vor- und Nachteile begründen. Sie
kennen Optimierungsansätze z.B. für den Einsatz in
XR-Echtzeit-Umgebungen aus der Forschung und
können diese erklären.
Die Studierenden sind in der Lage, im Master-Projekt
Medieninformatik eine XR-Anwendung unter
Anwendung der Theorie aus der Lehrveranstaltung auf
der Basis einer geeigneten Engine zu entwickeln.
Die Studierenden sind zudem in der Lage, ihr Wissen
im Hinblick auf weiter reichende Anforderungen im
Studium, im Hinblick auf Arbeiten in der Forschung
sowie im späteren Beruf schnell zu erweitern und zu
vertiefen.', NULL, '• Augmented, Mixed und Virtual Reality:
Technologien, Geräte, Anwendungen, Studien über
AR- und MR-Einsatz
• Analyse und Erzeugung von 3D-Rotationsmatrizen:
Euler-Rotationen, spezielle orthogonale Matrizen
• Probleme mit Matrizen (Gimbal Lock), Quaternionen
• Simultane Rotationen in unterschiedlichen
Koordinatensystemen, Tracking mit mehreren
Sensoren/Geräten
• Rendering-Gleichung, Reflexionsverteilungsfunktion
(BRDF)
• Reflexion und Transmission, Raytracing,
Eigenschaften der generierten Bilder und des
Verfahrens, Optimierungsmethoden
• Diffuse Verfahren: Diffuses Raytracing, Path
Tracing, Photon Mapping, Radiosity
• Tracking: Prinzipien (Inside-Out, Outside-In),
Sensor-Technologien
• Navigationsverfahren für virtuelle Räume, Verfahren
zur intuitiven Fortbewegung
• Kollisionserkennung und –behandlung
• Analyse von Ergebnissen zu einem aktuellen XR-
Forschungsthema, das variieren kann: z.B.: XR im
Bereich medizinischer Rehabilitation.
Semesterbegleitend Mitarbeit an der Analyse eines
Forschungsthemas, Lesen und Exzerpieren eines
Forschungsartikels');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (131, 1, 'Die Studierenden erlernen ein vertiefendes Verständnis
zum Supply Chain Management (Aufbau und
Gestaltung, Strategien und Instrumente)
Insbesondere analysieren und untersuchen sie:
• eine Data Science basierte Perspektive im
Supply Chain Management
• die Wirkungen von Risiken und Unsicherheit in
komplexen Unternehmensnetzen und die
Potentiale von digitalen Systemen zum
Management und erfolgreichen Betrieb
• eine kritische Perspektive zur Betrachtung von
Risiken in der Supply Chain, insb. post Covid-
19, Risikomanagement- und Resilienz-
Methoden', NULL, 'Vertiefung Supply Chain Management
• Strategien und Instrumente in komplexen
Unternehmensnetzen und deren Abbildung in
Informationssystemen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 100 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Planungs- und Steuerungskonzepte im Supply Chain
Management, insb. angewandte deterministische
und stochastische Modelle aus operativer und
strategischer Sicht
• Supply Chain Risikomanagement und -Resilienz
• Simulation und Optimierung komplexer
Netzstrukturen und deren Visualisierung
• SCM Post Covid-19
• Praktikum mit Fallstudien und Übungen zu den
Themen der Vorlesung');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (113, 1, 'Die Studierenden lernen unterschiedliche
Technologien, Konzepte und Verfahren kennen, die für
den Betrieb großer IT-Infrastrukturen wichtig sind. Sie
bekommen erste Erfahrungen im Umgang mit diesen
Technologien und Verfahren. Die Fähigkeit neue
Technologien in diesem Umfeld schnell begreifen,
einordnen und bewerten zu können wird erlangt.
Die Studierenden lernen komplexe Rechnersysteme zu
analysieren und mit Hilfe von formalen Methoden zu
bewerten um Verbesserungen der Systeme vornehmen
zu können.', NULL, '• Leistungsbewertung
• Monitoring, Software, Hardware, hybrid
Modellierung, funktionale und zeitbehaftete Petri-
Netze
• Zusammenhang zwischen Messung und
Modellierung
• Fehlertoleranz
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 53 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik
• Rechner-Cluster
• ITIL
• IT-Controlling');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (97, 1, 'Die Studierenden beschäftigen sich längere Zeit
intensiv mit einem Thema der praktischen oder
technischen Informatik und lernen in diesem Rahmen
die wissenschaftliche Arbeits- und Denkweise intensiv
kennen.
Die Studierenden lernen, sich schnell in
Anwendungsproblematiken einzuarbeiten, und
sammeln Erfahrung bei der Analyse eines komplexen
Problems, bei der strukturierten Entwicklung von
Lösungen und der konkreten Realisierung unter
Nutzung vorhandener Programme bzw. mit Hilfe neu
entwickelter Programme.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 18 -
Informatik (Master) – PO2023 Modulkatalog
Die Studenten erweitern ihre sozialen Kompetenzen,
falls die Bearbeitung des Themas im Rahmen einer
Teamarbeit erfolgt.', NULL, 'Im Rahmen dieses Projekts sollen die Studierenden
möglichst selbständig unter Nutzung des in den
Veranstaltungen erlangten Wissens die Lösung eines
komplexen Problems der technischen oder praktischen
Informatik erarbeiten.
Dazu gehört die Analyse des Problems, die Ermittlung
des Standes der Technik und die Synthese und
Implementierung einer eigenen Lösung.
Die Bearbeitung des Problems soll in einem Team
erfolgen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (132, 1, 'Die Studierenden können potentielle oder sich
abzeichnende zukünftige technologische Entwicklungen
und deren mögliche gesellschaftliche Auswirkungen
analysieren, diskutieren, zusammenfassen und
bewerten,
Indem Sie:
• Verschiedene Perspektiven durch verschiedene
Vortragende kennenlernen
• Regelmäßig in Diskussionen debattieren und
argumentieren
• Wechselwirkungen, beispielsweise auf sozialer und
gesellschaftlicher Ebene gezielt berücksichtigen
• Eigene Sichtweisen formulieren, abgrenzen und
verteidigen
Um später:
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 102 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
• Sich an Technologieentwicklung aktiv und bewusst
und mit einer gesellschaftlichen Verantwortung
betreiben zu können.', NULL, '• Die Veranstaltung ist als Ringvorlesung konzipiert
mit wechselnden internen und externen
Vortragenden.
• Themen sind aktuelle Technologietrends, mit klarem
Fokus auf zukünftige Entwicklungen (+10 Jahre) und
deren Auswirkungen auf die Menschheit.
• Gekoppelt wird dies mit Diskussionsrunden,
Paneldiskussionen und Frage-Antwort Runden.
• Eine intensive Beteiligung ist Teil der
Prüfungsleistung.
• Einzelne Themen der Ringvorlesung müssen
vorbereitet werden. Unterschiedliche Rollen werden
durch die Studierenden übernommen, z.B.
Moderation oder Panelteilnehmer:in.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (133, 1, 'Die Studierenden beherrschen fortgeschrittene
Konzepte der IT-Sicherheit, insb. System- und
Softwaresicherheit, und können sie mit Internet-
Technologien kombinieren. Sie gewinnen praktische
Erfahrungen über sichere und unsichere IT-
Infrastrukturen und Programme. In Teamarbeit soll ein
komplexes Problem nach wissenschaftlicher
Betrachtung praktisch gelöst werden. Die
Teilnehmenden sind in der Lage, ihre Ergebnisse
gemessen am Stand der Wissenschaft und Technik
einzuordnen und sowohl unter Verwendung von
Fachtermini untereinander als auch gegenüber der
Hochschulöffentlichkeit darzustellen und zu
kommunizieren.
Wenn möglich werden über die Teilnahme an
kompetitiven, spielerischen Wettbewerben (etwa
Capture The Flag) die erworbenen Kompetenzen unter
Beweis gestellt.', 'unter Beweis gestellt.', 'Aktuelle praktische oder wissenschaftliche Probleme
basierend auf etwa Konferenzbeiträgen zu Top-Tier-
Konferenzen und Journals oder durch aktuelle CTF-
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 4 -
Internet-Sicherheit (Master) – PO2023 Modulkatalog
Wettbewerbe • IT-Sicherheit • System- und
Softwaresicherheit • Internet- und
Netzwerktechnologien und Angriffsmethoden');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (134, 1, 'Die/der Studierende ist in der Lage, die Ergebnisse
ihrer/seiner Masterarbeit aus der Internet-Sicherheit,
ihre fachlichen Grundlagen, ihre Einordnung in den
aktuellen Stand der Technik, bzw. der Forschung, ihre
fächerübergreifenden Zusammenhänge und ihre
außerfachliche Bezüge in begrenzter Zeit in einem
Vortrag zu präsentieren.
Darüber hinaus kann sie/er Fragen zu inhaltlichen
Details, zu fachlichen Begründungen und Methoden
sowie zu inhaltlichen Zusammenhängen zwischen
Teilbereichen ihrer/seiner Arbeit beantworten. Die/der
Studierende kann ihre/seine Masterarbeit auch im
Kontext beurteilen und ihre Bedeutung für die Praxis
und die Forschung einschätzen und ist in der Lage,
auch entsprechende Fragen nach themen- und
fachübergreifenden Zusammenhängen zu beantworten.', NULL, 'Zunächst wird der Inhalt der Masterarbeit aus der
Internet-Sicherheit im Rahmen eines Vortrages
präsentiert. Anschließend sollen in einer Diskussion
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 13 -
Internet-Sicherheit (Master) – PO2023 Modulkatalog
Fragen zum Vortrag und zur Masterarbeit beantwortet
werden.
Die Prüfer können weitere Zuhörer zulassen. Diese
Zulassung kann sich nur auf den Vortrag, auf den
Vortrag und einen Teil der Diskussion oder auf das
gesamte Kolloquium zur Masterarbeit erstrecken.
Der Vortrag soll die Problemstellung der Masterarbeit,
die vergleichende Darstellung alternativer oder
konkurrierender Lösungsansätze mit Bezug zum
aktuellen Stand der Technik, bzw. Forschung, den
gewählten Lösungsansatz, die erzielten Ergebnisse
zusammen mit einer abschließenden Bewertung der
Arbeit sowie einen Ausblick beinhalten. Je nach Thema
können weitere Anforderungen hinzukommen. Die
Dauer des Vortrages wird vom Erstprüfer festgelegt und
kann zwischen 30 und 40 Minuten betragen.
In der anschließenden Diskussion werden Fragen von
den Prüfern gestellt. Fragen der übrigen Zuhörer des
Kolloquiums können durch die Prüfer ebenfalls
zugelassen werden. Die Dauer der Diskussion wird
durch die Prüfer bestimmt und beträgt ca. 30-45
Minuten.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (135, 1, 'Die/der Studierende ist in der Lage, innerhalb einer
vorgegebenen Frist entweder
• eine schwierige und komplexe praxisorientierte
Problemstellung aus der Internet-Sicherheit
sowohl in ihren fachlichen Einzelheiten als auch
in den themen- und fachübergreifenden
Zusammenhängen nach wissenschaftlichen
Methoden selbständig zu bearbeiten und zu lösen
oder
• eine anspruchsvolle Fragestellung aus der
aktuellen Forschung auf dem Gebiet der Internet-
Sicherheit unter Anleitung eigenständig zu
bearbeiten und selbstständig ein neues
wissenschaftliches Ergebnis zu entwickeln.', NULL, 'Es soll eine praxisorientierte Problemstellung oder eine
Fragestellung aus der Forschung auf dem Gebiet der
Internet-Sicherheit mit den im Studium erworbenen
oder während der Masterarbeit neu erlernten
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -
Internet-Sicherheit (Master) – PO2023 Modulkatalog
wissenschaftlichen Methoden in begrenzter Zeit mit
Unterstützung eines erfahrenen Betreuers gelöst
werden.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (136, 1, 'Die Studierenden sind in der Lage, ihre bisher
erworbenen speziellen Kenntnisse, Fertigkeiten und
Lösungsstrategien aus der Informatik und der Internet-
Sicherheit auf interdisziplinäre Problemstellungen
anwenden.', NULL, '• Im Master-Projekt Internet-Sicherheit wird besonders
die interdisziplinäre Komponente des
Masterstudiengangs Internet-Sicherheit in den
Mittelpunkt gerückt.
• Während der Projektarbeit sollen die Studierenden
vor allem ihre speziellen Kenntnisse, Fertigkeiten
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 19 -
Internet-Sicherheit (Master) – PO2023 Modulkatalog
und Lösungsstrategien aus der Informatik auf
interdisziplinäre Problemstellungen anwenden.
• Interdisziplinäre Projekte können mit den anderen
Master-Studiengängen koordiniert werden. Beispiele
sind:
o Wirtschaftsinformatik (Return of Security
Investment (RoSI), Mehrwerte von Internet-
Sicherheit, …) oder
o Technische Informatik (Sicherheit bei „Internet
der Dinge“, Industrie 4.0, …) oder
o Medieninformatik (Vertrauenswürdige
Gestaltung von Oberflächen, Darstellung von
sicherheitsrelevanten Ereignissen auf eine
intuitive Weise, …) oder
o Praktische Informatik (Integration von IT-
Sicherheit in Anwendungen, …).
• Die Projektteams haben dabei die Verantwortung für
die genaue Ausgestaltung und das Zeitmanagement.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (137, 1, 'Die Studierenden besitzen die folgenden Fähigkeiten:
• Sie sind in der Lage zur selbstständigen
Einarbeitung in aktuelle Forschungsfragen zur
Internet- Sicherheit auf der Basis von Primärliteratur
(Publikationen in Fachzeitschriften sowie
Tagungsbeiträge);
• Sie können Informationsrecherchen zu
forschungsorientierten Fragestellungen durchführen
und sind in der Lage, dazu eine strukturiert
schriftliche Aufbereitung des aktuellen Stands der
Forschung zu erarbeiten;
• Sie können eine zusammengefasste Darstellungder
Ergebnisse zu einer Fragestellung präsentieren
sowie in der Diskussion mit allen
Seminarteilnehmern sich ergebende Fragen
beantworten und aufgestellte Thesen verteidigen.', NULL, '• Im Rahmen dieses Projekts bearbeiten die
Studierenden aktuelle Themen aus dem Bereich der
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 21 -
Internet-Sicherheit (Master) – PO2023 Modulkatalog
Internet-Sicherheit. Die Themen orientieren sich z.B.
an den Forschungsthemen des Instituts für Internet-
Sicherheit -if(is).
Die Rahmenbedingungen für das Projekt werden
von den Lehrenden vorgegeben, die Ausgestaltung
und die Verantwortung liegen aber bei den einzelnen
Projektteams des Institutes.
• Dadurch sollen die Studierenden das selbstständige
und zielorientierte Bearbeiten von
wissenschaftlichen Problemstellungen über einen
längeren Zeitraum erlernen.
• Ein Schwerpunkt dieses Seminars bildet die
eigenständige Bearbeitung wissenschaftlicher
Fragestellungen.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (138, 1, 'Die Studierenden sind in der Lage, wissenschaftlich
anspruchsvolle Problemstellungen selbstständig und
zielorientiert zu bearbeiten.', NULL, '• Im Rahmen dieses Projekts bearbeiten die
Studierenden aktuelle Themen aus dem Bereich der
Internet-Sicherheit. Die Themen orientieren sich z.B.
an den Forschungsthemen des Instituts für Internet-
Sicherheit -if(is).
• Die Rahmenbedingungen für das Projekt werden
von den Lehrenden vorgegeben, die Ausgestaltung
und die Verantwortung liegen aber bei den einzelnen
Projektteams des Institutes.
• Dadurch sollen die Studierenden das selbstständige
und zielorientierte Bearbeiten von
wissenschaftlichen Problemstellungen über einen
längeren Zeitraum erlernen.
• Ein Schwerpunkt dieses Seminars bildet die
eigenständige Bearbeitung wissenschaftlicher
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -
Internet-Sicherheit (Master) – PO2023 Modulkatalog
Fragestellungen. Idealerweise entsteht daraus ein
Artikel, die veröffentlich werden kann.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (139, 1, 'Die Studierenden können Simulationsumgebungen und
Prototypen für zukünftige Cross-Reality Systeme
konzipieren und technologisch umsetzen
indem Sie
• Die Möglichkeiten und Herausforderungen für
Device- und Realitätsübergreifende interaktive
Systeme analysieren und diskutieren
• Aktuelle Forschungsliteratur recherchieren,
kritisieren und Lösungsansätze ableiten
• Werkzeuge aus dem Kontext AR/VR und Cross-
Platform Development zusammenführen
Um später / damit sie…
• Zukünftige Benutzererlebnisse gestalten zu
können, die im Sinne eines übergreifenden
Metaverse nicht an Realitäten und Geräteklassen
gebunden sein werden', NULL, '• In der Veranstaltung werden aktuelle
Herausforderungen, Lösungen und Möglichkeiten
diskutiert, die sich aus dem Prototyping von CR-
Systemen und ihren Interaktionen ergeben.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 5 -
Medieninformatik (Master) – PO2023 Modulkatalog
• Es werden aktuelle Forschungsansätze vorgestellt,
kontrastiert und interpretiert
• In Kleingruppen werden für spezifische
Problemstellungen mögliche CR Konzepte entworfen
und prototypisch realisiert.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (141, 1, 'Die Studierenden sind in der Lage, die Ergebnisse ihrer
Masterarbeit aus der Medieninformatik, ihre fachlichen
Grundlagen, ihre Einordnung in den aktuellen Stand der
Technik, bzw. der Forschung, ihre
fächerübergreifenden Zusammenhänge und ihre
außerfachlichen Bezüge in begrenzter Zeit in einem
Vortrag zu präsentieren.
Darüber hinaus können die Studierenden Fragen zu
inhaltlichen Details, zu fachlichen Begründungen und
Methoden sowie zu inhaltlichen Zusammenhängen
zwischen Teilbereichen ihrer Arbeit selbstständig
beantworten und diese verteidigen.
Die Studierenden können ihre Masterarbeit auch im
Kontext beurteilen und ihre Bedeutung für die Praxis
und die Forschung einschätzen und sind in der Lage,
auch entsprechende Fragen nach themen- und
fachübergreifenden Zusammenhängen zu beantworten.', NULL, 'Zunächst wird der Inhalt der Masterarbeit aus der
Medieninformatik im Rahmen eines Vortrags
präsentiert. Anschließend sollen in einer Diskussion
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -
Medieninformatik (Master) – PO2023 Modulkatalog
Fragen zum Vortrag und zur Masterarbeit beantwortet
werden.
Die Prüfer können weitere Zuhörer zulassen. Diese
Zulassung kann sich nur auf den Vortrag, auf den
Vortrag und einen Teil der Diskussion oder auf das
gesamte Kolloquium zur Masterarbeit erstrecken.
Der Vortrag soll die Problemstellung der Masterarbeit,
die vergleichende Darstellung alternativer oder
konkurrierender Lösungsansätze mit Bezug zum
aktuellen Stand der Technik, bzw. Forschung, den
gewählten Lösungsansatz, die erzielten Ergebnisse
zusammen mit einer abschließenden Bewertung der
Arbeit sowie einen Ausblick beinhalten. Je nach Thema
können weitere Anforderungen hinzukommen.
Die Dauer des Kolloquiums ist in § 16 der
Studiengangsprüfungsordnung geregelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (142, 1, 'Die/der Studierende ist in der Lage, innerhalb einer
vorgegebenen Frist entweder
eine schwierige und komplexe praxisorientierte
Problemstellung aus der Medieninformatik sowohl in
ihren fachlichen Einzelheiten als auch in den themen-
und fachübergreifenden Zusammenhängen nach
wissenschaftlichen Methoden selbständig zu bearbeiten
und zu lösen oder eine anspruchsvolle Fragestellung
aus der aktuellen Forschung auf dem Gebiet der
Medieninformatik unter Anleitung eigenständig zu
bearbeiten und selbstständig ein neues
wissenschaftliches Ergebnis zu entwickeln.', NULL, 'Es wird eine praxisorientierte Problemstellung oder eine
Fragestellung aus der Forschung auf dem Gebiet der
Medieninformatik mit den im Studium erworbenen oder
während der Master- Arbeit neu erlernten
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -
Medieninformatik (Master) – PO2023 Modulkatalog
wissenschaftlichen Methoden in begrenzter Zeit mit
Unterstützung eines erfahrenen Betreuers gelöst.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (143, 1, 'Die Studierenden können ein digitales interaktives
Produkt mit signifikantem Software-Anteil von der
Problemanalyse bis hin zur Auslieferung erschaffen,
indem sie:
• Sich in einem Projektteam organisieren und
Methoden des agilen Projektmanagements anwenden
• Im Studium erlernte Methoden, Konzepte und
Techniken kombinieren, arrangieren, modifizieren und
anwenden
• Mögliche Lösungsansätze (z.B. in der
wissenschaftlichen Fachliteratur oder Entwicklerblogs
etc.) prüfen, bewerten und evaluieren
• Methoden der mensch-zentrierten Entwicklung auf
die konkrete Projektstellung anpassen und anwenden
• Komplexe Aufgaben sinnvoll strukturieren,
dekompilieren und entsprechend den individuellen
Fachkompetenzen als Team effizient bearbeiten
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 19 -
Medieninformatik (Master) – PO2023 Modulkatalog
• Typische Schnittstellenprobleme in der Abstimmung
und Zusammenarbeit sowohl auf technisch-fachlicher
als auch auf sozialer Ebene mit Hilfe von
Projektmanagementmethoden bewältigen
• Zwischenergebnisse dokumentieren und präsentieren
um später
• Die Kenntnisse und Kompetenzen verschiedener
Module in einem realistischen Projekt zu vertiefen
und zusammenzuführen.
• Über die reinen Fachkompetenzen hinaus Erfahrungen
und Herausforderungen bei der Zusammenarbeit im
Team über einen längeren Zeitraum mit einer
komplexen Aufgabe kennenlernen und
Lösungsstrategien entwickeln zu können', 'als Team effizient bearbeiten', '• Im Rahmen des Master-Projektes Medieninformatik
bearbeiten die Teilnehmer eine typische größere
Aufgabenstellung aus dem Bereich der Medieninformatik
in einem Projektteam. Die Themenstellung erfolgt mit
Rücksicht auf die Kenntnisse der Studierenden.
• Selbstständige Durchführung des Projekts von der
Problemanalyse über Konzept, Design, Prototyping,
Realisierung/Implementierung und Test bis zur
Dokumentation.
• Anwendung von grundlegenden Projektmanagement-
Methoden für Definition, Planung, Kontrolle und
Realisierung des Projekts.
• Vertiefung von Kenntnissen zur Entwicklung von
Anwendungen der Medieninformatik.
• Entwicklung im Team unter Beteiligung von
realen/potentiellen Anwendern und Benutzern.
• In regelmäßigen Projektsitzungen werden im Rahmen
einer Qualitätssicherung die Zwischenergebnisse von den
Teams durch Präsentation und Vorführung vorgestellt
und diskutiert.
• Die Projektthemen werden rechtzeitig vor Beginn der
Veranstaltung bekannt gemacht. Es wird versucht,
praxisnahe Projekte auch von hochschulexternen
Anwendern der Medieninformatik zu akquirieren.
• Das Masterprojekt Medieninformatik hat je nach
Themenstellung einen Schwerpunkt im Bereich der UI-
Interface-Gestaltung, der Mensch-Computer-Interaktion
oder der Computergrafik, wird aber zumeist Aspekte aus
mehreren Gebieten beinhalten.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 20 -
Medieninformatik (Master) – PO2023 Modulkatalog
• Projektvorschläge von Studierenden sind nach Absprache
ebenfalls möglich.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (144, 1, 'Die Studierenden können ein aktuelles
Forschungsgebiet anhand einer konkreten
Forschungsfrage auf Basis der aktuellen
wissenschaftlichen Literatur analysieren und bewerten,
Indem Sie:
• Wissenschaftliche Literatur recherchieren,
einordnen und abstrahieren können
• Gemeinsamkeiten und Diskrepanzen in der
Literatur identifizieren und bewerten können
• Eine zusammenhänge Übersicht des Stands der
Forschung diskutieren und präsentieren können
• Eine eigene Position zum Stand der Forschung
und offenen Forschungsfragen einnehmen und
verteidigen können.
Um später:
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 22 -
Medieninformatik (Master) – PO2023 Modulkatalog
• Diese Kompetenzen in die theoretische Analyse
für die Masterarbeit einbringen zu können
• Eigenständig wissenschaftliche Forschung über
die Masterarbeit hinaus zu betreiben.', NULL, '• In diesem Seminar werden aktuelle
Forschungsbereich und Forschungsfragen kurz
vorgestellt und anschließend durch die Teilnehmer
im Selbststudium analysiert und aufgearbeitet.
• Die Themenvergabe erfolgt am Semesterbeginn. In
Regelmäßigen Sitzungen präsentieren die
Studierenden Rechercheergebnisse und den
Diskussionsstand.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (145, 1, 'Die Studierenden können eine aktuelle
wissenschaftliche Forschungsfrage extrahieren,
analysieren, bewerten und im Rahmen der
Durchführung des Moduls induktiv neues Wissen
generieren
indem sie:
• Eingehend für eine vorgegebene Thematik die
wissenschaftliche Literatur recherchieren,
analysieren und bewerten und daraus deduktiv
eine offene Forschungsfrage ableiten.
• Selbstständig Maßnahmen, Werkzeuge und
Prozesse definieren und erzeugen, um die
Forschungsfrage beantworten zu können.
• Empirische Forschungsmethodik inklusive
entsprechender Auswertungsmethoden verstehen,
adaptieren und anwenden und damit die
Forschungsfrage beantworten ODER durch die
konzeptionelle, gestalterische und/oder technische
Erzeugung eines Artefakts oder Prototypen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 77 -
Medieninformatik (Master) – PO2023 Wahlpflichtkatalog
praktische Lösungsmöglichkeiten für die
Forschungsfrage aufzeigen.
Um später
• Die grundlegende Vorgehensweise
wissenschaftlichen Arbeitens auf dem Niveau,
welches für eine Masterarbeit notwendig ist,
kennen und anwenden zu können.
• Eigenständig wissenschaftliche Forschung über die
Masterarbeit hinaus zu betreiben.', NULL, 'Im Rahmen dieses Moduls wird den Studierenden eine
Problemstellung bzw. ein Themenfeld aus einem
aktuellen Forschungsbereich der Medieninformatik als
Basis gegeben.
In der Regel geschieht dies angelehnt an aktuelle
Forschungsprojekte und entsprechend kann auch die
Durchführung eingebettet sein in die aktive
Forschungsarbeit.
Je nach Problemstellung und Ergebnisse der Analyse
der verwandten Arbeiten sowie der Vorkenntnisse und
Interessen der Studierenden, kann sich die Arbeit
sowohl auf die Durchführung einer empirischen Studie
fokussieren als auch die Gestaltung oder
Implementierung eines Prototypen, welcher weniger als
Produkt/Minimal Viable Product zu sehen ist als
vielmehr als gezielter Versuch, durch Experiment und
Versuch Antworten für die Forschungsfrage zu
erhalten. Auch eine Kombination aus
Prototypentwicklung und anschließender empirischer
Studie/Experiement ist möglich.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (146, 1, 'Die/der Studierende ist in der Lage, innerhalb einer
vorgegebenen Frist eine praxisorientierte Aufgabe aus
der Wirtschaftsinformatik sowohl in ihren fachlichen
Einzelheiten als auch in ihren themen- und
fachübergreifenden Zusammenhängen nach
wissenschaftlichen und fachpraktischen Methoden
selbstständig zu bearbeiten und zu dokumentieren.', NULL, 'Es wird ein in der Regel praxisorientiertes Problem aus
der Wirtschaftsinformatik mit den im Studium erlernten
Konzepten, Verfahren und Methoden in begrenzter Zeit
unter Anleitung eines erfahrenen Betreuers gelöst.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (147, 1, 'Die Studierenden können – fokussiert auf die
Erfordernisse der Wirtschaftsinformatik - die
grundlegenden Eigenschaften der für sie relevanten
hardwarenahen IT-Systeme verstehen und einordnen.
Sie haben die Kompetenz, Anwendungssoftware auf
Server und Clients sinnvoll zu verteilen und die
Bedeutung und Eigenschaften der unterlegten
Betriebssysteme einzuordnen.
Sie sind in der Lage, die für verteilte Anwendungen
notwendige Infrastruktur in Form von Netzen
einzusetzen und bis zu einem gewissem Grade
zuzuschneiden.
Sie können die grundlegende
Datenspeicherungssysteme unterscheiden und haben
damit die Kompetenz, die für die jeweiligen
Anwendungssysteme sinnvollen Datenablagesysteme
auszuwählen.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 8 -
Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog
Sie können neue Entwicklungen im Bereich
Betriebssysteme und Netzwerke verstehen, bewerten
und für ihre Arbeit nutzbar machen.', NULL, 'Rechnerarchitektur, Prozesse und Threads,
Speicherverwaltung, Ein-/Ausgabe, Dateisysteme,
Betriebssystemplattformen, Virtualisierung,
Übertragungsmedien, Netzwerktopologien, Protokolle
und Standards, Internet, mobile Netze, Speichernetze,
Cloud');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (148, 1, 'Die Veranstaltung verknüpft insbesondere die in den
vorangegangenen Semestern erworbenen Kenntnisse
zum Supply Chain Mangement aus einer
informationstechnischen Perspektive (s.
Voraussetzungen PMW, EBW, GWI und EP).
Die Studierenden
• lernen den grundsätzlichen Aufbau sowie
Aufgaben und Ziele, Strategien und Instrumente
des Supply Chain Managements kennen
• verstehen die grundsätzlichen
Modellierungsansätze der Wirtschaftsinformatik
an praktischen Aufgaben im Supply Chain
Management zu verknüpfen und zu begreifen
• werden fachliche Anforderungen, insbesondere
aus dem Supply Chain Management, in
geeignete technische Modelle überführen,
gestalten und beurteilen können.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -
Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog', NULL, 'Grundlagen Supply Chain Management
• Gestaltung und Einsatz von Informationssystemen in
komplexen Unternehmensnetzen und
interdependenten Unternehmensbereichen aus
operativer und strategischer Perspektive
• Aufgaben und Ziele, Strategien und Instrumente des
Supply Chain Managements
• Horizontale und vertikale Kooperationsstrategien
• Aktuelle und relevante Probleme in der Anwendung
• Verknüpfung Supply Chain Management und
strategisches Informationsmanagement
• Der Bullwhip-Effekt und seine Ursachen
• Praktikum GSC mit aktuellen und angewandten
Fallstudien');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (149, 1, 'Die/der Studierende ist in der Lage, die Ergebnisse der
Bachelorarbeit, ihre fachlichen und methodischen
Grundlagen, ihre fächerübergreifenden
Zusammenhänge und ihre außerfachlichen Bezüge
mündlich in begrenzter Zeit in einem Vortrag zu
präsentieren.
Darüber hinaus kann sie/er Fragen zu inhaltlichen
Details, zu fachlichen Begründungen und Methoden
sowie zu inhaltlichen Zusammenhängen zwischen
Teilbereichen ihrer/seiner Arbeit selbstständig
beantworten.
Die/der Studierende kann ihre/seine Bachelorarbeit
auch im Kontext beurteilen und ihre Bedeutung für die
Praxis einschätzen und ist in der Lage, auch
entsprechende Fragen nach themen- und
fachübergreifenden Zusammenhängen zu beantworten.', NULL, 'Zunächst wird der Inhalt der Bachelorarbeit im Rahmen
eines Vortrages präsentiert. Anschließend werden in
einer Diskussion Fragen zum Vortrag und zur
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 30 -
Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog
Bachelorarbeit gestellt, die von der/dem Studierenden
beantwortet werden müssen.
Der Vortrag soll mindestens die Problemstellung der
Bachelorarbeit, den gewählten Lösungsansatz, die
erzielten Ergebnisse zusammen mit einer
abschließenden Bewertung der Arbeit sowie einen
Ausblick beinhalten.
Je nach Thema können weitere Anforderungen
hinzukommen, wie z.B. die vergleichende Darstellung
alternativer oder konkurrierender Lösungsansätze, ein
Literaturüberblick oder die Darlegung des aktuellen
Standes der Wissenschaft.
Die Dauer des Kolloquiums ist in § 26 der Bachelor-
Rahmenprüfungsordnung und § 19 der
Studiengangsprüfungsordnung geregelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (150, 1, 'Die Veranstaltung verknüpft insbesondere die
erworbenen Kenntnisse zum Supply Chain
Management aus einer informationstechnischen
Perspektive (s. Voraussetzungen PMW, EBW, GWI und
EP) – aufbauend und als Weiterführung der
Veranstaltung GSC.
Die Studierenden
• verstehen den interdependenten Charakter der
Struktur des Supply Chain Managements im
Unternehmen und in Unternehmensnetzen
kennen
• verknüpfen weiterführende
Modellierungsansätze der Wirtschaftsinformatik
an praktischen Aufgaben und Fallstudien des
Supply Chain Managements und erkennen
konfliktäre Zielsetzungen
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 46 -
Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog
• untersuchen die Abbildung fachlicher
Anforderungen, insbesondere aus dem Supply
Chain Management, zur Anwendung in
geeigneten mathematisch, technische Modellen
der Wirtschaftsinformatik anhand komplexer
ausgewählter Fallstudien.', NULL, 'Supply Chain Management und Digitalisierung
• Gestaltung und Einsatz von Informationssystemen in
komplexen Unternehmensnetzen und
interdependenten Unternehmensbereichen aus
operativer und strategischer Perspektive.
• Deterministische und stochastische Modelle im
Rahmen der Planung komplexer angewandter
Problemstellungen im Unternehmen
• Interdependente Problemstellungen aus dem Supply
Chain Management mit Aufgaben und Funktionen in
Informationssystemen und deren
Geschäftsprozessen
• Angewandte aktuelle und relevante
Problemstellungen basierend auf Fallstudien
• Digitales Supply Chain Management und seine
Perspektiven, betriebswirtschaftschaftliche Potentiale
zukünftiger Herausforderungen
• Praktikum DSC mit aktuellen und angewandten
Fallstudien und kritischer Reflexion');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (151, 1, 'Die Studierende werden in die Lage versetzt:
• durch wissenschaftliches Vorgehen für praktische
Problemstellungen den Stand der Technik zu
recherchieren, Anforderungen zu analysieren,
Lösungen zu entwickeln und zu begründen,
• die Integration von betriebswirtschaftlichen
Wissen mit Informatiktechnologien zur Gestaltung
und Umsetzung von betrieblichen
Informationssystemen anzuwenden,
• das Erlernte – insbesondere die Methoden,
Verfahren und Werkzeuge - in Rahmen einer
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -
Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog
komplexeren Aufgabenstellung selbständig und im
Team anzuwenden,
• ihre Fähigkeiten zur Teamarbeit in Form von
Leitung und Moderation von Besprechungen,
Lösung von Konflikten, Beurteilung und
Präsentation von Arbeitsergebnissen anzuwenden
und weiter zu entwickeln.', NULL, 'Der Vorlesungsteil wird als globale Veranstaltung für
alle Teilnehmer abgehalten und führt in die Grundlagen
des wissenschaftlichen Arbeitens ein.
Zum wissenschaftlichen Arbeiten gehören:
• Recherche
• Analyse
• Dokumentation
• Präsentation
Im Praktikumsteil steht die systematische Anwendung
und Zusammenführung von in
Vorgängerveranstaltungen erlernten Wissen im
Vordergrund:
• Durchführung eines komplexeren Projektes zur
Entwicklung einer
Anwendungssystemkomponente.
• Selbstständige Durchführung des Projekts von der
Analyse über Design, Implementierung und Test
bis zur Dokumentation
• In diesem Projekt werden die erlernten Kenntnisse
aus dem Studium anhand eines Fallbeispiels
durchgängig und systematisch angewendet.
• In dem Projekt sollen die im Studium erlernten
fachlichen, sozialen und methodischen
Kompetenzen angewendet werden.
• Die Projektarbeit wird in Teams mit 4 bis 6
Studenten durchgeführt.
In regelmäßigen Projektsitzungen werden im Rahmen
einer Qualitätssicherung die Zwischenergebnisse von
den Teams durch Präsentation und Vorführung
vorgestellt und diskutiert.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (152, 1, 'Die Studierenden erwerben berufsorientierte
englischsprachige Diskurs- und Handlungskompetenz
unter Berücksichtigung (inter-)kultureller Elemente.', NULL, 'Diese Fachsprache-Veranstaltung widmet sich
methodisch und inhaltlich englischen
Sprachverwendungssituationen für
Wirtschaftsinformatiker.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (153, 1, 'Die Studierende werden in die Lage versetzt:
• das erlernte theoretischen Wissen, die
Modellierungsmethoden und das Vorgehensmodell
zu Business Intelligence, Data Warehouse und Big
Data Systemen zu erläutern und anzuwenden,
• den Aufbau und die Architektur des SAP Business
Warehouse System zu erklären,
• den Aufbau eines Data Warehouses und die
Integrationsmethoden und -möglichkeiten von Daten
verschiedener Quellsysteme praktisch mit dem SAP
BW System umzusetzen,
• aktuelles Wissen und den Stand der Forschung zu
Business Intelligence, Data Warehouse und Big
Data selbständig zu erarbeiten.', NULL, '• Grundlagen, Methoden und Anwendungsgebiete von
Business Intelligence (BI), Data Warehouse und Big
Data.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 4 -
Wirtschaftsinformatik (Master) – PO2023 Modulkatalog
• Architektur, Datenmodell und Techniken in Business
Intelligence am Beispiel SAP Business Warehouse
• Methoden und Techniken von Big Data
• Architekturen zur Integration von BI, Data
Warehouse und Data Lakes
• Methoden und Algorithmen zum Data Mining
• Fallbeispiele aus der Unternehmenspraxis');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (158, 1, 'Die Studierenden können selbständig…
a) Management und Unternehmensführung:
… den wissenschaftlichen Forschungsprozess auf
betriebswirtschaftlich relevante Fragestellungen
anwenden. Sie sind vertraut mit der den Grundlagen
des Managements und lernen, Management als
Führungsaufgabe zu verstehen. Sie lernen Methoden
und Kompetenzmanagementsysteme der
Personalauswahl und -führung kennen und können ihre
Handhabung und Einsatz für unterschiedliche
Führungsaufgaben erkennen und nutzen. Sie erkennen
die Bedeutung der Verantwortung und ethischen
Herausforderungen an eine Führungskraft. In konkreten
Case Studies und im Planspiel bearbeiten Sie
komplexe Management- und Führungsaufgaben und
lernen Methoden der Problemstrukturierung und –
lösung kennen und können diese systematisch und
fallgeeignet auswählen und anwenden. Weitere
Schwerpunkte liegen auf aktuellen
Managementherausforderungen an Unternehmen und
der Rolle der Kommunikation in diesem
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 50 -
Wirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft
Zusammenhang, wie z.B. Herausforderungen durch die
Arbeitswelt 4.0, Konfliktmanagement oder Change
Kommunikation.
b) Content-Marketing:
… über mehrere Plattformen und Mediengattungen
hinweg – unter Wahrung der Markenidentität –
kommunizieren. Sie beherrschen es, mit crossmedialen
Angeboten die Aufmerksamkeit der Mediennutzer zu
generieren und zu binden. Sie kennen die spezifischen
Anforderungen der verschiedenen Medien und können
sie beurteilen. Sie sind eigenständig in der Lage Inhalte
und Themen digital für alle Ausspielkanäle
aufzubereiten und sie nach der Veröffentlichung zu
begleiten.', NULL, 'Wechselnde Lehrinhalte, z.B.
a) Management und Unternehmensführung:
• Betriebswirtschaftlichen Grundlagen des
Management
• Management als Führungsaufgabe denken und
verstehen
• Ethik im Management
• Führungsansätze und Personalführung
• Kompetenzmanagementsysteme
• Personalauswahl und -entwicklung
• Unternehmenskultur und Führungsstile
• Aktuelle Herausforderungen für Unternehmen
und deren Management
b) Content-Marketing Crossmedia-Management:
• Denken und Arbeiten in crossmedialen
Strukturen
• Content-Management-Systeme
• Crossmediales Produzieren
• Digitales Projektmanagement
• Spezifika der Medien
• Chancen und Risiken der Interaktivität
• Ökonomische und rechtliche
Rahmenbedingungen
Content-Marketing:
• Content-Strategie
• Brand Content
• Merkmale guter Inhalte
• Storytelling
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -
Wirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft
• Fallstudien
• Suchmaschinen-Optimierung
• Linkaufbau
• Social-Media-PR
• Evaluation');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (154, 1, 'Die/der Studierende ist in der Lage, die Ergebnisse
ihrer/seiner Masterarbeit aus der Wirtschaftsinformatik,
ihre fachlichen Grundlagen, ihre Einordnung in den
aktuellen Stand der Technik, bzw. der Forschung, ihre
fächerübergreifenden Zusammenhänge und ihre
außerfachlichen Bezüge in begrenzter Zeit in einem
Vortrag zu präsentieren.
Darüber hinaus kann sie/er Fragen zu inhaltlichen
Details, zu fachlichen Begründungen und Methoden
sowie zu inhaltlichen Zusammenhängen zwischen
Teilbereichen ihrer/seiner Arbeit selbstständig
beantworten.
Die/der Studierende kann ihre/seine Masterarbeit auch
im Kontext beurteilen und ihre Bedeutung für die Praxis
und die Forschung einschätzen und ist in der Lage,
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 11 -
Wirtschaftsinformatik (Master) – PO2023 Modulkatalog
auch entsprechende Fragen nach themen- und
fachübergreifenden Zusammenhängen zu beantworten.', NULL, 'Zunächst wird der Inhalt der Masterarbeit aus der
Wirtschaftsinformatik im Rahmen eines Vortrags
präsentiert. Anschließend sollen in einer Diskussion
Fragen zum Vortrag und zur Masterarbeit beantwortet
werden.
Die Prüfer können weitere Zuhörer zulassen. Diese
Zulassung kann sich nur auf den Vortrag, auf den
Vortrag und einen Teil der Diskussion oder auf das
gesamte Kolloquium zur Masterarbeit erstrecken.
Der Vortrag soll die Problemstellung der Masterarbeit,
die vergleichende Darstellung alternativer oder
konkurrierender Lösungsansätze mit Bezug zum
aktuellen Stand der Technik, bzw. Forschung, den
gewählten Lösungsansatz, die erzielten Ergebnisse
zusammen mit einer abschließenden Bewertung der
Arbeit sowie einen Ausblick beinhalten. Je nach Thema
können weitere Anforderungen hinzukommen.
Die Dauer des Kolloquiums ist in § 26 der Master-
Rahmenprüfungsordnung und § 16 der
Studiengangsprüfungsordnung geregelt.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (156, 1, 'Die/der Studierende ist in der Lage, innerhalb einer
vorgegebenen Frist entweder
eine schwierige und komplexe praxisorientierte
Problemstellung aus der Wirtschaftsinformatik sowohl
in ihren fachlichen Einzelheiten als auch in den themen-
und fachübergreifenden Zusammenhängen nach
wissenschaftlichen Methoden selbständig zu bearbeiten
und zu lösen oder
eine anspruchsvolle Fragestellung aus der aktuellen
Forschung auf dem Gebiet der Wirtschaftsinformatik
unter Anleitung eigenständig zu bearbeiten und
selbstständig ein neues wissenschaftliches Ergebnis zu
entwickeln.', NULL, 'Es wird eine praxisorientierte Problemstellung oder eine
Fragestellung aus der Forschung auf dem Gebiet der
Wirtschaftsinformatik mit den im Studium erworbenen
oder während der Master- Arbeit neu erlernten
wissenschaftlichen Methoden in begrenzter Zeit mit
Unterstützung eines erfahrenen Betreuers gelöst.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -
Wirtschaftsinformatik (Master) – PO2023 Modulkatalog');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (155, 1, 'Die Studierenden haben ein tieferes Verständnis für die
Aufgaben und Erfolgsfaktoren bei der Durchführung
eines mittelgroßen Software-Projekts in einem Team.
Das Projekt betrifft Aufgaben aus dem Bereich
Wirtschaftsinformatik.
Sie sind in der Lage, das im Studium bisher Erlernte –
insbesondere Methoden, Verfahren und Werkzeuge –
anzuwenden, um ein komplexes Softwareprojekt aus
der Wirtschaftsinformatik von der Anforderungsanalyse
über Entwurf, Implementierung und Evaluierung bis hin
zur Auslieferung selbstständig und im Team zu
bewältigen.
Die Studierenden können komplexe Aufgaben sinnvoll
strukturieren und typische Schnittstellenprobleme
sowohl auf technisch-fachlicher als auch auf sozialer
Ebene bewältigen. Sie können Management-Methoden
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 13 -
Wirtschaftsinformatik (Master) – PO2023 Modulkatalog
zur Projektdefinition, -planung und -kontrolle bei der
Projektarbeit anwenden.
Sie sind in der Lage, Besprechungen zu moderieren
sowie Arbeitsergebnisse professionell zu präsentieren
und zu bewerten.', NULL, 'Im Rahmen des Software-Projektes Master
Wirtschaftsinformatik bearbeiten die Teilnehmer eine
typische größere Aufgabenstellung aus dem Bereich
der Wirtschaftsinformatik in einem Projektteam. Die
Themenstellung erfolgt mit Rücksicht auf die
Kenntnisse der Studierenden.
Bei der Durchführung des Projektes steht die
systematische Anwendung und Zusammenführung des
Wissens aus dem jeweiligen Fachgebiet mit den
Methoden der Softwareentwicklung im Vordergrund:
Durchführung eines mittelgroßen und anspruchsvollen
Software-Projekts aus dem Gebiet der
Wirtschaftsinformatik.
Selbstständige Durchführung des Projekts von der
Analyse über Design, Implementierung und Test bis zur
Dokumentation.
Anwendung von grundlegenden Projektmanagement-
Methoden für Definition, Planung, Kontrolle und
Realisierung des Projekts.
Vertiefung von Kenntnissen in der Programmierung und
zu Programmiermethodiken.
Softwareentwicklung im Team und ggf. unter
Beteiligung von externen Anwendern
In regelmäßigen Projektsitzungen werden im Rahmen
einer Qualitätssicherung die Zwischenergebnisse von
den Teams durch Präsentation und Vorführung
vorgestellt und diskutiert.
Die Projektthemen werden rechtzeitig vor Beginn der
Veranstaltung bekannt gemacht. Es wird versucht,
praxisnahe Projekte auch von hochschulexternen
Anwendern der praktischen und technischen Informatik
zu akquirieren. Projektvorschläge von Studierenden
sind nach Absprache ebenfalls möglich.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (157, 1, 'Die Studierenden besitzen die folgenden Fähigkeiten:
Sie sind in der Lage, sich selbstständig in aktuelle
Forschungsfragen zur praktischen und technischen
Informatik auf der Basis von Primärliteratur
(Publikationen in Fachzeitschriften sowie
Tagungsbeiträge) einzuarbeiten.
Sie können Informationsrecherchen zu
forschungsorientierten Fragestellungen durchführen
und sind in der Lage, dazu eine strukturierte schriftliche
Aufbereitung des aktuellen Stands der Forschung zu
erarbeiten
Sie können eine zusammengefasste Darstellung der
Ergebnisse zu einer Fragestellung präsentieren sowie
in der Diskussion mit allen Seminarteilnehmern sich
ergebende Fragen beantworten und aufgestellte
Thesen verteidigen.', NULL, 'In diesem Seminar werden aktuelle oder vertiefende
Themen aus den Bereichen Wirtschaftsinformatik,
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 19 -
Wirtschaftsinformatik (Master) – PO2023 Modulkatalog
insbesondere Betriebliche Informationssysteme,
Business Intelligence, Big Data, Digitales Marketing,
Business Logistics und Geschäftsprozessmanagement.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (6, 1, '• Die Studierenden kennen und verstehen die
grundlegenden Elemente der imperativen und
objektorientierten (noch ohne Klassenhierarchie)
Programmierung.
• Sie können Rekursion und Iteration adäquat zur
Realisierung wiederholender Abläufe einsetzen.
• Anhand von Anwendungsbeispielen gewinnen sie ein
grundlegendes Verständnis für die Themen Effizienz
und Korrektheit.
• Die Studierenden wissen, dass Dokumentation und
Test untrennbar mit Programmierung verbunden
sind.
• Sie sind insgesamt in der Lage, zu einfachen
Aufgabenstellungen qualitativ gute Lösungen (in der
Lehrsprache Java) zu konzipieren und zu realisieren.', NULL, 'Begriff des Algorithmus • elementare Datentypen •
Typen und Werte von Ausdrücken • Rekursion und
Strategien zur Entwicklung rekursiver Lösungen •
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -
Informatik und Design (Bachelor) – PO2023 Modulkatalog
Klassen und Objekte • statische und Instanzmethoden •
Dokumentation von Klassen und Methoden •
Kontrollstrukturen • Entwurfsansätze für iterative
Lösungen • Kapselung und Abstraktion • Felder •
rekursive Datenstrukturen');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (96, 1, 'Die Studierenden kennen die Erfolgsfaktoren für gutes
Projektmanagement. Sie können die wesentlichen
Unterschiede von klassischem und agilem
Projektmanagement benennen und sind in der Lage für
ein gegebenes Projekt zu entscheiden, welche Vor- und
Nachteile die einzelnen Arten des Projektmanagements
haben. Sie kennen die Handwerkszeuge, die für
Planung, Überwachung und Risikomanagement zur
Verfügung stehen. Sie kennen die
Rahmenbedingungen, die einer Aufwandsschätzung
zugrundgelegt werden müssen und sind in der Lage
realistische Aufwände zu schätzen.', ', die im Bachelor- Modul Softwaretechnik vermittelt werden sowie Erfahrung in eigenen Software-Projekten bspw. im Bachelor-Studium. Angestrebte Lernergebnisse: Die Studierenden kennen die Erfolgsfaktoren für gutes Projektmanagement. Sie können die wesentlichen Unterschiede von klassischem und agilem Projektmanagement benennen und sind in der Lage für ein gegebenes Projekt zu entscheiden, welche Vor- und Nachteile die einzelnen Arten des Projektmanagements haben. Sie kennen die Handwerkszeuge, die für Planung, Überwachung und Risikomanagement zur Verfügung stehen. Sie kennen die Rahmenbedingungen, die einer Aufwandsschätzung zugrundgelegt werden müssen und sind in der Lage realistische Aufwände zu schätzen.', 'Grundlagen des Projektmanagements
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -
Informatik (Master) – PO2023 Modulkatalog
Klassisches Projektmanagement (Initiierung, Planung,
Aufwandsschätzung, Controlling, Abschluss), Agile
Softwareentwicklung
Die Veranstaltung basiert auf der aktiven Mitwirkung
aller Studierenden, inkl. Literaturstudium und
Internetrecherche. Die Themen werden zum großen
Teil durch die Teilnehmerinnen und Teilnehmer selbst
erarbeitet und präsentiert und in der Gruppe diskutiert
und praktisch geübt.
Mögliche Themenbereiche sind: Aufwandsschätzung,
Controlling, Risikomanagement, Change- Management,
Portfoliomanagement, Teammanagement und
Leadership, Kanban, PRINCE2. Weitere Themen
können durch die Teilnehmerinnen und Teilnehmer
selbst vorgeschlagen werden.
Die Lehrveranstaltung enthält eine Vorbereitung zur
Professional Scrum MasterTM I-Zertifizierung. Die
Zertifizierung kann freiwillig in Eigenregie über
scrum.org abgelegt werden.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (57, 1, 'Die Studierenden lernen unterschiedliche
Beschreibungssprachen und deren Einsatzgebiete
kennen und bekommen erste praktische Erfahrungen
mit deren Anwendung. Die Studierenden erlernen
Verfahren zur Erstellung dynamischer Web-Seiten und
wenden das Erlernte im Praktikum an.
Sie erlangen die Fähigkeit, neue Konzepte im Umfeld
der Internet-Sprachen schnell begreifen, einordnen und
bewerten zu können.', NULL, '• HTML
• CSS
• PHP
• XML, Verarbeitung von XML-Dateien mit Java, XML-
Schema, XSLT, …
• JavaScript, AJAX
• Web-Services
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -
Informatik (Bachelor) – PO2023 Modulkatalog');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (116, 1, 'Die Studierenden besitzen grundlegende Kenntnisse
über Datenschutz und Ethik.
Sie haben ein gutes Verständnis über die
fundamentalen Gesetze, Verordnungen und Strategien
im Datenschutz.
Sie erlernen den Sinn und Zweck einer Ethik in der
vernetzten Informations- und Wissensgesellschaft.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 62 -
Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit
(enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, '• Einführung in Datenschutz und Ethik.
• Begriffsbestimmungen: personenbezogene Daten,
Datenregister, …
• Informationelle Selbstbestimmung,
Bundesdatenschutzgesetz, Teledienstedatenschutz,
Telekommunikationsgesetz, DSGVO, …
• Rechte der Betroffenen.
• Organisatorische und technische Maßnahmen zum
Schutz personenbezogene Daten.
• Ethik in der vernetzten Informations- und
Wissensgesellschaft.');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (91, 1, 'Die Studierenden besitzen ein geschärftes
professionelles Selbstverständnis als Mitglieder ihres
Berufsstandes.
Sie verstehen besser als vorher die gegenseitigen
Wechselwirkungen zwischen der technologischen
Entwicklung der Informatik und gesellschaftlichen
Prozessen und Konflikten und sind hierbei in der Lage,
Alternativen zu bewerten und eine eigene Beurteilung
zu entwickeln.
Die Studierenden besitzen ein erhöhtes individuelles
Problem- und Verantwortungsbewusstsein bei der
Berufsausübung und Erarbeitung konkreter
Möglichkeiten und Handlungsalternativen zur
Wahrnehmung dieser Verantwortung.
Sie können ihr Wissen sowie eigene Bewertungen und
Beurteilungen in selbständig erarbeiteten Vorträgen
und Ausarbeitungen darstellen und in Fachgesprächen
vertreten.
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 5 -
Informatik (Master) – PO2023 Modulkatalog', NULL, 'In dieser Lehrveranstaltung werden wichtige
Auswirkungen der Informatik auf die Gesellschaft
behandelt. Spezielle Themen sind hierbei u.a.:
• Nationale und internationale Berufsverbände (GI,
ACM, IEEE)
• Das Recht auf informationelle Selbstbestimmung
und seine Gefährdung durch die Anwendungen
neuer Informatik-Technologien, insbesondere auf
der Basis des Internets.
• Auswirkungen der Informatik auf die Arbeitswelt.
• Ethische Leitlinien der Gesellschaft für Informatik
(GI) sowie der Association for Computing Machinery
(ACM).');
INSERT INTO public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) VALUES (159, 1, 'Komplexe Unternehmenanforderungen sind im
Rahmen einer gemeinsamen Spielsituation (Serious
Business Game) zu analysieren, zu planen und zu
entscheiden sowie die Ergebnisse dieser
Entscheidungen zu beurteilen und zu korrigieren bzw.
fortzuführen.
Die Studierenden werden in die Lage versetzt, u.a.
• die strategisches und operatives Management im
unternehmerischen Kontext zu verstehen und zu
erläutern,
• die wesentlichen Aufgaben der betrieblichen
Funktionalbereiche und deren Interdependenzen zu
verstehen,
• die Bewältigung von komplexen
Entscheidungssituationen
• die Etablierung und Skalierung eines neuen
Geschäftsmodells
Westfälische Hochschule
Fachbereich Informatik und Kommunikation MODULHANDBUCH - 54 -
Wirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft', NULL, 'Aus dem Bereich der Allgemeinen
Betriebswirtschaftslehre insbesondere
Unternehmensführung, u.a.
• Corporate Entrepreneurship
• Geschäftsmodell-Innovation
• Marktsignale und Trends auf neuem und
unerforschtem Terrain richtig deuten
• Strategische Geschäftsentwicklung
• Strategisches Marketing
• Personalplanung und –qualifikation,
Produktivitäte
• Produktmanagement
• Nachhaltigkeit der Produktion
• Investitions- und Auslastungsplanung
• Finanz- und Rechnungswesen
• Umgang mit Komplexität, Unsicherheit und
Volatilität
Mit Hilfe wechselnder Planspielangebote (TopSim oder
andere) können jeweils unterschiedliche Schwerpunkte
gesetzt und auf ausgewählte Problemstellungen im
Management-Kontext näher eingegangen werden.');


--
-- Data for Name: modul_literatur; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (1, 1, 1, 'Skript, ergänzend:', NULL, NULL, NULL, NULL, NULL, true, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (2, 1, 1, 'Cormen, Leierson, Rivest, Stein: Introduction to Algorithms, MIT Press', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (3, 1, 1, 'Skiena: Algorithm Design Manual, Springer jeweils in aktueller Auflage.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (4, 2, 1, 'Eckermann, Ines Maria: Frei & kreativ: Das Handbuch für den Start in die Selbstständigkeit. Alles, was kreative Köpfe zu Existenzgründung, Businessplan, Akquise und Co. wissen müssen, 2021 Osterwalder, Alexander und Pigneur, Yves et al.: Business Model Generation: Ein Handbuch für Visionäre, Spielveränderer und Herausforderer, 2011 Leipziger, Jürg W: Konzepte entwickeln: Handfeste Anleitungen für bessere Kommunikation, 2010', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (5, 3, 1, 'Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 9 - Informatik und Design (Bachelor) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (6, 3, 1, 'Karmasin, M', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (7, 3, 1, 'Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (8, 3, 1, 'Weitere themenspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (9, 4, 1, 'Einführung in die plattformübergreifende Entwicklung Einführung in aktuelle Frameworks, z.B. Flutter, Xamarin, ReactNative mit Fokus auf eines, das dann im Projekt genutzt wird sowie die zugrundeliegenden Programmiersprachen (z.B. Dard, C#, Javascript). Hierbei wird auch mit Hilfe von bereitgestellten Materialien ein hoher Selbstlernanteil integriert. Softwaretechnische Grundlagen für plattformübergreifende Entwicklung, z.B. Design- Patterns wie MVVM In Projektgruppen wird das theoretisch erlernte Wissen direkt im Rahmen eines realitätsnahen Semesterprojekts oder mehreren Vorlesungsbegleitetenden kleinen Projektaufgaben in die Praxis überführt.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (10, 5, 1, 'Heuer, Sattler, Saake. Datenbanken: Konzepte und Sprachen. mitp-Verlag', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (11, 5, 1, 'Elmasri, Navathe. Grundlagen von Datenbanksystemen. Pearson Studium', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (12, 5, 1, 'Foundations of Databases, Serge Abiteboul, Rick Hull, Victor Vianu, 1995.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (13, 5, 1, 'Ramakrishnan, Gehrke. Database Management Systems. McGraw-Hill', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (14, 6, 1, 'Joachim Goll, Cornelia Heinisch: Java als erste Pro- grammiersprache. Springer Vieweg, 2016.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (15, 6, 1, 'Christian Ullenboom: Java ist auch eine Insel. Rheinwerk Computing, 2021.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (16, 6, 1, 'Offizielle Spezifikation der jeweils aktuellen Java- Version als Nachschlagewerk', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (17, 7, 1, 'Akenine-Möller, T. et. al.: Real-Time Rendering. 4th edition, CRC Press, 2018. Rick Parent: Computer Animation: Algorithms and Techniques. 3rd edition, Morgan Kaufman / Elsevier, Third Edition, 2012. Dörner, R', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (18, 7, 1, 'Jung, B. (Hrsg.): Virtual und Augmented Reality (VR / AR): Grundlagen und Methoden der Virtuellen und Augmentierten Realität. Verlag: Springer Vieweg 2019. Bender, M.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (19, 7, 1, 'Brill, M.: Computergrafik. 2. Auflage, Carl Hanser, 2006.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (20, 8, 1, 'Projekt-spezifisch', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (21, 9, 1, 'Projekt-spezifisch', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (22, 10, 1, 'Themenspezifische Literatur in Online-Literaturliste in Moodle', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (23, 11, 1, 'Kuzbari, Rafic', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (24, 11, 1, 'Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256 Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978- 3642134197', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (25, 12, 1, 'Skript, ergänzend:', NULL, NULL, NULL, NULL, NULL, true, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (26, 12, 1, 'Schöning: Logik für Informatiker, Spektrum', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (27, 12, 1, 'Schöning: Ideen der Informatik, Oldenbourg jeweils in aktueller Auflage.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (28, 13, 1, 'Heinecke A. M.: Mensch-Computer-Interaktion – Basiswissen für Entwickler und Gestalter. x.media.press, Springer, Berlin 2014.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (29, 13, 1, 'Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (30, 13, 1, 'Epple A.: JavaFX 8: Grundlagen und fortgeschrittene Techniken. dpunkt.verlag, Heidelberg 2015.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (31, 13, 1, 'Offizielle Java Dokumentation (Oracle) sowie verschiedene, geprüfte und als Onlinematerialien hinterlegte Web-Tutorials zu JavaFX.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (32, 14, 1, 'Weitz, E.: Konkrete Mathematik (nicht nur) für Informatiker', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (33, 14, 1, 'Papula, L.: Mathematik für Ingenieure und Naturwissenschaftler Band 1: Ein Lehr- und Arbeitsbuch für das Grundstudium', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (34, 15, 1, 'Joachim Goll, Cornelia Heinisch: Java als erste Pro- grammiersprache. Springer Vieweg, 2016.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (35, 15, 1, 'Christian Ullenboom: Java ist auch eine Insel. Rheinwerk Computing, 2021.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (36, 15, 1, 'Martin Fowler: Refactoring, Improving the Design of Existing Code. Addison Wesley, 2018.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (37, 15, 1, 'Offizielle Spezifikation der jeweils aktuellen Java- Version als Nachschlagewerk', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (38, 16, 1, 'Gothelf, J., & Seiden, J. (2021). Lean UX. " O''Reilly Media, Inc.".', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (39, 17, 1, 'https://designsprint.org/de/ https://hpi-academy.de/design-thinking/ Dreyfuss, H. (203). Designing for people. Skyhorse Publishing Inc.. Aktuelle Literatur und Selbstlernmaterial wird zu Beginn bekannt gegeben. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 41 - Informatik und Design (Bachelor) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (40, 19, 1, 'Weitz, E.: Konkrete Mathematik (nicht nur) für Informatiker', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (41, 19, 1, 'Papula, L.: Mathematik für Ingenieure und Naturwissenschaftler Band 2 (Lineare Algebra) und Band 3 (Statistik)', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (42, 19, 1, 'P. Knabner, W. Barth: Lineare Algebra: Grundlagen und Anwendungen. Springer (2018)', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (43, 19, 1, 'E. Kramer, U. Kamps: Statistik und Wahrscheinlichkeitsrechnung. Springer (2008)', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (44, 19, 1, 'P. Planing: Statistik Grundlagen. Planing Publishing (2022)', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (45, 19, 1, 'A. Rooch: Statistik für Ingenieure. Springer (2014)', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (46, 19, 1, 'Weitere Literatur wird in der Vorlesung bekannt gegeben.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (47, 20, 1, 'Spezifisch zu den ausgewählten Learning Units', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (48, 21, 1, 'Spezifisch zu den ausgewählten Learning Units', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (265, 85, 1, 'Wöhe, Günter', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (49, 22, 1, 'Pisani, Patricia und Radtke, Susanne P.: Medienkompetenz: Handbuch Visuelle Mediengestaltung: Visuelle Sprache - Grundlagen der Gestaltung - Konzeption digitaler Medien - Fotogestaltung und Usability, 2012', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (50, 22, 1, 'Wäger, Markus: Grafik und Gestaltung: Mediengestaltung von A bis Z verständlich erklärt, 2014', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (51, 22, 1, 'Bergmann, Roberta: Die Grundlagen des Gestaltens: Plus: 50 praktische Übungen, 2021', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (52, 22, 1, 'Willberg, Hans P. Und Forssman, Friedrich: Lesetypografie, 2010', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (53, 22, 1, 'Hammer, Norbert: Mediendesign für Studium und Beruf (Grundlagenwissen und Entwurfssystematik in Layout, Typografie und Farbgestaltung), 2008', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (54, 22, 1, 'Weitere Literatur in Online-Literaturliste in Moodle', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (55, 23, 1, 'Dirk W. Hoffmann: Grundlagen der Technischen Informatik. 3. Auflage. Hanser Fachbuch, 2013. Andrew S. Tanenbaum, Herbert Bos: Moderne Betriebssysteme. Pearson Studium, 2016. Andrew S. Tanenbaum: Computernetzwerke. 5. Auflage, Pearson Studium, 2012. Dirk W. Hoffmann, Theoretische Informatik, Carl Hanser Verlag, 5. Auflage, 2022.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (56, 24, 1, 'Lewrick, Michael und Link, Patrick: The Design Thinking Playbook: Mindful Digital Transformation of Teams, Products, Services, Businesses and Ecosystems, 2018', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (57, 24, 1, 'Noack, Jana und Diaz, Jose: Das Design Sprint Handbuch: Ihr Wegbegleiter durch die Produktentwicklung, 2019', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (58, 24, 1, 'Wäger, Markus: Grafik und Gestaltung: Design und Mediengestaltung von A bis Z, 2016', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (59, 24, 1, 'Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (60, 25, 1, 'Sommerville, Ian: Software Engineering, Pearson, 10. aktualisierte Auflage, 2018', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (61, 25, 1, 'Sommerville, Ian: Modernes Software- Engineering, Pearson, 2020', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (62, 25, 1, 'Software Engineering Body of Knowledge (SWEBOOK): https://www.computer.org/education/bodies-of- knowledge/software-engineering (Version 4.0a, 2025)', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (63, 26, 1, 'Wird in der ersten Veranstaltung bekannt gegeben Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 59 - Informatik und Design (Bachelor) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (64, 27, 1, 'Cook, J. (2017): Docker for Data Science. Apress, Springer, New York. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 62 - Informatik und Design (Bachelor) – PO2023 Learning Units BUILDING Hunter, T. (2017): Advanced Microservices. Apress, Springer, New York. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 63 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (65, 28, 1, 'Ramos, Brais. B.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (66, 28, 1, 'Doran, John P.: Unreal Engine 4 Shaders and Effects Cookbook. Packt Publishing, 2019. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 64 -', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (67, 29, 1, 'Noch zu definieren Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 65 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (68, 30, 1, 'Wird im Modul bekanntgegeben Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (69, 31, 1, 'Schmidt, Eric: Arduino Programming for Beginners: A Comprehensive Beginner’s Guide to Learn the Realms of Arduino Programming from A-Z Independently published (10. August 2022). ISBN: 979-8846004832. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 67 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (70, 32, 1, 'Sumeragi, Kyou', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (71, 32, 1, 'Yusuf, Arthatama: Learning Blender Python: A Beginner''s First Steps in Understanding Blender Python. Independently published (16. Februar 2020). ISBN-13: 979-8608118104. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 68 -', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (72, 33, 1, 'Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 69 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (73, 34, 1, 'Hammad Fozi et. al.: Game Development Projects with Unreal Engine: Learn to build your first games and bring your ideas to life using UE4 and C++. Packt Publishing Ltd. 2020. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 71 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (74, 35, 1, 'Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 73 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (75, 36, 1, 'Hammad Fozi et. al.: Game Development Projects with Unreal Engine: Learn to build your first games and bring your ideas to life using UE4 and C++. Packt Publishing Ltd. 2020. ISBN: 978-1-80020-922-0. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 75 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (76, 37, 1, 'Aktuelle Literatur wird abhängig von der thematischen Schwerpunktsetzung zum Semesterstart bekannt Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 76 - Informatik und Design (Bachelor) – PO2023 Learning Units BUILDING gegeben Basisliteratur: WOLF, Jürgen, 2016. HTML5 und CSS3: das umfassende Handbuch. 2. Auflage. Bonn: Rheinwerk. ISBN 978-3-8362-4158-8, 3-8362-4158-7 HELLER, Stephan, 2015. PHP 5.6 - Grundlagen zur Erstellung dynamischer Webseiten. Bodenheim: Herdt. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 77 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (77, 38, 1, 'Mitch McCaffrey: Unreal Engine VR Cookbook. Pearson Education, 2017. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 79 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Learning Units DESIGNING Die nachfolgenden Learning Units können Teil des Moduls Projekt-Support-Modul DESIGNING Sustainable Futures sein. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 80 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (78, 39, 1, 'Andreas Asanger: Blender 3 – Das umfassende Handbuch. Rheinwerk-Verlag, Bonn 2022. John M. Blain: The Complete Guide to Blender Graphics – Computer Modeling & Animation. 7th edition, CRC Press, 2022. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 82 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (79, 40, 1, 'Giogoli, André und Hausel, Katharina: Bildgestaltung: die große Fotoschule. Von guten Bildern lernen: Theorie, Analyse, kreative Praxis. Mit vielen Anregungen und Übungen, 2022 Hogl, Marion: Digitale Fotografie: Über 700 Seiten Praxiswissen zu Technik, Bildgestaltung und Motiven, 2021 Freeman, Michael und Schmithäuser, Michael: Michael Freemans Komposition: Eine Masterclass für die fotografische Bildgestaltung, 2022 Rempen, Thomas und Stoklossa, Uwe: Blicktricks: Anleitung zur visuellen Verführung, 2005 Pricken, Mario und Klell, Christine: Visuelle Kreativität: Kreativitätstechniken für neue Bildwelten in Werbung, 3- D-Animation und Computergames, 2003 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 84 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (80, 41, 1, 'Baetzgen, Andreas: Brand Design: Strategien für die digitale Welt, 2017 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 85 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (81, 42, 1, 'Andreas Asanger: Blender 3 – Das umfassende Handbuch. Rheinwerk-Verlag, Bonn 2022. John M. Blain: The Complete Guide to Blender Graphics – Computer Modeling & Animation. 7th edition, CRC Press, 2022. Rick Parent: Computer Animation – Algorithms & Techniques. Morgan Kaufmann (3rd ed), 2012. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 87 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (82, 43, 1, 'Jesse Schell: The Art of Game-Design – A Book of Lenses. 3rd Edition, CRC Press, Taylor & Francis Group, 2020. Werbach Kevin, Hunter Dan: For the Win – The Power of Gamification and Game Thinking in Business, Education, Goverment and Social Impact. Wharton School Press, 2020. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 89 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (83, 44, 1, 'Hil Darjan und Lachenmeier Nicole: Visualizing Complexity: Handbuch modulares Informationsdesign, 2022 Heber, Raimar: Infografik: Gute Geschichten erzählen mit komplexen Daten: Fakten und Zahlen spannend präsentieren!, 2016 Stapelkamp, Torsten: Informationsvisualisierung: Web - Print - Signaletik. Erfolgreiches Informationsdesign: Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 90 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Leitsysteme, Wissensvermittlung und Informationsarchitektur, 2012 Data Flow: Visualising Information in Graphic Design, 2008 Weber, Wibke: Kompendium Informationsdesign, 2007 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 91 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (84, 45, 1, 'Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann. Lim, Y. K., Stolterman, E., & Tenenberg, J. (2008). The anatomy of prototypes: Prototypes as filters, prototypes as manifestations of design ideas. ACM Transactions on Computer-Human Interaction (TOCHI), 15(2), 1-27. Dokumentation und geprüfte Tutorials unterschiedlicher Prototyping Tools Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 93 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (85, 46, 1, 'Salmond, Michael: Video Game Level Design: How to Create Video Games with Emotion, Interaction, and Engagement. Bloomsbury Academic, 2021. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 94 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (86, 47, 1, 'Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 95 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (87, 48, 1, 'Alam, Daud und Gühl, Uwe: Projektmanagement für die Praxis: Ein Leitfaden und Werkzeugkasten für erfolgreiche Projekte, 2021 Dellnitz, Julia und Gentsch, Jan: Daily Play: Agile Spiele für Coaches und Scrum Master. Über 20 Spiele für agiles Projektmanagement, 2021 Kaltenecker, Siegfried: Selbstorganisierte Teams führen: Arbeitsbuch für Lean & Agile Professionals, 2021 Koschek, Holger und Trbojevic, Markus: Jedes Team ist anders: Ein Praxisbuch für nachhaltige Teamentwicklung, 2022 Sibbet, David: Visuelle Meetings: Meetings und Teamarbeit durch Zeichnungen, Collagen und Ideen- Mapping produktiver gestalten, 2011 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 97 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (88, 49, 1, 'Radtke, Susanne P.: Interkulturelle Design-Grundlagen: Kulturelle und soziale Kompetenz für globales Design, 2022 Bieling, Tom: Inklusion als Entwurf: Teilhabeorientierte Forschung über, für und durch Design, 2019 Tromp, Nynkeund Hekkert, Paul: Designing for Society: Products and Services for a Better World, 2018 Stickdorn, Marc und Schneider, Jakob: This Is Service Design Thinking: Basics, Tools, Cases, 2012 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 99 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (89, 50, 1, 'Pyczak, Thomas: Tell me!: Wie Sie mit Storytelling überzeugen. Mit vielen Praxisbeispielen. Für alle, die erfolgreich sein wollen in Beruf, PR und Marketing, 2020 Lupton, Ellen: Design is Storytelling, 2017 Willemien, Brand: Visuelles Denken: Stärkung von Menschen und Unternehmen durch visuelle Zusammenarbeit, 2019 Schaffranek, Ines: Sketchnotes kann jeder: Visuelle Notizen leicht gemacht – Für Einsteiger und Fortgeschrittene', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (90, 50, 1, 'Graphic Recording für Hobby und den beruflichen Einsatz!, 2017 Fuchs, Werner T: Warum das Gehirn Geschichten liebt, Haufe, 2009 Christiano, Giuseppe: Storyboard Design (Grundlagen', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (91, 50, 1, 'Übungen und Techniken), 2008 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 101 -', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (92, 51, 1, 'Stickdorn, Marc et al.: This is Service Design Doing, 2017 Nunnally, Brad und Farkas, David: UX Research: Practical Techniques for Designing Better Products, 2017 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 102 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Falbe, Trine: White Hat UX: The Next Generation in User Experience, 2017 Lewrick, Michael et al.: Das Design Thinking Playbook: Mit traditionellen, aktuellen und zukünftigen Erfolgsfaktoren, 2018 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 103 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (93, 52, 1, 'Jovy, Jörg: Digital filmen: Das umfassende Handbuch: Filme planen, aufnehmen, bearbeiten und präsentieren, 2019 Rogge, Axel: Videoeffekte: Attraktive Filme mit kleinem Budget: Videoschnitt, Blende, Zeitraffer, Soundeffekte und Greenscreen, 2015 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 105 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (94, 53, 1, 'Spies, Marco & Wenger, Katja: Branded Interactions: Marketing Through Design in the Digital Age, 2020 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 106 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Rohles, Björn: Grundkurs gutes Webdesign: Alles, was Sie über Gestaltung im Web wissen müssen, für moderne und attraktive Websites, die jeder gerne besucht!, 2017 Head, Val: Designing Interface Animation: Improving the User Experience Through Animation, 2016 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 107 -', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (95, 54, 1, 'Karmasin, M', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (96, 54, 1, 'Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 108 -', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (364, 110, 1, 'Foundations of Databases, Serge Abiteboul, Rick Hull, Victor Vianu, 1995.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (100, 55, 1, 'Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400 Karmasin, M', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (101, 55, 1, 'Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 7 - Informatik (Bachelor) – PO2023 Modulkatalog Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596 Weitere themenspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (102, 56, 1, 'Bekanntgabe in der Vorlesung Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 9 - Informatik (Bachelor) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (110, 57, 1, 'Bekanntgabe in der Vorlesung', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (111, 58, 1, 'Kuzbari, Rafic', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (112, 58, 1, 'Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (113, 58, 1, 'Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer,2010. ISBN: 978- 3642134197', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (127, 59, 1, 'Riggert/ Lübben, Rechnernetze, Hanser Verlag, aktuellste Auflage (online-Ressource)', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (128, 59, 1, 'Dye, McDonald, Rufi', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (129, 59, 1, 'Network Fundamentals, Cisco Press, 2007, ISBN 978-1-58713-208-7', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (130, 59, 1, 'LAN Switching and Wireless, Cisco Press, 2008, ISBN 978-1- 58713-207-0', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (131, 59, 1, 'Graziani, Johnson', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (132, 59, 1, 'Routing Protocols and Concepts, Cisco Press, 2007, ISBN 978-1-58713-206-3', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (133, 59, 1, 'Vachon, Graziani', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (134, 59, 1, 'Accessing the WAN, Cisco Press, 2009, ISBN 978-1- 58713-205-6', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (135, 59, 1, 'Aktuelle Ergänzungen auf den Moodle-Kurs zu diesem Modul', NULL, NULL, NULL, NULL, NULL, false, 11);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (143, 60, 1, 'Theisen, Manuel René, Wissenschaftliches Arbeiten: Erfolgreich bei Bachelor- und Masterarbeit, 17. aktualis. und bearb. Aufl., 2017, Verlag Franz Vahlen GmbH, 320 Seiten, ISBN: 978-3-8006-5382-9', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (144, 60, 1, 'Burghardt, Manfred, Einführung in Projektmanagement: Definition, Planung, Kontrolle und Abschluss, 6. aktualis. und erw. Aufl., 2013, Publicis Corporate Publishing, 391 Seiten, ISBN: 978-3895784002', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (145, 60, 1, 'Helmut Balzert, Lehrbuch der Software-Technik – Software- Management, Software- Qualitätssicherung, Unternehmensmodellierung, Band 2, 2. Auflage, Spektrum Akademischer Verlag, 2008, 721 Seiten, ISBN: 978-3827411617', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (149, 61, 1, 'Wird in der ersten Veranstaltung bekannt gegeben Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 39 - Informatik (Bachelor) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (150, 62, 1, 'Häberlein, Tobias, Technische Informatik Vieweg und Teubner Verlag, aktuellste Auflage', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (151, 62, 1, 'Hoffmann, Dirk W. , Grundlagen der Technischen Informatik, Hanser Verlag, aktuellste Auflage', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (152, 62, 1, 'Eventuelle weitere aktuelle Literatur wird im zugehörigen Moodle Kurs genannt', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (469, 133, 1, 'Literatur an das aktuelle Thema angepasst', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (153, 63, 1, 'Dirk W. Hoffmann, Theoretische Informatik, Carl Hanser Verlag, 5. aktualisierte Auflage, 2022, 432 Seiten, ISBN: 978-3-446-47029-3', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (154, 63, 1, 'Uwe Schöning: Theoretische Informatik – kurzgefasst, Spektrum Akademischer Verlag, 5. Auflage, 2003, 190 Seiten, ISBN-13: 978-3-827- 41824-1', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (155, 64, 1, 'Bekanntgabe in der Vorlesung', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (156, 65, 1, 'J. Steinmüller: „Bildanalyse“, Springer Verlag, ISBN 978-3540797425.- A. Nischwitz, P. Haberäcker: „Computergrafik und Bildverarbeitung, Band II Bildverarbeitung“, TeubnerVerlag, ISBN 978-3-834- 81712-9 A. Kaehler, G Bradski: "Learning OpenCV 3: Computer Vision in C++ with the OpenCV", 978-1491937990', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (157, 66, 1, 'B. Müller, H. Wehr: Java Persistence API , Hanser Verlag, aktuelle Ausgabe', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (158, 66, 1, 'Relevante Dokumentationen und Spezifikationen der verwendeten Technologien werden in der Vorlesung bekanntgegeben', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (159, 67, 1, 'Benjamin M. Abdel-Karim: Data Science - Best Practices mit Python (Springer 2022)', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (160, 67, 1, 'Manas A. Pathak: Beginning Data Science with R (Springer 2014)', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (161, 67, 1, 'Joel Grus: Einführung in Data Science – Grundprinzipien der Datenanalyse mit Python (O’Reilly 2019)', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (162, 67, 1, 'Annalyn Ng, Kenneth Soo: Data Science – was ist das eigentlich?!', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (163, 67, 1, 'Weitere Literatur wird in der Veranstaltung bekannt gegeben.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (164, 68, 1, 'Lehmann et al.: Handbuch der Medizinischen Informatik, (Hanser 2005)', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (165, 68, 1, 'Martin Dugas und Katrin Schmidt: Medizinische Informatik und Bioinformatik (Springer 2002)', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (166, 68, 1, 'Kenneth Rothman, Sander Greenland, Timothy Lash: Modern Epidemiology (Wolter Kluwer, 2008)', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (167, 68, 1, 'Weitere Literatur wird in der Veranstaltung bekannt gegeben.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (168, 69, 1, 'Wolfgang Weber: Industrieroboter, Methoden der Steuerung und Regelung, Hanser Verlag, 4. Auflage, ISBN 978-3-446-41031-2', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (169, 69, 1, 'Quigley, M: Programming Robots with ROS: A Practical Introduction to the Robot Operating System', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (170, 69, 1, 'P.I. Corke, “Robotics, Vision & Control”, Springer 2017, ISBN 978-3-319-54413-7 und Robotics Tollbox for Python- Introduction to Robotics: Mechanics and Control: Global Edition, 3rd Edition', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (171, 69, 1, 'Bruno Siciliano, Oussama Khatib (Eds.): Handbook of Robotic, ISBN 978-3-540-23957-4', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (172, 70, 1, 'Tanenbaum, A.: "Computernetzwerke"', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (173, 70, 1, 'Prentice Hall, 2003', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (174, 70, 1, 'ISBN: 3- 8273-7046-9', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (175, 70, 1, 'Tanenbaum, A.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (176, 70, 1, 'van Stehen, M.: "Verteilte Systeme - Grundlagen und Paradigmen"', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (178, 70, 1, 'ISBN: 3-8273-7057-4', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (179, 70, 1, 'Proebster, W: "Rechnernetze - Technik, Protokolle, Systeme, Anwendungen"', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (180, 70, 1, 'Oldenbourg Verlag', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (181, 70, 1, 'ISBN: 3-486-25777-3', NULL, NULL, NULL, NULL, NULL, false, 11);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (182, 70, 1, 'Kreutzer, M.: "Telematik- und Kommunikationssysteme in der vernetzten Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 58 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik Wirtschaft"', NULL, NULL, NULL, NULL, NULL, true, 14);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (184, 70, 1, 'ISBN: 3-486-25888- 5', NULL, NULL, NULL, NULL, NULL, false, 16);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (185, 70, 1, '"Protokolle und Dienste der Informationstechnologie"', NULL, NULL, NULL, NULL, NULL, false, 18);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (186, 70, 1, 'Interest Verlag', NULL, NULL, NULL, NULL, NULL, false, 19);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (187, 70, 1, 'ISBN: 3- 8245-0412-X', NULL, NULL, NULL, NULL, NULL, false, 20);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (188, 70, 1, 'S. Feld, N. Pohlmann, M. Sparenberg, B. Wichmann: „Analyzing G-20´Key Autonomous Systems and their Intermeshing using AS-Analyzer”. In Proceedings of the ISSE 2012 - Securing Electronic Business Processes - Highlights of the Information Security Solutions Europe 2012 Conference, Eds.: N. Pohlmann, H. Reimer, W. Schneider', NULL, NULL, NULL, NULL, NULL, false, 21);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (189, 70, 1, 'Springer Vieweg Verlag, Wiesbaden 2012', NULL, NULL, NULL, NULL, NULL, false, 22);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (190, 71, 1, 'Nach Bekanntgabe in der Vorlesung.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (191, 72, 1, 'N. Pohlmann: „Cyber-Sicherheit - Das Lehrbuch für Konzepte, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung“ 2. Auflage, Springer Vieweg Verlag, Wiesbaden 2022', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (192, 72, 1, 'Pohlmann, N.: Firewall-Systeme - Sicherheit für Internet und Intranet, E- Mail-Security, Virtual Private Network, Intrution Detection-System, Personal Firewalls. 5. aktualisierte und erweiterte Auflage', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (193, 72, 1, 'ISBN 3- 8266-0988-3', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (194, 72, 1, 'MITP-Verlag, Bonn 2003', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (195, 72, 1, 'Pohlmann, N.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (196, 72, 1, 'Reimer, H.: "Trusted Computing - Ein Weg zu neuen IT- Sicherheitsarchitekturen”, ISBN 978-3-8348-0309-2, Vieweg-Verlag, Wiesbaden 2008', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (197, 72, 1, 'H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Auflage, ISBN-10: 3-8266-1635-9', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (198, 72, 1, '523 Seiten, MITP- Verlag, Bonn 2006', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (199, 72, 1, 'M. Hertlein, P. Manaras, N. Pohlmann: “Bring Your Own Device For Authentication (BYOD4A) – The Xign–System“. In Proceedings of the ISSE 2015 - Securing Electronic Business Processes - Highlights of the Information Security Solutions Europe 2015 Conference, Eds.: N. Pohlmann, H. Reimer, W. Schneider', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (200, 72, 1, 'Springer Vieweg Verlag, Wiesbaden 2015', NULL, NULL, NULL, NULL, NULL, false, 11);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (201, 73, 1, 'Sommerville, Ian: Software Engineering, Addison- Wesley, 10th Edition, 2015', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (202, 73, 1, 'George T. Heineman, William T. Councill: Component-Based Software Engineering: Putting the Pieces Together, Addison-Wesley Professional, 2001', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (203, 73, 1, 'Clemens Szyperski: Component Software: Beyond Object-Oriented Programming. 2nd Edition, Addison- Wesley, 2002', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (204, 73, 1, 'Eric Jendrock, Ricardo Cervera-Navarro, Ian Evans, Kim Haase, William Markito: The Java EE 7 Tutorial, 2014', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (205, 73, 1, 'SPRING Framework documentation: https://spring.io/', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (206, 74, 1, 'Russell, Norvig: Artificial Intelligence, A Modern Approach, Pearson, in der jeweils aktuellen Auflage', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (207, 74, 1, 'Ertel, Grundkurs Künstliche Intelligenz, Springer, in der jeweils aktuellen Auflage', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (208, 74, 1, 'Ergänzende grundlegende und aktuelle Forschungsarbeiten und Vorträge.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (209, 75, 1, 'P.Hitzler, M. Krötzsch, S. Rudolph: Foundations of Semantic Web Technologies, CRC Press, 2009. T. Heath, Ch. Bitzer: Linked Data – Evolving the Web into a Global Data Space, Morgan & Claypool, 2011.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (210, 76, 1, 'Liebel, C.: Progressive Web Apps: Das Praxisbuch. Rheinwerk Computing, 2018.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (211, 76, 1, 'Sillmann, T.: Das Swift-Handbuch: Apps programmieren für macOS, iOS, watchOS und tvOS. Carl Hanser Verlag, 2025.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (212, 76, 1, 'Springer, S.: React: Das umfassende Handbuch, Rheinwerk Computing, 2023.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (213, 76, 1, 'Theis, T.: Einstieg in Kotlin: Apps entwickeln mit Android Studio. Rheinwerk Computing, 2021.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (214, 77, 1, 'Jens Riwotzki, Cloud-Computing Theorie und Praxis, HERDT-Verlag', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (215, 77, 1, 'Ulrich Trick, Einführung in die Mobilfunknetze der 5. Generation, Walter de Gruyter GmbH', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (216, 77, 1, 'Michael Sauter, Grundkurs Mobile Kommunikationssysteme, Springer Vieweg, aktuellste Auflage', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (217, 77, 1, 'Aktuelle Ergänzungen im Moodle-Kurs zu diesem Modul', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (218, 78, 1, 'J. Hertzberg, K. Lingemann, A. Nüchter: „Mobile Roboter: Eine Einführung aus Sicht der Informatik“, ISBN 978-3642017254', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (219, 78, 1, 'B. Siciliano, O. Khatib (Eds.): „Handbook of Robotic“, ISBN 978-3-540-23957-4', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (220, 78, 1, 'Craig, J.J. (2004), „Introduction to Robotics: Mechanics and Control (3rd Edition)“, 8, 2004. Prentice Hall', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (221, 78, 1, 'R. Siegwart „Introduction to Autonomous Mobile Robots“, MIT Press, ISBN: 978-0-262-19502 -7', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (222, 78, 1, 'S. Thrun, W. Burgard, D. Fox: „Probabilistic Robotics“, ISBN 978-0262201629', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (223, 79, 1, 'Thomas Rauber: “Parallele Programmierung”, Springer Verlag, ISBN 978-3-540-46549-2.- S. Hoffmann, R. Lienhart: "OpenMP"', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (224, 79, 1, 'T. Rauber, G. Rünger: "Multicore: Parallele Programmierung"', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (225, 79, 1, 'Norm Matloff: "Programming on Parallel Machines', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (226, 79, 1, 'GPU, Multicore, Clusters and More"', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (227, 80, 1, 'Manfred Dausmann, Ulrich Bröckl und Joachim Goll, C als erste Programmiersprache. Vom Einsteiger zum Profi. 8. überarb. und erw. Auflage, Springer Vieweg, 2014, 727 Seiten, ISBN-13: 978-3-834- 81858-4', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (228, 80, 1, 'Jürgen Wolf, C von A bis Z. Rheinwerk Computing, 3., aktualisierte und erweiterte Auflage, 2009, 1190 Seiten, ISBN-13: 978-3-8362-1411-7', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (229, 80, 1, 'Vogt: C für Java-Programmierer, Carl Hanser Verlag 2007, 256 Seiten, ISBN-13: 978-3-446-4079-78', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (230, 81, 1, 'Eckert, C.: IT-Sicherheit. Konzepte, Verfahren, Protokolle. Oldenbourg, München, aktuellste Auflage', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (231, 81, 1, 'Erickson, J.: Hacking - The Art of Exploitation. No Starch Press', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (232, 81, 1, 'aktuellste Auflage', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (233, 81, 1, 'Aktuelle wissenschaftliche Publikationen', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (234, 82, 1, 'Sommerville, Ian: Software Engineering, Addison- Wesley, 10th Edition, 2015', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (235, 82, 1, 'Fowler, Martin: Patterns of Enterprise Application Architecture, Addison-Wesley, 2002', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (236, 82, 1, 'Rup, Chris u.a. UML 2 glasklar: Praxiswissen für die UML-Modellierung, Hanser, 4. Auflage, 2012', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (237, 82, 1, 'Kirk Knoernschild: Java Application Architecture: Modularity Patterns with Examples Using OSGi, Prentice Hall, 2012', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (238, 83, 1, 'Hefner, Sabine', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (239, 83, 1, 'Dittmar, Michael: Grundlagen des SAP R/3-Finanzwesen, München 2001.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (240, 83, 1, 'Liening, Frank', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (241, 83, 1, 'Scherleitner, Stephan: SAP R/3 – Gemeinkostencontrolling, München 2001.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (242, 83, 1, 'Olfert, Klaus: Kostenrechnung, 13. Auflage, Leipzig 2003.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (243, 83, 1, 'Weber, Jürgen', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (244, 83, 1, 'Weißenberger, E. Barbara: Einführung in das Rechnungswesen, Bilanzierung und Kostenrechnung, 10. Auflage, Stuttgart 2021.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (245, 83, 1, 'Wöhe, Günter: Einführung in die Allgemeine Betriebswirtschaftslehre, 27. Auflage, München 2020.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (246, 84, 1, 'Primärliteratur:', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (247, 84, 1, 'Hassler, M.: Digital und Web Analytics. 5. Aufl. mitp Verlag 2019.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (248, 84, 1, 'Keßler, E./Rabsch, S./Mandic, M.: Erfolgreiche Websites. 4. Aufl. Rheinwerk 2018.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (249, 84, 1, 'Kreutzer, R.T.: Praxisorientiertes Online-Marketing. 3. Aufl. Springer 2018.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (250, 84, 1, 'Kuß, A.: Marketing-Theorie: Eine Einführung. 3. Aufl. Springer 2013.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (251, 84, 1, 'Lammenett, E.: Praxiswissen Online-Marketing. 8. Aufl. Springer 2021.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (252, 84, 1, 'Rieber, D.: Mobile Marketing. Grundlagen, Strategien, Instrumente. Springer 2017.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (253, 84, 1, 'Terstiege, M.: Digitales Marketing. Erfolgsmodelle aus der Praxis. Springer 2021 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 88 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, NULL, NULL, NULL, NULL, true, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (254, 84, 1, 'Vollmert, M./Lück, H.: Google Analytics – Das umfassende Handbuch. 3. Aufl. Rheinwerk 2017.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (255, 84, 1, 'Wenz, C./Hauser, T. (Hrsg.): Websites optimieren – Das Handbuch, Springer Vieweg 2015.', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (256, 84, 1, 'Sens, B.: Suchmaschinenoptimierung. Erste Schritte und Checklisten für bessere Google-Positionen. Springer 2018 Sekundärliteratur:', NULL, NULL, NULL, NULL, NULL, false, 11);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (257, 84, 1, 'Erlhofer, S.: Suchmaschinen-Optimierung: Das SEO- Standardwerk in neuer Auflage. Rheinwerk 2020.', NULL, NULL, NULL, NULL, NULL, false, 12);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (258, 84, 1, 'Grisby, M.: Marketing Analytics: A Practical Guide to Improving Consumer Insights Using Data Techniques. 2. Aufl. Kogan Page 2018.', NULL, NULL, NULL, NULL, NULL, false, 13);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (259, 84, 1, 'Haberich, R.: Future Digital Business: Wie Business Intelligence und Web Analytics Online-Marketing und Conversion verändern. mitp Verlag 2018.', NULL, NULL, NULL, NULL, NULL, false, 14);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (260, 84, 1, 'Heggde, G./Shainesh, G. (Hrsg.): Social Media Marketing. Palgrave Macmillan 2018.', NULL, NULL, NULL, NULL, NULL, false, 15);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (261, 84, 1, 'Olbrich, R./Schultz, C. D./Holsing, C.: Electronic Commerce und Online-Marketing. 2. Aufl. Springer 2020.', NULL, NULL, NULL, NULL, NULL, false, 16);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (262, 85, 1, 'Rahn, H.-J.: Einführung in die Betriebswirtschaftslehre, 11. Auflage, Herne 2013.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (263, 85, 1, 'Volkmann, C.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (264, 85, 1, 'Tokarski, K.-O.: Enterpreneurship, Gründung und Wachstum von jungen Unternehmen, Stuttgart 2006.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (266, 85, 1, 'Döhring, Ulrich: Einführung in die Allgemeine Betriebswirtschaftslehre, 25. Auflage, München 2013.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (267, 86, 1, 'Becker, J., Kugeler, M., Rosemann, M. [Hrsg.]: Prozessmanagement, Ein Leitfaden zur prozessorientierten Gestaltung, 7. Aufl., Berlin, Heidelberg, New York 2012.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (268, 86, 1, 'Rücker, B.: Praxishandbuch BPMN 2.0, 6. Aufl., München 2019.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (269, 86, 1, 'Hanschke, I.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (270, 86, 1, 'Lorenz, R.: Strategisches Prozessmanagement, 2. Aufl., München 2021.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (271, 86, 1, 'Scheer, A.-W.: ARIS-Vom Geschäftsprozess zum Anwendungssystem, 4. Aufl., Berlin, Heidelberg, New York 2002.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (272, 86, 1, 'Scheer, A-W.: Wirtschaftsinformatik, Referenzmodelle für industrielle Geschäftsprozesse, 7. Aufl., Berlin, Heidelberg, New York 1997.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (273, 86, 1, 'Schmelzer, H.-J., Sesselmann, W.: Geschäftsprozessmanagement in der Praxis, 9. Aufl., München 2020.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (274, 87, 1, 'Primärliteratur:', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (275, 87, 1, 'Hansen, H.R./Mendling, J./Neumann, G.: Wirtschaftsinformatik. 12. Aufl., Berlin 2019.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (276, 87, 1, 'Kofler, T.: Das digitale Unternehmen. Heidelberg 2018.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (277, 87, 1, 'Laudon, K.C./Laudon, J.P./Schoder, D.: Wirtschaftsinformatik. Eine Einführung. 3. Aufl., München 2015.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (278, 87, 1, 'Leimeister, J.M: Einführung in die Wirtschaftsinformatik, 13. Aufl., Berlin 2021. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 95 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, NULL, NULL, NULL, NULL, true, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (279, 87, 1, 'Weber, P./Gabriel, R.: Basiswissen Wirtschaftsinformatik, 4. Aufl., Heidelberg 2022. Sekundärliteratur:', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (280, 87, 1, 'Wirtz, B.: Electronic Business. 7. Aufl., Berlin 2020.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (281, 87, 1, 'Kollmann, T.: E-Business. Grundlagen elektronischer Geschäftsprozesse in der Digitalen Wirtschaft. 7. Aufl., Heidelberg 2019.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (282, 88, 1, 'Kappes, Martin: Netzwerk- und Datensicherheit: Eine praktische Einführung. Berlin Heidelberg New York: Springer-Verlag, 2007. -ISBN 978-3-835-19202-7. S. 1-348 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 98 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, NULL, NULL, NULL, NULL, true, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (283, 88, 1, 'Yaworski, Peter: Real-World Bug Hunting: A Field Guide to Web Hacking. München: No Starch Press, 2019. -ISBN 978-1-593-27862-5. S. 1-264', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (284, 88, 1, 'Hoffman, Andrew: Web Application Security: Exploitation and Countermeasures for Modern Web Applications. Sebastopol: O''Reilly Media, 2020. -ISBN 978-1-492-05311-8. S. 1-450', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (285, 88, 1, 'Pohlmann, Norbert: Cyber-Sicherheit: Das Lehrbuch für Konzepte, Prinzipien, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung. Wiesbaden: Springer Fachmedien Wiesbaden, 2019. -ISBN 978-3-658-25397-4. S.1-594', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (286, 88, 1, 'Eckert, Claudia: IT-Sicherheit: Konzepte – Verfahren – Protokolle. Berlin/Boston: De Gruyter Oldenbourg, 2023. -ISBN 978-3-110-99689-0. S. 1-1040', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (287, 89, 1, 'Burghardt, M.: Einführung in Projektmanagement', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (288, 89, 1, 'Hrsg.: Siemens AG, Publicis Corporate Publishing, Erlangen, 2002, ISBN 3-89578-198-3', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (289, 89, 1, 'Hindel, Hörmann, Müller, Schmied: Software- Projektmanagement', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (290, 89, 1, 'dpunkt.verlag GmbH, Heidelberg 2004, ISBN 3-89864-230-5', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (291, 89, 1, 'Litke, H.-D.: Projektmanagement, Carl Hanser Verlag, 1995, ISBN 3- 446-18310-8', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (292, 89, 1, 'Bartsch-Beuerlein, S.: Qualitätsmanagement in IT- Projekten Planung, Organisation, Umsetzung', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (293, 89, 1, 'Carl Hanser 2000', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (294, 90, 1, 'Steven, M.: Produktionslogistik. Stuttgart: W. Kohlhammer Verlag, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (295, 90, 1, 'Schönsleben, P.: Integrales Logistikmanagement', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (296, 90, 1, 'Springer-Verlag, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (297, 90, 1, 'Lasch, R.: Strategisches und operatives Logistikmanagement: Beschaffung. SpringerGabler, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (298, 90, 1, 'Vandeput, N.: Inventory Optimization. Models and Simulations, De Gruyter, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (299, 90, 1, 'Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (300, 90, 1, 'Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (301, 91, 1, 'Themenspezifisch', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (302, 92, 1, 'Kuzbari, Rafic', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (303, 92, 1, 'Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (304, 92, 1, 'Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978-3642134197', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (305, 93, 1, 'Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (306, 93, 1, 'Karmasin, M', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (307, 93, 1, 'Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (308, 93, 1, 'Weitere themenspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (309, 94, 1, 'Projektspezifisch', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (310, 95, 1, 'Themenspezifische Literatur, insbesondere Primärliteratur aus der aktuellen Forschung.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (311, 96, 1, 'DECHANGE, André. 2020. Projektmanagement – Schnell erfasst. Springer Gabler, Zugriff aus dem Hochschulnetz über https://link.springer.com/book/10.1007/978-3-662- 57667-0', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (312, 96, 1, 'BURGHARDT, Manfred, 2018. Projektmanagement : Leitfaden für die Planung, Überwachung und Steuerung von Projekten [online]. Ed.: 10., überarbeitete und erweiterte Auflage. Erlangen : Publicis. ISBN 978-3- 89578-472-9. Zugriff aus dem Hochschulnetz über https://w- hs.digibib.net/search/eds/record/nlebk:1726722/eds- fulltext', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (313, 96, 1, 'KAMMERER, Sebastian, Werner ACHTERT, Michael LANG, Michael AMBERG, Martin T. ADAM, Torsten BECKER, Roland BÖTTCHER und Jürgen BOPPER, 2012. IT-Projektmanagement-Methoden Best Practices von Scrum bis PRINCE2. Düsseldorf: Symposion, 2012. 1. Aufl. Erfolgreiches IT- Projektmanagement. ISBN 978-3-86329-435-9', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (314, 96, 1, 'LAYTON, Mark C., 2015. Scrum For Dummies. Hoboken, NJ: For Dummies. ISBN 978-1-118- 90583-8 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 16 - Informatik (Master) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (315, 96, 1, 'LEOPOLD, Klaus und Siegfried KALTENECKER, 2018. Kanban in der IT eine Kultur der kontinuierlichen Verbesserung schaffen. München: Hanser. ISBN 978- 3-446-45360-9', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (316, 97, 1, 'Projektspezifisch', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (317, 98, 1, 'A. Geron: „Hands-On Machine Learning with Scikit- Learn & TensorFlow“ O’Reilly, 978-1492032649', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (318, 98, 1, 'F. Chollet, „Deep Learning with Python“, Nanning, ISBN 978-1617294433', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (319, 98, 1, 'M. Lapan: „Deep Reinforcement Learning Hands-On“, Expert Insight, ISBN 978-1788834247', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (320, 99, 1, 'B. Cyganek, J.P. Siebert: „An Introduction to 3DComputer Vision Techniques and Algorithms“, Wiley,ISBN: 978-0-470-01704-3', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (321, 99, 1, 'J. Steinmüller: „Bildanalyse“, Springer Verlag, ISBN978-3-540-79743-2.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (322, 99, 1, 'A. Nischwitz, P. Haberäcker: „Computergrafik und Bildverarbeitung, Band II Bildverarbeitung“, TeubnerVerlag, ISBN 978-3-834-81712-9.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (323, 99, 1, 'A Kaehler, G. Bradski: „Computer Vision in C++ withthe OpenCV Library“, O''Reilly, ISBN 978-1-449- 31465-1', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (324, 99, 1, 'Aktuelle Literatur: https://paperswithcode.com/', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (325, 100, 1, 'Leskovec, Rajaraman, Ullman. Mining of Massive Datasets Foundations of Databases, Serge Abiteboul, Rick Hull, Victor Vianu, 1995.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (326, 101, 1, 'G. James, D. Witten, T. Hastie, R. Tibshirani: An Introduction to Statistical Learning with Applications in R, Springer (2021)', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (327, 101, 1, 'J.M. Philipps: Mathematical Foundations for Data Analysis, Springer (2021)', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (328, 101, 1, 'M. Plaue: Data Science: Grundlagen, Statistik und maschinelles Lernen, Springer (2021)', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (329, 101, 1, 'Weitere Literatur wird in der Veranstaltung bekannt gegeben.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (330, 102, 1, 'Grundlegende und aktuelle Literatur, angepasst an das (Wettbewerbs-)Thema (in der Regel mit intensivem Bezug zu maschinellem Lernen)', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (331, 103, 1, 'Hannemann, D.: "Physik Smart-Book", ISBN 978-3- 920088-52-5', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (332, 103, 1, 'Bostrom Nick, 2014: "Superintelligenz" Surkamp, eISBN 978-3-518-73900-6', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (333, 103, 1, 'Kurzweil, Ray, 2014: "Menschheit 2.0" Die Singularität naht, ISBN 978-3-944203-08-9', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (334, 103, 1, 'Human Brain Project, 2022: https://www.humanbrainproject.eu/', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (335, 103, 1, 'Homeister, Matthias, 2018: "Quantum Computing verstehen", ISBN 978-3-658-10455-9', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (336, 103, 1, 'Hinze, Th., M. Sturm, 2004: "Rechnen mit DNA" ISBN 3-486-27530-5', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (337, 103, 1, 'Sackmann, E. & Merkel, R. 2010: "Lehrbuch der Biophysik"', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (338, 103, 1, 'Thompson, R.F., 2001: "Das Gehirn", ISBN: 978-3- 662-53349-9', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (339, 103, 1, 'Diverse Forschungsberichte zu folgenden Themen: o Neuromorphes Computing o Quanten-Computer, -Internet, -Information o Photonische Chips', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (340, 104, 1, 'Richard Bird: Introduction to Functional Programming using Haskell. Prentice Hall, 2002.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (341, 104, 1, 'Richard Bird: Thinking Functionally with Haskell. Cambridge University Press, 2014.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (342, 105, 1, 'Russell, Norvig: Artificial Intelligence, A Modern Approach, Pearson, in aktueller Auflage (4. derzeit)', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (343, 105, 1, 'Ausgewählte grundlegende und aktuelle Forschungspapiere und Vorträge.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (344, 106, 1, 'William F. Clocksin, Christopher S. Mellish: Programming in Prolog. Using the ISO Standard. 5th Ed., Springer, 2003, 299 Seiten, ISBN 978- 3540006787', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (345, 106, 1, 'Ivan Bratko: Prolog Programming for Artificial Intelligence (4th Ed.). Addison-Wesley, 2011, 696 Seiten, ISBN: 978-0321417466', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (346, 106, 1, 'Ulf Nilson, Jan Maluszynski: Logic, Programming, and Prolog (2nd Ed.). John Wiley, 1995, 294 Seiten, vom Verlag nicht mehr erhältlich, dafür online unter http://www.ida.liu.se/~ulfni/lpp (last updated: 2012- 05-07)', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (347, 106, 1, 'Patrick Blackburn, Johan Bos, Kristina Striegnitz, Learn Prolog Now! College Publications, 2006, 284 Seiten, ISBN 978-1904987178 oder freie Online- Version http://www.learnprolognow.org.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (348, 107, 1, 'M.Wooldridge, An Introduction to MultiAgent Systems Second Edition. John Wiley & Sons, 2009.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (349, 107, 1, 'Y. Shoham and K. Leyton-Brown. Multiagent Systems: Algorithmic, Gamer-Theoretic, and Logical Foundations. Cambridge UP, 2008. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 41 - Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik', NULL, NULL, NULL, NULL, NULL, true, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (350, 107, 1, 'G. Weiss, editor. Multi-Agent Systems. The MIT Press, 1999.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (351, 107, 1, 'M. Singh and M. Huhns. Readings in Agents. Morgan-Kaufmann Publishers, 1997.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (352, 107, 1, 'OSGi release 6', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (353, 107, 1, 'Neil Bartlett: OSGi in Practice, 2009, online free available', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (354, 108, 1, 'Jens Riwotzki, Cloud-Computing Theorie und Praxis, HERDT-Verlag', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (355, 108, 1, 'Benjamin Kettner, Frank Geisler, Pro Serverless Data Handling with Microsoft Azure, Berkeley, CA: Apress, Imprint: Apress, 2022 (Online-Ressource)', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (356, 108, 1, 'Ulrich Trick, Einführung in die Mobilfunknetze der 5. Generation, Walter de Gruyter GmbH', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (357, 108, 1, 'Gerd Siegmund, SDN - Software-defined Networking: neue Anforderungen und Netzarchitekturen für performante Netze, VDE Verlag (Online-Ressource)', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (358, 108, 1, 'Liyanage, Software Defined Mobile Networks (SDMN) - Beyond LTE Network Architecture John Wiley & Sons (Online-Ressource)', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (359, 108, 1, 'Aktuelle Ergänzungen im Moodle-Kurs zu diesem Modul', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (360, 109, 1, 'I. Goodfellow, Y. Bengio, A. Courville: Deep Learning. MIT Press, 2016 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 45 - Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik', NULL, NULL, NULL, NULL, NULL, true, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (361, 109, 1, 'M. A. Nielsen, Neural Networks and Deep Learning. Determination Press, 2015', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (362, 109, 1, 'R. Kruse et al: Computational Intelligence: Eine methodische Einführung in Künstliche Neuronale Netze, Evolutionäre Algorithmen, Fuzzy-Systeme und Bayes-Netze (Springer 2015)', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (363, 110, 1, 'Leskovec, Rajaraman, Ullman. Mining of Massive Datasets', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (365, 111, 1, 'A. Geron: „Hands-On Machine Learning with Scikit- Learn & TensorFlow“ O’Reilly, 978-1492032649', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (366, 111, 1, 'F. Chollet, „Deep Learning with Python“, Nanning, ISBN 978-1617294433', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (367, 111, 1, 'M. Lapan: „Deep Reinforcement Learning Hands-On“, Expert Insight, ISBN 978-1788834247', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (368, 111, 1, 'Aktuelle Literatur: https://paperswithcode.com/', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (369, 112, 1, 'Sommerville, Ian: Software Engineering, Addison- Wesley, 10th Edition, 2015', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (370, 112, 1, 'SPRING Framework 3.0: http://static.springsource.org/ spring/ docs/ 3.0.x/ spring-framework-reference/html/ (from 01.09.2009)', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (371, 112, 1, 'Clements / Northrup: Software Product Lines: Practices and Patterns, 6th ed., Addison-Wesley, 2007', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (372, 112, 1, 'Bass / Clements / Kazman: Software Architecture in Practice, Addison-Wesley', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (373, 112, 1, '3rd ed., 2012', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (374, 112, 1, 'Douglass, Bruce: Real time UML, Addison-Wesley, 3rd ed., 2004', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (375, 112, 1, 'Gelernter, David: The second coming - a manifesto, http://www.edge.org/3rd_culture/gelernter/gelernter_i ndex.html (article from 2009, read June 2012)', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (376, 112, 1, 'McAfee, Andrew: Enterprise 2.0: new collaborative tools for your organization''s toughest challenges, Harvard Business School Press', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (377, 112, 1, '1st edition (November 16, 2009)', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (378, 113, 1, 'Wird in der Vorlesung bekannt gegeben', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (379, 114, 1, 'Dunne, Anthony und Raby, Fiona: Speculative Everything: Design, Fiction, and Social Dreaming, 2013', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (380, 114, 1, 'Literatur je nach Themenschwerpunkt in Online- Literaturliste in Moodle', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (381, 115, 1, 'Andreas Dewald, Felix C. Freiling: Forensische Informatik. Books on demand, 2. Auflage 2015', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (382, 115, 1, 'Alexander Geschonneck: Computer Forensik, dpunkt Verlag, 2. Auflage, 2006', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (383, 115, 1, 'Diverse aktuelle Konferenz-Publikationen', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (384, 116, 1, 'Nach Bekanntgabe in der Veranstaltung Themen werden an Hand von aktueller Primärliteratur behandelt.', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (385, 117, 1, 'Kern, Ulrich u. Petra: Designplanung - Prozesse und Projekte des wissenschaftlich-gestalterischen Arbeitens, 2009', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (386, 117, 1, 'Hensel, Daniela: Understanding Branding: Strategie- und Designprozesse verstehen und anwenden, 2015', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (387, 117, 1, 'Niesen, Katrin: Designprojekte gestalten: ... damit Kreativität gewinnt und sich auszahlt, 2021', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (388, 117, 1, 'Baars, Jan-Erik: Leading Design: How to build a successful business by design! Taschenbuch, 2020', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (389, 117, 1, 'Weitere Literatur in Online-Literaturliste in Moodle', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (390, 118, 1, 'Aktuelle wissenschaftliche Veröffentlichungen zu dem jeweiligen Thema der Vorlesung (wird zu Veranstaltungsbeginn bekannt gegeben).', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (391, 119, 1, 'Kapp, K.M.: The Gamification of Learning and Instruction. Verlag John Wiley & Sons Inc 2012.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (392, 119, 1, 'Mesch, R.: The Gamification of Learning and Instruction Fieldbook. Verlag John Wiley & Sons Inc 2014.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (393, 119, 1, 'Anna Faust: The Effects of Gamification on Motivation and Performance. Springer Gabler, 2021.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (394, 119, 1, 'Susanne Strahringer, Christian Leyh (Hrsg.): Gamification und Serious Games. Springer 2017.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (395, 119, 1, 'Stefan Stieglitz et. al. (eds): Gamicication – Using Game Elements in Serious Contexts. Springer 2017.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (396, 119, 1, 'Johan Huizinga. Homo ludens: Vom Ursprung der Kultur im Spiel. Rowohlt Taschenbuch Verlag, 1987.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (397, 119, 1, 'Jeweils aktualisierte Forschungsartikel', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (398, 120, 1, 'Koch, M.: Computer-Supported Cooperative Work. Reihe: Interaktive Medien (Hrsg.: M. Herczeg), Oldenbourg Verlag, 2007, ISBN: 978- 3-486-58000-6', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (399, 120, 1, 'Scott, S.: Territoriality in Collaborative Tabletop Workspaces. PhD Thesis, University of Calgary, Calgary, Alberta, Canada, March, 2005.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (400, 120, 1, 'Tang, A. et al.: Collaborative coupling over tabletop displays. Proceedings of the SIGCHI conference on Human Factors in computing systems (Montreal, Quebec, Canada: ACM), 1181-90.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (401, 120, 1, 'Greenberg, S.: The Mechanics of Collaboration: Developing Low Cost Usability Evaluation Methods for Shared Workspaces. WETICE ''00 Proceedings of the 9th IEEE International Workshops on Enabling Technologies: Infrastructure for Collaborative Enterprises, IEEE, 2000.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (402, 121, 1, 'N. Pohlmann: „Cyber-Sicherheit - Das Lehrbuch für Konzepte, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung“ 2. Auflage, Springer Vieweg Verlag, Wiesbaden 2022', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (403, 121, 1, 'Pohlmann, N.: Firewall-Systeme - Sicherheit für Internet und Intranet, E- Mail-Security, Virtual Private Network, Intrution Detection-System, Personal Firewalls. 5. aktualisierte und erweiterte Auflage', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (404, 121, 1, 'ISBN 3- 8266-0988-3', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (405, 121, 1, 'MITP-Verlag, Bonn 2003', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (406, 121, 1, 'A Campo, M.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (407, 121, 1, 'Pohlmann, N.: Virtual Private Network (VPN). 2. aktualisierte und erweiterte Auflage, ISBN 3-8266-0882-8', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (409, 121, 1, 'D. Petersen, N. Pohlmann: „An ideal Internet Early Warning System“. In “Advances in IT Early Warning”, Fraunhofer Verlag, München 2013', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (410, 122, 1, 'N. Pohlmann: „Cyber-Sicherheit - Das Lehrbuch für Konzepte, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung“ 2. Auflage, Springer Vieweg Verlag, Wiesbaden 2022', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (411, 122, 1, 'H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 76 - Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik) Auflage, ISBN-10: 3-8266-1635-9', NULL, NULL, NULL, NULL, NULL, true, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (412, 122, 1, '523 Seiten, MITP- Verlag, Bonn 2006', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (413, 122, 1, 'Pohlmann, N.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (414, 122, 1, 'Reimer, H.: "Trusted Computing - Ein Weg zu neuen IT- Sicherheitsarchitekturen”, ISBN 978-3-8348-0309-2, Vieweg-Verlag, Wiesbaden 2008', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (470, 133, 1, 'Diverse aktuelle Konferenz-Publikationen', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (415, 122, 1, 'M. Jungbauer, N. Pohlmann: „Integrity Check of Remote Computer Systems - Trusted Network Connect". In Proceedings of the ISSE/SECURE 2007 - Securing Electronic Business Processes - Highlights of the Information Security Solutions Europe/Secure 2007 Conference, Eds.: N. Pohlmann, H. Reimer, W. Schneider', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (416, 122, 1, 'Vieweg Verlag, Wiesbaden 2007', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (417, 123, 1, 'Abhängig von der gewählten Entwicklungssprache und Umgebung. Für JavaFX beispielsweise:', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (418, 123, 1, 'Epple A.: JavaFX 8: Grundlagen und fortgeschrittene Techniken. dpunkt.verlag, Heidelberg 2015.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (419, 123, 1, 'Sharan K.: Learn JavaFX 8 - Building User Experience and Interfaces with Java 8. Apress, New York 2015.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (420, 123, 1, 'Esseling B.: A Practical Guide to Localization. John Benjamins Publishing Company, Amsterdam 2000.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (421, 123, 1, 'Cunningham K.: Accessibility Handbook. O’Reilly, Sebastopol 2012.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (422, 124, 1, 'Timo Steffens: Auf der Spur der Hacker - Wie man die Täter hinter der Computer-Spionage enttarnt', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (423, 124, 1, 'Michael Sikorski and Andrew Honig: Practical Malware Analysis', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (424, 124, 1, 'Russinovich, M./Solomon, D./Ionescu, A.: Windows Internals, Part 1 & 2', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (425, 124, 1, 'Microsoft Press, 6. Edition', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (426, 124, 1, 'Diverse aktuelle Konferenz-Publikationen', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (427, 125, 1, 'Wigdor D. and Wixon D.: Brave NUI World - Designing Natural User Interfaces for Touch and Gesture. Morgan Kaufmann, Burlington 2011.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (428, 125, 1, 'Kean S. e.a.: Meet the Kinect - An Introduction to Programming Natural User Interfaces. Apress, New York 2011.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (429, 125, 1, 'Lee, G.G. e.a.: Natural Language Dialog Systems and Intelligent Assistants. Springer, New York 2015.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (430, 126, 1, 'Adams, Carlisle. Introduction to Privacy Enhancing Technologies. 1st ed. Cham, Switzerland: Springer Nature, 2021. https://doi.org/10.1007/978-3-030- 81043-6.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (431, 126, 1, 'Jarmul, Katharine. Practical Data Privacy. O’Reilly Media, 2023.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (432, 126, 1, 'Dennedy, Michelle, Jonathan Fox, and Tom Finneran. The Privacy Engineer’s Manifesto. PDF. 1st ed. Berlin, Germany: APress, 2014. https://doi.org/10.1007/978-1-4302-6356-2.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (433, 126, 1, 'Aktuelle wissenschaftliche Veröffentlichungen', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (434, 127, 1, 'The Rust Programming Language, Steve Klabnik and Carol Nichols, August 2019, https://doc.rust- lang.org/book/', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (435, 127, 1, 'Software Security: Principles, Policies, and Protection (SS3P), Mathias Payer, v0.37, https://nebelwelt.net/SS3P/softsec.pdf', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (436, 127, 1, 'Diverse aktuelle Konferenz-Publikationen', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (437, 128, 1, 'Eilam, E.: Reversing: Secrets of Reverse Engineering', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (438, 128, 1, 'John Wiley & Sons, 1. Auflage', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (439, 128, 1, 'Dang, B./Gazet, A.: Practical Reverse Engineering: x86, x64, ARM, Windows Kernel, Reversing Tools, and Obfuscation', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (441, 128, 1, 'Russinovich, M./Solomon, D./Ionescu, A.: Windows Internals, Part 1 & 2', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (442, 128, 1, 'Microsoft Press, 6. Edition', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (443, 128, 1, 'Diverse aktuelle Konferenz-Publikationen', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (444, 129, 1, 'Primärliteratur:', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (445, 129, 1, 'Cleve, J./Lämmel, U.: Data Mining. 3. Aufl., Berlin 2020.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (446, 129, 1, 'Bengfort, B/Bilbro, R./Ojeda, T.: Applied Text Analysis with Python: Enabling Language Aware Data Products with Machine Learning. Newark 2018', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (447, 129, 1, 'Kollmann, T.: Digital Marketing. Grundlagen der Absatzpolitik in der Digitalen Wirtschaft. 3. Aufl., Stuttgart 2020.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (448, 129, 1, 'Kreutzer, R.T.: Praxisorientiertes Online-Marketing. 4. Aufl., Wiesbaden 2021.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (449, 129, 1, 'Lammenett, E.: Praxiswissen Online-Marketing. Affiliate- und E-Mail-Marketing, Suchmaschinenmarketing, Online-Werbung, Social Media, Online-PR. 8. Aufl., Wiesbaden 2021.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (450, 129, 1, 'Neckel, P./Knobloch, B.: Customer Relationship Analytics. Praktische Anwendung des Data Mining im CRM. 2. Aufl., Heidelberg 2015. Sekundärliteratur: Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 95 - Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)', NULL, NULL, NULL, NULL, NULL, true, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (451, 129, 1, 'Backhaus, K./Erichson, B./Gensler, S./Weiber, R./Weiber, T.: Multivariate Analysemethoden. Ein anwendungsorientierte Einführung. 16. Aufl., Berlin 2021.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (452, 129, 1, 'Kaufmann, U./Tan, A.: Data Analytics for Organisational Development: Unleashing the Potential of Your Data. Newark 2021.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (453, 129, 1, 'Russel, M./Klassen, M.: Mining the social web: Data Mining Facebook, Twitter, LinkedIn, Google+, Github, and more. Newark 2019.', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (454, 130, 1, 'Sherman, W.R.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (455, 130, 1, 'Craig, A.B.: Understanding Virtual Reality: Interface, Application, and Design. Morgan Kaufman Publishers, 2018.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (456, 130, 1, 'Jung, B. (Hrsg.): Virtual und Augmented Reality (VR / AR): Grundlagen und Methoden der Virtuellen und Augmentierten Realität. Verlag: Springer Vieweg 2019.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (457, 130, 1, 'Akenine-Möller, T.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (458, 130, 1, 'Hoffman, N.: Real- Time Rendering. Verlag Taylor & Francis Ltd. 2018 (4th edition).', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (459, 131, 1, 'Mertens, P. et al.: Grundzüge der Wirtschaftsinformatik, aktuelle Auflage', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (460, 131, 1, 'Alicke, K.: Supply Chain Management. Springer, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (461, 131, 1, 'Sucky, E.: Supply Chain Management, Kohlhammer, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (462, 131, 1, 'Vandeput, N.: Inventory optimization. Models and simulations, de Gruyter, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (463, 131, 1, 'Biedermann, L.: Supply Chain Resilienz. Konzeptioneller Bezugsrahmen und Identifikation zukünftiger Erfolgsfaktoren, Springer, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (464, 131, 1, 'Schönsleben, P.: Integrales Logistikmanagement', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (465, 131, 1, 'Springer-Verlag, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (466, 131, 1, 'Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (467, 131, 1, 'Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (468, 132, 1, 'Abhängig von den jeweiligen aktuellen Trendthemen', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (481, 122, 1, 'H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 11 - Internet-Sicherheit (Master) – PO2023 Modulkatalog Auflage, ISBN-10: 3-8266-1635-9', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (487, 134, 1, 'Kuzbari, R.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (488, 134, 1, 'Ammer, R.: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006. ISBN-10 3-211-23525-6', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (489, 134, 1, 'Leopold-Wildburger, U.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (490, 134, 1, 'Schütze, J.: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. Springer-Verlag Berlin Heidelberg New York, 2002. ISBN 3-540-43027-X', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (491, 135, 1, 'Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart 2009 (15. Auflage). ISBN-10: 3825207242', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (492, 135, 1, 'Bliefert, C.: Bachelor-. Master- und Doktorarbeit – Anleitungen für den naturwissenschaftlichtechnischen Nachwuchs. Verlag Wiley 2009 (4. Auflage). ISBN-10: 3527324771', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (493, 135, 1, 'Gockel, T.: Form der wissenschaftlichen Ausarbeitung. Springer-Verlag Berlin 2008. ISBN-10: 3540786139', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (494, 135, 1, 'Themenspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (500, 136, 1, 'Projektspezifisch, wird zu Veranstaltungsbeginn bekannt gegeben', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (501, 137, 1, 'Projektspezifisch, wird zu Veranstaltungsbeginn bekannt gegeben', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (502, 138, 1, 'Projektspezifisch, wird zu Veranstaltungsbeginn bekannt gegeben', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (546, 139, 1, 'Aktuelle Forschungsliteratur', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (547, 139, 1, 'Uwe Gruenefeld, Jonas Auda, Florian Mathis, Stefan Schneegass, Mohamed Khamis, Jan Gugenheimer, and Sven Mayer. 2022. VRception: Rapid Prototyping of Cross-Reality Systems in Virtual Reality. In Proceedings of the 2022 CHI Conference on Human Factors in Computing Systems (CHI ''22). Association for Computing Machinery, New York, NY, USA, Article 611, 1–15. https://doi.org/10.1145/3491102.3501821', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (548, 139, 1, 'Proceedings Cross-Reality Interaction Workshop http://ceur-ws.org/Vol-2779/', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (549, 139, 1, 'https://x-pro.fh-ooe.at/', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (550, 139, 1, 'https://crossreality.hcigroup.de/', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (551, 140, 1, 'https://www.interaction-design.org/literature/book/the- encyclopedia-of-human-computer-interaction-2nd- ed/3d-user-interfaces', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (552, 140, 1, 'LaViola Jr, J. J., Kruijff, E., McMahan, R. P., Bowman, D., & Poupyrev, I. P. (2017). 3D User Interfaces: Theory and Practice . Addison-WesleyProfessional.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (559, 141, 1, 'Kuzbari, Rafic', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (560, 141, 1, 'Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (561, 141, 1, 'Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978-3642134197', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (562, 142, 1, 'Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400 Karmasin, M', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (563, 142, 1, 'Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596 weitere themenspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (564, 143, 1, 'projekt-spezifisch', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (565, 144, 1, 'Themenspezifische Literatur aus den Forschungsbereichen', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (605, 120, 1, 'Koch, M.: Computer-Supported Cooperative Work. Reihe: Interaktive Medien (Hrsg.: M. Herczeg), Oldenbourg Verlag, 2007, ISBN: 978-3-486-58000-6', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (620, 122, 1, 'H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 55 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog Auflage, ISBN-10: 3-8266-1635-9', NULL, NULL, NULL, NULL, NULL, true, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (636, 107, 1, 'Y. Shoham and K. Leyton-Brown. Multiagent Systems: Algorithmic, Gamer-Theoretic, and Logical Foundations. Cambridge UP, 2008. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 62 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog', NULL, NULL, NULL, NULL, NULL, true, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (646, 109, 1, 'I. Goodfellow, Y. Bengio, A. Courville: Deep Learning. MIT Press, 2016 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog', NULL, NULL, NULL, NULL, NULL, true, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (657, 96, 1, 'LAYTON, Mark C., 2015. Scrum For Dummies. Hoboken, NJ: For Dummies. ISBN 978-1-118- 90583-8 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 73 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog', NULL, NULL, NULL, NULL, NULL, true, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (668, 145, 1, 'Abhängig von der Forschungsthematik', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (673, 146, 1, 'Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (674, 146, 1, 'Weitere themenspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (675, 147, 1, 'ISBN 978-3-662-61411-2 Betriebssysteme kompakt von Christian Baun (Online-Ressource), Springer Vieweg', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (676, 147, 1, 'ISBN 978-3-662-59897-9 Computernetze kompakt Christian Baun (abgestimmte Online-Ressource), Springer Vieweg', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (677, 147, 1, 'Tanenbaum/Bos Moderne Betriebssysteme, Pearson Studium, aktuellste Auflage', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (678, 147, 1, 'Tanenbaum, Wetherall Computernetzwerke, Pearson Stark, aktuellste Auflage', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (679, 147, 1, 'Aktuelle Ergänzungen im Moodle-Kurs zu diesem Modul', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (699, 84, 1, 'Terstiege, M.: Digitales Marketing. Erfolgsmodelle aus der Praxis. Springer 2021 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 15 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (723, 148, 1, 'Mertens, P. et al.: Grundzüge der Wirtschaftsinformatik, aktuelle Auflage', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (724, 148, 1, 'Scheer, A.-W.: Wirtschaftsinformatik, Springer- Verlag, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (725, 148, 1, 'Alicke, K.: Planung und Betrieb von Logistiknetzwerken. Unternehmensübergreifendes Supply Chain Management. Springer, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (726, 148, 1, 'Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (727, 148, 1, 'Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (728, 148, 1, 'Schönsleben, P.: Integrales Logistikmanagement', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (729, 148, 1, 'Springer-Verlag, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (730, 148, 1, 'Meier, L.: Koordination Interdependenter Planungssysteme in der Logistik, Gabler, 2009.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (735, 87, 1, 'Leimeister, J.M: Einführung in die Wirtschaftsinformatik, 13. Aufl., Berlin 2021. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 26 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (740, 149, 1, 'Kuzbari, Rafic', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (741, 149, 1, 'Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (742, 149, 1, 'Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978- 3642134197', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (770, 150, 1, 'Mertens, P. et al.: Grundzüge der Wirtschaftsinformatik, aktuelle Auflage', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (771, 150, 1, 'Alicke, K.: Planung und Betrieb von Logistiknetzwerken. Unternehmensübergreifendes Supply Chain Management. Springer, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (772, 150, 1, 'Sucky, E.: Supply Chain Management, Kohlhammer, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (773, 150, 1, 'Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (774, 150, 1, 'Vandeput, N.: Inventory Optimization. Models and Simulations, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (775, 150, 1, 'Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (776, 150, 1, 'Schönsleben, P.: Integrales Logistikmanagement', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (777, 150, 1, 'Springer-Verlag, aktuelle Auflage.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (778, 150, 1, 'Meier, L.: Koordination Interdependenter Planungssysteme in der Logistik, Gabler, 2009. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 47 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog Weitere jeweils aktuelle Quellen auch zur Fallstudie werden zu Beginn der Veranstaltung bekannt gegeben.', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (786, 151, 1, 'Theisen, Manuel René, Wissenschaftliches Arbeiten: Erfolgreich bei Bachelor- und Masterarbeit, 17. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 52 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog aktualis. und bearb. Aufl., 2017, Verlag Franz Vahlen GmbH, 320 Seiten, ISBN: 978-3-8006-5382-9', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (787, 151, 1, 'Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (788, 151, 1, 'Helmut Balzert, Lehrbuch der Software-Technik – Software- Management, Software- Qualitätssicherung, Unternehmensmodellierung, Band 2, 2. Auflage, Spektrum Akademischer Verlag, 2008.', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (789, 151, 1, 'Projektspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (790, 151, 1, 'Literatur zu Projekt- und Teamarbeit', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (794, 152, 1, 'Wird in der ersten Veranstaltung bekannt gegeben', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (813, 70, 1, 'Kreutzer, M.: "Telematik- und Kommunikationssysteme in der vernetzten Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 - Wirtschaftsinformatik (Bachelor) – PO2023 Wahlpflichtkatalog Wirtschaft"', NULL, NULL, NULL, NULL, NULL, true, 14);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (847, 88, 1, 'Kappes, Martin: Netzwerk- und Datensicherheit: Eine praktische Einführung. Berlin Heidelberg New York: Springer-Verlag, 2007. -ISBN 978-3-835-19202-7. S. 1-348 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 81 - Wirtschaftsinformatik (Bachelor) – PO2023 Wahlpflichtkatalog', NULL, NULL, NULL, NULL, NULL, true, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (860, 153, 1, 'Bauer, Andreas', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (861, 153, 1, 'Günzel, Holger (Hrsg.): Data Warehouse Systeme – Architektur, Entwicklung, Anwendung, 4. Auflage, 2013.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (862, 153, 1, 'Gluchowski, Peter', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (863, 153, 1, 'Gabriel, Roland', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (864, 153, 1, 'Dittmar, Carsten: Management Support Systeme und Business Intelligence – Computergestützte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 5 - Wirtschaftsinformatik (Master) – PO2023 Modulkatalog Informationssysteme für Fach- und Führungskräfte, 2. Auflage, Berlin 2008.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (865, 153, 1, 'Gómez, Jorge Marx', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (866, 153, 1, 'Rautenstrauch, Claus', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (867, 153, 1, 'Cissek, Peter: Einführung in Business Intelligence mit SAP Netweaver 7.0, Berlin 2008.', NULL, NULL, NULL, NULL, NULL, false, 9);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (868, 153, 1, 'Hahne, Michael: SAP Business Warehouse – Mehrdimensionale Datenmodellierung, Berlin 2005.', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (869, 153, 1, 'Kimball, Ralph', NULL, NULL, NULL, NULL, NULL, false, 11);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (870, 153, 1, 'u. a.: The Data Warehouse Lifecycle Toolkit, Expert Methods for Designing, Developing, and Deploying Data Warehouses, New York 1998.', NULL, NULL, NULL, NULL, NULL, false, 12);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (871, 153, 1, 'Lehner, Wolfgang: Datenbanktechnologien für Data- Warehouse-Systeme: Konzepte und Methoden, Heidelberg 2003.', NULL, NULL, NULL, NULL, NULL, false, 13);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (872, 153, 1, 'Lusti, Markus: Data Warehousing und Data Mining – Eine Einführung in entscheidungsunterstützende Systeme, Berlin 2002.', NULL, NULL, NULL, NULL, NULL, false, 14);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (873, 153, 1, 'u. a.: Big Data, Related Technologies, Challenges and Future Prospects, Heidelberg 2014.', NULL, NULL, NULL, NULL, NULL, false, 16);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (874, 153, 1, 'Plattner, H., Zeier, A.: In-Memory Data Management, Ein Wendepunkt für Unternehmensanwendungen, Heidelberg 2012.', NULL, NULL, NULL, NULL, NULL, false, 17);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (875, 153, 1, 'Wolf, F. K.', NULL, NULL, NULL, NULL, NULL, false, 18);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (876, 153, 1, 'Yamad, S.: Datenmodellierung in SAP Netweaver BW, Bonn 2010.', NULL, NULL, NULL, NULL, NULL, false, 19);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (877, 153, 1, 'Ausgesuchte Literatur zum Stand der Entwicklung.', NULL, NULL, NULL, NULL, NULL, false, 20);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (890, 154, 1, 'Kuzbari, Rafic', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (891, 154, 1, 'Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (892, 154, 1, 'Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978-3642134197', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (893, 155, 1, 'Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (894, 155, 1, 'Projektspezifisch', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (897, 156, 1, 'Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (898, 156, 1, 'weitere themenspezifische Literatur', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (899, 157, 1, 'Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (900, 157, 1, 'Themenspezifische Primärliteratur aus der aktuellen Forschung', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (909, 129, 1, 'Neckel, P./Knobloch, B.: Customer Relationship Analytics. Praktische Anwendung des Data Mining im CRM. 2. Aufl., Heidelberg 2015. Sekundärliteratur: Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 25 - Wirtschaftsinformatik (Master) – PO2023 Modulkatalog', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (935, 122, 1, 'H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 38 - Wirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Informatik Auflage, ISBN-10: 3-8266-1635-9', NULL, NULL, NULL, NULL, NULL, true, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (961, 158, 1, 'Basisliteratur für a) Management und Unternehmensfühung:', NULL, NULL, NULL, NULL, NULL, false, 1);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (962, 158, 1, 'Eckert, W., & Ellenrieder, P. (2013). Marktforschung: methodische Grundlagen und praktische Anwendung. Springer-Verlag.', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (963, 158, 1, 'Komlos, J. & Süssmuth, B. (2010). Empirische Ökonomie. Berlin: Springer.', NULL, NULL, NULL, NULL, NULL, false, 3);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (964, 158, 1, 'Domschke, W.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (965, 158, 1, 'Klein, R., Scholl, A. (2015). Einführung in Operations Research. Berlin: Springer.', NULL, NULL, NULL, NULL, NULL, false, 6);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (966, 158, 1, 'Malik, F. (2013). Management: Das A und O des Handwerks (Management: Komplexität meistern. Frankfurt & New York: Campus.', NULL, NULL, NULL, NULL, NULL, false, 7);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (967, 158, 1, 'Malik, F. (2014). Führen Leisten Leben: Wirksames Management für eine neue Welt. Campus Verlag.', NULL, NULL, NULL, NULL, NULL, false, 8);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (968, 158, 1, 'Stair, R.M. & Hanna, M.E. (2012). Quantitative Analysis for Management. Pearson Prentice Hall.', NULL, NULL, NULL, NULL, NULL, false, 10);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (969, 158, 1, 'Thommen, J.-P.', NULL, NULL, NULL, NULL, NULL, false, 11);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (970, 158, 1, 'Achleitner, A.-K.', NULL, NULL, NULL, NULL, NULL, false, 12);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (971, 158, 1, 'Gilbert, D.U.', NULL, NULL, NULL, NULL, NULL, false, 13);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (972, 158, 1, 'Hachmeister, D.', NULL, NULL, NULL, NULL, NULL, false, 14);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (973, 158, 1, 'Kaiser, G. (2017). Allgemeine Betriebswirtschaftslehre. Umfassende Einführung aus managementorientierter Sicht. Wiesbaden: Springer Gabler. b) Content-Marketing', NULL, NULL, NULL, NULL, NULL, false, 15);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (974, 158, 1, 'Baetzgen, Andreas & Tropp, Jörg (Hg.)(2013). Brand Content. Die Marke als Medienereignis. Stuttgart: Schaeffer-Poeschl.', NULL, NULL, NULL, NULL, NULL, false, 16);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (975, 158, 1, 'Herbst, Dieter Georg (2014). Storytelling (3. Aufl.). Konstanz: UVK52 8 Modul „“', NULL, NULL, NULL, NULL, NULL, false, 17);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (976, 158, 1, 'Hohlfeld, Ralf', NULL, NULL, NULL, NULL, NULL, false, 18);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (977, 158, 1, 'Müller, Philipp', NULL, NULL, NULL, NULL, NULL, false, 19);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (978, 158, 1, 'Richter, Annekathrin & Zacher, Franziska (Hg.)(2013). Crossmedia – Wer bleibt auf der Strecke? Beiträge aus Wissenschaft und Praxis (2. Aufl.). Münster: Lit.', NULL, NULL, NULL, NULL, NULL, false, 20);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (979, 158, 1, 'Jakubetz, Christian (2011). Crossmedia (2. Aufl.). Konstanz: UVK.', NULL, NULL, NULL, NULL, NULL, false, 21);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (980, 158, 1, 'Lieb, Rebecca (2011). Content Marketing: Think Like a Publisher – How to Use Content to Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 52 - Wirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft Market Online and in Social Media. Indianapolis: Que.', NULL, NULL, NULL, NULL, NULL, true, 22);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (981, 158, 1, 'Löffler, Miriam (2014). Think Content! Content- Strategie, Content-Marketing, Texten furs Web, Bonn: Galileo Computing.', NULL, NULL, NULL, NULL, NULL, false, 23);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (982, 158, 1, 'Schneider, Martin (Hg.)(2013). Management von Medienunternehmen: Digitale Innovationen – crossmediale Strategien. Wiesbaden: Springer Gabler.', NULL, NULL, NULL, NULL, NULL, false, 24);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (983, 158, 1, 'Wirtz, Bernd W. (2013). Medien- und Internetmanagement (8. Aufl.). Wiesbaden: Springer Gabler.', NULL, NULL, NULL, NULL, NULL, false, 25);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (984, 158, 1, 'Wirtz, Bernd W. (2013). Übungsbuch Medien- und Internetmanagement: Fallstudien – Aufgaben – Lösungen. Wiesbaden: Springer Gabler.', NULL, NULL, NULL, NULL, NULL, false, 26);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (985, 159, 1, 'Anleitungen und Einführung zum Planspiel (TopSim o.ä.)', NULL, NULL, NULL, NULL, NULL, false, 2);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (986, 159, 1, 'Rahn, H.-J.: Einführung in die Betriebswirtschaftslehre, 11. Auflage, Herne 2013.', NULL, NULL, NULL, NULL, NULL, false, 4);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (987, 159, 1, 'Wöhe, Günter', NULL, NULL, NULL, NULL, NULL, false, 5);
INSERT INTO public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) VALUES (988, 159, 1, 'Döhring, Ulrich: Einführung in die Allgemeine Betriebswirtschaftslehre, 27. Auflage, München 2020.', NULL, NULL, NULL, NULL, NULL, false, 6);


--
-- Data for Name: modul_pruefung; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (67, 1, 'Klausur und/oder schriftliche Ausarbeitung und/oder
mündliche Prüfung', NULL, 'Klausur und/oder schriftliche Ausarbeitung und/oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (68, 1, 'Klausur und/oder schriftliche Ausarbeitung und/oder
mündliche Prüfung', NULL, 'Klausur und/oder schriftliche Ausarbeitung und/oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (57, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: keine
Prüfungsleistu', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (71, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (72, 1, 'Studienleistungen: Erfolgreich absolviertes Praktikum
als Vorleistung für die Prüfungszulassung
Prüf', 90, 'Studienleistungen: Erfolgreich absolviertes Praktikum', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (73, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 60, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (58, 1, 'Siehe § 26 der Bachelor-Rahmenprüfungsordnung und
§ 19 der Studiengangsprüfungsordnung', NULL, 'Siehe § 26 der Bachelor-Rahmenprüfungsordnung und', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (74, 1, 'Klausur', NULL, 'Klausur', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (75, 1, 'Klausur oder mündliche Prüfung', NULL, 'Klausur oder mündliche Prüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (76, 1, 'Klausur oder Kombinationsprüfung', NULL, 'Klausur oder Kombinationsprüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (77, 1, 'Studienleistungen: Die Studierenden können während
des Praktikums Bonuspunkte für die Klausur erwerb', NULL, 'Studienleistungen: Die Studierenden können während', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (78, 1, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder
Klausur (90 Min.) je nach Teilnehmerzahl (>12 K', 30, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (88, 1, 'Prüfungsleistungen:
Schriftliche Prüfung oder mündliche Prüfung oder
Kombinationsprüfung (55% Klausu', 60, 'Prüfungsleistungen:', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (79, 1, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder
Klausur (90 Min.) je nach Teilnehmerzahl (>12 K', 30, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (89, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine;
Prüfungsleist', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (90, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine;
Prüfungsleist', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (80, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (81, 1, 'Studienleistungen: Die Studierenden können während
des Praktikums Bonuspunkte für die Klausur erwerb', NULL, 'Studienleistungen: Die Studierenden können während', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (59, 1, 'Studienleistungen: Die Studierenden können während
des Praktikums Bonuspunkte für die Klausur erwerb', NULL, 'Studienleistungen: Die Studierenden können während', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (60, 1, 'Kombinationsprüfung: Zum Bestehen des Moduls
müssen das unbenotete Testat sowie das Projekt
bestande', NULL, 'Kombinationsprüfung: Zum Bestehen des Moduls', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (82, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 60, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (61, 1, 'Prüfungsleistungen: Klausur (120 Min.)', 120, 'Prüfungsleistungen: Klausur (120 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (62, 1, 'Studienleistungen: Die Studierenden können während
des Praktikums Bonuspunkte für die Klausur erwerb', NULL, 'Studienleistungen: Die Studierenden können während', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (63, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (114, 1, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)
beispielsweise Kombination aus Projekt und
Präsent', NULL, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (98, 1, 'Mündliche Prüfung (30 Min.) oder
Prüfungsleistungen: Klausur (90 Min.) je nach Teilnehmerzahl (>12 K', 30, 'Mündliche Prüfung (30 Min.) oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (99, 1, 'Literatur: • B. Cyganek, J.P. Siebert: „An Introduction to
3DComputer Vision Techniques and Algorith', NULL, 'Literatur: • B. Cyganek, J.P. Siebert: „An Introduction to', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (100, 1, 'Klausur oder mündliche Prüfung', NULL, 'Klausur oder mündliche Prüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (115, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (101, 1, 'Klausur und/oder mündliche Prüfung und/oder
schriftliche Ausarbeitung', NULL, 'Klausur und/oder mündliche Prüfung und/oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (116, 1, 'Anwesenheitspflicht nach Prüfungsordnung
Prüfungsleistung: Ausarbeitung der geforderten
Projektergeb', NULL, 'Anwesenheitspflicht nach Prüfungsordnung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (117, 1, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)
beispielsweise Kombination aus Präsentation und
sc', NULL, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (118, 1, 'Prüfungsleistungen: Kombinationsprüfung aus
2 Teilleistungen
▪ Präsentationen (50%)
▪ Schriftliche A', NULL, 'Prüfungsleistungen: Kombinationsprüfung aus', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (102, 1, 'Mündliche Prüfung (final), Vortrag, Ausarbeitung (auch
Codeartefakte)', NULL, 'Mündliche Prüfung (final), Vortrag, Ausarbeitung (auch', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (103, 1, 'Prüfungsleistungen: Klausur (90 Min.)
Westfälische Hochschule
Fachbereich Informatik und Kommunikati', 90, 'Prüfungsleistungen: Klausur (90 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (104, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (119, 1, 'Kombinationsprüfung (§ 12 PO).
Beispielsweise:
• K1: Klausur oder mündliche Prüfung
• K2: Ausarbeitu', NULL, 'Kombinationsprüfung (§ 12 PO).', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (91, 1, 'Anwesenheitspflicht nach Prüfungsordnung
Prüfungsleistungen: Vortrag mit Ausarbeitung und
mündliche ', NULL, 'Anwesenheitspflicht nach Prüfungsordnung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (120, 1, 'Kombinationsprüfung (§ 12 PO)
beispielsweise Kombination aus Projekt und
Präsentation', NULL, 'Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (105, 1, 'Klausur', NULL, 'Klausur', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (121, 1, 'Studienleistungen: Erfolgreich absolviertes Praktikum
als Vorleistung für die Prüfungszulassung
Prüf', 90, 'Studienleistungen: Erfolgreich absolviertes Praktikum', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (122, 1, 'Studienleistungen: Erfolgreich absolviertes Praktikum
als Vorleistung für die Prüfungszulassung
Prüf', 90, 'Studienleistungen: Erfolgreich absolviertes Praktikum', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (123, 1, 'Kombinationsprüfung', NULL, 'Kombinationsprüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (92, 1, 'Siehe § 16 PO und § 26 MRPO', NULL, 'Siehe § 16 PO und § 26 MRPO', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (106, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (93, 1, 'Siehe § 24 und § 25 der Master-
Rahmenprüfungsordnung und § 14 und § 15 der
Studiengangsprüfungsordn', NULL, 'Siehe § 24 und § 25 der Master-', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (107, 1, 'Course achievement: oral presentation including a
documentation, software and its related documentat', 60, 'Course achievement: oral presentation including a', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (7, 1, 'Kombinationsprüfung, beispielsweise wie folgt
aufgebaut:
- K1: Klausur
- K2: Ausarbeitung: Abgabe de', NULL, 'Kombinationsprüfung, beispielsweise wie folgt', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (8, 1, 'Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)', NULL, 'Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (9, 1, 'Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)', NULL, 'Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (10, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (11, 1, 'Siehe § 19 Prüfungsordnung', NULL, 'Siehe § 19 Prüfungsordnung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (16, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (1, 1, 'Klausur (75 Min)', 75, 'Klausur (75 Min)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (3, 1, 'Siehe § 18 der Prüfungsordnung', NULL, 'Siehe § 18 der Prüfungsordnung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (2, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (4, 1, 'Kombinationsprüfung', NULL, 'Kombinationsprüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (17, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (20, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (21, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (22, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (23, 1, 'Kombinationsprüfung, beispielsweise:
- K1: Klausur
- K2: Ausarbeitung: Abgabe der Lösungen
semesterb', NULL, 'Kombinationsprüfung, beispielsweise:', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (24, 1, 'Kombinationsprüfung (§ 14 PO)', NULL, 'Kombinationsprüfung (§ 14 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (26, 1, 'Prüfungsleistungen: Klausur (120 Min.)', 120, 'Prüfungsleistungen: Klausur (120 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (55, 1, 'Siehe § 24 und § 25 BRPO und siehe § 18 PO', NULL, 'Siehe § 24 und § 25 BRPO und siehe § 18 PO', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (56, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: keine
Prüfungsleistu', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (64, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: keine
Prüfungsleistu', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (83, 1, 'Prüfungsleistungen: Klausur (90 Min.)', 90, 'Prüfungsleistungen: Klausur (90 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (65, 1, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder
Klausur (90 Min.) je nach Teilnehmerzahl (>12 K', 30, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (84, 1, 'Studienleistungen lauf Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine;
Prüfungsleist', NULL, 'Studienleistungen lauf Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (66, 1, 'Klausur (75min)', 75, 'Klausur (75min)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (85, 1, 'Prüfungsleistungen: Klausur (90 Min.)', 90, 'Prüfungsleistungen: Klausur (90 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (5, 1, 'Prüfungsleistung: Klausur (75min)', 75, 'Prüfungsleistung: Klausur (75min)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (6, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (12, 1, 'Klausur (75 Min.)', 75, 'Klausur (75 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (13, 1, 'Klausur, mündliche Prüfung oder Kombinationsprüfung', NULL, 'Klausur, mündliche Prüfung oder Kombinationsprüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (14, 1, 'Studienleistungen: Die Studierenden können während
des Semesters Bonuspunkte für die Klausur erwerbe', 90, 'Studienleistungen: Die Studierenden können während', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (15, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 120, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (18, 1, 'siehe § 11 Bachelor-RahmenPO', NULL, 'siehe § 11 Bachelor-RahmenPO', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (19, 1, 'Studienleistungen: Die Studierenden können während
des Semesters Bonuspunkte für die Klausur erwerbe', 60, 'Studienleistungen: Die Studierenden können während', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (25, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 60, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (69, 1, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder
Klausur (90 Min.) je nach Teilnehmerzahl (>12 K', 30, 'Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (86, 1, 'Prüfungsleistungen: Klausur (90 Min.)', 90, 'Prüfungsleistungen: Klausur (90 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (87, 1, 'Studienleistungen lauf Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine;
Prüfungsleist', NULL, 'Studienleistungen lauf Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (70, 1, 'Studienleistungen: Erfolgreich absolviertes Praktikum
als Vorleistung für die Prüfungszulassung
Prüf', 90, 'Studienleistungen: Erfolgreich absolviertes Praktikum', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (129, 1, 'Kombinationsprüfung', NULL, 'Kombinationsprüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (108, 1, 'Studienleistungen: Die Studierenden können während
des Praktikums Bonuspunkte für die Klausur erwerb', NULL, 'Studienleistungen: Die Studierenden können während', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (124, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (109, 1, 'Klausur und/oder mündliche Prüfung und/oder
schriftliche Ausarbeitung', NULL, 'Klausur und/oder mündliche Prüfung und/oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (94, 1, 'Prüfungsleistungen: Ausarbeitung in Form einer
entwickelten Software, Ausarbeitungen und
Präsentatio', NULL, 'Prüfungsleistungen: Ausarbeitung in Form einer', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (95, 1, 'Anwesenheitspflicht nach Prüfungsordnung.
Westfälische Hochschule
Fachbereich Informatik und Kommuni', NULL, 'Anwesenheitspflicht nach Prüfungsordnung.', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (110, 1, 'Prüfungsleistung: Klausur (75min)
Westfälische Hochschule
Fachbereich Informatik und Kommunikation M', 75, 'Prüfungsleistung: Klausur (75min)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (125, 1, 'Kombinationsprüfung (§ 12 PO)
beispielsweise Kombination aus Projekt und
Präsentation', NULL, 'Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (126, 1, 'Prüfungsleistungen:
Schriftliche Prüfung oder mündliche Prüfung oder
Kombinationsprüfung (50% Klausu', 60, 'Prüfungsleistungen:', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (96, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (127, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (111, 1, 'Mündliche Prüfung (30 Min.) oder
Prüfungsleistungen: Klausur (90 Min.) je nach Teilnehmerzahl (>12 K', 30, 'Mündliche Prüfung (30 Min.) oder', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (128, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 90, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (112, 1, 'Course achievement: oral presentation including a
documentation, software and its related documentat', 60, 'Course achievement: oral presentation including a', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (130, 1, 'Kombinationsprüfung (§ 12 PO), beispielsweise:
• K1: Klausur oder mündliche Prüfung
• K2: Ausarbeitu', NULL, 'Kombinationsprüfung (§ 12 PO), beispielsweise:', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (131, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine;
Prüfungsleist', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (113, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: erfolgreiche
Teilnah', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (97, 1, 'Prüfungsleistung: Je nach Projekt Ausarbeitung in Form
einer entwickelten Software und/oder Ausarbei', NULL, 'Prüfungsleistung: Je nach Projekt Ausarbeitung in Form', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (132, 1, 'Kombinationsprüfung (§ 12 PO)', NULL, 'Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (133, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (134, 1, 'Benotung des Vortrages und der anschließenden
Diskussion und Fragen durch die Prüfer laut
Prüfungsor', NULL, 'Benotung des Vortrages und der anschließenden', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (135, 1, 'In der Prüfungsordnung geregelt', NULL, 'In der Prüfungsordnung geregelt', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (136, 1, 'Prüfungsleistung: Ausarbeitung der geforderten
Projektergebnisse und Präsentationen', NULL, 'Prüfungsleistung: Ausarbeitung der geforderten', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (137, 1, 'Prüfungsleistung: Ausarbeitung der geforderten
Projektergebnisse und Präsentationen', NULL, 'Prüfungsleistung: Ausarbeitung der geforderten', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (138, 1, 'In der Prüfungsordnung geregelt', NULL, 'In der Prüfungsordnung geregelt', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (139, 1, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)
beispielsweise Kombination aus Projekt und
Präsent', NULL, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (140, 1, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)
beispielsweise Kombination aus Projekt und
Präsent', NULL, 'Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (141, 1, 'Siehe § 16 Studiengangsprüfungsordnung', NULL, 'Siehe § 16 Studiengangsprüfungsordnung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (142, 1, 'Siehe § 14 PO und § 25 MRPO', NULL, 'Siehe § 14 PO und § 25 MRPO', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (143, 1, 'Kombinationsprüfung', NULL, 'Kombinationsprüfung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (144, 1, 'Kombinationsprüfung. Beispielsweise Präsentation und
schriftliche Ausarbeitung', NULL, 'Kombinationsprüfung. Beispielsweise Präsentation und', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (145, 1, 'Kombinationsprüfung (§ 12 PO)
beispielsweise Kombination aus Projekt und
Präsentation und schriftlic', NULL, 'Kombinationsprüfung (§ 12 PO)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (146, 1, 'Siehe § 24 und § 25 der Bachelor-
Rahmenprüfungsordnung', NULL, 'Siehe § 24 und § 25 der Bachelor-', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (147, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine
Prüfungsleistu', 60, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (148, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine;
Prüfungsleist', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (149, 1, 'Siehe § 26 der Bachelor-Rahmenprüfungsordnung und
§ 19 der Studiengangsprüfungsordnung', NULL, 'Siehe § 26 der Bachelor-Rahmenprüfungsordnung und', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (150, 1, 'Studienleistungen laut Prüfungsordnung als
Voraussetzung zur Prüfungsteilnahme: Keine;
Prüfungsleist', NULL, 'Studienleistungen laut Prüfungsordnung als', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (151, 1, 'Kombinationsprüfung: Zum Bestehen des Moduls
müssen das unbenotete Testat sowie das Projekt
bestande', NULL, 'Kombinationsprüfung: Zum Bestehen des Moduls', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (152, 1, 'Prüfungsleistungen: Klausur (120 Min.)', 120, 'Prüfungsleistungen: Klausur (120 Min.)', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (153, 1, 'Studierende erhalten für die folgenden freiwillig zu
erbringenden semesterbegleitenden Leistungen ei', 90, 'Studierende erhalten für die folgenden freiwillig zu', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (158, 1, 'Seminararbeit (50.000 Zeichen) und Präsentation (ca.
30 Minuten)', NULL, 'Seminararbeit (50.000 Zeichen) und Präsentation (ca.', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (154, 1, 'Siehe § 26 der MRPO und § 16 der PO', NULL, 'Siehe § 26 der MRPO und § 16 der PO', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (156, 1, 'Siehe § 24 und § 25 der Master-
Rahmenprüfungsordnung und § 14 und § 15 der
Studiengangsprüfungsordn', NULL, 'Siehe § 24 und § 25 der Master-', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (155, 1, 'Prüfungsleistungen: Ausarbeitung in Form einer
entwickelten Software, Ausarbeitungen und
Präsentatio', NULL, 'Prüfungsleistungen: Ausarbeitung in Form einer', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (157, 1, 'Anwesenheitspflicht nach Prüfungsordnung
Prüfungsleistungen: Ausarbeitung und Vortrag', NULL, 'Anwesenheitspflicht nach Prüfungsordnung', NULL);
INSERT INTO public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) VALUES (159, 1, 'Die Teilnehmer der Veranstaltung sind verpflichtet am
Planspiel und den dafür erforderlichen Präsenz', NULL, 'Die Teilnehmer der Veranstaltung sind verpflichtet am', NULL);


--
-- Data for Name: modul_seiten; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (1, 1, 1, 5, 6);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (2, 1, 1, 7, 8);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (3, 1, 1, 9, 10);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (4, 1, 1, 11, 12);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (5, 1, 1, 13, 14);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (6, 1, 1, 15, 16);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (7, 1, 1, 17, 19);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (8, 1, 1, 20, 22);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (9, 1, 1, 23, 25);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (10, 1, 1, 26, 27);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (11, 1, 1, 28, 29);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (12, 1, 1, 30, 31);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (13, 1, 1, 32, 33);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (14, 1, 1, 34, 35);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (15, 1, 1, 36, 37);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (16, 1, 1, 38, 39);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (17, 1, 1, 40, 42);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (18, 1, 1, 43, 44);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (19, 1, 1, 45, 46);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (20, 1, 1, 47, 48);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (21, 1, 1, 49, 50);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (22, 1, 1, 51, 52);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (23, 1, 1, 53, 54);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (24, 1, 1, 55, 56);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (25, 1, 1, 57, 58);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (26, 1, 1, 59, 61);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (27, 1, 1, 62, 63);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (28, 1, 1, 64, 64);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (29, 1, 1, 65, 65);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (30, 1, 1, 66, 66);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (31, 1, 1, 67, 67);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (32, 1, 1, 68, 68);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (33, 1, 1, 69, 69);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (34, 1, 1, 70, 71);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (35, 1, 1, 72, 73);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (36, 1, 1, 74, 75);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (37, 1, 1, 76, 77);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (38, 1, 1, 78, 80);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (39, 1, 1, 81, 82);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (40, 1, 1, 83, 84);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (41, 1, 1, 85, 85);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (42, 1, 1, 86, 87);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (43, 1, 1, 88, 89);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (44, 1, 1, 90, 91);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (45, 1, 1, 92, 93);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (46, 1, 1, 94, 94);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (47, 1, 1, 95, 95);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (48, 1, 1, 96, 97);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (49, 1, 1, 98, 99);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (50, 1, 1, 100, 101);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (51, 1, 1, 102, 103);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (52, 1, 1, 104, 105);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (53, 1, 1, 106, 107);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (54, 1, 1, 108, 108);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (1, 1, 2, 5, 6);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (55, 1, 2, 7, 8);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (56, 1, 2, 9, 10);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (5, 1, 2, 11, 12);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (6, 1, 2, 13, 14);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (57, 1, 2, 15, 16);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (58, 1, 2, 17, 18);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (12, 1, 2, 19, 20);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (13, 1, 2, 21, 22);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (14, 1, 2, 23, 24);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (15, 1, 2, 25, 26);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (18, 1, 2, 27, 28);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (59, 1, 2, 29, 30);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (19, 1, 2, 31, 32);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (60, 1, 2, 33, 36);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (25, 1, 2, 37, 38);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (61, 1, 2, 39, 40);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (62, 1, 2, 41, 42);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (63, 1, 2, 43, 45);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (64, 1, 2, 46, 46);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (65, 1, 2, 47, 48);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (66, 1, 2, 49, 50);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (67, 1, 2, 51, 52);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (68, 1, 2, 53, 54);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (69, 1, 2, 55, 56);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (70, 1, 2, 57, 59);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (71, 1, 2, 60, 61);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (72, 1, 2, 62, 63);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (73, 1, 2, 64, 65);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (74, 1, 2, 66, 67);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (75, 1, 2, 68, 69);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (76, 1, 2, 70, 71);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (77, 1, 2, 72, 73);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (78, 1, 2, 74, 75);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (79, 1, 2, 76, 77);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (80, 1, 2, 78, 79);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (81, 1, 2, 80, 81);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (82, 1, 2, 82, 84);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (83, 1, 2, 85, 86);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (84, 1, 2, 87, 89);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (85, 1, 2, 90, 91);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (86, 1, 2, 92, 93);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (87, 1, 2, 94, 96);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (88, 1, 2, 97, 99);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (89, 1, 2, 100, 101);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (90, 1, 2, 102, 103);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (91, 1, 3, 5, 6);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (92, 1, 3, 7, 8);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (93, 1, 3, 9, 10);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (94, 1, 3, 11, 12);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (95, 1, 3, 13, 14);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (96, 1, 3, 15, 17);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (97, 1, 3, 18, 20);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (98, 1, 3, 21, 22);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (99, 1, 3, 23, 24);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (100, 1, 3, 25, 26);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (101, 1, 3, 27, 28);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (102, 1, 3, 29, 30);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (103, 1, 3, 31, 33);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (104, 1, 3, 34, 35);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (105, 1, 3, 36, 37);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (106, 1, 3, 38, 39);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (107, 1, 3, 40, 42);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (108, 1, 3, 43, 44);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (109, 1, 3, 45, 46);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (110, 1, 3, 47, 48);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (111, 1, 3, 49, 50);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (112, 1, 3, 51, 52);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (113, 1, 3, 53, 57);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (114, 1, 3, 58, 59);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (115, 1, 3, 60, 61);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (116, 1, 3, 62, 63);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (117, 1, 3, 64, 65);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (118, 1, 3, 66, 67);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (119, 1, 3, 68, 70);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (120, 1, 3, 71, 72);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (121, 1, 3, 73, 74);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (122, 1, 3, 75, 77);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (123, 1, 3, 78, 81);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (124, 1, 3, 82, 83);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (125, 1, 3, 84, 85);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (126, 1, 3, 86, 88);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (127, 1, 3, 89, 90);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (128, 1, 3, 91, 92);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (129, 1, 3, 93, 96);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (130, 1, 3, 97, 99);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (131, 1, 3, 100, 101);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (132, 1, 3, 102, 103);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (133, 1, 4, 4, 5);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (116, 1, 4, 6, 7);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (121, 1, 4, 8, 9);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (122, 1, 4, 10, 12);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (134, 1, 4, 13, 14);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (135, 1, 4, 15, 16);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (124, 1, 4, 17, 18);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (136, 1, 4, 19, 20);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (137, 1, 4, 21, 22);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (138, 1, 4, 23, 24);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (127, 1, 4, 25, 26);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (128, 1, 4, 27, 29);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (100, 1, 4, 30, 31);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (115, 1, 4, 32, 33);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (101, 1, 4, 34, 35);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (118, 1, 4, 36, 37);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (103, 1, 4, 38, 40);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (104, 1, 4, 41, 42);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (105, 1, 4, 43, 44);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (106, 1, 4, 45, 46);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (110, 1, 4, 47, 48);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (126, 1, 4, 49, 51);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (113, 1, 4, 52, 55);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (139, 1, 5, 5, 6);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (140, 1, 5, 7, 8);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (117, 1, 5, 9, 10);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (91, 1, 5, 11, 14);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (141, 1, 5, 15, 16);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (142, 1, 5, 17, 18);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (143, 1, 5, 19, 21);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (144, 1, 5, 22, 23);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (130, 1, 5, 24, 27);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (114, 1, 5, 28, 29);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (98, 1, 5, 30, 31);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (99, 1, 5, 32, 33);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (100, 1, 5, 34, 35);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (101, 1, 5, 36, 37);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (116, 1, 5, 38, 39);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (103, 1, 5, 40, 42);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (104, 1, 5, 43, 44);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (119, 1, 5, 45, 47);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (120, 1, 5, 48, 49);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (105, 1, 5, 50, 51);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (121, 1, 5, 52, 53);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (122, 1, 5, 54, 56);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (123, 1, 5, 57, 58);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (106, 1, 5, 59, 60);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (107, 1, 5, 61, 63);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (124, 1, 5, 64, 65);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (109, 1, 5, 66, 67);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (110, 1, 5, 68, 69);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (125, 1, 5, 70, 71);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (96, 1, 5, 72, 74);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (112, 1, 5, 75, 76);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (145, 1, 5, 77, 78);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (132, 1, 5, 79, 82);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (1, 1, 6, 5, 6);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (146, 1, 6, 7, 7);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (147, 1, 6, 8, 9);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (83, 1, 6, 10, 11);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (5, 1, 6, 12, 13);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (84, 1, 6, 14, 16);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (85, 1, 6, 17, 18);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (6, 1, 6, 19, 20);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (86, 1, 6, 21, 22);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (148, 1, 6, 23, 24);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (87, 1, 6, 25, 27);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (71, 1, 6, 28, 29);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (149, 1, 6, 30, 31);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (12, 1, 6, 32, 33);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (13, 1, 6, 34, 35);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (14, 1, 6, 36, 37);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (15, 1, 6, 38, 39);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (89, 1, 6, 40, 41);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (90, 1, 6, 42, 43);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (18, 1, 6, 44, 45);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (150, 1, 6, 46, 48);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (19, 1, 6, 49, 50);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (151, 1, 6, 51, 53);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (25, 1, 6, 54, 55);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (152, 1, 6, 56, 57);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (64, 1, 6, 58, 58);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (65, 1, 6, 59, 60);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (66, 1, 6, 61, 62);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (69, 1, 6, 63, 64);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (70, 1, 6, 65, 67);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (57, 1, 6, 68, 69);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (72, 1, 6, 70, 71);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (73, 1, 6, 72, 73);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (75, 1, 6, 74, 75);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (76, 1, 6, 76, 77);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (78, 1, 6, 78, 79);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (88, 1, 6, 80, 82);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (81, 1, 6, 83, 84);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (82, 1, 6, 85, 86);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (153, 1, 7, 4, 6);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (101, 1, 7, 7, 8);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (121, 1, 7, 9, 10);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (154, 1, 7, 11, 12);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (155, 1, 7, 15, 16);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (156, 1, 7, 17, 18);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (157, 1, 7, 19, 20);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (110, 1, 7, 21, 22);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (129, 1, 7, 23, 26);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (131, 1, 7, 27, 29);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (100, 1, 7, 30, 31);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (103, 1, 7, 32, 34);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (104, 1, 7, 35, 36);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (122, 1, 7, 37, 39);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (108, 1, 7, 40, 41);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (126, 1, 7, 42, 44);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (112, 1, 7, 45, 46);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (113, 1, 7, 47, 49);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (158, 1, 7, 50, 53);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (159, 1, 7, 54, 56);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (116, 1, 7, 57, 58);
INSERT INTO public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) VALUES (91, 1, 7, 59, 60);


--
-- Data for Name: modul_sprache; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (1, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (5, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (6, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (12, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (15, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (18, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (24, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (25, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (26, 1, 2);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (34, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (38, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (39, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (55, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (56, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (57, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (58, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (60, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (61, 1, 2);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (63, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (64, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (65, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (66, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (70, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (72, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (73, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (74, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (75, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (76, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (80, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (82, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (84, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (85, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (86, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (87, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (89, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (96, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (100, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (104, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (105, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (106, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (110, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (113, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (115, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (116, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (121, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (122, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (124, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (127, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (128, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (129, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (133, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (134, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (135, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (136, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (137, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (138, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (146, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (149, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (151, 1, 1);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (152, 1, 2);
INSERT INTO public.modul_sprache (modul_id, po_id, sprache_id) VALUES (158, 1, 1);


--
-- Data for Name: modul_studiengang; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (4, 2, 1, 1, 4, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (13, 7, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (16, 10, 1, 1, 4, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (41, 23, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (46, 26, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (307, 42, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (305, 40, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (306, 41, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (292, 27, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (308, 43, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (293, 28, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (309, 44, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (117, 133, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (310, 45, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (316, 51, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (294, 29, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (311, 46, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (304, 39, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (295, 30, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (312, 47, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (296, 31, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (313, 48, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (297, 32, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (314, 49, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (298, 33, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (299, 34, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (315, 50, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (300, 35, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (301, 36, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (317, 52, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (302, 37, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (318, 53, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (319, 54, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (303, 38, 1, 2, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (80, 60, 1, 2, 5, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (5, 3, 1, 1, 6, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (6, 4, 1, 1, 3, false, true, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (14, 8, 1, 1, 5, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (15, 9, 1, 1, 4, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (17, 11, 1, 1, 6, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (30, 16, 1, 1, 5, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (31, 17, 1, 1, 4, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (38, 20, 1, 1, 5, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (39, 21, 1, 1, 4, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (40, 22, 1, 1, 2, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (42, 24, 1, 1, 1, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (257, 114, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (241, 98, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (242, 99, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (243, 100, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (258, 115, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (244, 101, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (259, 116, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (260, 117, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (261, 118, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (245, 102, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (246, 103, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (247, 104, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (262, 119, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (234, 91, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (263, 120, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (248, 105, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (264, 121, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (265, 122, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (266, 123, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (235, 92, 1, 6, NULL, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (249, 106, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (155, 146, 1, 1, 6, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (133, 139, 1, 1, 2, false, true, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (134, 140, 1, 1, 1, false, true, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (170, 149, 1, 1, 6, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (127, 137, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (122, 134, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (129, 127, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (130, 128, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (138, 141, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (203, 154, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (135, 117, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (123, 135, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (206, 156, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (139, 142, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (125, 136, 1, 1, 1, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (142, 144, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (143, 130, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (140, 143, 1, 1, 2, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (205, 155, 1, 1, 3, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (128, 138, 1, 1, 3, false, true, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (236, 93, 1, 6, NULL, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (250, 107, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (251, 108, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (156, 147, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (157, 83, 1, 1, 5, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (267, 124, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (252, 109, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (237, 94, 1, 6, NULL, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (161, 84, 1, 1, 5, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (162, 85, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (238, 95, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (253, 110, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (268, 125, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (166, 86, 1, 1, 4, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (167, 148, 1, 1, 4, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (168, 87, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (269, 126, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (239, 96, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (270, 127, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (254, 111, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (271, 128, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (255, 112, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (272, 129, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (273, 130, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (274, 131, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (256, 113, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (240, 97, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (275, 132, 1, 6, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (100, 94, 1, 4, 3, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (126, 136, 1, 4, 2, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (183, 89, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (184, 90, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (344, 76, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (349, 153, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (359, 100, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (188, 150, 1, 1, 5, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (350, 101, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (369, 116, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (360, 103, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (192, 151, 1, 1, 4, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (193, 151, 1, 2, 5, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (361, 104, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (367, 158, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (370, 91, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (197, 152, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (351, 121, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (199, 153, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (362, 122, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (352, 154, 1, 7, NULL, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (354, 156, 1, 7, NULL, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (363, 108, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (353, 155, 1, 7, NULL, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (355, 157, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (207, 157, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (356, 110, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (209, 129, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (210, 131, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (364, 126, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (368, 159, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (365, 112, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (357, 129, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (358, 131, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (149, 124, 1, 1, 2, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (366, 113, 1, 7, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (201, 121, 1, 1, 1, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (211, 122, 1, 1, 2, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (212, 116, 1, 1, 2, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (152, 1, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (153, 1, 1, 2, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (154, 1, 1, 3, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (277, 3, 1, 2, 6, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (276, 2, 1, 2, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (278, 4, 1, 2, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (158, 5, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (159, 5, 1, 2, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (160, 5, 1, 3, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (163, 6, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (164, 6, 1, 2, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (165, 6, 1, 3, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (279, 7, 1, 2, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (280, 8, 1, 2, 5, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (281, 9, 1, 2, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (282, 10, 1, 2, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (283, 11, 1, 2, 6, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (171, 12, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (172, 12, 1, 2, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (173, 12, 1, 3, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (174, 13, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (175, 13, 1, 2, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (176, 13, 1, 3, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (177, 14, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (178, 14, 1, 2, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (179, 14, 1, 3, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (180, 15, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (181, 15, 1, 2, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (182, 15, 1, 3, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (284, 16, 1, 2, 5, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (285, 17, 1, 2, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (185, 18, 1, 1, 6, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (186, 18, 1, 2, 6, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (187, 18, 1, 3, 6, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (189, 19, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (190, 19, 1, 2, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (191, 19, 1, 3, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (286, 20, 1, 2, 5, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (287, 21, 1, 2, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (288, 22, 1, 2, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (289, 23, 1, 2, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (290, 24, 1, 2, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (194, 25, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (195, 25, 1, 2, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (196, 25, 1, 3, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (291, 26, 1, 2, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (50, 55, 1, 1, 6, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (215, 64, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (335, 64, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (322, 83, 1, 3, 5, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (51, 56, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (216, 65, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (336, 65, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (323, 84, 1, 3, 5, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (217, 66, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (337, 66, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (218, 67, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (324, 85, 1, 3, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (219, 68, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (220, 69, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (338, 69, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (325, 86, 1, 3, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (327, 87, 1, 3, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (221, 70, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (339, 70, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (198, 57, 1, 1, 3, true, false, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (340, 57, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (169, 71, 1, 1, 4, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (328, 71, 1, 3, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (222, 72, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (341, 72, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (223, 73, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (342, 73, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (59, 58, 1, 1, 6, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (224, 74, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (225, 75, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (343, 75, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (226, 76, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (227, 77, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (228, 78, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (345, 78, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (233, 88, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (346, 88, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (229, 79, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (330, 89, 1, 3, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (331, 90, 1, 3, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (230, 80, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (231, 81, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (347, 81, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (75, 59, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (79, 60, 1, 1, 4, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (232, 82, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (348, 82, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (84, 61, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (85, 62, 1, 1, 1, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (86, 63, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (378, 114, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (424, 98, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (379, 98, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (425, 99, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (380, 99, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (426, 100, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (381, 100, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (413, 100, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (427, 100, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (414, 115, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (200, 101, 1, 1, 1, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (382, 101, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (415, 101, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (428, 101, 1, 3, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (383, 116, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (402, 116, 1, 5, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (429, 116, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (373, 117, 1, 4, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (430, 118, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (416, 118, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (431, 102, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (432, 103, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (417, 103, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (384, 103, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (433, 103, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (434, 104, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (385, 104, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (418, 104, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (435, 104, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (386, 119, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (213, 91, 1, 1, 3, true, false, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (214, 91, 1, 4, 1, true, false, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (436, 91, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (387, 120, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (437, 105, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (388, 105, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (419, 105, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (202, 121, 1, 4, 1, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (403, 121, 1, 5, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (438, 121, 1, 3, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (389, 122, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (404, 122, 1, 5, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (439, 122, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (390, 123, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (97, 92, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (440, 106, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (391, 106, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (420, 106, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (98, 93, 1, 1, 4, true, false, 'thesis');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (441, 107, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (392, 107, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (442, 108, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (393, 124, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (407, 124, 1, 5, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (443, 109, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (394, 109, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (99, 94, 1, 1, 2, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (101, 95, 1, 1, 2, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (208, 110, 1, 1, 1, false, true, 'wahlpflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (395, 110, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (421, 110, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (444, 110, 1, 3, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (396, 125, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (445, 126, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (422, 126, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (446, 126, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (151, 96, 1, 1, 1, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (397, 96, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (411, 127, 1, 5, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (447, 111, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (412, 128, 1, 5, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (448, 112, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (398, 112, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (449, 112, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (450, 129, 1, 3, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (377, 130, 1, 4, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (451, 131, 1, 3, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (452, 113, 1, 1, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (423, 113, 1, 5, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (453, 113, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (103, 97, 1, 1, 3, true, false, 'pflicht');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (400, 132, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (401, 133, 1, 5, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (405, 134, 1, 5, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (406, 135, 1, 5, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (408, 136, 1, 5, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (409, 137, 1, 5, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (410, 138, 1, 5, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (371, 139, 1, 4, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (372, 140, 1, 4, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (374, 141, 1, 4, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (375, 142, 1, 4, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (141, 143, 1, 4, 2, true, false, 'projekt');
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (376, 144, 1, 4, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (399, 145, 1, 4, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (320, 146, 1, 3, 6, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (321, 147, 1, 3, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (326, 148, 1, 3, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (329, 149, 1, 3, 6, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (332, 150, 1, 3, 5, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (333, 151, 1, 3, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (334, 152, 1, 3, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (454, 153, 1, 3, 1, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (455, 158, 1, 3, NULL, false, true, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (456, 154, 1, 3, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (457, 156, 1, 3, 4, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (458, 155, 1, 3, 2, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (459, 157, 1, 3, 3, true, false, NULL);
INSERT INTO public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) VALUES (460, 159, 1, 3, NULL, false, true, NULL);


--
-- Data for Name: modul_voraussetzungen; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (2, 1, '', '(Modulprüfungen):', '');
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (4, 1, '', '(Modulprüfungen):', '');
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (3, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (7, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (8, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (9, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (10, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (11, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (16, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (17, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (20, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (21, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (22, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (23, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (24, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (26, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (27, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (28, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (29, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (30, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (31, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (32, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (33, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (34, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (35, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (36, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (37, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (38, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (39, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (40, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (41, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (42, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (43, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (44, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (45, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (46, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (47, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (48, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (49, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (50, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (51, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (52, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (53, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (54, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (55, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (56, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (58, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (59, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (60, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (61, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (62, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (63, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (67, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (68, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (74, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (77, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (79, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (80, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (92, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (93, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (94, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (95, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (97, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (102, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (111, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (1, 1, '', '(Modulprüfungen):', '');
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (133, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (134, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (135, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (136, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (137, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (138, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (127, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (128, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (115, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (118, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (139, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (140, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (117, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (141, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (142, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (143, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (144, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (130, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (114, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (98, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (99, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (119, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (120, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (105, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (123, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (106, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (107, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (124, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (109, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (125, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (96, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (145, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (132, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (146, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (147, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (83, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (5, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (84, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (85, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (6, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (86, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (148, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (87, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (71, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (149, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (12, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (13, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (14, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (15, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (89, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (90, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (18, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (150, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (19, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (151, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (25, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (152, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (64, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (65, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (66, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (69, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (70, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (57, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (72, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (73, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (75, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (76, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (78, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (88, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (81, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (82, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (153, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (101, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (121, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (154, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (155, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (156, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (157, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (110, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (129, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (131, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (100, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (103, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (104, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (122, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (108, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (126, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (112, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (113, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (158, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (159, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (116, 1, NULL, '(Modulprüfungen):', NULL);
INSERT INTO public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) VALUES (91, 1, NULL, '(Modulprüfungen):', NULL);


--
-- Data for Name: modulhandbuch; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) VALUES (1, 'MHB_2023_ID_BA.pdf', 2, 1, NULL, NULL, 54, '2025-10-09 15:29:11', '22815c9a2fd6ba0ba8e4cc19956cb8ca94b7732980ce78055ae66d213742d253');
INSERT INTO public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) VALUES (2, 'MHB_2023_IN_BA.pdf', 1, 1, NULL, NULL, 46, '2025-10-09 15:29:15', 'e42773225482c2fda4f647d2da9756c5f0f313c3da755e77bcd48c2e43dc9fa4');
INSERT INTO public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) VALUES (3, 'MHB_2023_IN_MA.pdf', 6, 1, NULL, NULL, 42, '2025-10-09 15:29:20', '1c2fddb2f7b469d678f7fe15b02cf2dd6400a69f3c50e45fd333457430ce6ead');
INSERT INTO public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) VALUES (4, 'MHB_2023_IS_MA.pdf', 5, 1, NULL, NULL, 23, '2025-10-09 15:29:22', '39031000b18c6c06c92eca0b4d51ce425f4cebcc1c84d35a252dacda38fa492f');
INSERT INTO public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) VALUES (5, 'MHB_2023_MI_MA.pdf', 8, 1, NULL, NULL, 33, '2025-10-09 15:29:26', 'a28b0f55e94deb7211d30c7b468fe261fe71f61141b5650e4f620fc7c6830ee6');
INSERT INTO public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) VALUES (6, 'MHB_2023_WI_BA.pdf', 3, 1, NULL, NULL, 39, '2025-10-09 15:29:30', '001cf2cc15f850628253c8d01202601ccb867a82f2e6fad8cf2bb883961000cb');
INSERT INTO public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) VALUES (7, 'MHB_2023_WI_MA.pdf', 7, 1, NULL, NULL, 23, '2025-10-09 15:29:33', 'e2781c88c2fd7a9012048c200112f021a748bda6ada950c1f6d8ce818e08eb84');


--
-- Data for Name: phase_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.phase_submissions (planungphase_id, professor_id, planung_id, eingereicht_am, status, freigegeben_am, freigegeben_von, abgelehnt_am, abgelehnt_von, abgelehnt_grund, id, created_at, updated_at) VALUES (19, 10, 20, '2026-02-02 01:38:55.893778', 'eingereicht', NULL, NULL, NULL, NULL, NULL, 23, '2026-02-02 01:38:55.631082', '2026-02-02 01:38:55.897788');


--
-- Data for Name: planungs_templates; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.planungs_templates (id, benutzer_id, semester_typ, name, beschreibung, ist_aktiv, wunsch_freie_tage, anmerkungen, raumbedarf, created_at, updated_at) VALUES (1, 39, 'winter', 'test', NULL, true, NULL, NULL, NULL, '2026-01-21 07:40:08.348335', '2026-01-21 07:40:08.37789');
INSERT INTO public.planungs_templates (id, benutzer_id, semester_typ, name, beschreibung, ist_aktiv, wunsch_freie_tage, anmerkungen, raumbedarf, created_at, updated_at) VALUES (2, 10, 'winter', 'winter', NULL, true, NULL, NULL, NULL, '2026-02-01 13:48:18.839424', '2026-02-01 13:48:18.93445');


--
-- Data for Name: planungsphasen; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.planungsphasen (semester_id, name, startdatum, enddatum, ist_aktiv, geschlossen_am, geschlossen_von, geschlossen_grund, semester_typ, semester_jahr, anzahl_einreichungen, anzahl_genehmigt, anzahl_abgelehnt, id, created_at, updated_at) VALUES (2, 'Wintersemester 2026/2027 - Planungsphase', '2026-02-02 02:36:13.609', '2026-02-03 00:00:00', true, NULL, NULL, NULL, 'wintersemester', 2026, 1, 0, 0, 19, '2026-02-02 01:36:19.486644', '2026-02-02 01:38:55.624381');


--
-- Data for Name: pruefungsordnung; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.pruefungsordnung (id, po_jahr, gueltig_von, gueltig_bis, beschreibung, created_at, updated_at) VALUES (1, 'PO2023', '2023-10-01', NULL, NULL, '2025-10-09 15:29:06', '2025-10-09 15:29:06');


--
-- Data for Name: rolle; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rolle (id, name, beschreibung, created_at) VALUES (1, 'dekan', 'Dekan - Vollzugriff', '2025-10-15 14:45:51');
INSERT INTO public.rolle (id, name, beschreibung, created_at) VALUES (2, 'professor', 'Professor - Eigene Planung + Module', '2025-10-15 14:45:51');
INSERT INTO public.rolle (id, name, beschreibung, created_at) VALUES (3, 'lehrbeauftragter', 'Lehrbeauftragter - Eigene Planung', '2025-10-15 14:45:51');


--
-- Data for Name: semester; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.semester (id, bezeichnung, kuerzel, start_datum, ende_datum, vorlesungsbeginn, vorlesungsende, ist_aktiv, ist_planungsphase, created_at) VALUES (1, 'Wintersemester 2025/2026', 'WS2025', '2025-10-01', '2026-03-31', '2025-10-15', '2026-02-15', true, false, '2025-10-15 14:45:51');
INSERT INTO public.semester (id, bezeichnung, kuerzel, start_datum, ende_datum, vorlesungsbeginn, vorlesungsende, ist_aktiv, ist_planungsphase, created_at) VALUES (2, 'Wintersemester 2026/2027', 'WS2026', '2026-10-01', '2027-03-31', NULL, NULL, true, true, '2026-01-22 19:28:01.036153');


--
-- Data for Name: semester_auftrag; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: semesterplanung; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.semesterplanung (id, semester_id, benutzer_id, planungsphase_id, status, anmerkungen, raumbedarf, room_requirements, special_requests, gesamt_sws, eingereicht_am, freigegeben_von, freigegeben_am, abgelehnt_am, ablehnungsgrund, created_at, updated_at) VALUES (20, 2, 10, 19, 'eingereicht', NULL, NULL, NULL, NULL, 4, '2026-02-02 01:38:55.560779', NULL, NULL, NULL, NULL, '2026-02-02 01:38:42.608362', '2026-02-02 01:38:55.562787');


--
-- Data for Name: sprache; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sprache (id, bezeichnung, iso_code) VALUES (1, 'Deutsch', 'de');
INSERT INTO public.sprache (id, bezeichnung, iso_code) VALUES (2, 'Englisch', 'en');
INSERT INTO public.sprache (id, bezeichnung, iso_code) VALUES (3, 'Deutsch/Englisch', 'de-en');


--
-- Data for Name: studiengang; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) VALUES (1, 'IN', 'Informatik', 'Bachelor', 'Informatik und Kommunikation', 7, 210, true, '2025-10-09 15:29:06');
INSERT INTO public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) VALUES (2, 'ID', 'Informatik.Dual', 'Bachelor', 'Informatik und Kommunikation', 7, 210, true, '2025-10-09 15:29:06');
INSERT INTO public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) VALUES (3, 'WI', 'Wirtschaftsinformatik', 'Bachelor', 'Informatik und Kommunikation', 7, 210, true, '2025-10-09 15:29:06');
INSERT INTO public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) VALUES (5, 'IS', 'Internet-Sicherheit', 'Master', 'Informatik und Kommunikation', 4, 120, true, '2025-10-09 15:29:06');
INSERT INTO public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) VALUES (4, 'MI', 'Medieninformatik', 'Master', 'Informatik und Kommunikation', 4, 120, true, '2025-10-09 15:29:06');
INSERT INTO public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) VALUES (6, 'IN_MA', 'Informatik', 'Master', 'Informatik und Kommunikation', 4, 120, true, '2026-01-27 18:22:52.999272');
INSERT INTO public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) VALUES (7, 'WI_MA', 'Wirtschaftsinformatik', 'Master', 'Informatik und Kommunikation', 4, 120, true, '2026-01-27 18:22:53.006246');


--
-- Data for Name: template_module; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.template_module (id, template_id, modul_id, po_id, anzahl_vorlesungen, anzahl_uebungen, anzahl_praktika, anzahl_seminare, mitarbeiter_ids, anmerkungen, raumbedarf, raum_vorlesung, raum_uebung, raum_praktikum, raum_seminar, kapazitaet_vorlesung, kapazitaet_uebung, kapazitaet_praktikum, kapazitaet_seminar, created_at) VALUES (1, 1, 89, 1, 1, 0, 1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 30, 20, 15, 20, '2026-01-21 08:29:01.116058');
INSERT INTO public.template_module (id, template_id, modul_id, po_id, anzahl_vorlesungen, anzahl_uebungen, anzahl_praktika, anzahl_seminare, mitarbeiter_ids, anmerkungen, raumbedarf, raum_vorlesung, raum_uebung, raum_praktikum, raum_seminar, kapazitaet_vorlesung, kapazitaet_uebung, kapazitaet_praktikum, kapazitaet_seminar, created_at) VALUES (2, 1, 90, 1, 1, 1, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 30, 20, 15, 20, '2026-01-21 09:04:45.207599');
INSERT INTO public.template_module (id, template_id, modul_id, po_id, anzahl_vorlesungen, anzahl_uebungen, anzahl_praktika, anzahl_seminare, mitarbeiter_ids, anmerkungen, raumbedarf, raum_vorlesung, raum_uebung, raum_praktikum, raum_seminar, kapazitaet_vorlesung, kapazitaet_uebung, kapazitaet_praktikum, kapazitaet_seminar, created_at) VALUES (3, 2, 1, 1, 1, 1, 0, 0, '[27]', NULL, NULL, NULL, NULL, NULL, NULL, 30, 20, 15, 20, '2026-02-01 13:48:41.651452');


--
-- Data for Name: wunsch_freie_tage; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Name: archivierte_planungen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.archivierte_planungen_id_seq', 102, true);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: auftrag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auftrag_id_seq', 20, true);


--
-- Name: benachrichtigung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.benachrichtigung_id_seq', 74, true);


--
-- Name: benutzer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.benutzer_id_seq', 54, true);


--
-- Name: deputats_betreuung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deputats_betreuung_id_seq', 1, false);


--
-- Name: deputats_einstellungen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deputats_einstellungen_id_seq', 1, true);


--
-- Name: deputats_ermaessigung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deputats_ermaessigung_id_seq', 1, false);


--
-- Name: deputats_lehrexport_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deputats_lehrexport_id_seq', 1, false);


--
-- Name: deputats_lehrtaetigkeit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deputats_lehrtaetigkeit_id_seq', 3, true);


--
-- Name: deputats_vertretung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deputats_vertretung_id_seq', 1, false);


--
-- Name: deputatsabrechnung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deputatsabrechnung_id_seq', 4, true);


--
-- Name: dozent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dozent_id_seq', 53, true);


--
-- Name: dozent_position_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dozent_position_id_seq', 26, true);


--
-- Name: geplante_module_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.geplante_module_id_seq', 29, true);


--
-- Name: lehrform_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.lehrform_id_seq', 7, true);


--
-- Name: modul_abhÃ¤ngigkeit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."modul_abhÃ¤ngigkeit_id_seq"', 1, false);


--
-- Name: modul_audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modul_audit_log_id_seq', 1, true);


--
-- Name: modul_dozent_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modul_dozent_id_seq', 502, true);


--
-- Name: modul_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modul_id_seq', 159, true);


--
-- Name: modul_lehrform_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modul_lehrform_id_seq', 480, true);


--
-- Name: modul_literatur_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modul_literatur_id_seq', 990, true);


--
-- Name: modul_studiengang_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modul_studiengang_id_seq', 460, true);


--
-- Name: modulhandbuch_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.modulhandbuch_id_seq', 7, true);


--
-- Name: phase_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.phase_submissions_id_seq', 23, true);


--
-- Name: planungs_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.planungs_templates_id_seq', 2, true);


--
-- Name: planungsphasen_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.planungsphasen_id_seq', 19, true);


--
-- Name: pruefungsordnung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pruefungsordnung_id_seq', 1, true);


--
-- Name: rolle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rolle_id_seq', 3, true);


--
-- Name: semester_auftrag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.semester_auftrag_id_seq', 6, true);


--
-- Name: semester_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.semester_id_seq', 2, true);


--
-- Name: semesterplanung_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.semesterplanung_id_seq', 20, true);


--
-- Name: sprache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sprache_id_seq', 3, true);


--
-- Name: studiengang_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.studiengang_id_seq', 7, true);


--
-- Name: template_module_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.template_module_id_seq', 3, true);


--
-- Name: wunsch_freie_tage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wunsch_freie_tage_id_seq', 1, false);


--
-- Name: archivierte_planungen archivierte_planungen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivierte_planungen
    ADD CONSTRAINT archivierte_planungen_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: auftrag auftrag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auftrag
    ADD CONSTRAINT auftrag_pkey PRIMARY KEY (id);


--
-- Name: benachrichtigung benachrichtigung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benachrichtigung
    ADD CONSTRAINT benachrichtigung_pkey PRIMARY KEY (id);


--
-- Name: benutzer benutzer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benutzer
    ADD CONSTRAINT benutzer_pkey PRIMARY KEY (id);


--
-- Name: deputats_betreuung deputats_betreuung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_betreuung
    ADD CONSTRAINT deputats_betreuung_pkey PRIMARY KEY (id);


--
-- Name: deputats_einstellungen deputats_einstellungen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_einstellungen
    ADD CONSTRAINT deputats_einstellungen_pkey PRIMARY KEY (id);


--
-- Name: deputats_ermaessigung deputats_ermaessigung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_ermaessigung
    ADD CONSTRAINT deputats_ermaessigung_pkey PRIMARY KEY (id);


--
-- Name: deputats_lehrexport deputats_lehrexport_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_lehrexport
    ADD CONSTRAINT deputats_lehrexport_pkey PRIMARY KEY (id);


--
-- Name: deputats_lehrtaetigkeit deputats_lehrtaetigkeit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_lehrtaetigkeit
    ADD CONSTRAINT deputats_lehrtaetigkeit_pkey PRIMARY KEY (id);


--
-- Name: deputats_vertretung deputats_vertretung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_vertretung
    ADD CONSTRAINT deputats_vertretung_pkey PRIMARY KEY (id);


--
-- Name: deputatsabrechnung deputatsabrechnung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputatsabrechnung
    ADD CONSTRAINT deputatsabrechnung_pkey PRIMARY KEY (id);


--
-- Name: dozent dozent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dozent
    ADD CONSTRAINT dozent_pkey PRIMARY KEY (id);


--
-- Name: dozent_position dozent_position_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dozent_position
    ADD CONSTRAINT dozent_position_pkey PRIMARY KEY (id);


--
-- Name: geplante_module geplante_module_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geplante_module
    ADD CONSTRAINT geplante_module_pkey PRIMARY KEY (id);


--
-- Name: lehrform lehrform_bezeichnung_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lehrform
    ADD CONSTRAINT lehrform_bezeichnung_key UNIQUE (bezeichnung);


--
-- Name: lehrform lehrform_kuerzel_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lehrform
    ADD CONSTRAINT lehrform_kuerzel_key UNIQUE (kuerzel);


--
-- Name: lehrform lehrform_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lehrform
    ADD CONSTRAINT lehrform_pkey PRIMARY KEY (id);


--
-- Name: modul_abhÃ¤ngigkeit modul_abhÃ¤ngigkeit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."modul_abhÃ¤ngigkeit"
    ADD CONSTRAINT "modul_abhÃ¤ngigkeit_pkey" PRIMARY KEY (id);


--
-- Name: modul_arbeitsaufwand modul_arbeitsaufwand_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_arbeitsaufwand
    ADD CONSTRAINT modul_arbeitsaufwand_pkey PRIMARY KEY (modul_id, po_id);


--
-- Name: modul_audit_log modul_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_audit_log
    ADD CONSTRAINT modul_audit_log_pkey PRIMARY KEY (id);


--
-- Name: modul_dozent modul_dozent_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent
    ADD CONSTRAINT modul_dozent_pkey PRIMARY KEY (id);


--
-- Name: modul_lehrform modul_lehrform_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lehrform
    ADD CONSTRAINT modul_lehrform_pkey PRIMARY KEY (id);


--
-- Name: modul_lernergebnisse modul_lernergebnisse_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lernergebnisse
    ADD CONSTRAINT modul_lernergebnisse_pkey PRIMARY KEY (modul_id, po_id);


--
-- Name: modul_literatur modul_literatur_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_literatur
    ADD CONSTRAINT modul_literatur_pkey PRIMARY KEY (id);


--
-- Name: modul modul_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul
    ADD CONSTRAINT modul_pkey PRIMARY KEY (id);


--
-- Name: modul_pruefung modul_pruefung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_pruefung
    ADD CONSTRAINT modul_pruefung_pkey PRIMARY KEY (modul_id, po_id);


--
-- Name: modul_seiten modul_seiten_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_seiten
    ADD CONSTRAINT modul_seiten_pkey PRIMARY KEY (modul_id, po_id, modulhandbuch_id);


--
-- Name: modul_sprache modul_sprache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_sprache
    ADD CONSTRAINT modul_sprache_pkey PRIMARY KEY (modul_id, po_id, sprache_id);


--
-- Name: modul_studiengang modul_studiengang_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_studiengang
    ADD CONSTRAINT modul_studiengang_pkey PRIMARY KEY (id);


--
-- Name: modul_voraussetzungen modul_voraussetzungen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_voraussetzungen
    ADD CONSTRAINT modul_voraussetzungen_pkey PRIMARY KEY (modul_id, po_id);


--
-- Name: modulhandbuch modulhandbuch_dateiname_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modulhandbuch
    ADD CONSTRAINT modulhandbuch_dateiname_key UNIQUE (dateiname);


--
-- Name: modulhandbuch modulhandbuch_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modulhandbuch
    ADD CONSTRAINT modulhandbuch_hash_key UNIQUE (hash);


--
-- Name: modulhandbuch modulhandbuch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modulhandbuch
    ADD CONSTRAINT modulhandbuch_pkey PRIMARY KEY (id);


--
-- Name: phase_submissions phase_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions
    ADD CONSTRAINT phase_submissions_pkey PRIMARY KEY (id);


--
-- Name: planungs_templates planungs_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungs_templates
    ADD CONSTRAINT planungs_templates_pkey PRIMARY KEY (id);


--
-- Name: planungsphasen planungsphasen_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungsphasen
    ADD CONSTRAINT planungsphasen_pkey PRIMARY KEY (id);


--
-- Name: pruefungsordnung pruefungsordnung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pruefungsordnung
    ADD CONSTRAINT pruefungsordnung_pkey PRIMARY KEY (id);


--
-- Name: pruefungsordnung pruefungsordnung_po_jahr_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pruefungsordnung
    ADD CONSTRAINT pruefungsordnung_po_jahr_key UNIQUE (po_jahr);


--
-- Name: rolle rolle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rolle
    ADD CONSTRAINT rolle_pkey PRIMARY KEY (id);


--
-- Name: semester_auftrag semester_auftrag_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester_auftrag
    ADD CONSTRAINT semester_auftrag_pkey PRIMARY KEY (id);


--
-- Name: semester semester_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester
    ADD CONSTRAINT semester_pkey PRIMARY KEY (id);


--
-- Name: semesterplanung semesterplanung_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesterplanung
    ADD CONSTRAINT semesterplanung_pkey PRIMARY KEY (id);


--
-- Name: sprache sprache_bezeichnung_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sprache
    ADD CONSTRAINT sprache_bezeichnung_key UNIQUE (bezeichnung);


--
-- Name: sprache sprache_iso_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sprache
    ADD CONSTRAINT sprache_iso_code_key UNIQUE (iso_code);


--
-- Name: sprache sprache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sprache
    ADD CONSTRAINT sprache_pkey PRIMARY KEY (id);


--
-- Name: studiengang studiengang_kuerzel_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studiengang
    ADD CONSTRAINT studiengang_kuerzel_key UNIQUE (kuerzel);


--
-- Name: studiengang studiengang_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.studiengang
    ADD CONSTRAINT studiengang_pkey PRIMARY KEY (id);


--
-- Name: template_module template_module_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_module
    ADD CONSTRAINT template_module_pkey PRIMARY KEY (id);


--
-- Name: phase_submissions unique_professor_phase_approved; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions
    ADD CONSTRAINT unique_professor_phase_approved UNIQUE (planungphase_id, professor_id, status);


--
-- Name: deputatsabrechnung uq_deputat_phase_benutzer; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputatsabrechnung
    ADD CONSTRAINT uq_deputat_phase_benutzer UNIQUE (planungsphase_id, benutzer_id);


--
-- Name: geplante_module uq_planung_modul; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geplante_module
    ADD CONSTRAINT uq_planung_modul UNIQUE (semesterplanung_id, modul_id);


--
-- Name: semesterplanung uq_semester_benutzer_phase; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesterplanung
    ADD CONSTRAINT uq_semester_benutzer_phase UNIQUE (semester_id, benutzer_id, planungsphase_id);


--
-- Name: planungs_templates uq_template_benutzer_semestertyp; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungs_templates
    ADD CONSTRAINT uq_template_benutzer_semestertyp UNIQUE (benutzer_id, semester_typ);


--
-- Name: template_module uq_template_modul; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_module
    ADD CONSTRAINT uq_template_modul UNIQUE (template_id, modul_id);


--
-- Name: wunsch_freie_tage wunsch_freie_tage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wunsch_freie_tage
    ADD CONSTRAINT wunsch_freie_tage_pkey PRIMARY KEY (id);


--
-- Name: idx_benutzer_dozent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_benutzer_dozent_id ON public.benutzer USING btree (dozent_id);


--
-- Name: idx_benutzer_rolle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_benutzer_rolle ON public.benutzer USING btree (rolle_id);


--
-- Name: idx_deputats_betreuung_deputat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deputats_betreuung_deputat ON public.deputats_betreuung USING btree (deputatsabrechnung_id);


--
-- Name: idx_deputats_ermaessigung_deputat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deputats_ermaessigung_deputat ON public.deputats_ermaessigung USING btree (deputatsabrechnung_id);


--
-- Name: idx_deputats_lehrexport_deputat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deputats_lehrexport_deputat ON public.deputats_lehrexport USING btree (deputatsabrechnung_id);


--
-- Name: idx_deputats_lehrtaetigkeit_deputat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deputats_lehrtaetigkeit_deputat ON public.deputats_lehrtaetigkeit USING btree (deputatsabrechnung_id);


--
-- Name: idx_deputats_vertretung_deputat; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deputats_vertretung_deputat ON public.deputats_vertretung USING btree (deputatsabrechnung_id);


--
-- Name: idx_deputatsabrechnung_benutzer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_deputatsabrechnung_benutzer ON public.deputatsabrechnung USING btree (benutzer_id);


--
-- Name: idx_dozent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dozent_name ON public.dozent USING btree (nachname, vorname);


--
-- Name: idx_dozent_position_typ; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dozent_position_typ ON public.dozent_position USING btree (typ);


--
-- Name: idx_modul_arbeitsaufwand_modul; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_arbeitsaufwand_modul ON public.modul_arbeitsaufwand USING btree (modul_id);


--
-- Name: idx_modul_dozent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_dozent ON public.modul_dozent USING btree (modul_id, dozent_id);


--
-- Name: idx_modul_dozent_position; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_dozent_position ON public.modul_dozent USING btree (dozent_position_id);


--
-- Name: idx_modul_dozent_rolle; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_dozent_rolle ON public.modul_dozent USING btree (rolle);


--
-- Name: idx_modul_kuerzel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_kuerzel ON public.modul USING btree (kuerzel);


--
-- Name: idx_modul_lernergebnisse_modul; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_lernergebnisse_modul ON public.modul_lernergebnisse USING btree (modul_id);


--
-- Name: idx_modul_literatur_modul; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_literatur_modul ON public.modul_literatur USING btree (modul_id);


--
-- Name: idx_modul_po; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_po ON public.modul USING btree (po_id);


--
-- Name: idx_modul_pruefung_modul; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_pruefung_modul ON public.modul_pruefung USING btree (modul_id);


--
-- Name: idx_modul_seiten_modulhandbuch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_seiten_modulhandbuch ON public.modul_seiten USING btree (modulhandbuch_id);


--
-- Name: idx_modul_sprache_sprache; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_sprache_sprache ON public.modul_sprache USING btree (sprache_id);


--
-- Name: idx_modul_studiengang; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_studiengang ON public.modul_studiengang USING btree (modul_id, studiengang_id);


--
-- Name: idx_modul_studiengang_kategorie; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_studiengang_kategorie ON public.modul_studiengang USING btree (modul_kategorie);


--
-- Name: idx_modul_studiengang_pflicht; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_studiengang_pflicht ON public.modul_studiengang USING btree (pflicht);


--
-- Name: idx_modul_studiengang_wahlpflicht; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_modul_studiengang_wahlpflicht ON public.modul_studiengang USING btree (wahlpflicht);


--
-- Name: idx_semesterplanung_benutzer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_semesterplanung_benutzer ON public.semesterplanung USING btree (benutzer_id);


--
-- Name: idx_semesterplanung_semester; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_semesterplanung_semester ON public.semesterplanung USING btree (semester_id);


--
-- Name: idx_semesterplanung_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_semesterplanung_status ON public.semesterplanung USING btree (status);


--
-- Name: idx_wunsch_freie_tage_planung; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_wunsch_freie_tage_planung ON public.wunsch_freie_tage USING btree (semesterplanung_id);


--
-- Name: ix_audit_log_aktion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_log_aktion ON public.audit_log USING btree (aktion);


--
-- Name: ix_audit_log_benutzer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_log_benutzer_id ON public.audit_log USING btree (benutzer_id);


--
-- Name: ix_audit_log_timestamp; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_audit_log_timestamp ON public.audit_log USING btree ("timestamp");


--
-- Name: ix_auftrag_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_auftrag_name ON public.auftrag USING btree (name);


--
-- Name: ix_benachrichtigung_empfaenger_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_benachrichtigung_empfaenger_id ON public.benachrichtigung USING btree (empfaenger_id);


--
-- Name: ix_benachrichtigung_gelesen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_benachrichtigung_gelesen ON public.benachrichtigung USING btree (gelesen);


--
-- Name: ix_benutzer_dozent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_benutzer_dozent_id ON public.benutzer USING btree (dozent_id);


--
-- Name: ix_benutzer_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_benutzer_email ON public.benutzer USING btree (email);


--
-- Name: ix_benutzer_rolle_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_benutzer_rolle_id ON public.benutzer USING btree (rolle_id);


--
-- Name: ix_benutzer_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_benutzer_username ON public.benutzer USING btree (username);


--
-- Name: ix_deputat_benutzer_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputat_benutzer_status ON public.deputatsabrechnung USING btree (benutzer_id, status);


--
-- Name: ix_deputat_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputat_status ON public.deputatsabrechnung USING btree (status);


--
-- Name: ix_deputats_betreuung_deputatsabrechnung_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputats_betreuung_deputatsabrechnung_id ON public.deputats_betreuung USING btree (deputatsabrechnung_id);


--
-- Name: ix_deputats_ermaessigung_deputatsabrechnung_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputats_ermaessigung_deputatsabrechnung_id ON public.deputats_ermaessigung USING btree (deputatsabrechnung_id);


--
-- Name: ix_deputats_lehrexport_deputatsabrechnung_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputats_lehrexport_deputatsabrechnung_id ON public.deputats_lehrexport USING btree (deputatsabrechnung_id);


--
-- Name: ix_deputats_lehrtaetigkeit_deputatsabrechnung_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputats_lehrtaetigkeit_deputatsabrechnung_id ON public.deputats_lehrtaetigkeit USING btree (deputatsabrechnung_id);


--
-- Name: ix_deputats_vertretung_deputatsabrechnung_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputats_vertretung_deputatsabrechnung_id ON public.deputats_vertretung USING btree (deputatsabrechnung_id);


--
-- Name: ix_deputatsabrechnung_benutzer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputatsabrechnung_benutzer_id ON public.deputatsabrechnung USING btree (benutzer_id);


--
-- Name: ix_deputatsabrechnung_planungsphase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputatsabrechnung_planungsphase_id ON public.deputatsabrechnung USING btree (planungsphase_id);


--
-- Name: ix_deputatsabrechnung_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_deputatsabrechnung_status ON public.deputatsabrechnung USING btree (status);


--
-- Name: ix_geplante_module_modul_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_geplante_module_modul_id ON public.geplante_module USING btree (modul_id);


--
-- Name: ix_geplante_module_semesterplanung_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_geplante_module_semesterplanung_id ON public.geplante_module USING btree (semesterplanung_id);


--
-- Name: ix_geplantes_modul_planung; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_geplantes_modul_planung ON public.geplante_module USING btree (semesterplanung_id);


--
-- Name: ix_modul_audit_log_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_audit_log_created_at ON public.modul_audit_log USING btree (created_at);


--
-- Name: ix_modul_audit_log_modul_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_audit_log_modul_id ON public.modul_audit_log USING btree (modul_id);


--
-- Name: ix_modul_audit_modul_datum; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_audit_modul_datum ON public.modul_audit_log USING btree (modul_id, created_at);


--
-- Name: ix_modul_dozent_dozent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_dozent_dozent_id ON public.modul_dozent USING btree (dozent_id);


--
-- Name: ix_modul_dozent_modul_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_dozent_modul_id ON public.modul_dozent USING btree (modul_id);


--
-- Name: ix_modul_dozent_vertreter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_dozent_vertreter_id ON public.modul_dozent USING btree (vertreter_id);


--
-- Name: ix_modul_dozent_zweitpruefer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_dozent_zweitpruefer_id ON public.modul_dozent USING btree (zweitpruefer_id);


--
-- Name: ix_modul_kuerzel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_kuerzel ON public.modul USING btree (kuerzel);


--
-- Name: ix_modul_lehrform_modul_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_lehrform_modul_id ON public.modul_lehrform USING btree (modul_id);


--
-- Name: ix_modul_po_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_po_id ON public.modul USING btree (po_id);


--
-- Name: ix_modul_studiengang_modul_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_studiengang_modul_id ON public.modul_studiengang USING btree (modul_id);


--
-- Name: ix_modul_studiengang_studiengang_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_modul_studiengang_studiengang_id ON public.modul_studiengang USING btree (studiengang_id);


--
-- Name: ix_planungs_templates_benutzer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_planungs_templates_benutzer_id ON public.planungs_templates USING btree (benutzer_id);


--
-- Name: ix_planungs_templates_semester_typ; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_planungs_templates_semester_typ ON public.planungs_templates USING btree (semester_typ);


--
-- Name: ix_rolle_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_rolle_name ON public.rolle USING btree (name);


--
-- Name: ix_semester_auftrag_auftrag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_auftrag_auftrag_id ON public.semester_auftrag USING btree (auftrag_id);


--
-- Name: ix_semester_auftrag_dozent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_auftrag_dozent ON public.semester_auftrag USING btree (dozent_id);


--
-- Name: ix_semester_auftrag_dozent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_auftrag_dozent_id ON public.semester_auftrag USING btree (dozent_id);


--
-- Name: ix_semester_auftrag_semester; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_auftrag_semester ON public.semester_auftrag USING btree (semester_id);


--
-- Name: ix_semester_auftrag_semester_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_auftrag_semester_id ON public.semester_auftrag USING btree (semester_id);


--
-- Name: ix_semester_auftrag_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_auftrag_status ON public.semester_auftrag USING btree (status);


--
-- Name: ix_semester_auftrag_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_semester_auftrag_unique ON public.semester_auftrag USING btree (semester_id, auftrag_id, dozent_id);


--
-- Name: ix_semester_ist_aktiv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_ist_aktiv ON public.semester USING btree (ist_aktiv);


--
-- Name: ix_semester_ist_planungsphase; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semester_ist_planungsphase ON public.semester USING btree (ist_planungsphase);


--
-- Name: ix_semester_kuerzel; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_semester_kuerzel ON public.semester USING btree (kuerzel);


--
-- Name: ix_semesterplanung_benutzer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semesterplanung_benutzer_id ON public.semesterplanung USING btree (benutzer_id);


--
-- Name: ix_semesterplanung_benutzer_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semesterplanung_benutzer_status ON public.semesterplanung USING btree (benutzer_id, status);


--
-- Name: ix_semesterplanung_planungsphase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semesterplanung_planungsphase_id ON public.semesterplanung USING btree (planungsphase_id);


--
-- Name: ix_semesterplanung_semester_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semesterplanung_semester_id ON public.semesterplanung USING btree (semester_id);


--
-- Name: ix_semesterplanung_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semesterplanung_status ON public.semesterplanung USING btree (status);


--
-- Name: ix_semesterplanung_status_semester; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_semesterplanung_status_semester ON public.semesterplanung USING btree (status, semester_id);


--
-- Name: ix_template_benutzer_aktiv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_template_benutzer_aktiv ON public.planungs_templates USING btree (benutzer_id, ist_aktiv);


--
-- Name: ix_template_modul_template; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_template_modul_template ON public.template_module USING btree (template_id);


--
-- Name: ix_template_module_modul_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_template_module_modul_id ON public.template_module USING btree (modul_id);


--
-- Name: ix_template_module_template_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_template_module_template_id ON public.template_module USING btree (template_id);


--
-- Name: ix_wunsch_freie_tage_semesterplanung_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_wunsch_freie_tage_semesterplanung_id ON public.wunsch_freie_tage USING btree (semesterplanung_id);


--
-- Name: archivierte_planungen archivierte_planungen_archiviert_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivierte_planungen
    ADD CONSTRAINT archivierte_planungen_archiviert_von_fkey FOREIGN KEY (archiviert_von) REFERENCES public.benutzer(id);


--
-- Name: archivierte_planungen archivierte_planungen_planungphase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivierte_planungen
    ADD CONSTRAINT archivierte_planungen_planungphase_id_fkey FOREIGN KEY (planungphase_id) REFERENCES public.planungsphasen(id);


--
-- Name: archivierte_planungen archivierte_planungen_professor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivierte_planungen
    ADD CONSTRAINT archivierte_planungen_professor_id_fkey FOREIGN KEY (professor_id) REFERENCES public.benutzer(id);


--
-- Name: archivierte_planungen archivierte_planungen_semester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.archivierte_planungen
    ADD CONSTRAINT archivierte_planungen_semester_id_fkey FOREIGN KEY (semester_id) REFERENCES public.semester(id);


--
-- Name: audit_log audit_log_benutzer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_benutzer_id_fkey FOREIGN KEY (benutzer_id) REFERENCES public.benutzer(id) ON DELETE SET NULL;


--
-- Name: benachrichtigung benachrichtigung_empfaenger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benachrichtigung
    ADD CONSTRAINT benachrichtigung_empfaenger_id_fkey FOREIGN KEY (empfaenger_id) REFERENCES public.benutzer(id) ON DELETE CASCADE;


--
-- Name: benutzer benutzer_dozent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benutzer
    ADD CONSTRAINT benutzer_dozent_id_fkey FOREIGN KEY (dozent_id) REFERENCES public.dozent(id) ON DELETE SET NULL;


--
-- Name: benutzer benutzer_rolle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.benutzer
    ADD CONSTRAINT benutzer_rolle_id_fkey FOREIGN KEY (rolle_id) REFERENCES public.rolle(id) ON DELETE RESTRICT;


--
-- Name: deputats_betreuung deputats_betreuung_deputatsabrechnung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_betreuung
    ADD CONSTRAINT deputats_betreuung_deputatsabrechnung_id_fkey FOREIGN KEY (deputatsabrechnung_id) REFERENCES public.deputatsabrechnung(id) ON DELETE CASCADE;


--
-- Name: deputats_einstellungen deputats_einstellungen_erstellt_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_einstellungen
    ADD CONSTRAINT deputats_einstellungen_erstellt_von_fkey FOREIGN KEY (erstellt_von) REFERENCES public.benutzer(id) ON DELETE SET NULL;


--
-- Name: deputats_ermaessigung deputats_ermaessigung_deputatsabrechnung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_ermaessigung
    ADD CONSTRAINT deputats_ermaessigung_deputatsabrechnung_id_fkey FOREIGN KEY (deputatsabrechnung_id) REFERENCES public.deputatsabrechnung(id) ON DELETE CASCADE;


--
-- Name: deputats_ermaessigung deputats_ermaessigung_semester_auftrag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_ermaessigung
    ADD CONSTRAINT deputats_ermaessigung_semester_auftrag_id_fkey FOREIGN KEY (semester_auftrag_id) REFERENCES public.semester_auftrag(id) ON DELETE SET NULL;


--
-- Name: deputats_lehrexport deputats_lehrexport_deputatsabrechnung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_lehrexport
    ADD CONSTRAINT deputats_lehrexport_deputatsabrechnung_id_fkey FOREIGN KEY (deputatsabrechnung_id) REFERENCES public.deputatsabrechnung(id) ON DELETE CASCADE;


--
-- Name: deputats_lehrtaetigkeit deputats_lehrtaetigkeit_deputatsabrechnung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_lehrtaetigkeit
    ADD CONSTRAINT deputats_lehrtaetigkeit_deputatsabrechnung_id_fkey FOREIGN KEY (deputatsabrechnung_id) REFERENCES public.deputatsabrechnung(id) ON DELETE CASCADE;


--
-- Name: deputats_lehrtaetigkeit deputats_lehrtaetigkeit_geplantes_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_lehrtaetigkeit
    ADD CONSTRAINT deputats_lehrtaetigkeit_geplantes_modul_id_fkey FOREIGN KEY (geplantes_modul_id) REFERENCES public.geplante_module(id) ON DELETE SET NULL;


--
-- Name: deputats_vertretung deputats_vertretung_deputatsabrechnung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputats_vertretung
    ADD CONSTRAINT deputats_vertretung_deputatsabrechnung_id_fkey FOREIGN KEY (deputatsabrechnung_id) REFERENCES public.deputatsabrechnung(id) ON DELETE CASCADE;


--
-- Name: deputatsabrechnung deputatsabrechnung_benutzer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputatsabrechnung
    ADD CONSTRAINT deputatsabrechnung_benutzer_id_fkey FOREIGN KEY (benutzer_id) REFERENCES public.benutzer(id) ON DELETE CASCADE;


--
-- Name: deputatsabrechnung deputatsabrechnung_genehmigt_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputatsabrechnung
    ADD CONSTRAINT deputatsabrechnung_genehmigt_von_fkey FOREIGN KEY (genehmigt_von) REFERENCES public.benutzer(id) ON DELETE SET NULL;


--
-- Name: deputatsabrechnung deputatsabrechnung_planungsphase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deputatsabrechnung
    ADD CONSTRAINT deputatsabrechnung_planungsphase_id_fkey FOREIGN KEY (planungsphase_id) REFERENCES public.planungsphasen(id) ON DELETE CASCADE;


--
-- Name: geplante_module geplante_module_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geplante_module
    ADD CONSTRAINT geplante_module_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: geplante_module geplante_module_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geplante_module
    ADD CONSTRAINT geplante_module_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: geplante_module geplante_module_semesterplanung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.geplante_module
    ADD CONSTRAINT geplante_module_semesterplanung_id_fkey FOREIGN KEY (semesterplanung_id) REFERENCES public.semesterplanung(id) ON DELETE CASCADE;


--
-- Name: modul_abhÃ¤ngigkeit modul_abhÃ¤ngigkeit_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."modul_abhÃ¤ngigkeit"
    ADD CONSTRAINT "modul_abhÃ¤ngigkeit_modul_id_fkey" FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_abhÃ¤ngigkeit modul_abhÃ¤ngigkeit_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."modul_abhÃ¤ngigkeit"
    ADD CONSTRAINT "modul_abhÃ¤ngigkeit_po_id_fkey" FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_abhÃ¤ngigkeit modul_abhÃ¤ngigkeit_voraussetzung_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."modul_abhÃ¤ngigkeit"
    ADD CONSTRAINT "modul_abhÃ¤ngigkeit_voraussetzung_modul_id_fkey" FOREIGN KEY (voraussetzung_modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_arbeitsaufwand modul_arbeitsaufwand_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_arbeitsaufwand
    ADD CONSTRAINT modul_arbeitsaufwand_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_arbeitsaufwand modul_arbeitsaufwand_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_arbeitsaufwand
    ADD CONSTRAINT modul_arbeitsaufwand_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_audit_log modul_audit_log_alt_dozent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_audit_log
    ADD CONSTRAINT modul_audit_log_alt_dozent_id_fkey FOREIGN KEY (alt_dozent_id) REFERENCES public.dozent(id) ON DELETE SET NULL;


--
-- Name: modul_audit_log modul_audit_log_geaendert_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_audit_log
    ADD CONSTRAINT modul_audit_log_geaendert_von_fkey FOREIGN KEY (geaendert_von) REFERENCES public.benutzer(id) ON DELETE SET NULL;


--
-- Name: modul_audit_log modul_audit_log_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_audit_log
    ADD CONSTRAINT modul_audit_log_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_audit_log modul_audit_log_neu_dozent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_audit_log
    ADD CONSTRAINT modul_audit_log_neu_dozent_id_fkey FOREIGN KEY (neu_dozent_id) REFERENCES public.dozent(id) ON DELETE SET NULL;


--
-- Name: modul_audit_log modul_audit_log_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_audit_log
    ADD CONSTRAINT modul_audit_log_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_dozent modul_dozent_dozent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent
    ADD CONSTRAINT modul_dozent_dozent_id_fkey FOREIGN KEY (dozent_id) REFERENCES public.dozent(id) ON DELETE CASCADE;


--
-- Name: modul_dozent modul_dozent_dozent_position_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent
    ADD CONSTRAINT modul_dozent_dozent_position_id_fkey FOREIGN KEY (dozent_position_id) REFERENCES public.dozent_position(id) ON DELETE SET NULL;


--
-- Name: modul_dozent modul_dozent_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent
    ADD CONSTRAINT modul_dozent_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_dozent modul_dozent_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent
    ADD CONSTRAINT modul_dozent_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_dozent modul_dozent_vertreter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent
    ADD CONSTRAINT modul_dozent_vertreter_id_fkey FOREIGN KEY (vertreter_id) REFERENCES public.dozent(id) ON DELETE SET NULL;


--
-- Name: modul_dozent modul_dozent_zweitpruefer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_dozent
    ADD CONSTRAINT modul_dozent_zweitpruefer_id_fkey FOREIGN KEY (zweitpruefer_id) REFERENCES public.dozent(id) ON DELETE SET NULL;


--
-- Name: modul_lehrform modul_lehrform_lehrform_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lehrform
    ADD CONSTRAINT modul_lehrform_lehrform_id_fkey FOREIGN KEY (lehrform_id) REFERENCES public.lehrform(id) ON DELETE CASCADE;


--
-- Name: modul_lehrform modul_lehrform_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lehrform
    ADD CONSTRAINT modul_lehrform_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_lehrform modul_lehrform_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lehrform
    ADD CONSTRAINT modul_lehrform_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_lernergebnisse modul_lernergebnisse_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lernergebnisse
    ADD CONSTRAINT modul_lernergebnisse_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_lernergebnisse modul_lernergebnisse_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_lernergebnisse
    ADD CONSTRAINT modul_lernergebnisse_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_literatur modul_literatur_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_literatur
    ADD CONSTRAINT modul_literatur_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_literatur modul_literatur_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_literatur
    ADD CONSTRAINT modul_literatur_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul modul_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul
    ADD CONSTRAINT modul_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_pruefung modul_pruefung_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_pruefung
    ADD CONSTRAINT modul_pruefung_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_pruefung modul_pruefung_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_pruefung
    ADD CONSTRAINT modul_pruefung_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_seiten modul_seiten_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_seiten
    ADD CONSTRAINT modul_seiten_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_seiten modul_seiten_modulhandbuch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_seiten
    ADD CONSTRAINT modul_seiten_modulhandbuch_id_fkey FOREIGN KEY (modulhandbuch_id) REFERENCES public.modulhandbuch(id) ON DELETE CASCADE;


--
-- Name: modul_seiten modul_seiten_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_seiten
    ADD CONSTRAINT modul_seiten_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_sprache modul_sprache_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_sprache
    ADD CONSTRAINT modul_sprache_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_sprache modul_sprache_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_sprache
    ADD CONSTRAINT modul_sprache_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_sprache modul_sprache_sprache_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_sprache
    ADD CONSTRAINT modul_sprache_sprache_id_fkey FOREIGN KEY (sprache_id) REFERENCES public.sprache(id) ON DELETE CASCADE;


--
-- Name: modul_studiengang modul_studiengang_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_studiengang
    ADD CONSTRAINT modul_studiengang_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_studiengang modul_studiengang_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_studiengang
    ADD CONSTRAINT modul_studiengang_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modul_studiengang modul_studiengang_studiengang_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_studiengang
    ADD CONSTRAINT modul_studiengang_studiengang_id_fkey FOREIGN KEY (studiengang_id) REFERENCES public.studiengang(id) ON DELETE CASCADE;


--
-- Name: modul_voraussetzungen modul_voraussetzungen_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_voraussetzungen
    ADD CONSTRAINT modul_voraussetzungen_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: modul_voraussetzungen modul_voraussetzungen_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modul_voraussetzungen
    ADD CONSTRAINT modul_voraussetzungen_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modulhandbuch modulhandbuch_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modulhandbuch
    ADD CONSTRAINT modulhandbuch_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: modulhandbuch modulhandbuch_studiengang_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.modulhandbuch
    ADD CONSTRAINT modulhandbuch_studiengang_id_fkey FOREIGN KEY (studiengang_id) REFERENCES public.studiengang(id) ON DELETE SET NULL;


--
-- Name: phase_submissions phase_submissions_abgelehnt_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions
    ADD CONSTRAINT phase_submissions_abgelehnt_von_fkey FOREIGN KEY (abgelehnt_von) REFERENCES public.benutzer(id);


--
-- Name: phase_submissions phase_submissions_freigegeben_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions
    ADD CONSTRAINT phase_submissions_freigegeben_von_fkey FOREIGN KEY (freigegeben_von) REFERENCES public.benutzer(id);


--
-- Name: phase_submissions phase_submissions_planung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions
    ADD CONSTRAINT phase_submissions_planung_id_fkey FOREIGN KEY (planung_id) REFERENCES public.semesterplanung(id) ON DELETE CASCADE;


--
-- Name: phase_submissions phase_submissions_planungphase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions
    ADD CONSTRAINT phase_submissions_planungphase_id_fkey FOREIGN KEY (planungphase_id) REFERENCES public.planungsphasen(id) ON DELETE CASCADE;


--
-- Name: phase_submissions phase_submissions_professor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.phase_submissions
    ADD CONSTRAINT phase_submissions_professor_id_fkey FOREIGN KEY (professor_id) REFERENCES public.benutzer(id);


--
-- Name: planungs_templates planungs_templates_benutzer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungs_templates
    ADD CONSTRAINT planungs_templates_benutzer_id_fkey FOREIGN KEY (benutzer_id) REFERENCES public.benutzer(id) ON DELETE CASCADE;


--
-- Name: planungsphasen planungsphasen_geschlossen_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungsphasen
    ADD CONSTRAINT planungsphasen_geschlossen_von_fkey FOREIGN KEY (geschlossen_von) REFERENCES public.benutzer(id);


--
-- Name: planungsphasen planungsphasen_semester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.planungsphasen
    ADD CONSTRAINT planungsphasen_semester_id_fkey FOREIGN KEY (semester_id) REFERENCES public.semester(id) ON DELETE CASCADE;


--
-- Name: semester_auftrag semester_auftrag_auftrag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester_auftrag
    ADD CONSTRAINT semester_auftrag_auftrag_id_fkey FOREIGN KEY (auftrag_id) REFERENCES public.auftrag(id) ON DELETE CASCADE;


--
-- Name: semester_auftrag semester_auftrag_beantragt_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester_auftrag
    ADD CONSTRAINT semester_auftrag_beantragt_von_fkey FOREIGN KEY (beantragt_von) REFERENCES public.benutzer(id) ON DELETE SET NULL;


--
-- Name: semester_auftrag semester_auftrag_dozent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester_auftrag
    ADD CONSTRAINT semester_auftrag_dozent_id_fkey FOREIGN KEY (dozent_id) REFERENCES public.dozent(id) ON DELETE CASCADE;


--
-- Name: semester_auftrag semester_auftrag_genehmigt_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester_auftrag
    ADD CONSTRAINT semester_auftrag_genehmigt_von_fkey FOREIGN KEY (genehmigt_von) REFERENCES public.benutzer(id) ON DELETE SET NULL;


--
-- Name: semester_auftrag semester_auftrag_semester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semester_auftrag
    ADD CONSTRAINT semester_auftrag_semester_id_fkey FOREIGN KEY (semester_id) REFERENCES public.semester(id) ON DELETE CASCADE;


--
-- Name: semesterplanung semesterplanung_benutzer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesterplanung
    ADD CONSTRAINT semesterplanung_benutzer_id_fkey FOREIGN KEY (benutzer_id) REFERENCES public.benutzer(id) ON DELETE CASCADE;


--
-- Name: semesterplanung semesterplanung_freigegeben_von_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesterplanung
    ADD CONSTRAINT semesterplanung_freigegeben_von_fkey FOREIGN KEY (freigegeben_von) REFERENCES public.benutzer(id) ON DELETE SET NULL;


--
-- Name: semesterplanung semesterplanung_planungsphase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesterplanung
    ADD CONSTRAINT semesterplanung_planungsphase_id_fkey FOREIGN KEY (planungsphase_id) REFERENCES public.planungsphasen(id) ON DELETE SET NULL;


--
-- Name: semesterplanung semesterplanung_semester_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.semesterplanung
    ADD CONSTRAINT semesterplanung_semester_id_fkey FOREIGN KEY (semester_id) REFERENCES public.semester(id) ON DELETE CASCADE;


--
-- Name: template_module template_module_modul_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_module
    ADD CONSTRAINT template_module_modul_id_fkey FOREIGN KEY (modul_id) REFERENCES public.modul(id) ON DELETE CASCADE;


--
-- Name: template_module template_module_po_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_module
    ADD CONSTRAINT template_module_po_id_fkey FOREIGN KEY (po_id) REFERENCES public.pruefungsordnung(id) ON DELETE CASCADE;


--
-- Name: template_module template_module_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.template_module
    ADD CONSTRAINT template_module_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.planungs_templates(id) ON DELETE CASCADE;


--
-- Name: wunsch_freie_tage wunsch_freie_tage_semesterplanung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wunsch_freie_tage
    ADD CONSTRAINT wunsch_freie_tage_semesterplanung_id_fkey FOREIGN KEY (semesterplanung_id) REFERENCES public.semesterplanung(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--


