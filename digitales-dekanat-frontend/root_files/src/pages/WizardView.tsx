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
  Chip,
} from '@mui/material';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('WizardView');
import {
  CheckCircle,
  Warning,
  ContentPaste,
  AcUnit,
  WbSunny,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';

// Step Components
import StepSemesterAuswahl from '../components/planning/wizard/steps/StepSemesterAuswahl';
import StepModuleAuswahl from '../components/planning/wizard/steps/StepModuleAuswahl';
import StepModuleHinzufuegen from '../components/planning/wizard/steps/Stepmodulehinzufuegen';
import StepMitarbeiterZuordnen from '../components/planning/wizard/steps/StepMitarbeiterZuordnen';
// Multiplikatoren werden in Schritt 3 (Module hinzufügen) gesetzt
import StepSemesterauftraege from '../components/planning/wizard/steps/StepSemesterauftraege';
import StepZusatzInfos from '../components/planning/wizard/steps/StepZusatzInfos';
import StepWunschFreieTage from '../components/planning/wizard/steps/StepWunschFreieTage';
import StepZusammenfassung from '../components/planning/wizard/steps/StepZusammenfassung';

// Services & Store
import planungService from '../services/planungService';
import templateService, { PlanungsTemplate } from '../services/templateService';
import usePlanungStore from '../store/planungStore';
import usePlanungPhaseStore from '../store/planungPhaseStore';
import { useToastStore } from '../components/common/Toast';
import useAuthStore from '../store/authStore';
import { getErrorMessage } from '../utils/errorUtils';
import { GeplantesModul } from '../types/planung.types';

interface WizardData {
  planungId?: number;
  semesterId?: number;
  semester?: unknown;
  geplantModule?: GeplantesModul[];
  wunschFreieTage?: unknown[];
  anmerkungen?: string;
  [key: string]: unknown;
}

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
  // Multiplikatoren werden in Schritt 3 (Module hinzufügen) gesetzt
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

  // Template State
  const [showTemplateDialog, setShowTemplateDialog] = useState(false);
  const [availableTemplate, setAvailableTemplate] = useState<PlanungsTemplate | null>(null);
  const [applyingTemplate, setApplyingTemplate] = useState(false);
  const [templateApplied, setTemplateApplied] = useState(false);
  const [templatePromptShown, setTemplatePromptShown] = useState(false); // Automatische Anzeige

  // Load existing planung if editing
  useEffect(() => {
    // Check phase submission status
    checkPhaseStatus();

    if (id) {
      loadPlanung(parseInt(id));
    } else {
      // Reset for new planung - aber lösche NICHT LocalStorage!
      log.debug(' Starting new wizard');
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
      log.error('Error checking phase status:', error);
    }
  };

  const loadPlanung = async (planungId: number) => {
    setLoading(true);
    try {
      log.debug(' 📥 Loading planung:', planungId);
      
      const response = await planungService.getPlanung(planungId);
      
      if (response.success && response.data) {
        const planung = response.data;
        
        log.debug(' ✅ Planung loaded:', planung);
        
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
    } catch (error: unknown) {
      log.error(' ❌ Error loading planung:', error);
      showToast(getErrorMessage(error, 'Fehler beim Laden der Planung'), 'error');
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  // =========================================================================
  // TEMPLATE FUNCTIONS
  // =========================================================================

  /**
   * Ermittelt den Semestertyp aus dem Semesterkuerzel
   */
  const getSemesterTyp = (): 'winter' | 'sommer' => {
    if (!semester?.kuerzel) return 'winter';
    const kuerzel = semester.kuerzel.toLowerCase();
    if (kuerzel.includes('ws') || kuerzel.includes('winter')) {
      return 'winter';
    }
    return 'sommer';
  };

  /**
   * Laedt verfuegbares Template fuer aktuellen Semestertyp
   */
  const loadAvailableTemplate = async () => {
    if (!semester) return;

    try {
      const semesterTyp = getSemesterTyp();
      log.debug(' Loading template for:', semesterTyp);

      const response = await templateService.getTemplateForSemester(semesterTyp);
      if (response.success && response.data) {
        setAvailableTemplate(response.data);
        log.debug(' Template found:', response.data.name, 'with', response.data.anzahl_module, 'modules');
      } else {
        setAvailableTemplate(null);
        log.debug(' No template found for', semesterTyp);
      }
    } catch (error) {
      log.error(' Error loading template:', error);
      setAvailableTemplate(null);
    }
  };

  // Load template when semester/planungId is available (immediately after phase load)
  useEffect(() => {
    if (semester && planungId && !templateApplied) {
      loadAvailableTemplate();
    }
  }, [semester, planungId]);

  // Show template dialog immediately when template is available and planung is ready
  useEffect(() => {
    const moduleCount = geplantModule?.length || 0;
    // Show template dialog immediately when:
    // 1. Template is available
    // 2. Template hasn't been applied yet
    // 3. Dialog hasn't been shown yet
    // 4. No modules exist yet
    // 5. We have a valid planungId
    if (
      availableTemplate &&
      !templateApplied &&
      !templatePromptShown &&
      moduleCount === 0 &&
      planungId
    ) {
      log.debug('Showing template dialog immediately after phase load');
      setShowTemplateDialog(true);
      setTemplatePromptShown(true);
    }
  }, [availableTemplate, templateApplied, templatePromptShown, geplantModule, planungId]);

  // Template-Dialog wird jetzt sofort gezeigt (siehe useEffect oben)
  // Der alte Step-1-basierte Dialog wurde entfernt

  /**
   * Helper: Mitarbeiter-Zuordnung aus geplante_module extrahieren
   */
  const buildMitarbeiterMap = (modules: GeplantesModul[]): Map<number, number[]> => {
    const map = new Map<number, number[]>();
    modules.forEach(gm => {
      if (gm.mitarbeiter_ids && gm.mitarbeiter_ids.length > 0) {
        map.set(gm.modul_id, gm.mitarbeiter_ids);
      }
    });
    return map;
  };

  /**
   * Wendet Template auf aktuelle Planung an
   * @param clearExisting - Bestehende Module löschen?
   * @param goToSummary - Direkt zur Zusammenfassung navigieren (Schnellstart)?
   */
  const handleApplyTemplate = async (clearExisting: boolean = false, goToSummary: boolean = false) => {
    if (!availableTemplate || !planungId) return;

    setApplyingTemplate(true);
    try {
      log.debug(' Applying template:', availableTemplate.id, 'to planung:', planungId, 'goToSummary:', goToSummary);

      const response = await templateService.applyToPlanung(
        availableTemplate.id,
        planungId,
        clearExisting
      );

      if (response.success) {
        const { hinzugefuegt, uebersprungen } = response.data;

        // Reload planung to get ALL data from backend (including mitarbeiter)
        const planungResponse = await planungService.getPlanung(planungId);
        if (planungResponse.success && planungResponse.data) {
          const geplanteModule = planungResponse.data.geplante_module || [];

          // Update Wizard mit ALLEN Daten aus der Planung (inkl. Mitarbeiter-Map)
          setWizardData({
            geplantModule: geplanteModule,
            wunschFreieTage: planungResponse.data.wunsch_freie_tage || [],
            anmerkungen: planungResponse.data.anmerkungen || planungResponse.data.notizen || '',
            raumbedarf: planungResponse.data.raumbedarf || '',
            mitarbeiterZuordnung: buildMitarbeiterMap(geplanteModule),
          });

          log.debug(' Template data loaded:', {
            moduleCount: geplanteModule.length,
            wunschTageCount: planungResponse.data.wunsch_freie_tage?.length || 0,
            hasAnmerkungen: !!planungResponse.data.anmerkungen,
            mitarbeiterCount: buildMitarbeiterMap(geplanteModule).size
          });
        }

        setTemplateApplied(true);
        setShowTemplateDialog(false);

        // Zeige detaillierte Erfolgsmeldung
        const modulInfo = `${hinzugefuegt} Module`;
        const skipInfo = uebersprungen > 0 ? `, ${uebersprungen} übersprungen` : '';
        const wunschTageInfo = availableTemplate.wunsch_freie_tage?.length
          ? `, ${availableTemplate.wunsch_freie_tage.length} Wunsch-Tage`
          : '';
        const extraInfo = (availableTemplate.anmerkungen || availableTemplate.raumbedarf)
          ? ', Zusatzinfos'
          : '';

        if (goToSummary) {
          // Schnellstart: Direkt zur Zusammenfassung (Schritt 7)
          setCurrentStep(7);
          showToast(
            `Schnellstart: ${modulInfo}${skipInfo}${wunschTageInfo}${extraInfo} geladen. Prüfen & einreichen!`,
            'success'
          );
        } else {
          // Laden & Bearbeiten: Zum nächsten Schritt navigieren
          nextStep();
          showToast(
            `Template angewendet: ${modulInfo}${skipInfo}${wunschTageInfo}${extraInfo}`,
            'success'
          );
        }
      }
    } catch (error: unknown) {
      log.error(' Error applying template:', error);
      showToast(getErrorMessage(error, 'Fehler beim Anwenden des Templates'), 'error');
    } finally {
      setApplyingTemplate(false);
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
      log.debug(' 📤 Submitting planung:', planungId);
      
      const response = await planungService.submitPlanung(planungId!);

      if (response.success) {
        // Record submission in planning phase system if phase is active
        if (activePhase) {
          try {
            await recordNewSubmission(planungId!);
            log.debug(' 📊 Submission recorded in phase system');
          } catch (phaseError) {
            log.error(' Error recording submission in phase:', phaseError);
            // Continue even if phase recording fails - submission was successful
          }
        }

        showToast('Planung erfolgreich eingereicht', 'success');

        // Clear LocalStorage nach erfolgreichem Submit
        clearLocalStorage();
        log.debug(' 🗑️ LocalStorage cleared after successful submit');

        resetWizard();
        navigate('/semesterplanung');
      } else {
        // Handle API error response
        showToast(response.message || 'Fehler beim Einreichen', 'error');
        setError(response.message || 'Fehler beim Einreichen');
      }
    } catch (error: unknown) {
      log.error(' ❌ Error submitting planung:', error);
      showToast(getErrorMessage(error, 'Fehler beim Einreichen der Planung'), 'error');
      setError(getErrorMessage(error));
    } finally {
      setLoading(false);
    }
  };

  const handleStepUpdate = (data: Partial<WizardData>) => {
    log.debug(' 💾 Step update:', Object.keys(data));
    setWizardData(data);
    // Auto-Save läuft automatisch im Store
  };

  const handleStepNext = () => {
    log.debug(' ➡️ Next step');
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

      // Multiplikatoren werden in case 2 (StepModuleHinzufuegen) gesetzt

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
            onGoToStep={setCurrentStep}
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

        {/* Stats + Template Button */}
        <Box sx={{ mt: 2, p: 2, bgcolor: 'background.default', borderRadius: 1, display: 'flex', gap: 3, alignItems: 'center', flexWrap: 'wrap' }}>
          {(totalSWS > 0 || moduleCount > 0) && (
            <>
              <Typography variant="body2">
                <strong>Module:</strong> {moduleCount}
              </Typography>
              <Typography variant="body2">
                <strong>Gesamt SWS:</strong> {totalSWS.toFixed(1)} SWS
              </Typography>
            </>
          )}

          {/* Template Button - prominenter nach Schritt 1 */}
          {availableTemplate && planungId && !templateApplied && currentStep >= 1 && (
            <Box sx={{ ml: 'auto' }}>
              <Button
                variant="contained"
                color="secondary"
                size="medium"
                startIcon={getSemesterTyp() === 'winter' ? <AcUnit /> : <WbSunny />}
                endIcon={<ContentPaste />}
                onClick={() => setShowTemplateDialog(true)}
                disabled={applyingTemplate}
                sx={{
                  animation: currentStep === 1 ? 'pulse 2s infinite' : 'none',
                  '@keyframes pulse': {
                    '0%': { boxShadow: '0 0 0 0 rgba(156, 39, 176, 0.4)' },
                    '70%': { boxShadow: '0 0 0 10px rgba(156, 39, 176, 0)' },
                    '100%': { boxShadow: '0 0 0 0 rgba(156, 39, 176, 0)' },
                  }
                }}
              >
                Schnellstart: {availableTemplate.anzahl_module} Module laden
              </Button>
            </Box>
          )}

          {/* Template bereits angewendet - Schnellstart Option */}
          {templateApplied && (
            <Box sx={{ ml: 'auto', display: 'flex', alignItems: 'center', gap: 1, flexWrap: 'wrap' }}>
              <Chip
                icon={<CheckCircle />}
                label="Template geladen"
                color="success"
                size="small"
                variant="outlined"
              />
              {/* Schnellstart: Direkt zur Zusammenfassung */}
              {currentStep < 7 && (
                <Button
                  size="small"
                  variant="contained"
                  color="success"
                  onClick={() => setCurrentStep(7)}
                  startIcon={<CheckCircle />}
                >
                  Direkt zur Zusammenfassung
                </Button>
              )}
              <Button
                size="small"
                variant="text"
                onClick={() => navigate('/templates')}
              >
                Templates verwalten
              </Button>
            </Box>
          )}
        </Box>

        {/* Template angewendet - Info Banner */}
        {templateApplied && currentStep >= 1 && (
          <Alert severity="success" sx={{ mt: 2 }} icon={<CheckCircle />}>
            <Typography variant="body2">
              <strong>Template-Daten geladen!</strong> Alle importierten Daten (Module, Wunsch-Tage, Anmerkungen)
              können Sie in den folgenden Schritten frei bearbeiten, ergänzen oder löschen.
            </Typography>
          </Alert>
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

      {/* Template Dialog - Erweitert mit allen Details */}
      <Dialog
        open={showTemplateDialog}
        onClose={() => setShowTemplateDialog(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            {getSemesterTyp() === 'winter' ? <AcUnit color="primary" /> : <WbSunny sx={{ color: 'orange' }} />}
            <Typography variant="h6">Template laden - Schnellstart</Typography>
          </Box>
        </DialogTitle>
        <DialogContent>
          {availableTemplate && (
            <>
              <Alert severity="success" sx={{ mb: 2 }}>
                <Typography variant="body2">
                  <strong>{availableTemplate.name || templateService.formatSemesterTyp(availableTemplate.semester_typ)}</strong>
                </Typography>
                <Typography variant="body2">
                  Mit einem Klick werden alle gespeicherten Einstellungen geladen. Sie koennen danach alles noch anpassen.
                </Typography>
              </Alert>

              {availableTemplate.beschreibung && (
                <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                  {availableTemplate.beschreibung}
                </Typography>
              )}

              {/* Uebersicht der Template-Inhalte */}
              <Box sx={{ bgcolor: 'background.default', p: 2, borderRadius: 1, mb: 2 }}>
                <Typography variant="subtitle2" gutterBottom>
                  Template enthaelt:
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2 }}>
                  <Chip
                    icon={<CheckCircle />}
                    label={`${availableTemplate.anzahl_module} Module`}
                    color="primary"
                    variant="outlined"
                  />
                  {availableTemplate.wunsch_freie_tage && availableTemplate.wunsch_freie_tage.length > 0 && (
                    <Chip
                      icon={<CheckCircle />}
                      label={`${availableTemplate.wunsch_freie_tage.length} Wunsch-Tage`}
                      color="primary"
                      variant="outlined"
                    />
                  )}
                  {availableTemplate.anmerkungen && (
                    <Chip
                      icon={<CheckCircle />}
                      label="Anmerkungen"
                      color="primary"
                      variant="outlined"
                    />
                  )}
                  {availableTemplate.raumbedarf && (
                    <Chip
                      icon={<CheckCircle />}
                      label="Raumbedarf"
                      color="primary"
                      variant="outlined"
                    />
                  )}
                </Box>
              </Box>

              {/* Module Preview mit Details */}
              {availableTemplate.template_module && availableTemplate.template_module.length > 0 && (
                <Box sx={{ mb: 2 }}>
                  <Typography variant="subtitle2" gutterBottom>
                    Module mit Konfiguration:
                  </Typography>
                  <Box sx={{ maxHeight: 200, overflowY: 'auto', bgcolor: 'grey.50', p: 1, borderRadius: 1 }}>
                    {availableTemplate.template_module.map((tm) => {
                      const lehrformen: string[] = [];
                      if (tm.anzahl_vorlesungen > 0) lehrformen.push(`${tm.anzahl_vorlesungen}V`);
                      if (tm.anzahl_uebungen > 0) lehrformen.push(`${tm.anzahl_uebungen}Ue`);
                      if (tm.anzahl_praktika > 0) lehrformen.push(`${tm.anzahl_praktika}P`);
                      if (tm.anzahl_seminare > 0) lehrformen.push(`${tm.anzahl_seminare}S`);
                      const lehrformenStr = lehrformen.join('+') || '-';
                      const mitarbeiterCount = tm.mitarbeiter_ids?.length || 0;
                      const hasRaum = tm.raum_vorlesung || tm.raum_uebung || tm.raum_praktikum || tm.raum_seminar;

                      return (
                        <Box
                          key={tm.id}
                          sx={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: 1,
                            py: 0.5,
                            borderBottom: '1px solid',
                            borderColor: 'divider',
                            '&:last-child': { borderBottom: 'none' }
                          }}
                        >
                          <Chip
                            label={tm.modul?.kuerzel || `Modul ${tm.modul_id}`}
                            size="small"
                            color="primary"
                          />
                          <Typography variant="body2" sx={{ flex: 1 }}>
                            {tm.modul?.bezeichnung_de || ''}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {lehrformenStr}
                          </Typography>
                          {mitarbeiterCount > 0 && (
                            <Chip label={`${mitarbeiterCount} MA`} size="small" variant="outlined" />
                          )}
                          {hasRaum && (
                            <Chip label="Raum" size="small" variant="outlined" color="success" />
                          )}
                        </Box>
                      );
                    })}
                  </Box>
                </Box>
              )}

              {/* Wunsch-freie Tage */}
              {availableTemplate.wunsch_freie_tage && availableTemplate.wunsch_freie_tage.length > 0 && (
                <Box sx={{ mb: 2 }}>
                  <Typography variant="subtitle2" gutterBottom>
                    Wunsch-freie Tage:
                  </Typography>
                  <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                    {availableTemplate.wunsch_freie_tage.map((tag, idx) => (
                      <Chip
                        key={idx}
                        label={`${tag.wochentag} (${tag.zeitraum})`}
                        size="small"
                        variant="outlined"
                        color={tag.prioritaet === 'hoch' ? 'error' : tag.prioritaet === 'mittel' ? 'warning' : 'default'}
                      />
                    ))}
                  </Box>
                </Box>
              )}

              {moduleCount > 0 && (
                <Alert severity="warning" sx={{ mb: 2 }}>
                  <Typography variant="body2">
                    <strong>Hinweis:</strong> Sie haben bereits {moduleCount} Module in der Planung.
                    Bestehende Module werden nicht geloescht, nur neue werden hinzugefuegt.
                  </Typography>
                </Alert>
              )}
            </>
          )}
        </DialogContent>
        <DialogActions sx={{ p: 2, gap: 1, flexWrap: 'wrap', justifyContent: 'space-between' }}>
          <Button onClick={() => setShowTemplateDialog(false)} disabled={applyingTemplate}>
            Manuell eingeben
          </Button>
          <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
            {moduleCount > 0 && (
              <Button
                variant="outlined"
                color="warning"
                onClick={() => handleApplyTemplate(true, false)}
                disabled={applyingTemplate}
                size="small"
              >
                Alles ersetzen
              </Button>
            )}
            <Button
              variant="outlined"
              onClick={() => handleApplyTemplate(false, false)}
              disabled={applyingTemplate}
              startIcon={applyingTemplate ? <CircularProgress size={16} /> : <ContentPaste />}
            >
              {applyingTemplate ? 'Lade...' : 'Laden & Bearbeiten'}
            </Button>
            <Button
              variant="contained"
              color="success"
              size="large"
              onClick={() => handleApplyTemplate(false, true)}
              disabled={applyingTemplate}
              startIcon={applyingTemplate ? <CircularProgress size={16} /> : <CheckCircle />}
            >
              {applyingTemplate ? 'Lade...' : 'Schnellstart'}
            </Button>
          </Box>
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