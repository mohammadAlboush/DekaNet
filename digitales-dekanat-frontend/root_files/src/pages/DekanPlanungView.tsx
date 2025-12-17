import React, { useState, useEffect } from 'react';
import {
  Container,
  Grid,
  Paper,
  Typography,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Tabs,
  Tab,
  Alert,
  Tooltip,
  LinearProgress,
  Divider,
  Badge,
} from '@mui/material';
import {
  Visibility,
  CheckCircle,
  Cancel,
  ArrowBack,
  ExpandMore,
  ExpandLess,
  School,
  Person,
  CalendarMonth,
  Notes,
  Settings,
  History,
  Archive,
  Room,
} from '@mui/icons-material';
import { useNavigate, useSearchParams } from 'react-router-dom';
import planungService from '../services/planungService';
import semesterService from '../services/semesterService';
import dozentService from '../services/dozentService';
import { useToastStore } from '../components/common/Toast';
import { Semesterplanung } from '../types/planung.types';
import { Semester } from '../types/semester.types';
import usePlanungPhaseStore from '../store/planungPhaseStore';
import PlanungsphasenManager from '../components/planning/PlanungsphasenManager';
import PhaseHistoryDialog from '../components/planning/PhaseHistoryDialog';
import ArchivedPlanungsList from '../components/planning/ArchivedPlanungsList';

/**
 * Dekan Planung View - PRODUCTION READY
 * ======================================
 * Spezielle View für Dekane zum Review von eingereichten Planungen
 * 
 * FEATURES:
 * - Tabs nach Status (Eingereicht, Freigegeben, Abgelehnt, Alle)
 * - Approve/Reject Actions
 * - Detail-View mit Modulen
 * - Ablehnungsgrund-Dialog
 */

