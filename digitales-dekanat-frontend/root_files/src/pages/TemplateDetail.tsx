import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Button,
  IconButton,
  Chip,
  CircularProgress,
  Tabs,
  Tab,
  TextField,
  Alert,
  Divider,
  Card,
  CardContent,
  Grid,
} from '@mui/material';
import {
  ArrowBack,
  Save,
  Delete,
  WbSunny,
  AcUnit,
  School,
  CalendarMonth,
  Notes,
  Summarize,
  Edit,
  Check,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';
import templateService, {
  PlanungsTemplate,
  UpdateTemplateData,
} from '../services/templateService';
import { useToastStore } from '../components/common/Toast';
import TemplateModulList from '../components/templates/TemplateModulList';
import WunschTagEditor, { WunschTag } from '../components/common/WunschTagEditor';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`template-tabpanel-${index}`}
      aria-labelledby={`template-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
    </div>
  );
}

/**
 * TemplateDetail
 *
 * Detailseite für ein Planungs-Template.
 * Ermöglicht vollständige Bearbeitung von Modulen, Wunsch-freien Tagen und Zusatzinfos.
 */
const TemplateDetail: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const showToast = useToastStore((state) => state.showToast);

  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [template, setTemplate] = useState<PlanungsTemplate | null>(null);
  const [activeTab, setActiveTab] = useState(0);

  // Form State für Zusatzinfos
  const [anmerkungen, setAnmerkungen] = useState('');
  const [raumbedarf, setRaumbedarf] = useState('');
  const [wunschFreieTage, setWunschFreieTage] = useState<WunschTag[]>([]);
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  // Name/Beschreibung bearbeiten
  const [editingHeader, setEditingHeader] = useState(false);
  const [headerForm, setHeaderForm] = useState({ name: '', beschreibung: '' });

  useEffect(() => {
    if (id) {
      loadTemplate(parseInt(id));
    }
  }, [id]);

  const loadTemplate = async (templateId: number) => {
    setLoading(true);
    try {
      const response = await templateService.getTemplate(templateId);
      if (response.success && response.data) {
        setTemplate(response.data);
        setAnmerkungen(response.data.anmerkungen || '');
        setRaumbedarf(response.data.raumbedarf || '');
        setWunschFreieTage(
          (response.data.wunsch_freie_tage || []).map((tag, idx) => ({
            ...tag,
            id: `wt-${idx}`,
          })) as WunschTag[]
        );
        setHeaderForm({
          name: response.data.name || '',
          beschreibung: response.data.beschreibung || '',
        });
        setHasUnsavedChanges(false);
      } else {
        showToast('Template nicht gefunden', 'error');
        navigate('/templates');
      }
    } catch (error: any) {
      console.error('Error loading template:', error);
      showToast(error.message || 'Fehler beim Laden', 'error');
      navigate('/templates');
    } finally {
      setLoading(false);
    }
  };

  const handleSaveZusatzinfos = async () => {
    if (!template) return;

    setSaving(true);
    try {
      const updateData: UpdateTemplateData = {
        anmerkungen,
        raumbedarf,
        wunsch_freie_tage: wunschFreieTage.map(tag => ({
          wochentag: tag.wochentag,
          zeitraum: tag.zeitraum,
          prioritaet: tag.prioritaet,
          grund: tag.grund,
        })),
      };

      await templateService.updateTemplate(template.id, updateData);
      showToast('Änderungen gespeichert', 'success');
      setHasUnsavedChanges(false);
      loadTemplate(template.id);
    } catch (error: any) {
      console.error('Error saving:', error);
      showToast(error.message || 'Fehler beim Speichern', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleSaveHeader = async () => {
    if (!template) return;

    setSaving(true);
    try {
      await templateService.updateTemplate(template.id, {
        name: headerForm.name || undefined,
        beschreibung: headerForm.beschreibung || undefined,
      });
      showToast('Änderungen gespeichert', 'success');
      setEditingHeader(false);
      loadTemplate(template.id);
    } catch (error: any) {
      console.error('Error saving header:', error);
      showToast(error.message || 'Fehler beim Speichern', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    if (!template) return;

    if (!window.confirm(`Template "${template.name || templateService.formatSemesterTyp(template.semester_typ)}" wirklich löschen?`)) {
      return;
    }

    try {
      await templateService.deleteTemplate(template.id);
      showToast('Template gelöscht', 'success');
      navigate('/templates');
    } catch (error: any) {
      console.error('Error deleting:', error);
      showToast(error.message || 'Fehler beim Löschen', 'error');
    }
  };

  const handleWunschTageChange = (tags: WunschTag[]) => {
    setWunschFreieTage(tags);
    setHasUnsavedChanges(true);
  };

  const handleZusatzinfoChange = (field: 'anmerkungen' | 'raumbedarf', value: string) => {
    if (field === 'anmerkungen') {
      setAnmerkungen(value);
    } else {
      setRaumbedarf(value);
    }
    setHasUnsavedChanges(true);
  };

  const getSemesterIcon = () => {
    if (!template) return null;
    return template.semester_typ === 'winter'
      ? <AcUnit color="primary" sx={{ fontSize: 28 }} />
      : <WbSunny sx={{ color: 'orange', fontSize: 28 }} />;
  };

  const getTotalLehrformen = () => {
    if (!template?.template_module) return { v: 0, u: 0, p: 0, s: 0 };
    return template.template_module.reduce((acc, m) => ({
      v: acc.v + (m.anzahl_vorlesungen || 0),
      u: acc.u + (m.anzahl_uebungen || 0),
      p: acc.p + (m.anzahl_praktika || 0),
      s: acc.s + (m.anzahl_seminare || 0),
    }), { v: 0, u: 0, p: 0, s: 0 });
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

  if (!template) {
    return null;
  }

  const lehrformen = getTotalLehrformen();

  return (
    <Container maxWidth="lg" sx={{ mt: 3, mb: 4 }}>
      {/* Header */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box display="flex" justifyContent="space-between" alignItems="flex-start" flexWrap="wrap" gap={2}>
          <Box display="flex" alignItems="flex-start" gap={2}>
            <IconButton onClick={() => navigate('/templates')} sx={{ mt: 0.5 }}>
              <ArrowBack />
            </IconButton>
            <Box>
              {editingHeader ? (
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                  <TextField
                    size="small"
                    label="Name"
                    value={headerForm.name}
                    onChange={(e) => setHeaderForm({ ...headerForm, name: e.target.value })}
                    placeholder={templateService.formatSemesterTyp(template.semester_typ)}
                  />
                  <TextField
                    size="small"
                    label="Beschreibung"
                    value={headerForm.beschreibung}
                    onChange={(e) => setHeaderForm({ ...headerForm, beschreibung: e.target.value })}
                    multiline
                    rows={2}
                  />
                  <Box sx={{ display: 'flex', gap: 1 }}>
                    <Button
                      size="small"
                      variant="contained"
                      startIcon={<Check />}
                      onClick={handleSaveHeader}
                      disabled={saving}
                    >
                      Speichern
                    </Button>
                    <Button
                      size="small"
                      onClick={() => setEditingHeader(false)}
                    >
                      Abbrechen
                    </Button>
                  </Box>
                </Box>
              ) : (
                <>
                  <Box display="flex" alignItems="center" gap={1}>
                    {getSemesterIcon()}
                    <Typography variant="h5" fontWeight={600}>
                      {template.name || templateService.formatSemesterTyp(template.semester_typ)}
                    </Typography>
                    {template.ist_aktiv && (
                      <Chip label="Aktiv" color="success" size="small" />
                    )}
                    <IconButton size="small" onClick={() => setEditingHeader(true)}>
                      <Edit fontSize="small" />
                    </IconButton>
                  </Box>
                  {template.beschreibung && (
                    <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>
                      {template.beschreibung}
                    </Typography>
                  )}
                </>
              )}
            </Box>
          </Box>

          <Box display="flex" gap={1}>
            {hasUnsavedChanges && (
              <Button
                variant="contained"
                color="primary"
                startIcon={<Save />}
                onClick={handleSaveZusatzinfos}
                disabled={saving}
              >
                {saving ? 'Speichert...' : 'Änderungen speichern'}
              </Button>
            )}
            <Button
              variant="outlined"
              color="error"
              startIcon={<Delete />}
              onClick={handleDelete}
            >
              Löschen
            </Button>
          </Box>
        </Box>
      </Paper>

      {/* Unsaved Changes Warning */}
      {hasUnsavedChanges && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          Sie haben ungespeicherte Änderungen. Klicken Sie auf "Änderungen speichern", um diese zu übernehmen.
        </Alert>
      )}

      {/* Tabs */}
      <Paper sx={{ mb: 3 }}>
        <Tabs
          value={activeTab}
          onChange={(_, newValue) => setActiveTab(newValue)}
          variant="fullWidth"
        >
          <Tab
            icon={<School />}
            label={`Module (${template.anzahl_module})`}
            iconPosition="start"
          />
          <Tab
            icon={<CalendarMonth />}
            label={`Wunsch-Tage (${wunschFreieTage.length})`}
            iconPosition="start"
          />
          <Tab
            icon={<Notes />}
            label="Zusatzinfos"
            iconPosition="start"
          />
          <Tab
            icon={<Summarize />}
            label="Übersicht"
            iconPosition="start"
          />
        </Tabs>
      </Paper>

      {/* Tab Panels */}
      <Paper sx={{ p: 3 }}>
        {/* Tab 0: Module */}
        <TabPanel value={activeTab} index={0}>
          <TemplateModulList
            templateId={template.id}
            module={template.template_module || []}
            onModuleChange={() => loadTemplate(template.id)}
          />
        </TabPanel>

        {/* Tab 1: Wunsch-freie Tage */}
        <TabPanel value={activeTab} index={1}>
          <Typography variant="h6" gutterBottom>
            Wunsch-freie Tage
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
            Definieren Sie Ihre bevorzugten freien Tage für die Stundenplanung.
            Diese werden bei jeder neuen Planung automatisch übernommen.
          </Typography>
          <WunschTagEditor
            wunschFreieTage={wunschFreieTage}
            onChange={handleWunschTageChange}
          />
        </TabPanel>

        {/* Tab 2: Zusatzinfos */}
        <TabPanel value={activeTab} index={2}>
          <Typography variant="h6" gutterBottom>
            Zusätzliche Informationen
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
            Allgemeine Anmerkungen und Raumbedarf, die für alle Planungen gelten.
          </Typography>

          <TextField
            fullWidth
            multiline
            rows={4}
            label="Anmerkungen"
            value={anmerkungen}
            onChange={(e) => handleZusatzinfoChange('anmerkungen', e.target.value)}
            sx={{ mb: 3 }}
            placeholder="Allgemeine Hinweise zur Planung, besondere Anforderungen, etc."
          />

          <TextField
            fullWidth
            multiline
            rows={4}
            label="Raumbedarf"
            value={raumbedarf}
            onChange={(e) => handleZusatzinfoChange('raumbedarf', e.target.value)}
            placeholder="Allgemeine Raumanforderungen, spezielle Ausstattung, etc."
          />
        </TabPanel>

        {/* Tab 3: Übersicht */}
        <TabPanel value={activeTab} index={3}>
          <Typography variant="h6" gutterBottom>
            Template-Übersicht
          </Typography>

          <Grid container spacing={3}>
            {/* Statistiken */}
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Statistiken
                  </Typography>
                  <Divider sx={{ my: 1 }} />
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2">Module:</Typography>
                      <Typography variant="body2" fontWeight={600}>{template.anzahl_module}</Typography>
                    </Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2">Vorlesungen:</Typography>
                      <Typography variant="body2" fontWeight={600}>{lehrformen.v}</Typography>
                    </Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2">Übungen:</Typography>
                      <Typography variant="body2" fontWeight={600}>{lehrformen.u}</Typography>
                    </Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2">Praktika:</Typography>
                      <Typography variant="body2" fontWeight={600}>{lehrformen.p}</Typography>
                    </Box>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2">Seminare:</Typography>
                      <Typography variant="body2" fontWeight={600}>{lehrformen.s}</Typography>
                    </Box>
                    <Divider sx={{ my: 1 }} />
                    <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                      <Typography variant="body2">Wunsch-freie Tage:</Typography>
                      <Typography variant="body2" fontWeight={600}>{wunschFreieTage.length}</Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>

            {/* Module-Liste */}
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Module
                  </Typography>
                  <Divider sx={{ my: 1 }} />
                  {template.template_module && template.template_module.length > 0 ? (
                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                      {template.template_module.map((m) => {
                        const lf: string[] = [];
                        if (m.anzahl_vorlesungen > 0) lf.push(`${m.anzahl_vorlesungen}V`);
                        if (m.anzahl_uebungen > 0) lf.push(`${m.anzahl_uebungen}Ü`);
                        if (m.anzahl_praktika > 0) lf.push(`${m.anzahl_praktika}P`);
                        if (m.anzahl_seminare > 0) lf.push(`${m.anzahl_seminare}S`);

                        return (
                          <Chip
                            key={m.id}
                            label={`${m.modul?.kuerzel || m.modul_id} (${lf.join('+')})`}
                            size="small"
                            variant="outlined"
                            color="primary"
                          />
                        );
                      })}
                    </Box>
                  ) : (
                    <Typography variant="body2" color="text.secondary">
                      Keine Module definiert
                    </Typography>
                  )}
                </CardContent>
              </Card>
            </Grid>

            {/* Wunsch-Tage */}
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Wunsch-freie Tage
                  </Typography>
                  <Divider sx={{ my: 1 }} />
                  {wunschFreieTage.length > 0 ? (
                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                      {wunschFreieTage.map((tag, idx) => (
                        <Chip
                          key={idx}
                          label={`${tag.wochentag} (${tag.zeitraum})`}
                          size="small"
                          variant="outlined"
                          color={tag.prioritaet === 'hoch' ? 'error' : tag.prioritaet === 'mittel' ? 'warning' : 'default'}
                        />
                      ))}
                    </Box>
                  ) : (
                    <Typography variant="body2" color="text.secondary">
                      Keine Wunsch-freien Tage definiert
                    </Typography>
                  )}
                </CardContent>
              </Card>
            </Grid>

            {/* Zusatzinfos */}
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                    Zusatzinfos
                  </Typography>
                  <Divider sx={{ my: 1 }} />
                  <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                    <Box>
                      <Typography variant="caption" color="text.secondary">Anmerkungen:</Typography>
                      <Typography variant="body2">
                        {anmerkungen || '-'}
                      </Typography>
                    </Box>
                    <Box>
                      <Typography variant="caption" color="text.secondary">Raumbedarf:</Typography>
                      <Typography variant="body2">
                        {raumbedarf || '-'}
                      </Typography>
                    </Box>
                  </Box>
                </CardContent>
              </Card>
            </Grid>

            {/* Metadaten */}
            <Grid item xs={12}>
              <Alert severity="info" icon={false}>
                <Typography variant="caption" color="text.secondary">
                  Erstellt: {template.created_at ? new Date(template.created_at).toLocaleString('de-DE') : '-'}
                  {' | '}
                  Zuletzt geändert: {template.updated_at ? new Date(template.updated_at).toLocaleString('de-DE') : '-'}
                </Typography>
              </Alert>
            </Grid>
          </Grid>
        </TabPanel>
      </Paper>
    </Container>
  );
};

export default TemplateDetail;
