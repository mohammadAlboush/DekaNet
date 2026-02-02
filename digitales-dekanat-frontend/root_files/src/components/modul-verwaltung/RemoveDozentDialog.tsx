import React, { useState } from 'react';
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
  Box,
  Chip
} from '@mui/material';
import { Delete, Warning, Close } from '@mui/icons-material';
import modulVerwaltungService from '../../services/modulVerwaltungService';
import { getErrorMessage } from '../../utils/errorUtils';

interface RemoveDozentDialogProps {
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
      name: string;
      rolle: string;
    };
  } | null;
}

const RemoveDozentDialog: React.FC<RemoveDozentDialogProps> = ({
  open,
  onClose,
  onSuccess,
  data
}) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [bemerkung, setBemerkung] = useState<string>('');

  // Reset form
  const resetForm = () => {
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
    if (!data) return;

    setLoading(true);
    setError(null);

    try {
      const response = await modulVerwaltungService.removeDozentFromModul(
        data.zuordnung.zuordnung_id,
        bemerkung ? { bemerkung } : undefined
      );

      if (response.success) {
        onSuccess();
        handleClose();
      } else {
        setError(response.message || 'Fehler beim Entfernen des Dozenten');
      }
    } catch (error: unknown) {
      setError(getErrorMessage(error, 'Ein Fehler ist aufgetreten'));
    } finally {
      setLoading(false);
    }
  };

  if (!data) return null;

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

  return (
    <Dialog open={open} onClose={handleClose} maxWidth="sm" fullWidth>
      <DialogTitle>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box display="flex" alignItems="center" gap={1}>
            <Delete color="error" />
            <Typography variant="h6">Dozent entfernen</Typography>
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

        {/* Warning */}
        <Alert severity="warning" icon={<Warning />} sx={{ mb: 3 }}>
          <Typography variant="body2" fontWeight="bold">
            Sind Sie sicher?
          </Typography>
          <Typography variant="caption">
            Diese Aktion kann nicht rückgängig gemacht werden.
          </Typography>
        </Alert>

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

          {/* Dozent Info */}
          <Grid item xs={12}>
            <Box sx={{ p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                Dozent wird entfernt
              </Typography>
              <Box display="flex" alignItems="center" gap={1}>
                <Typography variant="body1" fontWeight="bold">
                  {data.zuordnung.name}
                </Typography>
                {renderRolleChip(data.zuordnung.rolle)}
              </Box>
            </Box>
          </Grid>

          {/* Bemerkung */}
          <Grid item xs={12}>
            <TextField
              fullWidth
              multiline
              rows={3}
              label="Bemerkung (optional)"
              placeholder="z.B. 'Dozent geht in Rente'"
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
          color="error"
          onClick={handleSubmit}
          disabled={loading}
          startIcon={loading ? <CircularProgress size={20} /> : <Delete />}
        >
          {loading ? 'Wird entfernt...' : 'Entfernen'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default RemoveDozentDialog;
