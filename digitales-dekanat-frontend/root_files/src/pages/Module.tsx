import React, { useState, useEffect, useCallback } from 'react';
import {
  Container, Paper, Typography, Box, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Chip, IconButton, TextField,
  InputAdornment, Button, Dialog, DialogTitle, DialogContent,
  DialogActions, Grid, Tooltip, CircularProgress, Alert,
  FormControlLabel, Switch, MenuItem, Divider, List, ListItem,
  ListItemText, Tabs, Tab, Select, FormControl, InputLabel, Card, CardContent,
  Stack, ListItemSecondaryAction
} from '@mui/material';
import {
  Search, Visibility, Edit, School, Add, Delete, Warning,
  Close, Save, Cancel, SwapHoriz, History
} from '@mui/icons-material';
import modulService from '../services/modulService';
import useAuthStore from '../store/authStore';
import { Modul, ModulDetails, ModulDozent, ModulLehrform, ModulLiteratur } from '../types/modul.types';
import { createContextLogger } from '../utils/logger';
import { getErrorMessage } from '../utils/errorUtils';

const log = createContextLogger('Module');
import BulkTransferDialog from '../components/modul-verwaltung/BulkTransferDialog';
import AuditLogViewer from '../components/modul-verwaltung/AuditLogViewer';
import ComprehensiveEditDialog from '../components/modul-verwaltung/ComprehensiveEditDialog';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
  loaded?: boolean; // Performance: Nur rendern wenn geladen
}

// Performance-Optimierung: Memoized TabPanel - rendert NUR wenn Tab aktiv oder bereits geladen
const TabPanel = React.memo(function TabPanel(props: TabPanelProps) {
  const { children, value, index, loaded = true, ...other } = props;

  // Performance: Nicht rendern wenn noch nicht geladen und nicht aktiv
  if (!loaded && value !== index) return null;

  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  );
});

// Memoized Table Row Component - verhindert unnötige Re-Renders
interface ModulRowProps {
  modul: Modul;
  canEdit: boolean;
  onViewDetails: (id: number) => void;
  onEdit: (modul: Modul) => void;
  onDelete: (modul: Modul) => void;
}

const MemoizedModulRow = React.memo(function ModulRow({
  modul, canEdit, onViewDetails, onEdit, onDelete
}: ModulRowProps) {
  return (
    <TableRow
      hover
      sx={{ cursor: 'pointer' }}
      onClick={() => onViewDetails(modul.id)}
    >
      <TableCell>
        <Chip label={modul.kuerzel} color="primary" variant="outlined" size="small" />
      </TableCell>
      <TableCell>
        <Typography variant="body2" fontWeight={500}>
          {modul.bezeichnung_de}
        </Typography>
        {modul.bezeichnung_en && (
          <Typography variant="caption" color="text.secondary">
            {modul.bezeichnung_en}
          </Typography>
        )}
      </TableCell>
      <TableCell align="center">
        <Chip label={modul.leistungspunkte} size="small" color="success" variant="outlined" />
      </TableCell>
      <TableCell align="center">
        <Typography variant="body2">{modul.sws_gesamt}</Typography>
      </TableCell>
      <TableCell>
        <Chip label={modul.turnus} size="small" variant="outlined" />
      </TableCell>
      <TableCell align="center" onClick={(e) => e.stopPropagation()}>
        <Tooltip title="Details anzeigen">
          <IconButton size="small" onClick={() => onViewDetails(modul.id)}>
            <Visibility />
          </IconButton>
        </Tooltip>
        {canEdit && (
          <>
            <Tooltip title="Bearbeiten">
              <IconButton size="small" color="primary" onClick={() => onEdit(modul)}>
                <Edit />
              </IconButton>
            </Tooltip>
            <Tooltip title="Löschen">
              <IconButton size="small" color="error" onClick={() => onDelete(modul)}>
                <Delete />
              </IconButton>
            </Tooltip>
          </>
        )}
      </TableCell>
    </TableRow>
  );
}, (prevProps, nextProps) => {
  // Custom comparison: re-render if any displayed modul data or canEdit changes
  return prevProps.modul.id === nextProps.modul.id &&
         prevProps.modul.kuerzel === nextProps.modul.kuerzel &&
         prevProps.modul.bezeichnung_de === nextProps.modul.bezeichnung_de &&
         prevProps.modul.bezeichnung_en === nextProps.modul.bezeichnung_en &&
         prevProps.modul.leistungspunkte === nextProps.modul.leistungspunkte &&
         prevProps.modul.sws_gesamt === nextProps.modul.sws_gesamt &&
         prevProps.modul.turnus === nextProps.modul.turnus &&
         prevProps.canEdit === nextProps.canEdit;
});

