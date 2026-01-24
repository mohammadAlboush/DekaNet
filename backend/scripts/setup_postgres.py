#!/usr/bin/env python3
"""
PostgreSQL Setup & Migration Script (v2)
========================================

Dieser Script:
1. Erstellt alle Tabellen in PostgreSQL via Flask ORM
2. Migriert alle Daten von SQLite zu PostgreSQL
3. Aktualisiert die .env Datei
"""

import os
import sys
import sqlite3
from pathlib import Path
from datetime import datetime

# Backend-Verzeichnis
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

# PostgreSQL Konfiguration
POSTGRES_URL = 'postgresql://postgres:postgres@localhost:5432/digidekan'
SQLITE_PATH = backend_dir / 'dekanat_new.db'

os.environ['DATABASE_URL'] = POSTGRES_URL


def convert_value(value, col_name):
    """Konvertiert Werte für PostgreSQL"""
    if value is None or value == '':
        return None

    # Alle bekannten Boolean-Spalten
    bool_patterns = ('ist_', 'is_', 'hat_', 'has_', 'kann_', 'can_', 'nur_')
    bool_names = (
        'aktiv', 'active', 'enabled', 'abgeschlossen', 'eingereicht',
        'bestaetigt', 'genehmigt', 'archived', 'deleted', 'pflicht',
        'wahlpflicht', 'gelesen', 'sichtbar', 'visible', 'hidden',
        'approved', 'verified', 'published', 'confirmed', 'read',
        'pflichtliteratur', 'empfohlen', 'required', 'optional'
    )

    col_lower = col_name.lower()
    is_bool = any(col_lower.startswith(p) for p in bool_patterns) or col_lower in bool_names

    if is_bool:
        if value in (0, '0', 'false', 'False', False, 'f', 'F', None):
            return False
        elif value in (1, '1', 'true', 'True', True, 't', 'T'):
            return True
        return bool(value) if value else False

    return value


