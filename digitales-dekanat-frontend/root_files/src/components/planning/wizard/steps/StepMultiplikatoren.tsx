import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Button,
  IconButton,
  Chip,
  Alert,
  Grid,
  Card,
  CardContent,
  Collapse,
} from '@mui/material';
import {
  NavigateNext,
  NavigateBefore,
  Edit,
  Save,
  Cancel,
  ExpandMore,
  ExpandLess,
  Info,
  Warning,
  CheckCircle,
} from '@mui/icons-material';
import { GeplantesModul } from '../../../../types/planung.types';
import { StepMultiplikatorenProps } from '../../../../types/StepProps.types';
import planungService from '../../../../services/planungService';
import { createContextLogger } from '../../../../utils/logger';
import { MULTIPLIKATOR_LIMITS } from '../../../../constants/planning.constants';

const log = createContextLogger('StepMultiplikatoren');

interface EditingState {
  modulId: number | null;
  values: {
    anzahl_vorlesungen: number;
    anzahl_uebungen: number;
    anzahl_praktika: number;
    anzahl_seminare: number;
  };
}

const StepMultiplikatoren: React.FC<StepMultiplikatorenProps> = ({ 
  data, 
  onUpdate, 
  onNext, 
  onBack,
  planungId 
}) => {
  const [geplantModule, setGeplantModule] = useState<GeplantesModul[]>(
    data.geplantModule || []
  );
  const [editing, setEditing] = useState<EditingState>({
    modulId: null,
    values: {
      anzahl_vorlesungen: 0,
      anzahl_uebungen: 0,
      anzahl_praktika: 0,
      anzahl_seminare: 0,
    }
  });
  const [expandedRows, setExpandedRows] = useState<number[]>([]);
  const [showInfo, setShowInfo] = useState(false);
  const [saving, setSaving] = useState(false);

  // Calculate SWS for a module using real Lehrformen data from backend
  const calculateModulSWS = (gm: GeplantesModul) => {
    // Use pre-calculated SWS if available (already computed by backend)
    if (gm.sws_gesamt && gm.sws_gesamt > 0) {
      return {
        sws_vorlesung: gm.sws_vorlesung || 0,
        sws_uebung: gm.sws_uebung || 0,
        sws_praktikum: gm.sws_praktikum || 0,
        sws_seminar: gm.sws_seminar || 0,
        sws_gesamt: gm.sws_gesamt,
      };
    }

    // Fallback: Calculate from Modul-Lehrformen (real SWS from database)
    const lehrformen = gm.modul?.lehrformen || [];

    // Helper to get base SWS for a teaching form by its abbreviation
    const getBaseSWS = (kuerzel: string): number => {
      const lehrform = lehrformen.find(l => l.kuerzel === kuerzel);
      return lehrform?.sws || 0;
    };

    const sws_vorlesung = gm.anzahl_vorlesungen * getBaseSWS('V');
    const sws_uebung = gm.anzahl_uebungen * getBaseSWS('Ü');
    const sws_praktikum = gm.anzahl_praktika * getBaseSWS('P');
    const sws_seminar = gm.anzahl_seminare * getBaseSWS('S');

    return {
      sws_vorlesung,
      sws_uebung,
      sws_praktikum,
      sws_seminar,
      sws_gesamt: sws_vorlesung + sws_uebung + sws_praktikum + sws_seminar,
    };
  };

  // Calculate total SWS
  const calculateTotalSWS = () => {
    return geplantModule.reduce((sum, gm) => {
      const sws = calculateModulSWS(gm);
      return sum + sws.sws_gesamt;
    }, 0);
  };

  // Check if multipliers are reasonable
  const checkMultiplierWarning = (gm: GeplantesModul) => {
    const total = gm.anzahl_vorlesungen + gm.anzahl_uebungen + 
                  gm.anzahl_praktika + gm.anzahl_seminare;
    
    if (total === 0) return 'error';
    if (total > MULTIPLIKATOR_LIMITS.warningThreshold) return 'warning';
    if (gm.anzahl_vorlesungen > MULTIPLIKATOR_LIMITS.vorlesungWarning || gm.anzahl_uebungen > MULTIPLIKATOR_LIMITS.uebungWarning) return 'warning';
    return 'success';
  };

  const handleStartEdit = (gm: GeplantesModul) => {
    setEditing({
      modulId: gm.modul_id,
      values: {
        anzahl_vorlesungen: gm.anzahl_vorlesungen,
        anzahl_uebungen: gm.anzahl_uebungen,
        anzahl_praktika: gm.anzahl_praktika,
        anzahl_seminare: gm.anzahl_seminare,
      }
    });
  };

  const handleCancelEdit = () => {
    setEditing({
      modulId: null,
      values: {
        anzahl_vorlesungen: 0,
        anzahl_uebungen: 0,
        anzahl_praktika: 0,
        anzahl_seminare: 0,
      }
    });
  };

  const handleSaveEdit = async () => {
    if (!editing.modulId) return;

    const updatedModule = geplantModule.map(gm => {
      if (gm.modul_id === editing.modulId) {
        const sws = calculateModulSWS({ ...gm, ...editing.values });
        return {
          ...gm,
          ...editing.values,
          ...sws,
        };
      }
      return gm;
    });

    setGeplantModule(updatedModule);
    onUpdate({ geplantModule: updatedModule });

    // Save to backend if planungId exists
    if (planungId) {
      setSaving(true);
      try {
        await planungService.updateModule(
          planungId,
          editing.modulId,
          editing.values
        );
      } catch (error) {
        log.error('Error saving multipliers:', error);
      } finally {
        setSaving(false);
      }
    }

    handleCancelEdit();
  };

  const handleToggleExpand = (modulId: number) => {
    setExpandedRows(prev => 
      prev.includes(modulId) 
        ? prev.filter(id => id !== modulId)
        : [...prev, modulId]
    );
  };

  const getLehrformenText = (gm: GeplantesModul) => {
    const parts = [];
    if (gm.anzahl_vorlesungen > 0) parts.push(`${gm.anzahl_vorlesungen}V`);
    if (gm.anzahl_uebungen > 0) parts.push(`${gm.anzahl_uebungen}Ü`);
    if (gm.anzahl_praktika > 0) parts.push(`${gm.anzahl_praktika}P`);
    if (gm.anzahl_seminare > 0) parts.push(`${gm.anzahl_seminare}S`);
    return parts.join(' + ') || 'Keine';
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'error': return 'error';
      case 'warning': return 'warning';
      case 'success': return 'success';
      default: return 'default';
    }
  };

  const totalSWS = calculateTotalSWS();
  const modulesWithWarning = geplantModule.filter(gm => 
    checkMultiplierWarning(gm) === 'warning'
  ).length;
  const modulesWithError = geplantModule.filter(gm => 
    checkMultiplierWarning(gm) === 'error'
  ).length;

  return (
    <Box>
      <Typography variant="h6" gutterBottom>
        Multiplikatoren für Lehrformen festlegen
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Passen Sie die Anzahl der Gruppen für jede Lehrform an. Die SWS werden automatisch berechnet.
      </Typography>

      {/* Info Button */}
      <Box sx={{ mb: 2 }}>
        <Button
          size="small"
          startIcon={<Info />}
          onClick={() => setShowInfo(!showInfo)}
        >
          Erläuterung zu Multiplikatoren
        </Button>
      </Box>

      <Collapse in={showInfo}>
        <Alert severity="info" sx={{ mb: 3 }}>
          <Typography variant="subtitle2" gutterBottom>
            Was sind Multiplikatoren?
          </Typography>
          <Typography variant="body2">
            Multiplikatoren geben an, wie oft eine Lehrform angeboten wird:
          </Typography>
          <ul style={{ margin: '8px 0', paddingLeft: '20px' }}>
            <li>Bei 2 Übungsgruppen: Multiplikator = 2</li>
            <li>Bei 3 Praktikumsgruppen: Multiplikator = 3</li>
            <li>Die SWS werden entsprechend multipliziert</li>
          </ul>
        </Alert>
      </Collapse>

      {/* Statistics Cards */}
      <Grid container spacing={2} sx={{ mb: 3 }}>
        <Grid item xs={12} md={3}>
          <Card>
            <CardContent>
              <Typography variant="subtitle2" color="text.secondary">
                Gesamt SWS
              </Typography>
              <Typography variant="h4" color="primary">
                {totalSWS.toFixed(1)}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Semesterwochenstunden
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={3}>
          <Card>
            <CardContent>
              <Typography variant="subtitle2" color="text.secondary">
                Module
              </Typography>
              <Typography variant="h4">
                {geplantModule.length}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                Geplante Module
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={3}>
          <Card>
            <CardContent>
              <Typography variant="subtitle2" color="text.secondary">
                Durchschnitt
              </Typography>
              <Typography variant="h4">
                {geplantModule.length > 0 
                  ? (totalSWS / geplantModule.length).toFixed(1)
                  : '0.0'
                }
              </Typography>
              <Typography variant="caption" color="text.secondary">
                SWS pro Modul
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={3}>
          <Card>
            <CardContent>
              <Typography variant="subtitle2" color="text.secondary">
                Status
              </Typography>
              {modulesWithError > 0 ? (
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                  <Warning color="error" />
                  <Typography color="error">
                    {modulesWithError} Fehler
                  </Typography>
                </Box>
              ) : modulesWithWarning > 0 ? (
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                  <Warning color="warning" />
                  <Typography color="warning.main">
                    {modulesWithWarning} Warnungen
                  </Typography>
                </Box>
              ) : (
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                  <CheckCircle color="success" />
                  <Typography color="success.main">
                    Alles OK
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Warnings */}
      {modulesWithError > 0 && (
        <Alert severity="error" sx={{ mb: 2 }}>
          <strong>Achtung:</strong> {modulesWithError} Module haben keine Lehrformen zugeordnet!
        </Alert>
      )}
      {modulesWithWarning > 0 && (
        <Alert severity="warning" sx={{ mb: 2 }}>
          <strong>Hinweis:</strong> {modulesWithWarning} Module haben ungewöhnlich hohe Multiplikatoren.
        </Alert>
      )}

      {/* Module Table */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell width={40} />
              <TableCell>Modul</TableCell>
              <TableCell align="center">Vorlesung</TableCell>
              <TableCell align="center">Übung</TableCell>
              <TableCell align="center">Praktikum</TableCell>
              <TableCell align="center">Seminar</TableCell>
              <TableCell align="right">SWS</TableCell>
              <TableCell align="center">Status</TableCell>
              <TableCell align="center">Aktion</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {geplantModule.map((gm) => {
              const isEditing = editing.modulId === gm.modul_id;
              const sws = calculateModulSWS(gm);
              const status = checkMultiplierWarning(gm);
              const isExpanded = expandedRows.includes(gm.modul_id);

              return (
                <React.Fragment key={gm.modul_id}>
                  <TableRow>
                    <TableCell>
                      <IconButton
                        size="small"
                        onClick={() => handleToggleExpand(gm.modul_id)}
                      >
                        {isExpanded ? <ExpandLess /> : <ExpandMore />}
                      </IconButton>
                    </TableCell>
                    <TableCell>
                      <Typography variant="subtitle2">
                        {gm.modul?.kuerzel}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {gm.modul?.bezeichnung_de}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      {isEditing ? (
                        <TextField
                          type="number"
                          size="small"
                          value={editing.values.anzahl_vorlesungen}
                          onChange={(e) => setEditing({
                            ...editing,
                            values: {
                              ...editing.values,
                              anzahl_vorlesungen: parseInt(e.target.value) || 0
                            }
                          })}
                          inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                          sx={{ width: 70 }}
                        />
                      ) : (
                        <Typography>{gm.anzahl_vorlesungen}</Typography>
                      )}
                    </TableCell>
                    <TableCell align="center">
                      {isEditing ? (
                        <TextField
                          type="number"
                          size="small"
                          value={editing.values.anzahl_uebungen}
                          onChange={(e) => setEditing({
                            ...editing,
                            values: {
                              ...editing.values,
                              anzahl_uebungen: parseInt(e.target.value) || 0
                            }
                          })}
                          inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                          sx={{ width: 70 }}
                        />
                      ) : (
                        <Typography>{gm.anzahl_uebungen}</Typography>
                      )}
                    </TableCell>
                    <TableCell align="center">
                      {isEditing ? (
                        <TextField
                          type="number"
                          size="small"
                          value={editing.values.anzahl_praktika}
                          onChange={(e) => setEditing({
                            ...editing,
                            values: {
                              ...editing.values,
                              anzahl_praktika: parseInt(e.target.value) || 0
                            }
                          })}
                          inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                          sx={{ width: 70 }}
                        />
                      ) : (
                        <Typography>{gm.anzahl_praktika}</Typography>
                      )}
                    </TableCell>
                    <TableCell align="center">
                      {isEditing ? (
                        <TextField
                          type="number"
                          size="small"
                          value={editing.values.anzahl_seminare}
                          onChange={(e) => setEditing({
                            ...editing,
                            values: {
                              ...editing.values,
                              anzahl_seminare: parseInt(e.target.value) || 0
                            }
                          })}
                          inputProps={{ min: 0, max: MULTIPLIKATOR_LIMITS.maxInput }}
                          sx={{ width: 70 }}
                        />
                      ) : (
                        <Typography>{gm.anzahl_seminare}</Typography>
                      )}
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="subtitle1" fontWeight={600}>
                        {sws.sws_gesamt.toFixed(1)}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Chip
                        size="small"
                        label={
                          status === 'error' ? 'Fehler' :
                          status === 'warning' ? 'Warnung' : 'OK'
                        }
                        color={getStatusColor(status) as 'default' | 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning'}
                        variant={status === 'success' ? 'outlined' : 'filled'}
                      />
                    </TableCell>
                    <TableCell align="center">
                      {isEditing ? (
                        <Box sx={{ display: 'flex', gap: 0.5 }}>
                          <IconButton
                            size="small"
                            color="primary"
                            onClick={handleSaveEdit}
                            disabled={saving}
                          >
                            <Save />
                          </IconButton>
                          <IconButton
                            size="small"
                            onClick={handleCancelEdit}
                          >
                            <Cancel />
                          </IconButton>
                        </Box>
                      ) : (
                        <IconButton
                          size="small"
                          onClick={() => handleStartEdit(gm)}
                        >
                          <Edit />
                        </IconButton>
                      )}
                    </TableCell>
                  </TableRow>
                  
                  {/* Expanded Details */}
                  <TableRow>
                    <TableCell colSpan={9} sx={{ py: 0 }}>
                      <Collapse in={isExpanded} timeout="auto" unmountOnExit>
                        <Box sx={{ p: 2, bgcolor: 'background.default' }}>
                          <Grid container spacing={2}>
                            <Grid item xs={12} md={6}>
                              <Typography variant="subtitle2" gutterBottom>
                                Lehrformen-Übersicht
                              </Typography>
                              <Chip
                                label={getLehrformenText(gm)}
                                color="primary"
                                variant="outlined"
                                sx={{ mr: 1 }}
                              />
                            </Grid>
                            <Grid item xs={12} md={6}>
                              <Typography variant="subtitle2" gutterBottom>
                                SWS-Aufschlüsselung
                              </Typography>
                              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                {sws.sws_vorlesung > 0 && (
                                  <Chip size="small" label={`V: ${sws.sws_vorlesung}`} />
                                )}
                                {sws.sws_uebung > 0 && (
                                  <Chip size="small" label={`Ü: ${sws.sws_uebung}`} />
                                )}
                                {sws.sws_praktikum > 0 && (
                                  <Chip size="small" label={`P: ${sws.sws_praktikum}`} />
                                )}
                                {sws.sws_seminar > 0 && (
                                  <Chip size="small" label={`S: ${sws.sws_seminar}`} />
                                )}
                              </Box>
                            </Grid>

                            {/* Raum-Präferenzen (aus Template oder manuell gesetzt) */}
                            {(gm.raum_vorlesung || gm.raum_uebung || gm.raum_praktikum || gm.raum_seminar) && (
                              <Grid item xs={12} md={6}>
                                <Typography variant="subtitle2" gutterBottom>
                                  Raum-Präferenzen
                                </Typography>
                                <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                  {gm.raum_vorlesung && (
                                    <Chip size="small" label={`V: ${gm.raum_vorlesung}`} color="info" variant="outlined" />
                                  )}
                                  {gm.raum_uebung && (
                                    <Chip size="small" label={`Ü: ${gm.raum_uebung}`} color="info" variant="outlined" />
                                  )}
                                  {gm.raum_praktikum && (
                                    <Chip size="small" label={`P: ${gm.raum_praktikum}`} color="info" variant="outlined" />
                                  )}
                                  {gm.raum_seminar && (
                                    <Chip size="small" label={`S: ${gm.raum_seminar}`} color="info" variant="outlined" />
                                  )}
                                </Box>
                              </Grid>
                            )}

                            {/* Kapazitäten (aus Template oder manuell gesetzt) */}
                            {(gm.kapazitaet_vorlesung || gm.kapazitaet_uebung || gm.kapazitaet_praktikum || gm.kapazitaet_seminar) && (
                              <Grid item xs={12} md={6}>
                                <Typography variant="subtitle2" gutterBottom>
                                  Kapazitäten
                                </Typography>
                                <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>
                                  {gm.kapazitaet_vorlesung && (
                                    <Chip size="small" label={`V: ${gm.kapazitaet_vorlesung} Plätze`} color="secondary" variant="outlined" />
                                  )}
                                  {gm.kapazitaet_uebung && (
                                    <Chip size="small" label={`Ü: ${gm.kapazitaet_uebung} Plätze`} color="secondary" variant="outlined" />
                                  )}
                                  {gm.kapazitaet_praktikum && (
                                    <Chip size="small" label={`P: ${gm.kapazitaet_praktikum} Plätze`} color="secondary" variant="outlined" />
                                  )}
                                  {gm.kapazitaet_seminar && (
                                    <Chip size="small" label={`S: ${gm.kapazitaet_seminar} Plätze`} color="secondary" variant="outlined" />
                                  )}
                                </Box>
                              </Grid>
                            )}

                            {gm.anmerkungen && (
                              <Grid item xs={12}>
                                <Typography variant="subtitle2" gutterBottom>
                                  Anmerkungen
                                </Typography>
                                <Typography variant="body2">
                                  {gm.anmerkungen}
                                </Typography>
                              </Grid>
                            )}

                            {gm.raumbedarf && (
                              <Grid item xs={12}>
                                <Typography variant="subtitle2" gutterBottom>
                                  Raumbedarf
                                </Typography>
                                <Typography variant="body2">
                                  {gm.raumbedarf}
                                </Typography>
                              </Grid>
                            )}
                          </Grid>
                        </Box>
                      </Collapse>
                    </TableCell>
                  </TableRow>
                </React.Fragment>
              );
            })}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Navigation */}
      <Box sx={{ mt: 4, display: 'flex', justifyContent: 'space-between' }}>
        <Button startIcon={<NavigateBefore />} onClick={onBack}>
          Zurück
        </Button>
        <Button
          variant="contained"
          endIcon={<NavigateNext />}
          onClick={onNext}
          disabled={modulesWithError > 0}
        >
          Weiter
        </Button>
      </Box>
    </Box>
  );
};

export default StepMultiplikatoren;