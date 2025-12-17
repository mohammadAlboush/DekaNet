"""Create auftrag and semester_auftrag tables

Revision ID: 002_auftrag_tables
Revises: 001_vertreter_zweitpruefer
Create Date: 2025-01-25

Feature 2: Semesteraufträge (Dekanin, Prodekan, etc.)
- Neue Tabelle: auftrag (Master-Liste)
- Neue Tabelle: semester_auftrag (Zuordnung pro Semester)
- Historie & mehrfache Zuordnungen möglich
"""
from alembic import op
import sqlalchemy as sa
from datetime import datetime


# revision identifiers, used by Alembic.
revision = '002_auftrag_tables'
down_revision = '001_vertreter_zweitpruefer'
branch_labels = None
depends_on = None


def upgrade():
    """
    Erstellt auftrag und semester_auftrag Tabellen
    """
    # Create auftrag table (Master-Liste)
    op.create_table(
        'auftrag',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('name', sa.String(100), nullable=False, unique=True),
        sa.Column('beschreibung', sa.Text(), nullable=True),
        sa.Column('standard_sws', sa.Float(), nullable=False, default=0.0),
        sa.Column('ist_aktiv', sa.Boolean(), nullable=False, default=True),
        sa.Column('sortierung', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(), nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow),
    )

    # Create index on name
    op.create_index('ix_auftrag_name', 'auftrag', ['name'])

    # Create semester_auftrag table (Zuordnung pro Semester)
    op.create_table(
        'semester_auftrag',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('semester_id', sa.Integer(), sa.ForeignKey('semester.id', ondelete='CASCADE'), nullable=False),
        sa.Column('auftrag_id', sa.Integer(), sa.ForeignKey('auftrag.id', ondelete='CASCADE'), nullable=False),
        sa.Column('dozent_id', sa.Integer(), sa.ForeignKey('dozent.id', ondelete='CASCADE'), nullable=False),
        sa.Column('sws', sa.Float(), nullable=False, default=0.0),
        sa.Column('status', sa.String(20), nullable=False, default='beantragt'),  # beantragt, genehmigt, abgelehnt
        sa.Column('beantragt_von', sa.Integer(), sa.ForeignKey('benutzer.id', ondelete='SET NULL'), nullable=True),
        sa.Column('genehmigt_von', sa.Integer(), sa.ForeignKey('benutzer.id', ondelete='SET NULL'), nullable=True),
        sa.Column('genehmigt_am', sa.DateTime(), nullable=True),
        sa.Column('anmerkung', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(), nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow),
    )

    # Create indexes
    op.create_index('ix_semester_auftrag_semester', 'semester_auftrag', ['semester_id'])
    op.create_index('ix_semester_auftrag_dozent', 'semester_auftrag', ['dozent_id'])
    op.create_index('ix_semester_auftrag_status', 'semester_auftrag', ['status'])

    # Create unique constraint (ein Dozent kann denselben Auftrag pro Semester nur einmal haben)
    op.create_index(
        'ix_semester_auftrag_unique',
        'semester_auftrag',
        ['semester_id', 'auftrag_id', 'dozent_id'],
        unique=True
    )

    # Insert default aufträge from requirements
    op.execute("""
        INSERT INTO auftrag (name, standard_sws, beschreibung, sortierung) VALUES
        ('Eventmanagement', 0.5, 'Koordination von Veranstaltungen und Events', 1),
        ('Auslandsbeauftragter 1', 0.5, 'Betreuung internationaler Studierender', 2),
        ('Auslandsbeauftragter 2', 0.5, 'Betreuung internationaler Studierender', 3),
        ('BAföG', 0.0, 'BAföG-Beratung und -Verwaltung', 4),
        ('Datensicherheit und Netzwerk', 0.0, 'IT-Sicherheit und Netzwerkverwaltung', 5),
        ('Dekanin', 5.0, 'Leitung des Fachbereichs', 6),
        ('Digitalisierung', 0.5, 'Digitalisierungsbeauftragter', 7),
        ('Marketing', 2.0, 'Marketing und Öffentlichkeitsarbeit', 8),
        ('Evaluation', 0.0, 'Qualitätssicherung und Evaluation', 9),
        ('Gleichstellung', 0.0, 'Gleichstellungsbeauftragte/r', 10),
        ('Prodekan', 4.5, 'Stellvertretung der Dekanin', 11),
        ('Sicherheit', 0.0, 'Sicherheitsbeauftragter', 12),
        ('Studienberatung Frauen', 0.0, 'Studienberatung speziell für Studentinnen', 13),
        ('Studiengangsbeauftragter IS', 0.5, 'Studiengangsleitung Informationssysteme', 14),
        ('Studiengangsbeauftragter ID', 0.5, 'Studiengangsleitung Interaction Design', 15),
        ('Studiengangsbeauftragter Inf 1', 0.5, 'Studiengangsleitung Informatik 1', 16),
        ('Studiengangsbeauftragter Inf 2', 0.0, 'Studiengangsleitung Informatik 2', 17),
        ('Studiengangsbeauftragter WI', 0.5, 'Studiengangsleitung Wirtschaftsinformatik', 18),
        ('Stundenplanerstellung', 1.0, 'Erstellung und Verwaltung des Stundenplans', 19),
        ('Prüfungsausschuss', 2.0, 'Mitglied im Prüfungsausschuss', 20)
    """)


def downgrade():
    """
    Löscht semester_auftrag und auftrag Tabellen
    """
    # Drop indexes first
    op.drop_index('ix_semester_auftrag_unique', table_name='semester_auftrag')
    op.drop_index('ix_semester_auftrag_status', table_name='semester_auftrag')
    op.drop_index('ix_semester_auftrag_dozent', table_name='semester_auftrag')
    op.drop_index('ix_semester_auftrag_semester', table_name='semester_auftrag')
    op.drop_index('ix_auftrag_name', table_name='auftrag')

    # Drop tables
    op.drop_table('semester_auftrag')
    op.drop_table('auftrag')
