#!/usr/bin/env python
"""
SQLite zu PostgreSQL Datenmigration
====================================
Migriert alle Daten von SQLite (dekanat_new3.db) zu PostgreSQL.

Verwendung:
    python migrate_sqlite_to_postgres.py

Voraussetzungen:
    - PostgreSQL ist installiert und läuft
    - PostgreSQL Datenbank ist erstellt
    - DATABASE_URL Environment Variable ist gesetzt
"""

import os
import sys
from pathlib import Path
from sqlalchemy import create_engine, MetaData, Table, inspect, text
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy.ext.automap import automap_base
from datetime import datetime

# Füge Backend-Verzeichnis zum Path hinzu
BASE_DIR = Path(__file__).parent
sys.path.insert(0, str(BASE_DIR))


def get_database_engines():
    """
    Erstellt SQLAlchemy Engines für SQLite und PostgreSQL
    """
    # SQLite Source
    sqlite_db = BASE_DIR / 'dekanat_new3.db'
    if not sqlite_db.exists():
        sqlite_db = BASE_DIR / 'dekanat_new.db'

    if not sqlite_db.exists():
        print(f"❌ ERROR: Keine SQLite-Datenbank gefunden!")
        print(f"   Gesucht: {BASE_DIR / 'dekanat_new3.db'} oder {BASE_DIR / 'dekanat_new.db'}")
        sys.exit(1)

    sqlite_uri = f'sqlite:///{sqlite_db}'
    print(f"📂 SQLite Source: {sqlite_db}")

    # PostgreSQL Target - als postgres-User für Superuser-Rechte
    postgres_uri = os.environ.get('DATABASE_URL', 'postgresql://postgres:postgres@localhost:5432/dekanat_migration')

    print(f"🐘 PostgreSQL Target: {postgres_uri.split('@')[1] if '@' in postgres_uri else postgres_uri}")

    # Engines erstellen
    sqlite_engine = create_engine(sqlite_uri)
    postgres_engine = create_engine(postgres_uri)

    return sqlite_engine, postgres_engine, sqlite_db


def get_table_order(engine):
    """
    Ermittelt die richtige Reihenfolge der Tabellen basierend auf Foreign Keys
    """
    inspector = inspect(engine)
    tables = inspector.get_table_names()

    # Basis-Reihenfolge (Tabellen ohne/mit wenigen Dependencies zuerst)
    priority_order = [
        'rolle',
        'sprache',
        'lehrform',
        'benutzer',
        'dozent',
        'studiengang',
        'pruefungsordnung',
        'semester',
        'modul',
        'modul_dozent',
        'semesterplanung',
        'geplantes_modul',
        'wunsch_freier_tag',
        'auftrag',
        'deputatsabrechnung',
        'deputat_abrechnung_eintrag',
        'planungs_template',
        'template_modul',
        'modul_audit_log',
        'notification',
        'alembic_version'
    ]

    # Sortiere Tabellen nach Priority-Order
    ordered_tables = []
    for table in priority_order:
        if table in tables:
            ordered_tables.append(table)

    # Füge übrige Tabellen hinzu
    for table in tables:
        if table not in ordered_tables:
            ordered_tables.append(table)

    return ordered_tables


def clear_postgres_tables(postgres_engine, tables):
    """
    Leert alle Tabellen in PostgreSQL (in umgekehrter Reihenfolge wegen FK)
    """
    print("\n🗑️  Lösche bestehende Daten in PostgreSQL...")

    with postgres_engine.connect() as conn:
        # Disable FK Constraints temporär
        conn.execute(text("SET session_replication_role = 'replica';"))
        conn.commit()

        # Lösche in umgekehrter Reihenfolge
        for table_name in reversed(tables):
            try:
                conn.execute(text(f'DELETE FROM "{table_name}";'))
                print(f"   ✓ {table_name}")
            except Exception as e:
                print(f"   ⚠️  {table_name}: {e}")

        conn.commit()

        # Re-enable FK Constraints
        conn.execute(text("SET session_replication_role = 'origin';"))
        conn.commit()

    print("   ✅ Alle Tabellen geleert")


