import { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  IconButton,
  TextField,
  InputAdornment,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Grid,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Alert,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Tooltip,
  CircularProgress,
} from '@mui/material';
import {
  Search,
  FilterList,
  Visibility,
  Restore,
  GetApp,
  ExpandMore,
  Archive as ArchiveIcon,
  Person,
  School,
  CheckCircle,
  Cancel,
  AccessTime,
} from '@mui/icons-material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { de } from 'date-fns/locale';
import { format } from 'date-fns';
import usePlanungPhaseStore from '../../store/planungPhaseStore';
import useAuthStore from '../../store/authStore';
import { ArchiviertePlanung, ArchivFilter } from '../../types/planungPhase.types';

const ArchivedPlanungsList: React.FC = () => {
  const { user } = useAuthStore();
  const {
    archivedPlanungen,
    loading,
    fetchArchivedPlanungen,
    restoreFromArchive,
    exportArchive,
  } = usePlanungPhaseStore();

  const isDekan = user?.rolle === 'Dekan';

  // Filter States
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [phaseFilter, setPhaseFilter] = useState<number | ''>('');
  const [dateFrom, setDateFrom] = useState<Date | null>(null);
  const [dateTo, setDateTo] = useState<Date | null>(null);
  const [showFilters, setShowFilters] = useState(false);

  // Pagination
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(10);

  // Dialog States
  const [selectedArchiv, setSelectedArchiv] = useState<ArchiviertePlanung | null>(null);
  const [openDetailDialog, setOpenDetailDialog] = useState(false);
  const [openRestoreDialog, setOpenRestoreDialog] = useState(false);
  const [restoreTarget, setRestoreTarget] = useState<ArchiviertePlanung | null>(null);

  useEffect(() => {
    loadArchivedPlanungen();
  }, []);

  const loadArchivedPlanungen = () => {
    const filter: ArchivFilter = {
      status: statusFilter || undefined,
      planungphase_id: phaseFilter !== '' ? phaseFilter : undefined,
      von_datum: dateFrom ? dateFrom.toISOString() : undefined,
      bis_datum: dateTo ? dateTo.toISOString() : undefined,
      nur_eigene: !isDekan, // Professoren sehen nur ihre eigenen
    };

    fetchArchivedPlanungen(filter);
  };

  const handleSearch = () => {
    loadArchivedPlanungen();
  };

  const handleResetFilters = () => {
    setSearchTerm('');
    setStatusFilter('');
    setPhaseFilter('');
    setDateFrom(null);
    setDateTo(null);
    loadArchivedPlanungen();
  };

  const handleRestore = async () => {
    if (!restoreTarget || !isDekan) return;

    try {
      const planungId = await restoreFromArchive(restoreTarget.id);
      setOpenRestoreDialog(false);
      setRestoreTarget(null);
      alert(`Planung wurde erfolgreich wiederhergestellt (ID: ${planungId})`);
      loadArchivedPlanungen(); // Reload list
    } catch (error) {
      console.error('Fehler beim Wiederherstellen:', error);
    }
  };

  const handleExport = () => {
    const filter: ArchivFilter = {
      status: statusFilter || undefined,
      planungphase_id: phaseFilter !== '' ? phaseFilter : undefined,
      von_datum: dateFrom ? dateFrom.toISOString() : undefined,
      bis_datum: dateTo ? dateTo.toISOString() : undefined,
      nur_eigene: !isDekan,
    };

    exportArchive(filter);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'freigegeben':
        return 'success';
      case 'abgelehnt':
        return 'error';
      case 'eingereicht':
        return 'warning';
      case 'entwurf':
        return 'default';
      default:
        return 'default';
    }
  };

  const getArchivGrundLabel = (grund: string) => {
    switch (grund) {
      case 'phase_geschlossen':
        return 'Phase beendet';
      case 'manuell':
        return 'Manuell archiviert';
      case 'system':
        return 'System-Archivierung';
      default:
        return grund;
    }
  };

  // Filter archived planungen based on search term
  const filteredPlanungen = archivedPlanungen.filter(planung => {
    if (!searchTerm) return true;
    const searchLower = searchTerm.toLowerCase();
    return (
      planung.professor_name.toLowerCase().includes(searchLower) ||
      planung.semester_name.toLowerCase().includes(searchLower) ||
      planung.phase_name.toLowerCase().includes(searchLower)
    );
  });

  // Group planungen by phase
  const groupedByPhase = filteredPlanungen.reduce((acc, planung) => {
    const phaseKey = `${planung.planungphase_id}-${planung.phase_name}`;
    if (!acc[phaseKey]) {
      acc[phaseKey] = {
        phase_key: phaseKey,
        phase_id: planung.planungphase_id,
        phase_name: planung.phase_name,
        planungen: []
      };
    }
    acc[phaseKey].planungen.push(planung);
    return acc;
  }, {} as Record<string, { phase_key: string; phase_id: number; phase_name: string; planungen: ArchiviertePlanung[] }>);

  // Convert to array and sort by phase_id descending (newest first)
  const phaseGroups = Object.values(groupedByPhase).sort((a, b) => b.phase_id - a.phase_id);

  const paginatedPlanungen = filteredPlanungen.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  );

  return (
    <Box>
      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
            <Typography variant="h6" display="flex" alignItems="center">
              <ArchiveIcon sx={{ mr: 1 }} />
              Archivierte Planungen
            </Typography>
            <Box>
              <Button
                startIcon={<FilterList />}
                onClick={() => setShowFilters(!showFilters)}
                variant="outlined"
                sx={{ mr: 1 }}
              >
                Filter {showFilters ? 'ausblenden' : 'anzeigen'}
              </Button>
              <Button
                startIcon={<GetApp />}
                onClick={handleExport}
                variant="contained"
                color="primary"
              >
                Excel Export
              </Button>
            </Box>
          </Box>

          {/* Quick Search */}
          <TextField
            fullWidth
            placeholder="Suche nach Professor, Semester oder Phase..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search />
                </InputAdornment>
              ),
            }}
            sx={{ mb: 2 }}
          />

          {/* Advanced Filters */}
          {showFilters && (
            <Paper elevation={1} sx={{ p: 2, mb: 2 }}>
              <Grid container spacing={2}>
                <Grid item xs={12} md={3}>
                  <FormControl fullWidth>
                    <InputLabel>Status</InputLabel>
                    <Select
                      value={statusFilter}
                      onChange={(e) => setStatusFilter(e.target.value)}
                      label="Status"
                    >
                      <MenuItem value="">Alle</MenuItem>
                      <MenuItem value="entwurf">Entwurf</MenuItem>
                      <MenuItem value="eingereicht">Eingereicht</MenuItem>
                      <MenuItem value="freigegeben">Freigegeben</MenuItem>
                      <MenuItem value="abgelehnt">Abgelehnt</MenuItem>
                    </Select>
                  </FormControl>
                </Grid>

                <Grid item xs={12} md={3}>
                  <LocalizationProvider dateAdapter={AdapterDateFns} adapterLocale={de}>
                    <DatePicker
                      label="Von Datum"
                      value={dateFrom}
                      onChange={setDateFrom}
                      format="dd.MM.yyyy"
                      slotProps={{
                        textField: { fullWidth: true }
                      }}
                    />
                  </LocalizationProvider>
                </Grid>

                <Grid item xs={12} md={3}>
                  <LocalizationProvider dateAdapter={AdapterDateFns} adapterLocale={de}>
                    <DatePicker
                      label="Bis Datum"
                      value={dateTo}
                      onChange={setDateTo}
                      format="dd.MM.yyyy"
                      slotProps={{
                        textField: { fullWidth: true }
                      }}
                    />
                  </LocalizationProvider>
                </Grid>

                <Grid item xs={12} md={3}>
                  <Box display="flex" gap={1}>
                    <Button
                      fullWidth
                      variant="contained"
                      onClick={handleSearch}
                      startIcon={<Search />}
                    >
                      Suchen
                    </Button>
                    <Button
                      fullWidth
                      variant="outlined"
                      onClick={handleResetFilters}
                    >
                      Zurücksetzen
                    </Button>
                  </Box>
                </Grid>
              </Grid>
            </Paper>
          )}

          {/* Results Info */}
          <Typography variant="body2" color="textSecondary" sx={{ mb: 2 }}>
            {filteredPlanungen.length} archivierte Planungen gefunden
            {!isDekan && ' (Nur eigene Planungen)'}
          </Typography>
        </CardContent>
      </Card>

      {/* Grouped by Phase View */}
      {loading ? (
        <Box display="flex" justifyContent="center" p={3}>
          <CircularProgress />
        </Box>
      ) : phaseGroups.length === 0 ? (
        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="body2" color="textSecondary">
            Keine archivierten Planungen gefunden
          </Typography>
        </Paper>
      ) : (
        <Box>
          {phaseGroups.map((group, index) => (
            <Accordion
              key={group.phase_key}
              defaultExpanded={index === 0}
              sx={{ mb: 2 }}
            >
              <AccordionSummary
                expandIcon={<ExpandMore />}
                sx={{
                  backgroundColor: 'primary.main',
                  color: 'primary.contrastText',
                  '&:hover': {
                    backgroundColor: 'primary.dark',
                  },
                }}
              >
                <Box display="flex" alignItems="center" width="100%" justifyContent="space-between" pr={2}>
                  <Box display="flex" alignItems="center" flex={1}>
                    <AccessTime sx={{ mr: 1 }} />
                    <Typography variant="h6">
                      {group.phase_name}
                    </Typography>
                  </Box>
                  <Box display="flex" gap={1} alignItems="center">
                    <Chip
                      label={`Gesamt: ${group.planungen.length}`}
                      size="small"
                      sx={{
                        backgroundColor: 'rgba(255, 255, 255, 0.3)',
                        color: 'white',
                        fontWeight: 'bold'
                      }}
                    />
                    <Chip
                      label={`Freigegeben: ${group.planungen.filter(p => p.status_bei_archivierung === 'freigegeben').length}`}
                      size="small"
                      sx={{
                        backgroundColor: 'success.light',
                        color: 'white',
                        fontWeight: 'bold'
                      }}
                    />
                    <Chip
                      label={`Eingereicht: ${group.planungen.filter(p => p.status_bei_archivierung === 'eingereicht').length}`}
                      size="small"
                      sx={{
                        backgroundColor: 'warning.light',
                        color: 'white',
                        fontWeight: 'bold'
                      }}
                    />
                    {group.planungen.filter(p => p.status_bei_archivierung === 'abgelehnt').length > 0 && (
                      <Chip
                        label={`Abgelehnt: ${group.planungen.filter(p => p.status_bei_archivierung === 'abgelehnt').length}`}
                        size="small"
                        sx={{
                          backgroundColor: 'error.light',
                          color: 'white',
                          fontWeight: 'bold'
                        }}
                      />
                    )}
                  </Box>
                </Box>
              </AccordionSummary>
              <AccordionDetails sx={{ p: 0 }}>
                <TableContainer>
                  <Table size="small">
                    <TableHead>
                      <TableRow>
                        <TableCell>Archiviert am</TableCell>
                        <TableCell>Professor</TableCell>
                        <TableCell>Semester</TableCell>
                        <TableCell>Status</TableCell>
                        <TableCell>Grund</TableCell>
                        <TableCell align="center">Aktionen</TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {group.planungen.map((archiv) => (
                        <TableRow
                          key={archiv.id}
                          hover
                          sx={{
                            '&:hover': {
                              backgroundColor: 'action.hover',
                            },
                          }}
                        >
                          <TableCell>
                            {archiv.archiviert_am ?
                              format(new Date(archiv.archiviert_am), 'dd.MM.yyyy HH:mm', { locale: de })
                              : '-'}
                          </TableCell>
                          <TableCell>
                            <Box display="flex" alignItems="center">
                              <Person sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                              {archiv.professor_name}
                            </Box>
                          </TableCell>
                          <TableCell>
                            <Box display="flex" alignItems="center">
                              <School sx={{ mr: 1, fontSize: 18, color: 'text.secondary' }} />
                              {archiv.semester_name}
                            </Box>
                          </TableCell>
                          <TableCell>
                            <Chip
                              size="small"
                              label={archiv.status_bei_archivierung}
                              color={getStatusColor(archiv.status_bei_archivierung)}
                              icon={
                                archiv.status_bei_archivierung === 'freigegeben' ? <CheckCircle /> :
                                archiv.status_bei_archivierung === 'abgelehnt' ? <Cancel /> : undefined
                              }
                            />
                          </TableCell>
                          <TableCell>
                            <Chip
                              size="small"
                              label={getArchivGrundLabel(archiv.archiviert_grund)}
                              variant="outlined"
                            />
                          </TableCell>
                          <TableCell align="center">
                            <Tooltip title="Details anzeigen">
                              <IconButton
                                size="small"
                                onClick={() => {
                                  setSelectedArchiv(archiv);
                                  setOpenDetailDialog(true);
                                }}
                              >
                                <Visibility />
                              </IconButton>
                            </Tooltip>
                            {isDekan && (
                              <Tooltip title="Wiederherstellen">
                                <IconButton
                                  size="small"
                                  color="primary"
                                  onClick={() => {
                                    setRestoreTarget(archiv);
                                    setOpenRestoreDialog(true);
                                  }}
                                >
                                  <Restore />
                                </IconButton>
                              </Tooltip>
                            )}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </TableContainer>
              </AccordionDetails>
            </Accordion>
          ))}
        </Box>
      )}

      {/* Detail Dialog */}
      <Dialog
        open={openDetailDialog}
        onClose={() => setOpenDetailDialog(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          Archivierte Planung - Details
        </DialogTitle>
        <DialogContent>
          {selectedArchiv && (
            <Box>
              <Grid container spacing={2} sx={{ mb: 3 }}>
                <Grid item xs={12} md={6}>
                  <Typography variant="caption" color="textSecondary">
                    Professor
                  </Typography>
                  <Typography variant="body1">
                    {selectedArchiv.professor_name}
                  </Typography>
                </Grid>
                <Grid item xs={12} md={6}>
                  <Typography variant="caption" color="textSecondary">
                    Archiviert am
                  </Typography>
                  <Typography variant="body1">
                    {selectedArchiv.archiviert_am ?
                      format(new Date(selectedArchiv.archiviert_am), 'dd.MM.yyyy HH:mm', { locale: de })
                      : '-'}
                  </Typography>
                </Grid>
                <Grid item xs={12} md={6}>
                  <Typography variant="caption" color="textSecondary">
                    Semester
                  </Typography>
                  <Typography variant="body1">
                    {selectedArchiv.semester_name}
                  </Typography>
                </Grid>
                <Grid item xs={12} md={6}>
                  <Typography variant="caption" color="textSecondary">
                    Planungsphase
                  </Typography>
                  <Typography variant="body1">
                    {selectedArchiv.phase_name}
                  </Typography>
                </Grid>
                <Grid item xs={12} md={6}>
                  <Typography variant="caption" color="textSecondary">
                    Status bei Archivierung
                  </Typography>
                  <Chip
                    label={selectedArchiv.status_bei_archivierung}
                    color={getStatusColor(selectedArchiv.status_bei_archivierung)}
                    size="small"
                  />
                </Grid>
                <Grid item xs={12} md={6}>
                  <Typography variant="caption" color="textSecondary">
                    Archivierungsgrund
                  </Typography>
                  <Chip
                    label={getArchivGrundLabel(selectedArchiv.archiviert_grund)}
                    variant="outlined"
                    size="small"
                  />
                </Grid>
              </Grid>

              {/* Planung Data */}
              <Accordion>
                <AccordionSummary expandIcon={<ExpandMore />}>
                  <Typography>Planungsdaten anzeigen</Typography>
                </AccordionSummary>
                <AccordionDetails>
                  <Box sx={{ maxHeight: 400, overflow: 'auto' }}>
                    <pre style={{ fontSize: '12px', whiteSpace: 'pre-wrap' }}>
                      {JSON.stringify(selectedArchiv.planung_daten, null, 2)}
                    </pre>
                  </Box>
                </AccordionDetails>
              </Accordion>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDetailDialog(false)}>Schließen</Button>
          {isDekan && selectedArchiv && (
            <Button
              variant="contained"
              color="primary"
              startIcon={<Restore />}
              onClick={() => {
                setRestoreTarget(selectedArchiv);
                setOpenDetailDialog(false);
                setOpenRestoreDialog(true);
              }}
            >
              Wiederherstellen
            </Button>
          )}
        </DialogActions>
      </Dialog>

      {/* Restore Confirmation Dialog */}
      <Dialog
        open={openRestoreDialog}
        onClose={() => setOpenRestoreDialog(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Planung wiederherstellen</DialogTitle>
        <DialogContent>
          <Alert severity="warning" sx={{ mb: 2 }}>
            Möchten Sie diese archivierte Planung wirklich wiederherstellen?
          </Alert>
          {restoreTarget && (
            <Box>
              <Typography variant="body2" gutterBottom>
                <strong>Professor:</strong> {restoreTarget.professor_name}
              </Typography>
              <Typography variant="body2" gutterBottom>
                <strong>Semester:</strong> {restoreTarget.semester_name}
              </Typography>
              <Typography variant="body2" gutterBottom>
                <strong>Phase:</strong> {restoreTarget.phase_name}
              </Typography>
              <Typography variant="body2">
                <strong>Status:</strong> {restoreTarget.status_bei_archivierung}
              </Typography>
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenRestoreDialog(false)}>Abbrechen</Button>
          <Button
            onClick={handleRestore}
            variant="contained"
            color="primary"
            startIcon={<Restore />}
          >
            Wiederherstellen
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ArchivedPlanungsList;