import React, { useState, useEffect } from 'react';
import {
  Container, Paper, Typography, Box, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Chip, IconButton, TextField,
  InputAdornment, Button, Grid, Tooltip, CircularProgress, Alert,
  FormControl, InputLabel, Select, MenuItem, Divider, Tab, Tabs,
  Stack, FormControlLabel, Checkbox
} from '@mui/material';
import {
  Search, Add, Delete, SwapHoriz, History, Group,
  Refresh, FilterList
} from '@mui/icons-material';
import modulVerwaltungService, {
  ModulMitDozenten,
  ModulDozentZuordnung
} from '../services/modulVerwaltungService';
import useAuthStore from '../store/authStore';
import { createContextLogger } from '../utils/logger';
import { getErrorMessage } from '../utils/errorUtils';
import AddDozentDialog from '../components/modul-verwaltung/AddDozentDialog';

const log = createContextLogger('ModulVerwaltung');
import RemoveDozentDialog from '../components/modul-verwaltung/RemoveDozentDialog';
import ReplaceDozentDialog from '../components/modul-verwaltung/ReplaceDozentDialog';
import BulkTransferDialog from '../components/modul-verwaltung/BulkTransferDialog';
import AuditLogViewer from '../components/modul-verwaltung/AuditLogViewer';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;
  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  );
}

