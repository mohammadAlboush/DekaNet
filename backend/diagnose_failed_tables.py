#!/usr/bin/env python3
"""
Diagnose: Warum schlagen Tabellen fehl?
Testet jede fehlgeschlagene Tabelle einzeln mit vollständiger Fehlermeldung
Speichert Ausgabe in diagnose_failed_output.txt
"""

import os
import sqlite3
import sys
from datetime import datetime

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from sqlalchemy import text

SQLITE_DB = 'dekanat_new.db'
OUTPUT_FILE = 'diagnose_failed_output.txt'

# Tabellen die laut migrate_final.py fehlgeschlagen sind
FAILED_TABLES = ['semester', 'modul_literatur', 'planungsphasen_old']

class OutputLogger:
    def __init__(self, filename):
        self.terminal = sys.stdout
        self.log = open(filename, 'w', encoding='utf-8', errors='replace')

    def write(self, message):
        try:
            self.terminal.write(message)
        except UnicodeEncodeError:
            self.terminal.write(message.encode('ascii', 'replace').decode('ascii'))
        self.log.write(message)

    def flush(self):
        self.terminal.flush()
        self.log.flush()

    def close(self):
        self.log.close()


def convert_value(col_name, value):
    """Konvertiert Boolean-Werte"""
    boolean_columns = ['aktiv', 'ist_aktiv', 'gelesen', 'ist_pflicht', 'ist_wahlpflicht']

    if col_name.lower() in boolean_columns:
        if value is None:
            return None
        if isinstance(value, bool):
            return value
        if isinstance(value, int):
            return value != 0
        return bool(value)
    return value


