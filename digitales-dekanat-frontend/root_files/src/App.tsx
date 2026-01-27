import React, { useEffect, Suspense } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { LocalizationProvider } from '@mui/x-date-pickers';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { de } from 'date-fns/locale';
import { CircularProgress, Box } from '@mui/material';

// Theme
import theme from './theme/theme';

// Components (nicht lazy - werden immer gebraucht)
import Layout from './components/common/Layout';
import ProtectedRoute from './components/auth/ProtectedRoute';
import Toast from './components/common/Toast';
import ErrorBoundary from './components/common/ErrorBoundary';

// Store
import useAuthStore from './store/authStore';

// ============================================================================
// LAZY LOADED PAGES - Code-Splitting für bessere Performance
// ============================================================================

// Pages - Auth (sofort laden)
import Login from './pages/Login';

// Pages - Dashboard (lazy)
const DekanDashboard = React.lazy(() => import('./pages/Dashboard'));
const ProfessorDashboard = React.lazy(() => import('./pages/ProfessorDashboard'));

// Pages - Semesterplanung (lazy)
const SemesterplanungPage = React.lazy(() => import('./pages/Semesterplanung'));
const WizardView = React.lazy(() => import('./pages/WizardView'));
const SemesterplanungDetail = React.lazy(() => import('./pages/SemesterplanungDetail'));
const DekanPlanungView = React.lazy(() => import('./pages/DekanPlanungView'));

// Pages - Module & Dozenten (lazy)
const ModulePage = React.lazy(() => import('./pages/Module'));
const DozentenPage = React.lazy(() => import('./pages/Dozenten'));
// Note: AuftraegeVerwaltung route redirects to /einstellungen
const SemesterPage = React.lazy(() => import('./pages/SemesterPage'));
const EinstellungenPage = React.lazy(() => import('./pages/EinstellungenPage'));

// Pages - Deputatsabrechnung (lazy)
const Deputatsabrechnung = React.lazy(() => import('./pages/DeputatsabrechnungNeu'));
const DeputatVerwaltung = React.lazy(() => import('./pages/DeputatVerwaltung'));

// Pages - Planungs-Templates (lazy)
const TemplateVerwaltung = React.lazy(() => import('./pages/TemplateVerwaltung'));
const TemplateDetail = React.lazy(() => import('./pages/TemplateDetail'));

// ============================================================================
// LOADING FALLBACK COMPONENT
// ============================================================================

const PageLoader: React.FC = () => (
  <Box
    sx={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      minHeight: '50vh',
    }}
  >
    <CircularProgress />
  </Box>
);

// ============================================================================
// MAIN APP COMPONENT
// ============================================================================

/**
 * Main App Component - PRODUCTION READY
 * ======================================
 *
 * PERFORMANCE OPTIMIERUNGEN:
 * - React.lazy() für Code-Splitting
 * - Suspense für Lazy-Loading Fallback
 * - Rollenbasiertes Routing
 */

