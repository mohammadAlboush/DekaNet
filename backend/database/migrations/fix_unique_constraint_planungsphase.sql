-- ============================================
-- FIX UNIQUE CONSTRAINT für Planungsphasen
-- ============================================
-- Erlaubt einem Professor mehrere Planungen pro Semester,
-- aber nur EINE pro Planungsphase
-- Datum: 2025-01-14
-- ============================================

-- 1. Entferne den alten Constraint (semester_id, benutzer_id)
-- SQLite: DROP CONSTRAINT wird nicht unterstützt, daher Table Recreate

-- Backup der Daten
CREATE TABLE semesterplanung_backup AS
SELECT * FROM semesterplanung;

-- Drop alte Tabelle
DROP TABLE semesterplanung;

-- Recreate mit neuem Constraint
CREATE TABLE semesterplanung (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    semester_id INTEGER NOT NULL,
    benutzer_id INTEGER NOT NULL,
    planungsphase_id INTEGER NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'entwurf',
    anmerkungen TEXT NULL,
    raumbedarf TEXT NULL,
    room_requirements TEXT NULL,
    special_requests TEXT NULL,
    gesamt_sws REAL DEFAULT 0.0,
    eingereicht_am TIMESTAMP NULL,
    freigegeben_von INTEGER NULL,
    freigegeben_am TIMESTAMP NULL,
    abgelehnt_am TIMESTAMP NULL,
    ablehnungsgrund TEXT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (semester_id) REFERENCES semester(id) ON DELETE CASCADE,
    FOREIGN KEY (benutzer_id) REFERENCES benutzer(id) ON DELETE CASCADE,
    FOREIGN KEY (planungsphase_id) REFERENCES planungsphasen(id) ON DELETE SET NULL,
    FOREIGN KEY (freigegeben_von) REFERENCES benutzer(id) ON DELETE SET NULL,

    -- ✅ NEUER UNIQUE CONSTRAINT: Ein Professor kann EINE Planung pro Planungsphase haben
    UNIQUE (semester_id, benutzer_id, planungsphase_id)
);

-- Restore Daten (mit COALESCE für NULL-Werte)
INSERT INTO semesterplanung (
    id, semester_id, benutzer_id, planungsphase_id,
    status, anmerkungen, raumbedarf, room_requirements, special_requests,
    gesamt_sws, eingereicht_am, freigegeben_von, freigegeben_am,
    abgelehnt_am, ablehnungsgrund, created_at, updated_at
)
SELECT
    id, semester_id, benutzer_id, planungsphase_id,
    COALESCE(status, 'entwurf'), anmerkungen, raumbedarf, room_requirements, special_requests,
    COALESCE(gesamt_sws, 0.0), eingereicht_am, freigegeben_von, freigegeben_am,
    abgelehnt_am, ablehnungsgrund,
    COALESCE(created_at, CURRENT_TIMESTAMP),
    COALESCE(updated_at, CURRENT_TIMESTAMP)
FROM semesterplanung_backup;

-- Drop Backup
DROP TABLE semesterplanung_backup;

-- Recreate Indices
CREATE INDEX IF NOT EXISTS ix_semesterplanung_status_semester
ON semesterplanung(status, semester_id);

CREATE INDEX IF NOT EXISTS ix_semesterplanung_benutzer_status
ON semesterplanung(benutzer_id, status);

CREATE INDEX IF NOT EXISTS ix_semesterplanung_phase
ON semesterplanung(planungsphase_id)
WHERE planungsphase_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS ix_semesterplanung_phase_status
ON semesterplanung(planungsphase_id, status)
WHERE planungsphase_id IS NOT NULL;

-- ============================================
-- VALIDIERUNG
-- ============================================
SELECT
    'semesterplanung' as tabelle,
    COUNT(*) as anzahl_zeilen
FROM semesterplanung;

-- ============================================
-- ENDE DER MIGRATION
-- ============================================
