"""Add vertreter_id and zweitpruefer_id to modul_dozent

Revision ID: 001_vertreter_zweitpruefer
Revises:
Create Date: 2025-01-25

Feature 1: Vertreter & Zweitprüfer pro Modul
- Neue Spalten: vertreter_id, zweitpruefer_id (beide nullable)
- Foreign Keys zu dozent.id
"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '001_vertreter_zweitpruefer'
down_revision = None  # Set this to the latest migration
branch_labels = None
depends_on = None


def upgrade():
    """
    Fügt vertreter_id und zweitpruefer_id zu modul_dozent hinzu
    """
    # Add columns to modul_dozent table
    with op.batch_alter_table('modul_dozent', schema=None) as batch_op:
        batch_op.add_column(sa.Column('vertreter_id', sa.Integer(), nullable=True))
        batch_op.add_column(sa.Column('zweitpruefer_id', sa.Integer(), nullable=True))

        # Add foreign key constraints
        batch_op.create_foreign_key(
            'fk_modul_dozent_vertreter',
            'dozent',
            ['vertreter_id'],
            ['id'],
            ondelete='SET NULL'
        )
        batch_op.create_foreign_key(
            'fk_modul_dozent_zweitpruefer',
            'dozent',
            ['zweitpruefer_id'],
            ['id'],
            ondelete='SET NULL'
        )


def downgrade():
    """
    Entfernt vertreter_id und zweitpruefer_id aus modul_dozent
    """
    with op.batch_alter_table('modul_dozent', schema=None) as batch_op:
        batch_op.drop_constraint('fk_modul_dozent_zweitpruefer', type_='foreignkey')
        batch_op.drop_constraint('fk_modul_dozent_vertreter', type_='foreignkey')
        batch_op.drop_column('zweitpruefer_id')
        batch_op.drop_column('vertreter_id')
