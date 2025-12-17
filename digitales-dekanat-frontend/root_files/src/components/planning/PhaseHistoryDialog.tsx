import { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Box,
  Typography,
  Card,
  CardContent,
  Chip,
  Grid,
  LinearProgress,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  Alert,
  CircularProgress,
  Paper,
  Accordion,
  AccordionSummary,
  AccordionDetails,
} from '@mui/material';
import {
  Timeline,
  TimelineItem,
  TimelineSeparator,
  TimelineConnector,
  TimelineContent,
  TimelineDot,
  TimelineOppositeContent,
} from '@mui/lab';
import {
  PlayArrow,
  Stop,
  CheckCircle,
  Cancel,
  Schedule,
  Assessment,
  Person,
  School,
  TrendingUp,
  Download,
  ExpandMore,
  Timer,
  DateRange,
  Group,
  Assignment,
} from '@mui/icons-material';
import { format, differenceInDays } from 'date-fns';
import { de } from 'date-fns/locale';
import usePlanungPhaseStore from '../../store/planungPhaseStore';
import useAuthStore from '../../store/authStore';
import { PhaseHistoryEntry } from '../../types/planungPhase.types';

interface PhaseHistoryDialogProps {
  open: boolean;
  onClose: () => void;
}

const PhaseHistoryDialog: React.FC<PhaseHistoryDialogProps> = ({ open, onClose }) => {
  const { user } = useAuthStore();
  const {
    phaseHistory,
    loading,
    error,
    fetchPhaseHistory,
    generatePhaseReport,
    clearError,
  } = usePlanungPhaseStore();

  const [selectedPhase, setSelectedPhase] = useState<PhaseHistoryEntry | null>(null);
  const [expandedPhase, setExpandedPhase] = useState<number | null>(null);

  const isDekan = user?.rolle === 'Dekan';
  const isProfessor = user?.rolle === 'Professor' || user?.rolle === 'Lehrbeauftragter';

  useEffect(() => {
    if (open) {
      // Load history based on user role
      const professorId = isProfessor ? user?.id : undefined;
      fetchPhaseHistory(professorId);
    }
  }, [open]);

  const handleGenerateReport = async (phaseId: number) => {
    try {
      await generatePhaseReport(phaseId);
    } catch (error) {
      console.error('Fehler beim Generieren des Berichts:', error);
    }
  };

  const getPhaseStatusIcon = (phase: PhaseHistoryEntry) => {
    if (phase.phase.ist_aktiv) {
      return <PlayArrow />;
    } else {
      return <Stop />;
    }
  };

  const getPhaseStatusColor = (phase: PhaseHistoryEntry): 'primary' | 'secondary' | 'success' | 'error' | 'warning' | 'info' | 'grey' => {
    if (phase.phase.ist_aktiv) {
      return 'primary';
    } else if (!phase.statistik) {
      return 'grey';
    } else if (phase.statistik.genehmigungsquote >= 80) {
      return 'success';
    } else if (phase.statistik.genehmigungsquote >= 50) {
      return 'warning';
    } else {
      return 'error';
    }
  };

  const getSubmissionStatusChip = (entry: PhaseHistoryEntry) => {
    if (!entry.eigene_einreichung) {
      return <Chip label="Nicht eingereicht" size="small" color="default" />;
    }

    switch (entry.eigene_einreichung.status) {
      case 'freigegeben':
        return <Chip label="Genehmigt" size="small" color="success" icon={<CheckCircle />} />;
      case 'abgelehnt':
        return <Chip label="Abgelehnt" size="small" color="error" icon={<Cancel />} />;
      case 'eingereicht':
        return <Chip label="Eingereicht" size="small" color="warning" icon={<Schedule />} />;
      default:
        return <Chip label="Unbekannt" size="small" color="default" />;
    }
  };

  const calculatePhaseDuration = (startDate: string, endDate?: string) => {
    const start = new Date(startDate);
    const end = endDate ? new Date(endDate) : new Date();
    return differenceInDays(end, start);
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="lg" fullWidth disableRestoreFocus>
      <DialogTitle>
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Typography variant="h6">Planungsphasen Historie</Typography>
          <Typography variant="caption" color="textSecondary">
            {phaseHistory.length} Phasen gefunden
          </Typography>
        </Box>
      </DialogTitle>
      <DialogContent dividers>
        {error && (
          <Alert severity="error" onClose={clearError} sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        {loading ? (
          <Box display="flex" justifyContent="center" p={3}>
            <CircularProgress />
          </Box>
        ) : phaseHistory.length === 0 ? (
          <Alert severity="info">
            Keine Phasenhistorie verfügbar
          </Alert>
        ) : (
          <Timeline position="alternate">
            {phaseHistory.map((entry, index) => (
              <TimelineItem key={entry.phase.id}>
                <TimelineOppositeContent color="text.secondary">
                  <Typography variant="caption">
                    {entry.phase.startdatum ?
                      format(new Date(entry.phase.startdatum), 'dd.MM.yyyy', { locale: de })
                      : '-'}
                  </Typography>
                  <Typography variant="caption" display="block">
                    {calculatePhaseDuration(entry.phase.startdatum, entry.phase.geschlossen_am)} Tage
                  </Typography>
                </TimelineOppositeContent>
                <TimelineSeparator>
                  <TimelineDot color={getPhaseStatusColor(entry)}>
                    {getPhaseStatusIcon(entry)}
                  </TimelineDot>
                  {index < phaseHistory.length - 1 && <TimelineConnector />}
                </TimelineSeparator>
                <TimelineContent>
                  <Card sx={{ cursor: 'pointer' }} onClick={() => setExpandedPhase(expandedPhase === entry.phase.id ? null : entry.phase.id)}>
                    <CardContent>
                      <Box display="flex" justifyContent="space-between" alignItems="center">
                        <Typography variant="h6" component="div">
                          {entry.phase.name}
                        </Typography>
                        {entry.phase.ist_aktiv && (
                          <Chip label="Aktiv" color="primary" size="small" />
                        )}
                      </Box>

                      {entry.statistik && (
                        <Box sx={{ mt: 1 }}>
                          <Grid container spacing={1}>
                            <Grid item xs={12} md={6}>
                              <Typography variant="caption" color="textSecondary">
                                <Group sx={{ fontSize: 14, mr: 0.5 }} />
                                {entry.statistik.professoren_eingereicht} / {entry.statistik.professoren_gesamt} Professoren
                              </Typography>
                            </Grid>
                            <Grid item xs={12} md={6}>
                              <Typography variant="caption" color="textSecondary">
                                <TrendingUp sx={{ fontSize: 14, mr: 0.5 }} />
                                {entry.statistik.einreichungsquote.toFixed(0)}% Einreichungsquote
                              </Typography>
                            </Grid>
                          </Grid>

                          {/* Progress Bar */}
                          <Box sx={{ mt: 1 }}>
                            <LinearProgress
                              variant="determinate"
                              value={entry.statistik.einreichungsquote}
                              sx={{ height: 6, borderRadius: 1 }}
                            />
                          </Box>
                        </Box>
                      )}

                      {/* Personal submission status for professors */}
                      {isProfessor && (
                        <Box sx={{ mt: 1 }}>
                          {getSubmissionStatusChip(entry)}
                        </Box>
                      )}

                      {/* Expanded Details */}
                      {expandedPhase === entry.phase.id && (
                        <Accordion expanded sx={{ mt: 2 }}>
                          <AccordionSummary>
                            <Typography variant="subtitle2">Details</Typography>
                          </AccordionSummary>
                          <AccordionDetails>
                            <Grid container spacing={2}>
                              <Grid item xs={12} md={4}>
                                <Paper sx={{ p: 2 }}>
                                  <Typography variant="caption" color="textSecondary">
                                    <DateRange sx={{ fontSize: 14, mr: 0.5 }} />
                                    Zeitraum
                                  </Typography>
                                  <Typography variant="body2">
                                    {entry.phase.startdatum ?
                                      format(new Date(entry.phase.startdatum), 'dd.MM.yyyy', { locale: de })
                                      : '-'}
                                    {entry.phase.enddatum && (
                                      <> - {entry.phase.enddatum ?
                                        format(new Date(entry.phase.enddatum), 'dd.MM.yyyy', { locale: de })
                                        : '-'}</>
                                    )}
                                  </Typography>
                                </Paper>
                              </Grid>

                              {entry.statistik && (
                                <>
                                  <Grid item xs={12} md={4}>
                                    <Paper sx={{ p: 2 }}>
                                      <Typography variant="caption" color="textSecondary">
                                        <Assessment sx={{ fontSize: 14, mr: 0.5 }} />
                                        Genehmigungsquote
                                      </Typography>
                                      <Typography variant="h6">
                                        {entry.statistik.genehmigungsquote.toFixed(1)}%
                                      </Typography>
                                    </Paper>
                                  </Grid>

                                  <Grid item xs={12} md={4}>
                                    <Paper sx={{ p: 2 }}>
                                      <Typography variant="caption" color="textSecondary">
                                        <Timer sx={{ fontSize: 14, mr: 0.5 }} />
                                        Ø Bearbeitungszeit
                                      </Typography>
                                      <Typography variant="h6">
                                        {entry.statistik.durchschnittliche_bearbeitungszeit.toFixed(1)}h
                                  </Typography>
                                </Paper>
                              </Grid>
                                </>
                              )}

                              <Grid item xs={12}>
                                <Paper sx={{ p: 2 }}>
                                  <Typography variant="caption" color="textSecondary">
                                    Statistiken
                                  </Typography>
                                  <List dense>
                                    <ListItem>
                                      <ListItemText
                                        primary="Einreichungen"
                                        secondary={`${entry.phase.anzahl_einreichungen} gesamt`}
                                      />
                                    </ListItem>
                                    <ListItem>
                                      <ListItemText
                                        primary="Genehmigt"
                                        secondary={`${entry.phase.anzahl_genehmigt} Planungen`}
                                      />
                                    </ListItem>
                                    <ListItem>
                                      <ListItemText
                                        primary="Abgelehnt"
                                        secondary={`${entry.phase.anzahl_abgelehnt} Planungen`}
                                      />
                                    </ListItem>
                                  </List>
                                </Paper>
                              </Grid>

                              {/* Top Modules */}
                              {entry.statistik?.top_module && entry.statistik.top_module.length > 0 && (
                                <Grid item xs={12}>
                                  <Paper sx={{ p: 2 }}>
                                    <Typography variant="caption" color="textSecondary">
                                      <School sx={{ fontSize: 14, mr: 0.5 }} />
                                      Top Module
                                    </Typography>
                                    <List dense>
                                      {entry.statistik.top_module.slice(0, 3).map((modul, idx) => (
                                        <ListItem key={idx}>
                                          <ListItemIcon>
                                            <Assignment fontSize="small" />
                                          </ListItemIcon>
                                          <ListItemText
                                            primary={modul.modul_name}
                                            secondary={`${modul.anzahl} mal geplant`}
                                          />
                                        </ListItem>
                                      ))}
                                    </List>
                                  </Paper>
                                </Grid>
                              )}

                              {/* Professor's own submission details */}
                              {isProfessor && entry.eigene_einreichung && (
                                <Grid item xs={12}>
                                  <Paper sx={{ p: 2, bgcolor: 'action.hover' }}>
                                    <Typography variant="caption" color="textSecondary">
                                      <Person sx={{ fontSize: 14, mr: 0.5 }} />
                                      Ihre Einreichung
                                    </Typography>
                                    <Grid container spacing={1} sx={{ mt: 1 }}>
                                      <Grid item xs={12} md={4}>
                                        <Typography variant="body2">
                                          <strong>Eingereicht:</strong> {entry.eigene_einreichung.eingereicht_am ?
                                            format(new Date(entry.eigene_einreichung.eingereicht_am), 'dd.MM.yyyy HH:mm', { locale: de })
                                            : '-'}
                                        </Typography>
                                      </Grid>
                                      {entry.eigene_einreichung.freigegeben_am && (
                                        <Grid item xs={12} md={4}>
                                          <Typography variant="body2">
                                            <strong>Genehmigt:</strong> {entry.eigene_einreichung.freigegeben_am ?
                                              format(new Date(entry.eigene_einreichung.freigegeben_am), 'dd.MM.yyyy HH:mm', { locale: de })
                                              : '-'}
                                          </Typography>
                                        </Grid>
                                      )}
                                      {entry.eigene_einreichung.abgelehnt_am && (
                                        <Grid item xs={12} md={4}>
                                          <Typography variant="body2">
                                            <strong>Abgelehnt:</strong> {entry.eigene_einreichung.abgelehnt_am ?
                                              format(new Date(entry.eigene_einreichung.abgelehnt_am), 'dd.MM.yyyy HH:mm', { locale: de })
                                              : '-'}
                                          </Typography>
                                        </Grid>
                                      )}
                                    </Grid>
                                  </Paper>
                                </Grid>
                              )}

                              {/* Actions for Dekan */}
                              {isDekan && !entry.phase.ist_aktiv && (
                                <Grid item xs={12}>
                                  <Box display="flex" justifyContent="flex-end">
                                    <Button
                                      variant="outlined"
                                      startIcon={<Download />}
                                      onClick={() => handleGenerateReport(entry.phase.id)}
                                    >
                                      Bericht generieren
                                    </Button>
                                  </Box>
                                </Grid>
                              )}
                            </Grid>
                          </AccordionDetails>
                        </Accordion>
                      )}
                    </CardContent>
                  </Card>
                </TimelineContent>
              </TimelineItem>
            ))}
          </Timeline>
        )}
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>Schließen</Button>
      </DialogActions>
    </Dialog>
  );
};

export default PhaseHistoryDialog;