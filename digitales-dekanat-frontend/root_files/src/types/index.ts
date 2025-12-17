// Re-export all types
export * from './auth.types';
export * from './modul.types';
export * from './planung.types';
export * from './semester.types';
export * from './deputat.types';

// Import and export specific types if needed
export type { User, LoginCredentials, LoginResponse } from './auth.types';
export type { Modul, ModulDetails, Lehrform, Dozent } from './modul.types';
export type { Semesterplanung, GeplantesModul, CreatePlanungData } from './planung.types';
export type { Semester, SemesterStatistik } from './semester.types';
export type {
  Deputatsabrechnung,
  DeputatsEinstellungen,
  DeputatStatus,
  DeputatSummen,
  DeputatsLehrtaetigkeit,
  DeputatsLehrexport,
  DeputatsVertretung,
  DeputatsErmaessigung,
  DeputatsBetreuung,
} from './deputat.types';