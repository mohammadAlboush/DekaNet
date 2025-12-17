"""
Modul Detail-Tabellen
=====================
Fortsetzung von modul.py - Detail-Tabellen fÃ¼r Module
"""

from datetime import datetime
from .base import db


class ModulLiteratur(db.Model):
    """Literatur-Empfehlungen fÃ¼r Module (990 EintrÃ¤ge)"""
    __tablename__ = 'modul_literatur'
    
    id = db.Column(db.Integer, primary_key=True)
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), nullable=False)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), nullable=False)
    
    titel = db.Column(db.Text, nullable=False)
    autoren = db.Column(db.String(500))
    verlag = db.Column(db.String(200))
    jahr = db.Column(db.Integer)
    isbn = db.Column(db.String(20))
    typ = db.Column(db.String(50))  # 'buch', 'artikel', 'online', etc.
    pflichtliteratur = db.Column(db.Boolean, default=False)
    sortierung = db.Column(db.Integer)
    
    # Relationships
    modul = db.relationship('Modul', back_populates='literatur')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    def __repr__(self):
        return f'<ModulLiteratur {self.titel[:50]}...>'


class ModulPruefung(db.Model):
    """PrÃ¼fungs-Details (131 EintrÃ¤ge)"""
    __tablename__ = 'modul_pruefung'
    
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), primary_key=True)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), primary_key=True)
    
    pruefungsform = db.Column(db.String(100))  # 'Klausur', 'Hausarbeit', etc.
    pruefungsdauer_minuten = db.Column(db.Integer)
    pruefungsleistungen = db.Column(db.Text)
    benotung = db.Column(db.String(50))  # 'benotet', 'unbenotet'
    
    # Relationships
    modul = db.relationship('Modul', back_populates='pruefung')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    def to_dict(self):
        return {
            'pruefungsform': self.pruefungsform,
            'dauer_minuten': self.pruefungsdauer_minuten,
            'benotung': self.benotung
        }


class ModulLernergebnisse(db.Model):
    """Lernziele und Kompetenzen (159 EintrÃ¤ge)"""
    __tablename__ = 'modul_lernergebnisse'
    
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), primary_key=True)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), primary_key=True)
    
    lernziele = db.Column(db.Text)
    kompetenzen = db.Column(db.Text)
    inhalt = db.Column(db.Text)
    
    # Relationships
    modul = db.relationship('Modul', back_populates='lernergebnisse')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    def to_dict(self):
        return {
            'lernziele': self.lernziele,
            'kompetenzen': self.kompetenzen,
            'inhalt': self.inhalt
        }


class ModulVoraussetzungen(db.Model):
    """Voraussetzungen (23 EintrÃ¤ge)"""
    __tablename__ = 'modul_voraussetzungen'
    
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), primary_key=True)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), primary_key=True)
    
    formal = db.Column(db.Text)  # Formale Voraussetzungen
    empfohlen = db.Column(db.Text)  # Empfohlene Voraussetzungen
    inhaltlich = db.Column(db.Text)  # Inhaltliche Voraussetzungen
    
    # Relationships
    modul = db.relationship('Modul', back_populates='voraussetzungen')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    def to_dict(self):
        return {
            'formal': self.formal,
            'empfohlen': self.empfohlen,
            'inhaltlich': self.inhaltlich
        }


class ModulAbhaengigkeit(db.Model):
    """Modul-AbhÃ¤ngigkeiten (0 EintrÃ¤ge aktuell)"""
    __tablename__ = 'modul_abhÃ¤ngigkeit'
    
    id = db.Column(db.Integer, primary_key=True)
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), nullable=False)
    voraussetzung_modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), nullable=False)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), nullable=False)
    typ = db.Column(db.String(20))  # 'zwingend', 'empfohlen'
    
    # Relationships
    modul = db.relationship('Modul', foreign_keys=[modul_id], back_populates='abhaengigkeiten')
    voraussetzung_modul = db.relationship('Modul', foreign_keys=[voraussetzung_modul_id])
    pruefungsordnung = db.relationship('Pruefungsordnung')


class ModulArbeitsaufwand(db.Model):
    """Arbeitsaufwand in Stunden (115 EintrÃ¤ge)"""
    __tablename__ = 'modul_arbeitsaufwand'
    
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), primary_key=True)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), primary_key=True)
    
    kontaktzeit_stunden = db.Column(db.Integer)
    selbststudium_stunden = db.Column(db.Integer)
    pruefungsvorbereitung_stunden = db.Column(db.Integer)
    gesamt_stunden = db.Column(db.Integer)
    
    # Relationships
    modul = db.relationship('Modul', back_populates='arbeitsaufwand')
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    def to_dict(self):
        return {
            'kontaktzeit': self.kontaktzeit_stunden,
            'selbststudium': self.selbststudium_stunden,
            'pruefungsvorbereitung': self.pruefungsvorbereitung_stunden,
            'gesamt': self.gesamt_stunden
        }


class ModulSprache(db.Model):
    """Modul â†” Sprache (61 EintrÃ¤ge)"""
    __tablename__ = 'modul_sprache'
    
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), primary_key=True)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), primary_key=True)
    sprache_id = db.Column(db.Integer, db.ForeignKey('sprache.id', ondelete='CASCADE'), primary_key=True)
    
    # Relationships
    modul = db.relationship('Modul', back_populates='sprachen')
    sprache = db.relationship('Sprache', back_populates='modul_sprachen')
    pruefungsordnung = db.relationship('Pruefungsordnung')


class ModulSeiten(db.Model):
    """Seitenzahlen im PDF-Modulhandbuch (259 EintrÃ¤ge)"""
    __tablename__ = 'modul_seiten'
    
    modul_id = db.Column(db.Integer, db.ForeignKey('modul.id', ondelete='CASCADE'), primary_key=True)
    po_id = db.Column(db.Integer, db.ForeignKey('pruefungsordnung.id', ondelete='CASCADE'), primary_key=True)
    modulhandbuch_id = db.Column(db.Integer, db.ForeignKey('modulhandbuch.id', ondelete='CASCADE'), primary_key=True)
    
    seite_von = db.Column(db.Integer, nullable=False)
    seite_bis = db.Column(db.Integer)
    
    # Relationships
    modul = db.relationship('Modul', back_populates='seiten')
    modulhandbuch = db.relationship('Modulhandbuch', back_populates='modul_seiten')
    pruefungsordnung = db.relationship('Pruefungsordnung')