import React, { useEffect, useState } from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  Alert,
  AlertTitle,
  CircularProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Tooltip,
} from '@mui/material';
import {
  CalendarMonth,
  CheckCircle,
  Cancel,
  PlayArrow,
  Refresh,
  Lock,
  LockOpen,
} from '@mui/icons-material';
import semesterService from '../../services/semesterService';
import { Semester } from '../../types/semester.types';
import { useToastStore } from '../common/Toast';
import { createContextLogger } from '../../utils/logger';
import { getErrorMessage } from '../../utils/errorUtils';

const log = createContextLogger('SemesterManagement');

/**
 * SemesterManagement Component
 * =============================
 * Verwaltung von Semestern für Dekan
 *
 * Features:
 * - Übersicht aller Semester mit Status
 * - Auto-Semester-Vorschlag (basierend auf Datum)
 * - Semester aktivieren/deaktivieren
 * - Planungsphase öffnen/schließen
 * - Statistiken pro Semester
 */

interface AutoSuggestion {
  vorschlag: Semester | null;
  aktives: Semester | null;
  laufendes: Semester | null;
  ist_korrekt: boolean;
  empfehlung: string;
  datum_heute: string;
}

const SemesterManagement: React.FC = () => {
  const showToast = useToastStore((state) => state.showToast);

  const [loading, setLoading] = useState(true);
  const [alleSemester, setAlleSemester] = useState<Semester[]>([]);
  const [autoSuggestion, setAutoSuggestion] = useState<AutoSuggestion | null>(null);
  const [confirmDialog, setConfirmDialog] = useState<{
    open: boolean;
    action: string;
    semester: Semester | null;
  }>({
    open: false,
    action: '',
    semester: null,
  });
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      // Load all semesters
      const semesterResponse = await semesterService.getAllSemesters();
      if (semesterResponse.success && semesterResponse.data) {
        setAlleSemester(semesterResponse.data);
      }

      // Load auto suggestion
      const suggestionResponse = await semesterService.getAutoSuggestion();
      if (suggestionResponse.success && suggestionResponse.data) {
        setAutoSuggestion(suggestionResponse.data);
      }
    } catch (error: unknown) {
      log.error(' Error loading data:', { error });
      showToast('Fehler beim Laden der Daten', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleActivateSemester = (semester: Semester, openPlanungsphase: boolean) => {
    setConfirmDialog({
      open: true,
      action: openPlanungsphase ? 'activate_with_phase' : 'activate',
      semester,
    });
  };

  const handleTogglePlanungsphase = (semester: Semester, open: boolean) => {
    setConfirmDialog({
      open: true,
      action: open ? 'open_phase' : 'close_phase',
      semester,
    });
  };

  const executeAction = async () => {
    if (!confirmDialog.semester) return;

    setActionLoading(true);
    try {
      const { action, semester } = confirmDialog;

      switch (action) {
        case 'activate':
          await semesterService.activateSemester(semester.id, false);
          showToast(`✅ ${semester.bezeichnung} aktiviert`, 'success');
          break;

        case 'activate_with_phase':
          await semesterService.activateSemester(semester.id, true);
          showToast(`✅ ${semester.bezeichnung} aktiviert und Planungsphase geöffnet`, 'success');
          break;

        case 'open_phase':
          await semesterService.controlPlanningPhase(semester.id, 'oeffnen');
          showToast(`✅ Planungsphase für ${semester.bezeichnung} geöffnet`, 'success');
          break;

        case 'close_phase':
          await semesterService.controlPlanningPhase(semester.id, 'schliessen');
          showToast(`✅ Planungsphase für ${semester.bezeichnung} geschlossen`, 'success');
          break;
      }

      // Reload data
      await loadData();
    } catch (error: unknown) {
      log.error(' Error executing action:', { error });
      showToast(getErrorMessage(error, 'Fehler bei der Aktion'), 'error');
    } finally {
      setActionLoading(false);
      setConfirmDialog({ open: false, action: '', semester: null });
    }
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('de-DE');
  };

  const getActionText = () => {
    const { action, semester } = confirmDialog;
    if (!semester) return '';

    switch (action) {
      case 'activate':
        return `Möchten Sie "${semester.bezeichnung}" als aktives Semester setzen?\n\nDies deaktiviert alle anderen Semester.`;
      case 'activate_with_phase':
        return `Möchten Sie "${semester.bezeichnung}" aktivieren und die Planungsphase öffnen?\n\nDies deaktiviert alle anderen Semester und öffnet die Planungsphase für dieses Semester.`;
      case 'open_phase':
        return `Möchten Sie die Planungsphase für "${semester.bezeichnung}" öffnen?\n\nProfessoren können dann ihre Semesterplanungen einreichen.`;
      case 'close_phase':
        return `Möchten Sie die Planungsphase für "${semester.bezeichnung}" schließen?\n\nProfessoren können dann keine neuen Planungen mehr einreichen.`;
      default:
        return '';
    }
  };

  if (loading) {
    return (
      <Card>
        <CardContent>
          <Box display="flex" justifyContent="center" alignItems="center" py={4}>
            <CircularProgress />
          </Box>
        </CardContent>
      </Card>
    );
  }

  return (
    <Box>
      {/* Auto-Semester-Vorschlag */}
      {autoSuggestion && !autoSuggestion.ist_korrekt && autoSuggestion.vorschlag && (
        <Alert
          severity="warning"
          sx={{ mb: 3 }}
          action={
            <Button
              color="inherit"
              size="small"
              onClick={() => handleActivateSemester(autoSuggestion.vorschlag!, true)}
              startIcon={<Refresh />}
            >
              Jetzt aktivieren
            </Button>
          }
        >
          <AlertTitle>📅 Semesterwechsel empfohlen</AlertTitle>
          <Typography variant="body2">
            {autoSuggestion.empfehlung}
          </Typography>
          <Typography variant="caption" display="block" sx={{ mt: 1 }}>
            Heute: {formatDate(autoSuggestion.datum_heute)}
          </Typography>
        </Alert>
      )}

      {autoSuggestion && autoSuggestion.ist_korrekt && (
        <Alert severity="success" sx={{ mb: 3 }}>
          <AlertTitle>✅ Semester-Status korrekt</AlertTitle>
          <Typography variant="body2">
            {autoSuggestion.empfehlung}
          </Typography>
        </Alert>
      )}

      {/* Semester-Übersicht */}
      <Card elevation={3}>
        <CardContent>
          <Box display="flex" alignItems="center" justifyContent="space-between" mb={2}>
            <Box display="flex" alignItems="center">
              <CalendarMonth color="primary" sx={{ mr: 1 }} />
              <Typography variant="h6" component="h2">
                Semester-Verwaltung
              </Typography>
            </Box>
            <Button
              variant="outlined"
              startIcon={<Refresh />}
              onClick={loadData}
              size="small"
            >
              Aktualisieren
            </Button>
          </Box>

          <Typography variant="body2" color="text.secondary" gutterBottom sx={{ mb: 3 }}>
            Verwalten Sie Semester und Planungsphasen. Nur ein Semester kann gleichzeitig aktiv sein.
          </Typography>

          <TableContainer component={Paper} variant="outlined">
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell><strong>Semester</strong></TableCell>
                  <TableCell><strong>Zeitraum</strong></TableCell>
                  <TableCell align="center"><strong>Status</strong></TableCell>
                  <TableCell align="center"><strong>Planungsphase</strong></TableCell>
                  <TableCell align="center"><strong>Statistik</strong></TableCell>
                  <TableCell align="right"><strong>Aktionen</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {alleSemester.map((semester) => (
                  <TableRow
                    key={semester.id}
                    sx={{
                      backgroundColor: semester.ist_aktiv ? 'action.selected' : 'inherit'
                    }}
                  >
                    <TableCell>
                      <Box>
                        <Typography variant="body2" fontWeight="bold">
                          {semester.bezeichnung}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {semester.kuerzel}
                        </Typography>
                      </Box>
                    </TableCell>

                    <TableCell>
                      <Typography variant="caption" display="block">
                        {formatDate(semester.start_datum)} - {formatDate(semester.ende_datum)}
                      </Typography>
                      {semester.ist_laufend && (
                        <Chip label="Läuft aktuell" size="small" color="success" sx={{ mt: 0.5 }} />
                      )}
                    </TableCell>

                    <TableCell align="center">
                      {semester.ist_aktiv ? (
                        <Chip
                          label="Aktiv"
                          color="primary"
                          size="small"
                          icon={<CheckCircle />}
                        />
                      ) : (
                        <Chip
                          label="Inaktiv"
                          variant="outlined"
                          size="small"
                          icon={<Cancel />}
                        />
                      )}
                    </TableCell>

                    <TableCell align="center">
                      {semester.ist_planungsphase ? (
                        <Chip
                          label="Offen"
                          color="success"
                          size="small"
                          icon={<LockOpen />}
                        />
                      ) : (
                        <Chip
                          label="Geschlossen"
                          variant="outlined"
                          size="small"
                          icon={<Lock />}
                        />
                      )}
                    </TableCell>

                    <TableCell align="center">
                      <Box>
                        <Typography variant="caption" display="block">
                          {semester.statistik?.gesamt || 0} Planungen
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {semester.statistik?.freigegeben || 0} freigegeben
                        </Typography>
                      </Box>
                    </TableCell>

                    <TableCell align="right">
                      <Box display="flex" gap={0.5} justifyContent="flex-end">
                        {!semester.ist_aktiv && (
                          <Tooltip title="Semester aktivieren">
                            <IconButton
                              size="small"
                              color="primary"
                              onClick={() => handleActivateSemester(semester, false)}
                            >
                              <PlayArrow />
                            </IconButton>
                          </Tooltip>
                        )}

                        {semester.ist_aktiv && !semester.ist_planungsphase && (
                          <Tooltip title="Planungsphase öffnen">
                            <IconButton
                              size="small"
                              color="success"
                              onClick={() => handleTogglePlanungsphase(semester, true)}
                            >
                              <LockOpen />
                            </IconButton>
                          </Tooltip>
                        )}

                        {semester.ist_aktiv && semester.ist_planungsphase && (
                          <Tooltip title="Planungsphase schließen">
                            <IconButton
                              size="small"
                              color="warning"
                              onClick={() => handleTogglePlanungsphase(semester, false)}
                            >
                              <Lock />
                            </IconButton>
                          </Tooltip>
                        )}
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}

                {alleSemester.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={6} align="center">
                      <Typography variant="body2" color="text.secondary" py={2}>
                        Keine Semester vorhanden
                      </Typography>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>

      {/* Confirm Dialog */}
      <Dialog
        open={confirmDialog.open}
        onClose={() => setConfirmDialog({ open: false, action: '', semester: null })}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          Bestätigung erforderlich
        </DialogTitle>
        <DialogContent>
          <Typography variant="body1" sx={{ whiteSpace: 'pre-line' }}>
            {getActionText()}
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button
            onClick={() => setConfirmDialog({ open: false, action: '', semester: null })}
            disabled={actionLoading}
          >
            Abbrechen
          </Button>
          <Button
            onClick={executeAction}
            variant="contained"
            disabled={actionLoading}
            startIcon={actionLoading ? <CircularProgress size={16} /> : null}
          >
            {actionLoading ? 'Wird ausgeführt...' : 'Bestätigen'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default SemesterManagement;
