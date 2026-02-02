--
-- PostgreSQL database dump
--

\restrict EMb6YYzpO75uASwOrIDNA6ejgasuGU7w1cohKLapX0nf9aNsRJP7sLgXvcP2Quj

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

COPY public.archivierte_planungen (original_planung_id, planungphase_id, professor_id, professor_name, semester_id, semester_name, phase_name, status_bei_archivierung, archiviert_am, archiviert_grund, archiviert_von, planung_daten, id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_log (id, benutzer_id, aktion, tabelle, datensatz_id, alte_werte, neue_werte, ip_adresse, "timestamp") FROM stdin;
\.


--
-- Data for Name: auftrag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auftrag (id, name, beschreibung, standard_sws, ist_aktiv, sortierung, created_at, updated_at) FROM stdin;
1	Eventmanagement	Koordination von Veranstaltungen und Events	0.5	t	1	2025-11-25 21:37:48	2025-11-25 21:37:48
2	Auslandsbeauftragter 1	Betreuung internationaler Studierender	0.5	t	2	2025-11-25 21:37:48	2025-11-25 21:37:48
3	Auslandsbeauftragter 2	Betreuung internationaler Studierender	0.5	t	3	2025-11-25 21:37:48	2025-11-25 21:37:48
4	BAföG	BAföG-Beratung und -Verwaltung	0	t	4	2025-11-25 21:37:48	2025-11-25 21:37:48
5	Datensicherheit und Netzwerk	IT-Sicherheit und Netzwerkverwaltung	0	t	5	2025-11-25 21:37:48	2025-11-25 21:37:48
6	Dekanin	Leitung des Fachbereichs	5	t	6	2025-11-25 21:37:48	2025-11-25 21:37:48
7	Digitalisierung	Digitalisierungsbeauftragter	0.5	t	7	2025-11-25 21:37:48	2025-11-25 21:37:48
8	Marketing	Marketing und Öffentlichkeitsarbeit	2	t	8	2025-11-25 21:37:48	2025-11-25 21:37:48
9	Evaluation	Qualitätssicherung und Evaluation	0	t	9	2025-11-25 21:37:48	2025-11-25 21:37:48
10	Gleichstellung	Gleichstellungsbeauftragte/r	0	t	10	2025-11-25 21:37:48	2025-11-25 21:37:48
11	Prodekan	Stellvertretung der Dekanin	4.5	t	11	2025-11-25 21:37:48	2025-11-25 21:37:48
12	Sicherheit	Sicherheitsbeauftragter	0	t	12	2025-11-25 21:37:48	2025-11-25 21:37:48
13	Studienberatung Frauen	Studienberatung speziell für Studentinnen	0	t	13	2025-11-25 21:37:48	2025-11-25 21:37:48
14	Studiengangsbeauftragter IS	Studiengangsleitung Informationssysteme	0.5	t	14	2025-11-25 21:37:48	2025-11-25 21:37:48
15	Studiengangsbeauftragter ID	Studiengangsleitung Interaction Design	0.5	t	15	2025-11-25 21:37:48	2025-11-25 21:37:48
16	Studiengangsbeauftragter Inf 1	Studiengangsleitung Informatik 1	0.5	t	16	2025-11-25 21:37:48	2025-11-25 21:37:48
17	Studiengangsbeauftragter Inf 2	Studiengangsleitung Informatik 2	0	t	17	2025-11-25 21:37:48	2025-11-25 21:37:48
18	Studiengangsbeauftragter WI	Studiengangsleitung Wirtschaftsinformatik	0.5	t	18	2025-11-25 21:37:48	2025-11-25 21:37:48
19	Stundenplanerstellung	Erstellung und Verwaltung des Stundenplans	1	t	19	2025-11-25 21:37:48	2025-11-25 21:37:48
20	Prüfungsausschuss	Mitglied im Prüfungsausschuss	2	t	20	2025-11-25 21:37:48	2025-11-25 21:37:48
\.


--
-- Data for Name: benachrichtigung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.benachrichtigung (id, empfaenger_id, typ, titel, nachricht, gelesen, erstellt_am, gelesen_am) FROM stdin;
70	39	planung_eingereicht	Planung für WS2026 eingereicht	Ihre Semesterplanung für WS2026 wurde eingereicht und wartet auf Freigabe.	f	2026-02-01 22:36:59.188053	\N
74	1	planung_eingereicht	Neue Planung von Wolfram Conen	Wolfram Conen hat eine Semesterplanung für WS2026 eingereicht.	f	2026-02-02 01:38:55.776931	\N
71	1	planung_eingereicht	Neue Planung von Leif Meier	Leif Meier hat eine Semesterplanung für WS2026 eingereicht.	f	2026-02-01 22:36:59.323813	\N
72	39	planung_freigegeben	Planung für WS2026 freigegeben	Ihre Semesterplanung für WS2026 wurde freigegeben.	f	2026-02-01 22:37:18.974834	\N
1	1	system	Willkommen!	Willkommen im Dekanat-System!	t	2025-10-27 18:09:59.526396	2025-10-27 18:27:52.401378
2	1	planung_eingereicht	Neue Planung eingereicht	Prof. Müller hat eine Semesterplanung für WS2025 eingereicht.	f	2025-10-27 18:09:59.526415	\N
3	1	erinnerung	Erinnerung	Bitte überprüfen Sie die offenen Planungen.	f	2025-10-27 18:09:59.526417	\N
4	54	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-01 17:58:43.397081	\N
5	1	planung_eingereicht	Neue Planung von Test Professor	Test Professor hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-01 17:58:43.429391	\N
6	54	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-01 18:37:44.259939	\N
7	10	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-06 22:38:33.606858	\N
8	1	planung_eingereicht	Neue Planung von Prof. Dr. Wolfram Conen	Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-06 22:38:33.622845	\N
9	10	planung_abgelehnt	Planung für WS2025 abgelehnt	Ihre Semesterplanung für WS2025 wurde abgelehnt.\n\nGrund: nicht vollständig 	f	2025-11-06 22:39:03.980706	\N
10	31	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-06 22:45:04.31436	\N
11	1	planung_eingereicht	Neue Planung von Prof. Dr. Marcel Luis	Prof. Dr. Marcel Luis hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-06 22:45:04.331151	\N
12	7	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-06 23:03:07.353331	\N
13	1	planung_eingereicht	Neue Planung von Prof. Katja Becker	Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-06 23:03:07.368329	\N
14	32	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-06 23:19:35.71695	\N
15	1	planung_eingereicht	Neue Planung von Prof. Dr. Gregor Lux	Prof. Dr. Gregor Lux hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-06 23:19:35.729788	\N
16	7	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-06 23:45:19.781308	\N
17	32	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-06 23:45:21.928995	\N
18	11	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-07 10:13:56.375316	\N
19	1	planung_eingereicht	Neue Planung von Prof. Dr. Andreas Cramer	Prof. Dr. Andreas Cramer hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-07 10:13:56.41786	\N
20	39	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-12 11:46:15.017429	\N
21	1	planung_eingereicht	Neue Planung von Prof. Dr. Leif Meier	Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-12 11:46:15.032444	\N
22	39	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-12 11:46:30.826709	\N
23	7	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-12 14:32:48.693028	\N
24	1	planung_eingereicht	Neue Planung von Prof. Katja Becker	Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-12 14:32:48.719031	\N
25	7	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-12 14:32:57.560901	\N
26	10	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-12 15:15:50.361519	\N
27	1	planung_eingereicht	Neue Planung von Prof. Dr. Wolfram Conen	Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-12 15:15:50.373524	\N
28	10	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-12 15:15:56.651997	\N
29	9	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-14 13:33:20.920717	\N
30	1	planung_eingereicht	Neue Planung von Prof. Dr. Sebastian Büttner	Prof. Dr. Sebastian Büttner hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-14 13:33:20.935821	\N
31	9	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-14 13:33:31.988878	\N
32	9	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-14 14:20:48.015605	\N
33	1	planung_eingereicht	Neue Planung von Prof. Dr. Sebastian Büttner	Prof. Dr. Sebastian Büttner hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-14 14:20:48.03361	\N
34	7	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-14 14:21:34.78122	\N
35	1	planung_eingereicht	Neue Planung von Prof. Katja Becker	Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-14 14:21:34.817586	\N
36	7	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-14 14:22:13.095988	\N
37	9	planung_abgelehnt	Planung für WS2025 abgelehnt	Ihre Semesterplanung für WS2025 wurde abgelehnt.\n\nGrund: nein	f	2025-11-14 14:22:19.296461	\N
38	7	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-14 14:40:15.791664	\N
39	1	planung_eingereicht	Neue Planung von Prof. Katja Becker	Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-14 14:40:15.80368	\N
40	7	planung_abgelehnt	Planung für WS2025 abgelehnt	Ihre Semesterplanung für WS2025 wurde abgelehnt.\n\nGrund: so	f	2025-11-14 14:41:21.251568	\N
41	7	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-14 15:00:31.473604	\N
42	1	planung_eingereicht	Neue Planung von Prof. Katja Becker	Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-14 15:00:31.487603	\N
43	7	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-14 15:15:16.991884	\N
44	10	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-14 15:19:58.833029	\N
45	1	planung_eingereicht	Neue Planung von Prof. Dr. Wolfram Conen	Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-14 15:19:58.846012	\N
46	10	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-14 15:20:16.608547	\N
47	52	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-14 15:38:28.17199	\N
48	1	planung_eingereicht	Neue Planung von Prof. Dr. Katja Zeume	Prof. Dr. Katja Zeume hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-14 15:38:28.188004	\N
49	52	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-14 15:38:35.373799	\N
50	39	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-19 09:55:36.097305	\N
51	1	planung_eingereicht	Neue Planung von Prof. Dr. Leif Meier	Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-19 09:55:36.128014	\N
52	39	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-19 09:56:54.695282	\N
53	7	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-25 22:39:03.867759	\N
54	1	planung_eingereicht	Neue Planung von Prof. Katja Becker	Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-25 22:39:03.889986	\N
55	7	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-11-25 22:55:21.745478	\N
56	7	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-25 23:00:59.706166	\N
57	1	planung_eingereicht	Neue Planung von Prof. Katja Becker	Prof. Katja Becker hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-25 23:00:59.72715	\N
58	39	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-11-25 23:46:39.173121	\N
59	1	planung_eingereicht	Neue Planung von Prof. Dr. Leif Meier	Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.	f	2025-11-25 23:46:39.193128	\N
60	10	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-12-02 09:18:38.172094	\N
61	1	planung_eingereicht	Neue Planung von Prof. Dr. Wolfram Conen	Prof. Dr. Wolfram Conen hat eine Semesterplanung für WS2025 eingereicht.	f	2025-12-02 09:18:38.190203	\N
62	10	planung_freigegeben	Planung für WS2025 freigegeben	Ihre Semesterplanung für WS2025 wurde freigegeben.	f	2025-12-02 09:19:29.135856	\N
63	9	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-12-05 01:32:31.486833	\N
64	1	planung_eingereicht	Neue Planung von Prof. Dr. Sebastian Büttner	Prof. Dr. Sebastian Büttner hat eine Semesterplanung für WS2025 eingereicht.	f	2025-12-05 01:32:31.500833	\N
65	52	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-12-05 08:44:49.495372	\N
66	1	planung_eingereicht	Neue Planung von Prof. Dr. Katja Zeume	Prof. Dr. Katja Zeume hat eine Semesterplanung für WS2025 eingereicht.	f	2025-12-05 08:44:49.52243	\N
67	39	planung_eingereicht	Planung für WS2025 eingereicht	Ihre Semesterplanung für WS2025 wurde eingereicht und wartet auf Freigabe.	f	2025-12-05 09:36:33.070845	\N
68	1	planung_eingereicht	Neue Planung von Prof. Dr. Leif Meier	Prof. Dr. Leif Meier hat eine Semesterplanung für WS2025 eingereicht.	f	2025-12-05 09:36:33.098852	\N
69	39	planung_abgelehnt	Planung für WS2025 abgelehnt	Ihre Semesterplanung für WS2025 wurde abgelehnt.\n\nGrund: test	f	2026-01-21 07:28:18.583869	\N
73	10	planung_eingereicht	Planung für WS2026 eingereicht	Ihre Semesterplanung für WS2026 wurde eingereicht und wartet auf Freigabe.	f	2026-02-02 01:38:55.692805	\N
\.


--
-- Data for Name: benutzer; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.benutzer (id, email, username, password_hash, rolle_id, dozent_id, vorname, nachname, aktiv, letzter_login, created_at, updated_at) FROM stdin;
2	alexanderkoch.lehrbeauftragter@w-hs.de	alexanderkoch.(lehrbeauftragte/r)	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	27	Alexander Koch	(Lehrbeauftragte/r)	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
3	n.n..(lehrbeauftragter)@hochschule.de	n.n..(lehrbeauftragter)	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	18	N.N.	(Lehrbeauftragter)	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
4	n.n..3d@hochschule.de	n.n..3d	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	19	N.N.	3D	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
5	henning.ahlf@w-hs.de	henning.ahlf	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	32	Henning	Ahlf	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
6	laura.anderle@w-hs.de	laura.anderle	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	11	Laura	Anderle	t	2025-11-06 23:20:33.736654	2025-10-15 14:45:51	2025-11-06 23:20:33.737654
7	katja.becker@w-hs.de	katja.becker	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	2	Katja	Becker	t	2025-12-04 14:44:31.99056	2025-10-15 14:45:51	2025-12-04 14:44:31.991558
8	ingsebastian.buettner@w-hs.de	-ing.sebastian.buettner	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	28	-Ing. Sebastian	Büttner	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
9	sebastian.buettner@w-hs.de	sebastian.buettner	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	5	Sebastian	Büttner	t	2025-12-05 01:16:18.884884	2025-10-15 14:45:51	2025-12-05 01:16:18.885902
11	andreas.cramer@w-hs.de	andreas.cramer	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	21	Andreas	Cramer	t	2025-11-07 09:56:16.995045	2025-10-15 14:45:51	2025-11-07 09:56:16.996046
12	lehrendedesstudiengangsinformatikund.design@hochschule.de	lehrendedesstudiengangsinformatikund.design	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	3	Lehrende des Studiengangs Informatik und	Design	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
13	studiengangsbeauftrage/rinformatikund.design@hochschule.de	studiengangsbeauftrage/rinformatikund.design	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	4	Studiengangsbeauftrage/r Informatik und	Design	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
14	studiengangsbeauftragte/rinformatikund.design@hochschule.de	studiengangsbeauftragte/rinformatikund.design	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	10	Studiengangsbeauftragte/r Informatik und	Design	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
15	christian.dietrich@w-hs.de	christian.dietrich	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	30	Christian	Dietrich	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
16	alleprofessorinnenprofessorender.fachgruppe@hochschule.de	alleprofessorinnenprofessorender.fachgruppe	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	50	Alle Professorinnen Professoren der	Fachgruppe	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
17	alleprofessorinnenundprofessorender.fachgruppe@hochschule.de	alleprofessorinnenundprofessorender.fachgruppe	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	13	Alle Professorinnen und Professoren der	Fachgruppe	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
18	volker.goerick@hochschule.de	volker.goerick	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	37	Volker	Goerick	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
19	ulrike.griefahn@w-hs.de	ulrike.griefahn	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	23	Ulrike	Griefahn	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
20	dieter.hannemann@w-hs.de	dieter.hannemann	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	40	Dieter	Hannemann	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
21	alleprofessorenderfachgruppe.informatik@hochschule.de	alleprofessorenderfachgruppe.informatik	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	38	Alle Professoren der Fachgruppe	Informatik	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
22	studiengangsbeauftragte/r.informatik@hochschule.de	studiengangsbeauftragte/r.informatik	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	20	Studiengangsbeauftragte/r	Informatik	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
23	alleprofessorendesmaster-studiengangs.internet-@hochschule.de	alleprofessorendesmaster-studiengangs.internet-	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	46	Alle Professoren des Master-Studiengangs	Internet-	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
24	markus.jelonek@w-hs.de	markus.jelonek	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	9	Markus	Jelonek	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
25	henningahlfprofdrsiegbert.kern@w-hs.de	henningahlf,prof.dr.siegbert.kern	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	34	Henning Ahlf, Prof. Dr. Siegbert	Kern	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
26	siegbert.kern@w-hs.de	siegbert.kern	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	31	Siegbert	Kern	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
10	wolfram.conen@w-hs.de	wolfram.conen	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	1	Wolfram	Conen	t	2026-02-02 01:38:37.963712	2025-10-15 14:45:51	2026-02-02 01:38:37.965711
1	dekan@hochschule.de	dekan	scrypt:32768:8:1$BjYSqfnqY4Du7JsV$7c95e16345e5337b0d6a2c2617af6e55f73f371e93a548d8444257ceb58c14a7de5ccdf74d4542aa871da83cbf5ef493c192acfbe13af29abbb796b5d91633b4	1	36	Leif	Meier	t	2026-02-02 09:11:40.872233	2025-10-15 14:45:51	2026-02-02 09:11:40.877233
27	lehrbeauftragte/r@hochschule.de	lehrbeauftragte/r	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	29	\N	Lehrbeauftragte/r	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
28	ulrikegriefahn.lehrbeauftragter@w-hs.de	ulrikegriefahn/.lehrbeauftragte/r	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	39	Ulrike Griefahn /	Lehrbeauftragte/r	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
29	lehrbeauftragter@hochschule.de	lehrbeauftragter	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	42	\N	Lehrbeauftragter	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
30	uwegruenefeld/.lehrbeauftragter@hochschule.de	uwegruenefeld/.lehrbeauftragter	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	43	Uwe Grünefeld /	Lehrbeauftragter	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
31	marcel.luis@w-hs.de	marcel.luis	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	7	Marcel	Luis	t	2025-11-06 22:59:05.527384	2025-10-15 14:45:51	2025-11-06 22:59:05.528385
32	gregor.lux@w-hs.de	gregor.lux	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	8	Gregor	Lux	t	2025-11-06 23:13:05.978042	2025-10-15 14:45:51	2025-11-06 23:13:05.97915
33	detlef.mansel@w-hs.de	detlef.mansel	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	22	Detlef	Mansel	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
34	alleprofessorender.medieninformatik@hochschule.de	alleprofessorender.medieninformatik	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	48	Alle Professoren der	Medieninformatik	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
35	lehrendeder.medieninformatik@hochschule.de	lehrendeder.medieninformatik	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	45	Lehrende der	Medieninformatik	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
36	studiengangsbeauftrage/r.medieninformatik@hochschule.de	studiengangsbeauftrage/r.medieninformatik	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	47	Studiengangsbeauftrage/r	Medieninformatik	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
37	studiengangsbeauftragte/r.medieninformatik@hochschule.de	studiengangsbeauftragte/r.medieninformatik	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	44	Studiengangsbeauftragte/r	Medieninformatik	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
38	henningahlfprofdrleif.meier@w-hs.de	henningahlf,prof.dr.leif.meier	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	52	Henning Ahlf, Prof. Dr. Leif	Meier	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
40	christopher.morasch@w-hs.de	christopher.morasch	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	51	Christopher	Morasch	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
41	siegbertkern.nn@w-hs.de	siegbertkern,.n.n.	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	33	Siegbert Kern,	N.N.	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
42	n.n.3d@hochschule.de	n.n.3d	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	14	\N	N.N.3D	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
43	tunnnorbert.pohlmann@w-hs.de	(tunn)norbert.pohlmann	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	25	(TU NN) Norbert	Pohlmann	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
44	n.n..swt@hochschule.de	n.n..swt	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	41	N.N.	SWT	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
45	michael.schmeing@w-hs.de	michael.schmeing	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	15	Michael	Schmeing	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
46	dozent:indes.sprachenzentrums@hochschule.de	dozent:indes.sprachenzentrums	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	17	Dozent:in des	Sprachenzentrums	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
47	leitungdes.sprachenzentrums@hochschule.de	leitungdes.sprachenzentrums	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	16	Leitung des	Sprachenzentrums	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
48	studiengangsbeauftragte/rdesjeweiligen.studiengangs@hochschule.de	studiengangsbeauftragte/rdesjeweiligen.studiengangs	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	12	Studiengangsbeauftragte/r des jeweiligen	Studiengangs	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
49	ingdiplinformhartmut.surmann@w-hs.de	-ing.dipl.inform.hartmut.surmann	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	24	-Ing. Dipl. Inform. Hartmut	Surmann	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
50	tobias.urban@w-hs.de	tobias.urban	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	35	Tobias	Urban	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
51	studiengangsbeauftragte/r.wirtschaftsinformatik@hochschule.de	studiengangsbeauftragte/r.wirtschaftsinformatik	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	26	Studiengangsbeauftragte/r	Wirtschaftsinformatik	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
52	katja.zeume@w-hs.de	katja.zeume	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	6	Katja	Zeume	t	2025-12-05 08:43:48.133778	2025-10-15 14:45:51	2025-12-05 08:43:48.134793
53	alleprofessorinnenundprofessoren.der@hochschule.de	alleprofessorinnenundprofessoren.der	pbkdf2:sha256:1000000$AwDpXpPJ2Gdb7G4g$9de313c605e16df63b23caa13e9aa083eb7f040a875b4b2f389a9a0d449c5e6b	3	49	Alle Professorinnen und Professoren	der	t	\N	2025-10-15 14:45:51	2025-10-15 14:45:51
54	test.professor@w-hs.de	prof.test	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	\N	Test	Professor	t	2025-11-06 13:12:34.522489	2025-10-30 20:36:37.318177	2025-11-06 13:12:34.523509
39	leif.meier@w-hs.de	leif.meier	scrypt:32768:8:1$GqRSbX3V54d0CsF6$921f82a43e567d99abd4480c4e014eaa80b985d890539b5aa852b3d9d4f217e28838b13493d04ef1ec5ce2447ec2cadfd78322b4e92b16081c19100122e79b36	2	36	Leif	Meier	t	2026-02-01 22:35:58.464125	2025-10-15 14:45:51	2026-02-01 22:35:58.481295
\.


--
-- Data for Name: deputats_betreuung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deputats_betreuung (id, deputatsabrechnung_id, student_name, student_vorname, titel_arbeit, betreuungsart, status, beginn_datum, ende_datum, sws, created_at) FROM stdin;
\.


--
-- Data for Name: deputats_einstellungen; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deputats_einstellungen (id, sws_bachelor_arbeit, sws_master_arbeit, sws_doktorarbeit, sws_seminar_ba, sws_seminar_ma, sws_projekt_ba, sws_projekt_ma, max_sws_praxisseminar, max_sws_projektveranstaltung, max_sws_seminar_master, max_sws_betreuung, warn_ermaessigung_ueber, default_netto_lehrverpflichtung, ist_aktiv, beschreibung, created_at, updated_at, erstellt_von) FROM stdin;
1	0.3	0.5	1	0.2	0.3	0.2	0.3	5	6	4	3	5	18	t	Standard-Einstellungen	2026-01-24 11:17:53	2026-01-24 11:17:53	\N
\.


--
-- Data for Name: deputats_ermaessigung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deputats_ermaessigung (id, deputatsabrechnung_id, bezeichnung, sws, quelle, semester_auftrag_id, created_at) FROM stdin;
\.


--
-- Data for Name: deputats_lehrexport; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deputats_lehrexport (id, deputatsabrechnung_id, fachbereich, fach, sws, created_at) FROM stdin;
\.


--
-- Data for Name: deputats_lehrtaetigkeit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deputats_lehrtaetigkeit (id, deputatsabrechnung_id, bezeichnung, kategorie, sws, wochentag, wochentage, ist_block, quelle, geplantes_modul_id, created_at) FROM stdin;
3	4	ADS - Algorithmen und Datenstrukturen  	lehrveranstaltung	4	\N	\N	f	planung	29	2026-02-02 01:38:59.200884
\.


--
-- Data for Name: deputats_vertretung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deputats_vertretung (id, deputatsabrechnung_id, art, vertretene_person, fach_professor, sws, created_at) FROM stdin;
\.


--
-- Data for Name: deputatsabrechnung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deputatsabrechnung (id, planungsphase_id, benutzer_id, netto_lehrverpflichtung, status, bemerkungen, eingereicht_am, genehmigt_von, genehmigt_am, abgelehnt_am, ablehnungsgrund, created_at, updated_at) FROM stdin;
4	19	10	18	genehmigt	\N	2026-02-02 01:39:10.390595	1	2026-02-02 01:40:09.196478	\N	\N	2026-02-02 01:38:58.991957	2026-02-02 01:40:09.20149
\.


--
-- Data for Name: dozent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dozent (id, titel, vorname, nachname, name_komplett, email, fachbereich, aktiv, created_at, ist_platzhalter) FROM stdin;
19	\N	N.N.	3D	N.N. 3D	\N	\N	f	2025-10-09 15:29:11	t
1	Prof. Dr.	Wolfram	Conen	Wolfram Conen	wolfram.conen@w-hs.de	\N	t	2025-10-09 15:29:11	f
2	Prof.	Katja	Becker	Katja Becker	katja.becker@w-hs.de	\N	t	2025-10-09 15:29:11	f
6	Prof. Dr.	Katja	Zeume	Katja Zeume	katja.zeume@w-hs.de	\N	t	2025-10-09 15:29:11	f
7	Prof. Dr.	Marcel	Luis	Marcel Luis	marcel.luis@w-hs.de	\N	t	2025-10-09 15:29:11	f
8	Prof. Dr.	Gregor	Lux	Gregor Lux	gregor.lux@w-hs.de	\N	t	2025-10-09 15:29:11	f
9	Prof. Dr.	Markus	Jelonek	Markus Jelonek	markus.jelonek@w-hs.de	\N	t	2025-10-09 15:29:11	f
11	Prof. Dr.	Laura	Anderle	Laura Anderle	laura.anderle@w-hs.de	\N	t	2025-10-09 15:29:11	f
15	Prof. Dr.	Michael	Schmeing	Michael Schmeing	michael.schmeing@w-hs.de	\N	t	2025-10-09 15:29:11	f
21	Prof. Dr.	Andreas	Cramer	Andreas Cramer	andreas.cramer@w-hs.de	\N	t	2025-10-09 15:29:15	f
22	Prof. Dr.	Detlef	Mansel	Detlef Mansel	detlef.mansel@w-hs.de	\N	t	2025-10-09 15:29:15	f
23	Prof. Dr.	Ulrike	Griefahn	Ulrike Griefahn	ulrike.griefahn@w-hs.de	\N	t	2025-10-09 15:29:15	f
5	Prof. Dr.-Ing.	Sebastian	Büttner	Sebastian Büttner	sebastian.buettner@w-hs.de	\N	t	2025-10-09 15:29:11	f
28	Prof. Dr.-Ing.	Sebastian	Buettner	Sebastian Buettner	ingsebastian.buettner@w-hs.de	\N	f	2025-10-09 15:29:15	t
30	Prof. Dr.	Christian	Dietrich	Christian Dietrich	christian.dietrich@w-hs.de	\N	t	2025-10-09 15:29:15	f
31	Prof. Dr.	Siegbert	Kern	Siegbert Kern	siegbert.kern@w-hs.de	\N	t	2025-10-09 15:29:15	f
32	Prof. Dr.	Henning	Ahlf	Henning Ahlf	henning.ahlf@w-hs.de	\N	t	2025-10-09 15:29:15	f
35	Prof. Dr.	Tobias	Urban	Tobias Urban	tobias.urban@w-hs.de	\N	t	2025-10-09 15:29:15	f
36	Prof. Dr.	Leif	Meier	Leif Meier	leif.meier@w-hs.de	\N	t	2025-10-09 15:29:15	f
40	Prof. Dr.	Dieter	Hannemann	Dieter Hannemann	dieter.hannemann@w-hs.de	\N	t	2025-10-09 15:29:20	f
51	Prof. Dr.	Christopher	Morasch	Christopher Morasch	christopher.morasch@w-hs.de	\N	t	2025-10-09 15:29:33	f
25	Prof. Dr.	Norbert	Pohlmann	Norbert Pohlmann	tunnnorbert.pohlmann@w-hs.de	\N	t	2025-10-09 15:29:15	f
14	\N	\N	N.N.3D	N.N.3D	\N	\N	f	2025-10-09 15:29:11	t
16	\N	Leitung des	Sprachenzentrums	Leitung des Sprachenzentrums	leitungdes.sprachenzentrums@w-hs.de	\N	f	2025-10-09 15:29:11	t
17	\N	Dozent:in des	Sprachenzentrums	Dozent:in des Sprachenzentrums	dozentindes.sprachenzentrums@w-hs.de	\N	f	2025-10-09 15:29:11	t
27	Prof. Dr.	Alexander	Koch	Alexander Koch	alexanderkoch.lehrbeauftragter@w-hs.de		t	2025-10-09 15:29:15	f
24	Prof. Dr.-Ing. Dipl. Inform.	Hartmut	Surmann	Hartmut Surmann	hartmut.surmann@w-hs.de	\N	t	2025-10-09 15:29:15	f
37	\N	Volker	Goerick	Volker Goerick	volker.goerick@w-hs.de	\N	t	2025-10-09 15:29:15	f
3	\N	Lehrende des Studiengangs Informatik und	Design	Lehrende des Studiengangs Informatik und Design	lehrendedesstudiengangsinformatikund.design@w-hs.de	\N	f	2025-10-09 15:29:11	t
4	\N	Studiengangsbeauftrage/r Informatik und	Design	Studiengangsbeauftrage/r Informatik und Design	studiengangsbeauftragerinformatikund.design@w-hs.de	\N	f	2025-10-09 15:29:11	t
10	\N	Studiengangsbeauftragte/r Informatik und	Design	Studiengangsbeauftragte/r Informatik und Design	studiengangsbeauftragterinformatikund.design@w-hs.de	\N	f	2025-10-09 15:29:11	t
12	\N	Studiengangsbeauftragte/r des jeweiligen	Studiengangs	Studiengangsbeauftragte/r des jeweiligen Studiengangs	studiengangsbeauftragterdesjeweiligen.studiengangs@w-hs.de	\N	f	2025-10-09 15:29:11	t
13	\N	Alle Professorinnen und Professoren der	Fachgruppe	Alle Professorinnen und Professoren der Fachgruppe	alleprofessorinnenundprofessorender.fachgruppe@w-hs.de	\N	f	2025-10-09 15:29:11	t
18	\N	N.N.	(Lehrbeauftragter)	N.N. (Lehrbeauftragter)	nn.lehrbeauftragter@w-hs.de	\N	f	2025-10-09 15:29:11	t
20	\N	Studiengangsbeauftragte/r	Informatik	Studiengangsbeauftragte/r Informatik	studiengangsbeauftragter.informatik@w-hs.de	\N	f	2025-10-09 15:29:15	t
26	\N	Studiengangsbeauftragte/r	Wirtschaftsinformatik	Studiengangsbeauftragte/r Wirtschaftsinformatik	studiengangsbeauftragter.wirtschaftsinformatik@w-hs.de	\N	f	2025-10-09 15:29:15	t
29	\N	\N	Lehrbeauftragte/r	Lehrbeauftragte/r	\N	\N	f	2025-10-09 15:29:15	t
38	\N	Alle Professoren der Fachgruppe	Informatik	Alle Professoren der Fachgruppe Informatik	alleprofessorenderfachgruppe.informatik@w-hs.de	\N	f	2025-10-09 15:29:20	t
41	\N	N.N.	SWT	N.N. SWT	nn.swt@w-hs.de	\N	f	2025-10-09 15:29:20	t
42	\N	\N	Lehrbeauftragter	Lehrbeauftragter	\N	\N	f	2025-10-09 15:29:20	t
44	\N	Studiengangsbeauftragte/r	Medieninformatik	Studiengangsbeauftragte/r Medieninformatik	studiengangsbeauftragter.medieninformatik@w-hs.de	\N	f	2025-10-09 15:29:20	t
45	\N	Lehrende der	Medieninformatik	Lehrende der Medieninformatik	lehrendeder.medieninformatik@w-hs.de	\N	f	2025-10-09 15:29:20	t
46	\N	Alle Professoren des Master-Studiengangs	Internet-	Alle Professoren des Master-Studiengangs Internet-	alleprofessorendesmasterstudiengangs.internet@w-hs.de	\N	f	2025-10-09 15:29:22	t
47	\N	Studiengangsbeauftrage/r	Medieninformatik	Studiengangsbeauftrage/r Medieninformatik	studiengangsbeauftrager.medieninformatik@w-hs.de	\N	f	2025-10-09 15:29:26	t
48	\N	Alle Professoren der	Medieninformatik	Alle Professoren der Medieninformatik	alleprofessorender.medieninformatik@w-hs.de	\N	f	2025-10-09 15:29:26	t
49	\N	Alle Professorinnen und Professoren	der	Alle Professorinnen und Professoren der	alleprofessorinnenundprofessoren.der@w-hs.de	\N	f	2025-10-09 15:29:26	t
34	Prof. Dr.	Henning Ahlf, Prof. Dr. Siegbert	Kern	Henning Ahlf, Prof. Dr. Siegbert Kern	henningahlfprofdrsiegbert.kern@w-hs.de	\N	f	2025-10-09 15:29:15	t
52	Prof. Dr.	Henning Ahlf, Prof. Dr. Leif	Meier	Henning Ahlf, Prof. Dr. Leif Meier	henningahlfprofdrleif.meier@w-hs.de	\N	f	2025-10-09 15:29:33	t
33	Prof. Dr.	Siegbert Kern,	N.N.	Siegbert Kern, N.N.	\N	\N	f	2025-10-09 15:29:15	f
39	Prof. Dr.	Ulrike Griefahn /	Lehrbeauftragte/r	Ulrike Griefahn / Lehrbeauftragte/r	ulrikegriefahn.lehrbeauftragter@w-hs.de	\N	f	2025-10-09 15:29:20	f
43	Dr.	Uwe Grünefeld /	Lehrbeauftragter	Uwe Grünefeld / Lehrbeauftragter	uwegruenefeld.lehrbeauftragter@w-hs.de	\N	f	2025-10-09 15:29:20	f
53	Dr.	Uwe	Gruenefeld	Uwe Gruenefeld	uwe.gruenefeld@w-hs.de	\N	t	2026-01-27 15:35:10.224967	f
50	\N	Alle Professorinnen Professoren der	Fachgruppe	Alle Professorinnen Professoren der Fachgruppe	alleprofessorinnenprofessorender.fachgruppe@w-hs.de	\N	f	2025-10-09 15:29:33	t
\.


--
-- Data for Name: dozent_position; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dozent_position (id, bezeichnung, typ, beschreibung, fachbereich, created_at) FROM stdin;
1	Lehrende des Studiengangs Informatik und Design	gruppe	Gruppenbezeichnung	\N	2026-01-27 15:35:10.224967
2	Studiengangsbeauftrage/r Informatik und Design	rolle	Studiengangsbeauftragte Person	\N	2026-01-27 15:35:10.224967
3	Studiengangsbeauftragte/r Informatik und Design	rolle	Studiengangsbeauftragte Person	\N	2026-01-27 15:35:10.224967
4	Studiengangsbeauftragte/r des jeweiligen Studiengangs	rolle	Studiengangsbeauftragte Person	\N	2026-01-27 15:35:10.224967
5	Alle Professorinnen und Professoren der Fachgruppe	gruppe	Gruppenbezeichnung	\N	2026-01-27 15:35:10.224967
6	N.N.	platzhalter	Noch nicht benannt / Not named	\N	2026-01-27 15:35:10.224967
7	N.N. 3D	platzhalter	Noch nicht benannt mit Kontext	\N	2026-01-27 15:35:10.224967
8	Studiengangsbeauftragte/r Informatik	rolle	Studiengangsbeauftragte Person	\N	2026-01-27 15:35:10.224967
9	Studiengangsbeauftragte/r Wirtschaftsinformatik	rolle	Studiengangsbeauftragte Person	\N	2026-01-27 15:35:10.224967
10	Lehrbeauftragte/r	rolle	Externe/r Lehrbeauftragte/r	\N	2026-01-27 15:35:10.224967
11	Alle Professoren der Fachgruppe Informatik	gruppe	Gruppenbezeichnung	\N	2026-01-27 15:35:10.224967
12	N.N. SWT	platzhalter	Noch nicht benannt mit Kontext	\N	2026-01-27 15:35:10.224967
13	Lehrbeauftragte/r	rolle	Externe/r Lehrbeauftragte/r	\N	2026-01-27 15:35:10.224967
14	Studiengangsbeauftragte/r Medieninformatik	rolle	Studiengangsbeauftragte Person	\N	2026-01-27 15:35:10.224967
15	Lehrende der Medieninformatik	gruppe	Gruppenbezeichnung	\N	2026-01-27 15:35:10.224967
16	Alle Professoren des Master-Studiengangs Internet-	gruppe	Gruppenbezeichnung	\N	2026-01-27 15:35:10.224967
17	Studiengangsbeauftrage/r Medieninformatik	rolle	Studiengangsbeauftragte Person	\N	2026-01-27 15:35:10.224967
18	Alle Professoren der Medieninformatik	gruppe	Gruppenbezeichnung	\N	2026-01-27 15:35:10.224967
19	Alle Professorinnen und Professoren der	gruppe	Gruppenbezeichnung	\N	2026-01-27 15:35:10.224967
20	N.N.	platzhalter	Aus Multi-Personen-Eintrag extrahiert	\N	2026-01-27 15:35:10.224967
21	Lehrbeauftragte/r	rolle	Aus Multi-Personen-Eintrag extrahiert	\N	2026-01-27 15:35:10.224967
22	Lehrbeauftragter	rolle	Aus Multi-Personen-Eintrag extrahiert	\N	2026-01-27 15:35:10.224967
23	N.N. 3D	platzhalter	N.N. Platzhalter fuer 3D-Bereich	\N	2026-01-27 16:09:19.523375
24	Leitung des Sprachenzentrums	rolle	Leitung des Sprachenzentrums	\N	2026-01-27 16:09:19.523375
25	Dozent:in des Sprachenzentrums	rolle	Dozent/in am Sprachenzentrum	\N	2026-01-27 16:09:19.523375
26	Alle Professorinnen und Professoren der Fachgruppe	gruppe	Gruppenbezeichnung	\N	2026-01-27 16:09:19.523375
\.


--
-- Data for Name: geplante_module; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.geplante_module (id, semesterplanung_id, modul_id, po_id, anzahl_vorlesungen, anzahl_uebungen, anzahl_praktika, anzahl_seminare, sws_vorlesung, sws_uebung, sws_praktikum, sws_seminar, sws_gesamt, mitarbeiter_ids, anmerkungen, raumbedarf, raum_vorlesung, raum_uebung, raum_praktikum, raum_seminar, kapazitaet_vorlesung, kapazitaet_uebung, kapazitaet_praktikum, kapazitaet_seminar, created_at) FROM stdin;
29	20	1	1	1	1	0	0	3	1	0	0	4	[27]	\N	\N	\N	\N	\N	\N	30	20	15	20	2026-02-02 01:38:49.231464
\.


--
-- Data for Name: lehrform; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.lehrform (id, bezeichnung, kuerzel) FROM stdin;
1	Vorlesung	V
2	Übung	Ü
3	Praktikum	P
4	Labor	L
5	Seminar	S
6	Projekt	Pr
7	Tutorium	T
\.


--
-- Data for Name: modul; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul (id, kuerzel, po_id, bezeichnung_de, bezeichnung_en, untertitel, leistungspunkte, turnus, "gruppengröße", teilnehmerzahl, anmeldemodalitaeten, created_at, updated_at) FROM stdin;
1	ADS	1	Algorithmen und Datenstrukturen  			6	Sommersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
3	BAID	1	Bachelorarbeit Informatik und Design	\N	\N	12	Die Vergabe einer Bachelor-Arbeit ist jederzeit mö	Arbeitsaufwand: 360 Stunden	Nicht begrenzt	Siehe § 23 und § 24 BRPO	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
2	BFK	1	Berufsfeldkompetenzen 			3	Sommersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
4	CPD	1	Cross-Platform Development 			6	Wintersemester, jährlich	4-6 Personen pro Projektgruppe	Nicht begrenzt	Anmeldung via Moodle Kurs	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
5	DBA	1	Datenbanksysteme	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
6	EPR	1	Einführung in die Programmierung	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
7	EXR	1	Extended Reality	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30	Nicht begrenzt	Anmeldung im Moodle-Kurs	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
8	GPB	1	Großprojekt BUILDING Sustainable Futures	\N	\N	12	Wintersemester, jährlich	Projektgruppen 3-6 Studierende	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
9	GPD	1	Großprojekt DESIGNING Sustainable Futures	\N	\N	12	Sommersemester, jährlich	Projektgruppen 3-6 Studierende	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
10	IDKG	1	Informatik und Design in Kultur und Gesellschaft	\N	\N	3	Sommersemester, jährlich	Arbeitsaufwand: Kontaktzeit: 28 Zeitstunden	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
11	KBID	1	Kolloquium zur Bachelorarbeit Informatik und Design	\N	\N	3	Das Kolloquium zur Bachelorarbeit wird ca. 2 Woche	Arbeitsaufwand: 90 Stunden	Nicht begrenzt	Siehe § 19 PO und § 26 BRPO	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
12	LDS	1	Logik und diskrete Strukturen	\N	\N	6	Wintersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
42	LUANI	1	Learning Unit: Computeranimation	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
40	LUBGS	1	Learning Unit: Bildkonzeption und Bildgestaltung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
41	LUBID	1	Learning Unit: Brand Identity und Design	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
27	LUCCO	1	Learning Unit: Cloud Computing	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
43	LUGDS	1	Learning Unit: Game-Design und Gamification	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
28	LUGSP	1	Learning Unit: Grafik und Shader Programmierung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
44	LUIND	1	Learning Unit: Informationsdesign	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
45	LUIPD	1	Learning Unit: Interaktive Prototypen und Demonstratoren	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
51	LUIUX	1	Learning Unit: UI und UX Design	\N	\N	\N	\N	Standard	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
29	LUKIF	1	Learning Unit: KI Modelle und Frameworks	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
46	LULVL	1	Learning Unit: Level Design und Generierung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
39	LUMOD	1	Learning Unit: 3D-Modellierung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
30	LUNOD	1	Learning Unit: NOSQL Datenbanken	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
47	LUNUF	1	Learning Unit: Nutzerforschung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
31	LUPHY	1	Learning Unit: Physical Computing	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
48	LUPRM	1	Learning Unit: Projektmanagement	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
32	LUPYP	1	Learning Unit: Python Programmierung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
49	LUSOD	1	Learning Unit: Social Design	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
33	LUSOT	1	Learning Unit: Software Testing	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
34	LUSPE	1	Learning Unit: Spiele-Entwicklung mit 3D Game Engines	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
50	LUSTV	1	Learning Unit: Storytelling und Visualisierung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
35	LUUST	1	Learning Unit: Usability Testing	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
36	LUVIP	1	Learning Unit: Visuelle Programmierung	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
52	LUVSP	1	Learning Unit: Videoschnitt und Produktion	\N	\N	\N	\N	\N	\N	Anmeldung über Moodle Kurs	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
37	LUWBT	1	Learning Unit: Web Technologien	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
53	LUWED	1	Learning Unit: Webdesign	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
54	LUWIA	1	Learning Unit: Wissenschaftliches Arbeiten	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
38	LUXRG	1	Learning Unit: XR-Gerätetechnologie	\N	\N	\N	\N	\N	\N	\N	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
13	MCI	1	Mensch-Computer-Interaktion	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt. Praktikum: 20	Nicht Begrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
14	MGR	1	Mathematische Grundlagen	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40	Nicht begrenzt	Erscheinen zum ersten Vorlesungstermin, Anmeldung	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
15	OPR	1	Objektorientierte Programmierung	\N	\N	7	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
16	PRB	1	PRIMER to Building Sustainable Futures	\N	\N	3	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
17	PRD	1	PRIMER to Designing Sustainable Futures	\N	\N	3	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
18	PXP	1	Praxisphase	\N	\N	15	Regulär: Sommersemester, jährlich	Arbeitsaufwand: Die praktische Arbeit umfasst 12 W	Nicht begrenzte Teilnehmerzahl	Explizite Anmeldung im Prüfungsamt	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
19	SLA	1	Statistik und Lineare Algebra	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30	Nicht begrenzt	Erscheinen zum ersten Vorlesungstermin, Anmelden	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
20	SPB	1	Projekt-Support-Modul BUILDING Sustainable Futures	\N	\N	9	Wintersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über Moodle-Kurs	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
21	SPD	1	Projekt-Support-Modul DESIGNING Sustainable Futures	\N	\N	9	Sommersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über Moodle-Kurs	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
22	STD	1	START Design	\N	\N	6	Sommersemester, jährlich	4-6 Personen pro Projekt	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
23	STI	1	START Informatik	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30.	Nicht begrenzt	Anmeldung im Moodle-Kurs	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
24	STP	1	START Projekt	\N	\N	6	Wintersemester, jährlich	4-6 Personen pro Gruppe	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
25	SWT	1	Softwaretechnik	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2	Nicht begrenzt	Anmeldung über Moodle	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
26	TEID	1	Technisches Englisch	\N	\N	5	Wintersemester, jährlich	≤ 30	≤ 30	Online unter www.spz.w-hs.de im Klausurzeitraum, der	2025-10-09 15:29:11	2026-02-02 03:49:08.493731
55	BAIN	1	Bachelorarbeit Informatik	\N	\N	12	Die Vergabe einer Bachelorarbeit ist jederzeit mög	Siehe § 22 BRPO	Wie Gruppengröße	Siehe § 24 BRPO	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
64	BKV	1	Betrieb komplexer verteilter Systeme	\N	\N	6	Wintersemester, jährlich	Vorlesung nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
83	BRW	1	Betriebliches Rechnungswesen	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
56	BSY	1	Betriebssysteme	\N	\N	6	Sommersemester, jährlich	Vorlesung nicht begrenzt, Übung: 30	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
65	BV	1	Einführung in die Bildverarbeitung	\N	\N	6	Wintersemester, jährlich	Standard	Nicht begrenzt	Keine	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
84	DIM	1	Digitales Marketing	\N	\N	6	Wintersemester, jährlich	Vorlesung: unbegrenzt, Übung 30, Praktikum 20	Unbegrenzt	Siehe Aushänge/Bekanntmachungen des	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
66	DOW	1	Data on the Web	\N	\N	6	Sommersemester (jährlich)	Vorlesung: nicht begrenzt, Praktikum: 20	Nicht begrenzt	Über den dazugehörenden Moodle-Kurs	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
67	DSP	1	Data Science in Practice	\N	\N	6	Sommersemester, bei Bedarf	20 Personen	Nicht begrenzt	Erscheinen zur ersten Vorlesung und Anmeldung zum	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
85	EBW	1	Einführung in die Betriebswirtschaftslehre	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
68	EMI	1	Einführung in die medizinische Informatik	\N	\N	6	Sommer- oder Wintersemester, bei Bedarf	Nicht begrenzt	Nicht begrenzt	Erscheinen zur ersten Vorlesung und Anmeldung zum	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
69	ERO	1	Einführung in die Robotik	\N	\N	6	Sommersemester, jährlich	Standard	Nicht begrenzt	Keine	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
86	GPM	1	Geschäftsprozessmanagement	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
87	GWI	1	Grundlagen der Wirtschaftsinformatik	\N	\N	6	Wintersemester, jährlich	Vorlesung: unbegrenzt, Übung: 40	Unbegrenzt	Siehe Aushänge/Bekanntmachungen des	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
70	INP	1	Internet-Protokolle	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
57	INS	1	Untertitel: ---	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
71	ITR	1	Untertitel:	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
72	ITS	1	Grundlagen der IT Sicherheit	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
73	KBE	1	Komponentenbasierte Softwareentwicklung	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
58	KBIN	1	Kolloquium zur Bachelorarbeit Informatik	\N	\N	3	Das Kolloquium zur Bachelorarbeit wird ca. 2 Woche	Siehe § 22 der Bachelor-Rahmenprüfungsordnung	Wie Gruppengröße	Siehe § 19 PO und § 26 BRPO	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
74	KI	1	Künstliche Intelligenz	\N	\N	6	Sommersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
75	KNG	1	Knowledge Graphs	\N	\N	6	Sommersemester (nach Bedarf)	Vorlesung: nicht begrenzt, Übung: 30, Praktikum: 2	Nicht begrenzt	Über den dazugehörenden Moodle-Kurs	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
76	MAD	1	Mobile Application Development	\N	\N	6	Sommersemester, jährlich	Vorlesung: nicht begrenzt, Praktikum: 20	Nicht begrenzt	Vorlesung: keine, Praktikum: über Moodle-Kurs	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
77	MCC	1	Mobile und Cloud Computing	\N	\N	6	Sommersemester, jährlich	Vorlesung: nicht begrenzt, Übung 30, Praktikum: 20	Nicht begrenzt	Anmeldung für Übung und Praktikum via Moodle	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
78	MRO	1	Mobile Robotik	\N	\N	6	Wintersemester, jährlich	Standard	Nicht begrenzt	Keine	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
88	NSA	1	Angewandte Netzwerksicherheit	\N	\N	6	Sommersemester, jährlich	Vorlesung: nicht begrenzt	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
79	PAP	1	Parallele Programmierung	\N	\N	6	Sommersemester, jährlich	Standard	Nicht begrenzt	Keine	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
89	PMA	1	Projektmanagement	\N	\N	6	Wintersemester, jährlich	Vorlesung: unbegrenzt	Nicht begrenzte Teilnehmerzahl	Siehe Aushang am Schwarzen Brett des Professors	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
90	PMW	1	Produktion und Materialwirtschaft	\N	\N	6	Sommersemester, jährlich	Vorlesung: unbegrenzt; Praktikum: 20; Übung: 30	Nicht begrenzt	siehe Lernplattform Moodle	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
80	PPR	1	Prozedurale Programmierung	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Vorlesung: keine, Übungen und Praktikum: über	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
81	PRAX	1	Practical Security Attacks and Exploitation	\N	\N	6	Sommersemester, jährlich	Vorlesung: nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung via Moodle	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
59	REN	1	Rechnernetze	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt, Übung 40, Praktikum: 20	Nicht begrenzt	Anmeldung für Übung und Praktikum via Moodle	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
60	SPIN	1	Softwareprojekt Informatik	\N	\N	12	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum:	Nicht begrenzt	Explizite Voranmeldung und Anmeldung erforderlich.	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
82	SWD	1	Software Design	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über Moodle-Kurs zu diesem Modul	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
61	TENI	1	Technisches Englisch für Informatiker	\N	\N	5	Wintersemester, jährlich	≤ 30	≤ 30	Online unter www.spz.w-hs.de im Klausurzeitraum, der	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
62	TGI	1	Technische Grundlagen der Informatik	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt, Übung 40, Praktikum: 20	Nicht begrenzt	Anmeldung für Übung und Praktikum via Moodle	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
63	THI	1	Theoretische Informatik	\N	\N	6	Sommersemester, jährlich	Vorlesung: nicht begrenzt, Übung: 40	Nicht begrenzt	Vorlesung: keine, Übungen: über den Moodle-Kurs	2025-10-09 15:29:15	2026-02-02 03:49:08.493731
114	AID	1	Advanced Interface Design	\N	\N	6	Wintersemester, jährlich	Projektgruppen mit 3-5 Studierenden	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
98	ASY	1	Autonome Systeme	\N	\N	6	Sommersemester, jährlich	Standard	Nicht begrenzt	Keine	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
99	CV	1	Computer Vision	\N	\N	6	unregelmäßig bei Bedarf	Standard	Nicht begrenzt	Moodle Abfrage	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
100	DBT	1	Datenbanktheorie	\N	\N	6	Sommersemester (nach Bedarf)	Vorlesung: nicht begrenzt, Übung: 30	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
115	DFIR	1	Digital Forensics and Incident Response	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Voraussetzungen nach Keine	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
101	DSC	1	Data Science Principles	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
116	DSE	1	Datenschutz und Ethik	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40	Nicht begrenzt	Siehe Aushang	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
117	DSM	1	Designmanagement	\N	\N	6	Sommersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
118	ECCR	1	Emerging Challenges in Cybersecurity Research	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
102	EINT	1	Entwicklung intelligenter Systeme	\N	\N	6	Sommersemester, unregelmäßig	Standard	12	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
103	FCO	1	Future Computing	\N	\N	6	Wintersemester, jährlich	Nicht begrenzt	Nicht begrenzt	Anmeldung per Email: Prof@DieterHannemann.de	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
104	FPR	1	Funktionale Programmierung	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Voraussetzungen nach Keine	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
119	GAM	1	Gamification	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 20	Nicht begrenzt	Anmeldung im Moodle-Kurs	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
91	IGE	1	Informatik und Gesellschaft	\N	\N	6	Wintersemester und Sommersemester, halbjährlich	Vorlesung: Nicht begrenzt, Übung: 20	Nicht begrenzt	Anmeldung beim ersten Veranstaltungstermin	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
120	IKA	1	Interaktive Kollaborative Arbeitsumgebungen	\N	\N	6	Sommersemester, jährlich	4-6 pro Projektgruppe	Nicht begrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
105	INT	1	Intelligente Systeme	\N	\N	6	Wintersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
121	ISA	1	Internet-Sicherheit A	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
122	ISB	1	Internet-Sicherheit B	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
123	ISY	1	Interaktive Systeme	\N	\N	6	Sommersemester, unregelmäßig	Standard	Nicht begrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
92	KMIN	1	Kolloquium zur Masterarbeit Informatik	\N	\N	5	Das Kolloquium zur Masterarbeit wird ca. 2 Wochen	Siehe § 22 der Master-Rahmenprüfungsordnung	Wie Gruppengröße	Siehe § 16 PO und § 26 MRPO	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
106	LPR	1	Logische Programmierung	\N	\N	6	Sommersemester, unregelmäßig	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
93	MAIN	1	Masterarbeit Informatik	\N	\N	25	Die Vergabe einer Masterarbeit ist jederzeit mögli	Siehe § 22 der Master-Rahmenprüfungsordnung	Wie Gruppengröße	Siehe § 13 und § 14 PO	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
107	MAS	1	Multi-Agent Systems	\N	\N	6	Summer term, not regularly	Lecture: no limits, theoretical work: 40	20	registration to the related Moodle-course	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
108	MCA	1	Mobile und Cloud Computing Advanced	\N	\N	6	Sommersemester, jährlich	Vorlesung: nicht begrenzt, Übung 40, Praktikum: 20	Nicht begrenzt	Anmeldung via Moodle	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
124	MCTI	1	Malware-Analyse und Cyber Threat Intelligence	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Voraussetzungen nach Keine	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
109	MGN	1	Mathematische Grundlagen neuronaler Netze	\N	\N	6	Sommersemester, nach Bedarf	Vorlesung: Nicht begrenzt, Übung: 40	Nicht begrenzt	Erscheinen zum ersten Kurstermin und Anmeldung	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
94	MPIN	1	Master-Projekt Informatik	\N	\N	12	Sommersemester, jährlich	Projektteams von 3 bis 8 Studierenden	Nicht begrenzt	Explizite Anmeldung erforderlich. Informationen im Info-	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
95	MSIN	1	Master-Seminar Informatik	\N	\N	6	Sommersemester, jährlich	Standard	Nicht begrenzt	Explizite Anmeldung notwendig. Weitere Informationen	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
110	NSQ	1	NOSQL Datenbanken	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
125	NUI	1	Natural User Interfaces	\N	\N	6	Sommersemester, unregelmäßig	Standard	Nicht begrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
126	PETS	1	Privacy Enhancing Technologies	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
96	PM	1	Projektmanagement	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt,	12	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
127	PRMS	1	Programmiermethodik und Sicherheit	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Praktikum: 20	Nicht begrenzt	Voraussetzungen nach Keine	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
111	SAS	1	Spezielle Kapitel Autonome Systeme	\N	\N	6	Wintersemester, jährlich	Standard	Nicht begrenzt	Keine	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
128	SRE	1	Software Reverse Engineering	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum: 2	Nicht begrenzt	Keine	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
112	SWE	1	Software Engineering	\N	\N	6	Summer term, not regularly	Lecture: no limits, theoretical work: 40	No limits	registration to the related Moodle-course	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
129	VDM	1	Vertiefung Digitales Marketing	\N	\N	6	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40	Nicht begrenzt	Voraussetzungen nach Keine modulspezifischen Voraussetzungen	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
130	VIR	1	Virtuelle Welten	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 30	Nicht begrenzt	Anmeldung im Moodle-Kurs	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
131	VSC	1	Vertiefung Supply Chain Management	\N	\N	6	Wintersemester, jährlich	Vorlesung: 30 Praktikum: 20	Nicht begrenzte Teilnehmerzahl	s. Lernplattform	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
113	WKV	1	Weiterführende Konzepte zum Betrieb komplexer verteilter	\N	\N	6	Sommersemester, jährlich	Vorlesung: nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
97	WVIN	1	Wissenschaftliche Vertiefung Informatik	\N	\N	12	Sommer- und Wintersemester, halbjährlich	Projektteams von 1 bis 3 Studierenden	Nicht begrenzt	Die Ausgabe eines Projektthemas kann über jede/n	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
132	ZMI	1	Zukunftstrends in der Medieninformatik	\N	\N	6	Sommersemester, unregelmäßig	Standard	Nicht begrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:20	2026-02-02 03:49:08.493731
133	ATIS	1	Ausgewählte Themen aus dem Bereich Internet und Sicherheit	\N	\N	6	Wintersemester und Sommersemester, halbjährlich	Vorlesung: Nicht begrenzt, Praktikum: 20	Nicht begrenzt	Voraussetzungen nach Keine	2025-10-09 15:29:22	2026-02-02 03:49:08.493731
134	KMIS	1	Kolloquium zur Masterarbeit Internet-Sicherheit	\N	\N	5	Das Kolloquium zur Masterarbeit ist jederzeit mögl	Im Regelfall Gruppengröße 1, größere Gruppen	Wie Gruppengröße	Siehe § 16 PO und § 26 MRPO	2025-10-09 15:29:22	2026-02-02 03:49:08.493731
135	MAIS	1	Masterarbeit Internet-Sicherheit	\N	\N	25	Die Vergabe einer Masterarbeit ist jederzeit mögli	Im Regelfall Gruppengröße 1, größere Gruppen	Wie Gruppengröße	Siehe § 13 und § 14 PO und § 23 MRPO	2025-10-09 15:29:22	2026-02-02 03:49:08.493731
136	MPIS	1	Master-Projekt Internet-Sicherheit	\N	\N	12	Wintersemester, jährlich	Standard, i.d.R. Projektteams von 6 bis 8 Studiere	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:22	2026-02-02 03:49:08.493731
137	MSIS	1	Master-Seminar Internet-Sicherheit	\N	\N	6	Zu jedem Semester	Standard, i.d.R. Projektteams von 3 bis 6 Studiere	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:22	2026-02-02 03:49:08.493731
138	MVIS	1	Wissenschaftliche Vertiefung Internet-Sicherheit	\N	\N	12	Wintersemester, jährlich	Standard, i.d.R. Projektteams von 3 bis 6 Studiere	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:22	2026-02-02 03:49:08.493731
139	CRI	1	Cross-Reality Interaction	\N	\N	6	Sommersemester, jährlich	4-6 pro Projektgruppe	unbegrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:26	2026-02-02 03:49:08.493731
140	D3D	1	Design für 3D User Interfaces	\N	\N	6	Wintersemester, jährlich	4-6 pro Projektgruppe	unbegrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:26	2026-02-02 03:49:08.493731
141	KMMI	1	Kolloquium zur Masterarbeit Medieninformatik	\N	\N	5	Das Kolloquium zur Masterarbeit wird ca. 2 Wochen	Arbeitsaufwand: 150 Stunden	Nicht begrenzt	Siehe § 16 PO und § 26 MRPO	2025-10-09 15:29:26	2026-02-02 03:49:08.493731
142	MMI	1	Masterarbeit Medieninformatik	\N	\N	25	Die Vergabe einer Masterarbeit ist jederzeit mögli	Arbeitsaufwand: 750 Stunden	Nicht begrenzt	Siehe § 13 und § 14 der Studiengangsprüfungsordnung	2025-10-09 15:29:26	2026-02-02 03:49:08.493731
143	MPMI	1	Master-Projekt Medieninformatik	\N	\N	12	Sommersemester, jährlich	Projektgruppen 3-6 Studierende	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:26	2026-02-02 03:49:08.493731
144	MSMI	1	Master-Seminar Medieninformatik	\N	\N	6	Wintersemester, jährlich	Standard	Nicht begrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:26	2026-02-02 03:49:08.493731
145	WVMI	1	Wissenschaftliche Vertiefung Medieninformatik	\N	\N	12	Unregelmäßig (bei Bedarf)	Projektteams von 1-4 Studierenden	Nicht begrenzt	Anmeldung über den Moodle Kurs zu diesem Modul	2025-10-09 15:29:26	2026-02-02 03:49:08.493731
146	BAWI	1	Bachelorarbeit Wirtschaftsinformatik	\N	\N	12	Die Vergabe einer Bachelorarbeit ist jederzeit mög	Siehe § 22 der Bachelor-Rahmenprüfungsordnung	Wie Gruppengröße	Siehe § 23 und § 24 BRPO	2025-10-09 15:29:30	2026-02-02 03:49:08.493731
147	BNW	1	Betriebssysteme und Netzwerke für WI	\N	\N	6	Wintersemester, jährlich	Vorlesung: nicht begrenzt, Übung 40	Nicht begrenzt	Anmeldung für Übung via Moodle	2025-10-09 15:29:30	2026-02-02 03:49:08.493731
148	GSC	1	Grundlagen Supply Chain Management	\N	\N	6	Sommersemester, jährlich	Vorlesung: unbegrenzt; Praktikum/ Übung: 20	Nicht begrenzt	siehe Lernplattform Moodle	2025-10-09 15:29:30	2026-02-02 03:49:08.493731
149	KBWI	1	Kolloquium zur Bachelorarbeit Wirtschaftsinformatik	\N	\N	3	Das Kolloquium zur Bachelorarbeit wird ca. 2 Woche	Siehe § 22 der Bachelor-Rahmenprüfungsordnung	Wie Gruppengröße	Siehe § 19 PO und § 26 BRPO	2025-10-09 15:29:30	2026-02-02 03:49:08.493731
150	SCD	1	Supply Chain Management und Digitalisierung	\N	\N	6	Wintersemester, jährlich	Vorlesung: unbegrenzt; Praktikum: 20; Übung: 40	Nicht begrenzt	siehe Lernplattform Moodle	2025-10-09 15:29:30	2026-02-02 03:49:08.493731
151	SPWI	1	Softwareprojekt Wirtschaftsinformatik	\N	\N	12	Sommersemester, jährlich	Vorlesung: Nicht begrenzt, Übung: 40, Praktikum:	Nicht begrenzt	Explizite Voranmeldung und Anmeldung erforderlich.	2025-10-09 15:29:30	2026-02-02 03:49:08.493731
152	WEN	1	Wirtschaftsenglisch für Wirtschaftsinformatiker	\N	\N	5	Sommersemester, jährlich	≤ 30	≤ 30	Online unter www.spz.w-hs.de im Klausurzeitraum, der	2025-10-09 15:29:30	2026-02-02 03:49:08.493731
153	BIN	1	Business Intelligence und Big Data	\N	\N	6	Wintersemester, jährlich	Vorlesung: Nicht begrenzt, Praktikum: 20	Nicht begrenzt	Anmeldung über den Moodle-Kurs zu diesem Modul	2025-10-09 15:29:33	2026-02-02 03:49:08.493731
158	GDM	1	Grundlagen des Managements	\N	\N	6	Wintersemester	20	5	Voraussetzungen nach Keine	2025-10-09 15:29:33	2026-02-02 03:49:08.493731
154	KMWI	1	Kolloquium zur Masterarbeit Wirtschaftsinformatik	\N	\N	5	Das Kolloquium zur Masterarbeit wird ca. 2 Wochen	Siehe § 22 der Master-Rahmenprüfungsordnung	Wie Gruppengröße	Siehe § 16 PO und § 26 MRPO	2025-10-09 15:29:33	2026-02-02 03:49:08.493731
156	MAWI	1	Masterarbeit Wirtschaftsinformatik	\N	\N	25	Die Vergabe einer Masterarbeit ist jederzeit mögli	Siehe § 22 der Master-Rahmenprüfungsordnung	Wie Gruppengröße	Siehe § 13 und § 14 PO und § 23 MRPO	2025-10-09 15:29:33	2026-02-02 03:49:08.493731
155	MPWI	1	Master-Projekt Wirtschaftsinformatik 1	\N	\N	12	Sommersemester, jährlich	Projektteams von 3 bis 8 Studierenden	Nicht begrenzt	Explizite Anmeldung erforderlich. Informationen im Info-	2025-10-09 15:29:33	2026-02-02 03:49:08.493731
157	MSWI	1	Master-Seminar Wirtschaftsinformatik	\N	\N	6	Wintersemester, jährlich	Standard	Nicht begrenzt	Explizite Anmeldung notwendig. Weitere Informationen	2025-10-09 15:29:33	2026-02-02 03:49:08.493731
159	SOM	1	Strategisches und operatives Management	\N	\N	6	Sommersemester, jährlich	Vorlesung und Übung 20	20	Keine	2025-10-09 15:29:33	2026-02-02 03:49:08.493731
\.


--
-- Data for Name: modul_abhÃ¤ngigkeit; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public."modul_abhÃ¤ngigkeit" (id, modul_id, voraussetzung_modul_id, po_id, typ) FROM stdin;
\.


--
-- Data for Name: modul_arbeitsaufwand; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_arbeitsaufwand (modul_id, po_id, kontaktzeit_stunden, selbststudium_stunden, pruefungsvorbereitung_stunden, gesamt_stunden) FROM stdin;
2	1	28	62	0	90
4	1	56	124	0	180
7	1	56	124	\N	180
8	1	56	304	\N	360
9	1	56	304	\N	360
10	1	28	62	\N	90
51	1	28	62	\N	90
16	1	28	62	\N	90
17	1	28	62	\N	90
18	1	\N	\N	\N	420
20	1	84	186	\N	270
21	1	84	186	\N	270
22	1	56	124	\N	180
23	1	56	124	\N	180
24	1	56	124	\N	180
26	1	60	90	\N	150
55	1	\N	\N	\N	360
56	1	56	124	\N	180
58	1	\N	\N	\N	90
59	1	60	120	\N	180
93	1	\N	\N	\N	750
134	1	\N	\N	\N	150
135	1	\N	\N	\N	750
145	1	56	304	\N	360
146	1	\N	\N	\N	360
147	1	75	105	\N	180
148	1	56	124	\N	180
149	1	\N	\N	\N	90
150	1	60	120	\N	180
151	1	50	310	\N	360
152	1	56	94	\N	150
153	1	60	120	\N	180
109	1	56	124	\N	180
94	1	29	331	\N	360
95	1	28	152	\N	180
125	1	56	124	\N	180
1	1	56	124	0	180
5	1	75	105	\N	180
6	1	75	105	\N	180
12	1	60	120	\N	180
13	1	70	110	\N	180
14	1	90	90	\N	180
15	1	70	140	\N	210
19	1	75	105	\N	180
25	1	60	120	\N	180
64	1	60	120	\N	180
83	1	75	105	\N	180
65	1	75	105	\N	180
84	1	60	120	\N	180
66	1	56	124	\N	180
67	1	42	138	\N	180
85	1	60	120	\N	180
68	1	60	120	\N	180
69	1	70	110	\N	180
86	1	70	110	\N	180
87	1	60	120	\N	180
70	1	56	124	\N	180
57	1	60	120	\N	180
71	1	54	124	\N	178
72	1	60	120	\N	180
73	1	60	120	\N	180
74	1	60	120	\N	180
75	1	56	124	\N	180
76	1	60	120	\N	180
77	1	56	124	\N	180
78	1	75	105	\N	180
88	1	56	124	\N	180
79	1	70	110	\N	180
89	1	60	120	\N	180
90	1	70	110	\N	180
80	1	60	120	\N	180
81	1	56	124	\N	180
60	1	85	275	\N	360
82	1	70	110	\N	180
61	1	60	90	\N	150
62	1	60	120	\N	180
63	1	56	124	\N	180
114	1	56	124	\N	180
98	1	70	110	\N	180
99	1	75	105	\N	180
115	1	56	124	\N	180
117	1	56	124	\N	180
118	1	56	124	\N	180
102	1	56	124	\N	180
119	1	56	124	\N	180
120	1	56	124	\N	180
105	1	60	120	\N	180
123	1	56	124	\N	180
106	1	60	120	\N	180
124	1	56	124	\N	180
96	1	60	120	\N	180
127	1	60	120	\N	180
111	1	75	105	\N	180
128	1	60	120	\N	180
130	1	60	120	\N	180
97	1	30	330	\N	360
132	1	56	124	\N	180
133	1	60	120	\N	180
136	1	56	304	\N	360
137	1	30	150	\N	180
138	1	30	330	\N	360
139	1	56	124	\N	180
140	1	60	120	\N	180
143	1	56	304	\N	360
144	1	28	152	\N	180
100	1	56	124	\N	180
101	1	60	120	\N	180
116	1	56	124	\N	180
103	1	60	120	\N	180
104	1	56	124	\N	180
91	1	60	120	\N	180
121	1	60	120	\N	180
122	1	56	124	\N	180
108	1	56	124	\N	180
110	1	60	120	\N	180
126	1	60	120	\N	180
129	1	56	124	\N	180
131	1	60	120	\N	180
113	1	56	124	\N	180
158	1	60	120	\N	180
155	1	28	332	\N	360
157	1	30	150	\N	180
159	1	60	120	\N	180
\.


--
-- Data for Name: modul_audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_audit_log (id, modul_id, po_id, geaendert_von, aktion, alt_dozent_id, neu_dozent_id, alte_rolle, neue_rolle, bemerkung, created_at) FROM stdin;
1	1	1	1	dozent_hinzugefuegt	\N	1	\N	pruefend	\N	2025-11-25 22:41:02.093092
\.


--
-- Data for Name: modul_dozent; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_dozent (id, modul_id, po_id, dozent_id, rolle, vertreter_id, zweitpruefer_id, dozent_position_id) FROM stdin;
88	55	1	\N	Dozent	\N	\N	5
98	58	1	\N	Dozent	\N	\N	5
114	60	1	\N	Dozent	\N	\N	5
180	92	1	\N	Dozent	\N	\N	5
184	94	1	\N	Dozent	\N	\N	5
186	95	1	\N	Dozent	\N	\N	5
190	97	1	\N	Dozent	\N	\N	5
57	29	1	\N	Dozent	\N	\N	6
58	30	1	\N	Dozent	\N	\N	6
82	52	1	\N	Dozent	\N	\N	7
87	55	1	\N	Modulverantwortlicher	\N	\N	8
97	58	1	\N	Modulverantwortlicher	\N	\N	8
113	60	1	\N	Modulverantwortlicher	\N	\N	8
177	91	1	\N	Modulverantwortlicher	\N	\N	8
179	92	1	\N	Modulverantwortlicher	\N	\N	8
181	93	1	\N	Modulverantwortlicher	\N	\N	8
183	94	1	\N	Modulverantwortlicher	\N	\N	8
185	95	1	\N	Modulverantwortlicher	\N	\N	8
189	97	1	\N	Modulverantwortlicher	\N	\N	8
137	71	1	\N	Modulverantwortlicher	\N	\N	9
156	80	1	\N	Dozent	\N	\N	10
178	91	1	\N	Dozent	\N	\N	10
182	93	1	\N	Dozent	\N	\N	11
209	107	1	\N	Modulverantwortlicher	\N	\N	12
210	107	1	\N	Dozent	\N	\N	12
242	123	1	\N	Dozent	\N	\N	13
259	132	1	\N	Modulverantwortlicher	\N	\N	14
260	132	1	\N	Dozent	\N	\N	15
270	134	1	\N	Dozent	\N	\N	16
272	135	1	\N	Dozent	\N	\N	16
276	136	1	\N	Dozent	\N	\N	16
278	137	1	\N	Dozent	\N	\N	16
280	138	1	\N	Dozent	\N	\N	16
495	85	1	31	Modulverantwortlicher	\N	\N	\N
496	86	1	31	Modulverantwortlicher	\N	\N	\N
497	87	1	32	Modulverantwortlicher	\N	\N	\N
498	87	1	31	Modulverantwortlicher	\N	\N	\N
499	96	1	23	Dozent	\N	\N	\N
500	125	1	53	Dozent	\N	\N	\N
501	159	1	32	Modulverantwortlicher	\N	\N	\N
502	159	1	36	Modulverantwortlicher	\N	\N	\N
4	2	1	\N	Dozent	\N	\N	1
6	3	1	\N	Dozent	\N	\N	1
16	8	1	\N	Dozent	\N	\N	1
18	9	1	\N	Dozent	\N	\N	1
20	10	1	\N	Dozent	\N	\N	1
22	11	1	\N	Dozent	\N	\N	1
32	16	1	\N	Dozent	\N	\N	1
34	17	1	\N	Dozent	\N	\N	1
40	20	1	\N	Dozent	\N	\N	1
42	21	1	\N	Dozent	\N	\N	1
50	24	1	\N	Dozent	\N	\N	1
5	3	1	\N	Modulverantwortlicher	\N	\N	2
15	8	1	\N	Modulverantwortlicher	\N	\N	2
17	9	1	\N	Modulverantwortlicher	\N	\N	2
31	16	1	\N	Modulverantwortlicher	\N	\N	2
33	17	1	\N	Modulverantwortlicher	\N	\N	2
21	11	1	\N	Modulverantwortlicher	\N	\N	3
39	20	1	\N	Modulverantwortlicher	\N	\N	3
41	21	1	\N	Modulverantwortlicher	\N	\N	3
35	18	1	\N	Modulverantwortlicher	\N	\N	4
36	18	1	\N	Dozent	\N	\N	5
1	1	1	1	Modulverantwortlicher	\N	\N	\N
2	1	1	1	Dozent	\N	\N	\N
3	2	1	2	Modulverantwortlicher	\N	\N	\N
7	4	1	5	Modulverantwortlicher	\N	\N	\N
8	4	1	5	Dozent	\N	\N	\N
9	5	1	6	Modulverantwortlicher	\N	\N	\N
10	5	1	6	Dozent	\N	\N	\N
11	6	1	7	Modulverantwortlicher	\N	\N	\N
12	6	1	7	Dozent	\N	\N	\N
13	7	1	8	Modulverantwortlicher	\N	\N	\N
14	7	1	8	Dozent	\N	\N	\N
19	10	1	9	Modulverantwortlicher	\N	\N	\N
23	12	1	1	Modulverantwortlicher	\N	\N	\N
24	12	1	1	Dozent	\N	\N	\N
25	13	1	9	Modulverantwortlicher	\N	\N	\N
26	13	1	9	Dozent	\N	\N	\N
27	14	1	11	Modulverantwortlicher	\N	\N	\N
28	14	1	11	Dozent	\N	\N	\N
29	15	1	7	Modulverantwortlicher	\N	\N	\N
30	15	1	7	Dozent	\N	\N	\N
37	19	1	11	Modulverantwortlicher	\N	\N	\N
38	19	1	11	Dozent	\N	\N	\N
43	22	1	2	Modulverantwortlicher	\N	\N	\N
44	22	1	2	Dozent	\N	\N	\N
46	23	1	8	Modulverantwortlicher	\N	\N	\N
47	23	1	8	Dozent	\N	\N	\N
48	23	1	5	Dozent	\N	\N	\N
49	24	1	2	Modulverantwortlicher	\N	\N	\N
51	25	1	15	Modulverantwortlicher	\N	\N	\N
52	25	1	15	Dozent	\N	\N	\N
55	27	1	5	Dozent	\N	\N	\N
56	28	1	8	Dozent	\N	\N	\N
59	31	1	8	Dozent	\N	\N	\N
60	32	1	8	Dozent	\N	\N	\N
61	33	1	5	Dozent	\N	\N	\N
62	34	1	8	Dozent	\N	\N	\N
63	35	1	9	Dozent	\N	\N	\N
64	36	1	8	Dozent	\N	\N	\N
65	37	1	5	Dozent	\N	\N	\N
66	38	1	8	Dozent	\N	\N	\N
67	39	1	8	Dozent	\N	\N	\N
68	40	1	2	Dozent	\N	\N	\N
69	41	1	2	Dozent	\N	\N	\N
70	42	1	8	Dozent	\N	\N	\N
71	43	1	8	Dozent	\N	\N	\N
72	44	1	2	Dozent	\N	\N	\N
74	45	1	5	Dozent	\N	\N	\N
75	46	1	8	Dozent	\N	\N	\N
76	47	1	9	Dozent	\N	\N	\N
77	48	1	9	Dozent	\N	\N	\N
78	49	1	2	Dozent	\N	\N	\N
79	50	1	2	Dozent	\N	\N	\N
81	51	1	2	Dozent	\N	\N	\N
83	53	1	2	Dozent	\N	\N	\N
84	54	1	9	Dozent	\N	\N	\N
89	56	1	21	Modulverantwortlicher	\N	\N	\N
90	56	1	21	Dozent	\N	\N	\N
95	57	1	21	Modulverantwortlicher	\N	\N	\N
96	57	1	21	Dozent	\N	\N	\N
109	59	1	22	Modulverantwortlicher	\N	\N	\N
110	59	1	22	Dozent	\N	\N	\N
119	62	1	22	Modulverantwortlicher	\N	\N	\N
120	62	1	22	Dozent	\N	\N	\N
121	63	1	23	Modulverantwortlicher	\N	\N	\N
122	63	1	23	Dozent	\N	\N	\N
123	64	1	21	Modulverantwortlicher	\N	\N	\N
124	64	1	21	Dozent	\N	\N	\N
125	65	1	24	Modulverantwortlicher	\N	\N	\N
126	65	1	24	Dozent	\N	\N	\N
127	66	1	6	Modulverantwortlicher	\N	\N	\N
128	66	1	6	Dozent	\N	\N	\N
129	67	1	11	Modulverantwortlicher	\N	\N	\N
130	67	1	11	Dozent	\N	\N	\N
131	68	1	11	Modulverantwortlicher	\N	\N	\N
132	68	1	11	Dozent	\N	\N	\N
133	69	1	24	Modulverantwortlicher	\N	\N	\N
134	69	1	24	Dozent	\N	\N	\N
135	70	1	25	Modulverantwortlicher	\N	\N	\N
136	70	1	25	Dozent	\N	\N	\N
138	71	1	27	Dozent	\N	\N	\N
139	72	1	25	Modulverantwortlicher	\N	\N	\N
45	22	1	\N	Dozent	\N	\N	23
73	44	1	\N	Dozent	\N	\N	23
80	50	1	\N	Dozent	\N	\N	23
53	26	1	\N	Modulverantwortlicher	\N	\N	24
117	61	1	\N	Modulverantwortlicher	\N	\N	24
54	26	1	\N	Dozent	\N	\N	25
118	61	1	\N	Dozent	\N	\N	25
140	72	1	25	Dozent	\N	\N	\N
141	73	1	15	Modulverantwortlicher	\N	\N	\N
142	73	1	15	Dozent	\N	\N	\N
143	74	1	1	Modulverantwortlicher	\N	\N	\N
144	74	1	1	Dozent	\N	\N	\N
145	75	1	6	Modulverantwortlicher	\N	\N	\N
146	75	1	6	Dozent	\N	\N	\N
149	77	1	22	Modulverantwortlicher	\N	\N	\N
150	77	1	22	Dozent	\N	\N	\N
151	78	1	24	Modulverantwortlicher	\N	\N	\N
152	78	1	24	Dozent	\N	\N	\N
153	79	1	24	Modulverantwortlicher	\N	\N	\N
154	79	1	24	Dozent	\N	\N	\N
155	80	1	23	Modulverantwortlicher	\N	\N	\N
157	81	1	30	Modulverantwortlicher	\N	\N	\N
158	81	1	30	Dozent	\N	\N	\N
159	82	1	15	Modulverantwortlicher	\N	\N	\N
160	82	1	15	Dozent	\N	\N	\N
161	83	1	31	Modulverantwortlicher	\N	\N	\N
162	83	1	31	Dozent	\N	\N	\N
163	84	1	32	Modulverantwortlicher	\N	\N	\N
164	84	1	32	Dozent	\N	\N	\N
166	85	1	31	Dozent	\N	\N	\N
168	86	1	31	Dozent	\N	\N	\N
170	87	1	32	Dozent	\N	\N	\N
171	88	1	35	Modulverantwortlicher	\N	\N	\N
172	88	1	35	Dozent	\N	\N	\N
173	89	1	36	Modulverantwortlicher	\N	\N	\N
174	89	1	37	Dozent	\N	\N	\N
175	90	1	36	Modulverantwortlicher	\N	\N	\N
176	90	1	36	Dozent	\N	\N	\N
187	96	1	23	Modulverantwortlicher	\N	\N	\N
191	98	1	24	Modulverantwortlicher	\N	\N	\N
192	98	1	24	Dozent	\N	\N	\N
193	99	1	24	Modulverantwortlicher	\N	\N	\N
194	99	1	24	Dozent	\N	\N	\N
195	100	1	6	Modulverantwortlicher	\N	\N	\N
196	100	1	6	Dozent	\N	\N	\N
197	101	1	11	Modulverantwortlicher	\N	\N	\N
198	101	1	11	Dozent	\N	\N	\N
199	102	1	1	Modulverantwortlicher	\N	\N	\N
200	102	1	1	Dozent	\N	\N	\N
201	103	1	40	Modulverantwortlicher	\N	\N	\N
202	103	1	40	Dozent	\N	\N	\N
203	104	1	7	Modulverantwortlicher	\N	\N	\N
204	104	1	7	Dozent	\N	\N	\N
205	105	1	1	Modulverantwortlicher	\N	\N	\N
206	105	1	1	Dozent	\N	\N	\N
207	106	1	23	Modulverantwortlicher	\N	\N	\N
208	106	1	23	Dozent	\N	\N	\N
211	108	1	22	Modulverantwortlicher	\N	\N	\N
212	108	1	22	Dozent	\N	\N	\N
213	109	1	11	Modulverantwortlicher	\N	\N	\N
214	109	1	11	Dozent	\N	\N	\N
215	110	1	6	Modulverantwortlicher	\N	\N	\N
216	110	1	6	Dozent	\N	\N	\N
217	111	1	24	Modulverantwortlicher	\N	\N	\N
218	111	1	24	Dozent	\N	\N	\N
219	112	1	15	Modulverantwortlicher	\N	\N	\N
220	112	1	15	Dozent	\N	\N	\N
221	113	1	21	Modulverantwortlicher	\N	\N	\N
222	113	1	21	Dozent	\N	\N	\N
223	114	1	2	Modulverantwortlicher	\N	\N	\N
224	114	1	2	Dozent	\N	\N	\N
225	115	1	30	Modulverantwortlicher	\N	\N	\N
226	115	1	30	Dozent	\N	\N	\N
227	116	1	25	Modulverantwortlicher	\N	\N	\N
228	116	1	27	Dozent	\N	\N	\N
229	117	1	2	Modulverantwortlicher	\N	\N	\N
230	117	1	2	Dozent	\N	\N	\N
231	118	1	35	Modulverantwortlicher	\N	\N	\N
232	118	1	35	Dozent	\N	\N	\N
233	119	1	8	Modulverantwortlicher	\N	\N	\N
234	119	1	8	Dozent	\N	\N	\N
235	120	1	9	Modulverantwortlicher	\N	\N	\N
236	120	1	9	Dozent	\N	\N	\N
237	121	1	25	Modulverantwortlicher	\N	\N	\N
238	121	1	25	Dozent	\N	\N	\N
239	122	1	25	Modulverantwortlicher	\N	\N	\N
240	122	1	25	Dozent	\N	\N	\N
241	123	1	9	Modulverantwortlicher	\N	\N	\N
243	124	1	30	Modulverantwortlicher	\N	\N	\N
244	124	1	30	Dozent	\N	\N	\N
245	125	1	9	Modulverantwortlicher	\N	\N	\N
247	126	1	35	Modulverantwortlicher	\N	\N	\N
248	126	1	35	Dozent	\N	\N	\N
249	127	1	30	Modulverantwortlicher	\N	\N	\N
250	127	1	30	Dozent	\N	\N	\N
251	128	1	30	Modulverantwortlicher	\N	\N	\N
252	128	1	30	Dozent	\N	\N	\N
253	129	1	32	Modulverantwortlicher	\N	\N	\N
254	129	1	32	Dozent	\N	\N	\N
255	130	1	8	Modulverantwortlicher	\N	\N	\N
256	130	1	8	Dozent	\N	\N	\N
257	131	1	36	Modulverantwortlicher	\N	\N	\N
258	131	1	36	Dozent	\N	\N	\N
261	133	1	30	Modulverantwortlicher	\N	\N	\N
262	133	1	30	Dozent	\N	\N	\N
269	134	1	25	Modulverantwortlicher	\N	\N	\N
271	135	1	25	Modulverantwortlicher	\N	\N	\N
275	136	1	25	Modulverantwortlicher	\N	\N	\N
277	137	1	25	Modulverantwortlicher	\N	\N	\N
279	138	1	25	Modulverantwortlicher	\N	\N	\N
307	139	1	5	Modulverantwortlicher	\N	\N	\N
308	139	1	5	Dozent	\N	\N	\N
309	140	1	\N	Modulverantwortlicher	\N	\N	23
147	76	1	5	Modulverantwortlicher	\N	\N	\N
377	147	1	22	Modulverantwortlicher	\N	\N	\N
378	147	1	22	Dozent	\N	\N	\N
391	148	1	36	Modulverantwortlicher	\N	\N	\N
392	148	1	36	Dozent	\N	\N	\N
413	150	1	36	Modulverantwortlicher	\N	\N	\N
414	150	1	36	Dozent	\N	\N	\N
451	153	1	31	Modulverantwortlicher	\N	\N	\N
452	153	1	31	Dozent	\N	\N	\N
489	158	1	51	Modulverantwortlicher	\N	\N	\N
490	158	1	51	Dozent	\N	\N	\N
492	159	1	32	Dozent	\N	\N	\N
493	159	1	36	Dozent	\N	\N	\N
494	1	1	1	pruefend	\N	\N	\N
316	141	1	\N	Dozent	\N	\N	5
318	142	1	\N	Dozent	\N	\N	5
376	146	1	\N	Dozent	\N	\N	5
398	149	1	\N	Dozent	\N	\N	5
418	151	1	\N	Dozent	\N	\N	5
458	154	1	\N	Dozent	\N	\N	5
460	155	1	\N	Dozent	\N	\N	5
466	157	1	\N	Dozent	\N	\N	5
375	146	1	\N	Modulverantwortlicher	\N	\N	9
397	149	1	\N	Modulverantwortlicher	\N	\N	9
417	151	1	\N	Modulverantwortlicher	\N	\N	9
457	154	1	\N	Modulverantwortlicher	\N	\N	9
459	155	1	\N	Modulverantwortlicher	\N	\N	9
463	156	1	\N	Modulverantwortlicher	\N	\N	9
465	157	1	\N	Modulverantwortlicher	\N	\N	9
315	141	1	\N	Modulverantwortlicher	\N	\N	14
317	142	1	\N	Modulverantwortlicher	\N	\N	14
320	143	1	\N	Dozent	\N	\N	15
319	143	1	\N	Modulverantwortlicher	\N	\N	17
321	144	1	\N	Modulverantwortlicher	\N	\N	17
369	145	1	\N	Modulverantwortlicher	\N	\N	17
322	144	1	\N	Dozent	\N	\N	18
370	145	1	\N	Dozent	\N	\N	19
310	140	1	\N	Dozent	\N	\N	23
421	152	1	\N	Modulverantwortlicher	\N	\N	24
422	152	1	\N	Dozent	\N	\N	25
464	156	1	\N	Dozent	\N	\N	26
\.


--
-- Data for Name: modul_lehrform; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_lehrform (id, modul_id, po_id, lehrform_id, sws) FROM stdin;
3	2	1	2	2
4	4	1	1	2
5	4	1	6	2
12	7	1	1	2
13	7	1	2	2
14	8	1	6	4
15	9	1	6	4
16	10	1	2	2
26	16	1	1	1
27	17	1	1	1
30	20	1	6	2
31	21	1	6	2
32	22	1	1	2
33	22	1	3	2
34	23	1	1	2
35	23	1	2	2
36	24	1	1	2
37	24	1	3	2
40	27	1	1	1
41	27	1	3	1
42	28	1	1	1
43	28	1	3	1
44	29	1	1	1
45	29	1	3	1
46	30	1	1	1
47	30	1	3	1
48	31	1	1	1
49	31	1	3	1
50	32	1	1	1
51	32	1	3	1
52	33	1	1	1
53	33	1	3	1
54	34	1	2	1
55	34	1	3	1
56	35	1	1	1
57	35	1	3	1
58	36	1	2	1
59	36	1	3	1
60	37	1	1	1
61	37	1	3	1
62	38	1	2	2
63	39	1	2	1
64	39	1	3	1
65	40	1	1	1
66	40	1	3	1
67	41	1	1	1
68	41	1	3	1
69	42	1	2	1
70	42	1	3	1
71	43	1	2	2
72	44	1	1	1
73	44	1	3	1
74	45	1	1	1
75	45	1	3	1
76	46	1	1	1
77	46	1	3	1
78	47	1	1	1
79	47	1	2	1
80	48	1	1	1
81	48	1	2	1
82	49	1	1	1
83	49	1	3	1
84	50	1	1	1
85	50	1	3	1
86	51	1	1	1
87	51	1	3	1
88	52	1	1	1
89	52	1	3	1
90	53	1	1	1
91	53	1	3	1
92	54	1	1	1
93	54	1	3	1
96	56	1	1	3
97	56	1	2	1
115	59	1	1	2
116	59	1	2	1
117	59	1	3	1
120	60	1	1	2
121	60	1	2	2
124	62	1	1	2
125	62	1	2	1
126	62	1	3	1
127	63	1	1	3
128	63	1	2	1
136	67	1	1	2
137	67	1	2	2
138	68	1	1	2
139	68	1	2	2
152	74	1	1	3
153	74	1	2	1
159	77	1	1	2
160	77	1	2	1
161	77	1	3	1
165	79	1	1	2
166	79	1	2	1
167	79	1	3	2
168	80	1	1	2
169	80	1	2	1
170	80	1	3	1
193	94	1	3	1
194	95	1	2	2
197	97	1	3	2
207	102	1	1	2
208	102	1	3	2
226	111	1	1	2
227	111	1	2	1
228	111	1	3	2
269	133	1	1	2
270	133	1	3	2
281	136	1	3	1
282	137	1	2	2
283	138	1	5	2
284	127	1	1	2
285	127	1	3	2
286	128	1	1	2
287	128	1	3	2
289	115	1	1	2
290	115	1	3	2
293	118	1	1	2
309	139	1	1	2
310	139	1	3	2
311	140	1	1	2
312	140	1	3	2
313	117	1	1	1
314	117	1	2	3
317	143	1	3	2
318	144	1	2	2
319	130	1	1	2
320	130	1	2	2
321	114	1	1	1
322	114	1	3	3
323	98	1	1	2
324	98	1	2	1
325	98	1	3	2
326	99	1	1	2
327	99	1	2	1
328	99	1	3	2
339	119	1	1	1
340	119	1	2	3
341	120	1	1	2
342	120	1	3	2
343	105	1	1	2
344	105	1	2	1
345	105	1	3	1
352	123	1	1	2
353	123	1	3	2
354	106	1	1	3
355	106	1	2	1
356	124	1	1	2
357	124	1	3	2
358	109	1	1	3
359	109	1	2	1
362	125	1	1	2
363	125	1	3	2
364	96	1	1	2
365	96	1	2	2
366	145	1	6	2
367	132	1	1	2
368	132	1	2	2
369	1	1	1	3
370	1	1	2	1
371	147	1	1	3
372	147	1	2	2
373	83	1	1	2
374	83	1	2	1
375	5	1	1	3
376	5	1	2	1
377	5	1	3	1
378	84	1	1	2
379	84	1	2	1
380	85	1	1	3
381	85	1	2	1
382	6	1	1	3
383	6	1	2	1
384	6	1	3	1
385	86	1	1	3
386	86	1	2	2
387	148	1	1	2
388	148	1	3	2
389	87	1	1	3
390	87	1	2	1
391	71	1	1	3
392	71	1	2	1
393	12	1	1	3
394	12	1	2	1
395	13	1	1	3
396	13	1	3	2
397	14	1	1	4
398	14	1	2	1
399	15	1	1	3
400	15	1	2	1
401	15	1	3	1
402	89	1	1	2
403	89	1	3	2
404	90	1	1	3
405	90	1	2	2
406	150	1	1	2
407	150	1	3	2
408	19	1	1	4
409	19	1	2	1
410	151	1	1	1
411	151	1	2	1
412	25	1	1	2
413	25	1	2	1
414	64	1	1	2
415	64	1	3	2
416	65	1	1	2
417	65	1	2	1
418	65	1	3	2
419	66	1	1	2
420	66	1	3	2
421	69	1	1	2
422	69	1	2	1
423	69	1	3	2
424	70	1	1	2
425	70	1	2	1
426	70	1	3	1
427	57	1	1	3
428	57	1	3	1
429	72	1	1	2
430	72	1	2	1
431	72	1	3	1
432	73	1	1	2
433	75	1	1	2
434	75	1	2	1
435	75	1	3	1
436	76	1	1	2
437	76	1	3	2
438	78	1	1	2
439	78	1	2	1
440	78	1	3	2
441	88	1	1	2
442	88	1	3	2
443	81	1	1	1
444	81	1	3	3
445	82	1	1	2
446	82	1	2	1
447	153	1	1	2
448	101	1	1	2
449	101	1	2	2
450	121	1	1	2
451	121	1	2	1
452	121	1	3	1
453	157	1	2	2
454	110	1	2	1
455	110	1	3	1
456	129	1	1	2
457	129	1	2	2
458	131	1	1	2
459	131	1	3	2
460	100	1	2	2
461	103	1	1	2
462	103	1	2	2
463	104	1	1	2
464	104	1	2	1
465	104	1	3	1
466	122	1	1	2
467	122	1	2	1
468	122	1	3	1
469	108	1	1	2
470	108	1	2	1
471	108	1	3	1
472	126	1	1	2
473	113	1	1	2
474	113	1	3	2
475	159	1	1	1
476	159	1	2	3
477	116	1	1	2
478	116	1	2	2
479	91	1	1	2
480	91	1	2	2
\.


--
-- Data for Name: modul_lernergebnisse; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_lernergebnisse (modul_id, po_id, lernziele, kompetenzen, inhalt) FROM stdin;
1	1	Die Studierenden kennen wichtige grundlegende\nResultate und Methoden der Algorithmik und können\ndiese auf ausgewählte Problemstellungen anwenden.\nSie gewinnen detaillierte Einblicke in die\nproblemspezifische Optimierung von Algorithmen mittels\ngeeignet gewählter Datenstrukturen und können diese\nnachvollziehen und anwenden.\nSie kennen und beherrschen die Grundzüge der\nAnalyse von Algorithmen und Problemen.		Wichtige Grundprobleme der Informatik und ihre Lösung\nmit Algorithmen und unterstützenden Datenstrukturen\nunter Berücksichtigung des Aufwandes, u.a.:\nSortieren (Quick/Heap/Bucketsort; Buckets, Priority-\nQueues)\nProblemlösung mittels Suche (Baumstrukturen,Tiefen-,\nBreitensuche, iterative Deepening, BestFirst, A*)\nZugriffsstrukturen (Indices, Hashing)\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 5 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nGreedy-Algorithmen (Kruskal, Huffman-Codierung,\nFractional Knapsack)\nGrenzen der praktischen Lösbarkeit (Komplexität) von\nProblemen am Beispiel von Wegeproblemen:\nAlgorithmik (Dijkstra-Varianten, MST) und\nApproximation (TSP/MST)\nQuerschnittsthema: Analyse von Algorithmen (Kosten,\nOptimalität, Approximierbarkeit).
3	1	Die/der Studierende ist in der Lage, innerhalb einer\nvorgegebenen Frist entweder\n• eine praxisorientierte Aufgabe aus dem\nSpannungsfeld Informatik und Design sowohl in\nihren fachlichen Einzelheiten als auch in den\nthemen- und fachübergreifenden\nZusammenhängen nach wissenschaftlichen\nMethoden selbständig zu bearbeiten und zu\nlösen und zu dokumentieren.	\N	Es wird ein in der Regel praxisorientiertes Problem aus\nden Disziplinen Informatik und Design mit den im\nStudium erlernten Konzepten, Verfahren und Methoden\nin begrenzter Zeit unter Anleitung eines erfahrenen\nBetreuers gelöst.
2	1	Die Studierenden kennen mögliche Berufsfelder,\nArbeitszusammenhänge und Berufsperspektiven in der\nInformatik und im Design und erarbeiten individuell ein\nPortfolio mit eigenem Kompetenzprofil.\n• Indem (nach Möglichkeit) eine\nAuseinandersetzung und ein Austausch mit der\nBerufspraxis stattfindet (Anforderungen an\nAbsolventen)\n• Indem Berufsperspektiven analysiert,\nrecherchiert und entwickelt werden.\n• Indem die Themen Konzeptentwicklung,\nVerfassen von Exposés, Zeit- und\nKostenmanagement sowie Präsentation,\nReflexion/Argumentation am praktischen\nBeispiel erprobt werden\n• Indem die eigenen Kompetenzen,\nEntwicklungsziele bzw. Karrierestrategien\nherausgearbeitet und dargestellt werden\n(Portfolio und Bewerbungsmappe)\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 7 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nUm später die eigene Selbstdarstellung und\nSelbsteinordnung der eigenen Fähigkeiten für den\nEinstieg in den Beruf vorbereiten zu können.	Kürzel: BFK Untertitel: Berufsvorbereitung und Portfolioerstellung Studiensemester: 4. (Bachelor) Modulverantwortliche(r): Prof. Katja Becker Dozent(in): Lehrende des Studiengangs Informatik und Design Sprache: Deutsch, Englisch bei Bedarf Zuordnung zum Curriculum: IN ID WI - 4 - Lehrform / SWS: 2 SWS Übung (Seminar) Gruppengröße: Standard Arbeitsaufwand: Kontaktzeit: 28 Zeitstunden Selbststudium: 62 Zeitstunden Leistungspunkte: 3 Turnus: Sommersemester, jährlich Teilnehmerzahl: Nicht begrenzt Anmeldungsmodalitäten: Anmeldung über den Moodle-Kurs zu diesem Modul	Vorlesungen, Übungen und Workshops zu den Themen:\n• Erstellung eines Portfolios mit eigenen\nArbeitsproben\n• Bewerbungsunterlagen, -training\n• Existenzgründung und Entrepreneurship\n• Formulieren eines Projektexposés\n• Zeitmanagement, Kostenkalkulation und\nErstellen eines Projektplans\nNach Möglichkeit werden Praxispartner aus der\nIndustrie in die Veranstaltung eingeladen (Vorträge zu\nTeilthemen, Einblick in Berufsalltag)
4	1	Die Studierenden können einfache interaktive\nAnwendungen konzeptionell und technisch so erstellen,\ndass Sie auf unterschiedlichen Plattformen (z.B.\nAndroid, iOS, Web, Windows Desktop, VR) lauffähig\nsind\nindem Sie\n• Die Trennung zwischen Anwendungslogik und\nGUI am Beispiel konkreter\nEntwicklungsumgebungen (z.B. Flutter, Xamarin,\nReact Native) verstehen und auf den praktischen\nEinsatz transferieren.\n• Entsprechende Design Patterns analysieren und\ndiskutieren können (z.B. MVVM)\n• Grundlegende Vorkenntnisse zu Usability,\nLayout und Gestaltung bei der Umsetzung von\nCross-Platform Anwendungen demonstrieren\n• Auch über Geräteklassen hinweg Unterschiede\nund Gemeinsamkeiten analysieren und deren\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 11 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nAuswirkungen auf die Entwicklung einer\nplattformübergreifenden Anwendung bewerten\nUm später\n• bei der Planung und Konzeption komplexerer\nAnwendung von vorneherein unterschiedliche\nPlattformen bedienen zu können\n• In Projekten im Studium oder im Beruf tiefer in\ndie Thematik der Cross-Platform Entwicklung\neinsteigen zu können und eigenständige, neue\nAnwendungen entwerfen und implementieren zu\nkönnen.		Einführung in die plattformübergreifende Entwicklung\nEinführung in aktuelle Frameworks, z.B. Flutter,\nXamarin, ReactNative mit Fokus auf eines, das dann im\nProjekt genutzt wird sowie die zugrundeliegenden\nProgrammiersprachen (z.B. Dard, C#, Javascript).\nHierbei wird auch mit Hilfe von bereitgestellten\nMaterialien ein hoher Selbstlernanteil integriert.\nSoftwaretechnische Grundlagen für\nplattformübergreifende Entwicklung, z.B. Design-\nPatterns wie MVVM\nIn Projektgruppen wird das theoretisch erlernte Wissen\ndirekt im Rahmen eines realitätsnahen\nSemesterprojekts oder mehreren\nVorlesungsbegleitetenden kleinen Projektaufgaben in\ndie Praxis überführt.
32	1	Die Studierenden kennen die wichtigsten\nSprachelemente der Sprache Python.\nDie Studierenden können zur Lösung vorgegebener\nAufgaben (ggf. aus dem Designing-Projekt heraus) in\nder Sprache Python das 3D-Modellierungssystem\nBlender um spezifische Funktionalität erweitern.\nDamit sind die Studierenden später in der Lage, Python-\nProgramme auch für andere Aufgaben und Kontexte zu\nschreiben. Zudem können die Studierenden Blender um\nspezielle Features (geometrische Besonderheiten,\nAutomatismen) erweitern und die Erweiterungen über\ndie Blender-GUI zugänglich machen.	\N	Eigenschaften und Elemente der Sprache Python, Verwendung von Python in Blender, Beispiele für in Python geschriebene Blender-Scripte. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
26	1	Die Studierenden erwerben berufsorientierte\nenglischsprachige Diskurs- und Handlungskompetenz\nunter Berücksichtigung (inter-)kultureller Elemente.	\N	Die Veranstaltung führt in die Fachsprache anhand\nausgewählter Inhalte z.B. aus folgenden Bereichen ein:\nAI (Artificial Intelligence), Basic Geometric and\nMathematical Terminology, Biometric Systems,\nDiagrammatic Representation, Display Technology,\nNetworking, Online Security Threats, Robotics, SDLC\n(Software Development Life Cycle).
5	1	Die Studierenden kennen die Grundlagen von\nDatenbanksystemen und deren Einsatz in der Praxis.\nDie Studierenden kennen die wesentliche\nVorgehensweise und Methoden, um\nRealweltausschnitte zu modellieren und in gut\nstrukturierte Datenbankschemata zu überführen.\nDie Studierenden sind in der Lage, Informationssysteme\nunter Einsatz von Datenbankprogrammierschnittstellen\nund der Datenbanksprache SQL zu entwickeln und zu\noptimieren.	\N	Die Veranstaltung bietet einen Einstieg in\nDatenbanksysteme und deren Anwendungen in der\nPraxis. Der Inhalt der Vorlesungen, Übungen und\nPraktika ist wie folgt strukturiert:\n• Einführung in Datenbanksysteme\n• Anwendungsfälle von Datenbanksystemen in der\nPraxis\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 13 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• Das Datenbankmanagementsystem und seine\nKomponenten\n• Datenbankschemata und Konsistenzbedingungen\n• Relationale Algebra\n• Grundlagen SQL und SQL-Optimierung\n• (Optional) XML\n• (Optional) Ausblick auf nicht-relationale und\nNOSQL Datenbanken\nÜbungen und Praktikum enthalten praktische\nAufgaben zum Datenbankdesign und der Anwendung\nvon SQL.
7	1	Die Studierenden kennen und verstehen den\nAnwendungshintergrund der Extended Reality (XR). Sie\nkennen die zentralen Begriffe, Konzepte Technologien\nund Anwendungsfelder, können Beispiele nennen und\nsie gegenseitig abgrenzen\nDie Studierenden kennen und verstehen die zentralen\nMethoden, Verfahren und wichtige Algorithmen aus der\nComputergrafik inklusive grafischer Interaktion und der\nComputeranimation als Grundlage der XR. Dieses\nWissen umfasst auch mathematisch-algorithmischen\nHintergrund sowie grundlegende Kenntnisse zu einigen\nrelevanten physikalische und physiologische Aspekten.\nDie Studierenden können auf der Basis vorgegebener\nAufgabenstellungen einfache computergrafische\nBerechnungen z.B. zu Transformationen, zur\nBeleuchtung und Texturierung sowie zu zeitabhängigen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nFunktionen der Computeranimation ausführen. Sie\nfinden zu gestellten Problemen eine angemessene\nMethodik oder ein algorithmisches Verfahren zur\nLösung und können die Methodik oder das Verfahren\nanwenden.\nDie Studierenden können Konstellationen (z.B.\nGeometrie, Material, Geräteauflösung) hinsichtlich\nQualität der Visualisierung, Rechengeschwindigkeit, der\nEchtzeitfähigkeit oder für die Interaktion beurteilen. Sie\nkennen relevante Sonderfälle.\nDie Studierenden besitzen Basiswissen aus der\nMedientechnik über Signale, über den Umgang mit\nAudio- und Video-Material, zu Kompressionsverfahren\nsowie über Geräte zur Visualisierung und zur Benutzer-\nEingabe (inkl. Tracking).\nDie Studierenden besitzen die theoretischen\nKenntnisse, um im Rahmen der Projektmodule und\nLearning Units des 4. und 5. Semesters sowie im\nRahmen ihrer Bachelorarbeit 3D-Modelle,\nComputeranimationen, Computerspiele und XR-\nAnwendungen auf der Basis von geeigneten\nWerkzeugen konzipieren und implementieren zu\nkönnen.\nDie Studierenden besitzen das theoretische Rückzeug,\num auch weiterführenden und vertiefenden Stoff z.B. in\neinem Masterstudium bewältigen zu können und um\nforschungsorientierte Arbeiten im Studium und Beruf auf\ndem Gebiet XR durchführen zu können.	\N	Einführung und Zentrale Konzepte: Extended Reality\n(Virtual Reality, Augmented Reality, Mixed Reality,\nTracking), XR-Anwendungen und ihre Merkmale,\nBasistechnologien 3D-Computergrafik,\nComputeranimation, Medientechnik\nFarbe und menschliche Wahrnehmungs-Aspekte\n(Mach-Band-Effekt, Aliasing in Darstellungen und im\nzeitlichen Verläufen, Wahrnehmung von Bewegung)\nKonzept der Rendering-Pipeline und grafische\nInteraktion: 3D-Modell und seine Bestandteile, Pipeline-\nStufen, Bilder und Pixel, Rückbeziehung von Benutzer-\nEingabe auf das 3D-Modell\nGeometrische Modelle, insbesondere Polygone und\nMesh-Modelle (Vertex-Konzept, Flächen und Eckpunkt-\nNormalen)\nTransformationen und Transformationsmatrizen:\nHomogene Koordinaten, Affine Abbildungen,\nTranslationen, Rotationen und Skalierungen zur\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 18 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nObjektmanipulation, Koordinatentransformationen für\ndas Rendering und beim Tracking\nProjektionen und Kameras: Perspektivische\nProjektionen für realistische Darstellungen,\nParallelprojektion für die interaktive 3D-Modellierung,\nVirtuelle Kamera, Ansichtspipeline\nBeleuchtung: Lokale Beleuchtungsmodelle (Ambiente,\ndiffuse, Spekulare Reflexion), Shading, Prinzipien\nglobaler Beleuchtung (Allgemeine\nBeleuchtungsgleichung, Raytracing, diffuse Verfahren)\nTexturierung: Mapping-Verfahren, Blending\nInterpolationsbasierte Animation: Frame-Konzept,\nInterpolation von zeitabhängigen Werten entlang von\nLinien, Kurven und Pfaden Keyframe-Animation\nPhysikalisch basierte Animation: Kinematik, Festkörper\n(freier Fall, Kollisionen)\nAnimationstechniken: Kinematische Ketten und\nCharacter-Animation, Vorwärts- und Rückwärts-\nKinematik, Motion Capture, Constraints\nSignale, Audio, Video, Umgang mit Audio und Video-\nMaterial, Pre- und Postproduction,\nKompressionsverfahren, Geräte zur Visualisierung\n(Monitore, XR-Brillen), zur Benutzerinteraktion\n(Controller), Tracking-Sensoren.
8	1	Die Studierenden können ein digitales interaktives\nProdukt mit signifikantem Software-Anteil auf Basis\neines bekannten Problems planen und implementieren,\nindem sie:\n• Sich in einem Projektteam organisieren und\nMethoden des agilen Projektmanagements\nanwenden\n• Im Studium erlernte Methoden, Konzepte und\nTechniken kombinieren, arrangieren, modifizieren\nund anwenden\n• Mögliche Lösungsansätze (z.B. in der\nwissenschaftlichen Fachliteratur oder\nEntwicklerblogs etc.) prüfen, bewerten und\nevaluieren\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 20 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• Methoden der mensch-zentrierten Entwicklung auf\ndie konkrete Projektstellung anpassen und\nanwenden\n• Komplexe Aufgaben sinnvoll strukturieren,\ndekompilieren und entsprechend den individuellen\nFachkompetenzen als Team effizient bearbeiten\n• Typische Schnittstellenprobleme in der\nAbstimmung und Zusammenarbeit sowohl auf\ntechnisch-fachlicher als auch auf sozialer Ebene\nmit Hilfe von Projektmanagementmethoden\nbewältigen\n• Zwischenergebnisse dokumentieren und\npräsentieren\n• Fragen der ökologischen, ökonomischen und\nsozialen Nachhaltigkeit und der gesellschaftlichen\nKonsequenzen diskutieren und kritisieren\num später\n• Die Kenntnisse und Kompetenzen verschiedener\nModule in einem realistischen Projekt zu vertiefen\nund zusammenzuführen.\n• Über die reinen Fachkompetenzen hinaus\nErfahrungen und Herausforderungen bei der\nZusammenarbeit im Team über einen längeren\nZeitraum mit einer komplexen Aufgabe\nkennenlernen und Lösungsstrategien entwickeln\nzu können\n• Verantwortungsvoll Software entwickeln, welche\ndie Prinzipien der ökologischen, ökonomischen\nund sozialen Nachhaltigkeit berücksichtigt.	\N	Im Rahmen des Großprojekts BUILDING bearbeiten die\nTeilnehmer in Projektgruppen eine typische größere\nAufgabenstellung aus dem Bereich der Informatik und\nDesign mit Schwerpunkt BUILD, das heißt Entwicklung.\nIn der Regel wird ein Thema pro Semester angeboten.\nDie Projektteams werden durch Mentoren bei der\nProjektarbeit begleitet. In regelmäßigen\nProjektsitzungen werden im Rahmen einer\nQualitätssicherung die Zwischenergebnisse von den\nTeams durch Präsentation und Vorführung vorgestellt\nund diskutiert.\nZudem belegen Studierende thematisch passende\nLearning Units, die notwendige Fachkompetenzen\nvermitteln.\nIm Gegensatz zum Projekt DESIGNING wird hier eine\ngrundlegende Problemstellung bereits weitgehend\nvorgegeben. Dennoch besteht ein hoher Freiheitsgrad\nhinsichtlich der möglichen Lösungsansätze. Dies\numfasst die selbstständige Durchführung des Projekts,\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 21 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\ninklusive Ableitung von User Stories, Prototyping, sowie\nRealisierung/Implementierung und Test bis zur\nDokumentation. Im Idealfall baut das Projekt BUILDING\nauf den Ergebnissen des DESIGNING Projekts auf und\nkann auf diese Vorarbeiten zu Konzept und Design\nzurückgreifen.\nAnwendung von grundlegenden Projektmanagement-\nMethoden für Definition, Planung, Kontrolle und\nRealisierung des Projekts.\nEntwicklung im Team unter Beteiligung von\nrealen/potentiellen Anwendern und Benutzern.\nDas Projektthema wird rechtzeitig vor Beginn der\nVeranstaltung bekannt gemacht. Es wird versucht,\npraxisnahe Projekte auch von hochschulexternen\nAnwendern im Bereich Informatik und Design zu\nakquirieren.\nDas Großprojekt BUILDING hat je nach Themenstellung\neinen Schwerpunkt im Bereich der App-Entwicklung,\nCross-Platform Entwicklung, AR/VR Entwicklung unter\nBerücksichtigung von Methoden der mensch-zentrierten\nEntwicklung (z.B. Evaluation).
55	1	Die/der Studierende ist in der Lage, innerhalb einer\nvorgegebenen Frist eine praxisorientierte Aufgabe aus\nder praktischen Informatik sowohl in ihren fachlichen\nEinzelheiten als auch in ihren themen- und\nfachübergreifenden Zusammenhängen nach\nwissenschaftlichen und fachpraktischen Methoden\nselbstständig zu bearbeiten und zu dokumentieren.	\N	Es wird ein in der Regel praxisorientiertes Problem aus\nder praktischen Informatik mit den im Studium erlernten\nKonzepten, Verfahren und Methoden in begrenzter Zeit\nunter Anleitung eines erfahrenen Betreuers gelöst.
56	1	Die Studierenden lernen die grundlegenden Konzepte\nund Verfahren von Betriebssystemen kennen. Sie\nerlangen die Fähigkeit, neue Betriebssystemkonzepte\nschnell begreifen, einordnen und bewerten zu können.	\N	Einführung in Betriebssysteme\nProzesse\nSpeicherverwaltung\nDateisystem\nEin-/Ausgabe\nUnix
9	1	Die Studierenden können ein digitales interaktives\nProdukt von der Problemanalyse bis hin zu einem\nerlebbaren Prototypen erschaffen,\nindem sie:\n• Sich in einem Projektteam organisieren und\nMethoden des agilen Projektmanagements\nanwenden\n• Im Studium erlernte Methoden, Konzepte und\nTechniken kombinieren, arrangieren, modifizieren\nund anwenden\n• Mögliche Lösungsansätze (z.B. in der\nwissenschaftlichen Fachliteratur oder\nEntwicklerblogs etc.) prüfen, bewerten und\nevaluieren\n• Methoden der mensch-zentrierten Entwicklung auf\ndie konkrete Projektstellung anpassen und\nanwenden\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• Komplexe Aufgaben sinnvoll strukturieren,\ndekompilieren und entsprechend den individuellen\nFachkompetenzen als Team effizient bearbeiten\n• Typische Schnittstellenprobleme in der Abstimmung\nund Zusammenarbeit sowohl auf technisch-\nfachlicher als auch auf sozialer Ebene mit Hilfe von\nProjektmanagementmethoden bewältigen\n• Zwischenergebnisse dokumentieren und\npräsentieren\num später\n• Die Kenntnisse und Kompetenzen verschiedener\nModule in einem realistischen Projekt zu vertiefen\nund zusammenzuführen.\n• Über die reinen Fachkompetenzen hinaus\nErfahrungen und Herausforderungen bei der\nZusammenarbeit im Team über einen längeren\nZeitraum mit einer komplexen Aufgabe\nkennenlernen und Lösungsstrategien entwickeln zu\nkönnen	\N	Im Rahmen des Großprojekts DESIGN bearbeiten die\nTeilnehmer in Projektgruppen eine typische größere\nAufgabenstellung aus dem Bereich der Informatik und\nDesign mit Schwerpunkt Design.\nIn der Regel wird ein Thema pro Semester angeboten.\nDie Projektteams werden durch Mentoren bei der\nProjektarbeit begleitet. In regelmäßigen\nProjektsitzungen werden im Rahmen einer\nQualitätssicherung die Zwischenergebnisse von den\nTeams durch Präsentation und Vorführung vorgestellt\nund diskutiert.\nZudem belegen Studierende thematisch passende\nLearning Units, die notwendige Fachkompetenzen\nvermitteln.\nSelbstständige Durchführung des Projekts von der\nProblemanalyse und Nutzerforschung hin zu\nIdeenfindung, Konzepterstellung, Designentwürfe. Am\nEnde steht ein erlebbarer Prototyp, welcher mit\nverschiedenen Mitteln erreicht werden kann\n(Prototyping Werkzeug, Video Envisionment,\nPhysischer Prototyp, etc.).\nAnwendung von grundlegenden Projektmanagement-\nMethoden für Definition, Planung, Kontrolle und\nRealisierung des Projekts.\nInsbesondere für die Nutzerforschung sollen\nreale/potentielle Anwender und Benutzer beteiligt\nwerden.\nDie Projektthemen werden rechtzeitig vor Beginn der\nVeranstaltung bekannt gemacht. Es wird versucht,\npraxisnahe Projekte auch von hochschulexternen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 24 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nAnwendern im Bereich Informatik und Design zu\nakquirieren.\nDas Großprojekt DESIGNING hat je nach\nThemenstellung einen Schwerpunkt im Bereich der\nAnalyse, Konzeption, UI-, Interface-Gestaltung oder der\nMensch-Computer-Interaktion, wird aber zumeist\nAspekte aus mehreren Gebieten beinhalten.
10	1	Die Studierenden reflektieren fachspezifische und\ngesamtgesellschaftliche Entwicklungen und Trends mit\nBlick in die nähere Zukunft und die eigene Rolle in\ndiesem Kontext. Aktuelle Fragestellen können in die\nVeranstaltung eingebracht und bearbeitet werden.\n• Indem eine Auseinandersetzung mit aktuellen\nTechnologien Tools, technischen Trends (Hard-\nund Softwareseitig), aus den Disziplinen Informatik\nund Design stattfindet.\n• Indem aktuelle Veröffentlichungen und\nKonferenzbeiträge recherchiert und diskutiert\nwerden.\n• Indem die Themenbereiche durch Gastvorträge,\nKonferenzbesuche, Expertengespräche\naufgegriffen und diskutiert werden.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 26 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• Indem die eigene Rolle und das individuelle\nHandeln im späteren Berufskontext und zukünftigen\nArbeitswelt reflektiert werden.\nUm später im Beruf die Auswirkungen von\nSoftwareentwicklung auf die ökologische, ökonomische\nund gesellschaftliche Nachhaltigkeit bewerten und\nreflektieren zu können.	\N	Vorlesungen, Übungen und Workshops zu den Themen:\n• relevante technische, gesellschaftliche,\nökologische, ökonomisch und ethische\nFragestellungen oder Dilemmata\n• aktuelle fachspezifische Fragestellungen,\nForschungsergebnisse und Veröffentlichungen aus\nder Informatik und dem Design bzw. das\nVerknüpfen und Integrieren unterschiedlicher\nfachspezifischen Perspektiven\nNach Möglichkeit werden Praxispartner aus der\nForschung oder Praxis in die Veranstaltung eingeladen\n(Experten-Gespräche und/oder Ringvorlesungen)
65	1	Die Studierenden lernen die Begriffe und Verfahren der\ndigitalen Bildverarbeitung und die Konzepte und\nMethoden deren Programmierung kennen. Sie können\ndiese effektiv und strukturiert bei der Entwicklung\neigener Bildverarbeitungsprogramme einsetzen. Neben\nder Programmiermethodik lernen die Studierenden die\nVerwendung von Bibliotheken (OpenCV, CNN‘s)\nkennen und können diese für die Entwicklung eigener\nLösungen einsetzten.	\N	• Grundlagen / Begriffsbildung\n• Kameras\n• Bildverarbeitungsoperationen\n• Bildsegmentierung\n• Merkmale von Objekten\n• Klassifikation\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 47 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• Neuronale Netze, CNNs\n• Lehrsprachen: C / C++, Python, ipython notebooks
11	1	Die Studierenden sind in der Lage, die Ergebnisse ihrer\nBachelorarbeit in Informatik und Design, ihre fachlichen\nGrundlagen, und ihre Einordnung in den aktuellen\nStand der Technik, bzw. der Forschung, in einem\nVortrag zu präsentieren.\nDarüber hinaus können die Studierenden Fragen zu\ninhaltlichen Details, zu fachlichen Begründungen und\nMethoden sowie zu inhaltlichen Zusammenhängen\nzwischen Teilbereichen ihrer Arbeit selbstständig\nbeantworten und diese verteidigen.\nDie Studierenden können ihre Bachelorarbeit auch im\nKontext beurteilen und ihre Bedeutung für die Praxis\nund die Forschung einschätzen und sind in der Lage,\nauch entsprechende Fragen nach themen- und\nfachübergreifenden Zusammenhängen zu beantworten.	\N	Zunächst wird der Inhalt der Bachelorarbeit aus\nInformatik und Design im Rahmen eines Vortrags\npräsentiert. Anschließend sollen in einer Diskussion\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 28 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nFragen zum Vortrag und zur Bachelorarbeit beantwortet\nwerden.\nDie Prüfer können weitere Zuhörer zulassen. Diese\nZulassung kann sich nur auf den Vortrag, auf den\nVortrag und einen Teil der Diskussion oder auf das\ngesamte Kolloquium zur Bachelorarbeit erstrecken.\nDer Vortrag soll die Problemstellung der Bachelorarbeit,\nden Stand der Technik bzw. Forschung, die erzielten\nErgebnisse zusammen mit einer abschließenden\nBewertung der Arbeit sowie einen Ausblick beinhalten.\nJe nach Thema können weitere Anforderungen\nhinzukommen.\nDie Dauer des Kolloquiums ist in § 19 der\nPrüfungsordnung geregelt.
12	1	Die Studierenden erkennen die grundlegende\nBedeutung von diskreten Strukturen für Analyse,\nDarstellung und Lösung von Problemen in der\nInformatik.\nSie beherrschen die elementaren automatisierten\nBeweisverfahren der Logik und können diese\nanwenden.\nSie kennen die grundlegenden Begrifflichkeiten der\nGraphentheorie und können Probleme entsprechend\ndarstellen. Ausgewählte Problemstellungen können sie\nlösen.\nSie kennen und beherrschen die Grundzüge der RSA-\nVerschlüsselung (Zahlentheorie), von\nEntscheidungsbäume und bayes’schem Schliessen\n(Data Mining / Machine Learning).	\N	Historischer Abriss zur Entwicklung und Bedeutung der\nLogik für die Informatik (Frege, Russell, Hilbert, Gödel,\nTuring, Post) und zu den Grenzen der Berechenbarkeit.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 30 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nExkurs: boole’sche Schaltkreise als Modell des\nBerechnens (inkl. Ausblick auf Funktionen und Logik).\nGrundlegende Begriffe und Konzepte der Mengenlehre\n(u.a. Eigenschaften von Funktionen, Abzählbarkeit)\nLogische Problemformulierung und Problemlösung\n(Aussagenlogik und Klassenkalkül 4/5, Datalog 1/5)\nAusgewählte diskrete Strukturen und Probleme:\nZahlentheorie (RSA), Entscheidungsbäume, diskrete\nWahrscheinlichkeiten/Naive Bayes, Graphentheorie\n(Wegfindung), Kombinatorik (kombinatorische\nExplosion).\nAufwand: Historie (10%), Mengen und Logik (60%),\nweitere diskrete Strukturen (30%)
42	1	Die Studierenden kennen und verstehen die wichtigen\nFunktionen zum Erstellen von Computeranimationen auf\nstatischen 3D-Modellen mit dem Werkzeug Blender,\nderen Konstruktion im Modul „3D-Modellierung“ erlernt\nwurde.\nDie Studierenden kennen und verstehen die\nZusammenhänge zwischen der Theorie über die\nGrundlagen der Computeranimation aus dem Modul\n„Extended Reality“ (Physiologische Faktoren,\nTemporäres Aliasing, Interpolation, Vorwärts- und\nInverse Kinematik in der Character-Animation,\nConstraints) und der Praxis einer Animationserstellung\nin Blender.\nDie Studierenden können Animationsentwürfe für 3D-\nModelle aus dem Designing-Projekt mit Hilfe der in ANI\nerworbenen Kenntnisse und auf der Basis von Blender\nals Computeranimationen umsetzen und in das Build-\nProjekt integrieren. Alternativ oder ergänzend zu\nAufgaben aus dem Designing-Projekt können die\nStudierenden vorgegebene Aufgaben zur Erstellung von\nComputeranimationen mit dem Werkzeug Blender lösen\nsowie ihre Vorgehensweise erklären und begründen.\nDie Studierenden sind in der Lage, ihre Kenntnisse und\nFertigkeiten der Animations-Entwicklung im Hinblick auf\nschwierigere Anforderungen und andere Werkzeuge im\nweiteren Studium und im Beruf zu erweitern.	\N	Überblick über die Funktionen zur Erstellung von Computeranimationen mit Blender unter Bezug zum Modul „Extended Reality“. Regeln und Prinzipien „handwerklich“ guter Computeranimationen Zentrale Konzepte und Funktionen zur Animationsentwicklung mit Blender - Keyframe-Animation: Timeline, Dope Sheet Editor, Graph Editor, Pfad-Animation
40	1	WAS\nDie Studierenden kennen und verstehen Mechanismen,\nKonzepte und Einsatzmöglichkeiten von Bildern/Icons\nund deren gestalterische Umsetzung und Aufbereitung\nmit digitalen Mitteln.\nWOMIT\n• Indem Basiswissen zur Farbgestaltung und -\npsychologie sowie Bildaufbau und -komposition\nvermittelt wird.\n• Indem Bildwelten und Entwurfsaufgaben im Bereich\nBildkonzeption und Bildgestaltung in Einzelarbeit\noder in der Gruppe erarbeitet und gestalterisch\numgesetzt werden.\n• Indem Konzepte und Möglichkeiten der\ngestalterischen Aufbereitung von Bildern vorgestellt\nund erprobt werden.\n• Indem praktische Fertigkeiten im Umgang mit der\nKamera (Fotografie) und Adobe Photoshop als\nEntwurfstool erlangt werden.\nWOZU\nBilder sind grundlegender Bestandteil in der Konzeption\nund Entwicklung von Benutzerschnittstellen. Die\nGrundprinzipien der Bildgestaltung können dem\nGroßprojekt Anwendung finden.	\N	Farbe in der Gestaltung (Farbsysteme, Farbkomposition, Farbpsychologie etc.), Experimentelle Bildgestaltung, Bildkomposition, Bildgestaltung als Teil des Assetdesigns von Web-/Softwareprojekten (Bildkonzeption, Bildoptimierung, Freistellen, Bildrandgestaltung, Hintergrundbilder, Kachelbilder), Bildtypografie, Buttondesign, Icondesign, Infografik, Reportinggrafik, Bildkonzeption, Entwicklung von Bildwelten (Foto, Illustration oder Grafik) Die Studierenden führen in Hausarbeit Gestaltungsentwürfe zu vorgegebenen Aufgaben durch. Im Praktikum finden dazu individuelle Korrekturbesprechungen statt.
41	1	WAS\nDie Studierenden kennen und verstehen den Nutzen\nvon konsistenten Erscheinungsbildern in digitalen\nAnwendungen und können die visuellen und\ninteraktiven Komponenten eines Corporate Designs\nbewusst einsetzen.\nWOMIT\n• Indem Grundbegriffe, Bestandteile und Richtlinien\ndes Brand und Corporate Designs kennengelernt\nund verstanden werden.\n• Indem Praxisbeispiele im Bereich Brand Identity,\nMarkenarchitektur usw. analysiert, reflektiert und\neigene Lösungswege entwickelt werden.\nWOZU\nEinheitliche und konsistente Markenerlebnisse und\nNutzererfahrungen sind sehr zentral für den Erfolg von\nProdukten, Services oder Devices und damit ein\nwichtiger Baustein für das Projektstudium. Das Wissen\nkann in Folgeveranstaltungen angewandt werden.	\N	Fachbegriffe und Abgrenzung Corporate und Brand Identity/Design, Nutzen, Funktion und Qualitätsstandards, Corporate Design-Prozess, Markenbild/-wahrnehmung, Visuelle Codes und Interactive Branding Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
27	1	Die Studierenden können moderne Cloud Plattformen\nund Microservicearchitekturen für die Umsetzung von\nwebbasierten Anwendungen zielgerichtet adaptieren\nund einsetzen\nIndem sie\n• Die Möglichkeiten und Herausforderungen von\nCloud Computing, Virtualisierung und\nContainertechnologie und Microservices\ndiskutieren und analysieren\n• In Kleingruppen anhand konkreter Vorgaben und\nunter Anleitung beispielhaft diese Technologien\nanwenden und deren Eignung Beurteilen\nUm später / damit sie\n• Im parallelen Großprojekt in der Lage sind,\nCloud Plattformtechnologien auszuwählen und\neffektiv zu integrieren\n• In späteren Projekten (z.B. Abschlussarbeit) und\nim Beruf moderne und komplexe\nWebanwendungen und Verknüpfungen zwischen\ndiesen realisieren zu können	\N	• Rückblick Computerarchitekturen und Internettechnologien • Cloud Architekturen und Plattformen • Hypervisor, Virtualization, Container (Hyper-V, VirtualBox, Docker) • Cluster Management (Kubernetes, Rancher) • Web Services, REST API, Microservices, Serverless Computing Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt
43	1	Die Studierenden kennen und verstehen die\ngrundlegenden Begriffe und Definitionen im Kontext von\nGame, Play und Gamification. Sie können Beispiele\ndazu nennen und beschreiben. Sie kennen wichtige\nKlassifizierungen von Games und können Game-\nEigenschaften den Klassen zuordnen.\nDie Studierenden kennen die wichtigen Elemente von\nGames und verstehen deren Bedeutung. Sie kennen die\nwichtigsten Spielmechaniken. Sie sind in der Lage,\nexistierende Spiele hinsichtlich der Elemente und\nMechaniken zu analysieren.\nDie Studierenden kennen eine Klassifizierung von\nSpielertypen. Sie besitzen ein grundlegendes\nVerständnis für wichtige psychologische Faktoren. Sie\nkönnen dieses Wissen auf Game-Klassen und Game-\nElemente beziehen.\nDie Studierenden kennen wichtige Probleme, die durch\nGaming bei Benutzern entstehen können.\nDie Studierenden sind in der Lage, Game-Elemente für\ndas Designing-Projekt mit den in der Learning Unit\nerlernten Methoden zu entwerfen und im Projekt\nkonzeptuell einzubetten. Dies kann in Form einfacher\nEntwürfe für Spielmechaniken, zur Gamifizierung oder\neinfacher Spiele (Mini-Spiele, Quizzes) erfolgen.	\N	Begriffe, Definitionen und Beispiele für Games, Play und Gamification. Klassifizierungen von Games (z.B. nach Genres, nach eingesetzten Ein-/Ausgabe- und Visualisierungstechnologien, Single- und Multiplayer) Elemente von Games und Spielmechaniken (z.B. Spielziel, Regeln auf unterschiedlichen Ebenen, Konflikt und Kooperation, Belohnungsstrukturen, Feedback, Levels)
28	1	Die Studierenden können einfache Spezialeffekte\nangefangen von z.B. speziellen Lichteffekten oder\nOberflächen-Texturierungen bis hin zu dynamischen\nEffekten wie Wasser mithilfe von Shadern\nprogrammieren und in Unreal-Modelle importieren.\nDie Studierenden sind damit in der Lage, einfache\nAnforderungen nach Spezialeffekten aus dem\nDesigning-Projekt im Build-Projekt umzusetzen.	\N	Fragment-(Pixel-)Shader, Vertex-Shader, Geometry- Shader, eine Shader-Sprache wie z.B. GLSL oder HLSL Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
44	1	WAS\nDie Studierenden verfügen über theoretisches Wissen\nund praktische Fertigkeiten, um Informationen visuell\nleicht verständlich aufzubereiten. Sie sind in der Lage,\nDaten und Zusammenhänge zu abstrahieren und zu\nvisualisieren, sie unter Berücksichtigung der jeweiligen\nZielgruppe und des Kommunikationszusammenhangs\ndarzustellen.\nWOMIT\n• Indem sie aktuelle (Multimedia-/Visualisierungs-)\nTechniken kennen und verstehen\n• Indem sie Kommunikationsprozesse in analogen,\naudiovisuellen und digitalen Medien, wie\nErklärfilmen, Infografiken und Illustrationen planen\nund optimieren.\n• Indem sie erproben, Inhalte verständlich\naufzubereiten und benutzerfreundlich zu gestalten\nWOZU\nDie Fähigkeit zur Visualisierung von\nBenutzerschnittstellen kann in Folgeveranstaltungen\nangewandt werden.	\N	verständlich aufzubereiten und benutzerfreundlich zu gestalten WOZU Die Fähigkeit zur Visualisierung von Benutzerschnittstellen kann in Folgeveranstaltungen angewandt werden. Inhalt: Wahrnehmungspsychologie, Visuelle Kommunikation, Informationsdesign/Informationsvisualisierung, Datendimensionen, Diagramme, Leitsysteme, Visualisierungstechniken, Technische Illustration, Multimediale Werkzeuge aus dem Kommunikations- und Webdesign. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
45	1	Die Studierenden können Prototyping Werkzeuge und\nMethoden für Interaktive Anwendungen analysieren,\nvergleichen und hinsichtlich ihrer Eignung für\nunterschiedliche Fragestellungen bewerten\nindem Sie\n• Verschiedene Arten und Ausprägungen von\nPrototypen in der\nSoftwareentwicklung/Interaktionsdesign\nbegreifen\n• Anhand vorgegebener Aufgabenstellungen\nverschiedene Werkzeuge und Methoden\nausprobieren und deren Eignung beurteilen\n• Die Möglichkeiten und Restriktionen der\nWerkzeuge und Methoden gegenseitig\npräsentieren und kritisieren\nUm später / damit sie…\n• Im parallelen Großprojekt in der Lage sind,\nPrototyping Werkzeuge und Methoden\nauszuwählen und zielführend einzusetzen\n• Diese Kompetenz im Rahmen von\nSoftwareentwicklungsprojekten einsetzen\nkönnen, um frühzeitig Design-Iterationen\nanzustoßen.	\N	Es werden zunächst verschiedene Methoden des Prototyping vorgestellt, beispielsweise high- vs. low- fidelity Prototypen, Manifestations und Filter, Vertical und Horizontal, Interactive und Static. Anschließend werde passende Werkzeuge in Kleingruppen untersucht und für konkrete Aufgabenstellungen angewendet. Beispielsweise Prototyping Tools wie Figma, aber auch Video Envisonment durch ensprechende Videoproduktion. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt
51	1	Die Studierenden kennen den User Experience\nWorkflow und die Grundlagen der Gestaltung von\ngrafischen Benutzeroberflächen und können die\nentsprechenden Methoden und Werkzeuge\nprojektbezogen auswählen auf verschiedene Kontexte\nanwenden.\nIndem sie Grundlagenwissen zur Usability und User\nExperience sowie zum User Interface Design\nkennenlernen. Dazu gehört die Analyse der\nNutzer:innen, die Erstellung von Wireframes und\nPrototypen und das Testen mit den jeweiligen\nNutzer:innengruppen. Ein weiterer Fokus liegt in der\nKonzeption und der Gestaltung von mobilen\nAnwendungen und den komplexen, responsiven\nScreendesigns für gängige Ausgabemedien (Desktop,\nTablet, Smartphone und Smartwatch) mit einem\nPrototypingtool wie Adobe XD, Sketch oder Figma.\nUm später unterschiedliche Benutzeroberflächen an\nverschiedene Schnittstellen und Zusammenhängen\nnutzer:innenzentriert entwickeln und testen zu können.	\N	Einführung User Experience und User Interface Design (UX Design Prozess und Workflows), User Research (z. B. Interviewtechniken), Analysetechniken (Nutzer:innen Ziele/Bedürfnisse, Personas, Journey Maps), Struktur/Navigation (User Flows, Informationsarchitektur), Interaktions Design, Designprinzipien und -patterns, Mobile UX, Interaktive Prototypen. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
46	1	Die Studierenden kennen und verstehen die wichtigen\nFunktionen zum Entwurf, zur interaktiven Konstruktion\nund zur Generierung von Spiele-Welten auf der Basis\neiner Game Engine wie Unreal.\nDie Studierenden können vorgegebene Aufgaben (ggf.\nmit Bezug zum Designing-Projekt) zur Erstellung von\nGame Leveln mit der Unreal Engine lösen sowie ihre\nVorgehensweise erklären und begründen.\nDamit sind die Studierenden später in der Lage, die\nUmgebung für ein Gameplay, das im Rahmen des\nDesigning-Projekts oder in einem anderen Kontext\nentworfen wurde, z.B. für das Build-Projekt spielbar zu\ngestalten und umzusetzen.Die Studierenden können.	\N	Überblick über die Unreal-Modellierungsfunktionalität zur interaktiven Level-Erstellung sowie zur Generierung von Leveln. Themen können sein: Verschiedene Arten von Content, Karten (Maps), Height Maps, Outdoor- und Indoor-Design, Strategien von Content-Generierung. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
39	1	Die Studierenden kennen die wichtigsten 3D-Modellierer\nam Markt und deren Haupt-Unterschiede.\nDie Studierenden kennen und verstehen die wichtigen\nFunktionen zum Konstruieren und Erweitern von\nstatischen 3D-Modellen auf der Basis eines GUI-\nbasierten Werkzeugs wie Blender.\nDie Studierenden kennen und verstehen die\nZusammenhänge zwischen der Theorie über die\nGrundlagen der Computergrafik aus dem Modul\n„Extended Reality“ (Geometrische Modelle,\nTransformationen, Beleuchtung, Texturierung) und der\nPraxis einer 3D-Modellierung in Blender.\nDie Studierenden können vorgegebene Aufgaben (ggf.\nmit Bezug zum Designing-Projekt) zur Konstruktion von\n3D-Modellen mit dem Werkzeug Blender lösen sowie\nihre Vorgehensweise erklären und begründen. Damit\nsind sie in der Lage, im weiteren Studienverlauf und im\nBeruf die häufige Anforderung nach benötigten 3D-\nModellen (oft in Form einfacher Assets) durch\nNeumodellierung oder über die Anpassung schon\nvorhandener importierter Modelle und Assets erfüllen zu\nkönnen.	\N	Wichtige Funktionen der interaktiven 3D-Modellierung unter Bezug zum Modul „Extended Reality“. Überblick über die wichtigsten Werkzeuge am Markt (z.B. Maya, 3ds MAX, Cinema4D) und Vergleich wichtiger Eigenschaften. Überblick über die Blender-Modellierungsfunktionalität Zentrale Konzepte und Funktionen zur 3D-Modellierung mit Blender - Blender-GUI: Elemente, Properties, User- Preferences, Navigation - Grundschritte: Objektvorbereitung, Materialien einstellen, Szene beleuchten, Rendern
30	1	Die Studierenden können NOSQL Datenbanken im\nkonkreten Kontext interaktiver, medienlastiger\nAnwendungen auswählen, adaptieren und einsetzen\nIndem sie…\n• Die Möglichkeiten und Herausforderungen von\nNOSQL Datenbanken verstehen und gegenüber\nklassischen relationalen Datenbanken abgrenzen\nkönnen\n• In Kleingruppen anhand konkreter Vorgaben und\nunter Anleitung beispielhaft diese Technologien\n(z.B. MongoDB) anwenden und deren Eignung\nbeurteilen.\nUm später…\n• Im parallelen Großprojekt in der Lage sind,\npassende Datenbanktechnologie auszuwählen und\neffektiv zu integrieren.\n• In späteren Projekten (z.B. Abschlussarbeit) und im\nBeruf moderne und komplexe interaktive\nAnwendungen in 2D und 3D auf Eben der\nDatenbank konzipieren und verstehen zu können.	\N	• Überblick nicht-relationale / NOSQL Datenbanken und deren Anfragesprachen. • Vor- und Nachteile der verschiedenen Formate . • Die Rolle von NOSQL Datenbanken bei der Entwicklung und dem Betrieb von interaktiven Anwendungen. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt
47	1	Die Studierenden können verschiedene Methoden der\nNutzerforschung vergleichen, praktizieren und kritisieren\nindem Sie\n• Für eine definierte Problemstellung geeignete\nMethoden der Nutzerforschung auswählen\n• Die entsprechende Datenerhebung vorbereiten\nund beispielhaft durchführen\n• Die gesammelten Daten transkribieren und in\nentsprechende Design Informing Models\nüberführen\n• Vor- und Nachteile der verschiedenen Methoden\nin der Gruppe vorstellen und diskutieren\nUm später\n• Im parallelen Großprojekt Nutzerforschung\nselbstständig konzipieren, durchführen und\nanalysieren zu können\n• Im Beruf die Schnittstellenkompetenz aufweisen,\nmit Spezialisten für Nutzerforschung\nzusammenarbeiten zu können	\N	Angelehnt an das parallel stattfindende Großprojekt wird eine Auswahl an Methoden der Nutzerforschung zunächst vorgestellt und anschließend durch die Studierenden seminaristisch analysiert, aufbereitet und eine beispielhafte Anwendung der Methoden konzipiert. In Kleingruppen erfolgt die praktische Anwendung und anschließende Diskussion und Analyse. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
48	1	Die Studierenden kennen die gesamte Breite moderner\nMethoden und Instrumente der Projektplanung und\nProjektsteuerung in der Informatik mit agilen Prozessen\nund können diese recherchieren, vergleichen und für\neinen passenden Kontext auswählen/anwenden.\nIndem Sie:\n• Moderne Methoden und Instrumente der\nProjektplanung und –steuerung kennen und\nverstehen\n• Erfolgsfaktoren und Hindernisse erfolgreicher\nTeamarbeit kennenlernen und in zukünftigen\nProjekten berücksichtigen können\n• Einzelne Vorgehensweisen und Tools im\nBereich Projektmanagement an einem konkreten\nBeispiel anwenden und reflektieren.\nUm später:\n• Für das Großprojekt relevante Methoden und\nInstrumente zur Strukturierung und Steuerung\nvon Projekten anwenden und Ergebnisse\npräsentieren zu können\n• in kleinen Teams ergebnisorientiert zu arbeiten\nund Konflikte in Projekten konstruktiv zu lösen\n• sich in Teams mit Mitgliedern unterschiedlichen\nAlters und unterschiedlicher Hintergründe\nzurecht zu finden\n• In der Lage zu sein, innerhalb eines\nvorgegebenen Zeitrahmen ein abgegrenztes\nProjekt planerisch umzusetzen.	\N	Theoretische Grundlagen des Projektmanagements/ Projektdefinition und Projektstrukturierung werden vermittelt und gehen einher mit der praktischen Anwendung grundlegender Projektmanagement- Methoden für Definition, Planung, Kontrolle und
49	1	WAS\nDie Studierenden kennen und verstehen globales,\nbarrierefreies Design, das kulturelle Unterschiede und\ndie Konzepte der inklusiven Gestaltung berücksichtigt.\nWOMIT\n• Indem Grundbegriffe, Richtlinien und Normen der\ninterkulturellen und barrierefreien Gestaltung\nkennengelernt und verstanden werden.\n• Indem Fallbeispiele verschiedener Kontinente\nanalysiert und bewertet werden.\n• Indem Fallbeispiele hinsichtlich der Konzepte des\nUniversal Designs/Design für Alle analysiert und\nbewertet werden.\n• Indem Methoden der transdisziplinären Forschung\n(Human Centered Design, Service Design,\nTransformation Design) am praktischen Beispiel\nangewandt werden.\n• Indem soziale und nachhaltige Fragestellungen im\nKontext von digitalen Anwendungen reflektiert\nwerden.\nWOZU\nDie Wirkung und Verschiedenartigkeit von Design in der\nglobalisierten Welt und die Wichtigkeit von\nkultursensibler und inklusiver Gestaltung ist Ziel der\nVeranstaltung. Vor dem Hintergrund internationaler\nZusammenarbeit mit interkulturell besetzten Teams ist\ndie Entwicklung eines soziokulturellen Bewusstseins,\ndas zu unterscheidbaren Designstilen und zur\nWertschätzung von Diversität und Gemeinsamkeiten\nführt.	\N	Prinzipien und Normen der barrierefreien, inklusiven Gestaltung, Gestaltungsgrundlagen (wie Wahrnehmung, Komposition, Typografie und Farbe) und Nutzungskontexte hinsichtlich interkultureller Unterschiede, Methoden des Human Centered Designs. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
33	1	Die Studierenden können für ausgewählte Cross-\nPlatform Frameworks, wie z.B. ReactNative\nTestverfahren wie Unit-Tests konzeptionell planen und\nimplementieren.\nIndem sie\n• Die grundlegenden Ansätze verschiedener\nTestverfahren kennen, unterscheiden und\ndiskutieren\n• An ausgewählten Beispielen konkrete\nImplementierungen durchführen\n• Ein Konzept für die Integration von\nTestverfahren in das parallel stattfindenden\nBuilding Projekt entwerfen und diskutieren\nUm später\nSchon in frühen Stadien Softwarearchitektur auch\nhinsichtlich des notwendigen Testkonzepts zu\ndurchdenken und entsprechende Tests selbst zu\nintegrieren oder im Entwicklungsteam unterstützen zu\nkönnen.	\N	Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt
34	1	Die Studierenden kennen grundlegende Fakten über die\nSpiele-Industrie und über die professionelle Entwicklung\nvon Computerspielen. Sie kennen und verstehen die\nwichtigsten Stufen im Entwicklungsprozess sowie die\nRollen der unterschiedlichen an einer Entwicklung\nbeteiligten Personen.\nDie Studierenden können einfache Game-Designs, die\nsie im Modul „Game-Design und Gamification“\nentworfen haben, mit Hilfe von Visueller\nProgrammierung mit Blueprints auf Basis der Unreal\nEngine umsetzen und in das Build-Projekt integrieren.\nDie Studierenden sind in der Lage, ihre Kenntnisse und\nFertigkeiten der Spiele-Entwicklung im Hinblick auf\nschwierigere Anforderungen, komplexere Applikationen\nund andere Werkzeuge im weiteren Studium und im\nBeruf zu erweitern.	\N	• Fakten zur Spiele-Industrie: Große Hersteller, Umsätze, Game-Engines • Professionelle Entwicklung von Spielen: Entwicklungs-Methodik, Entwicklungsprozess inkl. Teststrategien, Entwickler-Rollen • Umsetzung von Spiel-Elementen mit Unreal • Modellierung von Game Levels; Import von Assets in Unreal • Implementierung einer Spiele-Logik • Player-Perspektiven (First-Person, Third-Person), Kameras, Integration von Mitspielern • Integration von Non-Player-Characteren (NPCs) • Simulation pysikalischer Effekte in Unreal
50	1	WAS\nDie Studierenden kennen und verstehen in welchen\nKontexten Storytelling eingesetzt werden kann und sind\nin der Lage auf Basis von Charakteren eine eigene\nGeschichte zu entwickeln und visualisieren.\nWOMIT\n• Indem der Aufbau von Geschichten und\nMechanismen und Vorgehensweisen des\nStorytellings vermittelt werden.\n• Indem eigenständig Charaktere vor dem\nHintergrund einer Geschichte erarbeitet werden.\n• Indem aus nachvollziehbaren Erzählsträngen\nStoryboards erstellt werden.\n• Indem Grundlagen der Visualisierung\nkennengelernt und erprobt werden (Storyboard-\nGestaltung in 2D oder 3D).\n• Indem Geschichten visuell umgesetzt werden und\nals statische Umsetzung oder Bewegtbild-Beitrag\nfür digitale Produkte\nWOZU\nStorytelling ist ein Prinzip, um Inhalte in Präsentationen,\nWeb-/Appangeboten, Bewegtbild, Animationen usw.\nspannungsvoll zu vermitteln. Das Wissen kann in\nFolgeveranstaltungen angewandt werden.	\N	in Präsentationen, Web-/Appangeboten, Bewegtbild, Animationen usw. spannungsvoll zu vermitteln. Das Wissen kann in Folgeveranstaltungen angewandt werden. Inhalt: Arten von Geschichten, Aufbau einer Geschichte, Storytelling in unterschiedlichen Kontexten, von der Idee zum Charakter zur Geschichte zum Bild, Erzähl- und Darstellungsformen, Storyboard-Aufbau und Besonderheiten in der Gestaltung, Visualisierungs- und Darstellungstechniken. Die Studierenden führen in Hausarbeit Gestaltungsentwürfe zu vorgegebenen Aufgaben durch. Im Praktikum finden dazu individuelle Korrekturbesprechungen statt. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
35	1	Die Studierenden können verschiedene Methoden zur\nDurchführung und Analyse von Usability Tests\nvergleichen, praktizieren und kritisieren.\nindem Sie\n• Für eine definierte Problemstellung geeignete\nUsability Test Methoden auswählen\n• Einen konkreten Usability Test planen und\nhierfür geeignete Methoden kombinieren und\nanpassen\n• Beispielhaft einen Usability Test durchführen\n• Die gesammelten Daten transkribieren,\nanalysieren und Usability Probleme identifizieren\n• Vor- und Nachteile der verschiedenen Methoden\nin der Gruppe vorstellen und diskutieren\nUm später\n• Im parallelen Großprojekt Usability Tests\nselbstständig konzipieren, durchführen und\nanalysieren zu können\n• Im Beruf die Schnittstellenkompetenz aufweisen,\nmit Spezialisten für Usability Tests\nzusammenarbeiten zu können oder diese\nselbstständig planen, konzipieren und\ndurchführen zu können.	\N	Angelehnt an das parallel stattfindende Großprojekt wird eine Auswahl an Methoden zur Durchführung und Analyse von Usability Tests zunächst vorgestellt und anschließend durch die Studierenden seminaristisch analysiert, aufbereitet und eine beispielhafte Anwendung der Methoden konzipiert. In Kleingruppen erfolgt die praktische Anwendung und anschließende Diskussion und Analyse. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
36	1	Die Studierenden kennen und verstehen das\nGrundkonzept der Visuellen Programmierung. Sie\nkennen die Unterschiede und die Vor- und Nachteile im\nVergleich zum konventionellen Programmieren. Sie\nkennen die Haupteigenschaften einiger\nunterschiedlicher visueller Beschreibungs- und\nProgrammiersprachen und die jeweiigen\nAusdrucksmöglichkeiten im Hinblick auf zu\nprogrammierende Problemstellungen.\nDie Studierenden können vorgegebene Aufgaben zu\neinfachen und in Games häufig umzusetzenden\nElementen mit Unreal-Blueprints implementieren und\nihre Lösungen erklären und begründen. Damit sind sie\nin der Lage, die Learning Unit „Spiele-Entwicklung mit\n3D-Game-Engines“ erfolgreich absolvieren zu können.	\N	Einführung in die Visuelle Programmierung, Unterschiede zur textuellen Programmierung Visuelle Modellier- und Programmiersprachen (Scratch, LabVIEW, SIMULINK) und ihre Haupteigenschaften Blueprint Editor und Überblick über Unreal Blueprints Zentrale Blueprint Konzepte und Elemente • Actors, ihre Manipulation und Actor-Klassen • Event-Graph • Game-Projekt, Game Mode • Pawn-Klassen • Input Aktionen des Spielers • Kamera • Line Traces und Kollision • Timers, Spawning Actors Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
52	1	Die Studierenden können ihre (Projekt-)Arbeiten in\nForm von Kurzvideos bzw. Filmbeiträgen präsentieren\nund dokumentieren, in dem sie vorhandenes\nFilmmaterial sichten, auswählen und bearbeiten sowie\nletztendlich einen vollständigen Videobeitrag mit Ton\nund Sound-Effekten/Musik veröffentlichen.\nIndem sie (bereits konzipiertes und erstelltes)\nFilmmaterial weiterbearbeiten, Vorgehensweisen zum\nVideoschnitt, Sound Design oder der Nutzung\nlizenzfreier Musik, Motion Design und Visuellen Effekten\nFarbkorrektur und Color-Grading, Mastering, Export,\nArchivierung kennenlernen und anwenden können.\nUm später Konzeptstudien und Studienarbeiten so\naufzubereiten, dass Idee und Umsetzung von Projekten\nkompakt visuell erklärbar sind, ohne umfangreiche\nAufbauten mit Hard- und Software vornehmen zu\nmüssen. Die Videobeiträge können langfristig\n(unabhängig von System- und Softwareupdates) für das\neigene Portfolio, Tagungen und Präsentationen genutzt\nwerden.	\N	Erfassen des Videomaterials und Auswahl von Bildfolgen für den Grobschnitt, ggf. Konzeptentwicklung anhand des vorliegenden Materials, Sounddesign oder Musikauswahl, hinzufügen von Soundeffekten und Abstimmung auf den Schnitt, die Dramaturgie und die Videolänge, Motion Design, Visuelle Effekte – Animation für das Video, wie Logo- oder Titelanimationen sowie Bildretuschen, Durchführung von Farbkorrekturen und Color Grading, zur Vereinheitlichung und Anpassung des Videomaterials an die gewünschten Stimmung sowie Vorbereitung der Veröffentlichung (Auflösung, Videoformate) durch Mastering, Export und Archivierung. Einführung in notwendige Software und Tools. Die genaue Fokussierung und
37	1	Die Studierenden können einfache Webanwendungen\nmit modernen Frameworks entwerfen, implementieren\nund in einer Client/Server Architektur aufsetzen,\nindem Sie\n• Die grundlegenden Technologien für Client- und\nserverseitige Web Anwendungen analysieren,\ndiskutieren und bewerten\n• In Kleingruppen anhand konkreter Vorgaben und\nunter Anleitung beispielhaft Webanwendungen\nin all ihren Teilaspekten umsetzen\n• Zugrundeliegende Entwurfsprinzipien und\nArchitekturdesigns verstehen und anwenden\n• Ansätze für weiterführende Technologien für\nCloud Computing wiedergeben\nUm später / damit sie…\n• Im Großprojekt entsprechende Werkzeuge\nzielgerichtet einsetzen können und sich\nweiterführende Kenntnisse und Kompetenzen\nhierzu selbst aneignen können\n• In späteren Projekten (z.B. Abschlussarbeit) und\nim Beruf Web Technologien auswählen und\nimplementieren zu können	hierzu selbst aneignen können • In späteren Projekten (z.B. Abschlussarbeit) und im Beruf Web Technologien auswählen und implementieren zu können	Es erfolgt zunächst eine kurze Einführung in grundlegende relevanter WWW Technologien (z.B. HTML, JavaScript, Ajax, Bootstrap, AJAX, PHP, REST). Anschließend werden in Kleingruppen zum Teil auch unterschiedliche Technologien genutzt um beispielhaft an einer Aufgabenstellung den Einsatz der Technologien kennenzulernen und die Limitationen und Möglichkeiten besser einschätzen zu können. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt
53	1	WAS\nDie Studierenden können einen thematisch\nvorgegebenen funktionstüchtigen Website-Prototypen\ngestalterisch und funktionell/interaktiv entwickeln.\nWOMIT\n• Indem Grundlagen des Webdesigns und der\ninteraktiven Gestaltung vermittelt werden.\n• Indem eine Analyse durchgeführt und ein Konzept\nhinsichtlich Zielsetzung, Zweck, Zielgruppe,\nNutzer:innenerwartung, Tonalität, Struktur und\nNavigation usw. entwickelt wird.\n• Indem eine individuelle Gestaltung der Website\nerarbeitet und mit einem Prototyping-Tool (z. B.\nAdobe XD) inkl. Funktionalitäten umgesetzt wird.\nWOZU\nDie Fähigkeit zur Visualisierung von\nBenutzerschnittstellen und Erstellung von Prototypen ist\nzentrale Kompetenz im Studiengang und kann in\nFolgeveranstaltungen angewandt werden.	\N	• Einführung in ein Prototyping-Tool und ein Content- Management-System (z. B. Adobe XD und WordPress) • Festlegung Projekt-/Zeitplanung & Arbeitspakete • Konkurrenzanalyse und Nutzungskontext, Zielgruppenbeschreibung (anhand von Personas) und Contentanalyse • Konzeptentwicklung, Festlegung Task- Flows/Sitestruktur und Interaktionsdesign • UI-Design-Entwicklung und Styleguide (ggf. inkl. Bildwelt) • Entwicklung eines ein individuellen Screendesigns als Entwurf oder ausgearbeiteter Gruppenentwurf, Darstellung als klickbarer Prototyp Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
54	1	Die Studierenden können für eine aktuelle\nwissenschaftliche Fragestellung untersuchen,\nrecherchieren und zusammenfassen\nIndem Sie:\n• Relevante wissenschaftliche Suchsysteme (z.B.\nACM, IEEE aber auch Google Scholar)\nzielführend bedienen.\n• Wissenschaftliche Arbeiten lesen und deren\nStruktur und Schematik verstehen.\n• Zentrale Kernpunkte wissenschaftlicher Arbeiten\nextrahieren und mit anderen Arbeiten\nkontrastieren\nUm später:\n• Für das Großprojekt relevante wissenschaftliche\nVorarbeiten oder Lösungsansätze in der\nLiteratur zu identifizieren\n• Die Grundlagen wissenschaftlichen Arbeitens in\nkomplexere Wissenschaftsvorhaben (z.B.\nAbschlussarbeiten) integrieren zu können.	\N	Theoretische Grundlagen wissenschaftlichen Arbeitens werden vermittelt und gehen einher mit der praktischen Anwendung an einer durch das Großprojekt geprägten Themenstellung.
38	1	Die Studierenden kennen und verstehen die\nFunktionsweise wichtiger XR-Geräte. Sie haben ein\ngrundlegendes Verständnis auch von deren\nphysikalischer Basis. Sie kennen wichtige\nLeistungsparameter der einzelnen Geräteklassen.\nDie Studierenden können die Zusammenhänge\nzwischen der Theorie (insbes. Computergrafik und\nMedientechnik) aus dem Modul „Extended Reality“ und\nder Praxis einer XR-Entwicklung in Unreal herstellen.\nDie Studierenden können einfache XR-Anforderungen\naus dem Designing-Projekt mit Hilfe der in XRG\nerworbenen Kenntnisse und auf der Basis von Unreal\nBlueprints implementieren und in das Build-Projekt\nintegrieren. Alternativ oder ergänzend zu Aufgaben aus\ndem Designing-Projekt können die Studierenden\nvorgegebene Aufgaben zur Erstellung von XR-\nAnwendungen mit dem Werkzeug Unreal\nimplementieren sowie ihre Vorgehensweise erklären\nund begründen.\nDie Studierenden sind in der Lage, ihre Kenntnisse und\nFertigkeiten der XR-Entwicklung im Hinblick auf\nschwierigere Anforderungen und andere Werkzeuge im\nweiteren Studium und im Beruf zu erweitern.	\N	• Einführung: Sensoren, insbesondere Tiefensensoren, Aktoren, XR mit Smartphones • Ausgabetechnologie: Datenbrillen und Augmented- Reality-Brillen, Mixel-Reality-Brillen, Virtual-Reality- Brillen • Eingabetechnologie: Controller, Motion Capture Systeme, Tracking-Technologie, Sonstige Eingabegeräte • Programmierung einer kleinen XR-Anwendung mit der Unreal Engine
13	1	• Die Studierenden können einfache grafische\nBenutzeroberflächen mit einer aktuellen\nProgrammiersprache für interaktive Anwendungen,\nz.B. JavaFX implementieren,\no indem sie Komponenten zur Ein- und Ausgabe,\nEreignisbehandlung, Layouterzeugung,\nBenutzerführung und Eingabeprüfungen\ndifferenziert auswählen, programmatisch\nverstehen und zusammenführen,\no um später diese Aspekte sowohl in komplexere\nAnwendungen angepasst integrieren zu können\nals auch auf andere Programmiersprachen\ntransferieren zu können.\n• Die Studierenden können einfache\nBenutzeroberflächen gestalten und kritisieren,\no indem Sie Grundlagen und Normen zur\nmenschlichen Wahrnehmung und Kognition mit\nGrundsätzen und Normen der\nInteraktionsgestaltung, Usability, User\nExperience und weiteren Designprinzipien\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 32 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nverbinden und mit Möglichkeiten der Ein- und\nAusgabetechnologie zusammenführen,\no um später konzeptionell bei der Gestaltung oder\nEvaluation von Benutzerobflächen Usability\nProbleme bewerten und letztlich vermeiden oder\nentdecken zu können.\n• Die Studierenden können die Phasen mensch-\nzentrierter Entwicklung auf definierte\nProblemstellungen anwenden\no Indem Sie sie hierfür notwendige zentrale\nMethoden auswählen, diskutieren und\ndifferenzieren können,\no Um später diese in eigens definierte\nProblemstellungen einführen und adaptieren zu\nkönnen.	\N	• Grundlagen mensch-zentrierter Entwicklung\nsowie die hierfür zentralen verschiedenen\nPhasen und Methoden.\n• Theoretische Grundlagen: Sensorische\nWahrnehmung, Mentale Modelle und\nMetaphern, Handlungsebenen und Modelle der\nInteraktion.\n• Interaktionsstile, Interaktionstechnologien und\nInteraktionsprinzipien.\n• Benutzerführung, Meldungen und Prüfung von\nEingaben.\n• Barrierefreiheit\n• Grundlagen für die Programmierung von\ngrafischen Benutzeroberflächen, insbesondere\nEreignisbehandlung, Layout Komponenten,\nInteraktionselemente, Meldungen und\nFehlerbehandlung.
14	1	Die Studierenden kennen und verstehen grundlegende\nBegriffe der Mathematik, insbesondere der Analysis,\nund deren Bedeutung in der Informatik. Sie können\nRechentechniken von Hand und anhand einfacher\nProgrammierung (Python) anwenden und einfache\nmathematische Modelle erstellen, interpretieren und\nanwenden.	\N	• Zahlen: Zahlenräume der Mathematik und\nZahlendarstellung im Rechner\n• Folgen: rekursiv und explizit definierte Folgen,\nvollständige Induktion, Grenzwertbestimmung,\nKonvergenzgeschwindigkeit\n• Funktionen: wichtige Modellfunktionen,\nEigenschaften von Funktionen (Stetigkeit,\nDifferenzierbarkeit, Krümmungsverhalten,\nGrenzwerte) und deren Bedeutung im Kontext von\nModellbildung und Informatik), Taylorpolynome,\nSplines, exakte und numerische Integration\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 34 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• Ausblick auf Anwendungen einfacher\nmathematischer Modelle in der Informatik
15	1	• Die Studierenden kennen alle wesentlichen\nKonzepte der objektorientierten Programmierung\nsowie typische Problemstellungen, in denen diese\nsinnvoll und effektiv eingesetzt werden können.\n• Sie kennen darüber hinaus die aus der funktionalen\nProgrammierung stammenden Konzepte der\nLambdas und Streams, und sie wissen, wann diese\nvorteilhaft verwendet werden können.\n• Sie beherrschen den Umgang mit den gängigen\nStandardklassen (Collections, I/O) der Lehrsprache\nJava und verstehen die dahinter stehenden\nKonzepte.\n• Die Studierenden erkennen den Sinn und die\nAnwendung von Ausnahmen.\n• Sie erlernen das Schreiben von Unit-Tests als\nuntrennbarem Bestandteil des Programmierablaufs.\nSie verstehen, dass das Schreiben von\nKomponententests eine Form der Spezifikation des\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 36 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\ngewünschten Verhaltens ist und darum an den\nAnfang des Programmierablaufs gehört.\n• Insgesamt sind die Studierenden in der Lage, zu\nüberschaubaren Aufgabenstellungen qualitativ gute,\nwartbare und erweiterbare Softwarelösungen zu\nerstellen.	\N	Klassenhierarchie und Polymorphie •\nTestautomatisierung mit JUnit • Collection-Klassen •\nAusnahmen • Schnittstellen • Nutzen von Schnittstellen\nam Beispiel eines Entwurfsmusters • Lambda-\nAusdrücke • Streams • Ein-/Ausgabe •\nAufzählungstypen • Parallelität
16	1	Die Studierenden können Methoden der agilen\nSoftwareentwicklung gegenüberstellen, diskutieren und\nargumentieren\nindem Sie\n• Das agile Manifesto darstellen und mit klassischen\nEntwicklungsmethoden kontrastieren\n• Verschiedene agile Ansätze, insbesondere auch\nlean UX analysieren und voneinander abgrenzen\n• Für das bevorstehende Großprojekt beispielhaft\nden agilen Ablauf planen und vorbereiten\n• Werkzeuge und Tools zur Unterstützung\nausprobieren und vergleichen\n• Limitationen und Skalierungsmöglichkeiten kennen\nund klassifizieren\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 38 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nUm später\n• Im Großprojekt effizient und effektiv im Team\narbeiten zu können\n• Im Beruf sich hinsichtlich der dort herrschenden\nEntwicklungsmethoden schnell einfinden und\nkonstruktiv zur Verbesserung beitragen können.\nDie Studierenden können, projektspezifische\ngrundlegende Fachkompetenzen anwenden\nIndem Sie\n• Die Thematik des Großprojekts analysieren und\nhinsichtlich der notwendigen Fachkompetenzen\ndiskutieren\n• Im Rahmen von kleinen Projektaufgaben und unter\nzu Hilfename vorbereiteter Tutorials und\nweiterführender Informationen die Notwendigkeit für\ndie Belegung weiterführender Learning Units oder\nSelbstlernmöglichkeiten analysieren und bewerten.\nUm später\n• Im Großprojekt direkt einsteigen zu können\n• Die Wahl für weiterführende Learning Units\ninformiert treffen zu können.	\N	Zentrale Inhalte des PRIMER TO Building sind\nMethoden, Werkzeuge und Techniken zur Projektarbeit\nin komplexen Softwareprojekten. Hierzu gehört\ninsbesondere die agile Softwareentwicklung und das\nVerständnis, wie diese auch in den Kontext mensch-\nzentrierter und nachhaltiger Softwareentwicklung\neingesetzt werden kann.\nDarüber hinaus werden, abhängig vom Projektthema,\nspezifische Fachkompetenzen vermittelt, welche als\nelementar für alle Projektteilnehmer betrachtet werden.\nWird beispielsweise im Projekt mit dem Ziel gearbeitet,\neine VR Anwendung in Unreal zu entwickeln, dann kann\nim Primer eine kurze Einführung und Grundlage hierzu\nvermittelt werden, welche die Studierenden in die Lage\nversetzt zu entscheiden, ob und wer das weiterführende\nLearning Unit besucht oder inwieweit im Selbststudium\nweiterführende Kompetenzen angeeignet werden\nkönnen
17	1	Die Studierenden können verschiedene\nDesignmethoden (insbesondere Analyse, Ideation,\nEntwurf) gegenüberstellen, diskutieren und\nargumentieren\nindem Sie\n• Beispielhaft und verkürzt einen Design Lifecycle\n(z.B. Design Thinking Sprint) anwenden\n• Verschiedene Designmethoden analysieren und\nvoneinander abgrenzen\n• Für das bevorstehende Großprojekt beispielhaft\nden Einsatz von Designmethoden planen und\nvorbereiten\n• Werkzeuge und Tools zur Unterstützung\nausprobieren und vergleichen\n• Limitationen und Skalierungsmöglichkeiten kennen\nund klassifizieren\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 40 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nUm später\n• Im Großprojekt effizient und effektiv im Team\narbeiten zu können\n• Im Beruf sich hinsichtlich der dort herrschenden\nDesignmethoden schnell einfinden und konstruktiv\nzur Verbesserung beitragen können.\nDie Studierenden können, projektspezifische\ngrundlegende Fachkompetenzen anwenden\nIndem Sie\n• Die Thematik des Großprojekts analysieren und\nhinsichtlich der notwendigen Fachkompetenzen\ndiskutieren\n• Im Rahmen von kleinen Projektaufgaben und unter\nzu Hilfename vorbereiteter Tutorials und\nweiterführender Informationen die Notwendigkeit für\ndie Belegung weiterführender Learning Units oder\nSelbstlernmöglichkeiten analysieren und bewerten.\nUm später\n• Im Großprojekt direkt einsteigen zu können\n• Die Wahl für weiterführende Learning Units\ninformiert treffen zu können.	\N	Zentrale Inhalte des PRIMER TO DESIGNING sind\nMethoden, Werkzeuge und Techniken zur Analyse,\nIdeenfindung und Entwurf in komplexen Design und\nSoftwareprojekten. Hierzu gehört insbesondere auch\ndas Verständnis, wie diese in den Kontext mensch-\nzentrierter und nachhaltiger Softwareentwicklung\neingesetzt werden können.\nDarüber hinaus werden, abhängig vom Projektthema,\nspezifische Fachkompetenzen vermittelt, welche als\nelementar für alle Projektteilnehmer betrachtet werden.\nWird beispielsweise im Projekt mit dem Ziel gearbeitet,\neine Webanwendung zu konzipieren, dann kann im\nPrimer eine kurze Einführung und Grundlage in\nverschiedene Prototyping Werkzeuge erfolgen, welche\ndie Studierenden in die Lage versetzt zu entscheiden,\nob und wer das weiterführende Learning Unit besucht\noder inwieweit im Selbststudium weiterführende\nKompetenzen angeeignet werden können.
18	1	Die Praxisphase hat die Studierenden an die berufliche\nTätigkeit des Informatikers bzw. an der Schnittstelle\nWirtschaftsinformatik oder Informatik und Design durch\nkonkrete Aufgabenstellung und praktische Mitarbeit in\nBetrieben oder anderen Einrichtungen der Berufspraxis\nherangeführt. Die Studierenden haben in Ansätzen\ngelernt, die im bisherigen Studium erworbenen\nKenntnisse und Fähigkeiten anzuwenden und die bei\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 43 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nder praktischen Tätigkeit gemachten Erfahrungen zu\nreflektieren und auszuwerten. Während der Praxisphase\nhaben die Studierenden auch die verschiedenen\nAspekte der betrieblichen\nEntscheidungsfindungsprozesse kennen gelernt und\nEinblick in informatische, technische, organisatorische,\nökonomische und soziale Zusammenhänge des\nBetriebsgeschehens erhalten.	\N	Spezielle Inhalte für die Praxisphase werden nicht\nvorgegeben. Es muss lediglich sichergestellt sein, dass\ndie Tätigkeit in der Praxisphase der Tätigkeit eines\nInformatikers entspricht, bzw. eine Tätigkeit an der\nSchnittstelle Wirtschaftsinformatik oder Informatik und\nDesign ist. Um dies sicherzustellen, wird jeder\nStudierende vor und während der Praxisphase von\neinem Professor oder einer Professorin des\nFachbereichs Informatik betreut. Dabei werden auch die\ngeplanten Tätigkeiten besprochen.
19	1	Die Studierenden kennen und verstehen grundlegende\nKonzepte der linearen Algebra und Statistik. Sie\nbeherrschen Rechentechniken und können Ergebnisse\ndaraus im anwendungsorientierten Kontext\ninterpretieren. Sie können mehrdimensionale Modelle in\nder Praxis anwenden und statistische Aussagen auf\nBasis vorgegebener Datensätze treffen und\ninterpretieren.	\N	• Rechnen mit Vektoren im Anschauungsraum und\nabstrakten Vektorraum (Grundrechenarten,\nSkalarprodukt, Kreuzprodukt)\n• Lineare Gleichungssysteme und Matrizen (Gauß-\nJordan-Verfahren)\n• Lineare Abbildungen und Matrizen (lineare\nAbbildungen als Drehstreckungen, Determinanten,\nEigenwerte und Eigenvektoren)\n• Deskriptive Statistik (Beschreibung von Daten an\nHand von Kennzahlen)\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 45 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• Diskrete Zufallsvariablen und Verteilungen\n• Normalverteilung\n• Statistische Tests: t-Test, z-Test\n• Hauptkomponentenanalyse als Zusammenspiel von\nlinearer Algebra und Statistik
20	1	Die Studierenden kennen und verstehen Entwicklungs-\nKonzepte, -Verfahren, -Werkzeuge und deren\nEinsatzmöglichkeiten, um komplexe\nEntwicklungsprojekte erfolgreich umsetzen zu können.\nDie einzelnen Teilnehmer:innen von Projektgruppen\nbesitzen spezielle rollenspezifische Kompetenzen und\nbelegen daher unterschiedliche Kombinationen von\nLUs.\nIndem gestalterisches Basiswissen, Konzepte und\nWerkzeuge der jeweils gewählten LUs vorgestellt und\nerprobt werden.\nDie erworbenen gestalterischen Kompetenzen können\nund sollen im Designing Projekt Anwendung finden.	und belegen daher unterschiedliche Kombinationen von LUs. Indem gestalterisches Basiswissen, Konzepte und Werkzeuge der jeweils gewählten LUs vorgestellt und erprobt werden. Die erworbenen gestalterischen Kompetenzen können und sollen im Designing Projekt Anwendung finden.	Jede Teilnehmerin / Jeder Teilnehmer wählt 3 von 6\nvorgegebenen Learning Units (LU) aus. Die\nvorgegebenen LU werden projektabhängig aus der Liste\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 47 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\naller möglichen LU zum Building Projekt ausgewählt.\nDiese Auswahl kann jährlich variieren.\nDie grundsätzlich möglichen Learning Units Building\nund deren detaillierte Beschreibung finden Sie im\nAnhang zum Modulkatalog.
21	1	Die Studierenden kennen und verstehen gestalterische\nMechanismen, Konzepte, Werkzeuge und deren\nEinsatzmöglichkeiten, um komplexe Design-Projekte mit\ndigitalen Mitteln erfolgreich umsetzen zu können. Die\neinzelnen Teilnehmer von Projektgruppen besitzen\nspezielle rollenspezifische Kompetenzen und belegen\ndaher unterschiedliche Kombinationen von LUs.\nIndem gestalterisches Basiswissen, Konzepte und\nWerkzeuge der jeweils gewählten LUs vorgestellt und\nerprobt werden.\nDie erworbenen gestalterischen Kompetenzen können\nund sollen im Designing Projekt Anwendung finden.	und belegen daher unterschiedliche Kombinationen von LUs. Indem gestalterisches Basiswissen, Konzepte und Werkzeuge der jeweils gewählten LUs vorgestellt und erprobt werden. Die erworbenen gestalterischen Kompetenzen können und sollen im Designing Projekt Anwendung finden.	Jede Teilnehmerin / Jeder Teilnehmer wählt 3 von 6\nvorgegebenen Learning Units (LU) aus. Die\nvorgegebenen LU werden projektabhängig aus der Liste\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 49 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\naller möglichen LU zum Designing Projekt ausgewählt.\nDiese Auswahl kann jährlich variieren.\nDie grundsätzlich möglichen Learning Units Designing\nund deren detaillierte Beschreibung finden Sie im\nAnhang zum Modulkatalog.
22	1	WAS\nDie Studierenden kennen die Grundbegriffe und -\nprinzipen der visuellen Kommunikation und Gestaltung\nund vertiefen diese in der praktischen Anwendung\nanhand von niedrig-komplexen Entwurfsaufgaben mit\nprofessioneller Designsoftware (z. B. Adobe Illustrator\nund InDesign).\nWOMIT\n• Indem Basiswissen in Komposition, Layout und\nTypografie und die grundlegenden\nGestaltungsprozesse und -prinzipien, -gesetze und\n-methoden erlernt werden.\n• indem ein Grundverständnis für Design angelegt\nund durch Schulung und Sensibilisierung der\neigenen Wahrnehmung vertieft wird.\n• indem eigene Entwurfspraktiken kennengelernt und\nEntwürfe im Plenum vorgestellt und reflektiert\nwerden.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• indem Gestaltungsbeispiele und -prozesse\ninsgesamt analysiert und reflektiert werden.\n• in dem eigene Entwürfe und Layouts mit den\nProgrammen Adobe Illustrator und InDesign in\nEinzel-und/oder Gruppenarbeit erarbeitet werden.\nWOZU\nUm die Prozesse und Instrumente des Designs in\nFolgeveranstaltungen und -projekten mitzubedenken\nund einzusetzen.	\N	Grundbegriffe, Wirkung und Einsatzgebiete von Design,\nDesignprozess und Gestaltungsprinzipien,\nWahrnehmungspsychologische Grundlagen, Layout und\nKomposition, Layoutraster, Typografische Grundlagen,\nTypohistorie, Typologie, Typoergonomie,\nRastertypografie, Postmoderne Typografie,\nTyposemantik und Farbgestaltung.
23	1	Die Studierenden kennen und verstehen das Konzept\nder Von-Neumann-Architektur von Computern. Sie\nbesitzen eine realistische Modellvorstellung von der\nArbeitsweise eines Prozessors und von der\nZusammenarbeit mehrerer Prozessoren zur\nParallelverarbeitung.\nDie Studierenden kennen und verstehen die wichtigsten\nFunktionen von Betriebssystemen. Sie kennen das\nKonzept von Ressourcen. Sie besitzen eine realistische\nModellvorstellung von konkurrierenden Prozessen zur\nVerwaltung der Ressourcen und kennen damit\nauftretende Probleme. Sie kennen und verstehen das\nKonzept von Netzwerken. Sie kennen den Begriff von\nNetzwerkschichten.\nDie Studierenden kennen einige wichtige Begriffe und\nKonzepte der theoretischen Informatik im Überblick:\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 53 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nKomplexität, Berechenbarkeit, Formale Sprachen und\nendliche Automaten.\nDie Studierenden können Bezüge zwischen den\nHauptthemen aus der Veranstaltung herstellen.\nDie Studierenden können zu allen Themen Wissens-\nund Verständnisfragen beantworten.	\N	Bus System, Arbeitsspeicher, Ein-/Ausgabe Einheit,\nCPU, GPU, Multiprozessorsysteme.\nProzesse, Speicherverwaltung, Ein-/Ausgabe,\nDateisysteme, Netzwerktopologien, Protokolle und\nStandards, Internet.\nBegriffe Komplexität und Berechenbarkeit, Formale\nSprachen und Automaten im Überblick.
24	1	WAS\nDie Studierenden kennen und verstehen das\nSpannungsfeld Informatik und Design und entwickeln\nsystematisch in Gruppenarbeit eine (sozio-)technische\nAnwendung mit den Projektphasen\nAnalyse/Nutzungskontext, Konzeption, Gestaltung und\nprototypische Entwicklung (wechselnde Gewichtung je\nProjektthema).\nWOMIT\n• indem sie domänenspezifische und\nnutzer:innenorientierte Anforderungen ermitteln,\n• dabei relevante gesellschaftliche, ökologische,\nökonomisch und ethische Kontexte identifizieren\nund berücksichtigen,\n• allgemeine Analyse-, Entwurfs-, Visualisierungs-,\nLösungsfindungs- und Umsetzungsmethoden\nanwenden,\n• fachspezifische Methoden und Werkzeuge (digitale\nTools) verwenden,\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 55 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\n• verknüpfen und integrieren dabei die\nunterschiedlichen fachspezifischen Perspektiven\n• reflektieren dabei typische und konkrete\nKonfliktbereiche und die Kommunikation im Team\n• dokumentieren und kommunizieren\nAnwender:innen adäquat.\nWOZU\nUm die erste Studienphase einzuleiten und ein\nGrundverständnis für die Zusammenarbeit in\ninterdisziplinären Teams, die Lehrformen (projekt- und\nproblembasiertes Lernen) und Methodiken (Human\nCentered Design) des Studiengangs zu legen. Der\nZugang ist spielerisch, um Interesse und Begeisterung\nfür den Studiengang wecken.	\N	Einführung Studiengang (Ausrichtung und Funktion\nsowie Perspektiven und Möglichkeiten), Einführung\nInformatik und Design (Disziplin und ihre Teilgebiete,\ngeschichtlicher Überblick, gesellschaftliche\nRahmenbedingungen und Auswirkungen,\nAufgabenfelder und Perspektiven), Einführung\nProjektarbeit (Teamarbeit, Projektmanagement und\nProjektpräsentation), Einführung Human Centered\nDesign (Verstehen, Definieren, Ideation, Prototyping\nund Testen), Benutzeroberflächen und Mensch-\nMaschine-Interaktion, Einblick in die\nSoftwareentwicklung Joy of Programming und Rapid\nPrototyping.\nRegelmäßige Teilnahme, Erarbeitung eines\nGruppenprojekts, Präsentation
25	1	Die Studierenden\n• kennen den typischen Lebenszyklus eines\nSoftwaresystems,\n• verstehen Begriffe der Softwaretechnik, wie\nAnforderungen/Requirements, Architektur,\nDesign, DevOps, Testing,\n• kennen verschiedene Vorgehensmodelle der\nSoftwareentwicklung und deren Phasen und\nverstehen deren Vor- und Nachteile,\n• kennen die grundsätzlichen Methoden des\nRequirements-Engineerings,\n• können Software-Design mit Hilfe von UML\nentwerfen und dokumentieren\n• kennen Software-Design-Prinzipien wie SOLID,\nDRY und KISS,\n• können verschiedene Software-\nQualitätsmerkmale (z.B. FURPS) klassifizieren\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 57 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nund ihren Wert für ein Softwaresystem\nbeurteilen,\n• kennen und verstehen DevOps-Prinzipien.\nIn Übung und Praktikum analysieren die Studierenden\nfunktionale und nicht-funktionale Anforderungen an ein\nSystem, wenden die gelernten Methoden zum Entwurf\nund zur Implementierung von Software an und stellen\nihr Design in angemessener Dokumentation dar.	\N	• Einführung in die Softwaretechnik\n• Vorgehensmodelle\n• Requirements-Engineering\n• Software-Architektur\n• Software-Design und Implementierung\n• Qualität\n• Tests\n• DevOps\n• Software-Betrieb
64	1	Die Studierenden lernen unterschiedliche Technologien\nund Konzepte kennen, die für den Betrieb großer IT-\nInfrastrukturen notwendig sind und bekommen erste\npraktische Erfahrungen mit deren Anwendung. Sie\nerlangen die Fähigkeit, neue Konzepte im Umfeld des\nIT-Betriebs schnell begreifen, einordnen und bewerten\nzu können.	\N	Einführung\nSpeichernetze\nVirtualisierung\nSystem-Management
83	1	Die Studierenden werden in die Lage versetzt:\n• den Aufbau und die wesentlichen Aufgaben des\nRechnungswesens wiederzugeben und zu erläutern,\n• die wesentlichen Methoden des internen und\nexternen Rechnungswesens anzuwenden,\n• die grundsätzliche betriebswirtschaftliche\nPlanungssystematik in einem Unternehmen\nanzuwenden,\n• die Integrationsmöglichkeiten zwischen primär\nbetriebswirtschaftlich planerischen Funktionen,\nStammdaten und Rechnungswesen wiederzugeben,\n• die erlernten betriebswirtschaftlichen Methoden und\nProzesse des Rechnungswesens in ein\nInformationssystem anhand eines integrierten ERP-\nAnwendungssystem am Beispiel SAP R/3 umzu-\nsetzen.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 85 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	• Aufbau, Aufgaben, Methoden und gesetzliche\nGrundlagen des externen Rechnungswesen\n(Finanzbuchhaltung, Anlagenbuchhaltung,\nJahresabschluss)\n• Aufbau, Aufgaben und Methoden des internen\nRechnungswesens (Kostenrechnung,\nErgebnisrechnung)\n• Integrationsaspekte zwischen primär\nbetriebswirtschaftlich planerischen Funktionen,\nStammdaten und Rechnungswesen\n• Einführung in die Unternehmensplanung\n(Planungsprozess, Planungssystem,\nPlanungsinstrumente)\n• Umsetzung des erlernten Wissens anhand eines\nFallbeispiels in das integrierte\nStandardsoftwaresystem
84	1	Die Studierenden\n• kennen die wesentlichen Aufgaben und Ziele des\ndigitalen Marketings und können die\nHerausforderungen der digitalen Transformation\nidentifizieren, um Produkte, Preise, Kommunikation\nund den Vertrieb marktorientiert zu gestalten,\n• verstehen den Prozess der systematischen Planung\neiner digitalen Marketingstrategie, die heute\ngrößtenteils datenbasiert konzipiert wird, damit\nunternehmerischer Erfolg gewährleistet wird,\n• können Methoden und Instrumente des digitalen\nMarketing wie Affiliate Marketing und\nSuchmaschinenmarketing unter Berücksichtigung der\nmarkt- und unternehmensbezogenen\nRahmenbedingungen mit Hilfe von\nSoftwareapplikationen und -werkzeugen planen,\numsetzen und kontrollieren, um so eine operative\nDurchführung unterstützen zu können,\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 87 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• kennen Methoden der Datenanalyse im Kontext des\ndigitalen Marketing und können Targeting sowie\nZielgruppen-/Kundenanalysen durchführen\n(Klassifikation, Verhaltensanalyse und Prognosen zur\nUmsatzentwicklung, Kauffrequenzen usw.), damit die\nErkenntnisse bei der Kampagnengestaltung\nverwendet werden können,\n• verstehen und evaluieren die Erfolgswirksamkeit von\nMaßnahmen des digitalen Marketings, um die\nWirtschaftlichkeit im unternehmerischen Kontext\ngewährleisten zu können,\n• gestalten und optimieren Maßnahmen des Social\nMedia Marketing bzw. des Customer Relationsship\nManagements mit Hilfe der Werkzeuge der\nintergrierten Marketingkonzeption zum Aufbau und\nzur Aufrechterhaltung langlebiger\nKundenbeziehungen,\n• verfügen über eine initiale Kreationskompetenz für\nerfolgreiches E-Mail- und Mobile-Marketing, um\ninnovative Maßnahmen planen und gestalten zu\nkönnen.	\N	1. Konzeption des Digitalen Marketing\n2. Gestaltung und Aufbau von Webseiten\n3. Affiliate-Marketing und Online-Werbung\n4. Suchmaschinenwerbung und -optimierung\n5. Social Media Marketing\n6. E-Mail- und Mobile-Marketing
66	1	Die Studierenden kennen die gängigen\nAnwendungsfelder der webbasierten Datenverarbeitung\nund die spezifischen Probleme die im Einsatz\nauftauchen.\nDabei lernen die Studierenden ihre Kenntnisse über\nrelationale Datenbanksysteme mit weiterführenden\nTechnologien zu erweitern und auf nicht-relationale\nAnwendungen zu übertragen.	\N	Die Veranstaltung bietet eine Vertiefung in verschiedene\naktuelle Datenbankformate und Anfragesprachen im\nKontext von webbasierten und Cloud-basierten\nAnwendungen.\n• Objekt-relationales Mapping (am Beispiel aktueller\nFramework-Implementierungen)\n• Einführung in verschiedene Datenformate\n(strukturiert, semi-strukturiert, unstrukturiert), sowie\npassenden Anfrage- und Schemasprachen.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 49 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• (Wahlweise) Unstrukturierte Datenbankformate (sog.\nNOSQL Datenbanken) am Beispiel\nGraphdatenbanken.\n• (Wahlweise) Weitere Datenbankformate (bspw.\nDokumenten-DB)\n• (Wahlweise) Einführung zu Cloud Technologien für\nDaten-basierte Anwendungen im Web\nDie einzelnen Themen werden mit Anwendungsfällen\naus der Praxis in der Vorlesung untersucht und anhand\npraktischer Beispiele im Praktikum erlernt.
67	1	Die Studierenden sind nach Absolvieren des Moduls in\nder Lage, eine anwendungsorientierte Fragestellung mit\nHilfe von Data Science-Methoden zu beantworten. Sie\nverstehen die angewandten Methoden und deren\nEinsetzbarkeit in der Praxis und können Daten,\nMethoden und Ergebnisse fachfremden erläutern und\ndiskutieren.\nFragestellungen und Datensätze entstammen in der\nRegel einem gesundheits-, gesellschafts- oder\ningenieurwissenschaftlichen Kontext.\nInsbesondere sind die Studierenden in der Lage,\n• Daten, Methoden und Ergebnisse mit Nicht-\nInformatikern zu diskutieren,\n• Daten zu bereinigen und für Analysen vorzubereiten,\n• explorative und deskriptive Datenanalysen\ndurchzuführen\n• zu entscheiden, ob eine gegebene Fragestellung am\nbesten mit Regressions-, Klassifikations- oder\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\nClusteringmethoden beantwortet werden kann, diese\nanzuwenden und die Ergebnisse zu interpretieren.	\N	• Vorstellung des behandelten Datensatzes und seiner\nfachlichen Hintergründe\n• Datenexploration, -visualisierung und deskriptive\nAnalysen\n• Überblick über zur Verfügung stehende Methodiken\n• Formulierung geeigneter Fragestellungen und\nMethodenauswahl\n• Einarbeitung in die ausgewählten Methoden\n• Datenanalyse\n• Vorstellung und Diskussion der Ergebnisse\nProgrammieranteile erfolgen in Python oder R. Die\nkonkrete Methodenauswahl erfolgt im Kurs im Dialog\nmit den Studierenden. Je nach Fragestellung wird\nangestrebt, Studierende, Praktiker*innen oder\nWissenschaftler*innen anderer Fachrichtungen zu\neinzelnen Kursterminen hinzuzuziehen.
68	1	Die Studierenden sind nach Absolvieren des Moduls in\nder Lage, das anwendungsbezogene Fachgebiet\n"Medizinische Informatik" zu überblicken. Sie können\nZusammenhänge zwischen den verschiedenen\nAnwendungsbereichen und Teilgebieten herstellen und\nkennen die notwendigen IT-Grundlagen der\nmedizinischen Informatik.\nInsbesondere sind die Studierenden in der Lage\n• Ziele, Nutzen und Aspekte von medizinischen IT-\nAnwendungen zu erklären,\n• med. Vorgänge/Prozesse zu modellieren und die\nBedeutung von Prozessunterstützung durch IT zu\nerklären\n• zu erklären, welche medizinischen bildgebenden\nVerfahren und Biosignale es gibt und welche\nmathematischen Operationen bei deren Übernahme\nin Rechnersysteme nötig sind,\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 53 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• Ziele und Vorgehen bei klinischen und\nepidemiologischen Studien zu beschreiben und den\nIT-Einsatz hierzu darzustellen\n• Einfache Programme zu Teilaspekten der\nmedizinischen Informatik zu schreiben und\n• einen ersten Überblick über rechtliche Aspekte\nmedizinischer Software zu geben.	\N	• Überblick über die Teilgebiete der medizinischen\nInformatik\n• Medizinische Prozesse, Dokumentation und\nInformationssysteme\n• Bildgebende Verfahren und Biosignale\n• Klinische und epidemiologische Studien\n• Einführung in rechtliche Aspekte
140	1	Die Studierenden können 3D User Interfaces\nhinsichtlich Gestaltung und Interaktion entwerfen,\nindem sie entsprechende Werkzeuge und Tools\nanalysieren, vergleichen und anwenden können\num später für interaktive Systeme 3D Komponenten\ngestalten zu können (beispielsweise VR, Spiele, AR).	\N	3D User Interfaces haben eine immer größere\nBedeutung. Dabei erfordert die Gestaltung sowohl von\ngrafischen Komponenten als auch der Interaktion eine\ngänzlich andere Herangehensweise als in 2D. Dies wird\nin Zukunft durch AR und VR Lösungen und das\nmetaverse nochmal zusätzliche Bedeutung erfahren.\nIn diesem Modul werden aktuelle Entwicklungen und\nMethoden vorgestellt und anschließend in Kleingruppen\nfür eine konkrete Aufgabenstellungen\nGestaltungsentwürfe entwickelt.
69	1	Die Studierenden lernen die Grundlagen, Komponenten\nund Begriffe von Industrierobotern und kollaborativen\nRobotern kennen. Sie lernen Konzepte und Methoden\nder Programmierung und können diese effektiv und\nstrukturiert bei der Entwicklung eigener\nSteuerungsprogramme einsetzten. Sie kennen die\nGefahren und Herausforderungen beim Einsatz von\nIndustrierobotern und verstehen die Wichtigkeit der\nEinhaltung von Vorschriften. Neben der\nProgrammiermethodik lernen die Studierenden die\nVerwendung von Bibliotheken des Roboter Frameworks\nROS (Robot Operation System) kennen.	\N	• Grundlagen der Industrierobotik /\nManipulatortechnik, kollaborativer Roboter\n• Begriffsbildung und Komponenten\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 55 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• Beschreibung einer Roboterstellung\n• Transformation zwischen Roboter- und\nWeltkoordinaten,\n• Kinematic, inverse Kinematic\n• Roboterprogrammierung,\n• Roboterframework ROS,\n• Bewegungsart und Interpolation\n• Betriebssytem: Linux + ROS; Lehrsprachen sind C /\nC++, Python, ipython notebooks
86	1	Die Studierende werden in die Lage versetzt:\n• die Aufgaben und den Aufbau eines\nGeschäftsprozessmanagements zu erläutern,\n• eine geeignete Methode zur Modellierung von\nGeschäftsprozessen auszuwählen,\n• Geschäftsprozesse mit den vorgestellten Methoden,\nWertschöpfungsdiagramme, ARIS und BPMN zu\nmodellieren und ablauforganisatorische\nSchwachstellen zu analysieren,\n• eine systematische Vorgehensweise zur Einführung\neines Geschäftsprozessmanagements anzuwenden,\n• die Einsatzmöglichkeiten und –grenzen von\nGeschäftsprozessreferenzmodellen zu verstehen,	\N	• Grundlagen zum Geschäftsprozessmanagement,\n• Methoden der Geschäftsprozessmodellierung\n(Wertschöpfungsdiagramme, ARIS, BPMN),\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 92 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Vorgehensmodell zur Einführung eines\nGeschäftsprozessmanagements (Modellierung,\nAnalyse, Umsetzung, Kontrolle),\n• Einsatz von Geschäftsprozessmodellen in der\nSoftwareentwicklung und Einführung von\nStandardsoftware.\n• Controlling im Rahmen des\nGeschäftsprozessmanagements
87	1	Die Studierenden\n• kennen die grundlegenden theoretischen und\npraktischen Aspekte der Wirtschaftsinformatik\nund sind in der Lage diese wiederzugeben und\nzu erläutern, um das spätere berufliche\nEinsatzfeld der Wirtschaftsinformatik zu\nverstehen,\n• können die Funktionen sowie die wirtschaftliche\nBedeutung und Abgrenzung der Typen von\nInformationssystemen erklären, damit sie in der\nLage sind, die Bedeutung der\nInformationssysteme im Rahmen der heutigen\nGeschäftsmodelle zu kennen und zu verstehen,\n• kennen die Aufgabengebiete der\nWirtschaftsinformatik bei der Planung,\nEntwicklung, Integration und Einführung von\nInformationssystemen, um später die fachlichen\nKompetenzen zielgerichtet einsetzen zu können,\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 94 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• können unternehmerische Geschäftsprozesse im\nHinblick auf den Einsatz bzw. die Verbesserung\ndurch Informationssysteme analysieren und\nbewerten, um damit organisatorisches\nOptimierungspotenzial zu identifizieren,\n• sind in der Lage die Komplexität des IT-\nManagements zu erklären, damit die\nHerausforderungen bei einer strategischen,\ntaktischen und operativen Planung und\nSteuerung von IT-Fachkräften bzw. IT-Projekten\nerkannt werden können,\n• verstehen inhaltliche Bezüge der Module des\nStudienganges im Kontext des Fachgebietes der\nWirtschaftsinformatik, um in\nFolgeveranstaltungen Bezüge zwischen\neinzelnen Lehrmodulen herstellen zu können.\n• werden befähigt mit komplexen\nbetriebswirtschaftlichen und\ninformationstechnologischen Problemstellungen\numzugehen, um sie auf zukünftige berufliche\nSituationen vorzubereiten.	zielgerichtet einsetzen zu können,	1. Einführung\n2. Grundlagen der Wirtschaftswissenschaften und\nder Informatik\n3. Informationssysteme im Kontext von Strategie\nund Organisation der Wertschöpfung\n4. Klassifizierung von Anwendungssystemen\n5. Integrierte Informationssysteme\n6. E-Commerce\n7. Wissensmanagement und Zusammenarbeit\n8. Informationsmanagement\n9. Systementwicklung
29	1	Die Studierenden können die frei verfügbaren\nKI/Machine Learning Modelle unterscheiden und auf\nihre Einsetzbarkeit im konkreten Projektkontext\nbewerten. Sie können zudem aktuelle Frameworks\nunterscheiden und anwenden\nIndem sie\n• Die Grundlagen verschiedener ML Verfahren\nkennen und unterscheiden können (z.B. Supervised\nLearning, Unsupervised Learning, Reinforcement\nLearning)\n• Mit aktuellen Frameworks wie Pytorch oder\nTensorflow in Python kleine KI Probleme lösen\nlernen.\n• Die Limitierungen und Möglichkeiten von KI\nVerfahren einschätzen und bewerten können.\nUm später\n• Im parallelen Großprojekt in begrenztem Umfang KI\nVerfahren oder ML Modelle einsetzen zu können.\n• Im Beruf die Potentiale für den Einsatz von KI und\nML bewerten und deren Integration begleiten zu\nkönnen.	\N	Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt
70	1	• Gutes Verständnis für die fundamentalen\nKommunikationsarchitekturen und -protokolle des\nInternets.\n• Erlangen von Kenntnissen über die Aufgaben,\nPrinzipien, Mechanismen und Architekturen auf den\nunterschiedlichen Kommunikationsebenen.\n• Gewinnen von praktischen Erfahrungen über die\nKommunikationsprotokolle, Kommunikationsdienste\nund -anwendungen durch Versuche und mit Hilfe von\nProtokollanalysen.\n• Erleben der Notwendigkeit und Wichtigkeit der\nLehrinhalte.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 57 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik	\N	• Einführung: Begriffe, geschichtliche Entwicklung,\nBeispiele für Netzwerke, die Zukunft von Netzwerken\nund des Internets\n• Das ISO- und TCP/IP-Referenzmodell: Instanzen,\nDienste, Protokolle, Paketstrukturen;\nSchichtenaufgaben\n• Netzkoppelelemente: Repeater, Hubs, Bridges,\nSwitches, Router, Gateway\n• Vermittlungsebene: Aufgaben der Vermittlungsebene\n(IP, ARP, ICMP, Routingprotokolle);\nBegriffe/Mechanismen der Vermittlungstechnik\n(Warteschlangen, Routingverfahren, Traffic Shaping,\nScheduling, Call admission control); Quality of\nService in IP-Netzen (Idee, Konzept, IntServ, RSVP,\nDiffServ, MLPS)\n• Transportebene: Dienste und Mechanismen der\nTransportschicht (TCP, UDP; RTP); Sequenz- und\nBestätigungsnummern, Prüfsumme,\nZeitüberwachung, Segmentierung, Stream-Service,\nSliding-Windows-Technik, Slow-Start, Congestion\nWindows, Delayed acknowledgement, Nagle\nAlgorithmus\n• Anwendungsebene: DNS (Domain Name Service),\nSMTP (E- Mail), HTTP (World Wide Web), SIP\n(Session Initiation Protocol) Pro Anwendungsdienst:\nKommandos, Nachrichten/Datentypen,\nVerbindungen/Kommunikation, Besonderheiten;\nProtokollanalysen und deren Bewertung\n• Client-Server- und P2P-Architektur\n• Struktur und Aufbau des Internets (AS, Arten von\nASe, Verbindungen, CDN, …)\n• Grundlagen von Verteilten Systemen (Motivation,\nZiele, Konzepte, Beispiele, …)
31	1	Die Studierenden können ein Mikro-Controller-System\nwie Ardiuno so in einer hardwarenahen Sprache wie C\nprogrammieren, dass es auf durch Menschen\nausgelöste physische Ereignisse wie z.B. bestimmte\nBewegungen über Sensor-Steuerung definierte\nReaktionen physicher Geräte über Aktoren auslöst.\nDamit sind die Studierenden später in der Lage,\neinfache Projekte zu realisieren, in denen Ereignisse\nder physischen Welt digital verarbeitet werden müssen,\num dann wiederum digitale oder physische Geräte\ndefiniert steuern zu können.	\N	Die Programmiersprache C, Sensoren und Aktoren, Sensor-Programmierung mit der Arduino-Plattform zur Steuerung von Leuchtdioden und anderen Geräten. Die genaue Fokussierung und Ausrichtung der Inhalte ist auf das parallel laufende Großprojekt abgestimmt.
71	1	Die Studierenden werden in die Lage versetzt:\ndie relevanten rechtlichen Aspekte und gesetzlichen\nRegelungen als Randbedingung in ihre berufliche Arbeit\neinbeziehen können,\nzu wissen, welche datenschutzrechtlichen Vorgaben es\nbei der Speicherung personenbezogener Daten gibt\noder welche rechtlichen Regeln bei der Gestaltung und\nProgrammierung von Internet-Auftritten einzuhalten\nsind.	\N	Rechtliche Aspekte bei der Erstellung und Anwendung\nvon Softwareprodukten aller Art,\nInternet-, Datenschutz- und Urheberrecht, die für die\nbehandelten Rechtsfelder maßgeblichen europäischen\nund deutschen Gesetze.
72	1	• Gutes Verständnis von möglichen Angriffen und\ngeeigneten Gegenmaßnahmen in der IT\n• Erlangen von Kenntnissen über den Aufbau, die\nPrinzipien, die Architektur und die Funktionsweise\nvon Sicherheitskomponenten und -systemen\n• Sammeln von Erfahrungen bei der Ausarbeitung und\nPräsentation von neuen Themen aus dem Bereich\nIT-Sicherheit\n• Gewinnen von praktischen Erfahrungen über die\nNutzung und die Wirkung von Sicherheitssystemen\n• Erleben der Notwendigkeit und Wichtigkeit der IT-\nSicherheit	\N	• Einführung: IT-Sicherheitslage, Cyber-\nSicherheitsstrategien, Cyber-Sicherheitsbedürfnisse,\nAngreifer – Motivationen, Kategorien und\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 62 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\nAngriffsvektoren, Pareto-Prinzip: Cyber-Sicherheit,\nCyber-Sicherheitsschäden\n• Kryptographie und technologische Grundlagen für\nSchutzmaßnahmen: Private-Key-Verfahren, Public-\nKey-Verfahren, Kryptoanalyse, Hashfunktionen,\nSchlüsselgenerierung\n• Sicherheitsmodule (SmartCards, TPM, high-security\nund high-performence Lösungen)\n• Identifikations- und Authentikationsverfahren:\nGrundsätzliche Prinzipien sowie unterschiedliche\nAlgorithmen und Verfahren\n• ID-Management (Idee, Ziel, Konzepte)\n• ID-Cards (Neuer Personalausweis, Smart-eID …)\n• Self-Sovereign Identity (SSI)
73	1	Die Studierenden kennen\n• Begriffe der komponentenbasierten\nSoftwareentwicklung\n• Begriffe der speziellen JEE Entwicklung (Session\nBeans, Singleton, Message-Driven Beans)\n• Webservices\n• Begriffe im Kontext von Frameworks (Inversion of\nControl IoC)\n• Begriffe der Aspektorientierte Softwareentwicklung\n• die folgenden Diagramme der UML:\nKomponentendiagramm, Verteilungsdiagramm\n• Begriffe der Softwarequalität wie Functionality,\nUsability, Reliability, Portability und Supportability\n(FURPS)\nDie Studierenden verstehen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 64 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• den Zusammenhang der einzelnen Phasen in\nverschiedenen Softwareprozessen und die jeweiligen\nVor- und Nachteile\n• den Zusammenhang zwischen Anforderungen und\nobjektorientierten Modellen\n• Die Studierenden können das Erlernte anwenden,\num\n• aus unstrukturierten Anforderungen an ein System\nfunktionale Anforderungen zu extrahieren\n• qualitative Anforderungen zu formulieren\n• objektorientierte Modelle auf Basis der UML zu\nerstellen für verschiedene Anwendungsdomänen	\N	• Einführung komponentenbasierte\nSoftwareentwicklung\n• Java Enterprise Komponentenmodell\n• Session Beans\n• Singleton Bean\n• Message-Driven Beans\n• Webservices\n• Aspektorientierte Softwareentwicklung\n• Einführung in Frameworks\n• Ein spezielles Framework\n• UML Diagramme: Komponentendiagramm und\nVerteilungsdiagramm
58	1	Die/der Studierende ist in der Lage, die Ergebnisse der\nBachelorarbeit, ihre fachlichen und methodischen\nGrundlagen, ihre fächerübergreifenden\nZusammenhänge und ihre außerfachlichen Bezüge\nmündlich in begrenzter Zeit in einem Vortrag zu\npräsentieren.\nDarüber hinaus kann sie/er Fragen zu inhaltlichen\nDetails, zu fachlichen Begründungen und Methoden\nsowie zu inhaltlichen Zusammenhängen zwischen\nTeilbereichen ihrer/seiner Arbeit selbstständig\nbeantworten.\nDie/der Studierende kann ihre/seine Bachelorarbeit\nauch im Kontext beurteilen und ihre Bedeutung für die\nPraxis einschätzen und ist in der Lage, auch\nentsprechende Fragen nach themen- und\nfachübergreifenden Zusammenhängen zu beantworten.	\N	Zunächst wird der Inhalt der Bachelorarbeit im Rahmen\neines Vortrages präsentiert. Anschließend werden in\neiner Diskussion Fragen zum Vortrag und zur\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -\nInformatik (Bachelor) – PO2023 Modulkatalog\nBachelorarbeit gestellt, die von der/dem Studierenden\nbeantwortet werden müssen.\nDer Vortrag soll mindestens die Problemstellung der\nBachelorarbeit, den gewählten Lösungsansatz, die\nerzielten Ergebnisse zusammen mit einer\nabschließenden Bewertung der Arbeit sowie einen\nAusblick beinhalten.\nJe nach Thema können weitere Anforderungen\nhinzukommen, wie z.B. die vergleichende Darstellung\nalternativer oder konkurrierender Lösungsansätze, ein\nLiteraturüberblick oder die Darlegung des aktuellen\nStandes der Wissenschaft.\nDie Dauer des Kolloquiums ist in § 26 der Bachelor-\nRahmenprüfungsordnung und § 19 der\nStudiengangsprüfungsordnung geregelt.
74	1	Die Studierenden kennen die Grundzüge der\nEntwicklungsgeschichte der Künstlichen Intelligenz (KI).\nSie kennen grundlegende Begriffe der Stochastik und\ndes maschinellen Lernens, insbesondere der\nbayes’schen Modellierung, und können diese\nanwenden.\nSie sind in der Lage, typische Problemsituationen aus\nden Feldern intelligentes Datamining (Klassifikation,\nLernen aus Daten, Bayes’sche Inferenz) und\nOptimierung rationaler Entscheidungen (insbesondere\nPlanen und Entscheiden bei unsicherem Wissen) zu\nmodellieren und zu lösen.\nSie kennen die Grundzüge der Lösung der genannten\nProbleme unter Verwendung von neuronalen Netzen.\nSie können ihre Erkenntnisse auf verwandte\nProblemstellungen übertragen und sind darauf\nvorbereitet, sich vertieft mit Spezialgebieten der KI-\nAnwendung auseinanderzusetzen.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 66 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\nSie wissen um die Problematik der Interpretierbarkeit\nvon Modellen und sind darauf vorbereitet, die\ninhaltichen und gesellschaftlichen Fragen, die mit dem\nEinsatz von KI-Modellen und -Systemen verbunden\nsind, kompetent zu diskutieren.	\N	Einführendes zur Geschichte der KI und zur\nProblemlösung mittels intelligenter Agenten.\nGrundlegendes zur algorithmischen Problemlösung\ndurch exakte und heuristische Suche.\nGrundlegendes zur Modellierung und Anwendung von\nWissen bei Unsicherheit: Bayes’sche Inferenz,\nSampling, Filtering, Decision Making und zugehörige\nGrundlagen.\nGrundlegendes zu maschinellem Lernen:\nKategorisierung (Naive Bayes, kNN, Decision Trees),\nClustering, Collaborative Filtering, Time Series Analysis\nund zugehörige Grundlagen, insbesondere neuronale\nNetze (NN), Deep-NN, Graph-NN.\nGrundlegendes zur sequentiellen Optimierung von\nEntscheidungen: Adversarial Search, MCTS, Dynamic\nProgramming, Reinforcement Learning (RL), Deep-RL\nEinführendes zur kritischen Diskussion der\nInterpretierbarkeit von Modellen des maschinellen\nLernens und der inhaltlichen und gesellschaftlichen\nKonsequenzen ihres Einsatzes.\nBonusthema unter Mitarbeit der Studierenden mit\nGruppenpräsentation, z.B.: KI und Kreativität.
75	1	Die Studierenden lernen die praktische Anwendung\nvon „Knowledge Graphs“ in der heutigen IT-\nLandschaft kennen.\nDie Studierenden lernen welchen typischen\nProbleme mit Knowledge Graphs gelöst werden\nund welche Probleme dabei auftreten können.\nDie Studierenden lernen den Umgang an einer\npraktischen Graph-Datenbank Implementierung\n(z.Bsp. RDF, SPARQL) kennen.\nDabei lernen die Studierenden ihre Kenntnisse\nüber relationale Datenbanksysteme auf eine erste\nnicht-relationale Technologie zu erweitern.	\N	Die Veranstaltung bietet eine Einführung in das\nThema „Knowledge Graphs“ im Kontext der\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 68 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\nVertiefung von nicht-relationalen\nDatenbankformaten.\n- Einführung in das Thema „Knowledge\nGraphs“ anhand von aktuellen\nBeispielanwendungen bzw. Problemfeldern.\n- Praktische Einführung einer Graph-\nDatenbank (z. Bsp. RDF und SPARQL).\n- Überblick Schemasprachen für Graphen.\n- Überblick Anfragesprachen für Graph-\nDatenbanken und deren spezielle\nProblemstellungen.\n- (Wahlweise) Weitere Technologien zum\nThema und der Vergleich von Vor- und\nNachteilen.
76	1	Die Studierenden können zentrale Plattformen der\nmobilen Anwendungsentwicklung (Android, iOS, mobile\nWeb, Cross-Plattform-Frameworks) einordnen, indem\nsie Gemeinsamkeiten und Unterschiede in Architektur,\nEntwicklungsumgebungen und Distributionsmodellen\nverstehen, um später fundierte Technologieentschei-\ndungen treffen zu können.\nDie Studierenden können mobile Anwendungen\nkonzipieren und implementieren, indem sie plattform-\nspezifische APIs sowie Frameworks (z. B. für Sensor-\nzugriff, lokale Datenhaltung oder Netzwerkkommunika-\ntion) praktisch einsetzen, um funktionsfähige Apps für\nverschiedene Plattformen zu entwickeln.\nDie Studierenden können Progressive Web Apps sowie\nhybride und Cross-Plattform-Lösungen umsetzen,\nindem sie geeignete Frameworks wie zum Beispiel\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 70 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\nReact oder React Native nutzen, um die Reichweite und\nPlattformunabhängigkeit von Anwendungen zu erhöhen.\nDie Studierenden können benutzerfreundliche\nOberflächen gestalten, indem sie plattformspezifische\nRichtlinien und Usability-Prinzipien berücksichtigen, um\nAnwendungen an die Erwartungen der Nutzerinnen und\nNutzer anzupassen.\nDie Studierenden können Entwicklungswerkzeuge\neffizient einsetzen und sich neue Technologien und\nFrameworks eigenständig erschließen, gestützt auf\neinem grundlegenden Verständnis von Konzepten der\nEntwicklung für mobile Plattformen.	\N	• Grundlagen mobiler Betriebssysteme und\nEntwicklungsumgebungen (Android, iOS)\n• Entwicklung nativer mobiler Anwendungen\n(Android, iOS)\n• Mobile Webentwicklung mit HTML5, JavaScript\nund CSS sowie Progressive Web Apps (PWA)\n• Cross-Plattform-Entwicklung mit Frameworks\nwie React Native\n• Prototyping und UI-Design mit Figma;\nGestaltung benutzerfreundlicher Oberflächen\nund plattformspezifischer UI-Komponenten\n• Software-Entwicklungsprozesse im Kontext\nmobiler Anwendungen\n• KI-gestützte Methoden und Werkzeuge in der\nSoftwareentwicklung\n• Projektorientierte Umsetzung einer mobilen\nAnwendung
77	1	• Die Studierenden kennen grundlegende Cloud\nTechnologien und deren Eigenschaften\n• Die Studierenden verstehen die enorme Bedeutung\neiner performanten Netzwerkanbindung.\n• Die Studierenden erwerben in Ergänzung zu den im\nModul Rechnernetzen erworbenen Kompetenzen\nzum Umgang mit Festnetzen Fähigkeiten zum\nUmgang mit den für mobile Anwendungen\nverwendeten relevanten Mobilfunksystemen.\n• Sie können grundlegend mit den Einschränkungen\nder Funkanbindung mobiler Endgeräte umgehen und\ndarauf aufbauend beurteilen, welchen Einfluss diese\nEinschränkungen auf die Effizienz der von Ihnen zu\nverantwortenden Software haben.	zum Umgang mit Festnetzen Fähigkeiten zum Umgang mit den für mobile Anwendungen verwendeten relevanten Mobilfunksystemen. • Sie können grundlegend mit den Einschränkungen der Funkanbindung mobiler Endgeräte umgehen und darauf aufbauend beurteilen, welchen Einfluss diese Einschränkungen auf die Effizienz der von Ihnen zu verantwortenden Software haben.	Grundlagen zu Cloud Computing und XaaS\nTypen mobiler Netze• Bluetooth als Beispiel für ein Ad\nhoc Netz• GSM/UMTSLTE als zellulares Infrastruktur-\nNetz• Wireless LAN (WLAN) •LoRaWAN als IoT Netz.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 72 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\nPraktikum mit Versuchen zu ausgewählten\nFunksystemen
78	1	Die Studierenden lernen die Begriffe und Komponenten\nvon mobilen Robotern sowie die Konzepte und\nMethoden der Programmierung kennen und können\ndiese effektiv und strukturiert bei der Entwicklung\neigener Steuerungsprogramme einsetzen.\nSie lernen wie unterschiedliche Sensordaten fusioniert\nwerden und mobile Systeme navigieren sowie sich\nselbst lokalisieren.\nSie kennen die Gefahren beim Umgang mit mobilen\nSystemen und die Wichtigkeit der Einhaltung von\nVorschriften sowohl auf technischer als auch sozialer\nEbene.\nNeben der Programmiermethodik lernen die\nStudierenden die Verwendung von weiteren\nBibliotheken des Roboter Frameworks ROS (Robot\nOperation System) kennen.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 74 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik	\N	• Roboterprogrammierung, Roboterframework ROS,\n• Sensorik\n• Aktuatorik\n• Lokalisierung\n• Kartenbau\n• Navigation\n• Planung\n• Betriebssystem: Linux + ROS; Lehrsprache ist C /\nC++, Python, ipython notebooks.
88	1	Die Studierenden verstehen verschiedenen\nAngriffsvektoren und entsprechende\nSchutzmechanismen in modernen Netzwerken. Konkret\nverfügen die Studierenden über Kenntnisse, ein\nVerständnis und Wissen in den folgenden\nThemenkomplexen.\n• Grundlegenden Konzepte und Prinzipien der\nNetzwerksicherheit verstehen, einschließlich\nBedrohungen, Angriffsmethoden und\nSchutzmöglichkeiten.\n• Kenntnisse über gängige Netzwerkangriffen wie\nDistributed Denial-of-Service (DDoS), Man-in-the-\nMiddle (MitM), Spoofing und weitere.\n• Verständnis von Sicherheitsprotokollen und -\ntechnologien zur Mitigation von Angriffsvektoren\nbzw. zur Verkleinerung von Angriffsflächen.\n• Bewertung von IT-Sicherheitsrisiken in Netzwerken\nund von verschiedenen Angriffsvektoren\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 97 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	Grundlagen\n• Netzwerkarchitekturen und Konzepte: TCP/IP und\nISO/OSI Referenzmodell, gängige Protokolle,\nNetzwerkarchitekturen.\n• Netzwerksicherheit: Einführung, Bedrohungen,\nHerausforderungen.\n• Analyse von Netzwerkverkehr: Erfassen und Mitlesen\nvon Netzwerkverkehr, gängige Tools und\nDatenformate zum Mitlesen, Vorteile und\nLimitierungen von verschiedenen Vorgehensweisen\nSicherheit auf der Internet- und Netzzugangsschicht\n• Angriffe auf MAC und IP-Ebene: ARP- Poisoning,\nMAC-Spoofing, ICMP-Flooding, Netzwerkscanner.\n• Sicherheit von drahtlosen Netzwerken:\nVerschlüsselung (WPA3), MAC-Adressen-Filterung\nund verstecken von SSIDs, Evil-Twin Angriffe, Man-in-\nthe-Middle Angriffe.\nSicherheit auf der Transportebene\n• Angriffe auf TCP und UDP: Portscanning, TCP\nSession Hijacking, UDP-Flooding und Reflektion\nAngriffe.\n• Protokolle zur Verschlüsselung: Transport Layer\nSecurity (TLS) und Datagram Transport Layer\nSecurity (DTLS).\nSicherheit auf der Anwendungsebene\n• Sicherheit von Web-Anwendungen: Cross-Site-\nRequest-Forgery (CSRF) und Cross-Site-Scripting\n(XSS), HTTP-Sicherheitsmechanismen (z.B. Content-\nSecurity-Policies), Command- und SQL-Injections.\n• Sicherheit von DNS: DNS-Spoofing, DNSSEC, DNS-\nTunneling, DNS-Amplifikationsangriff.\n• E-Mail-Sicherheit: Erkennung von SPAM,\nVerschlüsselung von E-Mails, Phishing.
79	1	Die Studierenden lernen die Grundlagen und Begriffe\nder parallelen Programmierung und des parallelen\nProgrammierparadigma kennen und können parallele\nProgramme entwickeln und testen. Sie lernen\nsequentielle Algorithmen zu parallelisieren und\ninnerhalb der Grafikkarte oder MultiCore Architekturen\noder über mehrere Rechner hinweg parallel zu verteilen.\nNeben der Programmiermethodik, parallelen Pattern\nund dem Design lernen die Studierenden die speziellen\nProbleme und Fragestellungen bei der parallelen\nProgrammierung kennen, insbesondere das Erkennen\nvon Nebenläufigkeiten und die schwierigere\nFehleranalyse.	\N	• Grundlagen paralleler Programmierung\n• Parallele Architekturen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 76 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• Design und Analyse von parallelen Algorithmen\n• Threads- OpenMP\n• MPI - OpenCL\n• CUDA- Parallele Pattern (Map, Reduce, Scan, Sort,\n...)
89	1	Die Studierende erlernen die theoretischen Grundlagen\ndes Projektmanagements. Sie können Projekte\nstrukturieren, zeitlich und im Aufwand planen und\nüberwachen. Die Studierenden verstehen, dass neben\nden technischen Aufgaben das Personalmanagement\n(mit allen Facetten) ein sehr wesentlicher Erfolgsfaktor\nfür das Projektmanagement ist. Durch den praktischen\nUmgang mit Projektmanagement anhand von\nFallbeispielen erlernen die Studierenden die Umsetzung\nvon theoretisch Erlerntem und den Einsatz von PM-\nTools.	\N	Einführung in das Projektmanagement\n• Projektorganisation\n• Projektplanung\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 100 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Strukturierung von Projekten,\nTerminplanungstechniken, Kapazitätsplanung,\nAufwandsschätzung, Projektkostenplanung\n• Projektüberwachung und –steuerung\n• Qualitätssicherung und Risikomanagement\n• Projektabnahme und –abschluss\n• Verhaltenstheoretische Elemente im\nProjektmanagement (Personalmanagement)\n• Projektleiter und Projektteam, Gruppenarbeit im\nProjektteam, Kommunikation, Gesprächsführung,\nMotivation\n• Projektunterstützungswerkzeuge\nAus der Beschreibung sollte die Gewichtung der Inhalte\nund ihr Niveau hervorgehen.
90	1	Die Studierende werden in die Lage versetzt:\n• die wesentlichen Prozesse der\nFunktionsbereiche Produktion und\nMaterialwirtschaft zu verstehen.\n• die wesentlichen Methoden und Modelltheorien\nin den betrieblichen Funktionsbereichen\nProduktion und Materialwirtschaft anzuwenden\nund beurteilen zu können.	\N	• Grundlagen der Produktion und Materialwirtschaft\n(Begriffsdefinition, Produktionsplanungsansätze)\n• Mathematisch operative und strategische,\ndeterministische und stochastische Planungsmodelle\n• Prozesse der Produktionsplanung und -Steuerung\nsowie Materialwirtschaft\n• Prognosemethoden und Risikomanagement\nAngewandte Fallbeispiele und -Applikationen aus der\nUnternehmenspraxis\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 102 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
80	1	Die Studierenden kennen die Konzepte und Methoden\nder prozeduralen Programmierung und können diese\neffektiv und strukturiert bei der Entwicklung eigener\nprozeduraler Programme mit der Programmiersprache\nC einsetzen. Sie gehen sicher mit maschinennahen\nKonzepten wie Zeigern und Speicherverwaltung sowie\nmit Strukturen um. Die Studierenden sind damit in der\nLage, sich zukünftig selbstständig und zügig in weitere\nprozedurale Sprachen einzuarbeiten.	\N	• Grundelemente von C\n• Funktionen und Speicherklassen\n• Präprozessor\n• Adressen und Zeiger\n• Dynamische Speicherverwaltung\n• Strukturen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 78 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• Weitere ausgewählte Sprachelemente\n• Make\n• Überblick über die Erweiterungen von C zu C++
81	1	• Verständnis gängiger Verfahren zur\nSystemsicherheit, Systemintegrität und zum\nSoftwareschutz\n• Anwenden von Mechanismen zur Identifikation und\nAusnutzung von Software-Schwachstellen\n• Anwenden von Angriffstechniken in\nComputernetzwerken\n• Erlangen von Kenntnissen im Bereich der\nSchadsoftware-Erkennung und -Abwehr\n• Teilnahme an einem Capture-the-Flag-Wettbewerb	\N	Die Studierenden lernen die Anwendbarkeit und\nGrenzen von sicherheitsrelevanten Angriffen gegen\nSysteme, Netzwerkprotokolle und Software.\nDabei werden die folgenden Themen behandelt:\n• Linux and Unix-like operating system basics\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 80 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• Vulnerability research\n• Reconnaissance and scanning\n• System security and operational security\n• Software security\n• Bytecode and binary code analysis\n• Denial-of-Service attacks\n• Web security\n• Incident response\nLerneinheiten bestehen jeweils aus einer Einführung in\nForm mindestens einer Vorlesungseinheit sowie\nAufgaben, die im Praktikum gelöst werden müssen.\nDarüber hinaus müssen die Studierenden selbst\nverwundbare Beispiele als Aufgaben entwerfen, die\nbeispielsweise im Rahmen eines eigenen CTF-\nWettbewerbs eingesetzt werden könnten.
59	1	• Die Studierenden kennen den grundlegenden Aufbau\nkonvergenter Netze. Sie kennen grundlegende\nKonzepte eines modernen LANs mit VLANs.\n• Sie können beim Design, Aufbau und Betrieb eines\nmittelgroßen LANs unter Führung eines erfahrenen\nNetzadministrators eingesetzt werden.\n• Darüber hinaus kennen Sie grundlegende\nEigenschaften eines WAN und des Internets.\n• Sie sind in der Lage, sich effektiv in weitere Aspekte\nvon Netzwerken einschließlich Sicherheitsfragen und\nManagement einzuarbeiten. Darüber hinaus sind Sie\nin der Lage, Protokolle höherer Schichten zügig zu\nerlernen und in das Schichtenmodell einzuordnen.\n• Lehrsprache im Praktikum ist Cisco IOS.	\N	Grundbegriffe, Netztopologien , ISO/OSI-\nSchichtenmodell und Internet-Architektur\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 29 -\nInformatik (Bachelor) – PO2023 Modulkatalog\n• Übertragungsmedien und -kanäle, Bitübertragung\nund Codierung generisch und am Beispiel Ethernet\n• Schicht 2 Technologie am Beispiel Ethernet, LLC und\nMAC• Schicht 2 LAN Switching einschließlich VLANs\nund Spanning Tree\n• Internet-Adressierung sowie statisches und\ndynamisches Routing als Schicht 3 Technologie,\nSchicht 3 Routing im LAN\n• Grundlagen zu Weitverkehrsnetzen und zum Internet\n• Einführung zu TCP und UDP und well-known-Port\nAnwendungsschichtprotokollen
82	1	Die Studierenden kennen\n• Architekturmuster\n• Designmuster\n• OSGi Komponentenmodell\nDie Studierenden verstehen\n• den Zusammenhang der einzelnen Phasen in\nverschiedenen Softwareprozessen und die\njeweiligen Vor- und Nachteile, insbesondere den\nÜbergang von Analyse zu Design\nDie Studierenden können das Erlernte anwenden, um\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 82 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik\n• aus einem Pflichtenheft ein Design zu entwickeln\n• qualitative Anforderungen an das Design zu\nformulieren\n• objektorientierte Designmodelle auf Basis der UML\nzu erstellen	\N	• Einführung komponentenbasierte Einführung\nSoftware Design\n• Design Patterns (Observer, Adapter, Fassade,\nStrategie, Dekorierer, Simple Fabrik, Fabrikmethode,\nabstrakte Fabrik, Watchdog)\n• Einführung in Architekturmuster\n• MVC (Model-View-Controller) und dessen Derivate\nPassive View und Supervising Controller\n• Mehrschichtarchitektur\n• UML Diagramme: Interaktionsübersicht,\nKommunikationsdiagramm, Paketdiagramm,\nKompositionsstrukturdiagramm,\nKomponentendiagramm, Verteilungsdiagramm)\n• Komponentenmodell OSGi
61	1	Die Studierenden erwerben berufsorientierte\nenglischsprachige Diskurs- und Handlungskompetenz\nunter Berücksichtigung (inter-)kultureller Elemente.	\N	Die Veranstaltung führt in die Fachsprache anhand\nausgewählter Inhalte z.B. aus folgenden Bereichen ein :\nAI (Artificial Intelligence), Basic Geometric and\nMathematical Terminology, Biometric Systems,\nDiagrammatic Representation, Display Technology,\nNetworking, Online Security Threats, Robotics, SDLC\n(Software Development Life Cycle).
62	1	• Die Studierenden kennen den grundlegenden Aufbau\nund die Funktionsweise der Hardware von Rechnern.\n• Die Studierenden sind in der Lage, grundlegende\nAbhängigkeiten zwischen der Performanz von\nSoftware und Hardware zu verstehen.\n• Die Studierenden sind in der Lage, die\nWeiterentwicklung der relevanten Hardware in Ihrem\nberuflichen Umfeld zu verstehen und einzuordnen.	\N	• Geschichtliches, u.a. Mooresche Gesetz, Prozessor-\nGenerationen\n• Rechner: Komponenten und Struktur ,\nFunktionsweise , Buskommunikation, PC-Systeme\n• Logikbausteine: Kombinatorische und sequentielle\nLogik , Taktverfahren , Entwurf sequentieller\nBausteine, Entwurf einer einfachen ALU\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 41 -\nInformatik (Bachelor) – PO2023 Modulkatalog\n• Prozessoren, RISC-Architektur vs. CISC-Architektur,\nBefehlssatzarchitekturen, Rechenleistung von\nProzessoren, Pipelining\n• Speicher: Speichertechnologien, Speicherhierarchie,\nHauptspeicher, Cachespeicher\n• Einfache Assemblerbeispiele als Brückenschlag zur\nSoftware
63	1	Die Studierenden können mit den wesentlichen\nGrundbegriffen der theoretischen Informatik umgehen.\nSie sind in der Lage, die Korrektheit einfacher\nAlgorithmen nachzuweisen.\nSie können die Komplexität einfacher Algorithmen\nformal herleiten und algorithmische Probleme\nhinsichtlich ihrer Laufzeitkomplexität in Klassen\neinteilen.\nDie Studierenden kennen unterschiedliche formale\nBerechnungsmodelle und sind in der Lage, einfache\nProbleme mit ihnen zu lösen.\nSie sind in der Lage, formale Sprachen in Klassen\neinzuteilen und mit Hilfe von Regelwerken zu\nbeschreiben sowie abstrakte Maschinenmodelle zu\ndefinieren, um formale Sprachen zu erkennen.\nDer Besuch dieses Moduls versetzt die Studierenden\ninsgesamt in die Lage, in ihrer zukünftigen Praxis\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 43 -\nInformatik (Bachelor) – PO2023 Modulkatalog\nhandhabbare Probleme von nicht mehr handhabbaren\nzu unterscheiden, und bei der Lösung praktischer\nProbleme die Anwendbarkeit formaler Konzepte zu\nerkennen und diese einzusetzen.	\N	• Programmverifikation\n• Komplexität und Komplexitätsklassen\n• Berechenbarkeit und Berechnungsmodelle\n• Formale Sprachen und Chomsky-Hierarchie\n• Endliche Automaten und reguläre Sprachen\n• Kontextfreie Sprachen und Kellerautomaten
114	1	Die Studierenden können verschiedene Arten von\nBenutzerschnittstellen beurteilen und umsetzen, sowie\ndie Nutzbarmachung von (Interface-)Design im\ngesellschaftlichen Kontext in eigenen Projekten\nanwenden.\n• indem theoretische Hintergründe und aktuelle\nThemen/Forschungsergebnisse/Methoden\nerarbeitet, kritisch reflektiert und in die Projektarbeit\nintegriert werden.\n• indem ein tiefes Verständnis für die Aufgaben und\nErfolgsfaktoren bei der Durchführung eines\nkomplexeren Entwicklungsprojekts der\nMedieninformatik in einem Team erworben wird.\n• indem die Studierenden in der Lage sind,\nselbständig einzeln und im Team bekannte\nMethoden, Verfahren und Werkzeuge zur\nErstellung einer komplexen Anwendung in der\nMedieninformatik auszuwählen und anzuwenden.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 58 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• indem die Studierenden, sich selbständig und im\nTeam in eine bestimmte Anwendungsdomäne so\nweit einzuarbeiten, dass sie sachgerecht mit\nAnwendern kommunizieren und mit diesen\nLösungen entwerfen können.\nUm im weiteren Studienverlauf Interface-Design-\nPrototypen mit wachsender Komplexität entwickeln und\ndie verknüpften Inhalte und Methoden auf andere\nDomänen übertragen zu können.	\N	Durchführung eines mittelgroßen und anspruchsvollen\nProjekts aus dem Gebiet der Medieninformatik im\nTeam, vorzugsweise mit dem Schwerpunkt\nInterfacegestaltung unter Berücksichtigung des\nAnsatzes des „Spekulativen Designs“.\nSelbstständige Durchführung des Projekts von der\nAnalyse über Design, Prototyping, Realisierung und\nTest bis zur Dokumentation, Anwendung von\ngrundlegenden Projektmanagement-Methoden für\nDefinition, Planung, Kontrolle und Realisierung des\nProjekts, Vertiefung von Kenntnissen zur Entwicklung\nvon Anwendungen der Medieninformatik.\nTypische Projektthemen mit gesellschaftlichem Bezug:\nEntwicklung elektronischer Hardwareinterfaces, z.B.\nMaschinensteuerung; Entwicklung von Apps oder\nWebsites z. B. im Themenbereich Bienensterben,\nMental Health etc.\nDie Studierenden führen das Projekt weitgehend\nselbständig durch und präsentieren ihre\nMeilensteinergebnisse im Plenum der Projektgruppe.
98	1	Die Studierenden lernen die Begriffe und Komponenten\nvon Autonomen Systemen, Multi-Agenten und\nSchwarmsystemen sowie die Konzepte und Methoden\nder Programmierung kennen und können diese effektiv\nund strukturiert bei der Entwicklung eigener\nAnwendungen einsetzen. Sie gehen sicher mit der\nproblemspezifischen Auswahl einer\nRoboterkontrollarchitektur um und wissen, welchen\nEinfluss und welche Grenzen die Architekturen\nhaben.Sie kennen die wichtigsten maschinellen\nLernverfahren, deren Möglichkeiten und Grenzen sowohl\nauf technischer als auch sozialer Ebene. Die\nStudierenden sind zudem in der Lage, sich selbstständig\nund zügig in unterschiedliche Arten von\nArchitekturkonzepten Autonomer Systeme und deren\nProgrammierumgebung einzuarbeiten.	\N	• Einführung / Begriffsbildung Autonomer Systeme\n• Kooperierende Roboter\n• Adaptivität und Maschinelles Lernen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 21 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\n• Fuzzy Logic, Genetische Algorithmen, Konvolutions\nNetze, Generator Netze, Auto Encoder, Deep\nReinforcment Learning, Ransac, Kohnen Netze\n• Wissensrepräsentation\n• Roboterkontrollarchitekturen\n• Lehrsprache C / C++, Python. ipython notebooks,\nscikit-learn
99	1	Die Studierenden kennen die Begriffe und Verfahren\nder dreidimensionalen Datenverarbeitung sowie die\nKonzepte und Methoden der Programmierung und\nkönnen diese effektiv und strukturiert bei der\nEntwicklung eigener Programme einsetzen. Sie können\naus Bilddaten 3D Darstellungen erstellen und mittels\nKI-Verfahren semantische Umgebungsdarstellungen\nberechnen.	\N	• Grundlagen / Begriffsbildung\n• 3D-Sensoren\n• Kamerakalibrierung\n• Stereo Vision\n• Structure from Motion\n• 3D Punktewolken\n• Registrierungsverfahren\n• Metrische Umgebungsmodelle\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\n• Neuronale Netze,\nLehrsprachen sind C / C++, Python, ipython notebooks.\nBibliotheken: OpenCV, scikit-image, scikit-learn, PCL
100	1	In der heutigen Zeit enthalten große IT-\nLandschaften oft komplexe Datenarchitekturen, die\nauf verschiedene Datenbankformate zurückgreifen\nund Daten effizient dazwischen integrieren. Die\nStudierenden lernen in der Veranstaltung die\nGrenzen von Datenbanken im Allgemeinen\n(hauptsächlich formatunabhängig) kennen.\nDabei lernen sie die theoretische Analyse von\nDaten-basierten Problemen kennen. Die\ngewonnenen Kenntnisse werden auf praktische\nProbleme umgesetzt.	\N	- Überblick über aktuelle Datenarchitekturen,\naus Sicht der verwendeten Datenbanken\n(mit verschiedenen Formaten) und aus Sicht\nder Datenmodellierung bzw. Integration\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 25 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\n- Formalisierung von Datenformaten und\nAnfragen (Kalkül vs. Algebra)\n- Ausdrucksstärke von Anfragesprachen für\nverschiedene Formate (z.Bsp. SQL,\nSPARQL, Key-Value)\n- Überblick und Einführung in die\nAuswertungskomplexität von Anfragen\nallgemein\n- (Wahlweise) Aktuelle verwandte Themen\nund deren Anwendung in der Praxis (z. Bsp.\nCAP Theorem, Ontologien, Knowledge\nGraphs)
115	1	Die Studierenden können die Terminologie forensischer\nArbeit verstehen und anwenden. Sie sind in der Lage,\ndie Qualität und Manipulierbarkeit digitalforensischer\nSpuren insb. auf Festspeicherdatenträgern\neinzuschätzen und kennen Anwendungen, mit Hilfe\nderer Spuren untersucht werden können. In einer\nGruppe Studierender kommunizieren Studierende unter\nVerwendung von Fachtermini. Sie zeigen, dass sie\ndigitalforensische Spuren aus Installationen des\nBetriebssystems Windows sachkundig erheben,\nanalysieren, auswerten und dokumentieren können, um\nkünftig bei der Aufklärung von Vorfällen mitwirken zu\nkönnen. Moderne Entwicklungen zur Beobachtung von\nSystemen unter Verwendung von Virtualisierung\nkönnen sie wiedergeben und erarbeiten Limitierungen\nbestehender Lösungen. Darüber hinaus verstehen sie\narchitekturelle Gegebenheiten von Android-basierten\nSmartphones im Hinblick auf die digitalforensische\nBedeutung.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 60 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	Methodische Fundierung der digitalen Forensik und\nforensischen Informatik • Dokumentation von\nforensischen Untersuchungen • Analyse forensischer\nBerichte • digitalforensische Spuren in Windows-\nInstallationen • Endpunktbasierte Erkennung und\nReaktion (EDR) • Einbruchserkennung • Hypervisor •\nSmartphone-Forensik
101	1	• Die Studierenden haben ein fundiertes Verständnis\nder theoretischen Hintergründe, Grenzen und\nEinsatzszenarien von datenwissenschaftlichen\nVerfahren und können diese\nFachwissenschaftler*innen und Fachfremden\nerläutern.\n• Sie sind in der Lage, den Einsatz\ndatenwissenschaftlicher Verfahren kritisch zu\nhinterfragen und gewissenhaft zu planen.\n• Dadurch sind sie in der Lage,\ndatenwissenschaftliche Verfahren sinnvoll zur\nProblemlösung in verschiedenen\nAnwendungsszenarien einzubringen und\neinzusetzen.	\N	Theoretische Grundlagen und Anwendung\nverschiedener\n• Regressionsverfahren\n• Klassifikationsverfahren\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 27 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\n• Clustering-Verfahren\n• Bootstrap- und Kreuzvalidierungsverfahren\n• Gütekriterien für die Ergebnisse\ndatenwissenschaftlicher Verfahren
117	1	Die Studierenden können die Bedeutung und Wirkung\nvon Design im Unternehmenskontext einordnen und als\nstrategisches Instrument einsetzen. Den Studierenden\nist die Planung von Designprojekten vertraut.\n• indem Designprozesse im Unternehmensbezug\nanalysiert werden.\n• indem erprobt wird, Designprojekte in der\nUnternehmenspraxis sowie als Freiberufler\nprofessionell zu planen, kalkulieren, strukturieren\nund professionell zu präsentieren.\n• indem der Umgang Designmethoden und\nKreativitätstechniken gelernt wird.\n• indem designtheoretisches Wissen erarbeitet und\nfundierte Designargumentation geübt wird.\nUm die Prozesse und Instrumente des Designs in\nFolgeveranstaltungen und -projekten mitzubedenken\nund einzusetzen.	\N	Einführung in den Designprozess und das\nDesignverständnis (Designtheorie), Design im\nUnternehmensbezug, Strategisches\nDesignmanagement (Positionierung und\nDesignstrategie), Corporate Designmanagement\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 64 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n(Branding), Operationales\nDesignmanagement/Designmethodik\n(Designprojektplanung, Kreativität, Bewertung,\nPräsentation); Designbüromanagement\n(Designangebot, -kalkulation)\nDie Studierenden bereiten selbständig Teilthemen in\nForm ausführlicher Referate/Präsentationen auf, die als\nDiskussionsbeitrag in der Lerngruppe dienen. Vorrangig\nwird Bezug auf aktuellste Literatur genommen.
118	1	Die Studierenden arbeiten sich in aktuelle und\nzukunftsweisende Forschungsthemen im Bereich der\nIT-Sicherheit und des Datenschutzes ein. Dazu wird in\njedem Semester ein anderes Schwerpunktthema, in\nwelches sich die Studierenden einarbeiten, den\naktuellen Stand der Technik verstehen und den Stand\nder Forschung sukzessive erarbeiten. Dabei sollen die\nStudierenden über Kenntnisse, ein Verständnis und\nWissen in den folgenden Themenkomplexen.\n• Eigenständige Erarbeitung von vertieften\nKenntnissen über aktuelle Forschungsthemen in der\nIT-Sicherheit und des Datenschutzes (Basierend auf\nPrimärliteratur).\n• Kritische Auseinandersetzung mit dem aktuellen\nwissenschaftlichen Diskurs bzw. neuen\nErkenntnissen in dem gewählten Themenkomplex\n• Identifikation von komplexen Sicherheitsproblemen\nund Entwicklung von innovativen Lösungen bzw.\nMethodiken.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 66 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Präzise Präsentation und Kommunikation von\nForschungsergebnissen.	\N	• Die Studierenden lernen den Prozess wie in der\nWissenschaft in der Regel Publikationen bewertet\nund veröffentlicht werden (peer-review) kennen.\n• Definition und Vorstellung eines Themenkomplexes,\nder innerhalb der Veranstaltung von den\nStudierenden vertieft und aus unterschiedlichen\nBlickwinkeln bearbeitet wird. Die Definition der\nThemen soll dabei entlang aktueller\nVeröffentlichungen auf führenden wissenschaftlichen\nKonferenzen und Journalen zum Thema IT-\nSicherheit und Privatheit erfolgen.\n• Die Studierenden stellen aktuelle wissenschaftliche\nVeröffentlichungen in dem Themenkomplex der\nGruppe vor\n• Die Studierenden diskutieren in der Gruppe die\nvorgestellten Arbeiten und können diese so im\ngrößeren Rahmen des gesamtthemenkomplexes\nsetzen und interpretieren.\n• Die Studierenden fertigen eigene Experimente an,\num die vorgestellten Ergebnisse zu demonstrieren.
102	1	Die Studierenden können erfolgreich in Teamarbeit ein\nkomplexes wissenschaftsnahes Problem zur\nEntwicklung intelligenter Systeme lösen.\nSie sind in der Lage, ihre Resulate kritisch und\nmethodisch mit SOTA-Ergebnissen zu vergleichen.\nSie sind in der Lage, ihre Ergebnis in der Veranstaltung\nund in der Hochschulöffentlichkeit verständlich und\nnachvollziehbar vorzustellen und im Diskurs zu\nverteidigen.\nWenn möglich, nehmen sie an einem internationalen\nWettbewerb teil und lernen, im Austausch mit anderen\neinen Beitrag zum wissenschaftlichen Fortschritt zu\nleisten.	\N	Ein laufender oder kürzlich abgeschlossener\nWettbewerb aus dem Themenkreis intelligenter\nInformationsverarbeitung oder Optimierung bestimmt in\nder Regel die inhaltliche Fokussierung, alternativ kann\nein aktuelles Thema aus der laufenden Forschung zu\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 29 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\nintelligenten Systeme vertiefend aufgegriffen werden,\nz.B. aus dem Bereich Reinforcement Learning.\nIn der Vergangenheit wurde in oder in Folge der\nVeranstaltung erfolgreich an Wettbewerben\nteilgenommen, z.B. PowerTAC (1. Platz) und TAC\n(Trading Agent Competition, „Best Newcomer“), Bidding\nAgent Competition (Agenten zur Optimierung von\nschlüsselwortbasierten Werbekampagnen, 1. Platz)\nDiscovery Challenge European Conference on Machine\nLearning (ECML) zu automatisierter Verschlagwortung,\n(2. Platz, Kategorie Freie Schlagwortfindung offline)\nThematische Einarbeitung durch Vorlesung und\nThemenvorträge. Praktische Teamarbeit zur\nKonzeption und Systemrealisierung.
85	1	Die Studierende werden in die Lage versetzt:\n• die wissenschaftstheoretischen Ansätze der\nBetriebswirtschaftslehre zu verstehen und zu\nerläutern,\n• die wesentlichen Aufgaben der betrieblichen\nFunktionalbereiche und deren Interdependenzen zu\nverstehen,\n• die vermittelten betriebswirtschaftlichen\nVorgehensweisen und Methoden anzuwenden.	\N	• Das Unternehmen und seine Rahmenbedingungen\n• Konstitutive Entscheidungen und Ziele eines\nUnternehmens\n• Unternehmensführung\n• Organisation\n• Marketing\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 90 -\nInformatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Personal\n• Finanzwirtschaft\n• Investitions- und Wirtschaftlichkeitsrechnung\n• Fallbeispiele aus der Unternehmenspraxis
103	1	Aufbauend auf Schulkenntnissen aus dem Bereich der\nNaturwissenschaften verstehen die Studierenden nach\ndem Studium dieses Moduls, welche Bedeutung\nneuere Rechnerkonzepte für die moderne Informatik\nhaben. Durch die Beschäftigung mit der\nnaturwissenschaftlichen Methodik wurde gleichzeitig\ndie logisch, analytische Denkweise verbessert und\nProblemlösungskompetenz entwickelt.\nDieses Modul trägt dazu bei, die Absolventen ganz\nallgemein zu wissenschaftlicher Arbeit und\nverantwortlichem Handeln bei der beruflichen Tätigkeit\nund in der Gesellschaft zu befähigen.\nInsbesondere werden durch dieses Modul die\nfolgenden Fertigkeiten und Kompetenzen der\nAbsolventen gestärkt:\nSie sind in der Lage, komplexe Aufgabenstellungen\naus einem neuen oder in der Entwicklung begriffenen\nBereich zu abstrahieren und zu formulieren sowie\nKonzepte und Lösungen zu komplexen, zum Teil auch\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 31 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\nunüblichen Aufgabenstellungen – ggf. unter\nEinbeziehung anderer Disziplinen – zu entwickeln.\nSie haben die Kompetenz, sich systematisch und in\nkurzer Zeit in neue Systeme und Methoden\neinzuarbeiten, neue und aufkommende Technologien\nzu untersuchen und zu bewerten sowie Wissen aus\nverschiedenen Bereichen methodisch zu klassifizieren\nund systematisch zu kombinieren.\nSie wissen, auf welchen Grundprinzipien\nQuantencomputer beruhen und wie man mit dem\nErbgut – der DNA – rechnen kann. Dabei wird die\nBiologie − im Bereich der Lebensinformatik − vor allem\nverstanden als die Wissenschaft von den komplexesten\nSystemen der Informations-verarbeitung, die es nur in\nder Natur gibt und deren Übertragung in die Informatik\nvon großer Bedeutung ist.	der Absolventen gestärkt: Sie sind in der Lage, komplexe Aufgabenstellungen aus einem neuen oder in der Entwicklung begriffenen Bereich zu abstrahieren und zu formulieren sowie Konzepte und Lösungen zu komplexen, zum Teil auch	• Einführung\no Lernhinweise\no Informationen\no Intelligenz\n• Molecular Computing\no BioPhysik\no Molekulargenetik\no Epigenetik\no Molekulares Rechnen\n• Computational Intelligence\no Neurobiologie\no Neuroinformatik\no Neuromorphie\no Fuzzy-Logik\n• Neue Technologien\no Quanten\no Quanteninformatik\no Diverses
104	1	Die Studierenden beherrschen die grundlegenden\nKonzepte der funktionalen Programmierung (FP) und\nkönnen diese für kleine Aufgabenstellungen (in der\nLehrsprache Haskell) sicher anwenden. Sie kennen die\nin FP möglichen Realisierungsmuster, z.B. in\nVerbindung mit unendlichen Datenstrukturen oder\nMonaden. Sie verstehen, dass FP für eine Vielzahl von\nProblemen eine elegante, fehlervermeidende und\nproduktive Form der Programmierung ist. Durch\nTermersetzung als Auswertungsmodell gewinnen die\nStudierenden einen Einblick in symbolisches Rechnen\nund erweiterten zudem ihre Sicht auf den Begriff der\nBerechnung. Durch Seitenblicke auf die Sprache Java\nerkennen die Studierenden schließlich, dass viele\nKonzepte von FP auch in originär nicht funktionalen\nSprachen angewendet werden können. Dadurch\nverbessern sie ihre Produktivität und Qualität bei der\nSoftware-Entwicklung in solchen Sprachen.	\N	Ausdrücke, Reduktion und Reduktionsstrategien •\nTypen und Typklassen • Currying und Funktionen\nhöherer Ordnung • Listen, rekursive Datentypen • Fold\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 34 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\nfür Listen, laws of fold • Unendliche Datenstrukturen •\nProgrammieren mit lazy evaluation • Monaden •\nPraxisbeispiele
119	1	Die Studierenden kennen und verstehen die wichtigsten\nTheorien zur Motivationsforschung. Sie kennen die\nVoraussetzungen und Mechanismen des Lernens und\ndes Erwerbens von Fertigkeiten.\nDie Studierenden kennen wichtige Studien und\nForschungsergebnisse zur Wirksamkeit von Serious\nGames und von Gamification.\nDie Studierenden kennen Vorgehensweisen für das\nManagement von Gamifizierungsprojekten. Sie wissen,\nwelche Entwicklungsdokumente zu erstellen sind und\nkennen die dazu nötigen Werkzeuge. Sie kennen die\nverschiedenen Rollen in einem Team und deren\nAufgaben im Entwicklungsprozess.\nDie Studierenden können einen vorgegebenen\nAnwendungs-Gegenstand mit den in der Veranstaltung\nbehandelten Methoden gamifizieren und dazu ein\ndetailliertes Konzept vorlegen. Sie sollen in die Lage\nversetzt sein, Gamification-Konzeptionen auch für\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 68 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\nberufliche oder Forschungs-Kontexte entwickeln zu\nkönnen.\nBei solchen Entwicklungen können die Studierenden\nauch komplexe Sachverhalte im Hinblick auf\nGamification-Potenzial analysieren. Sie sind in der\nLage, erfolgsentscheidende Randbedingungen beim\nKonzeptentwurf umfassend zu berücksichtigen.\nDie Studierenden können die Anwendung einzelner\nGamifizierungs-Elemente kontextuell und vor dem\nHintergrund der Erkenntnisse der Motivations- und\nLernforschung begründen. Sie sind zudem in der Lage,\ninnovative Technologien in ihr Konzept\nmiteinzubeziehen.	\N	Theorien zur Motivation (z.B. Ryan und Deci, ARCS-\nModell) und die Taxonomie der intrinsischen Motivation\nvon Lepper und Malone\nGrundlagen des Lernens und verschiedene didaktische\nAnsätze (z.B. verteiltes Üben, Scaffolding, episodisches\nGedächtnis, soziales Lernen)\nNeueste Studien und Forschungsergebnisse zur\nEffektivität von Games und Gamification z.B. für das\nLernen, für den Erwerb von motorischen und geistigen\nFertigkeiten, zur Problemlösung, aber auch etwa zur\nBeeinflussung von Personen\nUnterschiede zwischen Serious Games und\nGamification und Herausarbeitung von Vor- und\nNachteilen für deren Einsatz\nAnwendung von Gamification auf unterschiedliche\nLerndomänen und in anderen Kontexten (z.B.\nUnterhaltung, Nudging, Werbung)\nManagement von Gamification-Projekten mit agilen\nMethoden wie Scrum, Rollen und ihre Aufgaben im\nEntwicklungsteam\nFall-Beispiel: Gamifizierung eines\nAnwendungsgegenstandes als Gruppenarbeit (z.B. ein\ngymnasialer Lernstoff, ein Erste-Hilfe-Kurs, eine Folge\nTrainingseinheiten zur Erreichung eines sportlichen\nZieles). Die Studierenden müssen dabei\nRandbedingungen wie z.B. die besondere Förderung\nleistungsschwächerer Teilnehmer berücksichtigen. Sie\nsollen die allgemeinen Inhalte und die behandelten\nForschungsergebnisse aus der Lehrveranstaltung\nberücksichtigen. Sie sollen zudem innovative\nTechnologien (z.B. moderne Smartphone-Sensorik,\nXR-Brillen) in das Konzept miteinbeziehen.\nSemesterbegleitend Mitarbeit an einem geteilten\nDokument zur Lehrveranstaltung. Dort werden Fragen\nbeantwortet und Aufgaben zum Stoff gelöst. Dabei\nwerden die abstrakten Konzepte des Lehrstoffes über\nBeispiele konkretisiert.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 69 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
120	1	Die Studierenden sind in der Lage die\nHerausforderungen für die Gestaltung,\nImplementierung, Evaluation und Nutzung von\ninteraktiven kollaborativen Arbeitsumgebungen\nanalysieren können.\nDie Studierenden sind in der Lage, auf dieser Basis für\nkonkrete Problemstellungen und Arbeitssituationen\nLösungskonzepte zu gestalten und zu bewerten –\nsowohl aus Sicht des Benutzers und dessen\nUmgebung als auch aus technologischer Perspektive,\ninsbesondere auch hinsichtlich hybrider\nKollaborationsszenarien.\nDie Studierenden können Evaluationskonzepte für\ninteraktive kollaborative Arbeitsumgebungen verstehen\nund anwenden.\nDurch eine erfolgreiche Absolvierung dieses Moduls\nsind die Studierenden in der Lage, Softwaresysteme\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 71 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\nund Technologien für interaktive kollaborative\nArbeitsumgebungen zu entwerfen und zu entwickeln.	\N	Heutige Arbeitsumgebungen sind größtmöglicher\nFlexibilität unterworfen. Dabei spielt die dynamische\nZusammenarbeit mehrerer Personen eine\nentscheidende Rolle. Folgende Themen werden in\ndiesem Modul behandelt:\n• Grundlagen und Grundbegriffe von Computer-\nSupported Cooperative Work Systemen (CSCW)\nanhand von Beispielen, Anwendungsfällen und\nVorgehensmodellen.\n• Überblick der Kerndimensionen der CSCW (z.B.\nAwareness, Coordination, Articulation work,\nAppropriation) und deren Implikation für die\nGestaltung und Umsetzung von interaktiven\nkollaborativen Arbeitsumgebungen.\n• Herausforderungen und Techniken für die\ntechnische Umsetzung von interaktiven\nkollaborativen Arbeitsumgebungen\n• Evaluationsmethoden für interaktive kollaborative\nArbeitsumgebungen.\nIn der Vorlesung werden die theoretischen Inhalte\nvermittelt. Im Rahmen eines Projekts werden die\nStudierenden eigene Konzepte für interaktive\nkollaborative Arbeitsumgebungen entwickeln und\nprototypisch umsetzen
105	1	Die Studierenden kennen grundlegende Methoden und\nStrukturen aus ausgewählten Kapiteln der künstlichen\nIntelligenz und können diese zur Konstruktion\nintelligenter Systeme anwenden.\nSie sind insbesondere in der Lage, durch Abstraktion\nund Modellbildung Problemstellungen zu analysieren,\nZusammenhänge zu vorhandenem Wissen zu\nerkennen und entsprechende Lösungsansätze zu\nidentifizieren und umzusetzen.\nSie sind mit der Problematik der Interpretation von\nModellen und den Risiken ihres Einsatzes vertraut und\nkönnen Ansätze, diese Risiken zu bewerten und zu\nminimieren, analysieren und kritisch hinterfragen.	\N	Einführendes: Geschichte der KI, ausgewählte aktuelle\nForschungsansätze.\nGrundlegendes: Problemlösung mit exakter und\nheuristischer Suche, Constraint\nSatisfaction/Optimization. Problemmodellierung und -\nlösung mit Logik und Wahrscheinlichkeiten.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 36 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\nLernen und intelligente Informationsanalyse: klassische\nVerfahren (Kategorisierung, Clustering: u.a. Naive\nBayes, Decision Trees, EM), stochastische Verfahren\n(Hidden Markov, POMDP), naturanaloge Verfahren\n(NN, Deep-NN).\nOptimierung von Handlungssequenzen: Adversarial\nSearch, DP und Reinforcement Learning, inkl. Deep-\nRL.\nInterpretierbarkeit von Modellen, ethische und\ngesellschaftliche Konsequenzen des Einsatzes von\nintelligenten Systemen.
121	1	• Gutes Verständnis von möglichen Angriffen und\ngeeigneten Gegenmaßnahmen im Bereich der\nInternet-Infrastruktur\n• Erlangen von Kenntnissen über den Aufbau, die\nPrinzipien, die Architektur und die Funktionsweise\nvon Sicherheitskomponenten und -systemen im\nBereich Frühwarn- und Infrastruktur-\nSicherheitssystemen\n• Sammeln von Erfahrungen bei der Ausarbeitung und\nPräsentation von neuen Themen aus dem Bereich\nInternet-Sicherheit\n• Gewinnen von praktischen Erfahrungen über die\nNutzung und die Wirkung von Sicherheitssystemen\nim Bereich der Internet-Infrastruktur\n• Erleben der Notwendigkeit und Wichtigkeit der\nInternet-Sicherheit\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 73 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	• Cyber-Sicherheit Frühwarn- und Lagebildsysteme\n• Firewall-Systeme: Definition, Elemente, Konzepte,\npraktischer Einsatz, die Wirkung und die\nMög lichkeiten und Grenzen von Firewall-Systemen\n• IPSec-Verschlüsselung - VPN-Systeme: Ziele,\nAnwendungsformen, Konzepte, Mechanismen und\nProtokolle von VPNs und Anwendungsbeispiele\n• Transport Layer Security (TLS): Idee, Mechanismen,\nProtokolle und Umsetzungskonzepte\n• Cyber-Sicherheitsmaßnahmen-gegen-DDoS-Angriffe\n• Wirtschaftlichkeit von Cyber-Sicherheitsmaßnahmen\n• Social-Web-Cyber-Sicherheit\n• Vertrauen und Vertrauenswürdigkeit
122	1	• Gutes Verständnis von möglichen Angriffen und\ngeeigneten Gegenmaßnahmen im Bereich der\nEndgeräte und Anwendungen\n• Erlangen von Kenntnissen über den Aufbau, die\nPrinzipien, die Architektur und die Funktionsweise\nvon Sicherheitskomponenten und -systemen im\nBereich Trusted Computing und PKI- und\nBlockchain-orientierten Sicherheitssystemen\n• Sammeln von Erfahrungen bei der Ausarbeitung und\nPräsentation von neuen Themen aus dem Bereich\nInternet-Sicherheit\n• Gewinnen von praktischen Erfahrungen über die\nNutzung und die Wirkung von Sicherheitssystemen\nim Bereich Trusted Computing und PKI- und\nBlockchain-orientierten Sicherheitssystemen\n• Erleben der Notwendigkeit und Wichtigkeit der\nInternet-Sicherheit\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 75 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	• Digitale Signatur: Gesetzliche Grundlagen,\nMechanismen und Prinzipien, Anwendungsbeispiele\n• Public-Key-Infrastruktur (PKI): Aufgaben,\nKomponenten, gesetzlicher Hintergrund, Modelle,\nUmsetzungskonzepte und praktische Beispiele\n• Blockchain-Technologie: Aufgaben, Komponenten\nund Eigenschaften, Umsetzungskonzepte und\npraktische Beispiele\n• Künstliche Intelligenz für Cyber-Sicherheit:\nEinordnung und Definitionen, Maschinelles Lernen,\nKünstliche Neuronale Netze, Anwendungen KI und\nCyber-Sicherheit, Angriffe auf maschinelles Lernen\nund Herausforderungen\n• Trusted Computing\n- TPM (Aufbau und Funktionen)\n- TC Funktionen (Trusted Boot, Binding, Sealing,\nand(Remote) Attestation),\n- Trusted Computing Base\n- Sicherheitsplattform (Idee, Ziele, Methoden, …)\n- Anwendungsbeispiele\n• Trusted Network Connect (TNC)\n- grundsätzliche Idee\n- TNC Architektur\n- T-NAC (Idee, Ziele, Methoden, …)\n• E-Mail-Security: Elemente, Konzepte und praktischer\nEinsatz\n• Anti-Spam-System: Schäden, Quellen; Anti-Spam-\nTechnologien, Kopfzeilenanalyse, Textanalyse,\nBlacklist, Distributed Checksum Clearinghouse\n(DCC), Distributed IP Reputation System, usw.\n• Botnetze: Malware, Infektionsvektoren, Botnetzen,\nSchadfunktionen durch Bots und Gegenmaßnahmen
123	1	Die Studierenden\n• verstehen fortgeschrittene\nImplementationskonzepte für gebrauchstaugliche\ninteraktive Systeme\n• können Anwendungssoftware in Hinblick auf\nLokalisierung und Zugänglichkeit entwerfen\n• können Interaktive Systeme so implementieren,\ndass Mehrsprachigkeit und länderspezifische\nGegebenheiten unterstützt werden\n• verstehen die Konzepte assistiver Techniken bei\nder Entwicklung von interaktiven Systemen\n• können interaktive Systeme so implementieren,\ndass Zugänglichkeit / Barrierefreiheit\ngewährleistet ist\n• können einfache assistive Techniken in\ninteraktiven Systemen programmieren\n• verstehen die Möglichkeiten der Anpassung des\nAussehens von interaktiven Systemen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 78 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• können das Aussehen eines interaktiven Systems\nan Vorgaben eines Style Guide anpassen	\N	• Anforderungen der Gebrauchstauglichkeit\n• Anforderungen eines „Design for all“\n• Rechtliche Vorgaben für Gebrauchstauglichkeit,\nBarrierefreiheit und Individualisierbarkeit\n• Benutzeranalyse in Hinblick auf Sprache sowie\nländerspezifische und kulturelle Unterschiede\n• Benutzeranalyse in Hinblick auf besondere\nBedürfnisse\n• Konzepte für Internationalisierung und Lokalisierung\n• Implementation von GUIs mit Internationalisierung\nund Lokalisierung (z.B. mit Java FX)\n• Konzepte für Barrierefreiheit und Zugänglichkeit\nImplementation von barrierefreien GUIs (z.B. mit\nJava FX)\n• Änderung des Aussehens eines GUI (z.B. in Java\nFX)
92	1	Die/der Studierende ist in der Lage, die Ergebnisse\nihrer/seiner Masterarbeit aus der praktischen oder\ntechnischen Informatik, ihre fachlichen Grundlagen, ihre\nEinordnung in den aktuellen Stand der Technik, bzw.\nder Forschung, ihre fächerübergreifenden\nZusammenhänge und ihre außerfachlichen Bezüge in\nbegrenzter Zeit in einem Vortrag zu präsentieren.\nDarüber hinaus kann sie/er Fragen zu inhaltlichen\nDetails, zu fachlichen Begründungen und Methoden\nsowie zu inhaltlichen Zusammenhängen zwischen\nTeilbereichen ihrer/seiner Arbeit selbstständig\nbeantworten.\nDie/der Studierende kann ihre/seine Masterarbeit auch\nim Kontext beurteilen und ihre Bedeutung für die Praxis\nund die Forschung einschätzen und ist in der Lage,\nauch entsprechende Fragen nach themen- und\nfachübergreifenden Zusammenhängen zu beantworten.	\N	Zunächst wird der Inhalt der Masterarbeit aus der\npraktischen oder technischen Informatik im Rahmen\neines Vortrags präsentiert. Anschließend sollen in einer\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 7 -\nInformatik (Master) – PO2023 Modulkatalog\nDiskussion Fragen zum Vortrag und zur Masterarbeit\nbeantwortet werden.\nDie Prüfer können weitere Zuhörer zulassen. Diese\nZulassung kann sich nur auf den Vortrag, auf den\nVortrag und einen Teil der Diskussion oder auf das\ngesamte Kolloquium zur Masterarbeit erstrecken.\nDer Vortrag soll die Problemstellung der Masterarbeit,\ndie vergleichende Darstellung alternativer oder\nkonkurrierender Lösungsansätze mit Bezug zum\naktuellen Stand der Technik, bzw. Forschung, den\ngewählten Lösungsansatz, die erzielten Ergebnisse\nzusammen mit einer abschließenden Bewertung der\nArbeit sowie einen Ausblick beinhalten. Je nach Thema\nkönnen weitere Anforderungen hinzukommen.\nDie Dauer des Kolloquiums ist in § 26 der Master-\nRahmenprüfungsordnung und § 16 der\nStudiengangsprüfungsordnung geregelt.
106	1	Die Studierenden kennen die Konzepte der logischen\nProgrammierung. Sie sind in der Lage, Probleme\ndeklarativ zu beschreiben und hierfür logische\nProgramme mit der Programmiersprache Prolog zu\nentwickeln.\nSie kennen die Theorie der logischen Programmierung\nund können sowohl die deklarative als auch die\nprozedurale Semantik logischer Programme im Detail\nerläutern. Sie können die Unterschiede der\nprozeduralen Semantik zur Auswertungsstrategie von\nProlog benennen und begründen, wie diese\nAbweichungen zustande kommen.\nMit Kenntnissen der logischen Programmierung sind\ndie Teilnehmer später besser in der Lage, Probleme auf\neinem höheren Abstraktionsniveau zu beschreiben und\ndamit die Problemanalyse vom Entwurf einer\nProblemlösungsstrategie besser zu trennen.	\N	Während in der imperativen Programmierung mit\nProgrammen alle Schritte festgelegt werden, die der\nComputer in der angegebenen Reihenfolge\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 38 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\nauszuführen hat, wird in der logischen Programmierung\ndas zu lösende Problem nur beschrieben und die\nLösungsfindung einem Auswertungssystem überlassen.\nInhalte der Vorlesung sind:\n• Problemlösen mit Prolog: Auswertungsstrategie,\nUnifikation, Backtracking.\n• Programmiertechniken: Generate & Test,\nRelationen, Datenstrukturen als Fakten,\nMusterorientierte Wissensrepräsentation\n• Theorie der logischen Programmierung:\nPrädikatenlogik 1. Ordnung, Deklarative\nSemantik, SLD-/SLDNF-Resolution\n• Nicht-logische Bestandteile von Prolog: Negation\nund Cut\n• Sprachverarbeitung in Prolog: Grammatiken und\nParsergenerierung\n• Ausblick Constraint-logische Programmierung
93	1	Die/der Studierende ist in der Lage, innerhalb einer\nvorgegebenen Frist entweder\neine schwierige und komplexe praxisorientierte\nProblemstellung aus der praktischen Informatik sowohl\nin ihren fachlichen Einzelheiten als auch in den themen-\nund fachübergreifenden Zusammenhängen nach\nwissenschaftlichen Methoden selbständig zu bearbeiten\nund zu lösen oder\neine anspruchsvolle Fragestellung aus der aktuellen\nForschung auf dem Gebiet der praktischen Informatik\nunter Anleitung eigenständig zu bearbeiten und\nselbstständig ein neues wissenschaftliches Ergebnis zu\nentwickeln.	\N	Es wird eine praxisorientierte Problemstellung oder eine\nFragestellung aus der Forschung auf dem Gebiet der\npraktischen Informatik mit den im Studium erworbenen\noder während der Masterarbeit neu erlernten\nwissenschaftlichen Methoden in begrenzter Zeit mit\nUnterstützung eines erfahrenen Betreuers gelöst.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 9 -\nInformatik (Master) – PO2023 Modulkatalog
107	1	Students know\n• nature of distributed systems\n• Software frameworks\n• OSGi components\n• Students will understand\n• the notion of an agent, how agents are distinct from\nother software paradigms (e.g., objects), and\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 40 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\nunderstand the characteristics of applications that\nlend themselves to an agent-oriented solution;\n• the key issues associated with constructing agents\ncapable of intelligent autonomous action, and the\nmain approaches taken to developing such agents;\n• the key issues and approaches to high-level\ncommunication in multi-agent systems;\n• the key issues in designing societies of agents that\ncan effectively cooperate in order to solve problems;\n• the main application areas of agent-based solutions;\n• the main techniques for automated decision-making\nin multi-agent systems, including techniques for\nvoting, forming coalitions, allocating scarce\nresources, and bargaining.\n• Students are able to develop multi-agent systems\nusing OSGi components	\N	• Multi-Agent Systems\n• Introduction: what is an agent: agents and objects;\nagents and expert systems; agents and distributed\nsystems; typical application areas for agent systems.\n• Intelligent Agents:\nabstract architectures for agents; tasks for agents.\nthe design of intelligent agents: reasoning agents,\nagents as reactive systems ; hybrid agents, layered\nagents\n• Multiagent Systems:\n• ontologies: OWL, KIF, RDF;\n• interaction languages and protocols: speech acts,\nKQML/KIF, the FIPA framework;\n• cooperation: cooperative distributed problem solving\n(CDPS), partial global planning; coherence and\ncoordination; applications.\n• Multi-Agent Decision Making\n• OSGi\n• OSGi components\n• OSGi in MAS
108	1	• Die Studierenden kennen Cloud Technologien in\neiner größeren Bandbreite und haben die Fähigkeit,\nverschiedenen Cloudansätze für einen gegebene\nAufgabenstellung zu bewerten und die geeignete\nauszuwählen\n• Die Studierenden kennen verschieden\nMobilfunktechniken in einer größeren Bandbreite\nund haben die Fähigkeit, verschiedene mobile\nAnbindungsmöglichkeiten für eine gegebene\nAufgabenstellung zu bewerten und die geeigneten\nauszuwählen.\n• Die Studierenden erwerben die Kompetenz, neue\nEntwicklungen im Bereich Cloud und Mobilfunk zu\nverstehen, zu bewerten und für ihre Arbeit nutzbar\nzu machen.	\N	• Vertiefte Betrachtung zu Cloud Technologien.\n• Azure Cloud mit Anwendungsszenarien als Beispiel.\n• Grundlagen zu Software Defined Networking.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 43 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\n• Use Case getriebene Entwicklung von\nMobilfunknetzen und deren Ausprägung am Beispiel\n5G.\n• Praktikum mit Themen aus dem Bereich Cloud am\nBeispiel der Azure Cloud und zu Mobile Computing\nam Beispiel von LTE und 5G
60	1	Die Studierenden sind in der Lage, durch\nwissenschaftliches Vorgehen für praktische\nProblemstellungen den Stand der Technik zu\nrecherchieren, Anforderungen zu analysieren, Lösungen\nzu entwickeln und zu begründen sowie\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 33 -\nInformatik (Bachelor) – PO2023 Modulkatalog\nArbeitsergebnisse professionell zu präsentieren und zu\nbewerten.\nSie können die in der Vorlesung zu diesem Modul\nerlernten grundlegenden Management-Methoden\nzur Projektdefinition, -planung und -kontrolle bei\nder Projektarbeit anwenden und sind in der Lage,\nBesprechungen zu moderieren und zu protokollieren.\nDie Studierenden haben ein Grundverständnis für die\nAufgaben und Erfolgsfaktoren bei der Durchführung\neines mittelgroßen Software-Projekts in einem Team.\nSie sind in der Lage das bisher im Studium Erlernte –\ninsbesondere Methoden, Verfahren und Werkzeuge –\nanzuwenden, um ein komplexes Softwareprojekt von\nder Anforderungsanalyse über Entwurf,\nImplementierung und Evaluierung bis hin zur\nAuslieferung selbstständig und im Team von 5 bis 8\nStudierenden zu bewältigen.\nDie Studierenden können komplexe Aufgaben sinnvoll\nstrukturieren und typische Schnittstellenprobleme so-\nwohl auf technisch-fachlicher als auch auf sozialer\nEbene bewältigen.	\N	Der Vorlesungsteil wird als globale Veranstaltung für\nalle Teilnehmer abgehalten und führt in die Grundlagen\ndes wissenschaftlichen Arbeitens und des\nManagements von Softwareprojekten ein.\nZum wissenschaftlichen Arbeiten gehören:\n• Recherche\n• Analyse\n• Erstellen wissenschaftlicher Texte\n• Präsentation\nDer Vorlesungsteil wird als globale Veranstaltung für\nalle Teilnehmer abgehalten und führt in die Grundlagen\ndes Managements von Softwareprojekten ein. Hierzu\ngehören:\n• Dateiorganisation, Protokolle\n• Projektdefinition\n• Projektplanung\n• Konfigurationsmanagement\n• Projektkontrolle und -steuerung\n• Projektabschluss\nIm Praktikumsteil steht die systematische Anwendung\nund Zusammenführung von in\nVorgängerveranstaltungen erlerntem Wissen im\nVordergrund:\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 34 -\nInformatik (Bachelor) – PO2023 Modulkatalog\n• Durchführung eines mittelgroßen und\nanspruchsvollen Software-Projekts\n• Selbstständige Durchführung des Projekts von der\nAnalyse über Design, Implementierung und Test\nbis zur Dokumentation\n• Anwendung von grundlegenden\nProjektmanagement-Methoden für Definition,\nPlanung, Kontrolle und Realisierung des Projekts.\n• Vertiefung von Programmierkenntnissen\n• Nutzung von Versionsmanagementwerkzeugen\nund Ticketsystemen\n• Softwareentwicklung im Team und ggf. unter\nBeteiligung von externen Anwendern\n• In regelmäßigen Projektsitzungen werden im\nRahmen einer Qualitätssicherung die\nZwischenergebnisse von den Teams durch\nPräsentation und Vorführung vorgestellt und\ndiskutiert.\nDie Projektthemen werden rechtzeitig vor Beginn der\nVeranstaltung bekannt gemacht. Es wird versucht,\npraxisnahe Projekte, ggf. auch von hochschulexternen\nAnwendern der praktischen und technischen Informatik\nzu akquirieren. Projektvorschläge von Studierenden\nsind nach Absprache ebenfalls möglich.
124	1	Die Studierenden vertiefen die Konzepte zur Analyse\nvon Schadsoftware (Malware) und zur Erkennung von\nAngriffswerkzeugen. Anhand realer Cyber-Angriffe\nwenden sie aktuelle Methoden zur technischen Analyse\nder Artefakte wie Schadsoftware-Samples oder\nNetzwerkmitschnitten an. Sie erkennen auf diese Weise\ndie Limitierungen aktueller Methoden und entwickeln\neigene Forschungsfragen. Darüber hinaus eignen sie\nsich selbst neues Wissen über das Studium\nbestehender Berichte zu vergangenen Vorfällen an und\nlernen Bewertungskriterien zur Einschätzung der\nBerichte zu entwickeln und anzuwenden sowie kritisch\nzu hinterfragen. Methode zur Attribution von Akteuren\nhinter Cyber-Angriffen müssen angewendet werden\nund eine geopolitische Einordnung wird betrachtet. Im\nRahmen der Veranstaltung wird abschließend anhand\neines realen Cyber-Angriffs die Analyse und die\nKommunikation der Analyse-Ergebnisse in Form eines\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 82 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\nThreat Intelligence Berichts sowie einer dazugehörigen\nPräsentation vertieft.	\N	Malware-Analyse • Malware-Erkennung und -\nKlassifikation • Signaturen • Exploit-Dokumente •\nShellcode • Unpacking und Speicherabzüge • Anti-\nAnalyse-Verfahren von Malware • Cyber kill chain •\nCyber Threat Intelligence • Analysis of Competing\nHypothesis • Angriffsvektoren •\nNetzwerkkommunikation • Attribution • Threat Actor
109	1	Die Studierenden haben ein fundiertes Verständnis der\nmathematischen Grundlagen neuronaler Netze.\nDadurch sind sie in der Lage, Methoden des\nmaschinellen Lernens zu verstehen, weiterzuentwickeln\nund informierte Entscheidungen bezüglich deren\nAnwendung zu treffen.	\N	• Einführung in mehrdimensionale Analysis,\nWiederholung von Aktivierungsfunktionen\n• Matrizenrechnung im Kontext neuronaler Netze\n• Backpropagation, Fehlerfunktionen und\nGradientenabstiegsverfahren\n• Stochastische neuronale Netze\n• Exkurs: Physics informed neural networks
94	1	Die Studierenden haben ein tieferes Verständnis für die\nAufgaben und Erfolgsfaktoren bei der Durchführung\neines mittelgroßen Software-Projekts in einem Team.\nSie sind in der Lage, das im Studium bisher Erlernte –\ninsbesondere Methoden, Verfahren und Werkzeuge –\nanzuwenden, um ein komplexes Softwareprojekt von\nder Anforderungsanalyse über Entwurf,\nImplementierung und Evaluierung bis hin zur\nAuslieferung selbstständig und im Team zu bewältigen.\nDie Studierenden können komplexe Aufgaben sinnvoll\nstrukturieren und typische Schnittstellenprobleme\nsowohl auf technisch-fachlicher als auch auf sozialer\nEbene bewältigen. Sie können Management-Methoden\nzur Projektdefinition, -planung und -kontrolle bei der\nProjektarbeit anwenden.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 11 -\nInformatik (Master) – PO2023 Modulkatalog\nSie sind in der Lage, Besprechungen zu moderieren\nsowie Arbeitsergebnisse professionell zu präsentieren\nund zu bewerten.	\N	Im Rahmen des Master-Projektes Informatik bearbeiten\ndie Teilnehmer eine typische größere Aufgabenstellung\naus dem Bereich der praktischen Informatik oder der\ntechnischen Informatik in einem Projektteam. Die\nThemenstellung erfolgt mit Rücksicht auf die\nKenntnisse der Studierenden.\nBei der Durchführung des Projektes steht die\nsystematische Anwendung und Zusammenführung des\nWissens aus dem jeweiligen Fachgebiet mit den\nMethoden der Softwareentwicklung im Vordergrund:\nDurchführung eines mittelgroßen und anspruchsvollen\nSoftware-Projekts aus dem Gebiet der praktischen oder\ntechnischen Informatik.\nSelbstständige Durchführung des Projekts von der\nAnalyse über Design, Implementierung und Test bis zur\nDokumentation\nAnwendung von grundlegenden Projektmanagement-\nMethoden für Definition, Planung, Kontrolle und\nRealisierung des Projekts.\nVertiefung von Kenntnissen in der Programmierung und\nzu Programmiermethodiken\nSoftwareentwicklung im Team und ggf. unter\nBeteiligung von externen Anwendern\nIn regelmäßigen Projektsitzungen werden im Rahmen\neiner Qualitätssicherung die Zwischenergebnisse von\nden Teams durch Präsentation und Vorführung\nvorgestellt und diskutiert.\nDie Projektthemen werden rechtzeitig vor Beginn der\nVeranstaltung bekannt gemacht. Es wird versucht,\npraxisnahe Projekte auch von hochschulexternen\nAnwendern der praktischen und technischen Informatik\nzu akquirieren. Projektvorschläge von Studierenden\nsind nach Absprache ebenfalls möglich.
95	1	Die Studierenden erwerben die folgenden Fähigkeiten:\nSie sind in der Lage, sich selbstständig in aktuelle\nForschungsfragen zur Informatik auf der Basis von\nPrimärliteratur (Publikationen in Fachzeitschriften sowie\nTagungsbeiträge) einzuarbeiten.\nSie können Informationsrecherchen zu\nforschungsorientierten Fragestellungen durchführen\nund sind in der Lage, dazu eine strukturierte schriftliche\nAufbereitung des aktuellen Stands der Forschung zu\nerarbeiten.\nSie können eine zusammengefasste Darstellung der\nErgebnisse zu einer Fragestellung präsentieren sowie\nin der Diskussion mit allen Seminarteilnehmern sich\nergebende Fragen beantworten und aufgestellte\nThesen angemessen verteidigen.	\N	In diesem Seminar werden aktuelle oder zu vertiefende\nThemen aus der Informatik behandelt.
110	1	Die Studierenden beherrschen den theoretischen und\npraktischen Umgang mit verschiedenen\nDatenbankformaten und deren Anfragesprachen.\nDie Studierenden sind in der Lage, NOSQL-\nDatenbanken unter Einsatz des entsprechenden DB-\nSupports zu benutzen und zu entwickeln.	\N	• Aktuelle Datenbankformate (über das relationale DB-\nModell hinaus) und deren Anwendungsfälle in der\nPraxis\n• Überblick nicht-relationale / NOSQL Datenbanken\nund deren Anfragesprachen\n• Vor- und Nachteile der verschiedenen Formate\n• Wahlweise eines oder mehrerer der folgenden\nThemenkomplexe: Information Retrieval,\nGraphdatenbanken, Ontologien, Grenzen von\nDatenbanken, wichtige Ergebnisse der DB-Theorie
125	1	Studierende\n• können den Begriff „Natural User Interface“\ndefinieren und die Kritik daran wiedergeben\n• kennen die unterschiedlichen Interaktionstechniken\nbei NUIs (Gesten, Sprache etc.)\n• können NUIs für bestimmte Anwendungen (z.B. im\nBereich Edutainment) konzipieren\n• können Benutzerschnittstellen mit bestimmten NUI-\nInteraktionstechniken implementieren.	\N	• Begriffsklärung „Natural User Interface“\n• Gestenbasierte 2-D-Interfaces\n• Gestenbasierte 3-D-Interfaces\n• Sprachbasierte Interfaces\n• Multimediale und multimodale Interfaces Usability\nund User Experience von NUIs\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 84 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
126	1	Die Studierenden lernen verschiedene Ansätze kennen,\nwie Technologien entwickelt und eingesetzt werden\nkönnen, um die Privatsphäre von Nutzerinnen und\nNutzern zu steigern bzw. zu schützen. Außerdem\nwerden Konzepte vorgestellt, wie Technologien\nprivatsphärenfreundlich entwickelt werden können\n(„Privacy-by-Design“). In dem Modul sollen die\nStudierenden Kenntnisse, Verständnis und Wissen in\nden folgenden Themenkomplexen erlernen\n• Weltweite rechtliche Rahmenbedingungen bezüglich\nder Sammlung, Verarbeitung und Speicherung von\npersonenbezogenen Daten.\n• Verständnis der grundlegenden Konzepte und\nTechniken zur Verbesserung der Privatsphäre.\n• Fähigkeit zur Bewertung und Implementierung von\nPET in verschiedenen Kontexten.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 86 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Gängige Methoden und Gegenmaßnahmen zur\nVerfolgung („user tracking“) von Nutzerinnen und\nNutzern im Internet.\n• Methodiken zur anonymen Kommunikation und zur\nVerarbeitung von verschlüsselten Daten.\n• Eigenständige Entwicklung von „Privacy Enhancing\nTechnologies“ basierend auf aktuellen\nForschungsthemen (basierend auf Primärliteratur).	\N	Grundlagen\n• Gesetzliche Rahmenbedingungen (z.B. DSGVO,\nCCPA/CPRA)\n• Ethische Aspekte des Datenschutzes\n• Definition von Grundbegriffen (z.B. Anonymität oder\nPseudonymität)\nUser Tracking im Internet\n• Third-party Tracking Methoden: Cookie-basiertes\nTracking, Browser-Fingerprinting, u.Ä.\n• First-Party Tracking: Server-side Tracking, CNAME\nCloaking, u.Ä.\n• Einwilligungserklärungen: Methodiken zur\nVerwaltung von Einwilligungserklärungen, gängige\nPraktiken zur Einholung von\nEinwilligungserklärungen, u.Ä.\n• Privatheit im Web messen: Generelle Ansätze zur\nMessung des Webs, Design von Messtudien für\nWebanwendungen und Testen von Webseiten\nAnonyme Kommunikation\n• Das Tor-Netzwerk: Architektur und Funktionsweise,\nErläuterung der verschiedenen Knotenarten (Entry\nNode, Relay Node, Exit Node), Onion Routing,\nSicherheitsmerkmale und Schwachstellen\n• Mixnets: Erläuterung des Konzepts von Mixnets und\nderen Unterschiede zu Tor, Mix-Kaskaden, Analyse\nder Sicherheitsmerkmale und Anonymitätsgarantien\nvon Mixnets, typische Anwendungen und\nEinsatzmöglichkeiten von Mixnets\n• Traffic-Analyse: Durchführung und Auswertung von\nTraffic-Analysen zur Untersuchung der Anonymität,\nTesten der Verbindung über das Tor-Netzwerk\nPrivacy by Design\n• Prinzipien und Best Practices des Datenschutzes\ndurch Design\n• Datenschutzfreundliche Architektur, Datenschutz-\nFolgenabschätzung (PIA), Auditing\nKryptographische Ansätze\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 87 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Homomorphe Verschlüsselung: Grundlagen der\nhomomorphen Verschlüsselung; Arten und\nAnwendungen (insb. teilweise homomorphe\nVerschlüsselung und voll homomorphe\nVerschlüsselung)\n• Secure Multi-Party Computation (SMPC): Konzepte\nund Protokolle der sicheren\nMehrparteienberechnung (z.B. Yao's Garbled\nCircuits oder Secret Sharing)
127	1	Die Studierenden beherrschen die grundlegenden\nKonzepte der Speichersicherheit (Memory Safety) und\nkennen Methoden und Techniken, um effizient\nzuverlässige Software hoher Qualität für sich schnell\nändernde und wachsende Anforderungen zu erstellen.\nDies gilt insbesondere für Anwendungen mit hohen\nAnforderungen an Sicherheit und Verlässlichkeit.\nBeispielhafte Umsetzungen erfolgen mit modernen\nProgrammiersprachen, etwa Rust. Darüber hinaus\nwenden sie Techniken zum Aufbau von sicheren IT-\nInfrastrukturen an.	\N	Test-Driven Design • Memory Safety • Inversion of\nControl • Convention over Configuration • Programming\nby Contract • Nebenläufige Programmierung •\nSoftware-Schwachstellen durch\nSpeicherschutzverletzungen • System-\nSchutzmechanismen • Type Safety •\nSpeicherzugriffsfehler • Garbage Collection •\nGenerische Programmierung • Fehlerbehandlung\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 89 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)
111	1	Die Studierenden lernen erweiterte Algorithmen und\nBibliotheken von Autonomen Systemen, Multi-Agenten\nund Schwarmsystemen sowie die Konzepte und\nMethoden der Programmierung kennen und können\ndiese effektiv und strukturiert bei der Entwicklung eigener\nAnwendungen einsetzen. Sie gehen sicher mit der\nproblemspezifischen Auswahl von Verfahren des\nmaschinellen Lernens um und wissen, welchen Einfluss\nund welche Grenzen die Architekturen haben. Die\nStudierenden sind zudem in der Lage, sich selbstständig\nund zügig in unterschiedliche Arten von erweiterten\nAlgorithmen Autonomer Systeme und deren\nProgrammierumgebung einzuarbeiten.	\N	• Transfer Learning\n• Rettungsrobotik\n• Kooperierende Roboter – Fliegende Roboter\n• Adaptivität und Maschinelles Lernen\n• Generator Netze, Auto Encoder, Deep Reinforcment\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 49 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\nLearning, LSTMs, Omni Depth, Ensemble Learning,\nStyleGAN\n• Wissensrepräsentation – Roboterkontrollarchitekturen\n• Lehrsprache C / C++, Python. ipython notebooks,\nscikit-learn
128	1	Die Studierenden beherrschen die grundlegenden\nKonzepte des Software Reverse Engineering und\nkönnen einige statische und dynamische Methoden zur\nProgrammanalyse zur Lösung überschaubarer,\npraktischer Aufgaben sicher anwenden. Sie kennen\ngewisse Elemente von Maschinensprachen, insb. Intel\nx86, amd64 oder ARM, sowie zur Umsetzung gewisser\nHochsprachen-Idiome in Maschinencode-\nEntsprechungen. Durch exemplarische Anwendung der\nMethoden werden praktische Erfahrungen zur\nSchadsoftware-Analyse gesammelt und ein\ngrundlegendes Verständnis zur Vorgehensweise von\nCyber-Angreifern erlangt. Darüber hinaus erfahren sie\ndie Grenzen der Programmanalyse beispielsweise bei\nobfuskiertem Binärcode und können abstrakte\nRepräsentationen von Programmen, etwa in\nKontrollflussgraphen, erstellen und zur Problemlösung\nnutzen. Gegebenenfalls werden die Kenntnisse im\nRahmen eines Capture-The-Flag-Wettbewerbs\nangewendet und vertieft.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 91 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	Maschinensprache und Assemblersprache für die Intel\nx86-Architektur • Wiederholung wichtiger\nBetriebssystemaspekte am Beispiel von Windows oder\nLinux • Methoden zur statischen Code-Analyse •\nDisassemblierung • Erkennung von C-\nHochsprachenkonzepten in Maschinencode •\nKontrollflusskonstrukte und Kontrollflussgraphen •\nDekompilation • Abbildung von C++-\nHochsprachenkonzepten (Vererbung, Virtual Function\nCalls) in Maschinencode • Methoden zur dynamischen\nCode-Analyse • Debugging • Hooking • Binary\nInstrumentation • Emulation • Grundlagen der\nSchadsoftware-Analyse
112	1	• Students know\n• Software frameworks and their structure\n• Architectural patterns\n• Quality and process improvement\n• Students understand\n• how software frameworks are the basis for reuse\nand advanced software development\n• Students are able to\n• develop large software systems using frameworks\nand other reuse oriented software engineering\nmethods\n• Students can use this knowledge to evaluate proper\nmethods and tools for a given context for optimized\ndevelopment of large software systems\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik	\N	• Advanced Software Engineering\n• Reuse as a foundation for the development of large\nsoftware systems\n• Frameworks\n• Structure of frameworks\n• Inversion of Control (IoC)\n• Meta-frameworks\n• Model-driven software engineering (MDSE)\n• Model driven architecture (MDA)\n• Domain Specific Languages (DSL)\n• Object Constraint Language (OCL)\n• Software families / software product lines\n• Software architecture\n• Software quality management\n• Process improvement\n• Introduction into formal specification\n• Future directions of Software Development\n• The future of the internet\n• Enterprise 2.0
129	1	Die Studierenden:\n• können Strategien und integrierte Konzepte im Sinne\ndes Multi-, Cross- und Omni-Channel-Marketing auf\nGrundlage der unternehmerischen\nRahmenbedingungen entwickeln bzw. gestalten und\numsetzen, um in einer durch VUKA geprägten Welt\nerfolgsorientierte Marketingkonzepte zu realisieren.\n• sind in der Lage die diversen und sich ständig\nverändernden An- und Herausforderungen der\nMarketing-Intelligence durch den zielgerichteten\nEinsatz analytischer Methoden zu bewältigen, damit\nsie befähigt werden, die Erkenntnisorientierung der\nDatenanalyse in den Vordergrund des\nunternehmerischen Handelns zu stellen.\n• kennen die aktuelle Technologielandschaft und\nerforderlichen IT-Architekturen zur Umsetzung von\nanalytischen Prozessen sowie zur Durchführung und\nKontrolle entsprechender digitaler\nMarketingkampagnen, um Softwarewerkzeuge und\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 93 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\ninformationstechnologische Hilfsmittel gemäß der\nAnforderungen begründet auszuwählen,\n• verstehen die qualitativen und quantitativen\nMethoden zur analytischen Auswertung und können\ndiese zielorientiert einsetzen und interpretieren, um\nlogische Schlussfolgerungen und unternehmerische\nHandlungsmöglichkeiten im Kontext des digitalen\nMarketing ableiten zu können,\n• kreieren und kontrollieren strategische Konzepte\nsowie sowie operative Prozesse des digitalen\nMarketings auf Basis von analytischen und\nzielorientierten Vorgehensweisen, damit sie die\nWirtschaftlichkeitsorientierung im Unternehmen\nfachlich vertreten können,\n• verstehen die Technologie und den Aufbau\nmoderner CRM-Systeme und sind in der Lage\nanalytische Softwareapplikationen anzubinden, um\nKundenbeziehungen datenbasiert auszuwerten und\nentsprechendes Optimierungspotenzial bei der\nGestaltung und Pflege von Kundenbeziehungen zu\nidentifizieren,\n• können Probleme im Hinblick auf Datenqualität\nerkennen und kennen rechtliche\nRahmenbedingungen von datengetriebenen\nMarketingkonzepten bzw. Geschäftsmodellen, um\ndie analytischen Methoden einwandfrei anwenden\nzu können und ein rechtskonformes\nunternehmerisches Handeln zu gewährleisten.	\N	1. Entscheidungsgrundlagen im Digitalen Marketing\n1.1 Markt- und kundenorientiertes\nEntscheidungsverhalten\n1.2 Verbesserung der Entscheidungsqualität im\ndigitalen Marketing\n1.3 Nachfrageseite von digitalen\nMarketinginformationen\n1.4 Anbieterseite von digitalen\nMarketinginformationen\n1.5 Herausforderungen eines zielgerichteten,\ndigitalen Marketing-Controllings\n2. Digitales Multi-, Cross- und Omni-Channel-Marketing\n2.1 Online-, Social Media- und Mobiles-Marketing\n2.2 Etablierung einer digitalen Marketing-Strategie\n2.3 Steuerungsinstrumente\n3. Datenanalyse im digitalen Marketing\n3.1 Datenquellen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 94 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n3.2 Datenverfügbarkeit und Datenbeschaffenheit\n3.3 Grundlegende Analyseverfahren und -\nmethoden\n4. Digitale Marketing Intelligence\n4.1 Qualitative Ansätze\n4.2 Quantitative Ansätze\n4.3 Data Warehouses im digitalen Marketing\n4.4 Ansätze des Data Mining\n4.5 Big Data Marketing – Chancen und\nHerausforderungen\n5. Customer Relationship Management (CRM) im\nKontext der digitalen Medien\n5.1 Ziele und Aufgaben im CRM\n5.2 CRM-Strategie\n5.3 Komponenten von CRM-Systemen\n5.4 Anforderungen an die einzelnen CRM-\nKomponenten\n5.5 Systematische und zielgerichtete\nWirkungskontrolle mit Hilfe von CRM-Systemen
130	1	Die Studierenden kennen den Stand der Technik auf\ndem Gebiet Extended Reality (XR) sowie wichtige\nEinsatzfelder und Anwendungen. Sie kennen\nForschungsarbeiten und Studien zu den Vor- und\nNachteilen der Verwendung von VR-/MR-/AR-\nTechnolgien für bestimmte Anwendungsfelder\ngegenüber herkömmlichen Formen der\nBenutzerkommunikation.\nDie Studierenden kennen den Stand der Forschung auf\neinem speziellen Teilgebiet der XR.\nDie Studierenden können XR-Anwendungen mit einem\nWerkzeug wie Unreal oder Unity entwickeln und\nbeherrschen insbesondere die mathematisch-\nalgorithmischen Probleme im Bereich von 3D-\nRotationen und unter simultaner Bewegung in\nmehreren unterschiedlichen Koordinatensystemen. Sie\nkennen praktische Arbeiten in diesem Bereich und\nderen Probleme.\nDie Studierenden kennen und verstehen globale\nBeleuchtungsverfahren zur Erzeugung\nhochrealistischer Visualisierungen. Sie kennen die\nzugehörigen mathematischen und physikalischen\nGrundlagen und die algorithmischen Umsetzungen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 97 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\nwichtiger Verfahren. Sie kennen die Unterschiede\nzwischen diesen Verfahren und können die\ngegenseitigen Vor- und Nachteile begründen. Sie\nkennen Optimierungsansätze z.B. für den Einsatz in\nXR-Echtzeit-Umgebungen aus der Forschung und\nkönnen diese erklären.\nDie Studierenden sind in der Lage, im Master-Projekt\nMedieninformatik eine XR-Anwendung unter\nAnwendung der Theorie aus der Lehrveranstaltung auf\nder Basis einer geeigneten Engine zu entwickeln.\nDie Studierenden sind zudem in der Lage, ihr Wissen\nim Hinblick auf weiter reichende Anforderungen im\nStudium, im Hinblick auf Arbeiten in der Forschung\nsowie im späteren Beruf schnell zu erweitern und zu\nvertiefen.	\N	• Augmented, Mixed und Virtual Reality:\nTechnologien, Geräte, Anwendungen, Studien über\nAR- und MR-Einsatz\n• Analyse und Erzeugung von 3D-Rotationsmatrizen:\nEuler-Rotationen, spezielle orthogonale Matrizen\n• Probleme mit Matrizen (Gimbal Lock), Quaternionen\n• Simultane Rotationen in unterschiedlichen\nKoordinatensystemen, Tracking mit mehreren\nSensoren/Geräten\n• Rendering-Gleichung, Reflexionsverteilungsfunktion\n(BRDF)\n• Reflexion und Transmission, Raytracing,\nEigenschaften der generierten Bilder und des\nVerfahrens, Optimierungsmethoden\n• Diffuse Verfahren: Diffuses Raytracing, Path\nTracing, Photon Mapping, Radiosity\n• Tracking: Prinzipien (Inside-Out, Outside-In),\nSensor-Technologien\n• Navigationsverfahren für virtuelle Räume, Verfahren\nzur intuitiven Fortbewegung\n• Kollisionserkennung und –behandlung\n• Analyse von Ergebnissen zu einem aktuellen XR-\nForschungsthema, das variieren kann: z.B.: XR im\nBereich medizinischer Rehabilitation.\nSemesterbegleitend Mitarbeit an der Analyse eines\nForschungsthemas, Lesen und Exzerpieren eines\nForschungsartikels
131	1	Die Studierenden erlernen ein vertiefendes Verständnis\nzum Supply Chain Management (Aufbau und\nGestaltung, Strategien und Instrumente)\nInsbesondere analysieren und untersuchen sie:\n• eine Data Science basierte Perspektive im\nSupply Chain Management\n• die Wirkungen von Risiken und Unsicherheit in\nkomplexen Unternehmensnetzen und die\nPotentiale von digitalen Systemen zum\nManagement und erfolgreichen Betrieb\n• eine kritische Perspektive zur Betrachtung von\nRisiken in der Supply Chain, insb. post Covid-\n19, Risikomanagement- und Resilienz-\nMethoden	\N	Vertiefung Supply Chain Management\n• Strategien und Instrumente in komplexen\nUnternehmensnetzen und deren Abbildung in\nInformationssystemen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 100 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Planungs- und Steuerungskonzepte im Supply Chain\nManagement, insb. angewandte deterministische\nund stochastische Modelle aus operativer und\nstrategischer Sicht\n• Supply Chain Risikomanagement und -Resilienz\n• Simulation und Optimierung komplexer\nNetzstrukturen und deren Visualisierung\n• SCM Post Covid-19\n• Praktikum mit Fallstudien und Übungen zu den\nThemen der Vorlesung
113	1	Die Studierenden lernen unterschiedliche\nTechnologien, Konzepte und Verfahren kennen, die für\nden Betrieb großer IT-Infrastrukturen wichtig sind. Sie\nbekommen erste Erfahrungen im Umgang mit diesen\nTechnologien und Verfahren. Die Fähigkeit neue\nTechnologien in diesem Umfeld schnell begreifen,\neinordnen und bewerten zu können wird erlangt.\nDie Studierenden lernen komplexe Rechnersysteme zu\nanalysieren und mit Hilfe von formalen Methoden zu\nbewerten um Verbesserungen der Systeme vornehmen\nzu können.	\N	• Leistungsbewertung\n• Monitoring, Software, Hardware, hybrid\nModellierung, funktionale und zeitbehaftete Petri-\nNetze\n• Zusammenhang zwischen Messung und\nModellierung\n• Fehlertoleranz\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 53 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Informatik\n• Rechner-Cluster\n• ITIL\n• IT-Controlling
97	1	Die Studierenden beschäftigen sich längere Zeit\nintensiv mit einem Thema der praktischen oder\ntechnischen Informatik und lernen in diesem Rahmen\ndie wissenschaftliche Arbeits- und Denkweise intensiv\nkennen.\nDie Studierenden lernen, sich schnell in\nAnwendungsproblematiken einzuarbeiten, und\nsammeln Erfahrung bei der Analyse eines komplexen\nProblems, bei der strukturierten Entwicklung von\nLösungen und der konkreten Realisierung unter\nNutzung vorhandener Programme bzw. mit Hilfe neu\nentwickelter Programme.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 18 -\nInformatik (Master) – PO2023 Modulkatalog\nDie Studenten erweitern ihre sozialen Kompetenzen,\nfalls die Bearbeitung des Themas im Rahmen einer\nTeamarbeit erfolgt.	\N	Im Rahmen dieses Projekts sollen die Studierenden\nmöglichst selbständig unter Nutzung des in den\nVeranstaltungen erlangten Wissens die Lösung eines\nkomplexen Problems der technischen oder praktischen\nInformatik erarbeiten.\nDazu gehört die Analyse des Problems, die Ermittlung\ndes Standes der Technik und die Synthese und\nImplementierung einer eigenen Lösung.\nDie Bearbeitung des Problems soll in einem Team\nerfolgen.
132	1	Die Studierenden können potentielle oder sich\nabzeichnende zukünftige technologische Entwicklungen\nund deren mögliche gesellschaftliche Auswirkungen\nanalysieren, diskutieren, zusammenfassen und\nbewerten,\nIndem Sie:\n• Verschiedene Perspektiven durch verschiedene\nVortragende kennenlernen\n• Regelmäßig in Diskussionen debattieren und\nargumentieren\n• Wechselwirkungen, beispielsweise auf sozialer und\ngesellschaftlicher Ebene gezielt berücksichtigen\n• Eigene Sichtweisen formulieren, abgrenzen und\nverteidigen\nUm später:\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 102 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)\n• Sich an Technologieentwicklung aktiv und bewusst\nund mit einer gesellschaftlichen Verantwortung\nbetreiben zu können.	\N	• Die Veranstaltung ist als Ringvorlesung konzipiert\nmit wechselnden internen und externen\nVortragenden.\n• Themen sind aktuelle Technologietrends, mit klarem\nFokus auf zukünftige Entwicklungen (+10 Jahre) und\nderen Auswirkungen auf die Menschheit.\n• Gekoppelt wird dies mit Diskussionsrunden,\nPaneldiskussionen und Frage-Antwort Runden.\n• Eine intensive Beteiligung ist Teil der\nPrüfungsleistung.\n• Einzelne Themen der Ringvorlesung müssen\nvorbereitet werden. Unterschiedliche Rollen werden\ndurch die Studierenden übernommen, z.B.\nModeration oder Panelteilnehmer:in.
133	1	Die Studierenden beherrschen fortgeschrittene\nKonzepte der IT-Sicherheit, insb. System- und\nSoftwaresicherheit, und können sie mit Internet-\nTechnologien kombinieren. Sie gewinnen praktische\nErfahrungen über sichere und unsichere IT-\nInfrastrukturen und Programme. In Teamarbeit soll ein\nkomplexes Problem nach wissenschaftlicher\nBetrachtung praktisch gelöst werden. Die\nTeilnehmenden sind in der Lage, ihre Ergebnisse\ngemessen am Stand der Wissenschaft und Technik\neinzuordnen und sowohl unter Verwendung von\nFachtermini untereinander als auch gegenüber der\nHochschulöffentlichkeit darzustellen und zu\nkommunizieren.\nWenn möglich werden über die Teilnahme an\nkompetitiven, spielerischen Wettbewerben (etwa\nCapture The Flag) die erworbenen Kompetenzen unter\nBeweis gestellt.	unter Beweis gestellt.	Aktuelle praktische oder wissenschaftliche Probleme\nbasierend auf etwa Konferenzbeiträgen zu Top-Tier-\nKonferenzen und Journals oder durch aktuelle CTF-\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 4 -\nInternet-Sicherheit (Master) – PO2023 Modulkatalog\nWettbewerbe • IT-Sicherheit • System- und\nSoftwaresicherheit • Internet- und\nNetzwerktechnologien und Angriffsmethoden
134	1	Die/der Studierende ist in der Lage, die Ergebnisse\nihrer/seiner Masterarbeit aus der Internet-Sicherheit,\nihre fachlichen Grundlagen, ihre Einordnung in den\naktuellen Stand der Technik, bzw. der Forschung, ihre\nfächerübergreifenden Zusammenhänge und ihre\naußerfachliche Bezüge in begrenzter Zeit in einem\nVortrag zu präsentieren.\nDarüber hinaus kann sie/er Fragen zu inhaltlichen\nDetails, zu fachlichen Begründungen und Methoden\nsowie zu inhaltlichen Zusammenhängen zwischen\nTeilbereichen ihrer/seiner Arbeit beantworten. Die/der\nStudierende kann ihre/seine Masterarbeit auch im\nKontext beurteilen und ihre Bedeutung für die Praxis\nund die Forschung einschätzen und ist in der Lage,\nauch entsprechende Fragen nach themen- und\nfachübergreifenden Zusammenhängen zu beantworten.	\N	Zunächst wird der Inhalt der Masterarbeit aus der\nInternet-Sicherheit im Rahmen eines Vortrages\npräsentiert. Anschließend sollen in einer Diskussion\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 13 -\nInternet-Sicherheit (Master) – PO2023 Modulkatalog\nFragen zum Vortrag und zur Masterarbeit beantwortet\nwerden.\nDie Prüfer können weitere Zuhörer zulassen. Diese\nZulassung kann sich nur auf den Vortrag, auf den\nVortrag und einen Teil der Diskussion oder auf das\ngesamte Kolloquium zur Masterarbeit erstrecken.\nDer Vortrag soll die Problemstellung der Masterarbeit,\ndie vergleichende Darstellung alternativer oder\nkonkurrierender Lösungsansätze mit Bezug zum\naktuellen Stand der Technik, bzw. Forschung, den\ngewählten Lösungsansatz, die erzielten Ergebnisse\nzusammen mit einer abschließenden Bewertung der\nArbeit sowie einen Ausblick beinhalten. Je nach Thema\nkönnen weitere Anforderungen hinzukommen. Die\nDauer des Vortrages wird vom Erstprüfer festgelegt und\nkann zwischen 30 und 40 Minuten betragen.\nIn der anschließenden Diskussion werden Fragen von\nden Prüfern gestellt. Fragen der übrigen Zuhörer des\nKolloquiums können durch die Prüfer ebenfalls\nzugelassen werden. Die Dauer der Diskussion wird\ndurch die Prüfer bestimmt und beträgt ca. 30-45\nMinuten.
135	1	Die/der Studierende ist in der Lage, innerhalb einer\nvorgegebenen Frist entweder\n• eine schwierige und komplexe praxisorientierte\nProblemstellung aus der Internet-Sicherheit\nsowohl in ihren fachlichen Einzelheiten als auch\nin den themen- und fachübergreifenden\nZusammenhängen nach wissenschaftlichen\nMethoden selbständig zu bearbeiten und zu lösen\noder\n• eine anspruchsvolle Fragestellung aus der\naktuellen Forschung auf dem Gebiet der Internet-\nSicherheit unter Anleitung eigenständig zu\nbearbeiten und selbstständig ein neues\nwissenschaftliches Ergebnis zu entwickeln.	\N	Es soll eine praxisorientierte Problemstellung oder eine\nFragestellung aus der Forschung auf dem Gebiet der\nInternet-Sicherheit mit den im Studium erworbenen\noder während der Masterarbeit neu erlernten\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -\nInternet-Sicherheit (Master) – PO2023 Modulkatalog\nwissenschaftlichen Methoden in begrenzter Zeit mit\nUnterstützung eines erfahrenen Betreuers gelöst\nwerden.
136	1	Die Studierenden sind in der Lage, ihre bisher\nerworbenen speziellen Kenntnisse, Fertigkeiten und\nLösungsstrategien aus der Informatik und der Internet-\nSicherheit auf interdisziplinäre Problemstellungen\nanwenden.	\N	• Im Master-Projekt Internet-Sicherheit wird besonders\ndie interdisziplinäre Komponente des\nMasterstudiengangs Internet-Sicherheit in den\nMittelpunkt gerückt.\n• Während der Projektarbeit sollen die Studierenden\nvor allem ihre speziellen Kenntnisse, Fertigkeiten\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 19 -\nInternet-Sicherheit (Master) – PO2023 Modulkatalog\nund Lösungsstrategien aus der Informatik auf\ninterdisziplinäre Problemstellungen anwenden.\n• Interdisziplinäre Projekte können mit den anderen\nMaster-Studiengängen koordiniert werden. Beispiele\nsind:\no Wirtschaftsinformatik (Return of Security\nInvestment (RoSI), Mehrwerte von Internet-\nSicherheit, …) oder\no Technische Informatik (Sicherheit bei „Internet\nder Dinge“, Industrie 4.0, …) oder\no Medieninformatik (Vertrauenswürdige\nGestaltung von Oberflächen, Darstellung von\nsicherheitsrelevanten Ereignissen auf eine\nintuitive Weise, …) oder\no Praktische Informatik (Integration von IT-\nSicherheit in Anwendungen, …).\n• Die Projektteams haben dabei die Verantwortung für\ndie genaue Ausgestaltung und das Zeitmanagement.
137	1	Die Studierenden besitzen die folgenden Fähigkeiten:\n• Sie sind in der Lage zur selbstständigen\nEinarbeitung in aktuelle Forschungsfragen zur\nInternet- Sicherheit auf der Basis von Primärliteratur\n(Publikationen in Fachzeitschriften sowie\nTagungsbeiträge);\n• Sie können Informationsrecherchen zu\nforschungsorientierten Fragestellungen durchführen\nund sind in der Lage, dazu eine strukturiert\nschriftliche Aufbereitung des aktuellen Stands der\nForschung zu erarbeiten;\n• Sie können eine zusammengefasste Darstellungder\nErgebnisse zu einer Fragestellung präsentieren\nsowie in der Diskussion mit allen\nSeminarteilnehmern sich ergebende Fragen\nbeantworten und aufgestellte Thesen verteidigen.	\N	• Im Rahmen dieses Projekts bearbeiten die\nStudierenden aktuelle Themen aus dem Bereich der\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 21 -\nInternet-Sicherheit (Master) – PO2023 Modulkatalog\nInternet-Sicherheit. Die Themen orientieren sich z.B.\nan den Forschungsthemen des Instituts für Internet-\nSicherheit -if(is).\nDie Rahmenbedingungen für das Projekt werden\nvon den Lehrenden vorgegeben, die Ausgestaltung\nund die Verantwortung liegen aber bei den einzelnen\nProjektteams des Institutes.\n• Dadurch sollen die Studierenden das selbstständige\nund zielorientierte Bearbeiten von\nwissenschaftlichen Problemstellungen über einen\nlängeren Zeitraum erlernen.\n• Ein Schwerpunkt dieses Seminars bildet die\neigenständige Bearbeitung wissenschaftlicher\nFragestellungen.
138	1	Die Studierenden sind in der Lage, wissenschaftlich\nanspruchsvolle Problemstellungen selbstständig und\nzielorientiert zu bearbeiten.	\N	• Im Rahmen dieses Projekts bearbeiten die\nStudierenden aktuelle Themen aus dem Bereich der\nInternet-Sicherheit. Die Themen orientieren sich z.B.\nan den Forschungsthemen des Instituts für Internet-\nSicherheit -if(is).\n• Die Rahmenbedingungen für das Projekt werden\nvon den Lehrenden vorgegeben, die Ausgestaltung\nund die Verantwortung liegen aber bei den einzelnen\nProjektteams des Institutes.\n• Dadurch sollen die Studierenden das selbstständige\nund zielorientierte Bearbeiten von\nwissenschaftlichen Problemstellungen über einen\nlängeren Zeitraum erlernen.\n• Ein Schwerpunkt dieses Seminars bildet die\neigenständige Bearbeitung wissenschaftlicher\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -\nInternet-Sicherheit (Master) – PO2023 Modulkatalog\nFragestellungen. Idealerweise entsteht daraus ein\nArtikel, die veröffentlich werden kann.
139	1	Die Studierenden können Simulationsumgebungen und\nPrototypen für zukünftige Cross-Reality Systeme\nkonzipieren und technologisch umsetzen\nindem Sie\n• Die Möglichkeiten und Herausforderungen für\nDevice- und Realitätsübergreifende interaktive\nSysteme analysieren und diskutieren\n• Aktuelle Forschungsliteratur recherchieren,\nkritisieren und Lösungsansätze ableiten\n• Werkzeuge aus dem Kontext AR/VR und Cross-\nPlatform Development zusammenführen\nUm später / damit sie…\n• Zukünftige Benutzererlebnisse gestalten zu\nkönnen, die im Sinne eines übergreifenden\nMetaverse nicht an Realitäten und Geräteklassen\ngebunden sein werden	\N	• In der Veranstaltung werden aktuelle\nHerausforderungen, Lösungen und Möglichkeiten\ndiskutiert, die sich aus dem Prototyping von CR-\nSystemen und ihren Interaktionen ergeben.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 5 -\nMedieninformatik (Master) – PO2023 Modulkatalog\n• Es werden aktuelle Forschungsansätze vorgestellt,\nkontrastiert und interpretiert\n• In Kleingruppen werden für spezifische\nProblemstellungen mögliche CR Konzepte entworfen\nund prototypisch realisiert.
141	1	Die Studierenden sind in der Lage, die Ergebnisse ihrer\nMasterarbeit aus der Medieninformatik, ihre fachlichen\nGrundlagen, ihre Einordnung in den aktuellen Stand der\nTechnik, bzw. der Forschung, ihre\nfächerübergreifenden Zusammenhänge und ihre\naußerfachlichen Bezüge in begrenzter Zeit in einem\nVortrag zu präsentieren.\nDarüber hinaus können die Studierenden Fragen zu\ninhaltlichen Details, zu fachlichen Begründungen und\nMethoden sowie zu inhaltlichen Zusammenhängen\nzwischen Teilbereichen ihrer Arbeit selbstständig\nbeantworten und diese verteidigen.\nDie Studierenden können ihre Masterarbeit auch im\nKontext beurteilen und ihre Bedeutung für die Praxis\nund die Forschung einschätzen und sind in der Lage,\nauch entsprechende Fragen nach themen- und\nfachübergreifenden Zusammenhängen zu beantworten.	\N	Zunächst wird der Inhalt der Masterarbeit aus der\nMedieninformatik im Rahmen eines Vortrags\npräsentiert. Anschließend sollen in einer Diskussion\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -\nMedieninformatik (Master) – PO2023 Modulkatalog\nFragen zum Vortrag und zur Masterarbeit beantwortet\nwerden.\nDie Prüfer können weitere Zuhörer zulassen. Diese\nZulassung kann sich nur auf den Vortrag, auf den\nVortrag und einen Teil der Diskussion oder auf das\ngesamte Kolloquium zur Masterarbeit erstrecken.\nDer Vortrag soll die Problemstellung der Masterarbeit,\ndie vergleichende Darstellung alternativer oder\nkonkurrierender Lösungsansätze mit Bezug zum\naktuellen Stand der Technik, bzw. Forschung, den\ngewählten Lösungsansatz, die erzielten Ergebnisse\nzusammen mit einer abschließenden Bewertung der\nArbeit sowie einen Ausblick beinhalten. Je nach Thema\nkönnen weitere Anforderungen hinzukommen.\nDie Dauer des Kolloquiums ist in § 16 der\nStudiengangsprüfungsordnung geregelt.
142	1	Die/der Studierende ist in der Lage, innerhalb einer\nvorgegebenen Frist entweder\neine schwierige und komplexe praxisorientierte\nProblemstellung aus der Medieninformatik sowohl in\nihren fachlichen Einzelheiten als auch in den themen-\nund fachübergreifenden Zusammenhängen nach\nwissenschaftlichen Methoden selbständig zu bearbeiten\nund zu lösen oder eine anspruchsvolle Fragestellung\naus der aktuellen Forschung auf dem Gebiet der\nMedieninformatik unter Anleitung eigenständig zu\nbearbeiten und selbstständig ein neues\nwissenschaftliches Ergebnis zu entwickeln.	\N	Es wird eine praxisorientierte Problemstellung oder eine\nFragestellung aus der Forschung auf dem Gebiet der\nMedieninformatik mit den im Studium erworbenen oder\nwährend der Master- Arbeit neu erlernten\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -\nMedieninformatik (Master) – PO2023 Modulkatalog\nwissenschaftlichen Methoden in begrenzter Zeit mit\nUnterstützung eines erfahrenen Betreuers gelöst.
143	1	Die Studierenden können ein digitales interaktives\nProdukt mit signifikantem Software-Anteil von der\nProblemanalyse bis hin zur Auslieferung erschaffen,\nindem sie:\n• Sich in einem Projektteam organisieren und\nMethoden des agilen Projektmanagements anwenden\n• Im Studium erlernte Methoden, Konzepte und\nTechniken kombinieren, arrangieren, modifizieren und\nanwenden\n• Mögliche Lösungsansätze (z.B. in der\nwissenschaftlichen Fachliteratur oder Entwicklerblogs\netc.) prüfen, bewerten und evaluieren\n• Methoden der mensch-zentrierten Entwicklung auf\ndie konkrete Projektstellung anpassen und anwenden\n• Komplexe Aufgaben sinnvoll strukturieren,\ndekompilieren und entsprechend den individuellen\nFachkompetenzen als Team effizient bearbeiten\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 19 -\nMedieninformatik (Master) – PO2023 Modulkatalog\n• Typische Schnittstellenprobleme in der Abstimmung\nund Zusammenarbeit sowohl auf technisch-fachlicher\nals auch auf sozialer Ebene mit Hilfe von\nProjektmanagementmethoden bewältigen\n• Zwischenergebnisse dokumentieren und präsentieren\num später\n• Die Kenntnisse und Kompetenzen verschiedener\nModule in einem realistischen Projekt zu vertiefen\nund zusammenzuführen.\n• Über die reinen Fachkompetenzen hinaus Erfahrungen\nund Herausforderungen bei der Zusammenarbeit im\nTeam über einen längeren Zeitraum mit einer\nkomplexen Aufgabe kennenlernen und\nLösungsstrategien entwickeln zu können	als Team effizient bearbeiten	• Im Rahmen des Master-Projektes Medieninformatik\nbearbeiten die Teilnehmer eine typische größere\nAufgabenstellung aus dem Bereich der Medieninformatik\nin einem Projektteam. Die Themenstellung erfolgt mit\nRücksicht auf die Kenntnisse der Studierenden.\n• Selbstständige Durchführung des Projekts von der\nProblemanalyse über Konzept, Design, Prototyping,\nRealisierung/Implementierung und Test bis zur\nDokumentation.\n• Anwendung von grundlegenden Projektmanagement-\nMethoden für Definition, Planung, Kontrolle und\nRealisierung des Projekts.\n• Vertiefung von Kenntnissen zur Entwicklung von\nAnwendungen der Medieninformatik.\n• Entwicklung im Team unter Beteiligung von\nrealen/potentiellen Anwendern und Benutzern.\n• In regelmäßigen Projektsitzungen werden im Rahmen\neiner Qualitätssicherung die Zwischenergebnisse von den\nTeams durch Präsentation und Vorführung vorgestellt\nund diskutiert.\n• Die Projektthemen werden rechtzeitig vor Beginn der\nVeranstaltung bekannt gemacht. Es wird versucht,\npraxisnahe Projekte auch von hochschulexternen\nAnwendern der Medieninformatik zu akquirieren.\n• Das Masterprojekt Medieninformatik hat je nach\nThemenstellung einen Schwerpunkt im Bereich der UI-\nInterface-Gestaltung, der Mensch-Computer-Interaktion\noder der Computergrafik, wird aber zumeist Aspekte aus\nmehreren Gebieten beinhalten.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 20 -\nMedieninformatik (Master) – PO2023 Modulkatalog\n• Projektvorschläge von Studierenden sind nach Absprache\nebenfalls möglich.
144	1	Die Studierenden können ein aktuelles\nForschungsgebiet anhand einer konkreten\nForschungsfrage auf Basis der aktuellen\nwissenschaftlichen Literatur analysieren und bewerten,\nIndem Sie:\n• Wissenschaftliche Literatur recherchieren,\neinordnen und abstrahieren können\n• Gemeinsamkeiten und Diskrepanzen in der\nLiteratur identifizieren und bewerten können\n• Eine zusammenhänge Übersicht des Stands der\nForschung diskutieren und präsentieren können\n• Eine eigene Position zum Stand der Forschung\nund offenen Forschungsfragen einnehmen und\nverteidigen können.\nUm später:\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 22 -\nMedieninformatik (Master) – PO2023 Modulkatalog\n• Diese Kompetenzen in die theoretische Analyse\nfür die Masterarbeit einbringen zu können\n• Eigenständig wissenschaftliche Forschung über\ndie Masterarbeit hinaus zu betreiben.	\N	• In diesem Seminar werden aktuelle\nForschungsbereich und Forschungsfragen kurz\nvorgestellt und anschließend durch die Teilnehmer\nim Selbststudium analysiert und aufgearbeitet.\n• Die Themenvergabe erfolgt am Semesterbeginn. In\nRegelmäßigen Sitzungen präsentieren die\nStudierenden Rechercheergebnisse und den\nDiskussionsstand.
145	1	Die Studierenden können eine aktuelle\nwissenschaftliche Forschungsfrage extrahieren,\nanalysieren, bewerten und im Rahmen der\nDurchführung des Moduls induktiv neues Wissen\ngenerieren\nindem sie:\n• Eingehend für eine vorgegebene Thematik die\nwissenschaftliche Literatur recherchieren,\nanalysieren und bewerten und daraus deduktiv\neine offene Forschungsfrage ableiten.\n• Selbstständig Maßnahmen, Werkzeuge und\nProzesse definieren und erzeugen, um die\nForschungsfrage beantworten zu können.\n• Empirische Forschungsmethodik inklusive\nentsprechender Auswertungsmethoden verstehen,\nadaptieren und anwenden und damit die\nForschungsfrage beantworten ODER durch die\nkonzeptionelle, gestalterische und/oder technische\nErzeugung eines Artefakts oder Prototypen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 77 -\nMedieninformatik (Master) – PO2023 Wahlpflichtkatalog\npraktische Lösungsmöglichkeiten für die\nForschungsfrage aufzeigen.\nUm später\n• Die grundlegende Vorgehensweise\nwissenschaftlichen Arbeitens auf dem Niveau,\nwelches für eine Masterarbeit notwendig ist,\nkennen und anwenden zu können.\n• Eigenständig wissenschaftliche Forschung über die\nMasterarbeit hinaus zu betreiben.	\N	Im Rahmen dieses Moduls wird den Studierenden eine\nProblemstellung bzw. ein Themenfeld aus einem\naktuellen Forschungsbereich der Medieninformatik als\nBasis gegeben.\nIn der Regel geschieht dies angelehnt an aktuelle\nForschungsprojekte und entsprechend kann auch die\nDurchführung eingebettet sein in die aktive\nForschungsarbeit.\nJe nach Problemstellung und Ergebnisse der Analyse\nder verwandten Arbeiten sowie der Vorkenntnisse und\nInteressen der Studierenden, kann sich die Arbeit\nsowohl auf die Durchführung einer empirischen Studie\nfokussieren als auch die Gestaltung oder\nImplementierung eines Prototypen, welcher weniger als\nProdukt/Minimal Viable Product zu sehen ist als\nvielmehr als gezielter Versuch, durch Experiment und\nVersuch Antworten für die Forschungsfrage zu\nerhalten. Auch eine Kombination aus\nPrototypentwicklung und anschließender empirischer\nStudie/Experiement ist möglich.
146	1	Die/der Studierende ist in der Lage, innerhalb einer\nvorgegebenen Frist eine praxisorientierte Aufgabe aus\nder Wirtschaftsinformatik sowohl in ihren fachlichen\nEinzelheiten als auch in ihren themen- und\nfachübergreifenden Zusammenhängen nach\nwissenschaftlichen und fachpraktischen Methoden\nselbstständig zu bearbeiten und zu dokumentieren.	\N	Es wird ein in der Regel praxisorientiertes Problem aus\nder Wirtschaftsinformatik mit den im Studium erlernten\nKonzepten, Verfahren und Methoden in begrenzter Zeit\nunter Anleitung eines erfahrenen Betreuers gelöst.
147	1	Die Studierenden können – fokussiert auf die\nErfordernisse der Wirtschaftsinformatik - die\ngrundlegenden Eigenschaften der für sie relevanten\nhardwarenahen IT-Systeme verstehen und einordnen.\nSie haben die Kompetenz, Anwendungssoftware auf\nServer und Clients sinnvoll zu verteilen und die\nBedeutung und Eigenschaften der unterlegten\nBetriebssysteme einzuordnen.\nSie sind in der Lage, die für verteilte Anwendungen\nnotwendige Infrastruktur in Form von Netzen\neinzusetzen und bis zu einem gewissem Grade\nzuzuschneiden.\nSie können die grundlegende\nDatenspeicherungssysteme unterscheiden und haben\ndamit die Kompetenz, die für die jeweiligen\nAnwendungssysteme sinnvollen Datenablagesysteme\nauszuwählen.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 8 -\nWirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog\nSie können neue Entwicklungen im Bereich\nBetriebssysteme und Netzwerke verstehen, bewerten\nund für ihre Arbeit nutzbar machen.	\N	Rechnerarchitektur, Prozesse und Threads,\nSpeicherverwaltung, Ein-/Ausgabe, Dateisysteme,\nBetriebssystemplattformen, Virtualisierung,\nÜbertragungsmedien, Netzwerktopologien, Protokolle\nund Standards, Internet, mobile Netze, Speichernetze,\nCloud
148	1	Die Veranstaltung verknüpft insbesondere die in den\nvorangegangenen Semestern erworbenen Kenntnisse\nzum Supply Chain Mangement aus einer\ninformationstechnischen Perspektive (s.\nVoraussetzungen PMW, EBW, GWI und EP).\nDie Studierenden\n• lernen den grundsätzlichen Aufbau sowie\nAufgaben und Ziele, Strategien und Instrumente\ndes Supply Chain Managements kennen\n• verstehen die grundsätzlichen\nModellierungsansätze der Wirtschaftsinformatik\nan praktischen Aufgaben im Supply Chain\nManagement zu verknüpfen und zu begreifen\n• werden fachliche Anforderungen, insbesondere\naus dem Supply Chain Management, in\ngeeignete technische Modelle überführen,\ngestalten und beurteilen können.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 23 -\nWirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog	\N	Grundlagen Supply Chain Management\n• Gestaltung und Einsatz von Informationssystemen in\nkomplexen Unternehmensnetzen und\ninterdependenten Unternehmensbereichen aus\noperativer und strategischer Perspektive\n• Aufgaben und Ziele, Strategien und Instrumente des\nSupply Chain Managements\n• Horizontale und vertikale Kooperationsstrategien\n• Aktuelle und relevante Probleme in der Anwendung\n• Verknüpfung Supply Chain Management und\nstrategisches Informationsmanagement\n• Der Bullwhip-Effekt und seine Ursachen\n• Praktikum GSC mit aktuellen und angewandten\nFallstudien
149	1	Die/der Studierende ist in der Lage, die Ergebnisse der\nBachelorarbeit, ihre fachlichen und methodischen\nGrundlagen, ihre fächerübergreifenden\nZusammenhänge und ihre außerfachlichen Bezüge\nmündlich in begrenzter Zeit in einem Vortrag zu\npräsentieren.\nDarüber hinaus kann sie/er Fragen zu inhaltlichen\nDetails, zu fachlichen Begründungen und Methoden\nsowie zu inhaltlichen Zusammenhängen zwischen\nTeilbereichen ihrer/seiner Arbeit selbstständig\nbeantworten.\nDie/der Studierende kann ihre/seine Bachelorarbeit\nauch im Kontext beurteilen und ihre Bedeutung für die\nPraxis einschätzen und ist in der Lage, auch\nentsprechende Fragen nach themen- und\nfachübergreifenden Zusammenhängen zu beantworten.	\N	Zunächst wird der Inhalt der Bachelorarbeit im Rahmen\neines Vortrages präsentiert. Anschließend werden in\neiner Diskussion Fragen zum Vortrag und zur\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 30 -\nWirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog\nBachelorarbeit gestellt, die von der/dem Studierenden\nbeantwortet werden müssen.\nDer Vortrag soll mindestens die Problemstellung der\nBachelorarbeit, den gewählten Lösungsansatz, die\nerzielten Ergebnisse zusammen mit einer\nabschließenden Bewertung der Arbeit sowie einen\nAusblick beinhalten.\nJe nach Thema können weitere Anforderungen\nhinzukommen, wie z.B. die vergleichende Darstellung\nalternativer oder konkurrierender Lösungsansätze, ein\nLiteraturüberblick oder die Darlegung des aktuellen\nStandes der Wissenschaft.\nDie Dauer des Kolloquiums ist in § 26 der Bachelor-\nRahmenprüfungsordnung und § 19 der\nStudiengangsprüfungsordnung geregelt.
150	1	Die Veranstaltung verknüpft insbesondere die\nerworbenen Kenntnisse zum Supply Chain\nManagement aus einer informationstechnischen\nPerspektive (s. Voraussetzungen PMW, EBW, GWI und\nEP) – aufbauend und als Weiterführung der\nVeranstaltung GSC.\nDie Studierenden\n• verstehen den interdependenten Charakter der\nStruktur des Supply Chain Managements im\nUnternehmen und in Unternehmensnetzen\nkennen\n• verknüpfen weiterführende\nModellierungsansätze der Wirtschaftsinformatik\nan praktischen Aufgaben und Fallstudien des\nSupply Chain Managements und erkennen\nkonfliktäre Zielsetzungen\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 46 -\nWirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog\n• untersuchen die Abbildung fachlicher\nAnforderungen, insbesondere aus dem Supply\nChain Management, zur Anwendung in\ngeeigneten mathematisch, technische Modellen\nder Wirtschaftsinformatik anhand komplexer\nausgewählter Fallstudien.	\N	Supply Chain Management und Digitalisierung\n• Gestaltung und Einsatz von Informationssystemen in\nkomplexen Unternehmensnetzen und\ninterdependenten Unternehmensbereichen aus\noperativer und strategischer Perspektive.\n• Deterministische und stochastische Modelle im\nRahmen der Planung komplexer angewandter\nProblemstellungen im Unternehmen\n• Interdependente Problemstellungen aus dem Supply\nChain Management mit Aufgaben und Funktionen in\nInformationssystemen und deren\nGeschäftsprozessen\n• Angewandte aktuelle und relevante\nProblemstellungen basierend auf Fallstudien\n• Digitales Supply Chain Management und seine\nPerspektiven, betriebswirtschaftschaftliche Potentiale\nzukünftiger Herausforderungen\n• Praktikum DSC mit aktuellen und angewandten\nFallstudien und kritischer Reflexion
151	1	Die Studierende werden in die Lage versetzt:\n• durch wissenschaftliches Vorgehen für praktische\nProblemstellungen den Stand der Technik zu\nrecherchieren, Anforderungen zu analysieren,\nLösungen zu entwickeln und zu begründen,\n• die Integration von betriebswirtschaftlichen\nWissen mit Informatiktechnologien zur Gestaltung\nund Umsetzung von betrieblichen\nInformationssystemen anzuwenden,\n• das Erlernte – insbesondere die Methoden,\nVerfahren und Werkzeuge - in Rahmen einer\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -\nWirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog\nkomplexeren Aufgabenstellung selbständig und im\nTeam anzuwenden,\n• ihre Fähigkeiten zur Teamarbeit in Form von\nLeitung und Moderation von Besprechungen,\nLösung von Konflikten, Beurteilung und\nPräsentation von Arbeitsergebnissen anzuwenden\nund weiter zu entwickeln.	\N	Der Vorlesungsteil wird als globale Veranstaltung für\nalle Teilnehmer abgehalten und führt in die Grundlagen\ndes wissenschaftlichen Arbeitens ein.\nZum wissenschaftlichen Arbeiten gehören:\n• Recherche\n• Analyse\n• Dokumentation\n• Präsentation\nIm Praktikumsteil steht die systematische Anwendung\nund Zusammenführung von in\nVorgängerveranstaltungen erlernten Wissen im\nVordergrund:\n• Durchführung eines komplexeren Projektes zur\nEntwicklung einer\nAnwendungssystemkomponente.\n• Selbstständige Durchführung des Projekts von der\nAnalyse über Design, Implementierung und Test\nbis zur Dokumentation\n• In diesem Projekt werden die erlernten Kenntnisse\naus dem Studium anhand eines Fallbeispiels\ndurchgängig und systematisch angewendet.\n• In dem Projekt sollen die im Studium erlernten\nfachlichen, sozialen und methodischen\nKompetenzen angewendet werden.\n• Die Projektarbeit wird in Teams mit 4 bis 6\nStudenten durchgeführt.\nIn regelmäßigen Projektsitzungen werden im Rahmen\neiner Qualitätssicherung die Zwischenergebnisse von\nden Teams durch Präsentation und Vorführung\nvorgestellt und diskutiert.
152	1	Die Studierenden erwerben berufsorientierte\nenglischsprachige Diskurs- und Handlungskompetenz\nunter Berücksichtigung (inter-)kultureller Elemente.	\N	Diese Fachsprache-Veranstaltung widmet sich\nmethodisch und inhaltlich englischen\nSprachverwendungssituationen für\nWirtschaftsinformatiker.
153	1	Die Studierende werden in die Lage versetzt:\n• das erlernte theoretischen Wissen, die\nModellierungsmethoden und das Vorgehensmodell\nzu Business Intelligence, Data Warehouse und Big\nData Systemen zu erläutern und anzuwenden,\n• den Aufbau und die Architektur des SAP Business\nWarehouse System zu erklären,\n• den Aufbau eines Data Warehouses und die\nIntegrationsmethoden und -möglichkeiten von Daten\nverschiedener Quellsysteme praktisch mit dem SAP\nBW System umzusetzen,\n• aktuelles Wissen und den Stand der Forschung zu\nBusiness Intelligence, Data Warehouse und Big\nData selbständig zu erarbeiten.	\N	• Grundlagen, Methoden und Anwendungsgebiete von\nBusiness Intelligence (BI), Data Warehouse und Big\nData.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 4 -\nWirtschaftsinformatik (Master) – PO2023 Modulkatalog\n• Architektur, Datenmodell und Techniken in Business\nIntelligence am Beispiel SAP Business Warehouse\n• Methoden und Techniken von Big Data\n• Architekturen zur Integration von BI, Data\nWarehouse und Data Lakes\n• Methoden und Algorithmen zum Data Mining\n• Fallbeispiele aus der Unternehmenspraxis
158	1	Die Studierenden können selbständig…\na) Management und Unternehmensführung:\n… den wissenschaftlichen Forschungsprozess auf\nbetriebswirtschaftlich relevante Fragestellungen\nanwenden. Sie sind vertraut mit der den Grundlagen\ndes Managements und lernen, Management als\nFührungsaufgabe zu verstehen. Sie lernen Methoden\nund Kompetenzmanagementsysteme der\nPersonalauswahl und -führung kennen und können ihre\nHandhabung und Einsatz für unterschiedliche\nFührungsaufgaben erkennen und nutzen. Sie erkennen\ndie Bedeutung der Verantwortung und ethischen\nHerausforderungen an eine Führungskraft. In konkreten\nCase Studies und im Planspiel bearbeiten Sie\nkomplexe Management- und Führungsaufgaben und\nlernen Methoden der Problemstrukturierung und –\nlösung kennen und können diese systematisch und\nfallgeeignet auswählen und anwenden. Weitere\nSchwerpunkte liegen auf aktuellen\nManagementherausforderungen an Unternehmen und\nder Rolle der Kommunikation in diesem\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 50 -\nWirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft\nZusammenhang, wie z.B. Herausforderungen durch die\nArbeitswelt 4.0, Konfliktmanagement oder Change\nKommunikation.\nb) Content-Marketing:\n… über mehrere Plattformen und Mediengattungen\nhinweg – unter Wahrung der Markenidentität –\nkommunizieren. Sie beherrschen es, mit crossmedialen\nAngeboten die Aufmerksamkeit der Mediennutzer zu\ngenerieren und zu binden. Sie kennen die spezifischen\nAnforderungen der verschiedenen Medien und können\nsie beurteilen. Sie sind eigenständig in der Lage Inhalte\nund Themen digital für alle Ausspielkanäle\naufzubereiten und sie nach der Veröffentlichung zu\nbegleiten.	\N	Wechselnde Lehrinhalte, z.B.\na) Management und Unternehmensführung:\n• Betriebswirtschaftlichen Grundlagen des\nManagement\n• Management als Führungsaufgabe denken und\nverstehen\n• Ethik im Management\n• Führungsansätze und Personalführung\n• Kompetenzmanagementsysteme\n• Personalauswahl und -entwicklung\n• Unternehmenskultur und Führungsstile\n• Aktuelle Herausforderungen für Unternehmen\nund deren Management\nb) Content-Marketing Crossmedia-Management:\n• Denken und Arbeiten in crossmedialen\nStrukturen\n• Content-Management-Systeme\n• Crossmediales Produzieren\n• Digitales Projektmanagement\n• Spezifika der Medien\n• Chancen und Risiken der Interaktivität\n• Ökonomische und rechtliche\nRahmenbedingungen\nContent-Marketing:\n• Content-Strategie\n• Brand Content\n• Merkmale guter Inhalte\n• Storytelling\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 51 -\nWirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft\n• Fallstudien\n• Suchmaschinen-Optimierung\n• Linkaufbau\n• Social-Media-PR\n• Evaluation
154	1	Die/der Studierende ist in der Lage, die Ergebnisse\nihrer/seiner Masterarbeit aus der Wirtschaftsinformatik,\nihre fachlichen Grundlagen, ihre Einordnung in den\naktuellen Stand der Technik, bzw. der Forschung, ihre\nfächerübergreifenden Zusammenhänge und ihre\naußerfachlichen Bezüge in begrenzter Zeit in einem\nVortrag zu präsentieren.\nDarüber hinaus kann sie/er Fragen zu inhaltlichen\nDetails, zu fachlichen Begründungen und Methoden\nsowie zu inhaltlichen Zusammenhängen zwischen\nTeilbereichen ihrer/seiner Arbeit selbstständig\nbeantworten.\nDie/der Studierende kann ihre/seine Masterarbeit auch\nim Kontext beurteilen und ihre Bedeutung für die Praxis\nund die Forschung einschätzen und ist in der Lage,\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 11 -\nWirtschaftsinformatik (Master) – PO2023 Modulkatalog\nauch entsprechende Fragen nach themen- und\nfachübergreifenden Zusammenhängen zu beantworten.	\N	Zunächst wird der Inhalt der Masterarbeit aus der\nWirtschaftsinformatik im Rahmen eines Vortrags\npräsentiert. Anschließend sollen in einer Diskussion\nFragen zum Vortrag und zur Masterarbeit beantwortet\nwerden.\nDie Prüfer können weitere Zuhörer zulassen. Diese\nZulassung kann sich nur auf den Vortrag, auf den\nVortrag und einen Teil der Diskussion oder auf das\ngesamte Kolloquium zur Masterarbeit erstrecken.\nDer Vortrag soll die Problemstellung der Masterarbeit,\ndie vergleichende Darstellung alternativer oder\nkonkurrierender Lösungsansätze mit Bezug zum\naktuellen Stand der Technik, bzw. Forschung, den\ngewählten Lösungsansatz, die erzielten Ergebnisse\nzusammen mit einer abschließenden Bewertung der\nArbeit sowie einen Ausblick beinhalten. Je nach Thema\nkönnen weitere Anforderungen hinzukommen.\nDie Dauer des Kolloquiums ist in § 26 der Master-\nRahmenprüfungsordnung und § 16 der\nStudiengangsprüfungsordnung geregelt.
156	1	Die/der Studierende ist in der Lage, innerhalb einer\nvorgegebenen Frist entweder\neine schwierige und komplexe praxisorientierte\nProblemstellung aus der Wirtschaftsinformatik sowohl\nin ihren fachlichen Einzelheiten als auch in den themen-\nund fachübergreifenden Zusammenhängen nach\nwissenschaftlichen Methoden selbständig zu bearbeiten\nund zu lösen oder\neine anspruchsvolle Fragestellung aus der aktuellen\nForschung auf dem Gebiet der Wirtschaftsinformatik\nunter Anleitung eigenständig zu bearbeiten und\nselbstständig ein neues wissenschaftliches Ergebnis zu\nentwickeln.	\N	Es wird eine praxisorientierte Problemstellung oder eine\nFragestellung aus der Forschung auf dem Gebiet der\nWirtschaftsinformatik mit den im Studium erworbenen\noder während der Master- Arbeit neu erlernten\nwissenschaftlichen Methoden in begrenzter Zeit mit\nUnterstützung eines erfahrenen Betreuers gelöst.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 17 -\nWirtschaftsinformatik (Master) – PO2023 Modulkatalog
155	1	Die Studierenden haben ein tieferes Verständnis für die\nAufgaben und Erfolgsfaktoren bei der Durchführung\neines mittelgroßen Software-Projekts in einem Team.\nDas Projekt betrifft Aufgaben aus dem Bereich\nWirtschaftsinformatik.\nSie sind in der Lage, das im Studium bisher Erlernte –\ninsbesondere Methoden, Verfahren und Werkzeuge –\nanzuwenden, um ein komplexes Softwareprojekt aus\nder Wirtschaftsinformatik von der Anforderungsanalyse\nüber Entwurf, Implementierung und Evaluierung bis hin\nzur Auslieferung selbstständig und im Team zu\nbewältigen.\nDie Studierenden können komplexe Aufgaben sinnvoll\nstrukturieren und typische Schnittstellenprobleme\nsowohl auf technisch-fachlicher als auch auf sozialer\nEbene bewältigen. Sie können Management-Methoden\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 13 -\nWirtschaftsinformatik (Master) – PO2023 Modulkatalog\nzur Projektdefinition, -planung und -kontrolle bei der\nProjektarbeit anwenden.\nSie sind in der Lage, Besprechungen zu moderieren\nsowie Arbeitsergebnisse professionell zu präsentieren\nund zu bewerten.	\N	Im Rahmen des Software-Projektes Master\nWirtschaftsinformatik bearbeiten die Teilnehmer eine\ntypische größere Aufgabenstellung aus dem Bereich\nder Wirtschaftsinformatik in einem Projektteam. Die\nThemenstellung erfolgt mit Rücksicht auf die\nKenntnisse der Studierenden.\nBei der Durchführung des Projektes steht die\nsystematische Anwendung und Zusammenführung des\nWissens aus dem jeweiligen Fachgebiet mit den\nMethoden der Softwareentwicklung im Vordergrund:\nDurchführung eines mittelgroßen und anspruchsvollen\nSoftware-Projekts aus dem Gebiet der\nWirtschaftsinformatik.\nSelbstständige Durchführung des Projekts von der\nAnalyse über Design, Implementierung und Test bis zur\nDokumentation.\nAnwendung von grundlegenden Projektmanagement-\nMethoden für Definition, Planung, Kontrolle und\nRealisierung des Projekts.\nVertiefung von Kenntnissen in der Programmierung und\nzu Programmiermethodiken.\nSoftwareentwicklung im Team und ggf. unter\nBeteiligung von externen Anwendern\nIn regelmäßigen Projektsitzungen werden im Rahmen\neiner Qualitätssicherung die Zwischenergebnisse von\nden Teams durch Präsentation und Vorführung\nvorgestellt und diskutiert.\nDie Projektthemen werden rechtzeitig vor Beginn der\nVeranstaltung bekannt gemacht. Es wird versucht,\npraxisnahe Projekte auch von hochschulexternen\nAnwendern der praktischen und technischen Informatik\nzu akquirieren. Projektvorschläge von Studierenden\nsind nach Absprache ebenfalls möglich.
157	1	Die Studierenden besitzen die folgenden Fähigkeiten:\nSie sind in der Lage, sich selbstständig in aktuelle\nForschungsfragen zur praktischen und technischen\nInformatik auf der Basis von Primärliteratur\n(Publikationen in Fachzeitschriften sowie\nTagungsbeiträge) einzuarbeiten.\nSie können Informationsrecherchen zu\nforschungsorientierten Fragestellungen durchführen\nund sind in der Lage, dazu eine strukturierte schriftliche\nAufbereitung des aktuellen Stands der Forschung zu\nerarbeiten\nSie können eine zusammengefasste Darstellung der\nErgebnisse zu einer Fragestellung präsentieren sowie\nin der Diskussion mit allen Seminarteilnehmern sich\nergebende Fragen beantworten und aufgestellte\nThesen verteidigen.	\N	In diesem Seminar werden aktuelle oder vertiefende\nThemen aus den Bereichen Wirtschaftsinformatik,\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 19 -\nWirtschaftsinformatik (Master) – PO2023 Modulkatalog\ninsbesondere Betriebliche Informationssysteme,\nBusiness Intelligence, Big Data, Digitales Marketing,\nBusiness Logistics und Geschäftsprozessmanagement.
6	1	• Die Studierenden kennen und verstehen die\ngrundlegenden Elemente der imperativen und\nobjektorientierten (noch ohne Klassenhierarchie)\nProgrammierung.\n• Sie können Rekursion und Iteration adäquat zur\nRealisierung wiederholender Abläufe einsetzen.\n• Anhand von Anwendungsbeispielen gewinnen sie ein\ngrundlegendes Verständnis für die Themen Effizienz\nund Korrektheit.\n• Die Studierenden wissen, dass Dokumentation und\nTest untrennbar mit Programmierung verbunden\nsind.\n• Sie sind insgesamt in der Lage, zu einfachen\nAufgabenstellungen qualitativ gute Lösungen (in der\nLehrsprache Java) zu konzipieren und zu realisieren.	\N	Begriff des Algorithmus • elementare Datentypen •\nTypen und Werte von Ausdrücken • Rekursion und\nStrategien zur Entwicklung rekursiver Lösungen •\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -\nInformatik und Design (Bachelor) – PO2023 Modulkatalog\nKlassen und Objekte • statische und Instanzmethoden •\nDokumentation von Klassen und Methoden •\nKontrollstrukturen • Entwurfsansätze für iterative\nLösungen • Kapselung und Abstraktion • Felder •\nrekursive Datenstrukturen
96	1	Die Studierenden kennen die Erfolgsfaktoren für gutes\nProjektmanagement. Sie können die wesentlichen\nUnterschiede von klassischem und agilem\nProjektmanagement benennen und sind in der Lage für\nein gegebenes Projekt zu entscheiden, welche Vor- und\nNachteile die einzelnen Arten des Projektmanagements\nhaben. Sie kennen die Handwerkszeuge, die für\nPlanung, Überwachung und Risikomanagement zur\nVerfügung stehen. Sie kennen die\nRahmenbedingungen, die einer Aufwandsschätzung\nzugrundgelegt werden müssen und sind in der Lage\nrealistische Aufwände zu schätzen.	, die im Bachelor- Modul Softwaretechnik vermittelt werden sowie Erfahrung in eigenen Software-Projekten bspw. im Bachelor-Studium. Angestrebte Lernergebnisse: Die Studierenden kennen die Erfolgsfaktoren für gutes Projektmanagement. Sie können die wesentlichen Unterschiede von klassischem und agilem Projektmanagement benennen und sind in der Lage für ein gegebenes Projekt zu entscheiden, welche Vor- und Nachteile die einzelnen Arten des Projektmanagements haben. Sie kennen die Handwerkszeuge, die für Planung, Überwachung und Risikomanagement zur Verfügung stehen. Sie kennen die Rahmenbedingungen, die einer Aufwandsschätzung zugrundgelegt werden müssen und sind in der Lage realistische Aufwände zu schätzen.	Grundlagen des Projektmanagements\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -\nInformatik (Master) – PO2023 Modulkatalog\nKlassisches Projektmanagement (Initiierung, Planung,\nAufwandsschätzung, Controlling, Abschluss), Agile\nSoftwareentwicklung\nDie Veranstaltung basiert auf der aktiven Mitwirkung\naller Studierenden, inkl. Literaturstudium und\nInternetrecherche. Die Themen werden zum großen\nTeil durch die Teilnehmerinnen und Teilnehmer selbst\nerarbeitet und präsentiert und in der Gruppe diskutiert\nund praktisch geübt.\nMögliche Themenbereiche sind: Aufwandsschätzung,\nControlling, Risikomanagement, Change- Management,\nPortfoliomanagement, Teammanagement und\nLeadership, Kanban, PRINCE2. Weitere Themen\nkönnen durch die Teilnehmerinnen und Teilnehmer\nselbst vorgeschlagen werden.\nDie Lehrveranstaltung enthält eine Vorbereitung zur\nProfessional Scrum MasterTM I-Zertifizierung. Die\nZertifizierung kann freiwillig in Eigenregie über\nscrum.org abgelegt werden.
57	1	Die Studierenden lernen unterschiedliche\nBeschreibungssprachen und deren Einsatzgebiete\nkennen und bekommen erste praktische Erfahrungen\nmit deren Anwendung. Die Studierenden erlernen\nVerfahren zur Erstellung dynamischer Web-Seiten und\nwenden das Erlernte im Praktikum an.\nSie erlangen die Fähigkeit, neue Konzepte im Umfeld\nder Internet-Sprachen schnell begreifen, einordnen und\nbewerten zu können.	\N	• HTML\n• CSS\n• PHP\n• XML, Verarbeitung von XML-Dateien mit Java, XML-\nSchema, XSLT, …\n• JavaScript, AJAX\n• Web-Services\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 15 -\nInformatik (Bachelor) – PO2023 Modulkatalog
116	1	Die Studierenden besitzen grundlegende Kenntnisse\nüber Datenschutz und Ethik.\nSie haben ein gutes Verständnis über die\nfundamentalen Gesetze, Verordnungen und Strategien\nim Datenschutz.\nSie erlernen den Sinn und Zweck einer Ethik in der\nvernetzten Informations- und Wissensgesellschaft.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 62 -\nInformatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit\n(enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	• Einführung in Datenschutz und Ethik.\n• Begriffsbestimmungen: personenbezogene Daten,\nDatenregister, …\n• Informationelle Selbstbestimmung,\nBundesdatenschutzgesetz, Teledienstedatenschutz,\nTelekommunikationsgesetz, DSGVO, …\n• Rechte der Betroffenen.\n• Organisatorische und technische Maßnahmen zum\nSchutz personenbezogene Daten.\n• Ethik in der vernetzten Informations- und\nWissensgesellschaft.
91	1	Die Studierenden besitzen ein geschärftes\nprofessionelles Selbstverständnis als Mitglieder ihres\nBerufsstandes.\nSie verstehen besser als vorher die gegenseitigen\nWechselwirkungen zwischen der technologischen\nEntwicklung der Informatik und gesellschaftlichen\nProzessen und Konflikten und sind hierbei in der Lage,\nAlternativen zu bewerten und eine eigene Beurteilung\nzu entwickeln.\nDie Studierenden besitzen ein erhöhtes individuelles\nProblem- und Verantwortungsbewusstsein bei der\nBerufsausübung und Erarbeitung konkreter\nMöglichkeiten und Handlungsalternativen zur\nWahrnehmung dieser Verantwortung.\nSie können ihr Wissen sowie eigene Bewertungen und\nBeurteilungen in selbständig erarbeiteten Vorträgen\nund Ausarbeitungen darstellen und in Fachgesprächen\nvertreten.\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 5 -\nInformatik (Master) – PO2023 Modulkatalog	\N	In dieser Lehrveranstaltung werden wichtige\nAuswirkungen der Informatik auf die Gesellschaft\nbehandelt. Spezielle Themen sind hierbei u.a.:\n• Nationale und internationale Berufsverbände (GI,\nACM, IEEE)\n• Das Recht auf informationelle Selbstbestimmung\nund seine Gefährdung durch die Anwendungen\nneuer Informatik-Technologien, insbesondere auf\nder Basis des Internets.\n• Auswirkungen der Informatik auf die Arbeitswelt.\n• Ethische Leitlinien der Gesellschaft für Informatik\n(GI) sowie der Association for Computing Machinery\n(ACM).
159	1	Komplexe Unternehmenanforderungen sind im\nRahmen einer gemeinsamen Spielsituation (Serious\nBusiness Game) zu analysieren, zu planen und zu\nentscheiden sowie die Ergebnisse dieser\nEntscheidungen zu beurteilen und zu korrigieren bzw.\nfortzuführen.\nDie Studierenden werden in die Lage versetzt, u.a.\n• die strategisches und operatives Management im\nunternehmerischen Kontext zu verstehen und zu\nerläutern,\n• die wesentlichen Aufgaben der betrieblichen\nFunktionalbereiche und deren Interdependenzen zu\nverstehen,\n• die Bewältigung von komplexen\nEntscheidungssituationen\n• die Etablierung und Skalierung eines neuen\nGeschäftsmodells\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation MODULHANDBUCH - 54 -\nWirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft	\N	Aus dem Bereich der Allgemeinen\nBetriebswirtschaftslehre insbesondere\nUnternehmensführung, u.a.\n• Corporate Entrepreneurship\n• Geschäftsmodell-Innovation\n• Marktsignale und Trends auf neuem und\nunerforschtem Terrain richtig deuten\n• Strategische Geschäftsentwicklung\n• Strategisches Marketing\n• Personalplanung und –qualifikation,\nProduktivitäte\n• Produktmanagement\n• Nachhaltigkeit der Produktion\n• Investitions- und Auslastungsplanung\n• Finanz- und Rechnungswesen\n• Umgang mit Komplexität, Unsicherheit und\nVolatilität\nMit Hilfe wechselnder Planspielangebote (TopSim oder\nandere) können jeweils unterschiedliche Schwerpunkte\ngesetzt und auf ausgewählte Problemstellungen im\nManagement-Kontext näher eingegangen werden.
\.


--
-- Data for Name: modul_literatur; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_literatur (id, modul_id, po_id, titel, autoren, verlag, jahr, isbn, typ, pflichtliteratur, sortierung) FROM stdin;
1	1	1	Skript, ergänzend:	\N	\N	\N	\N	\N	t	1
2	1	1	Cormen, Leierson, Rivest, Stein: Introduction to Algorithms, MIT Press	\N	\N	\N	\N	\N	f	2
3	1	1	Skiena: Algorithm Design Manual, Springer jeweils in aktueller Auflage.	\N	\N	\N	\N	\N	f	3
4	2	1	Eckermann, Ines Maria: Frei & kreativ: Das Handbuch für den Start in die Selbstständigkeit. Alles, was kreative Köpfe zu Existenzgründung, Businessplan, Akquise und Co. wissen müssen, 2021 Osterwalder, Alexander und Pigneur, Yves et al.: Business Model Generation: Ein Handbuch für Visionäre, Spielveränderer und Herausforderer, 2011 Leipziger, Jürg W: Konzepte entwickeln: Handfeste Anleitungen für bessere Kommunikation, 2010	\N	\N	\N	\N	\N	f	1
5	3	1	Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 9 - Informatik und Design (Bachelor) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	3
6	3	1	Karmasin, M	\N	\N	\N	\N	\N	f	4
7	3	1	Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596	\N	\N	\N	\N	\N	f	5
8	3	1	Weitere themenspezifische Literatur	\N	\N	\N	\N	\N	f	6
9	4	1	Einführung in die plattformübergreifende Entwicklung Einführung in aktuelle Frameworks, z.B. Flutter, Xamarin, ReactNative mit Fokus auf eines, das dann im Projekt genutzt wird sowie die zugrundeliegenden Programmiersprachen (z.B. Dard, C#, Javascript). Hierbei wird auch mit Hilfe von bereitgestellten Materialien ein hoher Selbstlernanteil integriert. Softwaretechnische Grundlagen für plattformübergreifende Entwicklung, z.B. Design- Patterns wie MVVM In Projektgruppen wird das theoretisch erlernte Wissen direkt im Rahmen eines realitätsnahen Semesterprojekts oder mehreren Vorlesungsbegleitetenden kleinen Projektaufgaben in die Praxis überführt.	\N	\N	\N	\N	\N	f	1
10	5	1	Heuer, Sattler, Saake. Datenbanken: Konzepte und Sprachen. mitp-Verlag	\N	\N	\N	\N	\N	f	2
11	5	1	Elmasri, Navathe. Grundlagen von Datenbanksystemen. Pearson Studium	\N	\N	\N	\N	\N	f	3
12	5	1	Foundations of Databases, Serge Abiteboul, Rick Hull, Victor Vianu, 1995.	\N	\N	\N	\N	\N	f	4
13	5	1	Ramakrishnan, Gehrke. Database Management Systems. McGraw-Hill	\N	\N	\N	\N	\N	f	5
14	6	1	Joachim Goll, Cornelia Heinisch: Java als erste Pro- grammiersprache. Springer Vieweg, 2016.	\N	\N	\N	\N	\N	f	2
15	6	1	Christian Ullenboom: Java ist auch eine Insel. Rheinwerk Computing, 2021.	\N	\N	\N	\N	\N	f	3
16	6	1	Offizielle Spezifikation der jeweils aktuellen Java- Version als Nachschlagewerk	\N	\N	\N	\N	\N	f	4
17	7	1	Akenine-Möller, T. et. al.: Real-Time Rendering. 4th edition, CRC Press, 2018. Rick Parent: Computer Animation: Algorithms and Techniques. 3rd edition, Morgan Kaufman / Elsevier, Third Edition, 2012. Dörner, R	\N	\N	\N	\N	\N	f	1
18	7	1	Jung, B. (Hrsg.): Virtual und Augmented Reality (VR / AR): Grundlagen und Methoden der Virtuellen und Augmentierten Realität. Verlag: Springer Vieweg 2019. Bender, M.	\N	\N	\N	\N	\N	f	4
19	7	1	Brill, M.: Computergrafik. 2. Auflage, Carl Hanser, 2006.	\N	\N	\N	\N	\N	f	5
20	8	1	Projekt-spezifisch	\N	\N	\N	\N	\N	f	1
21	9	1	Projekt-spezifisch	\N	\N	\N	\N	\N	f	1
22	10	1	Themenspezifische Literatur in Online-Literaturliste in Moodle	\N	\N	\N	\N	\N	f	1
23	11	1	Kuzbari, Rafic	\N	\N	\N	\N	\N	f	1
24	11	1	Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256 Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978- 3642134197	\N	\N	\N	\N	\N	f	2
25	12	1	Skript, ergänzend:	\N	\N	\N	\N	\N	t	1
26	12	1	Schöning: Logik für Informatiker, Spektrum	\N	\N	\N	\N	\N	f	2
27	12	1	Schöning: Ideen der Informatik, Oldenbourg jeweils in aktueller Auflage.	\N	\N	\N	\N	\N	f	3
28	13	1	Heinecke A. M.: Mensch-Computer-Interaktion – Basiswissen für Entwickler und Gestalter. x.media.press, Springer, Berlin 2014.	\N	\N	\N	\N	\N	f	2
29	13	1	Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann.	\N	\N	\N	\N	\N	f	3
30	13	1	Epple A.: JavaFX 8: Grundlagen und fortgeschrittene Techniken. dpunkt.verlag, Heidelberg 2015.	\N	\N	\N	\N	\N	f	4
31	13	1	Offizielle Java Dokumentation (Oracle) sowie verschiedene, geprüfte und als Onlinematerialien hinterlegte Web-Tutorials zu JavaFX.	\N	\N	\N	\N	\N	f	5
32	14	1	Weitz, E.: Konkrete Mathematik (nicht nur) für Informatiker	\N	\N	\N	\N	\N	f	2
33	14	1	Papula, L.: Mathematik für Ingenieure und Naturwissenschaftler Band 1: Ein Lehr- und Arbeitsbuch für das Grundstudium	\N	\N	\N	\N	\N	f	3
34	15	1	Joachim Goll, Cornelia Heinisch: Java als erste Pro- grammiersprache. Springer Vieweg, 2016.	\N	\N	\N	\N	\N	f	2
35	15	1	Christian Ullenboom: Java ist auch eine Insel. Rheinwerk Computing, 2021.	\N	\N	\N	\N	\N	f	3
36	15	1	Martin Fowler: Refactoring, Improving the Design of Existing Code. Addison Wesley, 2018.	\N	\N	\N	\N	\N	f	4
37	15	1	Offizielle Spezifikation der jeweils aktuellen Java- Version als Nachschlagewerk	\N	\N	\N	\N	\N	f	5
38	16	1	Gothelf, J., & Seiden, J. (2021). Lean UX. " O'Reilly Media, Inc.".	\N	\N	\N	\N	\N	f	1
39	17	1	https://designsprint.org/de/ https://hpi-academy.de/design-thinking/ Dreyfuss, H. (203). Designing for people. Skyhorse Publishing Inc.. Aktuelle Literatur und Selbstlernmaterial wird zu Beginn bekannt gegeben. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 41 - Informatik und Design (Bachelor) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	1
40	19	1	Weitz, E.: Konkrete Mathematik (nicht nur) für Informatiker	\N	\N	\N	\N	\N	f	2
41	19	1	Papula, L.: Mathematik für Ingenieure und Naturwissenschaftler Band 2 (Lineare Algebra) und Band 3 (Statistik)	\N	\N	\N	\N	\N	f	3
42	19	1	P. Knabner, W. Barth: Lineare Algebra: Grundlagen und Anwendungen. Springer (2018)	\N	\N	\N	\N	\N	f	4
43	19	1	E. Kramer, U. Kamps: Statistik und Wahrscheinlichkeitsrechnung. Springer (2008)	\N	\N	\N	\N	\N	f	5
44	19	1	P. Planing: Statistik Grundlagen. Planing Publishing (2022)	\N	\N	\N	\N	\N	f	6
45	19	1	A. Rooch: Statistik für Ingenieure. Springer (2014)	\N	\N	\N	\N	\N	f	7
46	19	1	Weitere Literatur wird in der Vorlesung bekannt gegeben.	\N	\N	\N	\N	\N	f	8
47	20	1	Spezifisch zu den ausgewählten Learning Units	\N	\N	\N	\N	\N	f	1
48	21	1	Spezifisch zu den ausgewählten Learning Units	\N	\N	\N	\N	\N	f	1
265	85	1	Wöhe, Günter	\N	\N	\N	\N	\N	f	6
49	22	1	Pisani, Patricia und Radtke, Susanne P.: Medienkompetenz: Handbuch Visuelle Mediengestaltung: Visuelle Sprache - Grundlagen der Gestaltung - Konzeption digitaler Medien - Fotogestaltung und Usability, 2012	\N	\N	\N	\N	\N	f	2
50	22	1	Wäger, Markus: Grafik und Gestaltung: Mediengestaltung von A bis Z verständlich erklärt, 2014	\N	\N	\N	\N	\N	f	3
51	22	1	Bergmann, Roberta: Die Grundlagen des Gestaltens: Plus: 50 praktische Übungen, 2021	\N	\N	\N	\N	\N	f	4
52	22	1	Willberg, Hans P. Und Forssman, Friedrich: Lesetypografie, 2010	\N	\N	\N	\N	\N	f	5
53	22	1	Hammer, Norbert: Mediendesign für Studium und Beruf (Grundlagenwissen und Entwurfssystematik in Layout, Typografie und Farbgestaltung), 2008	\N	\N	\N	\N	\N	f	6
54	22	1	Weitere Literatur in Online-Literaturliste in Moodle	\N	\N	\N	\N	\N	f	7
55	23	1	Dirk W. Hoffmann: Grundlagen der Technischen Informatik. 3. Auflage. Hanser Fachbuch, 2013. Andrew S. Tanenbaum, Herbert Bos: Moderne Betriebssysteme. Pearson Studium, 2016. Andrew S. Tanenbaum: Computernetzwerke. 5. Auflage, Pearson Studium, 2012. Dirk W. Hoffmann, Theoretische Informatik, Carl Hanser Verlag, 5. Auflage, 2022.	\N	\N	\N	\N	\N	f	1
56	24	1	Lewrick, Michael und Link, Patrick: The Design Thinking Playbook: Mindful Digital Transformation of Teams, Products, Services, Businesses and Ecosystems, 2018	\N	\N	\N	\N	\N	f	2
57	24	1	Noack, Jana und Diaz, Jose: Das Design Sprint Handbuch: Ihr Wegbegleiter durch die Produktentwicklung, 2019	\N	\N	\N	\N	\N	f	3
58	24	1	Wäger, Markus: Grafik und Gestaltung: Design und Mediengestaltung von A bis Z, 2016	\N	\N	\N	\N	\N	f	4
59	24	1	Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann.	\N	\N	\N	\N	\N	f	5
60	25	1	Sommerville, Ian: Software Engineering, Pearson, 10. aktualisierte Auflage, 2018	\N	\N	\N	\N	\N	f	2
61	25	1	Sommerville, Ian: Modernes Software- Engineering, Pearson, 2020	\N	\N	\N	\N	\N	f	3
62	25	1	Software Engineering Body of Knowledge (SWEBOOK): https://www.computer.org/education/bodies-of- knowledge/software-engineering (Version 4.0a, 2025)	\N	\N	\N	\N	\N	f	4
63	26	1	Wird in der ersten Veranstaltung bekannt gegeben Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 59 - Informatik und Design (Bachelor) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	1
64	27	1	Cook, J. (2017): Docker for Data Science. Apress, Springer, New York. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 62 - Informatik und Design (Bachelor) – PO2023 Learning Units BUILDING Hunter, T. (2017): Advanced Microservices. Apress, Springer, New York. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 63 -	\N	\N	\N	\N	\N	f	1
65	28	1	Ramos, Brais. B.	\N	\N	\N	\N	\N	f	1
66	28	1	Doran, John P.: Unreal Engine 4 Shaders and Effects Cookbook. Packt Publishing, 2019. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 64 -	\N	\N	\N	\N	\N	f	2
67	29	1	Noch zu definieren Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 65 -	\N	\N	\N	\N	\N	f	1
68	30	1	Wird im Modul bekanntgegeben Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 -	\N	\N	\N	\N	\N	f	1
69	31	1	Schmidt, Eric: Arduino Programming for Beginners: A Comprehensive Beginner’s Guide to Learn the Realms of Arduino Programming from A-Z Independently published (10. August 2022). ISBN: 979-8846004832. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 67 -	\N	\N	\N	\N	\N	f	1
70	32	1	Sumeragi, Kyou	\N	\N	\N	\N	\N	f	1
71	32	1	Yusuf, Arthatama: Learning Blender Python: A Beginner's First Steps in Understanding Blender Python. Independently published (16. Februar 2020). ISBN-13: 979-8608118104. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 68 -	\N	\N	\N	\N	\N	f	2
72	33	1	Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 69 -	\N	\N	\N	\N	\N	f	1
73	34	1	Hammad Fozi et. al.: Game Development Projects with Unreal Engine: Learn to build your first games and bring your ideas to life using UE4 and C++. Packt Publishing Ltd. 2020. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 71 -	\N	\N	\N	\N	\N	f	1
74	35	1	Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 73 -	\N	\N	\N	\N	\N	f	1
75	36	1	Hammad Fozi et. al.: Game Development Projects with Unreal Engine: Learn to build your first games and bring your ideas to life using UE4 and C++. Packt Publishing Ltd. 2020. ISBN: 978-1-80020-922-0. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 75 -	\N	\N	\N	\N	\N	f	1
76	37	1	Aktuelle Literatur wird abhängig von der thematischen Schwerpunktsetzung zum Semesterstart bekannt Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 76 - Informatik und Design (Bachelor) – PO2023 Learning Units BUILDING gegeben Basisliteratur: WOLF, Jürgen, 2016. HTML5 und CSS3: das umfassende Handbuch. 2. Auflage. Bonn: Rheinwerk. ISBN 978-3-8362-4158-8, 3-8362-4158-7 HELLER, Stephan, 2015. PHP 5.6 - Grundlagen zur Erstellung dynamischer Webseiten. Bodenheim: Herdt. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 77 -	\N	\N	\N	\N	\N	f	1
77	38	1	Mitch McCaffrey: Unreal Engine VR Cookbook. Pearson Education, 2017. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 79 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Learning Units DESIGNING Die nachfolgenden Learning Units können Teil des Moduls Projekt-Support-Modul DESIGNING Sustainable Futures sein. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 80 -	\N	\N	\N	\N	\N	f	1
78	39	1	Andreas Asanger: Blender 3 – Das umfassende Handbuch. Rheinwerk-Verlag, Bonn 2022. John M. Blain: The Complete Guide to Blender Graphics – Computer Modeling & Animation. 7th edition, CRC Press, 2022. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 82 -	\N	\N	\N	\N	\N	f	1
79	40	1	Giogoli, André und Hausel, Katharina: Bildgestaltung: die große Fotoschule. Von guten Bildern lernen: Theorie, Analyse, kreative Praxis. Mit vielen Anregungen und Übungen, 2022 Hogl, Marion: Digitale Fotografie: Über 700 Seiten Praxiswissen zu Technik, Bildgestaltung und Motiven, 2021 Freeman, Michael und Schmithäuser, Michael: Michael Freemans Komposition: Eine Masterclass für die fotografische Bildgestaltung, 2022 Rempen, Thomas und Stoklossa, Uwe: Blicktricks: Anleitung zur visuellen Verführung, 2005 Pricken, Mario und Klell, Christine: Visuelle Kreativität: Kreativitätstechniken für neue Bildwelten in Werbung, 3- D-Animation und Computergames, 2003 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 84 -	\N	\N	\N	\N	\N	f	1
80	41	1	Baetzgen, Andreas: Brand Design: Strategien für die digitale Welt, 2017 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 85 -	\N	\N	\N	\N	\N	f	1
81	42	1	Andreas Asanger: Blender 3 – Das umfassende Handbuch. Rheinwerk-Verlag, Bonn 2022. John M. Blain: The Complete Guide to Blender Graphics – Computer Modeling & Animation. 7th edition, CRC Press, 2022. Rick Parent: Computer Animation – Algorithms & Techniques. Morgan Kaufmann (3rd ed), 2012. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 87 -	\N	\N	\N	\N	\N	f	1
82	43	1	Jesse Schell: The Art of Game-Design – A Book of Lenses. 3rd Edition, CRC Press, Taylor & Francis Group, 2020. Werbach Kevin, Hunter Dan: For the Win – The Power of Gamification and Game Thinking in Business, Education, Goverment and Social Impact. Wharton School Press, 2020. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 89 -	\N	\N	\N	\N	\N	f	1
83	44	1	Hil Darjan und Lachenmeier Nicole: Visualizing Complexity: Handbuch modulares Informationsdesign, 2022 Heber, Raimar: Infografik: Gute Geschichten erzählen mit komplexen Daten: Fakten und Zahlen spannend präsentieren!, 2016 Stapelkamp, Torsten: Informationsvisualisierung: Web - Print - Signaletik. Erfolgreiches Informationsdesign: Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 90 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Leitsysteme, Wissensvermittlung und Informationsarchitektur, 2012 Data Flow: Visualising Information in Graphic Design, 2008 Weber, Wibke: Kompendium Informationsdesign, 2007 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 91 -	\N	\N	\N	\N	\N	f	1
84	45	1	Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann. Lim, Y. K., Stolterman, E., & Tenenberg, J. (2008). The anatomy of prototypes: Prototypes as filters, prototypes as manifestations of design ideas. ACM Transactions on Computer-Human Interaction (TOCHI), 15(2), 1-27. Dokumentation und geprüfte Tutorials unterschiedlicher Prototyping Tools Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 93 -	\N	\N	\N	\N	\N	f	1
85	46	1	Salmond, Michael: Video Game Level Design: How to Create Video Games with Emotion, Interaction, and Engagement. Bloomsbury Academic, 2021. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 94 -	\N	\N	\N	\N	\N	f	1
86	47	1	Hartson, R., & Pyla, P. (2018). The UX book: Agile UX design for a quality user experience. Morgan Kaufmann. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 95 -	\N	\N	\N	\N	\N	f	1
87	48	1	Alam, Daud und Gühl, Uwe: Projektmanagement für die Praxis: Ein Leitfaden und Werkzeugkasten für erfolgreiche Projekte, 2021 Dellnitz, Julia und Gentsch, Jan: Daily Play: Agile Spiele für Coaches und Scrum Master. Über 20 Spiele für agiles Projektmanagement, 2021 Kaltenecker, Siegfried: Selbstorganisierte Teams führen: Arbeitsbuch für Lean & Agile Professionals, 2021 Koschek, Holger und Trbojevic, Markus: Jedes Team ist anders: Ein Praxisbuch für nachhaltige Teamentwicklung, 2022 Sibbet, David: Visuelle Meetings: Meetings und Teamarbeit durch Zeichnungen, Collagen und Ideen- Mapping produktiver gestalten, 2011 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 97 -	\N	\N	\N	\N	\N	f	1
88	49	1	Radtke, Susanne P.: Interkulturelle Design-Grundlagen: Kulturelle und soziale Kompetenz für globales Design, 2022 Bieling, Tom: Inklusion als Entwurf: Teilhabeorientierte Forschung über, für und durch Design, 2019 Tromp, Nynkeund Hekkert, Paul: Designing for Society: Products and Services for a Better World, 2018 Stickdorn, Marc und Schneider, Jakob: This Is Service Design Thinking: Basics, Tools, Cases, 2012 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 99 -	\N	\N	\N	\N	\N	f	1
89	50	1	Pyczak, Thomas: Tell me!: Wie Sie mit Storytelling überzeugen. Mit vielen Praxisbeispielen. Für alle, die erfolgreich sein wollen in Beruf, PR und Marketing, 2020 Lupton, Ellen: Design is Storytelling, 2017 Willemien, Brand: Visuelles Denken: Stärkung von Menschen und Unternehmen durch visuelle Zusammenarbeit, 2019 Schaffranek, Ines: Sketchnotes kann jeder: Visuelle Notizen leicht gemacht – Für Einsteiger und Fortgeschrittene	\N	\N	\N	\N	\N	f	1
90	50	1	Graphic Recording für Hobby und den beruflichen Einsatz!, 2017 Fuchs, Werner T: Warum das Gehirn Geschichten liebt, Haufe, 2009 Christiano, Giuseppe: Storyboard Design (Grundlagen	\N	\N	\N	\N	\N	f	2
91	50	1	Übungen und Techniken), 2008 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 101 -	\N	\N	\N	\N	\N	f	3
92	51	1	Stickdorn, Marc et al.: This is Service Design Doing, 2017 Nunnally, Brad und Farkas, David: UX Research: Practical Techniques for Designing Better Products, 2017 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 102 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Falbe, Trine: White Hat UX: The Next Generation in User Experience, 2017 Lewrick, Michael et al.: Das Design Thinking Playbook: Mit traditionellen, aktuellen und zukünftigen Erfolgsfaktoren, 2018 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 103 -	\N	\N	\N	\N	\N	f	1
93	52	1	Jovy, Jörg: Digital filmen: Das umfassende Handbuch: Filme planen, aufnehmen, bearbeiten und präsentieren, 2019 Rogge, Axel: Videoeffekte: Attraktive Filme mit kleinem Budget: Videoschnitt, Blende, Zeitraffer, Soundeffekte und Greenscreen, 2015 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 105 -	\N	\N	\N	\N	\N	f	1
94	53	1	Spies, Marco & Wenger, Katja: Branded Interactions: Marketing Through Design in the Digital Age, 2020 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 106 - Informatik und Design (Bachelor) – PO2023 Learning Units DESIGNING Rohles, Björn: Grundkurs gutes Webdesign: Alles, was Sie über Gestaltung im Web wissen müssen, für moderne und attraktive Websites, die jeder gerne besucht!, 2017 Head, Val: Designing Interface Animation: Improving the User Experience Through Animation, 2016 Weitere Literatur in Online-Literaturliste in Moodle Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 107 -	\N	\N	\N	\N	\N	f	1
95	54	1	Karmasin, M	\N	\N	\N	\N	\N	f	1
96	54	1	Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 108 -	\N	\N	\N	\N	\N	f	2
364	110	1	Foundations of Databases, Serge Abiteboul, Rick Hull, Victor Vianu, 1995.	\N	\N	\N	\N	\N	f	3
100	55	1	Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400 Karmasin, M	\N	\N	\N	\N	\N	f	2
101	55	1	Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 7 - Informatik (Bachelor) – PO2023 Modulkatalog Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596 Weitere themenspezifische Literatur	\N	\N	\N	\N	\N	f	3
102	56	1	Bekanntgabe in der Vorlesung Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 9 - Informatik (Bachelor) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	1
110	57	1	Bekanntgabe in der Vorlesung	\N	\N	\N	\N	\N	f	1
111	58	1	Kuzbari, Rafic	\N	\N	\N	\N	\N	f	2
112	58	1	Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256	\N	\N	\N	\N	\N	f	3
113	58	1	Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer,2010. ISBN: 978- 3642134197	\N	\N	\N	\N	\N	f	4
127	59	1	Riggert/ Lübben, Rechnernetze, Hanser Verlag, aktuellste Auflage (online-Ressource)	\N	\N	\N	\N	\N	f	2
128	59	1	Dye, McDonald, Rufi	\N	\N	\N	\N	\N	f	3
129	59	1	Network Fundamentals, Cisco Press, 2007, ISBN 978-1-58713-208-7	\N	\N	\N	\N	\N	f	4
130	59	1	LAN Switching and Wireless, Cisco Press, 2008, ISBN 978-1- 58713-207-0	\N	\N	\N	\N	\N	f	6
131	59	1	Graziani, Johnson	\N	\N	\N	\N	\N	f	7
132	59	1	Routing Protocols and Concepts, Cisco Press, 2007, ISBN 978-1-58713-206-3	\N	\N	\N	\N	\N	f	8
133	59	1	Vachon, Graziani	\N	\N	\N	\N	\N	f	9
134	59	1	Accessing the WAN, Cisco Press, 2009, ISBN 978-1- 58713-205-6	\N	\N	\N	\N	\N	f	10
135	59	1	Aktuelle Ergänzungen auf den Moodle-Kurs zu diesem Modul	\N	\N	\N	\N	\N	f	11
143	60	1	Theisen, Manuel René, Wissenschaftliches Arbeiten: Erfolgreich bei Bachelor- und Masterarbeit, 17. aktualis. und bearb. Aufl., 2017, Verlag Franz Vahlen GmbH, 320 Seiten, ISBN: 978-3-8006-5382-9	\N	\N	\N	\N	\N	f	2
144	60	1	Burghardt, Manfred, Einführung in Projektmanagement: Definition, Planung, Kontrolle und Abschluss, 6. aktualis. und erw. Aufl., 2013, Publicis Corporate Publishing, 391 Seiten, ISBN: 978-3895784002	\N	\N	\N	\N	\N	f	3
145	60	1	Helmut Balzert, Lehrbuch der Software-Technik – Software- Management, Software- Qualitätssicherung, Unternehmensmodellierung, Band 2, 2. Auflage, Spektrum Akademischer Verlag, 2008, 721 Seiten, ISBN: 978-3827411617	\N	\N	\N	\N	\N	f	4
149	61	1	Wird in der ersten Veranstaltung bekannt gegeben Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 39 - Informatik (Bachelor) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	1
150	62	1	Häberlein, Tobias, Technische Informatik Vieweg und Teubner Verlag, aktuellste Auflage	\N	\N	\N	\N	\N	f	2
151	62	1	Hoffmann, Dirk W. , Grundlagen der Technischen Informatik, Hanser Verlag, aktuellste Auflage	\N	\N	\N	\N	\N	f	3
152	62	1	Eventuelle weitere aktuelle Literatur wird im zugehörigen Moodle Kurs genannt	\N	\N	\N	\N	\N	f	4
469	133	1	Literatur an das aktuelle Thema angepasst	\N	\N	\N	\N	\N	f	1
153	63	1	Dirk W. Hoffmann, Theoretische Informatik, Carl Hanser Verlag, 5. aktualisierte Auflage, 2022, 432 Seiten, ISBN: 978-3-446-47029-3	\N	\N	\N	\N	\N	f	2
154	63	1	Uwe Schöning: Theoretische Informatik – kurzgefasst, Spektrum Akademischer Verlag, 5. Auflage, 2003, 190 Seiten, ISBN-13: 978-3-827- 41824-1	\N	\N	\N	\N	\N	f	3
155	64	1	Bekanntgabe in der Vorlesung	\N	\N	\N	\N	\N	f	1
156	65	1	J. Steinmüller: „Bildanalyse“, Springer Verlag, ISBN 978-3540797425.- A. Nischwitz, P. Haberäcker: „Computergrafik und Bildverarbeitung, Band II Bildverarbeitung“, TeubnerVerlag, ISBN 978-3-834- 81712-9 A. Kaehler, G Bradski: "Learning OpenCV 3: Computer Vision in C++ with the OpenCV", 978-1491937990	\N	\N	\N	\N	\N	f	2
157	66	1	B. Müller, H. Wehr: Java Persistence API , Hanser Verlag, aktuelle Ausgabe	\N	\N	\N	\N	\N	f	2
158	66	1	Relevante Dokumentationen und Spezifikationen der verwendeten Technologien werden in der Vorlesung bekanntgegeben	\N	\N	\N	\N	\N	f	3
159	67	1	Benjamin M. Abdel-Karim: Data Science - Best Practices mit Python (Springer 2022)	\N	\N	\N	\N	\N	f	2
160	67	1	Manas A. Pathak: Beginning Data Science with R (Springer 2014)	\N	\N	\N	\N	\N	f	3
161	67	1	Joel Grus: Einführung in Data Science – Grundprinzipien der Datenanalyse mit Python (O’Reilly 2019)	\N	\N	\N	\N	\N	f	4
162	67	1	Annalyn Ng, Kenneth Soo: Data Science – was ist das eigentlich?!	\N	\N	\N	\N	\N	f	5
163	67	1	Weitere Literatur wird in der Veranstaltung bekannt gegeben.	\N	\N	\N	\N	\N	f	6
164	68	1	Lehmann et al.: Handbuch der Medizinischen Informatik, (Hanser 2005)	\N	\N	\N	\N	\N	f	2
165	68	1	Martin Dugas und Katrin Schmidt: Medizinische Informatik und Bioinformatik (Springer 2002)	\N	\N	\N	\N	\N	f	3
166	68	1	Kenneth Rothman, Sander Greenland, Timothy Lash: Modern Epidemiology (Wolter Kluwer, 2008)	\N	\N	\N	\N	\N	f	4
167	68	1	Weitere Literatur wird in der Veranstaltung bekannt gegeben.	\N	\N	\N	\N	\N	f	5
168	69	1	Wolfgang Weber: Industrieroboter, Methoden der Steuerung und Regelung, Hanser Verlag, 4. Auflage, ISBN 978-3-446-41031-2	\N	\N	\N	\N	\N	f	2
169	69	1	Quigley, M: Programming Robots with ROS: A Practical Introduction to the Robot Operating System	\N	\N	\N	\N	\N	f	3
170	69	1	P.I. Corke, “Robotics, Vision & Control”, Springer 2017, ISBN 978-3-319-54413-7 und Robotics Tollbox for Python- Introduction to Robotics: Mechanics and Control: Global Edition, 3rd Edition	\N	\N	\N	\N	\N	f	4
171	69	1	Bruno Siciliano, Oussama Khatib (Eds.): Handbook of Robotic, ISBN 978-3-540-23957-4	\N	\N	\N	\N	\N	f	5
172	70	1	Tanenbaum, A.: "Computernetzwerke"	\N	\N	\N	\N	\N	f	2
173	70	1	Prentice Hall, 2003	\N	\N	\N	\N	\N	f	3
174	70	1	ISBN: 3- 8273-7046-9	\N	\N	\N	\N	\N	f	4
175	70	1	Tanenbaum, A.	\N	\N	\N	\N	\N	f	5
176	70	1	van Stehen, M.: "Verteilte Systeme - Grundlagen und Paradigmen"	\N	\N	\N	\N	\N	f	6
178	70	1	ISBN: 3-8273-7057-4	\N	\N	\N	\N	\N	f	8
179	70	1	Proebster, W: "Rechnernetze - Technik, Protokolle, Systeme, Anwendungen"	\N	\N	\N	\N	\N	f	9
180	70	1	Oldenbourg Verlag	\N	\N	\N	\N	\N	f	10
181	70	1	ISBN: 3-486-25777-3	\N	\N	\N	\N	\N	f	11
182	70	1	Kreutzer, M.: "Telematik- und Kommunikationssysteme in der vernetzten Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 58 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Informatik Wirtschaft"	\N	\N	\N	\N	\N	t	14
184	70	1	ISBN: 3-486-25888- 5	\N	\N	\N	\N	\N	f	16
185	70	1	"Protokolle und Dienste der Informationstechnologie"	\N	\N	\N	\N	\N	f	18
186	70	1	Interest Verlag	\N	\N	\N	\N	\N	f	19
187	70	1	ISBN: 3- 8245-0412-X	\N	\N	\N	\N	\N	f	20
188	70	1	S. Feld, N. Pohlmann, M. Sparenberg, B. Wichmann: „Analyzing G-20´Key Autonomous Systems and their Intermeshing using AS-Analyzer”. In Proceedings of the ISSE 2012 - Securing Electronic Business Processes - Highlights of the Information Security Solutions Europe 2012 Conference, Eds.: N. Pohlmann, H. Reimer, W. Schneider	\N	\N	\N	\N	\N	f	21
189	70	1	Springer Vieweg Verlag, Wiesbaden 2012	\N	\N	\N	\N	\N	f	22
190	71	1	Nach Bekanntgabe in der Vorlesung.	\N	\N	\N	\N	\N	f	1
191	72	1	N. Pohlmann: „Cyber-Sicherheit - Das Lehrbuch für Konzepte, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung“ 2. Auflage, Springer Vieweg Verlag, Wiesbaden 2022	\N	\N	\N	\N	\N	f	2
192	72	1	Pohlmann, N.: Firewall-Systeme - Sicherheit für Internet und Intranet, E- Mail-Security, Virtual Private Network, Intrution Detection-System, Personal Firewalls. 5. aktualisierte und erweiterte Auflage	\N	\N	\N	\N	\N	f	3
193	72	1	ISBN 3- 8266-0988-3	\N	\N	\N	\N	\N	f	4
194	72	1	MITP-Verlag, Bonn 2003	\N	\N	\N	\N	\N	f	5
195	72	1	Pohlmann, N.	\N	\N	\N	\N	\N	f	6
196	72	1	Reimer, H.: "Trusted Computing - Ein Weg zu neuen IT- Sicherheitsarchitekturen”, ISBN 978-3-8348-0309-2, Vieweg-Verlag, Wiesbaden 2008	\N	\N	\N	\N	\N	f	7
197	72	1	H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Auflage, ISBN-10: 3-8266-1635-9	\N	\N	\N	\N	\N	f	8
198	72	1	523 Seiten, MITP- Verlag, Bonn 2006	\N	\N	\N	\N	\N	f	9
199	72	1	M. Hertlein, P. Manaras, N. Pohlmann: “Bring Your Own Device For Authentication (BYOD4A) – The Xign–System“. In Proceedings of the ISSE 2015 - Securing Electronic Business Processes - Highlights of the Information Security Solutions Europe 2015 Conference, Eds.: N. Pohlmann, H. Reimer, W. Schneider	\N	\N	\N	\N	\N	f	10
200	72	1	Springer Vieweg Verlag, Wiesbaden 2015	\N	\N	\N	\N	\N	f	11
201	73	1	Sommerville, Ian: Software Engineering, Addison- Wesley, 10th Edition, 2015	\N	\N	\N	\N	\N	f	2
202	73	1	George T. Heineman, William T. Councill: Component-Based Software Engineering: Putting the Pieces Together, Addison-Wesley Professional, 2001	\N	\N	\N	\N	\N	f	3
203	73	1	Clemens Szyperski: Component Software: Beyond Object-Oriented Programming. 2nd Edition, Addison- Wesley, 2002	\N	\N	\N	\N	\N	f	4
204	73	1	Eric Jendrock, Ricardo Cervera-Navarro, Ian Evans, Kim Haase, William Markito: The Java EE 7 Tutorial, 2014	\N	\N	\N	\N	\N	f	5
205	73	1	SPRING Framework documentation: https://spring.io/	\N	\N	\N	\N	\N	f	6
206	74	1	Russell, Norvig: Artificial Intelligence, A Modern Approach, Pearson, in der jeweils aktuellen Auflage	\N	\N	\N	\N	\N	f	2
207	74	1	Ertel, Grundkurs Künstliche Intelligenz, Springer, in der jeweils aktuellen Auflage	\N	\N	\N	\N	\N	f	3
208	74	1	Ergänzende grundlegende und aktuelle Forschungsarbeiten und Vorträge.	\N	\N	\N	\N	\N	f	4
209	75	1	P.Hitzler, M. Krötzsch, S. Rudolph: Foundations of Semantic Web Technologies, CRC Press, 2009. T. Heath, Ch. Bitzer: Linked Data – Evolving the Web into a Global Data Space, Morgan & Claypool, 2011.	\N	\N	\N	\N	\N	f	1
210	76	1	Liebel, C.: Progressive Web Apps: Das Praxisbuch. Rheinwerk Computing, 2018.	\N	\N	\N	\N	\N	f	2
211	76	1	Sillmann, T.: Das Swift-Handbuch: Apps programmieren für macOS, iOS, watchOS und tvOS. Carl Hanser Verlag, 2025.	\N	\N	\N	\N	\N	f	3
212	76	1	Springer, S.: React: Das umfassende Handbuch, Rheinwerk Computing, 2023.	\N	\N	\N	\N	\N	f	4
213	76	1	Theis, T.: Einstieg in Kotlin: Apps entwickeln mit Android Studio. Rheinwerk Computing, 2021.	\N	\N	\N	\N	\N	f	5
214	77	1	Jens Riwotzki, Cloud-Computing Theorie und Praxis, HERDT-Verlag	\N	\N	\N	\N	\N	f	2
215	77	1	Ulrich Trick, Einführung in die Mobilfunknetze der 5. Generation, Walter de Gruyter GmbH	\N	\N	\N	\N	\N	f	3
216	77	1	Michael Sauter, Grundkurs Mobile Kommunikationssysteme, Springer Vieweg, aktuellste Auflage	\N	\N	\N	\N	\N	f	4
217	77	1	Aktuelle Ergänzungen im Moodle-Kurs zu diesem Modul	\N	\N	\N	\N	\N	f	5
218	78	1	J. Hertzberg, K. Lingemann, A. Nüchter: „Mobile Roboter: Eine Einführung aus Sicht der Informatik“, ISBN 978-3642017254	\N	\N	\N	\N	\N	f	2
219	78	1	B. Siciliano, O. Khatib (Eds.): „Handbook of Robotic“, ISBN 978-3-540-23957-4	\N	\N	\N	\N	\N	f	3
220	78	1	Craig, J.J. (2004), „Introduction to Robotics: Mechanics and Control (3rd Edition)“, 8, 2004. Prentice Hall	\N	\N	\N	\N	\N	f	4
221	78	1	R. Siegwart „Introduction to Autonomous Mobile Robots“, MIT Press, ISBN: 978-0-262-19502 -7	\N	\N	\N	\N	\N	f	5
222	78	1	S. Thrun, W. Burgard, D. Fox: „Probabilistic Robotics“, ISBN 978-0262201629	\N	\N	\N	\N	\N	f	6
223	79	1	Thomas Rauber: “Parallele Programmierung”, Springer Verlag, ISBN 978-3-540-46549-2.- S. Hoffmann, R. Lienhart: "OpenMP"	\N	\N	\N	\N	\N	f	2
224	79	1	T. Rauber, G. Rünger: "Multicore: Parallele Programmierung"	\N	\N	\N	\N	\N	f	3
225	79	1	Norm Matloff: "Programming on Parallel Machines	\N	\N	\N	\N	\N	f	4
226	79	1	GPU, Multicore, Clusters and More"	\N	\N	\N	\N	\N	f	5
227	80	1	Manfred Dausmann, Ulrich Bröckl und Joachim Goll, C als erste Programmiersprache. Vom Einsteiger zum Profi. 8. überarb. und erw. Auflage, Springer Vieweg, 2014, 727 Seiten, ISBN-13: 978-3-834- 81858-4	\N	\N	\N	\N	\N	f	2
228	80	1	Jürgen Wolf, C von A bis Z. Rheinwerk Computing, 3., aktualisierte und erweiterte Auflage, 2009, 1190 Seiten, ISBN-13: 978-3-8362-1411-7	\N	\N	\N	\N	\N	f	3
229	80	1	Vogt: C für Java-Programmierer, Carl Hanser Verlag 2007, 256 Seiten, ISBN-13: 978-3-446-4079-78	\N	\N	\N	\N	\N	f	4
230	81	1	Eckert, C.: IT-Sicherheit. Konzepte, Verfahren, Protokolle. Oldenbourg, München, aktuellste Auflage	\N	\N	\N	\N	\N	f	2
231	81	1	Erickson, J.: Hacking - The Art of Exploitation. No Starch Press	\N	\N	\N	\N	\N	f	3
232	81	1	aktuellste Auflage	\N	\N	\N	\N	\N	f	4
233	81	1	Aktuelle wissenschaftliche Publikationen	\N	\N	\N	\N	\N	f	5
234	82	1	Sommerville, Ian: Software Engineering, Addison- Wesley, 10th Edition, 2015	\N	\N	\N	\N	\N	f	2
235	82	1	Fowler, Martin: Patterns of Enterprise Application Architecture, Addison-Wesley, 2002	\N	\N	\N	\N	\N	f	3
236	82	1	Rup, Chris u.a. UML 2 glasklar: Praxiswissen für die UML-Modellierung, Hanser, 4. Auflage, 2012	\N	\N	\N	\N	\N	f	4
237	82	1	Kirk Knoernschild: Java Application Architecture: Modularity Patterns with Examples Using OSGi, Prentice Hall, 2012	\N	\N	\N	\N	\N	f	5
238	83	1	Hefner, Sabine	\N	\N	\N	\N	\N	f	2
239	83	1	Dittmar, Michael: Grundlagen des SAP R/3-Finanzwesen, München 2001.	\N	\N	\N	\N	\N	f	3
240	83	1	Liening, Frank	\N	\N	\N	\N	\N	f	4
241	83	1	Scherleitner, Stephan: SAP R/3 – Gemeinkostencontrolling, München 2001.	\N	\N	\N	\N	\N	f	5
242	83	1	Olfert, Klaus: Kostenrechnung, 13. Auflage, Leipzig 2003.	\N	\N	\N	\N	\N	f	6
243	83	1	Weber, Jürgen	\N	\N	\N	\N	\N	f	7
244	83	1	Weißenberger, E. Barbara: Einführung in das Rechnungswesen, Bilanzierung und Kostenrechnung, 10. Auflage, Stuttgart 2021.	\N	\N	\N	\N	\N	f	8
245	83	1	Wöhe, Günter: Einführung in die Allgemeine Betriebswirtschaftslehre, 27. Auflage, München 2020.	\N	\N	\N	\N	\N	f	9
246	84	1	Primärliteratur:	\N	\N	\N	\N	\N	f	1
247	84	1	Hassler, M.: Digital und Web Analytics. 5. Aufl. mitp Verlag 2019.	\N	\N	\N	\N	\N	f	2
248	84	1	Keßler, E./Rabsch, S./Mandic, M.: Erfolgreiche Websites. 4. Aufl. Rheinwerk 2018.	\N	\N	\N	\N	\N	f	3
249	84	1	Kreutzer, R.T.: Praxisorientiertes Online-Marketing. 3. Aufl. Springer 2018.	\N	\N	\N	\N	\N	f	4
250	84	1	Kuß, A.: Marketing-Theorie: Eine Einführung. 3. Aufl. Springer 2013.	\N	\N	\N	\N	\N	f	5
251	84	1	Lammenett, E.: Praxiswissen Online-Marketing. 8. Aufl. Springer 2021.	\N	\N	\N	\N	\N	f	6
252	84	1	Rieber, D.: Mobile Marketing. Grundlagen, Strategien, Instrumente. Springer 2017.	\N	\N	\N	\N	\N	f	7
253	84	1	Terstiege, M.: Digitales Marketing. Erfolgsmodelle aus der Praxis. Springer 2021 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 88 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	\N	\N	\N	\N	t	8
254	84	1	Vollmert, M./Lück, H.: Google Analytics – Das umfassende Handbuch. 3. Aufl. Rheinwerk 2017.	\N	\N	\N	\N	\N	f	9
255	84	1	Wenz, C./Hauser, T. (Hrsg.): Websites optimieren – Das Handbuch, Springer Vieweg 2015.	\N	\N	\N	\N	\N	f	10
256	84	1	Sens, B.: Suchmaschinenoptimierung. Erste Schritte und Checklisten für bessere Google-Positionen. Springer 2018 Sekundärliteratur:	\N	\N	\N	\N	\N	f	11
257	84	1	Erlhofer, S.: Suchmaschinen-Optimierung: Das SEO- Standardwerk in neuer Auflage. Rheinwerk 2020.	\N	\N	\N	\N	\N	f	12
258	84	1	Grisby, M.: Marketing Analytics: A Practical Guide to Improving Consumer Insights Using Data Techniques. 2. Aufl. Kogan Page 2018.	\N	\N	\N	\N	\N	f	13
259	84	1	Haberich, R.: Future Digital Business: Wie Business Intelligence und Web Analytics Online-Marketing und Conversion verändern. mitp Verlag 2018.	\N	\N	\N	\N	\N	f	14
260	84	1	Heggde, G./Shainesh, G. (Hrsg.): Social Media Marketing. Palgrave Macmillan 2018.	\N	\N	\N	\N	\N	f	15
261	84	1	Olbrich, R./Schultz, C. D./Holsing, C.: Electronic Commerce und Online-Marketing. 2. Aufl. Springer 2020.	\N	\N	\N	\N	\N	f	16
262	85	1	Rahn, H.-J.: Einführung in die Betriebswirtschaftslehre, 11. Auflage, Herne 2013.	\N	\N	\N	\N	\N	f	3
263	85	1	Volkmann, C.	\N	\N	\N	\N	\N	f	4
264	85	1	Tokarski, K.-O.: Enterpreneurship, Gründung und Wachstum von jungen Unternehmen, Stuttgart 2006.	\N	\N	\N	\N	\N	f	5
266	85	1	Döhring, Ulrich: Einführung in die Allgemeine Betriebswirtschaftslehre, 25. Auflage, München 2013.	\N	\N	\N	\N	\N	f	7
267	86	1	Becker, J., Kugeler, M., Rosemann, M. [Hrsg.]: Prozessmanagement, Ein Leitfaden zur prozessorientierten Gestaltung, 7. Aufl., Berlin, Heidelberg, New York 2012.	\N	\N	\N	\N	\N	f	2
268	86	1	Rücker, B.: Praxishandbuch BPMN 2.0, 6. Aufl., München 2019.	\N	\N	\N	\N	\N	f	4
269	86	1	Hanschke, I.	\N	\N	\N	\N	\N	f	5
270	86	1	Lorenz, R.: Strategisches Prozessmanagement, 2. Aufl., München 2021.	\N	\N	\N	\N	\N	f	6
271	86	1	Scheer, A.-W.: ARIS-Vom Geschäftsprozess zum Anwendungssystem, 4. Aufl., Berlin, Heidelberg, New York 2002.	\N	\N	\N	\N	\N	f	7
272	86	1	Scheer, A-W.: Wirtschaftsinformatik, Referenzmodelle für industrielle Geschäftsprozesse, 7. Aufl., Berlin, Heidelberg, New York 1997.	\N	\N	\N	\N	\N	f	8
273	86	1	Schmelzer, H.-J., Sesselmann, W.: Geschäftsprozessmanagement in der Praxis, 9. Aufl., München 2020.	\N	\N	\N	\N	\N	f	9
274	87	1	Primärliteratur:	\N	\N	\N	\N	\N	f	1
275	87	1	Hansen, H.R./Mendling, J./Neumann, G.: Wirtschaftsinformatik. 12. Aufl., Berlin 2019.	\N	\N	\N	\N	\N	f	2
276	87	1	Kofler, T.: Das digitale Unternehmen. Heidelberg 2018.	\N	\N	\N	\N	\N	f	3
277	87	1	Laudon, K.C./Laudon, J.P./Schoder, D.: Wirtschaftsinformatik. Eine Einführung. 3. Aufl., München 2015.	\N	\N	\N	\N	\N	f	4
278	87	1	Leimeister, J.M: Einführung in die Wirtschaftsinformatik, 13. Aufl., Berlin 2021. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 95 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	\N	\N	\N	\N	t	5
279	87	1	Weber, P./Gabriel, R.: Basiswissen Wirtschaftsinformatik, 4. Aufl., Heidelberg 2022. Sekundärliteratur:	\N	\N	\N	\N	\N	f	6
280	87	1	Wirtz, B.: Electronic Business. 7. Aufl., Berlin 2020.	\N	\N	\N	\N	\N	f	7
281	87	1	Kollmann, T.: E-Business. Grundlagen elektronischer Geschäftsprozesse in der Digitalen Wirtschaft. 7. Aufl., Heidelberg 2019.	\N	\N	\N	\N	\N	f	8
282	88	1	Kappes, Martin: Netzwerk- und Datensicherheit: Eine praktische Einführung. Berlin Heidelberg New York: Springer-Verlag, 2007. -ISBN 978-3-835-19202-7. S. 1-348 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 98 - Informatik (Bachelor) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	\N	\N	\N	\N	t	2
283	88	1	Yaworski, Peter: Real-World Bug Hunting: A Field Guide to Web Hacking. München: No Starch Press, 2019. -ISBN 978-1-593-27862-5. S. 1-264	\N	\N	\N	\N	\N	f	3
284	88	1	Hoffman, Andrew: Web Application Security: Exploitation and Countermeasures for Modern Web Applications. Sebastopol: O'Reilly Media, 2020. -ISBN 978-1-492-05311-8. S. 1-450	\N	\N	\N	\N	\N	f	4
285	88	1	Pohlmann, Norbert: Cyber-Sicherheit: Das Lehrbuch für Konzepte, Prinzipien, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung. Wiesbaden: Springer Fachmedien Wiesbaden, 2019. -ISBN 978-3-658-25397-4. S.1-594	\N	\N	\N	\N	\N	f	5
286	88	1	Eckert, Claudia: IT-Sicherheit: Konzepte – Verfahren – Protokolle. Berlin/Boston: De Gruyter Oldenbourg, 2023. -ISBN 978-3-110-99689-0. S. 1-1040	\N	\N	\N	\N	\N	f	6
287	89	1	Burghardt, M.: Einführung in Projektmanagement	\N	\N	\N	\N	\N	f	2
288	89	1	Hrsg.: Siemens AG, Publicis Corporate Publishing, Erlangen, 2002, ISBN 3-89578-198-3	\N	\N	\N	\N	\N	f	3
289	89	1	Hindel, Hörmann, Müller, Schmied: Software- Projektmanagement	\N	\N	\N	\N	\N	f	4
290	89	1	dpunkt.verlag GmbH, Heidelberg 2004, ISBN 3-89864-230-5	\N	\N	\N	\N	\N	f	5
291	89	1	Litke, H.-D.: Projektmanagement, Carl Hanser Verlag, 1995, ISBN 3- 446-18310-8	\N	\N	\N	\N	\N	f	6
292	89	1	Bartsch-Beuerlein, S.: Qualitätsmanagement in IT- Projekten Planung, Organisation, Umsetzung	\N	\N	\N	\N	\N	f	7
293	89	1	Carl Hanser 2000	\N	\N	\N	\N	\N	f	8
294	90	1	Steven, M.: Produktionslogistik. Stuttgart: W. Kohlhammer Verlag, aktuelle Auflage.	\N	\N	\N	\N	\N	f	2
295	90	1	Schönsleben, P.: Integrales Logistikmanagement	\N	\N	\N	\N	\N	f	3
296	90	1	Springer-Verlag, aktuelle Auflage.	\N	\N	\N	\N	\N	f	4
297	90	1	Lasch, R.: Strategisches und operatives Logistikmanagement: Beschaffung. SpringerGabler, aktuelle Auflage.	\N	\N	\N	\N	\N	f	5
298	90	1	Vandeput, N.: Inventory Optimization. Models and Simulations, De Gruyter, aktuelle Auflage.	\N	\N	\N	\N	\N	f	6
299	90	1	Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.	\N	\N	\N	\N	\N	f	7
300	90	1	Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.	\N	\N	\N	\N	\N	f	8
301	91	1	Themenspezifisch	\N	\N	\N	\N	\N	f	1
302	92	1	Kuzbari, Rafic	\N	\N	\N	\N	\N	f	2
303	92	1	Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256	\N	\N	\N	\N	\N	f	3
304	92	1	Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978-3642134197	\N	\N	\N	\N	\N	f	4
305	93	1	Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400	\N	\N	\N	\N	\N	f	3
306	93	1	Karmasin, M	\N	\N	\N	\N	\N	f	4
307	93	1	Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596	\N	\N	\N	\N	\N	f	5
308	93	1	Weitere themenspezifische Literatur	\N	\N	\N	\N	\N	f	6
309	94	1	Projektspezifisch	\N	\N	\N	\N	\N	f	1
310	95	1	Themenspezifische Literatur, insbesondere Primärliteratur aus der aktuellen Forschung.	\N	\N	\N	\N	\N	f	1
311	96	1	DECHANGE, André. 2020. Projektmanagement – Schnell erfasst. Springer Gabler, Zugriff aus dem Hochschulnetz über https://link.springer.com/book/10.1007/978-3-662- 57667-0	\N	\N	\N	\N	\N	f	2
312	96	1	BURGHARDT, Manfred, 2018. Projektmanagement : Leitfaden für die Planung, Überwachung und Steuerung von Projekten [online]. Ed.: 10., überarbeitete und erweiterte Auflage. Erlangen : Publicis. ISBN 978-3- 89578-472-9. Zugriff aus dem Hochschulnetz über https://w- hs.digibib.net/search/eds/record/nlebk:1726722/eds- fulltext	\N	\N	\N	\N	\N	f	3
313	96	1	KAMMERER, Sebastian, Werner ACHTERT, Michael LANG, Michael AMBERG, Martin T. ADAM, Torsten BECKER, Roland BÖTTCHER und Jürgen BOPPER, 2012. IT-Projektmanagement-Methoden Best Practices von Scrum bis PRINCE2. Düsseldorf: Symposion, 2012. 1. Aufl. Erfolgreiches IT- Projektmanagement. ISBN 978-3-86329-435-9	\N	\N	\N	\N	\N	f	4
314	96	1	LAYTON, Mark C., 2015. Scrum For Dummies. Hoboken, NJ: For Dummies. ISBN 978-1-118- 90583-8 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 16 - Informatik (Master) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	5
315	96	1	LEOPOLD, Klaus und Siegfried KALTENECKER, 2018. Kanban in der IT eine Kultur der kontinuierlichen Verbesserung schaffen. München: Hanser. ISBN 978- 3-446-45360-9	\N	\N	\N	\N	\N	f	6
316	97	1	Projektspezifisch	\N	\N	\N	\N	\N	f	1
317	98	1	A. Geron: „Hands-On Machine Learning with Scikit- Learn & TensorFlow“ O’Reilly, 978-1492032649	\N	\N	\N	\N	\N	f	2
318	98	1	F. Chollet, „Deep Learning with Python“, Nanning, ISBN 978-1617294433	\N	\N	\N	\N	\N	f	3
319	98	1	M. Lapan: „Deep Reinforcement Learning Hands-On“, Expert Insight, ISBN 978-1788834247	\N	\N	\N	\N	\N	f	4
320	99	1	B. Cyganek, J.P. Siebert: „An Introduction to 3DComputer Vision Techniques and Algorithms“, Wiley,ISBN: 978-0-470-01704-3	\N	\N	\N	\N	\N	f	2
321	99	1	J. Steinmüller: „Bildanalyse“, Springer Verlag, ISBN978-3-540-79743-2.	\N	\N	\N	\N	\N	f	3
322	99	1	A. Nischwitz, P. Haberäcker: „Computergrafik und Bildverarbeitung, Band II Bildverarbeitung“, TeubnerVerlag, ISBN 978-3-834-81712-9.	\N	\N	\N	\N	\N	f	4
323	99	1	A Kaehler, G. Bradski: „Computer Vision in C++ withthe OpenCV Library“, O'Reilly, ISBN 978-1-449- 31465-1	\N	\N	\N	\N	\N	f	5
324	99	1	Aktuelle Literatur: https://paperswithcode.com/	\N	\N	\N	\N	\N	f	6
325	100	1	Leskovec, Rajaraman, Ullman. Mining of Massive Datasets Foundations of Databases, Serge Abiteboul, Rick Hull, Victor Vianu, 1995.	\N	\N	\N	\N	\N	f	1
326	101	1	G. James, D. Witten, T. Hastie, R. Tibshirani: An Introduction to Statistical Learning with Applications in R, Springer (2021)	\N	\N	\N	\N	\N	f	2
327	101	1	J.M. Philipps: Mathematical Foundations for Data Analysis, Springer (2021)	\N	\N	\N	\N	\N	f	3
328	101	1	M. Plaue: Data Science: Grundlagen, Statistik und maschinelles Lernen, Springer (2021)	\N	\N	\N	\N	\N	f	4
329	101	1	Weitere Literatur wird in der Veranstaltung bekannt gegeben.	\N	\N	\N	\N	\N	f	5
330	102	1	Grundlegende und aktuelle Literatur, angepasst an das (Wettbewerbs-)Thema (in der Regel mit intensivem Bezug zu maschinellem Lernen)	\N	\N	\N	\N	\N	f	1
331	103	1	Hannemann, D.: "Physik Smart-Book", ISBN 978-3- 920088-52-5	\N	\N	\N	\N	\N	f	2
332	103	1	Bostrom Nick, 2014: "Superintelligenz" Surkamp, eISBN 978-3-518-73900-6	\N	\N	\N	\N	\N	f	3
333	103	1	Kurzweil, Ray, 2014: "Menschheit 2.0" Die Singularität naht, ISBN 978-3-944203-08-9	\N	\N	\N	\N	\N	f	4
334	103	1	Human Brain Project, 2022: https://www.humanbrainproject.eu/	\N	\N	\N	\N	\N	f	5
335	103	1	Homeister, Matthias, 2018: "Quantum Computing verstehen", ISBN 978-3-658-10455-9	\N	\N	\N	\N	\N	f	6
336	103	1	Hinze, Th., M. Sturm, 2004: "Rechnen mit DNA" ISBN 3-486-27530-5	\N	\N	\N	\N	\N	f	7
337	103	1	Sackmann, E. & Merkel, R. 2010: "Lehrbuch der Biophysik"	\N	\N	\N	\N	\N	f	8
338	103	1	Thompson, R.F., 2001: "Das Gehirn", ISBN: 978-3- 662-53349-9	\N	\N	\N	\N	\N	f	9
339	103	1	Diverse Forschungsberichte zu folgenden Themen: o Neuromorphes Computing o Quanten-Computer, -Internet, -Information o Photonische Chips	\N	\N	\N	\N	\N	f	10
340	104	1	Richard Bird: Introduction to Functional Programming using Haskell. Prentice Hall, 2002.	\N	\N	\N	\N	\N	f	2
341	104	1	Richard Bird: Thinking Functionally with Haskell. Cambridge University Press, 2014.	\N	\N	\N	\N	\N	f	3
342	105	1	Russell, Norvig: Artificial Intelligence, A Modern Approach, Pearson, in aktueller Auflage (4. derzeit)	\N	\N	\N	\N	\N	f	2
343	105	1	Ausgewählte grundlegende und aktuelle Forschungspapiere und Vorträge.	\N	\N	\N	\N	\N	f	3
344	106	1	William F. Clocksin, Christopher S. Mellish: Programming in Prolog. Using the ISO Standard. 5th Ed., Springer, 2003, 299 Seiten, ISBN 978- 3540006787	\N	\N	\N	\N	\N	f	2
345	106	1	Ivan Bratko: Prolog Programming for Artificial Intelligence (4th Ed.). Addison-Wesley, 2011, 696 Seiten, ISBN: 978-0321417466	\N	\N	\N	\N	\N	f	3
346	106	1	Ulf Nilson, Jan Maluszynski: Logic, Programming, and Prolog (2nd Ed.). John Wiley, 1995, 294 Seiten, vom Verlag nicht mehr erhältlich, dafür online unter http://www.ida.liu.se/~ulfni/lpp (last updated: 2012- 05-07)	\N	\N	\N	\N	\N	f	4
347	106	1	Patrick Blackburn, Johan Bos, Kristina Striegnitz, Learn Prolog Now! College Publications, 2006, 284 Seiten, ISBN 978-1904987178 oder freie Online- Version http://www.learnprolognow.org.	\N	\N	\N	\N	\N	f	5
348	107	1	M.Wooldridge, An Introduction to MultiAgent Systems Second Edition. John Wiley & Sons, 2009.	\N	\N	\N	\N	\N	f	2
349	107	1	Y. Shoham and K. Leyton-Brown. Multiagent Systems: Algorithmic, Gamer-Theoretic, and Logical Foundations. Cambridge UP, 2008. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 41 - Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik	\N	\N	\N	\N	\N	t	3
350	107	1	G. Weiss, editor. Multi-Agent Systems. The MIT Press, 1999.	\N	\N	\N	\N	\N	f	4
351	107	1	M. Singh and M. Huhns. Readings in Agents. Morgan-Kaufmann Publishers, 1997.	\N	\N	\N	\N	\N	f	5
352	107	1	OSGi release 6	\N	\N	\N	\N	\N	f	6
353	107	1	Neil Bartlett: OSGi in Practice, 2009, online free available	\N	\N	\N	\N	\N	f	7
354	108	1	Jens Riwotzki, Cloud-Computing Theorie und Praxis, HERDT-Verlag	\N	\N	\N	\N	\N	f	2
355	108	1	Benjamin Kettner, Frank Geisler, Pro Serverless Data Handling with Microsoft Azure, Berkeley, CA: Apress, Imprint: Apress, 2022 (Online-Ressource)	\N	\N	\N	\N	\N	f	3
356	108	1	Ulrich Trick, Einführung in die Mobilfunknetze der 5. Generation, Walter de Gruyter GmbH	\N	\N	\N	\N	\N	f	4
357	108	1	Gerd Siegmund, SDN - Software-defined Networking: neue Anforderungen und Netzarchitekturen für performante Netze, VDE Verlag (Online-Ressource)	\N	\N	\N	\N	\N	f	5
358	108	1	Liyanage, Software Defined Mobile Networks (SDMN) - Beyond LTE Network Architecture John Wiley & Sons (Online-Ressource)	\N	\N	\N	\N	\N	f	6
359	108	1	Aktuelle Ergänzungen im Moodle-Kurs zu diesem Modul	\N	\N	\N	\N	\N	f	7
360	109	1	I. Goodfellow, Y. Bengio, A. Courville: Deep Learning. MIT Press, 2016 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 45 - Informatik (Master) – PO2023 Wahlpflichtkatalog Informatik	\N	\N	\N	\N	\N	t	2
361	109	1	M. A. Nielsen, Neural Networks and Deep Learning. Determination Press, 2015	\N	\N	\N	\N	\N	f	3
362	109	1	R. Kruse et al: Computational Intelligence: Eine methodische Einführung in Künstliche Neuronale Netze, Evolutionäre Algorithmen, Fuzzy-Systeme und Bayes-Netze (Springer 2015)	\N	\N	\N	\N	\N	f	4
363	110	1	Leskovec, Rajaraman, Ullman. Mining of Massive Datasets	\N	\N	\N	\N	\N	f	2
365	111	1	A. Geron: „Hands-On Machine Learning with Scikit- Learn & TensorFlow“ O’Reilly, 978-1492032649	\N	\N	\N	\N	\N	f	2
366	111	1	F. Chollet, „Deep Learning with Python“, Nanning, ISBN 978-1617294433	\N	\N	\N	\N	\N	f	3
367	111	1	M. Lapan: „Deep Reinforcement Learning Hands-On“, Expert Insight, ISBN 978-1788834247	\N	\N	\N	\N	\N	f	4
368	111	1	Aktuelle Literatur: https://paperswithcode.com/	\N	\N	\N	\N	\N	f	5
369	112	1	Sommerville, Ian: Software Engineering, Addison- Wesley, 10th Edition, 2015	\N	\N	\N	\N	\N	f	2
370	112	1	SPRING Framework 3.0: http://static.springsource.org/ spring/ docs/ 3.0.x/ spring-framework-reference/html/ (from 01.09.2009)	\N	\N	\N	\N	\N	f	3
371	112	1	Clements / Northrup: Software Product Lines: Practices and Patterns, 6th ed., Addison-Wesley, 2007	\N	\N	\N	\N	\N	f	4
372	112	1	Bass / Clements / Kazman: Software Architecture in Practice, Addison-Wesley	\N	\N	\N	\N	\N	f	5
373	112	1	3rd ed., 2012	\N	\N	\N	\N	\N	f	6
374	112	1	Douglass, Bruce: Real time UML, Addison-Wesley, 3rd ed., 2004	\N	\N	\N	\N	\N	f	7
375	112	1	Gelernter, David: The second coming - a manifesto, http://www.edge.org/3rd_culture/gelernter/gelernter_i ndex.html (article from 2009, read June 2012)	\N	\N	\N	\N	\N	f	8
376	112	1	McAfee, Andrew: Enterprise 2.0: new collaborative tools for your organization's toughest challenges, Harvard Business School Press	\N	\N	\N	\N	\N	f	9
377	112	1	1st edition (November 16, 2009)	\N	\N	\N	\N	\N	f	10
378	113	1	Wird in der Vorlesung bekannt gegeben	\N	\N	\N	\N	\N	f	1
379	114	1	Dunne, Anthony und Raby, Fiona: Speculative Everything: Design, Fiction, and Social Dreaming, 2013	\N	\N	\N	\N	\N	f	2
380	114	1	Literatur je nach Themenschwerpunkt in Online- Literaturliste in Moodle	\N	\N	\N	\N	\N	f	3
381	115	1	Andreas Dewald, Felix C. Freiling: Forensische Informatik. Books on demand, 2. Auflage 2015	\N	\N	\N	\N	\N	f	2
382	115	1	Alexander Geschonneck: Computer Forensik, dpunkt Verlag, 2. Auflage, 2006	\N	\N	\N	\N	\N	f	3
383	115	1	Diverse aktuelle Konferenz-Publikationen	\N	\N	\N	\N	\N	f	4
384	116	1	Nach Bekanntgabe in der Veranstaltung Themen werden an Hand von aktueller Primärliteratur behandelt.	\N	\N	\N	\N	\N	f	1
385	117	1	Kern, Ulrich u. Petra: Designplanung - Prozesse und Projekte des wissenschaftlich-gestalterischen Arbeitens, 2009	\N	\N	\N	\N	\N	f	2
386	117	1	Hensel, Daniela: Understanding Branding: Strategie- und Designprozesse verstehen und anwenden, 2015	\N	\N	\N	\N	\N	f	3
387	117	1	Niesen, Katrin: Designprojekte gestalten: ... damit Kreativität gewinnt und sich auszahlt, 2021	\N	\N	\N	\N	\N	f	4
388	117	1	Baars, Jan-Erik: Leading Design: How to build a successful business by design! Taschenbuch, 2020	\N	\N	\N	\N	\N	f	5
389	117	1	Weitere Literatur in Online-Literaturliste in Moodle	\N	\N	\N	\N	\N	f	6
390	118	1	Aktuelle wissenschaftliche Veröffentlichungen zu dem jeweiligen Thema der Vorlesung (wird zu Veranstaltungsbeginn bekannt gegeben).	\N	\N	\N	\N	\N	f	1
391	119	1	Kapp, K.M.: The Gamification of Learning and Instruction. Verlag John Wiley & Sons Inc 2012.	\N	\N	\N	\N	\N	f	2
392	119	1	Mesch, R.: The Gamification of Learning and Instruction Fieldbook. Verlag John Wiley & Sons Inc 2014.	\N	\N	\N	\N	\N	f	5
393	119	1	Anna Faust: The Effects of Gamification on Motivation and Performance. Springer Gabler, 2021.	\N	\N	\N	\N	\N	f	6
394	119	1	Susanne Strahringer, Christian Leyh (Hrsg.): Gamification und Serious Games. Springer 2017.	\N	\N	\N	\N	\N	f	7
395	119	1	Stefan Stieglitz et. al. (eds): Gamicication – Using Game Elements in Serious Contexts. Springer 2017.	\N	\N	\N	\N	\N	f	8
396	119	1	Johan Huizinga. Homo ludens: Vom Ursprung der Kultur im Spiel. Rowohlt Taschenbuch Verlag, 1987.	\N	\N	\N	\N	\N	f	9
397	119	1	Jeweils aktualisierte Forschungsartikel	\N	\N	\N	\N	\N	f	10
398	120	1	Koch, M.: Computer-Supported Cooperative Work. Reihe: Interaktive Medien (Hrsg.: M. Herczeg), Oldenbourg Verlag, 2007, ISBN: 978- 3-486-58000-6	\N	\N	\N	\N	\N	f	3
399	120	1	Scott, S.: Territoriality in Collaborative Tabletop Workspaces. PhD Thesis, University of Calgary, Calgary, Alberta, Canada, March, 2005.	\N	\N	\N	\N	\N	f	4
400	120	1	Tang, A. et al.: Collaborative coupling over tabletop displays. Proceedings of the SIGCHI conference on Human Factors in computing systems (Montreal, Quebec, Canada: ACM), 1181-90.	\N	\N	\N	\N	\N	f	5
401	120	1	Greenberg, S.: The Mechanics of Collaboration: Developing Low Cost Usability Evaluation Methods for Shared Workspaces. WETICE '00 Proceedings of the 9th IEEE International Workshops on Enabling Technologies: Infrastructure for Collaborative Enterprises, IEEE, 2000.	\N	\N	\N	\N	\N	f	7
402	121	1	N. Pohlmann: „Cyber-Sicherheit - Das Lehrbuch für Konzepte, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung“ 2. Auflage, Springer Vieweg Verlag, Wiesbaden 2022	\N	\N	\N	\N	\N	f	2
403	121	1	Pohlmann, N.: Firewall-Systeme - Sicherheit für Internet und Intranet, E- Mail-Security, Virtual Private Network, Intrution Detection-System, Personal Firewalls. 5. aktualisierte und erweiterte Auflage	\N	\N	\N	\N	\N	f	3
404	121	1	ISBN 3- 8266-0988-3	\N	\N	\N	\N	\N	f	4
405	121	1	MITP-Verlag, Bonn 2003	\N	\N	\N	\N	\N	f	5
406	121	1	A Campo, M.	\N	\N	\N	\N	\N	f	6
407	121	1	Pohlmann, N.: Virtual Private Network (VPN). 2. aktualisierte und erweiterte Auflage, ISBN 3-8266-0882-8	\N	\N	\N	\N	\N	f	7
409	121	1	D. Petersen, N. Pohlmann: „An ideal Internet Early Warning System“. In “Advances in IT Early Warning”, Fraunhofer Verlag, München 2013	\N	\N	\N	\N	\N	f	9
410	122	1	N. Pohlmann: „Cyber-Sicherheit - Das Lehrbuch für Konzepte, Mechanismen, Architekturen und Eigenschaften von Cyber-Sicherheitssystemen in der Digitalisierung“ 2. Auflage, Springer Vieweg Verlag, Wiesbaden 2022	\N	\N	\N	\N	\N	f	2
411	122	1	H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 76 - Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik) Auflage, ISBN-10: 3-8266-1635-9	\N	\N	\N	\N	\N	t	3
412	122	1	523 Seiten, MITP- Verlag, Bonn 2006	\N	\N	\N	\N	\N	f	4
413	122	1	Pohlmann, N.	\N	\N	\N	\N	\N	f	5
414	122	1	Reimer, H.: "Trusted Computing - Ein Weg zu neuen IT- Sicherheitsarchitekturen”, ISBN 978-3-8348-0309-2, Vieweg-Verlag, Wiesbaden 2008	\N	\N	\N	\N	\N	f	6
470	133	1	Diverse aktuelle Konferenz-Publikationen	\N	\N	\N	\N	\N	f	2
415	122	1	M. Jungbauer, N. Pohlmann: „Integrity Check of Remote Computer Systems - Trusted Network Connect". In Proceedings of the ISSE/SECURE 2007 - Securing Electronic Business Processes - Highlights of the Information Security Solutions Europe/Secure 2007 Conference, Eds.: N. Pohlmann, H. Reimer, W. Schneider	\N	\N	\N	\N	\N	f	7
416	122	1	Vieweg Verlag, Wiesbaden 2007	\N	\N	\N	\N	\N	f	8
417	123	1	Abhängig von der gewählten Entwicklungssprache und Umgebung. Für JavaFX beispielsweise:	\N	\N	\N	\N	\N	f	1
418	123	1	Epple A.: JavaFX 8: Grundlagen und fortgeschrittene Techniken. dpunkt.verlag, Heidelberg 2015.	\N	\N	\N	\N	\N	f	2
419	123	1	Sharan K.: Learn JavaFX 8 - Building User Experience and Interfaces with Java 8. Apress, New York 2015.	\N	\N	\N	\N	\N	f	3
420	123	1	Esseling B.: A Practical Guide to Localization. John Benjamins Publishing Company, Amsterdam 2000.	\N	\N	\N	\N	\N	f	4
421	123	1	Cunningham K.: Accessibility Handbook. O’Reilly, Sebastopol 2012.	\N	\N	\N	\N	\N	f	5
422	124	1	Timo Steffens: Auf der Spur der Hacker - Wie man die Täter hinter der Computer-Spionage enttarnt	\N	\N	\N	\N	\N	f	2
423	124	1	Michael Sikorski and Andrew Honig: Practical Malware Analysis	\N	\N	\N	\N	\N	f	3
424	124	1	Russinovich, M./Solomon, D./Ionescu, A.: Windows Internals, Part 1 & 2	\N	\N	\N	\N	\N	f	4
425	124	1	Microsoft Press, 6. Edition	\N	\N	\N	\N	\N	f	5
426	124	1	Diverse aktuelle Konferenz-Publikationen	\N	\N	\N	\N	\N	f	6
427	125	1	Wigdor D. and Wixon D.: Brave NUI World - Designing Natural User Interfaces for Touch and Gesture. Morgan Kaufmann, Burlington 2011.	\N	\N	\N	\N	\N	f	2
428	125	1	Kean S. e.a.: Meet the Kinect - An Introduction to Programming Natural User Interfaces. Apress, New York 2011.	\N	\N	\N	\N	\N	f	3
429	125	1	Lee, G.G. e.a.: Natural Language Dialog Systems and Intelligent Assistants. Springer, New York 2015.	\N	\N	\N	\N	\N	f	4
430	126	1	Adams, Carlisle. Introduction to Privacy Enhancing Technologies. 1st ed. Cham, Switzerland: Springer Nature, 2021. https://doi.org/10.1007/978-3-030- 81043-6.	\N	\N	\N	\N	\N	f	2
431	126	1	Jarmul, Katharine. Practical Data Privacy. O’Reilly Media, 2023.	\N	\N	\N	\N	\N	f	3
432	126	1	Dennedy, Michelle, Jonathan Fox, and Tom Finneran. The Privacy Engineer’s Manifesto. PDF. 1st ed. Berlin, Germany: APress, 2014. https://doi.org/10.1007/978-1-4302-6356-2.	\N	\N	\N	\N	\N	f	4
433	126	1	Aktuelle wissenschaftliche Veröffentlichungen	\N	\N	\N	\N	\N	f	5
434	127	1	The Rust Programming Language, Steve Klabnik and Carol Nichols, August 2019, https://doc.rust- lang.org/book/	\N	\N	\N	\N	\N	f	2
435	127	1	Software Security: Principles, Policies, and Protection (SS3P), Mathias Payer, v0.37, https://nebelwelt.net/SS3P/softsec.pdf	\N	\N	\N	\N	\N	f	3
436	127	1	Diverse aktuelle Konferenz-Publikationen	\N	\N	\N	\N	\N	f	4
437	128	1	Eilam, E.: Reversing: Secrets of Reverse Engineering	\N	\N	\N	\N	\N	f	2
438	128	1	John Wiley & Sons, 1. Auflage	\N	\N	\N	\N	\N	f	3
439	128	1	Dang, B./Gazet, A.: Practical Reverse Engineering: x86, x64, ARM, Windows Kernel, Reversing Tools, and Obfuscation	\N	\N	\N	\N	\N	f	4
441	128	1	Russinovich, M./Solomon, D./Ionescu, A.: Windows Internals, Part 1 & 2	\N	\N	\N	\N	\N	f	6
442	128	1	Microsoft Press, 6. Edition	\N	\N	\N	\N	\N	f	7
443	128	1	Diverse aktuelle Konferenz-Publikationen	\N	\N	\N	\N	\N	f	8
444	129	1	Primärliteratur:	\N	\N	\N	\N	\N	f	1
445	129	1	Cleve, J./Lämmel, U.: Data Mining. 3. Aufl., Berlin 2020.	\N	\N	\N	\N	\N	f	2
446	129	1	Bengfort, B/Bilbro, R./Ojeda, T.: Applied Text Analysis with Python: Enabling Language Aware Data Products with Machine Learning. Newark 2018	\N	\N	\N	\N	\N	f	3
447	129	1	Kollmann, T.: Digital Marketing. Grundlagen der Absatzpolitik in der Digitalen Wirtschaft. 3. Aufl., Stuttgart 2020.	\N	\N	\N	\N	\N	f	4
448	129	1	Kreutzer, R.T.: Praxisorientiertes Online-Marketing. 4. Aufl., Wiesbaden 2021.	\N	\N	\N	\N	\N	f	5
449	129	1	Lammenett, E.: Praxiswissen Online-Marketing. Affiliate- und E-Mail-Marketing, Suchmaschinenmarketing, Online-Werbung, Social Media, Online-PR. 8. Aufl., Wiesbaden 2021.	\N	\N	\N	\N	\N	f	6
450	129	1	Neckel, P./Knobloch, B.: Customer Relationship Analytics. Praktische Anwendung des Data Mining im CRM. 2. Aufl., Heidelberg 2015. Sekundärliteratur: Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 95 - Informatik (Master) – PO2023 Wahlpflichtkatalog Lehreinheit (enthält auch alle Module des Wahlpflichtkatalogs Informatik)	\N	\N	\N	\N	\N	t	7
451	129	1	Backhaus, K./Erichson, B./Gensler, S./Weiber, R./Weiber, T.: Multivariate Analysemethoden. Ein anwendungsorientierte Einführung. 16. Aufl., Berlin 2021.	\N	\N	\N	\N	\N	f	8
452	129	1	Kaufmann, U./Tan, A.: Data Analytics for Organisational Development: Unleashing the Potential of Your Data. Newark 2021.	\N	\N	\N	\N	\N	f	9
453	129	1	Russel, M./Klassen, M.: Mining the social web: Data Mining Facebook, Twitter, LinkedIn, Google+, Github, and more. Newark 2019.	\N	\N	\N	\N	\N	f	10
454	130	1	Sherman, W.R.	\N	\N	\N	\N	\N	f	2
455	130	1	Craig, A.B.: Understanding Virtual Reality: Interface, Application, and Design. Morgan Kaufman Publishers, 2018.	\N	\N	\N	\N	\N	f	3
456	130	1	Jung, B. (Hrsg.): Virtual und Augmented Reality (VR / AR): Grundlagen und Methoden der Virtuellen und Augmentierten Realität. Verlag: Springer Vieweg 2019.	\N	\N	\N	\N	\N	f	7
457	130	1	Akenine-Möller, T.	\N	\N	\N	\N	\N	f	8
458	130	1	Hoffman, N.: Real- Time Rendering. Verlag Taylor & Francis Ltd. 2018 (4th edition).	\N	\N	\N	\N	\N	f	10
459	131	1	Mertens, P. et al.: Grundzüge der Wirtschaftsinformatik, aktuelle Auflage	\N	\N	\N	\N	\N	f	2
460	131	1	Alicke, K.: Supply Chain Management. Springer, aktuelle Auflage.	\N	\N	\N	\N	\N	f	3
461	131	1	Sucky, E.: Supply Chain Management, Kohlhammer, aktuelle Auflage.	\N	\N	\N	\N	\N	f	4
462	131	1	Vandeput, N.: Inventory optimization. Models and simulations, de Gruyter, aktuelle Auflage.	\N	\N	\N	\N	\N	f	5
463	131	1	Biedermann, L.: Supply Chain Resilienz. Konzeptioneller Bezugsrahmen und Identifikation zukünftiger Erfolgsfaktoren, Springer, aktuelle Auflage.	\N	\N	\N	\N	\N	f	6
464	131	1	Schönsleben, P.: Integrales Logistikmanagement	\N	\N	\N	\N	\N	f	7
465	131	1	Springer-Verlag, aktuelle Auflage.	\N	\N	\N	\N	\N	f	8
466	131	1	Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.	\N	\N	\N	\N	\N	f	9
467	131	1	Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, SpringerGabler, aktuelle Auflage.	\N	\N	\N	\N	\N	f	10
468	132	1	Abhängig von den jeweiligen aktuellen Trendthemen	\N	\N	\N	\N	\N	f	1
481	122	1	H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 11 - Internet-Sicherheit (Master) – PO2023 Modulkatalog Auflage, ISBN-10: 3-8266-1635-9	\N	\N	\N	\N	\N	f	3
487	134	1	Kuzbari, R.	\N	\N	\N	\N	\N	f	2
488	134	1	Ammer, R.: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006. ISBN-10 3-211-23525-6	\N	\N	\N	\N	\N	f	3
489	134	1	Leopold-Wildburger, U.	\N	\N	\N	\N	\N	f	4
490	134	1	Schütze, J.: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. Springer-Verlag Berlin Heidelberg New York, 2002. ISBN 3-540-43027-X	\N	\N	\N	\N	\N	f	5
491	135	1	Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart 2009 (15. Auflage). ISBN-10: 3825207242	\N	\N	\N	\N	\N	f	3
492	135	1	Bliefert, C.: Bachelor-. Master- und Doktorarbeit – Anleitungen für den naturwissenschaftlichtechnischen Nachwuchs. Verlag Wiley 2009 (4. Auflage). ISBN-10: 3527324771	\N	\N	\N	\N	\N	f	5
493	135	1	Gockel, T.: Form der wissenschaftlichen Ausarbeitung. Springer-Verlag Berlin 2008. ISBN-10: 3540786139	\N	\N	\N	\N	\N	f	6
494	135	1	Themenspezifische Literatur	\N	\N	\N	\N	\N	f	7
500	136	1	Projektspezifisch, wird zu Veranstaltungsbeginn bekannt gegeben	\N	\N	\N	\N	\N	f	1
501	137	1	Projektspezifisch, wird zu Veranstaltungsbeginn bekannt gegeben	\N	\N	\N	\N	\N	f	1
502	138	1	Projektspezifisch, wird zu Veranstaltungsbeginn bekannt gegeben	\N	\N	\N	\N	\N	f	1
546	139	1	Aktuelle Forschungsliteratur	\N	\N	\N	\N	\N	f	2
547	139	1	Uwe Gruenefeld, Jonas Auda, Florian Mathis, Stefan Schneegass, Mohamed Khamis, Jan Gugenheimer, and Sven Mayer. 2022. VRception: Rapid Prototyping of Cross-Reality Systems in Virtual Reality. In Proceedings of the 2022 CHI Conference on Human Factors in Computing Systems (CHI '22). Association for Computing Machinery, New York, NY, USA, Article 611, 1–15. https://doi.org/10.1145/3491102.3501821	\N	\N	\N	\N	\N	f	3
548	139	1	Proceedings Cross-Reality Interaction Workshop http://ceur-ws.org/Vol-2779/	\N	\N	\N	\N	\N	f	4
549	139	1	https://x-pro.fh-ooe.at/	\N	\N	\N	\N	\N	f	5
550	139	1	https://crossreality.hcigroup.de/	\N	\N	\N	\N	\N	f	6
551	140	1	https://www.interaction-design.org/literature/book/the- encyclopedia-of-human-computer-interaction-2nd- ed/3d-user-interfaces	\N	\N	\N	\N	\N	f	2
552	140	1	LaViola Jr, J. J., Kruijff, E., McMahan, R. P., Bowman, D., & Poupyrev, I. P. (2017). 3D User Interfaces: Theory and Practice . Addison-WesleyProfessional.	\N	\N	\N	\N	\N	f	3
559	141	1	Kuzbari, Rafic	\N	\N	\N	\N	\N	f	2
560	141	1	Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256	\N	\N	\N	\N	\N	f	3
561	141	1	Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978-3642134197	\N	\N	\N	\N	\N	f	4
562	142	1	Stary, J.: Die Technik wissenschaftlichen Arbeitens. UTB-Verlag Stuttgart, 2013 (17. überarb. Auflage), 301 Seiten, ISBN: 978-3825240400 Karmasin, M	\N	\N	\N	\N	\N	f	2
563	142	1	Ribing, R.: Die Gestaltung wissenschaftlicher Arbeiten: Ein Leitfaden für Seminararbeiten, Bachelor-, Master- und Magisterarbeiten sowie Dissertationen. UTB-Verlag Stuttgart, 2014 (8. aktual. Auflage), 167 Seiten, ISBN: 978-3825242596 weitere themenspezifische Literatur	\N	\N	\N	\N	\N	f	3
564	143	1	projekt-spezifisch	\N	\N	\N	\N	\N	f	1
565	144	1	Themenspezifische Literatur aus den Forschungsbereichen	\N	\N	\N	\N	\N	f	1
605	120	1	Koch, M.: Computer-Supported Cooperative Work. Reihe: Interaktive Medien (Hrsg.: M. Herczeg), Oldenbourg Verlag, 2007, ISBN: 978-3-486-58000-6	\N	\N	\N	\N	\N	f	3
620	122	1	H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 55 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog Auflage, ISBN-10: 3-8266-1635-9	\N	\N	\N	\N	\N	t	3
636	107	1	Y. Shoham and K. Leyton-Brown. Multiagent Systems: Algorithmic, Gamer-Theoretic, and Logical Foundations. Cambridge UP, 2008. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 62 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog	\N	\N	\N	\N	\N	t	3
646	109	1	I. Goodfellow, Y. Bengio, A. Courville: Deep Learning. MIT Press, 2016 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog	\N	\N	\N	\N	\N	t	2
657	96	1	LAYTON, Mark C., 2015. Scrum For Dummies. Hoboken, NJ: For Dummies. ISBN 978-1-118- 90583-8 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 73 - Medieninformatik (Master) – PO2023 Wahlpflichtkatalog	\N	\N	\N	\N	\N	t	5
668	145	1	Abhängig von der Forschungsthematik	\N	\N	\N	\N	\N	f	1
673	146	1	Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.	\N	\N	\N	\N	\N	f	3
674	146	1	Weitere themenspezifische Literatur	\N	\N	\N	\N	\N	f	4
675	147	1	ISBN 978-3-662-61411-2 Betriebssysteme kompakt von Christian Baun (Online-Ressource), Springer Vieweg	\N	\N	\N	\N	\N	f	2
676	147	1	ISBN 978-3-662-59897-9 Computernetze kompakt Christian Baun (abgestimmte Online-Ressource), Springer Vieweg	\N	\N	\N	\N	\N	f	3
677	147	1	Tanenbaum/Bos Moderne Betriebssysteme, Pearson Studium, aktuellste Auflage	\N	\N	\N	\N	\N	f	4
678	147	1	Tanenbaum, Wetherall Computernetzwerke, Pearson Stark, aktuellste Auflage	\N	\N	\N	\N	\N	f	5
679	147	1	Aktuelle Ergänzungen im Moodle-Kurs zu diesem Modul	\N	\N	\N	\N	\N	f	6
699	84	1	Terstiege, M.: Digitales Marketing. Erfolgsmodelle aus der Praxis. Springer 2021 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 15 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	8
723	148	1	Mertens, P. et al.: Grundzüge der Wirtschaftsinformatik, aktuelle Auflage	\N	\N	\N	\N	\N	f	2
724	148	1	Scheer, A.-W.: Wirtschaftsinformatik, Springer- Verlag, aktuelle Auflage.	\N	\N	\N	\N	\N	f	3
725	148	1	Alicke, K.: Planung und Betrieb von Logistiknetzwerken. Unternehmensübergreifendes Supply Chain Management. Springer, aktuelle Auflage.	\N	\N	\N	\N	\N	f	4
726	148	1	Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, aktuelle Auflage.	\N	\N	\N	\N	\N	f	5
727	148	1	Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, aktuelle Auflage.	\N	\N	\N	\N	\N	f	6
728	148	1	Schönsleben, P.: Integrales Logistikmanagement	\N	\N	\N	\N	\N	f	7
729	148	1	Springer-Verlag, aktuelle Auflage.	\N	\N	\N	\N	\N	f	8
730	148	1	Meier, L.: Koordination Interdependenter Planungssysteme in der Logistik, Gabler, 2009.	\N	\N	\N	\N	\N	f	9
735	87	1	Leimeister, J.M: Einführung in die Wirtschaftsinformatik, 13. Aufl., Berlin 2021. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 26 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	5
740	149	1	Kuzbari, Rafic	\N	\N	\N	\N	\N	f	2
741	149	1	Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256	\N	\N	\N	\N	\N	f	3
742	149	1	Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978- 3642134197	\N	\N	\N	\N	\N	f	4
770	150	1	Mertens, P. et al.: Grundzüge der Wirtschaftsinformatik, aktuelle Auflage	\N	\N	\N	\N	\N	f	2
771	150	1	Alicke, K.: Planung und Betrieb von Logistiknetzwerken. Unternehmensübergreifendes Supply Chain Management. Springer, aktuelle Auflage.	\N	\N	\N	\N	\N	f	3
772	150	1	Sucky, E.: Supply Chain Management, Kohlhammer, aktuelle Auflage.	\N	\N	\N	\N	\N	f	4
773	150	1	Thommen, J.-P. et al.: Allgemeine Betriebswirtschaftslehre, aktuelle Auflage.	\N	\N	\N	\N	\N	f	5
774	150	1	Vandeput, N.: Inventory Optimization. Models and Simulations, aktuelle Auflage.	\N	\N	\N	\N	\N	f	6
775	150	1	Weber, W. et al.: Einführung in die Betriebswirtschaftslehre, aktuelle Auflage.	\N	\N	\N	\N	\N	f	7
776	150	1	Schönsleben, P.: Integrales Logistikmanagement	\N	\N	\N	\N	\N	f	8
777	150	1	Springer-Verlag, aktuelle Auflage.	\N	\N	\N	\N	\N	f	9
778	150	1	Meier, L.: Koordination Interdependenter Planungssysteme in der Logistik, Gabler, 2009. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 47 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog Weitere jeweils aktuelle Quellen auch zur Fallstudie werden zu Beginn der Veranstaltung bekannt gegeben.	\N	\N	\N	\N	\N	f	10
786	151	1	Theisen, Manuel René, Wissenschaftliches Arbeiten: Erfolgreich bei Bachelor- und Masterarbeit, 17. Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 52 - Wirtschaftsinformatik (Bachelor) – PO2023 Modulkatalog aktualis. und bearb. Aufl., 2017, Verlag Franz Vahlen GmbH, 320 Seiten, ISBN: 978-3-8006-5382-9	\N	\N	\N	\N	\N	f	2
787	151	1	Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.	\N	\N	\N	\N	\N	f	4
788	151	1	Helmut Balzert, Lehrbuch der Software-Technik – Software- Management, Software- Qualitätssicherung, Unternehmensmodellierung, Band 2, 2. Auflage, Spektrum Akademischer Verlag, 2008.	\N	\N	\N	\N	\N	f	5
789	151	1	Projektspezifische Literatur	\N	\N	\N	\N	\N	f	6
790	151	1	Literatur zu Projekt- und Teamarbeit	\N	\N	\N	\N	\N	f	7
794	152	1	Wird in der ersten Veranstaltung bekannt gegeben	\N	\N	\N	\N	\N	f	1
813	70	1	Kreutzer, M.: "Telematik- und Kommunikationssysteme in der vernetzten Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 66 - Wirtschaftsinformatik (Bachelor) – PO2023 Wahlpflichtkatalog Wirtschaft"	\N	\N	\N	\N	\N	t	14
847	88	1	Kappes, Martin: Netzwerk- und Datensicherheit: Eine praktische Einführung. Berlin Heidelberg New York: Springer-Verlag, 2007. -ISBN 978-3-835-19202-7. S. 1-348 Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 81 - Wirtschaftsinformatik (Bachelor) – PO2023 Wahlpflichtkatalog	\N	\N	\N	\N	\N	t	2
860	153	1	Bauer, Andreas	\N	\N	\N	\N	\N	f	2
861	153	1	Günzel, Holger (Hrsg.): Data Warehouse Systeme – Architektur, Entwicklung, Anwendung, 4. Auflage, 2013.	\N	\N	\N	\N	\N	f	3
862	153	1	Gluchowski, Peter	\N	\N	\N	\N	\N	f	4
863	153	1	Gabriel, Roland	\N	\N	\N	\N	\N	f	5
864	153	1	Dittmar, Carsten: Management Support Systeme und Business Intelligence – Computergestützte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 5 - Wirtschaftsinformatik (Master) – PO2023 Modulkatalog Informationssysteme für Fach- und Führungskräfte, 2. Auflage, Berlin 2008.	\N	\N	\N	\N	\N	f	6
865	153	1	Gómez, Jorge Marx	\N	\N	\N	\N	\N	f	7
866	153	1	Rautenstrauch, Claus	\N	\N	\N	\N	\N	f	8
867	153	1	Cissek, Peter: Einführung in Business Intelligence mit SAP Netweaver 7.0, Berlin 2008.	\N	\N	\N	\N	\N	f	9
868	153	1	Hahne, Michael: SAP Business Warehouse – Mehrdimensionale Datenmodellierung, Berlin 2005.	\N	\N	\N	\N	\N	f	10
869	153	1	Kimball, Ralph	\N	\N	\N	\N	\N	f	11
870	153	1	u. a.: The Data Warehouse Lifecycle Toolkit, Expert Methods for Designing, Developing, and Deploying Data Warehouses, New York 1998.	\N	\N	\N	\N	\N	f	12
871	153	1	Lehner, Wolfgang: Datenbanktechnologien für Data- Warehouse-Systeme: Konzepte und Methoden, Heidelberg 2003.	\N	\N	\N	\N	\N	f	13
872	153	1	Lusti, Markus: Data Warehousing und Data Mining – Eine Einführung in entscheidungsunterstützende Systeme, Berlin 2002.	\N	\N	\N	\N	\N	f	14
873	153	1	u. a.: Big Data, Related Technologies, Challenges and Future Prospects, Heidelberg 2014.	\N	\N	\N	\N	\N	f	16
874	153	1	Plattner, H., Zeier, A.: In-Memory Data Management, Ein Wendepunkt für Unternehmensanwendungen, Heidelberg 2012.	\N	\N	\N	\N	\N	f	17
875	153	1	Wolf, F. K.	\N	\N	\N	\N	\N	f	18
876	153	1	Yamad, S.: Datenmodellierung in SAP Netweaver BW, Bonn 2010.	\N	\N	\N	\N	\N	f	19
877	153	1	Ausgesuchte Literatur zum Stand der Entwicklung.	\N	\N	\N	\N	\N	f	20
890	154	1	Kuzbari, Rafic	\N	\N	\N	\N	\N	f	2
891	154	1	Ammer, Reinhard: Der wissenschaftliche Vortrag. Springer-Verlag Wien New York, 2006, 166 Seiten, ISBN: 978-3211235256	\N	\N	\N	\N	\N	f	3
892	154	1	Leopold-Wildburger, Ulrike: Verfassen und Vortragen - Wissenschaftliche Arbeiten und Vorträge leicht gemacht. 2. Auflage, Springer, 2010. ISBN: 978-3642134197	\N	\N	\N	\N	\N	f	4
893	155	1	Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.	\N	\N	\N	\N	\N	f	3
894	155	1	Projektspezifisch	\N	\N	\N	\N	\N	f	4
897	156	1	Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.	\N	\N	\N	\N	\N	f	3
898	156	1	weitere themenspezifische Literatur	\N	\N	\N	\N	\N	f	4
899	157	1	Kern, S.: Richtlinien zur Erstellung von Bachelor- und Masterarbeiten, Moodle-Prof. Kern, 2016.	\N	\N	\N	\N	\N	f	3
900	157	1	Themenspezifische Primärliteratur aus der aktuellen Forschung	\N	\N	\N	\N	\N	f	4
909	129	1	Neckel, P./Knobloch, B.: Customer Relationship Analytics. Praktische Anwendung des Data Mining im CRM. 2. Aufl., Heidelberg 2015. Sekundärliteratur: Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 25 - Wirtschaftsinformatik (Master) – PO2023 Modulkatalog	\N	\N	\N	\N	\N	f	7
935	122	1	H. Blumberg, N. Pohlmann: "Der IT- Sicherheitsleitfaden“, 2. aktualisierte und erweiterte Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 38 - Wirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Informatik Auflage, ISBN-10: 3-8266-1635-9	\N	\N	\N	\N	\N	t	3
961	158	1	Basisliteratur für a) Management und Unternehmensfühung:	\N	\N	\N	\N	\N	f	1
962	158	1	Eckert, W., & Ellenrieder, P. (2013). Marktforschung: methodische Grundlagen und praktische Anwendung. Springer-Verlag.	\N	\N	\N	\N	\N	f	2
963	158	1	Komlos, J. & Süssmuth, B. (2010). Empirische Ökonomie. Berlin: Springer.	\N	\N	\N	\N	\N	f	3
964	158	1	Domschke, W.	\N	\N	\N	\N	\N	f	4
965	158	1	Klein, R., Scholl, A. (2015). Einführung in Operations Research. Berlin: Springer.	\N	\N	\N	\N	\N	f	6
966	158	1	Malik, F. (2013). Management: Das A und O des Handwerks (Management: Komplexität meistern. Frankfurt & New York: Campus.	\N	\N	\N	\N	\N	f	7
967	158	1	Malik, F. (2014). Führen Leisten Leben: Wirksames Management für eine neue Welt. Campus Verlag.	\N	\N	\N	\N	\N	f	8
968	158	1	Stair, R.M. & Hanna, M.E. (2012). Quantitative Analysis for Management. Pearson Prentice Hall.	\N	\N	\N	\N	\N	f	10
969	158	1	Thommen, J.-P.	\N	\N	\N	\N	\N	f	11
970	158	1	Achleitner, A.-K.	\N	\N	\N	\N	\N	f	12
971	158	1	Gilbert, D.U.	\N	\N	\N	\N	\N	f	13
972	158	1	Hachmeister, D.	\N	\N	\N	\N	\N	f	14
973	158	1	Kaiser, G. (2017). Allgemeine Betriebswirtschaftslehre. Umfassende Einführung aus managementorientierter Sicht. Wiesbaden: Springer Gabler. b) Content-Marketing	\N	\N	\N	\N	\N	f	15
974	158	1	Baetzgen, Andreas & Tropp, Jörg (Hg.)(2013). Brand Content. Die Marke als Medienereignis. Stuttgart: Schaeffer-Poeschl.	\N	\N	\N	\N	\N	f	16
975	158	1	Herbst, Dieter Georg (2014). Storytelling (3. Aufl.). Konstanz: UVK52 8 Modul „“	\N	\N	\N	\N	\N	f	17
976	158	1	Hohlfeld, Ralf	\N	\N	\N	\N	\N	f	18
977	158	1	Müller, Philipp	\N	\N	\N	\N	\N	f	19
978	158	1	Richter, Annekathrin & Zacher, Franziska (Hg.)(2013). Crossmedia – Wer bleibt auf der Strecke? Beiträge aus Wissenschaft und Praxis (2. Aufl.). Münster: Lit.	\N	\N	\N	\N	\N	f	20
979	158	1	Jakubetz, Christian (2011). Crossmedia (2. Aufl.). Konstanz: UVK.	\N	\N	\N	\N	\N	f	21
980	158	1	Lieb, Rebecca (2011). Content Marketing: Think Like a Publisher – How to Use Content to Westfälische Hochschule Fachbereich Informatik und Kommunikation MODULHANDBUCH - 52 - Wirtschaftsinformatik (Master) – PO2023 Wahlpflichtkatalog Wirtschaft Market Online and in Social Media. Indianapolis: Que.	\N	\N	\N	\N	\N	t	22
981	158	1	Löffler, Miriam (2014). Think Content! Content- Strategie, Content-Marketing, Texten furs Web, Bonn: Galileo Computing.	\N	\N	\N	\N	\N	f	23
982	158	1	Schneider, Martin (Hg.)(2013). Management von Medienunternehmen: Digitale Innovationen – crossmediale Strategien. Wiesbaden: Springer Gabler.	\N	\N	\N	\N	\N	f	24
983	158	1	Wirtz, Bernd W. (2013). Medien- und Internetmanagement (8. Aufl.). Wiesbaden: Springer Gabler.	\N	\N	\N	\N	\N	f	25
984	158	1	Wirtz, Bernd W. (2013). Übungsbuch Medien- und Internetmanagement: Fallstudien – Aufgaben – Lösungen. Wiesbaden: Springer Gabler.	\N	\N	\N	\N	\N	f	26
985	159	1	Anleitungen und Einführung zum Planspiel (TopSim o.ä.)	\N	\N	\N	\N	\N	f	2
986	159	1	Rahn, H.-J.: Einführung in die Betriebswirtschaftslehre, 11. Auflage, Herne 2013.	\N	\N	\N	\N	\N	f	4
987	159	1	Wöhe, Günter	\N	\N	\N	\N	\N	f	5
988	159	1	Döhring, Ulrich: Einführung in die Allgemeine Betriebswirtschaftslehre, 27. Auflage, München 2020.	\N	\N	\N	\N	\N	f	6
\.


--
-- Data for Name: modul_pruefung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_pruefung (modul_id, po_id, pruefungsform, pruefungsdauer_minuten, pruefungsleistungen, benotung) FROM stdin;
67	1	Klausur und/oder schriftliche Ausarbeitung und/oder\nmündliche Prüfung	\N	Klausur und/oder schriftliche Ausarbeitung und/oder	\N
68	1	Klausur und/oder schriftliche Ausarbeitung und/oder\nmündliche Prüfung	\N	Klausur und/oder schriftliche Ausarbeitung und/oder	\N
57	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: keine\nPrüfungsleistu	\N	Studienleistungen laut Prüfungsordnung als	\N
71	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
72	1	Studienleistungen: Erfolgreich absolviertes Praktikum\nals Vorleistung für die Prüfungszulassung\nPrüf	90	Studienleistungen: Erfolgreich absolviertes Praktikum	\N
73	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	60	Studienleistungen laut Prüfungsordnung als	\N
58	1	Siehe § 26 der Bachelor-Rahmenprüfungsordnung und\n§ 19 der Studiengangsprüfungsordnung	\N	Siehe § 26 der Bachelor-Rahmenprüfungsordnung und	\N
74	1	Klausur	\N	Klausur	\N
75	1	Klausur oder mündliche Prüfung	\N	Klausur oder mündliche Prüfung	\N
76	1	Klausur oder Kombinationsprüfung	\N	Klausur oder Kombinationsprüfung	\N
77	1	Studienleistungen: Die Studierenden können während\ndes Praktikums Bonuspunkte für die Klausur erwerb	\N	Studienleistungen: Die Studierenden können während	\N
78	1	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder\nKlausur (90 Min.) je nach Teilnehmerzahl (>12 K	30	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder	\N
88	1	Prüfungsleistungen:\nSchriftliche Prüfung oder mündliche Prüfung oder\nKombinationsprüfung (55% Klausu	60	Prüfungsleistungen:	\N
79	1	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder\nKlausur (90 Min.) je nach Teilnehmerzahl (>12 K	30	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder	\N
89	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine;\nPrüfungsleist	\N	Studienleistungen laut Prüfungsordnung als	\N
90	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine;\nPrüfungsleist	\N	Studienleistungen laut Prüfungsordnung als	\N
80	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
81	1	Studienleistungen: Die Studierenden können während\ndes Praktikums Bonuspunkte für die Klausur erwerb	\N	Studienleistungen: Die Studierenden können während	\N
59	1	Studienleistungen: Die Studierenden können während\ndes Praktikums Bonuspunkte für die Klausur erwerb	\N	Studienleistungen: Die Studierenden können während	\N
60	1	Kombinationsprüfung: Zum Bestehen des Moduls\nmüssen das unbenotete Testat sowie das Projekt\nbestande	\N	Kombinationsprüfung: Zum Bestehen des Moduls	\N
82	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	60	Studienleistungen laut Prüfungsordnung als	\N
61	1	Prüfungsleistungen: Klausur (120 Min.)	120	Prüfungsleistungen: Klausur (120 Min.)	\N
62	1	Studienleistungen: Die Studierenden können während\ndes Praktikums Bonuspunkte für die Klausur erwerb	\N	Studienleistungen: Die Studierenden können während	\N
63	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
114	1	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)\nbeispielsweise Kombination aus Projekt und\nPräsent	\N	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)	\N
98	1	Mündliche Prüfung (30 Min.) oder\nPrüfungsleistungen: Klausur (90 Min.) je nach Teilnehmerzahl (>12 K	30	Mündliche Prüfung (30 Min.) oder	\N
99	1	Literatur: • B. Cyganek, J.P. Siebert: „An Introduction to\n3DComputer Vision Techniques and Algorith	\N	Literatur: • B. Cyganek, J.P. Siebert: „An Introduction to	\N
100	1	Klausur oder mündliche Prüfung	\N	Klausur oder mündliche Prüfung	\N
115	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	\N	Studienleistungen laut Prüfungsordnung als	\N
101	1	Klausur und/oder mündliche Prüfung und/oder\nschriftliche Ausarbeitung	\N	Klausur und/oder mündliche Prüfung und/oder	\N
116	1	Anwesenheitspflicht nach Prüfungsordnung\nPrüfungsleistung: Ausarbeitung der geforderten\nProjektergeb	\N	Anwesenheitspflicht nach Prüfungsordnung	\N
117	1	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)\nbeispielsweise Kombination aus Präsentation und\nsc	\N	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)	\N
118	1	Prüfungsleistungen: Kombinationsprüfung aus\n2 Teilleistungen\n▪ Präsentationen (50%)\n▪ Schriftliche A	\N	Prüfungsleistungen: Kombinationsprüfung aus	\N
102	1	Mündliche Prüfung (final), Vortrag, Ausarbeitung (auch\nCodeartefakte)	\N	Mündliche Prüfung (final), Vortrag, Ausarbeitung (auch	\N
103	1	Prüfungsleistungen: Klausur (90 Min.)\nWestfälische Hochschule\nFachbereich Informatik und Kommunikati	90	Prüfungsleistungen: Klausur (90 Min.)	\N
104	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
119	1	Kombinationsprüfung (§ 12 PO).\nBeispielsweise:\n• K1: Klausur oder mündliche Prüfung\n• K2: Ausarbeitu	\N	Kombinationsprüfung (§ 12 PO).	\N
91	1	Anwesenheitspflicht nach Prüfungsordnung\nPrüfungsleistungen: Vortrag mit Ausarbeitung und\nmündliche 	\N	Anwesenheitspflicht nach Prüfungsordnung	\N
120	1	Kombinationsprüfung (§ 12 PO)\nbeispielsweise Kombination aus Projekt und\nPräsentation	\N	Kombinationsprüfung (§ 12 PO)	\N
105	1	Klausur	\N	Klausur	\N
121	1	Studienleistungen: Erfolgreich absolviertes Praktikum\nals Vorleistung für die Prüfungszulassung\nPrüf	90	Studienleistungen: Erfolgreich absolviertes Praktikum	\N
122	1	Studienleistungen: Erfolgreich absolviertes Praktikum\nals Vorleistung für die Prüfungszulassung\nPrüf	90	Studienleistungen: Erfolgreich absolviertes Praktikum	\N
123	1	Kombinationsprüfung	\N	Kombinationsprüfung	\N
92	1	Siehe § 16 PO und § 26 MRPO	\N	Siehe § 16 PO und § 26 MRPO	\N
106	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
93	1	Siehe § 24 und § 25 der Master-\nRahmenprüfungsordnung und § 14 und § 15 der\nStudiengangsprüfungsordn	\N	Siehe § 24 und § 25 der Master-	\N
107	1	Course achievement: oral presentation including a\ndocumentation, software and its related documentat	60	Course achievement: oral presentation including a	\N
7	1	Kombinationsprüfung, beispielsweise wie folgt\naufgebaut:\n- K1: Klausur\n- K2: Ausarbeitung: Abgabe de	\N	Kombinationsprüfung, beispielsweise wie folgt	\N
8	1	Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)	\N	Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)	\N
9	1	Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)	\N	Prüfungsleistungen: Kombinationsprüfung (§ 14 PO)	\N
10	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
11	1	Siehe § 19 Prüfungsordnung	\N	Siehe § 19 Prüfungsordnung	\N
16	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
1	1	Klausur (75 Min)	75	Klausur (75 Min)	\N
3	1	Siehe § 18 der Prüfungsordnung	\N	Siehe § 18 der Prüfungsordnung	\N
2	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
4	1	Kombinationsprüfung	\N	Kombinationsprüfung	\N
17	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
20	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
21	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
22	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
23	1	Kombinationsprüfung, beispielsweise:\n- K1: Klausur\n- K2: Ausarbeitung: Abgabe der Lösungen\nsemesterb	\N	Kombinationsprüfung, beispielsweise:	\N
24	1	Kombinationsprüfung (§ 14 PO)	\N	Kombinationsprüfung (§ 14 PO)	\N
26	1	Prüfungsleistungen: Klausur (120 Min.)	120	Prüfungsleistungen: Klausur (120 Min.)	\N
55	1	Siehe § 24 und § 25 BRPO und siehe § 18 PO	\N	Siehe § 24 und § 25 BRPO und siehe § 18 PO	\N
56	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: keine\nPrüfungsleistu	\N	Studienleistungen laut Prüfungsordnung als	\N
64	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: keine\nPrüfungsleistu	\N	Studienleistungen laut Prüfungsordnung als	\N
83	1	Prüfungsleistungen: Klausur (90 Min.)	90	Prüfungsleistungen: Klausur (90 Min.)	\N
65	1	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder\nKlausur (90 Min.) je nach Teilnehmerzahl (>12 K	30	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder	\N
84	1	Studienleistungen lauf Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine;\nPrüfungsleist	\N	Studienleistungen lauf Prüfungsordnung als	\N
66	1	Klausur (75min)	75	Klausur (75min)	\N
85	1	Prüfungsleistungen: Klausur (90 Min.)	90	Prüfungsleistungen: Klausur (90 Min.)	\N
5	1	Prüfungsleistung: Klausur (75min)	75	Prüfungsleistung: Klausur (75min)	\N
6	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
12	1	Klausur (75 Min.)	75	Klausur (75 Min.)	\N
13	1	Klausur, mündliche Prüfung oder Kombinationsprüfung	\N	Klausur, mündliche Prüfung oder Kombinationsprüfung	\N
14	1	Studienleistungen: Die Studierenden können während\ndes Semesters Bonuspunkte für die Klausur erwerbe	90	Studienleistungen: Die Studierenden können während	\N
15	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	120	Studienleistungen laut Prüfungsordnung als	\N
18	1	siehe § 11 Bachelor-RahmenPO	\N	siehe § 11 Bachelor-RahmenPO	\N
19	1	Studienleistungen: Die Studierenden können während\ndes Semesters Bonuspunkte für die Klausur erwerbe	60	Studienleistungen: Die Studierenden können während	\N
25	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	60	Studienleistungen laut Prüfungsordnung als	\N
69	1	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder\nKlausur (90 Min.) je nach Teilnehmerzahl (>12 K	30	Prüfungsleistungen: Mündliche Prüfung (30 Min.) oder	\N
86	1	Prüfungsleistungen: Klausur (90 Min.)	90	Prüfungsleistungen: Klausur (90 Min.)	\N
87	1	Studienleistungen lauf Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine;\nPrüfungsleist	\N	Studienleistungen lauf Prüfungsordnung als	\N
70	1	Studienleistungen: Erfolgreich absolviertes Praktikum\nals Vorleistung für die Prüfungszulassung\nPrüf	90	Studienleistungen: Erfolgreich absolviertes Praktikum	\N
129	1	Kombinationsprüfung	\N	Kombinationsprüfung	\N
108	1	Studienleistungen: Die Studierenden können während\ndes Praktikums Bonuspunkte für die Klausur erwerb	\N	Studienleistungen: Die Studierenden können während	\N
124	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	\N	Studienleistungen laut Prüfungsordnung als	\N
109	1	Klausur und/oder mündliche Prüfung und/oder\nschriftliche Ausarbeitung	\N	Klausur und/oder mündliche Prüfung und/oder	\N
94	1	Prüfungsleistungen: Ausarbeitung in Form einer\nentwickelten Software, Ausarbeitungen und\nPräsentatio	\N	Prüfungsleistungen: Ausarbeitung in Form einer	\N
95	1	Anwesenheitspflicht nach Prüfungsordnung.\nWestfälische Hochschule\nFachbereich Informatik und Kommuni	\N	Anwesenheitspflicht nach Prüfungsordnung.	\N
110	1	Prüfungsleistung: Klausur (75min)\nWestfälische Hochschule\nFachbereich Informatik und Kommunikation M	75	Prüfungsleistung: Klausur (75min)	\N
125	1	Kombinationsprüfung (§ 12 PO)\nbeispielsweise Kombination aus Projekt und\nPräsentation	\N	Kombinationsprüfung (§ 12 PO)	\N
126	1	Prüfungsleistungen:\nSchriftliche Prüfung oder mündliche Prüfung oder\nKombinationsprüfung (50% Klausu	60	Prüfungsleistungen:	\N
96	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	\N	Studienleistungen laut Prüfungsordnung als	\N
127	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
111	1	Mündliche Prüfung (30 Min.) oder\nPrüfungsleistungen: Klausur (90 Min.) je nach Teilnehmerzahl (>12 K	30	Mündliche Prüfung (30 Min.) oder	\N
128	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	90	Studienleistungen laut Prüfungsordnung als	\N
112	1	Course achievement: oral presentation including a\ndocumentation, software and its related documentat	60	Course achievement: oral presentation including a	\N
130	1	Kombinationsprüfung (§ 12 PO), beispielsweise:\n• K1: Klausur oder mündliche Prüfung\n• K2: Ausarbeitu	\N	Kombinationsprüfung (§ 12 PO), beispielsweise:	\N
131	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine;\nPrüfungsleist	\N	Studienleistungen laut Prüfungsordnung als	\N
113	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: erfolgreiche\nTeilnah	\N	Studienleistungen laut Prüfungsordnung als	\N
97	1	Prüfungsleistung: Je nach Projekt Ausarbeitung in Form\neiner entwickelten Software und/oder Ausarbei	\N	Prüfungsleistung: Je nach Projekt Ausarbeitung in Form	\N
132	1	Kombinationsprüfung (§ 12 PO)	\N	Kombinationsprüfung (§ 12 PO)	\N
133	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	\N	Studienleistungen laut Prüfungsordnung als	\N
134	1	Benotung des Vortrages und der anschließenden\nDiskussion und Fragen durch die Prüfer laut\nPrüfungsor	\N	Benotung des Vortrages und der anschließenden	\N
135	1	In der Prüfungsordnung geregelt	\N	In der Prüfungsordnung geregelt	\N
136	1	Prüfungsleistung: Ausarbeitung der geforderten\nProjektergebnisse und Präsentationen	\N	Prüfungsleistung: Ausarbeitung der geforderten	\N
137	1	Prüfungsleistung: Ausarbeitung der geforderten\nProjektergebnisse und Präsentationen	\N	Prüfungsleistung: Ausarbeitung der geforderten	\N
138	1	In der Prüfungsordnung geregelt	\N	In der Prüfungsordnung geregelt	\N
139	1	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)\nbeispielsweise Kombination aus Projekt und\nPräsent	\N	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)	\N
140	1	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)\nbeispielsweise Kombination aus Projekt und\nPräsent	\N	Prüfungsleistungen: Kombinationsprüfung (§ 12 PO)	\N
141	1	Siehe § 16 Studiengangsprüfungsordnung	\N	Siehe § 16 Studiengangsprüfungsordnung	\N
142	1	Siehe § 14 PO und § 25 MRPO	\N	Siehe § 14 PO und § 25 MRPO	\N
143	1	Kombinationsprüfung	\N	Kombinationsprüfung	\N
144	1	Kombinationsprüfung. Beispielsweise Präsentation und\nschriftliche Ausarbeitung	\N	Kombinationsprüfung. Beispielsweise Präsentation und	\N
145	1	Kombinationsprüfung (§ 12 PO)\nbeispielsweise Kombination aus Projekt und\nPräsentation und schriftlic	\N	Kombinationsprüfung (§ 12 PO)	\N
146	1	Siehe § 24 und § 25 der Bachelor-\nRahmenprüfungsordnung	\N	Siehe § 24 und § 25 der Bachelor-	\N
147	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine\nPrüfungsleistu	60	Studienleistungen laut Prüfungsordnung als	\N
148	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine;\nPrüfungsleist	\N	Studienleistungen laut Prüfungsordnung als	\N
149	1	Siehe § 26 der Bachelor-Rahmenprüfungsordnung und\n§ 19 der Studiengangsprüfungsordnung	\N	Siehe § 26 der Bachelor-Rahmenprüfungsordnung und	\N
150	1	Studienleistungen laut Prüfungsordnung als\nVoraussetzung zur Prüfungsteilnahme: Keine;\nPrüfungsleist	\N	Studienleistungen laut Prüfungsordnung als	\N
151	1	Kombinationsprüfung: Zum Bestehen des Moduls\nmüssen das unbenotete Testat sowie das Projekt\nbestande	\N	Kombinationsprüfung: Zum Bestehen des Moduls	\N
152	1	Prüfungsleistungen: Klausur (120 Min.)	120	Prüfungsleistungen: Klausur (120 Min.)	\N
153	1	Studierende erhalten für die folgenden freiwillig zu\nerbringenden semesterbegleitenden Leistungen ei	90	Studierende erhalten für die folgenden freiwillig zu	\N
158	1	Seminararbeit (50.000 Zeichen) und Präsentation (ca.\n30 Minuten)	\N	Seminararbeit (50.000 Zeichen) und Präsentation (ca.	\N
154	1	Siehe § 26 der MRPO und § 16 der PO	\N	Siehe § 26 der MRPO und § 16 der PO	\N
156	1	Siehe § 24 und § 25 der Master-\nRahmenprüfungsordnung und § 14 und § 15 der\nStudiengangsprüfungsordn	\N	Siehe § 24 und § 25 der Master-	\N
155	1	Prüfungsleistungen: Ausarbeitung in Form einer\nentwickelten Software, Ausarbeitungen und\nPräsentatio	\N	Prüfungsleistungen: Ausarbeitung in Form einer	\N
157	1	Anwesenheitspflicht nach Prüfungsordnung\nPrüfungsleistungen: Ausarbeitung und Vortrag	\N	Anwesenheitspflicht nach Prüfungsordnung	\N
159	1	Die Teilnehmer der Veranstaltung sind verpflichtet am\nPlanspiel und den dafür erforderlichen Präsenz	\N	Die Teilnehmer der Veranstaltung sind verpflichtet am	\N
\.


--
-- Data for Name: modul_seiten; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_seiten (modul_id, po_id, modulhandbuch_id, seite_von, seite_bis) FROM stdin;
1	1	1	5	6
2	1	1	7	8
3	1	1	9	10
4	1	1	11	12
5	1	1	13	14
6	1	1	15	16
7	1	1	17	19
8	1	1	20	22
9	1	1	23	25
10	1	1	26	27
11	1	1	28	29
12	1	1	30	31
13	1	1	32	33
14	1	1	34	35
15	1	1	36	37
16	1	1	38	39
17	1	1	40	42
18	1	1	43	44
19	1	1	45	46
20	1	1	47	48
21	1	1	49	50
22	1	1	51	52
23	1	1	53	54
24	1	1	55	56
25	1	1	57	58
26	1	1	59	61
27	1	1	62	63
28	1	1	64	64
29	1	1	65	65
30	1	1	66	66
31	1	1	67	67
32	1	1	68	68
33	1	1	69	69
34	1	1	70	71
35	1	1	72	73
36	1	1	74	75
37	1	1	76	77
38	1	1	78	80
39	1	1	81	82
40	1	1	83	84
41	1	1	85	85
42	1	1	86	87
43	1	1	88	89
44	1	1	90	91
45	1	1	92	93
46	1	1	94	94
47	1	1	95	95
48	1	1	96	97
49	1	1	98	99
50	1	1	100	101
51	1	1	102	103
52	1	1	104	105
53	1	1	106	107
54	1	1	108	108
1	1	2	5	6
55	1	2	7	8
56	1	2	9	10
5	1	2	11	12
6	1	2	13	14
57	1	2	15	16
58	1	2	17	18
12	1	2	19	20
13	1	2	21	22
14	1	2	23	24
15	1	2	25	26
18	1	2	27	28
59	1	2	29	30
19	1	2	31	32
60	1	2	33	36
25	1	2	37	38
61	1	2	39	40
62	1	2	41	42
63	1	2	43	45
64	1	2	46	46
65	1	2	47	48
66	1	2	49	50
67	1	2	51	52
68	1	2	53	54
69	1	2	55	56
70	1	2	57	59
71	1	2	60	61
72	1	2	62	63
73	1	2	64	65
74	1	2	66	67
75	1	2	68	69
76	1	2	70	71
77	1	2	72	73
78	1	2	74	75
79	1	2	76	77
80	1	2	78	79
81	1	2	80	81
82	1	2	82	84
83	1	2	85	86
84	1	2	87	89
85	1	2	90	91
86	1	2	92	93
87	1	2	94	96
88	1	2	97	99
89	1	2	100	101
90	1	2	102	103
91	1	3	5	6
92	1	3	7	8
93	1	3	9	10
94	1	3	11	12
95	1	3	13	14
96	1	3	15	17
97	1	3	18	20
98	1	3	21	22
99	1	3	23	24
100	1	3	25	26
101	1	3	27	28
102	1	3	29	30
103	1	3	31	33
104	1	3	34	35
105	1	3	36	37
106	1	3	38	39
107	1	3	40	42
108	1	3	43	44
109	1	3	45	46
110	1	3	47	48
111	1	3	49	50
112	1	3	51	52
113	1	3	53	57
114	1	3	58	59
115	1	3	60	61
116	1	3	62	63
117	1	3	64	65
118	1	3	66	67
119	1	3	68	70
120	1	3	71	72
121	1	3	73	74
122	1	3	75	77
123	1	3	78	81
124	1	3	82	83
125	1	3	84	85
126	1	3	86	88
127	1	3	89	90
128	1	3	91	92
129	1	3	93	96
130	1	3	97	99
131	1	3	100	101
132	1	3	102	103
133	1	4	4	5
116	1	4	6	7
121	1	4	8	9
122	1	4	10	12
134	1	4	13	14
135	1	4	15	16
124	1	4	17	18
136	1	4	19	20
137	1	4	21	22
138	1	4	23	24
127	1	4	25	26
128	1	4	27	29
100	1	4	30	31
115	1	4	32	33
101	1	4	34	35
118	1	4	36	37
103	1	4	38	40
104	1	4	41	42
105	1	4	43	44
106	1	4	45	46
110	1	4	47	48
126	1	4	49	51
113	1	4	52	55
139	1	5	5	6
140	1	5	7	8
117	1	5	9	10
91	1	5	11	14
141	1	5	15	16
142	1	5	17	18
143	1	5	19	21
144	1	5	22	23
130	1	5	24	27
114	1	5	28	29
98	1	5	30	31
99	1	5	32	33
100	1	5	34	35
101	1	5	36	37
116	1	5	38	39
103	1	5	40	42
104	1	5	43	44
119	1	5	45	47
120	1	5	48	49
105	1	5	50	51
121	1	5	52	53
122	1	5	54	56
123	1	5	57	58
106	1	5	59	60
107	1	5	61	63
124	1	5	64	65
109	1	5	66	67
110	1	5	68	69
125	1	5	70	71
96	1	5	72	74
112	1	5	75	76
145	1	5	77	78
132	1	5	79	82
1	1	6	5	6
146	1	6	7	7
147	1	6	8	9
83	1	6	10	11
5	1	6	12	13
84	1	6	14	16
85	1	6	17	18
6	1	6	19	20
86	1	6	21	22
148	1	6	23	24
87	1	6	25	27
71	1	6	28	29
149	1	6	30	31
12	1	6	32	33
13	1	6	34	35
14	1	6	36	37
15	1	6	38	39
89	1	6	40	41
90	1	6	42	43
18	1	6	44	45
150	1	6	46	48
19	1	6	49	50
151	1	6	51	53
25	1	6	54	55
152	1	6	56	57
64	1	6	58	58
65	1	6	59	60
66	1	6	61	62
69	1	6	63	64
70	1	6	65	67
57	1	6	68	69
72	1	6	70	71
73	1	6	72	73
75	1	6	74	75
76	1	6	76	77
78	1	6	78	79
88	1	6	80	82
81	1	6	83	84
82	1	6	85	86
153	1	7	4	6
101	1	7	7	8
121	1	7	9	10
154	1	7	11	12
155	1	7	15	16
156	1	7	17	18
157	1	7	19	20
110	1	7	21	22
129	1	7	23	26
131	1	7	27	29
100	1	7	30	31
103	1	7	32	34
104	1	7	35	36
122	1	7	37	39
108	1	7	40	41
126	1	7	42	44
112	1	7	45	46
113	1	7	47	49
158	1	7	50	53
159	1	7	54	56
116	1	7	57	58
91	1	7	59	60
\.


--
-- Data for Name: modul_sprache; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_sprache (modul_id, po_id, sprache_id) FROM stdin;
1	1	1
5	1	1
6	1	1
12	1	1
15	1	1
18	1	1
24	1	1
25	1	1
26	1	2
34	1	1
38	1	1
39	1	1
55	1	1
56	1	1
57	1	1
58	1	1
60	1	1
61	1	2
63	1	1
64	1	1
65	1	1
66	1	1
70	1	1
72	1	1
73	1	1
74	1	1
75	1	1
76	1	1
80	1	1
82	1	1
84	1	1
85	1	1
86	1	1
87	1	1
89	1	1
96	1	1
100	1	1
104	1	1
105	1	1
106	1	1
110	1	1
113	1	1
115	1	1
116	1	1
121	1	1
122	1	1
124	1	1
127	1	1
128	1	1
129	1	1
133	1	1
134	1	1
135	1	1
136	1	1
137	1	1
138	1	1
146	1	1
149	1	1
151	1	1
152	1	2
158	1	1
\.


--
-- Data for Name: modul_studiengang; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_studiengang (id, modul_id, po_id, studiengang_id, semester, pflicht, wahlpflicht, modul_kategorie) FROM stdin;
4	2	1	1	4	t	f	pflicht
13	7	1	1	3	t	f	pflicht
16	10	1	1	4	t	f	pflicht
41	23	1	1	1	t	f	pflicht
46	26	1	1	2	t	f	pflicht
307	42	1	2	\N	f	t	\N
305	40	1	2	\N	f	t	\N
306	41	1	2	\N	f	t	\N
292	27	1	2	\N	f	t	\N
308	43	1	2	\N	f	t	\N
293	28	1	2	\N	f	t	\N
309	44	1	2	\N	f	t	\N
117	133	1	1	3	t	f	pflicht
310	45	1	2	\N	f	t	\N
316	51	1	2	\N	f	t	\N
294	29	1	2	\N	f	t	\N
311	46	1	2	\N	f	t	\N
304	39	1	2	\N	f	t	\N
295	30	1	2	\N	f	t	\N
312	47	1	2	\N	f	t	\N
296	31	1	2	\N	f	t	\N
313	48	1	2	\N	f	t	\N
297	32	1	2	\N	f	t	\N
314	49	1	2	\N	f	t	\N
298	33	1	2	\N	f	t	\N
299	34	1	2	\N	f	t	\N
315	50	1	2	\N	f	t	\N
300	35	1	2	\N	f	t	\N
301	36	1	2	\N	f	t	\N
317	52	1	2	\N	f	t	\N
302	37	1	2	\N	f	t	\N
318	53	1	2	\N	f	t	\N
319	54	1	2	\N	f	t	\N
303	38	1	2	\N	f	t	\N
80	60	1	2	5	t	f	projekt
5	3	1	1	6	t	f	thesis
6	4	1	1	3	f	t	projekt
14	8	1	1	5	t	f	projekt
15	9	1	1	4	t	f	projekt
17	11	1	1	6	t	f	thesis
30	16	1	1	5	t	f	projekt
31	17	1	1	4	t	f	projekt
38	20	1	1	5	t	f	projekt
39	21	1	1	4	t	f	projekt
40	22	1	1	2	t	f	projekt
42	24	1	1	1	t	f	projekt
257	114	1	6	\N	f	t	\N
241	98	1	6	\N	f	t	\N
242	99	1	6	\N	f	t	\N
243	100	1	6	\N	f	t	\N
258	115	1	6	\N	f	t	\N
244	101	1	6	\N	f	t	\N
259	116	1	6	\N	f	t	\N
260	117	1	6	\N	f	t	\N
261	118	1	6	\N	f	t	\N
245	102	1	6	\N	f	t	\N
246	103	1	6	\N	f	t	\N
247	104	1	6	\N	f	t	\N
262	119	1	6	\N	f	t	\N
234	91	1	6	\N	f	t	\N
263	120	1	6	\N	f	t	\N
248	105	1	6	\N	f	t	\N
264	121	1	6	\N	f	t	\N
265	122	1	6	\N	f	t	\N
266	123	1	6	\N	f	t	\N
235	92	1	6	\N	t	f	\N
249	106	1	6	\N	f	t	\N
155	146	1	1	6	t	f	thesis
133	139	1	1	2	f	t	projekt
134	140	1	1	1	f	t	projekt
170	149	1	1	6	t	f	thesis
127	137	1	1	3	t	f	pflicht
122	134	1	1	4	t	f	thesis
129	127	1	1	1	t	f	pflicht
130	128	1	1	1	t	f	pflicht
138	141	1	1	4	t	f	thesis
203	154	1	1	4	t	f	thesis
135	117	1	1	2	t	f	pflicht
123	135	1	1	4	t	f	thesis
206	156	1	1	4	t	f	thesis
139	142	1	1	4	t	f	thesis
125	136	1	1	1	t	f	projekt
142	144	1	1	3	t	f	pflicht
143	130	1	1	1	t	f	pflicht
140	143	1	1	2	t	f	projekt
205	155	1	1	3	t	f	projekt
128	138	1	1	3	f	t	projekt
236	93	1	6	\N	t	f	\N
250	107	1	6	\N	f	t	\N
251	108	1	6	\N	f	t	\N
156	147	1	1	3	t	f	pflicht
157	83	1	1	5	t	f	pflicht
267	124	1	6	\N	f	t	\N
252	109	1	6	\N	f	t	\N
237	94	1	6	\N	t	f	\N
161	84	1	1	5	t	f	pflicht
162	85	1	1	1	t	f	pflicht
238	95	1	6	\N	f	t	\N
253	110	1	6	\N	f	t	\N
268	125	1	6	\N	f	t	\N
166	86	1	1	4	t	f	pflicht
167	148	1	1	4	t	f	pflicht
168	87	1	1	1	t	f	pflicht
269	126	1	6	\N	f	t	\N
239	96	1	6	\N	f	t	\N
270	127	1	6	\N	f	t	\N
254	111	1	6	\N	f	t	\N
271	128	1	6	\N	f	t	\N
255	112	1	6	\N	f	t	\N
272	129	1	6	\N	f	t	\N
273	130	1	6	\N	f	t	\N
274	131	1	6	\N	f	t	\N
256	113	1	6	\N	f	t	\N
240	97	1	6	\N	f	t	\N
275	132	1	6	\N	f	t	\N
100	94	1	4	3	t	f	projekt
126	136	1	4	2	t	f	projekt
183	89	1	1	3	t	f	pflicht
184	90	1	1	2	t	f	pflicht
344	76	1	3	\N	f	t	\N
349	153	1	7	\N	f	t	\N
359	100	1	7	\N	f	t	\N
188	150	1	1	5	t	f	pflicht
350	101	1	7	\N	f	t	\N
369	116	1	7	\N	f	t	\N
360	103	1	7	\N	f	t	\N
192	151	1	1	4	t	f	pflicht
193	151	1	2	5	t	f	pflicht
361	104	1	7	\N	f	t	\N
367	158	1	7	\N	f	t	\N
370	91	1	7	\N	f	t	\N
197	152	1	1	2	t	f	pflicht
351	121	1	7	\N	f	t	\N
199	153	1	1	1	t	f	pflicht
362	122	1	7	\N	f	t	\N
352	154	1	7	\N	t	f	\N
354	156	1	7	\N	t	f	\N
363	108	1	7	\N	f	t	\N
353	155	1	7	\N	t	f	\N
355	157	1	7	\N	f	t	\N
207	157	1	1	3	t	f	pflicht
356	110	1	7	\N	f	t	\N
209	129	1	1	2	t	f	pflicht
210	131	1	1	1	t	f	pflicht
364	126	1	7	\N	f	t	\N
368	159	1	7	\N	f	t	\N
365	112	1	7	\N	f	t	\N
357	129	1	7	\N	f	t	\N
358	131	1	7	\N	f	t	\N
149	124	1	1	2	f	t	wahlpflicht
366	113	1	7	\N	f	t	\N
201	121	1	1	1	f	t	wahlpflicht
211	122	1	1	2	f	t	wahlpflicht
212	116	1	1	2	f	t	wahlpflicht
152	1	1	1	2	t	f	pflicht
153	1	1	2	2	t	f	pflicht
154	1	1	3	2	t	f	pflicht
277	3	1	2	6	t	f	\N
276	2	1	2	4	t	f	\N
278	4	1	2	3	t	f	\N
158	5	1	1	3	t	f	pflicht
159	5	1	2	3	t	f	pflicht
160	5	1	3	3	t	f	pflicht
163	6	1	1	1	t	f	pflicht
164	6	1	2	1	t	f	pflicht
165	6	1	3	1	t	f	pflicht
279	7	1	2	3	t	f	\N
280	8	1	2	5	t	f	\N
281	9	1	2	4	t	f	\N
282	10	1	2	4	t	f	\N
283	11	1	2	6	t	f	\N
171	12	1	1	1	t	f	pflicht
172	12	1	2	1	t	f	pflicht
173	12	1	3	1	t	f	pflicht
174	13	1	1	3	t	f	pflicht
175	13	1	2	3	t	f	pflicht
176	13	1	3	3	t	f	pflicht
177	14	1	1	1	t	f	pflicht
178	14	1	2	1	t	f	pflicht
179	14	1	3	1	t	f	pflicht
180	15	1	1	2	t	f	pflicht
181	15	1	2	2	t	f	pflicht
182	15	1	3	2	t	f	pflicht
284	16	1	2	5	t	f	\N
285	17	1	2	4	t	f	\N
185	18	1	1	6	t	f	pflicht
186	18	1	2	6	t	f	pflicht
187	18	1	3	6	t	f	pflicht
189	19	1	1	2	t	f	pflicht
190	19	1	2	2	t	f	pflicht
191	19	1	3	2	t	f	pflicht
286	20	1	2	5	t	f	\N
287	21	1	2	4	t	f	\N
288	22	1	2	2	t	f	\N
289	23	1	2	1	t	f	\N
290	24	1	2	1	t	f	\N
194	25	1	1	3	t	f	pflicht
195	25	1	2	3	t	f	pflicht
196	25	1	3	3	t	f	pflicht
291	26	1	2	2	t	f	\N
50	55	1	1	6	t	f	thesis
215	64	1	1	\N	f	t	\N
335	64	1	3	\N	f	t	\N
322	83	1	3	5	t	f	\N
51	56	1	1	2	t	f	pflicht
216	65	1	1	\N	f	t	\N
336	65	1	3	\N	f	t	\N
323	84	1	3	5	t	f	\N
217	66	1	1	\N	f	t	\N
337	66	1	3	\N	f	t	\N
218	67	1	1	\N	f	t	\N
324	85	1	3	1	t	f	\N
219	68	1	1	\N	f	t	\N
220	69	1	1	\N	f	t	\N
338	69	1	3	\N	f	t	\N
325	86	1	3	4	t	f	\N
327	87	1	3	1	t	f	\N
221	70	1	1	\N	f	t	\N
339	70	1	3	\N	f	t	\N
198	57	1	1	3	t	f	wahlpflicht
340	57	1	3	\N	f	t	\N
169	71	1	1	4	f	t	wahlpflicht
328	71	1	3	4	t	f	\N
222	72	1	1	\N	f	t	\N
341	72	1	3	\N	f	t	\N
223	73	1	1	\N	f	t	\N
342	73	1	3	\N	f	t	\N
59	58	1	1	6	t	f	thesis
224	74	1	1	\N	f	t	\N
225	75	1	1	\N	f	t	\N
343	75	1	3	\N	f	t	\N
226	76	1	1	\N	f	t	\N
227	77	1	1	\N	f	t	\N
228	78	1	1	\N	f	t	\N
345	78	1	3	\N	f	t	\N
233	88	1	1	\N	f	t	\N
346	88	1	3	\N	f	t	\N
229	79	1	1	\N	f	t	\N
330	89	1	3	3	t	f	\N
331	90	1	3	2	t	f	\N
230	80	1	1	\N	f	t	\N
231	81	1	1	\N	f	t	\N
347	81	1	3	\N	f	t	\N
75	59	1	1	3	t	f	pflicht
79	60	1	1	4	t	f	projekt
232	82	1	1	\N	f	t	\N
348	82	1	3	\N	f	t	\N
84	61	1	1	1	t	f	pflicht
85	62	1	1	1	t	f	pflicht
86	63	1	1	2	t	f	pflicht
378	114	1	4	\N	f	t	\N
424	98	1	1	\N	f	t	\N
379	98	1	4	\N	f	t	\N
425	99	1	1	\N	f	t	\N
380	99	1	4	\N	f	t	\N
426	100	1	1	\N	f	t	\N
381	100	1	4	\N	f	t	\N
413	100	1	5	\N	f	t	\N
427	100	1	3	\N	f	t	\N
414	115	1	5	\N	f	t	\N
200	101	1	1	1	f	t	wahlpflicht
382	101	1	4	\N	f	t	\N
415	101	1	5	\N	f	t	\N
428	101	1	3	1	t	f	\N
383	116	1	4	\N	f	t	\N
402	116	1	5	2	t	f	\N
429	116	1	3	\N	f	t	\N
373	117	1	4	2	t	f	\N
430	118	1	1	\N	f	t	\N
416	118	1	5	\N	f	t	\N
431	102	1	1	\N	f	t	\N
432	103	1	1	\N	f	t	\N
417	103	1	5	\N	f	t	\N
384	103	1	4	\N	f	t	\N
433	103	1	3	\N	f	t	\N
434	104	1	1	\N	f	t	\N
385	104	1	4	\N	f	t	\N
418	104	1	5	\N	f	t	\N
435	104	1	3	\N	f	t	\N
386	119	1	4	\N	f	t	\N
213	91	1	1	3	t	f	wahlpflicht
214	91	1	4	1	t	f	wahlpflicht
436	91	1	3	\N	f	t	\N
387	120	1	4	\N	f	t	\N
437	105	1	1	\N	f	t	\N
388	105	1	4	\N	f	t	\N
419	105	1	5	\N	f	t	\N
202	121	1	4	1	f	t	wahlpflicht
403	121	1	5	1	t	f	\N
438	121	1	3	1	t	f	\N
389	122	1	4	\N	f	t	\N
404	122	1	5	2	t	f	\N
439	122	1	3	\N	f	t	\N
390	123	1	4	\N	f	t	\N
97	92	1	1	4	t	f	thesis
440	106	1	1	\N	f	t	\N
391	106	1	4	\N	f	t	\N
420	106	1	5	\N	f	t	\N
98	93	1	1	4	t	f	thesis
441	107	1	1	\N	f	t	\N
392	107	1	4	\N	f	t	\N
442	108	1	1	\N	f	t	\N
393	124	1	4	\N	f	t	\N
407	124	1	5	2	t	f	\N
443	109	1	1	\N	f	t	\N
394	109	1	4	\N	f	t	\N
99	94	1	1	2	t	f	projekt
101	95	1	1	2	t	f	pflicht
208	110	1	1	1	f	t	wahlpflicht
395	110	1	4	\N	f	t	\N
421	110	1	5	\N	f	t	\N
444	110	1	3	1	t	f	\N
396	125	1	4	\N	f	t	\N
445	126	1	1	\N	f	t	\N
422	126	1	5	\N	f	t	\N
446	126	1	3	\N	f	t	\N
151	96	1	1	1	t	f	projekt
397	96	1	4	\N	f	t	\N
411	127	1	5	1	t	f	\N
447	111	1	1	\N	f	t	\N
412	128	1	5	1	t	f	\N
448	112	1	1	\N	f	t	\N
398	112	1	4	\N	f	t	\N
449	112	1	3	\N	f	t	\N
450	129	1	3	2	t	f	\N
377	130	1	4	1	t	f	\N
451	131	1	3	1	t	f	\N
452	113	1	1	\N	f	t	\N
423	113	1	5	\N	f	t	\N
453	113	1	3	\N	f	t	\N
103	97	1	1	3	t	f	pflicht
400	132	1	4	\N	f	t	\N
401	133	1	5	3	t	f	\N
405	134	1	5	4	t	f	\N
406	135	1	5	4	t	f	\N
408	136	1	5	1	t	f	\N
409	137	1	5	3	t	f	\N
410	138	1	5	3	t	f	\N
371	139	1	4	2	t	f	\N
372	140	1	4	1	t	f	\N
374	141	1	4	4	t	f	\N
375	142	1	4	4	t	f	\N
141	143	1	4	2	t	f	projekt
376	144	1	4	3	t	f	\N
399	145	1	4	\N	f	t	\N
320	146	1	3	6	t	f	\N
321	147	1	3	3	t	f	\N
326	148	1	3	4	t	f	\N
329	149	1	3	6	t	f	\N
332	150	1	3	5	t	f	\N
333	151	1	3	4	t	f	\N
334	152	1	3	2	t	f	\N
454	153	1	3	1	t	f	\N
455	158	1	3	\N	f	t	\N
456	154	1	3	4	t	f	\N
457	156	1	3	4	t	f	\N
458	155	1	3	2	t	f	\N
459	157	1	3	3	t	f	\N
460	159	1	3	\N	f	t	\N
\.


--
-- Data for Name: modul_voraussetzungen; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modul_voraussetzungen (modul_id, po_id, formal, empfohlen, inhaltlich) FROM stdin;
2	1		(Modulprüfungen):	
4	1		(Modulprüfungen):	
3	1	\N	(Modulprüfungen):	\N
7	1	\N	(Modulprüfungen):	\N
8	1	\N	(Modulprüfungen):	\N
9	1	\N	(Modulprüfungen):	\N
10	1	\N	(Modulprüfungen):	\N
11	1	\N	(Modulprüfungen):	\N
16	1	\N	(Modulprüfungen):	\N
17	1	\N	(Modulprüfungen):	\N
20	1	\N	(Modulprüfungen):	\N
21	1	\N	(Modulprüfungen):	\N
22	1	\N	(Modulprüfungen):	\N
23	1	\N	(Modulprüfungen):	\N
24	1	\N	(Modulprüfungen):	\N
26	1	\N	(Modulprüfungen):	\N
27	1	\N	(Modulprüfungen):	\N
28	1	\N	(Modulprüfungen):	\N
29	1	\N	(Modulprüfungen):	\N
30	1	\N	(Modulprüfungen):	\N
31	1	\N	(Modulprüfungen):	\N
32	1	\N	(Modulprüfungen):	\N
33	1	\N	(Modulprüfungen):	\N
34	1	\N	(Modulprüfungen):	\N
35	1	\N	(Modulprüfungen):	\N
36	1	\N	(Modulprüfungen):	\N
37	1	\N	(Modulprüfungen):	\N
38	1	\N	(Modulprüfungen):	\N
39	1	\N	(Modulprüfungen):	\N
40	1	\N	(Modulprüfungen):	\N
41	1	\N	(Modulprüfungen):	\N
42	1	\N	(Modulprüfungen):	\N
43	1	\N	(Modulprüfungen):	\N
44	1	\N	(Modulprüfungen):	\N
45	1	\N	(Modulprüfungen):	\N
46	1	\N	(Modulprüfungen):	\N
47	1	\N	(Modulprüfungen):	\N
48	1	\N	(Modulprüfungen):	\N
49	1	\N	(Modulprüfungen):	\N
50	1	\N	(Modulprüfungen):	\N
51	1	\N	(Modulprüfungen):	\N
52	1	\N	(Modulprüfungen):	\N
53	1	\N	(Modulprüfungen):	\N
54	1	\N	(Modulprüfungen):	\N
55	1	\N	(Modulprüfungen):	\N
56	1	\N	(Modulprüfungen):	\N
58	1	\N	(Modulprüfungen):	\N
59	1	\N	(Modulprüfungen):	\N
60	1	\N	(Modulprüfungen):	\N
61	1	\N	(Modulprüfungen):	\N
62	1	\N	(Modulprüfungen):	\N
63	1	\N	(Modulprüfungen):	\N
67	1	\N	(Modulprüfungen):	\N
68	1	\N	(Modulprüfungen):	\N
74	1	\N	(Modulprüfungen):	\N
77	1	\N	(Modulprüfungen):	\N
79	1	\N	(Modulprüfungen):	\N
80	1	\N	(Modulprüfungen):	\N
92	1	\N	(Modulprüfungen):	\N
93	1	\N	(Modulprüfungen):	\N
94	1	\N	(Modulprüfungen):	\N
95	1	\N	(Modulprüfungen):	\N
97	1	\N	(Modulprüfungen):	\N
102	1	\N	(Modulprüfungen):	\N
111	1	\N	(Modulprüfungen):	\N
1	1		(Modulprüfungen):	
133	1	\N	(Modulprüfungen):	\N
134	1	\N	(Modulprüfungen):	\N
135	1	\N	(Modulprüfungen):	\N
136	1	\N	(Modulprüfungen):	\N
137	1	\N	(Modulprüfungen):	\N
138	1	\N	(Modulprüfungen):	\N
127	1	\N	(Modulprüfungen):	\N
128	1	\N	(Modulprüfungen):	\N
115	1	\N	(Modulprüfungen):	\N
118	1	\N	(Modulprüfungen):	\N
139	1	\N	(Modulprüfungen):	\N
140	1	\N	(Modulprüfungen):	\N
117	1	\N	(Modulprüfungen):	\N
141	1	\N	(Modulprüfungen):	\N
142	1	\N	(Modulprüfungen):	\N
143	1	\N	(Modulprüfungen):	\N
144	1	\N	(Modulprüfungen):	\N
130	1	\N	(Modulprüfungen):	\N
114	1	\N	(Modulprüfungen):	\N
98	1	\N	(Modulprüfungen):	\N
99	1	\N	(Modulprüfungen):	\N
119	1	\N	(Modulprüfungen):	\N
120	1	\N	(Modulprüfungen):	\N
105	1	\N	(Modulprüfungen):	\N
123	1	\N	(Modulprüfungen):	\N
106	1	\N	(Modulprüfungen):	\N
107	1	\N	(Modulprüfungen):	\N
124	1	\N	(Modulprüfungen):	\N
109	1	\N	(Modulprüfungen):	\N
125	1	\N	(Modulprüfungen):	\N
96	1	\N	(Modulprüfungen):	\N
145	1	\N	(Modulprüfungen):	\N
132	1	\N	(Modulprüfungen):	\N
146	1	\N	(Modulprüfungen):	\N
147	1	\N	(Modulprüfungen):	\N
83	1	\N	(Modulprüfungen):	\N
5	1	\N	(Modulprüfungen):	\N
84	1	\N	(Modulprüfungen):	\N
85	1	\N	(Modulprüfungen):	\N
6	1	\N	(Modulprüfungen):	\N
86	1	\N	(Modulprüfungen):	\N
148	1	\N	(Modulprüfungen):	\N
87	1	\N	(Modulprüfungen):	\N
71	1	\N	(Modulprüfungen):	\N
149	1	\N	(Modulprüfungen):	\N
12	1	\N	(Modulprüfungen):	\N
13	1	\N	(Modulprüfungen):	\N
14	1	\N	(Modulprüfungen):	\N
15	1	\N	(Modulprüfungen):	\N
89	1	\N	(Modulprüfungen):	\N
90	1	\N	(Modulprüfungen):	\N
18	1	\N	(Modulprüfungen):	\N
150	1	\N	(Modulprüfungen):	\N
19	1	\N	(Modulprüfungen):	\N
151	1	\N	(Modulprüfungen):	\N
25	1	\N	(Modulprüfungen):	\N
152	1	\N	(Modulprüfungen):	\N
64	1	\N	(Modulprüfungen):	\N
65	1	\N	(Modulprüfungen):	\N
66	1	\N	(Modulprüfungen):	\N
69	1	\N	(Modulprüfungen):	\N
70	1	\N	(Modulprüfungen):	\N
57	1	\N	(Modulprüfungen):	\N
72	1	\N	(Modulprüfungen):	\N
73	1	\N	(Modulprüfungen):	\N
75	1	\N	(Modulprüfungen):	\N
76	1	\N	(Modulprüfungen):	\N
78	1	\N	(Modulprüfungen):	\N
88	1	\N	(Modulprüfungen):	\N
81	1	\N	(Modulprüfungen):	\N
82	1	\N	(Modulprüfungen):	\N
153	1	\N	(Modulprüfungen):	\N
101	1	\N	(Modulprüfungen):	\N
121	1	\N	(Modulprüfungen):	\N
154	1	\N	(Modulprüfungen):	\N
155	1	\N	(Modulprüfungen):	\N
156	1	\N	(Modulprüfungen):	\N
157	1	\N	(Modulprüfungen):	\N
110	1	\N	(Modulprüfungen):	\N
129	1	\N	(Modulprüfungen):	\N
131	1	\N	(Modulprüfungen):	\N
100	1	\N	(Modulprüfungen):	\N
103	1	\N	(Modulprüfungen):	\N
104	1	\N	(Modulprüfungen):	\N
122	1	\N	(Modulprüfungen):	\N
108	1	\N	(Modulprüfungen):	\N
126	1	\N	(Modulprüfungen):	\N
112	1	\N	(Modulprüfungen):	\N
113	1	\N	(Modulprüfungen):	\N
158	1	\N	(Modulprüfungen):	\N
159	1	\N	(Modulprüfungen):	\N
116	1	\N	(Modulprüfungen):	\N
91	1	\N	(Modulprüfungen):	\N
\.


--
-- Data for Name: modulhandbuch; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.modulhandbuch (id, dateiname, studiengang_id, po_id, version, anzahl_seiten, anzahl_module, import_datum, hash) FROM stdin;
1	MHB_2023_ID_BA.pdf	2	1	\N	\N	54	2025-10-09 15:29:11	22815c9a2fd6ba0ba8e4cc19956cb8ca94b7732980ce78055ae66d213742d253
2	MHB_2023_IN_BA.pdf	1	1	\N	\N	46	2025-10-09 15:29:15	e42773225482c2fda4f647d2da9756c5f0f313c3da755e77bcd48c2e43dc9fa4
3	MHB_2023_IN_MA.pdf	6	1	\N	\N	42	2025-10-09 15:29:20	1c2fddb2f7b469d678f7fe15b02cf2dd6400a69f3c50e45fd333457430ce6ead
4	MHB_2023_IS_MA.pdf	5	1	\N	\N	23	2025-10-09 15:29:22	39031000b18c6c06c92eca0b4d51ce425f4cebcc1c84d35a252dacda38fa492f
5	MHB_2023_MI_MA.pdf	8	1	\N	\N	33	2025-10-09 15:29:26	a28b0f55e94deb7211d30c7b468fe261fe71f61141b5650e4f620fc7c6830ee6
6	MHB_2023_WI_BA.pdf	3	1	\N	\N	39	2025-10-09 15:29:30	001cf2cc15f850628253c8d01202601ccb867a82f2e6fad8cf2bb883961000cb
7	MHB_2023_WI_MA.pdf	7	1	\N	\N	23	2025-10-09 15:29:33	e2781c88c2fd7a9012048c200112f021a748bda6ada950c1f6d8ce818e08eb84
\.


--
-- Data for Name: phase_submissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.phase_submissions (planungphase_id, professor_id, planung_id, eingereicht_am, status, freigegeben_am, freigegeben_von, abgelehnt_am, abgelehnt_von, abgelehnt_grund, id, created_at, updated_at) FROM stdin;
19	10	20	2026-02-02 01:38:55.893778	eingereicht	\N	\N	\N	\N	\N	23	2026-02-02 01:38:55.631082	2026-02-02 01:38:55.897788
\.


--
-- Data for Name: planungs_templates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.planungs_templates (id, benutzer_id, semester_typ, name, beschreibung, ist_aktiv, wunsch_freie_tage, anmerkungen, raumbedarf, created_at, updated_at) FROM stdin;
1	39	winter	test	\N	t	\N	\N	\N	2026-01-21 07:40:08.348335	2026-01-21 07:40:08.37789
2	10	winter	winter	\N	t	\N	\N	\N	2026-02-01 13:48:18.839424	2026-02-01 13:48:18.93445
\.


--
-- Data for Name: planungsphasen; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.planungsphasen (semester_id, name, startdatum, enddatum, ist_aktiv, geschlossen_am, geschlossen_von, geschlossen_grund, semester_typ, semester_jahr, anzahl_einreichungen, anzahl_genehmigt, anzahl_abgelehnt, id, created_at, updated_at) FROM stdin;
2	Wintersemester 2026/2027 - Planungsphase	2026-02-02 02:36:13.609	2026-02-03 00:00:00	t	\N	\N	\N	wintersemester	2026	1	0	0	19	2026-02-02 01:36:19.486644	2026-02-02 01:38:55.624381
\.


--
-- Data for Name: pruefungsordnung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pruefungsordnung (id, po_jahr, gueltig_von, gueltig_bis, beschreibung, created_at, updated_at) FROM stdin;
1	PO2023	2023-10-01	\N	\N	2025-10-09 15:29:06	2025-10-09 15:29:06
\.


--
-- Data for Name: rolle; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rolle (id, name, beschreibung, created_at) FROM stdin;
1	dekan	Dekan - Vollzugriff	2025-10-15 14:45:51
2	professor	Professor - Eigene Planung + Module	2025-10-15 14:45:51
3	lehrbeauftragter	Lehrbeauftragter - Eigene Planung	2025-10-15 14:45:51
\.


--
-- Data for Name: semester; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.semester (id, bezeichnung, kuerzel, start_datum, ende_datum, vorlesungsbeginn, vorlesungsende, ist_aktiv, ist_planungsphase, created_at) FROM stdin;
1	Wintersemester 2025/2026	WS2025	2025-10-01	2026-03-31	2025-10-15	2026-02-15	t	f	2025-10-15 14:45:51
2	Wintersemester 2026/2027	WS2026	2026-10-01	2027-03-31	\N	\N	t	t	2026-01-22 19:28:01.036153
\.


--
-- Data for Name: semester_auftrag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.semester_auftrag (id, semester_id, auftrag_id, dozent_id, sws, status, beantragt_von, genehmigt_von, genehmigt_am, anmerkung, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: semesterplanung; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.semesterplanung (id, semester_id, benutzer_id, planungsphase_id, status, anmerkungen, raumbedarf, room_requirements, special_requests, gesamt_sws, eingereicht_am, freigegeben_von, freigegeben_am, abgelehnt_am, ablehnungsgrund, created_at, updated_at) FROM stdin;
20	2	10	19	eingereicht	\N	\N	\N	\N	4	2026-02-02 01:38:55.560779	\N	\N	\N	\N	2026-02-02 01:38:42.608362	2026-02-02 01:38:55.562787
\.


--
-- Data for Name: sprache; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sprache (id, bezeichnung, iso_code) FROM stdin;
1	Deutsch	de
2	Englisch	en
3	Deutsch/Englisch	de-en
\.


--
-- Data for Name: studiengang; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.studiengang (id, kuerzel, bezeichnung, abschluss, fachbereich, regelstudienzeit, ects_gesamt, aktiv, created_at) FROM stdin;
1	IN	Informatik	Bachelor	Informatik und Kommunikation	7	210	t	2025-10-09 15:29:06
2	ID	Informatik.Dual	Bachelor	Informatik und Kommunikation	7	210	t	2025-10-09 15:29:06
3	WI	Wirtschaftsinformatik	Bachelor	Informatik und Kommunikation	7	210	t	2025-10-09 15:29:06
5	IS	Internet-Sicherheit	Master	Informatik und Kommunikation	4	120	t	2025-10-09 15:29:06
4	MI	Medieninformatik	Master	Informatik und Kommunikation	4	120	t	2025-10-09 15:29:06
6	IN_MA	Informatik	Master	Informatik und Kommunikation	4	120	t	2026-01-27 18:22:52.999272
7	WI_MA	Wirtschaftsinformatik	Master	Informatik und Kommunikation	4	120	t	2026-01-27 18:22:53.006246
\.


--
-- Data for Name: template_module; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.template_module (id, template_id, modul_id, po_id, anzahl_vorlesungen, anzahl_uebungen, anzahl_praktika, anzahl_seminare, mitarbeiter_ids, anmerkungen, raumbedarf, raum_vorlesung, raum_uebung, raum_praktikum, raum_seminar, kapazitaet_vorlesung, kapazitaet_uebung, kapazitaet_praktikum, kapazitaet_seminar, created_at) FROM stdin;
1	1	89	1	1	0	1	0	\N	\N	\N	\N	\N	\N	\N	30	20	15	20	2026-01-21 08:29:01.116058
2	1	90	1	1	1	0	0	\N	\N	\N	\N	\N	\N	\N	30	20	15	20	2026-01-21 09:04:45.207599
3	2	1	1	1	1	0	0	[27]	\N	\N	\N	\N	\N	\N	30	20	15	20	2026-02-01 13:48:41.651452
\.


--
-- Data for Name: wunsch_freie_tage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wunsch_freie_tage (id, semesterplanung_id, wochentag, zeitraum, prioritaet, bemerkung, grund) FROM stdin;
\.


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

\unrestrict EMb6YYzpO75uASwOrIDNA6ejgasuGU7w1cohKLapX0nf9aNsRJP7sLgXvcP2Quj

