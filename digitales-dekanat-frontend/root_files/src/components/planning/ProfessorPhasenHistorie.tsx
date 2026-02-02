import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Box,
  Typography,
  Paper,
  Chip,
  Alert,
  CircularProgress,
  Divider,
  Grid,
  List,
  ListItem,
} from '@mui/material';
import {
  CheckCircle,
  Cancel,
  Schedule,
  Block,
  CalendarToday,
  Description,
} from '@mui/icons-material';
import { format } from 'date-fns';
import { de } from 'date-fns/locale';
import api from '../../services/api';
import { createContextLogger } from '../../utils/logger';
import { getErrorMessage } from '../../utils/errorUtils';

const log = createContextLogger('ProfessorPhasenHistorie');

interface ProfessorPhasenHistorieProps {
  open: boolean;
  onClose: () => void;
}

interface PhaseHistoryEntry {
  phase: {
    id: number;
    name: string;
    startdatum: string | null;
    enddatum: string | null;
    ist_aktiv: boolean;
    geschlossen_am: string | null;
  };
  planung: {
    id: number;
    status: string;
    gesamt_sws: number;
    eingereicht_am: string | null;
    freigegeben_am: string | null;
    abgelehnt_am: string | null;
    ablehnungsgrund: string | null;
  } | null;
  hat_planung: boolean;
  status: string | null;
  eingereicht_am: string | null;
  module_anzahl: number;
}

interface HistorieResponse {
  semester: {
    id: number;
    kuerzel: string;
    bezeichnung: string;
  };
  phasen: PhaseHistoryEntry[];
  gesamt_phasen: number;
  phasen_mit_planung: number;
}

