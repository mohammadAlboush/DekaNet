# SQLite → PostgreSQL Migrations-Anleitung

Diese Anleitung beschreibt, wie Sie Ihre SQLite-Datenbank nach PostgreSQL migrieren.

## Übersicht

1. **Lokal**: PostgreSQL installieren und Migration durchführen
2. **Lokal**: PostgreSQL-Dump erstellen
3. **GitHub**: Dump hochladen (temporär)
4. **Server**: Dump herunterladen und importieren
5. **GitHub**: Dump wieder entfernen

## Voraussetzungen

- PostgreSQL auf Windows installiert
- Git Bash oder PowerShell
- Zugriff auf den Server via SSH

## Schritt 1: PostgreSQL auf Windows installieren

### Option A: Download von postgresql.org

```
1. Download: https://www.postgresql.org/download/windows/
2. Installer ausführen (PostgreSQL 16.x empfohlen)
3. Standard-Port: 5432
4. Passwort für postgres-User setzen: postgres123
5. pgAdmin 4 mit installieren (optional, für GUI)
```

### Option B: Mit Chocolatey (schneller)

```powershell
# PowerShell als Administrator
choco install postgresql
```

### Verifizieren

```bash
# Git Bash
psql --version
# Ausgabe: psql (PostgreSQL) 16.x
```

## Schritt 2: Komplette Migration durchführen

**In Git Bash im backend/-Verzeichnis:**

```bash
cd backend

# Skript ausführbar machen
chmod +x create_migration_dump.sh

# Migration durchführen
./create_migration_dump.sh
```

**Das Skript führt automatisch aus:**
1. ✅ Erstellt PostgreSQL-Datenbank `dekanat_migration`
2. ✅ Erstellt Benutzer `dekanat_user`
3. ✅ Erstellt Datenbank-Schema (Flask Migrations)
4. ✅ Migriert alle Daten von SQLite → PostgreSQL
5. ✅ Erstellt komprimierten Dump: `database_dumps/dekanat_postgres_dump.sql.gz`
6. ✅ Erstellt Import-Skript für Server: `database_dumps/import_on_server.sh`

**Erwartete Ausgabe:**
```
================================================================================
  ✅ MIGRATION ABGESCHLOSSEN!
================================================================================

📦 Dump-Datei: database_dumps/dekanat_postgres_dump.sql.gz
📜 Import-Skript: database_dumps/import_on_server.sh

📋 Nächste Schritte: ...
```

## Schritt 3: Dump zu GitHub pushen

```bash
cd ..  # Zurück ins Hauptverzeichnis

# Dump hinzufügen
git add database_dumps/
git commit -m "Add PostgreSQL database dump for migration"
git push origin main
```

⚠️ **WICHTIG:** Der Dump enthält Ihre Datenbank-Daten. Entfernen Sie ihn nach dem Import wieder!

## Schritt 4: Auf dem Server importieren

### 4.1 Server-Vorbereitungen

```bash
# SSH zum Server
ssh mohammad@172.16.194.152

# PostgreSQL installieren (falls nicht vorhanden)
sudo apt update
sudo apt install postgresql postgresql-contrib

# PostgreSQL starten
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 4.2 PostgreSQL Benutzer und Datenbank erstellen

```bash
# Als postgres-User
sudo -u postgres psql

# In PostgreSQL:
CREATE DATABASE dekanat_production;
CREATE USER dekanat_user WITH PASSWORD 'IHR_SICHERES_PASSWORT';
GRANT ALL PRIVILEGES ON DATABASE dekanat_production TO dekanat_user;
ALTER USER dekanat_user CREATEDB;  -- Für Migrations
\q
```

### 4.3 Repository pullen

```bash
# Zum Projekt
cd ~/DekaNet

# Neueste Version holen
git pull origin main

# Ins database_dumps-Verzeichnis
cd database_dumps
```

### 4.4 Import-Skript anpassen und ausführen

```bash
# Skript bearbeiten
nano import_on_server.sh

# Passwort anpassen (Zeile 15):
DB_PASSWORD="IHR_PASSWORT_HIER"  # ← Hier Ihr PostgreSQL-Passwort eintragen

# Skript ausführen
chmod +x import_on_server.sh
./import_on_server.sh
```

**Erwartete Ausgabe:**
```
================================================================================
  PostgreSQL Dump Import
================================================================================

[1/3] Entpacke Dump...
   ✓ Dump entpackt

[2/3] Importiere in PostgreSQL...
   ✓ Import abgeschlossen

[3/3] Aufräumen...
   ✓ Temporäre Dateien gelöscht

================================================================================
  ✅ IMPORT ERFOLGREICH!
================================================================================
```

### 4.5 Import verifizieren

```bash
# Teste Datenbank
psql -U dekanat_user -d dekanat_production -c "SELECT COUNT(*) FROM benutzer;"

