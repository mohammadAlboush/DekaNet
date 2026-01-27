import React, { useState, useEffect } from 'react';
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
  Button,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Chip,
  Alert,
  CircularProgress,
  Switch,
  FormControlLabel,
  Tooltip,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  Save,
  Cancel,
  ArrowBack,
  Work,
  DragIndicator,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import auftragService from '../services/auftragService';
import { Auftrag, CreateAuftragData } from '../types/auftrag.types';
import { useToastStore } from '../components/common/Toast';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('AuftraegeVerwaltung');

/**
 * Aufträge-Verwaltung - MASTER-LISTE
 * ===================================
 * Dekan verwaltet die Liste der verfügbaren Semesteraufträge
 *
 * Features:
 * - Liste aller Aufträge mit SWS
 * - Hinzufügen neuer Aufträge
 * - Bearbeiten existierender Aufträge
 * - Aktivieren/Deaktivieren von Aufträgen
 * - Sortierung ändern
 *
 * Beispiel-Aufträge:
 * - Dekanin (5.0 SWS)
 * - Prodekan (4.5 SWS)
 * - Studiengangsbeauftragter Informatik (0.5 SWS)
 * - etc.
 */

interface AuftraegeVerwaltungProps {
  embedded?: boolean;
}

const AuftraegeVerwaltung: React.FC<AuftraegeVerwaltungProps> = ({ embedded = false }) => {
  const navigate = useNavigate();
  const showToast = useToastStore((state) => state.showToast);

  const [loading, setLoading] = useState(true);
  const [auftraege, setAuftraege] = useState<Auftrag[]>([]);
  const [showDialog, setShowDialog] = useState(false);
  const [editMode, setEditMode] = useState(false);
  const [selectedAuftrag, setSelectedAuftrag] = useState<Auftrag | null>(null);

  // Form state
  const [formData, setFormData] = useState<CreateAuftragData>({
    name: '',
    standard_sws: 0,
    beschreibung: '',
    sortierung: 0,
  });

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const data = await auftragService.getAlleAuftraege(false); // Alle, auch inaktive
      setAuftraege(data);
      log.debug(' Loaded:', data.length, 'aufträge');
    } catch (error) {
      log.error(' Error loading:', error);
      showToast('Fehler beim Laden der Aufträge', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleOpenDialog = (auftrag?: Auftrag) => {
    if (auftrag) {
      // Edit mode
      setEditMode(true);
      setSelectedAuftrag(auftrag);
      setFormData({
        name: auftrag.name,
        standard_sws: auftrag.standard_sws,
        beschreibung: auftrag.beschreibung || '',
        sortierung: auftrag.sortierung || 0,
      });
    } else {
      // Create mode
      setEditMode(false);
      setSelectedAuftrag(null);
      setFormData({
        name: '',
        standard_sws: 0,
        beschreibung: '',
        sortierung: auftraege.length + 1,
      });
    }
    setShowDialog(true);
  };

  const handleCloseDialog = () => {
    setShowDialog(false);
    setEditMode(false);
    setSelectedAuftrag(null);
    setFormData({
      name: '',
      standard_sws: 0,
      beschreibung: '',
      sortierung: 0,
    });
  };

  const handleSave = async () => {
    if (!formData.name.trim()) {
      showToast('Bitte geben Sie einen Namen ein', 'warning');
      return;
    }

    if (!formData.standard_sws || formData.standard_sws <= 0) {
      showToast('SWS muss größer als 0 sein', 'warning');
      return;
    }

    try {
      setLoading(true);

      if (editMode && selectedAuftrag) {
        // Update
        const updated = await auftragService.updateAuftrag(selectedAuftrag.id, formData);
        setAuftraege(auftraege.map(a => a.id === updated.id ? updated : a));
        showToast('Auftrag aktualisiert', 'success');
      } else {
        // Create
        const created = await auftragService.createAuftrag(formData);
        setAuftraege([...auftraege, created]);
        showToast('Auftrag erstellt', 'success');
      }

      handleCloseDialog();
    } catch (error: any) {
      log.error(' Error saving:', error);
      showToast(error.message || 'Fehler beim Speichern', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleToggleAktiv = async (auftrag: Auftrag) => {
    try {
      const updated = await auftragService.updateAuftrag(auftrag.id, {
        ist_aktiv: !auftrag.ist_aktiv,
      });
      setAuftraege(auftraege.map(a => a.id === updated.id ? updated : a));
      showToast(
        updated.ist_aktiv ? 'Auftrag aktiviert' : 'Auftrag deaktiviert',
        'success'
      );
    } catch (error: any) {
      log.error(' Error toggling:', error);
      showToast(error.message || 'Fehler beim Ändern', 'error');
    }
  };

  const handleDelete = async (auftrag: Auftrag) => {
    const confirmed = window.confirm(
      `Möchten Sie den Auftrag "${auftrag.name}" wirklich löschen?\n\n` +
      'ACHTUNG: Bereits beantragte Semesteraufträge bleiben erhalten, ' +
      'aber neue Beantragungen sind nicht mehr möglich.'
    );

    if (!confirmed) return;

    try {
      setLoading(true);
      await auftragService.deleteAuftrag(auftrag.id);
      setAuftraege(auftraege.filter(a => a.id !== auftrag.id));
      showToast('Auftrag gelöscht', 'success');
    } catch (error: any) {
      log.error(' Error deleting:', error);
      showToast(error.message || 'Fehler beim Löschen', 'error');
    } finally {
      setLoading(false);
    }
  };

  if (loading && auftraege.length === 0) {
    return (
      <Container maxWidth="lg">
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '50vh' }}>
          <CircularProgress />
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" disableGutters={embedded}>
      {/* Header - nur wenn nicht embedded */}
      {!embedded && (
        <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <IconButton onClick={() => navigate('/dashboard')}>
              <ArrowBack />
            </IconButton>
            <Box>
              <Typography variant="h4" fontWeight={600}>
                Semesteraufträge verwalten
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Master-Liste aller verfügbaren Aufträge
              </Typography>
            </Box>
          </Box>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={() => handleOpenDialog()}
            size="large"
          >
            Neuer Auftrag
          </Button>
        </Box>
      )}

      {/* Wenn embedded: Kompakter Header */}
      {embedded && (
        <Box sx={{ mb: 3, display: 'flex', justifyContent: 'flex-end' }}>
          <Button variant="contained" startIcon={<Add />} onClick={() => handleOpenDialog()}>
            Neuer Auftrag
          </Button>
        </Box>
      )}

      {/* Info */}
      <Alert severity="info" sx={{ mb: 3 }}>
        <Typography variant="subtitle2" gutterBottom>
          ℹ️ Was sind Semesteraufträge?
        </Typography>
        <Typography variant="body2">
          Semesteraufträge sind administrative Tätigkeiten, die Professoren übernehmen können
          (z.B. Dekanin, Prodekan, Studiengangsbeauftragter). Jeder Auftrag hat eine Standard-SWS-Zahl,
          die bei der Beantragung vom BAföG-Amt angerechnet wird.
        </Typography>
      </Alert>

      {/* Statistik */}
      <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <Chip
          label={`Gesamt: ${auftraege.length}`}
          color="primary"
          variant="outlined"
          icon={<Work />}
        />
        <Chip
          label={`Aktiv: ${auftraege.filter(a => a.ist_aktiv).length}`}
          color="success"
          variant="outlined"
        />
        <Chip
          label={`Inaktiv: ${auftraege.filter(a => !a.ist_aktiv).length}`}
          color="default"
          variant="outlined"
        />
      </Box>

      {/* Tabelle */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell width={40}></TableCell>
              <TableCell><strong>Name</strong></TableCell>
              <TableCell><strong>Beschreibung</strong></TableCell>
              <TableCell align="center"><strong>Standard SWS</strong></TableCell>
              <TableCell align="center"><strong>Sortierung</strong></TableCell>
              <TableCell align="center"><strong>Status</strong></TableCell>
              <TableCell align="center"><strong>Aktionen</strong></TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {auftraege.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center">
                  <Box sx={{ py: 4 }}>
                    <Work sx={{ fontSize: 64, color: 'text.disabled', mb: 2 }} />
                    <Typography variant="h6" color="text.secondary" gutterBottom>
                      Keine Aufträge vorhanden
                    </Typography>
                    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                      Erstellen Sie den ersten Auftrag
                    </Typography>
                    <Button
                      variant="contained"
                      startIcon={<Add />}
                      onClick={() => handleOpenDialog()}
                    >
                      Ersten Auftrag erstellen
                    </Button>
                  </Box>
                </TableCell>
              </TableRow>
            ) : (
              auftraege
                .sort((a, b) => (a.sortierung || 0) - (b.sortierung || 0))
                .map((auftrag) => (
                  <TableRow
                    key={auftrag.id}
                    sx={{
                      opacity: auftrag.ist_aktiv ? 1 : 0.5,
                      bgcolor: auftrag.ist_aktiv ? 'inherit' : 'action.hover',
                    }}
                  >
                    <TableCell>
                      <Tooltip title="Sortierung (Drag & Drop coming soon)">
                        <DragIndicator sx={{ color: 'text.disabled' }} />
                      </Tooltip>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight={500}>
                        {auftrag.name}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="caption" color="text.secondary">
                        {auftrag.beschreibung || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Chip
                        label={auftrag.standard_sws.toFixed(1)}
                        size="small"
                        color="primary"
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="center">
                      <Typography variant="body2" color="text.secondary">
                        {auftrag.sortierung || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <FormControlLabel
                        control={
                          <Switch
                            checked={auftrag.ist_aktiv}
                            onChange={() => handleToggleAktiv(auftrag)}
                            size="small"
                          />
                        }
                        label={auftrag.ist_aktiv ? 'Aktiv' : 'Inaktiv'}
                        labelPlacement="start"
                      />
                    </TableCell>
                    <TableCell align="center">
                      <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'center' }}>
                        <Tooltip title="Bearbeiten">
                          <IconButton
                            size="small"
                            color="primary"
                            onClick={() => handleOpenDialog(auftrag)}
                          >
                            <Edit />
                          </IconButton>
                        </Tooltip>
                        <Tooltip title="Löschen">
                          <IconButton
                            size="small"
                            color="error"
                            onClick={() => handleDelete(auftrag)}
                          >
                            <Delete />
                          </IconButton>
                        </Tooltip>
                      </Box>
                    </TableCell>
                  </TableRow>
                ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Dialog: Erstellen/Bearbeiten */}
      <Dialog
        open={showDialog}
        onClose={handleCloseDialog}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          {editMode ? 'Auftrag bearbeiten' : 'Neuer Auftrag'}
        </DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
            <TextField
              label="Name"
              placeholder="z.B. Dekanin, Prodekan, Studiengangsbeauftragter..."
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              fullWidth
              required
              autoFocus
            />

            <TextField
              label="Standard SWS"
              type="number"
              inputProps={{ min: 0, step: 0.5 }}
              value={formData.standard_sws}
              onChange={(e) => setFormData({ ...formData, standard_sws: parseFloat(e.target.value) || 0 })}
              fullWidth
              required
              helperText="SWS-Zahl, die standardmäßig bei der Beantragung verwendet wird"
            />

            <TextField
              label="Beschreibung"
              placeholder="Optionale Beschreibung..."
              value={formData.beschreibung}
              onChange={(e) => setFormData({ ...formData, beschreibung: e.target.value })}
              fullWidth
              multiline
              rows={3}
            />

            <TextField
              label="Sortierung"
              type="number"
              inputProps={{ min: 0 }}
              value={formData.sortierung}
              onChange={(e) => setFormData({ ...formData, sortierung: parseInt(e.target.value) || 0 })}
              fullWidth
              helperText="Niedrigere Zahlen erscheinen weiter oben in der Liste"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog} startIcon={<Cancel />}>
            Abbrechen
          </Button>
          <Button
            onClick={handleSave}
            variant="contained"
            startIcon={<Save />}
            disabled={!formData.name.trim() || !formData.standard_sws || formData.standard_sws <= 0}
          >
            {editMode ? 'Speichern' : 'Erstellen'}
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default AuftraegeVerwaltung;