const DekanPlanungView: React.FC = () => {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const showToast = useToastStore((state) => state.showToast);

  const [loading, setLoading] = useState(false);
  const [tabValue, setTabValue] = useState(0);
  const [planungen, setPlanungen] = useState<Semesterplanung[]>([]);
  const [semester, setSemester] = useState<Semester | null>(null);
  const [dozenten, setDozenten] = useState<any[]>([]);

  // Planning Phase Store
  const {
    activePhase,
    fetchActivePhase,
  } = usePlanungPhaseStore();

  // Reject Dialog
  const [rejectDialog, setRejectDialog] = useState(false);
  const [selectedPlanung, setSelectedPlanung] = useState<Semesterplanung | null>(null);
  const [ablehnungsgrund, setAblehnungsgrund] = useState('');

  // Expandable rows
  const [expandedRows, setExpandedRows] = useState<Set<number>>(new Set());

  // New Dialog States for Planning Phase Features
  const [showPhaseManager, setShowPhaseManager] = useState(false);
  const [showPhaseHistory, setShowPhaseHistory] = useState(false);
  const [showArchive, setShowArchive] = useState(false);

  useEffect(() => {
    loadData();
    fetchActivePhase(); // Load active planning phase

    // Set tab from URL parameter
    const status = searchParams.get('status');
    if (status === 'eingereicht') setTabValue(0);
    else if (status === 'freigegeben') setTabValue(1);
    else if (status === 'abgelehnt') setTabValue(2);
    else setTabValue(3);
  }, [searchParams]);

  const loadData = async () => {
    setLoading(true);
    try {
      // Load dozenten for name mapping
      const dozentenRes = await dozentService.getAllDozenten();
      if (dozentenRes.success && dozentenRes.data) {
        setDozenten(dozentenRes.data);
        console.log('[DekanPlanungView] Dozenten loaded:', dozentenRes.data.length);
      }

      // Load planning semester
      const semesterRes = await semesterService.getPlanningSemester();
      if (semesterRes.success && semesterRes.data) {
        setSemester(semesterRes.data);

        // Load planungen - ONLY for active planning phase
        const planungenRes = await planungService.getAllPlanungenDekan({
          semester_id: semesterRes.data.id,
          nur_aktive_phase: true  // ✅ KRITISCH: Nur Planungen der aktiven Phase laden
        });

        if (planungenRes.success && planungenRes.data) {
          setPlanungen(planungenRes.data);
          console.log('[DekanPlanungView] Planungen loaded (nur aktive Phase):', planungenRes.data.length);

          // Log Phase-Info
          if (activePhase) {
            console.log('[DekanPlanungView] Active phase:', activePhase.name);
            const withPhase = planungenRes.data.filter(p => p.planungsphase?.id === activePhase.id).length;
            console.log('[DekanPlanungView] Planungen in aktiver Phase:', withPhase);
          } else {
            console.log('[DekanPlanungView] WARNUNG: Keine aktive Phase, zeige trotzdem Planungen');
          }
        }
      }
    } catch (error) {
      console.error('[DekanPlanungView] Error loading data:', error);
      showToast('Fehler beim Laden der Planungen', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleApprove = async (planungId: number) => {
    if (!window.confirm('Möchten Sie diese Planung wirklich freigeben?')) {
      return;
    }

    try {
      setLoading(true);
      const response = await planungService.approvePlanung(planungId);

      if (response.success) {
        showToast('Planung erfolgreich freigegeben', 'success');
        loadData(); // Reload data
      } else {
        showToast(response.message || 'Fehler beim Freigeben', 'error');
      }
    } catch (error: any) {
      console.error('[DekanPlanungView] Error approving:', error);
      showToast(error.message || 'Fehler beim Freigeben', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleRejectClick = (planung: Semesterplanung) => {
    setSelectedPlanung(planung);
    setAblehnungsgrund('');
    setRejectDialog(true);
  };

  const handleRejectConfirm = async () => {
    if (!selectedPlanung) return;

    if (!ablehnungsgrund.trim()) {
      showToast('Bitte geben Sie einen Ablehnungsgrund an', 'warning');
      return;
    }

    try {
      setLoading(true);
      const response = await planungService.rejectPlanung(
        selectedPlanung.id,
        ablehnungsgrund
      );
      
      if (response.success) {
        showToast('Planung abgelehnt', 'success');
        setRejectDialog(false);
        setSelectedPlanung(null);
        setAblehnungsgrund('');
        loadData(); // Reload data
      } else {
        showToast(response.message || 'Fehler beim Ablehnen', 'error');
      }
    } catch (error: any) {
      console.error('[DekanPlanungView] Error rejecting:', error);
      showToast(error.message || 'Fehler beim Ablehnen', 'error');
    } finally {
      setLoading(false);
    }
  };

  const getStatusChip = (status: string) => {
    const config: Record<string, { label: string; color: 'default' | 'warning' | 'success' | 'error' }> = {
      entwurf: { label: 'Entwurf', color: 'default' },
      eingereicht: { label: 'Eingereicht', color: 'warning' },
      freigegeben: { label: 'Freigegeben', color: 'success' },
      abgelehnt: { label: 'Abgelehnt', color: 'error' },
    };

    const { label, color } = config[status] || config.entwurf;

    return <Chip label={label} color={color} size="small" />;
  };

  const toggleRowExpanded = (planungId: number) => {
    const newExpanded = new Set(expandedRows);
    if (newExpanded.has(planungId)) {
      newExpanded.delete(planungId);
    } else {
      newExpanded.add(planungId);
    }
    setExpandedRows(newExpanded);
  };

  const calculateGesamtECTS = (planung: Semesterplanung): number => {
    if (!planung.geplante_module) return 0;
    return planung.geplante_module.reduce((sum, gm) => {
      return sum + (gm.modul?.leistungspunkte || 0);
    }, 0);
  };

  const getMitarbeiterNamen = (mitarbeiterIds: number[]): string[] => {
    if (!mitarbeiterIds || mitarbeiterIds.length === 0) return [];
    return mitarbeiterIds
      .map(id => {
        const dozent = dozenten.find(d => d.id === id);
        return dozent ? (dozent.name_kurz || dozent.name_komplett) : `ID: ${id}`;
      })
      .filter(Boolean);
  };

  const filteredPlanungen = planungen.filter(p => {
    if (tabValue === 0) return p.status === 'eingereicht';
    if (tabValue === 1) return p.status === 'freigegeben';
    if (tabValue === 2) return p.status === 'abgelehnt';
    return true; // Alle
  });

  const counts = {
    eingereicht: planungen.filter(p => p.status === 'eingereicht').length,
    freigegeben: planungen.filter(p => p.status === 'freigegeben').length,
    abgelehnt: planungen.filter(p => p.status === 'abgelehnt').length,
    gesamt: planungen.length,
  };

  return (
    <Container maxWidth="xl">
      {/* Header */}
      <Box sx={{ mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <IconButton onClick={() => navigate('/dashboard')}>
          <ArrowBack />
        </IconButton>
        <Box sx={{ flex: 1 }}>
          <Typography variant="h4" fontWeight={600}>
            Semesterplanungen prüfen
          </Typography>
          {semester && (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
              <Typography variant="body1" color="text.secondary">
                {semester.bezeichnung}
              </Typography>
              {activePhase && (
                <Chip
                  label={`Phase: ${activePhase.name}`}
                  color="primary"
                  size="small"
                />
              )}
            </Box>
          )}
        </Box>
        {/* Phase Management Actions */}
        <Box sx={{ display: 'flex', gap: 1 }}>
          <Tooltip title="Planungsphasen verwalten">
            <IconButton
              onClick={() => setShowPhaseManager(true)}
              color="primary"
            >
              <Badge badgeContent={activePhase ? '1' : '0'} color="error">
                <Settings />
              </Badge>
            </IconButton>
          </Tooltip>
          <Tooltip title="Phasenhistorie">
            <IconButton onClick={() => setShowPhaseHistory(true)}>
              <History />
            </IconButton>
          </Tooltip>
          <Tooltip title="Archiv">
            <IconButton onClick={() => setShowArchive(true)}>
              <Archive />
            </IconButton>
          </Tooltip>
        </Box>
      </Box>

      {loading && <LinearProgress sx={{ mb: 2 }} />}

      {/* Warnung wenn keine aktive Phase */}
      {!activePhase && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            ⚠️ Keine aktive Planungsphase
          </Typography>
          <Typography variant="body2">
            Derzeit ist keine Planungsphase aktiv. Es werden keine Planungen angezeigt.
            Bitte öffnen Sie eine neue Planungsphase über die Planungsphasen-Verwaltung.
          </Typography>
        </Alert>
      )}

      {/* Info Alert */}
      {activePhase && counts.eingereicht > 0 && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          <Typography variant="subtitle2">
            ⚠️ {counts.eingereicht} Planung(en) warten auf Ihre Freigabe
          </Typography>
        </Alert>
      )}

      {/* Tabs */}
      <Paper sx={{ mb: 3 }}>
        <Tabs 
          value={tabValue} 
          onChange={(_, v) => setTabValue(v)}
          variant="fullWidth"
        >
          <Tab 
            label={`Eingereicht (${counts.eingereicht})`}
            icon={counts.eingereicht > 0 ? <Alert severity="warning" sx={{ display: 'inline', py: 0, px: 1 }}>!</Alert> : undefined}
            iconPosition="end"
          />
          <Tab label={`Freigegeben (${counts.freigegeben})`} />
          <Tab label={`Abgelehnt (${counts.abgelehnt})`} />
          <Tab label={`Alle (${counts.gesamt})`} />
        </Tabs>
      </Paper>

      {/* Table */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell width={40}></TableCell>
              <TableCell><strong>Dozent</strong></TableCell>
              <TableCell><strong>Status</strong></TableCell>
              <TableCell align="center"><strong>Module</strong></TableCell>
              <TableCell align="center"><strong>ECTS</strong></TableCell>
              <TableCell align="center"><strong>SWS</strong></TableCell>
              <TableCell align="center"><strong>Info</strong></TableCell>
              <TableCell><strong>Eingereicht am</strong></TableCell>
              <TableCell align="center"><strong>Aktionen</strong></TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredPlanungen.length === 0 ? (
              <TableRow>
                <TableCell colSpan={9} align="center">
                  <Typography color="text.secondary" sx={{ py: 4 }}>
                    {tabValue === 0 && 'Keine eingereichten Planungen'}
                    {tabValue === 1 && 'Keine freigegebenen Planungen'}
                    {tabValue === 2 && 'Keine abgelehnten Planungen'}
                    {tabValue === 3 && 'Keine Planungen vorhanden'}
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              filteredPlanungen.map((planung) => (
                <React.Fragment key={planung.id}>
                  <TableRow
                    hover
                    sx={{
                      cursor: 'pointer',
                      '& > *': { borderBottom: expandedRows.has(planung.id) ? 'none !important' : undefined }
                    }}
                    onClick={() => navigate(`/semesterplanung/${planung.id}`)}
                  >
                    {/* Expand Button */}
                    <TableCell onClick={(e) => e.stopPropagation()}>
                      <IconButton
                        size="small"
                        onClick={() => toggleRowExpanded(planung.id)}
                      >
                        {expandedRows.has(planung.id) ? <ExpandLess /> : <ExpandMore />}
                      </IconButton>
                    </TableCell>

                    {/* Dozent */}
                    <TableCell>
                      <Typography variant="body2" fontWeight={500}>
                        {planung.benutzer?.name_komplett || 'Unbekannt'}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {planung.benutzer?.email || ''}
                      </Typography>
                    </TableCell>

                    {/* Status */}
                    <TableCell>{getStatusChip(planung.status)}</TableCell>

                    {/* Module Count */}
                    <TableCell align="center">
                      <Chip
                        label={planung.anzahl_module || 0}
                        size="small"
                        color="primary"
                        variant="outlined"
                        icon={<School fontSize="small" />}
                      />
                    </TableCell>

                    {/* ECTS */}
                    <TableCell align="center">
                      <Typography variant="body2" fontWeight={600}>
                        {calculateGesamtECTS(planung)} ECTS
                      </Typography>
                    </TableCell>

                    {/* SWS */}
                    <TableCell align="center">
                      <Typography variant="body2" fontWeight={600}>
                        {planung.gesamt_sws?.toFixed(1) || '0.0'} SWS
                      </Typography>
                    </TableCell>

                    {/* Info Icons */}
                    <TableCell align="center">
                      <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'center' }}>
                        {planung.anmerkungen && (
                          <Tooltip title={<Typography variant="caption">{planung.anmerkungen}</Typography>}>
                            <Chip
                              icon={<Notes fontSize="small" />}
                              label="Anmerkungen"
                              size="small"
                              variant="outlined"
                            />
                          </Tooltip>
                        )}
                        {planung.wunsch_freie_tage && planung.wunsch_freie_tage.length > 0 && (
                          <Tooltip title={`Wunsch-freie Tage: ${planung.wunsch_freie_tage.join(', ')}`}>
                            <Chip
                              icon={<CalendarMonth fontSize="small" />}
                              label={`${planung.wunsch_freie_tage.length} Tag(e)`}
                              size="small"
                              variant="outlined"
                              color="info"
                            />
                          </Tooltip>
                        )}
                      </Box>
                    </TableCell>

                    {/* Eingereicht am */}
                    <TableCell>
                      {planung.eingereicht_am
                        ? new Date(planung.eingereicht_am).toLocaleDateString('de-DE', {
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit'
                          })
                        : '-'
                      }
                    </TableCell>

                    {/* Aktionen */}
                    <TableCell align="center" onClick={(e) => e.stopPropagation()}>
                      <Box sx={{ display: 'flex', gap: 1, justifyContent: 'center' }}>
                        {/* View Button */}
                        <Tooltip title="Details anzeigen">
                          <IconButton
                            size="small"
                            onClick={() => navigate(`/semesterplanung/${planung.id}`)}
                          >
                            <Visibility />
                          </IconButton>
                        </Tooltip>

                        {/* Approve Button (nur bei eingereicht) */}
                        {planung.status === 'eingereicht' && (
                          <Tooltip title="Freigeben">
                            <IconButton
                              size="small"
                              color="success"
                              onClick={() => handleApprove(planung.id)}
                            >
                              <CheckCircle />
                            </IconButton>
                          </Tooltip>
                        )}

                        {/* Reject Button (nur bei eingereicht) */}
                        {planung.status === 'eingereicht' && (
                          <Tooltip title="Ablehnen">
                            <IconButton
                              size="small"
                              color="error"
                              onClick={() => handleRejectClick(planung)}
                            >
                              <Cancel />
                            </IconButton>
                          </Tooltip>
                        )}
                      </Box>
                    </TableCell>
                  </TableRow>

                  {/* Expandable Module Details */}
                  {expandedRows.has(planung.id) && (
                    <TableRow>
                      <TableCell colSpan={9} sx={{ bgcolor: 'grey.50', py: 2 }}>
                        <Box sx={{ px: 2 }}>
                          <Typography variant="subtitle2" gutterBottom fontWeight={600} sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                            <School fontSize="small" />
                            Geplante Module ({planung.anzahl_module || 0})
                          </Typography>

                          {planung.geplante_module && planung.geplante_module.length > 0 ? (
                            <Grid container spacing={2} sx={{ mt: 1 }}>
                              {planung.geplante_module.map((gm, index) => (
                                <Grid item xs={12} md={6} key={index}>
                                  <Paper variant="outlined" sx={{ p: 2 }}>
                                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}>
                                      <Typography variant="subtitle2" fontWeight={600}>
                                        {gm.modul?.kuerzel || 'Unbekannt'}
                                      </Typography>
                                      <Box sx={{ display: 'flex', gap: 0.5 }}>
                                        {gm.modul?.leistungspunkte && (
                                          <Chip label={`${gm.modul.leistungspunkte} ECTS`} size="small" color="primary" />
                                        )}
                                        {gm.sws_gesamt && (
                                          <Chip label={`${gm.sws_gesamt.toFixed(1)} SWS`} size="small" color="secondary" />
                                        )}
                                      </Box>
                                    </Box>

                                    <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                                      {gm.modul?.bezeichnung_de}
                                    </Typography>

                                    {/* SWS Details */}
                                    {(gm.sws_vorlesung || gm.sws_uebung || gm.sws_praktikum || gm.sws_seminar) && (
                                      <Box sx={{ mt: 1 }}>
                                        <Typography variant="caption" color="text.secondary" display="block" gutterBottom>
                                          SWS-Aufteilung:
                                        </Typography>
                                        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
                                          {gm.sws_vorlesung > 0 && (
                                            <Chip label={`V: ${gm.sws_vorlesung}`} size="small" variant="outlined" />
                                          )}
                                          {gm.sws_uebung > 0 && (
                                            <Chip label={`Ü: ${gm.sws_uebung}`} size="small" variant="outlined" />
                                          )}
                                          {gm.sws_praktikum > 0 && (
                                            <Chip label={`P: ${gm.sws_praktikum}`} size="small" variant="outlined" />
                                          )}
                                          {gm.sws_seminar > 0 && (
                                            <Chip label={`S: ${gm.sws_seminar}`} size="small" variant="outlined" />
                                          )}
                                        </Box>
                                      </Box>
                                    )}

                                    {/* Mitarbeiter */}
                                    {gm.mitarbeiter_ids && gm.mitarbeiter_ids.length > 0 && (
                                      <Box sx={{ mt: 1 }}>
                                        <Typography variant="caption" color="text.secondary" display="block" gutterBottom>
                                          <Person fontSize="small" sx={{ verticalAlign: 'middle', mr: 0.5 }} />
                                          Zugeordnete Mitarbeiter:
                                        </Typography>
                                        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
                                          {getMitarbeiterNamen(gm.mitarbeiter_ids).map((name, idx) => (
                                            <Chip
                                              key={idx}
                                              label={name}
                                              size="small"
                                              variant="outlined"
                                              icon={<Person fontSize="small" />}
                                            />
                                          ))}
                                        </Box>
                                      </Box>
                                    )}

                                    {/* Raumplanung pro Lehrform */}
                                    {(gm.raum_vorlesung || gm.raum_uebung || gm.raum_praktikum || gm.raum_seminar) && (
                                      <Box sx={{ mt: 1 }}>
                                        <Typography variant="caption" color="text.secondary" display="block" gutterBottom>
                                          <Room fontSize="small" sx={{ verticalAlign: 'middle', mr: 0.5 }} />
                                          Raumplanung pro Lehrform:
                                        </Typography>
                                        <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
                                          {gm.raum_vorlesung && (
                                            <Tooltip title={gm.kapazitaet_vorlesung ? `Kapazität: ${gm.kapazitaet_vorlesung}` : ''}>
                                              <Chip
                                                label={`V: ${gm.raum_vorlesung}${gm.kapazitaet_vorlesung ? ` (${gm.kapazitaet_vorlesung})` : ''}`}
                                                size="small"
                                                variant="outlined"
                                                color="primary"
                                                icon={<Room fontSize="small" />}
                                              />
                                            </Tooltip>
                                          )}
                                          {gm.raum_uebung && (
                                            <Tooltip title={gm.kapazitaet_uebung ? `Kapazität: ${gm.kapazitaet_uebung}` : ''}>
                                              <Chip
                                                label={`Ü: ${gm.raum_uebung}${gm.kapazitaet_uebung ? ` (${gm.kapazitaet_uebung})` : ''}`}
                                                size="small"
                                                variant="outlined"
                                                color="secondary"
                                                icon={<Room fontSize="small" />}
                                              />
                                            </Tooltip>
                                          )}
                                          {gm.raum_praktikum && (
                                            <Tooltip title={gm.kapazitaet_praktikum ? `Kapazität: ${gm.kapazitaet_praktikum}` : ''}>
                                              <Chip
                                                label={`P: ${gm.raum_praktikum}${gm.kapazitaet_praktikum ? ` (${gm.kapazitaet_praktikum})` : ''}`}
                                                size="small"
                                                variant="outlined"
                                                color="warning"
                                                icon={<Room fontSize="small" />}
                                              />
                                            </Tooltip>
                                          )}
                                          {gm.raum_seminar && (
                                            <Tooltip title={gm.kapazitaet_seminar ? `Kapazität: ${gm.kapazitaet_seminar}` : ''}>
                                              <Chip
                                                label={`S: ${gm.raum_seminar}${gm.kapazitaet_seminar ? ` (${gm.kapazitaet_seminar})` : ''}`}
                                                size="small"
                                                variant="outlined"
                                                color="success"
                                                icon={<Room fontSize="small" />}
                                              />
                                            </Tooltip>
                                          )}
                                        </Box>
                                      </Box>
                                    )}

                                    {/* Legacy Raumbedarf */}
                                    {gm.raumbedarf && (
                                      <Box sx={{ mt: 1 }}>
                                        <Typography variant="caption" color="text.secondary" display="block" gutterBottom>
                                          <Room fontSize="small" sx={{ verticalAlign: 'middle', mr: 0.5 }} />
                                          Raumbedarf:
                                        </Typography>
                                        <Typography variant="body2" sx={{ pl: 2 }}>
                                          {gm.raumbedarf}
                                        </Typography>
                                      </Box>
                                    )}

                                    {/* Anmerkungen */}
                                    {gm.anmerkungen && (
                                      <Alert severity="info" sx={{ mt: 1, py: 0 }}>
                                        <Typography variant="caption">
                                          <strong>Anmerkung:</strong> {gm.anmerkungen}
                                        </Typography>
                                      </Alert>
                                    )}
                                  </Paper>
                                </Grid>
                              ))}
                            </Grid>
                          ) : (
                            <Typography variant="body2" color="text.secondary" sx={{ fontStyle: 'italic', mt: 1 }}>
                              Keine Module geplant
                            </Typography>
                          )}

                          {/* Planungs-Anmerkungen & Zusatzinformationen */}
                          {(planung.anmerkungen || planung.raumbedarf || (Array.isArray(planung.room_requirements) && planung.room_requirements.length > 0) || planung.special_requests || (planung.wunsch_freie_tage && planung.wunsch_freie_tage.length > 0)) && (
                            <Box sx={{ mt: 3 }}>
                              <Divider sx={{ mb: 2 }} />
                              <Typography variant="subtitle2" gutterBottom fontWeight={600}>
                                Zusätzliche Informationen
                              </Typography>
                              <Grid container spacing={2}>
                                {planung.anmerkungen && (
                                  <Grid item xs={12} md={6}>
                                    <Alert severity="info" icon={<Notes />}>
                                      <Typography variant="caption" fontWeight={600} display="block" gutterBottom>
                                        Anmerkungen zur Planung
                                      </Typography>
                                      <Typography variant="body2" sx={{ whiteSpace: 'pre-wrap' }}>
                                        {planung.anmerkungen}
                                      </Typography>
                                    </Alert>
                                  </Grid>
                                )}

                                {planung.raumbedarf && (
                                  <Grid item xs={12} md={6}>
                                    <Alert severity="info" icon={<Room />}>
                                      <Typography variant="caption" fontWeight={600} display="block" gutterBottom>
                                        Raumbedarf
                                      </Typography>
                                      <Typography variant="body2" sx={{ whiteSpace: 'pre-wrap' }}>
                                        {planung.raumbedarf}
                                      </Typography>
                                    </Alert>
                                  </Grid>
                                )}

                                {planung.wunsch_freie_tage && planung.wunsch_freie_tage.length > 0 && (
                                  <Grid item xs={12}>
                                    <Alert severity="warning" icon={<CalendarMonth />}>
                                      <Typography variant="caption" fontWeight={600} display="block" gutterBottom>
                                        Wunsch-freie Tage ({planung.wunsch_freie_tage.length})
                                      </Typography>
                                      <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mt: 1 }}>
                                        {planung.wunsch_freie_tage.map((tag: any, idx: number) => (
                                          <Chip
                                            key={idx}
                                            label={`${tag.wochentag} (${tag.zeitraum || 'ganztags'})`}
                                            size="small"
                                            color={
                                              tag.prioritaet === 'hoch' ? 'error' :
                                              tag.prioritaet === 'mittel' ? 'warning' : 'default'
                                            }
                                            title={tag.grund || 'Kein Grund angegeben'}
                                          />
                                        ))}
                                      </Box>
                                    </Alert>
                                  </Grid>
                                )}

                                {Array.isArray(planung.room_requirements) && planung.room_requirements.length > 0 && (
                                  <Grid item xs={12} md={6}>
                                    <Alert severity="info" icon={<Room />}>
                                      <Typography variant="caption" fontWeight={600} display="block" gutterBottom>
                                        Raumanforderungen ({planung.room_requirements.length})
                                      </Typography>
                                      {planung.room_requirements.map((room: any, idx: number) => (
                                        <Box key={idx} sx={{ mt: 0.5 }}>
                                          <Typography variant="body2">
                                            <strong>{room.type}</strong> (Kapazität: {room.capacity})
                                          </Typography>
                                          {room.equipment && room.equipment.length > 0 && (
                                            <Typography variant="caption" color="text.secondary">
                                              Ausstattung: {room.equipment.join(', ')}
                                            </Typography>
                                          )}
                                        </Box>
                                      ))}
                                    </Alert>
                                  </Grid>
                                )}

                                {planung.special_requests && typeof planung.special_requests === 'object' && !Array.isArray(planung.special_requests) && Object.keys(planung.special_requests).some(k => (planung.special_requests as any)[k]) && (
                                  <Grid item xs={12} md={6}>
                                    <Alert severity="info">
                                      <Typography variant="caption" fontWeight={600} display="block" gutterBottom>
                                        Spezielle Anforderungen
                                      </Typography>
                                      <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap' }}>
                                        {(planung.special_requests as any).needsComputerRoom && <Chip label="Computerraum" size="small" />}
                                        {(planung.special_requests as any).needsLab && <Chip label="Labor" size="small" />}
                                        {(planung.special_requests as any).needsBeamer && <Chip label="Beamer" size="small" />}
                                        {(planung.special_requests as any).needsWhiteboard && <Chip label="Whiteboard" size="small" />}
                                        {(planung.special_requests as any).flexibleScheduling && <Chip label="Flexible Planung" size="small" />}
                                        {(planung.special_requests as any).blockCourse && <Chip label="Blockveranstaltung" size="small" />}
                                      </Box>
                                    </Alert>
                                  </Grid>
                                )}
                              </Grid>
                            </Box>
                          )}
                        </Box>
                      </TableCell>
                    </TableRow>
                  )}
                </React.Fragment>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Reject Dialog */}
      <Dialog
        open={rejectDialog}
        onClose={() => setRejectDialog(false)}
        maxWidth="sm"
        fullWidth
        disableRestoreFocus
      >
        <DialogTitle>
          Planung ablehnen
        </DialogTitle>
        <DialogContent>
          <Alert severity="warning" sx={{ mb: 2 }}>
            Die Planung wird abgelehnt und der Dozent kann sie überarbeiten.
          </Alert>

          <Typography variant="body2" gutterBottom>
            <strong>Dozent:</strong> {selectedPlanung?.benutzer?.name_komplett}
          </Typography>
          <Typography variant="body2" gutterBottom sx={{ mb: 2 }}>
            <strong>Module:</strong> {selectedPlanung?.anzahl_module || 0} • {selectedPlanung?.gesamt_sws?.toFixed(1) || '0.0'} SWS
          </Typography>

          <TextField
            autoFocus
            fullWidth
            multiline
            rows={4}
            label="Ablehnungsgrund *"
            placeholder="Bitte geben Sie an, warum die Planung abgelehnt wird..."
            value={ablehnungsgrund}
            onChange={(e) => setAblehnungsgrund(e.target.value)}
            helperText="Der Dozent wird diesen Grund sehen und kann die Planung überarbeiten."
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRejectDialog(false)}>
            Abbrechen
          </Button>
          <Button
            variant="contained"
            color="error"
            onClick={handleRejectConfirm}
            disabled={!ablehnungsgrund.trim() || loading}
          >
            Ablehnen
          </Button>
        </DialogActions>
      </Dialog>

      {/* Planning Phase Management Dialog */}
      <Dialog
        open={showPhaseManager}
        onClose={() => setShowPhaseManager(false)}
        maxWidth="lg"
        fullWidth
        disableRestoreFocus
      >
        <DialogTitle>
          <Box display="flex" justifyContent="space-between" alignItems="center">
            <Typography variant="h6">Planungsphasen-Verwaltung</Typography>
            <IconButton onClick={() => setShowPhaseManager(false)}>
              <Cancel />
            </IconButton>
          </Box>
        </DialogTitle>
        <DialogContent dividers>
          <PlanungsphasenManager />
        </DialogContent>
      </Dialog>

      {/* Phase History Dialog */}
      <PhaseHistoryDialog
        open={showPhaseHistory}
        onClose={() => setShowPhaseHistory(false)}
      />

      {/* Archive View Dialog */}
      <Dialog
        open={showArchive}
        onClose={() => setShowArchive(false)}
        maxWidth="lg"
        fullWidth
        disableRestoreFocus
      >
        <DialogTitle>
          <Box display="flex" justifyContent="space-between" alignItems="center">
            <Typography variant="h6">Archivierte Planungen</Typography>
            <IconButton onClick={() => setShowArchive(false)}>
              <Cancel />
            </IconButton>
          </Box>
        </DialogTitle>
        <DialogContent dividers>
          <ArchivedPlanungsList />
        </DialogContent>
      </Dialog>
    </Container>
  );
};

export default DekanPlanungView;