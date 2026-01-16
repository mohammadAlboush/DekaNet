#!/usr/bin/env python3
"""
Komplette Daten-Migration: SQLite -> PostgreSQL
Führt alle Schritte automatisch durch
"""

import os
import sqlite3
import sys
from datetime import datetime

# PostgreSQL Connection String
os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from app.models.user import Benutzer
from werkzeug.security import generate_password_hash
from sqlalchemy import text, inspect

# SQLite Datenbank
SQLITE_DB = 'dekanat_new.db'

# Dekan Credentials
DEKAN_PASSWORD = 'dekan123'
DEFAULT_PASSWORD = 'prof123'


def print_header(title):
    """Gibt einen formatierten Header aus"""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80 + "\n")


def create_tables(app):
    """Erstellt alle Tabellen in PostgreSQL"""
    print_header("SCHRITT 1: Tabellen erstellen")

    with app.app_context():
        print("Erstelle alle Tabellen in PostgreSQL...")
        db.create_all()

        # Zeige erstellte Tabellen
        inspector = inspect(db.engine)
        tables = inspector.get_table_names()

        print(f"✅ {len(tables)} Tabellen erstellt:\n")
        for table in sorted(tables):
            print(f"   - {table}")

    return True


def migrate_data(app):
    """Migriert alle Daten von SQLite zu PostgreSQL"""
    print_header("SCHRITT 2: Daten migrieren")

    if not os.path.exists(SQLITE_DB):
        print(f"❌ FEHLER: SQLite-Datenbank '{SQLITE_DB}' nicht gefunden!")
        print(f"   Aktuelles Verzeichnis: {os.getcwd()}")
        return False

    with app.app_context():
        # SQLite verbinden
        sqlite_conn = sqlite3.connect(SQLITE_DB)
        sqlite_conn.row_factory = sqlite3.Row
        sqlite_cursor = sqlite_conn.cursor()

        # Tabellen in richtiger Reihenfolge (Foreign Keys beachten)
        tables = [
            'rolle',
            'semester',
            'dozent',
            'benutzer',
            'modul',
            'auftrag',
            'semesterplanung',
            'semester_auftrag',
            'planungsphasen',
            'phase_submissions',
            'deputatsabrechnung',
            'deputats_einstellungen',
            'benachrichtigung',
            'audit_log',
            'modul_audit_log',
            'archivierte_planungen',
            'planungs_templates'
        ]

        total_rows = 0
        migrated_tables = 0

        for table in tables:
            try:
                # Prüfe ob Tabelle in SQLite existiert
                sqlite_cursor.execute(
                    f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table}'"
                )
                if not sqlite_cursor.fetchone():
                    print(f"   ⊘ {table}: Existiert nicht in SQLite")
                    continue

                # Hole alle Daten aus SQLite
                sqlite_cursor.execute(f"SELECT * FROM {table}")
                rows = sqlite_cursor.fetchall()

                if not rows:
                    print(f"   ○ {table}: 0 Zeilen (leer)")
                    continue

                # Spalten-Namen
                columns = [description[0] for description in sqlite_cursor.description]

                # Tabelle leeren
                db.session.execute(text(f"DELETE FROM {table}"))

                # Daten einfügen
                for row in rows:
                    placeholders = ', '.join([f':{col}' for col in columns])
                    sql = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
                    db.session.execute(text(sql), dict(zip(columns, row)))

                db.session.commit()

                # ID-Sequenz zurücksetzen (für autoincrement)
                if 'id' in columns:
                    result = db.session.execute(
                        text(f"SELECT MAX(id) FROM {table}")
                    ).scalar()
                    if result:
                        db.session.execute(
                            text(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), {result})")
                        )
                        db.session.commit()

                print(f"   ✓ {table}: {len(rows)} Zeilen migriert")
                total_rows += len(rows)
                migrated_tables += 1

            except Exception as e:
                print(f"   ✗ {table}: FEHLER - {str(e)}")
                db.session.rollback()

        sqlite_conn.close()

        print(f"\n✅ Migration abgeschlossen:")
        print(f"   - {migrated_tables} Tabellen migriert")
        print(f"   - {total_rows} Zeilen insgesamt")

    return True


