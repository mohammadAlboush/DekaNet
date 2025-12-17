
import React, { useState, useEffect } from 'react';
import {
  Box,
  Stepper,
  Step,
  StepLabel,
  StepContent,
  Button,
  Paper,
  Typography,
  Container,
  Alert,
  CircularProgress,
  LinearProgress,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  List,
  ListItem,
  ListItemText,
} from '@mui/material';
import {
  CheckCircle,
  Warning,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';

// Step Components
import StepSemesterAuswahl from '../components/planning/wizard/steps/StepSemesterAuswahl';
import StepModuleAuswahl from '../components/planning/wizard/steps/StepModuleAuswahl';
import StepModuleHinzufuegen from '../components/planning/wizard/steps/Stepmodulehinzufuegen';
import StepMitarbeiterZuordnen from '../components/planning/wizard/steps/StepMitarbeiterZuordnen';
// ❌ REMOVED: StepMultiplikatoren (nicht mehr benötigt - Multiplikatoren werden in Schritt 3 gesetzt)
import StepSemesterauftraege from '../components/planning/wizard/steps/StepSemesterauftraege';
import StepZusatzInfos from '../components/planning/wizard/steps/StepZusatzInfos';
import StepWunschFreieTage from '../components/planning/wizard/steps/StepWunschFreieTage';
import StepZusammenfassung from '../components/planning/wizard/steps/StepZusammenfassung';

// Services & Store
import planungService from '../services/planungService';
import usePlanungStore from '../store/planungStore';
import usePlanungPhaseStore from '../store/planungPhaseStore';
import { useToastStore } from '../components/common/Toast';
import useAuthStore from '../store/authStore';

const STEPS = [
  {
    label: 'Semester auswählen',
    icon: '📅',
    description: 'Wählen Sie das Semester für Ihre Planung'
  },
  {
    label: 'Module auswählen',
    icon: '📚',
    description: 'Wählen Sie die Module aus dem Katalog'
  },
  {
    label: 'Module hinzufügen',
    icon: '➕',
    description: 'Konfigurieren Sie die Lehrformen und Multiplikatoren'
  },
  {
    label: 'Mitarbeiter zuordnen',
    icon: '👥',
    description: 'Optional: Ordnen Sie Mitarbeiter zu'
  },
  // ❌ REMOVED: 'Multiplikatoren setzen' - Wird jetzt in Schritt 3 gemacht
  {
    label: 'Semesteraufträge',
    icon: '💼',
    description: 'Optional: Aufträge beantragen (z.B. Dekanin, Prodekan)'
  },
  {
    label: 'Zusätzliche Infos',
    icon: '📝',
    description: 'Anmerkungen und Raumbedarf'
  },
  {
    label: 'Wunsch-freie Tage',
    icon: '📆',
    description: 'Optional: Wünsche für freie Tage'
  },
  {
    label: 'Zusammenfassung',
    icon: '✅',
    description: 'Überprüfen und einreichen'
  },
];

/**
 * ===========================
 * - Erstellt Planung in Schritt 1
 * - Korrekte Prop-Weitergabe (setPlanungId)
 * - Keine getState() Fehler mehr
 */
const WizardView: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const { user } = useAuthStore();
  const showToast = useToastStore((state) => state.showToast);

  // Planning Phase Store
  const {
    activePhase,
    submissionStatus,
    checkSubmissionStatus,
    canSubmit,
    recordNewSubmission,
  } = usePlanungPhaseStore();

  // Store - Alle benötigten Werte destrukturieren
  const {
    // State
    currentStep,
    planungId,
    semesterId,
    semester,
    selectedModules,
    geplantModule,
    mitarbeiterZuordnung,
    anmerkungen,
    raumbedarf,
    wunschFreieTage,
    isLoading,
    error,
    lastSaved,
    
    // Actions
    setCurrentStep,
    nextStep,
    previousStep,
    setPlanungId,
    setLoading,
    setError,
    setWizardData,
    resetWizard,
    getTotalSWS,
    loadFromLocalStorage,
    clearLocalStorage,
  } = usePlanungStore();

  const [showValidationDialog, setShowValidationDialog] = useState(false);
  const [validationErrors, setValidationErrors] = useState<string[]>([]);

  // Load existing planung if editing
  useEffect(() => {
    // Check phase submission status
    checkPhaseStatus();

    if (id) {
      loadPlanung(parseInt(id));
    } else {
      // Reset for new planung - aber lösche NICHT LocalStorage!
      console.log('[Wizard] Starting new wizard');
      // Versuche aus LocalStorage zu laden
      const restored = loadFromLocalStorage();
      if (restored) {
        showToast('Daten wiederhergestellt', 'info');
      }
    }

    return () => {
      // Cleanup nur bei neuem Wizard UND erfolgreichem Submit
      // LocalStorage wird erst bei Submit gelöscht
    };
  }, [id]);

  const checkPhaseStatus = async () => {
    try {
      await checkSubmissionStatus(user?.id);

      // Check if new submission is allowed
      if (!id && !canSubmit()) {
        let message = 'Sie können derzeit keine neue Planung erstellen.\n';
        if (submissionStatus?.grund === 'keine_aktive_phase') {
          message += 'Es ist keine aktive Planungsphase vorhanden.';
        } else if (submissionStatus?.grund === 'bereits_genehmigt') {
          message += 'Sie haben bereits eine genehmigte Planung in dieser Phase.';
        } else if (submissionStatus?.grund === 'phase_abgelaufen') {
          message += 'Die Deadline für diese Phase ist abgelaufen.';
        }

        showToast(message, 'warning');
        // Show warning but don't prevent wizard - professor may be editing draft
      }
    } catch (error) {
      console.error('Error checking phase status:', error);
    }
  };

  const loadPlanung = async (planungId: number) => {
    setLoading(true);
    try {
      console.log('[Wizard] 📥 Loading planung:', planungId);
      
      const response = await planungService.getPlanung(planungId);
      
      if (response.success && response.data) {
        const planung = response.data;
        
        console.log('[Wizard] ✅ Planung loaded:', planung);
        
        // Populate store from existing planung
        setWizardData({
          planungId: planung.id,
          semesterId: planung.semester_id,
          semester: planung.semester,
          geplantModule: planung.geplante_module || [],
          wunschFreieTage: planung.wunsch_freie_tage || [],
          anmerkungen: planung.notizen || '',
        });

        setPlanungId(planung.id);
      }
    } catch (error: any) {
      console.error('[Wizard] ❌ Error loading planung:', error);
      showToast('Fehler beim Laden der Planung', 'error');
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const validatePlanungForSubmission = (): { valid: boolean; errors: string[] } => {
    const errors: string[] = [];

    // Check if submission is allowed in current phase
    if (!canSubmit()) {
      if (submissionStatus?.grund === 'keine_aktive_phase') {
        errors.push('Es ist keine aktive Planungsphase vorhanden. Die Einreichung ist nicht möglich.');
      } else if (submissionStatus?.grund === 'bereits_genehmigt') {
        errors.push('Sie haben bereits eine genehmigte Planung in dieser Phase eingereicht.');
      } else if (submissionStatus?.grund === 'phase_abgelaufen') {
        errors.push('Die Deadline für Einreichungen in dieser Phase ist abgelaufen.');
      } else {
        errors.push('Die Einreichung ist derzeit nicht möglich.');
      }
    }

    // Check if planung exists
    if (!planungId) {
      errors.push('Planung wurde noch nicht erstellt. Bitte gehen Sie zurück zu Schritt 1.');
    }

    // Check if semester is selected
    if (!semesterId) {
      errors.push('Kein Semester ausgewählt.');
    }

    // Check if modules exist
    if (!geplantModule || geplantModule.length === 0) {
      errors.push('Mindestens ein Modul muss zur Planung hinzugefügt werden.');
    }

    // Check if modules have valid SWS
    const totalSWS = getTotalSWS();
    if (totalSWS === 0) {
      errors.push('Die Gesamt-SWS muss größer als 0 sein.');
    }

    return {
      valid: errors.length === 0,
      errors
    };
  };

  const handleSubmit = async () => {
    // Validate before submission
    const validation = validatePlanungForSubmission();
    
    if (!validation.valid) {
      setValidationErrors(validation.errors);
      setShowValidationDialog(true);
      return;
    }

    const confirmed = window.confirm(
      'Möchten Sie die Planung wirklich einreichen?\n\n' +
      'Nach dem Einreichen können keine Änderungen mehr vorgenommen werden.\n' +
      'Die Planung wird an den Dekan zur Prüfung weitergeleitet.'
    );

    if (!confirmed) return;

    setLoading(true);
    try {
      console.log('[Wizard] 📤 Submitting planung:', planungId);
      
      const response = await planungService.submitPlanung(planungId!);

      if (response.success) {
        // Record submission in planning phase system if phase is active
        if (activePhase) {
          try {
            await recordNewSubmission(planungId!);
            console.log('[Wizard] 📊 Submission recorded in phase system');
          } catch (phaseError) {
            console.error('[Wizard] Error recording submission in phase:', phaseError);
            // Continue even if phase recording fails - submission was successful
          }
        }

        showToast('Planung erfolgreich eingereicht', 'success');

        // Clear LocalStorage nach erfolgreichem Submit
        clearLocalStorage();
        console.log('[Wizard] 🗑️ LocalStorage cleared after successful submit');

        resetWizard();
        navigate('/semesterplanung');
      } else {
        // Handle API error response
        showToast(response.message || 'Fehler beim Einreichen', 'error');
        setError(response.message || 'Fehler beim Einreichen');
      }
    } catch (error: any) {
      console.error('[Wizard] ❌ Error submitting planung:', error);
      showToast(error.message || 'Fehler beim Einreichen der Planung', 'error');
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleStepUpdate = (data: any) => {
    console.log('[Wizard] 💾 Step update:', Object.keys(data));
    setWizardData(data);
    // Auto-Save läuft automatisch im Store
  };

  const handleStepNext = () => {
    console.log('[Wizard] ➡️ Next step');
    nextStep();
  };

  const getStepContent = (step: number) => {
    const wizardData = {
      semesterId,
      semester,
      selectedModules,
      geplantModule,
      mitarbeiterZuordnung,
      anmerkungen,
      raumbedarf,
      wunschFreieTage,
      planungId,
    };

    switch (step) {
      case 0:
        return (
          <StepSemesterAuswahl
            data={wizardData}
            onUpdate={handleStepUpdate}
            onNext={handleStepNext}
            planungId={planungId ?? undefined}
            setPlanungId={setPlanungId}  // ← WICHTIG: weitergeben!
          />
        );
      
      case 1:
        return (
          <StepModuleAuswahl
            data={wizardData}
            onUpdate={handleStepUpdate}
            onNext={handleStepNext}
            onBack={previousStep}
          />
        );
      
      case 2:
        return (
          <StepModuleHinzufuegen
            data={wizardData}
            onUpdate={handleStepUpdate}
            onNext={handleStepNext}
            onBack={previousStep}
            planungId={planungId ?? undefined}
          />
        );
      
      case 3:
        return (
          <StepMitarbeiterZuordnen
            data={wizardData}
            onUpdate={handleStepUpdate}
            onNext={handleStepNext}
            onBack={previousStep}
          />
        );

      // ❌ REMOVED: case 4 (StepMultiplikatoren) - Nicht mehr benötigt

      case 4:
        return (
          <StepSemesterauftraege
            data={wizardData}
            onUpdate={handleStepUpdate}
            onNext={handleStepNext}
            onBack={previousStep}
            planungId={planungId ?? undefined}
          />
        );

      case 5:
        return (
          <StepZusatzInfos
            data={wizardData}
            onUpdate={handleStepUpdate}
            onNext={handleStepNext}
            onBack={previousStep}
          />
        );

      case 6:
        return (
          <StepWunschFreieTage
            data={wizardData}
            onUpdate={handleStepUpdate}
            onNext={handleStepNext}
            onBack={previousStep}
            planungId={planungId ?? undefined}
          />
        );

      case 7:
        return (
          <StepZusammenfassung
            data={wizardData}
            onBack={previousStep}
            onSubmit={handleSubmit}
            planungId={planungId ?? undefined}
          />
        );
      
      default:
        return null;
    }
  };

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', py: 4, gap: 2 }}>
        <CircularProgress size={48} />
        <Typography>Lade Planung...</Typography>
      </Box>
    );
  }

  const progress = ((currentStep + 1) / STEPS.length) * 100;
  const totalSWS = getTotalSWS();
  const moduleCount = geplantModule?.length || 0;

  return (
    <Container maxWidth="lg">
      {/* Header */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Box>
            <Typography variant="h4" gutterBottom>
              {id ? 'Semesterplanung bearbeiten' : 'Neue Semesterplanung'}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {user?.name_komplett || user?.username} • {STEPS[currentStep].description}
            </Typography>
          </Box>
          
          {planungId && (
            <Alert severity="success" sx={{ py: 0.5, px: 2 }}>
              <Typography variant="caption">
                ✅ Planung ID: <strong>{planungId}</strong>
              </Typography>
            </Alert>
          )}
        </Box>

        {/* Progress Bar */}
        <Box sx={{ mt: 2 }}>
          <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}>
            <Typography variant="body2" color="text.secondary">
              Schritt {currentStep + 1} von {STEPS.length}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {progress.toFixed(0)}% abgeschlossen
            </Typography>
          </Box>
          <LinearProgress variant="determinate" value={progress} sx={{ height: 8, borderRadius: 1 }} />
        </Box>

        {/* Stats */}
        {(totalSWS > 0 || moduleCount > 0) && (
          <Box sx={{ mt: 2, p: 2, bgcolor: 'background.default', borderRadius: 1, display: 'flex', gap: 3 }}>
            <Typography variant="body2">
              <strong>Module:</strong> {moduleCount}
            </Typography>
            <Typography variant="body2">
              <strong>Gesamt SWS:</strong> {totalSWS.toFixed(1)} SWS
            </Typography>
          </Box>
        )}

        {/* Warning if no modules */}
        {planungId && moduleCount === 0 && currentStep >= 2 && (
          <Alert severity="warning" sx={{ mt: 2 }} icon={<Warning />}>
            <Typography variant="body2">
              <strong>Achtung:</strong> Sie haben noch keine Module zur Planung hinzugefügt. 
              Mindestens ein Modul ist erforderlich, um die Planung einzureichen.
            </Typography>
          </Alert>
        )}

        {/* Error Alert */}
        {error && (
          <Alert severity="error" sx={{ mt: 2 }} onClose={() => setError(null)}>
            {error}
          </Alert>
        )}

        {/* Auto-Save Info */}
        {lastSaved && (
          <Alert severity="info" sx={{ mt: 2 }}>
            <Typography variant="caption">
              💾 Letzte Sicherung: {new Date(lastSaved).toLocaleTimeString('de-DE')}
            </Typography>
          </Alert>
        )}
      </Paper>

      {/* Wizard Steps */}
      <Paper sx={{ p: 3 }}>
        <Stepper activeStep={currentStep} orientation="vertical">
          {STEPS.map((step, index) => (
            <Step key={step.label}>
              <StepLabel
                optional={
                  index === STEPS.length - 1 ? (
                    <Typography variant="caption">Letzter Schritt</Typography>
                  ) : undefined
                }
              >
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <span style={{ fontSize: '1.2rem' }}>{step.icon}</span>
                  <Typography variant="subtitle1">{step.label}</Typography>
                </Box>
              </StepLabel>
              <StepContent>
                <Box sx={{ my: 2 }}>
                  {getStepContent(index)}
                </Box>
              </StepContent>
            </Step>
          ))}
        </Stepper>

        {/* Completion */}
        {currentStep === STEPS.length && (
          <Paper square elevation={0} sx={{ p: 3, bgcolor: 'success.lighter' }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
              <CheckCircle color="success" sx={{ fontSize: 48 }} />
              <Box>
                <Typography variant="h6">
                  Planung erfolgreich eingereicht!
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Ihre Semesterplanung wurde zur Prüfung an den Dekan weitergeleitet.
                </Typography>
              </Box>
            </Box>
            <Button
              variant="contained"
              onClick={() => navigate('/semesterplanung')}
              sx={{ mt: 2 }}
            >
              Zur Übersicht
            </Button>
          </Paper>
        )}
      </Paper>

      {/* Validation Dialog */}
      <Dialog
        open={showValidationDialog}
        onClose={() => setShowValidationDialog(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Warning color="warning" />
            <Typography variant="h6">Planung kann nicht eingereicht werden</Typography>
          </Box>
        </DialogTitle>
        <DialogContent>
          <Typography variant="body2" paragraph>
            Bitte beheben Sie folgende Probleme, bevor Sie die Planung einreichen:
          </Typography>
          <List dense>
            {validationErrors.map((error, index) => (
              <ListItem key={index} sx={{ pl: 0 }}>
                <ListItemText
                  primary={`${index + 1}. ${error}`}
                  primaryTypographyProps={{ variant: 'body2', color: 'error' }}
                />
              </ListItem>
            ))}
          </List>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowValidationDialog(false)} color="primary">
            Verstanden
          </Button>
        </DialogActions>
      </Dialog>

      {/* Navigation Info */}
      <Box sx={{ mt: 2, textAlign: 'center' }}>
        <Typography variant="caption" color="text.secondary">
          💾 Ihre Änderungen werden automatisch gespeichert
        </Typography>
      </Box>
    </Container>
  );
};

export default WizardView;