const ModulVerwaltungPage: React.FC = () => {
  const { user, isAuthenticated } = useAuthStore();

  // Auth Check
  const isDekan = React.useMemo(() => {
    if (!user) return false;
    if (typeof user.rolle === 'string') return user.rolle === 'dekan';
    return user.rolle?.name === 'dekan';
  }, [user]);

  // States
  const [loading, setLoading] = useState(false);
  const [initializing, setInitializing] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [module, setModule] = useState<ModulMitDozenten[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedPoId, setSelectedPoId] = useState<number | ''>('');
  const [nurAktive, setNurAktive] = useState(true);
  const [currentTab, setCurrentTab] = useState(0);

  // Selected Module/Dozenten for Operations
  const [selectedModulForAdd, setSelectedModulForAdd] = useState<ModulMitDozenten | null>(null);
  const [selectedForRemove, setSelectedForRemove] = useState<{
    modul: ModulMitDozenten;
    zuordnung: ModulDozentZuordnung;
  } | null>(null);
  const [selectedForReplace, setSelectedForReplace] = useState<{
    modul: ModulMitDozenten;
    zuordnung: ModulDozentZuordnung;
  } | null>(null);

  // Dialogs
  const [addDozentDialog, setAddDozentDialog] = useState(false);
  const [replaceDozentDialog, setReplaceDozentDialog] = useState(false);
  const [removeDozentDialog, setRemoveDozentDialog] = useState(false);
  const [bulkTransferDialog, setBulkTransferDialog] = useState(false);

  // Initialize
  useEffect(() => {
    const initializePage = async () => {
      await new Promise(resolve => setTimeout(resolve, 100));
      setInitializing(false);
      if (isAuthenticated && isDekan) {
        loadModule();
      }
    };
    initializePage();
  }, [isAuthenticated, isDekan]);

  // Load Module
  const loadModule = async () => {
    if (!isAuthenticated || !isDekan) return;
    setLoading(true);
    setError(null);
    try {
      const response = await modulVerwaltungService.getModuleMitDozenten({
        po_id: selectedPoId || undefined,
        nur_aktive: nurAktive
      });

      if (response.success) {
        setModule(response.data || []);
        log.debug(' Module loaded:', response.data?.length);
      } else {
        setError(response.message || 'Fehler beim Laden der Module');
      }
    } catch (error: unknown) {
      log.error(' Error:', { error });
      setError(getErrorMessage(error, 'Ein Fehler ist aufgetreten'));
    } finally {
      setLoading(false);
    }
  };

  // Filter Module by Search Term
  const filteredModule = React.useMemo(() => {
    if (!searchTerm) return module;

    const term = searchTerm.toLowerCase();
    return module.filter(m =>
      m.kuerzel.toLowerCase().includes(term) ||
      m.bezeichnung_de.toLowerCase().includes(term) ||
      m.dozenten.some(d => d.name.toLowerCase().includes(term))
    );
  }, [module, searchTerm]);

  // Handle Refresh
  const handleRefresh = () => {
    loadModule();
  };

  // Handle Add Dozent
  const handleAddDozent = (modul: ModulMitDozenten) => {
    setSelectedModulForAdd(modul);
    setAddDozentDialog(true);
  };

  // Handle Remove Dozent
  const handleRemoveDozent = (modul: ModulMitDozenten, zuordnung: ModulDozentZuordnung) => {
    setSelectedForRemove({ modul, zuordnung });
    setRemoveDozentDialog(true);
  };

  // Handle Replace Dozent
  const handleReplaceDozent = (modul: ModulMitDozenten, zuordnung: ModulDozentZuordnung) => {
    setSelectedForReplace({ modul, zuordnung });
    setReplaceDozentDialog(true);
  };

  // Handle Success (reload data + show message)
  const handleSuccess = (message: string = 'Aktion erfolgreich durchgeführt') => {
    setSuccess(message);
    loadModule();
    setTimeout(() => setSuccess(null), 5000);
  };

  // Render Rolle Chip
  const renderRolleChip = (rolle: string) => {
    const colors: Record<string, any> = {
      verantwortlich: 'primary',
      mitwirkend: 'default',
      vertreter: 'secondary',
      pruefend: 'info'
    };

    return (
      <Chip
        label={rolle}
        size="small"
        color={colors[rolle] || 'default'}
      />
    );
  };

  // Authorization Check
  if (!isAuthenticated || !isDekan) {
    return (
      <Container maxWidth="md" sx={{ mt: 4 }}>
        <Alert severity="error">
          Keine Berechtigung. Diese Seite ist nur für Dekan zugänglich.
        </Alert>
      </Container>
    );
  }

  if (initializing) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="xl" sx={{ mt: 3, mb: 4 }}>
      {/* Header */}
      <Paper elevation={0} sx={{ p: 3, mb: 3, backgroundColor: 'primary.main', color: 'white' }}>
        <Typography variant="h4" gutterBottom>
          <Group sx={{ mr: 1, verticalAlign: 'middle' }} />
          Modul-Verwaltung
        </Typography>
        <Typography variant="body2">
          Verwalten Sie Modul-Zuordnungen und weisen Sie Dozenten zu
        </Typography>
      </Paper>

      {/* Error/Success Messages */}
      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}
      {success && (
        <Alert severity="success" sx={{ mb: 2 }} onClose={() => setSuccess(null)}>
          {success}
        </Alert>
      )}

      {/* Tabs */}
      <Paper elevation={2} sx={{ mb: 3 }}>
        <Tabs
          value={currentTab}
          onChange={(_, newValue) => setCurrentTab(newValue)}
          indicatorColor="primary"
          textColor="primary"
        >
          <Tab label="Module & Dozenten" icon={<Group />} iconPosition="start" />
          <Tab label="Audit Log" icon={<History />} iconPosition="start" />
        </Tabs>
      </Paper>

      {/* Tab 1: Module & Dozenten */}
      <TabPanel value={currentTab} index={0}>
        <Paper elevation={2} sx={{ p: 3 }}>
          {/* Filters & Search */}
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12} md={4}>
              <TextField
                fullWidth
                variant="outlined"
                placeholder="Suche nach Modul oder Dozent..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Search />
                    </InputAdornment>
                  )
                }}
              />
            </Grid>

            <Grid item xs={12} md={3}>
              <FormControl fullWidth>
                <InputLabel>Prüfungsordnung</InputLabel>
                <Select
                  value={selectedPoId}
                  label="Prüfungsordnung"
                  onChange={(e) => setSelectedPoId(e.target.value as number)}
                >
                  <MenuItem value="">Alle</MenuItem>
                  <MenuItem value={1}>PO 2023</MenuItem>
                  <MenuItem value={2}>PO 2020</MenuItem>
                  <MenuItem value={3}>PO 2017</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={12} md={2}>
              <FormControlLabel
                control={
                  <Checkbox
                    checked={nurAktive}
                    onChange={(e) => setNurAktive(e.target.checked)}
                  />
                }
                label="Nur aktive"
              />
            </Grid>

            <Grid item xs={12} md={3}>
              <Stack direction="row" spacing={1}>
                <Button
                  variant="outlined"
                  startIcon={<FilterList />}
                  onClick={handleRefresh}
                  fullWidth
                >
                  Filter anwenden
                </Button>
                <Tooltip title="Aktualisieren">
                  <IconButton onClick={handleRefresh} color="primary">
                    <Refresh />
                  </IconButton>
                </Tooltip>
              </Stack>
            </Grid>
          </Grid>

          <Divider sx={{ my: 2 }} />

          {/* Action Buttons */}
          <Box sx={{ mb: 3 }}>
            <Stack direction="row" spacing={2}>
              <Button
                variant="contained"
                startIcon={<SwapHoriz />}
                onClick={() => setBulkTransferDialog(true)}
              >
                Bulk Transfer
              </Button>
            </Stack>
          </Box>

          {/* Module Table */}
          {loading ? (
            <Box display="flex" justifyContent="center" py={4}>
              <CircularProgress />
            </Box>
          ) : (
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell><strong>Kürzel</strong></TableCell>
                    <TableCell><strong>Bezeichnung</strong></TableCell>
                    <TableCell><strong>LP</strong></TableCell>
                    <TableCell><strong>Dozenten</strong></TableCell>
                    <TableCell align="right"><strong>Aktionen</strong></TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {filteredModule.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} align="center">
                        <Typography variant="body2" color="text.secondary" py={4}>
                          Keine Module gefunden
                        </Typography>
                      </TableCell>
                    </TableRow>
                  ) : (
                    filteredModule.map((modul) => (
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
                            <Typography variant="caption" color="text.secondary">
                              {modul.bezeichnung_en}
                            </Typography>
                          )}
                        </TableCell>
                        <TableCell>
                          {modul.leistungspunkte}
                        </TableCell>
                        <TableCell>
                          {modul.dozenten.length === 0 ? (
                            <Typography variant="caption" color="text.secondary">
                              Keine Zuordnungen
                            </Typography>
                          ) : (
                            <Stack spacing={0.5}>
                              {modul.dozenten.map((doz) => (
                                <Box key={doz.zuordnung_id} display="flex" alignItems="center" gap={1}>
                                  <Typography variant="body2">
                                    {doz.name}
                                  </Typography>
                                  {renderRolleChip(doz.rolle)}
                                  <Stack direction="row" spacing={0.5}>
                                    <Tooltip title="Ersetzen">
                                      <IconButton
                                        size="small"
                                        onClick={() => handleReplaceDozent(modul, doz)}
                                      >
                                        <SwapHoriz fontSize="small" />
                                      </IconButton>
                                    </Tooltip>
                                    <Tooltip title="Entfernen">
                                      <IconButton
                                        size="small"
                                        color="error"
                                        onClick={() => handleRemoveDozent(modul, doz)}
                                      >
                                        <Delete fontSize="small" />
                                      </IconButton>
                                    </Tooltip>
                                  </Stack>
                                </Box>
                              ))}
                            </Stack>
                          )}
                        </TableCell>
                        <TableCell align="right">
                          <Tooltip title="Dozent hinzufügen">
                            <IconButton
                              color="primary"
                              onClick={() => handleAddDozent(modul)}
                            >
                              <Add />
                            </IconButton>
                          </Tooltip>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          )}

          {/* Summary */}
          <Box sx={{ mt: 2 }}>
            <Typography variant="caption" color="text.secondary">
              {filteredModule.length} Module • {filteredModule.reduce((sum, m) => sum + m.dozenten.length, 0)} Zuordnungen
            </Typography>
          </Box>
        </Paper>
      </TabPanel>

      {/* Tab 2: Audit Log */}
      <TabPanel value={currentTab} index={1}>
        <AuditLogViewer />
      </TabPanel>

      {/* Dialogs */}

      {/* Add Dozent Dialog */}
      {selectedModulForAdd && (
        <AddDozentDialog
          open={addDozentDialog}
          onClose={() => {
            setAddDozentDialog(false);
            setSelectedModulForAdd(null);
          }}
          onSuccess={() => handleSuccess('Dozent erfolgreich hinzugefügt')}
          modul={{
            id: selectedModulForAdd.id,
            kuerzel: selectedModulForAdd.kuerzel,
            bezeichnung_de: selectedModulForAdd.bezeichnung_de
          }}
        />
      )}

      {/* Remove Dozent Dialog */}
      {selectedForRemove && (
        <RemoveDozentDialog
          open={removeDozentDialog}
          onClose={() => {
            setRemoveDozentDialog(false);
            setSelectedForRemove(null);
          }}
          onSuccess={() => handleSuccess('Dozent erfolgreich entfernt')}
          data={{
            modul: {
              id: selectedForRemove.modul.id,
              kuerzel: selectedForRemove.modul.kuerzel,
              bezeichnung_de: selectedForRemove.modul.bezeichnung_de
            },
            zuordnung: {
              zuordnung_id: selectedForRemove.zuordnung.zuordnung_id,
              name: selectedForRemove.zuordnung.name,
              rolle: selectedForRemove.zuordnung.rolle
            }
          }}
        />
      )}

      {/* Replace Dozent Dialog */}
      {selectedForReplace && (
        <ReplaceDozentDialog
          open={replaceDozentDialog}
          onClose={() => {
            setReplaceDozentDialog(false);
            setSelectedForReplace(null);
          }}
          onSuccess={() => handleSuccess('Dozent erfolgreich ersetzt')}
          data={{
            modul: {
              id: selectedForReplace.modul.id,
              kuerzel: selectedForReplace.modul.kuerzel,
              bezeichnung_de: selectedForReplace.modul.bezeichnung_de
            },
            zuordnung: {
              zuordnung_id: selectedForReplace.zuordnung.zuordnung_id,
              id: selectedForReplace.zuordnung.id,
              name: selectedForReplace.zuordnung.name,
              rolle: selectedForReplace.zuordnung.rolle
            }
          }}
        />
      )}

      {/* Bulk Transfer Dialog */}
      <BulkTransferDialog
        open={bulkTransferDialog}
        onClose={() => setBulkTransferDialog(false)}
        onSuccess={() => handleSuccess('Bulk Transfer erfolgreich durchgeführt')}
        module={module}
      />
    </Container>
  );
};

export default ModulVerwaltungPage;
