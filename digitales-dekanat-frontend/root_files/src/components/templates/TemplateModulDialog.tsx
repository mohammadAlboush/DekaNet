import React, { useState, useEffect } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Grid,
  Box,
  Typography,
  Paper,
  Chip,
  Alert,
  Divider,
  IconButton,
  InputAdornment,
  Autocomplete,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  CircularProgress,
} from '@mui/material';
import {
  Close,
  Save,
  School,
  Schedule,
  Search,
  Group,
} from '@mui/icons-material';
import { Modul, ModulLehrform } from '../../types/modul.types';
import templateService, { TemplateModul, AddTemplateModulData } from '../../services/templateService';
import api from '../../services/api';
import { useToastStore } from '../common/Toast';

interface Dozent {
  id: number;
  name_komplett: string;
  kuerzel?: string;
}

interface TemplateModulDialogProps {
  open: boolean;
  onClose: () => void;
  templateId: number;
  editingModul?: TemplateModul | null;
  onSave: () => void;
}

interface ModulFormData {
  modul: Modul | null;
  anzahl_vorlesungen: number;
  anzahl_uebungen: number;
  anzahl_praktika: number;
  anzahl_seminare: number;
  anmerkungen: string;
  mitarbeiter_ids: number[];
  raum_vorlesung: string;
  raum_uebung: string;
  raum_praktikum: string;
  raum_seminar: string;
  kapazitaet_vorlesung: number;
  kapazitaet_uebung: number;
  kapazitaet_praktikum: number;
  kapazitaet_seminar: number;
}

const initialFormData: ModulFormData = {
  modul: null,
  anzahl_vorlesungen: 0,
  anzahl_uebungen: 0,
  anzahl_praktika: 0,
  anzahl_seminare: 0,
  anmerkungen: '',
  mitarbeiter_ids: [],
  raum_vorlesung: '',
  raum_uebung: '',
  raum_praktikum: '',
  raum_seminar: '',
  kapazitaet_vorlesung: 30,
  kapazitaet_uebung: 20,
  kapazitaet_praktikum: 15,
  kapazitaet_seminar: 20,
};

/**
 * TemplateModulDialog
 *
 * Dialog zum Hinzufügen oder Bearbeiten eines Moduls im Template.
 * Basiert auf dem Pattern aus Stepmodulehinzufuegen.tsx
 */
