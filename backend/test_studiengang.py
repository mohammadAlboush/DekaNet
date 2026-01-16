#!/usr/bin/env python3
"""
Test: Studiengang-Migration mit vollem Logging
Speichert Ausgabe in test_studiengang_output.txt
"""

import os
import sqlite3
import sys
from datetime import datetime

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from sqlalchemy import text

SQLITE_DB = 'dekanat_new.db'
OUTPUT_FILE = 'test_studiengang_output.txt'

# Output Logger
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


def convert_boolean(value):
    """Konvertiert 0/1 zu TRUE/FALSE"""
    if value is None:
        return None
    if isinstance(value, bool):
        return value
    if isinstance(value, int):
        return value != 0
    return bool(value)


def main():
    # Aktiviere Output Logging
    logger = OutputLogger(OUTPUT_FILE)
    sys.stdout = logger

    print("=" * 80)
    print("TEST: studiengang-Migration mit detailliertem Logging")
    print(f"Zeitstempel: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Output wird gespeichert in: {OUTPUT_FILE}")
    print("=" * 80 + "\n")

    # SQLite öffnen
    sqlite_conn = sqlite3.connect(SQLITE_DB)
    cursor = sqlite_conn.cursor()

    cursor.execute("SELECT * FROM studiengang LIMIT 1")
    row = cursor.fetchone()
    columns = [d[0] for d in cursor.description]

    print("SQLite-Daten (erste Zeile):")
    for col, val in zip(columns, row):
        print(f"   {col:25} = {val!r:30} (type: {type(val).__name__})")

    # Flask initialisieren
    app = create_app()

    with app.app_context():
        # VARCHAR-Länge anpassen
        print("\nErweitere VARCHAR-Felder...")
        try:
            db.session.execute(text("ALTER TABLE studiengang ALTER COLUMN bezeichnung TYPE VARCHAR(200)"))
            db.session.execute(text("ALTER TABLE studiengang ALTER COLUMN fachbereich TYPE VARCHAR(200)"))
            db.session.commit()
            print("[OK] VARCHAR-Felder erweitert")
        except Exception as e:
            print(f"[INFO] {e}")
            db.session.rollback()

        # Konvertiere Werte
        print("\nKonvertiere Werte:")
        row_dict = {}
        for col, val in zip(columns, row):
            if col.lower() in ['aktiv', 'ist_aktiv']:
                converted = convert_boolean(val)
                row_dict[col] = converted
                print(f"   {col:25} = {val!r} -> {converted!r} (Boolean-Konvertierung)")
            else:
                row_dict[col] = val

        # Zeige finale Werte
        print("\nFinale Werte für INSERT:")
        for col, val in row_dict.items():
            print(f"   {col:25} = {val!r:30} (type: {type(val).__name__})")

        # Tabelle leeren
        print("\nLeere Tabelle...")
        db.session.execute(text("DELETE FROM studiengang"))
        db.session.commit()
        print("[OK] Tabelle geleert")

        # INSERT versuchen
        print("\nVersuche INSERT...")
        try:
            placeholders = ', '.join(f':{col}' for col in columns)
            sql = f"INSERT INTO studiengang ({', '.join(columns)}) VALUES ({placeholders})"

            print(f"\nSQL: {sql}")
            print(f"\nParameter: {row_dict}")

            db.session.execute(text(sql), row_dict)
            db.session.commit()

            print("\n[OK] INSERT erfolgreich!")

            # Verifizieren
            result = db.session.execute(text("SELECT * FROM studiengang")).first()
            print("\nVerifizierung:")
            for col, val in zip(columns, result):
                print(f"   {col:25} = {val!r}")

        except Exception as e:
            db.session.rollback()
            print(f"\n[FEHLER] INSERT fehlgeschlagen!")
            print(f"\nFehlertyp: {type(e).__name__}")
            print(f"Fehlermeldung: {e}")

    sqlite_conn.close()

    # Schließe Logger
    logger.close()
    sys.stdout = logger.terminal

    print(f"\n[OK] Test abgeschlossen! Ausgabe gespeichert in: {OUTPUT_FILE}")
    print("Jetzt ausführen:")
    print(f"   git add {OUTPUT_FILE}")
    print(f"   git commit -m 'test: studiengang migration results'")
    print(f"   git push origin main")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\nUNERWARTETER FEHLER: {e}")
        import traceback
        traceback.print_exc()
