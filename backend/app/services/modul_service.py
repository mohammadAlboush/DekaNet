"""
Modul Service
=============
Business Logic für Modul-Verwaltung.

Funktionen:
- Module suchen/filtern
- Modul-Details holen
- Dozenten-Zuordnung
- Lehrformen-Verwaltung
"""

from typing import Optional, List, Dict, Any
from sqlalchemy.orm import joinedload
from app.services.base_service import BaseService
from app.models import Modul, ModulDozent, ModulLehrform, Pruefungsordnung
from app.extensions import db


class ModulService(BaseService):
    """
    Modul Service
    
    Verwaltet Module und deren Verknüpfungen.
    """
    
    model = Modul
    
    # =========================================================================
    # MODUL QUERIES
    # =========================================================================
    
    def get_by_kuerzel(
        self,
        kuerzel: str,
        po_id: Optional[int] = None
    ) -> Optional[Modul]:
        """
        Findet Modul anhand Kürzel
        
        Args:
            kuerzel: Modul-Kürzel (z.B. "SCD")
            po_id: Optional - Prüfungsordnung ID
            
        Returns:
            Modul oder None
        """
        if po_id:
            return self.get_first(kuerzel=kuerzel, po_id=po_id)
        return self.get_first(kuerzel=kuerzel)
    
    def search(
        self,
        suchbegriff: str,
        po_id: Optional[int] = None
    ) -> List[Modul]:
        """
        Sucht Module anhand Bezeichnung oder Kürzel
        
        Args:
            suchbegriff: Suchtext
            po_id: Optional - Filter nach PO
            
        Returns:
            Liste von gefundenen Modulen
            
        Example:
            >>> module = modul_service.search('Programmieren')
        """
        pattern = f"%{suchbegriff}%"
        query = Modul.query.filter(
            db.or_(
                Modul.kuerzel.ilike(pattern),
                Modul.bezeichnung_de.ilike(pattern),
                Modul.bezeichnung_en.ilike(pattern)
            )
        )
        
        if po_id:
            query = query.filter_by(po_id=po_id)
        
        return query.all()
    
    def get_by_po(
        self,
        po_id: int
    ) -> List[Modul]:
        """
        Holt alle Module einer Prüfungsordnung
        
        Args:
            po_id: Prüfungsordnung ID
            
        Returns:
            Liste von Modulen
        """
        return self.get_all(po_id=po_id)
    
    def get_by_turnus(
        self,
        turnus: str,
        po_id: Optional[int] = None
    ) -> List[Modul]:
        """
        Holt Module nach Turnus
        
        Args:
            turnus: "Wintersemester", "Sommersemester", "Jedes Semester"
            po_id: Optional - Filter nach PO
            
        Returns:
            Liste von Modulen
        """
        if po_id:
            return self.get_all(turnus=turnus, po_id=po_id)
        return self.get_all(turnus=turnus)
    
    # =========================================================================
    # MODUL DETAILS
    # =========================================================================
    
    def get_with_details(
        self,
        modul_id: int
    ) -> Dict[str, Any]:
        """
        Holt Modul mit allen Details (optimiert gegen N+1 Queries)

        Args:
            modul_id: Modul ID

        Returns:
            Dict mit Modul und allen Details
        """
        # Optimized query with eager loading to prevent N+1 queries
        modul = db.session.query(Modul)\
            .options(
                joinedload(Modul.lehrformen),
                joinedload(Modul.lernergebnisse),
                joinedload(Modul.pruefung),
                joinedload(Modul.voraussetzungen),
                joinedload(Modul.arbeitsaufwand)
            )\
            .filter_by(id=modul_id)\
            .first()

        if not modul:
            return {}

        return {
            'modul': modul.to_dict(),
            'lehrformen': [lf.to_dict() for lf in modul.lehrformen],
            'dozenten': {
                'verantwortliche': [d.to_dict() for d in modul.get_verantwortliche()],
                'lehrpersonen': [d.to_dict() for d in modul.get_lehrpersonen()]
            },
            'studiengaenge': [sg.to_dict() for sg in modul.get_studiengaenge()],
            'lernergebnisse': modul.lernergebnisse.to_dict() if modul.lernergebnisse else None,
            'pruefung': modul.pruefung.to_dict() if modul.pruefung else None,
            'voraussetzungen': modul.voraussetzungen.to_dict() if modul.voraussetzungen else None,
            'arbeitsaufwand': modul.arbeitsaufwand.to_dict() if modul.arbeitsaufwand else None
        }
    
    def get_sws_gesamt(
        self,
        modul_id: int
    ) -> float:
        """
        Berechnet Gesamt-SWS eines Moduls
        
        Args:
            modul_id: Modul ID
            
        Returns:
            float: Gesamt-SWS
        """
        modul = self.get_by_id(modul_id)
        if not modul:
            return 0.0
        
        return modul.get_sws_gesamt()
    
    # =========================================================================
    # DOZENTEN MANAGEMENT
    # =========================================================================
    
    def get_dozenten(
        self,
        modul_id: int,
        rolle: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Holt Dozenten eines Moduls
        
        Args:
            modul_id: Modul ID
            rolle: Optional - Filter nach Rolle ('verantwortlicher', 'lehrperson')
            
        Returns:
            Liste von Dozenten-Dicts
        """
        modul = self.get_by_id(modul_id)
        if not modul:
            return []
        
        if rolle:
            if rolle == 'verantwortlicher':
                return [d.to_dict() for d in modul.get_verantwortliche()]
            elif rolle == 'lehrperson':
                return [d.to_dict() for d in modul.get_lehrpersonen()]
        
        return [d.to_dict() for d in modul.get_dozenten()]
    
    def get_verantwortliche(
        self,
        modul_id: int
    ) -> List[Dict[str, Any]]:
        """
        Holt verantwortliche Dozenten
        
        Args:
            modul_id: Modul ID
            
        Returns:
            Liste von Dozenten
        """
        return self.get_dozenten(modul_id, rolle='verantwortlicher')
    
    def get_lehrpersonen(
        self,
        modul_id: int
    ) -> List[Dict[str, Any]]:
        """
        Holt Lehrpersonen
        
        Args:
            modul_id: Modul ID
            
        Returns:
            Liste von Dozenten
        """
        return self.get_dozenten(modul_id, rolle='lehrperson')
    
    # =========================================================================
    # LEHRFORMEN
    # =========================================================================
    
    def get_lehrformen(
        self,
        modul_id: int
    ) -> List[Dict[str, Any]]:
        """
        Holt Lehrformen eines Moduls
        
        Args:
            modul_id: Modul ID
            
        Returns:
            Liste von Lehrformen mit SWS
        """
        # Optimized query with eager loading to prevent N+1 query
        modul = db.session.query(Modul)\
            .options(joinedload(Modul.lehrformen))\
            .filter_by(id=modul_id)\
            .first()

        if not modul:
            return []

        return [lf.to_dict() for lf in modul.lehrformen]
    
    def get_lehrform_sws(
        self,
        modul_id: int,
        lehrform_kuerzel: str
    ) -> Optional[float]:
        """
        Holt SWS für eine bestimmte Lehrform
        
        Args:
            modul_id: Modul ID
            lehrform_kuerzel: Lehrform-Kürzel (z.B. 'V', 'Ü')
            
        Returns:
            float: SWS oder None
        """
        # Optimized query with eager loading to prevent N+1 query
        modul = db.session.query(Modul)\
            .options(joinedload(Modul.lehrformen))\
            .filter_by(id=modul_id)\
            .first()

        if not modul:
            return None

        for lf in modul.lehrformen:
            if lf.lehrform.kuerzel == lehrform_kuerzel:
                return lf.sws
        
        return None
    
    # =========================================================================
    # STATISTICS
    # =========================================================================
    
    def get_statistik(
        self,
        po_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Gibt Modul-Statistiken zurück
        
        Args:
            po_id: Optional - Nur für diese PO
            
        Returns:
            Dict mit Statistiken
        """
        filters = {'po_id': po_id} if po_id else {}
        
        return {
            'gesamt': self.count(**filters),
            'mit_vorlesung': self._count_with_lehrform('V', po_id),
            'mit_uebung': self._count_with_lehrform('Ü', po_id),
            'mit_praktikum': self._count_with_lehrform('P', po_id),
            'wintersemester': self.count(turnus='Wintersemester', **filters),
            'sommersemester': self.count(turnus='Sommersemester', **filters),
            'jedes_semester': self.count(turnus='Jedes Semester', **filters),
        }
    
    def _count_with_lehrform(
        self,
        lehrform_kuerzel: str,
        po_id: Optional[int] = None
    ) -> int:
        """Helper: Zählt Module mit bestimmter Lehrform"""
        from app.models import Lehrform
        
        lehrform = Lehrform.query.filter_by(kuerzel=lehrform_kuerzel).first()
        if not lehrform:
            return 0
        
        query = ModulLehrform.query.filter_by(lehrform_id=lehrform.id)
        if po_id:
            query = query.filter_by(po_id=po_id)
        
        return query.distinct(ModulLehrform.modul_id).count()
    
    # =========================================================================
    # FILTERING
    # =========================================================================
    
    def filter_module(
        self,
        po_id: Optional[int] = None,
        turnus: Optional[str] = None,
        min_leistungspunkte: Optional[int] = None,
        max_leistungspunkte: Optional[int] = None,
        suchbegriff: Optional[str] = None
    ) -> List[Modul]:
        """
        Filtert Module mit verschiedenen Kriterien
        
        Args:
            po_id: Optional - Prüfungsordnung
            turnus: Optional - Turnus
            min_leistungspunkte: Optional - Minimum LP
            max_leistungspunkte: Optional - Maximum LP
            suchbegriff: Optional - Suchtext
            
        Returns:
            Liste von gefilterten Modulen
        """
        query = Modul.query
        
        if po_id:
            query = query.filter_by(po_id=po_id)
        
        if turnus:
            query = query.filter_by(turnus=turnus)
        
        if min_leistungspunkte:
            query = query.filter(Modul.leistungspunkte >= min_leistungspunkte)
        
        if max_leistungspunkte:
            query = query.filter(Modul.leistungspunkte <= max_leistungspunkte)
        
        if suchbegriff:
            pattern = f"%{suchbegriff}%"
            query = query.filter(
                db.or_(
                    Modul.kuerzel.ilike(pattern),
                    Modul.bezeichnung_de.ilike(pattern)
                )
            )
        
        return query.all()


# Singleton Instance
modul_service = ModulService()