#!/usr/bin/env python3
"""
Automatischer PostgreSQL-Datenbank-Import auf dem Server
=========================================================
Dieses Skript importiert den PostgreSQL-Dump in die Server-Datenbank.

Verwendung:
    python3 import_database_to_server.py

Voraussetzungen:
    - PostgreSQL ist installiert
    - Dump-Datei existiert in database_dumps/
"""

import os
import sys
import subprocess
import gzip
from datetime import datetime
from pathlib import Path

# Server-Konfiguration
DB_NAME = "dekanet_db"
DB_USER = "dekanet"
DB_PASSWORD = "DekaNet2025Secure"
DB_HOST = "localhost"
DB_PORT = "5432"

# Pfade
SCRIPT_DIR = Path(__file__).parent
DUMP_DIR = SCRIPT_DIR / "database_dumps"
DUMP_FILE = DUMP_DIR / "dekanat_postgres_dump.sql.gz"
BACKUP_DIR = Path.home() / "dekanet_backups"

def print_header(text):
    """Druckt eine formatierte Überschrift"""
    print("\n" + "=" * 80)
    print(f"  {text}")
    print("=" * 80 + "\n")

def print_step(step_num, total_steps, text):
    """Druckt einen Schritt"""
    print(f"[{step_num}/{total_steps}] {text}")

def run_command(command, env=None, capture_output=False):
    """Führt einen Shell-Befehl aus"""
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            env=env or os.environ.copy(),
            capture_output=capture_output,
            text=True
        )
        return result.stdout if capture_output else True
    except subprocess.CalledProcessError as e:
        print(f"   ✗ Fehler: {e}")
        if capture_output and e.stderr:
            print(f"   Details: {e.stderr}")
        return False

def run_psql(sql, as_postgres=False):
    """Führt SQL-Befehl aus"""
    env = os.environ.copy()
    env['PGPASSWORD'] = DB_PASSWORD

    if as_postgres:
        cmd = f'sudo -u postgres psql -d {DB_NAME} -c "{sql}"'
    else:
        cmd = f'psql -U {DB_USER} -h {DB_HOST} -d {DB_NAME} -c "{sql}"'

    return run_command(cmd, env=env)

