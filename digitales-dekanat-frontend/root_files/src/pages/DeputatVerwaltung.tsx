import React, { useState, useEffect } from 'react';
import {
  Container,
  Paper,
  Typography,
  Box,
  Grid,
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
  Card,
  CardContent,
  FormControl,
  InputLabel,
  Select,
  Tabs,
  Tab,
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Divider,
} from '@mui/material';
import {
  ArrowBack,
  Check,
  Close,
  Visibility,
  Settings,
  ExpandMore,
  Refresh,
  PictureAsPdf,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import deputatService from '../services/deputatService';
import planungPhaseService from '../services/planungPhaseService';
import { createContextLogger } from '../utils/logger';

const log = createContextLogger('DeputatVerwaltung');

import {
  Deputatsabrechnung,
  DeputatsEinstellungen,
  DeputatStatistik,
  DEPUTAT_STATUS,
  DEPUTAT_STATUS_COLORS,
  UpdateEinstellungenData,
} from '../types/deputat.types';
import { useToastStore } from '../components/common/Toast';

/**
 * Deputat-Verwaltung - Dekan-Ansicht
 * ==================================
 *
 * Features:
 * - Übersicht aller Deputatsabrechnungen
 * - Filter nach Planungsphase und Status
 * - Statistiken
 * - Eingereichte Abrechnungen prüfen
 * - Genehmigen / Ablehnen
 * - Einstellungen verwalten
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

const DeputatVerwaltung: React.FC = () => {
  const navigate = useNavigate();
  const showToast = useToastStore((state) => state.showToast);

  // State
  const [loading, setLoading] = useState(true);
  const [tabValue, setTabValue] = useState(0);
  const [planungsphasen, setPlanungsphasen] = useState<any[]>([]);
  const [selectedPhaseId, setSelectedPhaseId] = useState<number | null>(null);
  const [statusFilter, setStatusFilter] = useState<string>('');

  // Data
  const [abrechnungen, setAbrechnungen] = useState<Deputatsabrechnung[]>([]);
  const [eingereichte, setEingereichte] = useState<Deputatsabrechnung[]>([]);
  const [statistik, setStatistik] = useState<DeputatStatistik | null>(null);
  const [einstellungen, setEinstellungen] = useState<DeputatsEinstellungen | null>(null);

  // Dialogs
  const [detailDialog, setDetailDialog] = useState<Deputatsabrechnung | null>(null);
  const [ablehnenDialog, setAblehnenDialog] = useState<Deputatsabrechnung | null>(null);
  const [ablehnenGrund, setAblehnenGrund] = useState('');
  const [einstellungenDialog, setEinstellungenDialog] = useState(false);
  const [einstellungenForm, setEinstellungenForm] = useState<UpdateEinstellungenData>({});
  const [pdfLoading, setPdfLoading] = useState<number | null>(null);

  // Load Planungsphasen
  useEffect(() => {
    const loadPlanungsphasen = async () => {
      try {
        const response = await planungPhaseService.getAllPhases();
        const phasen = response.phasen || [];
        setPlanungsphasen(phasen);
        if (phasen.length > 0) {
          const aktive = response.aktive_phase || phasen.find((p: any) => p.ist_aktiv);
          setSelectedPhaseId(aktive?.id || phasen[0].id);
        }
      } catch (error) {
        log.error('Error loading planungsphasen:', error);
      }
    };
    loadPlanungsphasen();
  }, []);

  // Load Data
  useEffect(() => {
    if (selectedPhaseId) {
      loadData();
    }
  }, [selectedPhaseId, statusFilter]);

  const loadData = async () => {
    try {
      setLoading(true);

      const [abrechnungenData, eingereichtData, statistikData, einstellungenData] =
        await Promise.all([
          deputatService.getAlleAbrechnungen(
            selectedPhaseId || undefined,
            statusFilter || undefined
          ),
          deputatService.getEingereichte(selectedPhaseId || undefined),
          deputatService.getStatistik(selectedPhaseId || undefined),
          deputatService.getEinstellungen(),
        ]);

      setAbrechnungen(abrechnungenData);
      setEingereichte(eingereichtData);
      setStatistik(statistikData);
      setEinstellungen(einstellungenData);
    } catch (error) {
      log.error('Error loading data:', error);
      showToast('Fehler beim Laden der Daten', 'error');
    } finally {
      setLoading(false);
    }
  };

  // Workflow Actions
  const handleGenehmigen = async (abrechnung: Deputatsabrechnung) => {
    if (!confirm('Abrechnung wirklich genehmigen?')) return;

    try {
      await deputatService.genehmigen(abrechnung.id);
      await loadData();
      showToast('Abrechnung genehmigt', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler beim Genehmigen', 'error');
    }
  };

  const handleAblehnen = async () => {
    if (!ablehnenDialog) return;

    try {
      await deputatService.ablehnen(ablehnenDialog.id, ablehnenGrund);
      setAblehnenDialog(null);
      setAblehnenGrund('');
      await loadData();
      showToast('Abrechnung abgelehnt', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler beim Ablehnen', 'error');
    }
  };

  // Einstellungen speichern
  const handleSaveEinstellungen = async () => {
    try {
      await deputatService.updateEinstellungen({
        ...einstellungenForm,
        beschreibung: `Geändert am ${new Date().toLocaleDateString('de-DE')}`,
      });
      setEinstellungenDialog(false);
      await loadData();
      showToast('Einstellungen gespeichert', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler beim Speichern', 'error');
    }
  };

  const openEinstellungenDialog = () => {
    if (einstellungen) {
      setEinstellungenForm({
        sws_bachelor_arbeit: einstellungen.sws_bachelor_arbeit,
        sws_master_arbeit: einstellungen.sws_master_arbeit,
        sws_doktorarbeit: einstellungen.sws_doktorarbeit,
        sws_seminar_ba: einstellungen.sws_seminar_ba,
        sws_seminar_ma: einstellungen.sws_seminar_ma,
        sws_projekt_ba: einstellungen.sws_projekt_ba,
        sws_projekt_ma: einstellungen.sws_projekt_ma,
        max_sws_praxisseminar: einstellungen.max_sws_praxisseminar,
        max_sws_projektveranstaltung: einstellungen.max_sws_projektveranstaltung,
        max_sws_seminar_master: einstellungen.max_sws_seminar_master,
        max_sws_betreuung: einstellungen.max_sws_betreuung,
        warn_ermaessigung_ueber: einstellungen.warn_ermaessigung_ueber,
        default_netto_lehrverpflichtung: einstellungen.default_netto_lehrverpflichtung,
      });
    }
    setEinstellungenDialog(true);
  };

  // PDF Export Handler
  const handlePdfExport = async (abrechnung: Deputatsabrechnung) => {
    try {
      setPdfLoading(abrechnung.id);
      await deputatService.downloadPdf(abrechnung.id);
      showToast('PDF wurde heruntergeladen', 'success');
    } catch (error: any) {
      showToast(error.response?.data?.message || 'Fehler beim PDF-Export', 'error');
    } finally {
      setPdfLoading(null);
    }
  };

  if (loading && !statistik) {
    return (
      <Container maxWidth="lg" sx={{ mt: 4 }}>
        <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
          <CircularProgress />
        </Box>
      </Container>
    );
  }

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box display="flex" alignItems="center" gap={2}>
          <IconButton onClick={() => navigate(-1)}>
            <ArrowBack />
          </IconButton>
          <Typography variant="h4">Deputat-Verwaltung</Typography>
        </Box>

        <Box display="flex" gap={2}>
          <FormControl sx={{ minWidth: 200 }}>
            <InputLabel>Planungsphase</InputLabel>
            <Select
              value={selectedPhaseId || ''}
              label="Planungsphase"
              onChange={(e) => setSelectedPhaseId(Number(e.target.value))}
              size="small"
            >
              {planungsphasen.map((phase) => (
                <MenuItem key={phase.id} value={phase.id}>
                  {phase.name}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Button
            variant="outlined"
            startIcon={<Settings />}
            onClick={openEinstellungenDialog}
          >
            Einstellungen
          </Button>

          <Button variant="outlined" startIcon={<Refresh />} onClick={loadData}>
            Aktualisieren
          </Button>
        </Box>
      </Box>

      {/* Statistik Cards */}
      {statistik && (
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={6} sm={4} md={2}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4">{statistik.gesamt}</Typography>
                <Typography variant="body2" color="text.secondary">
                  Gesamt
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4">{statistik.entwurf}</Typography>
                <Typography variant="body2" color="text.secondary">
                  Entwurf
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <Card sx={{ bgcolor: 'info.light' }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4">{statistik.eingereicht}</Typography>
                <Typography variant="body2">Eingereicht</Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <Card sx={{ bgcolor: 'success.light' }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4">{statistik.genehmigt}</Typography>
                <Typography variant="body2">Genehmigt</Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <Card sx={{ bgcolor: 'error.light' }}>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4">{statistik.abgelehnt}</Typography>
                <Typography variant="body2">Abgelehnt</Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={6} sm={4} md={2}>
            <Card>
              <CardContent sx={{ textAlign: 'center' }}>
                <Typography variant="h4">{statistik.quote_genehmigt}%</Typography>
                <Typography variant="body2" color="text.secondary">
                  Quote
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      )}

      {/* Tabs */}
      <Paper>
        <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)}>
          <Tab label={`Zur Genehmigung (${eingereichte.length})`} />
          <Tab label={`Alle Abrechnungen (${abrechnungen.length})`} />
        </Tabs>

        {/* Eingereichte */}
        <TabPanel value={tabValue} index={0}>
          <Box sx={{ p: 2 }}>
            {eingereichte.length === 0 ? (
              <Alert severity="info">Keine eingereichten Abrechnungen vorhanden</Alert>
            ) : (
              eingereichte.map((abr) => (
                <Accordion key={abr.id} sx={{ mb: 1 }}>
                  <AccordionSummary expandIcon={<ExpandMore />}>
                    <Box
                      display="flex"
                      justifyContent="space-between"
                      alignItems="center"
                      width="100%"
                      pr={2}
                    >
                      <Box>
                        <Typography variant="subtitle1">
                          {abr.benutzer?.name_komplett || 'Unbekannt'}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          {abr.planungsphase?.name} | Eingereicht:{' '}
                          {abr.eingereicht_am
                            ? new Date(abr.eingereicht_am).toLocaleDateString('de-DE')
                            : '-'}
                        </Typography>
                      </Box>
                      <Box display="flex" alignItems="center" gap={2}>
                        {abr.summen && (
                          <Chip
                            label={`${abr.summen.nettobelastung} / ${abr.summen.netto_lehrverpflichtung} SWS`}
                            color={deputatService.getBewertungColor(abr.summen.bewertung)}
                            variant="outlined"
                          />
                        )}
                      </Box>
                    </Box>
                  </AccordionSummary>
                  <AccordionDetails>
                    <Grid container spacing={2}>
                      {/* Details */}
                      <Grid item xs={12} md={8}>
                        <Typography variant="subtitle2" gutterBottom>
                          Zusammenfassung
                        </Typography>
                        {abr.summen && (
                          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 2 }}>
                            <Chip
                              size="small"
                              label={`Lehrtätigkeiten: ${abr.summen.sws_lehrtaetigkeiten} SWS`}
                            />
                            <Chip
                              size="small"
                              label={`Lehrexport: ${abr.summen.sws_lehrexport} SWS`}
                            />
                            <Chip
                              size="small"
                              label={`Vertretungen: ${abr.summen.sws_vertretungen} SWS`}
                            />
                            <Chip
                              size="small"
                              label={`Betreuungen: ${abr.summen.sws_betreuungen_angerechnet} SWS`}
                            />
                            <Chip
                              size="small"
                              color="warning"
                              label={`Ermäßigungen: -${abr.summen.sws_ermaessigungen} SWS`}
                            />
                          </Box>
                        )}

                        {abr.summen?.warnungen && abr.summen.warnungen.length > 0 && (
                          <Box sx={{ mb: 2 }}>
                            <Typography variant="subtitle2" color="warning.main" gutterBottom>
                              Warnungen:
                            </Typography>
                            {abr.summen.warnungen.map((w, i) => (
                              <Alert key={i} severity="warning" sx={{ mb: 1 }}>
                                {w}
                              </Alert>
                            ))}
                          </Box>
                        )}

                        {abr.bemerkungen && (
                          <Box sx={{ mb: 2 }}>
                            <Typography variant="subtitle2">Bemerkungen:</Typography>
                            <Typography variant="body2">{abr.bemerkungen}</Typography>
                          </Box>
                        )}
                      </Grid>

                      {/* Aktionen */}
                      <Grid item xs={12} md={4}>
                        <Box display="flex" flexDirection="column" gap={1}>
                          <Button
                            variant="contained"
                            color="success"
                            startIcon={<Check />}
                            onClick={() => handleGenehmigen(abr)}
                            fullWidth
                          >
                            Genehmigen
                          </Button>
                          <Button
                            variant="outlined"
                            color="error"
                            startIcon={<Close />}
                            onClick={() => setAblehnenDialog(abr)}
                            fullWidth
                          >
                            Ablehnen
                          </Button>
                          <Button
                            variant="outlined"
                            startIcon={<Visibility />}
                            onClick={() => setDetailDialog(abr)}
                            fullWidth
                          >
                            Details anzeigen
                          </Button>
                          <Button
                            variant="outlined"
                            color="secondary"
                            startIcon={pdfLoading === abr.id ? <CircularProgress size={20} /> : <PictureAsPdf />}
                            onClick={() => handlePdfExport(abr)}
                            disabled={pdfLoading === abr.id}
                            fullWidth
                          >
                            {pdfLoading === abr.id ? 'Wird erstellt...' : 'PDF Export'}
                          </Button>
                        </Box>
                      </Grid>
                    </Grid>
                  </AccordionDetails>
                </Accordion>
              ))
            )}
          </Box>
        </TabPanel>

        {/* Alle Abrechnungen */}
        <TabPanel value={tabValue} index={1}>
          <Box sx={{ p: 2 }}>
            <Box sx={{ mb: 2 }}>
              <FormControl size="small" sx={{ minWidth: 150 }}>
                <InputLabel>Status Filter</InputLabel>
                <Select
                  value={statusFilter}
                  label="Status Filter"
                  onChange={(e) => setStatusFilter(e.target.value)}
                >
                  <MenuItem value="">Alle</MenuItem>
                  <MenuItem value="entwurf">Entwurf</MenuItem>
                  <MenuItem value="eingereicht">Eingereicht</MenuItem>
                  <MenuItem value="genehmigt">Genehmigt</MenuItem>
                  <MenuItem value="abgelehnt">Abgelehnt</MenuItem>
                </Select>
              </FormControl>
            </Box>

            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Professor</TableCell>
                    <TableCell>Planungsphase</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell align="right">Deputat</TableCell>
                    <TableCell align="right">Differenz</TableCell>
                    <TableCell>Bewertung</TableCell>
                    <TableCell>Aktionen</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {abrechnungen.map((abr) => (
                    <TableRow key={abr.id}>
                      <TableCell>{abr.benutzer?.name_komplett || '-'}</TableCell>
                      <TableCell>{abr.planungsphase?.name || '-'}</TableCell>
                      <TableCell>
                        <Chip
                          size="small"
                          label={DEPUTAT_STATUS[abr.status]}
                          color={DEPUTAT_STATUS_COLORS[abr.status]}
                        />
                      </TableCell>
                      <TableCell align="right">
                        {abr.summen
                          ? `${abr.summen.nettobelastung} / ${abr.summen.netto_lehrverpflichtung}`
                          : '-'}
                      </TableCell>
                      <TableCell align="right">
                        {abr.summen
                          ? `${abr.summen.differenz > 0 ? '+' : ''}${abr.summen.differenz}`
                          : '-'}
                      </TableCell>
                      <TableCell>
                        {abr.summen && (
                          <Chip
                            size="small"
                            color={deputatService.getBewertungColor(abr.summen.bewertung)}
                            label={deputatService.getBewertungText(abr.summen.bewertung)}
                          />
                        )}
                      </TableCell>
                      <TableCell>
                        <IconButton size="small" onClick={() => setDetailDialog(abr)}>
                          <Visibility fontSize="small" />
                        </IconButton>
                        <IconButton
                          size="small"
                          onClick={() => handlePdfExport(abr)}
                          disabled={pdfLoading === abr.id}
                        >
                          {pdfLoading === abr.id ? (
                            <CircularProgress size={18} />
                          ) : (
                            <PictureAsPdf fontSize="small" />
                          )}
                        </IconButton>
                        {abr.status === 'eingereicht' && (
                          <>
                            <IconButton
                              size="small"
                              color="success"
                              onClick={() => handleGenehmigen(abr)}
                            >
                              <Check fontSize="small" />
                            </IconButton>
                            <IconButton
                              size="small"
                              color="error"
                              onClick={() => setAblehnenDialog(abr)}
                            >
                              <Close fontSize="small" />
                            </IconButton>
                          </>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                  {abrechnungen.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={7} align="center">
                        Keine Abrechnungen gefunden
                      </TableCell>
                    </TableRow>
                  )}
                </TableBody>
              </Table>
            </TableContainer>
          </Box>
        </TabPanel>
      </Paper>

      {/* Detail Dialog */}
      <Dialog
        open={!!detailDialog}
        onClose={() => setDetailDialog(null)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>
          Deputatsabrechnung - {detailDialog?.benutzer?.name_komplett}
        </DialogTitle>
        <DialogContent>
          {detailDialog?.summen && (
            <Grid container spacing={2} sx={{ mt: 1 }}>
              <Grid item xs={12} md={6}>
                <Typography variant="subtitle2">Lehrtätigkeiten</Typography>
                <Typography>Gesamt: {detailDialog.summen.sws_lehrtaetigkeiten} SWS</Typography>
                <Typography variant="body2" color="text.secondary">
                  Praxisseminar: {detailDialog.summen.sws_praxisseminar} (angerechnet:{' '}
                  {detailDialog.summen.sws_praxisseminar_angerechnet})
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Projektveranstaltung: {detailDialog.summen.sws_projektveranstaltung} (angerechnet:{' '}
                  {detailDialog.summen.sws_projektveranstaltung_angerechnet})
                </Typography>
              </Grid>
              <Grid item xs={12} md={6}>
                <Typography variant="subtitle2">Weitere Kategorien</Typography>
                <Typography variant="body2">
                  Lehrexport: {detailDialog.summen.sws_lehrexport} SWS
                </Typography>
                <Typography variant="body2">
                  Vertretungen: {detailDialog.summen.sws_vertretungen} SWS
                </Typography>
                <Typography variant="body2">
                  Betreuungen: {detailDialog.summen.sws_betreuungen_angerechnet} SWS (roh:{' '}
                  {detailDialog.summen.sws_betreuungen_roh})
                </Typography>
                <Typography variant="body2" color="warning.main">
                  Ermäßigungen: -{detailDialog.summen.sws_ermaessigungen} SWS
                </Typography>
              </Grid>
              <Grid item xs={12}>
                <Divider sx={{ my: 2 }} />
                <Box display="flex" justifyContent="space-between">
                  <Typography variant="h6">
                    Nettobelastung: {detailDialog.summen.nettobelastung} SWS
                  </Typography>
                  <Typography variant="h6">
                    Soll: {detailDialog.summen.netto_lehrverpflichtung} SWS
                  </Typography>
                  <Chip
                    label={`Differenz: ${detailDialog.summen.differenz > 0 ? '+' : ''}${detailDialog.summen.differenz} SWS`}
                    color={deputatService.getBewertungColor(detailDialog.summen.bewertung)}
                  />
                </Box>
              </Grid>
            </Grid>
          )}
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDetailDialog(null)}>Schließen</Button>
          {detailDialog && (
            <Button
              variant="outlined"
              color="secondary"
              startIcon={pdfLoading === detailDialog.id ? <CircularProgress size={20} /> : <PictureAsPdf />}
              onClick={() => handlePdfExport(detailDialog)}
              disabled={pdfLoading === detailDialog.id}
            >
              {pdfLoading === detailDialog.id ? 'Wird erstellt...' : 'PDF Export'}
            </Button>
          )}
        </DialogActions>
      </Dialog>

      {/* Ablehnen Dialog */}
      <Dialog open={!!ablehnenDialog} onClose={() => setAblehnenDialog(null)}>
        <DialogTitle>Abrechnung ablehnen</DialogTitle>
        <DialogContent>
          <Typography gutterBottom>
            Abrechnung von {ablehnenDialog?.benutzer?.name_komplett} ablehnen?
          </Typography>
          <TextField
            label="Ablehnungsgrund"
            multiline
            rows={3}
            fullWidth
            value={ablehnenGrund}
            onChange={(e) => setAblehnenGrund(e.target.value)}
            sx={{ mt: 2 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAblehnenDialog(null)}>Abbrechen</Button>
          <Button onClick={handleAblehnen} color="error" variant="contained">
            Ablehnen
          </Button>
        </DialogActions>
      </Dialog>

      {/* Einstellungen Dialog */}
      <Dialog
        open={einstellungenDialog}
        onClose={() => setEinstellungenDialog(false)}
        maxWidth="md"
        fullWidth
      >
        <DialogTitle>Deputats-Einstellungen</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            {/* SWS für Betreuungen */}
            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom>
                SWS für Betreuungen
              </Typography>
            </Grid>
            <Grid item xs={6} sm={4}>
              <TextField
                label="Bachelorarbeit"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.sws_bachelor_arbeit || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    sws_bachelor_arbeit: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.1 }}
              />
            </Grid>
            <Grid item xs={6} sm={4}>
              <TextField
                label="Masterarbeit"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.sws_master_arbeit || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    sws_master_arbeit: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.1 }}
              />
            </Grid>
            <Grid item xs={6} sm={4}>
              <TextField
                label="Doktorarbeit"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.sws_doktorarbeit || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    sws_doktorarbeit: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.1 }}
              />
            </Grid>

            {/* Obergrenzen */}
            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
                Obergrenzen (max. anrechenbare SWS)
              </Typography>
            </Grid>
            <Grid item xs={6} sm={3}>
              <TextField
                label="Praxisseminar"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.max_sws_praxisseminar || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    max_sws_praxisseminar: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.5 }}
              />
            </Grid>
            <Grid item xs={6} sm={3}>
              <TextField
                label="Projektveranstaltung"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.max_sws_projektveranstaltung || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    max_sws_projektveranstaltung: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.5 }}
              />
            </Grid>
            <Grid item xs={6} sm={3}>
              <TextField
                label="Seminar Master"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.max_sws_seminar_master || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    max_sws_seminar_master: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.5 }}
              />
            </Grid>
            <Grid item xs={6} sm={3}>
              <TextField
                label="Betreuungen"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.max_sws_betreuung || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    max_sws_betreuung: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.5 }}
              />
            </Grid>

            {/* Warnschwellen & Standard */}
            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom sx={{ mt: 2 }}>
                Weitere Einstellungen
              </Typography>
            </Grid>
            <Grid item xs={6}>
              <TextField
                label="Warnung bei Ermäßigungen über"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.warn_ermaessigung_ueber || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    warn_ermaessigung_ueber: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 0.5 }}
                helperText="SWS"
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                label="Standard Netto-Lehrverpflichtung"
                type="number"
                fullWidth
                size="small"
                value={einstellungenForm.default_netto_lehrverpflichtung || ''}
                onChange={(e) =>
                  setEinstellungenForm({
                    ...einstellungenForm,
                    default_netto_lehrverpflichtung: parseFloat(e.target.value),
                  })
                }
                inputProps={{ step: 1 }}
                helperText="SWS"
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEinstellungenDialog(false)}>Abbrechen</Button>
          <Button onClick={handleSaveEinstellungen} variant="contained">
            Speichern
          </Button>
        </DialogActions>
      </Dialog>
    </Container>
  );
};

export default DeputatVerwaltung;
