"""
Deputatsabrechnung Models
=========================

Feature: Vollständige Deputatsabrechnungsfunktion

Models:
- Deputatsabrechnung: Haupttabelle (eine pro Planungsphase + Benutzer)
- DeputatsLehrtaetigkeit: Lehrveranstaltungen (aus Planung oder manuell)
- DeputatsLehrexport: Lehre für andere Fachbereiche (manuell)
- DeputatsVertretung: Vertretungen (manuell)
- DeputatsErmaessigung: Ermäßigungen (aus Semesteraufträgen oder manuell)
- DeputatsBetreuung: Betreuung von Abschlussarbeiten (manuell)

Workflow:
- Entwurf → Eingereicht → Genehmigt/Abgelehnt
- Automatischer Import aus Planung und Semesteraufträgen
- Manuelle Ergänzungen möglich
"""

from datetime import datetime, date
from typing import Optional, List, Dict, Any
from app.extensions import db


# =============================================================================
# HAUPTTABELLE: DEPUTATSABRECHNUNG
# =============================================================================

class Deputatsabrechnung(db.Model):
    """
    Deputatsabrechnung - Haupttabelle

    Eine Abrechnung pro Planungsphase und Benutzer.
    Enthält alle Deputats-Komponenten und den Workflow-Status.

    Attributes:
        planungsphase_id: Verknüpfung zur Planungsphase (UNIQUE mit benutzer_id)
        benutzer_id: Der Professor der die Abrechnung erstellt
        netto_lehrverpflichtung: Soll-Deputat (Standard: 18 SWS)
        status: Workflow-Status
        bemerkungen: Freitext für Anmerkungen
    """
    __tablename__ = 'deputatsabrechnung'

    id = db.Column(db.Integer, primary_key=True)

    # Verknüpfungen
    planungsphase_id = db.Column(
        db.Integer,
        db.ForeignKey('planungsphasen.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    benutzer_id = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    # Deputatswerte
    netto_lehrverpflichtung = db.Column(db.Float, default=18.0, nullable=False)

    # Status Workflow
    status = db.Column(
        db.String(50),
        default='entwurf',
        nullable=False,
        index=True
    )  # 'entwurf', 'eingereicht', 'genehmigt', 'abgelehnt'

    # Freitext
    bemerkungen = db.Column(db.Text, nullable=True)

    # Workflow Timestamps
    eingereicht_am = db.Column(db.DateTime, nullable=True)
    genehmigt_von = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='SET NULL'),
        nullable=True
    )
    genehmigt_am = db.Column(db.DateTime, nullable=True)
    abgelehnt_am = db.Column(db.DateTime, nullable=True)
    ablehnungsgrund = db.Column(db.Text, nullable=True)

    # Audit
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )

    # Relationships
    planungsphase = db.relationship(
        'Planungsphase',
        foreign_keys=[planungsphase_id],
        backref=db.backref('deputatsabrechnungen', lazy='dynamic')
    )
    benutzer = db.relationship(
        'Benutzer',
        foreign_keys=[benutzer_id],
        backref=db.backref('deputatsabrechnungen', lazy='dynamic')
    )
    genehmiger = db.relationship(
        'Benutzer',
        foreign_keys=[genehmigt_von]
    )

    # Child-Tabellen
    lehrtaetigkeiten = db.relationship(
        'DeputatsLehrtaetigkeit',
        back_populates='deputatsabrechnung',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )
    lehrexporte = db.relationship(
        'DeputatsLehrexport',
        back_populates='deputatsabrechnung',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )
    vertretungen = db.relationship(
        'DeputatsVertretung',
        back_populates='deputatsabrechnung',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )
    ermaessigungen = db.relationship(
        'DeputatsErmaessigung',
        back_populates='deputatsabrechnung',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )
    betreuungen = db.relationship(
        'DeputatsBetreuung',
        back_populates='deputatsabrechnung',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )

    # UNIQUE Constraint: Ein User kann EINE Abrechnung pro Planungsphase haben
    __table_args__ = (
        db.UniqueConstraint(
            'planungsphase_id',
            'benutzer_id',
            name='uq_deputat_phase_benutzer'
        ),
        db.Index('ix_deputat_status', 'status'),
        db.Index('ix_deputat_benutzer_status', 'benutzer_id', 'status'),
    )

    def __repr__(self):
        return f'<Deputatsabrechnung {self.id} - {self.benutzer.username if self.benutzer else "?"} - {self.status}>'

    # =========================================================================
    # STATUS CHECKS
    # =========================================================================

    @property
    def ist_entwurf(self) -> bool:
        """Ist Status = entwurf?"""
        return self.status == 'entwurf'

    @property
    def ist_eingereicht(self) -> bool:
        """Ist Status = eingereicht?"""
        return self.status == 'eingereicht'

    @property
    def ist_genehmigt(self) -> bool:
        """Ist Status = genehmigt?"""
        return self.status == 'genehmigt'

    @property
    def ist_abgelehnt(self) -> bool:
        """Ist Status = abgelehnt?"""
        return self.status == 'abgelehnt'

    def kann_bearbeitet_werden(self) -> bool:
        """Kann die Abrechnung noch bearbeitet werden?"""
        return self.status in ['entwurf', 'abgelehnt']

    def kann_eingereicht_werden(self) -> bool:
        """Kann die Abrechnung eingereicht werden?"""
        return self.status == 'entwurf'

    def kann_genehmigt_werden(self) -> bool:
        """Kann die Abrechnung genehmigt werden? (nur Dekan)"""
        return self.status == 'eingereicht'

    # =========================================================================
    # WORKFLOW ACTIONS
    # =========================================================================

    def einreichen(self) -> bool:
        """Reicht die Abrechnung ein"""
        if not self.kann_eingereicht_werden():
            raise ValueError(f"Abrechnung kann nicht eingereicht werden (Status: {self.status})")

        self.status = 'eingereicht'
        self.eingereicht_am = datetime.utcnow()
        db.session.commit()
        return True

    def genehmigen(self, genehmiger_id: int) -> bool:
        """Genehmigt die Abrechnung (nur Dekan)"""
        if not self.kann_genehmigt_werden():
            raise ValueError(f"Abrechnung kann nicht genehmigt werden (Status: {self.status})")

        self.status = 'genehmigt'
        self.genehmigt_von = genehmiger_id
        self.genehmigt_am = datetime.utcnow()
        db.session.commit()
        return True

    def ablehnen(self, grund: str = None) -> bool:
        """Lehnt die Abrechnung ab (nur Dekan)"""
        if self.status != 'eingereicht':
            raise ValueError(f"Nur eingereichte Abrechnungen können abgelehnt werden (Status: {self.status})")

        self.status = 'abgelehnt'
        self.abgelehnt_am = datetime.utcnow()
        self.ablehnungsgrund = grund
        db.session.commit()
        return True

    def zurueck_zu_entwurf(self) -> bool:
        """Setzt Status zurück auf Entwurf"""
        self.status = 'entwurf'
        self.eingereicht_am = None
        self.genehmigt_von = None
        self.genehmigt_am = None
        self.abgelehnt_am = None
        self.ablehnungsgrund = None
        db.session.commit()
        return True

    # =========================================================================
    # BERECHNUNGEN
    # =========================================================================

    def berechne_summen(self, einstellungen: 'DeputatsEinstellungen' = None) -> Dict[str, Any]:
        """
        Berechnet alle Summen der Deputatsabrechnung

        Args:
            einstellungen: DeputatsEinstellungen für Obergrenzen

        Returns:
            Dict mit allen berechneten Summen
        """
        from .deputat_einstellungen import DeputatsEinstellungen

        if einstellungen is None:
            einstellungen = DeputatsEinstellungen.get_current()

        # Lehrtätigkeiten (mit Obergrenzen)
        sws_lehrtaetigkeiten = 0.0
        sws_praxisseminar = 0.0
        sws_projektveranstaltung = 0.0
        sws_seminar_master = 0.0
        sws_sonstige = 0.0

        for lt in self.lehrtaetigkeiten.all():
            if lt.kategorie == 'praxisseminar':
                sws_praxisseminar += lt.sws
            elif lt.kategorie == 'projektveranstaltung':
                sws_projektveranstaltung += lt.sws
            elif lt.kategorie == 'seminar_master':
                sws_seminar_master += lt.sws
            else:
                sws_sonstige += lt.sws

        # Obergrenzen anwenden
        sws_praxisseminar_angerechnet = min(sws_praxisseminar, einstellungen.max_sws_praxisseminar)
        sws_projektveranstaltung_angerechnet = min(sws_projektveranstaltung, einstellungen.max_sws_projektveranstaltung)
        sws_seminar_master_angerechnet = min(sws_seminar_master, einstellungen.max_sws_seminar_master)

        sws_lehrtaetigkeiten = (
            sws_sonstige +
            sws_praxisseminar_angerechnet +
            sws_projektveranstaltung_angerechnet +
            sws_seminar_master_angerechnet
        )

        # Lehrexport
        sws_lehrexport = sum(le.sws for le in self.lehrexporte.all())

        # Vertretungen
        sws_vertretungen = sum(v.sws for v in self.vertretungen.all())

        # Ermäßigungen
        sws_ermaessigungen = sum(e.sws for e in self.ermaessigungen.all())

        # Betreuungen (mit Obergrenze)
        sws_betreuungen_roh = sum(b.sws for b in self.betreuungen.all())
        sws_betreuungen_angerechnet = min(sws_betreuungen_roh, einstellungen.max_sws_betreuung)

        # Gesamtdeputat (erbrachte Lehre + Funktionen/Semesteraufträge)
        # Funktionen (früher "Ermäßigungen") sind zusätzliche SWS aus Semesteraufträgen
        # z.B. Studiengangsleitung, Prüfungsausschuss, etc.
        gesamtdeputat = (
            sws_lehrtaetigkeiten +
            sws_lehrexport +
            sws_vertretungen +
            sws_betreuungen_angerechnet +
            sws_ermaessigungen  # Funktionen/Semesteraufträge addieren!
        )

        # Nettobelastung = Gesamtdeputat
        nettobelastung = gesamtdeputat

        # Differenz = Gesamtdeputat - Netto-Lehrverpflichtung
        differenz = gesamtdeputat - self.netto_lehrverpflichtung

        # Status-Bewertung
        if abs(differenz) <= 1.0:
            bewertung = 'erfuellt'
        elif abs(differenz) <= 3.0:
            bewertung = 'abweichung'
        else:
            bewertung = 'starke_abweichung'

        # Warnungen sammeln
        warnungen = []

        if sws_praxisseminar > einstellungen.max_sws_praxisseminar:
            warnungen.append(f"Praxisseminar: {sws_praxisseminar} SWS, max. {einstellungen.max_sws_praxisseminar} SWS angerechnet")

        if sws_projektveranstaltung > einstellungen.max_sws_projektveranstaltung:
            warnungen.append(f"Projektveranstaltung: {sws_projektveranstaltung} SWS, max. {einstellungen.max_sws_projektveranstaltung} SWS angerechnet")

        if sws_seminar_master > einstellungen.max_sws_seminar_master:
            warnungen.append(f"Seminar Master: {sws_seminar_master} SWS, max. {einstellungen.max_sws_seminar_master} SWS angerechnet")

        if sws_betreuungen_roh > einstellungen.max_sws_betreuung:
            warnungen.append(f"Betreuungen: {sws_betreuungen_roh} SWS, max. {einstellungen.max_sws_betreuung} SWS angerechnet")

        if sws_ermaessigungen > einstellungen.warn_ermaessigung_ueber:
            warnungen.append(f"Ermäßigungen überschreiten {einstellungen.warn_ermaessigung_ueber} SWS ({sws_ermaessigungen} SWS)")

        return {
            # Lehrtätigkeiten Detail
            'sws_lehrtaetigkeiten': round(sws_lehrtaetigkeiten, 2),
            'sws_praxisseminar': round(sws_praxisseminar, 2),
            'sws_praxisseminar_angerechnet': round(sws_praxisseminar_angerechnet, 2),
            'sws_projektveranstaltung': round(sws_projektveranstaltung, 2),
            'sws_projektveranstaltung_angerechnet': round(sws_projektveranstaltung_angerechnet, 2),
            'sws_seminar_master': round(sws_seminar_master, 2),
            'sws_seminar_master_angerechnet': round(sws_seminar_master_angerechnet, 2),
            'sws_sonstige_lehre': round(sws_sonstige, 2),

            # Weitere Kategorien
            'sws_lehrexport': round(sws_lehrexport, 2),
            'sws_vertretungen': round(sws_vertretungen, 2),
            'sws_ermaessigungen': round(sws_ermaessigungen, 2),
            'sws_betreuungen_roh': round(sws_betreuungen_roh, 2),
            'sws_betreuungen_angerechnet': round(sws_betreuungen_angerechnet, 2),

            # Summen
            'gesamtdeputat': round(gesamtdeputat, 2),
            'nettobelastung': round(nettobelastung, 2),
            'netto_lehrverpflichtung': round(self.netto_lehrverpflichtung, 2),
            'differenz': round(differenz, 2),

            # Bewertung
            'bewertung': bewertung,
            'warnungen': warnungen,

            # Anzahlen
            'anzahl_lehrtaetigkeiten': self.lehrtaetigkeiten.count(),
            'anzahl_lehrexporte': self.lehrexporte.count(),
            'anzahl_vertretungen': self.vertretungen.count(),
            'anzahl_ermaessigungen': self.ermaessigungen.count(),
            'anzahl_betreuungen': self.betreuungen.count(),
        }

    # =========================================================================
    # SERIALISIERUNG
    # =========================================================================

    def to_dict(self, include_details: bool = False, include_summen: bool = False) -> Dict[str, Any]:
        """Konvertiert zu Dictionary (für API)"""
        data = {
            'id': self.id,
            'planungsphase_id': self.planungsphase_id,
            'benutzer_id': self.benutzer_id,
            'status': self.status,
            'netto_lehrverpflichtung': self.netto_lehrverpflichtung,
            'bemerkungen': self.bemerkungen,
            'eingereicht_am': self.eingereicht_am.isoformat() if self.eingereicht_am else None,
            'genehmigt_am': self.genehmigt_am.isoformat() if self.genehmigt_am else None,
            'genehmigt_von': self.genehmigt_von,
            'abgelehnt_am': self.abgelehnt_am.isoformat() if self.abgelehnt_am else None,
            'ablehnungsgrund': self.ablehnungsgrund,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None,
        }

        # Benutzer-Info
        if self.benutzer:
            data['benutzer'] = {
                'id': self.benutzer.id,
                'username': self.benutzer.username,
                'name_komplett': self.benutzer.name_komplett,
                'email': self.benutzer.email
            }

        # Planungsphase-Info
        if self.planungsphase:
            data['planungsphase'] = {
                'id': self.planungsphase.id,
                'name': self.planungsphase.name,
                'semester_id': self.planungsphase.semester_id,
                'semester_kuerzel': self.planungsphase.semester.kuerzel if self.planungsphase.semester else None
            }

        # Genehmiger-Info
        if self.genehmiger:
            data['genehmiger'] = {
                'id': self.genehmiger.id,
                'name_komplett': self.genehmiger.name_komplett
            }

        if include_details:
            data['lehrtaetigkeiten'] = [lt.to_dict() for lt in self.lehrtaetigkeiten.all()]
            data['lehrexporte'] = [le.to_dict() for le in self.lehrexporte.all()]
            data['vertretungen'] = [v.to_dict() for v in self.vertretungen.all()]
            data['ermaessigungen'] = [e.to_dict() for e in self.ermaessigungen.all()]
            data['betreuungen'] = [b.to_dict() for b in self.betreuungen.all()]

        if include_summen:
            try:
                data['summen'] = self.berechne_summen()
            except Exception as e:
                import logging
                logging.getLogger(__name__).warning(f"berechne_summen failed: {e}")
                # Fallback mit Default-Werten
                data['summen'] = {
                    'sws_lehrtaetigkeiten': 0,
                    'sws_praxisseminar': 0,
                    'sws_praxisseminar_angerechnet': 0,
                    'sws_projektveranstaltung': 0,
                    'sws_projektveranstaltung_angerechnet': 0,
                    'sws_seminar_master': 0,
                    'sws_seminar_master_angerechnet': 0,
                    'sws_sonstige_lehre': 0,
                    'sws_lehrexport': 0,
                    'sws_vertretungen': 0,
                    'sws_ermaessigungen': 0,
                    'sws_betreuungen_roh': 0,
                    'sws_betreuungen_angerechnet': 0,
                    'gesamtdeputat': 0,
                    'nettobelastung': 0,
                    'netto_lehrverpflichtung': self.netto_lehrverpflichtung,
                    'differenz': 0,
                    'bewertung': 'abweichung',
                    'warnungen': [f'Fehler bei Berechnung: {str(e)}'],
                    'anzahl_lehrtaetigkeiten': 0,
                    'anzahl_lehrexporte': 0,
                    'anzahl_vertretungen': 0,
                    'anzahl_ermaessigungen': 0,
                    'anzahl_betreuungen': 0,
                }

        return data


