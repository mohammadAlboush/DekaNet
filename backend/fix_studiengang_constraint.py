#!/usr/bin/env python3
"""
FIX: studiengang UNIQUE Constraint Problem
Problem: UNIQUE constraint auf 'kuerzel' allein blockiert Bachelor+Master mit gleichem Kürzel
Lösung: Composite UNIQUE constraint auf (kuerzel, abschluss)
Speichert Ausgabe in fix_studiengang_output.txt
"""

import os
import sqlite3
import sys
from datetime import datetime

os.environ['DATABASE_URL'] = 'postgresql://dekanet:DekaNet2025Secure@localhost:5432/dekanet_db'

from app import create_app, db
from sqlalchemy import text

SQLITE_DB = 'dekanat_new.db'
OUTPUT_FILE = 'fix_studiengang_output.txt'

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
    print("FIX: studiengang UNIQUE Constraint Problem")
    print(f"Zeitstempel: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80 + "\n")

    # SQLite
    sqlite_conn = sqlite3.connect(SQLITE_DB)
    cursor = sqlite_conn.cursor()

    cursor.execute("SELECT * FROM studiengang")
    rows = cursor.fetchall()
    columns = [d[0] for d in cursor.description]

    print(f"SQLite: {len(rows)} Studiengänge gefunden\n")

    print("Alle Studiengänge in SQLite:")
    for i, row in enumerate(rows, 1):
        row_dict = dict(zip(columns, row))
        print(f"   {i}. {row_dict['kuerzel']:5} | {row_dict['bezeichnung']:30} | {row_dict['abschluss']}")
    print()

    # Flask
    app = create_app()

    with app.app_context():
        print("=" * 80)
        print("SCHRITT 1: Constraint-Problem diagnostizieren")
        print("=" * 80 + "\n")

        # Prüfe aktuellen Constraint
        result = db.session.execute(text("""
            SELECT constraint_name, constraint_type
            FROM information_schema.table_constraints
            WHERE table_name = 'studiengang'
            AND constraint_type = 'UNIQUE'
        """))

        print("Aktuelle UNIQUE Constraints:")
        constraints = list(result)
        for row in constraints:
            print(f"   - {row[0]} ({row[1]})")
        print()

        # Entferne alten Constraint
        print("=" * 80)
        print("SCHRITT 2: Alten UNIQUE Constraint entfernen")
        print("=" * 80 + "\n")

        try:
            # Finde den genauen Constraint-Namen
            result = db.session.execute(text("""
                SELECT constraint_name
                FROM information_schema.table_constraints
                WHERE table_name = 'studiengang'
                AND constraint_type = 'UNIQUE'
                AND constraint_name LIKE '%kuerzel%'
            """))

            constraint_names = [row[0] for row in result]

            for constraint_name in constraint_names:
                print(f"Entferne Constraint: {constraint_name}")
                db.session.execute(text(f"ALTER TABLE studiengang DROP CONSTRAINT {constraint_name}"))
                print(f"[OK] {constraint_name} entfernt\n")

            db.session.commit()

        except Exception as e:
            print(f"[INFO] {e}\n")
            db.session.rollback()

        # VARCHAR erweitern
        print("=" * 80)
        print("SCHRITT 3: VARCHAR-Felder erweitern")
        print("=" * 80 + "\n")

        try:
            db.session.execute(text("ALTER TABLE studiengang ALTER COLUMN bezeichnung TYPE VARCHAR(200)"))
            db.session.execute(text("ALTER TABLE studiengang ALTER COLUMN fachbereich TYPE VARCHAR(200)"))
            db.session.commit()
            print("[OK] VARCHAR-Felder erweitert\n")
        except Exception as e:
            print(f"[INFO] {e}\n")
            db.session.rollback()

        # Neuen Composite Constraint hinzufügen
        print("=" * 80)
        print("SCHRITT 4: Neuen Composite UNIQUE Constraint hinzufügen")
        print("=" * 80 + "\n")

        try:
            db.session.execute(text(
                "ALTER TABLE studiengang ADD CONSTRAINT studiengang_kuerzel_abschluss_unique "
                "UNIQUE (kuerzel, abschluss)"
            ))
            db.session.commit()
            print("[OK] Neuer Constraint hinzugefügt: UNIQUE (kuerzel, abschluss)\n")
        except Exception as e:
            print(f"[INFO] {e}\n")
            db.session.rollback()

        # Tabelle leeren
        print("=" * 80)
        print("SCHRITT 5: Tabelle leeren und neu befüllen")
        print("=" * 80 + "\n")

        db.session.execute(text("DELETE FROM studiengang"))
        db.session.commit()
        print("[OK] Tabelle geleert\n")

        # Alle Zeilen einfügen
        print(f"Füge {len(rows)} Zeilen ein:\n")

        success_count = 0
        failed_count = 0

        for i, row in enumerate(rows, 1):
            row_dict = {col: convert_value(col, val) for col, val in zip(columns, row)}

            try:
                placeholders = ', '.join(f':{col}' for col in columns)
                sql = f"INSERT INTO studiengang ({', '.join(columns)}) VALUES ({placeholders})"
                db.session.execute(text(sql), row_dict)
                db.session.commit()

                print(f"   [{i}/8] [OK] {row_dict['kuerzel']:5} | {row_dict['bezeichnung']:30} | {row_dict['abschluss']}")
                success_count += 1

            except Exception as e:
                db.session.rollback()
                print(f"   [{i}/8] [FEHLER] {row_dict.get('kuerzel', '?'):5}")
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
        print("=" * 80 + "\n")

        result = db.session.execute(text("SELECT kuerzel, bezeichnung, abschluss, aktiv FROM studiengang ORDER BY kuerzel, abschluss"))
        print("Studiengänge in PostgreSQL:\n")
        for row in result:
            print(f"   {row[0]:5} | {row[1]:30} | {row[2]:8} | aktiv={row[3]}")

        # Prüfe neue Constraints
        print("\n" + "=" * 80)
        print("NEUE CONSTRAINTS")
        print("=" * 80 + "\n")

        result = db.session.execute(text("""
            SELECT constraint_name, constraint_type
            FROM information_schema.table_constraints
            WHERE table_name = 'studiengang'
            AND constraint_type = 'UNIQUE'
        """))

        print("Aktuelle UNIQUE Constraints:")
        for row in result:
            print(f"   - {row[0]} ({row[1]})")

    sqlite_conn.close()

    logger.close()
    sys.stdout = logger.terminal

    print(f"\n[OK] Fix abgeschlossen! Ausgabe in: {OUTPUT_FILE}")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f"\nFEHLER: {e}")
        import traceback
        traceback.print_exc()
