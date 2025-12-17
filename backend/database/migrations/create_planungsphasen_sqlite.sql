-- ============================================
-- PLANUNGSPHASEN SYSTEM - SQLITE VERSION
-- ============================================
-- SQLite-kompatible Version der Planungsphasen-Tabellen
-- ============================================

-- 1. Planungsphasen Tabelle
CREATE TABLE IF NOT EXISTS planungsphasen (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    semester_id INTEGER NOT NULL REFERENCES semester(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    startdatum TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    enddatum TIMESTAMP NULL,
    ist_aktiv BOOLEAN NOT NULL DEFAULT 1,
    geschlossen_am TIMESTAMP NULL,
    geschlossen_von INTEGER NULL REFERENCES benutzer(id),
    geschlossen_grund TEXT NULL,
    anzahl_einreichungen INTEGER NOT NULL DEFAULT 0,
    anzahl_genehmigt INTEGER NOT NULL DEFAULT 0,
    anzahl_abgelehnt INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (enddatum IS NULL OR enddatum > startdatum)
);

-- Index für Performance
CREATE INDEX IF NOT EXISTS idx_planungsphasen_aktiv ON planungsphasen(ist_aktiv) WHERE ist_aktiv = 1;
CREATE INDEX IF NOT EXISTS idx_planungsphasen_semester ON planungsphasen(semester_id);

-- 2. Submission Tracking Tabelle
CREATE TABLE IF NOT EXISTS phase_submissions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    planungphase_id INTEGER NOT NULL REFERENCES planungsphasen(id) ON DELETE CASCADE,
    professor_id INTEGER NOT NULL REFERENCES benutzer(id),
    planung_id INTEGER NOT NULL REFERENCES semesterplanung(id) ON DELETE CASCADE,
    eingereicht_am TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL DEFAULT 'eingereicht',
    freigegeben_am TIMESTAMP NULL,
    freigegeben_von INTEGER NULL REFERENCES benutzer(id),
    abgelehnt_am TIMESTAMP NULL,
    abgelehnt_von INTEGER NULL REFERENCES benutzer(id),
    abgelehnt_grund TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(planungphase_id, professor_id, status)
);

-- Indizes für Performance
CREATE INDEX IF NOT EXISTS idx_phase_submissions_phase ON phase_submissions(planungphase_id);
CREATE INDEX IF NOT EXISTS idx_phase_submissions_professor ON phase_submissions(professor_id);
CREATE INDEX IF NOT EXISTS idx_phase_submissions_status ON phase_submissions(status);

-- 3. Archivierte Planungen
CREATE TABLE IF NOT EXISTS archivierte_planungen (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    original_planung_id INTEGER NOT NULL,
    planungphase_id INTEGER NOT NULL REFERENCES planungsphasen(id),
    professor_id INTEGER NOT NULL REFERENCES benutzer(id),
    professor_name VARCHAR(255) NOT NULL,
    semester_id INTEGER NOT NULL REFERENCES semester(id),
    semester_name VARCHAR(255) NOT NULL,
    phase_name VARCHAR(255) NOT NULL,
    status_bei_archivierung VARCHAR(50) NOT NULL,
    archiviert_am TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    archiviert_grund VARCHAR(50) NOT NULL,
    archiviert_von INTEGER NULL REFERENCES benutzer(id),
    planung_daten TEXT NOT NULL, -- JSON als TEXT in SQLite
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indizes für Archiv
CREATE INDEX IF NOT EXISTS idx_archiv_phase ON archivierte_planungen(planungphase_id);
CREATE INDEX IF NOT EXISTS idx_archiv_professor ON archivierte_planungen(professor_id);
CREATE INDEX IF NOT EXISTS idx_archiv_semester ON archivierte_planungen(semester_id);
CREATE INDEX IF NOT EXISTS idx_archiv_status ON archivierte_planungen(status_bei_archivierung);
CREATE INDEX IF NOT EXISTS idx_archiv_datum ON archivierte_planungen(archiviert_am);

-- 4. Benachrichtigungseinstellungen
CREATE TABLE IF NOT EXISTS phase_notification_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deadline_reminder_days INTEGER NOT NULL DEFAULT 3,
    auto_close_after_deadline BOOLEAN NOT NULL DEFAULT 0,
    send_submission_confirmation BOOLEAN NOT NULL DEFAULT 1,
    send_approval_notification BOOLEAN NOT NULL DEFAULT 1,
    send_rejection_notification BOOLEAN NOT NULL DEFAULT 1,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER REFERENCES benutzer(id)
);

-- Initial settings
INSERT OR IGNORE INTO phase_notification_settings (id, deadline_reminder_days)
VALUES (1, 3);

-- 5. Erinnerungs-Log
CREATE TABLE IF NOT EXISTS phase_reminders_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    planungphase_id INTEGER NOT NULL REFERENCES planungsphasen(id),
    professor_id INTEGER NOT NULL REFERENCES benutzer(id),
    gesendet_am TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    email_status VARCHAR(50) NOT NULL,
    fehler_details TEXT NULL
);