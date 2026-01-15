#!/bin/bash
# ============================================================================
# PostgreSQL Dump Import auf dem Server
# ============================================================================

set -e

echo "================================================================================"
echo "  PostgreSQL Dump Import"
echo "================================================================================"
echo ""

# PostgreSQL Credentials (ANPASSEN!)
DB_NAME="dekanat_production"
DB_USER="dekanat_user"
DB_PASSWORD="IHR_PASSWORT_HIER"  # ⚠️ ANPASSEN!
DB_HOST="localhost"
DB_PORT="5432"

DUMP_FILE="dekanat_postgres_dump.sql.gz"

# Prüfe ob Dump existiert
if [ ! -f "$DUMP_FILE" ]; then
    echo "❌ ERROR: Dump-Datei nicht gefunden: $DUMP_FILE"
    exit 1
fi

echo "[1/3] Entpacke Dump..."
gunzip -k "$DUMP_FILE"
DUMP_SQL="${DUMP_FILE%.gz}"
echo "   ✓ Dump entpackt"

echo ""
echo "[2/3] Importiere in PostgreSQL..."
export PGPASSWORD="$DB_PASSWORD"

# Import (Datenbank muss bereits existieren!)
psql -U "$DB_USER" -h "$DB_HOST" -d "$DB_NAME" < "$DUMP_SQL"

echo "   ✓ Import abgeschlossen"

echo ""
echo "[3/3] Aufräumen..."
rm "$DUMP_SQL"
echo "   ✓ Temporäre Dateien gelöscht"

echo ""
echo "================================================================================"
echo "  ✅ IMPORT ERFOLGREICH!"
echo "================================================================================"
echo ""
echo "Datenbank: $DB_NAME"
echo "Host: $DB_HOST:$DB_PORT"
echo ""
echo "Test mit:"
echo "psql -U $DB_USER -d $DB_NAME -c 'SELECT COUNT(*) FROM benutzer;'"
echo ""
