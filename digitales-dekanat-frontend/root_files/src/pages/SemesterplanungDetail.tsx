import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Typography,
  Box,
  Grid,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  CircularProgress,
} from '@mui/material';
import {
  ArrowBack,
  Edit,
  Delete,
  Add,
  Send,
  CheckCircle,
  Cancel,
} from '@mui/icons-material';
import planungService from '../services/planungService';
import modulService from '../services/modulService';
import { useToastStore } from '../components/common/Toast';
import { createContextLogger } from '../utils/logger';
import { GeplantesModul, WunschFreierTag } from '../types/planung.types';

const log = createContextLogger('SemesterplanungDetail');
import useAuthStore from '../store/authStore';

const SemesterplanungDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const showToast = useToastStore((state) => state.showToast);
  
  const [loading, setLoading] = useState(true);
  const [planung, setPlanung] = useState<any>(null);
  const [modules, setModules] = useState<any[]>([]);
  const [openAddDialog, setOpenAddDialog] = useState(false);
  const [selectedModule, setSelectedModule] = useState<any>(null);
  const [modulConfig, setModulConfig] = useState({
    anzahl_vorlesungen: 1,
    anzahl_uebungen: 1,
    anzahl_praktika: 0,
    anzahl_seminare: 0,
    bemerkung: '',
  });

  const isEdit = window.location.pathname.includes('/edit');

  const getUserRole = () => {
    if (!user?.rolle) return null;
    return typeof user.rolle === 'string' ? user.rolle : user.rolle.name;
  };

  const canEdit = planung?.status === 'entwurf' &&
    (user?.id === planung?.benutzer_id || getUserRole() === 'dekan');

  // Debug-Log für Berechtigungen
  useEffect(() => {
    if (planung && user) {
      log.debug(' Berechtigungen:', {
        isEdit,
        canEdit,
        planung_status: planung.status,
        user_id: user.id,
        planung_benutzer_id: planung.benutzer_id,
        user_rolle: getUserRole(),
        isOwner: user.id === planung.benutzer_id,
        isDekan: getUserRole() === 'dekan',
      });
    }
  }, [planung, user, isEdit, canEdit]);

  useEffect(() => {
    if (id) {
      loadPlanung();
      loadModules();
    }
  }, [id]);

  const loadPlanung = async () => {
    try {
      const response = await planungService.getPlanung(parseInt(id!));
      if (response.success) {
        setPlanung(response.data);
      }
    } catch (error) {
      showToast('Fehler beim Laden der Planung', 'error');
    } finally {
      setLoading(false);
    }
  };

  const loadModules = async () => {
    try {
      const response = await modulService.getAllModules();
      if (response.success) {
        setModules(response.data || []);
      }
    } catch (error) {
      log.error('Error loading modules:', error);
    }
  };

  const handleAddModule = async () => {
    if (!selectedModule || !planung) return;

    try {
      const response = await planungService.addModule(
        parseInt(id!),
        {
          modul_id: selectedModule.id,
          po_id: planung.po_id,
          ...modulConfig,
        }
      );
      if (response.success) {
        showToast('Modul hinzugefügt', 'success');
        loadPlanung();
        setOpenAddDialog(false);
        resetModulDialog();
      }
    } catch (error) {
      showToast('Fehler beim Hinzufügen des Moduls', 'error');
    }
  };

  const handleRemoveModule = async (modulId: number) => {
    if (!confirm('Modul wirklich entfernen?')) return;

    try {
      const response = await planungService.removeModule(parseInt(id!), modulId);
      if (response.success) {
        showToast('Modul entfernt', 'success');
        loadPlanung();
      }
    } catch (error) {
      showToast('Fehler beim Entfernen des Moduls', 'error');
    }
  };

  const handleSubmit = async () => {
    if (!confirm('Planung wirklich einreichen? Nach dem Einreichen können keine Änderungen mehr vorgenommen werden.')) {
      return;
    }

    try {
      const response = await planungService.submitPlanung(parseInt(id!));
      if (response.success) {
        showToast('Planung erfolgreich eingereicht', 'success');
        navigate('/semesterplanung');
      }
    } catch (error) {
      showToast('Fehler beim Einreichen der Planung', 'error');
    }
  };

  const handleApprove = async () => {
    try {
      const response = await planungService.approvePlanung(parseInt(id!));
      if (response.success) {
        showToast('Planung freigegeben', 'success');
        loadPlanung();
      }
    } catch (error) {
      showToast('Fehler beim Freigeben der Planung', 'error');
    }
  };

  const handleReject = async () => {
    const grund = prompt('Ablehnungsgrund eingeben:');
    if (!grund) return;

    try {
      const response = await planungService.rejectPlanung(parseInt(id!), grund);
      if (response.success) {
        showToast('Planung abgelehnt', 'success');
        loadPlanung();
      }
    } catch (error) {
      showToast('Fehler beim Ablehnen der Planung', 'error');
    }
  };

  const resetModulDialog = () => {
    setSelectedModule(null);
    setModulConfig({
      anzahl_vorlesungen: 1,
      anzahl_uebungen: 1,
      anzahl_praktika: 0,
      anzahl_seminare: 0,
      bemerkung: '',
    });
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  if (!planung) {
    return (
      <Container>
        <Typography>Planung nicht gefunden</Typography>
      </Container>
    );
  }

  return (
    <Container maxWidth="xl">
      {/* Header */}
      <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <IconButton onClick={() => navigate('/semesterplanung')}>
          <ArrowBack />
        </IconButton>
        <Typography variant="h4" sx={{ flex: 1 }}>
          Semesterplanung {planung.semester?.kuerzel}
        </Typography>
        <Chip
          label={planung.status}
          color={
            planung.status === 'freigegeben' ? 'success' :
            planung.status === 'eingereicht' ? 'warning' :
            planung.status === 'abgelehnt' ? 'error' : 'default'
          }
        />
      </Box>

      {/* Info Grid - ✅ ERWEITERT */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} md={3}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle2" color="text.secondary">
              Dozent
            </Typography>
            <Typography variant="body1">
              {planung.benutzer?.name_komplett}
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={2}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle2" color="text.secondary">
              Module
            </Typography>
            <Typography variant="h6">
              {planung.geplante_module?.length || 0}
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={2}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle2" color="text.secondary">
              Gesamt SWS
            </Typography>
            <Typography variant="h6">
              {planung.gesamt_sws?.toFixed(1) || '0.0'}
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={2}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle2" color="text.secondary">
              Gesamt ECTS
            </Typography>
            <Typography variant="h6">
              {planung.geplante_module?.reduce((sum: number, gm: GeplantesModul) =>
                sum + (gm.modul?.leistungspunkte || 0), 0) || 0}
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={3}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="subtitle2" color="text.secondary">
              {planung.status === 'eingereicht' ? 'Eingereicht am' :
               planung.status === 'freigegeben' ? 'Freigegeben am' :
               'Erstellt am'}
            </Typography>
            <Typography variant="body2">
              {planung.eingereicht_am
                ? new Date(planung.eingereicht_am).toLocaleDateString('de-DE')
                : planung.freigegeben_am
                ? new Date(planung.freigegeben_am).toLocaleDateString('de-DE')
                : new Date(planung.created_at).toLocaleDateString('de-DE')}
            </Typography>
          </Paper>
        </Grid>
      </Grid>

      {/* Anmerkungen & Raumbedarf - ✅ NEU */}
      {(planung.anmerkungen || planung.wunsch_freie_tage?.length > 0) && (
        <Grid container spacing={3} sx={{ mb: 3 }}>
          {planung.anmerkungen && (
            <Grid item xs={12} md={6}>
              <Paper sx={{ p: 2 }}>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Anmerkungen zur Planung
                </Typography>
                <Typography variant="body2" sx={{ whiteSpace: 'pre-wrap' }}>
                  {planung.anmerkungen}
                </Typography>
              </Paper>
            </Grid>
          )}

          {planung.wunsch_freie_tage && planung.wunsch_freie_tage.length > 0 && (
            <Grid item xs={12} md={6}>
              <Paper sx={{ p: 2 }}>
                <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                  Wunsch-freie Tage
                </Typography>
                {planung.wunsch_freie_tage.map((tag: WunschFreierTag, index: number) => (
                  <Chip
                    key={index}
                    label={tag.wochentag}
                    size="small"
                    sx={{ mr: 1, mb: 1 }}
                  />
                ))}
              </Paper>
            </Grid>
          )}
        </Grid>
      )}

      {/* Module Table */}
      <Paper sx={{ mb: 3 }}>
        <Box sx={{ p: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6">Geplante Module</Typography>
          {canEdit && isEdit && (
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={() => setOpenAddDialog(true)}
            >
              Modul hinzufügen
            </Button>
          )}
        </Box>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Kürzel</TableCell>
                <TableCell>Bezeichnung</TableCell>
                <TableCell align="center">ECTS</TableCell>
                <TableCell align="center">V</TableCell>
                <TableCell align="center">Ü</TableCell>
                <TableCell align="center">P</TableCell>
                <TableCell align="center">S</TableCell>
                <TableCell align="right">SWS</TableCell>
                <TableCell>Mitarbeiter</TableCell>
                <TableCell>Anmerkungen</TableCell>
                {canEdit && isEdit && (
                  <TableCell align="center">Aktionen</TableCell>
                )}
              </TableRow>
            </TableHead>
            <TableBody>
              {planung.geplante_module?.map((gm: GeplantesModul) => (
                <TableRow key={gm.id}>
                  <TableCell>
                    <Typography variant="body2" fontWeight={600}>
                      {gm.modul?.kuerzel}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">
                      {gm.modul?.bezeichnung_de}
                    </Typography>
                  </TableCell>
                  <TableCell align="center">
                    <Chip
                      label={gm.modul?.leistungspunkte || 0}
                      size="small"
                      variant="outlined"
                    />
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="body2">
                      {gm.anzahl_vorlesungen || '-'}
                    </Typography>
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="body2">
                      {gm.anzahl_uebungen || '-'}
                    </Typography>
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="body2">
                      {gm.anzahl_praktika || '-'}
                    </Typography>
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="body2">
                      {gm.anzahl_seminare || '-'}
                    </Typography>
                  </TableCell>
                  <TableCell align="right">
                    <Typography variant="body2" fontWeight={600}>
                      {(gm.sws_gesamt ?? 0).toFixed(1)}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    {gm.mitarbeiter_ids && gm.mitarbeiter_ids.length > 0 ? (
                      <Chip
                        label={`${gm.mitarbeiter_ids.length} Mitarbeiter`}
                        size="small"
                        color="primary"
                      />
                    ) : (
                      <Typography variant="caption" color="text.secondary">
                        Keine
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    {gm.anmerkungen ? (
                      <Typography
                        variant="caption"
                        sx={{
                          display: '-webkit-box',
                          WebkitLineClamp: 2,
                          WebkitBoxOrient: 'vertical',
                          overflow: 'hidden',
                          textOverflow: 'ellipsis',
                          maxWidth: '200px',
                        }}
                      >
                        {gm.anmerkungen}
                      </Typography>
                    ) : (
                      <Typography variant="caption" color="text.secondary">
                        -
                      </Typography>
                    )}
                  </TableCell>
                  {canEdit && isEdit && (
                    <TableCell align="center">
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => handleRemoveModule(gm.modul_id)}
                      >
                        <Delete />
                      </IconButton>
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </Paper>

      {/* Actions */}
      <Box sx={{ display: 'flex', gap: 2, justifyContent: 'flex-end' }}>
        {planung.status === 'entwurf' && user?.id === planung.benutzer_id && (
          <>
            {!isEdit && (
              <Button
                variant="outlined"
                startIcon={<Edit />}
                onClick={() => navigate(`/semesterplanung/${id}/edit`)}
              >
                Bearbeiten
              </Button>
            )}
            <Button
              variant="contained"
              startIcon={<Send />}
              onClick={handleSubmit}
            >
              Einreichen
            </Button>
          </>
        )}

        {planung.status === 'eingereicht' && user?.rolle === 'dekan' && (
          <>
            <Button
              variant="contained"
              color="success"
              startIcon={<CheckCircle />}
              onClick={handleApprove}
            >
              Freigeben
            </Button>
            <Button
              variant="outlined"
              color="error"
              startIcon={<Cancel />}
              onClick={handleReject}
            >
              Ablehnen
            </Button>
          </>
        )}
      </Box>

      {/* Add Module Dialog */}
      <Dialog
        open={openAddDialog}
        onClose={() => setOpenAddDialog(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Modul hinzufügen</DialogTitle>
        <DialogContent>
          <FormControl fullWidth sx={{ mt: 2, mb: 2 }}>
            <InputLabel>Modul auswählen</InputLabel>
            <Select
              value={selectedModule?.id || ''}
              onChange={(e) => {
                const modul = modules.find(m => m.id === e.target.value);
                setSelectedModule(modul);
              }}
              label="Modul auswählen"
            >
              {modules.map((modul) => (
                <MenuItem key={modul.id} value={modul.id}>
                  {modul.kuerzel} - {modul.bezeichnung_de}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Grid container spacing={2}>
            <Grid item xs={6}>
              <TextField
                fullWidth
                type="number"
                label="Anzahl Vorlesungen"
                value={modulConfig.anzahl_vorlesungen}
                onChange={(e) => setModulConfig({
                  ...modulConfig,
                  anzahl_vorlesungen: parseInt(e.target.value) || 0
                })}
                inputProps={{ min: 0, max: 10 }}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                type="number"
                label="Anzahl Übungen"
                value={modulConfig.anzahl_uebungen}
                onChange={(e) => setModulConfig({
                  ...modulConfig,
                  anzahl_uebungen: parseInt(e.target.value) || 0
                })}
                inputProps={{ min: 0, max: 10 }}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                type="number"
                label="Anzahl Praktika"
                value={modulConfig.anzahl_praktika}
                onChange={(e) => setModulConfig({
                  ...modulConfig,
                  anzahl_praktika: parseInt(e.target.value) || 0
                })}
                inputProps={{ min: 0, max: 10 }}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                type="number"
                label="Anzahl Seminare"
                value={modulConfig.anzahl_seminare}
                onChange={(e) => setModulConfig({
                  ...modulConfig,
                  anzahl_seminare: parseInt(e.target.value) || 0
                })}
                inputProps={{ min: 0, max: 10 }}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={2}
                label="Bemerkung (optional)"
                value={modulConfig.bemerkung}
                onChange={(e) => setModulConfig({
                  ...modulConfig,
                  bemerkung: e.target.value
                })}
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenAddDialog(false)}>
            Abbrechen
          </Button>
          <Button 
            variant="contained" 
            onClick={handleAddModule}
            disabled={!selectedModule}
          >
            Hinzufügen
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default SemesterplanungDetail;