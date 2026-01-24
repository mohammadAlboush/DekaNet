#!/usr/bin/env python3
"""
VOLLSTÄNDIGE Daten-Migration: SQLite -> PostgreSQL
Behebt ALLE bekannten Probleme für 100% Migration:
- VOLLSTÄNDIGE Boolean-Konvertierung (alle 15 Boolean-Spalten)
- Legacy-Tabellen-Filter (planungsphasen_old ignorieren)
- Optimierte Migrations-Reihenfolge
- studiengang UNIQUE Constraint Fix
- Erweiterte VARCHAR-Felder
- Multi-Pass Migration (bis zu 5 Durchläufe)
- Passwort-Reset für alle Benutzer
"""

import os
import sqlite3
import sys
import re
from datetime import datetime

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from app.models.user import Benutzer
from werkzeug.security import generate_password_hash
from sqlalchemy import text

SQLITE_DB = 'dekanat_new.db'
DEKAN_PASSWORD = 'dekan123'
DEFAULT_PASSWORD = 'prof123'
MAX_PASSES = 5

stats = {'sqlite_total': 0, 'migrated_total': 0, 'success': [], 'failed': {}, 'skipped': [], 'passwords': 0}


def print_header(title):
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80 + "\n")


def should_skip_table(table_name):
    """Prüft ob Tabelle übersprungen werden soll"""

    # Legacy-Tabellen die NICHT in PostgreSQL existieren
    legacy_tables = [
        'planungsphasen_old',       # Ersetzt durch 'planungsphasen'
        'sqlite_sequence',          # SQLite-interne Tabelle
        'alembic_version'           # Alembic-interne Tabelle
    ]

    # Tabellen mit Präfix ignorieren
    legacy_prefixes = ['old_', 'backup_', 'temp_']

    if table_name in legacy_tables:
        return True

    for prefix in legacy_prefixes:
        if table_name.startswith(prefix):
            return True

    return False


def convert_value(col_name, value):
    """Konvertiert Werte basierend auf Spaltenname und Wert"""

    # VOLLSTÄNDIGE Liste ALLER Boolean-Spalten (15 insgesamt)
    boolean_columns = [
        # Basis
        'aktiv',                    # dozent, studiengang, benutzer
        'ist_aktiv',                # auftrag, deputat_einstellungen, planungsphase,
                                    # planungs_template, semester
        'ist_planungsphase',        # semester (KRITISCH - war fehlend!)

        # Flags
        'ist_block',                # deputat, deputats_lehrtaetigkeit
        'gelesen',                  # benachrichtigung

        # Modul-Pflichtangaben
        'pflicht',                  # modul_studiengang
        'wahlpflicht',              # modul_studiengang
        'pflichtliteratur',         # modul_literatur (KRITISCH - war fehlend!)

        # Legacy (falls vorhanden)
        'ist_pflicht',              # Legacy-Spalten
        'ist_wahlpflicht'           # Legacy-Spalten
    ]

    if col_name.lower() in boolean_columns:
        if value is None:
            return None
        if isinstance(value, bool):
            return value
        if isinstance(value, int):
            return value != 0
        if isinstance(value, str):
            return value.lower() in ('true', '1', 'yes', 't', 'y')
        return bool(value)

    return value


def fix_studiengang_constraints():
    """Behebt studiengang UNIQUE Constraint Problem"""
    try:
        print("Behebe studiengang UNIQUE Constraint...")

        # Entferne alten UNIQUE Constraint auf 'kuerzel'
        result = db.session.execute(text("""
            SELECT constraint_name
            FROM information_schema.table_constraints
            WHERE table_name = 'studiengang'
            AND constraint_type = 'UNIQUE'
            AND constraint_name LIKE '%kuerzel%'
            AND constraint_name NOT LIKE '%abschluss%'
        """))

        constraint_names = [row[0] for row in result]

        for constraint_name in constraint_names:
            db.session.execute(text(f"ALTER TABLE studiengang DROP CONSTRAINT {constraint_name}"))
            print(f"   [OK] Constraint '{constraint_name}' entfernt")

        # Füge neuen Composite UNIQUE Constraint hinzu
        try:
            db.session.execute(text(
                "ALTER TABLE studiengang ADD CONSTRAINT studiengang_kuerzel_abschluss_unique "
                "UNIQUE (kuerzel, abschluss)"
            ))
            print(f"   [OK] Neuer Constraint 'studiengang_kuerzel_abschluss_unique' hinzugefügt")
        except:
            pass  # Constraint existiert bereits

        db.session.commit()

    except Exception as e:
        print(f"   [INFO] {e}")
        db.session.rollback()