def migrate_table_data(table_name, sqlite_engine, postgres_engine, metadata_sqlite, metadata_postgres):
    """
    Migriert Daten einer einzelnen Tabelle
    """
    try:
        # Tabellen-Objekte erstellen
        sqlite_table = Table(table_name, metadata_sqlite, autoload_with=sqlite_engine)
        postgres_table = Table(table_name, metadata_postgres, autoload_with=postgres_engine)

        # Daten aus SQLite lesen
        with sqlite_engine.connect() as sqlite_conn:
            result = sqlite_conn.execute(sqlite_table.select())
            rows = result.fetchall()

            if not rows:
                print(f"   ⊘ {table_name}: Keine Daten")
                return 0

        # Daten in PostgreSQL schreiben
        with postgres_engine.connect() as postgres_conn:
            # Daten als Dictionaries konvertieren
            data_dicts = []
            for row in rows:
                # row._mapping gibt uns ein Dict-ähnliches Objekt
                row_dict = dict(row._mapping)
                data_dicts.append(row_dict)

            # Batch Insert
            if data_dicts:
                postgres_conn.execute(postgres_table.insert(), data_dicts)
                postgres_conn.commit()

        print(f"   ✓ {table_name}: {len(rows)} Einträge migriert")
        return len(rows)

    except Exception as e:
        print(f"   ❌ {table_name}: FEHLER - {e}")
        return 0


def reset_sequences(postgres_engine, tables):
    """
    Setzt PostgreSQL Sequences (Auto-Increment) auf den richtigen Wert
    """
    print("\n🔄 Setze PostgreSQL Sequences...")

    with postgres_engine.connect() as conn:
        inspector = inspect(postgres_engine)

        for table_name in tables:
            try:
                # Finde Primary Key Column
                pk_columns = inspector.get_pk_constraint(table_name).get('constrained_columns', [])

                if pk_columns:
                    pk_column = pk_columns[0]

                    # Hole maximalen ID-Wert
                    result = conn.execute(text(f'SELECT MAX("{pk_column}") FROM "{table_name}"'))
                    max_id = result.scalar()

                    if max_id is not None:
                        # Setze Sequence
                        sequence_name = f"{table_name}_{pk_column}_seq"
                        conn.execute(text(f"SELECT setval('{sequence_name}', {max_id}, true);"))
                        print(f"   ✓ {table_name}: Sequence auf {max_id} gesetzt")

            except Exception as e:
                # Nicht alle Tabellen haben Sequences
                pass

        conn.commit()

    print("   ✅ Sequences aktualisiert")


def main():
    """
    Hauptfunktion für die Migration
    """
    print("=" * 80)
    print("  SQLite -> PostgreSQL Datenmigration")
    print("  Digitales Dekanat")
    print("=" * 80)
    print()

    # 1. Engines erstellen
    sqlite_engine, postgres_engine, sqlite_db = get_database_engines()

    # 2. Metadaten laden
    print("\n📋 Lade Datenbank-Schemas...")
    metadata_sqlite = MetaData()
    metadata_postgres = MetaData()
    metadata_sqlite.reflect(bind=sqlite_engine)
    metadata_postgres.reflect(bind=postgres_engine)

    print(f"   SQLite Tabellen: {len(metadata_sqlite.tables)}")
    print(f"   PostgreSQL Tabellen: {len(metadata_postgres.tables)}")

    # 3. Tabellen-Reihenfolge ermitteln
    tables = get_table_order(sqlite_engine)
    print(f"\n📊 Tabellen zur Migration: {len(tables)}")

    # 4. Benutzer-Bestätigung
    print("\n⚠️  WARNUNG: Alle bestehenden Daten in PostgreSQL werden gelöscht!")
    response = input("Möchten Sie fortfahren? (ja/nein): ")
    if response.lower() not in ['ja', 'j', 'yes', 'y']:
        print("❌ Migration abgebrochen.")
        sys.exit(0)

    # 5. PostgreSQL leeren
    clear_postgres_tables(postgres_engine, tables)

    # 6. Daten migrieren
    print("\n📦 Migriere Daten...")
    print("-" * 80)

    start_time = datetime.now()
    total_rows = 0

    for table_name in tables:
        rows_migrated = migrate_table_data(
            table_name,
            sqlite_engine,
            postgres_engine,
            metadata_sqlite,
            metadata_postgres
        )
        total_rows += rows_migrated

    print("-" * 80)

    # 7. Sequences zurücksetzen
    reset_sequences(postgres_engine, tables)

    # 8. Abschluss
    duration = (datetime.now() - start_time).total_seconds()

    print("\n" + "=" * 80)
    print("  ✅ MIGRATION ERFOLGREICH ABGESCHLOSSEN!")
    print("=" * 80)
    print(f"\n📊 Statistiken:")
    print(f"   Tabellen: {len(tables)}")
    print(f"   Einträge: {total_rows:,}")
    print(f"   Dauer: {duration:.2f} Sekunden")
    print(f"\n🗄️  Quelle: {sqlite_db}")
    print(f"🐘 Ziel: PostgreSQL")
    print("\n💡 Nächste Schritte:")
    print("   1. Teste die PostgreSQL-Datenbank: flask shell")
    print("   2. Starte die Anwendung: python run.py")
    print("   3. Teste den Login über API")
    print()


if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Migration durch Benutzer abgebrochen.")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ FEHLER: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
