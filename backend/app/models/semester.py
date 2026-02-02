"""
Semester Model
==============
Für Semesterplanung-System.

Verwaltet Semester-Zeiträume (WS2025, SS2026, etc.)
"""

from datetime import datetime, date
from .base import db


class Semester(db.Model):
    """
    Semester-Verwaltung
    
    Ein Semester definiert einen Planungszeitraum.
    Nur ein Semester kann gleichzeitig aktiv sein (für Planung).

    Attributes:
        bezeichnung: Vollständiger Name (z.B. "Wintersemester 2025/2026")
        kuerzel: Kurzes Kürzel (z.B. "WS2025")
        start_datum: Semesterbeginn
        ende_datum: Semesterende
        vorlesungsbeginn: Erster Tag der Vorlesungen
        vorlesungsende: Letzter Tag der Vorlesungen
        ist_aktiv: Ist dieses Semester aktuell aktiv?
        ist_planungsphase: Ist das Planungsfenster geöffnet?
    """
    __tablename__ = 'semester'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Semester-Info
    bezeichnung = db.Column(db.String(50), nullable=False)  # "Wintersemester 2025/2026"
    kuerzel = db.Column(db.String(10), nullable=False, unique=True, index=True)  # "WS2025"
    
    # Zeiträume
    start_datum = db.Column(db.Date, nullable=False)
    ende_datum = db.Column(db.Date, nullable=False)
    vorlesungsbeginn = db.Column(db.Date)
    vorlesungsende = db.Column(db.Date)
    
    # Status-Flags
    ist_aktiv = db.Column(db.Boolean, default=False, nullable=False, index=True)
    ist_planungsphase = db.Column(db.Boolean, default=False, nullable=False, index=True)
    
    # Audit
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    semesterplanungen = db.relationship(
        'Semesterplanung',
        back_populates='semester',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    def __repr__(self):
        return f'<Semester {self.kuerzel}>'
    
    def __str__(self):
        return self.bezeichnung
    
    # =========================================================================
    # VALIDATION
    # =========================================================================
    
    @property
    def ist_valid(self):
        """Prüft ob Semester-Daten valide sind"""
        if self.start_datum >= self.ende_datum:
            return False
        if self.vorlesungsbeginn and self.vorlesungsende:
            if self.vorlesungsbeginn >= self.vorlesungsende:
                return False
        return True
    
    # =========================================================================
    # STATUS MANAGEMENT
    # =========================================================================
    
    def aktivieren(self, planungsphase=True):
        """
        Aktiviert dieses Semester (deaktiviert alle anderen)
        
        Args:
            planungsphase: Soll Planungsphase auch geöffnet werden?
        """
        # Deaktiviere alle anderen Semester
        Semester.query.update({'ist_aktiv': False, 'ist_planungsphase': False})
        
        # Aktiviere dieses Semester
        self.ist_aktiv = True
        self.ist_planungsphase = planungsphase
        db.session.commit()
    
    def deaktivieren(self):
        """Deaktiviert dieses Semester"""
        self.ist_aktiv = False
        self.ist_planungsphase = False
        db.session.commit()
    
    def planungsphase_oeffnen(self):
        """Öffnet das Planungsfenster"""
        if not self.ist_aktiv:
            raise ValueError("Semester muss aktiv sein um Planungsphase zu öffnen")
        self.ist_planungsphase = True
        db.session.commit()
    
    def planungsphase_schliessen(self):
        """Schließt das Planungsfenster"""
        self.ist_planungsphase = False
        db.session.commit()
    
    # =========================================================================
    # PROPERTIES
    # =========================================================================
    
    @property
    def ist_wintersemester(self):
        """Ist es ein Wintersemester?"""
        return 'WS' in self.kuerzel or 'Winter' in self.bezeichnung
    
    @property
    def ist_sommersemester(self):
        """Ist es ein Sommersemester?"""
        return 'SS' in self.kuerzel or 'Sommer' in self.bezeichnung
    
    @property
    def jahr(self):
        """
        Extrahiert das Jahr aus dem Kürzel
        Returns: int oder None
        """
        import re
        match = re.search(r'\d{4}', self.kuerzel)
        if match:
            return int(match.group())
        return None
    
    @property
    def dauer_tage(self):
        """Dauer des Semesters in Tagen"""
        return (self.ende_datum - self.start_datum).days
    
    @property
    def vorlesungszeit_tage(self):
        """Dauer der Vorlesungszeit in Tagen"""
        if self.vorlesungsbeginn and self.vorlesungsende:
            return (self.vorlesungsende - self.vorlesungsbeginn).days
        return None
    
    @property
    def ist_vergangen(self):
        """Ist das Semester bereits vorbei?"""
        return self.ende_datum < date.today()
    
    @property
    def ist_zukuenftig(self):
        """Liegt das Semester in der Zukunft?"""
        return self.start_datum > date.today()
    
    @property
    def ist_laufend(self):
        """Läuft das Semester gerade?"""
        heute = date.today()
        return self.start_datum <= heute <= self.ende_datum
    
    # =========================================================================
    # STATISTICS
    # =========================================================================
    
    def anzahl_planungen(self, status=None):
        """
        Zählt Semesterplanungen

        Args:
            status: Optional - Nur Planungen mit diesem Status zählen

        Returns:
            int: Anzahl Planungen
        """
        query = self.semesterplanungen
        if status:
            query = query.filter_by(status=status)
        return query.count()
    
    def anzahl_eingereicht(self):
        """Anzahl eingereichte Planungen"""
        return self.anzahl_planungen('eingereicht')
    
    def anzahl_freigegeben(self):
        """Anzahl freigegebene Planungen"""
        return self.anzahl_planungen('freigegeben')
    
    def anzahl_entwurf(self):
        """Anzahl Entwürfe"""
        return self.anzahl_planungen('entwurf')
    
    @property
    def planungen_abgeschlossen(self):
        """Sind alle Planungen freigegeben?"""
        total = self.semesterplanungen.count()
        if total == 0:
            return False
        freigegeben = self.anzahl_freigegeben()
        return freigegeben == total
    
    # =========================================================================
    # HELPER METHODS
    # =========================================================================
    
    def to_dict(self):
        """Konvertiert zu Dictionary (für API)"""
        return {
            'id': self.id,
            'bezeichnung': self.bezeichnung,
            'kuerzel': self.kuerzel,
            'start_datum': self.start_datum.isoformat(),
            'ende_datum': self.ende_datum.isoformat(),
            'vorlesungsbeginn': self.vorlesungsbeginn.isoformat() if self.vorlesungsbeginn else None,
            'vorlesungsende': self.vorlesungsende.isoformat() if self.vorlesungsende else None,
            'ist_aktiv': self.ist_aktiv,
            'ist_planungsphase': self.ist_planungsphase,
            'ist_wintersemester': self.ist_wintersemester,
            'ist_sommersemester': self.ist_sommersemester,
            'ist_laufend': self.ist_laufend,
            'dauer_tage': self.dauer_tage,
            'statistik': {
                'gesamt': self.semesterplanungen.count(),
                'entwurf': self.anzahl_entwurf(),
                'eingereicht': self.anzahl_eingereicht(),
                'freigegeben': self.anzahl_freigegeben(),
            }
        }
    
    # =========================================================================
    # CLASS METHODS
    # =========================================================================
    
    @classmethod
    def get_aktives_semester(cls):
        """
        Gibt das aktuell aktive Semester zurück

        Returns:
            Semester oder None
        """
        return cls.query.filter_by(ist_aktiv=True).first()
    
    @classmethod
    def get_aktuelles_planungssemester(cls):
        """
        Gibt das Semester zurück, für das gerade geplant werden kann

        Returns:
            Semester oder None
        """
        return cls.query.filter_by(ist_planungsphase=True).first()
    
    @classmethod
    def get_by_kuerzel(cls, kuerzel):
        """
        Findet Semester anhand Kürzel

        Args:
            kuerzel: Semester-Kürzel (z.B. "WS2025")

        Returns:
            Semester oder None
        """
        return cls.query.filter_by(kuerzel=kuerzel).first()
    
    @classmethod
    def get_vergangene(cls):
        """Holt alle vergangenen Semester"""
        return cls.query.filter(cls.ende_datum < date.today()).order_by(cls.start_datum.desc()).all()
    
    @classmethod
    def get_zukuenftige(cls):
        """Holt alle zukünftigen Semester"""
        return cls.query.filter(cls.start_datum > date.today()).order_by(cls.start_datum.asc()).all()
    
    @classmethod
    def get_laufende(cls):
        """Holt alle laufenden Semester"""
        heute = date.today()
        return cls.query.filter(
            cls.start_datum <= heute,
            cls.ende_datum >= heute
        ).all()
    
    @classmethod
    def create_semester(cls, bezeichnung, kuerzel, start_datum, ende_datum, **kwargs):
        """
        Erstellt ein neues Semester

        Args:
            bezeichnung: Vollständiger Name
            kuerzel: Kurzes Kürzel
            start_datum: Semesterbeginn (date oder ISO-String)
            ende_datum: Semesterende (date oder ISO-String)
            **kwargs: Weitere optionale Felder

        Returns:
            Semester: Neu erstelltes Semester
        """
        # Konvertiere Strings zu Dates falls nötig
        if isinstance(start_datum, str):
            start_datum = datetime.fromisoformat(start_datum).date()
        if isinstance(ende_datum, str):
            ende_datum = datetime.fromisoformat(ende_datum).date()
        
        semester = cls(
            bezeichnung=bezeichnung,
            kuerzel=kuerzel,
            start_datum=start_datum,
            ende_datum=ende_datum,
            **kwargs
        )
        
        if not semester.ist_valid:
            raise ValueError("Semester-Daten sind nicht valide (start_datum >= ende_datum)")
        
        db.session.add(semester)
        db.session.commit()
        
        return semester
    
    @classmethod
    def get_semester_for_date(cls, datum):
        """
        Findet Semester für ein bestimmtes Datum

        Args:
            datum: Date-Objekt oder ISO-String

        Returns:
            Semester oder None
        """
        if isinstance(datum, str):
            datum = datetime.fromisoformat(datum).date()
        
        return cls.query.filter(
            cls.start_datum <= datum,
            cls.ende_datum >= datum
        ).first()