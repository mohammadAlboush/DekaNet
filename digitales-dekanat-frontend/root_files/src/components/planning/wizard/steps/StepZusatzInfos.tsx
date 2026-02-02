import React, { useState } from 'react';
import {
  Box,
  Typography,
  TextField,
  Paper,
  Grid,
  Button,
  Alert,
  AlertTitle,
  Chip,
  FormControlLabel,
  Switch,
  IconButton,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Divider,
} from '@mui/material';
import {
  NavigateNext,
  NavigateBefore,
  Add,
  Delete,
  Edit,
  Room,
  Description,
  Computer,
  Science,
  Group,
  Info,
} from '@mui/icons-material';
import { DEFAULT_CAPACITIES } from '../../../../constants/planning.constants';

interface ModulLehrform {
  kuerzel: string;
  bezeichnung?: string;
  sws?: number;
}

interface WizardStepData {
  anmerkungen?: string;
  raumbedarf?: string;
  roomRequirements?: RoomRequirement[];
  specialRequests?: SpecialRequests;
  raum_vorlesung?: string;
  raum_uebung?: string;
  raum_praktikum?: string;
  raum_seminar?: string;
  modul?: {
    lehrformen?: ModulLehrform[];
    [key: string]: unknown;
  };
  [key: string]: unknown;
}

interface SpecialRequests {
  needsComputerRoom: boolean;
  needsLab: boolean;
  needsBeamer: boolean;
  needsWhiteboard: boolean;
  flexibleScheduling: boolean;
  blockCourse: boolean;
}

interface StepProps {
  data: WizardStepData;
  onUpdate: (data: Partial<WizardStepData>) => void;
  onNext: () => void;
  onBack: () => void;
}

interface RoomRequirement {
  id: string;
  type: string;
  capacity: number;
  equipment: string[];
  notes: string;
}