# =============================================================================
# LEHRTÄTIGKEITEN
# =============================================================================

class DeputatsLehrtaetigkeit(db.Model):
    """
    Lehrtätigkeit in der Deputatsabrechnung

    Kann aus der Planung importiert oder manuell hinzugefügt werden.

    Kategorien:
    - lehrveranstaltung: Normale Lehrveranstaltung
    - praxisseminar: Max. 5 SWS anrechenbar
    - projektveranstaltung: Max. 6 SWS anrechenbar
    - seminar_master: Max. 4 SWS anrechenbar
    """
    __tablename__ = 'deputats_lehrtaetigkeit'

    id = db.Column(db.Integer, primary_key=True)
    deputatsabrechnung_id = db.Column(
        db.Integer,
        db.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    # Lehrtätigkeits-Details
    bezeichnung = db.Column(db.String(200), nullable=False)
    kategorie = db.Column(
        db.String(50),
        default='lehrveranstaltung',
        nullable=False
    )  # 'lehrveranstaltung', 'praxisseminar', 'projektveranstaltung', 'seminar_master'

    sws = db.Column(db.Float, nullable=False)

    # Wochentage (für Tabellenansicht) - NEU: Mehrere Tage möglich als JSON-Array
    wochentag = db.Column(db.String(20), nullable=True)  # Legacy: einzelner Tag
    wochentage = db.Column(db.JSON, nullable=True)  # NEU: Array von Tagen ['montag', 'mittwoch']
    ist_block = db.Column(db.Boolean, default=False, nullable=False)

    # Quelle
    quelle = db.Column(db.String(20), default='manuell', nullable=False)  # 'planung', 'manuell'
    geplantes_modul_id = db.Column(
        db.Integer,
        db.ForeignKey('geplante_module.id', ondelete='SET NULL'),
        nullable=True
    )

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    deputatsabrechnung = db.relationship('Deputatsabrechnung', back_populates='lehrtaetigkeiten')
    geplantes_modul = db.relationship('GeplantesModul')

    # Konstanten
    KATEGORIEN = ['lehrveranstaltung', 'praxisseminar', 'projektveranstaltung', 'seminar_master']
    WOCHENTAGE = ['montag', 'dienstag', 'mittwoch', 'donnerstag', 'freitag']

    def __repr__(self):
        return f'<DeputatsLehrtaetigkeit {self.bezeichnung} ({self.sws} SWS)>'

    def get_wochentage_list(self) -> list:
        """Gibt Liste der Wochentage zurück (kombiniert legacy + neu)"""
        if self.wochentage:
            return self.wochentage
        elif self.wochentag:
            return [self.wochentag]
        return []

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'deputatsabrechnung_id': self.deputatsabrechnung_id,
            'bezeichnung': self.bezeichnung,
            'kategorie': self.kategorie,
            'sws': self.sws,
            'wochentag': self.wochentag,  # Legacy
            'wochentage': self.get_wochentage_list(),  # NEU: Array
            'ist_block': self.ist_block,
            'quelle': self.quelle,
            'geplantes_modul_id': self.geplantes_modul_id,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


# =============================================================================
# LEHREXPORT
# =============================================================================

class DeputatsLehrexport(db.Model):
    """
    Lehrexport - Lehre für andere Fachbereiche

    Komplett manuell eingetragen.
    """
    __tablename__ = 'deputats_lehrexport'

    id = db.Column(db.Integer, primary_key=True)
    deputatsabrechnung_id = db.Column(
        db.Integer,
        db.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    fachbereich = db.Column(db.String(100), nullable=False)
    fach = db.Column(db.String(200), nullable=False)
    sws = db.Column(db.Float, nullable=False)

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    deputatsabrechnung = db.relationship('Deputatsabrechnung', back_populates='lehrexporte')

    def __repr__(self):
        return f'<DeputatsLehrexport {self.fachbereich} - {self.fach} ({self.sws} SWS)>'

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'deputatsabrechnung_id': self.deputatsabrechnung_id,
            'fachbereich': self.fachbereich,
            'fach': self.fach,
            'sws': self.sws,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


# =============================================================================
# VERTRETUNGEN
# =============================================================================

class DeputatsVertretung(db.Model):
    """
    Vertretung für Praxis- oder Forschungsfreisemester

    Komplett manuell eingetragen.
    """
    __tablename__ = 'deputats_vertretung'

    id = db.Column(db.Integer, primary_key=True)
    deputatsabrechnung_id = db.Column(
        db.Integer,
        db.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    art = db.Column(db.String(50), nullable=False)  # 'praxissemester', 'forschungsfreisemester'
    vertretene_person = db.Column(db.String(200), nullable=False)
    fach_professor = db.Column(db.String(200), nullable=False)
    sws = db.Column(db.Float, nullable=False)

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    deputatsabrechnung = db.relationship('Deputatsabrechnung', back_populates='vertretungen')

    # Konstanten
    ARTEN = ['praxissemester', 'forschungsfreisemester']

    def __repr__(self):
        return f'<DeputatsVertretung {self.art} - {self.vertretene_person} ({self.sws} SWS)>'

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'deputatsabrechnung_id': self.deputatsabrechnung_id,
            'art': self.art,
            'vertretene_person': self.vertretene_person,
            'fach_professor': self.fach_professor,
            'sws': self.sws,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


# =============================================================================
# ERMÄSSIGUNGEN
# =============================================================================

class DeputatsErmaessigung(db.Model):
    """
    Ermäßigungsstunden

    Kann aus Semesteraufträgen importiert oder manuell hinzugefügt werden.
    Warnung wenn Gesamt > 5 SWS.
    """
    __tablename__ = 'deputats_ermaessigung'

    id = db.Column(db.Integer, primary_key=True)
    deputatsabrechnung_id = db.Column(
        db.Integer,
        db.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    bezeichnung = db.Column(db.String(200), nullable=False)
    sws = db.Column(db.Float, nullable=False)

    # Quelle
    quelle = db.Column(db.String(20), default='manuell', nullable=False)  # 'semesterauftrag', 'manuell'
    semester_auftrag_id = db.Column(
        db.Integer,
        db.ForeignKey('semester_auftrag.id', ondelete='SET NULL'),
        nullable=True
    )

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    deputatsabrechnung = db.relationship('Deputatsabrechnung', back_populates='ermaessigungen')
    semester_auftrag = db.relationship('SemesterAuftrag')

    def __repr__(self):
        return f'<DeputatsErmaessigung {self.bezeichnung} ({self.sws} SWS)>'

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'deputatsabrechnung_id': self.deputatsabrechnung_id,
            'bezeichnung': self.bezeichnung,
            'sws': self.sws,
            'quelle': self.quelle,
            'semester_auftrag_id': self.semester_auftrag_id,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


# =============================================================================
# BETREUUNGEN
# =============================================================================

class DeputatsBetreuung(db.Model):
    """
    Betreuung von Abschlussarbeiten und Projekten

    Komplett manuell eingetragen.
    SWS wird automatisch basierend auf Betreuungsart berechnet.
    Obergrenze: Max. 3 SWS für Abschlussarbeiten anrechenbar.
    """
    __tablename__ = 'deputats_betreuung'

    id = db.Column(db.Integer, primary_key=True)
    deputatsabrechnung_id = db.Column(
        db.Integer,
        db.ForeignKey('deputatsabrechnung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    # Student
    student_name = db.Column(db.String(100), nullable=False)
    student_vorname = db.Column(db.String(100), nullable=False)
    titel_arbeit = db.Column(db.String(500), nullable=True)

    # Betreuungsart
    betreuungsart = db.Column(db.String(50), nullable=False)
    # 'bachelor', 'master', 'doktorarbeit', 'seminar_ba', 'seminar_ma', 'projekt_ba', 'projekt_ma'

    # Status
    status = db.Column(db.String(20), default='laufend', nullable=False)  # 'laufend', 'abgeschlossen'
    beginn_datum = db.Column(db.Date, nullable=True)
    ende_datum = db.Column(db.Date, nullable=True)

    # SWS (automatisch berechnet)
    sws = db.Column(db.Float, nullable=False, default=0.0)

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)

    # Relationships
    deputatsabrechnung = db.relationship('Deputatsabrechnung', back_populates='betreuungen')

    # Konstanten
    BETREUUNGSARTEN = [
        'bachelor', 'master', 'doktorarbeit',
        'seminar_ba', 'seminar_ma',
        'projekt_ba', 'projekt_ma'
    ]
    STATUS_OPTIONEN = ['laufend', 'abgeschlossen']

    @property
    def student_name_komplett(self) -> str:
        """Voller Name des Studenten"""
        return f"{self.student_vorname} {self.student_name}"

    def __repr__(self):
        return f'<DeputatsBetreuung {self.student_vorname} {self.student_name} - {self.betreuungsart} ({self.sws} SWS)>'

    def berechne_sws(self, einstellungen: 'DeputatsEinstellungen' = None) -> float:
        """
        Berechnet SWS basierend auf Betreuungsart

        Args:
            einstellungen: DeputatsEinstellungen für SWS-Werte

        Returns:
            float: Berechnete SWS
        """
        from .deputat_einstellungen import DeputatsEinstellungen

        if einstellungen is None:
            einstellungen = DeputatsEinstellungen.get_current()

        sws_mapping = {
            'bachelor': einstellungen.sws_bachelor_arbeit,
            'master': einstellungen.sws_master_arbeit,
            'doktorarbeit': einstellungen.sws_doktorarbeit,
            'seminar_ba': einstellungen.sws_seminar_ba,
            'seminar_ma': einstellungen.sws_seminar_ma,
            'projekt_ba': einstellungen.sws_projekt_ba,
            'projekt_ma': einstellungen.sws_projekt_ma,
        }

        self.sws = sws_mapping.get(self.betreuungsart, 0.0)
        return self.sws

    def to_dict(self) -> Dict[str, Any]:
        return {
            'id': self.id,
            'deputatsabrechnung_id': self.deputatsabrechnung_id,
            'student_name': self.student_name,
            'student_vorname': self.student_vorname,
            'student_name_komplett': f"{self.student_vorname} {self.student_name}",
            'titel_arbeit': self.titel_arbeit,
            'betreuungsart': self.betreuungsart,
            'status': self.status,
            'beginn_datum': self.beginn_datum.isoformat() if self.beginn_datum else None,
            'ende_datum': self.ende_datum.isoformat() if self.ende_datum else None,
            'sws': self.sws,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