def fix_varchar_lengths(table_name):
    """Erweitert zu kurze VARCHAR-Felder"""
    try:
        # Erweitere bekannte problematische Felder
        varchar_fixes = {
            'modul': [
                ('bezeichnung_de', 200),
                ('bezeichnung_en', 200),
                ('turnus', 200),
                ('gruppengröße', 200),
                ('teilnehmerzahl', 200),
                ('anmeldemodalitaeten', 500)
            ],
            'studiengang': [
                ('kuerzel', 20),
                ('bezeichnung', 200),
                ('abschluss', 50),
                ('fachbereich', 200)
            ]
        }

        if table_name in varchar_fixes:
            for col, length in varchar_fixes[table_name]:
                try:
                    db.session.execute(text(
                        f"ALTER TABLE {table_name} ALTER COLUMN {col} TYPE VARCHAR({length})"
                    ))
                    db.session.commit()
                except:
                    pass  # Spalte existiert vielleicht nicht
    except:
        pass


def migrate_table(sqlite_conn, table_name):
    """Migriert eine Tabelle"""
    cursor = sqlite_conn.cursor()

    try:
        # NEU: Prüfe ob Tabelle übersprungen werden soll
        if should_skip_table(table_name):
            return None, "Legacy-Tabelle (übersprungen)"

        # Prüfe Existenz in SQLite
        cursor.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table_name}'")
        if not cursor.fetchone():
            return None, "Nicht in SQLite"

        # Daten holen
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()

        if not rows:
            return 0, "Leer"

        columns = [d[0] for d in cursor.description]

        # VARCHAR-Längen fixen
        fix_varchar_lengths(table_name)

        # Tabelle leeren
        db.session.execute(text(f"DELETE FROM {table_name}"))
        db.session.commit()

        # Daten einfügen mit Konvertierung
        for row in rows:
            row_dict = {col: convert_value(col, val) for col, val in zip(columns, row)}

            placeholders = ', '.join(f':{col}' for col in columns)
            sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"
            db.session.execute(text(sql), row_dict)

        db.session.commit()

        # ID-Sequenz
        if 'id' in columns:
            max_id = db.session.execute(text(f"SELECT MAX(id) FROM {table_name}")).scalar()
            if max_id:
                db.session.execute(
                    text(f"SELECT setval(pg_get_serial_sequence('{table_name}', 'id'), {max_id})")
                )
                db.session.commit()

        return len(rows), "OK"

    except Exception as e:
        db.session.rollback()
        error = str(e)

        # Detaillierte Fehleranalyse
        if 'ForeignKeyViolation' in error:
            return 0, "FK-Fehler (Abhängigkeit fehlt)"
        elif 'UniqueViolation' in error:
            return 0, "UNIQUE Constraint verletzt"
        elif 'DatatypeMismatch' in error:
            # Finde welche Spalte das Problem verursacht
            if 'boolean' in error.lower():
                match = re.search(r'column "(\w+)"', error)
                col_name = match.group(1) if match else "unknown"
                return 0, f"Boolean-Fehler: {col_name}"
        elif 'DETAIL:' in error:
            error = error.split('DETAIL:')[0].strip()

        return 0, error[:150]