def main():
    """Hauptfunktion"""
    print_header("DekaNet Datenbank-Import")

    total_steps = 7
    current_step = 0

    # Schritt 1: Prüfe Voraussetzungen
    current_step += 1
    print_step(current_step, total_steps, "Prüfe Voraussetzungen...")

    if not DUMP_FILE.exists():
        print(f"   ✗ Dump-Datei nicht gefunden: {DUMP_FILE}")
        sys.exit(1)

    dump_size = DUMP_FILE.stat().st_size / 1024
    print(f"   ✓ Dump gefunden: {dump_size:.1f} KB")

    # Prüfe PostgreSQL
    if not run_command("which psql", capture_output=True):
        print("   ✗ PostgreSQL ist nicht installiert!")
        sys.exit(1)
    print("   ✓ PostgreSQL gefunden")

    # Schritt 2: Backup erstellen
    current_step += 1
    print_step(current_step, total_steps, "Erstelle Backup der aktuellen Datenbank...")

    BACKUP_DIR.mkdir(exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = BACKUP_DIR / f"dekanet_db_backup_{timestamp}.sql"

    env = os.environ.copy()
    env['PGPASSWORD'] = DB_PASSWORD

    backup_cmd = f"pg_dump -U {DB_USER} -h {DB_HOST} {DB_NAME} > {backup_file}"
    if run_command(backup_cmd, env=env):
        print(f"   ✓ Backup erstellt: {backup_file}")
    else:
        print("   ⚠ Backup fehlgeschlagen (wird fortgesetzt)")

    # Schritt 3: Alte Datenbank leeren
    current_step += 1
    print_step(current_step, total_steps, "Lösche alte Datenbankstruktur...")

    if run_psql("DROP SCHEMA public CASCADE; CREATE SCHEMA public;", as_postgres=True):
        print("   ✓ Schema zurückgesetzt")
    else:
        print("   ✗ Schema-Reset fehlgeschlagen")
        sys.exit(1)

    # Schritt 4: Berechtigungen setzen
    current_step += 1
    print_step(current_step, total_steps, "Setze Berechtigungen...")

    permissions = [
        f"GRANT ALL ON SCHEMA public TO {DB_USER};",
        f"GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO {DB_USER};",
        f"GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO {DB_USER};"
    ]

    for perm in permissions:
        run_psql(perm, as_postgres=True)

    print("   ✓ Berechtigungen gesetzt")

    # Schritt 5: Dump entpacken
    current_step += 1
    print_step(current_step, total_steps, "Entpacke Dump...")

    sql_file = DUMP_DIR / "dekanat_postgres_dump.sql"

    try:
        with gzip.open(DUMP_FILE, 'rb') as f_in:
            with open(sql_file, 'wb') as f_out:
                f_out.write(f_in.read())
        print("   ✓ Dump entpackt")
    except Exception as e:
        print(f"   ✗ Entpacken fehlgeschlagen: {e}")
        sys.exit(1)

    # Schritt 6: Import durchführen
    current_step += 1
    print_step(current_step, total_steps, "Importiere Datenbank...")

    env = os.environ.copy()
    env['PGPASSWORD'] = DB_PASSWORD

    import_cmd = f"psql -U {DB_USER} -h {DB_HOST} -d {DB_NAME} < {sql_file}"
    if run_command(import_cmd, env=env):
        print("   ✓ Import erfolgreich")
    else:
        print("   ✗ Import fehlgeschlagen")
        sql_file.unlink(missing_ok=True)
        sys.exit(1)

    # Entpackte Datei löschen
    sql_file.unlink(missing_ok=True)

    # Schritt 7: Verifizierung
    current_step += 1
    print_step(current_step, total_steps, "Verifiziere Import...")

    env = os.environ.copy()
    env['PGPASSWORD'] = DB_PASSWORD

    checks = [
        ("Benutzer", "SELECT COUNT(*) FROM benutzer;"),
        ("Dozenten", "SELECT COUNT(*) FROM dozent;"),
        ("Semester", "SELECT COUNT(*) FROM semester;")
    ]

    all_checks_passed = True
    for table_name, sql in checks:
        result = subprocess.run(
            f'psql -U {DB_USER} -h {DB_HOST} -d {DB_NAME} -t -c "{sql}"',
            shell=True,
            capture_output=True,
            text=True,
            env=env
        )
        if result.returncode == 0:
            count = result.stdout.strip()
            print(f"   ✓ {table_name}: {count} Einträge")
        else:
            print(f"   ✗ {table_name}: Fehler bei Abfrage")
            all_checks_passed = False

    if not all_checks_passed:
        print("\n⚠ Import abgeschlossen, aber Verifizierung fehlgeschlagen!")
        sys.exit(1)

    # Backend neu starten
    print("\n[Extra] Starte Backend-Service neu...")
    if run_command("sudo systemctl restart dekanet"):
        print("   ✓ Backend neu gestartet")

        # Status prüfen
        status = subprocess.run(
            "sudo systemctl is-active dekanet",
            shell=True,
            capture_output=True,
            text=True
        )
        if status.stdout.strip() == "active":
            print("   ✓ Backend läuft")
        else:
            print("   ⚠ Backend-Status unklar - bitte manuell prüfen")
    else:
        print("   ⚠ Backend-Neustart fehlgeschlagen - bitte manuell ausführen")

    # Erfolg
    print_header("✅ IMPORT ERFOLGREICH ABGESCHLOSSEN!")
    print("Nächste Schritte:")
    print("1. Teste den Login: http://172.16.194.152/")
    print("2. Falls alles funktioniert, entferne database_dumps/ aus GitHub")
    print(f"3. Backup wurde gespeichert in: {backup_file}")
    print()

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n✗ Import abgebrochen durch Benutzer")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n✗ Unerwarteter Fehler: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
