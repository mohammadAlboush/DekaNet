"""Add room columns to geplantes_modul table

Revision ID: 003_raum_planung
Revises: 002_auftrag_tables
Create Date: 2025-01-25

Feature 4: Raumplanung pro Lehrform
- Jede Lehrform bekommt ein eigenes Raumfeld
- Vorlesung ist Pflichtfeld (wird im Frontend validiert)
"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '003_raum_planung'
down_revision = '002_auftrag_tables'
branch_labels = None
depends_on = None


def upgrade():
    """
    Fügt Raumfelder für jede Lehrform zur geplante_module Tabelle hinzu
    """
    with op.batch_alter_table('geplante_module', schema=None) as batch_op:
        # Raumfelder für jede Lehrform
        batch_op.add_column(sa.Column('raum_vorlesung', sa.String(100), nullable=True))
        batch_op.add_column(sa.Column('raum_uebung', sa.String(100), nullable=True))
        batch_op.add_column(sa.Column('raum_praktikum', sa.String(100), nullable=True))
        batch_op.add_column(sa.Column('raum_seminar', sa.String(100), nullable=True))


def downgrade():
    """
    Entfernt Raumfelder
    """
    with op.batch_alter_table('geplante_module', schema=None) as batch_op:
        batch_op.drop_column('raum_seminar')
        batch_op.drop_column('raum_praktikum')
        batch_op.drop_column('raum_uebung')
        batch_op.drop_column('raum_vorlesung')
