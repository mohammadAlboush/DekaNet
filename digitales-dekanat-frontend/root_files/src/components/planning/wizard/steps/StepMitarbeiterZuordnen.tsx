import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Button,
  Grid,
  Card,
  CardContent,
  Chip,
  Alert,
  CircularProgress,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  OutlinedInput,
  Checkbox,
  ListItemText,
  Divider,
} from '@mui/material';
import {
  NavigateBefore,
  NavigateNext,
  Person,
  PersonAdd,
  CheckCircle,
  Info,
  School,
} from '@mui/icons-material';
import { StepMitarbeiterZuordnenProps } from '../../../../types/StepProps.types';
import api from '../../../../services/api';
import { createContextLogger } from '../../../../utils/logger';

const log = createContextLogger('StepMitarbeiterZuordnen');

interface Dozent {
  id: number;
  name_komplett: string;
  name_kurz: string;
  titel?: string;
  email?: string;
  aktiv: boolean;
}

const ITEM_HEIGHT = 48;
const ITEM_PADDING_TOP = 8;
const MenuProps = {
  PaperProps: {
    style: {
      maxHeight: ITEM_HEIGHT * 4.5 + ITEM_PADDING_TOP,
      width: 250,
    },
  },
};

const StepMitarbeiterZuordnen: React.FC<StepMitarbeiterZuordnenProps> = ({ 
  data, 
  onUpdate, 
  onNext, 
  onBack 
}) => {
  const [loading, setLoading] = useState(true);
  const [dozenten, setDozenten] = useState<Dozent[]>([]);
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [zuordnungen, setZuordnungen] = useState<Map<number, number[]>>(new Map());

  useEffect(() => {
    loadData();
  }, []);

  // Load existing assignments from wizard data
  useEffect(() => {
    if (data.mitarbeiterZuordnung) {
      setZuordnungen(new Map(data.mitarbeiterZuordnung));
    }
  }, [data.mitarbeiterZuordnung]);

  const loadData = async () => {
    try {
      setLoading(true);
      
      // Load current user
      const userResponse = await api.get('/auth/me');
      if (userResponse.data.success) {
        setCurrentUser(userResponse.data.data);
      }

      // Load all active dozenten - Korrekte Route (plural!)
      const dozentenResponse = await api.get('/dozenten?aktiv=true');
      if (dozentenResponse.data.success) {
        setDozenten(dozentenResponse.data.data || []);
      }

      // Auto-assign current professor to all modules if not already assigned
      if (userResponse.data.success && userResponse.data.data.dozent_id) {
        const dozentId = userResponse.data.data.dozent_id;
        const newZuordnungen = new Map(data.mitarbeiterZuordnung || new Map());
        
        data.geplantModule.forEach((gm) => {
          // Nur zuordnen wenn noch keine Mitarbeiter zugeordnet sind
          if (!newZuordnungen.has(gm.modul_id) || newZuordnungen.get(gm.modul_id)?.length === 0) {
            log.debug('Auto-assigning professor to module:', gm.modul?.kuerzel);
            newZuordnungen.set(gm.modul_id, [dozentId]);
          }
        });

        setZuordnungen(newZuordnungen);
        onUpdate({ mitarbeiterZuordnung: newZuordnungen });
      }

    } catch (error) {
      log.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleZuordnungChange = (modulId: number, dozentenIds: number[]) => {
    log.debug('Updating assignment for module:', modulId, 'Dozenten:', dozentenIds);
    
    const newZuordnungen = new Map(zuordnungen);
    newZuordnungen.set(modulId, dozentenIds);
    
    setZuordnungen(newZuordnungen);
    onUpdate({ mitarbeiterZuordnung: newZuordnungen });
  };

  // Removed unused helper functions:
  // - getAssignedDozenten (not called anywhere)
  // - getDozentenNamen (not called anywhere)

  const isCurrentUserAssigned = (modulId: number): boolean => {
    if (!currentUser?.dozent_id) return false;
    const dozentenIds = zuordnungen.get(modulId) || [];
    return dozentenIds.includes(currentUser.dozent_id);
  };

  const allModulesAssigned = (): boolean => {
    return data.geplantModule.every(gm => {
      const assigned = zuordnungen.get(gm.modul_id);
      return assigned && assigned.length > 0;
    });
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 4 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Mitarbeiter zuordnen
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Ordnen Sie jedem Modul die verantwortlichen Mitarbeiter zu. Sie wurden automatisch als Verantwortlicher eingetragen.
        </Typography>
      </Box>

      {/* Info Alert */}
      <Alert severity="info" sx={{ mb: 3 }} icon={<Info />}>
        <Typography variant="body2">
          Sie können für jedes Modul mehrere Mitarbeiter auswählen. Die Auswahl kann später noch geändert werden.
          {currentUser?.dozent_id && (
            <strong> Sie wurden automatisch als Verantwortlicher für alle Module eingetragen.</strong>
          )}
        </Typography>
      </Alert>

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
                <CheckCircle color={allModulesAssigned() ? 'success' : 'disabled'} />
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    Zugeordnet
                  </Typography>
                  <Typography variant="h6">
                    {Array.from(zuordnungen.values()).filter(z => z.length > 0).length} / {data.geplantModule.length}
                  </Typography>
                </Box>
              </Box>
            </Grid>
            <Grid item xs={12} md={4}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <Person color="action" />
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    Verfügbare Dozenten
                  </Typography>
                  <Typography variant="h6">
                    {dozenten.length}
                  </Typography>
                </Box>
              </Box>
            </Grid>
          </Grid>
        </Paper>
      )}

      {/* Module Cards */}
      {data.geplantModule.length === 0 ? (
        <Alert severity="warning">
          <Typography variant="body2">
            Keine Module vorhanden. Bitte gehen Sie zurück und fügen Sie Module hinzu.
          </Typography>
        </Alert>
      ) : (
        <Grid container spacing={2}>
          {data.geplantModule.map((gm) => (
            <Grid item xs={12} key={gm.modul_id}>
              <Card variant="outlined">
                <CardContent>
                  <Grid container spacing={2} alignItems="center">
                    {/* Modul Info */}
                    <Grid item xs={12} md={4}>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                        <School color="primary" />
                        <Typography variant="h6">
                          {gm.modul?.kuerzel}
                        </Typography>
                        {isCurrentUserAssigned(gm.modul_id) && (
                          <Chip 
                            size="small" 
                            label="Sie" 
                            color="primary"
                            icon={<Person />}
                          />
                        )}
                      </Box>
                      <Typography variant="body2" color="text.secondary">
                        {gm.modul?.bezeichnung_de}
                      </Typography>
                      <Box sx={{ display: 'flex', gap: 0.5, mt: 1 }}>
                        {gm.modul?.leistungspunkte && (
                          <Chip size="small" label={`${gm.modul.leistungspunkte} ECTS`} />
                        )}
                        {gm.sws_gesamt && (
                          <Chip size="small" label={`${gm.sws_gesamt.toFixed(1)} SWS`} color="secondary" />
                        )}
                      </Box>
                    </Grid>

                    <Divider orientation="vertical" flexItem sx={{ display: { xs: 'none', md: 'block' } }} />

                    {/* Mitarbeiter Selection */}
                    <Grid item xs={12} md={7}>
                      <FormControl fullWidth>
                        <InputLabel id={`dozenten-label-${gm.modul_id}`}>
                          Mitarbeiter auswählen
                        </InputLabel>
                        <Select
                          labelId={`dozenten-label-${gm.modul_id}`}
                          multiple
                          value={zuordnungen.get(gm.modul_id) || []}
                          onChange={(e) => handleZuordnungChange(gm.modul_id, e.target.value as number[])}
                          input={<OutlinedInput label="Mitarbeiter auswählen" />}
                          renderValue={(selected) => (
                            <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                              {(selected as number[]).map((value) => {
                                const dozent = dozenten.find(d => d.id === value);
                                // Show warning if dozent not found (inactive or deleted)
                                if (!dozent) {
                                  return (
                                    <Chip
                                      key={value}
                                      label={`Unbekannt (ID: ${value})`}
                                      size="small"
                                      color="error"
                                      title="Dieser Dozent ist nicht mehr verfügbar. Bitte entfernen und neu zuweisen."
                                    />
                                  );
                                }
                                return (
                                  <Chip
                                    key={value}
                                    label={dozent.name_kurz}
                                    size="small"
                                    icon={value === currentUser?.dozent_id ? <Person /> : undefined}
                                    color={value === currentUser?.dozent_id ? "primary" : "default"}
                                  />
                                );
                              })}
                            </Box>
                          )}
                          MenuProps={MenuProps}
                        >
                          {dozenten.map((dozent) => (
                            <MenuItem key={dozent.id} value={dozent.id}>
                              <Checkbox 
                                checked={(zuordnungen.get(gm.modul_id) || []).includes(dozent.id)} 
                              />
                              <ListItemText 
                                primary={
                                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    {dozent.name_komplett}
                                    {dozent.id === currentUser?.dozent_id && (
                                      <Chip size="small" label="Sie" color="primary" />
                                    )}
                                  </Box>
                                }
                                secondary={dozent.email}
                              />
                            </MenuItem>
                          ))}
                        </Select>
                      </FormControl>

                      {/* Assigned Count */}
                      <Box sx={{ mt: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
                        {(zuordnungen.get(gm.modul_id) || []).length > 0 ? (
                          <>
                            <CheckCircle fontSize="small" color="success" />
                            <Typography variant="caption" color="text.secondary">
                              {(zuordnungen.get(gm.modul_id) || []).length} Mitarbeiter zugeordnet
                            </Typography>
                          </>
                        ) : (
                          <>
                            <PersonAdd fontSize="small" color="disabled" />
                            <Typography variant="caption" color="text.secondary">
                              Keine Mitarbeiter zugeordnet
                            </Typography>
                          </>
                        )}
                      </Box>
                    </Grid>
                  </Grid>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      {/* Completion Alert */}
      {!allModulesAssigned() && data.geplantModule.length > 0 && (
        <Alert severity="warning" sx={{ mt: 3 }}>
          <Typography variant="body2">
            Bitte ordnen Sie allen Modulen mindestens einen Mitarbeiter zu, um fortzufahren.
          </Typography>
        </Alert>
      )}

      {allModulesAssigned() && data.geplantModule.length > 0 && (
        <Alert severity="success" sx={{ mt: 3 }}>
          <Typography variant="body2">
            ✓ Alle Module haben zugeordnete Mitarbeiter. Sie können fortfahren.
          </Typography>
        </Alert>
      )}

      {/* Info: Optional Step */}
      <Alert severity="info" sx={{ mt: 3 }}>
        <Typography variant="body2" fontWeight={600} gutterBottom>
          Optionaler Schritt
        </Typography>
        <Typography variant="body2">
          Die Mitarbeiter-Zuordnung ist optional. Sie können auch ohne Zuordnung fortfahren und diese später vornehmen.
        </Typography>
      </Alert>

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
        >
          Weiter
        </Button>
      </Box>
    </Box>
  );
};

export default StepMitarbeiterZuordnen;