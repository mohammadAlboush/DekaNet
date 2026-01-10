import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Grid,
  Button,
  Alert,
  Chip,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Card,
  CardContent,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from '@mui/material';
import {
  CalendarToday,
  Info,
  Delete,
  Edit,
  Add,
  WbSunny,
  Cloud,
  EventBusy,
  CheckCircle,
} from '@mui/icons-material';

/**
 * WunschTag Interface
 * Struktur für einen Wunsch-freien Tag
 */
export interface WunschTag {
  id: string;
  wochentag: string;
  zeitraum: 'ganztags' | 'vormittag' | 'nachmittag';
  prioritaet: 'hoch' | 'mittel' | 'niedrig';
  grund?: string;
}

/**
 * Props für den WunschTagEditor
 */
interface WunschTagEditorProps {
  /** Liste der Wunsch-freien Tage */
  wunschFreieTage: WunschTag[];
  /** Callback bei Änderungen */
  onChange: (tags: WunschTag[]) => void;
  /** Read-Only Modus (nur Anzeige) */
  readOnly?: boolean;
  /** Kompakte Darstellung ohne Stats */
  compact?: boolean;
  /** Hinweis-Text ausblenden */
  hideHints?: boolean;
}

const WOCHENTAGE = [
  { value: 'montag', label: 'Montag', short: 'Mo' },
  { value: 'dienstag', label: 'Dienstag', short: 'Di' },
  { value: 'mittwoch', label: 'Mittwoch', short: 'Mi' },
  { value: 'donnerstag', label: 'Donnerstag', short: 'Do' },
  { value: 'freitag', label: 'Freitag', short: 'Fr' },
];

const ZEITRAEUME = [
  { value: 'ganztags', label: 'Ganztags', icon: <CalendarToday /> },
  { value: 'vormittag', label: 'Vormittag', icon: <WbSunny /> },
  { value: 'nachmittag', label: 'Nachmittag', icon: <Cloud /> },
];

const PRIORITAETEN = [
  { value: 'hoch', label: 'Hoch', color: 'error' as const },
  { value: 'mittel', label: 'Mittel', color: 'warning' as const },
  { value: 'niedrig', label: 'Niedrig', color: 'info' as const },
];

/**
 * WunschTagEditor - Wiederverwendbare Komponente
 *
 * Ermöglicht das Hinzufügen, Bearbeiten und Löschen von Wunsch-freien Tagen.
 * Kann sowohl im Wizard als auch in der Template-Verwaltung verwendet werden.
 */
