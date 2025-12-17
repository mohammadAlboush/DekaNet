-- ============================================
-- DELETE EXISTING PLANUNGEN
-- ============================================
-- Löscht alle vorhandenen Planungen aus der Datenbank
-- WARNUNG: Dies löscht alle Planungsdaten unwiderruflich!
-- ============================================

-- Starte Transaktion
BEGIN;

-- 1. Lösche abhängige Daten zuerst
DELETE FROM geplantes_modul;
DELETE FROM wunsch_freier_tag;
DELETE FROM phase_submissions;

-- 2. Lösche Hauptplanungen
DELETE FROM semesterplanung;

-- 3. Optional: Reset Auto-Increment IDs (PostgreSQL)
-- ALTER SEQUENCE semesterplanung_id_seq RESTART WITH 1;
-- ALTER SEQUENCE geplantes_modul_id_seq RESTART WITH 1;
-- ALTER SEQUENCE wunsch_freier_tag_id_seq RESTART WITH 1;

-- 4. Optional: Reset für SQLite
-- DELETE FROM sqlite_sequence WHERE name IN ('semesterplanung', 'geplantes_modul', 'wunsch_freier_tag');

-- Zeige Anzahl verbleibender Einträge
SELECT 'Semesterplanungen:' as table_name, COUNT(*) as count FROM semesterplanung
UNION ALL
SELECT 'Geplante Module:', COUNT(*) FROM geplantes_modul
UNION ALL
SELECT 'Wunsch freie Tage:', COUNT(*) FROM wunsch_freier_tag;

-- Commit der Transaktion
COMMIT;

-- Bestätigung
SELECT '✅ Alle Planungen wurden erfolgreich gelöscht!' as status;