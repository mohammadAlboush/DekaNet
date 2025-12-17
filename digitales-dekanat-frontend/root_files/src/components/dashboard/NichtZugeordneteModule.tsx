import React, { useEffect, useState } from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Alert,
  AlertTitle,
  CircularProgress,
  Grid,
  Divider,
  LinearProgress,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  SelectChangeEvent,
  IconButton,
  Tooltip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Autocomplete,
  TextField,
  Stack,
} from '@mui/material';
import {
  Warning,
  CheckCircle,
  School,
  FilterList,
  PersonAdd,
  Person,
  Send,
  ThumbUp,
  ThumbDown,
  HourglassEmpty,
  Edit,
} from '@mui/icons-material';
import dashboardService, {
  NichtZugeordneteModuleResponse,
  NichtZugeordnetesModul,
} from '../../services/dashboardService';
import semesterService from '../../services/semesterService';
import dozentService from '../../services/dozentService';
import { Semester } from '../../types/semester.types';

/**
 * NichtZugeordneteModule Component
 * =================================
 * Zeigt Module an, die noch nicht in einer Semesterplanung zugeordnet sind.
 *
 * Features:
 * - Automatische Semester-Erkennung (Winter/Sommer)
 * - Filter nach relevantem Turnus
 * - Filter nach Semester (Aktuell, Alle, Sommersemester, Wintersemester)
 * - Statistiken und Zuordnungsquote
 * - Übersichtliche Tabelle
 * - Anzeige von Planungsstatus (wer hat eingereicht)
 * - Zuweisungs-Dialog für Dekan
 *
 * Turnus-Logik:
 * - Wintersemester: "Wintersemester", "Wintersemester, jährlich", "Jedes Semester"
 * - Sommersemester: "Sommersemester", "Sommersemester, jährlich", "Jedes Semester"
 */

// Relevante Turnus-Werte pro Semester-Typ
const WINTER_TURNUS = ['Wintersemester', 'Wintersemester, jährlich', 'Jedes Semester'];
const SOMMER_TURNUS = ['Sommersemester', 'Sommersemester, jährlich', 'Jedes Semester'];

type SemesterFilter = 'aktuell' | 'alle' | 'sommer' | 'winter';

interface Dozent {
  id: number;
  vorname: string;
  nachname: string;
  email?: string;
}

interface Props {
  semesterId?: number;
  poId?: number;
}

