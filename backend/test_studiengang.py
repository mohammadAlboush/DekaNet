#!/usr/bin/env python3
"""
Test: Studiengang-Migration mit vollem Logging
"""

import os
import sqlite3
import sys

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from sqlalchemy import text

SQLITE_DB = 'dekanat_new.db'


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
    print("=" * 80)
    print("TEST: studiengang-Migration mit detailliertem Logging")
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


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\nUNERWARTETER FEHLER: {e}")
        import traceback
        traceback.print_exc()
