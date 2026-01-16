#!/usr/bin/env python3
"""
Migrations-Diagnose: Analysiert warum Tabellen fehlschlagen
"""

import os
import sqlite3
import sys

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from sqlalchemy import text, inspect

SQLITE_DB = 'dekanat_new.db'


def print_header(title):
    print("\n" + "=" * 80)
    print(f"  {title}")
    print("=" * 80 + "\n")


def analyze_table_dependencies():
    """Analysiert Foreign Key Dependencies in PostgreSQL"""
    print_header("FOREIGN KEY ANALYSE")

    app = create_app()

    with app.app_context():
        # Hole alle FK Constraints
        result = db.session.execute(text("""
            SELECT
                tc.table_name,
                kcu.column_name,
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM information_schema.table_constraints AS tc
            JOIN information_schema.key_column_usage AS kcu
              ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage AS ccu
              ON ccu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'FOREIGN KEY'
            AND tc.table_schema = 'public'
            ORDER BY tc.table_name;
        """))

        fk_map = {}
        for row in result:
            table = row[0]
            col = row[1]
            ref_table = row[2]
            ref_col = row[3]

            if table not in fk_map:
                fk_map[table] = []
            fk_map[table].append(f"{col} -> {ref_table}.{ref_col}")

        print("Tabellen mit Foreign Keys:\n")
        for table in sorted(fk_map.keys()):
            print(f"{table}:")
            for fk in fk_map[table]:
                print(f"   - {fk}")
            print()

        return fk_map


def test_single_table(table_name):
    """Testet Migration einer einzelnen Tabelle mit detaillierten Fehlern"""
    print_header(f"TEST: {table_name}")

    if not os.path.exists(SQLITE_DB):
        print(f"[FEHLER] SQLite DB nicht gefunden!")
        return

    sqlite_conn = sqlite3.connect(SQLITE_DB)
    cursor = sqlite_conn.cursor()

    # Hole Daten aus SQLite
    try:
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()
        columns = [d[0] for d in cursor.description]

        print(f"SQLite-Tabelle '{table_name}':")
        print(f"   - {len(columns)} Spalten: {', '.join(columns[:10])}{'...' if len(columns) > 10 else ''}")
        print(f"   - {len(rows)} Zeilen\n")

        if len(rows) > 0:
            print("Erste Zeile (Beispiel):")
            for col, val in zip(columns, rows[0]):
                print(f"   {col}: {val}")

    except Exception as e:
        print(f"[FEHLER] Kann Daten aus SQLite nicht lesen: {e}")
        sqlite_conn.close()
        return

    # Versuche in PostgreSQL einzufügen
    print(f"\nVersuche Einfügen in PostgreSQL...\n")

    app = create_app()

    with app.app_context():
        try:
            # Lösche existierende Daten
            db.session.execute(text(f"DELETE FROM {table_name}"))
            db.session.commit()
            print("[OK] Tabelle geleert")

            # Versuche erste Zeile einzufügen
            if len(rows) > 0:
                row_dict = dict(zip(columns, rows[0]))

                # Zeige Boolean-Konvertierung
                bool_conversions = []
                for col, val in row_dict.items():
                    if isinstance(val, int) and val in (0, 1):
                        bool_conversions.append(f"{col}: {val} -> {bool(val)}")

                if bool_conversions:
                    print(f"\nBoolean-Konvertierungen:")
                    for conv in bool_conversions[:5]:
                        print(f"   {conv}")

                placeholders = ', '.join(f':{col}' for col in columns)
                sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"

                db.session.execute(text(sql), row_dict)
                db.session.commit()
                print("\n[OK] Erste Zeile erfolgreich eingefügt!")

                # Versuche alle Zeilen
                print(f"\nVersuche alle {len(rows)} Zeilen einzufügen...")

                db.session.execute(text(f"DELETE FROM {table_name}"))

                for i, row in enumerate(rows):
                    row_dict = dict(zip(columns, row))
                    db.session.execute(text(sql), row_dict)

                    if (i + 1) % 100 == 0:
                        print(f"   {i + 1}/{len(rows)} Zeilen...")

                db.session.commit()
                print(f"\n[OK] Alle {len(rows)} Zeilen erfolgreich eingefügt!")

        except Exception as e:
            db.session.rollback()
            print(f"\n[FEHLER] Migration fehlgeschlagen!\n")
            print(f"Fehlertyp: {type(e).__name__}")
            print(f"Fehlermeldung:\n{str(e)}\n")

            # Extrahiere Details
            error_str = str(e)
            if 'DETAIL:' in error_str:
                detail = error_str.split('DETAIL:')[1].split('\n')[0]
                print(f"Detail: {detail}")

            if 'ForeignKeyViolation' in error_str:
                print("\n[HINWEIS] Foreign Key Violation detected!")
                print("Das bedeutet: Die referenzierte Tabelle enthält die benötigten Daten nicht.")

            if 'DatatypeMismatch' in error_str:
                print("\n[HINWEIS] Datatype Mismatch detected!")
                print("Das bedeutet: Boolean-Konvertierung notwendig (0/1 -> TRUE/FALSE)")

    sqlite_conn.close()


def main():
    print("\n" + "╔" + "═" * 78 + "╗")
    print("║" + " " * 25 + "MIGRATIONS-DIAGNOSE" + " " * 34 + "║")
    print("╚" + "═" * 78 + "╝")

    # 1. Analysiere Dependencies
    analyze_table_dependencies()

    # 2. Teste kritische Tabellen
    critical_tables = ['studiengang', 'modul']

    for table in critical_tables:
        test_single_table(table)

    print_header("EMPFEHLUNGEN")
    print("1. Prüfe welche Tabellen studiengang referenziert")
    print("2. Migriere diese Tabellen zuerst")
    print("3. Dann studiengang")
    print("4. Dann modul")
    print()


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
