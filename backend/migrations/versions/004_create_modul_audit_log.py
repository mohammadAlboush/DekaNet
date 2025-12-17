"""Create modul_audit_log table

Revision ID: 004_modul_audit
Revises: 003_raum_planung
Create Date: 2025-01-25

Feature 3: Modul-Verwaltung für Dekan
- Audit Log für Modul-Dozenten-Zuordnungen
- Protokolliert wer, wann, welche Änderung gemacht hat
"""
from alembic import op
import sqlalchemy as sa
from datetime import datetime


# revision identifiers, used by Alembic.
revision = '004_modul_audit'
down_revision = '003_raum_planung'
branch_labels = None
depends_on = None


def upgrade():
    """
    Erstellt modul_audit_log Tabelle
    """
    op.create_table(
        'modul_audit_log',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),

        # Was wurde geändert?
        sa.Column('modul_id', sa.Integer(), sa.ForeignKey('modul.id', ondelete='CASCADE'), nullable=False),
        sa.Column('po_id', sa.Integer(), sa.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), nullable=False),

        # Wer hat geändert?
        sa.Column('geaendert_von', sa.Integer(), sa.ForeignKey('benutzer.id', ondelete='SET NULL'), nullable=True),

        # Änderungstyp
        sa.Column('aktion', sa.String(50), nullable=False),

        # Vorher / Nachher
        sa.Column('alt_dozent_id', sa.Integer(), sa.ForeignKey('dozent.id', ondelete='SET NULL'), nullable=True),
        sa.Column('neu_dozent_id', sa.Integer(), sa.ForeignKey('dozent.id', ondelete='SET NULL'), nullable=True),
        sa.Column('alte_rolle', sa.String(50), nullable=True),
        sa.Column('neue_rolle', sa.String(50), nullable=True),

        # Zusätzliche Infos
        sa.Column('bemerkung', sa.Text(), nullable=True),

        # Timestamp
        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )

    # Indexes
    op.create_index('ix_modul_audit_log_modul_id', 'modul_audit_log', ['modul_id'])
    op.create_index('ix_modul_audit_log_created_at', 'modul_audit_log', ['created_at'])
    op.create_index('ix_modul_audit_modul_datum', 'modul_audit_log', ['modul_id', 'created_at'])


def downgrade():
    """
    Entfernt modul_audit_log Tabelle
    """
    op.drop_index('ix_modul_audit_modul_datum', table_name='modul_audit_log')
    op.drop_index('ix_modul_audit_log_created_at', table_name='modul_audit_log')
    op.drop_index('ix_modul_audit_log_modul_id', table_name='modul_audit_log')
    op.drop_table('modul_audit_log')
