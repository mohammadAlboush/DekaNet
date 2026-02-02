/**
 * ComprehensiveEditDialog - Optimierte Modul-Bearbeitungsansicht
 * ==============================================================
 * Schnelle, einfache Bearbeitung aller Modul-Daten.
 */

import React, { useState, useEffect, useMemo } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Grid,
  Tabs,
  Tab,
  Box,
  Typography,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Divider,
  IconButton,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  Alert,
  CircularProgress,
  Chip,
  Paper
} from '@mui/material';
import {
  Delete as DeleteIcon,
  Add as AddIcon,
  Save as SaveIcon,
  Close as CloseIcon,
  Edit as EditIcon
} from '@mui/icons-material';
import { ModulDetails, ModulLiteratur, ModulLehrform, ModulDozent } from '../../types/modul.types';
import { getErrorMessage } from '../../utils/errorUtils';

// Option Types
interface LehrformOption {
  id: number;
  bezeichnung: string;
  kuerzel: string;
}

interface DozentOption {
  id: number;
  name_komplett: string;
  name_kurz?: string;
}

// Einfaches TabPanel ohne komplexe Logik
const TabPanel = React.memo(({ children, value, index }: { children: React.ReactNode; value: number; index: number }) => (
  <div hidden={value !== index} style={{ padding: '16px 0' }}>
    {value === index && children}
  </div>
));

interface Props {
  open: boolean;
  modul: ModulDetails | null;
  onClose: () => void;
  onSaveSuccess?: () => Promise<void> | void;
  onSaveBasics: (data: Record<string, unknown>) => Promise<{ success: boolean }>;
  onSavePruefung: (data: Record<string, unknown>) => Promise<{ success: boolean }>;
  onSaveLernergebnisse: (data: Record<string, unknown>) => Promise<{ success: boolean }>;
  onSaveVoraussetzungen: (data: Record<string, unknown>) => Promise<{ success: boolean }>;
  onSaveArbeitsaufwand: (data: Record<string, unknown>) => Promise<{ success: boolean }>;
  onAddLiteratur?: (data: Record<string, unknown>) => Promise<{ success: boolean }>;
  onDeleteLiteratur?: (id: number) => Promise<{ success: boolean }>;
  lehrformOptions?: LehrformOption[];
  dozentOptions?: DozentOption[];
}

