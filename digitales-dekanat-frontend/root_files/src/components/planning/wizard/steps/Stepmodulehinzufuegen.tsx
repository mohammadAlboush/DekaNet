import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Button,
  Grid,
  Card,
  CardContent,
  TextField,
  Alert,
  Chip,
  IconButton,
  Divider,
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
  InputAdornment,
} from '@mui/material';
import {
  NavigateBefore,
  NavigateNext,
  Add,
  Edit,
  Delete,
  School,
  Schedule,
  Save,
  Close,
  CheckCircle,
  Search,
} from '@mui/icons-material';
import { StepModuleHinzufuegenProps } from '../../../../types/StepProps.types';
import { Modul, ModulLehrform } from '../../../../types/modul.types';
import { GeplantesModul, AddModulData } from '../../../../types/planung.types';
import planungService from '../../../../services/planungService';
import { useToastStore } from '../../../../components/common/Toast';
import api from '../../../../services/api';
import { logger } from '../../../../utils/logger';
import { getErrorMessage } from '../../../../utils/errorUtils';
import { DEFAULT_CAPACITIES, MULTIPLIKATOR_LIMITS, PERFORMANCE_LIMITS } from '../../../../constants/planning.constants';

interface ModulFormData {
  modul: Modul;
  anzahl_vorlesungen: number;
  anzahl_uebungen: number;
  anzahl_praktika: number;
  anzahl_seminare: number;
  anmerkungen: string;
  // Raum-Planung pro Lehrform
  raum_vorlesung: string;
  raum_uebung: string;
  raum_praktikum: string;
  raum_seminar: string;
  // Kapazitäts-Anforderungen
  kapazitaet_vorlesung: number;
  kapazitaet_uebung: number;
  kapazitaet_praktikum: number;
  kapazitaet_seminar: number;
}

