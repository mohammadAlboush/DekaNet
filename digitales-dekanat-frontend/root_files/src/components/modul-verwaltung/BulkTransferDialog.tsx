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
  Box,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Checkbox,
  Divider,
  Paper
} from '@mui/material';
import { SwapHoriz, Close, School } from '@mui/icons-material';
import modulVerwaltungService, { BulkTransferResult } from '../../services/modulVerwaltungService';
import dozentService, { Dozent } from '../../services/dozentService';
import poService, { Pruefungsordnung } from '../../services/poService';

interface BulkTransferDialogProps {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
  module: Array<{
    id: number;
    kuerzel: string;
    bezeichnung_de: string;
    dozenten: Array<{
      id: number;
      name: string;
      rolle: string;
    }>;
  }>;
}

const BulkTransferDialog: React.FC<BulkTransferDialogProps> = ({
  open,
  onClose,
  onSuccess,
  module
}) => {
  const [loading, setLoading] = useState(false);
  const [loadingDozenten, setLoadingDozenten] = useState(false);
  const [loadingPOs, setLoadingPOs] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [dozenten, setDozenten] = useState<Dozent[]>([]);
  const [pruefungsordnungen, setPruefungsordnungen] = useState<Pruefungsordnung[]>([]);
  const [result, setResult] = useState<BulkTransferResult | null>(null);

  // Form Data
  const [vonDozent, setVonDozent] = useState<Dozent | null>(null);
  const [zuDozent, setZuDozent] = useState<Dozent | null>(null);
  const [poId, setPoId] = useState<number | null>(null);
  const [rolle, setRolle] = useState<string>('verantwortlich');
  const [selectedModuleIds, setSelectedModuleIds] = useState<number[]>([]);
  const [bemerkung, setBemerkung] = useState<string>('');

  // Load Dozenten and POs
  useEffect(() => {
    if (open) {
      loadDozenten();
      loadPruefungsordnungen();
      setResult(null);
    }
  }, [open]);

  // Update selected modules when vonDozent changes
  useEffect(() => {
    if (vonDozent) {
      // Auto-select modules where vonDozent is assigned with the selected rolle
      const matchingModules = module
        .filter(m => m.dozenten.some(d => d.id === vonDozent.id && d.rolle === rolle))
        .map(m => m.id);
      setSelectedModuleIds(matchingModules);
    } else {
      setSelectedModuleIds([]);
    }
  }, [vonDozent, rolle, module]);

  const loadDozenten = async () => {
    setLoadingDozenten(true);
    try {
      const response = await dozentService.getAllDozenten({ aktiv: true });
      if (response.success) {
        setDozenten(response.data || []);
      }
    } catch (error: any) {
      console.error('Error loading dozenten:', error);
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
    } catch (error: any) {
      console.error('Error loading Prüfungsordnungen:', error);
    } finally {
      setLoadingPOs(false);
    }
  };

  // Reset form
  const resetForm = () => {
    setVonDozent(null);
    setZuDozent(null);
    setPoId(pruefungsordnungen.length > 0 ? pruefungsordnungen[0].id : null);
    setRolle('verantwortlich');
    setSelectedModuleIds([]);
    setBemerkung('');
    setError(null);
    setResult(null);
  };

  // Handle Close
  const handleClose = () => {
    resetForm();
    onClose();
  };

  // Handle Module Toggle
  const handleToggleModul = (modulId: number) => {
    setSelectedModuleIds(prev =>
      prev.includes(modulId)
        ? prev.filter(id => id !== modulId)
        : [...prev, modulId]
    );
  };

  // Handle Submit
  const handleSubmit = async () => {
    if (!vonDozent || !zuDozent || !poId || selectedModuleIds.length === 0) {
      setError('Bitte füllen Sie alle Pflichtfelder aus und wählen Sie mindestens ein Modul');
      return;
    }

    if (vonDozent.id === zuDozent.id) {
      setError('Von-Dozent und Zu-Dozent müssen unterschiedlich sein');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await modulVerwaltungService.bulkTransferModule({
        modul_ids: selectedModuleIds,
        von_dozent_id: vonDozent.id,
        zu_dozent_id: zuDozent.id,
        po_id: poId,
        rolle: rolle,
        bemerkung: bemerkung || undefined
      });

      if (response.success && response.data) {
        setResult(response.data);
        if (response.data.fehlgeschlagen_count === 0) {
          // Vollständiger Erfolg
          setTimeout(() => {
            onSuccess();
            handleClose();
          }, 2000);
        }
      } else {
        setError(response.message || 'Fehler beim Übertragen der Module');
      }
    } catch (error: any) {
      setError(error.message || 'Ein Fehler ist aufgetreten');
    } finally {
      setLoading(false);
    }
  };

  // Validation
  const isValid = vonDozent !== null && zuDozent !== null && poId !== null && selectedModuleIds.length > 0;

  // Filtered available modules
  const availableModules = module.filter(m =>
    m.dozenten.some(d => d.id === vonDozent?.id && d.rolle === rolle)
  );

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
      <DialogTitle>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box display="flex" alignItems="center" gap={1}>
            <SwapHoriz />
            <Typography variant="h6">Bulk Transfer - Module übertragen</Typography>
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

        {result && (
          <Alert
            severity={result.fehlgeschlagen_count === 0 ? 'success' : 'warning'}
            sx={{ mb: 2 }}
          >
            <Typography variant="body2" fontWeight="bold">
              {result.erfolgreich_count} von {result.gesamt} Modulen erfolgreich übertragen
            </Typography>
            {result.fehlgeschlagen_count > 0 && (
              <Box sx={{ mt: 1 }}>
                <Typography variant="caption">Fehler:</Typography>
                <List dense>
                  {result.fehlgeschlagen.map((f, idx) => (
                    <ListItem key={idx} dense>
                      <ListItemText
                        primary={`Modul ${f.modul_id}: ${f.fehler}`}
                        primaryTypographyProps={{ variant: 'caption' }}
                      />
                    </ListItem>
                  ))}
                </List>
              </Box>
            )}
          </Alert>
        )}

        <Grid container spacing={3}>
          {/* Von Dozent */}
          <Grid item xs={12} md={6}>
            <Autocomplete
              options={dozenten}
              getOptionLabel={(option) => option.name_komplett}
              value={vonDozent}
              onChange={(_, newValue) => setVonDozent(newValue)}
              loading={loadingDozenten}
              disabled={loading || !!result}
              renderInput={(params) => (
                <TextField
                  {...params}
                  label="Von Dozent *"
                  placeholder="Aktueller Dozent..."
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
            />
          </Grid>

          {/* Zu Dozent */}
          <Grid item xs={12} md={6}>
            <Autocomplete
              options={dozenten.filter(d => d.id !== vonDozent?.id)}
              getOptionLabel={(option) => option.name_komplett}
              value={zuDozent}
              onChange={(_, newValue) => setZuDozent(newValue)}
              loading={loadingDozenten}
              disabled={loading || !!result}
              renderInput={(params) => (
                <TextField
                  {...params}
                  label="Zu Dozent *"
                  placeholder="Neuer Dozent..."
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
            />
          </Grid>

          {/* Prüfungsordnung */}
          <Grid item xs={12} md={6}>
            <FormControl fullWidth required disabled={loading || !!result || loadingPOs}>
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
            <FormControl fullWidth required disabled={loading || !!result}>
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

          {/* Module Selection */}
          {vonDozent && (
            <>
              <Grid item xs={12}>
                <Divider />
              </Grid>
              <Grid item xs={12}>
                <Typography variant="subtitle2" gutterBottom>
                  Module auswählen ({selectedModuleIds.length} ausgewählt)
                </Typography>
                {availableModules.length === 0 ? (
                  <Alert severity="info">
                    {vonDozent.name_komplett} hat keine Module mit der Rolle "{rolle}"
                  </Alert>
                ) : (
                  <Paper variant="outlined" sx={{ maxHeight: 300, overflow: 'auto' }}>
                    <List dense>
                      {availableModules.map((modul) => (
                        <ListItem
                          key={modul.id}
                          button
                          onClick={() => !loading && !result && handleToggleModul(modul.id)}
                          disabled={loading || !!result}
                        >
                          <ListItemIcon>
                            <Checkbox
                              edge="start"
                              checked={selectedModuleIds.includes(modul.id)}
                              disabled={loading || !!result}
                            />
                          </ListItemIcon>
                          <ListItemIcon>
                            <School />
                          </ListItemIcon>
                          <ListItemText
                            primary={`${modul.kuerzel} - ${modul.bezeichnung_de}`}
                            secondary={`${modul.dozenten.length} Dozent(en)`}
                          />
                        </ListItem>
                      ))}
                    </List>
                  </Paper>
                )}
              </Grid>
            </>
          )}

          {/* Bemerkung */}
          <Grid item xs={12}>
            <TextField
              fullWidth
              multiline
              rows={2}
              label="Bemerkung (optional)"
              placeholder="z.B. 'Workload-Ausgleich WS25/26'"
              value={bemerkung}
              onChange={(e) => setBemerkung(e.target.value)}
              disabled={loading || !!result}
            />
          </Grid>

          {/* Preview */}
          {vonDozent && zuDozent && selectedModuleIds.length > 0 && !result && (
            <Grid item xs={12}>
              <Alert severity="info">
                <Typography variant="body2" fontWeight="bold">
                  Vorschau:
                </Typography>
                <Typography variant="caption">
                  {selectedModuleIds.length} Module werden von{' '}
                  <strong>{vonDozent.name_komplett}</strong> zu{' '}
                  <strong>{zuDozent.name_komplett}</strong> übertragen (Rolle: {rolle})
                </Typography>
              </Alert>
            </Grid>
          )}
        </Grid>
      </DialogContent>

      <DialogActions>
        <Button onClick={handleClose} disabled={loading}>
          {result ? 'Schließen' : 'Abbrechen'}
        </Button>
        {!result && (
          <Button
            variant="contained"
            onClick={handleSubmit}
            disabled={loading || !isValid}
            startIcon={loading ? <CircularProgress size={20} /> : <SwapHoriz />}
          >
            {loading ? 'Wird übertragen...' : `${selectedModuleIds.length} Module übertragen`}
          </Button>
        )}
      </DialogActions>
    </Dialog>
  );
};

export default BulkTransferDialog;
