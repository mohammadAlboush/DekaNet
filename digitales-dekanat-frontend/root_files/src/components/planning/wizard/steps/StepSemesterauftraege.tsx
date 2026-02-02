/**
 * StepSemesterauftraege.tsx
 *
 * Wizard Step 5: Semesteraufträge beantragen
 *
 * Features:
 * - Anzeige verfügbarer Aufträge (Master-Liste)
 * - Beantragung von Aufträgen mit optionaler SWS-Anpassung
 * - Übersicht bereits beantragter Aufträge (mit Status)
 * - SWS-Berechnung: Module + Aufträge
 * - Optional: Kann übersprungen werden
 */

import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Button,
  Grid,
  Card,
  CardContent,
  Chip,
  Alert,
  CircularProgress,
  TextField,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  IconButton,
  Divider,
  Tooltip,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
} from '@mui/material';
import {
  NavigateBefore,
  NavigateNext,
  Add,
  Delete,
  CheckCircle,
  Schedule,
  Cancel,
  Info,
  Work,
} from '@mui/icons-material';
import { BaseStepProps } from '../../../../types/StepProps.types';
import auftragService from '../../../../services/auftragService';
import { Auftrag, SemesterAuftrag } from '../../../../types/auftrag.types';
import { GeplantesModul } from '../../../../types/planung.types';
import useAuftragStore from '../../../../store/auftragStore';
import { createContextLogger } from '../../../../utils/logger';
import { getErrorMessage } from '../../../../utils/errorUtils';

const log = createContextLogger('StepSemesterauftraege');

interface StepSemesterauftraegeProps extends BaseStepProps {}

