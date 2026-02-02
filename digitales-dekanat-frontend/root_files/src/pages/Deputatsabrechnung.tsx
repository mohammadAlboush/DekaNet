import React, { useState, useEffect, useCallback } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Grid,
  Button,
  IconButton,
  Tabs,
  Tab,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
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
  FormControl,
  InputLabel,
  Select,
  FormControlLabel,
  Checkbox,
} from '@mui/material';
import {
  Add,
  Edit,
  Delete,
  ArrowBack,
  Send,
  ImportExport,
  CheckCircle,
  Warning,
  Error as ErrorIcon,
  PictureAsPdf,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';
import deputatService from '../services/deputatService';
import planungPhaseService from '../services/planungPhaseService';
import { createContextLogger } from '../utils/logger';
import { getErrorMessage } from '../utils/errorUtils';
import { PlanungPhase } from '../types/planungPhase.types';

const log = createContextLogger('Deputatsabrechnung');

import {
  Deputatsabrechnung as DeputatsabrechnungType,
  CreateLehrtaetigkeitData,
  CreateLehrexportData,
  CreateVertretungData,
  CreateErmaessigungData,
  CreateBetreuungData,
  LEHRTAETIGKEIT_KATEGORIEN,
  WOCHENTAGE,
  VERTRETUNG_ARTEN,
  BETREUUNGS_ARTEN,
  BETREUUNG_STATUS,
  DEPUTAT_STATUS,
  DEPUTAT_STATUS_COLORS,
  LehrtaetigkeitKategorie,
  Wochentag,
  VertretungArt,
  BetreuungsArt,
  BetreuungStatus,
  DeputatsLehrtaetigkeit,
  DeputatsLehrexport,
  DeputatsVertretung,
  DeputatsErmaessigung,
  DeputatsBetreuung,
} from '../types/deputat.types';

type EditItemType = DeputatsLehrtaetigkeit | DeputatsLehrexport | DeputatsVertretung | DeputatsErmaessigung | DeputatsBetreuung | null;
import { useToastStore } from '../components/common/Toast';

/**
 * Deputatsabrechnung - Professor-Ansicht
 * ======================================
 *
 * Features:
 * - Übersicht über eigene Deputatsabrechnung
 * - Import aus Planung und Semesteraufträgen
 * - Manuelle Eingabe von Lehrtätigkeiten, Lehrexport, Vertretungen, etc.
 * - Betreuungen verwalten
 * - Summen-Übersicht mit Warnungen
 * - Einreichen zur Genehmigung
 */

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;
  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && <Box sx={{ pt: 3 }}>{children}</Box>}
    </div>
  );
}