const NichtZugeordneteModule: React.FC<Props> = ({ semesterId: propSemesterId, poId }) => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<NichtZugeordneteModuleResponse | null>(null);
  const [alleSemester, setAlleSemester] = useState<Semester[]>([]);
  const [filter, setFilter] = useState<SemesterFilter>('aktuell');
  const [selectedSemesterId] = useState<number | undefined>(propSemesterId);

  // Zuweisungs-Dialog State
  const [zuweisungDialogOpen, setZuweisungDialogOpen] = useState(false);
  const [selectedModul, setSelectedModul] = useState<NichtZugeordnetesModul | null>(null);
  const [dozenten, setDozenten] = useState<Dozent[]>([]);
  const [selectedDozent, setSelectedDozent] = useState<Dozent | null>(null);
  const [zuweisungLoading, setZuweisungLoading] = useState(false);

  useEffect(() => {
    loadAlleSemester();
  }, []);

  useEffect(() => {
    if (alleSemester.length > 0) {
      loadData();
    }
  }, [filter, selectedSemesterId, poId, alleSemester]);

  const loadAlleSemester = async () => {
    try {
      const response = await semesterService.getAll();
      if (response.success && response.data) {
        setAlleSemester(response.data);
      }
    } catch (err) {
      console.error('[NichtZugeordneteModule] Error loading semesters:', err);
    }
  };

  const getFilteredSemesterId = (): number | undefined => {
    if (filter === 'aktuell') {
      // Verwende propSemesterId falls vorhanden, sonst aktives Semester
      if (propSemesterId) return propSemesterId;
      const aktivesSemester = alleSemester.find(s => s.ist_aktiv);
      return aktivesSemester?.id;
    }

    if (filter === 'alle') {
      // Kein Filter - Backend gibt alle Module zurück
      return undefined;
    }

    // Für Sommer/Winter: Finde passende Semester
    if (filter === 'sommer') {
      const sommerSemester = alleSemester.find(s =>
        s.kuerzel.includes('SS') || s.bezeichnung.toLowerCase().includes('sommer')
      );
      return sommerSemester?.id;
    }

    if (filter === 'winter') {
      const winterSemester = alleSemester.find(s =>
        s.kuerzel.includes('WS') || s.bezeichnung.toLowerCase().includes('winter')
      );
      return winterSemester?.id;
    }

    return undefined;
  };

  const loadData = async () => {
    setLoading(true);
    setError(null);

    try {
      const semesterId = getFilteredSemesterId();

      const response = await dashboardService.getNichtZugeordneteModule(
        semesterId,
        poId
      );

      if (response.success && response.data) {
        setData(response.data);
      } else {
        setError(response.message || 'Fehler beim Laden der Daten');
      }
    } catch (err: any) {
      console.error('[NichtZugeordneteModule] Error:', err);
      setError(err.message || 'Ein Fehler ist aufgetreten');
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (event: SelectChangeEvent<SemesterFilter>) => {
    setFilter(event.target.value as SemesterFilter);
  };

  // Lade Dozenten für Zuweisungs-Dialog
  const loadDozenten = async () => {
    try {
      const response = await dozentService.getAllDozenten({ aktiv: true });
      if (response.success && response.data) {
        setDozenten(response.data.map(d => ({
          id: d.id,
          vorname: d.vorname || '',
          nachname: d.nachname,
          email: d.email,
        })));
      }
    } catch (err) {
      console.error('[NichtZugeordneteModule] Error loading dozenten:', err);
    }
  };

  // Öffne Zuweisungs-Dialog
  const handleOpenZuweisungDialog = async (modul: NichtZugeordnetesModul) => {
    setSelectedModul(modul);
    setSelectedDozent(null);
    if (dozenten.length === 0) {
      await loadDozenten();
    }
    setZuweisungDialogOpen(true);
  };

  // Schließe Zuweisungs-Dialog
  const handleCloseZuweisungDialog = () => {
    setZuweisungDialogOpen(false);
    setSelectedModul(null);
    setSelectedDozent(null);
  };

  // Zuweisung durchführen (TODO: Backend-Endpoint implementieren)
  const handleZuweisung = async () => {
    if (!selectedModul || !selectedDozent) return;

    setZuweisungLoading(true);
    try {
      // TODO: Backend-Endpoint für Modul-Zuweisung aufrufen
      // await planungService.zuweiseModul(selectedModul.id, selectedDozent.id, propSemesterId);
      console.log('[NichtZugeordneteModule] Zuweisung:', {
        modul: selectedModul.kuerzel,
        dozent: `${selectedDozent.vorname} ${selectedDozent.nachname}`,
      });

      // Erfolgsmeldung und Dialog schließen
      alert(`Modul "${selectedModul.kuerzel}" wurde ${selectedDozent.vorname} ${selectedDozent.nachname} zugewiesen.`);
      handleCloseZuweisungDialog();

      // Daten neu laden
      await loadData();
    } catch (err: any) {
      console.error('[NichtZugeordneteModule] Error:', err);
      alert('Fehler bei der Zuweisung: ' + (err.message || 'Unbekannter Fehler'));
    } finally {
      setZuweisungLoading(false);
    }
  };

  // Helper: Status-Icon für Planungsstatus
  const getPlanungStatusIcon = (status?: string) => {
    switch (status) {
      case 'eingereicht':
        return <Send fontSize="small" color="warning" />;
      case 'genehmigt':
        return <ThumbUp fontSize="small" color="success" />;
      case 'abgelehnt':
        return <ThumbDown fontSize="small" color="error" />;
      case 'entwurf':
        return <Edit fontSize="small" color="action" />;
      default:
        return <HourglassEmpty fontSize="small" color="disabled" />;
    }
  };

  // Helper: Status-Text für Planungsstatus
  const getPlanungStatusText = (status?: string) => {
    switch (status) {
      case 'eingereicht':
        return 'Eingereicht';
      case 'genehmigt':
        return 'Genehmigt';
      case 'abgelehnt':
        return 'Abgelehnt';
      case 'entwurf':
        return 'Entwurf';
      default:
        return 'Keine Planung';
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

  if (error) {
    return (
      <Card>
        <CardContent>
          <Alert severity="error">
            <AlertTitle>Fehler</AlertTitle>
            {error}
          </Alert>
        </CardContent>
      </Card>
    );
  }

  if (!data) {
    return null;
  }

  // Keine aktive Planungsphase - NUR für "aktuell" Filter relevant
  if (!data.planungsphase_aktiv && filter === 'aktuell') {
    return (
      <Card>
        <CardContent>
          <Alert severity="info">
            <AlertTitle>Keine aktive Planungsphase</AlertTitle>
            Aktuell ist keine Planungsphase aktiv. Diese Übersicht ist nur verfügbar, wenn eine Planungsphase geöffnet ist.
          </Alert>
        </CardContent>
      </Card>
    );
  }

  const { semester, planungsphase, nicht_zugeordnete_module, statistik, relevante_turnus } = data;
  const zuordnungsquote = statistik.zuordnungsquote;
  const hasModules = nicht_zugeordnete_module.length > 0;

  return (
    <Card elevation={3}>
      <CardContent>
        {/* Header mit Filter */}
        <Box display="flex" alignItems="center" justifyContent="space-between" mb={2}>
          <Box display="flex" alignItems="center">
            <Warning color="warning" sx={{ mr: 1 }} />
            <Typography variant="h6" component="h2">
              Nicht zugeordnete Module
            </Typography>
          </Box>

          {/* Filter Dropdown */}
          <FormControl size="small" sx={{ minWidth: 200 }}>
            <InputLabel id="semester-filter-label">
              <Box display="flex" alignItems="center" gap={0.5}>
                <FilterList fontSize="small" />
                Semester-Filter
              </Box>
            </InputLabel>
            <Select
              labelId="semester-filter-label"
              value={filter}
              label="Semester-Filter"
              onChange={handleFilterChange}
            >
              <MenuItem value="aktuell">
                📅 Aktuelles Semester
              </MenuItem>
              <MenuItem value="winter">
                ❄️ Wintersemester
              </MenuItem>
              <MenuItem value="sommer">
                ☀️ Sommersemester
              </MenuItem>
              <MenuItem value="alle">
                📚 Alle Semester
              </MenuItem>
            </Select>
          </FormControl>
        </Box>

        {/* Semester & Phase Info */}
        <Box mb={3}>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <Typography variant="body2" color="text.secondary">
                <strong>Semester:</strong> {semester?.bezeichnung} ({semester?.kuerzel})
              </Typography>
            </Grid>
            <Grid item xs={12} md={6}>
              <Typography variant="body2" color="text.secondary">
                <strong>Planungsphase:</strong> {planungsphase?.name}
              </Typography>
            </Grid>
          </Grid>
        </Box>

        {/* Statistiken */}
        <Grid container spacing={2} mb={3}>
          {/* Zuordnungsquote */}
          <Grid item xs={12} md={6}>
            <Paper variant="outlined" sx={{ p: 2 }}>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                Zuordnungsquote
              </Typography>
              <Box display="flex" alignItems="center" mb={1}>
                <Typography variant="h4" color={zuordnungsquote >= 80 ? 'success.main' : zuordnungsquote >= 50 ? 'warning.main' : 'error.main'}>
                  {zuordnungsquote.toFixed(1)}%
                </Typography>
                <Box ml={2}>
                  {zuordnungsquote >= 80 ? (
                    <CheckCircle color="success" />
                  ) : (
                    <Warning color={zuordnungsquote >= 50 ? 'warning' : 'error'} />
                  )}
                </Box>
              </Box>
              <LinearProgress
                variant="determinate"
                value={zuordnungsquote}
                color={zuordnungsquote >= 80 ? 'success' : zuordnungsquote >= 50 ? 'warning' : 'error'}
                sx={{ height: 8, borderRadius: 1 }}
              />
              <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                {statistik.geplante_module} von {statistik.alle_module} Modulen zugeordnet
              </Typography>
            </Paper>
          </Grid>

          {/* Nicht zugeordnet */}
          <Grid item xs={12} md={6}>
            <Paper variant="outlined" sx={{ p: 2 }}>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                Nicht zugeordnete Module
              </Typography>
              <Typography variant="h4" color={hasModules ? 'warning.main' : 'success.main'}>
                {statistik.gesamt}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Module benötigen Zuweisung
              </Typography>
            </Paper>
          </Grid>
        </Grid>

        {/* Relevante Turnus */}
        <Box mb={2}>
          <Typography variant="body2" color="text.secondary" gutterBottom>
            <strong>Relevanter Turnus für dieses Semester:</strong>
          </Typography>
          <Box display="flex" gap={1} flexWrap="wrap">
            {/* Zeige Backend-Daten oder Frontend-Defaults basierend auf Semester-Typ */}
            {relevante_turnus && relevante_turnus.length > 0 ? (
              relevante_turnus.map((turnus) => (
                <Chip
                  key={turnus}
                  label={turnus}
                  size="small"
                  color="primary"
                  variant="outlined"
                />
              ))
            ) : (
              // Fallback: Zeige erwartete Turnus-Werte basierend auf Semester
              (semester?.kuerzel?.includes('WS') || semester?.bezeichnung?.toLowerCase().includes('winter')
                ? WINTER_TURNUS
                : SOMMER_TURNUS
              ).map((turnus) => (
                <Chip
                  key={turnus}
                  label={turnus}
                  size="small"
                  color="primary"
                  variant="outlined"
                />
              ))
            )}
          </Box>
          <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
            Module mit diesen Turnus-Werten müssen in diesem Semester geplant werden.
          </Typography>
        </Box>

        {/* Statistik nach Turnus */}
        {Object.keys(statistik.nach_turnus).length > 0 && (
          <Box mb={3}>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              <strong>Verteilung nach Turnus:</strong>
            </Typography>
            <Box display="flex" gap={1} flexWrap="wrap">
              {Object.entries(statistik.nach_turnus).map(([turnus, anzahl]) => (
                <Chip
                  key={turnus}
                  label={`${turnus}: ${anzahl}`}
                  size="small"
                  icon={<School />}
                />
              ))}
            </Box>
          </Box>
        )}

        <Divider sx={{ my: 2 }} />

        {/* Module Tabelle */}
        {hasModules ? (
          <>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              <strong>Liste der nicht zugeordneten Module:</strong>
            </Typography>
            <TableContainer component={Paper} variant="outlined" sx={{ mt: 2 }}>
              <Table size="small">
                <TableHead>
                  <TableRow sx={{ bgcolor: 'grey.100' }}>
                    <TableCell><strong>Kürzel</strong></TableCell>
                    <TableCell><strong>Bezeichnung</strong></TableCell>
                    <TableCell align="center"><strong>LP</strong></TableCell>
                    <TableCell align="center"><strong>SWS</strong></TableCell>
                    <TableCell><strong>Turnus</strong></TableCell>
                    <TableCell><strong>Verantwortlich</strong></TableCell>
                    <TableCell><strong>Planungsstatus</strong></TableCell>
                    <TableCell align="center"><strong>Aktion</strong></TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {nicht_zugeordnete_module.map((modul) => {
                    // Prüfe ob jemand das Modul in einer Planung hat
                    const hatPlanung = modul.planungen && modul.planungen.length > 0;

                    return (
                      <TableRow key={modul.id} hover>
                        <TableCell>
                          <Typography variant="body2" fontWeight="bold">
                            {modul.kuerzel}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2">
                            {modul.bezeichnung_de}
                          </Typography>
                          {modul.bezeichnung_en && (
                            <Typography variant="caption" color="text.secondary" display="block">
                              {modul.bezeichnung_en}
                            </Typography>
                          )}
                        </TableCell>
                        <TableCell align="center">
                          <Chip label={modul.leistungspunkte} size="small" />
                        </TableCell>
                        <TableCell align="center">
                          <Chip label={modul.sws_gesamt} size="small" color="primary" />
                        </TableCell>
                        <TableCell>
                          <Chip
                            label={modul.turnus}
                            size="small"
                            variant="outlined"
                            color={
                              modul.turnus === 'Jedes Semester' ? 'success' :
                              modul.turnus === 'Wintersemester' ? 'info' :
                              'secondary'
                            }
                          />
                        </TableCell>
                        {/* Verantwortlicher Dozent */}
                        <TableCell>
                          {modul.verantwortlicher ? (
                            <Tooltip title={modul.verantwortlicher.email || ''}>
                              <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                <Person fontSize="small" color="primary" />
                                <Typography variant="body2">
                                  {modul.verantwortlicher.name}
                                </Typography>
                              </Box>
                            </Tooltip>
                          ) : (
                            <Typography variant="body2" color="text.disabled">
                              Nicht definiert
                            </Typography>
                          )}
                        </TableCell>
                        {/* Planungsstatus */}
                        <TableCell>
                          {hatPlanung ? (
                            <Stack spacing={0.5}>
                              {modul.planungen!.map((planung, idx) => (
                                <Box key={idx} sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                  {getPlanungStatusIcon(planung.status)}
                                  <Typography variant="caption">
                                    {planung.dozent_name}: {getPlanungStatusText(planung.status)}
                                  </Typography>
                                </Box>
                              ))}
                            </Stack>
                          ) : (
                            <Chip
                              icon={<HourglassEmpty />}
                              label="Keine Einreichung"
                              size="small"
                              color="error"
                              variant="outlined"
                            />
                          )}
                        </TableCell>
                        {/* Aktionen */}
                        <TableCell align="center">
                          <Tooltip title="Dozent zuweisen">
                            <IconButton
                              size="small"
                              color="primary"
                              onClick={() => handleOpenZuweisungDialog(modul)}
                            >
                              <PersonAdd />
                            </IconButton>
                          </Tooltip>
                        </TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </TableContainer>
          </>
        ) : (
          <Alert severity="success" sx={{ mt: 2 }}>
            <AlertTitle>Alle Module zugeordnet!</AlertTitle>
            Alle relevanten Module für dieses Semester wurden bereits in Semesterplanungen zugeordnet.
          </Alert>
        )}
      </CardContent>

      {/* Zuweisungs-Dialog */}
      <Dialog
        open={zuweisungDialogOpen}
        onClose={handleCloseZuweisungDialog}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <PersonAdd color="primary" />
            Modul zuweisen
          </Box>
        </DialogTitle>
        <DialogContent>
          {selectedModul && (
            <Box sx={{ pt: 1 }}>
              {/* Modul-Info */}
              <Paper variant="outlined" sx={{ p: 2, mb: 3, bgcolor: 'grey.50' }}>
                <Typography variant="subtitle1" fontWeight="bold">
                  {selectedModul.kuerzel}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {selectedModul.bezeichnung_de}
                </Typography>
                <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
                  <Chip label={`${selectedModul.sws_gesamt} SWS`} size="small" color="primary" />
                  <Chip label={selectedModul.turnus} size="small" variant="outlined" />
                </Box>
              </Paper>

              {/* Dozent-Auswahl */}
              <Autocomplete
                options={dozenten}
                getOptionLabel={(option) => `${option.vorname} ${option.nachname}`}
                value={selectedDozent}
                onChange={(_, newValue) => setSelectedDozent(newValue)}
                renderInput={(params) => (
                  <TextField
                    {...params}
                    label="Dozent auswählen"
                    placeholder="Name eingeben..."
                    fullWidth
                  />
                )}
                renderOption={(props, option) => (
                  <li {...props}>
                    <Box>
                      <Typography variant="body2">
                        {option.vorname} {option.nachname}
                      </Typography>
                      {option.email && (
                        <Typography variant="caption" color="text.secondary">
                          {option.email}
                        </Typography>
                      )}
                    </Box>
                  </li>
                )}
              />

              <Alert severity="info" sx={{ mt: 2 }}>
                <Typography variant="caption">
                  Der ausgewählte Dozent wird benachrichtigt und das Modul wird seiner Semesterplanung hinzugefügt.
                </Typography>
              </Alert>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseZuweisungDialog} disabled={zuweisungLoading}>
            Abbrechen
          </Button>
          <Button
            onClick={handleZuweisung}
            variant="contained"
            disabled={!selectedDozent || zuweisungLoading}
            startIcon={zuweisungLoading ? <CircularProgress size={16} /> : <PersonAdd />}
          >
            {zuweisungLoading ? 'Wird zugewiesen...' : 'Zuweisen'}
          </Button>
        </DialogActions>
      </Dialog>
    </Card>
  );
};

export default NichtZugeordneteModule;
