"""
SWS Calculator
==============
Berechnet Semesterwochenstunden (SWS) fÃ¼r Module und Planungen.

Der Calculator nutzt die bestehende modul_lehrform Tabelle um:
- SWS pro Lehrform zu holen (aus DB)
- Mit Multiplikatoren zu multiplizieren
- Gesamt-SWS zu berechnen
"""

from typing import Dict, List, Optional, Any
from app.models import Modul, ModulLehrform, GeplantesModul, Lehrform
from app.extensions import db


class SWSCalculator:
    """
    SWS Calculator
    
    Berechnet Semesterwochenstunden basierend auf:
    - Modul-Lehrformen (aus DB)
    - Multiplikatoren (Anzahl Gruppen)
    """
    
    # Mapping: Lehrform-KÃ¼rzel â†’ GeplantesModul-Feld
    LEHRFORM_MAPPING = {
        'V': 'anzahl_vorlesungen',    # Vorlesung
        'Ü': 'anzahl_uebungen',        # Übung
        'P': 'anzahl_praktika',        # Praktikum
        'S': 'anzahl_seminare',        # Seminar
    }
    
    # =========================================================================
    # MODUL SWS CALCULATION
    # =========================================================================
    
    def get_modul_basis_sws(
        self,
        modul_id: int,
        po_id: int
    ) -> Dict[str, float]:
        """
        Holt Basis-SWS eines Moduls aus der DB
        
        Args:
            modul_id: Modul ID
            po_id: PrÃ¼fungsordnung ID
            
        Returns:
            Dict: {lehrform_kuerzel: sws}
            
        Example:
            >>> calculator.get_modul_basis_sws(1, 1)
            {'V': 2.0, 'Ü': 2.0, 'P': 2.0}
        """
        # Hole alle Lehrformen fÃ¼r dieses Modul
        lehrformen = ModulLehrform.query.filter_by(
            modul_id=modul_id,
            po_id=po_id
        ).all()
        
        # Baue Dictionary
        sws_dict = {}
        for lf in lehrformen:
            kuerzel = lf.lehrform.kuerzel
            sws_dict[kuerzel] = lf.sws
        
        return sws_dict
    
    def get_modul_gesamt_sws(
        self,
        modul_id: int,
        po_id: int
    ) -> float:
        """
        Berechnet Gesamt-SWS eines Moduls (ohne Multiplikatoren)
        
        Args:
            modul_id: Modul ID
            po_id: PrÃ¼fungsordnung ID
            
        Returns:
            float: Gesamt-SWS
            
        Example:
            >>> calculator.get_modul_gesamt_sws(1, 1)
            6.0  # 2V + 2Ü + 2P
        """
        sws_dict = self.get_modul_basis_sws(modul_id, po_id)
        return sum(sws_dict.values())
    
    # =========================================================================
    # GEPLANTES MODUL SWS CALCULATION
    # =========================================================================
    
    def berechne_geplantes_modul_sws(
        self,
        geplantes_modul: GeplantesModul
    ) -> Dict[str, float]:
        """
        Berechnet SWS fÃ¼r ein geplantes Modul mit Multiplikatoren
        
        Args:
            geplantes_modul: GeplantesModul Objekt
            
        Returns:
            Dict mit berechneten SWS:
                - sws_vorlesung: float
                - sws_uebung: float
                - sws_praktikum: float
                - sws_seminar: float
                - sws_gesamt: float
                
        Example:
            >>> geplantes = GeplantesModul.query.get(1)
            >>> calculator.berechne_geplantes_modul_sws(geplantes)
            {
                'sws_vorlesung': 4.0,  # 2 * 2V
                'sws_uebung': 4.0,     # 2 * 2Ü
                'sws_praktikum': 2.0,  # 1 * 2P
                'sws_seminar': 0.0,
                'sws_gesamt': 10.0
            }
        """
        # Hole Basis-SWS aus DB
        basis_sws = self.get_modul_basis_sws(
            geplantes_modul.modul_id,
            geplantes_modul.po_id
        )
        
        # Berechne SWS mit Multiplikatoren
        sws_vorlesung = geplantes_modul.anzahl_vorlesungen * basis_sws.get('V', 0.0)
        sws_uebung = geplantes_modul.anzahl_uebungen * basis_sws.get('Ü', 0.0)
        sws_praktikum = geplantes_modul.anzahl_praktika * basis_sws.get('P', 0.0)
        sws_seminar = geplantes_modul.anzahl_seminare * basis_sws.get('S', 0.0)
        
        sws_gesamt = sws_vorlesung + sws_uebung + sws_praktikum + sws_seminar
        
        return {
            'sws_vorlesung': sws_vorlesung,
            'sws_uebung': sws_uebung,
            'sws_praktikum': sws_praktikum,
            'sws_seminar': sws_seminar,
            'sws_gesamt': sws_gesamt
        }
    
    def update_geplantes_modul_sws(
        self,
        geplantes_modul: GeplantesModul
    ) -> GeplantesModul:
        """
        Berechnet und speichert SWS fÃ¼r ein geplantes Modul
        
        Args:
            geplantes_modul: GeplantesModul Objekt
            
        Returns:
            GeplantesModul mit aktualisierten SWS-Werten
            
        Example:
            >>> geplantes = GeplantesModul.query.get(1)
            >>> calculator.update_geplantes_modul_sws(geplantes)
        """
        sws = self.berechne_geplantes_modul_sws(geplantes_modul)
        
        # Update Felder
        geplantes_modul.sws_vorlesung = sws['sws_vorlesung']
        geplantes_modul.sws_uebung = sws['sws_uebung']
        geplantes_modul.sws_praktikum = sws['sws_praktikum']
        geplantes_modul.sws_seminar = sws['sws_seminar']
        geplantes_modul.sws_gesamt = sws['sws_gesamt']
        
        db.session.commit()
        
        return geplantes_modul
    
    # =========================================================================
    # SEMESTERPLANUNG SWS CALCULATION
    # =========================================================================
    
    def berechne_planung_gesamt_sws(
        self,
        semesterplanung_id: int
    ) -> float:
        """
        Berechnet Gesamt-SWS einer Semesterplanung
        
        Args:
            semesterplanung_id: Semesterplanung ID
            
        Returns:
            float: Gesamt-SWS
            
        Example:
            >>> calculator.berechne_planung_gesamt_sws(1)
            24.5
        """
        from app.models import Semesterplanung
        
        planung = Semesterplanung.query.get(semesterplanung_id)
        if not planung:
            return 0.0
        
        total = 0.0
        for geplantes_modul in planung.geplante_module.all():
            total += geplantes_modul.sws_gesamt or 0.0
        
        return total
    
    def update_planung_gesamt_sws(
        self,
        semesterplanung_id: int
    ) -> float:
        """
        Berechnet und speichert Gesamt-SWS einer Semesterplanung
        
        Args:
            semesterplanung_id: Semesterplanung ID
            
        Returns:
            float: Gesamt-SWS
        """
        from app.models import Semesterplanung
        
        planung = Semesterplanung.query.get(semesterplanung_id)
        if not planung:
            return 0.0
        
        total = self.berechne_planung_gesamt_sws(semesterplanung_id)
        planung.gesamt_sws = total
        db.session.commit()
        
        return total
    
    # =========================================================================
    # BULK OPERATIONS
    # =========================================================================
    
    def update_alle_geplanten_module(
        self,
        semesterplanung_id: int
    ) -> List[GeplantesModul]:
        """
        Updated SWS fÃ¼r alle geplanten Module einer Planung
        
        Args:
            semesterplanung_id: Semesterplanung ID
            
        Returns:
            Liste von aktualisierten GeplantesModul Objekten
        """
        from app.models import Semesterplanung
        
        planung = Semesterplanung.query.get(semesterplanung_id)
        if not planung:
            return []
        
        updated = []
        for geplantes_modul in planung.geplante_module.all():
            self.update_geplantes_modul_sws(geplantes_modul)
            updated.append(geplantes_modul)
        
        # Update Planung Gesamt-SWS
        self.update_planung_gesamt_sws(semesterplanung_id)
        
        return updated
    
    # =========================================================================
    # VALIDATION & HELPERS
    # =========================================================================
    
    def validate_multiplikatoren(
        self,
        modul_id: int,
        po_id: int,
        anzahl_vorlesungen: int = 0,
        anzahl_uebungen: int = 0,
        anzahl_praktika: int = 0,
        anzahl_seminare: int = 0
    ) -> tuple[bool, str]:
        """
        Validiert ob Multiplikatoren fÃ¼r ein Modul sinnvoll sind
        
        Args:
            modul_id: Modul ID
            po_id: PrÃ¼fungsordnung ID
            anzahl_vorlesungen: Multiplikator Vorlesungen
            anzahl_uebungen: Multiplikator Übungen
            anzahl_praktika: Multiplikator Praktika
            anzahl_seminare: Multiplikator Seminare
            
        Returns:
            tuple: (is_valid, message)
            
        Example:
            >>> calculator.validate_multiplikatoren(1, 1, anzahl_vorlesungen=2)
            (True, "")
        """
        # Hole Basis-SWS
        basis_sws = self.get_modul_basis_sws(modul_id, po_id)
        
        # PrÃ¼fe ob Multiplikatoren passen
        if anzahl_vorlesungen > 0 and 'V' not in basis_sws:
            return False, "Modul hat keine Vorlesung"
        
        if anzahl_uebungen > 0 and 'Ü' not in basis_sws:
            return False, "Modul hat keine Übung"
        
        if anzahl_praktika > 0 and 'P' not in basis_sws:
            return False, "Modul hat kein Praktikum"
        
        if anzahl_seminare > 0 and 'S' not in basis_sws:
            return False, "Modul hat kein Seminar"
        
        # PrÃ¼fe ob mindestens ein Multiplikator > 0
        if sum([anzahl_vorlesungen, anzahl_uebungen, anzahl_praktika, anzahl_seminare]) == 0:
            return False, "Mindestens ein Multiplikator muss > 0 sein"
        
        return True, ""
    
    def get_lehrformen_text(
        self,
        anzahl_vorlesungen: int = 0,
        anzahl_uebungen: int = 0,
        anzahl_praktika: int = 0,
        anzahl_seminare: int = 0
    ) -> str:
        """
        Generiert Text-ReprÃ¤sentation der Lehrformen
        
        Args:
            anzahl_vorlesungen: Multiplikator Vorlesungen
            anzahl_uebungen: Multiplikator Übungen
            anzahl_praktika: Multiplikator Praktika
            anzahl_seminare: Multiplikator Seminare
            
        Returns:
            str: Formatierte Lehrformen (z.B. "2V + 1Ü + 1P")
            
        Example:
            >>> calculator.get_lehrformen_text(2, 1, 1, 0)
            "2V + 1Ü + 1P"
        """
        parts = []
        
        if anzahl_vorlesungen > 0:
            parts.append(f"{anzahl_vorlesungen}V")
        if anzahl_uebungen > 0:
            parts.append(f"{anzahl_uebungen}Ü")
        if anzahl_praktika > 0:
            parts.append(f"{anzahl_praktika}P")
        if anzahl_seminare > 0:
            parts.append(f"{anzahl_seminare}S")
        
        return " + ".join(parts) if parts else "Keine"
    
    def get_verfuegbare_lehrformen(
        self,
        modul_id: int,
        po_id: int
    ) -> List[Dict[str, Any]]:
        """
        Gibt verfÃ¼gbare Lehrformen fÃ¼r ein Modul zurÃ¼ck
        
        Args:
            modul_id: Modul ID
            po_id: PrÃ¼fungsordnung ID
            
        Returns:
            Liste von Dicts mit Lehrform-Infos:
                - kuerzel: str
                - bezeichnung: str
                - sws: float
                
        Example:
            >>> calculator.get_verfuegbare_lehrformen(1, 1)
            [
                {'kuerzel': 'V', 'bezeichnung': 'Vorlesung', 'sws': 2.0},
                {'kuerzel': 'Ü', 'bezeichnung': 'Übung', 'sws': 2.0}
            ]
        """
        lehrformen = ModulLehrform.query.filter_by(
            modul_id=modul_id,
            po_id=po_id
        ).all()
        
        result = []
        for lf in lehrformen:
            result.append({
                'kuerzel': lf.lehrform.kuerzel,
                'bezeichnung': lf.lehrform.bezeichnung,
                'sws': lf.sws
            })
        
        return result


# Singleton Instance
sws_calculator = SWSCalculator()