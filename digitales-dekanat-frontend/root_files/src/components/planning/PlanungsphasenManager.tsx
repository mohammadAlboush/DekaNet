import { useState, useEffect } from 'react';
import {
  Card,
  CardContent,
  CardHeader,
  Typography,
  Button,
  Box,
  Alert,
  AlertTitle,
  Grid,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControlLabel,
  Switch,
  LinearProgress,
  List,
  ListItem,
  ListItemText,
  Badge,
  Tabs,
  Tab,
  Paper,
  CircularProgress,
} from '@mui/material';
import {
  PlayArrow,
  Stop,
  History,
  Archive,
  Assessment,
  Notifications,
  Edit,
  Download,
  Warning,
  CheckCircle,
  Cancel,
  Schedule,
  People,
  Email,
} from '@mui/icons-material';
import { DateTimePicker } from '@mui/x-date-pickers/DateTimePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { de } from 'date-fns/locale';
import { format, differenceInDays, differenceInHours } from 'date-fns';
import usePlanungPhaseStore from '../../store/planungPhaseStore';
import useAuthStore from '../../store/authStore';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`phase-tabpanel-${index}`}
      aria-labelledby={`phase-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ p: 3 }}>{children}</Box>}
    </div>
  );
}

const PlanungsphasenManager: React.FC = () => {
  const { user } = useAuthStore();
  const {
    activePhase,
    allPhases,
    submissionStatus,
    currentPhaseStatistics,
    phaseSubmissions,
    loading,
    error,
    isPhaseActive,
    canSubmit,
    getTimeRemaining,
    fetchActivePhase,
    startNewPhase,
    closeCurrentPhase,
    updatePhase,
    fetchPhaseSubmissions,
    fetchPhaseStatistics,
    sendRemindersToProfs,
    clearError,
  } = usePlanungPhaseStore();

  const [tabValue, setTabValue] = useState(0);
  const [openStartDialog, setOpenStartDialog] = useState(false);
  const [openCloseDialog, setOpenCloseDialog] = useState(false);
  const [openEditDialog, setOpenEditDialog] = useState(false);
  const [openReminderDialog, setOpenReminderDialog] = useState(false);

  // Form States for Start Phase Dialog
  const [phaseName, setPhaseName] = useState('');
  const [phaseDeadline, setPhaseDeadline] = useState<Date | null>(null);
  const [hasDeadline, setHasDeadline] = useState(false);

  // Form States for Close Phase Dialog
  const [archiveEntwuerfe, setArchiveEntwuerfe] = useState(false);
  const [closeReason, setCloseReason] = useState('');

  // Load initial data
  useEffect(() => {
    let isMounted = true;

    const loadData = async () => {
      if (isMounted) {
        await fetchActivePhase();
      }
    };

    loadData();

    return () => {
      isMounted = false;
    };
  }, []);

  // Load phase data when activePhase changes
  useEffect(() => {
    let isMounted = true;

    const loadPhaseData = async () => {
      if (activePhase && activePhase.id && isMounted) {
        await fetchPhaseSubmissions(activePhase.id);
        await fetchPhaseStatistics(activePhase.id);
      }
    };

    loadPhaseData();

    return () => {
      isMounted = false;
    };
  }, [activePhase]);

  // Auto-generate phase name
  useEffect(() => {
    if (openStartDialog && !phaseName) {
      const currentDate = new Date();
      const month = currentDate.getMonth();
      const year = currentDate.getFullYear();
      const semester = month >= 3 && month <= 8 ? 'Sommersemester' : 'Wintersemester';
      const phaseNumber = allPhases.filter(p =>
        p.name.includes(semester) && p.name.includes(year.toString())
      ).length + 1;
      setPhaseName(`${semester} ${year} - Phase ${phaseNumber}`);
    }
  }, [openStartDialog, allPhases]);

  const handleStartPhase = async () => {
    if (!phaseName.trim()) {
      alert('Bitte geben Sie einen Namen für die Phase ein.');
      return;
    }

    try {
      await startNewPhase(
        phaseName,
        1, // TODO: Get actual semester ID
        hasDeadline && phaseDeadline ? phaseDeadline.toISOString() : undefined
      );
      setOpenStartDialog(false);
      setPhaseName('');
      setPhaseDeadline(null);
      setHasDeadline(false);

      // Reload data
      fetchActivePhase();
    } catch (error) {
      console.error('Fehler beim Starten der Phase:', error);
    }
  };

  const handleClosePhase = async () => {
    if (!activePhase || !activePhase.id) {
      alert('Keine aktive Phase zum Schließen gefunden.');
      return;
    }

    try {
      await closeCurrentPhase(archiveEntwuerfe, closeReason);
      setOpenCloseDialog(false);
      setArchiveEntwuerfe(false);
      setCloseReason('');

      // Reload data
      fetchActivePhase();
    } catch (error) {
      console.error('Fehler beim Schließen der Phase:', error);
      alert('Fehler beim Schließen der Phase. Bitte versuchen Sie es erneut.');
    }
  };

  const handleSendReminders = async () => {
    if (!activePhase) return;

    try {
      await sendRemindersToProfs(activePhase.id);
      setOpenReminderDialog(false);
      alert('Erinnerungen wurden erfolgreich versendet.');
    } catch (error) {
      console.error('Fehler beim Senden der Erinnerungen:', error);
    }
  };

  const getPhaseStatusColor = () => {
    if (!activePhase) return 'default';
    if (!activePhase.ist_aktiv) return 'default';

    const timeRemaining = getTimeRemaining();
    if (!timeRemaining) return 'success';

    if (timeRemaining < 1440) return 'error'; // Weniger als 24 Stunden
    if (timeRemaining < 4320) return 'warning'; // Weniger als 3 Tage
    return 'success';
  };

  const formatTimeRemaining = (minutes: number | null) => {
    if (!minutes) return 'Keine Deadline';

    const days = Math.floor(minutes / 1440);
    const hours = Math.floor((minutes % 1440) / 60);
    const mins = minutes % 60;

    if (days > 0) {
      return `${days} Tage, ${hours} Stunden`;
    } else if (hours > 0) {
      return `${hours} Stunden, ${mins} Minuten`;
    } else {
      return `${mins} Minuten`;
    }
  };

  const calculateProgress = () => {
    if (!currentPhaseStatistics) return 0;
    return (currentPhaseStatistics.professoren_eingereicht / currentPhaseStatistics.professoren_gesamt) * 100;
  };

  return (
    <Card>
      <CardHeader
        title={
          <Box display="flex" alignItems="center" justifyContent="space-between">
            <Typography variant="h5">Planungsphasen-Verwaltung</Typography>
            {activePhase && (
              <Chip
                label={activePhase.ist_aktiv ? 'Phase Aktiv' : 'Phase Geschlossen'}
                color={activePhase.ist_aktiv ? 'success' : 'default'}
                icon={activePhase.ist_aktiv ? <CheckCircle /> : <Cancel />}
              />
            )}
          </Box>
        }
      />
      <CardContent>
        {error && (
          <Alert severity="error" onClose={clearError} sx={{ mb: 2 }}>
            <AlertTitle>Fehler</AlertTitle>
            {error}
          </Alert>
        )}

        {/* Active Phase Info */}
        {activePhase ? (
          <Paper elevation={2} sx={{ p: 3, mb: 3 }}>
            <Typography variant="h6" gutterBottom>
              Aktuelle Phase: {activePhase.name}
            </Typography>

            <Grid container spacing={2} sx={{ mt: 1 }}>
              <Grid item xs={12} md={3}>
                <Box>
                  <Typography variant="caption" color="textSecondary">
                    Gestartet am
                  </Typography>
                  <Typography variant="body2">
                    {activePhase.startdatum ?
                      format(new Date(activePhase.startdatum), 'dd.MM.yyyy HH:mm', { locale: de })
                      : '-'}
                  </Typography>
                </Box>
              </Grid>

              {activePhase.enddatum && (
                <Grid item xs={12} md={3}>
                  <Box>
                    <Typography variant="caption" color="textSecondary">
                      Deadline
                    </Typography>
                    <Typography variant="body2">
                      {activePhase.enddatum ?
                        format(new Date(activePhase.enddatum), 'dd.MM.yyyy HH:mm', { locale: de })
                        : '-'}
                    </Typography>
                  </Box>
                </Grid>
              )}

              <Grid item xs={12} md={3}>
                <Box>
                  <Typography variant="caption" color="textSecondary">
                    Verbleibende Zeit
                  </Typography>
                  <Typography variant="body2" color={getPhaseStatusColor()}>
                    {formatTimeRemaining(getTimeRemaining())}
                  </Typography>
                </Box>
              </Grid>

              <Grid item xs={12} md={3}>
                <Box>
                  <Typography variant="caption" color="textSecondary">
                    Status
                  </Typography>
                  <Typography variant="body2">
                    {activePhase.anzahl_einreichungen} Einreichungen
                    ({activePhase.anzahl_genehmigt} genehmigt, {activePhase.anzahl_abgelehnt} abgelehnt)
                  </Typography>
                </Box>
              </Grid>
            </Grid>

            {currentPhaseStatistics && (
              <Box sx={{ mt: 3 }}>
                <Typography variant="caption" color="textSecondary">
                  Fortschritt: {currentPhaseStatistics.professoren_eingereicht} von {currentPhaseStatistics.professoren_gesamt} Professoren
                </Typography>
                <LinearProgress
                  variant="determinate"
                  value={calculateProgress()}
                  sx={{ mt: 1, height: 10, borderRadius: 1 }}
                />
              </Box>
            )}

            <Box sx={{ mt: 3, display: 'flex', gap: 2 }}>
              <Button
                variant="outlined"
                color="warning"
                startIcon={<Stop />}
                onClick={() => setOpenCloseDialog(true)}
              >
                Phase Beenden
              </Button>
              <Button
                variant="outlined"
                startIcon={<Edit />}
                onClick={() => setOpenEditDialog(true)}
              >
                Phase Bearbeiten
              </Button>
              <Button
                variant="outlined"
                startIcon={<Email />}
                onClick={() => setOpenReminderDialog(true)}
              >
                Erinnerungen Senden
              </Button>
              <Button
                variant="outlined"
                startIcon={<Assessment />}
                onClick={() => fetchPhaseStatistics(activePhase.id)}
              >
                Statistiken Aktualisieren
              </Button>
            </Box>
          </Paper>
        ) : (
          <Alert severity="info" sx={{ mb: 3 }}>
            <AlertTitle>Keine aktive Planungsphase</AlertTitle>
            Es ist derzeit keine Planungsphase aktiv. Starten Sie eine neue Phase, damit Professoren ihre Planungen einreichen können.
            <Box sx={{ mt: 2 }}>
              <Button
                variant="contained"
                color="primary"
                startIcon={<PlayArrow />}
                onClick={() => setOpenStartDialog(true)}
              >
                Neue Phase Starten
              </Button>
            </Box>
          </Alert>
        )}

        {/* Tabs for different views */}
        <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
          <Tabs value={tabValue} onChange={(_, newValue) => setTabValue(newValue)}>
            <Tab label="Aktuelle Einreichungen" icon={<Badge badgeContent={phaseSubmissions.length} color="primary"><People /></Badge>} />
            <Tab label="Statistiken" icon={<Assessment />} />
            <Tab label="Historie" icon={<History />} />
            <Tab label="Archiv" icon={<Archive />} />
          </Tabs>
        </Box>

        <TabPanel value={tabValue} index={0}>
          {/* Current Submissions */}
          {loading ? (
            <CircularProgress />
          ) : (
            <List>
              {phaseSubmissions.map((submission) => (
                <ListItem key={submission.id || `${submission.professor_id}-${submission.planung_id}`}>
                  <ListItemText
                    primary={`Professor ID: ${submission.professor_id}`}
                    secondary={
                      <Box>
                        <Typography variant="body2" component="span">
                          Eingereicht: {submission.eingereicht_am ?
                            format(new Date(submission.eingereicht_am), 'dd.MM.yyyy HH:mm', { locale: de })
                            : '-'}
                        </Typography>
                        <Chip
                          size="small"
                          label={submission.status}
                          color={
                            submission.status === 'freigegeben' ? 'success' :
                            submission.status === 'abgelehnt' ? 'error' : 'default'
                          }
                          sx={{ ml: 1 }}
                        />
                      </Box>
                    }
                  />
                </ListItem>
              ))}
              {phaseSubmissions.length === 0 && (
                <Typography variant="body2" color="textSecondary" align="center">
                  Noch keine Einreichungen in dieser Phase
                </Typography>
              )}
            </List>
          )}
        </TabPanel>

        <TabPanel value={tabValue} index={1}>
          {/* Statistics */}
          {currentPhaseStatistics ? (
            <Grid container spacing={3}>
              <Grid item xs={12} md={4}>
                <Paper sx={{ p: 2 }}>
                  <Typography variant="h6">{currentPhaseStatistics.einreichungsquote.toFixed(1)}%</Typography>
                  <Typography variant="caption">Einreichungsquote</Typography>
                </Paper>
              </Grid>
              <Grid item xs={12} md={4}>
                <Paper sx={{ p: 2 }}>
                  <Typography variant="h6">{currentPhaseStatistics.genehmigungsquote.toFixed(1)}%</Typography>
                  <Typography variant="caption">Genehmigungsquote</Typography>
                </Paper>
              </Grid>
              <Grid item xs={12} md={4}>
                <Paper sx={{ p: 2 }}>
                  <Typography variant="h6">{currentPhaseStatistics.durchschnittliche_bearbeitungszeit.toFixed(1)}h</Typography>
                  <Typography variant="caption">Ø Bearbeitungszeit</Typography>
                </Paper>
              </Grid>

              {currentPhaseStatistics.top_module.length > 0 && (
                <Grid item xs={12}>
                  <Typography variant="h6" gutterBottom>Top Module</Typography>
                  <List>
                    {currentPhaseStatistics.top_module.map((modul, index) => (
                      <ListItem key={index}>
                        <ListItemText
                          primary={modul.modul_name}
                          secondary={`${modul.anzahl} mal geplant`}
                        />
                      </ListItem>
                    ))}
                  </List>
                </Grid>
              )}
            </Grid>
          ) : (
            <Typography variant="body2" color="textSecondary" align="center">
              Keine Statistiken verfügbar
            </Typography>
          )}
        </TabPanel>

        <TabPanel value={tabValue} index={2}>
          {/* History - Will be implemented with PhaseHistoryDialog */}
          <Typography variant="body2" color="textSecondary" align="center">
            Phasenhistorie wird geladen...
          </Typography>
        </TabPanel>

        <TabPanel value={tabValue} index={3}>
          {/* Archive - Will be implemented with ArchivedPlanungsList */}
          <Typography variant="body2" color="textSecondary" align="center">
            Archiv wird geladen...
          </Typography>
        </TabPanel>

        {/* Start Phase Dialog */}
        <Dialog open={openStartDialog} onClose={() => setOpenStartDialog(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Neue Planungsphase Starten</DialogTitle>
          <DialogContent>
            <Box sx={{ mt: 2 }}>
              <TextField
                fullWidth
                label="Phasenname"
                value={phaseName}
                onChange={(e) => setPhaseName(e.target.value)}
                placeholder="z.B. Sommersemester 2024 - Phase 1"
                sx={{ mb: 3 }}
              />

              <FormControlLabel
                control={
                  <Switch
                    checked={hasDeadline}
                    onChange={(e) => setHasDeadline(e.target.checked)}
                  />
                }
                label="Deadline festlegen"
                sx={{ mb: 2 }}
              />

              {hasDeadline && (
                <LocalizationProvider dateAdapter={AdapterDateFns} adapterLocale={de}>
                  <DateTimePicker
                    label="Deadline"
                    value={phaseDeadline}
                    onChange={setPhaseDeadline}
                    format="dd.MM.yyyy HH:mm"
                    ampm={false}
                    minDate={new Date()}
                    slotProps={{
                      textField: {
                        fullWidth: true,
                        helperText: 'Nach dieser Zeit können keine Einreichungen mehr gemacht werden'
                      }
                    }}
                  />
                </LocalizationProvider>
              )}
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpenStartDialog(false)}>Abbrechen</Button>
            <Button onClick={handleStartPhase} variant="contained" color="primary">
              Phase Starten
            </Button>
          </DialogActions>
        </Dialog>

        {/* Close Phase Dialog */}
        <Dialog open={openCloseDialog} onClose={() => setOpenCloseDialog(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Planungsphase Beenden</DialogTitle>
          <DialogContent>
            <Alert severity="warning" sx={{ mb: 2 }}>
              <AlertTitle>Achtung</AlertTitle>
              Das Beenden der Phase kann nicht rückgängig gemacht werden. Alle aktuellen Planungen werden archiviert.
            </Alert>

            <FormControlLabel
              control={
                <Switch
                  checked={archiveEntwuerfe}
                  onChange={(e) => setArchiveEntwuerfe(e.target.checked)}
                />
              }
              label="Entwürfe archivieren (statt löschen)"
              sx={{ mb: 2 }}
            />

            <TextField
              fullWidth
              multiline
              rows={3}
              label="Grund für Beendigung (optional)"
              value={closeReason}
              onChange={(e) => setCloseReason(e.target.value)}
              placeholder="z.B. Planungsphase abgeschlossen, alle Einreichungen bearbeitet"
            />

            {currentPhaseStatistics && (
              <Alert severity="info" sx={{ mt: 2 }}>
                Es werden {currentPhaseStatistics.professoren_eingereicht} Planungen archiviert.
                {currentPhaseStatistics.professoren_gesamt - currentPhaseStatistics.professoren_eingereicht} Professoren haben nicht eingereicht.
              </Alert>
            )}
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpenCloseDialog(false)}>Abbrechen</Button>
            <Button onClick={handleClosePhase} variant="contained" color="error">
              Phase Beenden
            </Button>
          </DialogActions>
        </Dialog>

        {/* Edit Phase Dialog */}
        <Dialog open={openEditDialog} onClose={() => setOpenEditDialog(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Phase Bearbeiten</DialogTitle>
          <DialogContent>
            <Typography variant="body2" color="textSecondary">
              Bearbeitung der Phase wird implementiert...
            </Typography>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpenEditDialog(false)}>Schließen</Button>
          </DialogActions>
        </Dialog>

        {/* Reminder Dialog */}
        <Dialog open={openReminderDialog} onClose={() => setOpenReminderDialog(false)} maxWidth="sm" fullWidth>
          <DialogTitle>Erinnerungen Senden</DialogTitle>
          <DialogContent>
            <Typography variant="body1" gutterBottom>
              Möchten Sie Erinnerungen an alle Professoren senden, die noch keine Planung eingereicht haben?
            </Typography>
            {currentPhaseStatistics && (
              <Alert severity="info" sx={{ mt: 2 }}>
                Es werden Erinnerungen an {currentPhaseStatistics.professoren_gesamt - currentPhaseStatistics.professoren_eingereicht} Professoren gesendet.
              </Alert>
            )}
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpenReminderDialog(false)}>Abbrechen</Button>
            <Button onClick={handleSendReminders} variant="contained" color="primary" startIcon={<Email />}>
              Erinnerungen Senden
            </Button>
          </DialogActions>
        </Dialog>
      </CardContent>
    </Card>
  );
};

export default PlanungsphasenManager;