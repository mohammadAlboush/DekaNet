import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { LocalizationProvider } from '@mui/x-date-pickers';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { de } from 'date-fns/locale';

// Theme
import theme from './theme/theme';

// Components
import Layout from './components/common/Layout';
import ProtectedRoute from './components/auth/ProtectedRoute';
import Toast from './components/common/Toast';
import ErrorBoundary from './components/common/ErrorBoundary';

// Pages - Auth
import Login from './pages/Login';

// Pages - Dashboard
import DekanDashboard from './pages/Dashboard';
import ProfessorDashboard from './pages/ProfessorDashboard';

// Pages - Semesterplanung
import SemesterplanungPage from './pages/Semesterplanung';
import WizardView from './pages/WizardView';
import SemesterplanungDetail from './pages/SemesterplanungDetail';
import DekanPlanungView from './pages/DekanPlanungView';

// Pages - Module & Dozenten
import ModulePage from './pages/Module';
import DozentenPage from './pages/Dozenten';
import ModulVerwaltungPage from './pages/ModulVerwaltung';
import AuftraegeVerwaltung from './pages/AuftraegeVerwaltung';
import SemesterPage from './pages/SemesterPage';

// Pages - Deputatsabrechnung (Feature 4)
import Deputatsabrechnung from './pages/DeputatsabrechnungNeu';
import DeputatVerwaltung from './pages/DeputatVerwaltung';

// Pages - Planungs-Templates (Feature 5)
import TemplateVerwaltung from './pages/TemplateVerwaltung';
import TemplateDetail from './pages/TemplateDetail';

// Store
import useAuthStore from './store/authStore';

/**
 * Main App Component - PRODUCTION READY
 * ======================================
 * 
 * IMPROVEMENTS:
 * - Rollenbasiertes Routing
 * - Dekan kann KEINE eigenen Planungen erstellen
 * - Dekan hat spezielle Review-Routes
 * - Professor/Lehrbeauftragter hat Wizard-Routes
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

                {/* Dekan - Modul-Verwaltung */}
                <Route
                  path="dekan/modul-verwaltung"
                  element={
                    <ProtectedRoute requiredRoles={['dekan']}>
                      <ModulVerwaltungPage />
                    </ProtectedRoute>
                  }
                />

                {/* Dekan - Aufträge-Verwaltung */}
                <Route
                  path="dekan/auftraege"
                  element={
                    <ProtectedRoute requiredRoles={['dekan']}>
                      <AuftraegeVerwaltung />
                    </ProtectedRoute>
                  }
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
                <Route path="einstellungen" element={<div>Einstellungen (TODO)</div>} />
                <Route path="profil" element={<div>Profil (TODO)</div>} />
              </Route>

              {/* Catch all - Redirect to Dashboard */}
              <Route path="*" element={<Navigate to="/dashboard" replace />} />
            </Routes>
          </Router>
        </LocalizationProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
};

export default App;