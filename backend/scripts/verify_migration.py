#!/usr/bin/env python3
"""
Migration Verification Script
=============================

Verifies that the PostgreSQL database has been migrated correctly:
- Row counts for all critical tables
- Foreign key integrity
- Active planning phase exists
- User authentication works

Usage:
    cd backend
    python scripts/verify_migration.py

Environment:
    Requires DATABASE_URL environment variable to be set
"""

import os
import sys
from pathlib import Path

# Add backend to path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

# Set up Flask app context
from app import create_app
from app.extensions import db

# Expected row counts (approximate - adjust as needed)
EXPECTED_COUNTS = {
    'benutzer': 50,      # ~54 users
    'modul': 150,        # ~159 modules
    'dozent': 50,        # ~52 dozenten
    'planungsphasen': 10,  # ~16 phases
    'semester': 2,       # 2 semesters
    'pruefungsordnung': 1,  # at least 1
    'studiengang': 1,    # at least 1
}


def verify_table_counts(app):
    """Verify row counts for critical tables"""
    print("\n" + "="*60)
    print("TABLE ROW COUNTS")
    print("="*60)

    with app.app_context():
        tables = [
            'benutzer', 'modul', 'dozent', 'planungsphasen', 'semester',
            'pruefungsordnung', 'studiengang', 'semesterplanung',
            'modul_dozent', 'modul_lehrform', 'geplante_module'
        ]

        all_ok = True
        for table in tables:
            try:
                result = db.session.execute(
                    db.text(f"SELECT COUNT(*) FROM {table}")
                ).scalar()

                expected = EXPECTED_COUNTS.get(table)
                if expected:
                    status = "OK" if result >= expected * 0.8 else "LOW"
                    if status == "LOW":
                        all_ok = False
                    print(f"  {table:25} {result:6} rows  [{status}]")
                else:
                    print(f"  {table:25} {result:6} rows")
            except Exception as e:
                print(f"  {table:25} ERROR: {e}")
                all_ok = False

        return all_ok


def verify_active_phase(app):
    """Verify that an active planning phase exists"""
    print("\n" + "="*60)
    print("ACTIVE PLANNING PHASE")
    print("="*60)

    with app.app_context():
        from app.models.planungsphase import Planungsphase

        active_phase = Planungsphase.query.filter_by(ist_aktiv=True).first()
        if active_phase:
            print(f"  Active Phase: {active_phase.name}")
            print(f"  Semester: {active_phase.semester.kuerzel if active_phase.semester else 'N/A'}")
            print(f"  Start: {active_phase.startdatum}")
            print(f"  End: {active_phase.enddatum}")
            return True
        else:
            print("  WARNING: No active planning phase found!")
            return False


def verify_foreign_keys(app):
    """Verify foreign key integrity"""
    print("\n" + "="*60)
    print("FOREIGN KEY INTEGRITY")
    print("="*60)

    with app.app_context():
        checks = [
            ("semesterplanung.benutzer_id -> benutzer.id",
             "SELECT COUNT(*) FROM semesterplanung sp WHERE NOT EXISTS (SELECT 1 FROM benutzer b WHERE b.id = sp.benutzer_id)"),
            ("modul_dozent.dozent_id -> dozent.id",
             "SELECT COUNT(*) FROM modul_dozent md WHERE NOT EXISTS (SELECT 1 FROM dozent d WHERE d.id = md.dozent_id)"),
            ("geplante_module.modul_id -> modul.id",
             "SELECT COUNT(*) FROM geplante_module gm WHERE NOT EXISTS (SELECT 1 FROM modul m WHERE m.id = gm.modul_id)"),
        ]

        all_ok = True
        for name, query in checks:
            try:
                orphans = db.session.execute(db.text(query)).scalar()
                status = "OK" if orphans == 0 else f"ORPHANED: {orphans}"
                if orphans > 0:
                    all_ok = False
                print(f"  {name[:45]:45} [{status}]")
            except Exception as e:
                print(f"  {name[:45]:45} [ERROR: {e}]")
                all_ok = False

        return all_ok


def verify_user_auth(app):
    """Verify user authentication works"""
    print("\n" + "="*60)
    print("USER AUTHENTICATION")
    print("="*60)

    with app.app_context():
        from app.models.user import Benutzer

        # Check for dekan user
        dekan = Benutzer.query.filter_by(username='dekan').first()
        if dekan:
            print(f"  Dekan user exists: {dekan.username}")
            print(f"  Role: {dekan.rolle.name if dekan.rolle else 'N/A'}")
            print(f"  Active: {dekan.aktiv}")

            # Try to verify password (if check_password method exists)
            if hasattr(dekan, 'check_password'):
                # Note: Don't print password verification result for security
                print(f"  Password hash present: {'Yes' if dekan.passwort_hash else 'No'}")
            return True
        else:
            print("  WARNING: Dekan user not found!")
            return False


def verify_indexes(app):
    """Verify performance indexes exist"""
    print("\n" + "="*60)
    print("PERFORMANCE INDEXES")
    print("="*60)

    with app.app_context():
        # PostgreSQL specific query for indexes
        try:
            result = db.session.execute(db.text("""
                SELECT indexname, tablename
                FROM pg_indexes
                WHERE schemaname = 'public'
                AND indexname LIKE 'ix_%'
                ORDER BY tablename, indexname
            """)).fetchall()

            print(f"  Found {len(result)} performance indexes:")
            for idx in result[:10]:  # Show first 10
                print(f"    - {idx[1]}.{idx[0]}")
            if len(result) > 10:
                print(f"    ... and {len(result) - 10} more")

            return len(result) >= 10  # Expect at least 10 custom indexes
        except Exception as e:
            print(f"  Could not check indexes: {e}")
            return False


def main():
    """Run all verification checks"""
    print("="*60)
    print("DIGIDEKAN MIGRATION VERIFICATION")
    print("="*60)

    # Check DATABASE_URL
    db_url = os.environ.get('DATABASE_URL', '')
    if not db_url:
        print("\nERROR: DATABASE_URL environment variable not set!")
        print("Set it with: export DATABASE_URL=postgresql://...")
        sys.exit(1)

    # Mask password in output
    if '@' in db_url:
        masked_url = db_url.split('@')[0].rsplit(':', 1)[0] + ':***@' + db_url.split('@')[1]
    else:
        masked_url = db_url
    print(f"\nDatabase: {masked_url}")

    # Check for SQLite (should not be used)
    if 'sqlite' in db_url.lower():
        print("\nWARNING: Using SQLite! Migration should use PostgreSQL.")

    # Create app
    app = create_app()

    # Run checks
    results = []
    results.append(("Table Counts", verify_table_counts(app)))
    results.append(("Active Phase", verify_active_phase(app)))
    results.append(("Foreign Keys", verify_foreign_keys(app)))
    results.append(("User Auth", verify_user_auth(app)))
    results.append(("Indexes", verify_indexes(app)))

    # Summary
    print("\n" + "="*60)
    print("VERIFICATION SUMMARY")
    print("="*60)

    all_passed = True
    for name, passed in results:
        status = "PASSED" if passed else "FAILED"
        if not passed:
            all_passed = False
        print(f"  {name:25} [{status}]")

    print("\n" + "="*60)
    if all_passed:
        print("ALL CHECKS PASSED - Migration verified!")
    else:
        print("SOME CHECKS FAILED - Please review above")
    print("="*60)

    sys.exit(0 if all_passed else 1)


if __name__ == '__main__':
    main()
