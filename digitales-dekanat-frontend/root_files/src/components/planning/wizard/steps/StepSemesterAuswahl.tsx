import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Alert,
  AlertTitle,
  Card,
  CardContent,
  CircularProgress,
  Button,
  Chip,
} from '@mui/material';
import { CheckCircle, CalendarMonth, Schedule } from '@mui/icons-material';
import { format } from 'date-fns';
import { de } from 'date-fns/locale';
import planungPhaseService from '../../../../services/planungPhaseService';
import planungService from '../../../../services/planungService';
import useAuthStore from '../../../../store/authStore';
import { useToastStore } from '../../../common/Toast';
import { createContextLogger } from '../../../../utils/logger';
import { getErrorMessage } from '../../../../utils/errorUtils';
import { StepSemesterAuswahlProps } from '../../../../types/StepProps.types';
import { PlanungPhase } from '../../../../types/planungPhase.types';
import { Semester } from '../../../../types/semester.types';

const log = createContextLogger('StepSemesterAuswahl');

/**
 * StepSemesterAuswahl - VEREINFACHTE VERSION
 * ==========================================
 *
 * Diese Version lädt automatisch die aktive Planungsphase und das zugehörige Semester.
 * Der Professor muss kein Semester mehr manuell auswählen - alles wird automatisch
 * basierend auf der vom Dekan gestarteten Phase gesetzt.
 *
 * Template-Laden wurde in WizardView.tsx konsolidiert (Schnellstart-Dialog).
 */