const Stepmodulehinzufuegen: React.FC<StepModuleHinzufuegenProps> = ({
  data,
  onUpdate,
  onNext,
  onBack,
  planungId
}) => {
  const showToast = useToastStore((state) => state.showToast);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingModul, setEditingModul] = useState<GeplantesModul | null>(null);
  const [formData, setFormData] = useState<ModulFormData | null>(null);
  const [saving, setSaving] = useState(false);

  // Lade ALLE Module, nicht nur die ausgewählten
  const [alleModule, setAlleModule] = useState<Modul[]>([]);
  const [searchTerm, setSearchTerm] = useState('');

  // Lade alle verfügbaren Module beim Mount
  useEffect(() => {
    loadAlleModule();
  }, []);

  const loadAlleModule = async () => {
    try {
      const response = await api.get('/module');
      if (response.data.success) {
        setAlleModule(response.data.data || []);
        logger.debug('StepModule', 'Alle Module geladen', { count: response.data.data?.length || 0 });
      }
    } catch (error) {
      logger.error('StepModule', 'Error loading modules', error);
      showToast('Fehler beim Laden der Module', 'error');
    }
  };

  // Korrigierte Funktion ohne semester.po_id
  const getPOId = (): number => {
    // Versuche po_id aus verschiedenen Quellen zu bekommen
    
    // 1. Aus den ausgewählten Modulen (alle sollten dieselbe PO haben)
    if (data.selectedModules && data.selectedModules.length > 0) {
      const firstModulPOId = data.selectedModules[0].po_id;
      if (firstModulPOId) {
        return firstModulPOId;
      }
    }
    
    // 2. Aus bereits geplanten Modulen
    if (data.geplantModule && data.geplantModule.length > 0) {
      const firstGeplantPOId = data.geplantModule[0].po_id;
      if (firstGeplantPOId) {
        return firstGeplantPOId;
      }
    }


    // 3. Fallback auf Standard-PO (Informatik Bachelor)
    logger.warn('StepModule', 'Keine PO-ID gefunden, verwende Standard-PO 1');
    return 1;
  };
  const handleAddModule = (modul: Modul) => {
    logger.debug('StepModule', 'Opening dialog for module', {
      kuerzel: modul.kuerzel,
      id: modul.id,
      po_id: modul.po_id,
      lehrformen: modul.lehrformen?.length || 0
    });

    // Initialisierung mit korrekten SWS-Daten
    let anzahl_vorlesungen = 0;
    let anzahl_uebungen = 0;
    let anzahl_praktika = 0;
    let anzahl_seminare = 0;
    
    if (modul.lehrformen && modul.lehrformen.length > 0) {
      // Prüfe welche Lehrformen vorhanden sind
      const hatVorlesung = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'V');
      const hatUebung = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'Ü');
      const hatPraktikum = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'P');
      const hatSeminar = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'S');
      
      // Setze Standard-Multiplikatoren basierend auf vorhandenen Lehrformen
      anzahl_vorlesungen = hatVorlesung ? 1 : 0;
      anzahl_uebungen = hatUebung ? 1 : 0;
      anzahl_praktika = hatPraktikum ? 1 : 0;
      anzahl_seminare = hatSeminar ? 1 : 0;


      logger.debug('StepModule', 'Lehrformen gefunden', {
        V: hatVorlesung,
        Ü: hatUebung,
        P: hatPraktikum,
        S: hatSeminar
      });
    } else {
      // Wenn keine Lehrformen definiert, setze Vorlesung als Standard
      logger.warn('StepModule', 'Keine Lehrformen definiert, verwende Standard');
      anzahl_vorlesungen = 1;
    }

    setFormData({
      modul,
      anzahl_vorlesungen,
      anzahl_uebungen,
      anzahl_praktika,
      anzahl_seminare,
      anmerkungen: '',
      // Raum-Planung
      raum_vorlesung: '',
      raum_uebung: '',
      raum_praktikum: '',
      raum_seminar: '',
      // Kapazität (Standardwerte aus Konstanten)
      kapazitaet_vorlesung: DEFAULT_CAPACITIES.vorlesung,
      kapazitaet_uebung: DEFAULT_CAPACITIES.uebung,
      kapazitaet_praktikum: DEFAULT_CAPACITIES.praktikum,
      kapazitaet_seminar: DEFAULT_CAPACITIES.seminar,
    });
    setEditingModul(null);
    setDialogOpen(true);
  };

  const handleEditModule = (geplantesModul: GeplantesModul) => {
    logger.debug('StepModule', 'Editing module', { kuerzel: geplantesModul.modul?.kuerzel });

    setFormData({
      modul: geplantesModul.modul!,
      anzahl_vorlesungen: geplantesModul.anzahl_vorlesungen || 0,
      anzahl_uebungen: geplantesModul.anzahl_uebungen || 0,
      anzahl_praktika: geplantesModul.anzahl_praktika || 0,
      anzahl_seminare: geplantesModul.anzahl_seminare || 0,
      anmerkungen: geplantesModul.anmerkungen || '',
      // Raum-Planung
      raum_vorlesung: geplantesModul.raum_vorlesung || '',
      raum_uebung: geplantesModul.raum_uebung || '',
      raum_praktikum: geplantesModul.raum_praktikum || '',
      raum_seminar: geplantesModul.raum_seminar || '',
      // Kapazität
      kapazitaet_vorlesung: geplantesModul.kapazitaet_vorlesung || DEFAULT_CAPACITIES.vorlesung,
      kapazitaet_uebung: geplantesModul.kapazitaet_uebung || DEFAULT_CAPACITIES.uebung,
      kapazitaet_praktikum: geplantesModul.kapazitaet_praktikum || DEFAULT_CAPACITIES.praktikum,
      kapazitaet_seminar: geplantesModul.kapazitaet_seminar || DEFAULT_CAPACITIES.seminar,
    });
    setEditingModul(geplantesModul);
    setDialogOpen(true);
  };

  const handleSaveModule = async () => {
    if (!formData || !planungId) {
      showToast('Keine Planung-ID vorhanden', 'error');
      return;
    }

    // Validation
    const totalMultiplikatoren = 
      formData.anzahl_vorlesungen + 
      formData.anzahl_uebungen + 
      formData.anzahl_praktika + 
      formData.anzahl_seminare;
    
    if (totalMultiplikatoren === 0) {
      showToast('Mindestens eine Lehrform muss > 0 sein', 'warning');
      return;
    }

    logger.debug('StepModule', 'Saving module', {
      modul_kuerzel: formData.modul.kuerzel,
      modul_id: formData.modul.id,
      po_id: getPOId(),
      planungId,
      multiplikatoren: {
        V: formData.anzahl_vorlesungen,
        Ü: formData.anzahl_uebungen,
        P: formData.anzahl_praktika,
        S: formData.anzahl_seminare,
      }
    });

    setSaving(true);
    try {
      if (editingModul) {
        // Update existing module
        logger.debug('StepModule', 'Updating existing module', { id: editingModul.id });

        await planungService.updateModule(
          planungId,
          editingModul.id,
          {
            anzahl_vorlesungen: formData.anzahl_vorlesungen,
            anzahl_uebungen: formData.anzahl_uebungen,
            anzahl_praktika: formData.anzahl_praktika,
            anzahl_seminare: formData.anzahl_seminare,
            anmerkungen: formData.anmerkungen,
            // Raum-Planung pro Lehrform
            raum_vorlesung: formData.raum_vorlesung || undefined,
            raum_uebung: formData.raum_uebung || undefined,
            raum_praktikum: formData.raum_praktikum || undefined,
            raum_seminar: formData.raum_seminar || undefined,
            kapazitaet_vorlesung: formData.kapazitaet_vorlesung || undefined,
            kapazitaet_uebung: formData.kapazitaet_uebung || undefined,
            kapazitaet_praktikum: formData.kapazitaet_praktikum || undefined,
            kapazitaet_seminar: formData.kapazitaet_seminar || undefined,
          }
        );

        // Update in wizard data
        const updatedModule = data.geplantModule.map(gm =>
          gm.id === editingModul.id
            ? {
                ...gm,
                anzahl_vorlesungen: formData.anzahl_vorlesungen,
                anzahl_uebungen: formData.anzahl_uebungen,
                anzahl_praktika: formData.anzahl_praktika,
                anzahl_seminare: formData.anzahl_seminare,
                anmerkungen: formData.anmerkungen,
                raum_vorlesung: formData.raum_vorlesung,
                raum_uebung: formData.raum_uebung,
                raum_praktikum: formData.raum_praktikum,
                raum_seminar: formData.raum_seminar,
                kapazitaet_vorlesung: formData.kapazitaet_vorlesung,
                kapazitaet_uebung: formData.kapazitaet_uebung,
                kapazitaet_praktikum: formData.kapazitaet_praktikum,
                kapazitaet_seminar: formData.kapazitaet_seminar,
                sws_gesamt: calculateModulSWS(formData.modul, formData)
              }
            : gm
        );

        onUpdate({ geplantModule: updatedModule });
        showToast('Modul aktualisiert', 'success');
      } else {
        // Add new module
        logger.debug('StepModule', 'Adding new module', { kuerzel: formData.modul.kuerzel });
        
        // Stelle sicher dass po_id immer gesetzt ist
        const po_id = formData.modul.po_id || getPOId();

        logger.debug('StepModule', 'PO-ID Debug', {
          'formData.modul.po_id': formData.modul.po_id,
          'getPOId()': getPOId(),
          'Final po_id': po_id
        });

        const addModulData: AddModulData = {
          modul_id: formData.modul.id,
          po_id: po_id,
          anzahl_vorlesungen: formData.anzahl_vorlesungen,
          anzahl_uebungen: formData.anzahl_uebungen,
          anzahl_praktika: formData.anzahl_praktika,
          anzahl_seminare: formData.anzahl_seminare,
          bemerkung: formData.anmerkungen,
          anmerkungen: formData.anmerkungen,
          // Raum-Planung pro Lehrform
          raum_vorlesung: formData.raum_vorlesung || undefined,
          raum_uebung: formData.raum_uebung || undefined,
          raum_praktikum: formData.raum_praktikum || undefined,
          raum_seminar: formData.raum_seminar || undefined,
          kapazitaet_vorlesung: formData.kapazitaet_vorlesung || undefined,
          kapazitaet_uebung: formData.kapazitaet_uebung || undefined,
          kapazitaet_praktikum: formData.kapazitaet_praktikum || undefined,
          kapazitaet_seminar: formData.kapazitaet_seminar || undefined,
        };

        logger.debug('StepModule', 'Sending to backend', {
          ...addModulData,
          multiplikatoren: {
            V: addModulData.anzahl_vorlesungen,
            Ü: addModulData.anzahl_uebungen,
            P: addModulData.anzahl_praktika,
            S: addModulData.anzahl_seminare
          }
        });

        const response = await planungService.addModule(planungId, addModulData);

        if (response.success && response.data) {
          logger.info('StepModule', 'Module added successfully', {
            data: response.data,
            sws_gesamt: response.data.sws_gesamt
          });

          const neuesGeplantesModul: GeplantesModul = {
            ...response.data,
            modul: formData.modul,
            // SWS-Daten
            sws_gesamt: response.data.sws_gesamt || 0,
            sws_vorlesung: response.data.sws_vorlesung || 0,
            sws_uebung: response.data.sws_uebung || 0,
            sws_praktikum: response.data.sws_praktikum || 0,
            sws_seminar: response.data.sws_seminar || 0,
            // Raum-Planung
            raum_vorlesung: formData.raum_vorlesung,
            raum_uebung: formData.raum_uebung,
            raum_praktikum: formData.raum_praktikum,
            raum_seminar: formData.raum_seminar,
            kapazitaet_vorlesung: formData.kapazitaet_vorlesung,
            kapazitaet_uebung: formData.kapazitaet_uebung,
            kapazitaet_praktikum: formData.kapazitaet_praktikum,
            kapazitaet_seminar: formData.kapazitaet_seminar,
          };

          logger.debug('StepModule', 'Gesamt SWS gespeichert', { sws_gesamt: neuesGeplantesModul.sws_gesamt });

          onUpdate({
            geplantModule: [...data.geplantModule, neuesGeplantesModul]
          });

          showToast(`Modul hinzugefügt (${neuesGeplantesModul.sws_gesamt?.toFixed(1)} SWS)`, 'success');
        } else {
          throw new Error(response.message || 'Fehler beim Hinzufügen');
        }
      }

      setDialogOpen(false);
      setFormData(null);
      setEditingModul(null);
    } catch (error: unknown) {
      logger.error('StepModule', 'Error saving module', { error });

      const errorMessage = getErrorMessage(error, 'Fehler beim Speichern des Moduls');
      logger.error('StepModule', 'Final error message', { errorMessage });

      showToast(errorMessage, 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleRemoveModule = async (geplantesModul: GeplantesModul) => {
    if (!planungId) return;

    if (!window.confirm(`Modul "${geplantesModul.modul?.kuerzel}" wirklich entfernen?`)) {
      return;
    }

    logger.debug('StepModule', 'Removing module', { id: geplantesModul.id });

    try {
      await planungService.removeModule(planungId, geplantesModul.id);

      const updatedModule = data.geplantModule.filter(gm => gm.id !== geplantesModul.id);
      onUpdate({ geplantModule: updatedModule });

      showToast('Modul entfernt', 'success');
    } catch (error: unknown) {
      logger.error('StepModule', 'Error removing module', { error });
      showToast(getErrorMessage(error, 'Fehler beim Entfernen'), 'error');
    }
  };

  // Berechne SWS
  const calculateModulSWS = (modul: Modul, formData: ModulFormData): number => {
    if (!modul.lehrformen) return 0;
    
    let total = 0;
    
    // Berechne SWS basierend auf Lehrformen
    modul.lehrformen.forEach((lf: ModulLehrform) => {
      switch (lf.kuerzel) {
        case 'V':
          total += formData.anzahl_vorlesungen * lf.sws;
          break;
        case 'Ü':
          total += formData.anzahl_uebungen * lf.sws;
          break;
        case 'P':
          total += formData.anzahl_praktika * lf.sws;
          break;
        case 'S':
          total += formData.anzahl_seminare * lf.sws;
          break;
      }
    });
    
    return total;
  };

  const calculatePreviewSWS = (): number => {
    if (!formData) return 0;
    return calculateModulSWS(formData.modul, formData);
  };

  const getLehrformenText = (gm: GeplantesModul) => {
    const parts: string[] = [];
    if (gm.anzahl_vorlesungen > 0) parts.push(`${gm.anzahl_vorlesungen}V`);
    if (gm.anzahl_uebungen > 0) parts.push(`${gm.anzahl_uebungen}Ü`);
    if (gm.anzahl_praktika > 0) parts.push(`${gm.anzahl_praktika}P`);
    if (gm.anzahl_seminare > 0) parts.push(`${gm.anzahl_seminare}S`);
    return parts.join(' + ') || 'Keine';
  };

  const getTotalSWS = () => {
    return data.geplantModule.reduce((sum, gm) => sum + (gm.sws_gesamt || 0), 0);
  };

  const canProceed = data.geplantModule.length > 0;

  // Prüfe ob Lehrform verfügbar ist
  const isLehrformAvailable = (modul: Modul, kuerzel: string): boolean => {
    if (!modul.lehrformen) return false;
    return modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === kuerzel);
  };

  return (
    <Box>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Module zur Planung hinzufügen
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Fügen Sie die ausgewählten Module zur Planung hinzu und definieren Sie die Lehrformen.
        </Typography>
      </Box>

      {/* Statistics */}
      {data.geplantModule.length > 0 && (
        <Paper sx={{ p: 2, mb: 3, bgcolor: 'background.default' }}>
          <Grid container spacing={2}>
            <Grid item xs={12} md={4}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <School color="primary" />
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    Geplante Module
                  </Typography>
                  <Typography variant="h6">
                    {data.geplantModule.length}
                  </Typography>
                </Box>
              </Box>
            </Grid>
            <Grid item xs={12} md={4}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Schedule color="secondary" />
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    Gesamt SWS
                  </Typography>
                  <Typography variant="h6">
                    {getTotalSWS().toFixed(1)}
                  </Typography>
                </Box>
              </Box>
            </Grid>
            <Grid item xs={12} md={4}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <CheckCircle color="success" />
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    Status
                  </Typography>
                  <Typography variant="h6" color="success.main">
                    {canProceed ? 'Bereit' : 'Unvollständig'}
                  </Typography>
                </Box>
              </Box>
            </Grid>
          </Grid>
        </Paper>
      )}

      {/* Ausgewählte Module aus Schritt 2 */}
      {data.selectedModules && data.selectedModules.length > 0 && (
        <>
          <Typography variant="subtitle2" gutterBottom fontWeight={600} sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <CheckCircle color="success" fontSize="small" />
            Ausgewählte Module aus Schritt 2
          </Typography>
          <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 2 }}>
            Diese Module haben Sie in Schritt 2 ausgewählt. Klicken Sie auf "Hinzufügen", um Multiplikatoren festzulegen.
          </Typography>

          <Grid container spacing={2} sx={{ mb: 4 }}>
            {data.selectedModules
              .filter((modul) => {
                // Zeige nur Module, die noch nicht hinzugefügt wurden
                return !data.geplantModule.some(gm => gm.modul_id === modul.id);
              })
              .map((modul) => (
                <Grid item xs={12} md={6} key={modul.id}>
                  <Card variant="outlined" sx={{ borderColor: 'success.main', borderWidth: 2 }}>
                    <CardContent>
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <Box sx={{ flex: 1 }}>
                          <Typography variant="h6" color="success.main">
                            {modul.kuerzel}
                          </Typography>
                          <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                            {modul.bezeichnung_de}
                          </Typography>
                          <Box sx={{ display: 'flex', gap: 0.5 }}>
                            {modul.leistungspunkte && (
                              <Chip size="small" label={`${modul.leistungspunkte} ECTS`} />
                            )}
                            {modul.sws_gesamt && modul.sws_gesamt > 0 && (
                              <Chip size="small" label={`${modul.sws_gesamt} SWS`} color="secondary" />
                            )}
                          </Box>
                        </Box>
                        <Button
                          variant="contained"
                          color="success"
                          size="small"
                          startIcon={<Add />}
                          onClick={() => handleAddModule(modul)}
                        >
                          Hinzufügen
                        </Button>
                      </Box>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
          </Grid>

          <Divider sx={{ my: 3 }} />
        </>
      )}

      {/* Weitere Module über Suche */}
      <Typography variant="subtitle2" gutterBottom fontWeight={600}>
        Weitere Module über Suche hinzufügen
      </Typography>
      <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 2 }}>
        Suchen Sie nach weiteren Modulen, die Sie zur Planung hinzufügen möchten.
      </Typography>

      {/* Search */}
      <TextField
        fullWidth
        size="small"
        placeholder="Modul suchen (Kürzel oder Bezeichnung)..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        sx={{ mb: 2 }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start">
              <Search />
            </InputAdornment>
          ),
        }}
      />

      <Grid container spacing={2} sx={{ mb: 3, maxHeight: '400px', overflowY: 'auto' }}>
        {alleModule
          .filter((modul) => {
            // Filter bereits hinzugefügte Module
            const alreadyAdded = data.geplantModule.some(gm => gm.modul_id === modul.id);
            if (alreadyAdded) return false;

            // Suchfilter
            if (searchTerm) {
              const search = searchTerm.toLowerCase();
              return (
                modul.kuerzel?.toLowerCase().includes(search) ||
                modul.bezeichnung_de?.toLowerCase().includes(search)
              );
            }

            return true;
          })
          .slice(0, PERFORMANCE_LIMITS.maxModuleSuggestions) // Limitiere für Performance
          .map((modul) => {
            return (
              <Grid item xs={12} md={6} key={modul.id}>
                <Card variant="outlined">
                  <CardContent>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                      <Box sx={{ flex: 1 }}>
                        <Typography variant="h6">
                          {modul.kuerzel}
                        </Typography>
                        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                          {modul.bezeichnung_de}
                        </Typography>
                        <Box sx={{ display: 'flex', gap: 0.5 }}>
                          {modul.leistungspunkte && (
                            <Chip size="small" label={`${modul.leistungspunkte} ECTS`} />
                          )}
                          {modul.sws_gesamt && modul.sws_gesamt > 0 && (
                            <Chip size="small" label={`${modul.sws_gesamt} SWS`} color="secondary" />
                          )}
                        </Box>
                      </Box>
                      <Button
                        variant="contained"
                        size="small"
                        startIcon={<Add />}
                        onClick={() => handleAddModule(modul)}
                      >
                        Hinzufügen
                      </Button>
                    </Box>
                  </CardContent>
                </Card>
              </Grid>
            );
          })}
      </Grid>

      {/* Added Modules Table */}
      {data.geplantModule.length > 0 && (
        <>
          <Typography variant="subtitle2" gutterBottom fontWeight={600}>
            Geplante Module ({data.geplantModule.length})
          </Typography>
          <TableContainer component={Paper} variant="outlined" sx={{ mb: 3 }}>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell><strong>Modul</strong></TableCell>
                  <TableCell><strong>Bezeichnung</strong></TableCell>
                  <TableCell align="center"><strong>Lehrformen</strong></TableCell>
                  <TableCell align="center"><strong>SWS</strong></TableCell>
                  <TableCell align="right"><strong>Aktionen</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {data.geplantModule.map((gm) => (
                  <TableRow key={gm.id || gm.modul_id}>
                    <TableCell>
                      <Typography variant="body2" fontWeight={600}>
                        {gm.modul?.kuerzel}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {gm.modul?.bezeichnung_de}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Chip 
                        size="small" 
                        label={getLehrformenText(gm)}
                        color="primary"
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="center">
                      <Typography variant="body2" fontWeight={600}>
                        {gm.sws_gesamt?.toFixed(1) || '0.0'}
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      <IconButton
                        size="small"
                        onClick={() => handleEditModule(gm)}
                        color="primary"
                      >
                        <Edit fontSize="small" />
                      </IconButton>
                      <IconButton
                        size="small"
                        onClick={() => handleRemoveModule(gm)}
                        color="error"
                      >
                        <Delete fontSize="small" />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </>
      )}

      {!canProceed && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          <Typography variant="body2">
            Bitte fügen Sie mindestens ein Modul hinzu.
          </Typography>
        </Alert>
      )}

      {/* Dialog */}
      <Dialog 
        open={dialogOpen} 
        onClose={() => setDialogOpen(false)}
        maxWidth="md"
        fullWidth
      >
        {formData && (
          <>
            <DialogTitle>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <Typography variant="h6">
                  {editingModul ? 'Modul bearbeiten' : 'Modul hinzufügen'}
                </Typography>
                <IconButton onClick={() => setDialogOpen(false)}>
                  <Close />
                </IconButton>
              </Box>
            </DialogTitle>
            
            <DialogContent>
              {/* Modul Info */}
              <Paper variant="outlined" sx={{ p: 2, mb: 3, bgcolor: 'background.default' }}>
                <Typography variant="subtitle1" fontWeight={600}>
                  {formData.modul.kuerzel}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {formData.modul.bezeichnung_de}
                </Typography>
                <Box sx={{ display: 'flex', gap: 1, mt: 1 }}>
                  {formData.modul.leistungspunkte && (
                    <Chip
                      size="small"
                      icon={<School />}
                      label={`${formData.modul.leistungspunkte} ECTS`}
                    />
                  )}
                  {formData.modul.sws_gesamt && formData.modul.sws_gesamt > 0 && (
                    <Chip
                      size="small"
                      icon={<Schedule />}
                      label={`${formData.modul.sws_gesamt} SWS (Basis)`}
                      color="secondary"
                    />
                  )}
                </Box>
                
                {/* Zeige verfügbare Lehrformen */}
                {formData.modul.lehrformen && formData.modul.lehrformen.length > 0 && (
                  <Box sx={{ mt: 2 }}>
                    <Typography variant="caption" color="text.secondary">
                      Verfügbare Lehrformen:
                    </Typography>
                    <Box sx={{ display: 'flex', gap: 0.5, mt: 0.5 }}>
                      {formData.modul.lehrformen.map((lf: ModulLehrform) => (
                        <Chip 
                          key={lf.id}
                          size="small" 
                          label={`${lf.kuerzel}: ${lf.sws} SWS`}
                          variant="outlined"
                        />
                      ))}
                    </Box>
                  </Box>
                )}
              </Paper>

              {/* Lehrformen */}
              <Typography variant="subtitle2" gutterBottom fontWeight={600}>
                Lehrformen & Multiplikatoren
              </Typography>
              <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 2 }}>
                Geben Sie an, wie oft jede Lehrform stattfinden soll (z.B. 2 = Lehrform in 2 Gruppen).
              </Typography>

              <Grid container spacing={2}>
                {/* Vorlesungen */}
                {isLehrformAvailable(formData.modul, 'V') && (
                  <Grid item xs={6}>
                    <TextField
                      fullWidth
                      type="number"
                      label="Vorlesungen"
                      value={formData.anzahl_vorlesungen}
                      onChange={(e) => setFormData({
                        ...formData,
                        anzahl_vorlesungen: Math.max(0, parseInt(e.target.value) || 0)
                      })}
                      InputProps={{
                        endAdornment: (
                          <InputAdornment position="end">
                            <Chip 
                              size="small" 
                              label={`${formData.modul.lehrformen?.find((lf: ModulLehrform) => lf.kuerzel === 'V')?.sws || 0} SWS`}
                            />
                          </InputAdornment>
                        ),
                      }}
                      inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                    />
                  </Grid>
                )}

                {/* Übungen */}
                {isLehrformAvailable(formData.modul, 'Ü') && (
                  <Grid item xs={6}>
                    <TextField
                      fullWidth
                      type="number"
                      label="Übungen"
                      value={formData.anzahl_uebungen}
                      onChange={(e) => setFormData({
                        ...formData,
                        anzahl_uebungen: Math.max(0, parseInt(e.target.value) || 0)
                      })}
                      InputProps={{
                        endAdornment: (
                          <InputAdornment position="end">
                            <Chip 
                              size="small" 
                              label={`${formData.modul.lehrformen?.find((lf: ModulLehrform) => lf.kuerzel === 'Ü')?.sws || 0} SWS`}
                            />
                          </InputAdornment>
                        ),
                      }}
                      inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                    />
                  </Grid>
                )}

                {/* Praktika */}
                {isLehrformAvailable(formData.modul, 'P') && (
                  <Grid item xs={6}>
                    <TextField
                      fullWidth
                      type="number"
                      label="Praktika"
                      value={formData.anzahl_praktika}
                      onChange={(e) => setFormData({
                        ...formData,
                        anzahl_praktika: Math.max(0, parseInt(e.target.value) || 0)
                      })}
                      InputProps={{
                        endAdornment: (
                          <InputAdornment position="end">
                            <Chip 
                              size="small" 
                              label={`${formData.modul.lehrformen?.find((lf: ModulLehrform) => lf.kuerzel === 'P')?.sws || 0} SWS`}
                            />
                          </InputAdornment>
                        ),
                      }}
                      inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                    />
                  </Grid>
                )}

                {/* Seminare */}
                {isLehrformAvailable(formData.modul, 'S') && (
                  <Grid item xs={6}>
                    <TextField
                      fullWidth
                      type="number"
                      label="Seminare"
                      value={formData.anzahl_seminare}
                      onChange={(e) => setFormData({
                        ...formData,
                        anzahl_seminare: Math.max(0, parseInt(e.target.value) || 0)
                      })}
                      InputProps={{
                        endAdornment: (
                          <InputAdornment position="end">
                            <Chip 
                              size="small" 
                              label={`${formData.modul.lehrformen?.find((lf: ModulLehrform) => lf.kuerzel === 'S')?.sws || 0} SWS`}
                            />
                          </InputAdornment>
                        ),
                      }}
                      inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                    />
                  </Grid>
                )}
                
                {/* Fallback wenn keine Lehrformen definiert */}
                {(!formData.modul.lehrformen || formData.modul.lehrformen.length === 0) && (
                  <Grid item xs={12}>
                    <Alert severity="warning">
                      <Typography variant="body2">
                        Für dieses Modul sind keine Lehrformen definiert. 
                        Bitte setzen Sie mindestens einen Multiplikator.
                      </Typography>
                    </Alert>
                    <Grid container spacing={2} sx={{ mt: 1 }}>
                      <Grid item xs={6}>
                        <TextField
                          fullWidth
                          type="number"
                          label="Vorlesungen"
                          value={formData.anzahl_vorlesungen}
                          onChange={(e) => setFormData({
                            ...formData,
                            anzahl_vorlesungen: Math.max(0, parseInt(e.target.value) || 0)
                          })}
                          inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                        />
                      </Grid>
                      <Grid item xs={6}>
                        <TextField
                          fullWidth
                          type="number"
                          label="Übungen"
                          value={formData.anzahl_uebungen}
                          onChange={(e) => setFormData({
                            ...formData,
                            anzahl_uebungen: Math.max(0, parseInt(e.target.value) || 0)
                          })}
                          inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                        />
                      </Grid>
                    </Grid>
                  </Grid>
                )}
              </Grid>

              {/* SWS Preview */}
              <Paper variant="outlined" sx={{ p: 2, mt: 2, bgcolor: 'primary.50' }}>
                <Typography variant="body2" color="text.secondary">
                  Berechnete Gesamt-SWS für dieses Modul:
                </Typography>
                <Typography variant="h5" color="primary" fontWeight={600}>
                  {calculatePreviewSWS().toFixed(1)} SWS
                </Typography>
                {formData.modul.lehrformen && formData.modul.lehrformen.length > 0 && (
                  <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
                    Berechnung: {
                      [
                        formData.anzahl_vorlesungen > 0 && `${formData.anzahl_vorlesungen}×${formData.modul.lehrformen.find((lf: ModulLehrform) => lf.kuerzel === 'V')?.sws || 0}V`,
                        formData.anzahl_uebungen > 0 && `${formData.anzahl_uebungen}×${formData.modul.lehrformen.find((lf: ModulLehrform) => lf.kuerzel === 'Ü')?.sws || 0}Ü`,
                        formData.anzahl_praktika > 0 && `${formData.anzahl_praktika}×${formData.modul.lehrformen.find((lf: ModulLehrform) => lf.kuerzel === 'P')?.sws || 0}P`,
                        formData.anzahl_seminare > 0 && `${formData.anzahl_seminare}×${formData.modul.lehrformen.find((lf: ModulLehrform) => lf.kuerzel === 'S')?.sws || 0}S`,
                      ].filter(Boolean).join(' + ') || 'Keine Berechnung'
                    }
                  </Typography>
                )}
              </Paper>

              {/* Validation Warning */}
              {(formData.anzahl_vorlesungen + formData.anzahl_uebungen +
                formData.anzahl_praktika + formData.anzahl_seminare) === 0 && (
                <Alert severity="warning" sx={{ mt: 2 }}>
                  <Typography variant="body2">
                    Bitte setzen Sie mindestens eine Lehrform auf einen Wert größer als 0.
                  </Typography>
                </Alert>
              )}

              {/* =================== RAUMPLANUNG PRO LEHRFORM =================== */}
              <Divider sx={{ my: 3 }} />
              <Typography variant="subtitle2" gutterBottom fontWeight={600}>
                Raumplanung pro Veranstaltung
              </Typography>
              <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 2 }}>
                Geben Sie an, welche Räume und Kapazitäten Sie für jede Lehrform benötigen.
              </Typography>

              <Grid container spacing={2}>
                {/* Vorlesung Raum */}
                {formData.anzahl_vorlesungen > 0 && (
                  <>
                    <Grid item xs={12}>
                      <Alert severity="info" icon={<School />} sx={{ py: 0.5 }}>
                        <Typography variant="subtitle2">
                          Vorlesung ({formData.anzahl_vorlesungen}x)
                        </Typography>
                      </Alert>
                    </Grid>
                    <Grid item xs={8}>
                      <TextField
                        fullWidth
                        size="small"
                        label="Raumwunsch Vorlesung"
                        placeholder="z.B. Hörsaal, großer Raum, Gebäude B..."
                        value={formData.raum_vorlesung}
                        onChange={(e) => setFormData({ ...formData, raum_vorlesung: e.target.value })}
                      />
                    </Grid>
                    <Grid item xs={4}>
                      <TextField
                        fullWidth
                        size="small"
                        type="number"
                        label="Kapazität"
                        value={formData.kapazitaet_vorlesung}
                        onChange={(e) => setFormData({ ...formData, kapazitaet_vorlesung: parseInt(e.target.value) || 0 })}
                        inputProps={{ min: 0 }}
                      />
                    </Grid>
                  </>
                )}

                {/* Übung Raum */}
                {formData.anzahl_uebungen > 0 && (
                  <>
                    <Grid item xs={12}>
                      <Alert severity="info" icon={<School />} sx={{ py: 0.5 }}>
                        <Typography variant="subtitle2">
                          Übung ({formData.anzahl_uebungen}x)
                        </Typography>
                      </Alert>
                    </Grid>
                    <Grid item xs={8}>
                      <TextField
                        fullWidth
                        size="small"
                        label="Raumwunsch Übung"
                        placeholder="z.B. Seminarraum, Computerraum..."
                        value={formData.raum_uebung}
                        onChange={(e) => setFormData({ ...formData, raum_uebung: e.target.value })}
                      />
                    </Grid>
                    <Grid item xs={4}>
                      <TextField
                        fullWidth
                        size="small"
                        type="number"
                        label="Kapazität"
                        value={formData.kapazitaet_uebung}
                        onChange={(e) => setFormData({ ...formData, kapazitaet_uebung: parseInt(e.target.value) || 0 })}
                        inputProps={{ min: 0 }}
                      />
                    </Grid>
                  </>
                )}

                {/* Praktikum Raum */}
                {formData.anzahl_praktika > 0 && (
                  <>
                    <Grid item xs={12}>
                      <Alert severity="info" icon={<School />} sx={{ py: 0.5 }}>
                        <Typography variant="subtitle2">
                          Praktikum ({formData.anzahl_praktika}x)
                        </Typography>
                      </Alert>
                    </Grid>
                    <Grid item xs={8}>
                      <TextField
                        fullWidth
                        size="small"
                        label="Raumwunsch Praktikum"
                        placeholder="z.B. Labor, Computerraum, Werkstatt..."
                        value={formData.raum_praktikum}
                        onChange={(e) => setFormData({ ...formData, raum_praktikum: e.target.value })}
                      />
                    </Grid>
                    <Grid item xs={4}>
                      <TextField
                        fullWidth
                        size="small"
                        type="number"
                        label="Kapazität"
                        value={formData.kapazitaet_praktikum}
                        onChange={(e) => setFormData({ ...formData, kapazitaet_praktikum: parseInt(e.target.value) || 0 })}
                        inputProps={{ min: 0 }}
                      />
                    </Grid>
                  </>
                )}

                {/* Seminar Raum */}
                {formData.anzahl_seminare > 0 && (
                  <>
                    <Grid item xs={12}>
                      <Alert severity="info" icon={<School />} sx={{ py: 0.5 }}>
                        <Typography variant="subtitle2">
                          Seminar ({formData.anzahl_seminare}x)
                        </Typography>
                      </Alert>
                    </Grid>
                    <Grid item xs={8}>
                      <TextField
                        fullWidth
                        size="small"
                        label="Raumwunsch Seminar"
                        placeholder="z.B. Seminarraum..."
                        value={formData.raum_seminar}
                        onChange={(e) => setFormData({ ...formData, raum_seminar: e.target.value })}
                      />
                    </Grid>
                    <Grid item xs={4}>
                      <TextField
                        fullWidth
                        size="small"
                        type="number"
                        label="Kapazität"
                        value={formData.kapazitaet_seminar}
                        onChange={(e) => setFormData({ ...formData, kapazitaet_seminar: parseInt(e.target.value) || 0 })}
                        inputProps={{ min: 0 }}
                      />
                    </Grid>
                  </>
                )}
              </Grid>

              <Divider sx={{ my: 3 }} />

              {/* Anmerkungen */}
              <TextField
                fullWidth
                multiline
                rows={3}
                label="Anmerkungen (optional)"
                value={formData.anmerkungen}
                onChange={(e) => setFormData({ ...formData, anmerkungen: e.target.value })}
                sx={{ mt: 2 }}
              />
            </DialogContent>

            <DialogActions>
              <Button onClick={() => setDialogOpen(false)}>
                Abbrechen
              </Button>
              <Button
                variant="contained"
                startIcon={<Save />}
                onClick={handleSaveModule}
                disabled={saving || 
                  (formData.anzahl_vorlesungen + formData.anzahl_uebungen + 
                   formData.anzahl_praktika + formData.anzahl_seminare) === 0}
              >
                {saving ? 'Speichert...' : 'Speichern'}
              </Button>
            </DialogActions>
          </>
        )}
      </Dialog>

      {/* Navigation */}
      <Box sx={{ mt: 4, display: 'flex', justifyContent: 'space-between' }}>
        <Button
          startIcon={<NavigateBefore />}
          onClick={onBack}
        >
          Zurück
        </Button>
        <Button
          variant="contained"
          endIcon={<NavigateNext />}
          onClick={onNext}
          disabled={!canProceed}
        >
          Weiter
        </Button>
      </Box>
    </Box>
  );
};

export default Stepmodulehinzufuegen;