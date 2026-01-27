import React, { useState, useEffect, useCallback } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Button,
  IconButton,
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
  FormControl,
  InputLabel,
  Select,
  FormControlLabel,
  Checkbox,
  Autocomplete,
  Tooltip,
  Stack,
  SelectChangeEvent,
  OutlinedInput,
} from '@mui/material';
import {
  Add,
  Delete,
  ArrowBack,
  Send,
  Sync,
  CheckCircle,
  Warning,
  Error as ErrorIcon,
  PictureAsPdf,
  Lock,
} from '@mui/icons-material';
import { useNavigate, useParams } from 'react-router-dom';
import deputatService from '../services/deputatService';
import planungPhaseService from '../services/planungPhaseService';
import modulService from '../services/modulService';
import auftragService from '../services/auftragService';
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
  DEPUTAT_STATUS,
  LehrtaetigkeitKategorie,
  Wochentag,
  VertretungArt,
  BetreuungsArt,
  DeputatsLehrtaetigkeit,
} from '../types/deputat.types';
import { useToastStore } from '../components/common/Toast';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('DeputatsabrechnungNeu');

// Wochentage für Anzeige
const WOCHENTAG_REVERSE_MAP: Record<Wochentag, string> = {
  'montag': 'Mo',
  'dienstag': 'Di',
  'mittwoch': 'Mi',
  'donnerstag': 'Do',
  'freitag': 'Fr',
};

// Einfacher Section-Header
const SectionRow: React.FC<{ title: string; sws?: number; colSpan: number }> = ({ title, sws, colSpan }) => (
  <TableRow sx={{ bgcolor: '#f5f5f5' }}>
    <TableCell colSpan={colSpan} sx={{ fontWeight: 600, py: 1.5, borderBottom: '2px solid #e0e0e0' }}>
      {title}
      {sws !== undefined && (
        <Typography component="span" sx={{ float: 'right', color: 'text.secondary' }}>
          {sws} SWS
        </Typography>
      )}
    </TableCell>
  </TableRow>
);

