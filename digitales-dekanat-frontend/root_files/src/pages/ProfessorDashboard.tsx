import React, { useEffect, useState } from 'react';
import {
  Container,
  Grid,
  Paper,
  Typography,
  Box,
  Button,
  Card,
  CardContent,
  CardActions,
  Chip,
  Alert,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  Divider,
  LinearProgress,
  AlertTitle,
} from '@mui/material';
import {
  Add,
  Edit,
  Visibility,
  CheckCircle,
  Schedule,
  School,
  Assignment,
  TrendingUp,
  CalendarToday,
  Warning,
  Send,
  ArrowForward,
  History,
  Timer,
  Block,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import { de } from 'date-fns/locale';
import useAuthStore from '../store/authStore';
import planungService from '../services/planungService';
import semesterService from '../services/semesterService';
import usePlanungPhaseStore from '../store/planungPhaseStore';
import { Semesterplanung } from '../types/planung.types';
import { Semester } from '../types/semester.types';
import ProfessorPhasenHistorie from '../components/planning/ProfessorPhasenHistorie';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('ProfessorDashboard');

/**
 * Professor Dashboard
 * ===================
 * Optimiert für Planung-Workflow
 */

const ProfessorDashboard: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuthStore();

  // Planning Phase Store
  const {
    activePhase,
    submissionStatus,
    fetchActivePhase,
    checkSubmissionStatus,
    canSubmit,
    getTimeRemaining,
    hasSubmittedInCurrentPhase,
  } = usePlanungPhaseStore();

  const [loading, setLoading] = useState(false);
  const [planungen, setPlanungen] = useState<Semesterplanung[]>([]);
  const [planningSemester, setPlanningSemester] = useState<Semester | null>(null);
  const [showPhaseHistory, setShowPhaseHistory] = useState(false);

  useEffect(() => {
    loadDashboardData();
    loadPhaseData();
  }, []);

  const loadPhaseData = async () => {
    try {
      await fetchActivePhase();
      // Don't pass professor's own ID - backend will use the logged-in user's ID
      await checkSubmissionStatus();
    } catch (error) {
      log.error('Error loading phase data:', error);
    }
  };

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // Load planning semester
      const semesterRes = await semesterService.getPlanningSemester();
      if (semesterRes.success && semesterRes.data) {
        setPlanningSemester(semesterRes.data);
      }

      // Load my planungen - ensure it's always an array
      const planungenRes = await planungService.getMeinePlanungen();
      if (planungenRes.success && planungenRes.data) {
        // Ensure data is an array
        if (Array.isArray(planungenRes.data)) {
          setPlanungen(planungenRes.data);
        } else {
          log.warn('API returned non-array data for planungen:', planungenRes.data);
          setPlanungen([]);
        }
      } else {
        setPlanungen([]);
      }
    } catch (error) {
      log.error('Error loading dashboard:', error);
      setPlanungen([]); // Ensure planungen is always an array
    } finally {
      setLoading(false);
    }
  };

  const handleCreatePlanung = async () => {
    if (!planningSemester) {
      alert('Keine Planungsphase aktiv!');
      return;
    }

    // Check if professor can submit in current phase
    if (!canSubmit()) {
      let message = 'Sie können derzeit keine neue Planung erstellen. ';
      if (submissionStatus?.grund === 'keine_aktive_phase') {
        message += 'Es ist keine aktive Planungsphase vorhanden.';
      } else if (submissionStatus?.grund === 'bereits_genehmigt') {
        message += 'Sie haben bereits eine genehmigte Planung in dieser Phase.';
      } else if (submissionStatus?.grund === 'phase_abgelaufen') {
        message += 'Die Deadline für diese Phase ist abgelaufen.';
      }
      alert(message);
      return;
    }

    try {
      setLoading(true);

      // ✅ FIX: Erst Planung erstellen/holen, dann zum Wizard navigieren
      // Backend gibt entweder neue Planung oder bestehende zurück
      const response = await planungService.createPlanung({
        semester_id: planningSemester.id,
        notizen: ''
      });

      if (response.success && response.data) {
        // Navigiere zum Wizard MIT der Planung-ID
        // Dadurch lädt der Wizard alle existierenden Module
        navigate(`/semesterplanung/${response.data.id}/edit`);
      } else {
        alert('Fehler beim Erstellen der Planung');
      }
    } catch (error) {
      log.error('Error creating planung:', error);
      alert('Fehler beim Erstellen der Planung');
    } finally {
      setLoading(false);
    }
  };

  const formatTimeRemaining = (minutes: number | null): string => {
    if (!minutes) return 'Keine Deadline';

    const days = Math.floor(minutes / 1440);
    const hours = Math.floor((minutes % 1440) / 60);

    if (days > 0) {
      return `${days} Tage, ${hours} Stunden`;
    } else if (hours > 0) {
      return `${hours} Stunden verbleibend`;
    } else {
      return `${minutes} Minuten verbleibend`;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'freigegeben': return 'success';
      case 'eingereicht': return 'warning';
      case 'abgelehnt': return 'error';
      default: return 'default';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'freigegeben': return <CheckCircle fontSize="small" />;
      case 'eingereicht': return <Schedule fontSize="small" />;
      case 'abgelehnt': return <Warning fontSize="small" />;
      default: return <Edit fontSize="small" />;
    }
  };

  // Statistics - with safety check
  const stats = {
    gesamt: Array.isArray(planungen) ? planungen.length : 0,
    entwurf: Array.isArray(planungen) ? planungen.filter(p => p.status === 'entwurf').length : 0,
    eingereicht: Array.isArray(planungen) ? planungen.filter(p => p.status === 'eingereicht').length : 0,
    freigegeben: Array.isArray(planungen) ? planungen.filter(p => p.status === 'freigegeben').length : 0,
    abgelehnt: Array.isArray(planungen) ? planungen.filter(p => p.status === 'abgelehnt').length : 0,
  };

  // ✅ WICHTIG: Nur Planung der AKTIVEN Planungsphase anzeigen!
  const currentPlanung = Array.isArray(planungen) && activePhase
    ? planungen.find(p => p.planungsphase_id === activePhase.id)
    : undefined;

  return (
    <Container maxWidth="xl">
      {/* Welcome */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 4 }}>
        <Box>
          <Typography variant="h4" fontWeight={600} gutterBottom>
            Willkommen zurück, {user?.vorname || user?.username}!
          </Typography>
          <Typography variant="body1" color="text.secondary">
            Hier ist eine Übersicht Ihrer Semesterplanungen
          </Typography>
        </Box>
        <Button
          variant="outlined"
          size="large"
          startIcon={<History />}
          onClick={() => setShowPhaseHistory(true)}
          sx={{ minWidth: 180 }}
        >
          Phasen-Historie
        </Button>
      </Box>

      {loading && <LinearProgress sx={{ mb: 3 }} />}

      {/* Planning Phase Alert */}
      {activePhase ? (
        <Card sx={{ mb: 3, bgcolor: 'background.paper', border: 1, borderColor: 'primary.main' }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Schedule color="primary" />
                <Typography variant="h6">
                  Aktuelle Planungsphase: {activePhase.name}
                </Typography>
              </Box>
              <Button
                variant="outlined"
                size="small"
                startIcon={<History />}
                onClick={() => setShowPhaseHistory(true)}
              >
                Historie
              </Button>
            </Box>

            <Grid container spacing={2}>
              <Grid item xs={12} md={3}>
                <Typography variant="caption" color="textSecondary">
                  Phase gestartet
                </Typography>
                <Typography variant="body2">
                  {activePhase.startdatum ?
                    format(new Date(activePhase.startdatum), 'dd.MM.yyyy', { locale: de })
                    : '-'}
                </Typography>
              </Grid>
              {activePhase.enddatum && (
                <Grid item xs={12} md={3}>
                  <Typography variant="caption" color="textSecondary">
                    Deadline
                  </Typography>
                  <Typography variant="body2">
                    {activePhase.enddatum ?
                      format(new Date(activePhase.enddatum), 'dd.MM.yyyy HH:mm', { locale: de })
                      : '-'}
                  </Typography>
                </Grid>
              )}
              <Grid item xs={12} md={3}>
                <Typography variant="caption" color="textSecondary">
                  Verbleibende Zeit
                </Typography>
                <Typography variant="body2" color={getTimeRemaining() && getTimeRemaining()! < 1440 ? 'error' : 'textPrimary'}>
                  <Timer sx={{ fontSize: 16, mr: 0.5, verticalAlign: 'middle' }} />
                  {formatTimeRemaining(getTimeRemaining())}
                </Typography>
              </Grid>
              <Grid item xs={12} md={3}>
                <Typography variant="caption" color="textSecondary">
                  Ihr Status
                </Typography>
                <Box>
                  {hasSubmittedInCurrentPhase() ? (
                    <Chip
                      label="Bereits eingereicht"
                      color="success"
                      size="small"
                      icon={<CheckCircle />}
                    />
                  ) : canSubmit() ? (
                    <Chip
                      label="Einreichung möglich"
                      color="primary"
                      size="small"
                    />
                  ) : (
                    <Chip
                      label="Einreichung nicht möglich"
                      color="error"
                      size="small"
                      icon={<Block />}
                    />
                  )}
                </Box>
              </Grid>
            </Grid>

            {/* Submission Status Details */}
            {submissionStatus && (
              <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.50', borderRadius: 1 }}>
                {submissionStatus.kann_einreichen ? (
                  <Alert severity="success">
                    <AlertTitle>Sie können eine Planung einreichen</AlertTitle>
                    {currentPlanung ? (
                      <Typography variant="body2">
                        Sie haben eine Planung mit Status: {currentPlanung.status}
                      </Typography>
                    ) : (
                      <Typography variant="body2">
                        Erstellen Sie jetzt Ihre Semesterplanung
                      </Typography>
                    )}
                  </Alert>
                ) : (
                  <Alert severity="warning">
                    <AlertTitle>Einreichung nicht möglich</AlertTitle>
                    <Typography variant="body2">
                      {submissionStatus.grund === 'bereits_genehmigt' && 'Sie haben bereits eine genehmigte Planung in dieser Phase.'}
                      {submissionStatus.grund === 'phase_abgelaufen' && 'Die Deadline für Einreichungen ist abgelaufen.'}
                      {submissionStatus.grund === 'keine_aktive_phase' && 'Es ist keine aktive Phase vorhanden.'}
                    </Typography>
                  </Alert>
                )}
              </Box>
            )}
          </CardContent>
        </Card>
      ) : (
        <Alert severity="warning" sx={{ mb: 3 }}>
          <AlertTitle>Keine aktive Planungsphase</AlertTitle>
          <Typography variant="body2">
            Derzeit ist keine Planungsphase aktiv. Bitte warten Sie, bis der Dekan die nächste Phase startet.
          </Typography>
        </Alert>
      )}

      {/* Quick Action Card */}
      {planningSemester && !currentPlanung && (
        <Card sx={{ mb: 3, bgcolor: 'primary.lighter', borderLeft: 4, borderColor: 'primary.main' }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Assignment color="primary" sx={{ fontSize: 48 }} />
              <Box sx={{ flex: 1 }}>
                <Typography variant="h6" gutterBottom>
                  Erstellen Sie Ihre Semesterplanung
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Die Planungsphase für {planningSemester.bezeichnung} ist geöffnet.
                  Erstellen Sie jetzt Ihre Planung in 8 einfachen Schritten.
                </Typography>
              </Box>
              <Button
                variant="contained"
                size="large"
                startIcon={<Add />}
                onClick={handleCreatePlanung}
                sx={{ minWidth: 180 }}
              >
                Neue Planung
              </Button>
            </Box>
          </CardContent>
        </Card>
      )}

      {/* Current Planning Card */}
      {currentPlanung && (
        <Card sx={{ mb: 3, borderLeft: 4, borderColor: 'primary.main' }}>
          <CardContent>
            <Box sx={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', mb: 2 }}>
              <Box>
                <Typography variant="h6" gutterBottom>
                  Aktuelle Planung: {planningSemester?.bezeichnung}
                </Typography>
                <Box sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
                  <Chip 
                    label={currentPlanung.status} 
                    color={getStatusColor(currentPlanung.status) as any}
                    size="small"
                    icon={getStatusIcon(currentPlanung.status)}
                  />
                  <Typography variant="body2" color="text.secondary">
                    • {currentPlanung.gesamt_sws || 0} SWS geplant
                  </Typography>
                </Box>
              </Box>
              <Box sx={{ display: 'flex', gap: 1 }}>
                {currentPlanung.status === 'entwurf' && (
                  <Button
                    variant="contained"
                    startIcon={<Edit />}
                    onClick={() => navigate(`/semesterplanung/${currentPlanung.id}/edit`)}
                  >
                    Bearbeiten
                  </Button>
                )}
                {currentPlanung.status !== 'entwurf' && (
                  <Button
                    variant="outlined"
                    startIcon={<Visibility />}
                    onClick={() => navigate(`/semesterplanung/${currentPlanung.id}`)}
                  >
                    Ansehen
                  </Button>
                )}
              </Box>
            </Box>

            {currentPlanung.notizen && (
              <Box sx={{ mt: 2, p: 2, bgcolor: 'background.default', borderRadius: 1 }}>
                <Typography variant="body2" color="text.secondary">
                  Notizen: {currentPlanung.notizen}
                </Typography>
              </Box>
            )}

            {currentPlanung.status === 'abgelehnt' && currentPlanung.ablehnungsgrund && (
              <Alert severity="error" sx={{ mt: 2 }}>
                <Typography variant="subtitle2" gutterBottom>
                  Ablehnungsgrund:
                </Typography>
                <Typography variant="body2">
                  {currentPlanung.ablehnungsgrund}
                </Typography>
              </Alert>
            )}
          </CardContent>
        </Card>
      )}

      {/* Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <Box>
                <Typography variant="h4" fontWeight={600}>
                  {stats.gesamt}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Gesamt
                </Typography>
              </Box>
              <Assignment color="primary" sx={{ fontSize: 40 }} />
            </Box>
          </Paper>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <Box>
                <Typography variant="h4" fontWeight={600}>
                  {stats.entwurf}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Entwürfe
                </Typography>
              </Box>
              <Edit color="action" sx={{ fontSize: 40 }} />
            </Box>
          </Paper>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <Box>
                <Typography variant="h4" fontWeight={600} color="warning.main">
                  {stats.eingereicht}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Eingereicht
                </Typography>
              </Box>
              <Schedule color="warning" sx={{ fontSize: 40 }} />
            </Box>
          </Paper>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Paper sx={{ p: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <Box>
                <Typography variant="h4" fontWeight={600} color="success.main">
                  {stats.freigegeben}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Freigegeben
                </Typography>
              </Box>
              <CheckCircle color="success" sx={{ fontSize: 40 }} />
            </Box>
          </Paper>
        </Grid>
      </Grid>

      {/* Planungen List */}
      <Paper sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Typography variant="h6" fontWeight={600}>
            Meine Planungen
          </Typography>
          <Button
            variant="outlined"
            onClick={() => navigate('/semesterplanung')}
            endIcon={<ArrowForward />}
          >
            Alle anzeigen
          </Button>
        </Box>

        {Array.isArray(planungen) && planungen.length > 0 ? (
          <List>
            {planungen.slice(0, 5).map((planung, index) => (
              <React.Fragment key={planung.id}>
                {index > 0 && <Divider />}
                <ListItem
                  sx={{
                    '&:hover': { bgcolor: 'action.hover' },
                    cursor: 'pointer',
                  }}
                  onClick={() => navigate(`/semesterplanung/${planung.id}`)}
                >
                  <ListItemText
                    primary={
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Typography variant="subtitle1">
                          {planung.semester?.bezeichnung || 'Unbekanntes Semester'}
                        </Typography>
                        <Chip
                          label={planung.status}
                          size="small"
                          color={getStatusColor(planung.status) as any}
                          icon={getStatusIcon(planung.status)}
                        />
                      </Box>
                    }
                    secondary={
                      <Typography variant="body2" color="text.secondary">
                        {planung.gesamt_sws || 0} SWS • Erstellt am{' '}
                        {planung.created_at ? new Date(planung.created_at).toLocaleDateString('de-DE') : 'unbekannt'}
                      </Typography>
                    }
                  />
                  <ListItemSecondaryAction>
                    <IconButton
                      edge="end"
                      onClick={(e) => {
                        e.stopPropagation();
                        navigate(`/semesterplanung/${planung.id}`);
                      }}
                    >
                      {planung.status === 'entwurf' ? <Edit /> : <Visibility />}
                    </IconButton>
                  </ListItemSecondaryAction>
                </ListItem>
              </React.Fragment>
            ))}
          </List>
        ) : (
          <Box sx={{ textAlign: 'center', py: 4 }}>
            <Assignment sx={{ fontSize: 64, color: 'text.disabled', mb: 2 }} />
            <Typography variant="h6" color="text.secondary" gutterBottom>
              Noch keine Planungen erstellt
            </Typography>
            <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
              Erstellen Sie Ihre erste Semesterplanung
            </Typography>
            {planningSemester && (
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={handleCreatePlanung}
              >
                Neue Planung erstellen
              </Button>
            )}
          </Box>
        )}
      </Paper>

      {/* Professor Phasen Historie - Gruppiert nach Phasen */}
      <ProfessorPhasenHistorie
        open={showPhaseHistory}
        onClose={() => setShowPhaseHistory(false)}
      />
    </Container>
  );
};

export default ProfessorDashboard;