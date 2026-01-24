import React, { useState, useEffect } from 'react';
import {
  Paper,
  Typography,
  Box,
  Button,
  Alert,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  CircularProgress,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  Divider,
  Chip,
  Stepper,
  Step,
  StepLabel,
} from '@mui/material';
import {
  Warning,
  DeleteForever,
  CheckCircle,
  Cancel,
  Assignment,
  Work,
  School,
  Description,
} from '@mui/icons-material';
import adminService, { ResetPreview } from '../../services/adminService';
import { useToastStore } from '../common/Toast';

const CONFIRMATION_CODE = 'RESET_BESTAETIGEN';

const ResetDatabaseSettings: React.FC = () => {
  const showToast = useToastStore((state) => state.showToast);

  const [loading, setLoading] = useState(false);
  const [preview, setPreview] = useState<ResetPreview | null>(null);
  const [previewError, setPreviewError] = useState<string | null>(null);

  // Dialog States
  const [step1Open, setStep1Open] = useState(false);
  const [step2Open, setStep2Open] = useState(false);
  const [step3Open, setStep3Open] = useState(false);
  const [successDialogOpen, setSuccessDialogOpen] = useState(false);

  // Confirmation Input
  const [confirmationInput, setConfirmationInput] = useState('');
  const [resetResult, setResetResult] = useState<ResetPreview | null>(null);

  // Load preview on mount
  useEffect(() => {
    loadPreview();
  }, []);

  const loadPreview = async () => {
    try {
      setLoading(true);
      setPreviewError(null);
      const response = await adminService.getResetPreview();
      if (response.success && response.preview) {
        setPreview(response.preview);
      } else {
        setPreviewError(response.error || 'Fehler beim Laden der Vorschau');
      }
    } catch (error: any) {
      setPreviewError(error.message || 'Fehler beim Laden der Vorschau');
    } finally {
      setLoading(false);
    }
  };

  const handleStartReset = () => {
    setStep1Open(true);
  };

  const handleStep1Confirm = () => {
    setStep1Open(false);
    setStep2Open(true);
  };

  const handleStep2Confirm = () => {
    setStep2Open(false);
    setConfirmationInput('');
    setStep3Open(true);
  };

  const handleStep3Confirm = async () => {
    if (confirmationInput !== CONFIRMATION_CODE) {
      showToast('Bestätigungscode stimmt nicht überein', 'error');
      return;
    }

    try {
      setLoading(true);
      const response = await adminService.resetDatabase(CONFIRMATION_CODE);

      if (response.success) {
        setStep3Open(false);
        setResetResult(response.deleted || null);
        setSuccessDialogOpen(true);
        // Reload preview to show updated counts (should all be 0)
        await loadPreview();
      } else {
        showToast(response.error || 'Fehler beim Zurücksetzen', 'error');
      }
    } catch (error: any) {
      showToast(error.message || 'Fehler beim Zurücksetzen', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleCloseAll = () => {
    setStep1Open(false);
    setStep2Open(false);
    setStep3Open(false);
    setSuccessDialogOpen(false);
    setConfirmationInput('');
  };

  const hasData = preview && preview.total_items > 0;

  return (
    <>
      <Paper sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
          <DeleteForever sx={{ fontSize: 40, color: 'error.main' }} />
          <Box>
            <Typography variant="h6">Datenbank zurücksetzen</Typography>
            <Typography variant="body2" color="text.secondary">
              Löscht alle Semesterplanungen und Deputatsabrechnungen
            </Typography>
          </Box>
        </Box>

        <Alert severity="warning" sx={{ mb: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            Diese Aktion ist nicht umkehrbar!
          </Typography>
          <Typography variant="body2">
            Alle Semesterplanungen, Deputatsabrechnungen und Semesteraufträge werden unwiderruflich gelöscht.
            Stammdaten (Module, Dozenten, Semester, etc.) bleiben erhalten.
          </Typography>
        </Alert>

        {previewError && (
          <Alert severity="error" sx={{ mb: 3 }}>
            {previewError}
          </Alert>
        )}

        {loading && !preview ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
            <CircularProgress />
          </Box>
        ) : preview ? (
          <>
            <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
              Aktuelle Daten in der Datenbank:
            </Typography>

            <List dense>
              <ListItem>
                <ListItemIcon>
                  <Assignment color="primary" />
                </ListItemIcon>
                <ListItemText
                  primary="Semesterplanungen"
                  secondary={`${preview.semesterplanungen} Planungen, ${preview.geplante_module} Module, ${preview.wunsch_freie_tage} Wunschtage`}
                />
                <Chip
                  label={preview.semesterplanungen}
                  size="small"
                  color={preview.semesterplanungen > 0 ? 'warning' : 'default'}
                />
              </ListItem>
              <Divider />
              <ListItem>
                <ListItemIcon>
                  <Description color="primary" />
                </ListItemIcon>
                <ListItemText
                  primary="Deputatsabrechnungen"
                  secondary={`${preview.deputatsabrechnungen} Abrechnungen`}
                />
                <Chip
                  label={preview.deputatsabrechnungen}
                  size="small"
                  color={preview.deputatsabrechnungen > 0 ? 'warning' : 'default'}
                />
              </ListItem>
              <Divider />
              <ListItem>
                <ListItemIcon>
                  <Work color="primary" />
                </ListItemIcon>
                <ListItemText
                  primary="Semesteraufträge"
                  secondary="Zuordnungen von Aufträgen zu Dozenten"
                />
                <Chip
                  label={preview.semester_auftraege}
                  size="small"
                  color={preview.semester_auftraege > 0 ? 'warning' : 'default'}
                />
              </ListItem>
            </List>

            <Box sx={{ mt: 3, p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
              <Typography variant="body2" color="text.secondary">
                <strong>Gesamt zu löschende Einträge:</strong> {preview.total_items}
              </Typography>
            </Box>

            <Box sx={{ mt: 3, display: 'flex', justifyContent: 'flex-end' }}>
              <Button
                variant="contained"
                color="error"
                startIcon={<DeleteForever />}
                onClick={handleStartReset}
                disabled={loading || !hasData}
              >
                {hasData ? 'Datenbank zurücksetzen' : 'Keine Daten zum Löschen'}
              </Button>
            </Box>
          </>
        ) : null}
      </Paper>

      {/* Step 1: Initial Warning */}
      <Dialog open={step1Open} onClose={handleCloseAll} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Warning color="warning" />
          Schritt 1 von 3: Erste Warnung
        </DialogTitle>
        <DialogContent>
          <Stepper activeStep={0} sx={{ mb: 3 }}>
            <Step>
              <StepLabel>Warnung</StepLabel>
            </Step>
            <Step>
              <StepLabel>Bestätigung</StepLabel>
            </Step>
            <Step>
              <StepLabel>Code eingeben</StepLabel>
            </Step>
          </Stepper>

          <Alert severity="error" sx={{ mb: 2 }}>
            <Typography variant="subtitle2" gutterBottom>
              ACHTUNG: Sie sind dabei, die Datenbank zurückzusetzen!
            </Typography>
            <Typography variant="body2">
              Diese Aktion löscht ALLE Semesterplanungen und Deputatsabrechnungen.
              Diese Daten können NICHT wiederhergestellt werden.
            </Typography>
          </Alert>

          <Typography variant="body2" sx={{ mb: 2 }}>
            Folgende Daten werden gelöscht:
          </Typography>

          <List dense>
            <ListItem>
              <ListItemIcon><Cancel color="error" /></ListItemIcon>
              <ListItemText primary={`${preview?.semesterplanungen || 0} Semesterplanungen`} />
            </ListItem>
            <ListItem>
              <ListItemIcon><Cancel color="error" /></ListItemIcon>
              <ListItemText primary={`${preview?.deputatsabrechnungen || 0} Deputatsabrechnungen`} />
            </ListItem>
            <ListItem>
              <ListItemIcon><Cancel color="error" /></ListItemIcon>
              <ListItemText primary={`${preview?.semester_auftraege || 0} Semesteraufträge`} />
            </ListItem>
          </List>

          <Alert severity="info" sx={{ mt: 2 }}>
            <Typography variant="body2">
              Stammdaten wie Module, Dozenten, Semester und Benutzer bleiben erhalten.
            </Typography>
          </Alert>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAll} color="inherit">
            Abbrechen
          </Button>
          <Button onClick={handleStep1Confirm} color="warning" variant="contained">
            Verstanden, weiter
          </Button>
        </DialogActions>
      </Dialog>

      {/* Step 2: Confirmation */}
      <Dialog open={step2Open} onClose={handleCloseAll} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Warning color="error" />
          Schritt 2 von 3: Letzte Chance zum Abbruch
        </DialogTitle>
        <DialogContent>
          <Stepper activeStep={1} sx={{ mb: 3 }}>
            <Step completed>
              <StepLabel>Warnung</StepLabel>
            </Step>
            <Step>
              <StepLabel>Bestätigung</StepLabel>
            </Step>
            <Step>
              <StepLabel>Code eingeben</StepLabel>
            </Step>
          </Stepper>

          <Alert severity="error" sx={{ mb: 2 }}>
            <Typography variant="subtitle2" gutterBottom>
              SIND SIE WIRKLICH SICHER?
            </Typography>
            <Typography variant="body2">
              Nach dem nächsten Schritt gibt es keinen Weg zurück.
              Alle Planungsdaten werden unwiderruflich gelöscht.
            </Typography>
          </Alert>

          <Box sx={{ p: 2, bgcolor: 'error.light', borderRadius: 1, mb: 2 }}>
            <Typography variant="body1" color="error.contrastText" fontWeight="bold">
              {preview?.total_items || 0} Einträge werden gelöscht!
            </Typography>
          </Box>

          <Typography variant="body2" color="text.secondary">
            Wenn Sie fortfahren möchten, klicken Sie auf "Ja, ich bin sicher".
            Sie müssen dann noch einen Bestätigungscode eingeben.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAll} color="inherit" variant="outlined">
            Nein, abbrechen
          </Button>
          <Button onClick={handleStep2Confirm} color="error" variant="contained">
            Ja, ich bin sicher
          </Button>
        </DialogActions>
      </Dialog>

      {/* Step 3: Enter Confirmation Code */}
      <Dialog open={step3Open} onClose={handleCloseAll} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <DeleteForever color="error" />
          Schritt 3 von 3: Bestätigungscode eingeben
        </DialogTitle>
        <DialogContent>
          <Stepper activeStep={2} sx={{ mb: 3 }}>
            <Step completed>
              <StepLabel>Warnung</StepLabel>
            </Step>
            <Step completed>
              <StepLabel>Bestätigung</StepLabel>
            </Step>
            <Step>
              <StepLabel>Code eingeben</StepLabel>
            </Step>
          </Stepper>

          <Alert severity="error" sx={{ mb: 3 }}>
            <Typography variant="body2">
              Um den Reset durchzuführen, geben Sie bitte den folgenden Code ein:
            </Typography>
            <Typography variant="h6" sx={{ mt: 1, fontFamily: 'monospace' }}>
              {CONFIRMATION_CODE}
            </Typography>
          </Alert>

          <TextField
            fullWidth
            label="Bestätigungscode"
            value={confirmationInput}
            onChange={(e) => setConfirmationInput(e.target.value.toUpperCase())}
            placeholder="Code hier eingeben"
            variant="outlined"
            autoFocus
            error={confirmationInput.length > 0 && confirmationInput !== CONFIRMATION_CODE}
            helperText={
              confirmationInput.length > 0 && confirmationInput !== CONFIRMATION_CODE
                ? 'Code stimmt nicht überein'
                : 'Geben Sie den Code exakt wie oben angezeigt ein'
            }
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAll} color="inherit" disabled={loading}>
            Abbrechen
          </Button>
          <Button
            onClick={handleStep3Confirm}
            color="error"
            variant="contained"
            disabled={loading || confirmationInput !== CONFIRMATION_CODE}
            startIcon={loading ? <CircularProgress size={20} /> : <DeleteForever />}
          >
            {loading ? 'Wird gelöscht...' : 'JETZT ZURÜCKSETZEN'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Success Dialog */}
      <Dialog open={successDialogOpen} onClose={handleCloseAll} maxWidth="sm" fullWidth>
        <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <CheckCircle color="success" />
          Datenbank erfolgreich zurückgesetzt
        </DialogTitle>
        <DialogContent>
          <Alert severity="success" sx={{ mb: 2 }}>
            <Typography variant="body2">
              Die Datenbank wurde erfolgreich zurückgesetzt.
              Alle Planungsdaten wurden gelöscht.
            </Typography>
          </Alert>

          {resetResult && (
            <>
              <Typography variant="subtitle2" gutterBottom>
                Gelöschte Einträge:
              </Typography>
              <List dense>
                <ListItem>
                  <ListItemText
                    primary="Semesterplanungen"
                    secondary={`${resetResult.semesterplanungen} gelöscht`}
                  />
                </ListItem>
                <ListItem>
                  <ListItemText
                    primary="Geplante Module"
                    secondary={`${resetResult.geplante_module} gelöscht`}
                  />
                </ListItem>
                <ListItem>
                  <ListItemText
                    primary="Deputatsabrechnungen"
                    secondary={`${resetResult.deputatsabrechnungen} gelöscht`}
                  />
                </ListItem>
                <ListItem>
                  <ListItemText
                    primary="Semesteraufträge"
                    secondary={`${resetResult.semester_auftraege} gelöscht`}
                  />
                </ListItem>
              </List>
            </>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAll} color="primary" variant="contained">
            Schließen
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

export default ResetDatabaseSettings;
