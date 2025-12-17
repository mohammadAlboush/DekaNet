"""
Studiengang Models
==================
Studiengang und Prüfungsordnung
"""

from datetime import datetime, date
from .base import db


class Pruefungsordnung(db.Model):
    """Prüfungsordnung (1 Eintrag: PO2023)"""
    __tablename__ = 'pruefungsordnung'
    
    id = db.Column(db.Integer, primary_key=True)
    po_jahr = db.Column(db.String(10), nullable=False, unique=True)
    gueltig_von = db.Column(db.Date, nullable=False)
    gueltig_bis = db.Column(db.Date)
    beschreibung = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    module = db.relationship('Modul', back_populates='pruefungsordnung', lazy='dynamic')
    
    def __repr__(self):
        return f'<Pruefungsordnung {self.po_jahr}>'
    
    @property
    def ist_aktuell(self):
        """Ist diese PO aktuell gültig?"""
        heute = date.today()
        if self.gueltig_bis:
            return self.gueltig_von <= heute <= self.gueltig_bis
        return self.gueltig_von <= heute
    
    def to_dict(self):
        return {
            'id': self.id,
            'po_jahr': self.po_jahr,
            'gueltig_von': self.gueltig_von.isoformat(),
            'gueltig_bis': self.gueltig_bis.isoformat() if self.gueltig_bis else None,
            'ist_aktuell': self.ist_aktuell
        }


class Studiengang(db.Model):
    """Studiengänge (8 Einträge: IN, ID, etc.)"""
    __tablename__ = 'studiengang'
    
    id = db.Column(db.Integer, primary_key=True)
    kuerzel = db.Column(db.String(10), nullable=False, unique=True)
    bezeichnung = db.Column(db.String(100), nullable=False)
    abschluss = db.Column(db.String(20))  # 'Bachelor', 'Master'
    fachbereich = db.Column(db.String(100))
    regelstudienzeit = db.Column(db.Integer)  # in Semestern
    ects_gesamt = db.Column(db.Integer)
    aktiv = db.Column(db.Boolean, default=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    modul_zuordnungen = db.relationship('ModulStudiengang', back_populates='studiengang', lazy='dynamic')
    modulhandbuecher = db.relationship('Modulhandbuch', back_populates='studiengang', lazy='dynamic')
    
    def __repr__(self):
        return f'<Studiengang {self.kuerzel}>'
    
    def __str__(self):
        return f"{self.kuerzel} - {self.bezeichnung}"
    
    def get_module(self, po_id=None):
        """Holt alle Module des Studiengangs"""
        query = self.modul_zuordnungen
        if po_id:
            query = query.filter_by(po_id=po_id)
        return [mz.modul for mz in query.all()]
    
    def get_pruefungsordnungen(self):
        """
        Holt alle Prüfungsordnungen für diesen Studiengang
        
        Da es keine direkte Beziehung gibt, suchen wir über Module
        """
        from app.models import Modul
        
        # Hole alle Module dieses Studiengangs
        modul_zuordnungen = self.modul_zuordnungen.all()
        
        # Sammle alle unique PO IDs
        po_ids = set()
        for mz in modul_zuordnungen:
            if mz.po_id:
                po_ids.add(mz.po_id)
        
        # Hole Prüfungsordnungen
        if po_ids:
            return Pruefungsordnung.query.filter(
                Pruefungsordnung.id.in_(po_ids)
            ).all()
        
        return []
    
    def to_dict(self):
        return {
            'id': self.id,
            'kuerzel': self.kuerzel,
            'bezeichnung': self.bezeichnung,
            'abschluss': self.abschluss,
            'regelstudienzeit': self.regelstudienzeit,
            'ects_gesamt': self.ects_gesamt,
            'aktiv': self.aktiv
        }