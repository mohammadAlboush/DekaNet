#!/bin/bash
# =============================================================================
# SERVER UPDATE SCRIPT - DigiDekan/DekaNet
# =============================================================================
# Verwendung: ./update_server.sh
# =============================================================================

set -e  # Bei Fehler abbrechen

echo "========================================"
echo " DigiDekan Server Update"
echo "========================================"

# Konfiguration
PROJECT_DIR="$HOME/DekaNet"
DB_NAME="dekanet_db"
DB_USER="dekanet"
DB_HOST="localhost"
BACKUP_DIR="$PROJECT_DIR/backups"

# Timestamp für Backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 1. Backup der aktuellen Datenbank
echo ""
echo "[1/5] Erstelle Datenbank-Backup..."
mkdir -p "$BACKUP_DIR"
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -f "$BACKUP_DIR/backup_$TIMESTAMP.dump" 2>/dev/null || {
    echo "Warnung: Backup fehlgeschlagen (evtl. leere DB)"
}
echo "Backup erstellt: $BACKUP_DIR/backup_$TIMESTAMP.dump"

# 2. Git Pull
echo ""
echo "[2/5] Hole neueste Version von GitHub..."
cd "$PROJECT_DIR"
git fetch origin
git reset --hard origin/main
echo "Git pull erfolgreich"

# 3. Backend Dependencies
echo ""
echo "[3/5] Installiere Backend-Dependencies..."
cd "$PROJECT_DIR/backend"
if [ -d "venv" ]; then
    source venv/bin/activate
fi
pip install -r requirements.txt --quiet
echo "Dependencies installiert"

# 4. Datenbank aktualisieren
echo ""
echo "[4/5] Aktualisiere Datenbank..."
echo "ACHTUNG: Dies ueberschreibt alle Daten in $DB_NAME!"
read -p "Fortfahren? (j/n): " confirm
if [ "$confirm" = "j" ]; then
    # Alle Tabellen droppen und neu erstellen
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
        DROP SCHEMA public CASCADE;
        CREATE SCHEMA public;
        GRANT ALL ON SCHEMA public TO $DB_USER;
        GRANT ALL ON SCHEMA public TO public;
    "

    # Dump importieren
    psql -h $DB_HOST -U $DB_USER -d $DB_NAME < database_dump.sql
    echo "Datenbank erfolgreich aktualisiert"
else
    echo "Datenbank-Update uebersprungen"
fi

# 5. Services neu starten
echo ""
echo "[5/5] Starte Services neu..."
if systemctl is-active --quiet digidekan-backend 2>/dev/null; then
    sudo systemctl restart digidekan-backend
    echo "Backend-Service neugestartet"
else
    echo "Hinweis: Kein systemd-Service gefunden. Bitte manuell neustarten:"
    echo "  pkill -f gunicorn"
    echo "  cd $PROJECT_DIR/backend && gunicorn -c gunicorn.conf.py run:app -D"
fi

echo ""
echo "========================================"
echo "Update abgeschlossen!"
echo "========================================"
echo ""
echo "Bei Problemen: Backup wiederherstellen mit:"
echo "  pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME -c $BACKUP_DIR/backup_$TIMESTAMP.dump"
