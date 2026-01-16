#!/usr/bin/env python3
"""
Komplette Daten-Migration: SQLite -> PostgreSQL (Version 2 - Fixed)
- Deaktiviert Foreign Keys während Migration
- Konvertiert Boolean-Werte korrekt (0/1 -> TRUE/FALSE)
- Migriert alle Tabellen in richtiger Reihenfolge
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

# Statistik
stats = {
    'sqlite_total': 0,
    'migrated_total': 0,
    'tables_success': [],
    'tables_failed': [],
    'password_count': 0,
    'duration': 0
}


def print_header(title):
    """Formatierter Header"""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80 + "\n")


def convert_boolean(value):
    """Konvertiert SQLite Boolean (0/1) zu PostgreSQL Boolean"""
    if value is None:
        return None
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value != 0
    if isinstance(value, str):
        return value.lower() in ('true', '1', 'yes', 't', 'y')
    return bool(value)


def get_table_schema(cursor, table_name):
    """Holt Schema-Informationen einer Tabelle"""
    cursor.execute(f"PRAGMA table_info({table_name})")
    columns_info = cursor.fetchall()

    # columns_info format: (cid, name, type, notnull, dflt_value, pk)
    boolean_columns = []
    for col in columns_info:
        col_type = col[2].upper()
        if 'BOOLEAN' in col_type or 'BOOL' in col_type:
            boolean_columns.append(col[1])  # col[1] is column name

    return boolean_columns


def migrate_table(sqlite_conn, table_name, app):
    """Migriert eine einzelne Tabelle"""
    sqlite_cursor = sqlite_conn.cursor()

    # Prüfe ob Tabelle existiert
    sqlite_cursor.execute(
        f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table_name}'"
    )
    if not sqlite_cursor.fetchone():
        return None, "Tabelle existiert nicht in SQLite"

    # Hole Schema-Informationen
    boolean_columns = get_table_schema(sqlite_cursor, table_name)

    # Hole alle Daten
    sqlite_cursor.execute(f"SELECT * FROM {table_name}")
    rows = sqlite_cursor.fetchall()

    if not rows:
        return 0, "Keine Daten"

    # Spalten-Namen
    columns = [description[0] for description in sqlite_cursor.description]

    try:
        # Tabelle leeren
        db.session.execute(text(f"DELETE FROM {table_name}"))

        # Daten einfügen mit Boolean-Konvertierung
        for row in rows:
            row_dict = {}
            for col_name, col_value in zip(columns, row):
                if col_name in boolean_columns:
                    row_dict[col_name] = convert_boolean(col_value)
                else:
                    row_dict[col_name] = col_value

            placeholders = ', '.join([f':{col}' for col in columns])
            sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"
            db.session.execute(text(sql), row_dict)

        db.session.commit()

        # ID-Sequenz zurücksetzen
        if 'id' in columns:
            max_id = db.session.execute(text(f"SELECT MAX(id) FROM {table_name}")).scalar()
            if max_id:
                db.session.execute(
                    text(f"SELECT setval(pg_get_serial_sequence('{table_name}', 'id'), {max_id})")
                )
                db.session.commit()

        return len(rows), "Erfolg"

    except Exception as e:
        db.session.rollback()
        return 0, str(e)[:150]


def main():
    """Hauptfunktion"""
    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 15 + "KOMPLETTE DATEN-MIGRATION (V2 - FIXED)" + " " * 24 + "║")
    print("║" + " " * 20 + "SQLite → PostgreSQL" + " " * 39 + "║")
    print("╚" + "═" * 78 + "╝")

    start_time = datetime.now()

    # Flask App initialisieren
    print("\n[INIT] Initialisiere Flask-Anwendung...")
    app = create_app()
    print("[OK] Flask-Anwendung initialisiert")

    # SQLite-Datenbank prüfen
    print_header("SCHRITT 1: SQLite-Datenbank analysieren")

    if not os.path.exists(SQLITE_DB):
        print(f"[FEHLER] SQLite-Datenbank '{SQLITE_DB}' nicht gefunden!")
        print(f"Aktuelles Verzeichnis: {os.getcwd()}")
        sys.exit(1)

    sqlite_conn = sqlite3.connect(SQLITE_DB)
    sqlite_cursor = sqlite_conn.cursor()

    # Tabellen zählen
    sqlite_cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
    all_tables = [t[0] for t in sqlite_cursor.fetchall()]

    total_rows = 0
    for table in all_tables:
        sqlite_cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = sqlite_cursor.fetchone()[0]
        total_rows += count

    stats['sqlite_total'] = total_rows
    print(f"SQLite-Datenbank gefunden:")
    print(f"   - {len(all_tables)} Tabellen")
    print(f"   - {total_rows} Zeilen insgesamt")

    # PostgreSQL Tabellen erstellen
    print_header("SCHRITT 2: PostgreSQL Tabellen erstellen")

    with app.app_context():
        print("Erstelle alle Tabellen...")
        db.create_all()

        inspector = inspect(db.engine)
        pg_tables = inspector.get_table_names()
        print(f"[OK] {len(pg_tables)} Tabellen erstellt")

    # Daten migrieren
    print_header("SCHRITT 3: Daten migrieren (Foreign Keys deaktiviert)")

    with app.app_context():
        # Deaktiviere Foreign Key Constraints
        print("Deaktiviere Foreign Key Constraints...")
        db.session.execute(text("SET session_replication_role = 'replica'"))
        db.session.commit()
        print("[OK] Foreign Keys deaktiviert\n")

        # Tabellen in optimaler Reihenfolge
        # Wichtig: Eltern-Tabellen ZUERST (keine Foreign Keys)
        # Dann Kinder-Tabellen (mit Foreign Keys)
        tables_order = [
            'rolle',
            'semester',
            'dozent',
            'benutzer',
            'modul',
            'auftrag',
            'planungsphasen',
            'semesterplanung',
            'semester_auftrag',
            'phase_submissions',
            'deputatsabrechnung',
            'deputats_einstellungen',
            'benachrichtigung',
            'audit_log',
            'modul_audit_log',
            'archivierte_planungen',
            'planungs_templates'
        ]

        print("Migriere Tabellen:\n")

        for table in tables_order:
            count, status = migrate_table(sqlite_conn, table, app)

            if count is None:
                print(f"   [SKIP] {table:30} {status}")
            elif count == 0:
                if "Keine Daten" in status:
                    print(f"   [ ] {table:30} {status}")
                else:
                    print(f"   [x] {table:30} FEHLER: {status[:40]}...")
                    stats['tables_failed'].append(table)
            else:
                print(f"   [+] {table:30} {count:5} Zeilen migriert")
                stats['migrated_total'] += count
                stats['tables_success'].append(table)

        # Reaktiviere Foreign Key Constraints
        print("\nReaktiviere Foreign Key Constraints...")
        db.session.execute(text("SET session_replication_role = 'origin'"))
        db.session.commit()
        print("[OK] Foreign Keys reaktiviert")

    sqlite_conn.close()

    # Passwörter neu setzen
    print_header("SCHRITT 4: Passwörter neu setzen")

    with app.app_context():
        users = Benutzer.query.all()

        if not users:
            print("[WARNUNG] Keine Benutzer gefunden!")
        else:
            dekan_count = 0
            other_count = 0

            for user in users:
                if user.username == 'dekan' or user.email == 'dekan@hochschule.de':
                    user.password_hash = generate_password_hash(DEKAN_PASSWORD)
                    print(f"   [+] Dekan: {user.email} -> {DEKAN_PASSWORD}")
                    dekan_count += 1
                else:
                    user.password_hash = generate_password_hash(DEFAULT_PASSWORD)
                    other_count += 1

            db.session.commit()

            print(f"\n[OK] Passwörter gesetzt:")
            print(f"   - {dekan_count} Dekan(e) -> {DEKAN_PASSWORD}")
            print(f"   - {other_count} andere Benutzer -> {DEFAULT_PASSWORD}")
            print(f"   - {len(users)} Benutzer insgesamt")

            stats['password_count'] = len(users)

    # Daten verifizieren
    print_header("SCHRITT 5: Daten-Vollständigkeit prüfen")

    with app.app_context():
        important_tables = ['rolle', 'semester', 'dozent', 'benutzer', 'modul', 'semesterplanung']

        print("PostgreSQL Datenbank-Inhalt:\n")

        final_total = 0
        for table in important_tables:
            try:
                count = db.session.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()
                final_total += count
                status = "[+]" if count > 0 else "[ ]"
                print(f"   {status} {table:25} {count:6} Einträge")
            except:
                print(f"   [x] {table:25} FEHLER")

    # Zusammenfassung
    end_time = datetime.now()
    stats['duration'] = (end_time - start_time).total_seconds()

    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 28 + "ZUSAMMENFASSUNG" + " " * 35 + "║")
    print("╚" + "═" * 78 + "╝\n")

    print("=" * 80)
    print(f"   Dauer:                {stats['duration']:.2f} Sekunden")
    print(f"   SQLite (Quelle):      {stats['sqlite_total']} Zeilen")
    print(f"   PostgreSQL (Ziel):    {stats['migrated_total']} Zeilen")
    print(f"   Erfolgreiche Tabellen: {len(stats['tables_success'])}")
    print(f"   Fehlgeschlagene:       {len(stats['tables_failed'])}")
    print(f"   Benutzer-Passwörter:   {stats['password_count']} gesetzt")

    migration_percent = (stats['migrated_total'] / stats['sqlite_total'] * 100) if stats['sqlite_total'] > 0 else 0

    print("=" * 80)

    if migration_percent >= 95:
        print(f"\n   [OK] Migration erfolgreich! ({migration_percent:.1f}% der Daten migriert)")
    elif migration_percent >= 80:
        print(f"\n   [WARNUNG] Teilweise erfolgreich ({migration_percent:.1f}% der Daten migriert)")
    else:
        print(f"\n   [FEHLER] Migration fehlgeschlagen! Nur {migration_percent:.1f}% der Daten migriert")

    if stats['tables_failed']:
        print(f"\n   Fehlgeschlagene Tabellen:")
        for table in stats['tables_failed']:
            print(f"      - {table}")

    print("\n" + "=" * 80)
    print("\nNÄCHSTE SCHRITTE:")
    print("=" * 80)
    print("   1. Backend neu starten:")
    print("      $ sudo systemctl restart dekanet")
    print()
    print("   2. Login testen:")
    print("      Browser: http://193.175.86.198/")
    print(f"      Email:    dekan@hochschule.de")
    print(f"      Passwort: {DEKAN_PASSWORD}")
    print()
    print("=" * 80 + "\n")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[WARNUNG] Migration abgebrochen durch Benutzer")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n[FEHLER] UNERWARTETER FEHLER: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
