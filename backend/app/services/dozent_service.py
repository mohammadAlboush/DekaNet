"""
Dozent Service
==============
Business Logic für Dozenten-Verwaltung.

Funktionen:
- Dozenten suchen/filtern
- Modul-Zuordnungen
- Benutzer-Verknüpfung
"""

from typing import Optional, List, Dict, Any
from app.services.base_service import BaseService
from app.models import Dozent, DozentPosition, ModulDozent, Benutzer
from app.extensions import db


class DozentPositionService(BaseService):
    """
    Service für Dozent-Positionen (Platzhalter, Rollen, Gruppen)
    """
    model = DozentPosition

    def get_by_typ(self, typ: str) -> List[DozentPosition]:
        """Holt alle Positionen eines Typs."""
        return DozentPosition.query.filter_by(typ=typ).order_by(DozentPosition.bezeichnung).all()

    def get_all_positionen(self) -> List[Dict[str, Any]]:
        """Holt alle Positionen als Dicts."""
        positionen = DozentPosition.query.order_by(DozentPosition.typ, DozentPosition.bezeichnung).all()
        return [p.to_dict() for p in positionen]

    def create_position(
        self,
        bezeichnung: str,
        typ: str,
        beschreibung: Optional[str] = None,
        fachbereich: Optional[str] = None
    ) -> DozentPosition:
        """Erstellt eine neue Position."""
        return self.create(
            bezeichnung=bezeichnung,
            typ=typ,
            beschreibung=beschreibung,
            fachbereich=fachbereich
        )


