#!/usr/bin/env python3
"""
SMARTE Daten-Migration: SQLite -> PostgreSQL
- Liest ALLE Tabellen aus SQLite automatisch
- Migriert in mehreren Durchläufen bis alle erfolgreich
- Löst Foreign Key Probleme automatisch durch Retry
- Konvertiert Boolean-Werte (0/1 -> TRUE/FALSE)
"""

import os
import sqlite3
import sys
from datetime import datetime

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from app.models.user import Benutzer
from werkzeug.security import generate_password_hash
from sqlalchemy import text, inspect

SQLITE_DB = 'dekanat_new.db'
DEKAN_PASSWORD = 'dekan123'
DEFAULT_PASSWORD = 'prof123'
MAX_RETRIES = 5  # Maximale Anzahl Durchläufe

stats = {'sqlite_total': 0, 'migrated_total': 0, 'success': [], 'failed': {}, 'passwords': 0, 'duration': 0}


def print_header(title):
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80 + "\n")


def convert_boolean(value):
    """Konvertiert SQLite Boolean zu PostgreSQL"""
    if value is None:
        return None
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value != 0
    if isinstance(value, str):
        return value.lower() in ('true', '1', 'yes', 't', 'y')
    return bool(value)


def get_boolean_columns(cursor, table_name):
    """Identifiziert Boolean-Spalten"""
    cursor.execute(f"PRAGMA table_info({table_name})")
    return [col[1] for col in cursor.fetchall() if 'BOOL' in (col[2] or '').upper()]


def migrate_table(sqlite_conn, table_name):
    """Migriert eine Tabelle"""
    cursor = sqlite_conn.cursor()

    try:
        # Prüfe Existenz
        cursor.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table_name}'")
        if not cursor.fetchone():
            return None, "Existiert nicht"

        # Boolean-Spalten
        bool_cols = get_boolean_columns(cursor, table_name)

        # Daten holen
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()

        if not rows:
            return 0, "Leer"

        columns = [d[0] for d in cursor.description]

        # Tabelle leeren
        db.session.execute(text(f"DELETE FROM {table_name}"))
        db.session.commit()

        # Daten einfügen
        for row in rows:
            row_dict = {col: (convert_boolean(val) if col in bool_cols else val)
                       for col, val in zip(columns, row)}

            placeholders = ', '.join(f':{col}' for col in columns)
            sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"
            db.session.execute(text(sql), row_dict)

        db.session.commit()

        # ID-Sequenz
        if 'id' in columns:
            max_id = db.session.execute(text(f"SELECT MAX(id) FROM {table_name}")).scalar()
            if max_id:
                db.session.execute(text(f"SELECT setval(pg_get_serial_sequence('{table_name}', 'id'), {max_id})"))
                db.session.commit()

        return len(rows), "OK"

    except Exception as e:
        db.session.rollback()
        error = str(e)
        if 'ForeignKeyViolation' in error:
            return 0, "FK-Fehler (Retry)"
        if 'DETAIL:' in error:
            error = error.split('DETAIL:')[0].strip()
        return 0, error[:100]


