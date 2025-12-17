"""
Dozent Model
============
Bestehend aus dekanat_professional_v4.db

Dozenten/Lehrende - Professoren und Lehrbeauftragte
"""

from datetime import datetime
from .base import db


class Dozent(db.Model):
    """
    Dozent - Lehrende
    
    Professoren, Lehrbeauftragte und wissenschaftliche Mitarbeiter.
    Bereits in DB vorhanden mit 52 EintrÃƒÂ¤gen.
    
    Attributes:
        titel: Akademischer Titel (Prof. Dr., Dr., etc.)
        vorname: Vorname
        nachname: Nachname (required)
        name_komplett: VollstÃƒÂ¤ndiger Name
        email: Email-Adresse
        fachbereich: ZugehÃƒÂ¶riger Fachbereich
        aktiv: Ist Dozent noch aktiv?
    """
    __tablename__ = 'dozent'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # PersÃƒÂ¶nliche Daten
    titel = db.Column(db.String(50))  # Prof. Dr., Dr., etc.
    vorname = db.Column(db.String(100))
    nachname = db.Column(db.String(100), nullable=False)
    name_komplett = db.Column(db.String(200), nullable=False)
    email = db.Column(db.String(100))
    fachbereich = db.Column(db.String(100))
    
    # Status
    aktiv = db.Column(db.Boolean, default=True, nullable=False)
    
    created_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        nullable=False
    )
    
    # Relationships
    # Modul-Zuordnungen (N:M via modul_dozent)
    modul_zuordnungen = db.relationship(
        'ModulDozent',
        back_populates='dozent',
        lazy='dynamic',
        foreign_keys='ModulDozent.dozent_id'
    )

    # ✨ NEW: Feature 2 - Semesteraufträge
    semester_auftraege = db.relationship(
        'SemesterAuftrag',
        back_populates='dozent',
        lazy='dynamic'
    )

    # Benutzer-Account (optional - nur fÃƒÂ¼r Login-User)
    benutzer = db.relationship(
        'Benutzer',
        foreign_keys='Benutzer.dozent_id',
        back_populates='dozent',
        uselist=False
    )
    
    # Indexes
    __table_args__ = (
        db.Index('idx_dozent_name', 'nachname', 'vorname'),
    )
    
    def __repr__(self):
        return f'<Dozent {self.name_komplett}>'
    
    def __str__(self):
        return self.name_komplett
    
    # =========================================================================
    # PROPERTIES
    # =========================================================================
    
    @property
    def initialen(self):
        """Initialen (z.B. "M.M." fÃƒÂ¼r "Max Mustermann")"""
        parts = []
        if self.vorname:
            parts.append(self.vorname[0].upper() + '.')
        if self.nachname:
            parts.append(self.nachname[0].upper() + '.')
        return ''.join(parts)
    
    @property
    def name_kurz(self):
        """Kurzer Name (z.B. "M. Mustermann")"""
        if self.vorname and self.nachname:
            return f"{self.vorname[0]}. {self.nachname}"
        return self.nachname
    
    @property
    def name_mit_titel(self):
        """Name mit Titel (z.B. "Prof. Dr. Max Mustermann")"""
        if self.titel:
            return f"{self.titel} {self.name_komplett}"
        return self.name_komplett
    
    @property
    def hat_benutzer_account(self):
        """Hat dieser Dozent einen Benutzer-Account?"""
        return self.benutzer is not None
    
    # =========================================================================
    # MODULE MANAGEMENT
    # =========================================================================
    
    def get_module(self, po_id=None):
        """
        Holt alle Module des Dozenten
        
        Args:
            po_id: Optional - Nur Module fÃƒÂ¼r diese PO
            
        Returns:
            list: Liste von Modul-Objekten
        """
        query = self.modul_zuordnungen
        if po_id:
            query = query.filter_by(po_id=po_id)
        return [mz.modul for mz in query.all()]
    
    def get_module_als_verantwortlicher(self, po_id=None):
        """Holt Module wo Dozent Verantwortlicher ist"""
        query = self.modul_zuordnungen.filter_by(rolle='verantwortlicher')
        if po_id:
            query = query.filter_by(po_id=po_id)
        return [mz.modul for mz in query.all()]
    
    def get_module_als_lehrperson(self, po_id=None):
        """Holt Module wo Dozent Lehrperson ist"""
        query = self.modul_zuordnungen.filter_by(rolle='lehrperson')
        if po_id:
            query = query.filter_by(po_id=po_id)
        return [mz.modul for mz in query.all()]
    
    @property
    def anzahl_module(self):
        """Anzahl eindeutiger Module die dieser Dozent unterrichtet"""
        # Zähle nur eindeutige Module (ein Dozent kann mehrere Rollen im selben Modul haben)
        unique_module_ids = set(mz.modul_id for mz in self.modul_zuordnungen.all())
        return len(unique_module_ids)
    
    # =========================================================================
    # HELPER METHODS
    # =========================================================================
    
    def aktivieren(self):
        """Aktiviert den Dozent"""
        self.aktiv = True
        db.session.commit()
    
    def deaktivieren(self):
        """Deaktiviert den Dozent"""
        self.aktiv = False
        db.session.commit()
    
    def to_dict(self):
        """Konvertiert zu Dictionary (fÃƒÂ¼r API)"""
        return {
            'id': self.id,
            'titel': self.titel,
            'vorname': self.vorname,
            'nachname': self.nachname,
            'name_komplett': self.name_komplett,
            'name_kurz': self.name_kurz,
            'name_mit_titel': self.name_mit_titel,
            'email': self.email,
            'fachbereich': self.fachbereich,
            'aktiv': self.aktiv,
            'anzahl_module': self.anzahl_module,
            'hat_benutzer_account': self.hat_benutzer_account
        }
    
    # =========================================================================
    # CLASS METHODS
    # =========================================================================
    
    @classmethod
    def get_aktive(cls):
        """Holt alle aktiven Dozenten"""
        return cls.query.filter_by(aktiv=True).order_by(cls.nachname, cls.vorname).all()
    
    @classmethod
    def get_by_fachbereich(cls, fachbereich):
        """Holt alle Dozenten eines Fachbereichs"""
        return cls.query.filter_by(fachbereich=fachbereich, aktiv=True).order_by(cls.nachname).all()
    
    @classmethod
    def get_by_email(cls, email):
        """Findet Dozent anhand Email"""
        return cls.query.filter_by(email=email).first()
    
    @classmethod
    def search(cls, suchbegriff):
        """
        Sucht Dozenten anhand Name oder Email
        
        Args:
            suchbegriff: Suchtext
            
        Returns:
            list: Gefundene Dozenten
        """
        pattern = f"%{suchbegriff}%"
        return cls.query.filter(
            db.or_(
                cls.name_komplett.ilike(pattern),
                cls.email.ilike(pattern),
                cls.nachname.ilike(pattern)
            )
        ).filter_by(aktiv=True).order_by(cls.nachname).all()
    
    @classmethod
    def create_dozent(cls, nachname, vorname=None, **kwargs):
        """
        Erstellt einen neuen Dozenten
        
        Args:
            nachname: Nachname (required)
            vorname: Vorname (optional)
            **kwargs: Weitere Felder
            
        Returns:
            Dozent: Neu erstellter Dozent
        """
        # Generiere name_komplett
        if 'name_komplett' not in kwargs:
            if vorname:
                kwargs['name_komplett'] = f"{vorname} {nachname}"
            else:
                kwargs['name_komplett'] = nachname
        
        dozent = cls(
            nachname=nachname,
            vorname=vorname,
            **kwargs
        )
        
        db.session.add(dozent)
        db.session.commit()
        
        return dozent