const App: React.FC = () => {
  const { checkAuth, user } = useAuthStore();

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  /**
   * Rollenbasierter Dashboard-Redirect
   * - Dekan → DekanDashboard (Admin-View)
   * - Professor/Lehrbeauftragter → ProfessorDashboard (Planungs-View)
   */
  const DashboardRedirect = () => {
    if (user?.rolle === 'dekan') {
      return <DekanDashboard />;
    }
    if (user?.rolle === 'professor' || user?.rolle === 'lehrbeauftragter') {
      return <ProfessorDashboard />;
    }
    // Fallback
    return <DekanDashboard />;
  };

  return (
    <ErrorBoundary>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <LocalizationProvider dateAdapter={AdapterDateFns} adapterLocale={de}>
          <Router>
            <Toast />
            <Suspense fallback={<PageLoader />}>
              <Routes>
                {/* Public Routes */}
                <Route path="/login" element={<Login />} />

                {/* Protected Routes */}
                <Route
                  path="/"
                  element={
                    <ProtectedRoute>
                      <Layout />
                    </ProtectedRoute>
                  }
                >
                  {/* Dashboard */}
                  <Route index element={<Navigate to="/dashboard" replace />} />
                  <Route path="dashboard" element={<DashboardRedirect />} />

                  {/* =====================================================
                      PROFESSOR/LEHRBEAUFTRAGTER ROUTES
                      ===================================================== */}

                  {/* Semesterplanung - Eigene Planungen */}
                  <Route
                    path="semesterplanung"
                    element={
                      <ProtectedRoute requiredRoles={['professor', 'lehrbeauftragter']}>
                        <SemesterplanungPage />
                      </ProtectedRoute>
                    }
                  />

                  {/* Neue Planung erstellen - NUR Professor/Lehrbeauftragter! */}
                  <Route
                    path="semesterplanung/neu"
                    element={
                      <ProtectedRoute requiredRoles={['professor', 'lehrbeauftragter']}>
                        <WizardView />
                      </ProtectedRoute>
                    }
                  />

                  {/* Planung bearbeiten - NUR eigene Planungen! */}
                  <Route
                    path="semesterplanung/:id/edit"
                    element={
                      <ProtectedRoute requiredRoles={['professor', 'lehrbeauftragter']}>
                        <WizardView />
                      </ProtectedRoute>
                    }
                  />

                  {/* Planung Details - Professor kann eigene sehen, Dekan kann alle sehen */}
                  <Route
                    path="semesterplanung/:id"
                    element={
                      <ProtectedRoute requiredRoles={['professor', 'lehrbeauftragter', 'dekan']}>
                        <SemesterplanungDetail />
                      </ProtectedRoute>
                    }
                  />

                  {/* =====================================================
                      DEKAN ROUTES
                      ===================================================== */}

                  {/* Dekan - Alle Planungen prüfen */}
                  <Route
                    path="dekan/planungen"
                    element={
                      <ProtectedRoute requiredRoles={['dekan']}>
                        <DekanPlanungView />
                      </ProtectedRoute>
                    }
                  />

                  {/* Dekan - Einzelne Planung prüfen */}
                  <Route
                    path="dekan/planungen/:id"
                    element={
                      <ProtectedRoute requiredRoles={['dekan']}>
                        <SemesterplanungDetail />
                      </ProtectedRoute>
                    }
                  />

                  {/* Dekan - Aufträge-Verwaltung (Redirect für Backward-Compatibility) */}
                  <Route
                    path="dekan/auftraege"
                    element={<Navigate to="/einstellungen" replace />}
                  />

                  {/* Dekan - Deputat-Verwaltung (Feature 4) */}
                  <Route
                    path="dekan/deputat"
                    element={
                      <ProtectedRoute requiredRoles={['dekan']}>
                        <DeputatVerwaltung />
                      </ProtectedRoute>
                    }
                  />

                  {/* =====================================================
                      PROFESSOR/LEHRBEAUFTRAGTER - DEPUTATSABRECHNUNG
                      ===================================================== */}

                  {/* Deputatsabrechnung - Eigene Abrechnungen */}
                  <Route
                    path="deputatsabrechnung"
                    element={
                      <ProtectedRoute requiredRoles={['professor', 'lehrbeauftragter']}>
                        <Deputatsabrechnung />
                      </ProtectedRoute>
                    }
                  />

                  {/* Planungs-Templates (Feature 5) */}
                  <Route
                    path="templates"
                    element={
                      <ProtectedRoute requiredRoles={['professor', 'lehrbeauftragter']}>
                        <TemplateVerwaltung />
                      </ProtectedRoute>
                    }
                  />
                  <Route
                    path="templates/:id"
                    element={
                      <ProtectedRoute requiredRoles={['professor', 'lehrbeauftragter']}>
                        <TemplateDetail />
                      </ProtectedRoute>
                    }
                  />

                  {/* =====================================================
                      SHARED ROUTES (Alle Rollen)
                      ===================================================== */}

                  {/* Module - Alle können sehen */}
                  <Route path="module" element={<ModulePage />} />
                  <Route path="module/:id" element={<ModulePage />} />

                  {/* Dozenten - Alle können sehen */}
                  <Route path="dozenten" element={<DozentenPage />} />

                  {/* Semester Management - NUR Dekan */}
                  <Route
                    path="semester"
                    element={
                      <ProtectedRoute requiredRoles={['dekan']}>
                        <SemesterPage />
                      </ProtectedRoute>
                    }
                  />

                  {/* Verwaltung - NUR Dekan */}
                  <Route
                    path="verwaltung/*"
                    element={
                      <ProtectedRoute requiredRoles={['dekan']}>
                        <div>Verwaltung (TODO)</div>
                      </ProtectedRoute>
                    }
                  />

                  {/* Settings & Profile */}
                  <Route path="einstellungen" element={<EinstellungenPage />} />
                  <Route path="profil" element={<div>Profil (TODO)</div>} />
                </Route>

                {/* Catch all - Redirect to Dashboard */}
                <Route path="*" element={<Navigate to="/dashboard" replace />} />
              </Routes>
            </Suspense>
          </Router>
        </LocalizationProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
};

export default App;
