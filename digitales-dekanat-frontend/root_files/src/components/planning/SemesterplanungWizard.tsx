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
} from '@mui/material';
import {
  Save,
  CheckCircle,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';

// Step Components - korrekte Pfade
import StepSemesterAuswahl from '../../components/planning/wizard/steps/StepSemesterAuswahl';
import StepModuleAuswahl from '../../components/planning/wizard/steps/StepModuleAuswahl';
import StepModuleHinzufuegen from '../../components/planning/wizard/steps/Stepmodulehinzufuegen';
import StepMitarbeiterZuordnen from '../../components/planning/wizard/steps/StepMitarbeiterZuordnen';
// ❌ StepMultiplikatoren ENTFERNT
import StepZusatzInfos from '../../components/planning/wizard/steps/StepZusatzInfos';
import StepWunschFreieTage from '../../components/planning/wizard/steps/StepWunschFreieTage';
import StepZusammenfassung from '../../components/planning/wizard/steps/StepZusammenfassung';

// Services & Types
import planungService from '../../services/planungService';
import { Semesterplanung, GeplantesModul } from '../../types/planung.types';
import { Semester } from '../../types/semester.types';
import { Modul } from '../../types/modul.types';
import { useToastStore } from '../../components/common/Toast';
import { createContextLogger } from '../../utils/logger';

const log = createContextLogger('SemesterplanungWizard');

interface WizardData {
  semesterId: number | null;
  semester: Semester | null;
  selectedModules: Modul[];
  geplantModule: GeplantesModul[];
  mitarbeiterZuordnung: Map<number, number[]>;
  wunschFreieTage: any[];
  anmerkungen: string;
  raumbedarf: string;
  planungId: number | null;
}

// ✅ ANGEPASST: Schritt 5 (Multiplikatoren) entfernt - jetzt nur noch 7 Schritte
const STEPS = [
  { label: 'Semester auswählen', icon: '📅' },
  { label: 'Module auswählen', icon: '📚' },
  { label: 'Module hinzufügen', icon: '➕' },
  { label: 'Mitarbeiter zuordnen', icon: '👥' },
  // ❌ ENTFERNT: { label: 'Multiplikatoren setzen', icon: '🔢' },
  { label: 'Zusätzliche Infos', icon: '📝' },
  { label: 'Wunsch-freie Tage', icon: '📆' },
  { label: 'Zusammenfassung & Einreichen', icon: '✅' },
];

const SemesterplanungWizard: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams();
  const showToast = useToastStore((state) => state.showToast);
  
  const [activeStep, setActiveStep] = useState(0);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [planung, setPlanung] = useState<Semesterplanung | null>(null);
  const [wizardData, setWizardData] = useState<WizardData>({
    semesterId: null,
    semester: null,
    selectedModules: [],
    geplantModule: [],
    mitarbeiterZuordnung: new Map(),
    wunschFreieTage: [],
    anmerkungen: '',
    raumbedarf: '',
    planungId: null,
  });

  // Load existing planung if editing
  useEffect(() => {
    if (id) {
      loadPlanung();
    }
  }, [id]);

  const loadPlanung = async () => {
    if (!id) return;
    
    setLoading(true);
    try {
      const response = await planungService.getPlanung(parseInt(id));
      if (response.success && response.data) {
        setPlanung(response.data);
        // Populate wizard data from existing planung
        setWizardData({
          semesterId: response.data.semester_id,
          semester: response.data.semester ?? null,  // ✅ Convert undefined to null
          selectedModules: [],
          geplantModule: response.data.geplante_module || [],
          mitarbeiterZuordnung: new Map(),
          wunschFreieTage: response.data.wunsch_freie_tage || [],
          anmerkungen: response.data.notizen || '',
          raumbedarf: '',
          planungId: response.data.id,
        });
      }
    } catch (error) {
      showToast('Fehler beim Laden der Planung', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleNext = () => {
    setActiveStep((prev) => prev + 1);
  };

  const handleBack = () => {
    setActiveStep((prev) => prev - 1);
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      // Save current state as draft
      if (planung) {
        // Update existing
        await planungService.updatePlanung(planung.id, {
          notizen: wizardData.anmerkungen,
        });
      } else {
        // Create new (po_id is not needed at creation, only when adding modules)
        const response = await planungService.createPlanung({
          semester_id: wizardData.semesterId!,
          notizen: wizardData.anmerkungen,
        });
        if (response.success && response.data) {
          const newPlanung = response.data;
          setPlanung(newPlanung);
          setWizardData(prev => ({ ...prev, planungId: newPlanung.id }));
        }
      }
      showToast('Zwischenstand gespeichert', 'success');
    } catch (error) {
      showToast('Fehler beim Speichern', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleSubmit = async () => {
    if (!planung) {
      showToast('Bitte speichern Sie zuerst die Planung', 'warning');
      return;
    }

    if (window.confirm('Möchten Sie die Planung wirklich einreichen? Nach dem Einreichen können keine Änderungen mehr vorgenommen werden.')) {
      setLoading(true);
      try {
        // ✅ WICHTIG: Erst alle Zusatzinfos speichern (anmerkungen, raumbedarf, wunschFreieTage, etc.)
        log.debug(' Saving zusatzinfos before submit...');
        log.debug(' WizardData:', {
          anmerkungen: wizardData.anmerkungen,
          raumbedarf: wizardData.raumbedarf,
          roomRequirements: (wizardData as any).roomRequirements,
          specialRequests: (wizardData as any).specialRequests,
          wunschFreieTage: wizardData.wunschFreieTage,
        });

        await planungService.updateZusatzinfos(planung.id, {
          anmerkungen: wizardData.anmerkungen || undefined,
          raumbedarf: wizardData.raumbedarf || undefined,
          room_requirements: (wizardData as any).roomRequirements || undefined,
          special_requests: (wizardData as any).specialRequests || undefined,
          wunsch_freie_tage: wizardData.wunschFreieTage?.map(tag => ({
            wochentag: tag.wochentag || 'montag',
            zeitraum: tag.zeitraum || 'ganztags',
            prioritaet: tag.prioritaet || 'mittel',
            grund: tag.grund || '',
          })) || [],
        });
        log.debug(' Zusatzinfos saved successfully');

        // Dann einreichen
        await planungService.submitPlanung(planung.id);
        showToast('Planung erfolgreich eingereicht', 'success');
        navigate('/semesterplanung');
      } catch (error) {
        log.error(' Error during submit:', error);
        showToast('Fehler beim Einreichen', 'error');
      } finally {
        setLoading(false);
      }
    }
  };

  const updateWizardData = (data: Partial<WizardData>) => {
    setWizardData((prev) => ({ ...prev, ...data }));
  };

  const setPlanungId = (id: number) => {
    setWizardData(prev => ({ ...prev, planungId: id }));
    if (planung) {
      setPlanung({ ...planung, id });
    }
  };

  /**
   * ✅ ANGEPASST: Step Content - Schritt 5 entfernt, alle nachfolgenden Steps um 1 verschoben
   */
  const getStepContent = (step: number) => {
    switch (step) {
      case 0: // Semester auswählen
        return (
          <StepSemesterAuswahl
            data={wizardData}
            onUpdate={updateWizardData}
            onNext={handleNext}
            planungId={wizardData.planungId || undefined}
            setPlanungId={setPlanungId}
          />
        );
      case 1: // Module auswählen
        return (
          <StepModuleAuswahl
            data={wizardData}
            onUpdate={updateWizardData}
            onNext={handleNext}
            onBack={handleBack}
          />
        );
      case 2: // Module hinzufügen
        return (
          <StepModuleHinzufuegen
            data={wizardData}
            onUpdate={updateWizardData}
            onNext={handleNext}
            onBack={handleBack}
            planungId={wizardData.planungId || undefined}
          />
        );
      case 3: // Mitarbeiter zuordnen
        return (
          <StepMitarbeiterZuordnen
            data={wizardData}
            onUpdate={updateWizardData}
            onNext={handleNext}
            onBack={handleBack}
          />
        );
      // ❌ ENTFERNT: case 4 (Multiplikatoren)
      case 4: // Zusätzliche Infos (war vorher case 5)
        return (
          <StepZusatzInfos
            data={wizardData}
            onUpdate={updateWizardData}
            onNext={handleNext}
            onBack={handleBack}
          />
        );
      case 5: // Wunsch-freie Tage (war vorher case 6)
        return (
          <StepWunschFreieTage
            data={wizardData}
            onUpdate={updateWizardData}
            onNext={handleNext}
            onBack={handleBack}
            planungId={wizardData.planungId || undefined}
          />
        );
      case 6: // Zusammenfassung (war vorher case 7)
        return (
          <StepZusammenfassung
            data={wizardData}
            onBack={handleBack}
            onSubmit={handleSubmit}
            planungId={wizardData.planungId || undefined}
          />
        );
      default:
        return null;
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Container maxWidth="lg">
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h4" gutterBottom>
          {id ? 'Semesterplanung bearbeiten' : 'Neue Semesterplanung'}
        </Typography>
        
        {planung?.status === 'entwurf' && (
          <Alert severity="info" sx={{ mb: 2 }}>
            Diese Planung befindet sich im Entwurfsmodus. Sie können jederzeit Änderungen vornehmen.
          </Alert>
        )}

        <Box sx={{ display: 'flex', justifyContent: 'flex-end', mb: 2 }}>
          <Button
            variant="outlined"
            startIcon={<Save />}
            onClick={handleSave}
            disabled={saving || !wizardData.semesterId}
          >
            {saving ? 'Speichert...' : 'Zwischenspeichern'}
          </Button>
        </Box>

        <Stepper activeStep={activeStep} orientation="vertical">
          {STEPS.map((step, index) => (
            <Step key={step.label}>
              <StepLabel
                optional={
                  index === STEPS.length - 1 ? (
                    <Typography variant="caption">Letzter Schritt</Typography>
                  ) : null
                }
              >
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <span>{step.icon}</span>
                  {step.label}
                </Box>
              </StepLabel>
              <StepContent>
                <Box sx={{ mb: 2 }}>
                  {getStepContent(index)}
                </Box>
              </StepContent>
            </Step>
          ))}
        </Stepper>

        {activeStep === STEPS.length && (
          <Paper square elevation={0} sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              <CheckCircle color="success" sx={{ mr: 1, verticalAlign: 'middle' }} />
              Alle Schritte abgeschlossen!
            </Typography>
            <Typography sx={{ mt: 2, mb: 1 }}>
              Ihre Semesterplanung wurde erfolgreich erstellt und eingereicht.
            </Typography>
            <Button
              variant="contained"
              onClick={() => navigate('/semesterplanung')}
              sx={{ mt: 1, mr: 1 }}
            >
              Zur Übersicht
            </Button>
          </Paper>
        )}
      </Paper>
    </Container>
  );
};

export default SemesterplanungWizard;