const ProfessorPhasenHistorie: React.FC<ProfessorPhasenHistorieProps> = ({ open, onClose }) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [historie, setHistorie] = useState<HistorieResponse | null>(null);

  useEffect(() => {
    if (open) {
      loadHistorie();
    }
  }, [open]);

  const loadHistorie = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await api.get('/planung/professor/phasen-historie');

      if (response.data?.success) {
        setHistorie(response.data.data);
      } else {
        setError('Fehler beim Laden der Historie');
      }
    } catch (err: unknown) {
      log.error(' Fehler:', { err });
      setError(getErrorMessage(err, 'Fehler beim Laden der Historie'));
    } finally {
      setLoading(false);
    }
  };

  const getStatusChip = (entry: PhaseHistoryEntry) => {
    if (!entry.hat_planung) {
      return <Chip label="Keine Einreichung" size="small" icon={<Block />} />;
    }

    switch (entry.status) {
      case 'freigegeben':
        return <Chip label="Freigegeben" size="small" color="success" icon={<CheckCircle />} />;
      case 'abgelehnt':
        return <Chip label="Abgelehnt" size="small" color="error" icon={<Cancel />} />;
      case 'eingereicht':
        return <Chip label="Eingereicht" size="small" color="warning" icon={<Schedule />} />;
      case 'entwurf':
        return <Chip label="Entwurf" size="small" color="default" icon={<Description />} />;
      default:
        return <Chip label="Unbekannt" size="small" />;
    }
  };

  const getPhaseStatusLabel = (phase: PhaseHistoryEntry['phase']) => {
    if (phase.ist_aktiv) {
      return <Chip label="Aktiv" color="primary" size="small" />;
    }
    if (phase.geschlossen_am) {
      return <Chip label="Geschlossen" color="default" size="small" />;
    }
    return null;
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="lg" fullWidth>
      <DialogTitle>
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Typography variant="h6">Meine Planungshistorie</Typography>
          {historie && (
            <Typography variant="caption" color="textSecondary">
              {historie.semester.bezeichnung} • {historie.phasen_mit_planung} von {historie.gesamt_phasen} Phasen mit Planung
            </Typography>
          )}
        </Box>
      </DialogTitle>

      <DialogContent dividers>
        {loading ? (
          <Box display="flex" justifyContent="center" p={3}>
            <CircularProgress />
          </Box>
        ) : error ? (
          <Alert severity="error">{error}</Alert>
        ) : !historie || historie.phasen.length === 0 ? (
          <Alert severity="info">Keine Planungshistorie verfügbar</Alert>
        ) : (
          <Box>
            {/* Semester Info */}
            <Paper sx={{ p: 2, mb: 3, bgcolor: 'primary.50' }}>
              <Grid container spacing={2} alignItems="center">
                <Grid item>
                  <CalendarToday color="primary" />
                </Grid>
                <Grid item xs>
                  <Typography variant="h6">{historie.semester.bezeichnung}</Typography>
                  <Typography variant="caption" color="textSecondary">
                    {historie.semester.kuerzel}
                  </Typography>
                </Grid>
                <Grid item>
                  <Box textAlign="center">
                    <Typography variant="h4" color="primary">
                      {historie.phasen_mit_planung}/{historie.gesamt_phasen}
                    </Typography>
                    <Typography variant="caption" color="textSecondary">
                      Eingereicht
                    </Typography>
                  </Box>
                </Grid>
              </Grid>
            </Paper>

            {/* Phasen-Liste */}
            <List>
              {historie.phasen.map((entry, index) => (
                <React.Fragment key={entry.phase.id}>
                  <ListItem
                    sx={{
                      flexDirection: 'column',
                      alignItems: 'stretch',
                      py: 2,
                      bgcolor: entry.phase.ist_aktiv ? 'action.selected' : 'transparent',
                      borderLeft: entry.phase.ist_aktiv ? 4 : 0,
                      borderColor: 'primary.main',
                    }}
                  >
                    {/* Phase Header */}
                    <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                      <Box display="flex" alignItems="center" gap={1}>
                        <Typography variant="h6">{entry.phase.name}</Typography>
                        {getPhaseStatusLabel(entry.phase)}
                      </Box>
                      {getStatusChip(entry)}
                    </Box>

                    {/* Phase Details */}
                    <Grid container spacing={2}>
                      <Grid item xs={12} md={4}>
                        <Paper variant="outlined" sx={{ p: 1.5 }}>
                          <Typography variant="caption" color="textSecondary" display="block" gutterBottom>
                            Zeitraum
                          </Typography>
                          <Typography variant="body2">
                            {entry.phase.startdatum
                              ? format(new Date(entry.phase.startdatum), 'dd.MM.yyyy', { locale: de })
                              : '-'}
                            {' - '}
                            {entry.phase.enddatum
                              ? format(new Date(entry.phase.enddatum), 'dd.MM.yyyy', { locale: de })
                              : '-'}
                          </Typography>
                        </Paper>
                      </Grid>

                      {entry.hat_planung && entry.planung && (
                        <>
                          <Grid item xs={12} md={4}>
                            <Paper variant="outlined" sx={{ p: 1.5 }}>
                              <Typography variant="caption" color="textSecondary" display="block" gutterBottom>
                                Eingereicht
                              </Typography>
                              <Typography variant="body2">
                                {entry.eingereicht_am
                                  ? format(new Date(entry.eingereicht_am), 'dd.MM.yyyy HH:mm', { locale: de })
                                  : 'Nicht eingereicht'}
                              </Typography>
                            </Paper>
                          </Grid>

                          <Grid item xs={12} md={4}>
                            <Paper variant="outlined" sx={{ p: 1.5 }}>
                              <Typography variant="caption" color="textSecondary" display="block" gutterBottom>
                                Module / SWS
                              </Typography>
                              <Typography variant="body2">
                                {entry.module_anzahl} Module • {entry.planung.gesamt_sws} SWS
                              </Typography>
                            </Paper>
                          </Grid>
                        </>
                      )}
                    </Grid>

                    {/* Genehmigung/Ablehnung Details */}
                    {entry.hat_planung && entry.planung && (
                      <Box mt={2}>
                        {entry.planung.freigegeben_am && (
                          <Alert severity="success" icon={<CheckCircle />} sx={{ mb: 1 }}>
                            Freigegeben am{' '}
                            {format(new Date(entry.planung.freigegeben_am), 'dd.MM.yyyy HH:mm', { locale: de })}
                          </Alert>
                        )}

                        {entry.planung.abgelehnt_am && (
                          <Alert severity="error" icon={<Cancel />}>
                            <Typography variant="body2" gutterBottom>
                              Abgelehnt am{' '}
                              {format(new Date(entry.planung.abgelehnt_am), 'dd.MM.yyyy HH:mm', { locale: de })}
                            </Typography>
                            {entry.planung.ablehnungsgrund && (
                              <Typography variant="caption" color="textSecondary">
                                Grund: {entry.planung.ablehnungsgrund}
                              </Typography>
                            )}
                          </Alert>
                        )}
                      </Box>
                    )}

                    {/* Keine Planung */}
                    {!entry.hat_planung && (
                      <Alert severity="info" sx={{ mt: 2 }}>
                        Keine Planung für diese Phase eingereicht
                      </Alert>
                    )}
                  </ListItem>

                  {index < historie.phasen.length - 1 && <Divider />}
                </React.Fragment>
              ))}
            </List>
          </Box>
        )}
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>Schließen</Button>
      </DialogActions>
    </Dialog>
  );
};

export default ProfessorPhasenHistorie;
