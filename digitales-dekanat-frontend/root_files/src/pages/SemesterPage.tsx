import React from 'react';
import {
  Container,
  Typography,
  Box,
  Breadcrumbs,
  Link as MuiLink,
} from '@mui/material';
import { NavigateNext, CalendarMonth } from '@mui/icons-material';
import { Link } from 'react-router-dom';
import SemesterManagement from '../components/dashboard/SemesterManagement';

/**
 * Semester-Seite
 * ==============
 * Vollständige Semesterverwaltung für Dekan
 *
 * Features:
 * - Alle Semester anzeigen
 * - Semester erstellen/bearbeiten
 * - Semester aktivieren/deaktivieren
 * - Planungsphase starten/beenden
 */
const SemesterPage: React.FC = () => {
  return (
    <Container maxWidth="xl">
      {/* Breadcrumbs */}
      <Box sx={{ mb: 3 }}>
        <Breadcrumbs separator={<NavigateNext fontSize="small" />}>
          <MuiLink
            component={Link}
            to="/dashboard"
            underline="hover"
            color="inherit"
          >
            Dashboard
          </MuiLink>
          <Typography color="text.primary">Semesterverwaltung</Typography>
        </Breadcrumbs>
      </Box>

      {/* Header */}
      <Box sx={{ mb: 4 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 1 }}>
          <CalendarMonth sx={{ fontSize: 40, color: 'primary.main' }} />
          <Typography variant="h4" component="h1">
            Semesterverwaltung
          </Typography>
        </Box>
        <Typography variant="body1" color="text.secondary">
          Verwalten Sie Semester, Planungsphasen und akademische Zeiträume
        </Typography>
      </Box>

      {/* Semester Management Component */}
      <SemesterManagement />
    </Container>
  );
};

export default SemesterPage;
