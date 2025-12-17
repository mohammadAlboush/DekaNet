-- ============================================
-- PLANUNGSPHASEN SYSTEM - DATABASE SCHEMA
-- ============================================
-- Professionelle Implementierung für Planungsphasen-Verwaltung
-- Version: 1.0.0
-- ============================================

-- 1. Planungsphasen Tabelle
CREATE TABLE IF NOT EXISTS planungsphasen (
    id SERIAL PRIMARY KEY,
    semester_id INTEGER NOT NULL REFERENCES semester(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    startdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    enddatum TIMESTAMP NULL, -- Optional: Deadline für Einreichungen
    ist_aktiv BOOLEAN NOT NULL DEFAULT true,
    geschlossen_am TIMESTAMP NULL,
    geschlossen_von INTEGER NULL REFERENCES users(id),
    geschlossen_grund TEXT NULL,

    -- Statistiken (werden automatisch aktualisiert)
    anzahl_einreichungen INTEGER NOT NULL DEFAULT 0,
    anzahl_genehmigt INTEGER NOT NULL DEFAULT 0,
    anzahl_abgelehnt INTEGER NOT NULL DEFAULT 0,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT chk_dates CHECK (enddatum IS NULL OR enddatum > startdatum),
    CONSTRAINT chk_aktiv_unique UNIQUE (semester_id, ist_aktiv) -- Nur eine aktive Phase pro Semester
);

-- Index für Performance
CREATE INDEX idx_planungsphasen_aktiv ON planungsphasen(ist_aktiv) WHERE ist_aktiv = true;
CREATE INDEX idx_planungsphasen_semester ON planungsphasen(semester_id);

-- 2. Submission Tracking Tabelle
CREATE TABLE IF NOT EXISTS phase_submissions (
    id SERIAL PRIMARY KEY,
    planungphase_id INTEGER NOT NULL REFERENCES planungsphasen(id) ON DELETE CASCADE,
    professor_id INTEGER NOT NULL REFERENCES users(id),
    planung_id INTEGER NOT NULL REFERENCES semesterplanung(id) ON DELETE CASCADE,

    eingereicht_am TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'eingereicht', -- eingereicht, freigegeben, abgelehnt

    freigegeben_am TIMESTAMP NULL,
    freigegeben_von INTEGER NULL REFERENCES users(id),

    abgelehnt_am TIMESTAMP NULL,
    abgelehnt_von INTEGER NULL REFERENCES users(id),
    abgelehnt_grund TEXT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ein Professor kann pro Phase nur eine genehmigte Planung haben
    CONSTRAINT unique_professor_phase_approved UNIQUE (planungphase_id, professor_id, status)
        DEFERRABLE INITIALLY DEFERRED
);

-- Indizes für Performance
CREATE INDEX idx_phase_submissions_phase ON phase_submissions(planungphase_id);
CREATE INDEX idx_phase_submissions_professor ON phase_submissions(professor_id);
CREATE INDEX idx_phase_submissions_status ON phase_submissions(status);

-- 3. Archivierte Planungen
CREATE TABLE IF NOT EXISTS archivierte_planungen (
    id SERIAL PRIMARY KEY,
    original_planung_id INTEGER NOT NULL,
    planungphase_id INTEGER NOT NULL REFERENCES planungsphasen(id),
    professor_id INTEGER NOT NULL REFERENCES users(id),
    professor_name VARCHAR(255) NOT NULL,
    semester_id INTEGER NOT NULL REFERENCES semester(id),
    semester_name VARCHAR(255) NOT NULL,
    phase_name VARCHAR(255) NOT NULL,

    status_bei_archivierung VARCHAR(50) NOT NULL,
    archiviert_am TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    archiviert_grund VARCHAR(50) NOT NULL, -- phase_geschlossen, manuell, system
    archiviert_von INTEGER NULL REFERENCES users(id),

    -- JSON Spalte für die kompletten Planungsdaten
    planung_daten JSONB NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indizes für Archiv
CREATE INDEX idx_archiv_phase ON archivierte_planungen(planungphase_id);
CREATE INDEX idx_archiv_professor ON archivierte_planungen(professor_id);
CREATE INDEX idx_archiv_semester ON archivierte_planungen(semester_id);
CREATE INDEX idx_archiv_status ON archivierte_planungen(status_bei_archivierung);
CREATE INDEX idx_archiv_datum ON archivierte_planungen(archiviert_am);

-- 4. Phase Statistiken (Materialized View für Performance)
CREATE MATERIALIZED VIEW IF NOT EXISTS phase_statistiken AS
SELECT
    pp.id as phase_id,
    pp.name as phase_name,
    pp.startdatum,
    pp.enddatum,
    pp.geschlossen_am,
    COALESCE(EXTRACT(DAY FROM (pp.geschlossen_am - pp.startdatum)),
             EXTRACT(DAY FROM (CURRENT_TIMESTAMP - pp.startdatum))) as dauer_tage,

    -- Professor Statistiken
    (SELECT COUNT(DISTINCT u.id)
     FROM users u
     WHERE u.rolle IN ('Professor', 'Lehrbeauftragter')) as professoren_gesamt,

    (SELECT COUNT(DISTINCT ps.professor_id)
     FROM phase_submissions ps
     WHERE ps.planungphase_id = pp.id) as professoren_eingereicht,

    -- Einreichungsstatistiken
    pp.anzahl_einreichungen,
    pp.anzahl_genehmigt,
    pp.anzahl_abgelehnt,

    -- Berechnete Quoten
    CASE
        WHEN (SELECT COUNT(DISTINCT u.id) FROM users u WHERE u.rolle IN ('Professor', 'Lehrbeauftragter')) > 0
        THEN (CAST((SELECT COUNT(DISTINCT ps.professor_id) FROM phase_submissions ps WHERE ps.planungphase_id = pp.id) AS FLOAT) /
              (SELECT COUNT(DISTINCT u.id) FROM users u WHERE u.rolle IN ('Professor', 'Lehrbeauftragter')) * 100)
        ELSE 0
    END as einreichungsquote,

    CASE
        WHEN pp.anzahl_einreichungen > 0
        THEN (CAST(pp.anzahl_genehmigt AS FLOAT) / pp.anzahl_einreichungen * 100)
        ELSE 0
    END as genehmigungsquote,

    -- Durchschnittliche Bearbeitungszeit in Stunden
    (SELECT AVG(EXTRACT(HOUR FROM (ps.freigegeben_am - ps.eingereicht_am)))
     FROM phase_submissions ps
     WHERE ps.planungphase_id = pp.id
     AND ps.freigegeben_am IS NOT NULL) as durchschnittliche_bearbeitungszeit_stunden

FROM planungsphasen pp;

-- Index für Materialized View
CREATE UNIQUE INDEX idx_phase_statistiken_id ON phase_statistiken(phase_id);

-- 5. Benachrichtigungseinstellungen
CREATE TABLE IF NOT EXISTS phase_notification_settings (
    id SERIAL PRIMARY KEY,
    deadline_reminder_days INTEGER NOT NULL DEFAULT 3,
    auto_close_after_deadline BOOLEAN NOT NULL DEFAULT false,
    send_submission_confirmation BOOLEAN NOT NULL DEFAULT true,
    send_approval_notification BOOLEAN NOT NULL DEFAULT true,
    send_rejection_notification BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER REFERENCES users(id)
);

-- Initial settings
INSERT INTO phase_notification_settings (deadline_reminder_days)
VALUES (3)
ON CONFLICT DO NOTHING;

-- 6. Erinnerungs-Log
CREATE TABLE IF NOT EXISTS phase_reminders_log (
    id SERIAL PRIMARY KEY,
    planungphase_id INTEGER NOT NULL REFERENCES planungsphasen(id),
    professor_id INTEGER NOT NULL REFERENCES users(id),
    gesendet_am TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    email_status VARCHAR(50) NOT NULL, -- success, failed
    fehler_details TEXT NULL
);

-- ============================================
-- STORED PROCEDURES / FUNCTIONS
-- ============================================

-- Funktion zum Starten einer neuen Phase
CREATE OR REPLACE FUNCTION start_planungsphase(
    p_semester_id INTEGER,
    p_name VARCHAR(255),
    p_enddatum TIMESTAMP DEFAULT NULL
)
RETURNS planungsphasen AS $$
DECLARE
    v_phase planungsphasen;
BEGIN
    -- Schließe alle anderen aktiven Phasen für dieses Semester
    UPDATE planungsphasen
    SET ist_aktiv = false,
        geschlossen_am = CURRENT_TIMESTAMP
    WHERE semester_id = p_semester_id
    AND ist_aktiv = true;

    -- Erstelle neue Phase
    INSERT INTO planungsphasen (semester_id, name, startdatum, enddatum, ist_aktiv)
    VALUES (p_semester_id, p_name, CURRENT_TIMESTAMP, p_enddatum, true)
    RETURNING * INTO v_phase;

    RETURN v_phase;
END;
$$ LANGUAGE plpgsql;

-- Funktion zum Schließen einer Phase mit Archivierung
CREATE OR REPLACE FUNCTION close_planungsphase(
    p_phase_id INTEGER,
    p_geschlossen_von INTEGER,
    p_archiviere_entwuerfe BOOLEAN DEFAULT false,
    p_grund TEXT DEFAULT NULL
)
RETURNS TABLE(
    phase planungsphasen,
    archivierte_planungen INTEGER,
    geloeschte_entwuerfe INTEGER
) AS $$
DECLARE
    v_phase planungsphasen;
    v_archiviert INTEGER := 0;
    v_geloescht INTEGER := 0;
BEGIN
    -- Phase schließen
    UPDATE planungsphasen
    SET ist_aktiv = false,
        geschlossen_am = CURRENT_TIMESTAMP,
        geschlossen_von = p_geschlossen_von,
        geschlossen_grund = p_grund
    WHERE id = p_phase_id
    RETURNING * INTO v_phase;

    -- Archiviere alle eingereichten/genehmigten/abgelehnten Planungen
    WITH archivierung AS (
        INSERT INTO archivierte_planungen (
            original_planung_id,
            planungphase_id,
            professor_id,
            professor_name,
            semester_id,
            semester_name,
            phase_name,
            status_bei_archivierung,
            archiviert_grund,
            archiviert_von,
            planung_daten
        )
        SELECT
            sp.id,
            p_phase_id,
            sp.dozent_id,
            CONCAT(u.vorname, ' ', u.nachname),
            sp.semester_id,
            s.bezeichnung,
            v_phase.name,
            sp.status,
            'phase_geschlossen',
            p_geschlossen_von,
            row_to_json(sp)::jsonb
        FROM semesterplanung sp
        JOIN users u ON u.id = sp.dozent_id
        JOIN semester s ON s.id = sp.semester_id
        WHERE sp.status IN ('eingereicht', 'freigegeben', 'abgelehnt')
        AND sp.semester_id = v_phase.semester_id
        RETURNING id
    )
    SELECT COUNT(*) INTO v_archiviert FROM archivierung;

    -- Entwürfe behandeln
    IF p_archiviere_entwuerfe THEN
        -- Archiviere auch Entwürfe
        WITH archivierung_entwuerfe AS (
            INSERT INTO archivierte_planungen (
                original_planung_id,
                planungphase_id,
                professor_id,
                professor_name,
                semester_id,
                semester_name,
                phase_name,
                status_bei_archivierung,
                archiviert_grund,
                archiviert_von,
                planung_daten
            )
            SELECT
                sp.id,
                p_phase_id,
                sp.dozent_id,
                CONCAT(u.vorname, ' ', u.nachname),
                sp.semester_id,
                s.bezeichnung,
                v_phase.name,
                sp.status,
                'phase_geschlossen',
                p_geschlossen_von,
                row_to_json(sp)::jsonb
            FROM semesterplanung sp
            JOIN users u ON u.id = sp.dozent_id
            JOIN semester s ON s.id = sp.semester_id
            WHERE sp.status = 'entwurf'
            AND sp.semester_id = v_phase.semester_id
            RETURNING id
        )
        SELECT COUNT(*) INTO v_geloescht FROM archivierung_entwuerfe;
    ELSE
        -- Lösche Entwürfe
        WITH deletion AS (
            DELETE FROM semesterplanung
            WHERE status = 'entwurf'
            AND semester_id = v_phase.semester_id
            RETURNING id
        )
        SELECT COUNT(*) INTO v_geloescht FROM deletion;
    END IF;

    RETURN QUERY SELECT v_phase, v_archiviert, v_geloescht;
END;
$$ LANGUAGE plpgsql;

-- Trigger zum Aktualisieren der Statistiken
CREATE OR REPLACE FUNCTION update_phase_statistics()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        UPDATE planungsphasen
        SET anzahl_einreichungen = (
                SELECT COUNT(*) FROM phase_submissions
                WHERE planungphase_id = NEW.planungphase_id
            ),
            anzahl_genehmigt = (
                SELECT COUNT(*) FROM phase_submissions
                WHERE planungphase_id = NEW.planungphase_id
                AND status = 'freigegeben'
            ),
            anzahl_abgelehnt = (
                SELECT COUNT(*) FROM phase_submissions
                WHERE planungphase_id = NEW.planungphase_id
                AND status = 'abgelehnt'
            ),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.planungphase_id;
    END IF;

    -- Refresh Materialized View
    REFRESH MATERIALIZED VIEW CONCURRENTLY phase_statistiken;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_phase_statistics
AFTER INSERT OR UPDATE ON phase_submissions
FOR EACH ROW
EXECUTE FUNCTION update_phase_statistics();

-- Funktion für Submission Status Check
CREATE OR REPLACE FUNCTION check_submission_status(p_professor_id INTEGER)
RETURNS JSON AS $$
DECLARE
    v_active_phase planungsphasen;
    v_last_submission phase_submissions;
    v_result JSON;
BEGIN
    -- Hole aktive Phase
    SELECT * INTO v_active_phase
    FROM planungsphasen
    WHERE ist_aktiv = true
    LIMIT 1;

    -- Wenn keine aktive Phase
    IF v_active_phase.id IS NULL THEN
        RETURN json_build_object(
            'kann_einreichen', false,
            'grund', 'keine_aktive_phase'
        );
    END IF;

    -- Check Deadline
    IF v_active_phase.enddatum IS NOT NULL AND v_active_phase.enddatum < CURRENT_TIMESTAMP THEN
        RETURN json_build_object(
            'kann_einreichen', false,
            'grund', 'phase_abgelaufen',
            'aktive_phase', row_to_json(v_active_phase)
        );
    END IF;

    -- Check ob bereits genehmigte Einreichung existiert
    SELECT * INTO v_last_submission
    FROM phase_submissions
    WHERE planungphase_id = v_active_phase.id
    AND professor_id = p_professor_id
    AND status = 'freigegeben'
    LIMIT 1;

    IF v_last_submission.id IS NOT NULL THEN
        RETURN json_build_object(
            'kann_einreichen', false,
            'grund', 'bereits_genehmigt',
            'aktive_phase', row_to_json(v_active_phase),
            'letzte_einreichung', row_to_json(v_last_submission)
        );
    END IF;

    -- Kann einreichen
    RETURN json_build_object(
        'kann_einreichen', true,
        'aktive_phase', row_to_json(v_active_phase),
        'verbleibende_zeit',
        CASE
            WHEN v_active_phase.enddatum IS NOT NULL
            THEN EXTRACT(EPOCH FROM (v_active_phase.enddatum - CURRENT_TIMESTAMP)) / 60
            ELSE NULL
        END
    );
END;
$$ LANGUAGE plpgsql;

-- View für Top Module pro Phase
CREATE OR REPLACE VIEW top_module_pro_phase AS
SELECT
    ps.planungphase_id,
    gm.modul_id,
    m.name as modul_name,
    COUNT(*) as anzahl,
    ROW_NUMBER() OVER (PARTITION BY ps.planungphase_id ORDER BY COUNT(*) DESC) as rang
FROM phase_submissions ps
JOIN semesterplanung sp ON sp.id = ps.planung_id
JOIN geplantes_modul gm ON gm.planung_id = sp.id
JOIN modul m ON m.id = gm.modul_id
GROUP BY ps.planungphase_id, gm.modul_id, m.name;

-- ============================================
-- GRANT PERMISSIONS (adjust based on your roles)
-- ============================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated_user;
GRANT INSERT, UPDATE ON planungsphasen TO dekan;
GRANT INSERT ON phase_submissions TO professor;
GRANT SELECT ON archivierte_planungen TO professor;
GRANT ALL ON archivierte_planungen TO dekan;

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================
-- Will be inserted via API calls