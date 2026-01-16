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

# Statistik-Tracking
stats = {
    'sqlite_tables': {},
    'migrated_tables': {},
    'skipped_tables': [],
    'failed_tables': {},
    'created_tables': [],
    'password_stats': {},
    'final_counts': {},
    'duration': 0
}


def print_header(title):
    """Gibt einen formatierten Header aus"""
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80 + "\n")


def analyze_sqlite(app):
    """Analysiert SQLite-Datenbank"""
    print_header("ANALYSE: SQLite-Datenbank")

    if not os.path.exists(SQLITE_DB):
        print(f"[FEHLER] SQLite-Datenbank '{SQLITE_DB}' nicht gefunden!")
        print(f"   Aktuelles Verzeichnis: {os.getcwd()}")
        return False

    sqlite_conn = sqlite3.connect(SQLITE_DB)
    sqlite_cursor = sqlite_conn.cursor()

    # Hole alle Tabellen
    sqlite_cursor.execute("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
    tables = sqlite_cursor.fetchall()

    print(f"SQLite-Datenbank '{SQLITE_DB}' gefunden!\n")
    print("Tabellen und Inhalte:\n")

    total_rows = 0
    for table in tables:
        table_name = table[0]
        sqlite_cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        count = sqlite_cursor.fetchone()[0]
        stats['sqlite_tables'][table_name] = count
        total_rows += count

        status = "[+]" if count > 0 else "[ ]"
        print(f"   {status} {table_name:30} {count:6} Zeilen")

    sqlite_conn.close()

    print(f"\n[OK] SQLite-Analyse abgeschlossen:")
    print(f"   - {len(tables)} Tabellen gefunden")
    print(f"   - {total_rows} Zeilen insgesamt")

    return True


def create_tables(app):
    """Erstellt alle Tabellen in PostgreSQL"""
    print_header("SCHRITT 1: PostgreSQL Tabellen erstellen")

    with app.app_context():
        print("Erstelle alle Tabellen in PostgreSQL...")
        db.create_all()

        # Zeige erstellte Tabellen
        inspector = inspect(db.engine)
        tables = inspector.get_table_names()
        stats['created_tables'] = sorted(tables)

        print(f"\n[OK] {len(tables)} Tabellen erstellt")

    return True


def migrate_data(app):
    """Migriert alle Daten von SQLite zu PostgreSQL"""
    print_header("SCHRITT 2: Daten migrieren")

    if not os.path.exists(SQLITE_DB):
        print(f"[FEHLER] SQLite-Datenbank '{SQLITE_DB}' nicht gefunden!")
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

        for table in tables:
            try:
                # Prüfe ob Tabelle in SQLite existiert
                sqlite_cursor.execute(
                    f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table}'"
                )
                if not sqlite_cursor.fetchone():
                    print(f"   [SKIP] {table}: Existiert nicht in SQLite")
                    stats['skipped_tables'].append(table)
                    continue

                # Hole alle Daten aus SQLite
                sqlite_cursor.execute(f"SELECT * FROM {table}")
                rows = sqlite_cursor.fetchall()

                if not rows:
                    print(f"   [ ] {table}: 0 Zeilen (leer)")
                    stats['migrated_tables'][table] = 0
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

                print(f"   [+] {table}: {len(rows)} Zeilen migriert")
                stats['migrated_tables'][table] = len(rows)

            except Exception as e:
                error_msg = str(e)[:100]
                print(f"   [x] {table}: FEHLER - {error_msg}")
                stats['failed_tables'][table] = error_msg
                db.session.rollback()

        sqlite_conn.close()

    return True


def reset_passwords(app):
    """Setzt alle Passwörter neu"""
    print_header("SCHRITT 3: Passwörter neu setzen")

    with app.app_context():
        users = Benutzer.query.all()

        if not users:
            print("[WARNUNG] Keine Benutzer gefunden!")
            stats['password_stats'] = {'error': 'Keine Benutzer gefunden'}
            return False

        dekan_count = 0
        other_count = 0

        for user in users:
            if user.username == 'dekan' or user.email == 'dekan@hochschule.de':
                user.password_hash = generate_password_hash(DEKAN_PASSWORD)
                print(f"   [+] Dekan: {user.email} → {DEKAN_PASSWORD}")
                dekan_count += 1
            else:
                user.password_hash = generate_password_hash(DEFAULT_PASSWORD)
                other_count += 1

        db.session.commit()

        print(f"\n[OK] Passwörter gesetzt:")
        print(f"   - {dekan_count} Dekan(e) → {DEKAN_PASSWORD}")
        print(f"   - {other_count} andere Benutzer → {DEFAULT_PASSWORD}")

        stats['password_stats'] = {
            'dekan': dekan_count,
            'others': other_count,
            'total': len(users)
        }

    return True


def verify_data(app):
    """Prüft ob alle Daten korrekt migriert wurden"""
    print_header("SCHRITT 4: Daten-Vollständigkeit prüfen")

    with app.app_context():
        tables_to_check = [
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
            'modul_audit_log'
        ]

        print("PostgreSQL Datenbank-Inhalt:\n")

        for table in tables_to_check:
            try:
                result = db.session.execute(
                    text(f"SELECT COUNT(*) FROM {table}")
                ).scalar()

                stats['final_counts'][table] = result
                status = "[+]" if result > 0 else "[ ]"
                print(f"   {status} {table:30} {result:6} Einträge")
            except Exception as e:
                print(f"   [x] {table:30} FEHLER")
                stats['final_counts'][table] = 0

    return True