def test_table_migration(table_name):
    """Testet Migration einer einzelnen Tabelle mit vollem Fehler-Output"""
    print("\n" + "=" * 80)
    print(f"TEST: {table_name}")
    print("=" * 80 + "\n")

    sqlite_conn = sqlite3.connect(SQLITE_DB)
    cursor = sqlite_conn.cursor()

    try:
        # Prüfe ob Tabelle in SQLite existiert
        cursor.execute(f"SELECT name FROM sqlite_master WHERE type='table' AND name='{table_name}'")
        if not cursor.fetchone():
            print(f"[FEHLER] Tabelle '{table_name}' existiert nicht in SQLite!\n")
            sqlite_conn.close()
            return

        # Hole Daten
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()
        columns = [d[0] for d in cursor.description]

        print(f"SQLite:")
        print(f"   Spalten: {len(columns)}")
        print(f"   Zeilen: {len(rows)}")
        print(f"   Spalten-Namen: {', '.join(columns[:10])}")

        if len(rows) > 0:
            print(f"\nErste Zeile (Beispiel):")
            for col, val in zip(columns, rows[0]):
                print(f"   {col:25} = {repr(val):30} ({type(val).__name__})")

        # Prüfe ob Tabelle in PostgreSQL existiert
        print(f"\nPostgreSQL:")
        try:
            result = db.session.execute(text(f"SELECT COUNT(*) FROM {table_name}"))
            count = result.scalar()
            print(f"   Tabelle existiert: Ja")
            print(f"   Aktuelle Zeilen: {count}")
        except Exception as e:
            print(f"   [FEHLER] Tabelle existiert nicht oder ist nicht erreichbar!")
            print(f"   Fehler: {e}")
            sqlite_conn.close()
            return

        # Hole PostgreSQL Spalten-Definition
        result = db.session.execute(text(f"""
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_name = '{table_name}'
            ORDER BY ordinal_position
        """))

        print(f"\n   PostgreSQL Spalten:")
        for row in result:
            col_name = row[0]
            col_type = row[1]
            col_length = row[2]
            if col_length:
                print(f"      {col_name:25} {col_type}({col_length})")
            else:
                print(f"      {col_name:25} {col_type}")

        # Leere Tabelle
        print(f"\nLeere Tabelle...")
        db.session.execute(text(f"DELETE FROM {table_name}"))
        db.session.commit()
        print("[OK] Tabelle geleert")

        # Versuche erste Zeile einzufügen
        if len(rows) > 0:
            print(f"\nVersuche erste Zeile einzufügen...")

            row_dict = {col: convert_value(col, val) for col, val in zip(columns, rows[0])}

            print(f"\nKonvertierte Werte:")
            for col, val in row_dict.items():
                print(f"   {col:25} = {repr(val):30} ({type(val).__name__})")

            placeholders = ', '.join(f':{col}' for col in columns)
            sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"

            print(f"\nSQL: {sql}")

            try:
                db.session.execute(text(sql), row_dict)
                db.session.commit()
                print("\n[OK] Erste Zeile erfolgreich eingefügt!")

                # Versuche alle Zeilen
                print(f"\nVersuche alle {len(rows)} Zeilen einzufügen...")
                db.session.execute(text(f"DELETE FROM {table_name}"))

                success_count = 0
                for i, row in enumerate(rows):
                    row_dict = {col: convert_value(col, val) for col, val in zip(columns, row)}
                    db.session.execute(text(sql), row_dict)
                    success_count += 1

                    if (i + 1) % 50 == 0:
                        print(f"   {i + 1}/{len(rows)} Zeilen...")

                db.session.commit()
                print(f"\n[OK] Alle {success_count} Zeilen erfolgreich eingefügt!")

            except Exception as e:
                db.session.rollback()
                print(f"\n[FEHLER] Einfügen fehlgeschlagen!")
                print(f"\nFehlertyp: {type(e).__name__}")
                print(f"\nVollständige Fehlermeldung:")
                print(f"{str(e)}")

                # Extrahiere Details
                error_str = str(e)
                if 'DETAIL:' in error_str:
                    print(f"\nDETAIL:")
                    detail = error_str.split('DETAIL:')[1].split('\n')[0]
                    print(f"   {detail}")

                if 'ForeignKeyViolation' in error_str:
                    print(f"\n[ANALYSE] Foreign Key Violation")
                    print(f"   Die referenzierte Tabelle enthält die benötigten Daten nicht.")
                    print(f"   Prüfe welche Tabellen {table_name} referenziert:")

                    # Zeige FK Constraints
                    result = db.session.execute(text(f"""
                        SELECT
                            kcu.column_name,
                            ccu.table_name AS foreign_table_name,
                            ccu.column_name AS foreign_column_name
                        FROM information_schema.table_constraints AS tc
                        JOIN information_schema.key_column_usage AS kcu
                          ON tc.constraint_name = kcu.constraint_name
                        JOIN information_schema.constraint_column_usage AS ccu
                          ON ccu.constraint_name = tc.constraint_name
                        WHERE tc.constraint_type = 'FOREIGN KEY'
                        AND tc.table_name = '{table_name}'
                    """))

                    for row in result:
                        print(f"      {row[0]} -> {row[1]}.{row[2]}")

                if 'value too long' in error_str.lower():
                    print(f"\n[ANALYSE] VARCHAR zu kurz")
                    print(f"   Ein Wert ist länger als die definierte VARCHAR-Länge.")

                if 'datatype' in error_str.lower():
                    print(f"\n[ANALYSE] Datatype Mismatch")
                    print(f"   Boolean-Konvertierung könnte fehlen.")

    except Exception as e:
        print(f"\n[FEHLER] Unerwarteter Fehler!")
        print(f"Fehler: {e}")
        import traceback
        traceback.print_exc()

    finally:
        sqlite_conn.close()


def main():
    logger = OutputLogger(OUTPUT_FILE)
    sys.stdout = logger

    print("=" * 80)
    print("DIAGNOSE: Fehlgeschlagene Tabellen analysieren")
    print(f"Zeitstempel: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)

    app = create_app()

    with app.app_context():
        for table in FAILED_TABLES:
            test_table_migration(table)

    print("\n" + "=" * 80)
    print("DIAGNOSE ABGESCHLOSSEN")
    print("=" * 80)

    logger.close()
    sys.stdout = logger.terminal

    print(f"\n[OK] Diagnose abgeschlossen! Ergebnisse in: {OUTPUT_FILE}")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
