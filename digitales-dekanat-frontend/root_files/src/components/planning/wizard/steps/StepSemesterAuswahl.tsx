import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  Chip,
  Button,
  Alert,
  CircularProgress,
  Card,
  CardContent,
  CardActionArea,
} from '@mui/material';
import {
  CalendarMonth,
  CheckCircle,
  Warning,
  NavigateNext,
  Schedule,
  DeleteForever,
} from '@mui/icons-material';
import semesterService from '../../../../services/semesterService';
import planungService from '../../../../services/planungService';
import planungPhaseService from '../../../../services/planungPhaseService';
import poService, { Pruefungsordnung } from '../../../../services/poService';
import { Semester } from '../../../../types/semester.types';
import { PlanungPhase } from '../../../../types/planungPhase.types';
import { useToastStore } from '../../../common/Toast';
import useAuthStore from '../../../../store/authStore';

interface StepProps {
  data: any;
  onUpdate: (data: any) => void;
  onNext: () => void;
  planungId?: number;
  setPlanungId: (id: number) => void;
}

/**
 * StepSemesterAuswahl - FIXED FOR 403 OWNERSHIP ERRORS
 * ======================================================
 * 
 * CRITICAL FIX:
 * - Prüft beim Laden ob Planung dem aktuellen User gehört
 * - Wenn 403 Fehler: Verwirft alte Planung und erstellt neue
 * - Verhindert Cross-User-Zugriff auf Planungen
 * 
 * PROBLEM: User versucht auf Planung zuzugreifen die einem anderen User gehört
 * LÖSUNG: 403 Fehler abfangen und neue Planung für aktuellen User erstellen
 */