# Sollte Anzahl Ihrer Benutzer anzeigen
```

## Schritt 5: Server-Anwendung konfigurieren

```bash
cd ~/DekaNet/backend

# .env-Datei erstellen/bearbeiten
nano .env

# Inhalt:
FLASK_ENV=production
DATABASE_URL=postgresql://dekanat_user:IHR_PASSWORT@localhost:5432/dekanat_production
SECRET_KEY=20174a4bbbf483467673773b687d509107318d4ea701332ded22c780109c6eeb
JWT_SECRET_KEY=6accd4ed07ca97244aad0da0b6fabb1c261b93d369cd079502b56404e7434aff
```

**Server starten:**
```bash
# Virtual Environment aktivieren
source venv/bin/activate

# Server starten
python run.py

# ODER mit Gunicorn (Production)
gunicorn -c gunicorn.conf.py run:app
```

**Login testen:**
```bash
curl -X POST http://172.16.194.152:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "dekan@hochschule.de", "password": "dekan123"}'
```

## Schritt 6: Dump aus GitHub entfernen

⚠️ **WICHTIG:** Nach erfolgreichem Import sollten Sie den Dump aus GitHub entfernen!

```bash
# Auf Ihrem lokalen PC
cd C:\Users\moham\OneDrive\Desktop\DigiDekan

# Dump-Verzeichnis aus Git entfernen
git rm -r database_dumps/
git commit -m "chore: Remove database dump after successful migration"
git push origin main
```

**Dump lokal behalten (optional):**
```bash
# Vor dem git rm: Backup erstellen
cp -r database_dumps ../database_dumps_backup
```

## Troubleshooting

### Problem: "psql: command not found"

PostgreSQL ist nicht im PATH.

**Windows:**
```bash
# Füge zu PATH hinzu (Git Bash):
export PATH="/c/Program Files/PostgreSQL/16/bin:$PATH"

# Oder in PowerShell:
$env:Path += ";C:\Program Files\PostgreSQL\16\bin"
```

### Problem: "FATAL: password authentication failed"

PostgreSQL `pg_hba.conf` anpassen:

```bash
# Auf dem Server
sudo nano /etc/postgresql/*/main/pg_hba.conf

# Ändere "peer" zu "md5":
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5

# PostgreSQL neu starten
sudo systemctl restart postgresql
```

### Problem: "Permission denied for schema public"

```bash
# Als postgres-User
sudo -u postgres psql -d dekanat_production

# Berechtigungen setzen:
GRANT ALL ON SCHEMA public TO dekanat_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dekanat_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dekanat_user;
\q
```

### Problem: Migration-Skript schlägt fehl

```bash
# Prüfe ob DATABASE_URL gesetzt ist
echo $DATABASE_URL

# Manuell setzen:
export DATABASE_URL="postgresql://dekanat_user:dekanat123@localhost:5432/dekanat_migration"

# Migration erneut versuchen
python migrate_sqlite_to_postgres.py
```

## Zusammenfassung der Dateien

```
DigiDekan/
├── backend/
│   ├── migrate_sqlite_to_postgres.py      # Migrations-Skript (SQLite→PostgreSQL)
│   ├── create_migration_dump.sh           # Automatisches Migrations-Script
│   ├── setup_local_postgres.sh            # PostgreSQL Setup (Git Bash)
│   └── setup_local_postgres.bat           # PostgreSQL Setup (Windows CMD)
├── database_dumps/                         # (Temporär, nach Import löschen!)
│   ├── dekanat_postgres_dump.sql.gz       # Komprimierter Dump
│   └── import_on_server.sh                # Import-Skript für Server
└── MIGRATION_GUIDE.md                      # Diese Anleitung
```

## Checkliste

- [ ] PostgreSQL auf Windows installiert
- [ ] Migrations-Skript ausgeführt (`create_migration_dump.sh`)
- [ ] Dump-Datei erstellt (`database_dumps/dekanat_postgres_dump.sql.gz`)
- [ ] Dump zu GitHub gepusht
- [ ] Auf Server: PostgreSQL installiert und Datenbank erstellt
- [ ] Auf Server: Repository gepullt
- [ ] Auf Server: Import-Skript angepasst (Passwort)
- [ ] Auf Server: Import ausgeführt
- [ ] Auf Server: Import verifiziert
- [ ] Server-Anwendung mit PostgreSQL gestartet
- [ ] Login getestet
- [ ] Dump aus GitHub entfernt

## Support

Bei Problemen:
1. Prüfe die Logs: `tail -f backend/logs/app.log`
2. Prüfe PostgreSQL-Logs: `sudo tail -f /var/log/postgresql/postgresql-*.log`
3. Teste Datenbankverbindung: `psql -U dekanat_user -d dekanat_production`
