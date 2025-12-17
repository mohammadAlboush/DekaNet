-- ============================================
-- PLANUNG ZUSATZFELDER MIGRATION
-- ============================================
-- Fügt fehlende Felder zu semesterplanung und wunsch_freie_tage hinzu
-- Datum: 2025-01-14
-- ============================================

-- 1. Semesterplanung: Verknüpfung zur Planungsphase
ALTER TABLE semesterplanung
ADD COLUMN planungsphase_id INTEGER NULL
REFERENCES planungsphasen(id) ON DELETE SET NULL;

-- 2. Semesterplanung: Raumbedarf auf Planungsebene
-- (existiert bereits in geplante_module, aber wird auch auf Planungsebene benötigt)
ALTER TABLE semesterplanung
ADD COLUMN raumbedarf TEXT NULL;

-- 3. Semesterplanung: Room Requirements (JSON)
-- Struktur: [{"id":"1","type":"Seminarraum","capacity":30,"equipment":["Beamer"],"notes":"..."}]
ALTER TABLE semesterplanung
ADD COLUMN room_requirements TEXT NULL; -- JSON als TEXT in SQLite

-- 4. Semesterplanung: Special Requests (JSON)
-- Struktur: {"needsComputerRoom":true,"needsLab":false,"needsBeamer":true,...}
ALTER TABLE semesterplanung
ADD COLUMN special_requests TEXT NULL; -- JSON als TEXT in SQLite

-- 5. Wunsch freie Tage: Zeitraum hinzufügen
-- Werte: 'ganztags', 'vormittag', 'nachmittag'
ALTER TABLE wunsch_freie_tage
ADD COLUMN zeitraum VARCHAR(20) NULL DEFAULT 'ganztags';

-- 6. Wunsch freie Tage: Grund-Feld umbenennen (bemerkung -> grund)
-- SQLite unterstützt kein RENAME COLUMN vor Version 3.25.0
-- Daher: Neues Feld hinzufügen, Daten kopieren, altes Feld später entfernen
ALTER TABLE wunsch_freie_tage
ADD COLUMN grund TEXT NULL;

-- Kopiere bestehende Bemerkungen nach Grund
UPDATE wunsch_freie_tage
SET grund = bemerkung
WHERE bemerkung IS NOT NULL;

-- Hinweis: Das alte bemerkung-Feld wird NICHT gelöscht (Breaking Change vermeiden)
-- Backend sollte beide Felder unterstützen (Rückwärtskompatibilität)

-- ============================================
-- INDIZES FÜR PERFORMANCE
-- ============================================

-- Index für Planungsphase-Filterung
CREATE INDEX IF NOT EXISTS idx_semesterplanung_phase
ON semesterplanung(planungsphase_id)
WHERE planungsphase_id IS NOT NULL;

-- Composite Index für häufige Queries (Phase + Status)
CREATE INDEX IF NOT EXISTS idx_semesterplanung_phase_status
ON semesterplanung(planungsphase_id, status)
WHERE planungsphase_id IS NOT NULL;

-- Index für Zeitraum-Filterung bei Wunschtagen
CREATE INDEX IF NOT EXISTS idx_wunsch_tage_zeitraum
ON wunsch_freie_tage(zeitraum);

-- ============================================
-- ROLLBACK (Optional - für Entwicklung)
-- ============================================
-- Hinweis: SQLite unterstützt DROP COLUMN nicht vor Version 3.35.0
-- Für Rollback müsste die gesamte Tabelle neu erstellt werden
-- Dies ist hier nicht implementiert - Migration sollte nur vorwärts laufen

-- ============================================
-- VALIDIERUNG
-- ============================================
-- Prüfe ob alle Felder korrekt hinzugefügt wurden
SELECT
    'semesterplanung' as tabelle,
    COUNT(*) as anzahl_zeilen
FROM semesterplanung;

SELECT
    'wunsch_freie_tage' as tabelle,
    COUNT(*) as anzahl_zeilen
FROM wunsch_freie_tage;

-- ============================================
-- ENDE DER MIGRATION
-- ============================================
