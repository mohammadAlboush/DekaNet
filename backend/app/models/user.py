"""
User & Authentication Models
=============================
Neue Models fÃ¼r Benutzer-Verwaltung und Login-System.

Models:
- Rolle: Benutzer-Rollen (dekan, professor, lehrbeauftragter)
- Benutzer: User-Accounts mit Login-FunktionalitÃ¤t
"""

from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin
from .base import db


class Rolle(db.Model):
    """
    Benutzer-Rollen
    
    Definiert die 3 Haupt-Rollen im System:
    - dekan: Vollzugriff auf alle Funktionen
    - professor: Eigene Semesterplanung + Modulzuordnung
    - lehrbeauftragter: Eigene Semesterplanung
    """
    __tablename__ = 'rolle'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False, index=True)
    beschreibung = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    benutzer = db.relationship('Benutzer', back_populates='rolle', lazy='dynamic')
    
    def __repr__(self):
        return f'<Rolle {self.name}>'
    
    def __str__(self):
        return self.name
    
    @classmethod
    def get_by_name(cls, name):
        """Findet Rolle anhand des Namens"""
        return cls.query.filter_by(name=name).first()
    
    @classmethod
    def is_valid_role(cls, name):
        """PrÃ¼ft ob Rollenname valide ist"""
        return name in ['dekan', 'professor', 'lehrbeauftragter']


