/**
 * Phasen-Statistiken Komponente
 *
 * Zeigt Statistiken pro Planungsphase an:
 * - Gesamtübersicht über alle Phasen
 * - Detaillierte Statistiken pro Phase
 * - Visualisierungen und Trends
 */

import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Grid,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  LinearProgress,
  Tabs,
  Tab,
  Alert,
  CircularProgress,
  Accordion,
  AccordionSummary,
  AccordionDetails,
} from '@mui/material';
import {
  ExpandMore,
  CheckCircle,
  Cancel,
  Edit,
  Send,
  TrendingUp,
  Schedule,
  Assessment,
} from '@mui/icons-material';
import dashboardService, {
  PhasenStatistikResponse,
} from '../../services/dashboardService';
import { createContextLogger } from '../../utils/logger';

const log = createContextLogger('PhasenStatistiken');

interface PhasenStatistikenProps {
  semesterId?: number;
  limit?: number;
}

const PhasenStatistiken: React.FC<PhasenStatistikenProps> = ({
  semesterId,
  limit,
}) => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<PhasenStatistikResponse | null>(null);
  const [tabValue, setTabValue] = useState(0);

  useEffect(() => {
    loadStatistiken();
  }, [semesterId, limit]);

  const loadStatistiken = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await dashboardService.getPhasenStatistik(
        semesterId,
        limit
      );

      if (response.success && response.data) {
        setData(response.data);
      } else {
        setError(response.message || 'Fehler beim Laden der Statistiken');
      }
    } catch (err: unknown) {
      // Detaillierte Fehlerinformationen
      log.error('Fehler beim Laden der Phasen-Statistiken:', { err });

      let errorMessage = 'Ein Fehler ist aufgetreten beim Laden der Statistiken';

      // Type-safe error handling for axios errors
      if (err && typeof err === 'object') {
        const axiosError = err as { response?: { status?: number; data?: { message?: string } }; message?: string };
        if (axiosError.response?.status === 500) {
          errorMessage = 'Server-Fehler: Der Backend-Endpoint "/dashboard/statistik/phasen" ist fehlerhaft. Bitte prüfen Sie das Backend-Log für Details.';
        } else if (axiosError.response?.status === 404) {
          errorMessage = 'Der Statistik-Endpoint wurde nicht gefunden. Möglicherweise fehlt die Backend-Implementierung.';
        } else if (axiosError.response?.status === 403) {
          errorMessage = 'Keine Berechtigung: Sie benötigen Dekan-Rechte für diese Statistiken.';
        } else if (axiosError.response?.data?.message) {
          errorMessage = axiosError.response.data.message;
        } else if (axiosError.message) {
          errorMessage = axiosError.message;
        }
      }

      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      entwuerfe: '#FFA726',
      eingereicht: '#42A5F5',
      freigegeben: '#66BB6A',
      abgelehnt: '#EF5350',
    };
    return colors[status] || '#9E9E9E';
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'freigegeben':
        return <CheckCircle sx={{ fontSize: 20 }} />;
      case 'abgelehnt':
        return <Cancel sx={{ fontSize: 20 }} />;
      case 'eingereicht':
        return <Send sx={{ fontSize: 20 }} />;
      case 'entwuerfe':
        return <Edit sx={{ fontSize: 20 }} />;
      default:
        return null;
    }
  };

  const formatDatum = (datum: string | null) => {
    if (!datum) return 'N/A';
    return new Date(datum).toLocaleDateString('de-DE', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
    });
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" p={4}>
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Alert severity="error" sx={{ m: 2 }}>
        {error}
      </Alert>
    );
  }

  if (!data) {
    return (
      <Alert severity="info" sx={{ m: 2 }}>
        Keine Statistiken verfügbar
      </Alert>
    );
  }

  const { gesamt, phasen } = data;

  return (
    <Box>
      {/* Gesamtstatistik-Karten */}
      <Typography variant="h5" gutterBottom sx={{ mb: 3, fontWeight: 600 }}>
        Planungsstatistiken Übersicht
      </Typography>

      <Grid container spacing={3} sx={{ mb: 4 }}>
        {/* Anzahl Phasen */}
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={2}>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <Schedule color="primary" sx={{ mr: 1 }} />
                <Typography variant="body2" color="text.secondary">
                  Planungsphasen
                </Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                {gesamt.anzahl_phasen}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                {gesamt.aktive_phasen} aktiv
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        {/* Gesamt Planungen */}
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={2}>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <Assessment color="primary" sx={{ mr: 1 }} />
                <Typography variant="body2" color="text.secondary">
                  Gesamt Planungen
                </Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                {gesamt.anzahl_planungen_gesamt}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                {gesamt.anzahl_entwuerfe_gesamt} Entwürfe
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        {/* Genehmigungen */}
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={2}>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <CheckCircle color="success" sx={{ mr: 1 }} />
                <Typography variant="body2" color="text.secondary">
                  Genehmigungen
                </Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold" color="success.main">
                {gesamt.anzahl_genehmigt_gesamt}
              </Typography>
              <Typography variant="caption" color="text.secondary">
                {gesamt.anzahl_einreichungen_gesamt} Einreichungen
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        {/* Genehmigungsrate */}
        <Grid item xs={12} sm={6} md={3}>
          <Card elevation={2}>
            <CardContent>
              <Box display="flex" alignItems="center" mb={1}>
                <TrendingUp color="primary" sx={{ mr: 1 }} />
                <Typography variant="body2" color="text.secondary">
                  Genehmigungsrate
                </Typography>
              </Box>
              <Typography variant="h4" fontWeight="bold">
                {gesamt.durchschnittliche_genehmigungsrate.toFixed(1)}%
              </Typography>
              <Box mt={1}>
                <LinearProgress
                  variant="determinate"
                  value={gesamt.durchschnittliche_genehmigungsrate}
                  sx={{ height: 8, borderRadius: 4 }}
                />
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Tabs für Ansichten */}
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
        <Tabs value={tabValue} onChange={(_, newValue) => setTabValue(newValue)}>
          <Tab label="Detailansicht" />
          <Tab label="Tabellenansicht" />
        </Tabs>
      </Box>

      {/* Detailansicht */}
      {tabValue === 0 && (
        <Box>
          {phasen.length === 0 ? (
            <Alert severity="info">Keine Planungsphasen vorhanden</Alert>
          ) : (
            phasen.map((phase) => (
              <Accordion key={phase.phase_id} sx={{ mb: 2 }}>
                <AccordionSummary expandIcon={<ExpandMore />}>
                  <Box
                    display="flex"
                    justifyContent="space-between"
                    alignItems="center"
                    width="100%"
                    pr={2}
                  >
                    <Box>
                      <Typography variant="h6" fontWeight="600">
                        {phase.phase_name}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {phase.semester_name} • {formatDatum(phase.startdatum)} -{' '}
                        {phase.geschlossen_am
                          ? formatDatum(phase.geschlossen_am)
                          : 'Laufend'}
                      </Typography>
                    </Box>
                    <Box display="flex" gap={1}>
                      {phase.ist_aktiv && (
                        <Chip label="Aktiv" color="success" size="small" />
                      )}
                      <Chip
                        label={`${phase.dauer_tage} Tage`}
                        size="small"
                        variant="outlined"
                      />
                    </Box>
                  </Box>
                </AccordionSummary>
                <AccordionDetails>
                  <Grid container spacing={3}>
                    {/* Planungen nach Status */}
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" gutterBottom fontWeight="600">
                        Planungen nach Status
                      </Typography>
                      <Box mt={2}>
                        {[
                          {
                            label: 'Entwürfe',
                            value: phase.statistiken.entwuerfe,
                            key: 'entwuerfe',
                          },
                          {
                            label: 'Eingereicht',
                            value: phase.statistiken.eingereicht,
                            key: 'eingereicht',
                          },
                          {
                            label: 'Freigegeben',
                            value: phase.statistiken.freigegeben,
                            key: 'freigegeben',
                          },
                          {
                            label: 'Abgelehnt',
                            value: phase.statistiken.abgelehnt,
                            key: 'abgelehnt',
                          },
                        ].map((item) => (
                          <Box
                            key={item.key}
                            display="flex"
                            alignItems="center"
                            justifyContent="space-between"
                            mb={1.5}
                          >
                            <Box display="flex" alignItems="center">
                              <Box
                                sx={{
                                  color: getStatusColor(item.key),
                                  mr: 1,
                                }}
                              >
                                {getStatusIcon(item.key)}
                              </Box>
                              <Typography variant="body2">{item.label}</Typography>
                            </Box>
                            <Box display="flex" alignItems="center" gap={1}>
                              <Typography variant="h6" fontWeight="600">
                                {item.value}
                              </Typography>
                              <Box sx={{ width: 100 }}>
                                <LinearProgress
                                  variant="determinate"
                                  value={
                                    phase.statistiken.gesamt_planungen > 0
                                      ? (item.value /
                                          phase.statistiken.gesamt_planungen) *
                                        100
                                      : 0
                                  }
                                  sx={{
                                    height: 6,
                                    borderRadius: 3,
                                    backgroundColor: '#E0E0E0',
                                    '& .MuiLinearProgress-bar': {
                                      backgroundColor: getStatusColor(item.key),
                                    },
                                  }}
                                />
                              </Box>
                            </Box>
                          </Box>
                        ))}
                      </Box>
                    </Grid>

                    {/* Weitere Statistiken */}
                    <Grid item xs={12} md={6}>
                      <Typography variant="subtitle2" gutterBottom fontWeight="600">
                        Weitere Statistiken
                      </Typography>
                      <Box mt={2}>
                        <Card variant="outlined" sx={{ mb: 2 }}>
                          <CardContent>
                            <Typography variant="body2" color="text.secondary">
                              Genehmigungsrate
                            </Typography>
                            <Typography variant="h5" fontWeight="600" gutterBottom>
                              {phase.statistiken.genehmigungsrate.toFixed(1)}%
                            </Typography>
                            <LinearProgress
                              variant="determinate"
                              value={phase.statistiken.genehmigungsrate}
                              sx={{ height: 8, borderRadius: 4 }}
                            />
                          </CardContent>
                        </Card>

                        <Card variant="outlined" sx={{ mb: 2 }}>
                          <CardContent>
                            <Typography variant="body2" color="text.secondary">
                              Gesamt SWS
                            </Typography>
                            <Typography variant="h5" fontWeight="600">
                              {phase.statistiken.sws.gesamt.toFixed(2)}
                            </Typography>
                            <Typography variant="caption" color="text.secondary">
                              Ø {phase.statistiken.sws.durchschnitt.toFixed(2)} SWS
                              pro Planung
                            </Typography>
                          </CardContent>
                        </Card>

                        <Card variant="outlined">
                          <CardContent>
                            <Typography variant="body2" color="text.secondary">
                              Gesamt Planungen
                            </Typography>
                            <Typography variant="h5" fontWeight="600">
                              {phase.statistiken.gesamt_planungen}
                            </Typography>
                          </CardContent>
                        </Card>
                      </Box>
                    </Grid>
                  </Grid>
                </AccordionDetails>
              </Accordion>
            ))
          )}
        </Box>
      )}

      {/* Tabellenansicht */}
      {tabValue === 1 && (
        <TableContainer component={Paper} elevation={2}>
          <Table>
            <TableHead>
              <TableRow sx={{ backgroundColor: '#f5f5f5' }}>
                <TableCell>Phase</TableCell>
                <TableCell>Semester</TableCell>
                <TableCell align="center">Status</TableCell>
                <TableCell align="right">Planungen</TableCell>
                <TableCell align="right">Genehmigt</TableCell>
                <TableCell align="right">Rate</TableCell>
                <TableCell align="right">SWS</TableCell>
                <TableCell align="right">Dauer</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {phasen.map((phase) => (
                <TableRow key={phase.phase_id} hover>
                  <TableCell>
                    <Typography variant="body2" fontWeight="600">
                      {phase.phase_name}
                    </Typography>
                  </TableCell>
                  <TableCell>{phase.semester_name}</TableCell>
                  <TableCell align="center">
                    {phase.ist_aktiv ? (
                      <Chip label="Aktiv" color="success" size="small" />
                    ) : (
                      <Chip label="Geschlossen" size="small" />
                    )}
                  </TableCell>
                  <TableCell align="right">
                    {phase.statistiken.gesamt_planungen}
                  </TableCell>
                  <TableCell align="right">
                    <Typography variant="body2" color="success.main" fontWeight="600">
                      {phase.statistiken.freigegeben}
                    </Typography>
                  </TableCell>
                  <TableCell align="right">
                    {phase.statistiken.genehmigungsrate.toFixed(1)}%
                  </TableCell>
                  <TableCell align="right">
                    {phase.statistiken.sws.gesamt.toFixed(2)}
                  </TableCell>
                  <TableCell align="right">{phase.dauer_tage} Tage</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      )}
    </Box>
  );
};

export default PhasenStatistiken;