const Deputatsabrechnung: React.FC = () => {
  const navigate = useNavigate();
  const { planungsphaseId } = useParams<{ planungsphaseId: string }>();
  const showToast = useToastStore((state) => state.showToast);

  // State
  const [loading, setLoading] = useState(true);
  const [pdfLoading, setPdfLoading] = useState(false);
  const [abrechnung, setAbrechnung] = useState<DeputatsabrechnungType | null>(null);
  const [planungsphasen, setPlanungsphasen] = useState<PlanungPhase[]>([]);
  const [selectedPhaseId, setSelectedPhaseId] = useState<number | null>(
    planungsphaseId ? parseInt(planungsphaseId) : null
  );
  const [tabValue, setTabValue] = useState(0);

  // Dialog State
  const [dialogOpen, setDialogOpen] = useState(false);
  const [dialogType, setDialogType] = useState<
    'lehrtaetigkeit' | 'lehrexport' | 'vertretung' | 'ermaessigung' | 'betreuung' | null
  >(null);
  const [editItem, setEditItem] = useState<EditItemType>(null);

  // Form States
  const [lehrtaetigkeitForm, setLehrtaetigkeitForm] = useState<CreateLehrtaetigkeitData>({
    bezeichnung: '',
    sws: 0,
    kategorie: 'lehrveranstaltung',
    wochentag: undefined,
    ist_block: false,
  });

  const [lehrexportForm, setLehrexportForm] = useState<CreateLehrexportData>({
    fachbereich: '',
    fach: '',
    sws: 0,
  });

  const [vertretungForm, setVertretungForm] = useState<CreateVertretungData>({
    art: 'praxissemester',
    vertretene_person: '',
    fach_professor: '',
    sws: 0,
  });

  const [ermaessigungForm, setErmaessigungForm] = useState<CreateErmaessigungData>({
    bezeichnung: '',
    sws: 0,
  });

  const [betreuungForm, setBetreuungForm] = useState<CreateBetreuungData>({
    student_name: '',
    student_vorname: '',
    betreuungsart: 'bachelor',
    titel_arbeit: '',
    status: 'laufend',
    beginn_datum: '',
    ende_datum: '',
  });

  // Load Planungsphasen
  useEffect(() => {
    const loadPlanungsphasen = async () => {
      try {
        const response = await planungPhaseService.getAllPhases();
        const phasen = response.phasen || [];
        setPlanungsphasen(phasen);

        // Auto-select aktive Phase wenn keine ausgewählt
        if (!selectedPhaseId && phasen.length > 0) {
          const aktive = response.aktive_phase || phasen.find((p: PlanungPhase) => p.ist_aktiv);
          if (aktive) {
            setSelectedPhaseId(aktive.id);
          }
        }
      } catch (error) {
        log.error('Error loading planungsphasen:', error);
      }
    };

    loadPlanungsphasen();
  }, []);

  // Load Abrechnung wenn Phase ausgewählt
  useEffect(() => {
    if (selectedPhaseId) {
      loadAbrechnung();
    }
  }, [selectedPhaseId]);

  const loadAbrechnung = useCallback(async () => {
    if (!selectedPhaseId) return;

    try {
      setLoading(true);
      const data = await deputatService.getOrCreateAbrechnung({
        planungsphase_id: selectedPhaseId,
      });
      setAbrechnung(data);
    } catch (error) {
      log.error('Error loading abrechnung:', error);
      showToast('Fehler beim Laden der Abrechnung', 'error');
    } finally {
      setLoading(false);
    }
  }, [selectedPhaseId, showToast]);

  // Import Handlers
  const handleImportPlanung = async () => {
    if (!abrechnung) return;
    try {
      await deputatService.importPlanung(abrechnung.id);
      await loadAbrechnung();
      showToast('Planung importiert', 'success');
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Import'), 'error');
    }
  };

  const handleImportSemesterauftraege = async () => {
    if (!abrechnung) return;
    try {
      await deputatService.importSemesterauftraege(abrechnung.id);
      await loadAbrechnung();
      showToast('Semesteraufträge importiert', 'success');
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Import'), 'error');
    }
  };

  // Dialog Handlers
  const openDialog = (
    type: 'lehrtaetigkeit' | 'lehrexport' | 'vertretung' | 'ermaessigung' | 'betreuung',
    item?: EditItemType
  ) => {
    setDialogType(type);
    setEditItem(item || null);

    // Reset Forms
    if (type === 'lehrtaetigkeit') {
      setLehrtaetigkeitForm(
        item
          ? {
              bezeichnung: item.bezeichnung,
              sws: item.sws,
              kategorie: item.kategorie,
              wochentag: item.wochentag,
              ist_block: item.ist_block,
            }
          : {
              bezeichnung: '',
              sws: 0,
              kategorie: 'lehrveranstaltung',
              wochentag: undefined,
              ist_block: false,
            }
      );
    } else if (type === 'lehrexport') {
      setLehrexportForm(
        item
          ? { fachbereich: item.fachbereich, fach: item.fach, sws: item.sws }
          : { fachbereich: '', fach: '', sws: 0 }
      );
    } else if (type === 'vertretung') {
      setVertretungForm(
        item
          ? {
              art: item.art,
              vertretene_person: item.vertretene_person,
              fach_professor: item.fach_professor,
              sws: item.sws,
            }
          : { art: 'praxissemester', vertretene_person: '', fach_professor: '', sws: 0 }
      );
    } else if (type === 'ermaessigung') {
      setErmaessigungForm(
        item
          ? { bezeichnung: item.bezeichnung, sws: item.sws }
          : { bezeichnung: '', sws: 0 }
      );
    } else if (type === 'betreuung') {
      setBetreuungForm(
        item
          ? {
              student_name: item.student_name,
              student_vorname: item.student_vorname,
              betreuungsart: item.betreuungsart,
              titel_arbeit: item.titel_arbeit || '',
              status: item.status,
              beginn_datum: item.beginn_datum || '',
              ende_datum: item.ende_datum || '',
            }
          : {
              student_name: '',
              student_vorname: '',
              betreuungsart: 'bachelor',
              titel_arbeit: '',
              status: 'laufend',
              beginn_datum: '',
              ende_datum: '',
            }
      );
    }

    setDialogOpen(true);
  };

  const closeDialog = () => {
    setDialogOpen(false);
    setDialogType(null);
    setEditItem(null);
  };

  // Save Handlers
  const handleSave = async () => {
    if (!abrechnung || !dialogType) return;

    try {
      switch (dialogType) {
        case 'lehrtaetigkeit':
          if (editItem) {
            await deputatService.updateLehrtaetigkeit(editItem.id, lehrtaetigkeitForm);
          } else {
            await deputatService.addLehrtaetigkeit(abrechnung.id, lehrtaetigkeitForm);
          }
          break;
        case 'lehrexport':
          if (editItem) {
            await deputatService.updateLehrexport(editItem.id, lehrexportForm);
          } else {
            await deputatService.addLehrexport(abrechnung.id, lehrexportForm);
          }
          break;
        case 'vertretung':
          if (editItem) {
            await deputatService.updateVertretung(editItem.id, vertretungForm);
          } else {
            await deputatService.addVertretung(abrechnung.id, vertretungForm);
          }
          break;
        case 'ermaessigung':
          if (editItem) {
            await deputatService.updateErmaessigung(editItem.id, ermaessigungForm);
          } else {
            await deputatService.addErmaessigung(abrechnung.id, ermaessigungForm);
          }
          break;
        case 'betreuung':
          if (editItem) {
            await deputatService.updateBetreuung(editItem.id, betreuungForm);
          } else {
            await deputatService.addBetreuung(abrechnung.id, betreuungForm);
          }
          break;
      }

      await loadAbrechnung();
      closeDialog();
      showToast('Gespeichert', 'success');
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Speichern'), 'error');
    }
  };

  // Delete Handlers
  const handleDelete = async (
    type: 'lehrtaetigkeit' | 'lehrexport' | 'vertretung' | 'ermaessigung' | 'betreuung',
    id: number
  ) => {
    if (!confirm('Wirklich löschen?')) return;

    try {
      switch (type) {
        case 'lehrtaetigkeit':
          await deputatService.deleteLehrtaetigkeit(id);
          break;
        case 'lehrexport':
          await deputatService.deleteLehrexport(id);
          break;
        case 'vertretung':
          await deputatService.deleteVertretung(id);
          break;
        case 'ermaessigung':
          await deputatService.deleteErmaessigung(id);
          break;
        case 'betreuung':
          await deputatService.deleteBetreuung(id);
          break;
      }

      await loadAbrechnung();
      showToast('Gelöscht', 'success');
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Löschen'), 'error');
    }
  };

  // Workflow Handlers
  const handleEinreichen = async () => {
    if (!abrechnung) return;
    if (!confirm('Abrechnung wirklich einreichen? Sie kann danach nicht mehr bearbeitet werden.')) return;

    try {
      await deputatService.einreichen(abrechnung.id);
      await loadAbrechnung();
      showToast('Abrechnung eingereicht', 'success');
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Einreichen'), 'error');
    }
  };

  const handleZuruecksetzen = async () => {
    if (!abrechnung) return;
    if (!confirm('Abrechnung wirklich zurücksetzen?')) return;

    try {
      await deputatService.zuruecksetzen(abrechnung.id);
      await loadAbrechnung();
      showToast('Abrechnung zurückgesetzt', 'success');
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim Zurücksetzen'), 'error');
    }
  };

  // PDF Export Handler
  const handlePdfExport = async () => {
    if (!abrechnung) return;

    try {
      setPdfLoading(true);
      await deputatService.downloadPdf(abrechnung.id);
      showToast('PDF wurde heruntergeladen', 'success');
    } catch (error: unknown) {
      showToast(getErrorMessage(error, 'Fehler beim PDF-Export'), 'error');
    } finally {
      setPdfLoading(false);
    }
  };

  // Render Loading
  if (loading && !abrechnung) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
          <CircularProgress />
        </Box>
      </Container>
    );
  }

  const summen = abrechnung?.summen;
  const kannBearbeiten = abrechnung && deputatService.kannBearbeitetWerden(abrechnung);
  const kannEinreichen = abrechnung && deputatService.kannEingereichtWerden(abrechnung);

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box display="flex" alignItems="center" gap={2}>
          <IconButton onClick={() => navigate(-1)}>
            <ArrowBack />
          </IconButton>
          <Typography variant="h4">Deputatsabrechnung</Typography>
        </Box>

        <FormControl sx={{ minWidth: 250 }}>
          <InputLabel>Planungsphase</InputLabel>
          <Select
            value={selectedPhaseId || ''}
            label="Planungsphase"
            onChange={(e) => setSelectedPhaseId(Number(e.target.value))}
          >
            {planungsphasen.map((phase) => (
              <MenuItem key={phase.id} value={phase.id}>
                {phase.name} {phase.is_aktiv && '(aktiv)'}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>

      {/* Status & Summen Card */}
      {abrechnung && summen && (
        <Grid container spacing={3} sx={{ mb: 3 }}>
          {/* Status Card */}
          <Grid item xs={12} md={4}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Status
                </Typography>
                <Chip
                  label={DEPUTAT_STATUS[abrechnung.status]}
                  color={DEPUTAT_STATUS_COLORS[abrechnung.status]}
                  sx={{ mb: 2 }}
                />
                {abrechnung.status === 'abgelehnt' && abrechnung.ablehnungsgrund && (
                  <Alert severity="error" sx={{ mt: 1 }}>
                    {abrechnung.ablehnungsgrund}
                  </Alert>
                )}
                <Box sx={{ mt: 2 }}>
                  {kannEinreichen && (
                    <Button
                      variant="contained"
                      color="primary"
                      startIcon={<Send />}
                      onClick={handleEinreichen}
                      fullWidth
                    >
                      Einreichen
                    </Button>
                  )}
                  {abrechnung.status === 'abgelehnt' && (
                    <Button
                      variant="outlined"
                      onClick={handleZuruecksetzen}
                      fullWidth
                      sx={{ mt: 1 }}
                    >
                      Zur Bearbeitung zurücksetzen
                    </Button>
                  )}
                  <Button
                    variant="outlined"
                    color="secondary"
                    startIcon={pdfLoading ? <CircularProgress size={20} /> : <PictureAsPdf />}
                    onClick={handlePdfExport}
                    disabled={pdfLoading}
                    fullWidth
                    sx={{ mt: 1 }}
                  >
                    {pdfLoading ? 'Wird erstellt...' : 'PDF exportieren'}
                  </Button>
                </Box>
              </CardContent>
            </Card>
          </Grid>

          {/* Summen Card */}
          <Grid item xs={12} md={4}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Deputat-Übersicht
                </Typography>
                <Box sx={{ mb: 2 }}>
                  <Typography variant="body2" color="text.secondary">
                    Netto-Lehrverpflichtung
                  </Typography>
                  <Typography variant="h5">{summen.netto_lehrverpflichtung} SWS</Typography>
                </Box>
                <Box sx={{ mb: 2 }}>
                  <Typography variant="body2" color="text.secondary">
                    Gesamtdeputat
                  </Typography>
                  <Typography variant="h5">{summen.gesamtdeputat} SWS</Typography>
                </Box>
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    Nettobelastung (nach Ermäßigungen)
                  </Typography>
                  <Typography variant="h5">{summen.nettobelastung} SWS</Typography>
                </Box>
              </CardContent>
            </Card>
          </Grid>

          {/* Bewertung Card */}
          <Grid item xs={12} md={4}>
            <Card>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Bewertung
                </Typography>
                <Box display="flex" alignItems="center" gap={1} mb={2}>
                  {summen.bewertung === 'erfuellt' && (
                    <CheckCircle color="success" fontSize="large" />
                  )}
                  {summen.bewertung === 'abweichung' && (
                    <Warning color="warning" fontSize="large" />
                  )}
                  {summen.bewertung === 'starke_abweichung' && (
                    <ErrorIcon color="error" fontSize="large" />
                  )}
                  <Box>
                    <Typography variant="h6">
                      {deputatService.getBewertungText(summen.bewertung)}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Differenz: {summen.differenz > 0 ? '+' : ''}
                      {summen.differenz} SWS
                    </Typography>
                  </Box>
                </Box>

                {summen.warnungen.length > 0 && (
                  <Box>
                    <Typography variant="subtitle2" color="warning.main" gutterBottom>
                      Warnungen:
                    </Typography>
                    {summen.warnungen.map((w, i) => (
                      <Alert key={i} severity="warning" sx={{ mb: 1 }}>
                        {w}
                      </Alert>
                    ))}
                  </Box>
                )}
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      )}

      {/* Import Buttons */}
      {kannBearbeiten && (
        <Paper sx={{ p: 2, mb: 3 }}>
          <Typography variant="subtitle1" gutterBottom>
            Daten importieren
          </Typography>
          <Box display="flex" gap={2}>
            <Button
              variant="outlined"
              startIcon={<ImportExport />}
              onClick={handleImportPlanung}
            >
              Aus Planung importieren
            </Button>
            <Button
              variant="outlined"
              startIcon={<ImportExport />}
              onClick={handleImportSemesterauftraege}
            >
              Ermäßigungen aus Semesteraufträgen
            </Button>
          </Box>
        </Paper>
      )}

      {/* Tabs */}
      <Paper sx={{ mb: 3 }}>
        <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)}>
          <Tab label={`Lehrtätigkeiten (${summen?.anzahl_lehrtaetigkeiten || 0})`} />
          <Tab label={`Lehrexport (${summen?.anzahl_lehrexporte || 0})`} />
          <Tab label={`Vertretungen (${summen?.anzahl_vertretungen || 0})`} />
          <Tab label={`Ermäßigungen (${summen?.anzahl_ermaessigungen || 0})`} />
          <Tab label={`Betreuungen (${summen?.anzahl_betreuungen || 0})`} />
        </Tabs>

        {/* Lehrtätigkeiten */}
        <TabPanel value={tabValue} index={0}>
          <Box sx={{ p: 2 }}>
            {kannBearbeiten && (
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={() => openDialog('lehrtaetigkeit')}
                sx={{ mb: 2 }}
              >
                Lehrtätigkeit hinzufügen
              </Button>
            )}
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Bezeichnung</TableCell>
                    <TableCell>Kategorie</TableCell>
                    <TableCell>Wochentag</TableCell>
                    <TableCell align="right">SWS</TableCell>
                    <TableCell>Quelle</TableCell>
                    {kannBearbeiten && <TableCell>Aktionen</TableCell>}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {abrechnung?.lehrtaetigkeiten?.map((lt) => (
                    <TableRow key={lt.id}>
                      <TableCell>{lt.bezeichnung}</TableCell>
                      <TableCell>
                        <Chip
                          size="small"
                          label={LEHRTAETIGKEIT_KATEGORIEN[lt.kategorie]}
                        />
                      </TableCell>
                      <TableCell>
                        {lt.ist_block ? 'Block' : lt.wochentag ? WOCHENTAGE[lt.wochentag] : '-'}
                      </TableCell>
                      <TableCell align="right">{lt.sws}</TableCell>
                      <TableCell>
                        <Chip
                          size="small"
                          variant="outlined"
                          label={lt.quelle === 'planung' ? 'Planung' : 'Manuell'}
                        />
                      </TableCell>
                      {kannBearbeiten && (
                        <TableCell>
                          <IconButton size="small" onClick={() => openDialog('lehrtaetigkeit', lt)}>
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={() => handleDelete('lehrtaetigkeit', lt.id)}
                          >
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                  {(!abrechnung?.lehrtaetigkeiten || abrechnung.lehrtaetigkeiten.length === 0) && (
                    <TableRow>
                      <TableCell colSpan={6} align="center">
                        Keine Lehrtätigkeiten vorhanden
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
            {summen && (
              <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle2">
                  Gesamt Lehrtätigkeiten: {summen.sws_lehrtaetigkeiten} SWS
                </Typography>
              </Box>
            )}
          </Box>
        </TabPanel>

        {/* Lehrexport */}
        <TabPanel value={tabValue} index={1}>
          <Box sx={{ p: 2 }}>
            {kannBearbeiten && (
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={() => openDialog('lehrexport')}
                sx={{ mb: 2 }}
              >
                Lehrexport hinzufügen
              </Button>
            )}
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Fachbereich</TableCell>
                    <TableCell>Fach</TableCell>
                    <TableCell align="right">SWS</TableCell>
                    {kannBearbeiten && <TableCell>Aktionen</TableCell>}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {abrechnung?.lehrexporte?.map((le) => (
                    <TableRow key={le.id}>
                      <TableCell>{le.fachbereich}</TableCell>
                      <TableCell>{le.fach}</TableCell>
                      <TableCell align="right">{le.sws}</TableCell>
                      {kannBearbeiten && (
                        <TableCell>
                          <IconButton size="small" onClick={() => openDialog('lehrexport', le)}>
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={() => handleDelete('lehrexport', le.id)}
                          >
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                  {(!abrechnung?.lehrexporte || abrechnung.lehrexporte.length === 0) && (
                    <TableRow>
                      <TableCell colSpan={4} align="center">
                        Kein Lehrexport vorhanden
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
            {summen && (
              <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle2">
                  Gesamt Lehrexport: {summen.sws_lehrexport} SWS
                </Typography>
              </Box>
            )}
          </Box>
        </TabPanel>

        {/* Vertretungen */}
        <TabPanel value={tabValue} index={2}>
          <Box sx={{ p: 2 }}>
            {kannBearbeiten && (
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={() => openDialog('vertretung')}
                sx={{ mb: 2 }}
              >
                Vertretung hinzufügen
              </Button>
            )}
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Art</TableCell>
                    <TableCell>Vertretene Person</TableCell>
                    <TableCell>Fach</TableCell>
                    <TableCell align="right">SWS</TableCell>
                    {kannBearbeiten && <TableCell>Aktionen</TableCell>}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {abrechnung?.vertretungen?.map((v) => (
                    <TableRow key={v.id}>
                      <TableCell>{VERTRETUNG_ARTEN[v.art]}</TableCell>
                      <TableCell>{v.vertretene_person}</TableCell>
                      <TableCell>{v.fach_professor}</TableCell>
                      <TableCell align="right">{v.sws}</TableCell>
                      {kannBearbeiten && (
                        <TableCell>
                          <IconButton size="small" onClick={() => openDialog('vertretung', v)}>
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={() => handleDelete('vertretung', v.id)}
                          >
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                  {(!abrechnung?.vertretungen || abrechnung.vertretungen.length === 0) && (
                    <TableRow>
                      <TableCell colSpan={5} align="center">
                        Keine Vertretungen vorhanden
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
            {summen && (
              <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle2">
                  Gesamt Vertretungen: {summen.sws_vertretungen} SWS
                </Typography>
              </Box>
            )}
          </Box>
        </TabPanel>

        {/* Ermäßigungen */}
        <TabPanel value={tabValue} index={3}>
          <Box sx={{ p: 2 }}>
            {kannBearbeiten && (
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={() => openDialog('ermaessigung')}
                sx={{ mb: 2 }}
              >
                Ermäßigung hinzufügen
              </Button>
            )}
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Bezeichnung</TableCell>
                    <TableCell align="right">SWS</TableCell>
                    <TableCell>Quelle</TableCell>
                    {kannBearbeiten && <TableCell>Aktionen</TableCell>}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {abrechnung?.ermaessigungen?.map((e) => (
                    <TableRow key={e.id}>
                      <TableCell>{e.bezeichnung}</TableCell>
                      <TableCell align="right">{e.sws}</TableCell>
                      <TableCell>
                        <Chip
                          size="small"
                          variant="outlined"
                          label={e.quelle === 'semesterauftrag' ? 'Semesterauftrag' : 'Manuell'}
                        />
                      </TableCell>
                      {kannBearbeiten && e.quelle === 'manuell' && (
                        <TableCell>
                          <IconButton size="small" onClick={() => openDialog('ermaessigung', e)}>
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={() => handleDelete('ermaessigung', e.id)}
                          >
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      )}
                      {kannBearbeiten && e.quelle !== 'manuell' && <TableCell>-</TableCell>}
                    </TableRow>
                  ))}
                  {(!abrechnung?.ermaessigungen || abrechnung.ermaessigungen.length === 0) && (
                    <TableRow>
                      <TableCell colSpan={4} align="center">
                        Keine Ermäßigungen vorhanden
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
            {summen && (
              <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle2">
                  Gesamt Ermäßigungen: {summen.sws_ermaessigungen} SWS
                </Typography>
              </Box>
            )}
          </Box>
        </TabPanel>

        {/* Betreuungen */}
        <TabPanel value={tabValue} index={4}>
          <Box sx={{ p: 2 }}>
            {kannBearbeiten && (
              <Button
                variant="contained"
                startIcon={<Add />}
                onClick={() => openDialog('betreuung')}
                sx={{ mb: 2 }}
              >
                Betreuung hinzufügen
              </Button>
            )}
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Student</TableCell>
                    <TableCell>Art</TableCell>
                    <TableCell>Titel</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell align="right">SWS</TableCell>
                    {kannBearbeiten && <TableCell>Aktionen</TableCell>}
                  </TableRow>
                </TableHead>
                <TableBody>
                  {abrechnung?.betreuungen?.map((b) => (
                    <TableRow key={b.id}>
                      <TableCell>{b.student_name_komplett}</TableCell>
                      <TableCell>{BETREUUNGS_ARTEN[b.betreuungsart]}</TableCell>
                      <TableCell>{b.titel_arbeit || '-'}</TableCell>
                      <TableCell>
                        <Chip
                          size="small"
                          color={b.status === 'abgeschlossen' ? 'success' : 'default'}
                          label={BETREUUNG_STATUS[b.status]}
                        />
                      </TableCell>
                      <TableCell align="right">{b.sws}</TableCell>
                      {kannBearbeiten && (
                        <TableCell>
                          <IconButton size="small" onClick={() => openDialog('betreuung', b)}>
                            <Edit fontSize="small" />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={() => handleDelete('betreuung', b.id)}
                          >
                            <Delete fontSize="small" />
                          </IconButton>
                        </TableCell>
                      )}
                    </TableRow>
                  ))}
                  {(!abrechnung?.betreuungen || abrechnung.betreuungen.length === 0) && (
                    <TableRow>
                      <TableCell colSpan={6} align="center">
                        Keine Betreuungen vorhanden
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
            {summen && (
              <Box sx={{ mt: 2, p: 2, bgcolor: 'grey.100', borderRadius: 1 }}>
                <Typography variant="subtitle2">
                  Betreuungen roh: {summen.sws_betreuungen_roh} SWS |
                  Angerechnet (max): {summen.sws_betreuungen_angerechnet} SWS
                </Typography>
              </Box>
            )}
          </Box>
        </TabPanel>
      </Paper>

      {/* Dialogs */}
      <Dialog open={dialogOpen} onClose={closeDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editItem ? 'Bearbeiten' : 'Hinzufügen'}
        </DialogTitle>
        <DialogContent>
          {/* Lehrtätigkeit Form */}
          {dialogType === 'lehrtaetigkeit' && (
            <Box sx={{ pt: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <TextField
                label="Bezeichnung"
                fullWidth
                value={lehrtaetigkeitForm.bezeichnung}
                onChange={(e) =>
                  setLehrtaetigkeitForm({ ...lehrtaetigkeitForm, bezeichnung: e.target.value })
                }
              />
              <TextField
                label="SWS"
                type="number"
                fullWidth
                value={lehrtaetigkeitForm.sws}
                onChange={(e) =>
                  setLehrtaetigkeitForm({ ...lehrtaetigkeitForm, sws: parseFloat(e.target.value) })
                }
                inputProps={{ step: 0.5 }}
              />
              <FormControl fullWidth>
                <InputLabel>Kategorie</InputLabel>
                <Select
                  value={lehrtaetigkeitForm.kategorie}
                  label="Kategorie"
                  onChange={(e) =>
                    setLehrtaetigkeitForm({
                      ...lehrtaetigkeitForm,
                      kategorie: e.target.value as LehrtaetigkeitKategorie,
                    })
                  }
                >
                  {Object.entries(LEHRTAETIGKEIT_KATEGORIEN).map(([key, label]) => (
                    <MenuItem key={key} value={key}>
                      {label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <FormControlLabel
                control={
                  <Checkbox
                    checked={lehrtaetigkeitForm.ist_block}
                    onChange={(e) =>
                      setLehrtaetigkeitForm({ ...lehrtaetigkeitForm, ist_block: e.target.checked })
                    }
                  />
                }
                label="Blockveranstaltung"
              />
              {!lehrtaetigkeitForm.ist_block && (
                <FormControl fullWidth>
                  <InputLabel>Wochentag</InputLabel>
                  <Select
                    value={lehrtaetigkeitForm.wochentag || ''}
                    label="Wochentag"
                    onChange={(e) =>
                      setLehrtaetigkeitForm({
                        ...lehrtaetigkeitForm,
                        wochentag: e.target.value as Wochentag | undefined,
                      })
                    }
                  >
                    <MenuItem value="">-</MenuItem>
                    {Object.entries(WOCHENTAGE).map(([key, label]) => (
                      <MenuItem key={key} value={key}>
                        {label}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>
              )}
            </Box>
          )}

          {/* Lehrexport Form */}
          {dialogType === 'lehrexport' && (
            <Box sx={{ pt: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <TextField
                label="Fachbereich"
                fullWidth
                value={lehrexportForm.fachbereich}
                onChange={(e) =>
                  setLehrexportForm({ ...lehrexportForm, fachbereich: e.target.value })
                }
              />
              <TextField
                label="Fach"
                fullWidth
                value={lehrexportForm.fach}
                onChange={(e) => setLehrexportForm({ ...lehrexportForm, fach: e.target.value })}
              />
              <TextField
                label="SWS"
                type="number"
                fullWidth
                value={lehrexportForm.sws}
                onChange={(e) =>
                  setLehrexportForm({ ...lehrexportForm, sws: parseFloat(e.target.value) })
                }
                inputProps={{ step: 0.5 }}
              />
            </Box>
          )}

          {/* Vertretung Form */}
          {dialogType === 'vertretung' && (
            <Box sx={{ pt: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <FormControl fullWidth>
                <InputLabel>Art</InputLabel>
                <Select
                  value={vertretungForm.art}
                  label="Art"
                  onChange={(e) =>
                    setVertretungForm({
                      ...vertretungForm,
                      art: e.target.value as VertretungArt,
                    })
                  }
                >
                  {Object.entries(VERTRETUNG_ARTEN).map(([key, label]) => (
                    <MenuItem key={key} value={key}>
                      {label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                label="Vertretene Person"
                fullWidth
                value={vertretungForm.vertretene_person}
                onChange={(e) =>
                  setVertretungForm({ ...vertretungForm, vertretene_person: e.target.value })
                }
              />
              <TextField
                label="Fach des Professors"
                fullWidth
                value={vertretungForm.fach_professor}
                onChange={(e) =>
                  setVertretungForm({ ...vertretungForm, fach_professor: e.target.value })
                }
              />
              <TextField
                label="SWS"
                type="number"
                fullWidth
                value={vertretungForm.sws}
                onChange={(e) =>
                  setVertretungForm({ ...vertretungForm, sws: parseFloat(e.target.value) })
                }
                inputProps={{ step: 0.5 }}
              />
            </Box>
          )}

          {/* Ermäßigung Form */}
          {dialogType === 'ermaessigung' && (
            <Box sx={{ pt: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <TextField
                label="Bezeichnung"
                fullWidth
                value={ermaessigungForm.bezeichnung}
                onChange={(e) =>
                  setErmaessigungForm({ ...ermaessigungForm, bezeichnung: e.target.value })
                }
              />
              <TextField
                label="SWS"
                type="number"
                fullWidth
                value={ermaessigungForm.sws}
                onChange={(e) =>
                  setErmaessigungForm({ ...ermaessigungForm, sws: parseFloat(e.target.value) })
                }
                inputProps={{ step: 0.5 }}
              />
            </Box>
          )}

          {/* Betreuung Form */}
          {dialogType === 'betreuung' && (
            <Box sx={{ pt: 2, display: 'flex', flexDirection: 'column', gap: 2 }}>
              <TextField
                label="Vorname"
                fullWidth
                value={betreuungForm.student_vorname}
                onChange={(e) =>
                  setBetreuungForm({ ...betreuungForm, student_vorname: e.target.value })
                }
              />
              <TextField
                label="Nachname"
                fullWidth
                value={betreuungForm.student_name}
                onChange={(e) =>
                  setBetreuungForm({ ...betreuungForm, student_name: e.target.value })
                }
              />
              <FormControl fullWidth>
                <InputLabel>Art der Betreuung</InputLabel>
                <Select
                  value={betreuungForm.betreuungsart}
                  label="Art der Betreuung"
                  onChange={(e) =>
                    setBetreuungForm({
                      ...betreuungForm,
                      betreuungsart: e.target.value as BetreuungsArt,
                    })
                  }
                >
                  {Object.entries(BETREUUNGS_ARTEN).map(([key, label]) => (
                    <MenuItem key={key} value={key}>
                      {label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                label="Titel der Arbeit (optional)"
                fullWidth
                value={betreuungForm.titel_arbeit}
                onChange={(e) =>
                  setBetreuungForm({ ...betreuungForm, titel_arbeit: e.target.value })
                }
              />
              <FormControl fullWidth>
                <InputLabel>Status</InputLabel>
                <Select
                  value={betreuungForm.status}
                  label="Status"
                  onChange={(e) =>
                    setBetreuungForm({
                      ...betreuungForm,
                      status: e.target.value as BetreuungStatus,
                    })
                  }
                >
                  {Object.entries(BETREUUNG_STATUS).map(([key, label]) => (
                    <MenuItem key={key} value={key}>
                      {label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                label="Beginn"
                type="date"
                fullWidth
                InputLabelProps={{ shrink: true }}
                value={betreuungForm.beginn_datum}
                onChange={(e) =>
                  setBetreuungForm({ ...betreuungForm, beginn_datum: e.target.value })
                }
              />
              <TextField
                label="Ende"
                type="date"
                fullWidth
                InputLabelProps={{ shrink: true }}
                value={betreuungForm.ende_datum}
                onChange={(e) =>
                  setBetreuungForm({ ...betreuungForm, ende_datum: e.target.value })
                }
              />
            </Box>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={closeDialog}>Abbrechen</Button>
          <Button onClick={handleSave} variant="contained">
            Speichern
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default Deputatsabrechnung;
