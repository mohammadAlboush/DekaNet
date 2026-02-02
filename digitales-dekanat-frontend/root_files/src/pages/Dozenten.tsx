import React, { useState, useEffect, useCallback } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Avatar,
  Chip,
  IconButton,
  TextField,
  InputAdornment,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Grid,
  List,
  ListItem,
  ListItemText,
  Tooltip,
  CircularProgress,
  Alert,
  FormControlLabel,
  Switch,
  Tabs,
  Tab,
} from '@mui/material';
import {
  Search,
  Person,
  Email,
  Visibility,
  Edit,
  Add,
  Delete,
  Warning,
  Close,
} from '@mui/icons-material';
import dozentService, { Dozent, DozentCreateData, DozentUpdateData } from '../services/dozentService';
import useAuthStore from '../store/authStore';
import { getErrorMessage } from '../utils/errorUtils';

interface DozentModul {
  modul_id: number;
  kuerzel: string;
  bezeichnung_de: string;
  rolle: string;
  po_id: number;
}

interface DozentModulWithRoles extends Omit<DozentModul, 'rolle'> {
  rollen: string[];
}

interface DozentBenutzer {
  username: string;
  email: string;
  rolle: string;
  aktiv: boolean;
  letzter_login?: string;
}

interface DozentDetails extends Dozent {
  module?: DozentModul[];
  benutzer?: DozentBenutzer;
  updated_at?: string;
}

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