def main():
    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 18 + "SMARTE DATEN-MIGRATION (FINAL)" + " " * 29 + "║")
    print("║" + " " * 25 + "SQLite → PostgreSQL" + " " * 34 + "║")
    print("╚" + "═" * 78 + "╝")

    start = datetime.now()

    print("\n[INIT] Initialisiere Flask...")
    app = create_app()
    print("[OK] Flask initialisiert")

    # SQLite analysieren
    print_header("SCHRITT 1: SQLite-Datenbank analysieren")

    if not os.path.exists(SQLITE_DB):
        print(f"[FEHLER] '{SQLITE_DB}' nicht gefunden!")
        sys.exit(1)

    sqlite_conn = sqlite3.connect(SQLITE_DB)
    cursor = sqlite_conn.cursor()

    # ALLE Tabellen aus SQLite lesen
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name")
    all_tables = [t[0] for t in cursor.fetchall()]

    # Zeilen zählen
    table_counts = {}
    total = 0
    for table in all_tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        table_counts[table] = count
        total += count

    stats['sqlite_total'] = total

    print(f"SQLite '{SQLITE_DB}':")
    print(f"   - {len(all_tables)} Tabellen gefunden")
    print(f"   - {total} Zeilen insgesamt\n")

    print("Tabellen mit Daten (Top 15):")
    sorted_tables = sorted(table_counts.items(), key=lambda x: x[1], reverse=True)
    for table, count in sorted_tables[:15]:
        if count > 0:
            print(f"   - {table:30} {count:5} Zeilen")

    # PostgreSQL Tabellen
    print_header("SCHRITT 2: PostgreSQL Tabellen erstellen")

    with app.app_context():
        print("Erstelle Tabellen...")
        db.create_all()
        inspector = inspect(db.engine)
        pg_tables = inspector.get_table_names()
        print(f"[OK] {len(pg_tables)} Tabellen erstellt")

    # Smarte Migration in mehreren Durchläufen
    print_header("SCHRITT 3: Smarte Multi-Pass Migration")
    print(f"Strategie: Bis zu {MAX_RETRIES} Durchläufe, bis alle Tabellen migriert sind\n")

    with app.app_context():
        # Priorisierung: Tabellen ohne FKs zuerst
        priority_first = ['rolle', 'semester', 'dozent', 'lehrform', 'pruefungsordnung', 'studiengang',
                         'abschlussart', 'sprache', 'fachbereich']

        # Sortiere: Priority first, dann alphabetisch
        tables_sorted = priority_first + [t for t in sorted(all_tables) if t not in priority_first]

        remaining = set(t for t in tables_sorted if table_counts.get(t, 0) > 0)
        retry_count = 0

        while remaining and retry_count < MAX_RETRIES:
            retry_count += 1
            print(f"Durchlauf {retry_count}/{MAX_RETRIES} ({len(remaining)} verbleibend):\n")

            newly_migrated = []

            for table in list(remaining):
                count, status = migrate_table(sqlite_conn, table)

                if count is None:
                    remaining.discard(table)
                    print(f"   [SKIP] {table:30} Existiert nicht in PostgreSQL")

                elif count == 0:
                    if "FK-Fehler" in status:
                        print(f"   [...]  {table:30} FK-Problem (versuche später)")
                    elif "Leer" in status:
                        remaining.discard(table)
                        print(f"   [ ]    {table:30} Keine Daten")
                    else:
                        remaining.discard(table)
                        stats['failed'][table] = status
                        print(f"   [x]    {table:30} FEHLER")
                        print(f"          -> {status[:60]}")

                else:
                    remaining.discard(table)
                    newly_migrated.append(table)
                    stats['migrated_total'] += count
                    stats['success'].append(table)
                    print(f"   [+]    {table:30} {count:5} Zeilen")

            print(f"\nDurchlauf {retry_count} abgeschlossen: {len(newly_migrated)} Tabellen migriert")

            if not newly_migrated and remaining:
                print(f"[WARNUNG] Keine Fortschritte mehr. {len(remaining)} Tabellen verbleiben.")
                break

    sqlite_conn.close()

    # Passwörter
    print_header("SCHRITT 4: Passwörter setzen")

    with app.app_context():
        users = Benutzer.query.all()

        if not users:
            print("[WARNUNG] Keine Benutzer!")
        else:
            dekan_count = 0
            for user in users:
                if user.username == 'dekan' or user.email == 'dekan@hochschule.de':
                    user.password_hash = generate_password_hash(DEKAN_PASSWORD)
                    print(f"   [+] Dekan: {user.email} -> {DEKAN_PASSWORD}")
                    dekan_count += 1
                else:
                    user.password_hash = generate_password_hash(DEFAULT_PASSWORD)

            db.session.commit()
            print(f"\n[OK] {len(users)} Passwörter gesetzt ({dekan_count} Dekan, {len(users)-dekan_count} andere)")
            stats['passwords'] = len(users)

    # Verifizieren
    print_header("SCHRITT 5: Verifizieren")

    with app.app_context():
        important = ['rolle', 'semester', 'dozent', 'benutzer', 'modul', 'semesterplanung',
                    'pruefungsordnung', 'lehrform', 'studiengang']

        print("Wichtigste Tabellen:\n")
        for table in important:
            try:
                count = db.session.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()
                status = "[+]" if count > 0 else "[ ]"
                print(f"   {status} {table:25} {count:6} Einträge")
            except:
                print(f"   [x] {table:25} Nicht verfügbar")

    # Zusammenfassung
    end = datetime.now()
    stats['duration'] = (end - start).total_seconds()

    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 30 + "ERGEBNIS" + " " * 40 + "║")
    print("╚" + "═" * 78 + "╝\n")

    print("=" * 80)
    print(f"   Dauer:                 {stats['duration']:.1f} Sekunden")
    print(f"   SQLite (Quelle):       {stats['sqlite_total']} Zeilen")
    print(f"   PostgreSQL (Ziel):     {stats['migrated_total']} Zeilen")
    print(f"   Erfolgreich:           {len(stats['success'])} Tabellen")
    print(f"   Fehlgeschlagen:        {len(stats['failed'])} Tabellen")
    print(f"   Benutzer-Passwörter:   {stats['passwords']}")
    print("=" * 80)

    percent = (stats['migrated_total'] / stats['sqlite_total'] * 100) if stats['sqlite_total'] > 0 else 0

    if percent >= 98:
        print(f"\n   [OK] PERFEKT! {percent:.1f}% migriert")
    elif percent >= 90:
        print(f"\n   [OK] ERFOLGREICH! {percent:.1f}% migriert")
    elif percent >= 70:
        print(f"\n   [WARNUNG] Teilweise erfolgreich ({percent:.1f}%)")
    else:
        print(f"\n   [FEHLER] Nur {percent:.1f}% migriert!")

    if stats['failed']:
        print(f"\n   Fehlgeschlagene Tabellen ({len(stats['failed'])}):")
        for table in list(stats['failed'].keys())[:5]:
            print(f"      - {table}")

    print("\n" + "=" * 80)
    print("\nNÄCHSTE SCHRITTE:")
    print("   $ sudo systemctl restart dekanet")
    print("   Browser: http://193.175.86.198/")
    print(f"   Login: dekan@hochschule.de / {DEKAN_PASSWORD}")
    print("=" * 80 + "\n")


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n[WARNUNG] Abgebrochen")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n[FEHLER] {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
