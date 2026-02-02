import React, { useEffect, useState } from 'react';
import {
  Container,
  Grid,
  Paper,
  Typography,
  Box,
  Card,
  CardContent,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Stack,
  CircularProgress,
  List,
  ListItem,
  ListItemText,
  Divider,
  Chip,
  Alert,
  Collapse,
  Tooltip,
  TextField,
} from '@mui/material';
import {
  Assignment,
  Work,
  Analytics,
  Close,
  TrendingUp,
  Group,
  School,
  Folder,
  ArrowForward,
  CheckCircle,
  Cancel,
  ExpandMore,
  ExpandLess,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import usePlanungPhaseStore from '../store/planungPhaseStore';
import planungService from '../services/planungService';
import auftragService from '../services/auftragService';
import semesterService from '../services/semesterService';
import { Semester } from '../types/semester.types';
import { SemesterAuftrag } from '../types/auftrag.types';
import { Semesterplanung } from '../types/planung.types';
import { getErrorMessage } from '../utils/errorUtils';
import DekanStatistics from '../components/dekan/DekanStatistics';
import NichtZugeordneteModule from '../components/dashboard/NichtZugeordneteModule';
import DozentenPlanungsfortschritt from '../components/dashboard/DozentenPlanungsfortschritt';
import useAuftragStore from '../store/auftragStore';

/**
 * Dekan Dashboard - Hauptübersicht
 * =================================
 * Schneller Überblick für den Dekan
 *
 * Features:
 * - Quick Stats (Eingereichte Planungen, Aufträge)
 * - Schnellaktionen
 * - Statistiken (auf Knopfdruck)
 * - Nicht zugeordnete Module
 */

interface QuickStats {
  eingereichtePlanungen: number;  // Planungen mit Status "eingereicht" (warten auf Genehmigung)
  offeneAuftraege: number;         // Beantragte Semesteraufträge
  genehmigteAuftraege: number;     // Genehmigte Semesteraufträge
}

const DekanDashboard: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const { fetchActivePhase } = usePlanungPhaseStore();
  const { lastUpdate, triggerRefresh } = useAuftragStore();

  const [loading, setLoading] = useState(true);
  const [planningSemester, setPlanningSemester] = useState<Semester | null>(null);
  const [quickStats, setQuickStats] = useState<QuickStats>({
    eingereichtePlanungen: 0,
    offeneAuftraege: 0,
    genehmigteAuftraege: 0,
  });
  const [beantrageAuftraege, setBeantrageAuftraege] = useState<SemesterAuftrag[]>([]);
  const [genehmigteAuftraege, setGenehmigteAuftraege] = useState<SemesterAuftrag[]>([]);
  const [statistikDialogOpen, setStatistikDialogOpen] = useState(false);
  const [genehmigteExpanded, setGenehmigteExpanded] = useState(false);
  const [actionLoading, setActionLoading] = useState<number | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [actionSuccess, setActionSuccess] = useState<string | null>(null);

  // Ablehnung Dialog
  const [ablehnungDialogOpen, setAblehnungDialogOpen] = useState(false);
  const [ablehnungAuftragId, setAblehnungAuftragId] = useState<number | null>(null);
  const [ablehnungGrund, setAblehnungGrund] = useState('');

  useEffect(() => {
    loadDashboardData();
    fetchActivePhase();
  }, []);

  // Auto-refresh when AuftragStore changes (Professor submits new request)
  useEffect(() => {
    if (lastUpdate && planningSemester) {
      loadAuftraegeOnly();
    }
  }, [lastUpdate, planningSemester]);

  // Only reload Aufträge (lighter refresh)
  const loadAuftraegeOnly = async () => {
    if (!planningSemester) return;
    try {
      const beantragtRes = await auftragService.getAuftraegeFuerSemester(
        planningSemester.id,
        undefined,
        'beantragt'
      );
      setBeantrageAuftraege(beantragtRes);

      const genehmigteRes = await auftragService.getAuftraegeFuerSemester(
        planningSemester.id,
        undefined,
        'genehmigt'
      );
      setGenehmigteAuftraege(genehmigteRes);

      setQuickStats(prev => ({
        ...prev,
        offeneAuftraege: beantragtRes.length,
        genehmigteAuftraege: genehmigteRes.length,
      }));
    } catch (err) {
      // Error logged via API interceptor('Error refreshing aufträge:', err);
    }
  };

  const loadDashboardData = async () => {
    setLoading(true);
    try {
      // Load planning semester
      const semesterRes = await semesterService.getPlanningSemester();
      let currentSemester: Semester | null = null;
      if (semesterRes.success && semesterRes.data) {
        currentSemester = semesterRes.data;
        setPlanningSemester(currentSemester);
      }

      // Load eingereichte Planungen count (nur Status "eingereicht")
      const planungenRes = await planungService.getEingereichtePlanungen();
      const eingereichtePlanungen = planungenRes.success && planungenRes.data
        ? planungenRes.data.filter((p: Semesterplanung) => p.status === 'eingereicht').length
        : 0;

      // Load Semesteraufträge (beantragt und genehmigt)
      let offeneAuftraege = 0;
      let genehmigteCount = 0;
      if (currentSemester) {
        try {
          // Lade beantragte Aufträge
          const beantragtRes = await auftragService.getAuftraegeFuerSemester(
            currentSemester.id,
            undefined,
            'beantragt'
          );
          setBeantrageAuftraege(beantragtRes);
          offeneAuftraege = beantragtRes.length;

          // Lade genehmigte Aufträge
          const genehmigteRes = await auftragService.getAuftraegeFuerSemester(
            currentSemester.id,
            undefined,
            'genehmigt'
          );
          setGenehmigteAuftraege(genehmigteRes);
          genehmigteCount = genehmigteRes.length;
        } catch (err) {
          // Error logged via API interceptor('Error loading aufträge:', err);
        }
      }

      setQuickStats({
        eingereichtePlanungen,
        offeneAuftraege,
        genehmigteAuftraege: genehmigteCount,
      });
    } catch (error) {
      // Error logged via API interceptor('Dashboard load error:', error);
    } finally {
      setLoading(false);
    }
  };

  // Auftrag genehmigen
  const handleGenehmigen = async (auftragId: number) => {
    setActionLoading(auftragId);
    setActionError(null);
    try {
      await auftragService.genehmigAuftrag(auftragId);
      setActionSuccess('Auftrag wurde genehmigt');
      // Reload data & trigger store for sync
      await loadDashboardData();
      if (planningSemester) {
        await triggerRefresh(planningSemester.id);
      }
      setTimeout(() => setActionSuccess(null), 3000);
    } catch (error: unknown) {
      setActionError(getErrorMessage(error, 'Fehler beim Genehmigen'));
    } finally {
      setActionLoading(null);
    }
  };

  // Ablehnung Dialog öffnen
  const openAblehnungDialog = (auftragId: number) => {
    setAblehnungAuftragId(auftragId);
    setAblehnungGrund('');
    setAblehnungDialogOpen(true);
  };

  // Auftrag ablehnen
  const handleAblehnen = async () => {
    if (!ablehnungAuftragId) return;

    setActionLoading(ablehnungAuftragId);
    setActionError(null);
    try {
      await auftragService.lehneAuftragAb(ablehnungAuftragId, ablehnungGrund || undefined);
      setAblehnungDialogOpen(false);
      setActionSuccess('Auftrag wurde abgelehnt');
      // Reload data & trigger store for sync
      await loadDashboardData();
      if (planningSemester) {
        await triggerRefresh(planningSemester.id);
      }
      setTimeout(() => setActionSuccess(null), 3000);
    } catch (error: unknown) {
      setActionError(getErrorMessage(error, 'Fehler beim Ablehnen'));
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <Container maxWidth="xl">
      {/* Welcome Header */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" gutterBottom>
          Willkommen, {user?.vorname || 'Dekan'}
        </Typography>
        <Typography variant="body2" color="text.secondary">
          {new Date().toLocaleDateString('de-DE', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric'
          })}
        </Typography>
      </Box>

      {/* Quick Stats Cards */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        {/* Eingereichte Planungen */}
        <Grid item xs={12} md={4}>
          <Card
            elevation={3}
            sx={{
              cursor: 'pointer',
              transition: 'all 0.2s',
              '&:hover': {
                elevation: 6,
                transform: 'translateY(-4px)',
              }
            }}
            onClick={() => navigate('/dekan/planungen')}
          >
            <CardContent>
              <Stack spacing={2}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Assignment sx={{ fontSize: 50, color: 'warning.main' }} />
                  {loading ? (
                    <CircularProgress size={40} />
                  ) : (
                    <Typography variant="h2" color="warning.main" fontWeight={700}>
                      {quickStats.eingereichtePlanungen}
                    </Typography>
                  )}
                </Box>
                <Typography variant="h6">Zu prüfende Planungen</Typography>
                <Typography variant="body2" color="text.secondary">
                  Eingereichte Planungen warten auf Genehmigung
                </Typography>
              </Stack>
            </CardContent>
          </Card>
        </Grid>

        {/* Offene Aufträge */}
        <Grid item xs={12} md={4}>
          <Card
            elevation={3}
            sx={{
              cursor: 'pointer',
              transition: 'all 0.2s',
              '&:hover': {
                elevation: 6,
                transform: 'translateY(-4px)',
              }
            }}
            onClick={() => navigate('/einstellungen')}
          >
            <CardContent>
              <Stack spacing={2}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Work sx={{ fontSize: 50, color: 'info.main' }} />
                  {loading ? (
                    <CircularProgress size={40} />
                  ) : (
                    <Typography variant="h2" color="info.main" fontWeight={700}>
                      {quickStats.offeneAuftraege}
                    </Typography>
                  )}
                </Box>
                <Typography variant="h6">Eingereichte Aufträge</Typography>
                <Typography variant="body2" color="text.secondary">
                  Beantragte Semesteraufträge warten auf Genehmigung
                </Typography>
              </Stack>
            </CardContent>
          </Card>
        </Grid>

        {/* Statistiken Button */}
        <Grid item xs={12} md={4}>
          <Card
            elevation={3}
            sx={{
              cursor: 'pointer',
              transition: 'all 0.2s',
              '&:hover': {
                elevation: 6,
                transform: 'translateY(-4px)',
              }
            }}
            onClick={() => setStatistikDialogOpen(true)}
          >
            <CardContent>
              <Stack spacing={2}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <Analytics sx={{ fontSize: 50, color: 'success.main' }} />
                  <TrendingUp sx={{ fontSize: 50, color: 'success.main' }} />
                </Box>
                <Typography variant="h6">Statistiken</Typography>
                <Typography variant="body2" color="text.secondary">
                  Detaillierte Auswertungen anzeigen
                </Typography>
              </Stack>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Schnellaktionen */}
      <Paper elevation={2} sx={{ mb: 4, p: 3 }}>
        <Typography variant="h6" gutterBottom sx={{ mb: 3 }}>
          Schnellaktionen
        </Typography>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6} md={3}>
            <Button
              fullWidth
              variant="outlined"
              size="large"
              startIcon={<Assignment />}
              onClick={() => navigate('/dekan/planungen')}
            >
              Planungen prüfen
            </Button>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Button
              fullWidth
              variant="outlined"
              size="large"
              startIcon={<Work />}
              onClick={() => navigate('/einstellungen')}
            >
              Aufträge verwalten
            </Button>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Button
              fullWidth
              variant="outlined"
              size="large"
              startIcon={<Folder />}
              onClick={() => navigate('/dekan/modul-verwaltung')}
            >
              Modulverwaltung
            </Button>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Button
              fullWidth
              variant="outlined"
              size="large"
              startIcon={<Group />}
              onClick={() => navigate('/dozenten')}
            >
              Dozenten
            </Button>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Button
              fullWidth
              variant="outlined"
              size="large"
              startIcon={<School />}
              onClick={() => navigate('/module')}
            >
              Module
            </Button>
          </Grid>
        </Grid>
      </Paper>

      {/* Feedback Alerts */}
      {actionSuccess && (
        <Alert severity="success" sx={{ mb: 2 }} onClose={() => setActionSuccess(null)}>
          {actionSuccess}
        </Alert>
      )}
      {actionError && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setActionError(null)}>
          {actionError}
        </Alert>
      )}

      {/* Beantragte Aufträge Liste - Warten auf Genehmigung */}
      {beantrageAuftraege.length > 0 && (
        <Paper elevation={2} sx={{ mb: 4, p: 3 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Typography variant="h6">
                Wartende Semesteraufträge
              </Typography>
              <Chip label={beantrageAuftraege.length} color="warning" size="small" />
            </Box>
            <Button
              endIcon={<ArrowForward />}
              onClick={() => navigate('/einstellungen')}
            >
              Alle anzeigen
            </Button>
          </Box>

          <List>
            {beantrageAuftraege.map((auftrag, index) => (
              <React.Fragment key={auftrag.id}>
                {index > 0 && <Divider />}
                <ListItem
                  sx={{
                    py: 2,
                    '&:hover': { bgcolor: 'action.hover' }
                  }}
                  secondaryAction={
                    <Stack direction="row" spacing={1}>
                      <Tooltip title="Genehmigen">
                        <IconButton
                          color="success"
                          onClick={(e) => {
                            e.stopPropagation();
                            handleGenehmigen(auftrag.id);
                          }}
                          disabled={actionLoading === auftrag.id}
                        >
                          {actionLoading === auftrag.id ? (
                            <CircularProgress size={20} />
                          ) : (
                            <CheckCircle />
                          )}
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Ablehnen">
                        <IconButton
                          color="error"
                          onClick={(e) => {
                            e.stopPropagation();
                            openAblehnungDialog(auftrag.id);
                          }}
                          disabled={actionLoading === auftrag.id}
                        >
                          <Cancel />
                        </IconButton>
                      </Tooltip>
                    </Stack>
                  }
                >
                  <ListItemText
                    primary={
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Typography variant="body1" fontWeight={500}>
                          {auftrag.dozent?.name || 'Unbekannt'}
                        </Typography>
                        <Chip
                          label="Beantragt"
                          size="small"
                          color="warning"
                        />
                      </Box>
                    }
                    secondary={
                      <Box sx={{ mt: 0.5 }}>
                        <Typography variant="body2" color="text.secondary">
                          {auftrag.auftrag?.name || 'Unbekannt'} • {auftrag.sws || 0} SWS
                        </Typography>
                        <Typography variant="caption" color="text.disabled">
                          Eingereicht am: {auftrag.created_at
                            ? new Date(auftrag.created_at).toLocaleDateString('de-DE')
                            : 'Unbekannt'
                          }
                        </Typography>
                      </Box>
                    }
                  />
                </ListItem>
              </React.Fragment>
            ))}
          </List>
        </Paper>
      )}

      {/* Genehmigte Aufträge Liste */}
      {genehmigteAuftraege.length > 0 && (
        <Paper elevation={2} sx={{ mb: 4, p: 3 }}>
          <Box
            sx={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              cursor: 'pointer',
            }}
            onClick={() => setGenehmigteExpanded(!genehmigteExpanded)}
          >
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Typography variant="h6">
                Genehmigte Semesteraufträge
              </Typography>
              <Chip label={genehmigteAuftraege.length} color="success" size="small" />
              <Typography variant="body2" color="text.secondary">
                (Gesamt: {genehmigteAuftraege.reduce((sum, a) => sum + a.sws, 0)} SWS)
              </Typography>
            </Box>
            <IconButton>
              {genehmigteExpanded ? <ExpandLess /> : <ExpandMore />}
            </IconButton>
          </Box>

          <Collapse in={genehmigteExpanded}>
            <List sx={{ mt: 2 }}>
              {genehmigteAuftraege.map((auftrag, index) => (
                <React.Fragment key={auftrag.id}>
                  {index > 0 && <Divider />}
                  <ListItem sx={{ py: 1.5 }}>
                    <ListItemText
                      primary={
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Typography variant="body1">
                            {auftrag.dozent?.name || 'Unbekannt'}
                          </Typography>
                          <Chip
                            label="Genehmigt"
                            size="small"
                            color="success"
                          />
                        </Box>
                      }
                      secondary={
                        <Box sx={{ mt: 0.5 }}>
                          <Typography variant="body2" color="text.secondary">
                            {auftrag.auftrag?.name || 'Unbekannt'} • {auftrag.sws || 0} SWS
                          </Typography>
                          {auftrag.genehmigt_am && (
                            <Typography variant="caption" color="text.disabled">
                              Genehmigt am: {new Date(auftrag.genehmigt_am).toLocaleDateString('de-DE')}
                            </Typography>
                          )}
                        </Box>
                      }
                    />
                  </ListItem>
                </React.Fragment>
              ))}
            </List>
          </Collapse>
        </Paper>
      )}

      {/* Nicht zugeordnete Module */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12}>
          <NichtZugeordneteModule
            semesterId={planningSemester?.id}
            poId={1}
          />
        </Grid>
      </Grid>

      {/* Dozenten Planungsfortschritt */}
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <DozentenPlanungsfortschritt
            semesterId={planningSemester?.id}
          />
        </Grid>
      </Grid>

      {/* Statistiken Dialog */}
      <Dialog
        open={statistikDialogOpen}
        onClose={() => setStatistikDialogOpen(false)}
        maxWidth="xl"
        fullWidth
        PaperProps={{
          sx: { height: '90vh' }
        }}
      >
        <DialogTitle>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <Typography variant="h5" component="div">
              Detaillierte Statistiken - {planningSemester?.bezeichnung || 'Kein Semester'}
            </Typography>
            <IconButton onClick={() => setStatistikDialogOpen(false)}>
              <Close />
            </IconButton>
          </Box>
        </DialogTitle>
        <DialogContent dividers>
          {planningSemester ? (
            <DekanStatistics
              semesterId={planningSemester.id}
              semesterBezeichnung={planningSemester.bezeichnung}
            />
          ) : (
            <Typography variant="body1" color="text.secondary" align="center" sx={{ py: 4 }}>
              Kein aktives Semester gefunden
            </Typography>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setStatistikDialogOpen(false)}>
            Schließen
          </Button>
        </DialogActions>
      </Dialog>

      {/* Ablehnung Dialog */}
      <Dialog
        open={ablehnungDialogOpen}
        onClose={() => setAblehnungDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Semesterauftrag ablehnen</DialogTitle>
        <DialogContent>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Bitte geben Sie optional einen Grund für die Ablehnung an.
          </Typography>
          <TextField
            autoFocus
            label="Ablehnungsgrund (optional)"
            fullWidth
            multiline
            rows={3}
            value={ablehnungGrund}
            onChange={(e) => setAblehnungGrund(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAblehnungDialogOpen(false)}>
            Abbrechen
          </Button>
          <Button
            onClick={handleAblehnen}
            color="error"
            variant="contained"
            disabled={actionLoading !== null}
          >
            {actionLoading !== null ? <CircularProgress size={20} /> : 'Ablehnen'}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default DekanDashboard;
