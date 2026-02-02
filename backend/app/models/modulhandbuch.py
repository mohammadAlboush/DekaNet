"""
Modulhandbuch Model
===================
Importierte PDF-Modulhandbücher
"""

from datetime import datetime
from .base import db


class Modulhandbuch(db.Model):
    """Modulhandbücher - Importierte PDF-Dokumente"""
    __tablename__ = 'modulhandbuch'

    id = db.Column(db.Integer, primary_key=True)
    dateiname = db.Column(db.String(255), nullable=False, unique=True)
    studiengang_id = db.Column(db.Integer, db.ForeignKey('studiengang.id', ondelete='SET NULL'), index=True)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), nullable=False, index=True)
    version = db.Column(db.String(20))
    anzahl_seiten = db.Column(db.Integer)
    anzahl_module = db.Column(db.Integer)
    import_datum = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    hash = db.Column(db.String(64), unique=True)  # SHA-256 Hash
    
    # Relationships
    studiengang = db.relationship('Studiengang', back_populates='modulhandbuecher')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    modul_seiten = db.relationship('ModulSeiten', back_populates='modulhandbuch', lazy='dynamic')
    
    def __repr__(self):
        return f'<Modulhandbuch {self.dateiname}>'
    
    def to_dict(self):
        return {
            'id': self.id,
            'dateiname': self.dateiname,
            'studiengang': self.studiengang.kuerzel if self.studiengang else None,
            'anzahl_module': self.anzahl_module,
            'import_datum': self.import_datum.isoformat()
        }