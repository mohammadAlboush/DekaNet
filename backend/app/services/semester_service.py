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
from app.services.base_service import BaseService
from app.models import Semester
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
        Gibt das Semester zurück für das gerade geplant werden kann
        
        Returns:
            Semester oder None
            
        Example:
            planungs_sem = semester_service.get_planungssemester()
        """
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
    
    def get_laufende(self) -> List[Semester]:
        """
        Holt alle aktuell laufenden Semester
        
        Returns:
            Liste von Semestern
        """
        heute = date.today()
        return Semester.query.filter(
            Semester.start_datum <= heute,
            Semester.ende_datum >= heute
        ).all()
    
    def get_semester_for_date(self, datum: date) -> Optional[Semester]:
        """
        Findet Semester für ein bestimmtes Datum

        Args:
            datum: Datum

        Returns:
            Semester oder None

        Example:
            semester = semester_service.get_semester_for_date(date(2025, 11, 1))
        """
        return Semester.query.filter(
            Semester.start_datum <= datum,
            Semester.ende_datum >= datum
        ).first()

    def get_aktuelles_laufendes_semester(self) -> Optional[Semester]:
        """
        Gibt das Semester zurück das heute läuft

        Returns:
            Semester oder None

        Example:
            laufendes = semester_service.get_aktuelles_laufendes_semester()
        """
        return self.get_semester_for_date(date.today())

    def auto_semester_vorschlag(self) -> Dict[str, Any]:
        """
        Schlägt automatisch das passende Semester vor basierend auf heutigem Datum

        Returns:
            Dict mit:
                - vorschlag: Vorgeschlagenes Semester (kann None sein)
                - aktives: Aktuell aktiviertes Semester (kann None sein)
                - laufendes: Heute laufendes Semester (kann None sein)
                - ist_korrekt: bool - Stimmen aktives und laufendes Semester überein?
                - empfehlung: str - Empfehlungstext

        Example:
            result = semester_service.auto_semester_vorschlag()
            if not result['ist_korrekt']:
                print(result['empfehlung'])
        """
        aktives = self.get_aktives_semester()
        laufendes = self.get_aktuelles_laufendes_semester()

        # Prüfe ob ein Wechsel nötig ist
        ist_korrekt = False
        empfehlung = ""
        vorschlag = None

        if not aktives and not laufendes:
            # Kein Semester vorhanden
            empfehlung = "Kein Semester vorhanden. Bitte erstellen Sie zunächst Semester."
        elif not aktives and laufendes:
            # Laufendes Semester existiert aber ist nicht aktiv
            vorschlag = laufendes
            empfehlung = f"Empfehlung: Aktivieren Sie '{laufendes.bezeichnung}', da dieses Semester aktuell läuft."
        elif aktives and not laufendes:
            # Aktives Semester aber kein laufendes gefunden
            empfehlung = f"Warnung: '{aktives.bezeichnung}' ist aktiv, aber es läuft aktuell kein Semester laut Datum."
        elif aktives.id == laufendes.id:
            # Perfekt - aktives Semester stimmt mit laufendem überein
            ist_korrekt = True
            empfehlung = f"Alles korrekt: '{aktives.bezeichnung}' ist aktiv und läuft aktuell."
        else:
            # Aktives und laufendes Semester unterschiedlich
            vorschlag = laufendes
            empfehlung = f"Semesterwechsel empfohlen: '{laufendes.bezeichnung}' läuft aktuell, aber '{aktives.bezeichnung}' ist noch aktiv."

        return {
            'vorschlag': vorschlag.to_dict() if vorschlag else None,
            'aktives': aktives.to_dict() if aktives else None,
            'laufendes': laufendes.to_dict() if laufendes else None,
            'ist_korrekt': ist_korrekt,
            'empfehlung': empfehlung,
            'datum_heute': date.today().isoformat()
        }
    
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
        Holt alle Semester mit Statistiken
        
        Returns:
            Liste von Dicts mit Semester und Statistiken
        """
        semester_liste = self.get_all()
        return [self.get_statistik(s.id) for s in semester_liste]
    
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