const StepSemesterAuswahl: React.FC<StepProps> = ({ 
  data, 
  onUpdate, 
  onNext,
  planungId,
  setPlanungId
}) => {
  const showToast = useToastStore((state) => state.showToast);
  const user = useAuthStore((state) => state.user);
  
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [planningSemester, setPlanningSemester] = useState<Semester | null>(null);
  const [activePhase, setActivePhase] = useState<PlanungPhase | null>(null);
  const [allSemesters, setAllSemesters] = useState<Semester[]>([]);
  const [selectedSemesterId, setSelectedSemesterId] = useState<number | null>(
    data.semesterId || null
  );
  const [allPOs, setAllPOs] = useState<Pruefungsordnung[]>([]);
  const [selectedPoId, setSelectedPoId] = useState<number>(data.poId || 1); // Default PO 1

  useEffect(() => {
    let isMounted = true;

    const loadData = async () => {
      if (!isMounted) return;

      await loadSemesters();
      await loadActivePhase();
      await loadPOs();

      // CRITICAL FIX: Validate existing planungId ownership
      if (planungId && isMounted) {
        await validatePlanungOwnership(planungId);
      }
    };

    loadData();

    return () => {
      isMounted = false;
    };
  }, []);

  /**
   * CRITICAL FIX: Validate that planungId belongs to current user
   * If 403, discard old planung and let user create new one
   */
  const validatePlanungOwnership = async (id: number) => {
    try {
      console.log('[StepSemester] 🔍 Validating ownership of planung:', id);
      
      const response = await planungService.getPlanung(id);
      
      if (response.success && response.data) {
        // Check if planung belongs to current user
        if (response.data.benutzer && user && response.data.benutzer.id !== user.id) {
          console.error('[StepSemester] ⛔ Planung belongs to different user!');
          console.log('[StepSemester] Planung owner:', response.data.benutzer.username);
          console.log('[StepSemester] Current user:', user.username);
          
          showToast(
            `⚠️ Die geladene Planung (ID ${id}) gehört einem anderen User (${response.data.benutzer.username}).\n` +
            'Sie wurde verworfen. Bitte erstellen Sie eine neue Planung.',
            'warning'
          );
          
          // Reset planung state
          setPlanungId(0);
          onUpdate({
            planungId: null,
            planungLocked: false,
            planungStatus: null,
            isExistingPlanung: false,
            geplantModule: [],
            selectedModules: []
          });
          
          return false;
        }
        
        console.log('[StepSemester] ✅ Planung ownership validated');
        return true;
      }
    } catch (error: any) {
      // CRITICAL: Handle 403 Forbidden
      if (error.message && error.message.includes('403')) {
        console.error('[StepSemester] ⛔ 403 Forbidden - Planung belongs to different user!');
        
        showToast(
          '⛔ Keine Berechtigung für diese Planung.\n' +
          'Sie gehört einem anderen User. Bitte erstellen Sie eine neue Planung.',
          'error'
        );
        
        // Reset planung state
        setPlanungId(0);
        onUpdate({
          planungId: null,
          planungLocked: false,
          planungStatus: null,
          isExistingPlanung: false,
          geplantModule: [],
          selectedModules: []
        });
        
        return false;
      }
      
      console.error('[StepSemester] Error validating ownership:', error);
    }
    return false;
  };

  const loadActivePhase = async () => {
    try {
      console.log('[StepSemester] Loading active planning phase...');
      const phase = await planungPhaseService.getActivePhase();
      if (phase) {
        setActivePhase(phase);
        console.log('[StepSemester] Active phase loaded:', phase.name);
      } else {
        console.log('[StepSemester] No active planning phase');
      }
    } catch (error) {
      console.error('[StepSemester] Error loading active phase:', error);
    }
  };

  const loadPOs = async () => {
    try {
      console.log('[StepSemester] Loading Prüfungsordnungen...');
      const response = await poService.getAll();
      if (response.success && response.data) {
        setAllPOs(response.data);
        console.log('[StepSemester] POs loaded:', response.data.length);

        // Auto-select first PO if none selected yet
        if (!selectedPoId && response.data.length > 0) {
          setSelectedPoId(response.data[0].id);
        }
      }
    } catch (error) {
      console.error('[StepSemester] Error loading POs:', error);
      showToast('Fehler beim Laden der Prüfungsordnungen', 'error');
    }
  };

  const loadSemesters = async () => {
    setLoading(true);
    try {
      console.log('[StepSemester] Loading semesters...');

      // Load planning semester
      const planningRes = await semesterService.getPlanningSemester();
      if (planningRes.success && planningRes.data) {
        setPlanningSemester(planningRes.data);
        console.log('[StepSemester] Planning semester:', planningRes.data.bezeichnung);

        // Auto-select if only one planning semester and no planungId yet
        if (!selectedSemesterId && !planungId) {
          setSelectedSemesterId(planningRes.data.id);
        }
      }

      // Load all semesters for selection
      const allRes = await semesterService.getAllSemesters();
      if (allRes.success && allRes.data) {
        // Filter only semesters with planning phase open
        const plannableSemesters = allRes.data.filter(s => s.ist_planungsphase);
        setAllSemesters(plannableSemesters);
        console.log('[StepSemester] Plannable semesters:', plannableSemesters.length);
      }
    } catch (error) {
      console.error('[StepSemester] Error loading semesters:', error);
      showToast('Fehler beim Laden der Semester', 'error');
    } finally {
      setLoading(false);
    }
  };

  /**
   * CRITICAL FIX: Löscht die alte Planung und erstellt eine neue
   */
  const deleteAndCreateNew = async () => {
    if (!selectedSemesterId || !planungId) return;
    
    const semester = allSemesters.find(s => s.id === selectedSemesterId);
    if (!semester) return;

    const confirmed = window.confirm(
      '⚠️ WARNUNG: Sie sind dabei, die existierende Planung zu löschen!\n\n' +
      `Planung-ID: ${planungId}\n` +
      `Status: ${data.planungStatus}\n\n` +
      'Diese Aktion kann nicht rückgängig gemacht werden.\n\n' +
      'Möchten Sie fortfahren und eine neue Planung erstellen?'
    );

    if (!confirmed) return;

    setDeleting(true);
    try {
      console.log('[StepSemester] 🗑️ Deleting old planung:', planungId);
      
      // Delete with force flag
      const deleteResponse = await planungService.deletePlanung(planungId, true);
      
      if (!deleteResponse.success) {
        throw new Error('Fehler beim Löschen der alten Planung');
      }

      console.log('[StepSemester] ✅ Old planung deleted');
      showToast('Alte Planung erfolgreich gelöscht', 'success');
      
      // Reset state
      setPlanungId(0);
      onUpdate({ 
        planungId: null,
        planungLocked: false,
        planungStatus: null,
        isExistingPlanung: false,
        geplantModule: [],
        selectedModules: []
      });
      
      // Now create new planung
      await createNewPlanung(selectedSemesterId, semester);
      
    } catch (error: any) {
      console.error('[StepSemester] ❌ Error:', error);
      showToast(error.message || 'Fehler beim Löschen und Neuerstellen', 'error');
    } finally {
      setDeleting(false);
    }
  };

  /**
   * 
   */
  const createNewPlanung = async (semesterId: number, semester: Semester) => {
    setCreating(true);
    try {
      console.log('[StepSemester] 🚀 Creating NEW planung for semester:', semester.bezeichnung);
      console.log('[StepSemester] Current user:', user?.username);
      console.log('[StepSemester] Selected PO ID:', selectedPoId);

      const response = await planungService.createPlanung({
        semester_id: semesterId,
        po_id: selectedPoId  // Dynamically selected PO
      });
      
      if (response.success && response.data) {
        const newPlanungId = response.data.id;
        const wasCreated = response.data.created !== false;
        const planungStatus = response.data.status || 'entwurf';
        
        console.log('[StepSemester] Response:', {
          id: newPlanungId,
          created: wasCreated,
          status: planungStatus,
          owner: response.data.benutzer?.username
        });
        
        // CRITICAL CHECK: Validate ownership of returned planung
        if (response.data.benutzer && user && response.data.benutzer.id !== user.id) {
          console.error('[StepSemester] ⛔ Backend returned planung for different user!');
          
          showToast(
            '⛔ Fehler: Backend hat Planung für anderen User zurückgegeben.\n' +
            'Bitte kontaktieren Sie den Administrator.',
            'error'
          );
          return false;
        }
        
        // CRITICAL CHECK: Wenn existierende Planung zurückgegeben wird
        if (!wasCreated && (planungStatus === 'freigegeben' || planungStatus === 'eingereicht')) {
          console.error('[StepSemester] ⚠️ Backend returned LOCKED planung!');
          
          // Update store with locked flag
          setPlanungId(newPlanungId);
          onUpdate({ 
            semesterId: semesterId,
            semester: semester,
            planungId: newPlanungId,
            isExistingPlanung: true,
            planungStatus: planungStatus,
            planungLocked: true  // CRITICAL: Mark as locked
          });
          
          const statusText = planungStatus === 'freigegeben' ? 'freigegeben' : 'eingereicht';
          showToast(
            `⛔ Es existiert bereits eine Planung mit Status "${statusText}".\n` +
            'Sie müssen die alte Planung löschen, um eine neue zu erstellen.',
            'error'
          );
          return false;
        }
        
        // SUCCESS: New planung created or existing editable planung loaded
        setPlanungId(newPlanungId);
        onUpdate({ 
          semesterId: semesterId,
          semester: semester,
          planungId: newPlanungId,
          isExistingPlanung: !wasCreated,
          planungStatus: planungStatus,
          planungLocked: false  // Planung is editable
        });
        
        if (wasCreated) {
          showToast('✅ Neue Planung erfolgreich erstellt', 'success');
        } else {
          showToast('📝 Bestehende Planung im Entwurf-Status geladen', 'info');
        }
        return true;
      } else {
        throw new Error(response.message || 'Fehler beim Erstellen der Planung');
      }
    } catch (error: any) {
      console.error('[StepSemester] ❌ Error creating planung:', error);
      
      // CRITICAL: Handle 403 Forbidden
      if (error.message && error.message.includes('403')) {
        showToast(
          '⛔ 403 Fehler beim Erstellen der Planung.\n' +
          'Möglicherweise existiert bereits eine Planung die Ihnen nicht gehört.\n' +
          'Bitte wenden Sie sich an den Administrator.',
          'error'
        );
      } else {
        showToast(error.message || 'Fehler beim Erstellen der Planung', 'error');
      }
      return false;
    } finally {
      setCreating(false);
    }
  };

  const handleSemesterSelect = async (semesterId: number) => {
    const semester = allSemesters.find(s => s.id === semesterId);
    if (!semester) {
      console.error('[StepSemester] Semester not found:', semesterId);
      return;
    }
    
    console.log('[StepSemester] Semester selected:', semester.bezeichnung);
    setSelectedSemesterId(semesterId);
    
    // Always try to create/load planung when semester is selected
    await createNewPlanung(semesterId, semester);
  };

  const handleContinue = () => {
    // CRITICAL CHECK: Don't allow continue if planung is locked
    if (data.planungLocked) {
      showToast('⛔ Planung ist gesperrt. Bitte löschen Sie die alte Planung zuerst.', 'error');
      return;
    }
    
    if (selectedSemesterId && planungId) {
      console.log('[StepSemester] ✅ Continuing to next step. Planung ID:', planungId);
      console.log('[StepSemester] Current user:', user?.username);
      onNext();
    } else {
      showToast('Bitte wählen Sie ein Semester aus', 'warning');
    }
  };

  const formatDateRange = (start: string, end: string) => {
    const startDate = new Date(start).toLocaleDateString('de-DE');
    const endDate = new Date(end).toLocaleDateString('de-DE');
    return `${startDate} - ${endDate}`;
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  if (!activePhase && !planningSemester && allSemesters.length === 0) {
    return (
      <Alert severity="warning" sx={{ mt: 2 }}>
        <Typography variant="body1" gutterBottom>
          Keine Planungsphase aktiv
        </Typography>
        <Typography variant="body2">
          Derzeit ist keine Planungsphase geöffnet. Bitte warten Sie, bis der Dekan eine neue Planungsphase öffnet.
        </Typography>
      </Alert>
    );
  }

  return (
    <Box>
      <Typography variant="h6" gutterBottom>
        Wählen Sie das Semester für Ihre Planung
      </Typography>
      
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Nach der Auswahl wird automatisch eine neue Planung erstellt.
      </Typography>

      {user && (
        <Alert severity="info" sx={{ mb: 3 }}>
          <Typography variant="body2">
            👤 Eingeloggt als: <strong>{user.username}</strong> ({user.vorname} {user.nachname})
          </Typography>
        </Alert>
      )}

      {activePhase && (
        <Alert severity="success" sx={{ mb: 3 }}>
          <Typography variant="body2" fontWeight={600} gutterBottom>
            Aktive Planungsphase: {activePhase.name}
          </Typography>
          {activePhase.startdatum && (
            <Typography variant="body2">
              Start: {new Date(activePhase.startdatum).toLocaleDateString('de-DE')}
            </Typography>
          )}
          {activePhase.enddatum && (
            <Typography variant="body2">
              <strong>Deadline: {new Date(activePhase.enddatum).toLocaleDateString('de-DE')}</strong>
            </Typography>
          )}
          {planningSemester && (
            <Typography variant="body2" sx={{ mt: 1 }}>
              Semester: {planningSemester.bezeichnung}
            </Typography>
          )}
        </Alert>
      )}

      {/* CRITICAL: Warning for locked planung */}
      {planungId && data.planungLocked && (
        <Alert 
          severity="error" 
          sx={{ mb: 3 }}
          icon={<Warning />}
        >
          <Typography variant="body2" fontWeight={600} gutterBottom>
            ⛔ Planung ist gesperrt!
          </Typography>
          <Typography variant="body2" gutterBottom>
            Es existiert bereits eine Planung (ID: <strong>{planungId}</strong>) mit Status 
            "<strong>{data.planungStatus}</strong>", die nicht mehr bearbeitet werden kann.
          </Typography>
          <Typography variant="body2" gutterBottom>
            <strong>Sie müssen die alte Planung löschen, bevor Sie fortfahren können.</strong>
          </Typography>
          <Box sx={{ mt: 2 }}>
            <Button 
              variant="contained" 
              color="error"
              size="small"
              startIcon={deleting ? <CircularProgress size={16} /> : <DeleteForever />}
              onClick={deleteAndCreateNew}
              disabled={deleting || creating}
            >
              {deleting ? 'Lösche...' : 'Alte Planung löschen und neu starten'}
            </Button>
          </Box>
        </Alert>
      )}

      {/* Success message for editable planung */}
      {planungId && !data.planungLocked && (
        <Alert severity="success" sx={{ mb: 3 }}>
          <Typography variant="body2">
            ✅ Planung erstellt • ID: <strong>{planungId}</strong> • 
            Status: <strong>{data.planungStatus || 'entwurf'}</strong>
          </Typography>
        </Alert>
      )}

      {creating && (
        <Alert severity="info" sx={{ mb: 3 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <CircularProgress size={20} />
            <Typography variant="body2">
              Erstelle Planung...
            </Typography>
          </Box>
        </Alert>
      )}

      <Grid container spacing={2}>
        {allSemesters.map((semester) => (
          <Grid item xs={12} md={6} key={semester.id}>
            <Card 
              sx={{ 
                border: selectedSemesterId === semester.id ? 2 : 1,
                borderColor: selectedSemesterId === semester.id ? 'primary.main' : 'divider',
                position: 'relative',
              }}
            >
              <CardActionArea 
                onClick={() => handleSemesterSelect(semester.id)}
                disabled={creating || deleting}
              >
                <CardContent>
                  {selectedSemesterId === semester.id && (
                    <CheckCircle 
                      color="primary" 
                      sx={{ 
                        position: 'absolute', 
                        top: 8, 
                        right: 8,
                        fontSize: 24
                      }} 
                    />
                  )}
                  
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                    <CalendarMonth color="primary" />
                    <Typography variant="h6">
                      {semester.bezeichnung}
                    </Typography>
                  </Box>
                  
                  <Typography variant="body2" color="text.secondary" gutterBottom>
                    {semester.kuerzel}
                  </Typography>
                  
                  <Box sx={{ mt: 2, display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                    <Chip 
                      size="small"
                      icon={<Schedule />}
                      label={formatDateRange(semester.start_datum, semester.ende_datum)}
                    />
                    {semester.ist_aktiv && (
                      <Chip 
                        size="small"
                        label="Aktiv"
                        color="success"
                      />
                    )}
                    {semester.ist_planungsphase && (
                      <Chip 
                        size="small"
                        label="Planungsphase offen"
                        color="primary"
                      />
                    )}
                  </Box>

                  {semester.vorlesungsbeginn && semester.vorlesungsende && (
                    <Typography variant="caption" display="block" sx={{ mt: 1 }}>
                      Vorlesungen: {formatDateRange(semester.vorlesungsbeginn, semester.vorlesungsende)}
                    </Typography>
                  )}
                </CardContent>
              </CardActionArea>
            </Card>
          </Grid>
        ))}
      </Grid>

      {selectedSemesterId && (
        <Paper sx={{ p: 2, mt: 3, bgcolor: 'background.default' }}>
          <Typography variant="subtitle2" color="text.secondary">
            Ausgewähltes Semester:
          </Typography>
          <Typography variant="body1" fontWeight={500}>
            {allSemesters.find(s => s.id === selectedSemesterId)?.bezeichnung}
          </Typography>
        </Paper>
      )}

      <Box sx={{ mt: 3, display: 'flex', justifyContent: 'flex-end' }}>
        <Button
          variant="contained"
          endIcon={<NavigateNext />}
          onClick={handleContinue}
          disabled={!selectedSemesterId || !planungId || creating || deleting || data.planungLocked}
        >
          {creating ? 'Erstelle Planung...' : 
           deleting ? 'Lösche Planung...' : 
           data.planungLocked ? '⛔ Planung gesperrt' : 
           'Weiter'}
        </Button>
      </Box>
    </Box>
  );
};

export default StepSemesterAuswahl;