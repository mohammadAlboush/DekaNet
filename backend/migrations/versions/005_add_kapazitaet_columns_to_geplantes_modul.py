"""Add capacity columns to geplantes_modul table

Revision ID: 005_kapazitaet
Revises: 004_create_modul_audit_log
Create Date: 2025-12-05

Feature 4 Extended: Kapazitätsplanung pro Lehrform
- Jede Lehrform bekommt ein eigenes Kapazitätsfeld
"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '005_kapazitaet'
down_revision = '004_create_modul_audit_log'
branch_labels = None
depends_on = None


def upgrade():
    """
    Fügt Kapazitätsfelder für jede Lehrform zur geplante_module Tabelle hinzu
    """
    with op.batch_alter_table('geplante_module', schema=None) as batch_op:
        # Kapazitätsfelder für jede Lehrform
        batch_op.add_column(sa.Column('kapazitaet_vorlesung', sa.Integer(), nullable=True))
        batch_op.add_column(sa.Column('kapazitaet_uebung', sa.Integer(), nullable=True))
        batch_op.add_column(sa.Column('kapazitaet_praktikum', sa.Integer(), nullable=True))
        batch_op.add_column(sa.Column('kapazitaet_seminar', sa.Integer(), nullable=True))


def downgrade():
    """
    Entfernt Kapazitätsfelder
    """
    with op.batch_alter_table('geplante_module', schema=None) as batch_op:
        batch_op.drop_column('kapazitaet_seminar')
        batch_op.drop_column('kapazitaet_praktikum')
        batch_op.drop_column('kapazitaet_uebung')
        batch_op.drop_column('kapazitaet_vorlesung')
