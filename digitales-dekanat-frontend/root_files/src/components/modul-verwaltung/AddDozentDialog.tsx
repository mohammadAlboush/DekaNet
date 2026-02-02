import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Grid,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Typography,
  CircularProgress,
  Alert,
  Autocomplete,
  Box
} from '@mui/material';
import { Add, Close } from '@mui/icons-material';
import modulVerwaltungService from '../../services/modulVerwaltungService';
import dozentService, { Dozent } from '../../services/dozentService';
import poService, { Pruefungsordnung } from '../../services/poService';
import { createContextLogger } from '../../utils/logger';
import { getErrorMessage } from '../../utils/errorUtils';

const log = createContextLogger('AddDozentDialog');

interface AddDozentDialogProps {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
  modul: {
    id: number;
    kuerzel: string;
    bezeichnung_de: string;
  };
}

const AddDozentDialog: React.FC<AddDozentDialogProps> = ({
  open,
  onClose,
  onSuccess,
  modul
}) => {
  const [loading, setLoading] = useState(false);
  const [loadingDozenten, setLoadingDozenten] = useState(false);
  const [loadingPOs, setLoadingPOs] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [dozenten, setDozenten] = useState<Dozent[]>([]);
  const [pruefungsordnungen, setPruefungsordnungen] = useState<Pruefungsordnung[]>([]);

  // Form Data
  const [selectedDozent, setSelectedDozent] = useState<Dozent | null>(null);
  const [poId, setPoId] = useState<number | null>(null);
  const [rolle, setRolle] = useState<string>('mitwirkend');
  const [bemerkung, setBemerkung] = useState<string>('');

  // Load Dozenten and POs
  useEffect(() => {
    if (open) {
      loadDozenten();
      loadPruefungsordnungen();
    }
  }, [open]);

  const loadDozenten = async () => {
    setLoadingDozenten(true);
    try {
      const response = await dozentService.getAllDozenten({ aktiv: true });
      if (response.success) {
        setDozenten(response.data || []);
      }
    } catch (error: unknown) {
      log.error('Error loading dozenten:', { error });
    } finally {
      setLoadingDozenten(false);
    }
  };

  const loadPruefungsordnungen = async () => {
    setLoadingPOs(true);
    try {
      const response = await poService.getAll();
      if (response.success && response.data) {
        setPruefungsordnungen(response.data);
        // Set default PO if available
        if (response.data.length > 0 && !poId) {
          setPoId(response.data[0].id);
        }
      }
    } catch (error: unknown) {
      log.error('Error loading Prüfungsordnungen:', { error });
    } finally {
      setLoadingPOs(false);
    }
  };

  // Reset form
  const resetForm = () => {
    setSelectedDozent(null);
    setPoId(pruefungsordnungen.length > 0 ? pruefungsordnungen[0].id : null);
    setRolle('mitwirkend');
    setBemerkung('');
    setError(null);
  };

  // Handle Close
  const handleClose = () => {
    resetForm();
    onClose();
  };

  // Handle Submit
  const handleSubmit = async () => {
    if (!selectedDozent || !poId) {
      setError('Bitte wählen Sie einen Dozenten und eine Prüfungsordnung aus');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await modulVerwaltungService.addDozentToModul(modul.id, {
        po_id: poId,
        dozent_id: selectedDozent.id,
        rolle: rolle,
        bemerkung: bemerkung || undefined
      });

      if (response.success) {
        onSuccess();
        handleClose();
      } else {
        setError(response.message || 'Fehler beim Hinzufügen des Dozenten');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error, 'Ein Fehler ist aufgetreten'));
    } finally {
      setLoading(false);
    }
  };

  // Validation
  const isValid = selectedDozent !== null && poId !== null;

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
      <DialogTitle>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box display="flex" alignItems="center" gap={1}>
            <Add />
            <Typography variant="h6">Dozent zu Modul hinzufügen</Typography>
          </Box>
          <Button onClick={handleClose} size="small">
            <Close />
          </Button>
        </Box>
      </DialogTitle>

      <DialogContent dividers>
        {error && (
          <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
            {error}
          </Alert>
        )}

        <Grid container spacing={3}>
          {/* Modul Info (readonly) */}
          <Grid item xs={12}>
            <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                Modul
              </Typography>
              <Typography variant="h6">
                {modul.kuerzel} - {modul.bezeichnung_de}
              </Typography>
            </Box>
          </Grid>

          {/* Dozent Select */}
          <Grid item xs={12}>
            <Autocomplete
              options={dozenten}
              getOptionLabel={(option) => option.name_komplett}
              value={selectedDozent}
              onChange={(_, newValue) => setSelectedDozent(newValue)}
              loading={loadingDozenten}
              renderInput={(params) => (
                <TextField
                  {...params}
                  label="Dozent *"
                  placeholder="Dozent auswählen..."
                  InputProps={{
                    ...params.InputProps,
                    endAdornment: (
                      <>
                        {loadingDozenten ? <CircularProgress color="inherit" size={20} /> : null}
                        {params.InputProps.endAdornment}
                      </>
                    ),
                  }}
                />
              )}
              renderOption={(props, option) => (
                <li {...props}>
                  <Box>
                    <Typography variant="body2">{option.name_komplett}</Typography>
                    {option.email && (
                      <Typography variant="caption" color="text.secondary">
                        {option.email}
                      </Typography>
                    )}
                  </Box>
                </li>
              )}
            />
          </Grid>

          {/* Prüfungsordnung */}
          <Grid item xs={12} md={6}>
            <FormControl fullWidth required disabled={loading || loadingPOs}>
              <InputLabel>Prüfungsordnung</InputLabel>
              <Select
                value={poId || ''}
                label="Prüfungsordnung"
                onChange={(e) => setPoId(e.target.value as number)}
              >
                {loadingPOs ? (
                  <MenuItem disabled>Lädt...</MenuItem>
                ) : pruefungsordnungen.length === 0 ? (
                  <MenuItem disabled>Keine POs verfügbar</MenuItem>
                ) : (
                  pruefungsordnungen.map((po) => (
                    <MenuItem key={po.id} value={po.id}>
                      {po.po_jahr}
                      {po.gueltig_bis && ` (gültig bis ${new Date(po.gueltig_bis).toLocaleDateString('de-DE')})`}
                    </MenuItem>
                  ))
                )}
              </Select>
            </FormControl>
          </Grid>

          {/* Rolle */}
          <Grid item xs={12} md={6}>
            <FormControl fullWidth required>
              <InputLabel>Rolle</InputLabel>
              <Select
                value={rolle}
                label="Rolle"
                onChange={(e) => setRolle(e.target.value)}
              >
                <MenuItem value="verantwortlich">Verantwortlich</MenuItem>
                <MenuItem value="mitwirkend">Mitwirkend</MenuItem>
                <MenuItem value="vertreter">Vertreter</MenuItem>
                <MenuItem value="pruefend">Prüfend</MenuItem>
              </Select>
            </FormControl>
          </Grid>

          {/* Bemerkung */}
          <Grid item xs={12}>
            <TextField
              fullWidth
              multiline
              rows={3}
              label="Bemerkung (optional)"
              placeholder="z.B. 'Übernimmt Übungen ab WS25/26'"
              value={bemerkung}
              onChange={(e) => setBemerkung(e.target.value)}
            />
          </Grid>
        </Grid>
      </DialogContent>

      <DialogActions>
        <Button onClick={handleClose} disabled={loading}>
          Abbrechen
        </Button>
        <Button
          variant="contained"
          onClick={handleSubmit}
          disabled={loading || !isValid}
          startIcon={loading ? <CircularProgress size={20} /> : <Add />}
        >
          {loading ? 'Wird hinzugefügt...' : 'Hinzufügen'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default AddDozentDialog;