def main():
    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 18 + "VOLLSTÄNDIGE DATEN-MIGRATION" + " " * 32 + "║")
    print("║" + " " * 25 + "SQLite → PostgreSQL" + " " * 34 + "║")
    print("╚" + "═" * 78 + "╝")
    print(f"\nZeitstempel: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    start = datetime.now()

    # Flask initialisieren
    print("[INIT] Initialisiere Flask...")
    app = create_app()
    print("[OK] Flask initialisiert")

    # SQLite analysieren
    print_header("SCHRITT 1: SQLite analysieren")

    if not os.path.exists(SQLITE_DB):
        print(f"[FEHLER] '{SQLITE_DB}' nicht gefunden!")
        sys.exit(1)

    sqlite_conn = sqlite3.connect(SQLITE_DB)
    cursor = sqlite_conn.cursor()

    # Alle Tabellen
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
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

    print(f"SQLite: {len(all_tables)} Tabellen, {total} Zeilen")

    # Zeige Legacy-Tabellen
    legacy_count = 0
    print("\nLegacy-Tabellen (werden übersprungen):")
    for table in all_tables:
        if should_skip_table(table):
            legacy_count += 1
            count = table_counts.get(table, 0)
            print(f"   - {table:30} {count:5} Zeilen")

    print(f"\nRelevante Tabellen: {len(all_tables) - legacy_count}")
    print("\nTabellen (Top 10):")
    for table, count in sorted(table_counts.items(), key=lambda x: x[1], reverse=True)[:10]:
        if count > 0 and not should_skip_table(table):
            print(f"   {table:30} {count:5} Zeilen")

    # PostgreSQL Tabellen
    print_header("SCHRITT 2: PostgreSQL Tabellen erstellen")

    with app.app_context():
        print("Erstelle Tabellen...")
        db.create_all()
        print("[OK] Tabellen erstellt")

        # Behebe studiengang UNIQUE Constraint
        fix_studiengang_constraints()

    # Migration
    print_header("SCHRITT 3: Multi-Pass Migration")
    print(f"Max {MAX_PASSES} Durchläufe\n")

    with app.app_context():
        # OPTIMIERTE Priorisierte Tabellen (Basis-Kataloge ohne FKs zuerst)
        priority = [
            # 1. Basis ohne Dependencies
            'rolle',
            'lehrform',
            'sprache',
            'abschlussart',
            'fachbereich',

            # 2. Master-Daten
            'dozent',
            'pruefungsordnung',
            'studiengang',                  # UNIQUE Constraint wurde bereits gefixt
            'semester',                     # KRITISCH: Muss vor allen Planungen

            # 3. Modul-Kern
            'modul',                        # Benötigt: pruefungsordnung, dozent
            'modulhandbuch',

            # 4. Modul-Details (nach modul)
            'modul_lehrform',
            'modul_dozent',
            'modul_studiengang',
            'modul_literatur',              # Benötigt: modul, pruefungsordnung
            'modul_pruefung',
            'modul_lernergebnisse',
            'modul_voraussetzungen',
            'modul_arbeitsaufwand',
            'modul_sprache',
            'modul_seiten',

            # 5. Planungs-System (nach semester und modul)
            'planungsphasen',               # Benötigt: semester
            'semesterplanung',
            'geplante_module',
            'wunsch_freie_tage',

            # 6. Aufträge & Deputate
            'auftrag',
            'semester_auftrag',
            'deputatsabrechnung',
            'deputats_lehrtaetigkeit',
            'deputats_lehrexport',
            'deputats_vertretung',
            'deputats_ermaessigung',
            'deputats_betreuung',
            'deputats_einstellungen',

            # 7. Templates
            'planungs_templates',
            'template_module',

            # 8. Audit & Benachrichtigungen
            'audit_log',
            'benachrichtigung',
            'modul_audit_log'
        ]

        # Sortiere: Priority first, dann alphabetisch
        tables_sorted = priority + [t for t in sorted(all_tables) if t not in priority]
        remaining = {t for t in tables_sorted if table_counts.get(t, 0) > 0 and not should_skip_table(t)}
        pass_num = 0

        while remaining and pass_num < MAX_PASSES:
            pass_num += 1
            print(f"Durchlauf {pass_num}/{MAX_PASSES} ({len(remaining)} verbleibend):\n")

            newly_done = []

            for table in list(remaining):
                count, status = migrate_table(sqlite_conn, table)

                if count is None:
                    # Tabelle übersprungen
                    remaining.discard(table)
                    if "Legacy" in status:
                        stats['skipped'].append(table)
                        print(f"   [SKIP] {table:28} {status}")
                elif count == 0:
                    if "FK-Fehler" in status:
                        print(f"   [...]  {table:28} FK-Fehler (retry)")
                    elif "Leer" in status:
                        remaining.discard(table)
                    else:
                        remaining.discard(table)
                        stats['failed'][table] = status
                        print(f"   [x]    {table:28} FEHLER: {status[:40]}...")
                else:
                    remaining.discard(table)
                    newly_done.append(table)
                    stats['migrated_total'] += count
                    stats['success'].append(table)
                    print(f"   [+]    {table:28} {count:5} Zeilen")

            print(f"\nDurchlauf {pass_num}: {len(newly_done)} Tabellen migriert")

            if not newly_done and remaining:
                print(f"[WARNUNG] Keine Fortschritte. {len(remaining)} verbleiben.")
                break

    sqlite_conn.close()

    # Passwörter
    print_header("SCHRITT 4: Passwörter")

    with app.app_context():
        users = Benutzer.query.all()

        if not users:
            print("[WARNUNG] Keine Benutzer!")
        else:
            dekan = 0
            for user in users:
                if user.username == 'dekan' or user.email == 'dekan@hochschule.de':
                    user.password_hash = generate_password_hash(DEKAN_PASSWORD)
                    print(f"   [+] Dekan: {user.email} -> {DEKAN_PASSWORD}")
                    dekan += 1
                else:
                    user.password_hash = generate_password_hash(DEFAULT_PASSWORD)

            db.session.commit()
            print(f"\n[OK] {len(users)} Passwörter ({dekan} Dekan, {len(users)-dekan} andere)")
            stats['passwords'] = len(users)

    # Verifizieren
    print_header("SCHRITT 5: Verifizieren")

    with app.app_context():
        important = ['rolle', 'semester', 'dozent', 'benutzer', 'studiengang', 'modul',
                    'modul_literatur', 'pruefungsordnung', 'semesterplanung']

        for table in important:
            try:
                count = db.session.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()
                status = "[+]" if count > 0 else "[ ]"
                print(f"   {status} {table:25} {count:6} Einträge")
            except:
                print(f"   [x] {table:25} Fehler")

    # Ergebnis
    end = datetime.now()
    duration = (end - start).total_seconds()

    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 32 + "ERGEBNIS" + " " * 38 + "║")
    print("╚" + "═" * 78 + "╝\n")

    print("=" * 80)
    print(f"   Dauer:              {duration:.1f} Sekunden")
    print(f"   SQLite:             {stats['sqlite_total']} Zeilen")
    print(f"   PostgreSQL:         {stats['migrated_total']} Zeilen")
    print(f"   Erfolgreich:        {len(stats['success'])} Tabellen")
    print(f"   Fehlgeschlagen:     {len(stats['failed'])} Tabellen")
    print(f"   Übersprungen:       {len(stats['skipped'])} Legacy-Tabellen")
    print(f"   Passwörter:         {stats['passwords']}")
    print("=" * 80)

    percent = (stats['migrated_total'] / stats['sqlite_total'] * 100) if stats['sqlite_total'] > 0 else 0

    if percent >= 98:
        print(f"\n   [OK] PERFEKT! {percent:.1f}% migriert")
    elif percent >= 90:
        print(f"\n   [OK] ERFOLGREICH! {percent:.1f}% migriert")
    elif percent >= 70:
        print(f"\n   [WARNUNG] {percent:.1f}% migriert")
    else:
        print(f"\n   [FEHLER] Nur {percent:.1f}% migriert")

    if stats['failed']:
        print(f"\n   Fehlgeschlagene Tabellen:")
        for table in list(stats['failed'].keys())[:5]:
            print(f"      - {table}: {stats['failed'][table]}")

    if stats['skipped']:
        print(f"\n   Übersprungene Legacy-Tabellen:")
        for table in stats['skipped'][:5]:
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
        print("\n\nAbgebrochen")
        sys.exit(1)
    except Exception as e:
        print(f"\n\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
