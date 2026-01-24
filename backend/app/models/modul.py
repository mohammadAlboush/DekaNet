"""
Modul Models
============

Alle Modul-bezogenen Tabellen:
- Modul: Haupt-Tabelle (159 Module)
- ModulLehrform: N:M Modul â†” Lehrform (mit SWS)
- ModulDozent: N:M Modul â†” Dozent  
- ModulStudiengang: N:M Modul â†” Studiengang
- ModulLiteratur: Literatur-Empfehlungen
- ModulPruefung: PrÃ¼fungs-Details
- ModulLernergebnisse: Lernziele & Kompetenzen
- ModulVoraussetzungen: Voraussetzungen
- ModulAbhaengigkeit: Modul-AbhÃ¤ngigkeiten
- ModulArbeitsaufwand: Arbeitsaufwand in Stunden
- ModulSprache: N:M Modul â†” Sprache
- ModulSeiten: Seitenzahlen im PDF
"""

from datetime import datetime
from .base import db


class Modul(db.Model):
    """
    Modul - Haupt-Tabelle
        
    Attributes:
        kuerzel: Modul-KÃ¼rzel (z.B. "SCD", "PMA")
        po_id: Foreign Key zu PrÃ¼fungsordnung
        bezeichnung_de: Deutsche Bezeichnung
        bezeichnung_en: Englische Bezeichnung
        leistungspunkte: ECTS/LP
        turnus: Angebot (WS, SS, jedes Semester)
    """
    __tablename__ = 'modul'
    
    id = db.Column(db.Integer, primary_key=True)
    kuerzel = db.Column(db.String(20), nullable=False, index=True)
    po_id = db.Column(
        db.Integer,
        db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    
    # Bezeichnungen
    bezeichnung_de = db.Column(db.String(200), nullable=False)
    bezeichnung_en = db.Column(db.String(200))
    untertitel = db.Column(db.String(200))
    
    # Module-Details
    leistungspunkte = db.Column(db.Integer)
    turnus = db.Column(db.String(50))  # "Wintersemester", "Sommersemester", "Jedes Semester"
    
    # Weitere Details
    gruppengroesse = db.Column('gruppengröße', db.String(50))
    teilnehmerzahl = db.Column(db.String(50))
    anmeldemodalitaeten = db.Column(db.Text)
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    pruefungsordnung = db.relationship('Pruefungsordnung', back_populates='module')
    
    # Lehrformen (N:M mit SWS) - selectin for efficient batch loading
    lehrformen = db.relationship(
        'ModulLehrform',
        back_populates='modul',
        lazy='selectin',
        cascade='all, delete-orphan'
    )

    # Dozenten (N:M mit Rolle) - selectin for efficient batch loading
    dozent_zuordnungen = db.relationship(
        'ModulDozent',
        back_populates='modul',
        lazy='selectin',
        cascade='all, delete-orphan'
    )
    
    # Studiengänge (N:M) - selectin for efficient batch loading
    studiengang_zuordnungen = db.relationship(
        'ModulStudiengang',
        back_populates='modul',
        lazy='selectin',
        cascade='all, delete-orphan'
    )
    
    # Detail-Tabellen (1:1)
    lernergebnisse = db.relationship(
        'ModulLernergebnisse',
        back_populates='modul',
        uselist=False,
        cascade='all, delete-orphan'
    )
    pruefung = db.relationship(
        'ModulPruefung',
        back_populates='modul',
        uselist=False,
        cascade='all, delete-orphan'
    )
    voraussetzungen = db.relationship(
        'ModulVoraussetzungen',
        back_populates='modul',
        uselist=False,
        cascade='all, delete-orphan'
    )
    arbeitsaufwand = db.relationship(
        'ModulArbeitsaufwand',
        back_populates='modul',
        uselist=False,
        cascade='all, delete-orphan'
    )
    
    # Listen-Tabellen (1:N)
    literatur = db.relationship(
        'ModulLiteratur',
        back_populates='modul',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    abhaengigkeiten = db.relationship(
        'ModulAbhaengigkeit',
        foreign_keys='ModulAbhaengigkeit.modul_id',
        back_populates='modul',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    sprachen = db.relationship(
        'ModulSprache',
        back_populates='modul',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    seiten = db.relationship(
        'ModulSeiten',
        back_populates='modul',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # Geplante Module in Semesterplanungen
    geplante_module = db.relationship(
        'GeplantesModul',
        back_populates='modul',
        lazy='dynamic'
    )
    
    # Indexes
    __table_args__ = (
        db.Index('idx_modul_kuerzel', 'kuerzel'),
        db.Index('idx_modul_po', 'po_id'),
    )
    
    def __repr__(self):
        return f'<Modul {self.kuerzel}>'
    
    def __str__(self):
        return f"{self.kuerzel} - {self.bezeichnung_de}"
    
    # =========================================================================
    # PROPERTIES
    # =========================================================================
    
    @property
    def display_name(self):
        """Name fÃ¼r Anzeige"""
        return f"{self.kuerzel} - {self.bezeichnung_de}"
    
    def get_sws_gesamt(self):
        """Berechnet Gesamt-SWS aus allen Lehrformen"""
        return sum(lf.sws for lf in self.lehrformen)

    def get_dozenten(self):
        """Holt alle Dozenten für dieses Modul"""
        return [dz.dozent for dz in self.dozent_zuordnungen]

    def get_verantwortliche(self):
        """Holt verantwortliche Dozenten"""
        # Prüfe verschiedene Schreibweisen der Rolle
        for rolle in ['verantwortlicher', 'Modulverantwortlicher', 'modulverantwortlicher', 'Verantwortlicher']:
            result = [dz.dozent for dz in self.dozent_zuordnungen if dz.rolle == rolle]
            if result:
                return result
        return []

    def get_lehrpersonen(self):
        """Holt Lehrpersonen"""
        # Prüfe verschiedene Schreibweisen der Rolle
        for rolle in ['lehrperson', 'Lehrperson', 'Dozent', 'dozent']:
            result = [dz.dozent for dz in self.dozent_zuordnungen if dz.rolle == rolle]
            if result:
                return result
        return []
    
    def get_studiengaenge(self):
        """Holt alle Studiengänge für dieses Modul"""
        return [sg.studiengang for sg in self.studiengang_zuordnungen]

    def to_dict(self, include_details=False):
        """Konvertiert zu Dictionary"""
        data = {
            'id': self.id,
            'kuerzel': self.kuerzel,
            'bezeichnung_de': self.bezeichnung_de,
            'bezeichnung_en': self.bezeichnung_en,
            'leistungspunkte': self.leistungspunkte,
            'turnus': self.turnus,
            'sws_gesamt': self.get_sws_gesamt()
        }

        if include_details:
            data['lehrformen'] = [lf.to_dict() for lf in self.lehrformen]
            data['dozenten'] = [d.to_dict() for d in self.get_dozenten()]
            data['studiengaenge'] = [sg.to_dict() for sg in self.get_studiengaenge()]

            if self.lernergebnisse:
                data['lernergebnisse'] = self.lernergebnisse.to_dict()
            if self.pruefung:
                data['pruefung'] = self.pruefung.to_dict()

        return data


class ModulLehrform(db.Model):
    """
    Modul â†” Lehrform VerknÃ¼pfung (mit SWS)
    
    271 EintrÃ¤ge in DB.
    Speichert welche Lehrformen ein Modul hat und mit wie viel SWS.
    
    Example: SCD hat Vorlesung (2 SWS), Ãœbung (2 SWS), Praktikum (2 SWS)
    """
    __tablename__ = 'modul_lehrform'
    
    id = db.Column(db.Integer, primary_key=True)
    modul_id = db.Column(
        db.Integer,
        db.ForeignKey('modul.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    po_id = db.Column(
        db.Integer,
        db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'),
        nullable=False
    )
    lehrform_id = db.Column(
        db.Integer,
        db.ForeignKey('lehrform.id', ondelete='CASCADE'),
        nullable=False
    )
    sws = db.Column(db.Float, nullable=False)  # Semesterwochenstunden
    
    # Relationships
    modul = db.relationship('Modul', back_populates='lehrformen')
    lehrform = db.relationship('Lehrform', back_populates='modul_lehrformen')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    def __repr__(self):
        return f'<ModulLehrform {self.modul.kuerzel if self.modul else "?"} - {self.lehrform.bezeichnung if self.lehrform else "?"} ({self.sws} SWS)>'
    
    def to_dict(self):
        return {
            'lehrform': self.lehrform.bezeichnung if self.lehrform else None,
            'kuerzel': self.lehrform.kuerzel if self.lehrform else None,
            'sws': self.sws
        }


class ModulDozent(db.Model):
    """
    Modul â†” Dozent VerknÃ¼pfung (mit Rolle)
    
    295 EintrÃ¤ge in DB.
    
    Rolle:
    - 'verantwortlicher': Modul-Verantwortlicher
    - 'lehrperson': Weitere Lehrperson
    """
    __tablename__ = 'modul_dozent'
    
    id = db.Column(db.Integer, primary_key=True)
    modul_id = db.Column(
        db.Integer,
        db.ForeignKey('modul.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    po_id = db.Column(
        db.Integer,
        db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'),
        nullable=False
    )
    dozent_id = db.Column(
        db.Integer,
        db.ForeignKey('dozent.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    rolle = db.Column(db.String(50), nullable=False)  # 'verantwortlicher' oder 'lehrperson'

    # ✨ NEW: Feature 1 - Vertreter & Zweitprüfer
    vertreter_id = db.Column(
        db.Integer,
        db.ForeignKey('dozent.id', ondelete='SET NULL'),
        nullable=True,
        index=True
    )
    zweitpruefer_id = db.Column(
        db.Integer,
        db.ForeignKey('dozent.id', ondelete='SET NULL'),
        nullable=True,
        index=True
    )

    # Relationships
    modul = db.relationship('Modul', back_populates='dozent_zuordnungen')
    # ✅ PERFORMANCE FIX: lazy='joined' für eager loading des Dozenten
    dozent = db.relationship('Dozent', back_populates='modul_zuordnungen', foreign_keys=[dozent_id], lazy='joined')
    pruefungsordnung = db.relationship('Pruefungsordnung')

    # ✨ NEW: Vertreter & Zweitprüfer Relationships
    vertreter = db.relationship(
        'Dozent',
        foreign_keys=[vertreter_id],
        backref='modul_vertretungen'
    )
    zweitpruefer = db.relationship(
        'Dozent',
        foreign_keys=[zweitpruefer_id],
        backref='modul_zweitpruefungen'
    )

    # Indexes
    __table_args__ = (
        db.Index('idx_modul_dozent', 'modul_id', 'dozent_id'),
    )

    def __repr__(self):
        return f'<ModulDozent {self.modul.kuerzel if self.modul else "?"} - {self.dozent.name_komplett if self.dozent else "?"}>'

    def to_dict(self):
        """Konvertiert zu Dictionary mit Vertreter & Zweitprüfer"""
        data = {
            'id': self.id,
            'modul_id': self.modul_id,
            'dozent_id': self.dozent_id,
            'rolle': self.rolle,
        }

        if self.dozent:
            data['dozent_name'] = self.dozent.name_komplett

        if self.vertreter:
            data['vertreter'] = {
                'id': self.vertreter.id,
                'name': self.vertreter.name_komplett
            }

        if self.zweitpruefer:
            data['zweitpruefer'] = {
                'id': self.zweitpruefer.id,
                'name': self.zweitpruefer.name_komplett
            }

        return data


class ModulStudiengang(db.Model):
    """
    Modul â†” Studiengang VerknÃ¼pfung
    
    113 EintrÃ¤ge in DB.
    Definiert in welchem Studiengang das Modul angeboten wird.
    """
    __tablename__ = 'modul_studiengang'
    
    id = db.Column(db.Integer, primary_key=True)
    modul_id = db.Column(
        db.Integer,
        db.ForeignKey('modul.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    po_id = db.Column(
        db.Integer,
        db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'),
        nullable=False
    )
    studiengang_id = db.Column(
        db.Integer,
        db.ForeignKey('studiengang.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    semester = db.Column(db.Integer)  # Fachsemester
    pflicht = db.Column(db.Boolean, default=False)
    wahlpflicht = db.Column(db.Boolean, default=False)
    
    # Relationships
    modul = db.relationship('Modul', back_populates='studiengang_zuordnungen')
    studiengang = db.relationship('Studiengang', back_populates='modul_zuordnungen')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    # Indexes
    __table_args__ = (
        db.Index('idx_modul_studiengang', 'modul_id', 'studiengang_id'),
    )
    
    def __repr__(self):
        return f'<ModulStudiengang {self.modul.kuerzel if self.modul else "?"} - {self.studiengang.bezeichnung if self.studiengang else "?"}>'


# Die restlichen Modul-Detail-Tabellen folgen im nÃ¤chsten Teil...