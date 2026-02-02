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
  TextField,
  InputAdornment,
  Alert,
  CircularProgress,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Checkbox,
  FormControlLabel,
  Stack,
  Divider,
} from '@mui/material';
import {
  NavigateBefore,
  NavigateNext,
  Search,
  School,
  CheckCircle,
  Schedule,
  FilterList,
  Person,
} from '@mui/icons-material';
import { StepModuleAuswahlProps } from '../../../../types/StepProps.types';
import { Modul, ModulDozent } from '../../../../types/modul.types';
import api from '../../../../services/api';
import { logger } from '../../../../utils/logger';

interface ModulFilters {
  turnus: string;
  minECTS: number;
  maxECTS: number;
  suchbegriff: string;
  nurMeineModule: boolean;
}

const StepModuleAuswahl: React.FC<StepModuleAuswahlProps> = ({ 
  data, 
  onUpdate, 
  onNext, 
  onBack 
}) => {
  const [loading, setLoading] = useState(true);
  const [alleModule, setAlleModule] = useState<Modul[]>([]);
  const [meineModule, setMeineModule] = useState<Modul[]>([]);
  const [gefilterte, setGefilterte] = useState<Modul[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<number>>(new Set());
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [filters, setFilters] = useState<ModulFilters>({
    turnus: '',
    minECTS: 0,
    maxECTS: 30,
    suchbegriff: '',
    nurMeineModule: true, // Start mit true - zeige standardmäßig nur eigene Module
  });

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    if (data.selectedModules && data.selectedModules.length > 0) {
      const ids = new Set(data.selectedModules.map(m => m.id));
      setSelectedIds(ids);
    }
  }, [data.selectedModules]);

  // DEAKTIVIERT: Turnus-Filter bleibt auf "Alle" statt automatisch gesetzt zu werden
  // useEffect(() => {
  //   if (data.semester?.kuerzel) {
  //     const semesterTurnus = determineSemesterTurnus(data.semester.kuerzel);
  //     setFilters(prev => ({ ...prev, turnus: semesterTurnus }));
  //   }
  // }, [data.semester]);

  useEffect(() => {
    applyFilters();
  }, [filters, alleModule, meineModule]);

  const loadData = async () => {
    try {
      setLoading(true);
      logger.debug('StepModuleAuswahl', 'Load data start');

      // Load current user
      logger.debug('StepModuleAuswahl', 'Fetching current user from /auth/me...');
      const userResponse = await api.get('/auth/me');
      logger.debug('StepModuleAuswahl', 'User response', {
        success: userResponse.data.success,
        status: userResponse.status,
        dataKeys: Object.keys(userResponse.data),
      });

      if (userResponse.data.success) {
        // Backend gibt {data: {user: {...}}} zurück, nicht direkt {data: {...}}
        const userData = userResponse.data.data.user || userResponse.data.data;
        setCurrentUser(userData);
        logger.debug('StepModuleAuswahl', 'Current user loaded', {
          id: userData.id,
          username: userData.username,
          dozent_id: userData.dozent_id,
          rolle: userData.rolle,
          allKeys: Object.keys(userData)
        });
      } else {
        logger.error('StepModuleAuswahl', 'User response not successful');
      }

      // Load all modules
      logger.debug('StepModuleAuswahl', 'Fetching all modules from /module...');
      const modulResponse = await api.get('/module');
      logger.debug('StepModuleAuswahl', 'Module response', {
        success: modulResponse.data.success,
        status: modulResponse.status,
        dataLength: modulResponse.data.data?.length,
      });

      if (modulResponse.data.success) {
        const module = modulResponse.data.data || [];
        setAlleModule(module);
        logger.debug('StepModuleAuswahl', 'Alle Module geladen', { count: module.length });

        // Debug: Zeige Struktur der ersten 3 Module
        logger.debug('StepModuleAuswahl', 'Struktur der ersten 3 Module');
        module.slice(0, 3).forEach((m: Modul, index: number) => {
          logger.debug('StepModuleAuswahl', `Modul ${index + 1}: ${m.kuerzel}`, {
            id: m.id,
            kuerzel: m.kuerzel,
            hasDozenten: !!m.dozenten,
            dozentenIsArray: Array.isArray(m.dozenten),
            dozentenLength: m.dozenten?.length || 0,
            dozenten: m.dozenten,
            allModuleKeys: Object.keys(m)
          });
        });

        // Korrekte Prüfung der Dozenten-Zuordnung
        const userData = userResponse.data.data.user || userResponse.data.data;
        if (userResponse.data.success && userData.dozent_id) {
          const dozentId = userData.dozent_id;
          logger.debug('StepModuleAuswahl', 'Filtering modules for dozent_id', { dozentId });

          // Filtere Module wo der Dozent zugeordnet ist
          const eigeneModule = module.filter((m: Modul) => {
            const hasDozenten = m.dozenten && Array.isArray(m.dozenten) && m.dozenten.length > 0;

            if (!hasDozenten) {
              logger.warn('StepModuleAuswahl', `Modul ${m.kuerzel} hat keine Dozenten-Zuordnung`);
              return false;
            }

            // Prüfe ob der Dozent in der Liste ist
            const isAssigned = m.dozenten?.some((d: ModulDozent) => {
              const match = d.dozent_id === dozentId;
              logger.debug('StepModuleAuswahl', `${match ? 'Match' : 'No match'} Checking ${m.kuerzel} - Dozent ${d.dozent_id} vs ${dozentId}`);
              return match;
            }) || false;

            if (isAssigned) {
              logger.debug('StepModuleAuswahl', `MATCH: ${m.kuerzel} ist dem Dozenten zugeordnet`);
            }

            return isAssigned;
          });

          setMeineModule(eigeneModule);
          logger.debug('StepModuleAuswahl', 'Meine Module gefunden', {
            count: eigeneModule.length,
            kuerzel: eigeneModule.map((m: Modul) => m.kuerzel).join(', ')
          });

          // Debug: Zeige Details ALLER eigenen Module
          eigeneModule.forEach((m: Modul, index: number) => {
            logger.debug('StepModuleAuswahl', `Eigenes Modul ${index + 1}: ${m.kuerzel}`, {
              id: m.id,
              dozenten: m.dozenten?.map((d: ModulDozent) => ({
                dozent_id: d.dozent_id,
                name: d.name_komplett || `${d.vorname} ${d.nachname}`,
                rolle: d.rolle
              }))
            });
          });
        } else {
          logger.error('StepModuleAuswahl', 'Kein dozent_id gefunden - kann nicht filtern', {
            userData,
            rawResponseData: userResponse.data.data
          });
          setMeineModule([]);
        }
      } else {
        logger.error('StepModuleAuswahl', 'Module response not successful');
      }

      logger.debug('StepModuleAuswahl', 'Load data end');
    } catch (error) {
      logger.error('StepModuleAuswahl', 'Error loading data', error);
      if (error instanceof Error) {
        logger.error('StepModuleAuswahl', 'Error details', {
          message: error.message,
          stack: error.stack
        });
      }
    } finally {
      setLoading(false);
    }
  };

  // Removed unused function: determineSemesterTurnus
  // (was only used in commented code on line 81)

  const applyFilters = () => {
    logger.debug('StepModuleAuswahl', 'Apply filters start', {
      filters,
      availableModules: {
        alleModule: alleModule.length,
        meineModule: meineModule.length
      }
    });

    // Start mit der richtigen Modulbasis
    let filtered = filters.nurMeineModule ? meineModule : alleModule;
    logger.debug('StepModuleAuswahl', 'Starting with', {
      source: filters.nurMeineModule ? 'meineModule' : 'alleModule',
      count: filtered.length
    });

    // Turnus-Filter
    if (filters.turnus) {
      const beforeCount = filtered.length;
      filtered = filtered.filter(m =>
        m.turnus === filters.turnus || m.turnus === 'Jedes Semester'
      );
      logger.debug('StepModuleAuswahl', `Turnus filter "${filters.turnus}"`, { beforeCount, afterCount: filtered.length });
    }

    // ECTS-Filter
    if (filters.minECTS > 0) {
      const beforeCount = filtered.length;
      filtered = filtered.filter(m =>
        (m.leistungspunkte || 0) >= filters.minECTS
      );
      logger.debug('StepModuleAuswahl', `Min ECTS filter (>=${filters.minECTS})`, { beforeCount, afterCount: filtered.length });
    }
    if (filters.maxECTS < 30) {
      const beforeCount = filtered.length;
      filtered = filtered.filter(m =>
        (m.leistungspunkte || 0) <= filters.maxECTS
      );
      logger.debug('StepModuleAuswahl', `Max ECTS filter (<=${filters.maxECTS})`, { beforeCount, afterCount: filtered.length });
    }

    // Verbesserte Suchfunktion
    if (filters.suchbegriff && filters.suchbegriff.trim() !== '') {
      const search = filters.suchbegriff.toLowerCase().trim();
      const beforeCount = filtered.length;
      filtered = filtered.filter(m => {
        // Suche in mehreren Feldern
        const searchableFields = [
          m.kuerzel?.toLowerCase(),
          m.bezeichnung_de?.toLowerCase(),
          m.bezeichnung_en?.toLowerCase(),
          m.untertitel?.toLowerCase()
        ];

        // Prüfe ob mindestens ein Feld den Suchbegriff enthält
        return searchableFields.some(field => field && field.includes(search));
      });
      logger.debug('StepModuleAuswahl', `Search filter "${search}"`, { beforeCount, afterCount: filtered.length });
    }

    setGefilterte(filtered);
    logger.debug('StepModuleAuswahl', 'Apply filters end', {
      finalCount: filtered.length,
      kuerzel: filtered.map(m => m.kuerzel).join(', ')
    });
  };

  const handleToggleModule = (modul: Modul) => {
    const newSelected = new Set(selectedIds);
    
    if (newSelected.has(modul.id)) {
      newSelected.delete(modul.id);
    } else {
      newSelected.add(modul.id);
    }
    
    setSelectedIds(newSelected);

    const selectedModules = alleModule.filter(m => newSelected.has(m.id));
    onUpdate({ selectedModules });
  };

  const handleSelectAll = () => {
    const allIds = new Set(gefilterte.map(m => m.id));
    setSelectedIds(allIds);
    
    const selectedModules = alleModule.filter(m => allIds.has(m.id));
    onUpdate({ selectedModules });
  };

  const handleDeselectAll = () => {
    setSelectedIds(new Set());
    onUpdate({ selectedModules: [] });
  };

  const isSelected = (modulId: number) => selectedIds.has(modulId);

  const canProceed = selectedIds.size > 0;

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
          Module auswählen
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Wählen Sie die Module aus, die Sie in diesem Semester planen möchten.
          {filters.nurMeineModule && meineModule.length > 0 && (
            <strong> Es werden nur Ihre zugeordneten Module angezeigt ({meineModule.length}).</strong>
          )}
        </Typography>
      </Box>

      {data.semester && (
        <Alert severity="info" sx={{ mb: 3 }}>
          <Typography variant="body2">
            <strong>Semester:</strong> {data.semester.bezeichnung} ({data.semester.kuerzel})
          </Typography>
        </Alert>
      )}

      {/* Debug Info - nur im Entwicklungsmodus */}
      {process.env.NODE_ENV === 'development' && currentUser && (
        <Alert severity="info" sx={{ mb: 3 }}>
          <Typography variant="caption">
            Debug: User {currentUser.username} • Dozent-ID: {currentUser.dozent_id || 'keine'} • 
            Module gesamt: {alleModule.length} • Meine Module: {meineModule.length}
          </Typography>
        </Alert>
      )}

      <Paper sx={{ p: 2, mb: 3 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
          <FilterList color="primary" />
          <Typography variant="subtitle1" fontWeight={600}>
            Filter & Suche
          </Typography>
        </Box>

        <Grid container spacing={2}>
          <Grid item xs={12} md={4}>
            <TextField
              fullWidth
              size="small"
              placeholder="Modul suchen (Kürzel, Name)..."
              value={filters.suchbegriff}
              onChange={(e) => setFilters(prev => ({ ...prev, suchbegriff: e.target.value }))}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Search />
                  </InputAdornment>
                ),
              }}
            />
          </Grid>

          <Grid item xs={12} md={3}>
            <FormControl fullWidth size="small">
              <InputLabel>Turnus</InputLabel>
              <Select
                value={filters.turnus}
                label="Turnus"
                onChange={(e) => setFilters(prev => ({ ...prev, turnus: e.target.value }))}
              >
                <MenuItem value="">Alle</MenuItem>
                <MenuItem value="Wintersemester">Wintersemester</MenuItem>
                <MenuItem value="Sommersemester">Sommersemester</MenuItem>
                <MenuItem value="Jedes Semester">Jedes Semester</MenuItem>
              </Select>
            </FormControl>
          </Grid>

          <Grid item xs={6} md={2}>
            <TextField
              fullWidth
              size="small"
              type="number"
              label="Min ECTS"
              value={filters.minECTS}
              onChange={(e) => setFilters(prev => ({ ...prev, minECTS: parseInt(e.target.value) || 0 }))}
              inputProps={{ min: 0, max: 30 }}
            />
          </Grid>

          <Grid item xs={6} md={2}>
            <TextField
              fullWidth
              size="small"
              type="number"
              label="Max ECTS"
              value={filters.maxECTS}
              onChange={(e) => setFilters(prev => ({ ...prev, maxECTS: parseInt(e.target.value) || 30 }))}
              inputProps={{ min: 0, max: 30 }}
            />
          </Grid>

          <Grid item xs={12}>
            <FormControlLabel
              control={
                <Checkbox
                  checked={filters.nurMeineModule}
                  onChange={(e) => setFilters(prev => ({ 
                    ...prev, 
                    nurMeineModule: e.target.checked 
                  }))}
                  color="primary"
                />
              }
              label={
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <Person fontSize="small" />
                  <Typography variant="body2">
                    Nur meine zugeordneten Module anzeigen 
                    {meineModule.length > 0 
                      ? ` (${meineModule.length} Module)`
                      : ' (keine Module zugeordnet)'}
                  </Typography>
                </Box>
              }
            />
          </Grid>
        </Grid>

        <Divider sx={{ my: 2 }} />

        <Stack direction="row" spacing={1}>
          <Button
            size="small"
            onClick={handleSelectAll}
            disabled={gefilterte.length === 0}
          >
            Alle auswählen ({gefilterte.length})
          </Button>
          <Button
            size="small"
            onClick={handleDeselectAll}
            disabled={selectedIds.size === 0}
          >
            Auswahl aufheben
          </Button>
        </Stack>
      </Paper>

      {selectedIds.size > 0 && (
        <Alert severity="success" sx={{ mb: 2 }}>
          <Typography variant="body2">
            <strong>{selectedIds.size}</strong> {selectedIds.size === 1 ? 'Modul' : 'Module'} ausgewählt
          </Typography>
        </Alert>
      )}

      {gefilterte.length === 0 ? (
        <Alert severity="info">
          <Typography variant="body2">
            {filters.nurMeineModule && meineModule.length === 0 
              ? 'Ihnen sind noch keine Module zugeordnet. Deaktivieren Sie den Filter "Nur meine Module" um alle Module zu sehen.'
              : filters.suchbegriff 
                ? `Keine Module für "${filters.suchbegriff}" gefunden. Passen Sie die Suche an.`
                : 'Keine Module gefunden. Passen Sie die Filter an.'}
          </Typography>
        </Alert>
      ) : (
        <Grid container spacing={2}>
          {gefilterte.map((modul) => (
            <Grid item xs={12} md={6} lg={4} key={modul.id}>
              <Card
                variant="outlined"
                sx={{
                  cursor: 'pointer',
                  transition: 'all 0.2s',
                  border: isSelected(modul.id) ? 2 : 1,
                  borderColor: isSelected(modul.id) ? 'primary.main' : 'divider',
                  bgcolor: isSelected(modul.id) ? 'primary.50' : 'background.paper',
                  '&:hover': {
                    borderColor: 'primary.main',
                    boxShadow: 2,
                  },
                }}
                onClick={() => handleToggleModule(modul)}
              >
                <CardContent>
                  <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}>
                    <Typography variant="h6" component="div" sx={{ fontWeight: 600 }}>
                      {modul.kuerzel}
                    </Typography>
                    {isSelected(modul.id) && (
                      <CheckCircle color="primary" />
                    )}
                  </Box>

                  <Typography variant="body2" color="text.secondary" sx={{ mb: 2, minHeight: 40 }}>
                    {modul.bezeichnung_de}
                  </Typography>

                  <Stack direction="row" spacing={1} flexWrap="wrap" gap={1}>
                    {modul.leistungspunkte && (
                      <Chip
                        size="small"
                        icon={<School />}
                        label={`${modul.leistungspunkte} ECTS`}
                        color="primary"
                        variant="outlined"
                      />
                    )}
                    {modul.sws_gesamt && modul.sws_gesamt > 0 && (
                      <Chip
                        size="small"
                        icon={<Schedule />}
                        label={`${modul.sws_gesamt} SWS`}
                        color="secondary"
                        variant="outlined"
                      />
                    )}
                    {modul.turnus && (
                      <Chip
                        size="small"
                        label={modul.turnus === 'Wintersemester' ? 'WS' : modul.turnus === 'Sommersemester' ? 'SS' : 'WS+SS'}
                        variant="outlined"
                      />
                    )}
                  </Stack>

                  {/* Zeige ob es ein eigenes Modul ist */}
                  {meineModule.some(m => m.id === modul.id) && (
                    <Box sx={{ mt: 1 }}>
                      <Chip
                        size="small"
                        icon={<Person />}
                        label="Mein Modul"
                        color="success"
                        variant="outlined"
                      />
                    </Box>
                  )}
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

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
          Weiter ({selectedIds.size} {selectedIds.size === 1 ? 'Modul' : 'Module'})
        </Button>
      </Box>
    </Box>
  );
};

export default StepModuleAuswahl;