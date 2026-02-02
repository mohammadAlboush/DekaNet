import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Grid,
  TextField,
  Typography,
  CircularProgress,
  Alert,
  Autocomplete,
  Box,
  Chip
} from '@mui/material';
import { SwapHoriz, Close, ArrowForward } from '@mui/icons-material';
import modulVerwaltungService from '../../services/modulVerwaltungService';
import dozentService, { Dozent } from '../../services/dozentService';
import { createContextLogger } from '../../utils/logger';
import { getErrorMessage } from '../../utils/errorUtils';

const log = createContextLogger('ReplaceDozentDialog');

interface ReplaceDozentDialogProps {
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
  data: {
    modul: {
      id: number;
      kuerzel: string;
      bezeichnung_de: string;
    };
    zuordnung: {
      zuordnung_id: number;
      id: number;
      name: string;
      rolle: string;
    };
  } | null;
}

const ReplaceDozentDialog: React.FC<ReplaceDozentDialogProps> = ({
  open,
  onClose,
  onSuccess,
  data
}) => {
  const [loading, setLoading] = useState(false);
  const [loadingDozenten, setLoadingDozenten] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [dozenten, setDozenten] = useState<Dozent[]>([]);

  // Form Data
  const [selectedDozent, setSelectedDozent] = useState<Dozent | null>(null);
  const [bemerkung, setBemerkung] = useState<string>('');

  // Load Dozenten
  useEffect(() => {
    if (open) {
      loadDozenten();
    }
  }, [open]);

  const loadDozenten = async () => {
    setLoadingDozenten(true);
    try {
      const response = await dozentService.getAllDozenten({ aktiv: true });
      if (response.success) {
        // Filter out current dozent
        const filtered = (response.data || []).filter(d => d.id !== data?.zuordnung.id);
        setDozenten(filtered);
      }
    } catch (error: unknown) {
      log.error('Error loading dozenten:', { error });
    } finally {
      setLoadingDozenten(false);
    }
  };

  // Reset form
  const resetForm = () => {
    setSelectedDozent(null);
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
    if (!selectedDozent || !data) return;

    setLoading(true);
    setError(null);

    try {
      const response = await modulVerwaltungService.replaceDozent(
        data.zuordnung.zuordnung_id,
        {
          neuer_dozent_id: selectedDozent.id,
          bemerkung: bemerkung || undefined
        }
      );

      if (response.success) {
        onSuccess();
        handleClose();
      } else {
        setError(response.message || 'Fehler beim Ersetzen des Dozenten');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error, 'Ein Fehler ist aufgetreten'));
    } finally {
      setLoading(false);
    }
  };

  // Validation
  const isValid = selectedDozent !== null;

  if (!data) return null;

  const renderRolleChip = (rolle: string) => {
    const colors: Record<string, 'default' | 'primary' | 'secondary' | 'info' | 'success' | 'warning' | 'error'> = {
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

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="md" fullWidth>
      <DialogTitle>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box display="flex" alignItems="center" gap={1}>
            <SwapHoriz />
            <Typography variant="h6">Dozent ersetzen</Typography>
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
          {/* Modul Info */}
          <Grid item xs={12}>
            <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                Modul
              </Typography>
              <Typography variant="body1" fontWeight="bold">
                {data.modul.kuerzel} - {data.modul.bezeichnung_de}
              </Typography>
            </Box>
          </Grid>

          {/* Current -> New Dozent */}
          <Grid item xs={12}>
            <Grid container spacing={2} alignItems="center">
              {/* Current Dozent */}
              <Grid item xs={12} md={5}>
                <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Aktueller Dozent
                  </Typography>
                  <Box display="flex" alignItems="center" gap={1}>
                    <Typography variant="body1" fontWeight="bold">
                      {data.zuordnung.name}
                    </Typography>
                    {renderRolleChip(data.zuordnung.rolle)}
                  </Box>
                </Box>
              </Grid>

              {/* Arrow */}
              <Grid item xs={12} md={2} sx={{ textAlign: 'center' }}>
                <ArrowForward color="primary" sx={{ fontSize: 40 }} />
              </Grid>

              {/* New Dozent */}
              <Grid item xs={12} md={5}>
                <Autocomplete
                  options={dozenten}
                  getOptionLabel={(option) => option.name_komplett}
                  value={selectedDozent}
                  onChange={(_, newValue) => setSelectedDozent(newValue)}
                  loading={loadingDozenten}
                  renderInput={(params) => (
                    <TextField
                      {...params}
                      label="Neuer Dozent *"
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
            </Grid>
          </Grid>

          {/* Info */}
          <Grid item xs={12}>
            <Alert severity="info">
              Die Rolle <strong>{data.zuordnung.rolle}</strong> wird beibehalten.
            </Alert>
          </Grid>

          {/* Bemerkung */}
          <Grid item xs={12}>
            <TextField
              fullWidth
              multiline
              rows={3}
              label="Bemerkung (optional)"
              placeholder="z.B. 'Vertretung für 2 Semester'"
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
          startIcon={loading ? <CircularProgress size={20} /> : <SwapHoriz />}
        >
          {loading ? 'Wird ersetzt...' : 'Ersetzen'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default ReplaceDozentDialog;