def reset_passwords(app):
    """Setzt alle Passwörter neu"""
    print_header("SCHRITT 3: Passwörter neu setzen")

    with app.app_context():
        users = Benutzer.query.all()

        if not users:
            print("⚠️  WARNUNG: Keine Benutzer gefunden!")
            return False

        dekan_count = 0
        other_count = 0

        for user in users:
            if user.username == 'dekan' or user.email == 'dekan@hochschule.de':
                user.password_hash = generate_password_hash(DEKAN_PASSWORD)
                print(f"   ✓ Dekan: {user.email} → {DEKAN_PASSWORD}")
                dekan_count += 1
            else:
                user.password_hash = generate_password_hash(DEFAULT_PASSWORD)
                other_count += 1

        db.session.commit()

        print(f"\n✅ Passwörter gesetzt:")
        print(f"   - {dekan_count} Dekan(e) → {DEKAN_PASSWORD}")
        print(f"   - {other_count} andere Benutzer → {DEFAULT_PASSWORD}")
        print(f"   - {len(users)} Benutzer insgesamt")

    return True


def verify_data(app):
    """Prüft ob alle Daten korrekt migriert wurden"""
    print_header("SCHRITT 4: Daten-Vollständigkeit prüfen")

    with app.app_context():
        tables_to_check = [
            ('rolle', 'Rollen'),
            ('semester', 'Semester'),
            ('dozent', 'Dozenten'),
            ('benutzer', 'Benutzer'),
            ('modul', 'Module'),
            ('auftrag', 'Aufträge'),
            ('semesterplanung', 'Semesterplanungen')
        ]

        print("Datenbank-Inhalt:\n")

        for table, label in tables_to_check:
            try:
                result = db.session.execute(
                    text(f"SELECT COUNT(*) FROM {table}")
                ).scalar()

                status = "✓" if result > 0 else "○"
                print(f"   {status} {label:20} {result:5} Einträge")
            except Exception as e:
                print(f"   ✗ {label:20} FEHLER: {e}")

    return True


def main():
    """Hauptfunktion - Führt alle Schritte durch"""
    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 20 + "KOMPLETTE DATEN-MIGRATION" + " " * 33 + "║")
    print("║" + " " * 20 + "SQLite → PostgreSQL" + " " * 39 + "║")
    print("╚" + "═" * 78 + "╝")

    start_time = datetime.now()

    # Flask App erstellen
    print("\n[INIT] Initialisiere Flask-Anwendung...")
    app = create_app()
    print("[OK] Flask-Anwendung initialisiert\n")

    # Schritt 1: Tabellen erstellen
    if not create_tables(app):
        print("\n❌ FEHLER beim Erstellen der Tabellen!")
        sys.exit(1)

    # Schritt 2: Daten migrieren
    if not migrate_data(app):
        print("\n❌ FEHLER bei der Daten-Migration!")
        sys.exit(1)

    # Schritt 3: Passwörter setzen
    if not reset_passwords(app):
        print("\n❌ FEHLER beim Setzen der Passwörter!")
        sys.exit(1)

    # Schritt 4: Daten prüfen
    verify_data(app)

    # Zusammenfassung
    end_time = datetime.now()
    duration = (end_time - start_time).total_seconds()

    print_header("✅ MIGRATION ERFOLGREICH ABGESCHLOSSEN!")

    print(f"Dauer: {duration:.2f} Sekunden\n")
    print("Nächste Schritte:")
    print("   1. Backend neu starten: sudo systemctl restart dekanet")
    print("   2. Login testen: http://193.175.86.198/")
    print(f"   3. Anmelden mit: dekan@hochschule.de / {DEKAN_PASSWORD}")
    print("\n" + "=" * 80 + "\n")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Migration abgebrochen durch Benutzer")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ UNERWARTETER FEHLER: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