const DozentenPage: React.FC = () => {
  const { user, isAuthenticated } = useAuthStore();
  
  const isDekan = React.useMemo(() => {
    if (!user) return false;
    if (typeof user.rolle === 'string') return user.rolle === 'dekan';
    return user.rolle?.name === 'dekan';
  }, [user]);

  const [loading, setLoading] = useState(false);
  const [initializing, setInitializing] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [dozenten, setDozenten] = useState<Dozent[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedDozent, setSelectedDozent] = useState<DozentDetails | null>(null);
  const [detailsDialog, setDetailsDialog] = useState(false);
  const [editDialog, setEditDialog] = useState(false);
  const [createDialog, setCreateDialog] = useState(false);
  const [deleteDialog, setDeleteDialog] = useState(false);
  const [deleteForce, setDeleteForce] = useState(false);
  const [detailsTab, setDetailsTab] = useState(0);
  
  const [createFormData, setCreateFormData] = useState<DozentCreateData>({
    titel: '',
    vorname: '',
    nachname: '',
    email: '',
    fachbereich: '',
    aktiv: true,
  });
  
  const [editFormData, setEditFormData] = useState<DozentUpdateData>({
    titel: '',
    vorname: '',
    nachname: '',
    email: '',
    fachbereich: '',
    aktiv: true,
  });

  useEffect(() => {
    const initializePage = async () => {
      await new Promise(resolve => setTimeout(resolve, 100));
      setInitializing(false);

      if (isAuthenticated && user) {
        loadDozenten();
      }
    };
    initializePage();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isAuthenticated]);

  const loadDozenten = useCallback(async () => {
    if (!isAuthenticated) return;

    setLoading(true);
    setError(null);

    try {
      const response = await dozentService.getAllDozenten();

      if (response.success) {
        setDozenten(response.data || []);
      } else {
        setError(response.message || 'Fehler beim Laden der Dozenten');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  }, [isAuthenticated]);

  const handleSearch = async () => {
    if (!searchTerm) {
      loadDozenten();
      return;
    }

    setLoading(true);
    setError(null);
    
    try {
      const response = await dozentService.searchDozenten(searchTerm);
      
      if (response.success) {
        setDozenten(response.data || []);
      } else {
        setError(response.message || 'Fehler bei der Suche');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleViewDetails = async (dozentId: number) => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await dozentService.getDozentDetails(dozentId);
      
      if (response.success && response.data) {
        setSelectedDozent(response.data);
        setDetailsDialog(true);
        setDetailsTab(0);
      } else {
        setError(response.message || 'Fehler beim Laden der Details');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleOpenCreate = () => {
    setCreateFormData({
      titel: '',
      vorname: '',
      nachname: '',
      email: '',
      fachbereich: '',
      aktiv: true,
    });
    setCreateDialog(true);
  };

  const handleOpenEdit = (dozent: Dozent) => {
    setEditFormData({
      titel: dozent.titel || '',
      vorname: dozent.vorname || '',
      nachname: dozent.nachname || '',
      email: dozent.email || '',
      fachbereich: dozent.fachbereich || '',
      aktiv: dozent.aktiv !== false,
    });
    setSelectedDozent(dozent);
    setEditDialog(true);
  };

  const handleCreate = async () => {
    if (!createFormData.nachname) {
      setError('Nachname ist erforderlich');
      return;
    }

    setLoading(true);
    setError(null);
    
    try {
      const response = await dozentService.createDozent(createFormData);
      
      if (response.success) {
        setSuccess('Dozent erfolgreich erstellt');
        setCreateDialog(false);
        loadDozenten();
      } else {
        setError(response.message || 'Fehler beim Erstellen');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleUpdate = async () => {
    if (!selectedDozent) return;

    setLoading(true);
    setError(null);
    
    try {
      const response = await dozentService.updateDozent(
        selectedDozent.id,
        editFormData
      );
      
      if (response.success) {
        setSuccess('Dozent erfolgreich aktualisiert');
        setEditDialog(false);
        loadDozenten();
      } else {
        setError(response.message || 'Fehler beim Aktualisieren');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDelete = (dozent: Dozent) => {
    setSelectedDozent(dozent);
    setDeleteForce(false);
    setDeleteDialog(true);
  };

  const handleDelete = async () => {
    if (!selectedDozent) return;

    setLoading(true);
    setError(null);
    
    try {
      const response = await dozentService.deleteDozent(selectedDozent.id, deleteForce);
      
      if (response.success) {
        setSuccess('Dozent erfolgreich gelöscht');
        setDeleteDialog(false);
        loadDozenten();
      } else {
        setError(response.message || 'Fehler beim Löschen');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  if (initializing) {
    return (
      <Container>
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '400px' }}>
          <CircularProgress />
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight={600} gutterBottom>
          Dozenten
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Dozentenverwaltung - {dozenten.length} Dozenten
        </Typography>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 3 }} onClose={() => setSuccess(null)}>
          {success}
        </Alert>
      )}

      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
          <TextField
            placeholder="Dozent suchen..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search />
                </InputAdornment>
              ),
            }}
            size="small"
            sx={{ flexGrow: 1 }}
          />
          <Button
            variant="outlined"
            onClick={handleSearch}
            disabled={loading}
          >
            Suchen
          </Button>
          {searchTerm && (
            <Button
              variant="outlined"
              onClick={() => {
                setSearchTerm('');
                loadDozenten();
              }}
            >
              Zurücksetzen
            </Button>
          )}
          {isDekan && (
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={handleOpenCreate}
            >
              Neu
            </Button>
          )}
        </Box>
      </Paper>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Fachbereich</TableCell>
              <TableCell align="center">Module</TableCell>
              <TableCell align="center">Status</TableCell>
              <TableCell align="center">Aktionen</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading && dozenten.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  <CircularProgress size={32} sx={{ my: 2 }} />
                </TableCell>
              </TableRow>
            ) : dozenten.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  <Typography color="text.secondary" sx={{ py: 4 }}>
                    {searchTerm ? 'Keine Dozenten gefunden' : 'Keine Dozenten vorhanden'}
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              dozenten.map((dozent) => (
                <TableRow 
                  key={dozent.id}
                  hover
                  sx={{ cursor: 'pointer' }}
                  onClick={() => handleViewDetails(dozent.id)}
                >
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                      <Avatar sx={{ bgcolor: 'primary.main' }}>
                        <Person />
                      </Avatar>
                      <Box>
                        <Typography variant="body2" fontWeight={500}>
                          {dozent.name_mit_titel || dozent.name_komplett}
                        </Typography>
                        {dozent.titel && (
                          <Typography variant="caption" color="text.secondary">
                            {dozent.titel}
                          </Typography>
                        )}
                      </Box>
                    </Box>
                  </TableCell>
                  <TableCell>
                    {dozent.email ? (
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        <Email fontSize="small" color="action" />
                        <Typography variant="body2">{dozent.email}</Typography>
                      </Box>
                    ) : (
                      <Typography variant="body2" color="text.secondary">-</Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    {dozent.fachbereich ? (
                      <Typography variant="body2">{dozent.fachbereich}</Typography>
                    ) : (
                      <Typography variant="body2" color="text.secondary">-</Typography>
                    )}
                  </TableCell>
                  <TableCell align="center">
                    <Chip
                      label={dozent.anzahl_module || 0}
                      size="small"
                      color="primary"
                      variant="outlined"
                    />
                  </TableCell>
                  <TableCell align="center">
                    <Chip
                      label={dozent.aktiv ? 'Aktiv' : 'Inaktiv'}
                      size="small"
                      color={dozent.aktiv ? 'success' : 'default'}
                      variant="outlined"
                    />
                  </TableCell>
                  <TableCell align="center" onClick={(e) => e.stopPropagation()}>
                    <Tooltip title="Details anzeigen">
                      <IconButton
                        size="small"
                        onClick={() => handleViewDetails(dozent.id)}
                      >
                        <Visibility />
                      </IconButton>
                    </Tooltip>
                    {isDekan && (
                      <>
                        <Tooltip title="Bearbeiten">
                          <IconButton 
                            size="small"
                            onClick={() => handleOpenEdit(dozent)}
                          >
                            <Edit />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Löschen">
                          <IconButton 
                            size="small"
                            color="error"
                            onClick={() => handleOpenDelete(dozent)}
                          >
                            <Delete />
                          </IconButton>
                        </Tooltip>
                      </>
                    )}
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ========== VOLLSTÄNDIGE DETAILS DIALOG ========== */}
      <Dialog
        open={detailsDialog}
        onClose={() => setDetailsDialog(false)}
        maxWidth="lg"
        fullWidth
      >
        {selectedDozent && (
          <>
            <DialogTitle>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                  <Person color="primary" />
                  <Box>
                    <Typography variant="h6">
                      {selectedDozent.name_mit_titel || selectedDozent.name_komplett}
                    </Typography>
                    {selectedDozent.email && (
                      <Typography variant="caption" color="text.secondary">
                        {selectedDozent.email}
                      </Typography>
                    )}
                  </Box>
                </Box>
                <Box>
                  {isDekan && (
                    <Button
                      variant="outlined"
                      startIcon={<Edit />}
                      onClick={() => {
                        setDetailsDialog(false);
                        handleOpenEdit(selectedDozent);
                      }}
                      sx={{ mr: 1 }}
                    >
                      Bearbeiten
                    </Button>
                  )}
                  <IconButton onClick={() => setDetailsDialog(false)}>
                    <Close />
                  </IconButton>
                </Box>
              </Box>
            </DialogTitle>
            
            <DialogContent dividers>
              <Tabs value={detailsTab} onChange={(_e, v) => setDetailsTab(v)} sx={{ mb: 2 }}>
                <Tab label="Übersicht" />
                <Tab label="Module" />
                <Tab label="Benutzer-Account" />
                <Tab label="Alle Daten" />
              </Tabs>

              <TabPanel value={detailsTab} index={0}>
                <Grid container spacing={3}>
                  {selectedDozent.titel && (
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Titel
                      </Typography>
                      <Typography variant="h6">
                        {selectedDozent.titel}
                      </Typography>
                    </Grid>
                  )}

                  {selectedDozent.vorname && (
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Vorname
                      </Typography>
                      <Typography variant="h6">
                        {selectedDozent.vorname}
                      </Typography>
                    </Grid>
                  )}

                  <Grid item xs={12} md={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Nachname
                    </Typography>
                    <Typography variant="h6">
                      {selectedDozent.nachname}
                    </Typography>
                  </Grid>

                  {selectedDozent.fachbereich && (
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Fachbereich
                      </Typography>
                      <Typography variant="h6">
                        {selectedDozent.fachbereich}
                      </Typography>
                    </Grid>
                  )}

                  <Grid item xs={12} md={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Status
                    </Typography>
                    <Chip
                      label={selectedDozent.aktiv ? 'Aktiv' : 'Inaktiv'}
                      color={selectedDozent.aktiv ? 'success' : 'default'}
                    />
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <Typography variant="subtitle2" color="text.secondary">
                      Anzahl Module
                    </Typography>
                    <Typography variant="h6">
                      {selectedDozent.anzahl_module || 0}
                    </Typography>
                  </Grid>

                  {selectedDozent.created_at && (
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Erstellt am
                      </Typography>
                      <Typography>
                        {new Date(selectedDozent.created_at).toLocaleString('de-DE')}
                      </Typography>
                    </Grid>
                  )}

                  {selectedDozent.updated_at && (
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Aktualisiert am
                      </Typography>
                      <Typography>
                        {new Date(selectedDozent.updated_at).toLocaleString('de-DE')}
                      </Typography>
                    </Grid>
                  )}
                </Grid>
              </TabPanel>

              <TabPanel value={detailsTab} index={1}>
                {selectedDozent.module && selectedDozent.module.length > 0 ? (
                  <List>
                    {(() => {
                      // Deduplicate modules by kuerzel and po_id, combine roles
                      const moduleMap = new Map<string, DozentModulWithRoles>();

                      selectedDozent.module.forEach((modul: DozentModul) => {
                        // Use kuerzel + po_id as unique key
                        const key = `${modul.kuerzel}-${modul.po_id}`;

                        if (moduleMap.has(key)) {
                          // Module exists, add role if not already present
                          const existing = moduleMap.get(key)!;
                          if (!existing.rollen.includes(modul.rolle)) {
                            existing.rollen.push(modul.rolle);
                          }
                        } else {
                          // New module entry
                          moduleMap.set(key, {
                            ...modul,
                            rollen: [modul.rolle]
                          });
                        }
                      });

                      // Convert map to array and render
                      return Array.from(moduleMap.values()).map((modul: DozentModulWithRoles) => (
                        <ListItem key={`${modul.kuerzel}-${modul.po_id}`}>
                          <ListItemText
                            primary={`${modul.kuerzel} - ${modul.bezeichnung_de}`}
                            secondary={`Rolle: ${modul.rollen.join(', ')} | PO: ${modul.po_id}`}
                          />
                        </ListItem>
                      ));
                    })()}
                  </List>
                ) : (
                  <Typography color="text.secondary">Keine Module zugeordnet</Typography>
                )}
              </TabPanel>

              <TabPanel value={detailsTab} index={2}>
                {selectedDozent.hat_benutzer_account && selectedDozent.benutzer ? (
                  <Grid container spacing={2}>
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Benutzername
                      </Typography>
                      <Typography>{selectedDozent.benutzer.username}</Typography>
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Email
                      </Typography>
                      <Typography>{selectedDozent.benutzer.email}</Typography>
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Rolle
                      </Typography>
                      <Chip label={selectedDozent.benutzer.rolle} size="small" />
                    </Grid>
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" color="text.secondary">
                        Status
                      </Typography>
                      <Chip 
                        label={selectedDozent.benutzer.aktiv ? 'Aktiv' : 'Inaktiv'}
                        color={selectedDozent.benutzer.aktiv ? 'success' : 'default'}
                        size="small"
                      />
                    </Grid>
                    {selectedDozent.benutzer.letzter_login && (
                      <Grid item xs={12}>
                        <Typography variant="subtitle2" color="text.secondary">
                          Letzter Login
                        </Typography>
                        <Typography>
                          {new Date(selectedDozent.benutzer.letzter_login).toLocaleString('de-DE')}
                        </Typography>
                      </Grid>
                    )}
                  </Grid>
                ) : (
                  <Alert severity="info">
                    Dieser Dozent hat keinen Benutzer-Account.
                  </Alert>
                )}
              </TabPanel>

              <TabPanel value={detailsTab} index={3}>
                <Typography variant="h6" gutterBottom>Alle Datenbankfelder</Typography>
                <Box sx={{ fontFamily: 'monospace', fontSize: '0.9rem' }}>
                  <pre>{JSON.stringify(selectedDozent, null, 2)}</pre>
                </Box>
              </TabPanel>
            </DialogContent>
            
            <DialogActions>
              <Button onClick={() => setDetailsDialog(false)}>
                Schließen
              </Button>
            </DialogActions>
          </>
        )}
      </Dialog>

      {/* ========== EDIT DIALOG ========== */}
      <Dialog
        open={editDialog}
        onClose={() => setEditDialog(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Edit color="primary" />
            <Typography variant="h6">Dozent bearbeiten</Typography>
          </Box>
        </DialogTitle>
        <DialogContent dividers>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <TextField
                label="Titel"
                fullWidth
                value={editFormData.titel}
                onChange={(e) => setEditFormData({ ...editFormData, titel: e.target.value })}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                label="Vorname"
                fullWidth
                value={editFormData.vorname}
                onChange={(e) => setEditFormData({ ...editFormData, vorname: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label="Nachname"
                fullWidth
                required
                value={editFormData.nachname}
                onChange={(e) => setEditFormData({ ...editFormData, nachname: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label="Email"
                type="email"
                fullWidth
                value={editFormData.email}
                onChange={(e) => setEditFormData({ ...editFormData, email: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label="Fachbereich"
                fullWidth
                value={editFormData.fachbereich}
                onChange={(e) => setEditFormData({ ...editFormData, fachbereich: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={editFormData.aktiv}
                    onChange={(e) => setEditFormData({ ...editFormData, aktiv: e.target.checked })}
                  />
                }
                label="Aktiv"
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEditDialog(false)}>Abbrechen</Button>
          <Button variant="contained" onClick={handleUpdate} disabled={loading}>
            Speichern
          </Button>
        </DialogActions>
      </Dialog>

      {/* ========== CREATE DIALOG ========== */}
      <Dialog
        open={createDialog}
        onClose={() => setCreateDialog(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Add color="primary" />
            <Typography variant="h6">Neuen Dozenten erstellen</Typography>
          </Box>
        </DialogTitle>
        <DialogContent dividers>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <TextField
                label="Titel"
                fullWidth
                value={createFormData.titel}
                onChange={(e) => setCreateFormData({ ...createFormData, titel: e.target.value })}
              />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField
                label="Vorname"
                fullWidth
                value={createFormData.vorname}
                onChange={(e) => setCreateFormData({ ...createFormData, vorname: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label="Nachname"
                fullWidth
                required
                value={createFormData.nachname}
                onChange={(e) => setCreateFormData({ ...createFormData, nachname: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label="Email"
                type="email"
                fullWidth
                value={createFormData.email}
                onChange={(e) => setCreateFormData({ ...createFormData, email: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label="Fachbereich"
                fullWidth
                value={createFormData.fachbereich}
                onChange={(e) => setCreateFormData({ ...createFormData, fachbereich: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={createFormData.aktiv}
                    onChange={(e) => setCreateFormData({ ...createFormData, aktiv: e.target.checked })}
                  />
                }
                label="Aktiv"
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setCreateDialog(false)}>Abbrechen</Button>
          <Button variant="contained" onClick={handleCreate} disabled={loading}>
            Erstellen
          </Button>
        </DialogActions>
      </Dialog>

      {/* ========== DELETE DIALOG ========== */}
      <Dialog
        open={deleteDialog}
        onClose={() => setDeleteDialog(false)}
        maxWidth="sm"
      >
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Warning color="error" />
            <Typography variant="h6">Dozent löschen</Typography>
          </Box>
        </DialogTitle>
        <DialogContent>
          <Typography gutterBottom>
            Möchten Sie den Dozenten <strong>{selectedDozent?.name_komplett}</strong> wirklich löschen?
          </Typography>
          <FormControlLabel
            control={
              <Switch
                checked={deleteForce}
                onChange={(e) => setDeleteForce(e.target.checked)}
              />
            }
            label="Erzwingen (auch bei Modulzuordnungen)"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialog(false)}>Abbrechen</Button>
          <Button
            variant="contained"
            color="error"
            onClick={handleDelete}
            disabled={loading}
          >
            Löschen
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default DozentenPage;