const WunschTagEditor: React.FC<WunschTagEditorProps> = ({
  wunschFreieTage,
  onChange,
  readOnly = false,
  compact = false,
  hideHints = false,
}) => {
  const [openDialog, setOpenDialog] = useState(false);
  const [editingWunsch, setEditingWunsch] = useState<WunschTag | null>(null);
  const [newWunsch, setNewWunsch] = useState<WunschTag>({
    id: '',
    wochentag: 'montag',
    zeitraum: 'ganztags',
    prioritaet: 'mittel',
    grund: '',
  });

  const handleQuickAdd = (wochentag: string) => {
    if (readOnly) return;
    if (!wunschFreieTage.find(w => w.wochentag === wochentag && w.zeitraum === 'ganztags')) {
      const wunsch: WunschTag = {
        id: Date.now().toString(),
        wochentag,
        zeitraum: 'ganztags',
        prioritaet: 'mittel',
        grund: '',
      };
      onChange([...wunschFreieTage, wunsch]);
    }
  };

  const handleQuickRemove = (wochentag: string) => {
    if (readOnly) return;
    const updated = wunschFreieTage.filter(w =>
      !(w.wochentag === wochentag && w.zeitraum === 'ganztags')
    );
    onChange(updated);
  };

  const getTagInfo = (wochentag: string) => {
    const tags = wunschFreieTage.filter(w => w.wochentag === wochentag);
    if (tags.length === 0) return null;

    const hasGanztags = tags.some(t => t.zeitraum === 'ganztags');
    const hasVormittag = tags.some(t => t.zeitraum === 'vormittag');
    const hasNachmittag = tags.some(t => t.zeitraum === 'nachmittag');

    return { hasGanztags, hasVormittag, hasNachmittag, count: tags.length };
  };

  const handleOpenDialog = (wunsch?: WunschTag) => {
    if (readOnly) return;
    if (wunsch) {
      setEditingWunsch(wunsch);
      setNewWunsch(wunsch);
    } else {
      setEditingWunsch(null);
      setNewWunsch({
        id: '',
        wochentag: 'montag',
        zeitraum: 'ganztags',
        prioritaet: 'mittel',
        grund: '',
      });
    }
    setOpenDialog(true);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    setEditingWunsch(null);
  };

  const handleSaveWunsch = () => {
    let updated: WunschTag[];

    if (editingWunsch) {
      updated = wunschFreieTage.map(w =>
        w.id === editingWunsch.id ? newWunsch : w
      );
    } else {
      const exists = wunschFreieTage.some(w =>
        w.wochentag === newWunsch.wochentag &&
        w.zeitraum === newWunsch.zeitraum
      );

      if (exists) {
        alert('Diese Kombination existiert bereits!');
        return;
      }

      updated = [...wunschFreieTage, { ...newWunsch, id: Date.now().toString() }];
    }

    onChange(updated);
    handleCloseDialog();
  };

  const handleDeleteWunsch = (id: string) => {
    if (readOnly) return;
    const updated = wunschFreieTage.filter(w => w.id !== id);
    onChange(updated);
  };

  const getTotalFreeTage = () => {
    const ganztags = wunschFreieTage.filter(w => w.zeitraum === 'ganztags').length;
    const halbtags = wunschFreieTage.filter(w => w.zeitraum !== 'ganztags').length;
    return ganztags + (halbtags * 0.5);
  };

  const getPriorityColor = (prioritaet: string) => {
    const priority = PRIORITAETEN.find(p => p.value === prioritaet);
    return priority?.color || 'default';
  };

  return (
    <Box>
      {/* Info Alert */}
      {!hideHints && !compact && (
        <Alert severity="info" sx={{ mb: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            <Info sx={{ mr: 1, verticalAlign: 'middle' }} />
            Hinweise zur Auswahl
          </Typography>
          <Typography variant="body2">
            • Wunsch-freie Tage können nicht garantiert werden
            <br />
            • Je nach Priorität werden Ihre Wünsche bei der Planung berücksichtigt
            <br />
            • Maximal 2 komplette Tage oder 4 Halbtage empfohlen
          </Typography>
        </Alert>
      )}

      {/* Statistics */}
      {!compact && (
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={12} md={4}>
            <Card variant="outlined">
              <CardContent>
                <Typography variant="subtitle2" color="text.secondary">
                  Freie Tage (Äquivalent)
                </Typography>
                <Typography variant="h4">
                  {getTotalFreeTage()}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  Tage gesamt
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card variant="outlined">
              <CardContent>
                <Typography variant="subtitle2" color="text.secondary">
                  Hohe Priorität
                </Typography>
                <Typography variant="h4" color="error">
                  {wunschFreieTage.filter(w => w.prioritaet === 'hoch').length}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  Einträge
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} md={4}>
            <Card variant="outlined">
              <CardContent>
                <Typography variant="subtitle2" color="text.secondary">
                  Status
                </Typography>
                {getTotalFreeTage() <= 2 ? (
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                    <CheckCircle color="success" />
                    <Typography color="success.main">
                      Optimal
                    </Typography>
                  </Box>
                ) : (
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                    <Info color="warning" />
                    <Typography color="warning.main">
                      Viele Wünsche
                    </Typography>
                  </Box>
                )}
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      )}

      {/* Quick Selection */}
      {!readOnly && (
        <Paper sx={{ p: 3, mb: 3 }} variant="outlined">
          <Typography variant="subtitle1" fontWeight={500} gutterBottom>
            Schnellauswahl - Ganztägig frei
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            Klicken Sie auf die Tage, an denen Sie ganztägig frei haben möchten
          </Typography>
          <Grid container spacing={1}>
            {WOCHENTAGE.map((tag) => {
              const info = getTagInfo(tag.value);
              const isSelected = info?.hasGanztags || false;

              return (
                <Grid item key={tag.value}>
                  <Button
                    variant={isSelected ? 'contained' : 'outlined'}
                    onClick={() =>
                      isSelected
                        ? handleQuickRemove(tag.value)
                        : handleQuickAdd(tag.value)
                    }
                    startIcon={isSelected ? <EventBusy /> : <CalendarToday />}
                    sx={{
                      minWidth: 120,
                      position: 'relative',
                    }}
                  >
                    {tag.label}
                    {info && !info.hasGanztags && (
                      <Chip
                        label={`${info.count}`}
                        size="small"
                        sx={{
                          position: 'absolute',
                          top: -8,
                          right: -8,
                          height: 20,
                          minWidth: 20,
                        }}
                      />
                    )}
                  </Button>
                </Grid>
              );
            })}
          </Grid>
        </Paper>
      )}

      {/* Detailed List */}
      <Paper sx={{ p: 3 }} variant="outlined">
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Typography variant="subtitle1" fontWeight={500}>
            {readOnly ? 'Wunsch-freie Tage' : 'Detaillierte Wunschliste'}
          </Typography>
          {!readOnly && (
            <Button
              size="small"
              startIcon={<Add />}
              onClick={() => handleOpenDialog()}
            >
              Wunsch hinzufügen
            </Button>
          )}
        </Box>

        {wunschFreieTage.length > 0 ? (
          <List>
            {wunschFreieTage.map((wunsch, index) => (
              <ListItem key={wunsch.id} divider={index < wunschFreieTage.length - 1}>
                <ListItemText
                  primary={
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <Typography variant="subtitle2">
                        {WOCHENTAGE.find(t => t.value === wunsch.wochentag)?.label}
                      </Typography>
                      <Chip
                        label={ZEITRAEUME.find(z => z.value === wunsch.zeitraum)?.label}
                        size="small"
                        variant="outlined"
                      />
                      <Chip
                        label={wunsch.prioritaet}
                        size="small"
                        color={getPriorityColor(wunsch.prioritaet)}
                      />
                    </Box>
                  }
                  secondary={wunsch.grund || 'Kein Grund angegeben'}
                />
                {!readOnly && (
                  <ListItemSecondaryAction>
                    <IconButton
                      edge="end"
                      size="small"
                      onClick={() => handleOpenDialog(wunsch)}
                      sx={{ mr: 1 }}
                    >
                      <Edit />
                    </IconButton>
                    <IconButton
                      edge="end"
                      size="small"
                      onClick={() => handleDeleteWunsch(wunsch.id)}
                    >
                      <Delete />
                    </IconButton>
                  </ListItemSecondaryAction>
                )}
              </ListItem>
            ))}
          </List>
        ) : (
          <Alert severity="info">
            {readOnly
              ? 'Keine Wunsch-freien Tage definiert.'
              : 'Keine Wunsch-freien Tage angegeben. Sie sind flexibel in der Stundenplanung.'
            }
          </Alert>
        )}
      </Paper>

      {/* Warning if too many free days */}
      {!hideHints && getTotalFreeTage() > 2 && (
        <Alert severity="warning" sx={{ mt: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            Viele Wunsch-freie Tage
          </Typography>
          <Typography variant="body2">
            Sie haben mehr als 2 Tage als Wunsch angegeben. Je mehr freie Tage Sie wünschen,
            desto schwieriger wird die Stundenplanung. Überlegen Sie, ob alle Wünsche
            wirklich notwendig sind.
          </Typography>
        </Alert>
      )}

      {/* Dialog for Adding/Editing */}
      <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editingWunsch ? 'Wunsch bearbeiten' : 'Neuen Wunsch hinzufügen'}
        </DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12} md={6}>
              <FormControl fullWidth>
                <InputLabel>Wochentag</InputLabel>
                <Select
                  value={newWunsch.wochentag}
                  onChange={(e) => setNewWunsch({ ...newWunsch, wochentag: e.target.value })}
                  label="Wochentag"
                >
                  {WOCHENTAGE.map(tag => (
                    <MenuItem key={tag.value} value={tag.value}>
                      {tag.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} md={6}>
              <FormControl fullWidth>
                <InputLabel>Zeitraum</InputLabel>
                <Select
                  value={newWunsch.zeitraum}
                  onChange={(e) => setNewWunsch({ ...newWunsch, zeitraum: e.target.value as WunschTag['zeitraum'] })}
                  label="Zeitraum"
                >
                  {ZEITRAEUME.map(zeit => (
                    <MenuItem key={zeit.value} value={zeit.value}>
                      {zeit.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12}>
              <FormControl fullWidth>
                <InputLabel>Priorität</InputLabel>
                <Select
                  value={newWunsch.prioritaet}
                  onChange={(e) => setNewWunsch({ ...newWunsch, prioritaet: e.target.value as WunschTag['prioritaet'] })}
                  label="Priorität"
                >
                  {PRIORITAETEN.map(prio => (
                    <MenuItem key={prio.value} value={prio.value}>
                      {prio.label}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={2}
                label="Begründung (optional)"
                value={newWunsch.grund}
                onChange={(e) => setNewWunsch({ ...newWunsch, grund: e.target.value })}
                placeholder="z.B. Kinderbetreuung, andere Verpflichtungen, etc."
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Abbrechen</Button>
          <Button variant="contained" onClick={handleSaveWunsch}>
            {editingWunsch ? 'Speichern' : 'Hinzufügen'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default WunschTagEditor;

// Re-export types for convenience
export { WOCHENTAGE, ZEITRAEUME, PRIORITAETEN };