const StepZusatzInfos: React.FC<StepProps> = ({
  data,
  onUpdate,
  onNext,
  onBack
}) => {
  const [anmerkungen, setAnmerkungen] = useState(data.anmerkungen || '');
  const [raumbedarf, setRaumbedarf] = useState(data.raumbedarf || '');

  // Feature 4 - Raumplanung pro Lehrform
  const [raumVorlesung, setRaumVorlesung] = useState(data.raum_vorlesung || '');
  const [raumUebung, setRaumUebung] = useState(data.raum_uebung || '');
  const [raumPraktikum, setRaumPraktikum] = useState(data.raum_praktikum || '');
  const [raumSeminar, setRaumSeminar] = useState(data.raum_seminar || '');

  // Check which Lehrformen the selected module has
  const hatVorlesung = data.modul?.lehrformen?.some((lf: ModulLehrform) => lf.kuerzel === 'V') || false;
  const hatUebung = data.modul?.lehrformen?.some((lf: ModulLehrform) => lf.kuerzel === 'Ü') || false;
  const hatPraktikum = data.modul?.lehrformen?.some((lf: ModulLehrform) => lf.kuerzel === 'P') || false;
  const hatSeminar = data.modul?.lehrformen?.some((lf: ModulLehrform) => lf.kuerzel === 'S') || false;
  const [roomRequirements, setRoomRequirements] = useState<RoomRequirement[]>(
    data.roomRequirements || []
  );
  const [specialRequests, setSpecialRequests] = useState({
    needsComputerRoom: data.specialRequests?.needsComputerRoom || false,
    needsLab: data.specialRequests?.needsLab || false,
    needsBeamer: data.specialRequests?.needsBeamer || true,
    needsWhiteboard: data.specialRequests?.needsWhiteboard || true,
    flexibleScheduling: data.specialRequests?.flexibleScheduling || false,
    blockCourse: data.specialRequests?.blockCourse || false,
  });
  const [openRoomDialog, setOpenRoomDialog] = useState(false);
  const [editingRoom, setEditingRoom] = useState<RoomRequirement | null>(null);
  const [newRoom, setNewRoom] = useState<RoomRequirement>({
    id: '',
    type: 'Seminarraum',
    capacity: DEFAULT_CAPACITIES.vorlesung,
    equipment: [],
    notes: '',
  });

  const roomTypes = [
    { value: 'Hörsaal', label: 'Hörsaal', icon: <Group /> },
    { value: 'Seminarraum', label: 'Seminarraum', icon: <Room /> },
    { value: 'Computerraum', label: 'Computerraum', icon: <Computer /> },
    { value: 'Labor', label: 'Labor', icon: <Science /> },
  ];

  const equipmentOptions = [
    'Beamer',
    'Whiteboard',
    'Tafel',
    'Flipchart',
    'Videokonferenz',
    'Smartboard',
    'Mikrofonanlage',
    'Computer-Arbeitsplätze',
  ];

  const handleSaveAnmerkungen = () => {
    onUpdate({
      anmerkungen,
      raumbedarf,
      roomRequirements,
      specialRequests,
      // Feature 4 - Raumfelder
      raum_vorlesung: raumVorlesung,
      raum_uebung: raumUebung,
      raum_praktikum: raumPraktikum,
      raum_seminar: raumSeminar
    });
  };

  const handleSpecialRequestChange = (key: string, value: boolean) => {
    const updated = { ...specialRequests, [key]: value };
    setSpecialRequests(updated);
    handleSaveAnmerkungen();
  };

  const handleOpenRoomDialog = (room?: RoomRequirement) => {
    if (room) {
      setEditingRoom(room);
      setNewRoom(room);
    } else {
      setEditingRoom(null);
      setNewRoom({
        id: Date.now().toString(),
        type: 'Seminarraum',
        capacity: DEFAULT_CAPACITIES.vorlesung,
        equipment: [],
        notes: '',
      });
    }
    setOpenRoomDialog(true);
  };

  const handleCloseRoomDialog = () => {
    setOpenRoomDialog(false);
    setEditingRoom(null);
    setNewRoom({
      id: '',
      type: 'Seminarraum',
      capacity: DEFAULT_CAPACITIES.vorlesung,
      equipment: [],
      notes: '',
    });
  };

  const handleSaveRoom = () => {
    let updated: RoomRequirement[];
    
    if (editingRoom) {
      updated = roomRequirements.map(r => 
        r.id === editingRoom.id ? newRoom : r
      );
    } else {
      updated = [...roomRequirements, { ...newRoom, id: Date.now().toString() }];
    }
    
    setRoomRequirements(updated);
    onUpdate({ 
      anmerkungen, 
      raumbedarf,
      roomRequirements: updated,
      specialRequests
    });
    handleCloseRoomDialog();
  };

  const handleDeleteRoom = (roomId: string) => {
    const updated = roomRequirements.filter(r => r.id !== roomId);
    setRoomRequirements(updated);
    onUpdate({ 
      anmerkungen, 
      raumbedarf,
      roomRequirements: updated,
      specialRequests
    });
  };

  const handleToggleEquipment = (equipment: string) => {
    const updated = newRoom.equipment.includes(equipment)
      ? newRoom.equipment.filter(e => e !== equipment)
      : [...newRoom.equipment, equipment];
    
    setNewRoom({ ...newRoom, equipment: updated });
  };

  const handleContinue = () => {
    // Feature 4 - Validate Vorlesung room if required
    if (hatVorlesung && !raumVorlesung) {
      // Validation will be shown by the error prop on the TextField
      return;
    }

    handleSaveAnmerkungen();
    onNext();
  };

  return (
    <Box>
      <Typography variant="h6" gutterBottom>
        Zusätzliche Informationen und Anforderungen
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Geben Sie spezielle Anforderungen und Hinweise für Ihre Semesterplanung an.
      </Typography>

      {/* Special Requests */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="subtitle1" fontWeight={500} gutterBottom>
          Spezielle Anforderungen
        </Typography>
        <Grid container spacing={2}>
          <Grid item xs={12} md={6}>
            <FormControlLabel
              control={
                <Switch
                  checked={specialRequests.needsComputerRoom}
                  onChange={(e) => handleSpecialRequestChange('needsComputerRoom', e.target.checked)}
                />
              }
              label="Computerraum benötigt"
            />
          </Grid>
          <Grid item xs={12} md={6}>
            <FormControlLabel
              control={
                <Switch
                  checked={specialRequests.needsLab}
                  onChange={(e) => handleSpecialRequestChange('needsLab', e.target.checked)}
                />
              }
              label="Labor benötigt"
            />
          </Grid>
          <Grid item xs={12} md={6}>
            <FormControlLabel
              control={
                <Switch
                  checked={specialRequests.needsBeamer}
                  onChange={(e) => handleSpecialRequestChange('needsBeamer', e.target.checked)}
                />
              }
              label="Beamer in allen Räumen"
            />
          </Grid>
          <Grid item xs={12} md={6}>
            <FormControlLabel
              control={
                <Switch
                  checked={specialRequests.needsWhiteboard}
                  onChange={(e) => handleSpecialRequestChange('needsWhiteboard', e.target.checked)}
                />
              }
              label="Whiteboard/Tafel benötigt"
            />
          </Grid>
          <Grid item xs={12} md={6}>
            <FormControlLabel
              control={
                <Switch
                  checked={specialRequests.flexibleScheduling}
                  onChange={(e) => handleSpecialRequestChange('flexibleScheduling', e.target.checked)}
                />
              }
              label="Flexible Terminplanung möglich"
            />
          </Grid>
          <Grid item xs={12} md={6}>
            <FormControlLabel
              control={
                <Switch
                  checked={specialRequests.blockCourse}
                  onChange={(e) => handleSpecialRequestChange('blockCourse', e.target.checked)}
                />
              }
              label="Blockveranstaltung geplant"
            />
          </Grid>
        </Grid>
      </Paper>

      {/* Room Requirements */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Typography variant="subtitle1" fontWeight={500}>
            Raumanforderungen
          </Typography>
          <Button
            size="small"
            startIcon={<Add />}
            onClick={() => handleOpenRoomDialog()}
          >
            Raum hinzufügen
          </Button>
        </Box>

        {roomRequirements.length > 0 ? (
          <List>
            {roomRequirements.map((room, index) => (
              <React.Fragment key={room.id}>
                {index > 0 && <Divider />}
                <ListItem>
                  <ListItemText
                    primary={
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        {roomTypes.find(t => t.value === room.type)?.icon}
                        <Typography variant="subtitle2">
                          {room.type} (Kapazität: {room.capacity} Personen)
                        </Typography>
                      </Box>
                    }
                    secondary={
                      <Box sx={{ mt: 0.5 }}>
                        {room.equipment.length > 0 && (
                          <Box sx={{ display: 'flex', gap: 0.5, flexWrap: 'wrap', mb: 0.5 }}>
                            {room.equipment.map(eq => (
                              <Chip key={eq} label={eq} size="small" variant="outlined" />
                            ))}
                          </Box>
                        )}
                        {room.notes && (
                          <Typography variant="caption" color="text.secondary">
                            {room.notes}
                          </Typography>
                        )}
                      </Box>
                    }
                  />
                  <ListItemSecondaryAction>
                    <IconButton 
                      edge="end" 
                      size="small"
                      onClick={() => handleOpenRoomDialog(room)}
                      sx={{ mr: 1 }}
                    >
                      <Edit />
                    </IconButton>
                    <IconButton 
                      edge="end" 
                      size="small"
                      onClick={() => handleDeleteRoom(room.id)}
                    >
                      <Delete />
                    </IconButton>
                  </ListItemSecondaryAction>
                </ListItem>
              </React.Fragment>
            ))}
          </List>
        ) : (
          <Alert severity="info">
            Keine speziellen Raumanforderungen angegeben. Standardräume werden zugeteilt.
          </Alert>
        )}
      </Paper>

      {/* General Notes */}
      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="subtitle1" fontWeight={500} gutterBottom>
              <Description sx={{ mr: 1, verticalAlign: 'middle' }} />
              Allgemeine Anmerkungen
            </Typography>
            <TextField
              fullWidth
              multiline
              rows={6}
              placeholder="Hier können Sie allgemeine Hinweise und Anmerkungen zur Planung eingeben..."
              value={anmerkungen}
              onChange={(e) => setAnmerkungen(e.target.value)}
              onBlur={handleSaveAnmerkungen}
            />
            <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
              z.B. Präferenzen, Hinweise für die Stundenplanung, etc.
            </Typography>
          </Paper>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="subtitle1" fontWeight={500} gutterBottom>
              <Room sx={{ mr: 1, verticalAlign: 'middle' }} />
              Raumbedarf Details
            </Typography>
            <TextField
              fullWidth
              multiline
              rows={6}
              placeholder="Spezielle Anforderungen an Räume und Ausstattung..."
              value={raumbedarf}
              onChange={(e) => setRaumbedarf(e.target.value)}
              onBlur={handleSaveAnmerkungen}
            />
            <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
              z.B. barrierefreier Zugang, spezielle Laborausstattung, etc.
            </Typography>
          </Paper>
        </Grid>
      </Grid>

      {/* Feature 4 - Raumplanung pro Lehrform */}
      {data.modul && (hatVorlesung || hatUebung || hatPraktikum || hatSeminar) && (
        <Paper sx={{ p: 3, mt: 3 }}>
          <Typography variant="subtitle1" fontWeight={500} gutterBottom>
            <Room sx={{ mr: 1, verticalAlign: 'middle' }} />
            Raumplanung pro Lehrform
          </Typography>
          <Typography variant="caption" color="text.secondary" sx={{ mb: 2, display: 'block' }}>
            Geben Sie für jede Lehrform den gewünschten Raum an
          </Typography>

          <Grid container spacing={2}>
            {/* Vorlesung */}
            {hatVorlesung && (
              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  label="Raum für Vorlesung"
                  required
                  placeholder="z.B. HS 101, A-Gebäude Hörsaal 3"
                  value={raumVorlesung}
                  onChange={(e) => setRaumVorlesung(e.target.value)}
                  onBlur={handleSaveAnmerkungen}
                  helperText="Pflichtfeld - Raum für die Vorlesung"
                  error={!raumVorlesung}
                />
              </Grid>
            )}

            {/* Übung */}
            {hatUebung && (
              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  label="Raum für Übung"
                  placeholder="z.B. SR 201, B-Gebäude Seminarraum 5"
                  value={raumUebung}
                  onChange={(e) => setRaumUebung(e.target.value)}
                  onBlur={handleSaveAnmerkungen}
                  helperText="Optional - Raum für die Übung"
                />
              </Grid>
            )}

            {/* Praktikum */}
            {hatPraktikum && (
              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  label="Raum für Praktikum"
                  placeholder="z.B. Labor 301, C-Gebäude PC-Pool 1"
                  value={raumPraktikum}
                  onChange={(e) => setRaumPraktikum(e.target.value)}
                  onBlur={handleSaveAnmerkungen}
                  helperText="Optional - Raum für das Praktikum"
                />
              </Grid>
            )}

            {/* Seminar */}
            {hatSeminar && (
              <Grid item xs={12} md={6}>
                <TextField
                  fullWidth
                  label="Raum für Seminar"
                  placeholder="z.B. SR 102, D-Gebäude Seminarraum 2"
                  value={raumSeminar}
                  onChange={(e) => setRaumSeminar(e.target.value)}
                  onBlur={handleSaveAnmerkungen}
                  helperText="Optional - Raum für das Seminar"
                />
              </Grid>
            )}
          </Grid>
        </Paper>
      )}

      {/* Info Box */}
      <Alert severity="info" sx={{ mt: 3 }}>
        <AlertTitle>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Info />
            <span>Hinweis zur Raumplanung</span>
          </Box>
        </AlertTitle>
        Die Raumzuteilung erfolgt nach Verfügbarkeit. Ihre Anforderungen werden bei der Planung
        berücksichtigt, können aber nicht garantiert werden. Bei speziellen Anforderungen
        kontaktieren Sie bitte frühzeitig die Raumverwaltung.
      </Alert>

      {/* Room Dialog */}
      <Dialog open={openRoomDialog} onClose={handleCloseRoomDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {editingRoom ? 'Raumanforderung bearbeiten' : 'Neue Raumanforderung'}
        </DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12}>
              <TextField
                select
                fullWidth
                label="Raumtyp"
                value={newRoom.type}
                onChange={(e) => setNewRoom({ ...newRoom, type: e.target.value })}
                SelectProps={{ native: true }}
              >
                {roomTypes.map(type => (
                  <option key={type.value} value={type.value}>
                    {type.label}
                  </option>
                ))}
              </TextField>
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                type="number"
                label="Kapazität (Personen)"
                value={newRoom.capacity}
                onChange={(e) => setNewRoom({ 
                  ...newRoom, 
                  capacity: parseInt(e.target.value) || 0 
                })}
                inputProps={{ min: 1, max: 500 }}
              />
            </Grid>
            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom>
                Benötigte Ausstattung
              </Typography>
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                {equipmentOptions.map(eq => (
                  <Chip
                    key={eq}
                    label={eq}
                    onClick={() => handleToggleEquipment(eq)}
                    color={newRoom.equipment.includes(eq) ? 'primary' : 'default'}
                    variant={newRoom.equipment.includes(eq) ? 'filled' : 'outlined'}
                  />
                ))}
              </Box>
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={2}
                label="Zusätzliche Hinweise"
                value={newRoom.notes}
                onChange={(e) => setNewRoom({ ...newRoom, notes: e.target.value })}
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseRoomDialog}>Abbrechen</Button>
          <Button variant="contained" onClick={handleSaveRoom}>
            {editingRoom ? 'Speichern' : 'Hinzufügen'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Navigation */}
      <Box sx={{ mt: 4, display: 'flex', justifyContent: 'space-between' }}>
        <Button startIcon={<NavigateBefore />} onClick={onBack}>
          Zurück
        </Button>
        <Button
          variant="contained"
          endIcon={<NavigateNext />}
          onClick={handleContinue}
        >
          Weiter
        </Button>
      </Box>
    </Box>
  );
};

export default StepZusatzInfos;