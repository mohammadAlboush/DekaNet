"""
Semester Service
================
Business Logic für Semester-Verwaltung.

Funktionen:
- Semester erstellen/bearbeiten/löschen
- Aktives Semester verwalten
- Planungsphase steuern
- Semester-Statistiken
"""

from typing import Optional, List, Dict, Any
from datetime import date, datetime
from sqlalchemy import func, case
from app.services.base_service import BaseService
from app.models import Semester, Semesterplanung
from app.extensions import db


class SemesterService(BaseService):
    """
    Semester Service
    
    Verwaltet Semester-Objekte und deren Status.
    """
    
    model = Semester
    
    # =========================================================================
    # SEMESTER MANAGEMENT
    # =========================================================================
    
    def create_semester(
        self,
        bezeichnung: str,
        kuerzel: str,
        start_datum: date,
        ende_datum: date,
        vorlesungsbeginn: Optional[date] = None,
        vorlesungsende: Optional[date] = None,
        ist_aktiv: bool = False,
        ist_planungsphase: bool = False
    ) -> Semester:
        """
        Erstellt ein neues Semester
        
        Args:
            bezeichnung: Vollständiger Name (z.B. "Wintersemester 2025/2026")
            kuerzel: Kurzes Kürzel (z.B. "WS2025")
            start_datum: Semesterbeginn
            ende_datum: Semesterende
            vorlesungsbeginn: Optional - Erster Tag der Vorlesungen
            vorlesungsende: Optional - Letzter Tag der Vorlesungen
            ist_aktiv: Soll Semester direkt aktiv sein?
            ist_planungsphase: Soll Planungsphase direkt offen sein?
            
        Returns:
            Semester: Neu erstelltes Semester
            
        Raises:
            ValueError: Bei ungültigen Daten
            
        Example:
            semester = semester_service.create_semester(
                bezeichnung='Wintersemester 2025/2026',
                kuerzel='WS2025',
                start_datum=date(2025, 10, 1),
                ende_datum=date(2026, 3, 31)
            )
        """
        # Validierung
        if start_datum >= ende_datum:
            raise ValueError("Start-Datum muss vor Ende-Datum liegen")
        
        if vorlesungsbeginn and vorlesungsende:
            if vorlesungsbeginn >= vorlesungsende:
                raise ValueError("Vorlesungsbeginn muss vor Vorlesungsende liegen")
        
        # Prüfe ob Kürzel bereits existiert
        if self.exists(kuerzel=kuerzel):
            raise ValueError(f"Semester mit Kürzel '{kuerzel}' existiert bereits")
        
        # Erstelle Semester
        semester = self.create(
            bezeichnung=bezeichnung,
            kuerzel=kuerzel,
            start_datum=start_datum,
            ende_datum=ende_datum,
            vorlesungsbeginn=vorlesungsbeginn,
            vorlesungsende=vorlesungsende,
            ist_aktiv=False,
            ist_planungsphase=False
        )
        
        # Aktivieren falls gewünscht
        if ist_aktiv:
            self.aktiviere_semester(semester.id, planungsphase=ist_planungsphase)
        
        return semester
    
    def update_semester(
        self,
        semester_id: int,
        **data
    ) -> Optional[Semester]:
        """
        Updated Semester-Daten
        
        Args:
            semester_id: Semester ID
            **data: Felder die geupdated werden sollen
            
        Returns:
            Geupdatetes Semester oder None
            
        Example:
            semester = semester_service.update_semester(
                1,
                vorlesungsbeginn=date(2025, 10, 15)
            )
        """
        semester = self.get_by_id(semester_id)
        if not semester:
            return None
        
        # Validierung
        if 'start_datum' in data and 'ende_datum' in data:
            if data['start_datum'] >= data['ende_datum']:
                raise ValueError("Start-Datum muss vor Ende-Datum liegen")
        
        return self.update(semester_id, **data)
    
    # =========================================================================
    # STATUS MANAGEMENT
    # =========================================================================
    
    def aktiviere_semester(
        self,
        semester_id: int,
        planungsphase: bool = True
    ) -> Semester:
        """
        Aktiviert ein Semester (deaktiviert alle anderen)
        
        Args:
            semester_id: ID des zu aktivierenden Semesters
            planungsphase: Soll Planungsphase auch geöffnet werden?
            
        Returns:
            Aktiviertes Semester
            
        Raises:
            ValueError: Wenn Semester nicht existiert
            
        Example:
            semester = semester_service.aktiviere_semester(1, planungsphase=True)
        """
        semester = self.get_by_id(semester_id)
        if not semester:
            raise ValueError(f"Semester {semester_id} nicht gefunden")
        
        # Deaktiviere alle anderen Semester
        Semester.query.update({
            'ist_aktiv': False,
            'ist_planungsphase': False
        })
        
        # Aktiviere dieses Semester
        semester.ist_aktiv = True
        semester.ist_planungsphase = planungsphase
        
        db.session.commit()
        return semester
    
    def deaktiviere_semester(self, semester_id: int) -> bool:
        """
        Deaktiviert ein Semester
        
        Args:
            semester_id: Semester ID
            
        Returns:
            bool: True wenn erfolgreich
        """
        semester = self.get_by_id(semester_id)
        if not semester:
            return False
        
        semester.ist_aktiv = False
        semester.ist_planungsphase = False
        db.session.commit()
        return True
    
    def oeffne_planungsphase(self, semester_id: int) -> Semester:
        """
        Öffnet Planungsphase für ein Semester
        
        Args:
            semester_id: Semester ID
            
        Returns:
            Semester mit geöffneter Planungsphase
            
        Raises:
            ValueError: Wenn Semester nicht aktiv ist
        """
        semester = self.get_by_id(semester_id)
        if not semester:
            raise ValueError(f"Semester {semester_id} nicht gefunden")
        
        if not semester.ist_aktiv:
            raise ValueError("Semester muss aktiv sein um Planungsphase zu öffnen")
        
        semester.ist_planungsphase = True
        db.session.commit()
        return semester
    
    def schliesse_planungsphase(self, semester_id: int) -> Semester:
        """
        Schließt Planungsphase für ein Semester
        
        Args:
            semester_id: Semester ID
            
        Returns:
            Semester mit geschlossener Planungsphase
        """
        semester = self.get_by_id(semester_id)
        if not semester:
            raise ValueError(f"Semester {semester_id} nicht gefunden")
        
        semester.ist_planungsphase = False
        db.session.commit()
        return semester
    
    # =========================================================================
    # QUERIES
    # =========================================================================
    
    def get_aktives_semester(self) -> Optional[Semester]:
        """
        Gibt das aktuell aktive Semester zurück
        
        Returns:
            Semester oder None
            
        Example:
            aktives = semester_service.get_aktives_semester()
        """
        return self.get_first(ist_aktiv=True)
    
    def get_planungssemester(self) -> Optional[Semester]:
        """
        Gibt das Semester zurück für das gerade geplant werden kann.
        Priorisiert Semester mit einer aktiven Planungsphase.

        Returns:
            Semester oder None

        Example:
            planungs_sem = semester_service.get_planungssemester()
        """
        from app.models.planungsphase import Planungsphase

        # Priorität 1: Semester mit aktiver Planungsphase
        semester_mit_aktiver_phase = Semester.query.join(
            Planungsphase, Planungsphase.semester_id == Semester.id
        ).filter(
            Planungsphase.ist_aktiv == True
        ).first()

        if semester_mit_aktiver_phase:
            return semester_mit_aktiver_phase

        # Fallback: Semester mit ist_planungsphase=True
        return self.get_first(ist_planungsphase=True)
    
    def get_by_kuerzel(self, kuerzel: str) -> Optional[Semester]:
        """
        Findet Semester anhand Kürzel

        Args:
            kuerzel: Semester-Kürzel (z.B. "WS2025")

        Returns:
            Semester oder None
        """
        return self.get_first(kuerzel=kuerzel)

    def get_or_create_semester_for_phase(self, semester_typ: str, jahr: int) -> Semester:
        """
        Erstellt oder findet Semester basierend auf Typ und Jahr.

        Args:
            semester_typ: 'wintersemester' oder 'sommersemester'
            jahr: Jahr (z.B. 2025)

        Returns:
            Semester: Existierendes oder neu erstelltes Semester

        Example:
            semester = semester_service.get_or_create_semester_for_phase('wintersemester', 2025)
        """
        kuerzel = f"{'WS' if semester_typ == 'wintersemester' else 'SS'}{jahr}"

        existing = self.get_by_kuerzel(kuerzel)
        if existing:
            return existing

        # Standard-Datumsbereiche für Deutschland
        if semester_typ == 'wintersemester':
            bezeichnung = f"Wintersemester {jahr}/{jahr+1}"
            start_datum = date(jahr, 10, 1)
            ende_datum = date(jahr+1, 3, 31)
        else:
            bezeichnung = f"Sommersemester {jahr}"
            start_datum = date(jahr, 4, 1)
            ende_datum = date(jahr, 9, 30)

        return self.create_semester(
            bezeichnung=bezeichnung,
            kuerzel=kuerzel,
            start_datum=start_datum,
            ende_datum=ende_datum
        )
    
    def get_vergangene(self) -> List[Semester]:
        """
        Holt alle vergangenen Semester
        
        Returns:
            Liste von Semestern
        """
        return Semester.query.filter(
            Semester.ende_datum < date.today()
        ).order_by(Semester.start_datum.desc()).all()
    
    def get_zukuenftige(self) -> List[Semester]:
        """
        Holt alle zukünftigen Semester
        
        Returns:
            Liste von Semestern
        """
        return Semester.query.filter(
            Semester.start_datum > date.today()
        ).order_by(Semester.start_datum.asc()).all()
    
    # NOTE: Die folgenden Methoden wurden entfernt da die automatische Semester-Erkennung
    # nicht mehr verwendet wird. Stattdessen wählt der Dekan Semester-Typ und Jahr manuell.
    # Entfernt: get_laufende(), get_semester_for_date(), get_aktuelles_laufendes_semester(), auto_semester_vorschlag()
    
    # =========================================================================
    # STATISTICS
    # =========================================================================
    
    def get_statistik(self, semester_id: int) -> Dict[str, Any]:
        """
        Gibt Statistiken für ein Semester zurück
        
        Args:
            semester_id: Semester ID
            
        Returns:
            Dict mit Statistiken:
                - gesamt_planungen: Anzahl aller Planungen
                - entwurf: Anzahl Entwürfe
                - eingereicht: Anzahl eingereichte Planungen
                - freigegeben: Anzahl freigegebene Planungen
                - abgelehnt: Anzahl abgelehnte Planungen
                
        Example:
            stats = semester_service.get_statistik(1)
            print(f"Freigegeben: {stats['freigegeben']}")
        """
        semester = self.get_by_id(semester_id)
        if not semester:
            return {}
        
        return {
            'semester': semester.to_dict(),
            'statistik': {
                'gesamt': semester.semesterplanungen.count(),
                'entwurf': semester.anzahl_entwurf(),
                'eingereicht': semester.anzahl_eingereicht(),
                'freigegeben': semester.anzahl_freigegeben(),
                'abgelehnt': semester.anzahl_planungen('abgelehnt'),
            },
            'planungen_abgeschlossen': semester.planungen_abgeschlossen
        }
    
    def get_alle_mit_statistik(self) -> List[Dict[str, Any]]:
        """
        Holt alle Semester mit Statistiken - OPTIMIERT mit einer Query

        Returns:
            Liste von Dicts mit Semester und Statistiken
        """
        # Hole alle Semester
        semester_liste = self.get_all()

        if not semester_liste:
            return []

        # Berechne alle Statistiken in EINER Query mit SQL-Aggregation
        stats_query = db.session.query(
            Semesterplanung.semester_id,
            func.count(Semesterplanung.id).label('gesamt'),
            func.sum(case((Semesterplanung.status == 'entwurf', 1), else_=0)).label('entwurf'),
            func.sum(case((Semesterplanung.status == 'eingereicht', 1), else_=0)).label('eingereicht'),
            func.sum(case((Semesterplanung.status == 'freigegeben', 1), else_=0)).label('freigegeben'),
            func.sum(case((Semesterplanung.status == 'abgelehnt', 1), else_=0)).label('abgelehnt')
        ).group_by(Semesterplanung.semester_id).all()

        # Erstelle Mapping für schnellen Zugriff
        stats_map = {
            row.semester_id: {
                'gesamt': row.gesamt or 0,
                'entwurf': row.entwurf or 0,
                'eingereicht': row.eingereicht or 0,
                'freigegeben': row.freigegeben or 0,
                'abgelehnt': row.abgelehnt or 0
            }
            for row in stats_query
        }

        result = []
        for semester in semester_liste:
            stats = stats_map.get(semester.id, {
                'gesamt': 0, 'entwurf': 0, 'eingereicht': 0,
                'freigegeben': 0, 'abgelehnt': 0
            })

            # Berechne planungen_abgeschlossen
            planungen_abgeschlossen = (
                stats['gesamt'] > 0 and stats['freigegeben'] == stats['gesamt']
            )

            result.append({
                'semester': {
                    'id': semester.id,
                    'bezeichnung': semester.bezeichnung,
                    'kuerzel': semester.kuerzel,
                    'start_datum': semester.start_datum.isoformat(),
                    'ende_datum': semester.ende_datum.isoformat(),
                    'vorlesungsbeginn': semester.vorlesungsbeginn.isoformat() if semester.vorlesungsbeginn else None,
                    'vorlesungsende': semester.vorlesungsende.isoformat() if semester.vorlesungsende else None,
                    'ist_aktiv': semester.ist_aktiv,
                    'ist_planungsphase': semester.ist_planungsphase,
                    'ist_wintersemester': semester.ist_wintersemester,
                    'ist_sommersemester': semester.ist_sommersemester,
                    'ist_laufend': semester.ist_laufend,
                    'dauer_tage': semester.dauer_tage,
                },
                'statistik': stats,
                'planungen_abgeschlossen': planungen_abgeschlossen
            })

        return result
    
    # =========================================================================
    # VALIDATION
    # =========================================================================
    
    def kann_geloescht_werden(self, semester_id: int) -> tuple[bool, str]:
        """
        Prüft ob Semester gelöscht werden kann
        
        Args:
            semester_id: Semester ID
            
        Returns:
            tuple: (kann_geloescht, grund)
            
        Example:
            kann, grund = semester_service.kann_geloescht_werden(1)
            if not kann:
                print(f"Kann nicht gelöscht werden: {grund}")
        """
        semester = self.get_by_id(semester_id)
        if not semester:
            return False, "Semester nicht gefunden"
        
        # Prüfe ob Planungen existieren
        anzahl_planungen = semester.semesterplanungen.count()
        if anzahl_planungen > 0:
            return False, f"Semester hat {anzahl_planungen} Planungen"
        
        # Prüfe ob aktiv
        if semester.ist_aktiv:
            return False, "Aktives Semester kann nicht gelöscht werden"
        
        return True, ""
    
    def delete_semester(self, semester_id: int, force: bool = False) -> bool:
        """
        Löscht ein Semester
        
        Args:
            semester_id: Semester ID
            force: Bei True werden auch Semester mit Planungen gelöscht
            
        Returns:
            bool: True wenn erfolgreich
            
        Raises:
            ValueError: Wenn Semester nicht gelöscht werden kann
        """
        if not force:
            kann, grund = self.kann_geloescht_werden(semester_id)
            if not kann:
                raise ValueError(f"Semester kann nicht gelöscht werden: {grund}")
        
        return self.delete(semester_id)


# Singleton Instance
semester_service = SemesterService()