const ModulePage: React.FC = () => {
  const { user, isAuthenticated } = useAuthStore();
  
  const isDekan = React.useMemo(() => {
    if (!user) return false;
    if (typeof user.rolle === 'string') return user.rolle === 'dekan';
    return user.rolle?.name === 'dekan';
  }, [user]);

  // Check if user is Modulverantwortlicher for a specific module
  const isModulverantwortlicher = React.useCallback((modul: Modul | ModulDetails | null): boolean => {
    if (!user || !modul) {
      log.debug('isModulverantwortlicher: false - no user or modul');
      return false;
    }
    if (!user.dozent_id) {
      log.debug('isModulverantwortlicher: false - user has no dozent_id', { user });
      return false;
    }

    // Check if dozenten array exists and contains the user as 'verantwortlicher'
    if (modul.dozenten && Array.isArray(modul.dozenten)) {
      const dozentenWithRoles = modul.dozenten.map(d => ({
        dozent_id: d.dozent_id,
        rolle: d.rolle,
        name: d.name_komplett || d.name_kurz || `${d.vorname || ''} ${d.nachname || ''}`.trim()
      }));

      // Unterstütze beide Schreibweisen: "verantwortlicher" UND "Modulverantwortlicher"
      const isVerantwortlicher = modul.dozenten.some(d => {
        if (d.dozent_id !== user.dozent_id) return false;

        const rolle = d.rolle?.toLowerCase() || '';
        return rolle === 'verantwortlicher' || rolle === 'modulverantwortlicher';
      });

      log.debug('isModulverantwortlicher check:', {
        modulId: modul.id,
        modulName: modul.kuerzel,
        userDozentId: user.dozent_id,
        dozentenWithRoles,
        modulDozenten: modul.dozenten,
        isVerantwortlicher
      });
      return isVerantwortlicher;
    }

    log.debug('isModulverantwortlicher: false - no dozenten array');
    return false;
  }, [user]);

  // Check if user can edit a module (Dekan OR Modulverantwortlicher)
  const canEditModul = React.useCallback((modul: Modul | ModulDetails | null): boolean => {
    return isDekan || isModulverantwortlicher(modul);
  }, [isDekan, isModulverantwortlicher]);

  // Basic States
  const [loading, setLoading] = useState(false);
  const [initializing, setInitializing] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [module, setModule] = useState<Modul[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedModul, setSelectedModul] = useState<ModulDetails | null>(null);
  
  // Dialog States
  const [detailsDialog, setDetailsDialog] = useState(false);
  const [createDialog, setCreateDialog] = useState(false);
  const [deleteDialog, setDeleteDialog] = useState(false);
  const [deleteForce, setDeleteForce] = useState(false);
  const [detailsTab, setDetailsTab] = useState(0);

  // Performance-Optimierung: Lazy Tab Loading - nur geladene Tabs rendern
  // Using Record instead of Set for better React state handling
  const [loadedTabs, setLoadedTabs] = useState<Record<number, boolean>>({ 0: true });
  
  // Edit Mode State - which section is being edited
  const [editMode, setEditMode] = useState<string | null>(null);
  
  // Options for Dropdowns
  const [lehrformenOptions, setLehrformenOptions] = useState<any[]>([]);
  const [dozentenOptions, setDozentenOptions] = useState<any[]>([]);
  
  // Form Data
  const [createFormData, setCreateFormData] = useState<any>({
    kuerzel: '', po_id: 1, bezeichnung_de: '', bezeichnung_en: '',
    untertitel: '', leistungspunkte: 5, turnus: 'WiSe',
    gruppengroesse: '', teilnehmerzahl: '', anmeldemodalitaeten: ''
  });
  
  const [editFormData, setEditFormData] = useState<any>({});
  
  // New Item Forms
  const [newLehrform, setNewLehrform] = useState({ lehrform_id: '', sws: 2 });
  const [newDozent, setNewDozent] = useState({ dozent_id: '', rolle: 'lehrperson' });
  const [newLiteratur, setNewLiteratur] = useState({
    titel: '', autoren: '', verlag: '', jahr: '', isbn: '',
    typ: 'buch', pflichtliteratur: false, sortierung: 0
  });

  // Dozent Edit State
  const [editingDozentId, setEditingDozentId] = useState<number | null>(null);
  const [editDozentRolle, setEditDozentRolle] = useState<string>('');
  const [replaceDozentDialog, setReplaceDozentDialog] = useState(false);
  const [replaceDozentData, setReplaceDozentData] = useState<{ id: number; name: string; rolle: string } | null>(null);
  const [replaceDozentNew, setReplaceDozentNew] = useState<string>('');

  // Bulk Transfer Dialog (Dekan only)
  const [bulkTransferDialog, setBulkTransferDialog] = useState(false);

  // Comprehensive Edit Dialog State
  const [comprehensiveEditDialog, setComprehensiveEditDialog] = useState(false);

  // useEffect nur einmal ausführen, statt bei jedem user-Objekt-Update
  useEffect(() => {
    const initializePage = async () => {
      await new Promise(resolve => setTimeout(resolve, 100));
      setInitializing(false);
      if (isAuthenticated && user) {
        // Beide API-Calls parallel starten
        await Promise.all([
          loadModule(),
          loadOptions()
        ]);
      }
    };
    initializePage();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isAuthenticated]); // Nur isAuthenticated als Dependency

  const loadModule = useCallback(async () => {
    if (!isAuthenticated) return;
    setLoading(true);
    setError(null);
    try {
      const response = await modulService.getAllModules({ per_page: 200 });
      if (response.success) {
        setModule(response.data || []);
      } else {
        setError(response.message || 'Fehler beim Laden der Module');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  }, [isAuthenticated]);

  // Parallele API-Calls statt sequentiell
  const loadOptions = useCallback(async () => {
    try {
      const [lehrformen, dozenten] = await Promise.all([
        modulService.getLehrformenOptions(),
        modulService.getDozentenOptions()
      ]);

      if (lehrformen.success) setLehrformenOptions(lehrformen.data || []);
      if (dozenten.success) setDozentenOptions(dozenten.data || []);
    } catch (error) {
      log.error('Error loading options:', error);
    }
  }, []);

  const handleSearch = useCallback(async () => {
    if (!searchTerm) {
      loadModule();
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const response = await modulService.searchModules(searchTerm);
      if (response.success) {
        setModule(response.data || []);
      } else {
        setError(response.message || 'Fehler bei der Suche');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  }, [searchTerm, loadModule]);

  // Performance-Optimierung: useCallback für stabilere Referenzen
  const handleViewDetails = useCallback(async (modulId: number) => {
    setLoading(true);
    setError(null);
    try {
      const response = await modulService.getModulDetails(modulId);
      if (response.success && response.data) {
        setSelectedModul(response.data);
        setDetailsDialog(true);
        setDetailsTab(0);
        setEditMode(null);
        setLoadedTabs({ 0: true }); // Reset loaded tabs for new module
      } else {
        setError(response.message || 'Fehler beim Laden der Details');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  }, []);

  const handleOpenCreate = useCallback(() => {
    setCreateFormData({
      kuerzel: '', po_id: 1, bezeichnung_de: '', bezeichnung_en: '',
      untertitel: '', leistungspunkte: 5, turnus: 'WiSe',
      gruppengroesse: '', teilnehmerzahl: '', anmeldemodalitaeten: ''
    });
    setCreateDialog(true);
  }, []);


  // Umfassende Bearbeitungsansicht öffnen
  const handleOpenComprehensiveEdit = useCallback(async (modul: Modul) => {
    setLoading(true);
    try {
      const response = await modulService.getModulDetails(modul.id);
      if (response.success && response.data) {
        setSelectedModul(response.data);
        setComprehensiveEditDialog(true);
      } else {
        setError('Fehler beim Laden der Modul-Details');
      }
    } catch (e: unknown) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  }, []);

  const handleCreate = async () => {
    if (!createFormData.kuerzel || !createFormData.bezeichnung_de) {
      setError('Kürzel und Bezeichnung sind erforderlich');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const response = await modulService.createModule(createFormData);
      if (response.success) {
        setSuccess('Modul erfolgreich erstellt');
        setCreateDialog(false);
        loadModule();
      } else {
        setError(response.message || 'Fehler beim Erstellen');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDelete = useCallback((modul: Modul) => {
    setSelectedModul(modul as ModulDetails);
    setDeleteForce(false);
    setDeleteDialog(true);
  }, []);

  const handleDelete = async () => {
    if (!selectedModul) return;
    setLoading(true);
    setError(null);
    try {
      const response = await modulService.deleteModule(selectedModul.id, deleteForce);
      if (response.success) {
        setSuccess('Modul erfolgreich gelöscht');
        setDeleteDialog(false);
        loadModule();
      } else {
        setError(response.message || 'Fehler beim Löschen');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // ========== EDIT HANDLERS FOR DETAIL SECTIONS ==========

  const handleEditBasic = () => {
    if (!selectedModul) return;
    setEditFormData({
      bezeichnung_de: selectedModul.bezeichnung_de,
      bezeichnung_en: selectedModul.bezeichnung_en || '',
      untertitel: selectedModul.untertitel || '',
      leistungspunkte: selectedModul.leistungspunkte || 5,
      turnus: selectedModul.turnus || 'WiSe',
      gruppengroesse: selectedModul.gruppengroesse || '',
      teilnehmerzahl: selectedModul.teilnehmerzahl || '',
      anmeldemodalitaeten: selectedModul.anmeldemodalitaeten || ''
    });
    setEditMode('basis');
  };

  const handleSaveBasic = async () => {
    if (!selectedModul) return;
    setLoading(true);
    try {
      const response = await modulService.updateModule(selectedModul.id, editFormData);
      if (response.success) {
        setSuccess('Basis-Daten aktualisiert');
        setEditMode(null);
        await handleViewDetails(selectedModul.id);
      } else {
        setError(response.message || 'Fehler beim Speichern');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // LEHRFORMEN
  const handleAddLehrform = async () => {
    if (!selectedModul || !newLehrform.lehrform_id) return;
    setLoading(true);
    try {
      const response = await modulService.addLehrform(selectedModul.id, {
        lehrform_id: parseInt(newLehrform.lehrform_id),
        sws: newLehrform.sws
      });
      if (response.success) {
        setSuccess('Lehrform hinzugefügt');
        setNewLehrform({ lehrform_id: '', sws: 2 });
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteLehrform = async (lehrformId: number) => {
    if (!selectedModul || !window.confirm('Lehrform wirklich entfernen?')) return;
    setLoading(true);
    try {
      const response = await modulService.deleteLehrform(selectedModul.id, lehrformId);
      if (response.success) {
        setSuccess('Lehrform entfernt');
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // DOZENTEN
  const handleAddDozent = async () => {
    if (!selectedModul || !newDozent.dozent_id) return;
    setLoading(true);
    try {
      const response = await modulService.addDozent(selectedModul.id, {
        dozent_id: parseInt(newDozent.dozent_id),
        rolle: newDozent.rolle as 'verantwortlicher' | 'lehrperson'
      });
      if (response.success) {
        setSuccess('Dozent hinzugefügt');
        setNewDozent({ dozent_id: '', rolle: 'lehrperson' });
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteDozent = async (dozentId: number) => {
    if (!selectedModul || !window.confirm('Dozent wirklich entfernen?')) return;
    setLoading(true);
    try {
      const response = await modulService.deleteDozent(selectedModul.id, dozentId);
      if (response.success) {
        setSuccess('Dozent entfernt');
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // Dozent Rolle bearbeiten
  const handleStartEditDozentRolle = (dozent: ModulDozent) => {
    setEditingDozentId(dozent.id);
    setEditDozentRolle(dozent.rolle);
  };

  const handleSaveDozentRolle = async (dozentZuordnungId: number) => {
    if (!selectedModul || !editDozentRolle) return;
    setLoading(true);
    try {
      const response = await modulService.updateDozentRolle(selectedModul.id, dozentZuordnungId, editDozentRolle);
      if (response.success) {
        setSuccess('Dozent-Rolle aktualisiert');
        setEditingDozentId(null);
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error, 'Fehler beim Aktualisieren der Rolle'));
    } finally {
      setLoading(false);
    }
  };

  const handleCancelEditDozentRolle = () => {
    setEditingDozentId(null);
    setEditDozentRolle('');
  };

  // Dozent ersetzen
  const handleOpenReplaceDozent = (dozent: ModulDozent) => {
    setReplaceDozentData({
      id: dozent.id,
      name: dozent.name_komplett || dozent.name_kurz || `${dozent.vorname || ''} ${dozent.nachname || ''}`.trim(),
      rolle: dozent.rolle
    });
    setReplaceDozentNew('');
    setReplaceDozentDialog(true);
  };

  const handleReplaceDozent = async () => {
    if (!selectedModul || !replaceDozentData || !replaceDozentNew) return;
    setLoading(true);
    try {
      const response = await modulService.replaceDozent(
        selectedModul.id,
        replaceDozentData.id,
        parseInt(replaceDozentNew)
      );
      if (response.success) {
        setSuccess('Dozent erfolgreich ersetzt');
        setReplaceDozentDialog(false);
        setReplaceDozentData(null);
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error, 'Fehler beim Ersetzen des Dozenten'));
    } finally {
      setLoading(false);
    }
  };

  // LITERATUR
  const handleAddLiteratur = async () => {
    if (!selectedModul || !newLiteratur.titel) return;
    setLoading(true);
    try {
      const response = await modulService.addLiteratur(selectedModul.id, {
        ...newLiteratur,
        jahr: newLiteratur.jahr ? parseInt(newLiteratur.jahr) : undefined
      });
      if (response.success) {
        setSuccess('Literatur hinzugefügt');
        setNewLiteratur({
          titel: '', autoren: '', verlag: '', jahr: '', isbn: '',
          typ: 'buch', pflichtliteratur: false, sortierung: 0
        });
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteLiteratur = async (literaturId: number) => {
    if (!selectedModul || !window.confirm('Literatur wirklich entfernen?')) return;
    setLoading(true);
    try {
      const response = await modulService.deleteLiteratur(selectedModul.id, literaturId);
      if (response.success) {
        setSuccess('Literatur entfernt');
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // PRÜFUNG
  const handleEditPruefung = () => {
    if (!selectedModul) return;
    const pruefung = selectedModul.pruefung || {};
    setEditFormData({
      pruefungsform: pruefung.pruefungsform || '',
      pruefungsdauer_minuten: pruefung.pruefungsdauer_minuten || '',
      pruefungsleistungen: pruefung.pruefungsleistungen || '',
      benotung: pruefung.benotung || ''
    });
    setEditMode('pruefung');
  };

  const handleSavePruefung = async () => {
    if (!selectedModul) return;
    setLoading(true);
    try {
      const response = await modulService.updatePruefung(selectedModul.id, editFormData);
      if (response.success) {
        setSuccess('Prüfung aktualisiert');
        setEditMode(null);
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // LERNERGEBNISSE
  const handleEditLernergebnisse = () => {
    if (!selectedModul) return;
    const lernergebnisse = selectedModul.lernergebnisse || {};
    setEditFormData({
      lernziele: lernergebnisse.lernziele || '',
      kompetenzen: lernergebnisse.kompetenzen || '',
      inhalt: lernergebnisse.inhalt || ''
    });
    setEditMode('lernergebnisse');
  };

  const handleSaveLernergebnisse = async () => {
    if (!selectedModul) return;
    setLoading(true);
    try {
      const response = await modulService.updateLernergebnisse(selectedModul.id, editFormData);
      if (response.success) {
        setSuccess('Lernergebnisse aktualisiert');
        setEditMode(null);
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // VORAUSSETZUNGEN
  const handleEditVoraussetzungen = () => {
    if (!selectedModul) return;
    const voraussetzungen = selectedModul.voraussetzungen || {};
    setEditFormData({
      formal: voraussetzungen.formal || '',
      empfohlen: voraussetzungen.empfohlen || '',
      inhaltlich: voraussetzungen.inhaltlich || ''
    });
    setEditMode('voraussetzungen');
  };

  const handleSaveVoraussetzungen = async () => {
    if (!selectedModul) return;
    setLoading(true);
    try {
      const response = await modulService.updateVoraussetzungen(selectedModul.id, editFormData);
      if (response.success) {
        setSuccess('Voraussetzungen aktualisiert');
        setEditMode(null);
        await handleViewDetails(selectedModul.id);
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // ARBEITSAUFWAND
  const handleEditArbeitsaufwand = () => {
    if (!selectedModul) return;
    const arbeitsaufwand = selectedModul.arbeitsaufwand?.[0] || {};
    setEditFormData({
      kontaktzeit_stunden: arbeitsaufwand.kontaktzeit_stunden || '',
      selbststudium_stunden: arbeitsaufwand.selbststudium_stunden || '',
      pruefungsvorbereitung_stunden: arbeitsaufwand.pruefungsvorbereitung_stunden || '',
      gesamt_stunden: arbeitsaufwand.gesamt_stunden || ''
    });
    setEditMode('arbeitsaufwand');
  };

  const handleSaveArbeitsaufwand = async () => {
    if (!selectedModul) return;
    setLoading(true);
    try {
      const response = await modulService.updateArbeitsaufwand(selectedModul.id, editFormData);
      if (response.success) {
        setSuccess('Arbeitsaufwand aktualisiert');
        setEditMode(null);
        await handleViewDetails(selectedModul.id);
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
          Module
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Modulverwaltung - {module.length} Module
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
            placeholder="Modul suchen..."
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
          <Button variant="outlined" onClick={handleSearch} disabled={loading}>
            Suchen
          </Button>
          {searchTerm && (
            <Button variant="outlined" onClick={() => { setSearchTerm(''); loadModule(); }}>
              Zurücksetzen
            </Button>
          )}
          {isDekan && (
            <>
              <Button variant="outlined" startIcon={<SwapHoriz />} onClick={() => setBulkTransferDialog(true)}>
                Bulk Transfer
              </Button>
              <Button variant="contained" startIcon={<Add />} onClick={handleOpenCreate}>
                Neu
              </Button>
            </>
          )}
        </Box>
      </Paper>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Kürzel</TableCell>
              <TableCell>Bezeichnung</TableCell>
              <TableCell align="center">ECTS</TableCell>
              <TableCell align="center">SWS</TableCell>
              <TableCell>Turnus</TableCell>
              <TableCell align="center">Aktionen</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {loading && module.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  <CircularProgress size={32} sx={{ my: 2 }} />
                </TableCell>
              </TableRow>
            ) : module.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  <Typography color="text.secondary" sx={{ py: 4 }}>
                    {searchTerm ? 'Keine Module gefunden' : 'Keine Module vorhanden'}
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              module.map((modul) => (
                <MemoizedModulRow
                  key={modul.id}
                  modul={modul}
                  canEdit={canEditModul(modul)}
                  onViewDetails={handleViewDetails}
                  onEdit={handleOpenComprehensiveEdit}
                  onDelete={handleOpenDelete}
                />
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ========== AUDIT LOG SECTION (DEKAN ONLY) ========== */}
      {isDekan && (
        <Paper sx={{ mt: 3, p: 3 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
            <History color="primary" />
            <Typography variant="h6">Änderungsprotokoll</Typography>
          </Box>
          <AuditLogViewer />
        </Paper>
      )}

      {/* ========== VOLLSTÄNDIGE DETAILS DIALOG WITH EDIT CAPABILITIES ========== */}
      <Dialog open={detailsDialog} onClose={() => setDetailsDialog(false)} maxWidth="lg" fullWidth>
        {selectedModul && (
          <>
            <DialogTitle>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
                  <School color="primary" />
                  <Box>
                    <Typography variant="h6">
                      {selectedModul.kuerzel} - {selectedModul.bezeichnung_de}
                    </Typography>
                    {selectedModul.bezeichnung_en && (
                      <Typography variant="caption" color="text.secondary">
                        {selectedModul.bezeichnung_en}
                      </Typography>
                    )}
                  </Box>
                </Box>
                <IconButton onClick={() => setDetailsDialog(false)}>
                  <Close />
                </IconButton>
              </Box>
            </DialogTitle>
            
            <DialogContent dividers>
              <Tabs value={detailsTab} onChange={(_e, v) => {
                  setDetailsTab(v);
                  // Lazy loading: Tab als geladen markieren
                  if (!loadedTabs[v]) {
                    setLoadedTabs(prev => ({ ...prev, [v]: true }));
                  }
                }} sx={{ mb: 2 }}>
                <Tab label="Übersicht" />
                <Tab label="Lehrformen" />
                <Tab label="Dozenten" />
                <Tab label="Literatur" />
                <Tab label="Prüfung" />
                <Tab label="Lernergebnisse" />
                <Tab label="Voraussetzungen" />
                <Tab label="Arbeitsaufwand" />
              </Tabs>

              {/* TAB 0: ÜBERSICHT (BASIS-DATEN) */}
              <TabPanel value={detailsTab} index={0} loaded={!!loadedTabs[0]}>
                {editMode !== 'basis' ? (
                  <Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                      <Typography variant="h6">Basis-Daten</Typography>
                      {canEditModul(selectedModul) && (
                        <Button startIcon={<Edit />} onClick={handleEditBasic} variant="outlined" size="small">
                          Bearbeiten
                        </Button>
                      )}
                    </Box>
                    <Grid container spacing={3}>
                      <Grid item xs={12} md={4}>
                        <Typography variant="subtitle2" color="text.secondary">Kürzel</Typography>
                        <Typography variant="h6">{selectedModul.kuerzel}</Typography>
                      </Grid>
                      <Grid item xs={12} md={4}>
                        <Typography variant="subtitle2" color="text.secondary">Leistungspunkte</Typography>
                        <Typography variant="h6">{selectedModul.leistungspunkte} ECTS</Typography>
                      </Grid>
                      <Grid item xs={12} md={4}>
                        <Typography variant="subtitle2" color="text.secondary">Turnus</Typography>
                        <Typography variant="h6">{selectedModul.turnus}</Typography>
                      </Grid>
                      <Grid item xs={12}>
                        <Typography variant="subtitle2" color="text.secondary">Bezeichnung (DE)</Typography>
                        <Typography>{selectedModul.bezeichnung_de}</Typography>
                      </Grid>
                      {selectedModul.bezeichnung_en && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="text.secondary">Bezeichnung (EN)</Typography>
                          <Typography>{selectedModul.bezeichnung_en}</Typography>
                        </Grid>
                      )}
                      {selectedModul.untertitel && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="text.secondary">Untertitel</Typography>
                          <Typography>{selectedModul.untertitel}</Typography>
                        </Grid>
                      )}
                      {selectedModul.gruppengroesse && (
                        <Grid item xs={12} md={6}>
                          <Typography variant="subtitle2" color="text.secondary">Gruppengröße</Typography>
                          <Typography>{selectedModul.gruppengroesse}</Typography>
                        </Grid>
                      )}
                      {selectedModul.teilnehmerzahl && (
                        <Grid item xs={12} md={6}>
                          <Typography variant="subtitle2" color="text.secondary">Teilnehmerzahl</Typography>
                          <Typography>{selectedModul.teilnehmerzahl}</Typography>
                        </Grid>
                      )}
                      {selectedModul.anmeldemodalitaeten && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="text.secondary">Anmeldemodalitäten</Typography>
                          <Typography>{selectedModul.anmeldemodalitaeten}</Typography>
                        </Grid>
                      )}
                    </Grid>
                  </Box>
                ) : (
                  <Box>
                    <Typography variant="h6" gutterBottom>Basis-Daten bearbeiten</Typography>
                    <Grid container spacing={2}>
                      <Grid item xs={12}>
                        <TextField fullWidth label="Bezeichnung (DE)" required
                          value={editFormData.bezeichnung_de || ''}
                          onChange={(e) => setEditFormData({...editFormData, bezeichnung_de: e.target.value})} />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth label="Bezeichnung (EN)"
                          value={editFormData.bezeichnung_en || ''}
                          onChange={(e) => setEditFormData({...editFormData, bezeichnung_en: e.target.value})} />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth label="Untertitel"
                          value={editFormData.untertitel || ''}
                          onChange={(e) => setEditFormData({...editFormData, untertitel: e.target.value})} />
                      </Grid>
                      <Grid item xs={6}>
                        <TextField fullWidth label="Leistungspunkte" type="number"
                          value={editFormData.leistungspunkte || ''}
                          onChange={(e) => setEditFormData({...editFormData, leistungspunkte: parseInt(e.target.value)})} />
                      </Grid>
                      <Grid item xs={6}>
                        <TextField fullWidth select label="Turnus"
                          value={editFormData.turnus || ''}
                          onChange={(e) => setEditFormData({...editFormData, turnus: e.target.value})}>
                          <MenuItem value="WiSe">Wintersemester</MenuItem>
                          <MenuItem value="SoSe">Sommersemester</MenuItem>
                          <MenuItem value="WiSe/SoSe">Jedes Semester</MenuItem>
                        </TextField>
                      </Grid>
                      <Grid item xs={6}>
                        <TextField fullWidth label="Gruppengröße"
                          value={editFormData.gruppengroesse || ''}
                          onChange={(e) => setEditFormData({...editFormData, gruppengroesse: e.target.value})} />
                      </Grid>
                      <Grid item xs={6}>
                        <TextField fullWidth label="Teilnehmerzahl"
                          value={editFormData.teilnehmerzahl || ''}
                          onChange={(e) => setEditFormData({...editFormData, teilnehmerzahl: e.target.value})} />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={3} label="Anmeldemodalitäten"
                          value={editFormData.anmeldemodalitaeten || ''}
                          onChange={(e) => setEditFormData({...editFormData, anmeldemodalitaeten: e.target.value})} />
                      </Grid>
                    </Grid>
                    <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                      <Button variant="contained" startIcon={<Save />} onClick={handleSaveBasic} disabled={loading}>
                        Speichern
                      </Button>
                      <Button variant="outlined" startIcon={<Cancel />} onClick={() => setEditMode(null)}>
                        Abbrechen
                      </Button>
                    </Stack>
                  </Box>
                )}
              </TabPanel>

              {/* TAB 1: LEHRFORMEN */}
              <TabPanel value={detailsTab} index={1} loaded={!!loadedTabs[1]}>
                <Typography variant="h6" gutterBottom>Lehrformen</Typography>
                <List>
                  {selectedModul.lehrformen && selectedModul.lehrformen.length > 0 ? (
                    selectedModul.lehrformen.map((lf: ModulLehrform) => (
                      <ListItem key={lf.id}>
                        <ListItemText
                          primary={`${lf.bezeichnung} (${lf.kuerzel})`}
                          secondary={`${lf.sws} SWS`}
                        />
                        {canEditModul(selectedModul) && (
                          <ListItemSecondaryAction>
                            <IconButton edge="end" color="error" onClick={() => handleDeleteLehrform(lf.id)}>
                              <Delete />
                            </IconButton>
                          </ListItemSecondaryAction>
                        )}
                      </ListItem>
                    ))
                  ) : (
                    <Typography color="text.secondary">Keine Lehrformen zugeordnet</Typography>
                  )}
                </List>

                {canEditModul(selectedModul) && (
                  <Card sx={{ mt: 3, bgcolor: 'grey.50' }}>
                    <CardContent>
                      <Typography variant="subtitle2" gutterBottom>Neue Lehrform hinzufügen</Typography>
                      <Grid container spacing={2}>
                        <Grid item xs={8}>
                          <FormControl fullWidth size="small">
                            <InputLabel>Lehrform</InputLabel>
                            <Select 
                              value={newLehrform.lehrform_id}
                              onChange={(e) => setNewLehrform({...newLehrform, lehrform_id: e.target.value})}
                            >
                              {lehrformenOptions.map(lf => (
                                <MenuItem key={lf.id} value={lf.id}>
                                  {lf.bezeichnung} ({lf.kuerzel})
                                </MenuItem>
                              ))}
                            </Select>
                          </FormControl>
                        </Grid>
                        <Grid item xs={2}>
                          <TextField
                            fullWidth
                            size="small"
                            label="SWS"
                            type="number"
                            value={newLehrform.sws}
                            onChange={(e) => setNewLehrform({...newLehrform, sws: parseInt(e.target.value)})}
                          />
                        </Grid>
                        <Grid item xs={2}>
                          <Button
                            fullWidth
                            variant="contained"
                            size="small"
                            startIcon={<Add />}
                            onClick={handleAddLehrform}
                            disabled={!newLehrform.lehrform_id || loading}
                          >
                            Hinzufügen
                          </Button>
                        </Grid>
                      </Grid>
                    </CardContent>
                  </Card>
                )}
              </TabPanel>

              {/* TAB 2: DOZENTEN */}
              <TabPanel value={detailsTab} index={2} loaded={!!loadedTabs[2]}>
                <Typography variant="h6" gutterBottom>Dozenten</Typography>
                <List>
                  {selectedModul.dozenten && selectedModul.dozenten.length > 0 ? (
                    selectedModul.dozenten.map((d: ModulDozent) => (
                      <ListItem key={d.id} sx={{ bgcolor: editingDozentId === d.id ? 'action.selected' : 'inherit', borderRadius: 1 }}>
                        <ListItemText
                          primary={d.name_komplett || d.name_kurz || `${d.vorname || ''} ${d.nachname || ''}`.trim()}
                          secondary={
                            editingDozentId === d.id ? (
                              <FormControl size="small" sx={{ mt: 1, minWidth: 180 }}>
                                <Select
                                  value={editDozentRolle}
                                  onChange={(e) => setEditDozentRolle(e.target.value)}
                                >
                                  <MenuItem value="verantwortlicher">Modulverantwortlicher</MenuItem>
                                  <MenuItem value="lehrperson">Lehrperson</MenuItem>
                                  <MenuItem value="pruefend">Prüfend</MenuItem>
                                  <MenuItem value="mitwirkend">Mitwirkend</MenuItem>
                                  <MenuItem value="vertreter">Vertreter</MenuItem>
                                </Select>
                              </FormControl>
                            ) : (
                              <Chip
                                label={d.rolle}
                                size="small"
                                color={d.rolle === 'verantwortlicher' || d.rolle === 'Modulverantwortlicher' ? 'primary' : 'default'}
                                variant="outlined"
                              />
                            )
                          }
                        />
                        {canEditModul(selectedModul) && (
                          <ListItemSecondaryAction>
                            {editingDozentId === d.id ? (
                              <>
                                <Tooltip title="Speichern">
                                  <IconButton edge="end" color="primary" onClick={() => handleSaveDozentRolle(d.id)} disabled={loading}>
                                    <Save />
                                  </IconButton>
                                </Tooltip>
                                <Tooltip title="Abbrechen">
                                  <IconButton edge="end" onClick={handleCancelEditDozentRolle}>
                                    <Cancel />
                                  </IconButton>
                                </Tooltip>
                              </>
                            ) : (
                              <>
                                <Tooltip title="Rolle bearbeiten">
                                  <IconButton edge="end" onClick={() => handleStartEditDozentRolle(d)}>
                                    <Edit fontSize="small" />
                                  </IconButton>
                                </Tooltip>
                                <Tooltip title="Dozent ersetzen">
                                  <IconButton edge="end" color="info" onClick={() => handleOpenReplaceDozent(d)}>
                                    <SwapHoriz fontSize="small" />
                                  </IconButton>
                                </Tooltip>
                                <Tooltip title="Entfernen">
                                  <IconButton edge="end" color="error" onClick={() => handleDeleteDozent(d.id)}>
                                    <Delete fontSize="small" />
                                  </IconButton>
                                </Tooltip>
                              </>
                            )}
                          </ListItemSecondaryAction>
                        )}
                      </ListItem>
                    ))
                  ) : (
                    <Typography color="text.secondary">Keine Dozenten zugeordnet</Typography>
                  )}
                </List>

                {canEditModul(selectedModul) && (
                  <Card sx={{ mt: 3, bgcolor: 'grey.50' }}>
                    <CardContent>
                      <Typography variant="subtitle2" gutterBottom>Neuen Dozenten hinzufügen</Typography>
                      <Grid container spacing={2}>
                        <Grid item xs={7}>
                          <FormControl fullWidth size="small">
                            <InputLabel>Dozent</InputLabel>
                            <Select
                              value={newDozent.dozent_id}
                              onChange={(e) => setNewDozent({...newDozent, dozent_id: e.target.value})}
                            >
                              {dozentenOptions.map(d => (
                                <MenuItem key={d.id} value={d.id}>{d.name}</MenuItem>
                              ))}
                            </Select>
                          </FormControl>
                        </Grid>
                        <Grid item xs={3}>
                          <FormControl fullWidth size="small">
                            <InputLabel>Rolle</InputLabel>
                            <Select
                              value={newDozent.rolle}
                              onChange={(e) => setNewDozent({...newDozent, rolle: e.target.value})}
                            >
                              <MenuItem value="verantwortlicher">Modulverantwortlicher</MenuItem>
                              <MenuItem value="lehrperson">Lehrperson</MenuItem>
                              <MenuItem value="pruefend">Prüfend</MenuItem>
                              <MenuItem value="mitwirkend">Mitwirkend</MenuItem>
                              <MenuItem value="vertreter">Vertreter</MenuItem>
                            </Select>
                          </FormControl>
                        </Grid>
                        <Grid item xs={2}>
                          <Button
                            fullWidth
                            variant="contained"
                            size="small"
                            startIcon={<Add />}
                            onClick={handleAddDozent}
                            disabled={!newDozent.dozent_id || loading}
                          >
                            Hinzufügen
                          </Button>
                        </Grid>
                      </Grid>
                    </CardContent>
                  </Card>
                )}
              </TabPanel>

              {/* TAB 3: LITERATUR */}
              <TabPanel value={detailsTab} index={3} loaded={!!loadedTabs[3]}>
                <Typography variant="h6" gutterBottom>Literatur</Typography>
                <List>
                  {selectedModul.literatur && selectedModul.literatur.length > 0 ? (
                    selectedModul.literatur.map((lit: ModulLiteratur, idx: number) => (
                      <React.Fragment key={lit.id || idx}>
                        {idx > 0 && <Divider sx={{ my: 1 }} />}
                        <ListItem alignItems="flex-start">
                          <ListItemText
                            primary={
                              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                <Typography variant="subtitle1">{lit.titel}</Typography>
                                {lit.pflichtliteratur && (
                                  <Chip label="Pflicht" size="small" color="error" />
                                )}
                                {lit.typ && (
                                  <Chip label={lit.typ} size="small" variant="outlined" />
                                )}
                              </Box>
                            }
                            secondary={
                              <>
                                {lit.autoren && <Typography variant="body2">Autor(en): {lit.autoren}</Typography>}
                                <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', mt: 0.5 }}>
                                  {lit.verlag && <Typography variant="body2">Verlag: {lit.verlag}</Typography>}
                                  {lit.jahr && <Typography variant="body2">Jahr: {lit.jahr}</Typography>}
                                  {lit.isbn && <Typography variant="body2">ISBN: {lit.isbn}</Typography>}
                                </Box>
                              </>
                            }
                          />
                          {canEditModul(selectedModul) && (
                            <ListItemSecondaryAction>
                              <IconButton edge="end" color="error" onClick={() => handleDeleteLiteratur(lit.id)}>
                                <Delete />
                              </IconButton>
                            </ListItemSecondaryAction>
                          )}
                        </ListItem>
                      </React.Fragment>
                    ))
                  ) : (
                    <Typography color="text.secondary">Keine Literatur hinterlegt</Typography>
                  )}
                </List>

                {canEditModul(selectedModul) && (
                  <Card sx={{ mt: 3, bgcolor: 'grey.50' }}>
                    <CardContent>
                      <Typography variant="subtitle2" gutterBottom>Neue Literatur hinzufügen</Typography>
                      <Grid container spacing={2}>
                        <Grid item xs={12}>
                          <TextField
                            fullWidth
                            size="small"
                            label="Titel"
                            required
                            value={newLiteratur.titel}
                            onChange={(e) => setNewLiteratur({...newLiteratur, titel: e.target.value})}
                          />
                        </Grid>
                        <Grid item xs={6}>
                          <TextField
                            fullWidth
                            size="small"
                            label="Autoren"
                            value={newLiteratur.autoren}
                            onChange={(e) => setNewLiteratur({...newLiteratur, autoren: e.target.value})}
                          />
                        </Grid>
                        <Grid item xs={4}>
                          <TextField
                            fullWidth
                            size="small"
                            label="Verlag"
                            value={newLiteratur.verlag}
                            onChange={(e) => setNewLiteratur({...newLiteratur, verlag: e.target.value})}
                          />
                        </Grid>
                        <Grid item xs={2}>
                          <TextField
                            fullWidth
                            size="small"
                            label="Jahr"
                            type="number"
                            value={newLiteratur.jahr}
                            onChange={(e) => setNewLiteratur({...newLiteratur, jahr: e.target.value})}
                          />
                        </Grid>
                        <Grid item xs={6}>
                          <TextField
                            fullWidth
                            size="small"
                            label="ISBN"
                            value={newLiteratur.isbn}
                            onChange={(e) => setNewLiteratur({...newLiteratur, isbn: e.target.value})}
                          />
                        </Grid>
                        <Grid item xs={3}>
                          <FormControl fullWidth size="small">
                            <InputLabel>Typ</InputLabel>
                            <Select
                              value={newLiteratur.typ}
                              onChange={(e) => setNewLiteratur({...newLiteratur, typ: e.target.value})}
                            >
                              <MenuItem value="buch">Buch</MenuItem>
                              <MenuItem value="artikel">Artikel</MenuItem>
                              <MenuItem value="online">Online</MenuItem>
                              <MenuItem value="zeitschrift">Zeitschrift</MenuItem>
                            </Select>
                          </FormControl>
                        </Grid>
                        <Grid item xs={2}>
                          <FormControlLabel
                            control={
                              <Switch
                                checked={newLiteratur.pflichtliteratur}
                                onChange={(e) => setNewLiteratur({...newLiteratur, pflichtliteratur: e.target.checked})}
                              />
                            }
                            label="Pflicht"
                          />
                        </Grid>
                        <Grid item xs={1}>
                          <Button
                            fullWidth
                            variant="contained"
                            size="small"
                            startIcon={<Add />}
                            onClick={handleAddLiteratur}
                            disabled={!newLiteratur.titel || loading}
                          >
                            +
                          </Button>
                        </Grid>
                      </Grid>
                    </CardContent>
                  </Card>
                )}
              </TabPanel>

             {/* TAB 4: PRÜFUNG */}
              <TabPanel value={detailsTab} index={4} loaded={!!loadedTabs[4]}>
                {editMode !== 'pruefung' ? (
                  <Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                      <Typography variant="h6">Prüfung</Typography>
                      {canEditModul(selectedModul) && (
                        <Button startIcon={<Edit />} onClick={handleEditPruefung} variant="outlined" size="small">
                          Bearbeiten
                        </Button>
                      )}
                    </Box>
                    <Grid container spacing={2}>
                      <Grid item xs={12} md={6}>
                        <Typography variant="subtitle2" color="text.secondary">Prüfungsform</Typography>
                        <Typography>{selectedModul.pruefung?.pruefungsform || '-'}</Typography>
                      </Grid>
                      <Grid item xs={12} md={6}>
                        <Typography variant="subtitle2" color="text.secondary">Prüfungsdauer</Typography>
                        <Typography>
                          {selectedModul.pruefung?.pruefungsdauer_minuten 
                            ? `${selectedModul.pruefung.pruefungsdauer_minuten} Minuten` 
                            : '-'}
                        </Typography>
                      </Grid>
                      <Grid item xs={12} md={6}>
                        <Typography variant="subtitle2" color="text.secondary">Benotung</Typography>
                        <Typography>{selectedModul.pruefung?.benotung || '-'}</Typography>
                      </Grid>
                      {selectedModul.pruefung?.pruefungsleistungen && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="text.secondary">Details</Typography>
                          <Paper sx={{ p: 2, bgcolor: 'background.default' }}>
                            <Typography variant="body2" style={{ whiteSpace: 'pre-wrap' }}>
                              {selectedModul.pruefung.pruefungsleistungen}
                            </Typography>
                          </Paper>
                        </Grid>
                      )}
                    </Grid>
                  </Box>
                ) : (
                  <Box>
                    <Typography variant="h6" gutterBottom>Prüfung bearbeiten</Typography>
                    <Grid container spacing={2}>
                      <Grid item xs={8}>
                        <TextField fullWidth label="Prüfungsform"
                          value={editFormData.pruefungsform || ''}
                          onChange={(e) => setEditFormData({...editFormData, pruefungsform: e.target.value})} />
                      </Grid>
                      <Grid item xs={4}>
                        <TextField fullWidth label="Dauer (Minuten)" type="number"
                          value={editFormData.pruefungsdauer_minuten || ''}
                          onChange={(e) => setEditFormData({...editFormData, pruefungsdauer_minuten: parseInt(e.target.value)})} />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth label="Benotung"
                          value={editFormData.benotung || ''}
                          onChange={(e) => setEditFormData({...editFormData, benotung: e.target.value})} />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={4} label="Prüfungsleistungen"
                          value={editFormData.pruefungsleistungen || ''}
                          onChange={(e) => setEditFormData({...editFormData, pruefungsleistungen: e.target.value})} />
                      </Grid>
                    </Grid>
                    <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                      <Button variant="contained" startIcon={<Save />} onClick={handleSavePruefung} disabled={loading}>
                        Speichern
                      </Button>
                      <Button variant="outlined" startIcon={<Cancel />} onClick={() => setEditMode(null)}>
                        Abbrechen
                      </Button>
                    </Stack>
                  </Box>
                )}
              </TabPanel>

              {/* TAB 5: LERNERGEBNISSE */}
              <TabPanel value={detailsTab} index={5} loaded={!!loadedTabs[5]}>
                {editMode !== 'lernergebnisse' ? (
                  <Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                      <Typography variant="h6">Lernergebnisse</Typography>
                      {canEditModul(selectedModul) && (
                        <Button startIcon={<Edit />} onClick={handleEditLernergebnisse} variant="outlined" size="small">
                          Bearbeiten
                        </Button>
                      )}
                    </Box>
                    <Grid container spacing={3}>
                      {selectedModul.lernergebnisse?.lernziele && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="primary" gutterBottom>Lernziele</Typography>
                          <Paper sx={{ p: 2, bgcolor: 'background.default' }}>
                            <Typography variant="body2" style={{ whiteSpace: 'pre-wrap' }}>
                              {selectedModul.lernergebnisse.lernziele}
                            </Typography>
                          </Paper>
                        </Grid>
                      )}
                      {selectedModul.lernergebnisse?.kompetenzen && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="primary" gutterBottom>Kompetenzen</Typography>
                          <Paper sx={{ p: 2, bgcolor: 'background.default' }}>
                            <Typography variant="body2" style={{ whiteSpace: 'pre-wrap' }}>
                              {selectedModul.lernergebnisse.kompetenzen}
                            </Typography>
                          </Paper>
                        </Grid>
                      )}
                      {selectedModul.lernergebnisse?.inhalt && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="primary" gutterBottom>Inhalt</Typography>
                          <Paper sx={{ p: 2, bgcolor: 'background.default' }}>
                            <Typography variant="body2" style={{ whiteSpace: 'pre-wrap' }}>
                              {selectedModul.lernergebnisse.inhalt}
                            </Typography>
                          </Paper>
                        </Grid>
                      )}
                      {!selectedModul.lernergebnisse?.lernziele && 
                       !selectedModul.lernergebnisse?.kompetenzen && 
                       !selectedModul.lernergebnisse?.inhalt && (
                        <Grid item xs={12}>
                          <Typography color="text.secondary">Keine Lernergebnisse hinterlegt</Typography>
                        </Grid>
                      )}
                    </Grid>
                  </Box>
                ) : (
                  <Box>
                    <Typography variant="h6" gutterBottom>Lernergebnisse bearbeiten</Typography>
                    <Grid container spacing={2}>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={4} label="Lernziele"
                          value={editFormData.lernziele || ''}
                          onChange={(e) => setEditFormData({...editFormData, lernziele: e.target.value})}
                          helperText="Was sollen die Studierenden lernen?" />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={4} label="Kompetenzen"
                          value={editFormData.kompetenzen || ''}
                          onChange={(e) => setEditFormData({...editFormData, kompetenzen: e.target.value})}
                          helperText="Welche Kompetenzen werden erworben?" />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={6} label="Inhalt"
                          value={editFormData.inhalt || ''}
                          onChange={(e) => setEditFormData({...editFormData, inhalt: e.target.value})}
                          helperText="Was sind die Inhalte des Moduls?" />
                      </Grid>
                    </Grid>
                    <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                      <Button variant="contained" startIcon={<Save />} onClick={handleSaveLernergebnisse} disabled={loading}>
                        Speichern
                      </Button>
                      <Button variant="outlined" startIcon={<Cancel />} onClick={() => setEditMode(null)}>
                        Abbrechen
                      </Button>
                    </Stack>
                  </Box>
                )}
              </TabPanel>

              {/* TAB 6: VORAUSSETZUNGEN */}
              <TabPanel value={detailsTab} index={6} loaded={!!loadedTabs[6]}>
                {editMode !== 'voraussetzungen' ? (
                  <Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                      <Typography variant="h6">Voraussetzungen</Typography>
                      {canEditModul(selectedModul) && (
                        <Button startIcon={<Edit />} onClick={handleEditVoraussetzungen} variant="outlined" size="small">
                          Bearbeiten
                        </Button>
                      )}
                    </Box>
                    <Grid container spacing={3}>
                      {selectedModul.voraussetzungen?.formal && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="primary" gutterBottom>Formale Voraussetzungen</Typography>
                          <Paper sx={{ p: 2, bgcolor: 'background.default' }}>
                            <Typography variant="body2" style={{ whiteSpace: 'pre-wrap' }}>
                              {selectedModul.voraussetzungen.formal}
                            </Typography>
                          </Paper>
                        </Grid>
                      )}
                      {selectedModul.voraussetzungen?.empfohlen && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="primary" gutterBottom>Empfohlene Voraussetzungen</Typography>
                          <Paper sx={{ p: 2, bgcolor: 'background.default' }}>
                            <Typography variant="body2" style={{ whiteSpace: 'pre-wrap' }}>
                              {selectedModul.voraussetzungen.empfohlen}
                            </Typography>
                          </Paper>
                        </Grid>
                      )}
                      {selectedModul.voraussetzungen?.inhaltlich && (
                        <Grid item xs={12}>
                          <Typography variant="subtitle2" color="primary" gutterBottom>Inhaltliche Voraussetzungen</Typography>
                          <Paper sx={{ p: 2, bgcolor: 'background.default' }}>
                            <Typography variant="body2" style={{ whiteSpace: 'pre-wrap' }}>
                              {selectedModul.voraussetzungen.inhaltlich}
                            </Typography>
                          </Paper>
                        </Grid>
                      )}
                      {!selectedModul.voraussetzungen?.formal && 
                       !selectedModul.voraussetzungen?.empfohlen && 
                       !selectedModul.voraussetzungen?.inhaltlich && (
                        <Grid item xs={12}>
                          <Typography color="text.secondary">Keine Voraussetzungen hinterlegt</Typography>
                        </Grid>
                      )}
                    </Grid>
                  </Box>
                ) : (
                  <Box>
                    <Typography variant="h6" gutterBottom>Voraussetzungen bearbeiten</Typography>
                    <Grid container spacing={2}>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={3} label="Formale Voraussetzungen"
                          value={editFormData.formal || ''}
                          onChange={(e) => setEditFormData({...editFormData, formal: e.target.value})}
                          helperText="Formale Anforderungen (z.B. bestandene Klausuren)" />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={3} label="Empfohlene Voraussetzungen"
                          value={editFormData.empfohlen || ''}
                          onChange={(e) => setEditFormData({...editFormData, empfohlen: e.target.value})}
                          helperText="Empfohlene Vorkenntnisse" />
                      </Grid>
                      <Grid item xs={12}>
                        <TextField fullWidth multiline rows={3} label="Inhaltliche Voraussetzungen"
                          value={editFormData.inhaltlich || ''}
                          onChange={(e) => setEditFormData({...editFormData, inhaltlich: e.target.value})}
                          helperText="Inhaltliche Anforderungen" />
                      </Grid>
                    </Grid>
                    <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                      <Button variant="contained" startIcon={<Save />} onClick={handleSaveVoraussetzungen} disabled={loading}>
                        Speichern
                      </Button>
                      <Button variant="outlined" startIcon={<Cancel />} onClick={() => setEditMode(null)}>
                        Abbrechen
                      </Button>
                    </Stack>
                  </Box>
                )}
              </TabPanel>

              {/* TAB 7: ARBEITSAUFWAND */}
              <TabPanel value={detailsTab} index={7} loaded={!!loadedTabs[7]}>
                {editMode !== 'arbeitsaufwand' ? (
                  <Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
                      <Typography variant="h6">Arbeitsaufwand</Typography>
                      {canEditModul(selectedModul) && (
                        <Button startIcon={<Edit />} onClick={handleEditArbeitsaufwand} variant="outlined" size="small">
                          Bearbeiten
                        </Button>
                      )}
                    </Box>
                    <Grid container spacing={3}>
                      <Grid item xs={12} md={3}>
                        <Typography variant="subtitle2" color="text.secondary">Kontaktzeit</Typography>
                        <Typography variant="h5" color="primary">
                          {selectedModul.arbeitsaufwand?.[0]?.kontaktzeit_stunden || 0} Std.
                        </Typography>
                      </Grid>
                      <Grid item xs={12} md={3}>
                        <Typography variant="subtitle2" color="text.secondary">Selbststudium</Typography>
                        <Typography variant="h5" color="primary">
                          {selectedModul.arbeitsaufwand?.[0]?.selbststudium_stunden || 0} Std.
                        </Typography>
                      </Grid>
                      <Grid item xs={12} md={3}>
                        <Typography variant="subtitle2" color="text.secondary">Prüfungsvorbereitung</Typography>
                        <Typography variant="h5" color="primary">
                          {selectedModul.arbeitsaufwand?.[0]?.pruefungsvorbereitung_stunden || 0} Std.
                        </Typography>
                      </Grid>
                      <Grid item xs={12} md={3}>
                        <Typography variant="subtitle2" color="text.secondary">Gesamt</Typography>
                        <Typography variant="h5" color="success.main">
                          {selectedModul.arbeitsaufwand?.[0]?.gesamt_stunden || 0} Std.
                        </Typography>
                      </Grid>
                    </Grid>
                  </Box>
                ) : (
                  <Box>
                    <Typography variant="h6" gutterBottom>Arbeitsaufwand bearbeiten</Typography>
                    <Grid container spacing={2}>
                      <Grid item xs={6}>
                        <TextField fullWidth label="Kontaktzeit (Std)" type="number"
                          value={editFormData.kontaktzeit_stunden || ''}
                          onChange={(e) => setEditFormData({...editFormData, kontaktzeit_stunden: parseInt(e.target.value)})}
                          helperText="Präsenzzeit in Stunden" />
                      </Grid>
                      <Grid item xs={6}>
                        <TextField fullWidth label="Selbststudium (Std)" type="number"
                          value={editFormData.selbststudium_stunden || ''}
                          onChange={(e) => setEditFormData({...editFormData, selbststudium_stunden: parseInt(e.target.value)})}
                          helperText="Selbstlernzeit in Stunden" />
                      </Grid>
                      <Grid item xs={6}>
                        <TextField fullWidth label="Prüfungsvorbereitung (Std)" type="number"
                          value={editFormData.pruefungsvorbereitung_stunden || ''}
                          onChange={(e) => setEditFormData({...editFormData, pruefungsvorbereitung_stunden: parseInt(e.target.value)})}
                          helperText="Zeit für Prüfungsvorbereitung" />
                      </Grid>
                      <Grid item xs={6}>
                        <TextField fullWidth label="Gesamt (Std)" type="number"
                          value={editFormData.gesamt_stunden || ''}
                          onChange={(e) => setEditFormData({...editFormData, gesamt_stunden: parseInt(e.target.value)})}
                          helperText="Gesamtaufwand" />
                      </Grid>
                    </Grid>
                    <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                      <Button variant="contained" startIcon={<Save />} onClick={handleSaveArbeitsaufwand} disabled={loading}>
                        Speichern
                      </Button>
                      <Button variant="outlined" startIcon={<Cancel />} onClick={() => setEditMode(null)}>
                        Abbrechen
                      </Button>
                    </Stack>
                  </Box>
                )}
              </TabPanel>
            </DialogContent>
            
            <DialogActions>
              <Button onClick={() => {
                setDetailsDialog(false);
                setEditMode(null);
              }}>
                Schließen
              </Button>
            </DialogActions>
          </>
        )}
      </Dialog>


      {/* ========== CREATE DIALOG ========== */}
      <Dialog open={createDialog} onClose={() => setCreateDialog(false)} maxWidth="md" fullWidth>
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Add color="primary" />
            <Typography variant="h6">Neues Modul erstellen</Typography>
          </Box>
        </DialogTitle>
        <DialogContent dividers>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <TextField label="Kürzel" fullWidth required
                value={createFormData.kuerzel}
                onChange={(e) => setCreateFormData({ ...createFormData, kuerzel: e.target.value.toUpperCase() })} />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField label="PO ID" type="number" fullWidth required
                value={createFormData.po_id}
                onChange={(e) => setCreateFormData({ ...createFormData, po_id: parseInt(e.target.value) })} />
            </Grid>
            <Grid item xs={12}>
              <TextField label="Bezeichnung (Deutsch)" fullWidth required
                value={createFormData.bezeichnung_de}
                onChange={(e) => setCreateFormData({ ...createFormData, bezeichnung_de: e.target.value })} />
            </Grid>
            <Grid item xs={12}>
              <TextField label="Bezeichnung (Englisch)" fullWidth
                value={createFormData.bezeichnung_en}
                onChange={(e) => setCreateFormData({ ...createFormData, bezeichnung_en: e.target.value })} />
            </Grid>
            <Grid item xs={12}>
              <TextField label="Untertitel" fullWidth
                value={createFormData.untertitel}
                onChange={(e) => setCreateFormData({ ...createFormData, untertitel: e.target.value })} />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField label="Leistungspunkte" type="number" fullWidth
                value={createFormData.leistungspunkte}
                onChange={(e) => setCreateFormData({ ...createFormData, leistungspunkte: parseInt(e.target.value) })} />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField label="Turnus" select fullWidth
                value={createFormData.turnus}
                onChange={(e) => setCreateFormData({ ...createFormData, turnus: e.target.value })}>
                <MenuItem value="WiSe">Wintersemester</MenuItem>
                <MenuItem value="SoSe">Sommersemester</MenuItem>
                <MenuItem value="WiSe/SoSe">Jedes Semester</MenuItem>
              </TextField>
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
      <Dialog open={deleteDialog} onClose={() => setDeleteDialog(false)} maxWidth="sm">
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Warning color="error" />
            <Typography variant="h6">Modul löschen</Typography>
          </Box>
        </DialogTitle>
        <DialogContent>
          <Typography gutterBottom>
            Möchten Sie das Modul <strong>{selectedModul?.kuerzel}</strong> wirklich löschen?
          </Typography>
          <FormControlLabel
            control={
              <Switch
                checked={deleteForce}
                onChange={(e) => setDeleteForce(e.target.checked)}
              />
            }
            label="Erzwingen (auch bei Verwendung in Planungen)"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialog(false)}>Abbrechen</Button>
          <Button variant="contained" color="error" onClick={handleDelete} disabled={loading}>
            Löschen
          </Button>
        </DialogActions>
      </Dialog>

      {/* ========== REPLACE DOZENT DIALOG ========== */}
      <Dialog open={replaceDozentDialog} onClose={() => setReplaceDozentDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <SwapHoriz color="primary" />
            <Typography variant="h6">Dozent ersetzen</Typography>
          </Box>
        </DialogTitle>
        <DialogContent dividers>
          {replaceDozentData && (
            <Grid container spacing={2}>
              <Grid item xs={12}>
                <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                  <Typography variant="subtitle2" color="text.secondary">Aktueller Dozent</Typography>
                  <Typography variant="body1" fontWeight="bold">
                    {replaceDozentData.name}
                  </Typography>
                  <Chip label={replaceDozentData.rolle} size="small" sx={{ mt: 1 }} />
                </Box>
              </Grid>
              <Grid item xs={12}>
                <FormControl fullWidth>
                  <InputLabel>Neuer Dozent</InputLabel>
                  <Select
                    value={replaceDozentNew}
                    label="Neuer Dozent"
                    onChange={(e) => setReplaceDozentNew(e.target.value)}
                  >
                    {dozentenOptions
                      .filter(d => d.id !== replaceDozentData.id)
                      .map(d => (
                        <MenuItem key={d.id} value={d.id}>{d.name}</MenuItem>
                      ))
                    }
                  </Select>
                </FormControl>
              </Grid>
              <Grid item xs={12}>
                <Alert severity="info">
                  Die Rolle <strong>{replaceDozentData.rolle}</strong> wird auf den neuen Dozenten übertragen.
                </Alert>
              </Grid>
            </Grid>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setReplaceDozentDialog(false)} disabled={loading}>
            Abbrechen
          </Button>
          <Button
            variant="contained"
            onClick={handleReplaceDozent}
            disabled={loading || !replaceDozentNew}
            startIcon={loading ? <CircularProgress size={16} /> : <SwapHoriz />}
          >
            {loading ? 'Wird ersetzt...' : 'Ersetzen'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* ========== BULK TRANSFER DIALOG (DEKAN ONLY) ========== */}
      <BulkTransferDialog
        open={bulkTransferDialog}
        onClose={() => setBulkTransferDialog(false)}
        onSuccess={() => {
          setSuccess('Bulk Transfer erfolgreich durchgeführt');
          loadModule();
        }}
        module={module.map(m => ({
          id: m.id,
          kuerzel: m.kuerzel,
          bezeichnung_de: m.bezeichnung_de,
          dozenten: m.dozenten?.map((d: ModulDozent) => ({
            zuordnung_id: d.id,
            id: d.dozent_id,
            name: d.name_komplett || d.name_kurz || `${d.vorname || ''} ${d.nachname || ''}`.trim(),
            rolle: d.rolle
          })) || []
        }))}
      />

      {/* ========== COMPREHENSIVE EDIT DIALOG ========== */}
      <ComprehensiveEditDialog
        open={comprehensiveEditDialog}
        modul={selectedModul}
        onClose={() => {
          setComprehensiveEditDialog(false);
        }}
        onSaveSuccess={async () => {
          // Refresh module list and details after successful save
          await loadModule();
          if (selectedModul?.id) {
            await handleViewDetails(selectedModul.id);
          }
          setSuccess('Änderungen wurden gespeichert');
        }}
        onSaveBasics={async (data) => {
          if (!selectedModul?.id) throw new Error('Kein Modul ausgewählt');
          const response = await modulService.updateModule(selectedModul.id, data);
          if (!response.success) throw new Error(response.message);
          return response;
        }}
        onSavePruefung={async (data) => {
          if (!selectedModul?.id) throw new Error('Kein Modul ausgewählt');
          const response = await modulService.updatePruefung(selectedModul.id, data);
          if (!response.success) throw new Error(response.message);
          return response;
        }}
        onSaveLernergebnisse={async (data) => {
          if (!selectedModul?.id) throw new Error('Kein Modul ausgewählt');
          const response = await modulService.updateLernergebnisse(selectedModul.id, data);
          if (!response.success) throw new Error(response.message);
          return response;
        }}
        onSaveVoraussetzungen={async (data) => {
          if (!selectedModul?.id) throw new Error('Kein Modul ausgewählt');
          const response = await modulService.updateVoraussetzungen(selectedModul.id, data);
          if (!response.success) throw new Error(response.message);
          return response;
        }}
        onSaveArbeitsaufwand={async (data) => {
          if (!selectedModul?.id) throw new Error('Kein Modul ausgewählt');
          const response = await modulService.updateArbeitsaufwand(selectedModul.id, data);
          if (!response.success) throw new Error(response.message);
          return response;
        }}
        onAddLiteratur={async (data) => {
          if (!selectedModul?.id) throw new Error('Kein Modul ausgewählt');
          const response = await modulService.addLiteratur(selectedModul.id, data);
          if (!response.success) throw new Error(response.message);
          // Refresh the module details
          const refreshed = await modulService.getModulDetails(selectedModul.id);
          if (refreshed.success && refreshed.data) {
            setSelectedModul(refreshed.data);
          }
          return response;
        }}
        onDeleteLiteratur={async (id) => {
          if (!selectedModul?.id) throw new Error('Kein Modul ausgewählt');
          const response = await modulService.deleteLiteratur(selectedModul.id, id);
          if (!response.success) throw new Error(response.message);
          // Refresh the module details
          const refreshed = await modulService.getModulDetails(selectedModul.id);
          if (refreshed.success && refreshed.data) {
            setSelectedModul(refreshed.data);
          }
          return response;
        }}
        lehrformOptions={lehrformenOptions}
        dozentOptions={dozentenOptions}
      />
    </Container>
  );
};

export default ModulePage;