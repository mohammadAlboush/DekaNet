"""Create deputatsabrechnung tables

Revision ID: 006_deputatsabrechnung
Revises: 005_kapazitaet_columns
Create Date: 2025-01-28

Feature 4: Deputatsabrechnung
- Neue Tabelle: deputats_einstellungen (globale Konfiguration)
- Neue Tabelle: deputatsabrechnung (Haupttabelle)
- Neue Tabelle: deputats_lehrtaetigkeit (Lehrveranstaltungen)
- Neue Tabelle: deputats_lehrexport (Lehre für andere FB)
- Neue Tabelle: deputats_vertretung (Vertretungen)
- Neue Tabelle: deputats_ermaessigung (Ermäßigungen)
- Neue Tabelle: deputats_betreuung (Abschlussarbeiten & Projekte)
"""
from alembic import op
import sqlalchemy as sa
from datetime import datetime


# revision identifiers, used by Alembic.
revision = '006_deputatsabrechnung'
down_revision = '005_kapazitaet_columns'
branch_labels = None
depends_on = None


def upgrade():
    """
    Erstellt alle Deputatsabrechnung-Tabellen
    """
    # =========================================================================
    # 1. DEPUTATS_EINSTELLUNGEN (Globale Konfiguration)
    # =========================================================================
    op.create_table(
        'deputats_einstellungen',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),

        # SWS-Werte für Betreuungen
        sa.Column('sws_bachelor_arbeit', sa.Float(), nullable=False, default=0.3),
        sa.Column('sws_master_arbeit', sa.Float(), nullable=False, default=0.5),
        sa.Column('sws_doktorarbeit', sa.Float(), nullable=False, default=1.0),
        sa.Column('sws_seminar_ba', sa.Float(), nullable=False, default=0.2),
        sa.Column('sws_seminar_ma', sa.Float(), nullable=False, default=0.3),
        sa.Column('sws_projekt_ba', sa.Float(), nullable=False, default=0.2),
        sa.Column('sws_projekt_ma', sa.Float(), nullable=False, default=0.3),

        # Obergrenzen
        sa.Column('max_sws_praxisseminar', sa.Float(), nullable=False, default=5.0),
        sa.Column('max_sws_projektveranstaltung', sa.Float(), nullable=False, default=6.0),
        sa.Column('max_sws_seminar_master', sa.Float(), nullable=False, default=4.0),
        sa.Column('max_sws_betreuung', sa.Float(), nullable=False, default=3.0),

        # Warnschwellen
        sa.Column('warn_ermaessigung_ueber', sa.Float(), nullable=False, default=5.0),

        # Standard-Lehrverpflichtung
        sa.Column('default_netto_lehrverpflichtung', sa.Float(), nullable=False, default=18.0),

        # Meta
        sa.Column('ist_aktiv', sa.Boolean(), nullable=False, default=True),
        sa.Column('beschreibung', sa.String(500), nullable=True),
        sa.Column('erstellt_von', sa.Integer(), sa.ForeignKey('benutzer.id', ondelete='SET NULL'), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(), nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow),
    )

    # Insert default settings
    op.execute("""
        INSERT INTO deputats_einstellungen (
            sws_bachelor_arbeit, sws_master_arbeit, sws_doktorarbeit,
            sws_seminar_ba, sws_seminar_ma, sws_projekt_ba, sws_projekt_ma,
            max_sws_praxisseminar, max_sws_projektveranstaltung, max_sws_seminar_master, max_sws_betreuung,
            warn_ermaessigung_ueber, default_netto_lehrverpflichtung,
            ist_aktiv, beschreibung, created_at, updated_at
        ) VALUES (
            0.3, 0.5, 1.0,
            0.2, 0.3, 0.2, 0.3,
            5.0, 6.0, 4.0, 3.0,
            5.0, 18.0,
            1, 'Standard-Einstellungen', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        )
    """)

    # =========================================================================
    # 2. DEPUTATSABRECHNUNG (Haupttabelle)
    # =========================================================================
    op.create_table(
        'deputatsabrechnung',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),

        # Verknüpfungen
        sa.Column('planungsphase_id', sa.Integer(), sa.ForeignKey('planungsphasen.id', ondelete='CASCADE'), nullable=False),
        sa.Column('benutzer_id', sa.Integer(), sa.ForeignKey('benutzer.id', ondelete='CASCADE'), nullable=False),

        # Deputatswerte
        sa.Column('netto_lehrverpflichtung', sa.Float(), nullable=False, default=18.0),

        # Status Workflow
        sa.Column('status', sa.String(50), nullable=False, default='entwurf'),

        # Freitext
        sa.Column('bemerkungen', sa.Text(), nullable=True),

        # Workflow Timestamps
        sa.Column('eingereicht_am', sa.DateTime(), nullable=True),
        sa.Column('genehmigt_von', sa.Integer(), sa.ForeignKey('benutzer.id', ondelete='SET NULL'), nullable=True),
        sa.Column('genehmigt_am', sa.DateTime(), nullable=True),
        sa.Column('abgelehnt_am', sa.DateTime(), nullable=True),
        sa.Column('ablehnungsgrund', sa.Text(), nullable=True),

        # Audit
        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
        sa.Column('updated_at', sa.DateTime(), nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow),
    )

    # Indexes
    op.create_index('ix_deputatsabrechnung_planungsphase', 'deputatsabrechnung', ['planungsphase_id'])
    op.create_index('ix_deputatsabrechnung_benutzer', 'deputatsabrechnung', ['benutzer_id'])
    op.create_index('ix_deputatsabrechnung_status', 'deputatsabrechnung', ['status'])
    op.create_index('ix_deputatsabrechnung_benutzer_status', 'deputatsabrechnung', ['benutzer_id', 'status'])

    # Unique constraint: Ein Benutzer kann pro Planungsphase nur EINE Abrechnung haben
    op.create_index(
        'uq_deputat_phase_benutzer',
        'deputatsabrechnung',
        ['planungsphase_id', 'benutzer_id'],
        unique=True
    )

    # =========================================================================
    # 3. DEPUTATS_LEHRTAETIGKEIT
    # =========================================================================
    op.create_table(
        'deputats_lehrtaetigkeit',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('deputatsabrechnung_id', sa.Integer(), sa.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'), nullable=False),

        # Lehrtätigkeits-Details
        sa.Column('bezeichnung', sa.String(200), nullable=False),
        sa.Column('kategorie', sa.String(50), nullable=False, default='lehrveranstaltung'),
        sa.Column('sws', sa.Float(), nullable=False),

        # Wochentag (für Tabellenansicht)
        sa.Column('wochentag', sa.String(20), nullable=True),
        sa.Column('ist_block', sa.Boolean(), nullable=False, default=False),

        # Quelle
        sa.Column('quelle', sa.String(20), nullable=False, default='manuell'),
        sa.Column('geplantes_modul_id', sa.Integer(), sa.ForeignKey('geplante_module.id', ondelete='SET NULL'), nullable=True),

        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )

    op.create_index('ix_deputats_lehrtaetigkeit_abrechnung', 'deputats_lehrtaetigkeit', ['deputatsabrechnung_id'])
    op.create_index('ix_deputats_lehrtaetigkeit_kategorie', 'deputats_lehrtaetigkeit', ['kategorie'])

    # =========================================================================
    # 4. DEPUTATS_LEHREXPORT
    # =========================================================================
    op.create_table(
        'deputats_lehrexport',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('deputatsabrechnung_id', sa.Integer(), sa.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'), nullable=False),

        sa.Column('fachbereich', sa.String(100), nullable=False),
        sa.Column('fach', sa.String(200), nullable=False),
        sa.Column('sws', sa.Float(), nullable=False),

        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )

    op.create_index('ix_deputats_lehrexport_abrechnung', 'deputats_lehrexport', ['deputatsabrechnung_id'])

    # =========================================================================
    # 5. DEPUTATS_VERTRETUNG
    # =========================================================================
    op.create_table(
        'deputats_vertretung',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('deputatsabrechnung_id', sa.Integer(), sa.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'), nullable=False),

        sa.Column('art', sa.String(50), nullable=False),
        sa.Column('vertretene_person', sa.String(200), nullable=False),
        sa.Column('fach_professor', sa.String(200), nullable=False),
        sa.Column('sws', sa.Float(), nullable=False),

        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )

    op.create_index('ix_deputats_vertretung_abrechnung', 'deputats_vertretung', ['deputatsabrechnung_id'])

    # =========================================================================
    # 6. DEPUTATS_ERMAESSIGUNG
    # =========================================================================
    op.create_table(
        'deputats_ermaessigung',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('deputatsabrechnung_id', sa.Integer(), sa.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'), nullable=False),

        sa.Column('bezeichnung', sa.String(200), nullable=False),
        sa.Column('sws', sa.Float(), nullable=False),

        # Quelle
        sa.Column('quelle', sa.String(20), nullable=False, default='manuell'),
        sa.Column('semester_auftrag_id', sa.Integer(), sa.ForeignKey('semester_auftrag.id', ondelete='SET NULL'), nullable=True),

        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )

    op.create_index('ix_deputats_ermaessigung_abrechnung', 'deputats_ermaessigung', ['deputatsabrechnung_id'])

    # =========================================================================
    # 7. DEPUTATS_BETREUUNG
    # =========================================================================
    op.create_table(
        'deputats_betreuung',
        sa.Column('id', sa.Integer(), primary_key=True, autoincrement=True),
        sa.Column('deputatsabrechnung_id', sa.Integer(), sa.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'), nullable=False),

        # Student
        sa.Column('student_name', sa.String(100), nullable=False),
        sa.Column('student_vorname', sa.String(100), nullable=False),
        sa.Column('titel_arbeit', sa.String(500), nullable=True),

        # Betreuungsart
        sa.Column('betreuungsart', sa.String(50), nullable=False),

        # Status
        sa.Column('status', sa.String(20), nullable=False, default='laufend'),
        sa.Column('beginn_datum', sa.Date(), nullable=True),
        sa.Column('ende_datum', sa.Date(), nullable=True),

        # SWS (automatisch berechnet)
        sa.Column('sws', sa.Float(), nullable=False, default=0.0),

        sa.Column('created_at', sa.DateTime(), nullable=False, default=datetime.utcnow),
    )

    op.create_index('ix_deputats_betreuung_abrechnung', 'deputats_betreuung', ['deputatsabrechnung_id'])
    op.create_index('ix_deputats_betreuung_art', 'deputats_betreuung', ['betreuungsart'])


def downgrade():
    """
    Löscht alle Deputatsabrechnung-Tabellen
    """
    # Drop indexes and tables in reverse order

    # 7. deputats_betreuung
    op.drop_index('ix_deputats_betreuung_art', table_name='deputats_betreuung')
    op.drop_index('ix_deputats_betreuung_abrechnung', table_name='deputats_betreuung')
    op.drop_table('deputats_betreuung')

    # 6. deputats_ermaessigung
    op.drop_index('ix_deputats_ermaessigung_abrechnung', table_name='deputats_ermaessigung')
    op.drop_table('deputats_ermaessigung')

    # 5. deputats_vertretung
    op.drop_index('ix_deputats_vertretung_abrechnung', table_name='deputats_vertretung')
    op.drop_table('deputats_vertretung')

    # 4. deputats_lehrexport
    op.drop_index('ix_deputats_lehrexport_abrechnung', table_name='deputats_lehrexport')
    op.drop_table('deputats_lehrexport')

    # 3. deputats_lehrtaetigkeit
    op.drop_index('ix_deputats_lehrtaetigkeit_kategorie', table_name='deputats_lehrtaetigkeit')
    op.drop_index('ix_deputats_lehrtaetigkeit_abrechnung', table_name='deputats_lehrtaetigkeit')
    op.drop_table('deputats_lehrtaetigkeit')

    # 2. deputatsabrechnung
    op.drop_index('uq_deputat_phase_benutzer', table_name='deputatsabrechnung')
    op.drop_index('ix_deputatsabrechnung_benutzer_status', table_name='deputatsabrechnung')
    op.drop_index('ix_deputatsabrechnung_status', table_name='deputatsabrechnung')
    op.drop_index('ix_deputatsabrechnung_benutzer', table_name='deputatsabrechnung')
    op.drop_index('ix_deputatsabrechnung_planungsphase', table_name='deputatsabrechnung')
    op.drop_table('deputatsabrechnung')

    # 1. deputats_einstellungen
    op.drop_table('deputats_einstellungen')
