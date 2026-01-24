"""
SQLite zu PostgreSQL Migration Script
======================================

Migriert alle Daten von SQLite (dekanat_new.db) zu PostgreSQL.

Verwendung:
    1. PostgreSQL Datenbank erstellen:
       createdb -U postgres digidekan

    2. Script ausführen:
       python scripts/migrate_to_postgres.py

    3. .env aktualisieren:
       DATABASE_URL=postgresql://postgres:password@localhost:5432/digidekan
"""

import os
import sys
import sqlite3
from pathlib import Path

# Füge Backend-Verzeichnis zum Path hinzu
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

# PostgreSQL Verbindungsdetails
POSTGRES_USER = os.environ.get('POSTGRES_USER', 'postgres')
POSTGRES_PASSWORD = os.environ.get('POSTGRES_PASSWORD', 'postgres')
POSTGRES_HOST = os.environ.get('POSTGRES_HOST', 'localhost')
POSTGRES_PORT = os.environ.get('POSTGRES_PORT', '5432')
POSTGRES_DB = os.environ.get('POSTGRES_DB', 'digidekan')

POSTGRES_URL = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"
SQLITE_PATH = backend_dir / "dekanat_new.db"


def get_sqlite_tables(conn):
    """Holt alle Tabellennamen aus SQLite"""
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'")
    return [row[0] for row in cursor.fetchall()]


def get_table_columns(conn, table_name):
    """Holt Spalteninformationen für eine Tabelle"""
    cursor = conn.cursor()
    cursor.execute(f"PRAGMA table_info({table_name})")
    return cursor.fetchall()


def get_table_data(conn, table_name):
    """Holt alle Daten aus einer Tabelle"""
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    return cursor.fetchall()


def sqlite_type_to_postgres(sqlite_type):
    """Konvertiert SQLite-Typen zu PostgreSQL-Typen"""
    type_map = {
        'INTEGER': 'INTEGER',
        'TEXT': 'TEXT',
        'REAL': 'DOUBLE PRECISION',
        'BLOB': 'BYTEA',
        'NUMERIC': 'NUMERIC',
        'BOOLEAN': 'BOOLEAN',
        'DATETIME': 'TIMESTAMP',
        'DATE': 'DATE',
        'TIME': 'TIME',
        'VARCHAR': 'VARCHAR',
        'FLOAT': 'DOUBLE PRECISION',
    }

    upper_type = sqlite_type.upper() if sqlite_type else 'TEXT'

    # Handle VARCHAR(n)
    if 'VARCHAR' in upper_type:
        return upper_type

    for sqlite_t, pg_t in type_map.items():
        if sqlite_t in upper_type:
            return pg_t

    return 'TEXT'


