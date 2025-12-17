export interface Semester {
  id: number;
  bezeichnung: string;
  kuerzel: string;
  start_datum: string;
  ende_datum: string;
  vorlesungsbeginn?: string;
  vorlesungsende?: string;
  ist_aktiv: boolean;
  ist_planungsphase: boolean;
  ist_wintersemester: boolean;
  ist_sommersemester: boolean;
  ist_laufend: boolean;
  dauer_tage: number;
  statistik: {
    gesamt: number;
    entwurf: number;
    eingereicht: number;
    freigegeben: number;
  };
}

export interface SemesterStatistik {
  semester: Semester;
  statistik: {
    gesamt: number;
    entwurf: number;
    eingereicht: number;
    freigegeben: number;
    abgelehnt: number;
  };
  planungen_abgeschlossen: boolean;
}