export default function ComprehensiveEditDialog({
  open, modul, onClose, onSaveSuccess,
  onSaveBasics, onSavePruefung, onSaveLernergebnisse,
  onSaveVoraussetzungen, onSaveArbeitsaufwand,
  onAddLiteratur, onDeleteLiteratur
}: Props) {
  const [tab, setTab] = useState(0);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Initialisiere Forms nur wenn modul sich ändert
  const initialBasics = useMemo(() => ({
    bezeichnung_de: modul?.bezeichnung_de || '',
    bezeichnung_en: modul?.bezeichnung_en || '',
    untertitel: modul?.untertitel || '',
    leistungspunkte: modul?.leistungspunkte || 5,
    turnus: modul?.turnus || 'WiSe',
    dauer_semester: modul?.dauer_semester || 1,
    sprache: modul?.sprache || 'Deutsch',
    gruppengroesse: modul?.gruppengroesse || '',
    teilnehmerzahl: modul?.teilnehmerzahl || '',
    anmeldemodalitaeten: modul?.anmeldemodalitaeten || ''
  }), [modul]);

  const initialPruefung = useMemo(() => ({
    pruefungsform: modul?.pruefung?.pruefungsform || '',
    pruefungsdauer_minuten: modul?.pruefung?.dauer_minuten || modul?.pruefung?.pruefungsdauer_minuten || '',
    benotung: modul?.pruefung?.benotung || '',
    pruefungsleistungen: modul?.pruefung?.pruefungsleistungen || ''
  }), [modul?.pruefung]);

  const initialLernergebnisse = useMemo(() => ({
    lernziele: modul?.lernergebnisse?.lernziele || '',
    kompetenzen: modul?.lernergebnisse?.kompetenzen || '',
    inhalt: modul?.lernergebnisse?.inhalt || ''
  }), [modul?.lernergebnisse]);

  const initialVoraussetzungen = useMemo(() => ({
    formal: modul?.voraussetzungen?.formal || '',
    empfohlen: modul?.voraussetzungen?.empfohlen || '',
    inhaltlich: modul?.voraussetzungen?.inhaltlich || ''
  }), [modul?.voraussetzungen]);

  // Arbeitsaufwand kann als Array oder Objekt kommen
  const arbeitsaufwandData = Array.isArray(modul?.arbeitsaufwand)
    ? modul.arbeitsaufwand[0]
    : modul?.arbeitsaufwand;

  const initialArbeitsaufwand = useMemo(() => ({
    kontaktzeit_stunden: arbeitsaufwandData?.kontaktzeit_stunden || arbeitsaufwandData?.kontaktzeit || 0,
    selbststudium_stunden: arbeitsaufwandData?.selbststudium_stunden || arbeitsaufwandData?.selbststudium || 0,
    pruefungsvorbereitung_stunden: arbeitsaufwandData?.pruefungsvorbereitung_stunden || arbeitsaufwandData?.pruefungsvorbereitung || 0,
    gesamt_stunden: arbeitsaufwandData?.gesamt_stunden || arbeitsaufwandData?.gesamt || 0
  }), [arbeitsaufwandData]);

  // Form States
  const [basics, setBasics] = useState(initialBasics);
  const [pruefung, setPruefung] = useState(initialPruefung);
  const [lernergebnisse, setLernergebnisse] = useState(initialLernergebnisse);
  const [voraussetzungen, setVoraussetzungen] = useState(initialVoraussetzungen);
  const [arbeitsaufwand, setArbeitsaufwand] = useState(initialArbeitsaufwand);
  const [newLit, setNewLit] = useState({ titel: '', autoren: '', verlag: '', jahr: '' });

  // Reset forms when modul changes
  useEffect(() => {
    if (open && modul) {
      setBasics(initialBasics);
      setPruefung(initialPruefung);
      setLernergebnisse(initialLernergebnisse);
      setVoraussetzungen(initialVoraussetzungen);
      setArbeitsaufwand(initialArbeitsaufwand);
      setTab(0);
      setMessage(null);
    }
  }, [open, modul, initialBasics, initialPruefung, initialLernergebnisse, initialVoraussetzungen, initialArbeitsaufwand]);

  // Speichern-Handler
  const handleSave = async () => {
    if (!modul?.id) return;
    setSaving(true);
    setMessage(null);

    const errors: string[] = [];
    const saved: string[] = [];

    try {
      // 1. Basisdaten
      try {
        await onSaveBasics(basics);
        saved.push('Basisdaten');
      } catch (e: unknown) {
        errors.push('Basisdaten: ' + getErrorMessage(e, 'Fehler'));
      }

      // 2. Prüfung
      try {
        await onSavePruefung({
          pruefungsform: pruefung.pruefungsform || null,
          pruefungsdauer_minuten: pruefung.pruefungsdauer_minuten ? parseInt(String(pruefung.pruefungsdauer_minuten)) : null,
          benotung: pruefung.benotung || null,
          pruefungsleistungen: pruefung.pruefungsleistungen || null
        });
        saved.push('Prüfung');
      } catch (e: unknown) {
        errors.push('Pruefung: ' + getErrorMessage(e, 'Fehler'));
      }

      // 3. Lernergebnisse
      try {
        await onSaveLernergebnisse(lernergebnisse);
        saved.push('Lernergebnisse');
      } catch (e: unknown) {
        errors.push('Lernergebnisse: ' + getErrorMessage(e, 'Fehler'));
      }

      // 4. Voraussetzungen
      try {
        await onSaveVoraussetzungen(voraussetzungen);
        saved.push('Voraussetzungen');
      } catch (e: unknown) {
        errors.push('Voraussetzungen: ' + getErrorMessage(e, 'Fehler'));
      }

      // 5. Arbeitsaufwand
      try {
        await onSaveArbeitsaufwand(arbeitsaufwand);
        saved.push('Arbeitsaufwand');
      } catch (e: unknown) {
        errors.push('Arbeitsaufwand: ' + getErrorMessage(e, 'Fehler'));
      }

      if (errors.length === 0) {
        setMessage({ type: 'success', text: 'Alle Daten gespeichert!' });
        // Call onSaveSuccess to refresh parent data, then close
        setTimeout(async () => {
          if (onSaveSuccess) {
            await onSaveSuccess();
          }
          onClose();
        }, 800);
      } else if (saved.length > 0) {
        setMessage({ type: 'error', text: `Gespeichert: ${saved.join(', ')}. Fehler: ${errors.join('; ')}` });
      } else {
        setMessage({ type: 'error', text: errors.join('; ') });
      }
    } catch (e: unknown) {
      setMessage({ type: 'error', text: getErrorMessage(e, 'Unbekannter Fehler') });
    } finally {
      setSaving(false);
    }
  };

  const handleAddLit = async () => {
    if (!newLit.titel || !onAddLiteratur) return;
    try {
      await onAddLiteratur(newLit);
      setNewLit({ titel: '', autoren: '', verlag: '', jahr: '' });
      setMessage({ type: 'success', text: 'Literatur hinzugefügt' });
    } catch (e: unknown) {
      setMessage({ type: 'error', text: getErrorMessage(e) });
    }
  };

  if (!modul) return null;

  const m = modul || {};

  return (
    <Dialog open={open} onClose={onClose} maxWidth="md" fullWidth>
      <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', pb: 1 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <EditIcon color="primary" />
          <Typography variant="h6">{m.kuerzel} bearbeiten</Typography>
        </Box>
        <IconButton onClick={onClose} size="small"><CloseIcon /></IconButton>
      </DialogTitle>

      {message && (
        <Alert severity={message.type} sx={{ mx: 2 }} onClose={() => setMessage(null)}>
          {message.text}
        </Alert>
      )}

      <DialogContent dividers sx={{ p: 2 }}>
        <Tabs value={tab} onChange={(_, v) => setTab(v)} sx={{ borderBottom: 1, borderColor: 'divider', mb: 2 }}>
          <Tab label="Basis" />
          <Tab label="Prüfung" />
          <Tab label="Lernziele" />
          <Tab label="Literatur" />
          <Tab label="Info" />
        </Tabs>

        {/* TAB 0: Basisdaten */}
        <TabPanel value={tab} index={0}>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <TextField fullWidth label="Bezeichnung (DE)" value={basics.bezeichnung_de}
                onChange={(e) => setBasics({ ...basics, bezeichnung_de: e.target.value })} />
            </Grid>
            <Grid item xs={12} md={6}>
              <TextField fullWidth label="Bezeichnung (EN)" value={basics.bezeichnung_en}
                onChange={(e) => setBasics({ ...basics, bezeichnung_en: e.target.value })} />
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth label="Untertitel" value={basics.untertitel}
                onChange={(e) => setBasics({ ...basics, untertitel: e.target.value })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <TextField fullWidth label="LP" type="number" value={basics.leistungspunkte}
                onChange={(e) => setBasics({ ...basics, leistungspunkte: parseInt(e.target.value) || 0 })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <FormControl fullWidth>
                <InputLabel>Turnus</InputLabel>
                <Select value={basics.turnus} label="Turnus"
                  onChange={(e) => setBasics({ ...basics, turnus: e.target.value })}>
                  <MenuItem value="WiSe">Wintersemester</MenuItem>
                  <MenuItem value="SoSe">Sommersemester</MenuItem>
                  <MenuItem value="WiSe/SoSe">Jedes Semester</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={6} md={3}>
              <TextField fullWidth label="Semester" type="number" value={basics.dauer_semester}
                onChange={(e) => setBasics({ ...basics, dauer_semester: parseInt(e.target.value) || 1 })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <FormControl fullWidth>
                <InputLabel>Sprache</InputLabel>
                <Select value={basics.sprache} label="Sprache"
                  onChange={(e) => setBasics({ ...basics, sprache: e.target.value })}>
                  <MenuItem value="Deutsch">Deutsch</MenuItem>
                  <MenuItem value="Englisch">Englisch</MenuItem>
                  <MenuItem value="Deutsch/Englisch">DE/EN</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={6}>
              <TextField fullWidth label="Gruppengröße" value={basics.gruppengroesse}
                onChange={(e) => setBasics({ ...basics, gruppengroesse: e.target.value })} />
            </Grid>
            <Grid item xs={6}>
              <TextField fullWidth label="Teilnehmerzahl" value={basics.teilnehmerzahl}
                onChange={(e) => setBasics({ ...basics, teilnehmerzahl: e.target.value })} />
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth multiline rows={2} label="Anmeldemodalitäten" value={basics.anmeldemodalitaeten}
                onChange={(e) => setBasics({ ...basics, anmeldemodalitaeten: e.target.value })} />
            </Grid>
          </Grid>
        </TabPanel>

        {/* TAB 1: Prüfung */}
        <TabPanel value={tab} index={1}>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <TextField fullWidth label="Prüfungsform" value={pruefung.pruefungsform}
                placeholder="z.B. Klausur, Hausarbeit"
                onChange={(e) => setPruefung({ ...pruefung, pruefungsform: e.target.value })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <TextField fullWidth label="Dauer (Min)" type="number" value={pruefung.pruefungsdauer_minuten}
                onChange={(e) => setPruefung({ ...pruefung, pruefungsdauer_minuten: e.target.value })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <FormControl fullWidth>
                <InputLabel>Benotung</InputLabel>
                <Select value={pruefung.benotung} label="Benotung"
                  onChange={(e) => setPruefung({ ...pruefung, benotung: e.target.value })}>
                  <MenuItem value="">-</MenuItem>
                  <MenuItem value="benotet">benotet</MenuItem>
                  <MenuItem value="unbenotet">unbenotet</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth multiline rows={3} label="Prüfungsleistungen"
                value={pruefung.pruefungsleistungen}
                onChange={(e) => setPruefung({ ...pruefung, pruefungsleistungen: e.target.value })} />
            </Grid>
          </Grid>
        </TabPanel>

        {/* TAB 2: Lernergebnisse */}
        <TabPanel value={tab} index={2}>
          <Grid container spacing={2}>
            <Grid item xs={12}>
              <TextField fullWidth multiline rows={3} label="Lernziele" value={lernergebnisse.lernziele}
                onChange={(e) => setLernergebnisse({ ...lernergebnisse, lernziele: e.target.value })} />
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth multiline rows={3} label="Kompetenzen" value={lernergebnisse.kompetenzen}
                onChange={(e) => setLernergebnisse({ ...lernergebnisse, kompetenzen: e.target.value })} />
            </Grid>
            <Grid item xs={12}>
              <TextField fullWidth multiline rows={3} label="Inhalt" value={lernergebnisse.inhalt}
                onChange={(e) => setLernergebnisse({ ...lernergebnisse, inhalt: e.target.value })} />
            </Grid>

            <Grid item xs={12}><Divider sx={{ my: 1 }}><Chip label="Voraussetzungen" size="small" /></Divider></Grid>

            <Grid item xs={12} md={4}>
              <TextField fullWidth multiline rows={2} label="Formal" value={voraussetzungen.formal}
                onChange={(e) => setVoraussetzungen({ ...voraussetzungen, formal: e.target.value })} />
            </Grid>
            <Grid item xs={12} md={4}>
              <TextField fullWidth multiline rows={2} label="Empfohlen" value={voraussetzungen.empfohlen}
                onChange={(e) => setVoraussetzungen({ ...voraussetzungen, empfohlen: e.target.value })} />
            </Grid>
            <Grid item xs={12} md={4}>
              <TextField fullWidth multiline rows={2} label="Inhaltlich" value={voraussetzungen.inhaltlich}
                onChange={(e) => setVoraussetzungen({ ...voraussetzungen, inhaltlich: e.target.value })} />
            </Grid>
          </Grid>
        </TabPanel>

        {/* TAB 3: Literatur */}
        <TabPanel value={tab} index={3}>
          <Typography variant="subtitle2" gutterBottom>Literaturliste</Typography>
          {modul.literatur?.length > 0 ? (
            <List dense sx={{ bgcolor: 'grey.50', borderRadius: 1, mb: 2 }}>
              {modul.literatur.map((lit: ModulLiteratur, i: number) => (
                <ListItem key={i}>
                  <ListItemText
                    primary={lit.titel}
                    secondary={[lit.autoren, lit.verlag, lit.jahr].filter(Boolean).join(' - ')}
                  />
                  {onDeleteLiteratur && (
                    <ListItemSecondaryAction>
                      <IconButton size="small" onClick={() => onDeleteLiteratur(lit.id)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </ListItemSecondaryAction>
                  )}
                </ListItem>
              ))}
            </List>
          ) : (
            <Typography color="text.secondary" sx={{ mb: 2 }}>Keine Literatur vorhanden</Typography>
          )}

          <Paper variant="outlined" sx={{ p: 2 }}>
            <Typography variant="subtitle2" gutterBottom>Neue Literatur</Typography>
            <Grid container spacing={1}>
              <Grid item xs={12}>
                <TextField size="small" fullWidth label="Titel" value={newLit.titel}
                  onChange={(e) => setNewLit({ ...newLit, titel: e.target.value })} />
              </Grid>
              <Grid item xs={4}>
                <TextField size="small" fullWidth label="Autor(en)" value={newLit.autoren}
                  onChange={(e) => setNewLit({ ...newLit, autoren: e.target.value })} />
              </Grid>
              <Grid item xs={4}>
                <TextField size="small" fullWidth label="Verlag" value={newLit.verlag}
                  onChange={(e) => setNewLit({ ...newLit, verlag: e.target.value })} />
              </Grid>
              <Grid item xs={2}>
                <TextField size="small" fullWidth label="Jahr" value={newLit.jahr}
                  onChange={(e) => setNewLit({ ...newLit, jahr: e.target.value })} />
              </Grid>
              <Grid item xs={2}>
                <Button fullWidth variant="outlined" startIcon={<AddIcon />}
                  onClick={handleAddLit} disabled={!newLit.titel}>
                  Hinzufügen
                </Button>
              </Grid>
            </Grid>
          </Paper>
        </TabPanel>

        {/* TAB 4: Info/Arbeitsaufwand */}
        <TabPanel value={tab} index={4}>
          <Typography variant="subtitle2" gutterBottom>Arbeitsaufwand (Stunden)</Typography>
          <Grid container spacing={2}>
            <Grid item xs={6} md={3}>
              <TextField fullWidth label="Kontaktzeit" type="number"
                value={arbeitsaufwand.kontaktzeit_stunden}
                onChange={(e) => setArbeitsaufwand({ ...arbeitsaufwand, kontaktzeit_stunden: parseInt(e.target.value) || 0 })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <TextField fullWidth label="Selbststudium" type="number"
                value={arbeitsaufwand.selbststudium_stunden}
                onChange={(e) => setArbeitsaufwand({ ...arbeitsaufwand, selbststudium_stunden: parseInt(e.target.value) || 0 })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <TextField fullWidth label="Prüfungsvorbereitung" type="number"
                value={arbeitsaufwand.pruefungsvorbereitung_stunden}
                onChange={(e) => setArbeitsaufwand({ ...arbeitsaufwand, pruefungsvorbereitung_stunden: parseInt(e.target.value) || 0 })} />
            </Grid>
            <Grid item xs={6} md={3}>
              <TextField fullWidth label="Gesamt" type="number"
                value={arbeitsaufwand.gesamt_stunden}
                onChange={(e) => setArbeitsaufwand({ ...arbeitsaufwand, gesamt_stunden: parseInt(e.target.value) || 0 })} />
            </Grid>
          </Grid>

          <Divider sx={{ my: 3 }} />

          <Typography variant="subtitle2" gutterBottom>Modul-Info</Typography>
          <Grid container spacing={1}>
            <Grid item xs={6} md={3}><Chip label={`ID: ${m.id}`} size="small" /></Grid>
            <Grid item xs={6} md={3}><Chip label={`Kürzel: ${m.kuerzel}`} size="small" /></Grid>
            <Grid item xs={6} md={3}><Chip label={`PO: ${m.po_id}`} size="small" /></Grid>
            <Grid item xs={6} md={3}><Chip label={`LP: ${m.leistungspunkte}`} size="small" /></Grid>
          </Grid>

          {modul.lehrformen?.length > 0 && (
            <Box sx={{ mt: 2 }}>
              <Typography variant="subtitle2" gutterBottom>Lehrformen</Typography>
              {modul.lehrformen.map((lf: ModulLehrform, i: number) => (
                <Chip key={i} label={`${lf.bezeichnung || lf.lehrform?.bezeichnung}: ${lf.sws} SWS`}
                  size="small" sx={{ mr: 1, mb: 1 }} />
              ))}
            </Box>
          )}

          {(modul.dozenten?.verantwortliche?.length > 0 || modul.dozenten?.lehrpersonen?.length > 0) && (
            <Box sx={{ mt: 2 }}>
              <Typography variant="subtitle2" gutterBottom>Dozenten</Typography>
              {modul.dozenten?.verantwortliche?.map((d: ModulDozent, i: number) => (
                <Chip key={`v${i}`} label={`${d.name_komplett || d.name} (V)`} size="small" color="primary" sx={{ mr: 1, mb: 1 }} />
              ))}
              {modul.dozenten?.lehrpersonen?.map((d: ModulDozent, i: number) => (
                <Chip key={`l${i}`} label={d.name_komplett || d.name} size="small" sx={{ mr: 1, mb: 1 }} />
              ))}
            </Box>
          )}
        </TabPanel>
      </DialogContent>

      <DialogActions sx={{ px: 2, py: 1.5 }}>
        <Button onClick={onClose}>Abbrechen</Button>
        <Button variant="contained" onClick={handleSave} disabled={saving}
          startIcon={saving ? <CircularProgress size={18} /> : <SaveIcon />}>
          {saving ? 'Speichert...' : 'Speichern'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