def migrate():
    """Hauptmigrationsfunktion"""
    print("=" * 60)
    print("SQLite zu PostgreSQL Migration")
    print("=" * 60)

    # Prüfe ob SQLite-DB existiert
    if not SQLITE_PATH.exists():
        print(f"FEHLER: SQLite-Datenbank nicht gefunden: {SQLITE_PATH}")
        sys.exit(1)

    print(f"\nQuelle: {SQLITE_PATH}")
    print(f"Ziel: {POSTGRES_URL.replace(POSTGRES_PASSWORD, '****')}")

    try:
        import psycopg2
        from psycopg2.extras import execute_values
    except ImportError:
        print("\nFEHLER: psycopg2 nicht installiert!")
        print("Installiere mit: pip install psycopg2-binary")
        sys.exit(1)

    # Verbindungen aufbauen
    print("\n1. Verbindungen aufbauen...")
    sqlite_conn = sqlite3.connect(SQLITE_PATH)

    try:
        pg_conn = psycopg2.connect(POSTGRES_URL)
        pg_conn.autocommit = True  # Jede Tabelle als eigene Transaktion
        pg_cursor = pg_conn.cursor()
    except Exception as e:
        print(f"\nFEHLER: PostgreSQL-Verbindung fehlgeschlagen!")
        print(f"Details: {e}")
        print(f"\nStellen Sie sicher, dass:")
        print(f"  1. PostgreSQL läuft")
        print(f"  2. Datenbank '{POSTGRES_DB}' existiert (createdb -U postgres {POSTGRES_DB})")
        print(f"  3. Benutzer '{POSTGRES_USER}' Zugriff hat")
        sys.exit(1)

    print("   [OK] Beide Verbindungen hergestellt")

    # Tabellen holen
    print("\n2. Tabellen analysieren...")
    tables = get_sqlite_tables(sqlite_conn)
    print(f"   Gefunden: {len(tables)} Tabellen")

    # Tabellen in richtiger Reihenfolge (wegen Foreign Keys)
    # Basis-Tabellen zuerst, dann abhängige Tabellen
    priority_tables = [
        'alembic_version',
        'rollen',
        'benutzer',
        'semester',
        'planungsphasen',
        'pruefungsordnungen',
        'studiengaenge',
        'sprachen',
        'lehrformen',
        'dozenten',
        'module',
        'auftrag',
    ]

    # Sortiere Tabellen
    sorted_tables = []
    for t in priority_tables:
        if t in tables:
            sorted_tables.append(t)
            tables.remove(t)
    sorted_tables.extend(tables)  # Rest anhängen

    # Migriere jede Tabelle
    print("\n3. Daten migrieren...")
    migrated_count = 0
    error_tables = []

    for table_name in sorted_tables:
        try:
            columns = get_table_columns(sqlite_conn, table_name)
            data = get_table_data(sqlite_conn, table_name)

            if not data:
                print(f"   [{table_name}] Leer - übersprungen")
                continue

            # Spalten-Namen
            col_names = [col[1] for col in columns]

            # DROP und CREATE in PostgreSQL
            pg_cursor.execute(f'DROP TABLE IF EXISTS "{table_name}" CASCADE')

            # CREATE TABLE
            col_defs = []
            for col in columns:
                col_name = col[1]
                col_type = sqlite_type_to_postgres(col[2])
                is_pk = col[5] == 1
                not_null = col[3] == 1

                col_def = f'"{col_name}" {col_type}'
                if is_pk:
                    if col_type == 'INTEGER':
                        col_def = f'"{col_name}" SERIAL PRIMARY KEY'
                    else:
                        col_def += ' PRIMARY KEY'
                elif not_null:
                    col_def += ' NOT NULL'

                col_defs.append(col_def)

            create_sql = f'CREATE TABLE "{table_name}" ({", ".join(col_defs)})'
            pg_cursor.execute(create_sql)

            # Finde Boolean-Spalten (für Typ-Konvertierung)
            # SQLite hat keinen echten Boolean-Typ, erkennen via Namenskonvention
            bool_indices = []
            bool_prefixes = ('ist_', 'is_', 'hat_', 'has_', 'kann_', 'can_')
            bool_names = ('aktiv', 'active', 'enabled', 'disabled', 'visible', 'hidden',
                          'deleted', 'archived', 'published', 'approved', 'verified',
                          'ist_block', 'ist_aktiv', 'ist_planungsphase', 'nur_aktive',
                          'ist_wintersemester', 'ist_sommersemester', 'abgeschlossen',
                          'eingereicht', 'bestaetigt', 'genehmigt', 'ist_archiviert')
            for idx, col in enumerate(columns):
                col_name = col[1].lower()
                col_type = col[2].upper() if col[2] else ''
                # Explizite Boolean-Typen
                if 'BOOLEAN' in col_type or 'BOOL' in col_type:
                    bool_indices.append(idx)
                # Namensbasierte Erkennung
                elif any(col_name.startswith(p) for p in bool_prefixes):
                    bool_indices.append(idx)
                elif col_name in bool_names:
                    bool_indices.append(idx)

            # INSERT Daten
            placeholders = ', '.join(['%s'] * len(col_names))
            insert_sql = f'INSERT INTO "{table_name}" ({", ".join([f"{c}" for c in col_names])}) VALUES ({placeholders})'

            # Konvertiere None-Werte und Boolean (0/1 -> True/False)
            clean_data = []
            for row in data:
                clean_row = list(row)
                for i, v in enumerate(clean_row):
                    if v == '':
                        clean_row[i] = None
                    elif i in bool_indices:
                        # Konvertiere 0/1 zu Boolean
                        if v in (0, '0', 'false', 'False', False):
                            clean_row[i] = False
                        elif v in (1, '1', 'true', 'True', True):
                            clean_row[i] = True
                        else:
                            clean_row[i] = bool(v) if v is not None else None
                clean_data.append(tuple(clean_row))

            pg_cursor.executemany(insert_sql, clean_data)

            # Reset Sequence für SERIAL Columns
            for col in columns:
                if col[5] == 1 and 'INTEGER' in sqlite_type_to_postgres(col[2]).upper():
                    col_name = col[1]
                    try:
                        pg_cursor.execute(f"""
                            SELECT setval(pg_get_serial_sequence('"{table_name}"', '{col_name}'),
                                   COALESCE((SELECT MAX("{col_name}") FROM "{table_name}"), 1))
                        """)
                    except:
                        pass  # Sequence existiert möglicherweise nicht

            print(f"   [{table_name}] {len(data)} Zeilen migriert")
            migrated_count += 1

        except Exception as e:
            print(f"   [{table_name}] FEHLER: {e}")
            error_tables.append((table_name, str(e)))

    # Commit
    print("\n4. Änderungen speichern...")
    pg_conn.commit()
    print("   [OK] Alle Änderungen gespeichert")

    # Aufräumen
    sqlite_conn.close()
    pg_cursor.close()
    pg_conn.close()

    # Zusammenfassung
    print("\n" + "=" * 60)
    print("MIGRATION ABGESCHLOSSEN")
    print("=" * 60)
    print(f"Erfolgreich migriert: {migrated_count} Tabellen")

    if error_tables:
        print(f"\nFehler bei {len(error_tables)} Tabellen:")
        for t, e in error_tables:
            print(f"  - {t}: {e}")

    print(f"\n NÄCHSTE SCHRITTE:")
    print(f"  1. Erstelle/Aktualisiere .env Datei:")
    print(f"     DATABASE_URL={POSTGRES_URL}")
    print(f"\n  2. Starte Backend neu:")
    print(f"     flask run")

    return migrated_count, error_tables


if __name__ == '__main__':
    migrate()
