"""Test database tables"""
from app import create_app
from app.extensions import db
from sqlalchemy import inspect

app = create_app()

with app.app_context():
    inspector = inspect(db.engine)
    tables = inspector.get_table_names()

    print(f"\n=== DATABASE TABLES ({len(tables)} total) ===")

    # Check if new tables exist
    new_tables = ['auftrag', 'semester_auftrag']

    for table in new_tables:
        if table in tables:
            print(f"[OK] {table} - EXISTS")
            columns = inspector.get_columns(table)
            print(f"  Columns: {', '.join([c['name'] for c in columns])}")
        else:
            print(f"[MISSING] {table} - NOT FOUND")

    # Check modul_dozent for new columns
    print("\n=== MODUL_DOZENT TABLE ===")
    if 'modul_dozent' in tables:
        columns = inspector.get_columns('modul_dozent')
        column_names = [c['name'] for c in columns]
        print(f"Columns: {', '.join(column_names)}")

        new_columns = ['vertreter_id', 'zweitpruefer_id']
        for col in new_columns:
            if col in column_names:
                print(f"[OK] {col} - EXISTS")
            else:
                print(f"[MISSING] {col} - NOT FOUND (migration needed)")

    print("\n=== MIGRATION STATUS ===")
    print("Run: flask db upgrade")
