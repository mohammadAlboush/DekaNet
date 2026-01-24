"""Add performance indexes for PostgreSQL

This migration adds additional indexes to improve query performance,
especially for common queries in the DigiDekan application.

Revision ID: add_perf_indexes
Revises:
Create Date: 2026-01-23
"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'add_perf_indexes'
down_revision = '006_deputatsabrechnung'
branch_labels = None
depends_on = None


def upgrade():
    """Add performance indexes"""

    # =========================================================================
    # BENUTZER (User) Table - Frequently queried columns
    # =========================================================================
    op.create_index(
        'ix_benutzer_rolle_aktiv',
        'benutzer',
        ['rolle_id', 'aktiv'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_benutzer_dozent',
        'benutzer',
        ['dozent_id'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_benutzer_username_aktiv',
        'benutzer',
        ['username', 'aktiv'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # DOZENT Table - Name searches
    # =========================================================================
    op.create_index(
        'ix_dozent_aktiv',
        'dozent',
        ['aktiv'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_dozent_email',
        'dozent',
        ['email'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # MODUL Table - Turnus and search queries
    # =========================================================================
    op.create_index(
        'ix_modul_turnus',
        'modul',
        ['turnus'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_modul_bezeichnung',
        'modul',
        ['bezeichnung_de'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # MODUL_LEHRFORM Table - Composite index for eager loading
    # =========================================================================
    op.create_index(
        'ix_modul_lehrform_composite',
        'modul_lehrform',
        ['modul_id', 'po_id', 'lehrform_id'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # MODUL_DOZENT Table - Role-based queries
    # =========================================================================
    op.create_index(
        'ix_modul_dozent_rolle',
        'modul_dozent',
        ['rolle'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_modul_dozent_dozent_rolle',
        'modul_dozent',
        ['dozent_id', 'rolle'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # SEMESTERPLANUNG Table - Status and filtering
    # =========================================================================
    op.create_index(
        'ix_semesterplanung_planungsphase_status',
        'semesterplanung',
        ['planungsphase_id', 'status'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # GEPLANTE_MODULE Table - For dashboard queries
    # =========================================================================
    op.create_index(
        'ix_geplante_module_modul',
        'geplante_module',
        ['modul_id'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # PLANUNGSPHASEN Table - Active phase queries
    # =========================================================================
    op.create_index(
        'ix_planungsphasen_aktiv',
        'planungsphasen',
        ['ist_aktiv'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_planungsphasen_semester_aktiv',
        'planungsphasen',
        ['semester_id', 'ist_aktiv'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_planungsphasen_dates',
        'planungsphasen',
        ['startdatum', 'enddatum'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # SEMESTER Table - Planning semester lookup
    # =========================================================================
    op.create_index(
        'ix_semester_ist_planungsphase',
        'semester',
        ['ist_planungsphase'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_semester_ist_aktiv',
        'semester',
        ['ist_aktiv'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # SEMESTER_AUFTRAG Table - Status and filtering
    # =========================================================================
    op.create_index(
        'ix_semester_auftrag_status',
        'semester_auftrag',
        ['status'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_semester_auftrag_semester_status',
        'semester_auftrag',
        ['semester_id', 'status'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_semester_auftrag_dozent',
        'semester_auftrag',
        ['dozent_id'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # DEPUTATSABRECHNUNG Table - Status and user queries
    # =========================================================================
    op.create_index(
        'ix_deputatsabrechnung_planungsphase',
        'deputatsabrechnung',
        ['planungsphase_id'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_deputatsabrechnung_status',
        'deputatsabrechnung',
        ['status'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_deputatsabrechnung_benutzer_status',
        'deputatsabrechnung',
        ['benutzer_id', 'status'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # SEMESTERPLANUNG Table - Missing planungsphase_id index
    # =========================================================================
    op.create_index(
        'ix_semesterplanung_planungsphase',
        'semesterplanung',
        ['planungsphase_id'],
        unique=False,
        if_not_exists=True
    )

    # =========================================================================
    # ARCHIVIERTE_PLANUNGEN Table - Filtering
    # =========================================================================
    op.create_index(
        'ix_archivierte_planungen_semester',
        'archivierte_planungen',
        ['semester_id'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_archivierte_planungen_phase',
        'archivierte_planungen',
        ['planungsphase_id'],
        unique=False,
        if_not_exists=True
    )
    op.create_index(
        'ix_archivierte_planungen_professor',
        'archivierte_planungen',
        ['professor_id'],
        unique=False,
        if_not_exists=True
    )


def downgrade():
    """Remove performance indexes"""

    # Remove all indexes (in reverse order)
    indexes_to_drop = [
        ('ix_archivierte_planungen_professor', 'archivierte_planungen'),
        ('ix_archivierte_planungen_phase', 'archivierte_planungen'),
        ('ix_archivierte_planungen_semester', 'archivierte_planungen'),
        ('ix_semesterplanung_planungsphase', 'semesterplanung'),
        ('ix_deputatsabrechnung_benutzer_status', 'deputatsabrechnung'),
        ('ix_deputatsabrechnung_status', 'deputatsabrechnung'),
        ('ix_deputatsabrechnung_planungsphase', 'deputatsabrechnung'),
        ('ix_semester_auftrag_dozent', 'semester_auftrag'),
        ('ix_semester_auftrag_semester_status', 'semester_auftrag'),
        ('ix_semester_auftrag_status', 'semester_auftrag'),
        ('ix_semester_ist_aktiv', 'semester'),
        ('ix_semester_ist_planungsphase', 'semester'),
        ('ix_planungsphasen_dates', 'planungsphasen'),
        ('ix_planungsphasen_semester_aktiv', 'planungsphasen'),
        ('ix_planungsphasen_aktiv', 'planungsphasen'),
        ('ix_geplante_module_modul', 'geplante_module'),
        ('ix_semesterplanung_planungsphase_status', 'semesterplanung'),
        ('ix_modul_dozent_dozent_rolle', 'modul_dozent'),
        ('ix_modul_dozent_rolle', 'modul_dozent'),
        ('ix_modul_lehrform_composite', 'modul_lehrform'),
        ('ix_modul_bezeichnung', 'modul'),
        ('ix_modul_turnus', 'modul'),
        ('ix_dozent_email', 'dozent'),
        ('ix_dozent_aktiv', 'dozent'),
        ('ix_benutzer_username_aktiv', 'benutzer'),
        ('ix_benutzer_dozent', 'benutzer'),
        ('ix_benutzer_rolle_aktiv', 'benutzer'),
    ]

    for index_name, table_name in indexes_to_drop:
        op.drop_index(index_name, table_name=table_name, if_exists=True)