const DeputatsabrechnungNeu: React.FC = () => {
  const navigate = useNavigate();
  const { planungsphaseId } = useParams<{ planungsphaseId: string }>();
  const showToast = useToastStore((state) => state.showToast);

  // State
  const [loading, setLoading] = useState(true);
  const [syncing, setSyncing] = useState(false);
  const [pdfLoading, setPdfLoading] = useState(false);
  const [abrechnung, setAbrechnung] = useState<DeputatsabrechnungType | null>(null);
  const [planungsphasen, setPlanungsphasen] = useState<any[]>([]);
  const [selectedPhaseId, setSelectedPhaseId] = useState<number | null>(
    planungsphaseId ? parseInt(planungsphaseId) : null
  );
  const [module, setModule] = useState<any[]>([]);
  const [auftraege, setAuftraege] = useState<any[]>([]);

  // Dialog State
  const [dialogOpen, setDialogOpen] = useState(false);
  const [dialogType, setDialogType] = useState<
    'lehrtaetigkeit' | 'lehrexport' | 'vertretung' | 'ermaessigung' | 'betreuung' | null
  >(null);

  // Form States
  const [selectedModul, setSelectedModul] = useState<any | null>(null);
  const [selectedAuftrag, setSelectedAuftrag] = useState<any | null>(null);
  const [selectedWochentage, setSelectedWochentage] = useState<Wochentag[]>([]);
  const [lehrtaetigkeitForm, setLehrtaetigkeitForm] = useState<CreateLehrtaetigkeitData>({
    bezeichnung: '',
    sws: 0,
    kategorie: 'lehrveranstaltung',
    wochentage: [],
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

        if (!selectedPhaseId && phasen.length > 0) {
          const aktive = response.aktive_phase || phasen.find((p: any) => p.ist_aktiv);
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

  // Load Module
  useEffect(() => {
    const loadModule = async () => {
      try {
        const response = await modulService.getAllModule();
        setModule(response || []);
      } catch (error) {
        log.error('Error loading module:', error);
      }
    };
    loadModule();
  }, []);

  // Load Aufträge
  useEffect(() => {
    const loadAuftraege = async () => {
      try {
        const response = await auftragService.getAlleAuftraege();
        setAuftraege(response || []);
      } catch (error) {
        log.error('Error loading auftraege:', error);
      }
    };
    loadAuftraege();
  }, []);

  // Load/Sync Abrechnung
  useEffect(() => {
    if (selectedPhaseId) {
      loadAndSyncAbrechnung();
    }
  }, [selectedPhaseId]);

  const loadAndSyncAbrechnung = useCallback(async () => {
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

  // Manueller Sync
  const handleManualSync = async () => {
    if (!abrechnung) return;
    try {
      setSyncing(true);
      const result = await deputatService.syncAbrechnung(abrechnung.id);
      setAbrechnung(result.data);

      const { planung, auftraege } = result.sync_result;
      const changes = planung.hinzugefuegt + planung.aktualisiert + auftraege.hinzugefuegt + auftraege.aktualisiert;

      if (changes > 0) {
        showToast(`Synchronisiert: ${planung.hinzugefuegt + auftraege.hinzugefuegt} hinzugefuegt`, 'success');
      } else {
        showToast('Bereits synchronisiert', 'info');
      }
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler bei der Synchronisation', 'error');
    } finally {
      setSyncing(false);
    }
  };

  // Workflow Handlers
  const handleEinreichen = async () => {
    if (!abrechnung) return;
    if (!confirm('Abrechnung wirklich einreichen?')) return;

    try {
      await deputatService.einreichen(abrechnung.id);
      await loadAndSyncAbrechnung();
      showToast('Abrechnung eingereicht', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler beim Einreichen', 'error');
    }
  };

  const handleZuruecksetzen = async () => {
    if (!abrechnung) return;
    if (!confirm('Abrechnung zuruecksetzen?')) return;

    try {
      await deputatService.zuruecksetzen(abrechnung.id);
      await loadAndSyncAbrechnung();
      showToast('Zurueckgesetzt', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler', 'error');
    }
  };

  const handlePdfExport = async () => {
    if (!abrechnung) return;
    try {
      setPdfLoading(true);
      await deputatService.downloadPdf(abrechnung.id);
      showToast('PDF heruntergeladen', 'success');
    } catch (error: any) {
      showToast('Fehler beim PDF-Export', 'error');
    } finally {
      setPdfLoading(false);
    }
  };

  // Dialog Handlers
  const openDialog = (type: typeof dialogType) => {
    setDialogType(type);
    setSelectedModul(null);
    setSelectedAuftrag(null);
    setSelectedWochentage([]);
    setLehrtaetigkeitForm({ bezeichnung: '', sws: 0, kategorie: 'lehrveranstaltung', wochentage: [], ist_block: false });
    setLehrexportForm({ fachbereich: '', fach: '', sws: 0 });
    setVertretungForm({ art: 'praxissemester', vertretene_person: '', fach_professor: '', sws: 0 });
    setErmaessigungForm({ bezeichnung: '', sws: 0 });
    setBetreuungForm({ student_name: '', student_vorname: '', betreuungsart: 'bachelor', titel_arbeit: '', status: 'laufend', beginn_datum: '', ende_datum: '' });
    setDialogOpen(true);
  };

  const closeDialog = () => {
    setDialogOpen(false);
    setDialogType(null);
  };

  // Hilfsfunktion: Modul-Anzeigename
  const getModulDisplayName = (modul: any): string => {
    if (!modul) return '';
    // Prüfe verschiedene mögliche Felder
    if (modul.display_name) return modul.display_name;
    if (modul.bezeichnung_de) {
      return modul.kuerzel ? `${modul.kuerzel} - ${modul.bezeichnung_de}` : modul.bezeichnung_de;
    }
    if (modul.name) return modul.name;
    return modul.kuerzel || '';
  };

  // Bei Modul-Auswahl
  const handleModulSelect = (modul: any) => {
    setSelectedModul(modul);
    if (modul) {
      setLehrtaetigkeitForm({
        ...lehrtaetigkeitForm,
        bezeichnung: getModulDisplayName(modul),
        sws: modul.sws_gesamt || modul.sws || 0,
      });
    } else {
      setLehrtaetigkeitForm({
        ...lehrtaetigkeitForm,
        bezeichnung: '',
        sws: 0,
      });
    }
  };

  // Bei Auftrag-Auswahl
  const handleAuftragSelect = (auftrag: any) => {
    setSelectedAuftrag(auftrag);
    if (auftrag) {
      setErmaessigungForm({
        ...ermaessigungForm,
        bezeichnung: auftrag.name,
        sws: auftrag.standard_sws || 0,
      });
    } else {
      setErmaessigungForm({
        ...ermaessigungForm,
        bezeichnung: '',
        sws: 0,
      });
    }
  };

  // Wochentage Multi-Select Handler
  const handleWochentageChange = (event: SelectChangeEvent<typeof selectedWochentage>) => {
    const value = event.target.value;
    const newWochentage = typeof value === 'string' ? value.split(',') as Wochentag[] : value;
    setSelectedWochentage(newWochentage);
    setLehrtaetigkeitForm({ ...lehrtaetigkeitForm, wochentage: newWochentage, ist_block: false });
  };

  // Save Handlers
  const handleSave = async () => {
    if (!abrechnung || !dialogType) return;

    try {
      switch (dialogType) {
        case 'lehrtaetigkeit':
          if (!selectedModul) {
            showToast('Bitte waehlen Sie ein Modul aus', 'error');
            return;
          }
          await deputatService.addLehrtaetigkeit(abrechnung.id, {
            ...lehrtaetigkeitForm,
            wochentage: selectedWochentage,
          });
          break;
        case 'lehrexport':
          await deputatService.addLehrexport(abrechnung.id, lehrexportForm);
          break;
        case 'vertretung':
          await deputatService.addVertretung(abrechnung.id, vertretungForm);
          break;
        case 'ermaessigung':
          if (!selectedAuftrag) {
            showToast('Bitte waehlen Sie eine Funktion aus', 'error');
            return;
          }
          await deputatService.addErmaessigung(abrechnung.id, ermaessigungForm);
          break;
        case 'betreuung':
          await deputatService.addBetreuung(abrechnung.id, betreuungForm);
          break;
      }

      await loadAndSyncAbrechnung();
      closeDialog();
      showToast('Hinzugefuegt', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler', 'error');
    }
  };

  // Delete Handler
  const handleDelete = async (
    type: 'lehrtaetigkeit' | 'lehrexport' | 'vertretung' | 'ermaessigung' | 'betreuung',
    id: number
  ) => {
    if (!confirm('Eintrag loeschen?')) return;

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

      await loadAndSyncAbrechnung();
      showToast('Geloescht', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler', 'error');
    }
  };

  // Computed values
  const summen = abrechnung?.summen;
  const kannBearbeiten = abrechnung && deputatService.kannBearbeitetWerden(abrechnung);
  const kannEinreichen = abrechnung && deputatService.kannEingereichtWerden(abrechnung);
  const colSpan = kannBearbeiten ? 5 : 4;

  // Wochentage fuer Anzeige
  const getWochentageDisplay = (lt: DeputatsLehrtaetigkeit): string => {
    if (lt.ist_block) return 'Block';
    const tage = lt.wochentage || (lt.wochentag ? [lt.wochentag] : []);
    if (tage.length === 0) return '-';
    return tage.map(t => WOCHENTAG_REVERSE_MAP[t] || t).join(', ');
  };

  // Status Farbe
  const getStatusColor = () => {
    switch (abrechnung?.status) {
      case 'genehmigt': return 'success';
      case 'eingereicht': return 'info';
      case 'abgelehnt': return 'error';
      default: return 'default';
    }
  };

  // Bewertung
  const getBewertungInfo = () => {
    if (!summen) return { color: 'default' as const, icon: null, text: '' };
    switch (summen.bewertung) {
      case 'erfuellt':
        return { color: 'success' as const, icon: <CheckCircle fontSize="small" />, text: 'Erfuellt' };
      case 'abweichung':
        return { color: 'warning' as const, icon: <Warning fontSize="small" />, text: 'Abweichung' };
      case 'starke_abweichung':
        return { color: 'error' as const, icon: <ErrorIcon fontSize="small" />, text: 'Starke Abweichung' };
      default:
        return { color: 'default' as const, icon: null, text: '' };
    }
  };

  const bewertung = getBewertungInfo();

  if (loading && !abrechnung) {
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
                Deputatsabrechnung
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Fortschreibungsliste fuer durchgefuehrte Lehrveranstaltungen
              </Typography>
            </Box>
          </Box>

          <FormControl size="small" sx={{ minWidth: 250 }}>
            <InputLabel>Planungsphase</InputLabel>
            <Select
              value={selectedPhaseId || ''}
              onChange={(e) => setSelectedPhaseId(Number(e.target.value))}
              label="Planungsphase"
            >
              {planungsphasen.map((phase) => (
                <MenuItem key={phase.id} value={phase.id}>
                  {phase.name} {phase.ist_aktiv && '(aktiv)'}
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        </Box>

        {/* Status Info */}
        {abrechnung && (
          <Box mt={3} display="flex" alignItems="center" gap={2} flexWrap="wrap">
            <Chip
              label={DEPUTAT_STATUS[abrechnung.status]}
              color={getStatusColor()}
              size="small"
            />
            <Typography variant="body2" color="text.secondary">
              Gesamtdeputat: <strong>{summen?.gesamtdeputat || 0}</strong> / {summen?.netto_lehrverpflichtung || 18} SWS
            </Typography>
            {summen && (
              <Chip
                icon={bewertung.icon || undefined}
                label={`Differenz: ${(summen.differenz || 0) > 0 ? '+' : ''}${summen.differenz || 0} SWS`}
                color={bewertung.color}
                variant="outlined"
                size="small"
              />
            )}
          </Box>
        )}
      </Paper>

      {/* Ablehnungsgrund */}
      {abrechnung?.status === 'abgelehnt' && abrechnung.ablehnungsgrund && (
        <Alert severity="error" sx={{ mb: 2 }}>
          <strong>Ablehnungsgrund:</strong> {abrechnung.ablehnungsgrund}
        </Alert>
      )}

      {/* Action Buttons */}
      <Paper sx={{ p: 2, mb: 2, display: 'flex', gap: 1, flexWrap: 'wrap', alignItems: 'center' }}>
        {kannBearbeiten && (
          <Tooltip title="Mit Semesterplanung synchronisieren">
            <Button
              variant="outlined"
              size="small"
              startIcon={syncing ? <CircularProgress size={14} /> : <Sync />}
              onClick={handleManualSync}
              disabled={syncing}
            >
              Sync
            </Button>
          </Tooltip>
        )}

        <Box sx={{ flexGrow: 1 }} />

        {kannEinreichen && (
          <Button variant="contained" size="small" startIcon={<Send />} onClick={handleEinreichen}>
            Einreichen
          </Button>
        )}
        {abrechnung?.status === 'abgelehnt' && (
          <Button variant="outlined" size="small" onClick={handleZuruecksetzen}>
            Zur Bearbeitung
          </Button>
        )}
        <Button
          variant="outlined"
          size="small"
          startIcon={pdfLoading ? <CircularProgress size={14} /> : <PictureAsPdf />}
          onClick={handlePdfExport}
          disabled={pdfLoading}
        >
          PDF
        </Button>
      </Paper>

      {/* Haupttabelle */}
      <TableContainer component={Paper}>
        <Table size="small">
          <TableHead>
            <TableRow sx={{ bgcolor: '#424242' }}>
              <TableCell sx={{ color: 'white', fontWeight: 600 }}>Bezeichnung</TableCell>
              <TableCell align="center" sx={{ color: 'white', fontWeight: 600, width: 80 }}>SWS</TableCell>
              <TableCell align="center" sx={{ color: 'white', fontWeight: 600, width: 100 }}>Tage</TableCell>
              <TableCell align="center" sx={{ color: 'white', fontWeight: 600, width: 90 }}>Quelle</TableCell>
              {kannBearbeiten && (
                <TableCell align="center" sx={{ color: 'white', width: 50 }}></TableCell>
              )}
            </TableRow>
          </TableHead>
          <TableBody>
            {/* Netto-Lehrverpflichtung */}
            <TableRow>
              <TableCell sx={{ fontWeight: 600 }}>Netto-Lehrverpflichtung</TableCell>
              <TableCell align="center" sx={{ fontWeight: 600 }}>{summen?.netto_lehrverpflichtung || 18}</TableCell>
              <TableCell colSpan={colSpan - 2}></TableCell>
            </TableRow>

            {/* Lehrtaetigkeiten */}
            <SectionRow title="1. Lehrtaetigkeiten" sws={summen?.sws_lehrtaetigkeiten} colSpan={colSpan} />

            {abrechnung?.lehrtaetigkeiten?.map((lt) => {
              const isImported = lt.quelle === 'planung';
              return (
                <TableRow key={lt.id} hover>
                  <TableCell sx={{ pl: 3 }}>
                    {isImported && <Lock fontSize="inherit" sx={{ mr: 0.5, opacity: 0.4, verticalAlign: 'middle' }} />}
                    {lt.bezeichnung}
                    {lt.kategorie !== 'lehrveranstaltung' && (
                      <Typography variant="caption" color="text.secondary" sx={{ ml: 1 }}>
                        ({LEHRTAETIGKEIT_KATEGORIEN[lt.kategorie as LehrtaetigkeitKategorie]})
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell align="center">{lt.sws}</TableCell>
                  <TableCell align="center">{getWochentageDisplay(lt)}</TableCell>
                  <TableCell align="center">
                    <Typography variant="caption" color={isImported ? 'primary' : 'text.secondary'}>
                      {isImported ? 'Import' : 'Manuell'}
                    </Typography>
                  </TableCell>
                  {kannBearbeiten && (
                    <TableCell align="center">
                      {!isImported && (
                        <IconButton size="small" onClick={() => handleDelete('lehrtaetigkeit', lt.id)}>
                          <Delete fontSize="small" />
                        </IconButton>
                      )}
                    </TableCell>
                  )}
                </TableRow>
              );
            })}

            {kannBearbeiten && (
              <TableRow>
                <TableCell colSpan={colSpan}>
                  <Button size="small" startIcon={<Add />} onClick={() => openDialog('lehrtaetigkeit')}>
                    Hinzufuegen
                  </Button>
                </TableCell>
              </TableRow>
            )}

            {/* Lehrexport */}
            <SectionRow title="2. Lehrexport" sws={summen?.sws_lehrexport} colSpan={colSpan} />

            {abrechnung?.lehrexporte?.map((le) => (
              <TableRow key={le.id} hover>
                <TableCell sx={{ pl: 3 }}>{le.fachbereich} - {le.fach}</TableCell>
                <TableCell align="center">{le.sws}</TableCell>
                <TableCell align="center">-</TableCell>
                <TableCell align="center">
                  <Typography variant="caption" color="text.secondary">Manuell</Typography>
                </TableCell>
                {kannBearbeiten && (
                  <TableCell align="center">
                    <IconButton size="small" onClick={() => handleDelete('lehrexport', le.id)}>
                      <Delete fontSize="small" />
                    </IconButton>
                  </TableCell>
                )}
              </TableRow>
            ))}

            {kannBearbeiten && (
              <TableRow>
                <TableCell colSpan={colSpan}>
                  <Button size="small" startIcon={<Add />} onClick={() => openDialog('lehrexport')}>
                    Hinzufuegen
                  </Button>
                </TableCell>
              </TableRow>
            )}

            {/* Vertretungen */}
            <SectionRow title="3. Vertretungen" sws={summen?.sws_vertretungen} colSpan={colSpan} />

            {abrechnung?.vertretungen?.map((v) => (
              <TableRow key={v.id} hover>
                <TableCell sx={{ pl: 3 }}>{VERTRETUNG_ARTEN[v.art]}: {v.vertretene_person}</TableCell>
                <TableCell align="center">{v.sws}</TableCell>
                <TableCell align="center">-</TableCell>
                <TableCell align="center">
                  <Typography variant="caption" color="text.secondary">Manuell</Typography>
                </TableCell>
                {kannBearbeiten && (
                  <TableCell align="center">
                    <IconButton size="small" onClick={() => handleDelete('vertretung', v.id)}>
                      <Delete fontSize="small" />
                    </IconButton>
                  </TableCell>
                )}
              </TableRow>
            ))}

            {kannBearbeiten && (
              <TableRow>
                <TableCell colSpan={colSpan}>
                  <Button size="small" startIcon={<Add />} onClick={() => openDialog('vertretung')}>
                    Hinzufuegen
                  </Button>
                </TableCell>
              </TableRow>
            )}

            {/* Ermaessigungen */}
            <SectionRow title="4. Ermaessigungen / Funktionen" sws={summen?.sws_ermaessigungen} colSpan={colSpan} />

            {abrechnung?.ermaessigungen?.map((e) => {
              const isImported = e.quelle === 'semesterauftrag';
              return (
                <TableRow key={e.id} hover>
                  <TableCell sx={{ pl: 3 }}>
                    {isImported && <Lock fontSize="inherit" sx={{ mr: 0.5, opacity: 0.4, verticalAlign: 'middle' }} />}
                    {e.bezeichnung}
                  </TableCell>
                  <TableCell align="center">{e.sws}</TableCell>
                  <TableCell align="center">-</TableCell>
                  <TableCell align="center">
                    <Typography variant="caption" color={isImported ? 'primary' : 'text.secondary'}>
                      {isImported ? 'Import' : 'Manuell'}
                    </Typography>
                  </TableCell>
                  {kannBearbeiten && (
                    <TableCell align="center">
                      {!isImported && (
                        <IconButton size="small" onClick={() => handleDelete('ermaessigung', e.id)}>
                          <Delete fontSize="small" />
                        </IconButton>
                      )}
                    </TableCell>
                  )}
                </TableRow>
              );
            })}

            {kannBearbeiten && (
              <TableRow>
                <TableCell colSpan={colSpan}>
                  <Button size="small" startIcon={<Add />} onClick={() => openDialog('ermaessigung')}>
                    Hinzufuegen
                  </Button>
                </TableCell>
              </TableRow>
            )}

            {/* Betreuungen */}
            <SectionRow title="5. Betreuungen (max. 3 SWS)" sws={summen?.sws_betreuungen_angerechnet} colSpan={colSpan} />

            {abrechnung?.betreuungen?.map((b) => (
              <TableRow key={b.id} hover>
                <TableCell sx={{ pl: 3 }}>
                  {b.student_vorname} {b.student_name}
                  <Typography variant="caption" color="text.secondary" sx={{ ml: 1 }}>
                    ({BETREUUNGS_ARTEN[b.betreuungsart]})
                  </Typography>
                </TableCell>
                <TableCell align="center">{b.sws}</TableCell>
                <TableCell align="center">-</TableCell>
                <TableCell align="center">
                  <Typography variant="caption" color="text.secondary">Manuell</Typography>
                </TableCell>
                {kannBearbeiten && (
                  <TableCell align="center">
                    <IconButton size="small" onClick={() => handleDelete('betreuung', b.id)}>
                      <Delete fontSize="small" />
                    </IconButton>
                  </TableCell>
                )}
              </TableRow>
            ))}

            {kannBearbeiten && (
              <TableRow>
                <TableCell colSpan={colSpan}>
                  <Button size="small" startIcon={<Add />} onClick={() => openDialog('betreuung')}>
                    Hinzufuegen
                  </Button>
                </TableCell>
              </TableRow>
            )}

            {/* Summenzeilen */}
            <TableRow sx={{ bgcolor: '#e0e0e0' }}>
              <TableCell sx={{ fontWeight: 600 }}>Gesamtdeputat</TableCell>
              <TableCell align="center" sx={{ fontWeight: 600, fontSize: '1.1em' }}>
                {summen?.gesamtdeputat || 0}
              </TableCell>
              <TableCell colSpan={colSpan - 2}></TableCell>
            </TableRow>

            <TableRow sx={{
              bgcolor: bewertung.color === 'success' ? '#e8f5e9' :
                       bewertung.color === 'warning' ? '#fff3e0' :
                       bewertung.color === 'error' ? '#ffebee' : '#f5f5f5'
            }}>
              <TableCell sx={{ fontWeight: 600, display: 'flex', alignItems: 'center', gap: 1 }}>
                {bewertung.icon}
                Differenz ({bewertung.text})
              </TableCell>
              <TableCell align="center" sx={{ fontWeight: 600, fontSize: '1.1em' }}>
                {(summen?.differenz || 0) > 0 ? '+' : ''}{summen?.differenz || 0}
              </TableCell>
              <TableCell colSpan={colSpan - 2}></TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </TableContainer>

      {/* Warnungen */}
      {summen?.warnungen && summen.warnungen.length > 0 && (
        <Paper sx={{ p: 2, mt: 2 }}>
          <Typography variant="subtitle2" gutterBottom>Hinweise</Typography>
          <Stack spacing={1}>
            {summen.warnungen.map((w, i) => (
              <Alert key={i} severity="warning" sx={{ py: 0 }}>{w}</Alert>
            ))}
          </Stack>
        </Paper>
      )}

      {/* Dialoge */}
      <Dialog open={dialogOpen} onClose={closeDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {dialogType === 'lehrtaetigkeit' && 'Lehrtaetigkeit hinzufuegen'}
          {dialogType === 'lehrexport' && 'Lehrexport hinzufuegen'}
          {dialogType === 'vertretung' && 'Vertretung hinzufuegen'}
          {dialogType === 'ermaessigung' && 'Ermaessigung hinzufuegen'}
          {dialogType === 'betreuung' && 'Betreuung hinzufuegen'}
        </DialogTitle>
        <DialogContent>
          {/* Lehrtaetigkeit Form */}
          {dialogType === 'lehrtaetigkeit' && (
            <Stack spacing={2} sx={{ pt: 1 }}>
              <Autocomplete
                options={module}
                getOptionLabel={(option) => getModulDisplayName(option)}
                value={selectedModul}
                onChange={(_, value) => handleModulSelect(value)}
                filterOptions={(options, { inputValue }) => {
                  const filterValue = inputValue.toLowerCase();
                  return options.filter(
                    (option) =>
                      (option.bezeichnung_de?.toLowerCase().includes(filterValue) ||
                       option.display_name?.toLowerCase().includes(filterValue) ||
                       option.name?.toLowerCase().includes(filterValue) ||
                       option.kuerzel?.toLowerCase().includes(filterValue))
                  ).slice(0, 20);
                }}
                renderInput={(params) => (
                  <TextField
                    {...params}
                    label="Modul auswaehlen *"
                    placeholder="Suchen..."
                    required
                    error={!selectedModul}
                    helperText={!selectedModul ? 'Pflichtfeld' : ''}
                    size="small"
                  />
                )}
                renderOption={(props, option) => (
                  <li {...props}>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', width: '100%' }}>
                      <Typography variant="body2">{getModulDisplayName(option)}</Typography>
                      <Typography variant="caption" color="text.secondary">{option.sws_gesamt || option.sws || 0} SWS</Typography>
                    </Box>
                  </li>
                )}
              />

              {selectedModul && (
                <>
                  <Box sx={{ display: 'flex', gap: 2 }}>
                    <TextField
                      label="Bezeichnung"
                      fullWidth
                      value={lehrtaetigkeitForm.bezeichnung}
                      disabled
                      size="small"
                    />
                    <TextField
                      label="SWS"
                      value={lehrtaetigkeitForm.sws}
                      disabled
                      size="small"
                      sx={{ width: 80 }}
                    />
                  </Box>

                  <FormControl fullWidth size="small">
                    <InputLabel>Kategorie</InputLabel>
                    <Select
                      value={lehrtaetigkeitForm.kategorie}
                      label="Kategorie"
                      onChange={(e) => setLehrtaetigkeitForm({ ...lehrtaetigkeitForm, kategorie: e.target.value as LehrtaetigkeitKategorie })}
                    >
                      {Object.entries(LEHRTAETIGKEIT_KATEGORIEN).map(([key, label]) => (
                        <MenuItem key={key} value={key}>{label}</MenuItem>
                      ))}
                    </Select>
                  </FormControl>

                  <FormControlLabel
                    control={
                      <Checkbox
                        checked={lehrtaetigkeitForm.ist_block}
                        onChange={(e) => {
                          setLehrtaetigkeitForm({ ...lehrtaetigkeitForm, ist_block: e.target.checked });
                          if (e.target.checked) setSelectedWochentage([]);
                        }}
                        size="small"
                      />
                    }
                    label="Blockveranstaltung"
                  />

                  {!lehrtaetigkeitForm.ist_block && (
                    <FormControl fullWidth size="small">
                      <InputLabel>Wochentage (optional)</InputLabel>
                      <Select
                        multiple
                        value={selectedWochentage}
                        onChange={handleWochentageChange}
                        input={<OutlinedInput label="Wochentage (optional)" />}
                        renderValue={(selected) => selected.map(v => WOCHENTAGE[v]).join(', ')}
                      >
                        {Object.entries(WOCHENTAGE).map(([key, label]) => (
                          <MenuItem key={key} value={key}>
                            <Checkbox checked={selectedWochentage.indexOf(key as Wochentag) > -1} size="small" />
                            {label}
                          </MenuItem>
                        ))}
                      </Select>
                    </FormControl>
                  )}
                </>
              )}
            </Stack>
          )}

          {/* Lehrexport Form */}
          {dialogType === 'lehrexport' && (
            <Stack spacing={2} sx={{ pt: 1 }}>
              <TextField
                label="Fachbereich"
                fullWidth
                value={lehrexportForm.fachbereich}
                onChange={(e) => setLehrexportForm({ ...lehrexportForm, fachbereich: e.target.value })}
                size="small"
              />
              <TextField
                label="Fach"
                fullWidth
                value={lehrexportForm.fach}
                onChange={(e) => setLehrexportForm({ ...lehrexportForm, fach: e.target.value })}
                size="small"
              />
              <TextField
                label="SWS"
                type="number"
                fullWidth
                value={lehrexportForm.sws}
                onChange={(e) => setLehrexportForm({ ...lehrexportForm, sws: parseFloat(e.target.value) || 0 })}
                inputProps={{ step: 0.5 }}
                size="small"
              />
            </Stack>
          )}

          {/* Vertretung Form */}
          {dialogType === 'vertretung' && (
            <Stack spacing={2} sx={{ pt: 1 }}>
              <FormControl fullWidth size="small">
                <InputLabel>Art</InputLabel>
                <Select
                  value={vertretungForm.art}
                  label="Art"
                  onChange={(e) => setVertretungForm({ ...vertretungForm, art: e.target.value as VertretungArt })}
                >
                  {Object.entries(VERTRETUNG_ARTEN).map(([key, label]) => (
                    <MenuItem key={key} value={key}>{label}</MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                label="Vertretene Person"
                fullWidth
                value={vertretungForm.vertretene_person}
                onChange={(e) => setVertretungForm({ ...vertretungForm, vertretene_person: e.target.value })}
                size="small"
              />
              <TextField
                label="Fach des Professors"
                fullWidth
                value={vertretungForm.fach_professor}
                onChange={(e) => setVertretungForm({ ...vertretungForm, fach_professor: e.target.value })}
                size="small"
              />
              <TextField
                label="SWS"
                type="number"
                fullWidth
                value={vertretungForm.sws}
                onChange={(e) => setVertretungForm({ ...vertretungForm, sws: parseFloat(e.target.value) || 0 })}
                inputProps={{ step: 0.5 }}
                size="small"
              />
            </Stack>
          )}

          {/* Ermaessigung Form */}
          {dialogType === 'ermaessigung' && (
            <Stack spacing={2} sx={{ pt: 1 }}>
              <Autocomplete
                options={auftraege}
                getOptionLabel={(option) => option.name || ''}
                value={selectedAuftrag}
                onChange={(_, value) => handleAuftragSelect(value)}
                renderInput={(params) => (
                  <TextField
                    {...params}
                    label="Funktion auswaehlen *"
                    placeholder="Suchen..."
                    required
                    error={!selectedAuftrag}
                    helperText={!selectedAuftrag ? 'Pflichtfeld' : ''}
                    size="small"
                  />
                )}
                renderOption={(props, option) => (
                  <li {...props}>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', width: '100%' }}>
                      <Typography variant="body2">{option.name}</Typography>
                      <Typography variant="caption" color="text.secondary">{option.standard_sws} SWS</Typography>
                    </Box>
                  </li>
                )}
              />
              {selectedAuftrag && (
                <Box sx={{ display: 'flex', gap: 2 }}>
                  <TextField
                    label="Bezeichnung"
                    fullWidth
                    value={ermaessigungForm.bezeichnung}
                    disabled
                    size="small"
                  />
                  <TextField
                    label="SWS"
                    value={ermaessigungForm.sws}
                    disabled
                    size="small"
                    sx={{ width: 80 }}
                  />
                </Box>
              )}
            </Stack>
          )}

          {/* Betreuung Form */}
          {dialogType === 'betreuung' && (
            <Stack spacing={2} sx={{ pt: 1 }}>
              <Box sx={{ display: 'flex', gap: 2 }}>
                <TextField
                  label="Vorname"
                  fullWidth
                  value={betreuungForm.student_vorname}
                  onChange={(e) => setBetreuungForm({ ...betreuungForm, student_vorname: e.target.value })}
                  size="small"
                />
                <TextField
                  label="Nachname"
                  fullWidth
                  value={betreuungForm.student_name}
                  onChange={(e) => setBetreuungForm({ ...betreuungForm, student_name: e.target.value })}
                  size="small"
                />
              </Box>
              <FormControl fullWidth size="small">
                <InputLabel>Art der Betreuung</InputLabel>
                <Select
                  value={betreuungForm.betreuungsart}
                  label="Art der Betreuung"
                  onChange={(e) => setBetreuungForm({ ...betreuungForm, betreuungsart: e.target.value as BetreuungsArt })}
                >
                  {Object.entries(BETREUUNGS_ARTEN).map(([key, label]) => (
                    <MenuItem key={key} value={key}>{label}</MenuItem>
                  ))}
                </Select>
              </FormControl>
              <TextField
                label="Titel der Arbeit (optional)"
                fullWidth
                value={betreuungForm.titel_arbeit}
                onChange={(e) => setBetreuungForm({ ...betreuungForm, titel_arbeit: e.target.value })}
                size="small"
              />
              <Typography variant="caption" color="text.secondary">
                SWS wird automatisch basierend auf der Betreuungsart berechnet
              </Typography>
            </Stack>
          )}
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={closeDialog} size="small">Abbrechen</Button>
          <Button onClick={handleSave} variant="contained" size="small">Speichern</Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default DeputatsabrechnungNeu;