def print_final_summary():
    """Gibt detaillierte End-Statistik aus"""
    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 24 + "MIGRATIONS-STATISTIK" + " " * 34 + "║")
    print("╚" + "═" * 78 + "╝\n")

    # SQLite Analyse
    print("═" * 80)
    print("1. SQLite-Datenbank (Quelle)")
    print("═" * 80)
    total_sqlite = sum(stats['sqlite_tables'].values())
    print(f"   Tabellen mit Daten: {len([t for t, c in stats['sqlite_tables'].items() if c > 0])}")
    print(f"   Gesamt-Zeilen:      {total_sqlite}")

    if stats['sqlite_tables']:
        print("\n   Top 5 größte Tabellen:")
        sorted_tables = sorted(stats['sqlite_tables'].items(), key=lambda x: x[1], reverse=True)[:5]
        for table, count in sorted_tables:
            print(f"      • {table:25} {count:6} Zeilen")

    # PostgreSQL Tabellen
    print("\n" + "═" * 80)
    print("2. PostgreSQL-Tabellen erstellt")
    print("═" * 80)
    print(f"   Anzahl: {len(stats['created_tables'])} Tabellen")

    # Migration Erfolg
    print("\n" + "═" * 80)
    print("3. Daten-Migration")
    print("═" * 80)
    total_migrated = sum(stats['migrated_tables'].values())
    print(f"   [+] Erfolgreich migriert: {len(stats['migrated_tables'])} Tabellen ({total_migrated} Zeilen)")

    if stats['migrated_tables']:
        print("\n   Details:")
        for table, count in sorted(stats['migrated_tables'].items()):
            print(f"      • {table:25} {count:6} Zeilen")

    if stats['skipped_tables']:
        print(f"\n   [SKIP] Übersprungen: {len(stats['skipped_tables'])} Tabellen")
        for table in stats['skipped_tables']:
            print(f"      • {table}")

    if stats['failed_tables']:
        print(f"\n   [x] FEHLER: {len(stats['failed_tables'])} Tabellen")
        for table, error in stats['failed_tables'].items():
            print(f"      • {table}: {error[:60]}...")

    # Passwörter
    print("\n" + "═" * 80)
    print("4. Passwort-Reset")
    print("═" * 80)
    if 'error' in stats['password_stats']:
        print(f"   [x] FEHLER: {stats['password_stats']['error']}")
    else:
        print(f"   [+] Dekan-Accounts:  {stats['password_stats'].get('dekan', 0)} → Passwort: {DEKAN_PASSWORD}")
        print(f"   [+] Andere Benutzer: {stats['password_stats'].get('others', 0)} → Passwort: {DEFAULT_PASSWORD}")
        print(f"   [+] Gesamt:          {stats['password_stats'].get('total', 0)} Benutzer")

    # Finale Datenbank
    print("\n" + "═" * 80)
    print("5. PostgreSQL Datenbank-Inhalt (Final)")
    print("═" * 80)
    total_final = sum(stats['final_counts'].values())
    tables_with_data = len([c for c in stats['final_counts'].values() if c > 0])
    print(f"   Tabellen mit Daten: {tables_with_data}")
    print(f"   Gesamt-Einträge:    {total_final}")

    print("\n   Wichtigste Tabellen:")
    important = ['benutzer', 'dozent', 'modul', 'semester', 'semesterplanung', 'rolle']
    for table in important:
        if table in stats['final_counts']:
            count = stats['final_counts'][table]
            status = "[+]" if count > 0 else "[x]"
            print(f"      {status} {table:20} {count:6} Einträge")

    # Zusammenfassung
    print("\n" + "═" * 80)
    print("ZUSAMMENFASSUNG")
    print("═" * 80)
    print(f"   Dauer:              {stats['duration']:.2f} Sekunden")
    print(f"   SQLite → PostgreSQL: {total_sqlite} → {total_final} Zeilen")

    if total_final == 0:
        print("\n   [FEHLER] KRITISCH: PostgreSQL-Datenbank ist leer!")
        print("   Mögliche Ursachen:")
        print("      • SQLite-Datenbank enthält keine Daten")
        print("      • Tabellennamen stimmen nicht überein")
        print("      • Migration wurde abgebrochen")
    elif total_final < total_sqlite * 0.8:
        print(f"\n   [WARNUNG] Nur {(total_final/total_sqlite*100):.1f}% der Daten migriert!")
    else:
        print("\n   [OK] Migration erfolgreich!")

    print("\n" + "═" * 80 + "\n")


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

    # Analyse SQLite
    if not analyze_sqlite(app):
        print("\n[FEHLER] FEHLER bei SQLite-Analyse!")
        sys.exit(1)

    # Schritt 1: Tabellen erstellen
    if not create_tables(app):
        print("\n[FEHLER] FEHLER beim Erstellen der Tabellen!")
        sys.exit(1)

    # Schritt 2: Daten migrieren
    migrate_data(app)

    # Schritt 3: Passwörter setzen
    reset_passwords(app)

    # Schritt 4: Daten prüfen
    verify_data(app)

    # Dauer berechnen
    end_time = datetime.now()
    stats['duration'] = (end_time - start_time).total_seconds()

    # FINALE STATISTIK
    print_final_summary()

    # Nächste Schritte
    print("NÄCHSTE SCHRITTE:")
    print("═" * 80)
    print("   1. Backend neu starten:")
    print("      $ sudo systemctl restart dekanet")
    print()
    print("   2. Login testen:")
    print("      Browser: http://193.175.86.198/")
    print(f"      Email:    dekan@hochschule.de")
    print(f"      Passwort: {DEKAN_PASSWORD}")
    print()
    print("═" * 80 + "\n")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[WARNUNG]  Migration abgebrochen durch Benutzer")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n[FEHLER] UNERWARTETER FEHLER: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
