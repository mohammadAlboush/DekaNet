import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Button,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  MenuItem,
  Chip,
  Alert,
  CircularProgress,
  Card,
  CardContent,
  CardActions,
  Grid,
  Tooltip,
  FormControl,
  InputLabel,
  Select,
  Divider,
  Switch,
  FormControlLabel,
} from '@mui/material';
import {
  Add,
  Delete,
  Edit,
  ContentCopy,
  ArrowBack,
  WbSunny,
  AcUnit,
  Refresh,
  Visibility,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import templateService, {
  PlanungsTemplate,
  CreateTemplateData,
  UpdateTemplateData,
} from '../services/templateService';
import planungService from '../services/planungService';
import { Semesterplanung } from '../types/planung.types';
import { useToastStore } from '../components/common/Toast';
import { createContextLogger } from '../utils/logger';
import { getErrorMessage } from '../utils/errorUtils';

const log = createContextLogger('TemplateVerwaltung');

/**
 * TemplateVerwaltung
 * ==================
 *
 * Seite zur Verwaltung von Planungs-Templates.
 * Professoren können hier ihre Standard-Modulkonfigurationen
 * für Winter- und Sommersemester verwalten.
 */

const TemplateVerwaltung: React.FC = () => {
  const navigate = useNavigate();
  const showToast = useToastStore((state) => state.showToast);

  // State
  const [loading, setLoading] = useState(true);
  const [templates, setTemplates] = useState<PlanungsTemplate[]>([]);
  const [planungen, setPlanungen] = useState<Semesterplanung[]>([]);

  // Dialog States
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [editDialogOpen, setEditDialogOpen] = useState(false);
  const [fromPlanungDialogOpen, setFromPlanungDialogOpen] = useState(false);
  const [selectedTemplate, setSelectedTemplate] = useState<PlanungsTemplate | null>(null);

  // Form States
  const [createForm, setCreateForm] = useState<CreateTemplateData>({
    semester_typ: 'winter',
    name: '',
    beschreibung: '',
  });
  const [editForm, setEditForm] = useState<UpdateTemplateData>({
    name: '',
    beschreibung: '',
    ist_aktiv: true,
  });
  const [selectedPlanungId, setSelectedPlanungId] = useState<number | null>(null);
  const [fromPlanungSemesterTyp, setFromPlanungSemesterTyp] = useState<'winter' | 'sommer'>('winter');

  // Load Templates
  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);

      // Templates laden
      const templatesResponse = await templateService.getAllTemplates();
      if (templatesResponse.success && templatesResponse.data) {
        setTemplates(templatesResponse.data);
      }

      // Planungen laden (für "Aus Planung erstellen")
      const planungenResponse = await planungService.getAllPlanungen();
      if (planungenResponse.success && planungenResponse.data) {
        setPlanungen(planungenResponse.data);
      }
    } catch (error: unknown) {
      log.error('Error loading data:', error);
      showToast(getErrorMessage(error, 'Fehler beim Laden der Daten'), 'error');
    } finally {
      setLoading(false);
    }
  };

  // Template erstellen
  const handleCreate = async () => {
    try {
      const response = await templateService.createTemplate(createForm);
      if (response.success) {
        showToast('Template erstellt', 'success');
        setCreateDialogOpen(false);
        setCreateForm({ semester_typ: 'winter', name: '', beschreibung: '' });
        loadData();
      }
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Erstellen'), 'error');
    }
  };

  // Template bearbeiten
  const handleEdit = async () => {
    if (!selectedTemplate) return;
    try {
      const response = await templateService.updateTemplate(selectedTemplate.id, editForm);
      if (response.success) {
        showToast('Template aktualisiert', 'success');
        setEditDialogOpen(false);
        setSelectedTemplate(null);
        loadData();
      }
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Aktualisieren'), 'error');
    }
  };

  // Template loeschen
  const handleDelete = async (template: PlanungsTemplate) => {
    if (!confirm(`Template "${template.name || template.semester_typ}" wirklich loeschen?`)) return;
    try {
      await templateService.deleteTemplate(template.id);
      showToast('Template geloescht', 'success');
      loadData();
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Loeschen'), 'error');
    }
  };

  // Template aus Planung erstellen
  const handleCreateFromPlanung = async () => {
    if (!selectedPlanungId) return;
    try {
      const response = await templateService.createFromPlanung(
        selectedPlanungId,
        fromPlanungSemesterTyp
      );
      if (response.success) {
        showToast(`Template erstellt mit ${response.data?.anzahl_module || 0} Modulen`, 'success');
        setFromPlanungDialogOpen(false);
        setSelectedPlanungId(null);
        loadData();
      }
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Erstellen'), 'error');
    }
  };

  // Template aus bestehender Planung aktualisieren
  const handleUpdateFromPlanung = async (template: PlanungsTemplate) => {
    const planung = planungen.find(p => {
      const semTyp = templateService.getSemesterTypFromKuerzel(p.semester?.kuerzel);
      return semTyp === template.semester_typ;
    });

    if (!planung) {
      showToast('Keine passende Planung gefunden', 'warning');
      return;
    }

    if (!confirm(`Template aus Planung "${planung.semester?.kuerzel}" aktualisieren? Alle bestehenden Module werden ueberschrieben.`)) return;

    try {
      const response = await templateService.updateFromPlanung(template.id, planung.id);
      if (response.success) {
        showToast('Template aktualisiert', 'success');
        loadData();
      }
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Aktualisieren'), 'error');
    }
  };

  // Dialog oeffnen zum Bearbeiten
  const openEditDialog = (template: PlanungsTemplate) => {
    setSelectedTemplate(template);
    setEditForm({
      name: template.name || '',
      beschreibung: template.beschreibung || '',
      ist_aktiv: template.ist_aktiv,
    });
    setEditDialogOpen(true);
  };

  // Semester-Icon
  const getSemesterIcon = (typ: 'winter' | 'sommer') => {
    return typ === 'winter' ? <AcUnit color="primary" /> : <WbSunny sx={{ color: 'orange' }} />;
  };

  // Template fuer Semestertyp vorhanden?
  const hasTemplateForType = (typ: 'winter' | 'sommer') => {
    return templates.some(t => t.semester_typ === typ);
  };

  if (loading) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
          <CircularProgress />
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 3, mb: 4 }}>
      {/* Header */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start" flexWrap="wrap" gap={2}>
          <Box display="flex" alignItems="center" gap={2}>
            <IconButton onClick={() => navigate(-1)} size="small">
              <ArrowBack />
            </IconButton>
            <Box>
              <Typography variant="h5" fontWeight="600">
                Planungs-Templates
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Standard-Modulkonfigurationen fuer Winter- und Sommersemester
              </Typography>
            </Box>
          </Box>

          <Box display="flex" gap={1}>
            <Button
              variant="outlined"
              startIcon={<ContentCopy />}
              onClick={() => setFromPlanungDialogOpen(true)}
              disabled={planungen.length === 0}
            >
              Aus Planung erstellen
            </Button>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={() => setCreateDialogOpen(true)}
              disabled={hasTemplateForType('winter') && hasTemplateForType('sommer')}
            >
              Neues Template
            </Button>
          </Box>
        </Box>
      </Paper>

      {/* Info Alert */}
      <Alert severity="info" sx={{ mb: 3 }}>
        <Typography variant="body2">
          Templates speichern Ihre Standard-Module fuer jedes Semester. Beim Start einer neuen Planung
          koennen Sie das passende Template laden und die Module werden automatisch uebernommen.
        </Typography>
      </Alert>

      {/* Templates */}
      {templates.length === 0 ? (
        <Paper sx={{ p: 4, textAlign: 'center' }}>
          <Typography variant="h6" color="text.secondary" gutterBottom>
            Keine Templates vorhanden
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Erstellen Sie Ihr erstes Template oder importieren Sie es aus einer bestehenden Planung.
          </Typography>
          <Box display="flex" gap={2} justifyContent="center">
            <Button
              variant="outlined"
              startIcon={<ContentCopy />}
              onClick={() => setFromPlanungDialogOpen(true)}
              disabled={planungen.length === 0}
            >
              Aus Planung
            </Button>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={() => setCreateDialogOpen(true)}
            >
              Manuell erstellen
            </Button>
          </Box>
        </Paper>
      ) : (
        <Grid container spacing={3}>
          {templates.map((template) => (
            <Grid item xs={12} md={6} key={template.id}>
              <Card elevation={3}>
                <CardContent>
                  <Box display="flex" alignItems="center" gap={1} mb={2}>
                    {getSemesterIcon(template.semester_typ)}
                    <Typography variant="h6">
                      {template.name || templateService.formatSemesterTyp(template.semester_typ)}
                    </Typography>
                    {template.ist_aktiv && (
                      <Chip label="Aktiv" color="success" size="small" />
                    )}
                  </Box>

                  {template.beschreibung && (
                    <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                      {template.beschreibung}
                    </Typography>
                  )}

                  <Divider sx={{ my: 2 }} />

                  {/* Stats */}
                  <Box display="flex" gap={3} mb={2}>
                    <Box>
                      <Typography variant="caption" color="text.secondary">Module</Typography>
                      <Typography variant="h6">{template.anzahl_module}</Typography>
                    </Box>
                    <Box>
                      <Typography variant="caption" color="text.secondary">Wunsch-Tage</Typography>
                      <Typography variant="h6">{template.wunsch_freie_tage?.length || 0}</Typography>
                    </Box>
                    {template.anmerkungen && (
                      <Box>
                        <Typography variant="caption" color="text.secondary">Anmerkungen</Typography>
                        <Typography variant="body2">Ja</Typography>
                      </Box>
                    )}
                    {template.raumbedarf && (
                      <Box>
                        <Typography variant="caption" color="text.secondary">Raumbedarf</Typography>
                        <Typography variant="body2">Ja</Typography>
                      </Box>
                    )}
                  </Box>

                  {/* Module Preview mit Details */}
                  {template.template_module && template.template_module.length > 0 && (
                    <Box>
                      <Typography variant="caption" color="text.secondary">
                        Module mit Konfiguration:
                      </Typography>
                      <Box display="flex" flexDirection="column" gap={0.5} mt={0.5}>
                        {template.template_module.slice(0, 4).map((tm) => {
                          const lehrformen: string[] = [];
                          if (tm.anzahl_vorlesungen > 0) lehrformen.push(`${tm.anzahl_vorlesungen}V`);
                          if (tm.anzahl_uebungen > 0) lehrformen.push(`${tm.anzahl_uebungen}Ue`);
                          if (tm.anzahl_praktika > 0) lehrformen.push(`${tm.anzahl_praktika}P`);
                          if (tm.anzahl_seminare > 0) lehrformen.push(`${tm.anzahl_seminare}S`);
                          const lehrformenStr = lehrformen.join('+') || 'Keine LF';
                          const mitarbeiterCount = tm.mitarbeiter_ids?.length || 0;

                          return (
                            <Box key={tm.id} display="flex" alignItems="center" gap={1}>
                              <Chip
                                label={tm.modul?.kuerzel || `Modul ${tm.modul_id}`}
                                size="small"
                                variant="outlined"
                                color="primary"
                              />
                              <Typography variant="caption" color="text.secondary">
                                {lehrformenStr}
                                {mitarbeiterCount > 0 && ` • ${mitarbeiterCount} MA`}
                                {tm.raum_vorlesung && ` • Raum`}
                              </Typography>
                            </Box>
                          );
                        })}
                        {template.template_module.length > 4 && (
                          <Typography variant="caption" color="text.secondary">
                            +{template.template_module.length - 4} weitere Module...
                          </Typography>
                        )}
                      </Box>
                    </Box>
                  )}

                  {/* Wunsch-freie Tage Preview */}
                  {template.wunsch_freie_tage && template.wunsch_freie_tage.length > 0 && (
                    <Box mt={1}>
                      <Typography variant="caption" color="text.secondary">
                        Wunsch-freie Tage:
                      </Typography>
                      <Box display="flex" flexWrap="wrap" gap={0.5} mt={0.5}>
                        {template.wunsch_freie_tage.map((tag, idx) => (
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

                  <Typography variant="caption" color="text.secondary" display="block" mt={2}>
                    Erstellt: {template.created_at ? new Date(template.created_at).toLocaleDateString('de-DE') : '-'}
                  </Typography>
                </CardContent>

                <CardActions sx={{ px: 2, pb: 2 }}>
                  <Tooltip title="Template bearbeiten (Detail-Ansicht)">
                    <IconButton size="small" color="primary" onClick={() => navigate(`/templates/${template.id}`)}>
                      <Visibility />
                    </IconButton>
                  </Tooltip>
                  <Tooltip title="Name/Beschreibung bearbeiten">
                    <IconButton size="small" onClick={() => openEditDialog(template)}>
                      <Edit />
                    </IconButton>
                  </Tooltip>
                  <Tooltip title="Aus aktueller Planung aktualisieren">
                    <IconButton
                      size="small"
                      onClick={() => handleUpdateFromPlanung(template)}
                      disabled={planungen.length === 0}
                    >
                      <Refresh />
                    </IconButton>
                  </Tooltip>
                  <Tooltip title="Template loeschen">
                    <IconButton size="small" color="error" onClick={() => handleDelete(template)}>
                      <Delete />
                    </IconButton>
                  </Tooltip>
                  <Box flexGrow={1} />
                  <Button
                    size="small"
                    variant="outlined"
                    onClick={() => navigate(`/templates/${template.id}`)}
                  >
                    Details
                  </Button>
                </CardActions>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      {/* Create Dialog */}
      <Dialog open={createDialogOpen} onClose={() => setCreateDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Neues Template erstellen</DialogTitle>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2} pt={1}>
            <FormControl fullWidth>
              <InputLabel>Semestertyp</InputLabel>
              <Select
                value={createForm.semester_typ}
                label="Semestertyp"
                onChange={(e) => setCreateForm({ ...createForm, semester_typ: e.target.value as 'winter' | 'sommer' })}
              >
                <MenuItem value="winter" disabled={hasTemplateForType('winter')}>
                  <Box display="flex" alignItems="center" gap={1}>
                    <AcUnit color="primary" /> Wintersemester
                    {hasTemplateForType('winter') && ' (existiert bereits)'}
                  </Box>
                </MenuItem>
                <MenuItem value="sommer" disabled={hasTemplateForType('sommer')}>
                  <Box display="flex" alignItems="center" gap={1}>
                    <WbSunny sx={{ color: 'orange' }} /> Sommersemester
                    {hasTemplateForType('sommer') && ' (existiert bereits)'}
                  </Box>
                </MenuItem>
              </Select>
            </FormControl>
            <TextField
              label="Name (optional)"
              fullWidth
              value={createForm.name}
              onChange={(e) => setCreateForm({ ...createForm, name: e.target.value })}
              placeholder={createForm.semester_typ === 'winter' ? 'Wintersemester Template' : 'Sommersemester Template'}
            />
            <TextField
              label="Beschreibung (optional)"
              fullWidth
              multiline
              rows={3}
              value={createForm.beschreibung}
              onChange={(e) => setCreateForm({ ...createForm, beschreibung: e.target.value })}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setCreateDialogOpen(false)}>Abbrechen</Button>
          <Button variant="contained" onClick={handleCreate}>Erstellen</Button>
        </DialogActions>
      </Dialog>

      {/* Edit Dialog */}
      <Dialog open={editDialogOpen} onClose={() => setEditDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Template bearbeiten</DialogTitle>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2} pt={1}>
            <TextField
              label="Name"
              fullWidth
              value={editForm.name}
              onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
            />
            <TextField
              label="Beschreibung"
              fullWidth
              multiline
              rows={3}
              value={editForm.beschreibung}
              onChange={(e) => setEditForm({ ...editForm, beschreibung: e.target.value })}
            />
            <FormControlLabel
              control={
                <Switch
                  checked={editForm.ist_aktiv}
                  onChange={(e) => setEditForm({ ...editForm, ist_aktiv: e.target.checked })}
                />
              }
              label="Template aktiv"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEditDialogOpen(false)}>Abbrechen</Button>
          <Button variant="contained" onClick={handleEdit}>Speichern</Button>
        </DialogActions>
      </Dialog>

      {/* From Planung Dialog */}
      <Dialog open={fromPlanungDialogOpen} onClose={() => setFromPlanungDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Template aus Planung erstellen</DialogTitle>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2} pt={1}>
            <Alert severity="info">
              Waehlen Sie eine bestehende Planung aus. Alle Module und Einstellungen werden in das neue Template uebernommen.
            </Alert>
            <FormControl fullWidth>
              <InputLabel>Planung auswaehlen</InputLabel>
              <Select
                value={selectedPlanungId || ''}
                label="Planung auswaehlen"
                onChange={(e) => {
                  const id = Number(e.target.value);
                  setSelectedPlanungId(id);
                  // Auto-detect semester type
                  const planung = planungen.find(p => p.id === id);
                  if (planung?.semester?.kuerzel) {
                    setFromPlanungSemesterTyp(templateService.getSemesterTypFromKuerzel(planung.semester.kuerzel));
                  }
                }}
              >
                {planungen.map((planung) => (
                  <MenuItem key={planung.id} value={planung.id}>
                    {planung.semester?.kuerzel || `Semester ${planung.semester_id}`} - {planung.status}
                    {planung.geplante_module?.length > 0 && ` (${planung.geplante_module.length} Module)`}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <FormControl fullWidth>
              <InputLabel>Ziel-Semestertyp</InputLabel>
              <Select
                value={fromPlanungSemesterTyp}
                label="Ziel-Semestertyp"
                onChange={(e) => setFromPlanungSemesterTyp(e.target.value as 'winter' | 'sommer')}
              >
                <MenuItem value="winter" disabled={hasTemplateForType('winter')}>
                  <Box display="flex" alignItems="center" gap={1}>
                    <AcUnit color="primary" /> Wintersemester
                    {hasTemplateForType('winter') && ' (existiert bereits)'}
                  </Box>
                </MenuItem>
                <MenuItem value="sommer" disabled={hasTemplateForType('sommer')}>
                  <Box display="flex" alignItems="center" gap={1}>
                    <WbSunny sx={{ color: 'orange' }} /> Sommersemester
                    {hasTemplateForType('sommer') && ' (existiert bereits)'}
                  </Box>
                </MenuItem>
              </Select>
            </FormControl>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setFromPlanungDialogOpen(false)}>Abbrechen</Button>
          <Button
            variant="contained"
            onClick={handleCreateFromPlanung}
            disabled={!selectedPlanungId || (hasTemplateForType(fromPlanungSemesterTyp))}
          >
            Template erstellen
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default TemplateVerwaltung;