class Benutzer(db.Model, UserMixin):
    """
    Benutzer-Accounts fÃ¼r Login
    
    VerknÃ¼pfung zu bestehender dozent-Tabelle via dozent_id.
    UserMixin von Flask-Login fÃ¼r Authentication.
    
    Attributes:
        email: Unique Email-Adresse
        username: Unique Benutzername
        password_hash: Gehashtes Passwort (niemals Klartext!)
        rolle_id: Foreign Key zu Rolle
        dozent_id: Optional - Foreign Key zu Dozent (NULL fÃ¼r Dekan ohne Dozenten-Profil)
        aktiv: Boolean - Ist Account aktiv?
    """
    __tablename__ = 'benutzer'
    
    id = db.Column(db.Integer, primary_key=True)
    
    # Login-Daten
    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    username = db.Column(db.String(100), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    
    # Rolle
    rolle_id = db.Column(
        db.Integer,
        db.ForeignKey('rolle.id', ondelete='RESTRICT'),
        nullable=False,
        index=True
    )
    
    # VerknÃ¼pfung zu bestehendem Dozent (optional)
    dozent_id = db.Column(
        db.Integer,
        db.ForeignKey('dozent.id', ondelete='SET NULL'),
        index=True
    )
    
    # PersÃ¶nliche Daten (redundant zu dozent, aber nÃ¼tzlich fÃ¼r Dekan ohne dozent_id)
    vorname = db.Column(db.String(100))
    nachname = db.Column(db.String(100))
    
    # Status
    aktiv = db.Column(db.Boolean, default=True, nullable=False)
    letzter_login = db.Column(db.DateTime)
    
    # Audit
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False
    )
    
    # Relationships
    rolle = db.relationship('Rolle', back_populates='benutzer')
    dozent = db.relationship('Dozent', foreign_keys=[dozent_id])
    
    # Semesterplanungen als Ersteller
    semesterplanungen = db.relationship(
        'Semesterplanung',
        foreign_keys='Semesterplanung.benutzer_id',
        back_populates='benutzer',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # Semesterplanungen als Freigeber (Dekan)
    freigegebene_planungen = db.relationship(
        'Semesterplanung',
        foreign_keys='Semesterplanung.freigegeben_von',
        back_populates='freigeber',
        lazy='dynamic'
    )
    
    # Benachrichtigungen
    benachrichtigungen = db.relationship(
        'Benachrichtigung',
        back_populates='empfaenger',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    # Audit Logs
    audit_logs = db.relationship(
        'AuditLog',
        back_populates='benutzer',
        lazy='dynamic',
        cascade='all, delete-orphan'
    )
    
    def __repr__(self):
        return f'<Benutzer {self.username}>'
    
    def __str__(self):
        return self.username
    
    # =========================================================================
    # PASSWORD MANAGEMENT
    # =========================================================================
    
    def set_password(self, password):
        """
        Setzt das Passwort (wird automatisch gehasht)
        
        Args:
            password: Klartext-Passwort
        """
        self.password_hash = generate_password_hash(
            password,
            method='pbkdf2:sha256',
            salt_length=16
        )
    
    def check_password(self, password):
        """
        PrÃ¼ft ob Passwort korrekt ist
        
        Args:
            password: Klartext-Passwort zum PrÃ¼fen
            
        Returns:
            bool: True wenn Passwort korrekt
        """
        return check_password_hash(self.password_hash, password)
    
    # =========================================================================
    # FLASK-LOGIN INTEGRATION
    # =========================================================================
    
    @property
    def is_authenticated(self):
        """Flask-Login: Ist User authentifiziert?"""
        return True
    
    @property
    def is_active(self):
        """Flask-Login: Ist User aktiv?"""
        return self.aktiv
    
    @property
    def is_anonymous(self):
        """Flask-Login: Ist User anonym?"""
        return False
    
    def get_id(self):
        """Flask-Login: User-ID als String"""
        return str(self.id)
    
    # =========================================================================
    # ROLE CHECKS
    # =========================================================================
    
    def hat_rolle(self, rolle_name):
        """
        PrÃ¼ft ob Benutzer eine bestimmte Rolle hat
        
        Args:
            rolle_name: Name der Rolle ('dekan', 'professor', 'lehrbeauftragter')
            
        Returns:
            bool: True wenn Rolle passt
        """
        return self.rolle and self.rolle.name == rolle_name
    
    def ist_dekan(self):
        """Ist Benutzer ein Dekan?"""
        return self.hat_rolle('dekan')
    
    def ist_professor(self):
        """Ist Benutzer ein Professor?"""
        return self.hat_rolle('professor')
    
    def ist_lehrbeauftragter(self):
        """Ist Benutzer ein Lehrbeauftragter?"""
        return self.hat_rolle('lehrbeauftragter')

    def ist_dozent(self):
        """Ist Benutzer ein Dozent? (Professor oder Lehrbeauftragter)"""
        return self.ist_professor() or self.ist_lehrbeauftragter()

    def get_rolle_name(self) -> str:
        """
        ✅ SECURITY: Sichere Methode um Rollennamen zu erhalten.

        Returns:
            str: Rollenname oder 'unknown' wenn keine Rolle zugewiesen
        """
        if self.rolle and hasattr(self.rolle, 'name'):
            return self.rolle.name
        return 'unknown'
    
    # =========================================================================
    # PROPERTIES
    # =========================================================================
    
    @property
    def name_komplett(self):
        """
        VollstÃ¤ndiger Name
        Nutzt dozent.name_komplett falls vorhanden, sonst eigene Felder
        
        Returns:
            str: VollstÃ¤ndiger Name
        """
        if self.dozent:
            return self.dozent.name_komplett
        if self.vorname and self.nachname:
            return f"{self.vorname} {self.nachname}"
        return self.username
    
    @property
    def display_name(self):
        """Name fÃ¼r Anzeige in UI"""
        return self.name_komplett
    
    # =========================================================================
    # HELPER METHODS
    # =========================================================================
    
    def aktualisiere_letzten_login(self):
        """Updated den letzten Login-Zeitstempel"""
        self.letzter_login = datetime.utcnow()
        db.session.commit()
    
    def aktivieren(self):
        """Aktiviert den Benutzer-Account"""
        self.aktiv = True
        db.session.commit()
    
    def deaktivieren(self):
        """Deaktiviert den Benutzer-Account"""
        self.aktiv = False
        db.session.commit()
    
    def get_aktuelle_planung(self, semester_id):
        """
        Holt die Semesterplanung fÃ¼r ein bestimmtes Semester
        
        Args:
            semester_id: ID des Semesters
            
        Returns:
            Semesterplanung oder None
        """
        return self.semesterplanungen.filter_by(semester_id=semester_id).first()
    
    def hat_planung_fuer_semester(self, semester_id):
        """
        PrÃ¼ft ob Benutzer eine Planung fÃ¼r Semester hat
        
        Args:
            semester_id: ID des Semesters
            
        Returns:
            bool: True wenn Planung existiert
        """
        return self.get_aktuelle_planung(semester_id) is not None
    
    def to_dict(self, include_sensitive=False):
        """
        Konvertiert zu Dictionary (fÃ¼r API)
        
        Args:
            include_sensitive: Soll password_hash inkludiert werden? (Normalerweise NEIN!)
            
        Returns:
            dict: Benutzer-Daten
        """
        data = {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'vorname': self.vorname,
            'nachname': self.nachname,
            'name_komplett': self.name_komplett,
            'rolle': self.rolle.name if self.rolle else None,
            'dozent_id': self.dozent_id,
            'aktiv': self.aktiv,
            'letzter_login': self.letzter_login.isoformat() if self.letzter_login else None,
            'created_at': self.created_at.isoformat(),
        }
        
        if include_sensitive:
            data['password_hash'] = self.password_hash
        
        return data
    
    # =========================================================================
    # CLASS METHODS
    # =========================================================================
    
    @classmethod
    def get_by_email(cls, email):
        """Findet Benutzer anhand Email"""
        return cls.query.filter_by(email=email).first()
    
    @classmethod
    def get_by_username(cls, username):
        """Findet Benutzer anhand Username"""
        return cls.query.filter_by(username=username).first()
    
    @classmethod
    def get_by_dozent(cls, dozent_id):
        """Findet Benutzer anhand Dozent-ID"""
        return cls.query.filter_by(dozent_id=dozent_id).first()
    
    @classmethod
    def get_all_aktiv(cls):
        """Holt alle aktiven Benutzer"""
        return cls.query.filter_by(aktiv=True).all()
    
    @classmethod
    def get_by_rolle(cls, rolle_name):
        """Holt alle Benutzer einer Rolle"""
        return cls.query.join(Rolle).filter(Rolle.name == rolle_name).all()
    
    @classmethod
    def create_user(cls, email, username, password, rolle_name, **kwargs):
        """
        Erstellt einen neuen Benutzer
        
        Args:
            email: Email-Adresse
            username: Benutzername
            password: Passwort (Klartext - wird gehasht)
            rolle_name: Name der Rolle
            **kwargs: Weitere optionale Felder (vorname, nachname, dozent_id, etc.)
            
        Returns:
            Benutzer: Neu erstellter Benutzer
        """
        rolle = Rolle.get_by_name(rolle_name)
        if not rolle:
            raise ValueError(f"Rolle '{rolle_name}' existiert nicht")
        
        benutzer = cls(
            email=email,
            username=username,
            rolle_id=rolle.id,
            **kwargs
        )
        benutzer.set_password(password)
        
        db.session.add(benutzer)
        db.session.commit()
        
        return benutzer