const TemplateModulDialog: React.FC<TemplateModulDialogProps> = ({
  open,
  onClose,
  templateId,
  editingModul,
  onSave,
}) => {
  const showToast = useToastStore((state) => state.showToast);

  const [formData, setFormData] = useState<ModulFormData>(initialFormData);
  const [alleModule, setAlleModule] = useState<Modul[]>([]);
  const [alleDozenten, setAlleDozenten] = useState<Dozent[]>([]);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [modulSearchOpen, setModulSearchOpen] = useState(false);

  // Lade Module und Dozenten beim Öffnen
  useEffect(() => {
    if (open) {
      loadData();
      if (editingModul) {
        loadEditingModul();
      } else {
        setFormData(initialFormData);
      }
    }
  }, [open, editingModul]);

  const loadData = async () => {
    setLoading(true);
    try {
      // Lade alle Module
      const modulResponse = await api.get('/module');
      if (modulResponse.data.success) {
        setAlleModule(modulResponse.data.data || []);
      }

      // Lade alle Dozenten
      const dozentenResponse = await api.get('/dozenten');
      if (dozentenResponse.data.success) {
        setAlleDozenten(dozentenResponse.data.data || []);
      }
    } catch (error) {
      console.error('Error loading data:', error);
      showToast('Fehler beim Laden der Daten', 'error');
    } finally {
      setLoading(false);
    }
  };

  const loadEditingModul = async () => {
    if (!editingModul) return;

    // Finde das vollständige Modul aus alleModule
    const vollstaendigesModul = alleModule.find(m => m.id === editingModul.modul_id);

    setFormData({
      modul: vollstaendigesModul || {
        id: editingModul.modul_id,
        kuerzel: editingModul.modul?.kuerzel || '',
        bezeichnung_de: editingModul.modul?.bezeichnung_de || '',
        bezeichnung_en: '',
        leistungspunkte: editingModul.modul?.leistungspunkte || 0,
        sws_gesamt: 0,
        po_id: editingModul.po_id,
        lehrformen: [],
      } as Modul,
      anzahl_vorlesungen: editingModul.anzahl_vorlesungen || 0,
      anzahl_uebungen: editingModul.anzahl_uebungen || 0,
      anzahl_praktika: editingModul.anzahl_praktika || 0,
      anzahl_seminare: editingModul.anzahl_seminare || 0,
      anmerkungen: editingModul.anmerkungen || '',
      mitarbeiter_ids: editingModul.mitarbeiter_ids || [],
      raum_vorlesung: editingModul.raum_vorlesung || '',
      raum_uebung: editingModul.raum_uebung || '',
      raum_praktikum: editingModul.raum_praktikum || '',
      raum_seminar: editingModul.raum_seminar || '',
      kapazitaet_vorlesung: editingModul.kapazitaet_vorlesung || 30,
      kapazitaet_uebung: editingModul.kapazitaet_uebung || 20,
      kapazitaet_praktikum: editingModul.kapazitaet_praktikum || 15,
      kapazitaet_seminar: editingModul.kapazitaet_seminar || 20,
    });
  };

  // Wenn alleModule geladen sind und wir editieren, aktualisiere das Modul
  useEffect(() => {
    if (editingModul && alleModule.length > 0 && formData.modul) {
      const vollstaendigesModul = alleModule.find(m => m.id === editingModul.modul_id);
      if (vollstaendigesModul && vollstaendigesModul.id !== formData.modul.id) {
        setFormData(prev => ({ ...prev, modul: vollstaendigesModul }));
      }
    }
  }, [alleModule, editingModul]);

  const handleModulSelect = (modul: Modul | null) => {
    if (!modul) {
      setFormData(initialFormData);
      return;
    }

    // Initialisiere Multiplikatoren basierend auf Lehrformen
    let anzahl_vorlesungen = 0;
    let anzahl_uebungen = 0;
    let anzahl_praktika = 0;
    let anzahl_seminare = 0;

    if (modul.lehrformen && modul.lehrformen.length > 0) {
      const hatVorlesung = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'V');
      const hatUebung = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'Ü');
      const hatPraktikum = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'P');
      const hatSeminar = modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === 'S');

      anzahl_vorlesungen = hatVorlesung ? 1 : 0;
      anzahl_uebungen = hatUebung ? 1 : 0;
      anzahl_praktika = hatPraktikum ? 1 : 0;
      anzahl_seminare = hatSeminar ? 1 : 0;
    } else {
      anzahl_vorlesungen = 1;
    }

    setFormData({
      ...initialFormData,
      modul,
      anzahl_vorlesungen,
      anzahl_uebungen,
      anzahl_praktika,
      anzahl_seminare,
    });
  };

  const handleSave = async () => {
    if (!formData.modul) {
      showToast('Bitte wählen Sie ein Modul aus', 'warning');
      return;
    }

    const totalMultiplikatoren =
      formData.anzahl_vorlesungen +
      formData.anzahl_uebungen +
      formData.anzahl_praktika +
      formData.anzahl_seminare;

    if (totalMultiplikatoren === 0) {
      showToast('Mindestens eine Lehrform muss > 0 sein', 'warning');
      return;
    }

    setSaving(true);
    try {
      const data: AddTemplateModulData = {
        modul_id: formData.modul.id,
        po_id: formData.modul.po_id || 1,
        anzahl_vorlesungen: formData.anzahl_vorlesungen,
        anzahl_uebungen: formData.anzahl_uebungen,
        anzahl_praktika: formData.anzahl_praktika,
        anzahl_seminare: formData.anzahl_seminare,
        mitarbeiter_ids: formData.mitarbeiter_ids.length > 0 ? formData.mitarbeiter_ids : undefined,
        anmerkungen: formData.anmerkungen || undefined,
        raum_vorlesung: formData.raum_vorlesung || undefined,
        raum_uebung: formData.raum_uebung || undefined,
        raum_praktikum: formData.raum_praktikum || undefined,
        raum_seminar: formData.raum_seminar || undefined,
        kapazitaet_vorlesung: formData.kapazitaet_vorlesung || undefined,
        kapazitaet_uebung: formData.kapazitaet_uebung || undefined,
        kapazitaet_praktikum: formData.kapazitaet_praktikum || undefined,
        kapazitaet_seminar: formData.kapazitaet_seminar || undefined,
      };

      if (editingModul) {
        await templateService.updateModul(templateId, editingModul.id, data);
        showToast('Modul aktualisiert', 'success');
      } else {
        await templateService.addModul(templateId, data);
        showToast('Modul hinzugefügt', 'success');
      }

      onSave();
      onClose();
    } catch (error: any) {
      console.error('Error saving module:', error);
      showToast(error.message || 'Fehler beim Speichern', 'error');
    } finally {
      setSaving(false);
    }
  };

  const isLehrformAvailable = (kuerzel: string): boolean => {
    if (!formData.modul?.lehrformen) return false;
    return formData.modul.lehrformen.some((lf: ModulLehrform) => lf.kuerzel === kuerzel);
  };

  const getLehrformSWS = (kuerzel: string): number => {
    if (!formData.modul?.lehrformen) return 0;
    const lf = formData.modul.lehrformen.find((lf: ModulLehrform) => lf.kuerzel === kuerzel);
    return lf?.sws || 0;
  };

  const calculatePreviewSWS = (): number => {
    if (!formData.modul?.lehrformen) return 0;

    let total = 0;
    formData.modul.lehrformen.forEach((lf: ModulLehrform) => {
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

  const getLehrformenText = (): string => {
    const parts: string[] = [];
    if (formData.anzahl_vorlesungen > 0) parts.push(`${formData.anzahl_vorlesungen}V`);
    if (formData.anzahl_uebungen > 0) parts.push(`${formData.anzahl_uebungen}Ü`);
    if (formData.anzahl_praktika > 0) parts.push(`${formData.anzahl_praktika}P`);
    if (formData.anzahl_seminare > 0) parts.push(`${formData.anzahl_seminare}S`);
    return parts.join(' + ') || 'Keine';
  };

  return (
    <Dialog
      open={open}
      onClose={onClose}
      maxWidth="md"
      fullWidth
    >
      <DialogTitle>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Typography variant="h6">
            {editingModul ? 'Modul bearbeiten' : 'Modul hinzufügen'}
          </Typography>
          <IconButton onClick={onClose} size="small">
            <Close />
          </IconButton>
        </Box>
      </DialogTitle>

      <DialogContent>
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
            <CircularProgress />
          </Box>
        ) : (
          <>
            {/* Modul-Auswahl */}
            {!editingModul && (
              <Box sx={{ mb: 3 }}>
                <Typography variant="subtitle2" gutterBottom fontWeight={600}>
                  Modul auswählen
                </Typography>
                <Autocomplete
                  open={modulSearchOpen}
                  onOpen={() => setModulSearchOpen(true)}
                  onClose={() => setModulSearchOpen(false)}
                  options={alleModule}
                  getOptionLabel={(option) => `${option.kuerzel} - ${option.bezeichnung_de}`}
                  value={formData.modul}
                  onChange={(_, value) => handleModulSelect(value)}
                  renderInput={(params) => (
                    <TextField
                      {...params}
                      placeholder="Modul suchen..."
                      InputProps={{
                        ...params.InputProps,
                        startAdornment: (
                          <>
                            <InputAdornment position="start">
                              <Search />
                            </InputAdornment>
                            {params.InputProps.startAdornment}
                          </>
                        ),
                      }}
                    />
                  )}
                  renderOption={(props, option) => (
                    <li {...props} key={option.id}>
                      <Box>
                        <Typography variant="body2" fontWeight={600}>
                          {option.kuerzel}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {option.bezeichnung_de}
                        </Typography>
                      </Box>
                    </li>
                  )}
                />
              </Box>
            )}

            {/* Modul Info */}
            {formData.modul && (
              <>
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

                {/* Lehrformen & Multiplikatoren */}
                <Typography variant="subtitle2" gutterBottom fontWeight={600}>
                  Lehrformen & Multiplikatoren
                </Typography>
                <Typography variant="caption" color="text.secondary" display="block" sx={{ mb: 2 }}>
                  Geben Sie an, wie oft jede Lehrform stattfinden soll.
                </Typography>

                <Grid container spacing={2}>
                  {isLehrformAvailable('V') && (
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
                              <Chip size="small" label={`${getLehrformSWS('V')} SWS`} />
                            </InputAdornment>
                          ),
                        }}
                        inputProps={{ min: 0, max: 10 }}
                      />
                    </Grid>
                  )}

                  {isLehrformAvailable('Ü') && (
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
                              <Chip size="small" label={`${getLehrformSWS('Ü')} SWS`} />
                            </InputAdornment>
                          ),
                        }}
                        inputProps={{ min: 0, max: 10 }}
                      />
                    </Grid>
                  )}

                  {isLehrformAvailable('P') && (
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
                              <Chip size="small" label={`${getLehrformSWS('P')} SWS`} />
                            </InputAdornment>
                          ),
                        }}
                        inputProps={{ min: 0, max: 10 }}
                      />
                    </Grid>
                  )}

                  {isLehrformAvailable('S') && (
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
                              <Chip size="small" label={`${getLehrformSWS('S')} SWS`} />
                            </InputAdornment>
                          ),
                        }}
                        inputProps={{ min: 0, max: 10 }}
                      />
                    </Grid>
                  )}

                  {/* Fallback wenn keine Lehrformen definiert */}
                  {(!formData.modul.lehrformen || formData.modul.lehrformen.length === 0) && (
                    <>
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
                          inputProps={{ min: 0, max: 10 }}
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
                          inputProps={{ min: 0, max: 10 }}
                        />
                      </Grid>
                    </>
                  )}
                </Grid>

                {/* SWS Preview */}
                <Paper variant="outlined" sx={{ p: 2, mt: 2, bgcolor: 'primary.50' }}>
                  <Typography variant="body2" color="text.secondary">
                    Konfiguration: {getLehrformenText()}
                  </Typography>
                  <Typography variant="h5" color="primary" fontWeight={600}>
                    {calculatePreviewSWS().toFixed(1)} SWS
                  </Typography>
                </Paper>

                {/* Validation Warning */}
                {(formData.anzahl_vorlesungen + formData.anzahl_uebungen +
                  formData.anzahl_praktika + formData.anzahl_seminare) === 0 && (
                  <Alert severity="warning" sx={{ mt: 2 }}>
                    Bitte setzen Sie mindestens eine Lehrform auf einen Wert größer als 0.
                  </Alert>
                )}

                {/* Mitarbeiter-Zuordnung */}
                <Divider sx={{ my: 3 }} />
                <Typography variant="subtitle2" gutterBottom fontWeight={600}>
                  <Group sx={{ mr: 1, verticalAlign: 'middle', fontSize: 18 }} />
                  Mitarbeiter-Zuordnung (optional)
                </Typography>
                <FormControl fullWidth sx={{ mb: 2 }}>
                  <InputLabel>Mitarbeiter</InputLabel>
                  <Select
                    multiple
                    value={formData.mitarbeiter_ids}
                    onChange={(e) => setFormData({
                      ...formData,
                      mitarbeiter_ids: e.target.value as number[]
                    })}
                    label="Mitarbeiter"
                    renderValue={(selected) => (
                      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                        {(selected as number[]).map((id) => {
                          const dozent = alleDozenten.find(d => d.id === id);
                          return (
                            <Chip
                              key={id}
                              label={dozent?.name_komplett || `ID: ${id}`}
                              size="small"
                            />
                          );
                        })}
                      </Box>
                    )}
                  >
                    {alleDozenten.map((dozent) => (
                      <MenuItem key={dozent.id} value={dozent.id}>
                        {dozent.name_komplett}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>

                {/* Raumplanung */}
                <Divider sx={{ my: 3 }} />
                <Typography variant="subtitle2" gutterBottom fontWeight={600}>
                  Raumplanung pro Lehrform (optional)
                </Typography>

                <Grid container spacing={2}>
                  {formData.anzahl_vorlesungen > 0 && (
                    <>
                      <Grid item xs={12}>
                        <Alert severity="info" sx={{ py: 0.5 }}>
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
                          placeholder="z.B. Hörsaal, großer Raum..."
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

                  {formData.anzahl_uebungen > 0 && (
                    <>
                      <Grid item xs={12}>
                        <Alert severity="info" sx={{ py: 0.5 }}>
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
                          placeholder="z.B. Seminarraum..."
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

                  {formData.anzahl_praktika > 0 && (
                    <>
                      <Grid item xs={12}>
                        <Alert severity="info" sx={{ py: 0.5 }}>
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
                          placeholder="z.B. Labor, Computerraum..."
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

                  {formData.anzahl_seminare > 0 && (
                    <>
                      <Grid item xs={12}>
                        <Alert severity="info" sx={{ py: 0.5 }}>
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

                {/* Anmerkungen */}
                <Divider sx={{ my: 3 }} />
                <TextField
                  fullWidth
                  multiline
                  rows={3}
                  label="Anmerkungen (optional)"
                  value={formData.anmerkungen}
                  onChange={(e) => setFormData({ ...formData, anmerkungen: e.target.value })}
                  placeholder="Zusätzliche Hinweise zum Modul..."
                />
              </>
            )}
          </>
        )}
      </DialogContent>

      <DialogActions>
        <Button onClick={onClose}>
          Abbrechen
        </Button>
        <Button
          variant="contained"
          startIcon={<Save />}
          onClick={handleSave}
          disabled={saving || !formData.modul ||
            (formData.anzahl_vorlesungen + formData.anzahl_uebungen +
             formData.anzahl_praktika + formData.anzahl_seminare) === 0}
        >
          {saving ? 'Speichert...' : 'Speichern'}
        </Button>
      </DialogActions>
    </Dialog>
  );
};

export default TemplateModulDialog;
