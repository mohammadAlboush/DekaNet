#!/bin/bash
# ============================================================================
# Kompletter Migrations-Workflow: SQLite → PostgreSQL → Dump
# ============================================================================

set -e  # Stop bei Fehler

echo "================================================================================"
echo "  SQLite → PostgreSQL Migration & Dump Creation"
echo "  Digitales Dekanat"
echo "================================================================================"
echo ""

# Verzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# ============================================================================
# Schritt 1: PostgreSQL Setup prüfen
# ============================================================================
echo "[1/6] Prüfe PostgreSQL Installation..."

if ! command -v psql &> /dev/null; then
    echo "❌ ERROR: PostgreSQL ist nicht installiert!"
    echo "   Installieren Sie PostgreSQL: https://www.postgresql.org/download/"
    exit 1
fi

echo "   ✓ PostgreSQL gefunden: $(psql --version)"

# ============================================================================
# Schritt 2: Datenbank erstellen
# ============================================================================
echo ""
echo "[2/6] Erstelle PostgreSQL-Datenbank..."

# PostgreSQL 17 Passwort verwenden
export PGPASSWORD=postgres

# Datenbank erstellen
psql -U postgres -h localhost -c "DROP DATABASE IF EXISTS dekanat_migration;" 2>/dev/null || true
psql -U postgres -h localhost -c "CREATE DATABASE dekanat_migration;"

# Benutzer erstellen
psql -U postgres -h localhost -c "DROP USER IF EXISTS dekanat_user;" 2>/dev/null || true
psql -U postgres -h localhost -c "CREATE USER dekanat_user WITH PASSWORD 'dekanat123';"

# Berechtigungen
psql -U postgres -h localhost -c "GRANT ALL PRIVILEGES ON DATABASE dekanat_migration TO dekanat_user;"
psql -U postgres -h localhost -d dekanat_migration -c "GRANT ALL ON SCHEMA public TO dekanat_user;"

echo "   ✓ Datenbank dekanat_migration erstellt"

# ============================================================================
# Schritt 3: Flask Migrations ausführen (Schema erstellen)
# ============================================================================
echo ""
echo "[3/6] Erstelle Datenbank-Schema in PostgreSQL..."

# DATABASE_URL für Migration setzen
export DATABASE_URL="postgresql://dekanat_user:dekanat123@localhost:5432/dekanat_migration"

# Aktiviere Virtual Environment (falls vorhanden)
if [ -d "venv" ]; then
    source venv/bin/activate
elif [ -d "../venv" ]; then
    source ../venv/bin/activate
fi

# Schema erstellen
echo "   → Führe Flask Migrations aus..."
flask db upgrade 2>/dev/null || python -c "from app import create_app, db; app = create_app(); app.app_context().push(); db.create_all(); print('✓ Schema erstellt')"

echo "   ✓ PostgreSQL-Schema erstellt"

# ============================================================================
# Schritt 4: Daten migrieren (SQLite → PostgreSQL)
# ============================================================================
echo ""
echo "[4/6] Migriere Daten von SQLite zu PostgreSQL..."

python migrate_sqlite_to_postgres.py <<EOF
ja
EOF

echo "   ✓ Daten migriert"

# ============================================================================
# Schritt 5: PostgreSQL Dump erstellen
# ============================================================================
echo ""
echo "[5/6] Erstelle PostgreSQL Dump..."

DUMP_FILE="../database_dumps/dekanat_postgres_dump.sql"
mkdir -p "../database_dumps"

# Dump erstellen
export PGPASSWORD=dekanat123
pg_dump -U dekanat_user -h localhost -d dekanat_migration \
    --clean \
    --if-exists \
    --no-owner \
    --no-privileges \
    -f "$DUMP_FILE"

# Dump komprimieren
gzip -f "$DUMP_FILE"
DUMP_FILE="${DUMP_FILE}.gz"

DUMP_SIZE=$(du -h "$DUMP_FILE" | cut -f1)

echo "   ✓ Dump erstellt: $DUMP_FILE"
echo "   ✓ Größe: $DUMP_SIZE"

# ============================================================================
# Schritt 6: Import-Skript für Server erstellen
# ============================================================================
echo ""
echo "[6/6] Erstelle Import-Skript für Server..."

cat > ../database_dumps/import_on_server.sh << 'IMPORTSCRIPT'
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

# Drop alte Datenbank und neu erstellen
psql -U postgres -h "$DB_HOST" -c "DROP DATABASE IF EXISTS $DB_NAME;" 2>/dev/null || true
psql -U postgres -h "$DB_HOST" -c "CREATE DATABASE $DB_NAME;"
psql -U postgres -h "$DB_HOST" -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"

# Import
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
IMPORTSCRIPT

chmod +x ../database_dumps/import_on_server.sh

echo "   ✓ Import-Skript erstellt: database_dumps/import_on_server.sh"

# ============================================================================
# Zusammenfassung
# ============================================================================
echo ""
echo "================================================================================"
echo "  ✅ MIGRATION ABGESCHLOSSEN!"
echo "================================================================================"
echo ""
echo "📦 Dump-Datei: database_dumps/dekanat_postgres_dump.sql.gz"
echo "📜 Import-Skript: database_dumps/import_on_server.sh"
echo ""
echo "📋 Nächste Schritte:"
echo ""
echo "1. Dump zu GitHub pushen:"
echo "   cd .."
echo "   git add database_dumps/"
echo "   git commit -m \"Add PostgreSQL database dump for migration\""
echo "   git push origin main"
echo ""
echo "2. Auf Server:"
echo "   git pull origin main"
echo "   cd database_dumps"
echo "   ./import_on_server.sh"
echo ""
echo "3. Dump aus GitHub entfernen:"
echo "   git rm -r database_dumps/"
echo "   git commit -m \"Remove database dump after migration\""
echo "   git push origin main"
echo ""
echo "⚠️  WICHTIG: Passen Sie das Passwort im import_on_server.sh an!"
echo ""