def migrate_with_raw_sql():
    """Migration mit direktem SQL"""
    import psycopg2
    from psycopg2.extras import execute_batch

    print("=" * 70)
    print("PostgreSQL Setup & Migration (v2)")
    print("=" * 70)

    # 1. Prüfe SQLite
    print(f"\n1. Prüfe SQLite-Datenbank...")
    if not SQLITE_PATH.exists():
        print(f"   FEHLER: {SQLITE_PATH} nicht gefunden!")
        sys.exit(1)
    print(f"   [OK] {SQLITE_PATH}")

    # 2. Erstelle Tabellen via Flask ORM
    print(f"\n2. Erstelle PostgreSQL-Tabellen via Flask...")
    try:
        from app import create_app, db
        app = create_app('development')
        with app.app_context():
            db.create_all()
            print(f"   [OK] Alle Tabellen erstellt")
    except Exception as e:
        print(f"   FEHLER: {e}")
        sys.exit(1)

    # 3. Direkte SQL-Migration
    print(f"\n3. Migriere Daten...")

    sqlite_conn = sqlite3.connect(SQLITE_PATH)
    sqlite_conn.row_factory = sqlite3.Row
    sqlite_cursor = sqlite_conn.cursor()

    pg_conn = psycopg2.connect(POSTGRES_URL)
    pg_conn.autocommit = True
    pg_cursor = pg_conn.cursor()

    # WICHTIG: Foreign Key Checks temporär deaktivieren
    print(f"   Deaktiviere Foreign Key Checks...")
    pg_cursor.execute("SET session_replication_role = 'replica';")

    # Hole SQLite-Tabellen
    sqlite_cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name != 'alembic_version'")
    tables = [row[0] for row in sqlite_cursor.fetchall()]

    # Tabellen-Reihenfolge (Foreign Keys beachten)
    priority = ['rolle', 'benutzer', 'semester', 'planungsphasen', 'pruefungsordnung',
                'studiengang', 'sprache', 'lehrform', 'dozent', 'modul', 'auftrag']

    sorted_tables = []
    for t in priority:
        if t in tables:
            sorted_tables.append(t)
            tables.remove(t)
    sorted_tables.extend(tables)

    success = 0
    failed = []

    for table in sorted_tables:
        try:
            # Hole Daten aus SQLite
            sqlite_cursor.execute(f'SELECT * FROM "{table}"')
            rows = sqlite_cursor.fetchall()

            if not rows:
                print(f"   [{table}] Leer")
                continue

            columns = [desc[0] for desc in sqlite_cursor.description]

            # Prüfe ob Tabelle in PostgreSQL existiert
            pg_cursor.execute("""
                SELECT EXISTS (
                    SELECT FROM information_schema.tables
                    WHERE table_name = %s
                )
            """, (table,))
            exists = pg_cursor.fetchone()[0]

            if not exists:
                print(f"   [{table}] Übersprungen (Tabelle fehlt in PostgreSQL)")
                continue

            # Lösche existierende Daten
            pg_cursor.execute(f'DELETE FROM "{table}"')

            # Insert-Statement vorbereiten
            placeholders = ', '.join(['%s'] * len(columns))
            cols_str = ', '.join([f'"{c}"' for c in columns])
            insert_sql = f'INSERT INTO "{table}" ({cols_str}) VALUES ({placeholders})'

            # Hole PostgreSQL-Spalteninformationen für Längenbeschränkungen
            pg_cursor.execute("""
                SELECT column_name, character_maximum_length
                FROM information_schema.columns
                WHERE table_name = %s AND character_maximum_length IS NOT NULL
            """, (table,))
            varchar_limits = {row[0]: row[1] for row in pg_cursor.fetchall()}

            # Daten konvertieren und einfügen
            converted_rows = []
            for row in rows:
                converted_row = []
                for i, val in enumerate(row):
                    col_name = columns[i]
                    converted_val = convert_value(val, col_name)

                    # Truncate strings if exceeding VARCHAR limit
                    if col_name in varchar_limits and isinstance(converted_val, str):
                        max_len = varchar_limits[col_name]
                        if len(converted_val) > max_len:
                            converted_val = converted_val[:max_len]

                    converted_row.append(converted_val)
                converted_rows.append(tuple(converted_row))

            # Bei UNIQUE-Constraint-Problemen: ON CONFLICT DO NOTHING
            # Oder deduplizieren
            try:
                execute_batch(pg_cursor, insert_sql, converted_rows, page_size=100)
            except Exception as batch_err:
                # Fallback: Einzeln einfügen, Duplikate überspringen
                if 'unique' in str(batch_err).lower() or 'duplicate' in str(batch_err).lower():
                    inserted = 0
                    for row in converted_rows:
                        try:
                            pg_cursor.execute(insert_sql, row)
                            inserted += 1
                        except:
                            pass  # Überspringe Duplikat
                    print(f"   [{table}] {inserted} Zeilen migriert (Duplikate übersprungen)")
                    success += 1
                    continue
                else:
                    raise batch_err

            # Reset Sequence für ID-Spalten
            if 'id' in columns:
                try:
                    pg_cursor.execute(f"""
                        SELECT setval(pg_get_serial_sequence('"{table}"', 'id'),
                               COALESCE((SELECT MAX(id) FROM "{table}"), 1), true)
                    """)
                except:
                    pass

            print(f"   [{table}] {len(rows)} Zeilen migriert")
            success += 1

        except Exception as e:
            print(f"   [{table}] FEHLER: {e}")
            failed.append((table, str(e)))

    # Foreign Key Checks wieder aktivieren
    print(f"   Aktiviere Foreign Key Checks...")
    pg_cursor.execute("SET session_replication_role = 'origin';")

    sqlite_conn.close()
    pg_cursor.close()
    pg_conn.close()

    # 4. Zusammenfassung
    print(f"\n" + "=" * 70)
    print("MIGRATION ABGESCHLOSSEN")
    print("=" * 70)
    print(f"\n   Erfolgreich: {success} Tabellen")
    if failed:
        print(f"   Fehler: {len(failed)} Tabellen")
        for t, e in failed[:5]:
            print(f"      - {t}: {e[:50]}...")

    # 5. .env erstellen
    print(f"\n4. Erstelle .env...")
    env_path = backend_dir / '.env'
    env_content = f"""# DigiDekan Konfiguration
# Generiert: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

# PostgreSQL Datenbank
DATABASE_URL={POSTGRES_URL}

# Flask
FLASK_ENV=development
FLASK_DEBUG=1

# Secret Keys (IN PRODUCTION ÄNDERN!)
SECRET_KEY=dev-secret-key-change-in-production
JWT_SECRET_KEY=jwt-secret-key-change-in-production
"""
    with open(env_path, 'w', encoding='utf-8') as f:
        f.write(env_content)
    print(f"   [OK] {env_path}")

    print(f"\n" + "=" * 70)
    print("NÄCHSTE SCHRITTE")
    print("=" * 70)
    print("""
   Backend neu starten:
      flask run

   Dann im Browser testen.
""")


if __name__ == '__main__':
    migrate_with_raw_sql()