class DozentService(BaseService):
    """
    Dozent Service

    Verwaltet Dozenten (Professoren, Lehrbeauftragte, etc.)
    Filtert standardmäßig Platzhalter-Dozenten aus.
    """

    model = Dozent
    
    # =========================================================================
    # DOZENT QUERIES
    # =========================================================================
    
    def get_aktive(self, include_platzhalter: bool = False) -> List[Dozent]:
        """
        Holt alle aktiven Dozenten

        Args:
            include_platzhalter: Platzhalter-Dozenten mit einschließen

        Returns:
            Liste von aktiven Dozenten
        """
        query = Dozent.query.filter_by(aktiv=True)
        if not include_platzhalter:
            query = query.filter_by(ist_platzhalter=False)
        return query.order_by(Dozent.nachname, Dozent.vorname).all()
    
    def get_by_fachbereich(
        self,
        fachbereich: str
    ) -> List[Dozent]:
        """
        Holt Dozenten eines Fachbereichs
        
        Args:
            fachbereich: Name des Fachbereichs
            
        Returns:
            Liste von Dozenten
        """
        return self.get_all(fachbereich=fachbereich, aktiv=True)
    
    def get_by_email(
        self,
        email: str
    ) -> Optional[Dozent]:
        """
        Findet Dozent anhand Email
        
        Args:
            email: Email-Adresse
            
        Returns:
            Dozent oder None
        """
        return self.get_first(email=email)
    
    def search(
        self,
        suchbegriff: str,
        include_platzhalter: bool = False
    ) -> List[Dozent]:
        """
        Sucht Dozenten anhand Name oder Email

        Args:
            suchbegriff: Suchtext
            include_platzhalter: Platzhalter-Dozenten mit einschließen

        Returns:
            Liste von gefundenen Dozenten
        """
        pattern = f"%{suchbegriff}%"
        query = Dozent.query.filter(
            db.or_(
                Dozent.name_komplett.ilike(pattern),
                Dozent.email.ilike(pattern),
                Dozent.nachname.ilike(pattern),
                Dozent.vorname.ilike(pattern)
            )
        ).filter_by(aktiv=True)
        if not include_platzhalter:
            query = query.filter_by(ist_platzhalter=False)
        return query.order_by(Dozent.nachname).all()
    
    # =========================================================================
    # DOZENT MANAGEMENT
    # =========================================================================
    
    def create_dozent(
        self,
        nachname: str,
        vorname: Optional[str] = None,
        titel: Optional[str] = None,
        email: Optional[str] = None,
        fachbereich: Optional[str] = None,
        aktiv: bool = True
    ) -> Dozent:
        """
        Erstellt einen neuen Dozenten
        
        Args:
            nachname: Nachname (required)
            vorname: Optional - Vorname
            titel: Optional - Akademischer Titel
            email: Optional - Email
            fachbereich: Optional - Fachbereich
            aktiv: Ist Dozent aktiv?
            
        Returns:
            Dozent: Neu erstellter Dozent
        """
        # Generiere name_komplett
        if vorname:
            name_komplett = f"{vorname} {nachname}"
        else:
            name_komplett = nachname
        
        dozent = self.create(
            nachname=nachname,
            vorname=vorname,
            titel=titel,
            name_komplett=name_komplett,
            email=email,
            fachbereich=fachbereich,
            aktiv=aktiv
        )
        
        return dozent
    
    def update_dozent(
        self,
        dozent_id: int,
        **data
    ) -> Optional[Dozent]:
        """
        Updated Dozent-Daten
        
        Args:
            dozent_id: Dozent ID
            **data: Felder die geupdated werden sollen
            
        Returns:
            Geupdateter Dozent oder None
        """
        # Regeneriere name_komplett wenn Vor-/Nachname geändert
        if 'vorname' in data or 'nachname' in data:
            dozent = self.get_by_id(dozent_id)
            if dozent:
                vorname = data.get('vorname', dozent.vorname)
                nachname = data.get('nachname', dozent.nachname)
                
                if vorname:
                    data['name_komplett'] = f"{vorname} {nachname}"
                else:
                    data['name_komplett'] = nachname
        
        return self.update(dozent_id, **data)
    
    def aktiviere_dozent(
        self,
        dozent_id: int
    ) -> bool:
        """
        Aktiviert einen Dozenten
        
        Args:
            dozent_id: Dozent ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent:
            return False
        
        dozent.aktivieren()
        return True
    
    def deaktiviere_dozent(
        self,
        dozent_id: int
    ) -> bool:
        """
        Deaktiviert einen Dozenten
        
        Args:
            dozent_id: Dozent ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent:
            return False
        
        dozent.deaktivieren()
        return True
    
    # =========================================================================
    # MODUL-ZUORDNUNGEN
    # =========================================================================
    
    def get_module(
        self,
        dozent_id: int,
        po_id: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        Holt alle Module eines Dozenten
        
        Args:
            dozent_id: Dozent ID
            po_id: Optional - Nur für diese PO
            
        Returns:
            Liste von Modulen
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent:
            return []
        
        module = dozent.get_module(po_id=po_id)
        
        # Dedupliziere Module basierend auf ID
        # (Ein Dozent kann mehrere Rollen im selben Modul haben)
        unique_modules = {}
        for m in module:
            if m.id not in unique_modules:
                unique_modules[m.id] = m
        
        return [m.to_dict() for m in unique_modules.values()]
    
    def get_module_als_verantwortlicher(
        self,
        dozent_id: int,
        po_id: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        Holt Module wo Dozent Verantwortlicher ist
        
        Args:
            dozent_id: Dozent ID
            po_id: Optional - Nur für diese PO
            
        Returns:
            Liste von Modulen
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent:
            return []
        
        module = dozent.get_module_als_verantwortlicher(po_id=po_id)
        return [m.to_dict() for m in module]
    
    def get_module_als_lehrperson(
        self,
        dozent_id: int,
        po_id: Optional[int] = None
    ) -> List[Dict[str, Any]]:
        """
        Holt Module wo Dozent Lehrperson ist
        
        Args:
            dozent_id: Dozent ID
            po_id: Optional - Nur für diese PO
            
        Returns:
            Liste von Modulen
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent:
            return []
        
        module = dozent.get_module_als_lehrperson(po_id=po_id)
        return [m.to_dict() for m in module]
    
    # =========================================================================
    # BENUTZER-VERKNÜPFUNG
    # =========================================================================
    
    def get_benutzer(
        self,
        dozent_id: int
    ) -> Optional[Dict[str, Any]]:
        """
        Holt Benutzer-Account eines Dozenten
        
        Args:
            dozent_id: Dozent ID
            
        Returns:
            Benutzer-Dict oder None
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent or not dozent.benutzer:
            return None
        
        return dozent.benutzer.to_dict()
    
    def hat_benutzer_account(
        self,
        dozent_id: int
    ) -> bool:
        """
        Prüft ob Dozent einen Benutzer-Account hat
        
        Args:
            dozent_id: Dozent ID
            
        Returns:
            bool: True wenn Account existiert
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent:
            return False
        
        return dozent.hat_benutzer_account
    
    def get_dozenten_ohne_account(self) -> List[Dozent]:
        """
        Holt alle aktiven Dozenten ohne Benutzer-Account
        
        Returns:
            Liste von Dozenten
        """
        return Dozent.query.filter(
            Dozent.aktiv == True,
            ~Dozent.id.in_(
                db.session.query(Benutzer.dozent_id).filter(
                    Benutzer.dozent_id.isnot(None)
                )
            )
        ).order_by(Dozent.nachname).all()
    
    # =========================================================================
    # STATISTICS
    # =========================================================================
    
    def get_statistik(self) -> Dict[str, Any]:
        """
        Gibt Dozenten-Statistiken zurück
        
        Returns:
            Dict mit Statistiken
        """
        return {
            'gesamt': self.count(),
            'aktiv': self.count(aktiv=True),
            'inaktiv': self.count(aktiv=False),
            'mit_benutzer_account': Benutzer.query.filter(
                Benutzer.dozent_id.isnot(None)
            ).count(),
            'ohne_benutzer_account': len(self.get_dozenten_ohne_account()),
        }
    
    def get_dozent_details(
        self,
        dozent_id: int
    ) -> Dict[str, Any]:
        """
        Holt vollständige Details eines Dozenten
        
        Args:
            dozent_id: Dozent ID
            
        Returns:
            Dict mit allen Details
        """
        dozent = self.get_by_id(dozent_id)
        if not dozent:
            return {}
        
        # Hole deduplizierte Module
        module_liste = self.get_module(dozent_id)
        
        return {
            'dozent': dozent.to_dict(),
            'module': {
                'gesamt': len(module_liste),  # Anzahl eindeutiger Module
                'verantwortlich': len(dozent.get_module_als_verantwortlicher()),
                'lehrperson': len(dozent.get_module_als_lehrperson()),
                'liste': module_liste
            },
            'benutzer': self.get_benutzer(dozent_id)
        }
    
    # =========================================================================
    # FILTERING
    # =========================================================================
    
    def filter_dozenten(
        self,
        fachbereich: Optional[str] = None,
        aktiv: Optional[bool] = True,
        mit_benutzer: Optional[bool] = None,
        suchbegriff: Optional[str] = None,
        include_platzhalter: bool = False
    ) -> List[Dozent]:
        """
        Filtert Dozenten mit verschiedenen Kriterien

        Args:
            fachbereich: Optional - Filter nach Fachbereich
            aktiv: Optional - Filter nach Status (default: True)
            mit_benutzer: Optional - Hat Benutzer-Account?
            suchbegriff: Optional - Suchtext
            include_platzhalter: Platzhalter-Dozenten mit einschließen

        Returns:
            Liste von gefilterten Dozenten
        """
        query = Dozent.query

        if aktiv is not None:
            query = query.filter_by(aktiv=aktiv)

        if not include_platzhalter:
            query = query.filter_by(ist_platzhalter=False)

        if fachbereich:
            query = query.filter_by(fachbereich=fachbereich)

        if mit_benutzer is not None:
            if mit_benutzer:
                query = query.filter(
                    Dozent.id.in_(
                        db.session.query(Benutzer.dozent_id).filter(
                            Benutzer.dozent_id.isnot(None)
                        )
                    )
                )
            else:
                query = query.filter(
                    ~Dozent.id.in_(
                        db.session.query(Benutzer.dozent_id).filter(
                            Benutzer.dozent_id.isnot(None)
                        )
                    )
                )

        if suchbegriff:
            pattern = f"%{suchbegriff}%"
            query = query.filter(
                db.or_(
                    Dozent.name_komplett.ilike(pattern),
                    Dozent.email.ilike(pattern)
                )
            )

        return query.order_by(Dozent.nachname).all()


# Singleton Instances
dozent_service = DozentService()
dozent_position_service = DozentPositionService()