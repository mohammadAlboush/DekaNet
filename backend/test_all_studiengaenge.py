#!/usr/bin/env python3
"""
Test: ALLE Studiengänge migrieren
Speichert Ausgabe in test_all_studiengaenge_output.txt
"""

import os
import sqlite3
import sys
from datetime import datetime

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from sqlalchemy import text

SQLITE_DB = 'dekanat_new.db'
OUTPUT_FILE = 'test_all_studiengaenge_output.txt'

class OutputLogger:
    def __init__(self, filename):
        self.terminal = sys.stdout
        self.log = open(filename, 'w', encoding='utf-8')

    def write(self, message):
        self.terminal.write(message)
        self.log.write(message)

    def flush(self):
        self.terminal.flush()
        self.log.flush()

    def close(self):
        self.log.close()


def convert_value(col_name, value):
    """Konvertiert Boolean-Werte"""
    if col_name.lower() in ['aktiv', 'ist_aktiv']:
        if value is None:
            return None
        if isinstance(value, bool):
            return value
        if isinstance(value, int):
            return value != 0
        return bool(value)
    return value


def main():
    logger = OutputLogger(OUTPUT_FILE)
    sys.stdout = logger

    print("=" * 80)
    print("TEST: ALLE Studiengänge migrieren")
    print(f"Zeitstempel: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80 + "\n")

    # SQLite
    sqlite_conn = sqlite3.connect(SQLITE_DB)
    cursor = sqlite_conn.cursor()

    cursor.execute("SELECT * FROM studiengang")
    rows = cursor.fetchall()
    columns = [d[0] for d in cursor.description]

    print(f"SQLite: {len(rows)} Studiengänge gefunden\n")

    # Flask
    app = create_app()

    with app.app_context():
        # VARCHAR erweitern
        print("Erweitere VARCHAR-Felder...")
        try:
            db.session.execute(text("ALTER TABLE studiengang ALTER COLUMN bezeichnung TYPE VARCHAR(200)"))
            db.session.execute(text("ALTER TABLE studiengang ALTER COLUMN fachbereich TYPE VARCHAR(200)"))
            db.session.commit()
            print("[OK] VARCHAR erweitert\n")
        except Exception as e:
            print(f"[INFO] {e}\n")
            db.session.rollback()

        # Tabelle leeren
        print("Leere Tabelle...")
        db.session.execute(text("DELETE FROM studiengang"))
        db.session.commit()
        print("[OK] Tabelle geleert\n")

        # Alle Zeilen einfügen
        print(f"Füge {len(rows)} Zeilen ein:\n")

        success_count = 0
        failed_count = 0

        for i, row in enumerate(rows, 1):
            # Konvertiere Werte
            row_dict = {col: convert_value(col, val) for col, val in zip(columns, row)}

            try:
                placeholders = ', '.join(f':{col}' for col in columns)
                sql = f"INSERT INTO studiengang ({', '.join(columns)}) VALUES ({placeholders})"
                db.session.execute(text(sql), row_dict)
                db.session.commit()

                print(f"   [{i}/8] [OK] {row_dict['kuerzel']:10} {row_dict['bezeichnung']}")
                success_count += 1

            except Exception as e:
                db.session.rollback()
                print(f"   [{i}/8] [FEHLER] {row_dict.get('kuerzel', '?'):10}")
                print(f"            Zeile: {row_dict}")
                print(f"            Fehler: {e}\n")
                failed_count += 1

        # Zusammenfassung
        print("\n" + "=" * 80)
        print("ZUSAMMENFASSUNG")
        print("=" * 80)
        print(f"   Erfolgreich: {success_count}")
        print(f"   Fehlgeschlagen: {failed_count}")

        if success_count == len(rows):
            print(f"\n   [OK] ALLE {len(rows)} Studiengänge erfolgreich migriert!")
        else:
            print(f"\n   [FEHLER] Nur {success_count}/{len(rows)} migriert")

        # Verifizierung
        print("\n" + "=" * 80)
        print("VERIFIZIERUNG")
        print("=" * 80)

        result = db.session.execute(text("SELECT kuerzel, bezeichnung, aktiv FROM studiengang ORDER BY id"))
        print("\nStudiengänge in PostgreSQL:")
        for row in result:
            print(f"   {row[0]:10} {row[1]:40} aktiv={row[2]}")

    sqlite_conn.close()

    logger.close()
    sys.stdout = logger.terminal

    print(f"\n[OK] Test abgeschlossen! Ausgabe in: {OUTPUT_FILE}")
    print("Jetzt:")
    print(f"   git add {OUTPUT_FILE}")
    print(f"   git commit -m 'test: all studiengaenge migration'")
    print(f"   git push")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
