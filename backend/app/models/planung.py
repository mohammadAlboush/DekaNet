"""
Semesterplanung Models
======================
KERN-Feature: Models fÃ¼r den Semesterplanungs-Workflow.

Models:
- Semesterplanung: Haupttabelle fÃ¼r Planung (ein Dozent pro Semester)
- GeplantesModul: Details mit Multiplikatoren und SWS-Berechnung
- WunschFreierTag: Wunsch-freie Tage fÃ¼r Stundenplanung
"""

from datetime import datetime
import json
from .base import db


class Semesterplanung(db.Model):
    """
    Semesterplanung - Haupttabelle
    
    Ein Dozent kann eine Planung pro Semester erstellen.
    Workflow: entwurf â†’ eingereicht â†’ freigegeben
    
    Attributes:
        semester_id: Foreign Key zu Semester
        benutzer_id: Foreign Key zu Benutzer (wer plant)
        status: Workflow-Status ('entwurf', 'eingereicht', 'freigegeben', 'abgelehnt')
        anmerkungen: Freitext-Anmerkungen vom Dozent
        gesamt_sws: Berechnete Gesamt-SWS (aus geplante_module)
    """
    __tablename__ = 'semesterplanung'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # VerknÃ¼pfungen
    semester_id = db.Column(
        db.Integer,
        db.ForeignKey('semester.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    benutzer_id = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
    planungsphase_id = db.Column(
        db.Integer,
        db.ForeignKey('planungsphasen.id', ondelete='SET NULL'),
        nullable=True,
        index=True
    )

    # Status Workflow
    status = db.Column(
        db.String(50),
        default='entwurf',
        nullable=False,
        index=True
    )  # 'entwurf', 'eingereicht', 'freigegeben', 'abgelehnt'

    # Anmerkungen & Zusatzinformationen
    anmerkungen = db.Column(db.Text)
    raumbedarf = db.Column(db.Text)

    # JSON-Felder (als TEXT in SQLite)
    _room_requirements = db.Column('room_requirements', db.Text)
    _special_requests = db.Column('special_requests', db.Text)
    
    # Berechnete Werte (aus geplante_module)
    gesamt_sws = db.Column(db.Float, default=0.0)
    
    # Workflow Timestamps
    eingereicht_am = db.Column(db.DateTime)
    freigegeben_von = db.Column(
        db.Integer,
        db.ForeignKey('benutzer.id', ondelete='SET NULL')
    )
    freigegeben_am = db.Column(db.DateTime)
    abgelehnt_am = db.Column(db.DateTime)
    ablehnungsgrund = db.Column(db.Text)
    
    # Audit
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )
    
    # Relationships
    semester = db.relationship('Semester', back_populates='semesterplanungen')
    benutzer = db.relationship(
        'Benutzer',
        foreign_keys=[benutzer_id],
        back_populates='semesterplanungen'
    )
    freigeber = db.relationship(
        'Benutzer',
        foreign_keys=[freigegeben_von],
        back_populates='freigegebene_planungen'
    )
    planungsphase = db.relationship(
        'Planungsphase',
        foreign_keys=[planungsphase_id],
        backref='semesterplanungen'
    )
    
    # Geplante Module (Hauptdetails)
    geplante_module = db.relationship(
        'GeplantesModul',
        back_populates='semesterplanung',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )
    
    # Wunsch-freie Tage
    wunsch_freie_tage = db.relationship(
        'WunschFreierTag',
        back_populates='semesterplanung',
        cascade='all, delete-orphan',
        lazy='dynamic'
    )
    
    # ✅ UNIQUE Constraint: Ein User kann EINE Planung pro Planungsphase haben
    # Dies erlaubt mehrere Planungen pro Semester, aber nur eine pro Phase
    # Composite Index für häufige Queries (status + semester filtering)
    __table_args__ = (
        db.UniqueConstraint('semester_id', 'benutzer_id', 'planungsphase_id', name='uq_semester_benutzer_phase'),
        db.Index('ix_semesterplanung_status_semester', 'status', 'semester_id'),
        db.Index('ix_semesterplanung_benutzer_status', 'benutzer_id', 'status'),
    )
    
    def __repr__(self):
        return f'<Semesterplanung {self.id} - {self.benutzer.username if self.benutzer else "?"} - {self.semester.kuerzel if self.semester else "?"}>'
    
    # =========================================================================
    # STATUS CHECKS
    # =========================================================================
    
    @property
    def ist_entwurf(self):
        """Ist Status = entwurf?"""
        return self.status == 'entwurf'
    
    @property
    def ist_eingereicht(self):
        """Ist Status = eingereicht?"""
        return self.status == 'eingereicht'
    
    @property
    def ist_freigegeben(self):
        """Ist Status = freigegeben?"""
        return self.status == 'freigegeben'
    
    @property
    def ist_abgelehnt(self):
        """Ist Status = abgelehnt?"""
        return self.status == 'abgelehnt'
    
    def kann_bearbeitet_werden(self):
        """Kann die Planung noch bearbeitet werden?"""
        return self.status in ['entwurf', 'abgelehnt']
    
    def kann_eingereicht_werden(self):
        """Kann die Planung eingereicht werden?"""
        return self.status == 'entwurf' and self.geplante_module.count() > 0
    
    def kann_freigegeben_werden(self):
        """Kann die Planung freigegeben werden? (nur Dekan)"""
        return self.status == 'eingereicht'

    # =========================================================================
    # JSON PROPERTIES - Room Requirements & Special Requests
    # =========================================================================

    @property
    def room_requirements(self):
        """Gibt Liste von Raumanforderungen zurück"""
        if self._room_requirements:
            try:
                return json.loads(self._room_requirements)
            except (json.JSONDecodeError, TypeError):
                return []
        return []

    @room_requirements.setter
    def room_requirements(self, value):
        """Setzt Raumanforderungen als JSON"""
        if value:
            self._room_requirements = json.dumps(value, ensure_ascii=False)
        else:
            self._room_requirements = None

    @property
    def special_requests(self):
        """Gibt Special Requests Dictionary zurück"""
        if self._special_requests:
            try:
                return json.loads(self._special_requests)
            except (json.JSONDecodeError, TypeError):
                return {}
        return {}

    @special_requests.setter
    def special_requests(self, value):
        """Setzt Special Requests als JSON"""
        if value:
            self._special_requests = json.dumps(value, ensure_ascii=False)
        else:
            self._special_requests = None

    # =========================================================================
    # WORKFLOW ACTIONS
    # =========================================================================
    
    def einreichen(self):
        """
        Reicht die Planung ein
        
        Returns:
            bool: True wenn erfolgreich
        """
        if not self.kann_eingereicht_werden():
            raise ValueError(f"Planung kann nicht eingereicht werden (Status: {self.status})")
        
        self.status = 'eingereicht'
        self.eingereicht_am = datetime.utcnow()
        self.berechne_gesamt_sws()
        db.session.commit()
        return True
    
    def freigeben(self, freigeber_benutzer_id):
        """
        Gibt die Planung frei (nur Dekan)
        
        Args:
            freigeber_benutzer_id: ID des Benutzers der freigibt
            
        Returns:
            bool: True wenn erfolgreich
        """
        if not self.kann_freigegeben_werden():
            raise ValueError(f"Planung kann nicht freigegeben werden (Status: {self.status})")
        
        self.status = 'freigegeben'
        self.freigegeben_von = freigeber_benutzer_id
        self.freigegeben_am = datetime.utcnow()
        db.session.commit()
        return True
    
    def ablehnen(self, grund=None):
        """
        Lehnt die Planung ab (nur Dekan)
        
        Args:
            grund: Optionaler Ablehnungsgrund
            
        Returns:
            bool: True wenn erfolgreich
        """
        if self.status != 'eingereicht':
            raise ValueError(f"Nur eingereichte Planungen kÃ¶nnen abgelehnt werden (Status: {self.status})")
        
        self.status = 'abgelehnt'
        self.abgelehnt_am = datetime.utcnow()
        self.ablehnungsgrund = grund
        db.session.commit()
        return True
    
    def zurueck_zu_entwurf(self):
        """Setzt Status zurÃ¼ck auf Entwurf"""
        self.status = 'entwurf'
        self.eingereicht_am = None
        self.freigegeben_von = None
        self.freigegeben_am = None
        self.abgelehnt_am = None
        self.ablehnungsgrund = None
        db.session.commit()
        return True
    
    # =========================================================================
    # SWS CALCULATION
    # =========================================================================
    
    def berechne_gesamt_sws(self):
        """
        Berechnet die Gesamt-SWS aus allen geplanten Modulen
        
        Returns:
            float: Gesamt-SWS
        """
        total = sum(modul.sws_gesamt or 0 for modul in self.geplante_module.all())
        self.gesamt_sws = total
        return total
    
    # =========================================================================
    # MODULE MANAGEMENT
    # =========================================================================
    
    def add_modul(self, modul_id, po_id, **kwargs):
        """
        FÃ¼gt ein Modul zur Planung hinzu
        
        Args:
            modul_id: ID des Moduls
            po_id: ID der PrÃ¼fungsordnung
            **kwargs: Weitere Felder (anzahl_vorlesungen, etc.)
            
        Returns:
            GeplantesModul: Das neu erstellte geplante Modul
        """
        # PrÃ¼fe ob Modul bereits existiert
        existing = self.geplante_module.filter_by(modul_id=modul_id).first()
        if existing:
            raise ValueError(f"Modul {modul_id} ist bereits in der Planung")
        
        geplantes_modul = GeplantesModul(
            semesterplanung_id=self.id,
            modul_id=modul_id,
            po_id=po_id,
            **kwargs
        )
        geplantes_modul.berechne_sws()
        
        db.session.add(geplantes_modul)
        db.session.commit()
        
        self.berechne_gesamt_sws()
        return geplantes_modul
    
    def remove_modul(self, modul_id):
        """
        Entfernt ein Modul aus der Planung
        
        Args:
            modul_id: ID des Moduls
        """
        geplantes_modul = self.geplante_module.filter_by(modul_id=modul_id).first()
        if geplantes_modul:
            db.session.delete(geplantes_modul)
            db.session.commit()
            self.berechne_gesamt_sws()
    
    # =========================================================================
    # STATISTICS
    # =========================================================================
    
    @property
    def anzahl_module(self):
        """Anzahl geplanter Module"""
        return self.geplante_module.count()
    
    # =========================================================================
    # HELPER METHODS
    # =========================================================================
    
    def to_dict(self, include_module=False):
        """
        Konvertiert zu Dictionary (fÃ¼r API)

        Args:
            include_module: Sollen alle Module inkludiert werden?
        """
        data = {
            'id': self.id,
            'semester': {
                'id': self.semester.id,
                'kuerzel': self.semester.kuerzel,
                'bezeichnung': self.semester.bezeichnung
            } if self.semester else None,
            'benutzer': {
                'id': self.benutzer.id,
                'username': self.benutzer.username,
                'name_komplett': self.benutzer.name_komplett,
                'email': self.benutzer.email
            } if self.benutzer else None,
            'planungsphase': {
                'id': self.planungsphase.id,
                'name': self.planungsphase.name,
                'startdatum': self.planungsphase.startdatum.isoformat() if self.planungsphase.startdatum else None,
                'enddatum': self.planungsphase.enddatum.isoformat() if self.planungsphase.enddatum else None
            } if self.planungsphase else None,
            'status': self.status,
            'anmerkungen': self.anmerkungen,
            'raumbedarf': self.raumbedarf,
            'room_requirements': self.room_requirements,
            'special_requests': self.special_requests,
            'gesamt_sws': self.gesamt_sws,
            'anzahl_module': self.anzahl_module,
            'eingereicht_am': self.eingereicht_am.isoformat() if self.eingereicht_am else None,
            'freigegeben_am': self.freigegeben_am.isoformat() if self.freigegeben_am else None,
            'abgelehnt_am': self.abgelehnt_am.isoformat() if self.abgelehnt_am else None,
            'ablehnungsgrund': self.ablehnungsgrund,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
        }

        if include_module:
            data['geplante_module'] = [m.to_dict() for m in self.geplante_module.all()]
            data['wunsch_freie_tage'] = [t.to_dict() for t in self.wunsch_freie_tage.all()]

        return data
    
    @classmethod
    def get_or_create(cls, semester_id, benutzer_id):
        """
        Holt bestehende Planung oder erstellt neue
        
        Args:
            semester_id: ID des Semesters
            benutzer_id: ID des Benutzers
            
        Returns:
            tuple: (Semesterplanung, created: bool)
        """
        planung = cls.query.filter_by(
            semester_id=semester_id,
            benutzer_id=benutzer_id
        ).first()
        
        if planung:
            return planung, False
        
        planung = cls(
            semester_id=semester_id,
            benutzer_id=benutzer_id,
            status='entwurf'
        )
        db.session.add(planung)
        db.session.commit()
        
        return planung, True


class GeplantesModul(db.Model):
    """
    Geplantes Modul - Details der Semesterplanung
    
    VerknÃ¼pft zu bestehender modul-Tabelle!
    EnthÃ¤lt Multiplikatoren und berechnete SWS.
    
    Attributes:
        semesterplanung_id: Foreign Key zu Semesterplanung
        modul_id: Foreign Key zu Modul (BESTEHEND!)
        po_id: Foreign Key zu Pruefungsordnung
        anzahl_vorlesungen: Multiplikator fÃ¼r Vorlesungen
        anzahl_uebungen: Multiplikator fÃ¼r Ãœbungen
        anzahl_praktika: Multiplikator fÃ¼r Praktika
        anzahl_seminare: Multiplikator fÃ¼r Seminare
        sws_*: Berechnete SWS (Multiplikator Ã— Basis-SWS aus modul_lehrform)
    """
    __tablename__ = 'geplante_module'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # VerknÃ¼pfungen
    semesterplanung_id = db.Column(
        db.Integer,
        db.ForeignKey('semesterplanung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )
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
    
    # MULTIPLIKATOREN (Schritt 5 im Workflow)
    anzahl_vorlesungen = db.Column(db.Integer, default=0, nullable=False)
    anzahl_uebungen = db.Column(db.Integer, default=0, nullable=False)
    anzahl_praktika = db.Column(db.Integer, default=0, nullable=False)
    anzahl_seminare = db.Column(db.Integer, default=0, nullable=False)
    
    # SWS-BERECHNUNG (automatisch aus modul_lehrform Ã— Multiplikator)
    sws_vorlesung = db.Column(db.Float, default=0.0, nullable=False)
    sws_uebung = db.Column(db.Float, default=0.0, nullable=False)
    sws_praktikum = db.Column(db.Float, default=0.0, nullable=False)
    sws_seminar = db.Column(db.Float, default=0.0, nullable=False)
    sws_gesamt = db.Column(db.Float, default=0.0, nullable=False)
    
    # MITARBEITER (Schritt 4 im Workflow)
    # JSON Array von dozent_ids: "[12, 45, 78]"
    _mitarbeiter_ids = db.Column('mitarbeiter_ids', db.Text)
    
    # ZUSÃ„TZLICHE INFOS (Schritt 6)
    anmerkungen = db.Column(db.Text)
    raumbedarf = db.Column(db.Text)

    # ✨ NEW: Feature 4 - RAUMPLANUNG PRO LEHRFORM
    raum_vorlesung = db.Column(db.String(100), nullable=True)
    raum_uebung = db.Column(db.String(100), nullable=True)
    raum_praktikum = db.Column(db.String(100), nullable=True)
    raum_seminar = db.Column(db.String(100), nullable=True)

    # ✨ NEW: Feature 4 - KAPAZITÄTS-ANFORDERUNGEN PRO LEHRFORM
    kapazitaet_vorlesung = db.Column(db.Integer, nullable=True)
    kapazitaet_uebung = db.Column(db.Integer, nullable=True)
    kapazitaet_praktikum = db.Column(db.Integer, nullable=True)
    kapazitaet_seminar = db.Column(db.Integer, nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    semesterplanung = db.relationship('Semesterplanung', back_populates='geplante_module')
    modul = db.relationship('Modul')  # Zu bestehendem Modul-Model
    pruefungsordnung = db.relationship('Pruefungsordnung')
    
    # UNIQUE Constraint: Ein Modul kann nur EINMAL pro Planung sein
    __table_args__ = (
        db.UniqueConstraint('semesterplanung_id', 'modul_id', name='uq_planung_modul'),
        db.Index('ix_geplantes_modul_planung', 'semesterplanung_id'),
    )
    
    def __repr__(self):
        return f'<GeplantesModul {self.modul.kuerzel if self.modul else "?"}>'
    
    # =========================================================================
    # MITARBEITER JSON HANDLING
    # =========================================================================
    
    @property
    def mitarbeiter_ids(self):
        """Gibt Liste von Mitarbeiter-IDs zurÃ¼ck"""
        if self._mitarbeiter_ids:
            try:
                return json.loads(self._mitarbeiter_ids)
            except (json.JSONDecodeError, TypeError):
                return []
        return []
    
    @mitarbeiter_ids.setter
    def mitarbeiter_ids(self, value):
        """Setzt Mitarbeiter-IDs als JSON"""
        if value:
            self._mitarbeiter_ids = json.dumps(value)
        else:
            self._mitarbeiter_ids = None
    
    # =========================================================================
    # SWS CALCULATION
    # =========================================================================
    
    def berechne_sws(self):
        """
        Berechnet SWS basierend auf modul_lehrform und Multiplikatoren
        Nutzt bestehende modul_lehrform-Tabelle!
        
        Returns:
            float: Gesamt-SWS
        """
        if not self.modul:
            return 0.0
        
        total_sws = 0.0
        
        # Hole Lehrformen aus modul_lehrform (bestehende Tabelle!)
        # Erstelle Dictionary: lehrform.kuerzel â†’ sws
        lehrformen_dict = {}
        for lehrform_entry in self.modul.lehrformen:
            if lehrform_entry.po_id == self.po_id:
                lehrform_kuerzel = lehrform_entry.lehrform.kuerzel
                lehrformen_dict[lehrform_kuerzel] = lehrform_entry.sws
        
        # Berechne SWS fÃ¼r jede Lehrform
        self.sws_vorlesung = self.anzahl_vorlesungen * lehrformen_dict.get('V', 0.0)
        self.sws_uebung = self.anzahl_uebungen * lehrformen_dict.get('Ãœ', 0.0)
        self.sws_praktikum = self.anzahl_praktika * lehrformen_dict.get('P', 0.0)
        self.sws_seminar = self.anzahl_seminare * lehrformen_dict.get('S', 0.0)
        
        total_sws = (
            self.sws_vorlesung +
            self.sws_uebung +
            self.sws_praktikum +
            self.sws_seminar
        )
        
        self.sws_gesamt = total_sws
        return total_sws
    
    # =========================================================================
    # HELPER METHODS
    # =========================================================================
    
    def get_lehrformen_text(self):
        """
        Gibt formatierte Lehrformen zurÃ¼ck (z.B. "2V + 1Ãœ + 1P")
        
        Returns:
            str: Formatierte Lehrformen
        """
        parts = []
        if self.anzahl_vorlesungen > 0:
            parts.append(f"{self.anzahl_vorlesungen}V")
        if self.anzahl_uebungen > 0:
            parts.append(f"{self.anzahl_uebungen}Ãœ")
        if self.anzahl_praktika > 0:
            parts.append(f"{self.anzahl_praktika}P")
        if self.anzahl_seminare > 0:
            parts.append(f"{self.anzahl_seminare}S")
        return " + ".join(parts) if parts else "Keine"
    
    def to_dict(self):
        """Konvertiert zu Dictionary (fÃ¼r API) - FIXED: Flache Struktur"""
        return {
            'id': self.id,
            'modul_id': self.modul_id,
            'po_id': self.po_id,
            'semesterplanung_id': self.semesterplanung_id,

            # Modul-Daten
            'modul': {
                'id': self.modul.id,
                'kuerzel': self.modul.kuerzel,
                'bezeichnung_de': self.modul.bezeichnung_de,
                'leistungspunkte': self.modul.leistungspunkte
            } if self.modul else None,

            # Multiplikatoren (FLACH!)
            'anzahl_vorlesungen': self.anzahl_vorlesungen,
            'anzahl_uebungen': self.anzahl_uebungen,
            'anzahl_praktika': self.anzahl_praktika,
            'anzahl_seminare': self.anzahl_seminare,

            # SWS (FLACH statt verschachtelt!)
            'sws_vorlesung': float(self.sws_vorlesung) if self.sws_vorlesung else 0.0,
            'sws_uebung': float(self.sws_uebung) if self.sws_uebung else 0.0,
            'sws_praktikum': float(self.sws_praktikum) if self.sws_praktikum else 0.0,
            'sws_seminar': float(self.sws_seminar) if self.sws_seminar else 0.0,
            'sws_gesamt': float(self.sws_gesamt) if self.sws_gesamt else 0.0,

            # Zusaetzlich
            'lehrformen_text': self.get_lehrformen_text(),
            'mitarbeiter_ids': self.mitarbeiter_ids,
            'anmerkungen': self.anmerkungen,
            'raumbedarf': self.raumbedarf,

            # ✨ NEW: Feature 4 - Raumplanung pro Lehrform
            'raum_vorlesung': self.raum_vorlesung,
            'raum_uebung': self.raum_uebung,
            'raum_praktikum': self.raum_praktikum,
            'raum_seminar': self.raum_seminar,

            # ✨ NEW: Feature 4 - Kapazitäts-Anforderungen pro Lehrform
            'kapazitaet_vorlesung': self.kapazitaet_vorlesung,
            'kapazitaet_uebung': self.kapazitaet_uebung,
            'kapazitaet_praktikum': self.kapazitaet_praktikum,
            'kapazitaet_seminar': self.kapazitaet_seminar,
        }


class WunschFreierTag(db.Model):
    """
    Wunsch-freie Tage fÃ¼r Semesterplanung (Schritt 7)

    Dozenten kÃ¶nnen Wunschtage fÃ¼r vorlesungsfreie Tage angeben.

    Attributes:
        semesterplanung_id: Foreign Key zu Semesterplanung
        wochentag: Wochentag ('montag', 'dienstag', etc.)
        zeitraum: Zeitraum ('ganztags', 'vormittag', 'nachmittag')
        prioritaet: 'hoch', 'mittel', 'niedrig'
        bemerkung: Optionale BegrÃ¼ndung (legacy)
        grund: Optionale BegrÃ¼ndung (neues Feld)
    """
    __tablename__ = 'wunsch_freie_tage'

    id = db.Column(db.Integer, primary_key=True)
    semesterplanung_id = db.Column(
        db.Integer,
        db.ForeignKey('semesterplanung.id', ondelete='CASCADE'),
        nullable=False,
        index=True
    )

    wochentag = db.Column(db.String(20), nullable=False)  # 'montag', 'dienstag', ...
    zeitraum = db.Column(db.String(20), default='ganztags', nullable=False)  # 'ganztags', 'vormittag', 'nachmittag'
    prioritaet = db.Column(db.String(20), default='mittel', nullable=False)  # 'hoch', 'mittel', 'niedrig'
    bemerkung = db.Column(db.Text)  # Legacy
    grund = db.Column(db.Text)  # Neues Feld
    
    # Relationships
    semesterplanung = db.relationship('Semesterplanung', back_populates='wunsch_freie_tage')
    
    def __repr__(self):
        return f'<WunschFreierTag {self.wochentag} {self.zeitraum}>'

    # Konstanten
    WOCHENTAGE = ['montag', 'dienstag', 'mittwoch', 'donnerstag', 'freitag']
    ZEITRAEUME = ['ganztags', 'vormittag', 'nachmittag']
    PRIORITAETEN = ['hoch', 'mittel', 'niedrig']

    @property
    def grund_text(self):
        """Gibt Grund zurück (nutzt neues Feld, fallback auf bemerkung)"""
        return self.grund or self.bemerkung or ''

    @classmethod
    def is_valid_wochentag(cls, wochentag):
        """Prüft ob Wochentag valide ist"""
        return wochentag.lower() in cls.WOCHENTAGE

    @classmethod
    def is_valid_zeitraum(cls, zeitraum):
        """Prüft ob Zeitraum valide ist"""
        return zeitraum.lower() in cls.ZEITRAEUME

    @classmethod
    def is_valid_prioritaet(cls, prioritaet):
        """Prüft ob Priorität valide ist"""
        return prioritaet.lower() in cls.PRIORITAETEN

    def to_dict(self):
        """Konvertiert zu Dictionary (für API)"""
        return {
            'id': self.id,
            'wochentag': self.wochentag,
            'zeitraum': self.zeitraum,
            'prioritaet': self.prioritaet,
            'grund': self.grund_text,  # Nutzt Property für Backward Compatibility
            # Legacy-Felder für Backward Compatibility
            'bemerkung': self.bemerkung
        }