"""
User Service
============
Business Logic für Benutzer-Verwaltung.

Funktionen:
- Benutzer erstellen/bearbeiten/löschen
- Passwort-Management
- Rollen-Verwaltung
- Dozenten-Verknüpfung
"""

from typing import Optional, List, Dict, Any
from app.services.base_service import BaseService
from app.models import Benutzer, Rolle, Dozent
from app.auth.utils import validate_password_with_config, validate_email
from app.extensions import db
from flask import current_app


class UserService(BaseService):
    """
    User Service
    
    Verwaltet Benutzer-Accounts und deren Rollen.
    """
    
    model = Benutzer
    
    # =========================================================================
    # USER MANAGEMENT
    # =========================================================================
    
    def create_user(
        self,
        email: str,
        username: str,
        password: str,
        rolle_name: str,
        vorname: Optional[str] = None,
        nachname: Optional[str] = None,
        dozent_id: Optional[int] = None,
        aktiv: bool = True
    ) -> Benutzer:
        """
        Erstellt einen neuen Benutzer
        
        Args:
            email: Email-Adresse (unique)
            username: Benutzername (unique)
            password: Passwort (Klartext - wird gehasht)
            rolle_name: Name der Rolle ('dekan', 'professor', 'lehrbeauftragter')
            vorname: Optional - Vorname
            nachname: Optional - Nachname
            dozent_id: Optional - Foreign Key zu Dozent
            aktiv: Ist User aktiv?
            
        Returns:
            Benutzer: Neu erstellter Benutzer
            
        Raises:
            ValueError: Bei ungültigen Daten
            
        Example:
            user = user_service.create_user(
                email='max@example.com',
                username='max.mueller',
                password='Test1234',
                rolle_name='professor'
            )
        """
        # Email validieren
        if not validate_email(email):
            raise ValueError("Ungültige Email-Adresse")
        
        # Passwort validieren
        is_valid, errors = validate_password_with_config(password, current_app.config)
        if not is_valid:
            raise ValueError(f"Passwort ungültig: {', '.join(errors)}")
        
        # Prüfe ob Email bereits existiert
        if self.get_by_email(email):
            raise ValueError(f"Email '{email}' ist bereits registriert")
        
        # Prüfe ob Username bereits existiert
        if self.get_by_username(username):
            raise ValueError(f"Username '{username}' ist bereits vergeben")
        
        # Rolle holen
        rolle = Rolle.get_by_name(rolle_name)
        if not rolle:
            raise ValueError(f"Rolle '{rolle_name}' existiert nicht")
        
        # Dozent prüfen falls angegeben
        if dozent_id:
            dozent = Dozent.query.get(dozent_id)
            if not dozent:
                raise ValueError(f"Dozent {dozent_id} nicht gefunden")
            # Prüfe ob Dozent bereits User hat
            existing = self.get_by_dozent(dozent_id)
            if existing:
                raise ValueError(f"Dozent hat bereits einen Benutzer-Account")
        
        # Benutzer erstellen
        user = Benutzer(
            email=email,
            username=username,
            rolle_id=rolle.id,
            vorname=vorname,
            nachname=nachname,
            dozent_id=dozent_id,
            aktiv=aktiv
        )
        user.set_password(password)
        
        db.session.add(user)
        db.session.commit()
        
        return user
    
    def update_user(
        self,
        user_id: int,
        **data
    ) -> Optional[Benutzer]:
        """
        Updated Benutzer-Daten
        
        Args:
            user_id: Benutzer ID
            **data: Felder die geupdated werden sollen
            
        Returns:
            Geupdateter Benutzer oder None
            
        Note:
            Passwort wird NICHT über diese Methode geändert!
            Verwende change_password() dafür.
            
        Example:
            user = user_service.update_user(
                1,
                vorname='Maximilian',
                nachname='Müller'
            )
        """
        # Passwort-Änderung verhindern
        if 'password' in data or 'password_hash' in data:
            raise ValueError("Passwort kann nicht über update_user() geändert werden")
        
        # Email-Änderung validieren
        if 'email' in data:
            if not validate_email(data['email']):
                raise ValueError("Ungültige Email-Adresse")
            # Prüfe ob neue Email bereits existiert
            existing = self.get_by_email(data['email'])
            if existing and existing.id != user_id:
                raise ValueError(f"Email '{data['email']}' ist bereits registriert")
        
        # Username-Änderung validieren
        if 'username' in data:
            existing = self.get_by_username(data['username'])
            if existing and existing.id != user_id:
                raise ValueError(f"Username '{data['username']}' ist bereits vergeben")
        
        return self.update(user_id, **data)
    
    # =========================================================================
    # PASSWORD MANAGEMENT
    # =========================================================================
    
    def change_password(
        self,
        user_id: int,
        old_password: str,
        new_password: str
    ) -> bool:
        """
        Ändert Benutzer-Passwort
        
        Args:
            user_id: Benutzer ID
            old_password: Altes Passwort
            new_password: Neues Passwort
            
        Returns:
            bool: True wenn erfolgreich
            
        Raises:
            ValueError: Bei ungültigem Passwort oder falscher Eingabe
        """
        user = self.get_by_id(user_id)
        if not user:
            raise ValueError("Benutzer nicht gefunden")
        
        # Altes Passwort prüfen
        if not user.check_password(old_password):
            raise ValueError("Altes Passwort ist falsch")
        
        # Neues Passwort validieren
        is_valid, errors = validate_password_with_config(new_password, current_app.config)
        if not is_valid:
            raise ValueError(f"Neues Passwort ungültig: {', '.join(errors)}")
        
        # Passwort ändern
        user.set_password(new_password)
        db.session.commit()
        
        return True
    
    def reset_password(
        self,
        user_id: int,
        new_password: str
    ) -> bool:
        """
        Setzt Passwort zurück (ohne altes Passwort)
        Nur für Admins!
        
        Args:
            user_id: Benutzer ID
            new_password: Neues Passwort
            
        Returns:
            bool: True wenn erfolgreich
        """
        user = self.get_by_id(user_id)
        if not user:
            raise ValueError("Benutzer nicht gefunden")
        
        # Neues Passwort validieren
        is_valid, errors = validate_password_with_config(new_password, current_app.config)
        if not is_valid:
            raise ValueError(f"Passwort ungültig: {', '.join(errors)}")
        
        user.set_password(new_password)
        db.session.commit()
        
        return True
    
    # =========================================================================
    # ACCOUNT STATUS
    # =========================================================================
    
    def aktiviere_user(self, user_id: int) -> bool:
        """
        Aktiviert Benutzer-Account
        
        Args:
            user_id: Benutzer ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        user = self.get_by_id(user_id)
        if not user:
            return False
        
        user.aktivieren()
        return True
    
    def deaktiviere_user(self, user_id: int) -> bool:
        """
        Deaktiviert Benutzer-Account
        
        Args:
            user_id: Benutzer ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        user = self.get_by_id(user_id)
        if not user:
            return False
        
        user.deaktivieren()
        return True
    
    # =========================================================================
    # ROLLE MANAGEMENT
    # =========================================================================
    
    def change_rolle(
        self,
        user_id: int,
        rolle_name: str
    ) -> Optional[Benutzer]:
        """
        Ändert Rolle eines Benutzers
        
        Args:
            user_id: Benutzer ID
            rolle_name: Neuer Rollenname
            
        Returns:
            Benutzer mit neuer Rolle oder None
        """
        user = self.get_by_id(user_id)
        if not user:
            return None
        
        rolle = Rolle.get_by_name(rolle_name)
        if not rolle:
            raise ValueError(f"Rolle '{rolle_name}' existiert nicht")
        
        user.rolle_id = rolle.id
        db.session.commit()
        
        return user
    
    # =========================================================================
    # QUERIES
    # =========================================================================
    
    def get_by_email(self, email: str) -> Optional[Benutzer]:
        """Findet Benutzer anhand Email"""
        return self.get_first(email=email)
    
    def get_by_username(self, username: str) -> Optional[Benutzer]:
        """Findet Benutzer anhand Username"""
        return self.get_first(username=username)
    
    def get_by_dozent(self, dozent_id: int) -> Optional[Benutzer]:
        """Findet Benutzer anhand Dozent-ID"""
        return self.get_first(dozent_id=dozent_id)
    
    def get_by_rolle(self, rolle_name: str) -> List[Benutzer]:
        """
        Holt alle Benutzer einer Rolle
        
        Args:
            rolle_name: Rollenname
            
        Returns:
            Liste von Benutzern
        """
        rolle = Rolle.get_by_name(rolle_name)
        if not rolle:
            return []
        return self.get_all(rolle_id=rolle.id)
    
    def get_aktive(self) -> List[Benutzer]:
        """Holt alle aktiven Benutzer"""
        return self.get_all(aktiv=True)
    
    def get_dekane(self) -> List[Benutzer]:
        """Holt alle Dekane"""
        return self.get_by_rolle('dekan')
    
    def get_professoren(self) -> List[Benutzer]:
        """Holt alle Professoren"""
        return self.get_by_rolle('professor')
    
    def get_lehrbeauftragte(self) -> List[Benutzer]:
        """Holt alle Lehrbeauftragten"""
        return self.get_by_rolle('lehrbeauftragter')
    
    def get_dozenten(self) -> List[Benutzer]:
        """Holt alle Dozenten (Professoren + Lehrbeauftragte)"""
        professoren = self.get_professoren()
        lehrbeauftragte = self.get_lehrbeauftragte()
        return professoren + lehrbeauftragte
    
    # =========================================================================
    # STATISTICS
    # =========================================================================
    
    def get_statistik(self) -> Dict[str, Any]:
        """
        Gibt Benutzer-Statistiken zurück
        
        Returns:
            Dict mit Statistiken
        """
        return {
            'gesamt': self.count(),
            'aktiv': self.count(aktiv=True),
            'inaktiv': self.count(aktiv=False),
            'dekane': len(self.get_dekane()),
            'professoren': len(self.get_professoren()),
            'lehrbeauftragte': len(self.get_lehrbeauftragte()),
        }
    
    # =========================================================================
    # VALIDATION
    # =========================================================================
    
    def kann_geloescht_werden(self, user_id: int) -> tuple[bool, str]:
        """
        Prüft ob Benutzer gelöscht werden kann
        
        Args:
            user_id: Benutzer ID
            
        Returns:
            tuple: (kann_geloescht, grund)
        """
        user = self.get_by_id(user_id)
        if not user:
            return False, "Benutzer nicht gefunden"
        
        # Prüfe ob Semesterplanungen existieren
        anzahl_planungen = user.semesterplanungen.count()
        if anzahl_planungen > 0:
            return False, f"Benutzer hat {anzahl_planungen} Semesterplanungen"
        
        # Prüfe ob freigegebene Planungen existieren
        anzahl_freigaben = user.freigegebene_planungen.count()
        if anzahl_freigaben > 0:
            return False, f"Benutzer hat {anzahl_freigaben} Planungen freigegeben"
        
        return True, ""
    
    def delete_user(self, user_id: int, force: bool = False) -> bool:
        """
        Löscht einen Benutzer
        
        Args:
            user_id: Benutzer ID
            force: Bei True werden auch Benutzer mit Planungen gelöscht
            
        Returns:
            bool: True wenn erfolgreich
        """
        if not force:
            kann, grund = self.kann_geloescht_werden(user_id)
            if not kann:
                raise ValueError(f"Benutzer kann nicht gelöscht werden: {grund}")
        
        return self.delete(user_id)


# Singleton Instance
user_service = UserService()