const StepSemesterAuswahl: React.FC<StepSemesterAuswahlProps> = ({
  data,
  onUpdate,
  onNext,
  planungId,
  setPlanungId
}) => {
  const showToast = useToastStore((state) => state.showToast);
  const user = useAuthStore((state) => state.user);

  const [loading, setLoading] = useState(true);
  const [activePhase, setActivePhase] = useState<PlanungPhase | null>(null);
  const [semester, setSemester] = useState<Semester | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadActivePhaseAndCreatePlanung();
  }, []);

  /**
   * Lädt aktive Phase + Semester und erstellt automatisch eine Planung
   */
  const loadActivePhaseAndCreatePlanung = async () => {
    setLoading(true);
    setError(null);

    try {
      // 1. Aktive Phase mit Semester laden
      log.debug(' Loading active phase with semester...');
      const response = await planungPhaseService.getActivePhasWithSemester();

      if (!response.success || !response.phase || !response.semester) {
        setError('Keine aktive Planungsphase vorhanden. Bitte wenden Sie sich an das Dekanat.');
        setLoading(false);
        return;
      }

      log.debug(' Active phase loaded:', response.phase.name);
      log.debug(' Semester:', response.semester.bezeichnung);

      setActivePhase(response.phase);
      setSemester(response.semester);

      // 2. Planung erstellen oder laden
      log.debug(' Creating/loading planung for semester:', response.semester.id);
      const planungResponse = await planungService.createPlanung({
        semester_id: response.semester.id,
        po_id: 1 // Default PO
      });

      if (!planungResponse.success || !planungResponse.data) {
        setError('Fehler beim Erstellen der Planung.');
        setLoading(false);
        return;
      }

      const newPlanungId = planungResponse.data.id;
      const planungStatus = planungResponse.data.status || 'entwurf';
      const wasCreated = planungResponse.data.created !== false;

      log.debug(' Planung response:', {
        id: newPlanungId,
        status: planungStatus,
        created: wasCreated
      });

      // Prüfe ob Planung gesperrt ist
      const isLocked = planungStatus === 'freigegeben' || planungStatus === 'eingereicht';

      // 3. Wizard-Daten aktualisieren
      setPlanungId(newPlanungId);
      onUpdate({
        semesterId: response.semester.id,
        semester: response.semester,
        planungId: newPlanungId,
        planungStatus: planungStatus,
        isExistingPlanung: !wasCreated,
        planungLocked: isLocked
      });

      if (wasCreated) {
        showToast('Neue Planung erfolgreich erstellt', 'success');
      } else if (!isLocked) {
        showToast('Bestehende Planung im Entwurf-Status geladen', 'info');
      }

      // Auto-weiter zum nächsten Schritt (Semester wird automatisch vom Dekan gesetzt)
      if (!isLocked) {
        log.debug('Auto-advancing to next step (semester auto-selected from phase)');
        setTimeout(() => onNext(), 500);
      }

    } catch (err: unknown) {
      log.error(' Error loading phase:', err);
      setError(getErrorMessage(err, 'Fehler beim Laden der Planungsphase'));
    } finally {
      setLoading(false);
    }
  };

  // Loading State
  if (loading) {
    return (
      <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', py: 6 }}>
        <CircularProgress size={48} />
        <Typography sx={{ mt: 2 }} color="text.secondary">
          Lade aktive Planungsphase...
        </Typography>
      </Box>
    );
  }

  // Error State
  if (error) {
    return (
      <Alert severity="error" sx={{ my: 2 }}>
        <AlertTitle>Keine Planungsphase verfügbar</AlertTitle>
        {error}
      </Alert>
    );
  }

  // Locked Planung State
  if (data.planungLocked) {
    return (
      <Box>
        <Alert severity="warning" sx={{ mb: 3 }}>
          <AlertTitle>Planung bereits eingereicht</AlertTitle>
          <Typography variant="body2">
            Sie haben bereits eine Planung für das Semester <strong>{semester?.bezeichnung}</strong> eingereicht
            (Status: <strong>{data.planungStatus}</strong>).
          </Typography>
          <Typography variant="body2" sx={{ mt: 1 }}>
            Bitte wenden Sie sich an das Dekanat, wenn Sie Änderungen vornehmen möchten.
          </Typography>
        </Alert>

        {/* Phase Info */}
        <Card variant="outlined" sx={{ mb: 3 }}>
          <CardContent>
            <Typography variant="subtitle2" color="text.secondary" gutterBottom>
              Aktive Planungsphase
            </Typography>
            <Typography variant="h6">{activePhase?.name}</Typography>
            {activePhase?.enddatum && (
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                <Schedule fontSize="small" color="action" />
                <Typography variant="body2" color="text.secondary">
                  Deadline: {format(new Date(activePhase.enddatum), 'dd.MM.yyyy HH:mm', { locale: de })}
                </Typography>
              </Box>
            )}
          </CardContent>
        </Card>
      </Box>
    );
  }

  // Success State - Phase und Semester geladen
  return (
    <Box>
      {/* User Info */}
      {user && (
        <Alert severity="info" sx={{ mb: 3 }} icon={false}>
          <Typography variant="body2">
            Eingeloggt als: <strong>{user.vorname} {user.nachname}</strong> ({user.username})
          </Typography>
        </Alert>
      )}

      {/* Phase Info */}
      <Alert severity="success" sx={{ mb: 3 }}>
        <AlertTitle>Aktive Planungsphase</AlertTitle>
        <Typography variant="body1" fontWeight={600}>
          {activePhase?.name}
        </Typography>
        {activePhase?.enddatum && (
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
            <Schedule fontSize="small" />
            <Typography variant="body2">
              Deadline: {format(new Date(activePhase.enddatum), 'dd.MM.yyyy HH:mm', { locale: de })}
            </Typography>
          </Box>
        )}
      </Alert>

      {/* Semester Card */}
      <Card
        variant="outlined"
        sx={{
          mb: 3,
          borderColor: 'primary.main',
          borderWidth: 2,
          bgcolor: 'primary.50'
        }}
      >
        <CardContent>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <CheckCircle color="primary" fontSize="large" />
            <Box sx={{ flex: 1 }}>
              <Typography variant="h6">{semester?.bezeichnung}</Typography>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 0.5 }}>
                <CalendarMonth fontSize="small" color="action" />
                <Typography variant="body2" color="text.secondary">
                  {semester?.start_datum && semester?.ende_datum && (
                    <>
                      {format(new Date(semester.start_datum), 'dd.MM.yyyy', { locale: de })} -{' '}
                      {format(new Date(semester.ende_datum), 'dd.MM.yyyy', { locale: de })}
                    </>
                  )}
                </Typography>
              </Box>
            </Box>
            <Chip label="Ausgewählt" color="primary" />
          </Box>
        </CardContent>
      </Card>

      {/* Planung Info */}
      {planungId && (
        <Alert severity="success" sx={{ mb: 3 }} icon={<CheckCircle />}>
          <Typography variant="body2">
            Planung erstellt - ID: <strong>{planungId}</strong> -
            Status: <strong>{data.planungStatus || 'entwurf'}</strong>
          </Typography>
        </Alert>
      )}

      {/* Weiter Button */}
      <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 4 }}>
        <Button
          variant="contained"
          size="large"
          onClick={onNext}
          disabled={!planungId}
        >
          Weiter zur Modul-Auswahl
        </Button>
      </Box>
    </Box>
  );
};

export default StepSemesterAuswahl;
