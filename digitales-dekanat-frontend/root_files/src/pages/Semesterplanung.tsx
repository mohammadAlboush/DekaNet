import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Button,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  LinearProgress,
  Alert,
  Tabs,
  Tab,
  Tooltip,
  AlertTitle,
} from '@mui/material';
import {
  Add,
  Edit,
  Send,
  Visibility,
  CheckCircle,
} from '@mui/icons-material';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('Semesterplanung');
import { useNavigate } from 'react-router-dom';
import useAuthStore from '../store/authStore';
import usePlanungPhaseStore from '../store/planungPhaseStore';
import planungService from '../services/planungService';
import semesterService from '../services/semesterService';
import { Semesterplanung } from '../types/planung.types';
import { Semester } from '../types/semester.types';

const SemesterplanungPage: React.FC = () => {
  const navigate = useNavigate();
  const { user } = useAuthStore();

  // Planning Phase Store
  const {
    activePhase,
    fetchActivePhase,
  } = usePlanungPhaseStore();

  const [loading, setLoading] = useState(false);
  const [tabValue, setTabValue] = useState(0);

  // State
  const [planungen, setPlanungen] = useState<Semesterplanung[]>([]);
  const [_activeSemester, setActiveSemester] = useState<Semester | null>(null);
  const [planningSemester, setPlanningSemester] = useState<Semester | null>(null);
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [_selectedPlanung, _setSelectedPlanung] = useState<Semesterplanung | null>(null);
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [_openDialog, _setOpenDialog] = useState(false);

  useEffect(() => {
    loadData();
    fetchActivePhase(); // Hole aktive Planungsphase
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      // Load semesters
      const [activeRes, planningRes] = await Promise.all([
        semesterService.getActiveSemester(),
        semesterService.getPlanningSemester(),
      ]);

      if (activeRes.success && activeRes.data) {
        setActiveSemester(activeRes.data);
      }
      if (planningRes.success && planningRes.data) {
        setPlanningSemester(planningRes.data);
      }

      // Load planungen based on role
      if (user?.rolle === 'dekan') {
        const res = await planungService.getAllPlanungen();
        if (res.success) setPlanungen(res.data || []);
      } else {
        const res = await planungService.getMeinePlanungen();
        if (res.success) setPlanungen(res.data || []);
      }
    } catch (error) {
      log.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCreatePlanung = () => {
    if (!activePhase) {
      alert('Keine Planungsphase aktiv!');
      return;
    }
    navigate('/semesterplanung/neu');
  };

  const handleSubmitPlanung = async (planungId: number) => {
    try {
      const res = await planungService.submitPlanung(planungId);
      if (res.success) {
        loadData();
      }
    } catch (error) {
      log.error('Error submitting planung:', error);
    }
  };

  const handleApprovePlanung = async (planungId: number) => {
    try {
      const res = await planungService.approvePlanung(planungId);
      if (res.success) {
        loadData();
      }
    } catch (error) {
      log.error('Error approving planung:', error);
    }
  };

  const getStatusChip = (status: string) => {
    const statusConfig = {
      entwurf: { label: 'Entwurf', color: 'default' as const },
      eingereicht: { label: 'Eingereicht', color: 'warning' as const },
      freigegeben: { label: 'Freigegeben', color: 'success' as const },
      abgelehnt: { label: 'Abgelehnt', color: 'error' as const },
    };

    const config = statusConfig[status as keyof typeof statusConfig] || statusConfig.entwurf;
    
    return <Chip label={config.label} color={config.color} size="small" />;
  };

  const filteredPlanungen = planungen.filter(p => {
    if (tabValue === 0) return true; // Alle
    if (tabValue === 1) return p.status === 'entwurf';
    if (tabValue === 2) return p.status === 'eingereicht';
    if (tabValue === 3) return p.status === 'freigegeben';
    return true;
  });

  return (
    <Container maxWidth="xl">
      {/* Header */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight={600} gutterBottom>
          Semesterplanung
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Verwalten Sie Ihre Lehrveranstaltungen für das kommende Semester
        </Typography>
      </Box>

      {/* Planning Phase Alert */}
      {activePhase ? (
        <Alert severity="success" sx={{ mb: 3 }}>
          <AlertTitle>Planungsphase "{activePhase.name}" ist geöffnet</AlertTitle>
          {planningSemester && `Für ${planningSemester.bezeichnung} | `}
          Gestartet am: {new Date(activePhase.startdatum).toLocaleDateString('de-DE')}
          {activePhase.enddatum && ` | Deadline: ${new Date(activePhase.enddatum).toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })}`}
        </Alert>
      ) : (
        <Alert severity="warning" sx={{ mb: 3 }}>
          <AlertTitle>Keine aktive Planungsphase</AlertTitle>
          Derzeit ist keine Planungsphase aktiv. Bitte warten Sie, bis der Dekan die nächste Phase startet.
        </Alert>
      )}

      {loading && <LinearProgress sx={{ mb: 2 }} />}

      {/* Actions */}
      <Box sx={{ mb: 3 }}>
        <Button
          variant="contained"
          startIcon={<Add />}
          onClick={handleCreatePlanung}
          disabled={!activePhase}
        >
          Neue Planung erstellen
        </Button>
      </Box>

      {/* Tabs */}
      <Paper sx={{ mb: 3 }}>
        <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)}>
          <Tab label={`Alle (${planungen.length})`} />
          <Tab label={`Entwurf (${planungen.filter(p => p.status === 'entwurf').length})`} />
          <Tab label={`Eingereicht (${planungen.filter(p => p.status === 'eingereicht').length})`} />
          <Tab label={`Freigegeben (${planungen.filter(p => p.status === 'freigegeben').length})`} />
        </Tabs>
      </Paper>

      {/* Table */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Semester</TableCell>
              {user?.rolle === 'dekan' && <TableCell>Dozent</TableCell>}
              <TableCell>Status</TableCell>
              <TableCell>Module</TableCell>
              <TableCell align="right">Gesamt SWS</TableCell>
              <TableCell>Eingereicht am</TableCell>
              <TableCell align="center">Aktionen</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredPlanungen.map((planung) => (
              <TableRow key={planung.id}>
                <TableCell>{planung.semester?.kuerzel || '-'}</TableCell>
                {user?.rolle === 'dekan' && (
                  <TableCell>{planung.benutzer?.name_komplett || '-'}</TableCell>
                )}
                <TableCell>{getStatusChip(planung.status)}</TableCell>
                <TableCell>{planung.geplante_module?.length || 0}</TableCell>
                <TableCell align="right">{planung.gesamt_sws.toFixed(1)}</TableCell>
                <TableCell>
                  {planung.eingereicht_am 
                    ? new Date(planung.eingereicht_am).toLocaleDateString('de-DE')
                    : '-'
                  }
                </TableCell>
                <TableCell align="center">
                  <Tooltip title="Anzeigen">
                    <IconButton 
                      size="small"
                      onClick={() => navigate(`/semesterplanung/${planung.id}`)}
                    >
                      <Visibility />
                    </IconButton>
                  </Tooltip>
                  
                  {planung.status === 'entwurf' && (
                    <>
                      <Tooltip title="Bearbeiten">
                        <IconButton 
                          size="small"
                          onClick={() => navigate(`/semesterplanung/${planung.id}/edit`)}
                        >
                          <Edit />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Einreichen">
                        <IconButton 
                          size="small"
                          color="primary"
                          onClick={() => handleSubmitPlanung(planung.id)}
                        >
                          <Send />
                        </IconButton>
                      </Tooltip>
                    </>
                  )}
                  
                  {user?.rolle === 'dekan' && planung.status === 'eingereicht' && (
                    <Tooltip title="Freigeben">
                      <IconButton 
                        size="small"
                        color="success"
                        onClick={() => handleApprovePlanung(planung.id)}
                      >
                        <CheckCircle />
                      </IconButton>
                    </Tooltip>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Container>
  );
};

export default SemesterplanungPage;