const StepSemesterauftraege: React.FC<StepSemesterauftraegeProps> = ({
  data,
  onNext,
  onBack,
}) => {
  // Use Auftrag Store for synchronization
  const { triggerRefresh } = useAuftragStore();

  const [loading, setLoading] = useState(true);
  const [auftraege, setAuftraege] = useState<Auftrag[]>([]);
  const [meineAuftraege, setMeineAuftraege] = useState<SemesterAuftrag[]>([]);
  const [showBeantragDialog, setShowBeantragDialog] = useState(false);
  const [selectedAuftrag, setSelectedAuftrag] = useState<Auftrag | null>(null);
  const [beantragSWS, setBeantragSWS] = useState<number>(0);
  const [beantragAnmerkung, setBeantragAnmerkung] = useState<string>('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    loadData();
  }, [data.semesterId]);

  const loadData = async () => {
    if (!data.semesterId) {
      setLoading(false);
      return;
    }

    try {
      setLoading(true);
      setError(null);

      // Load all active Aufträge (master list)
      const auftraegeResponse = await auftragService.getAlleAuftraege(true);
      setAuftraege(auftraegeResponse);

      // Load my assignments for this semester
      const meineResponse = await auftragService.getMeineAuftraege(data.semesterId);
      setMeineAuftraege(meineResponse);

      log.debug(' Loaded:', auftraegeResponse.length, 'aufträge,', meineResponse.length, 'meine');
    } catch (error: unknown) {
      log.error(' Error loading data:', error);
      setError(getErrorMessage(error, 'Fehler beim Laden der Aufträge'));
    } finally {
      setLoading(false);
    }
  };

  const handleOpenBeantragDialog = (auftrag: Auftrag) => {
    setSelectedAuftrag(auftrag);
    setBeantragSWS(auftrag.standard_sws);
    setBeantragAnmerkung('');
    setShowBeantragDialog(true);
  };

  const handleCloseBeantragDialog = () => {
    setShowBeantragDialog(false);
    setSelectedAuftrag(null);
    setBeantragSWS(0);
    setBeantragAnmerkung('');
  };

  const handleBeantragAuftrag = async () => {
    if (!selectedAuftrag || !data.semesterId) return;

    try {
      setSubmitting(true);
      setError(null);

      // Professor kann SWS nicht ändern - immer Standard verwenden
      const newAuftrag = await auftragService.beantrageAuftrag(
        data.semesterId,
        {
          auftrag_id: selectedAuftrag.id,
          // SWS wird nicht gesendet, Backend verwendet standard_sws
          anmerkung: beantragAnmerkung || undefined
        }
      );

      // Update local state
      setMeineAuftraege([...meineAuftraege, newAuftrag]);

      // Trigger Store refresh for Dashboard synchronization
      if (data.semesterId) {
        await triggerRefresh(data.semesterId);
      }

      handleCloseBeantragDialog();
      log.debug(' ✅ Auftrag beantragt:', newAuftrag);
    } catch (error: unknown) {
      log.error(' Error beantragen:', error);
      setError(getErrorMessage(error, 'Fehler beim Beantragen'));
    } finally {
      setSubmitting(false);
    }
  };

  const handleDeleteAuftrag = async (semesterAuftragId: number) => {
    const confirmed = window.confirm('Möchten Sie diesen Auftrag wirklich zurückziehen?');
    if (!confirmed) return;

    try {
      setError(null);
      await auftragService.deleteSemesterAuftrag(semesterAuftragId);

      // Update local state
      setMeineAuftraege(meineAuftraege.filter(a => a.id !== semesterAuftragId));

      // Trigger Store refresh for Dashboard synchronization
      if (data.semesterId) {
        await triggerRefresh(data.semesterId);
      }

      log.debug(' ✅ Auftrag zurückgezogen:', semesterAuftragId);
    } catch (error: unknown) {
      log.error(' Error deleting:', error);
      setError(getErrorMessage(error, 'Fehler beim Löschen'));
    }
  };

  const isAuftragBeantragt = (auftragId: number): boolean => {
    return meineAuftraege.some(ma => ma.auftrag_id === auftragId);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'genehmigt': return 'success';
      case 'abgelehnt': return 'error';
      case 'beantragt': return 'warning';
      default: return 'default';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'genehmigt': return <CheckCircle fontSize="small" />;
      case 'abgelehnt': return <Cancel fontSize="small" />;
      case 'beantragt': return <Schedule fontSize="small" />;
      default: return undefined;
    }
  };

  const berechneAuftrageSWS = (): number => {
    return meineAuftraege
      .filter(a => a.status === 'genehmigt')
      .reduce((sum, a) => sum + a.sws, 0);
  };

  const berechneModuleSWS = (): number => {
    return data.geplantModule?.reduce((sum: number, gm: GeplantesModul) => sum + (gm.sws_gesamt || 0), 0) || 0;
  };

  const berechneGesamtSWS = (): number => {
    return berechneModuleSWS() + berechneAuftrageSWS();
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
        <CircularProgress />
        <Typography sx={{ ml: 2 }}>Lade Aufträge...</Typography>
      </Box>
    );
  }

  if (!data.semesterId) {
    return (
      <Alert severity="warning">
        <Typography variant="body2">
          Bitte wählen Sie zuerst ein Semester aus (Schritt 1).
        </Typography>
      </Alert>
    );
  }

  const moduleSWS = berechneModuleSWS();
  const auftrageSWS = berechneAuftrageSWS();
  const gesamtSWS = berechneGesamtSWS();
  const beantragtCount = meineAuftraege.filter(a => a.status === 'beantragt').length;
  const genehmigteCount = meineAuftraege.filter(a => a.status === 'genehmigt').length;

  return (
    <Box>
      {/* Info Alert */}
      <Alert severity="info" icon={<Info />} sx={{ mb: 3 }}>
        <Typography variant="body2">
          <strong>Semesteraufträge</strong> sind administrative Tätigkeiten wie Dekanin, Prodekan, Studiengangsbeauftragter, etc.
          Sie können hier Aufträge beantragen. Der Dekan muss diese genehmigen, bevor sie zu Ihrer SWS-Last hinzugefügt werden.
        </Typography>
      </Alert>

      {/* Error Alert */}
      {error && (
        <Alert severity="error" onClose={() => setError(null)} sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {/* SWS Summary */}
      <Paper sx={{ p: 2, mb: 3, bgcolor: 'primary.lighter' }}>
        <Grid container spacing={2}>
          <Grid item xs={12} md={3}>
            <Typography variant="body2" color="text.secondary">Module SWS</Typography>
            <Typography variant="h6">{moduleSWS.toFixed(1)} SWS</Typography>
          </Grid>
          <Grid item xs={12} md={3}>
            <Typography variant="body2" color="text.secondary">Genehmigte Aufträge</Typography>
            <Typography variant="h6" color="success.main">{auftrageSWS.toFixed(1)} SWS</Typography>
          </Grid>
          <Grid item xs={12} md={3}>
            <Typography variant="body2" color="text.secondary">Gesamt SWS</Typography>
            <Typography variant="h6" color="primary.main">
              <strong>{gesamtSWS.toFixed(1)} SWS</strong>
            </Typography>
          </Grid>
          <Grid item xs={12} md={3}>
            <Typography variant="body2" color="text.secondary">Status</Typography>
            <Typography variant="body2">
              {genehmigteCount} genehmigt • {beantragtCount} beantragt
            </Typography>
          </Grid>
        </Grid>
      </Paper>

      <Grid container spacing={3}>
        {/* Left: Meine Aufträge */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Work />
              Meine Aufträge ({meineAuftraege.length})
            </Typography>
            <Divider sx={{ my: 2 }} />

            {meineAuftraege.length === 0 ? (
              <Alert severity="info">
                <Typography variant="body2">
                  Sie haben noch keine Aufträge beantragt.
                </Typography>
              </Alert>
            ) : (
              <List>
                {meineAuftraege.map((sa) => (
                  <ListItem
                    key={sa.id}
                    sx={{
                      border: '1px solid',
                      borderColor: 'divider',
                      borderRadius: 1,
                      mb: 1,
                      bgcolor: 'background.default'
                    }}
                  >
                    <ListItemText
                      primary={
                        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                          <Typography variant="subtitle2">
                            {sa.auftrag?.name || `Auftrag #${sa.auftrag_id}`}
                          </Typography>
                          <Chip
                            label={sa.status}
                            size="small"
                            color={getStatusColor(sa.status)}
                            icon={getStatusIcon(sa.status)}
                          />
                        </Box>
                      }
                      secondary={
                        <Box>
                          <Typography variant="body2" color="text.secondary">
                            {sa.sws.toFixed(1)} SWS
                            {sa.auftrag && sa.sws !== sa.auftrag.standard_sws && (
                              <Chip
                                label={`Standard: ${sa.auftrag.standard_sws} SWS`}
                                size="small"
                                sx={{ ml: 1 }}
                              />
                            )}
                          </Typography>
                          {sa.anmerkung && (
                            <Typography variant="caption" color="text.secondary" sx={{ display: 'block', mt: 0.5 }}>
                              {sa.anmerkung}
                            </Typography>
                          )}
                        </Box>
                      }
                    />
                    <ListItemSecondaryAction>
                      {sa.status === 'beantragt' && (
                        <Tooltip title="Zurückziehen">
                          <IconButton
                            edge="end"
                            onClick={() => handleDeleteAuftrag(sa.id)}
                            size="small"
                            color="error"
                          >
                            <Delete />
                          </IconButton>
                        </Tooltip>
                      )}
                    </ListItemSecondaryAction>
                  </ListItem>
                ))}
              </List>
            )}
          </Paper>
        </Grid>

        {/* Right: Verfügbare Aufträge */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Add />
              Verfügbare Aufträge ({auftraege.length})
            </Typography>
            <Divider sx={{ my: 2 }} />

            {auftraege.length === 0 ? (
              <Alert severity="warning">
                <Typography variant="body2">
                  Keine Aufträge verfügbar.
                </Typography>
              </Alert>
            ) : (
              <Box sx={{ maxHeight: 500, overflowY: 'auto' }}>
                {auftraege.map((auftrag) => {
                  const isBeantragt = isAuftragBeantragt(auftrag.id);

                  return (
                    <Card
                      key={auftrag.id}
                      sx={{
                        mb: 1.5,
                        opacity: isBeantragt ? 0.6 : 1,
                        border: '1px solid',
                        borderColor: isBeantragt ? 'success.main' : 'divider'
                      }}
                    >
                      <CardContent sx={{ p: 1.5, '&:last-child': { pb: 1.5 } }}>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                          <Box sx={{ flex: 1 }}>
                            <Typography variant="subtitle2" gutterBottom>
                              {auftrag.name}
                            </Typography>
                            <Typography variant="body2" color="text.secondary" sx={{ fontSize: '0.8rem', mb: 1 }}>
                              {auftrag.beschreibung}
                            </Typography>
                            <Chip
                              label={`${auftrag.standard_sws.toFixed(1)} SWS`}
                              size="small"
                              color="primary"
                              variant="outlined"
                            />
                          </Box>
                          <Button
                            variant={isBeantragt ? "outlined" : "contained"}
                            size="small"
                            startIcon={isBeantragt ? <CheckCircle /> : <Add />}
                            onClick={() => handleOpenBeantragDialog(auftrag)}
                            disabled={isBeantragt}
                            sx={{ ml: 1 }}
                          >
                            {isBeantragt ? 'Beantragt' : 'Beantragen'}
                          </Button>
                        </Box>
                      </CardContent>
                    </Card>
                  );
                })}
              </Box>
            )}
          </Paper>
        </Grid>
      </Grid>

      {/* Beantrag Dialog */}
      <Dialog
        open={showBeantragDialog}
        onClose={handleCloseBeantragDialog}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          Auftrag beantragen: {selectedAuftrag?.name}
        </DialogTitle>
        <DialogContent>
          {selectedAuftrag && (
            <Box sx={{ pt: 1 }}>
              <Typography variant="body2" color="text.secondary" paragraph>
                {selectedAuftrag.beschreibung}
              </Typography>

              <TextField
                label="SWS"
                type="number"
                fullWidth
                value={beantragSWS}
                disabled
                InputProps={{
                  readOnly: true,
                }}
                helperText="SWS wird vom Dekan festgelegt und kann hier nicht geändert werden"
                sx={{ mb: 2 }}
              />

              <TextField
                label="Anmerkung (optional)"
                multiline
                rows={3}
                fullWidth
                value={beantragAnmerkung}
                onChange={(e) => setBeantragAnmerkung(e.target.value)}
                placeholder="Zusätzliche Informationen oder Begründung..."
              />

              <Alert severity="info" sx={{ mt: 2 }}>
                <Typography variant="caption">
                  Der Auftrag wird zur Genehmigung an den Dekan gesendet.
                  Nach Genehmigung wird die SWS zu Ihrer Gesamtlast hinzugefügt.
                </Typography>
              </Alert>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseBeantragDialog} disabled={submitting}>
            Abbrechen
          </Button>
          <Button
            onClick={handleBeantragAuftrag}
            variant="contained"
            disabled={submitting || beantragSWS <= 0}
            startIcon={submitting ? <CircularProgress size={16} /> : <Add />}
          >
            {submitting ? 'Wird beantragt...' : 'Beantragen'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Navigation */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 3 }}>
        <Button
          onClick={onBack}
          startIcon={<NavigateBefore />}
          variant="outlined"
        >
          Zurück
        </Button>
        <Button
          onClick={onNext}
          endIcon={<NavigateNext />}
          variant="contained"
        >
          Weiter
        </Button>
      </Box>

      {/* Optional Info */}
      <Box sx={{ mt: 2, textAlign: 'center' }}>
        <Typography variant="caption" color="text.secondary">
          💡 Dieser Schritt ist optional. Sie können auch ohne Aufträge fortfahren.
        </Typography>
      </Box>
    </Box>
  );
};

export default StepSemesterauftraege;
