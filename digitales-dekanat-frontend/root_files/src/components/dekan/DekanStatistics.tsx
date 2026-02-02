import React, { useEffect, useState } from 'react';
import {
  Grid,
  Paper,
  Typography,
  Box,
  Card,
  CardContent,
  LinearProgress,
  Chip,
  Alert,
  Tabs,
  Tab,
  Divider,
  CircularProgress,
} from '@mui/material';
import { createContextLogger } from '../../utils/logger';

const log = createContextLogger('DekanStatistics');
import {
  TrendingUp,
  TrendingDown,
  Warning,
  Person,
  School,
  AccessTime,
  BarChart as BarChartIcon,
  PieChart as PieChartIcon,
  ShowChart,
  Assessment,
  Timeline,
} from '@mui/icons-material';
import {
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip as RechartsTooltip,
  Legend,
  ResponsiveContainer,
  LineChart,
  Line,
} from 'recharts';
import planungService from '../../services/planungService';
import api from '../../services/api';
import { Semesterplanung } from '../../types/planung.types';
import PhasenStatistiken from '../dashboard/PhasenStatistiken';

interface DekanStatisticsProps {
  semesterId: number;
  semesterBezeichnung: string;
}

interface DozentData {
  id: number;
  name_komplett: string;
  name_kurz: string;
  email: string;
  aktiv: boolean;
  hat_planung: boolean;
  planung?: Semesterplanung;
  anzahl_module: number;
  gesamt_sws: number;
  gesamt_ects: number;
  sws_vorlesung: number;
  sws_uebung: number;
  sws_praktikum: number;
  sws_seminar: number;
  status?: string;
  eingereicht_am?: string;
}

interface StatisticsSummary {
  // Allgemein
  total_dozenten: number;
  aktive_dozenten: number;
  mit_planung: number;
  ohne_planung: number;
  einreichungs_quote: number;

  // Status
  eingereicht: number;
  entwurf: number;
  freigegeben: number;
  abgelehnt: number;

  // SWS
  gesamt_sws: number;
  durchschnitt_sws: number;
  median_sws: number;
  min_sws: number;
  max_sws: number;
  standardabweichung_sws: number;

  // Module & ECTS
  gesamt_module: number;
  gesamt_ects: number;
  durchschnitt_module: number;
  durchschnitt_ects: number;

  // Fairness
  gini_koeffizient: number;
  cv_sws: number; // Variationskoeffizient
}

const COLORS = {
  primary: '#1976d2',
  success: '#2e7d32',
  warning: '#ed6c02',
  error: '#d32f2f',
  info: '#0288d1',
  grey: '#757575',
};

const STATUS_COLORS = {
  eingereicht: COLORS.warning,
  freigegeben: COLORS.success,
  abgelehnt: COLORS.error,
  entwurf: COLORS.grey,
  ohne_planung: '#e0e0e0',
};

/**
 * DekanStatistics - PROFESSIONELLE Statistiken mit Charts
 * ========================================================
 * Umfassende Datenanalyse für Dekane mit:
 * - Interaktiven Diagrammen (recharts)
 * - Alle Dozenten (mit und ohne Planung)
 * - Fairness-Metriken
 * - Multiple Ansichten (Tabs)
 */
const DekanStatistics: React.FC<DekanStatisticsProps> = ({ semesterId, semesterBezeichnung }) => {
  const [loading, setLoading] = useState(true);
  const [tabValue, setTabValue] = useState(0);
  const [dozenten, setDozenten] = useState<DozentData[]>([]);
  const [summary, setSummary] = useState<StatisticsSummary | null>(null);

  useEffect(() => {
    loadStatistics();
  }, [semesterId]);

  const loadStatistics = async () => {
    setLoading(true);
    try {
      log.debug('========== LOADING STATISTICS START ==========');
      log.debug('Semester ID:', semesterId);

      // Load ALL active Dozenten
      log.debug('Fetching all active dozenten...');
      const dozentenResponse = await api.get('/dozenten?aktiv=true');
      log.debug('Dozenten response:', dozentenResponse);

      // Load all planungen - NUR für aktive Planungsphase!
      log.debug('Fetching planungen for semester (nur aktive Phase):', semesterId);
      const planungenResponse = await planungService.getAllPlanungenDekan({
        semester_id: semesterId,
        nur_aktive_phase: true  // Kritisch: Nur aktive Phase!
      });
      log.debug('Planungen response (nur aktive Phase):', planungenResponse);

      if (dozentenResponse.data.success && planungenResponse.success) {
        const allDozenten = dozentenResponse.data.data || [];
        const planungen = planungenResponse.data || [];

        log.debug('Data loaded successfully:');
        log.debug('  - Dozenten:', allDozenten.length);
        log.debug('  - Planungen:', planungen.length);
        log.debug('First 3 Dozenten:', allDozenten.slice(0, 3));
        log.debug('First 3 Planungen:', planungen.slice(0, 3));

        // Debug: Show structure
        if (planungen.length > 0) {
          log.debug('First planung structure:', {
            id: planungen[0].id,
            benutzer: planungen[0].benutzer,
            status: planungen[0].status,
            anzahl_module: planungen[0].anzahl_module,
            gesamt_sws: planungen[0].gesamt_sws,
            geplante_module: planungen[0].geplante_module,
            geplante_module_count: planungen[0].geplante_module?.length
          });
        }

        // Merge data
        log.debug('Merging dozenten and planungen data...');
        const mergedData = mergeDozentPlanungData(allDozenten, planungen);
        log.debug('Merged data:', mergedData.length, 'entries');
        log.debug('First 3 merged entries:', mergedData.slice(0, 3));

        setDozenten(mergedData);

        // Calculate comprehensive summary
        log.debug('Calculating comprehensive summary...');
        const summaryData = calculateComprehensiveSummary(mergedData);
        log.debug('Summary calculated:', summaryData);

        setSummary(summaryData);
      } else {
        log.error('Response not successful:', {
          dozentenSuccess: dozentenResponse.data.success,
          planungenSuccess: planungenResponse.success
        });
      }

      log.debug('========== LOADING STATISTICS END ==========');
    } catch (error) {
      log.error('Error loading statistics:', error);
    } finally {
      setLoading(false);
    }
  };

  const mergeDozentPlanungData = (
    allDozenten: Array<{
      id: number;
      name_komplett: string;
      name_kurz?: string;
      nachname?: string;
      email?: string;
      aktiv: boolean;
    }>,
    planungen: Semesterplanung[]
  ): DozentData[] => {
    log.debug('Starting merge...');
    log.debug('  - Dozenten count:', allDozenten.length);
    log.debug('  - Planungen count:', planungen.length);

    // Create map of planungen by dozent email/user
    const planungMap = new Map<string, Semesterplanung>();

    // Also try matching by username if email doesn't work
    const planungMapByUsername = new Map<string, Semesterplanung>();

    planungen.forEach(p => {
      if (p.benutzer?.email) {
        planungMap.set(p.benutzer.email.toLowerCase(), p);
        log.debug(`[Map] Added planung for email: ${p.benutzer.email}`);
      }
      if (p.benutzer?.username) {
        planungMapByUsername.set(p.benutzer.username.toLowerCase(), p);
        log.debug(`[Map] Added planung for username: ${p.benutzer.username}`);
      }
    });

    log.debug('Map sizes:', {
      byEmail: planungMap.size,
      byUsername: planungMapByUsername.size
    });

    return allDozenten.map((dozent, index) => {
      // Try to find planung by email or username
      let planung = planungMap.get(dozent.email?.toLowerCase());

      // If no match, try matching by username from email (part before @)
      if (!planung && dozent.email) {
        const emailUsername = dozent.email.split('@')[0].toLowerCase();
        planung = planungMapByUsername.get(emailUsername);
        if (planung) {
          log.debug(`[Dozent ${index + 1}] MATCHED by email username: ${emailUsername}`);
        }
      }

      // Fallback: try name_kurz
      if (!planung && dozent.name_kurz) {
        planung = planungMapByUsername.get(dozent.name_kurz.toLowerCase());
      }

      log.debug(`[Dozent ${index + 1}] ${dozent.name_komplett} (${dozent.email}):`,
        planung ? `HAS PLANUNG (${planung.anzahl_module} modules, ${planung.gesamt_sws} SWS)` : 'NO PLANUNG'
      );

      if (planung) {
        // Calculate ECTS
        const gesamt_ects = planung.geplante_module?.reduce((sum, gm) =>
          sum + (gm.modul?.leistungspunkte || 0), 0
        ) || 0;

        log.debug(`  - ECTS calculation: ${gesamt_ects} (from ${planung.geplante_module?.length || 0} modules)`);

        // Calculate SWS breakdown
        const sws_breakdown = planung.geplante_module?.reduce((acc, gm) => ({
          vorlesung: acc.vorlesung + (gm.sws_vorlesung || 0),
          uebung: acc.uebung + (gm.sws_uebung || 0),
          praktikum: acc.praktikum + (gm.sws_praktikum || 0),
          seminar: acc.seminar + (gm.sws_seminar || 0),
        }), { vorlesung: 0, uebung: 0, praktikum: 0, seminar: 0 }) ||
        { vorlesung: 0, uebung: 0, praktikum: 0, seminar: 0 };

        log.debug(`  - SWS breakdown:`, sws_breakdown);

        return {
          id: dozent.id,
          name_komplett: dozent.name_komplett,
          name_kurz: dozent.name_kurz || dozent.nachname,
          email: dozent.email,
          aktiv: dozent.aktiv,
          hat_planung: true,
          planung,
          anzahl_module: planung.anzahl_module || 0,
          gesamt_sws: planung.gesamt_sws || 0,
          gesamt_ects,
          sws_vorlesung: sws_breakdown.vorlesung,
          sws_uebung: sws_breakdown.uebung,
          sws_praktikum: sws_breakdown.praktikum,
          sws_seminar: sws_breakdown.seminar,
          status: planung.status,
          eingereicht_am: planung.eingereicht_am,
        };
      } else {
        return {
          id: dozent.id,
          name_komplett: dozent.name_komplett,
          name_kurz: dozent.name_kurz || dozent.nachname,
          email: dozent.email,
          aktiv: dozent.aktiv,
          hat_planung: false,
          anzahl_module: 0,
          gesamt_sws: 0,
          gesamt_ects: 0,
          sws_vorlesung: 0,
          sws_uebung: 0,
          sws_praktikum: 0,
          sws_seminar: 0,
        };
      }
    });
  };

  const calculateComprehensiveSummary = (data: DozentData[]): StatisticsSummary => {
    const total_dozenten = data.length;
    const aktive_dozenten = data.filter(d => d.aktiv).length;
    const mit_planung = data.filter(d => d.hat_planung).length;
    const ohne_planung = total_dozenten - mit_planung;

    const eingereicht = data.filter(d => d.status === 'eingereicht').length;
    const entwurf = data.filter(d => d.status === 'entwurf').length;
    const freigegeben = data.filter(d => d.status === 'freigegeben').length;
    const abgelehnt = data.filter(d => d.status === 'abgelehnt').length;

    const gesamt_sws = data.reduce((sum, d) => sum + d.gesamt_sws, 0);
    const gesamt_module = data.reduce((sum, d) => sum + d.anzahl_module, 0);
    const gesamt_ects = data.reduce((sum, d) => sum + d.gesamt_ects, 0);

    // Only calculate averages from those who have planungen
    const mit_planung_data = data.filter(d => d.hat_planung);
    const durchschnitt_sws = mit_planung_data.length > 0 ?
      gesamt_sws / mit_planung_data.length : 0;
    const durchschnitt_module = mit_planung_data.length > 0 ?
      gesamt_module / mit_planung_data.length : 0;
    const durchschnitt_ects = mit_planung_data.length > 0 ?
      gesamt_ects / mit_planung_data.length : 0;

    // Median SWS
    const sws_sorted = mit_planung_data.map(d => d.gesamt_sws).sort((a, b) => a - b);
    const median_sws = sws_sorted.length > 0 ?
      sws_sorted[Math.floor(sws_sorted.length / 2)] : 0;

    const min_sws = mit_planung_data.length > 0 ?
      Math.min(...mit_planung_data.map(d => d.gesamt_sws)) : 0;
    const max_sws = mit_planung_data.length > 0 ?
      Math.max(...mit_planung_data.map(d => d.gesamt_sws)) : 0;

    // Standardabweichung
    const variance = mit_planung_data.length > 0 ?
      mit_planung_data.reduce((sum, d) =>
        sum + Math.pow(d.gesamt_sws - durchschnitt_sws, 2), 0
      ) / mit_planung_data.length : 0;
    const standardabweichung_sws = Math.sqrt(variance);

    // Variationskoeffizient (CV)
    const cv_sws = durchschnitt_sws > 0 ?
      (standardabweichung_sws / durchschnitt_sws) * 100 : 0;

    // Gini-Koeffizient (vereinfacht)
    const gini_koeffizient = calculateGiniCoefficient(
      mit_planung_data.map(d => d.gesamt_sws)
    );

    const einreichungs_quote = aktive_dozenten > 0 ?
      (mit_planung / aktive_dozenten) * 100 : 0;

    return {
      total_dozenten,
      aktive_dozenten,
      mit_planung,
      ohne_planung,
      einreichungs_quote,
      eingereicht,
      entwurf,
      freigegeben,
      abgelehnt,
      gesamt_sws,
      durchschnitt_sws,
      median_sws,
      min_sws,
      max_sws,
      standardabweichung_sws,
      gesamt_module,
      gesamt_ects,
      durchschnitt_module,
      durchschnitt_ects,
      gini_koeffizient,
      cv_sws,
    };
  };

  const calculateGiniCoefficient = (values: number[]): number => {
    if (values.length === 0) return 0;

    const sorted = [...values].sort((a, b) => a - b);
    const n = sorted.length;
    const sum = sorted.reduce((a, b) => a + b, 0);

    if (sum === 0) return 0;

    let numerator = 0;
    sorted.forEach((val, i) => {
      numerator += (i + 1) * val;
    });

    return ((2 * numerator) / (n * sum)) - ((n + 1) / n);
  };

  const getStatusChartData = () => {
    if (!summary) return [];

    return [
      { name: 'Eingereicht', value: summary.eingereicht, color: STATUS_COLORS.eingereicht },
      { name: 'Freigegeben', value: summary.freigegeben, color: STATUS_COLORS.freigegeben },
      { name: 'Entwurf', value: summary.entwurf, color: STATUS_COLORS.entwurf },
      { name: 'Abgelehnt', value: summary.abgelehnt, color: STATUS_COLORS.abgelehnt },
      { name: 'Keine Planung', value: summary.ohne_planung, color: STATUS_COLORS.ohne_planung },
    ].filter(item => item.value > 0);
  };

  const getSWSBarChartData = () => {
    return dozenten
      .filter(d => d.hat_planung)
      .sort((a, b) => b.gesamt_sws - a.gesamt_sws)
      .map(d => ({
        name: d.name_kurz,
        SWS: d.gesamt_sws,
        Durchschnitt: summary?.durchschnitt_sws || 0,
      }));
  };

  const getSWSBreakdownChartData = () => {
    return dozenten
      .filter(d => d.hat_planung && d.gesamt_sws > 0)
      .sort((a, b) => b.gesamt_sws - a.gesamt_sws)
      .slice(0, 10) // Top 10
      .map(d => ({
        name: d.name_kurz,
        Vorlesung: d.sws_vorlesung,
        Übung: d.sws_uebung,
        Praktikum: d.sws_praktikum,
        Seminar: d.sws_seminar,
      }));
  };

  const getModuleBarChartData = () => {
    return dozenten
      .filter(d => d.hat_planung)
      .sort((a, b) => b.anzahl_module - a.anzahl_module)
      .map(d => ({
        name: d.name_kurz,
        Module: d.anzahl_module,
        ECTS: d.gesamt_ects,
      }));
  };

  const getFairnessIndicator = () => {
    if (!summary) return { color: 'success', text: 'Ausgeglichen', severity: 'success' as const };

    // Based on CV (Variationskoeffizient)
    const cv = summary.cv_sws;

    if (cv < 15) return { color: COLORS.success, text: 'Sehr fair verteilt', severity: 'success' as const };
    if (cv < 25) return { color: COLORS.info, text: 'Ausgeglichen', severity: 'info' as const };
    if (cv < 40) return { color: COLORS.warning, text: 'Leicht ungleich', severity: 'warning' as const };
    return { color: COLORS.error, text: 'Ungleich verteilt', severity: 'error' as const };
  };

  if (loading) {
    return (
      <Box sx={{ py: 8, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}>
        <CircularProgress size={60} />
        <Typography variant="h6" color="text.secondary">
          Lade umfassende Statistiken...
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Analysiere Daten für {semesterBezeichnung}
        </Typography>
      </Box>
    );
  }

  if (!summary) {
    return (
      <Alert severity="error">
        Fehler beim Laden der Statistiken
      </Alert>
    );
  }

  const fairness = getFairnessIndicator();

  return (
    <Box>
      {/* Header with Key Metrics */}
      <Grid container spacing={3} sx={{ mb: 4 }}>
        {/* Einreichungs-Quote */}
        <Grid item xs={12} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                <Person sx={{ fontSize: 40, color: COLORS.primary }} />
                <Box sx={{ textAlign: 'right' }}>
                  <Typography variant="h3" fontWeight={700} color="primary">
                    {summary.einreichungs_quote.toFixed(0)}%
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Einreichungs-Quote
                  </Typography>
                </Box>
              </Box>
              <LinearProgress
                variant="determinate"
                value={summary.einreichungs_quote}
                sx={{ height: 8, borderRadius: 1 }}
                color={summary.einreichungs_quote >= 80 ? 'success' : summary.einreichungs_quote >= 50 ? 'warning' : 'error'}
              />
              <Typography variant="body2" sx={{ mt: 1 }} color="text.secondary">
                {summary.mit_planung} von {summary.aktive_dozenten} Dozenten
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        {/* Gesamt SWS */}
        <Grid item xs={12} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                <AccessTime sx={{ fontSize: 40, color: COLORS.success }} />
                <Box sx={{ textAlign: 'right' }}>
                  <Typography variant="h3" fontWeight={700} color="success.main">
                    {summary.gesamt_sws.toFixed(0)}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Gesamt SWS
                  </Typography>
                </Box>
              </Box>
              <Divider sx={{ my: 1 }} />
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <Typography variant="caption" color="text.secondary">Ø:</Typography>
                <Typography variant="body2" fontWeight={600}>{summary.durchschnitt_sws.toFixed(1)}</Typography>
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <Typography variant="caption" color="text.secondary">Range:</Typography>
                <Typography variant="body2">{summary.min_sws.toFixed(1)} - {summary.max_sws.toFixed(1)}</Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Module & ECTS */}
        <Grid item xs={12} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                <School sx={{ fontSize: 40, color: COLORS.info }} />
                <Box sx={{ textAlign: 'right' }}>
                  <Typography variant="h3" fontWeight={700} color="info.main">
                    {summary.gesamt_module}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Gesamt Module
                  </Typography>
                </Box>
              </Box>
              <Divider sx={{ my: 1 }} />
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <Typography variant="caption" color="text.secondary">Gesamt ECTS:</Typography>
                <Typography variant="body2" fontWeight={600}>{summary.gesamt_ects}</Typography>
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <Typography variant="caption" color="text.secondary">Ø Module/Prof:</Typography>
                <Typography variant="body2">{summary.durchschnitt_module.toFixed(1)}</Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        {/* Fairness */}
        <Grid item xs={12} md={3}>
          <Card elevation={3}>
            <CardContent>
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 2 }}>
                <Assessment sx={{ fontSize: 40, color: fairness.color }} />
                <Box sx={{ textAlign: 'right' }}>
                  <Typography variant="h4" fontWeight={700} sx={{ color: fairness.color }}>
                    {fairness.text}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Workload-Fairness
                  </Typography>
                </Box>
              </Box>
              <Divider sx={{ my: 1 }} />
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <Typography variant="caption" color="text.secondary">Std.abw.:</Typography>
                <Typography variant="body2" fontWeight={600}>{summary.standardabweichung_sws.toFixed(2)}</Typography>
              </Box>
              <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
                <Typography variant="caption" color="text.secondary">CV:</Typography>
                <Typography variant="body2">{summary.cv_sws.toFixed(1)}%</Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Fairness Warning */}
      {summary.cv_sws > 25 && (
        <Alert severity={fairness.severity} sx={{ mb: 3 }} icon={<Warning />}>
          <Typography variant="subtitle2" gutterBottom>
            ⚠️ Ungleiche Workload-Verteilung erkannt
          </Typography>
          <Typography variant="body2">
            Der Variationskoeffizient von {summary.cv_sws.toFixed(1)}% deutet auf eine ungleiche Verteilung hin.
            Differenz zwischen höchster und niedrigster Belastung: {(summary.max_sws - summary.min_sws).toFixed(1)} SWS.
          </Typography>
        </Alert>
      )}

      {/* Tabs for different views */}
      <Paper sx={{ mb: 3 }}>
        <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)} variant="fullWidth">
          <Tab label="Übersicht" icon={<BarChartIcon />} iconPosition="start" />
          <Tab label="SWS-Verteilung" icon={<ShowChart />} iconPosition="start" />
          <Tab label="Status & Module" icon={<PieChartIcon />} iconPosition="start" />
          <Tab label="Phasen-Statistiken" icon={<Timeline />} iconPosition="start" />
        </Tabs>
      </Paper>

      {/* Tab Content */}
      {tabValue === 0 && (
        <Grid container spacing={3}>
          {/* Status Distribution Pie Chart */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom fontWeight={600}>
                📊 Status-Verteilung
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={getStatusChartData()}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, value }: { name: string; value: number }) => `${name}: ${value}`}
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {getStatusChartData().map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={entry.color} />
                    ))}
                  </Pie>
                  <RechartsTooltip />
                  {/* @ts-ignore - recharts Legend type issue */}
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>

          {/* SWS per Professor Bar Chart */}
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom fontWeight={600}>
                📈 SWS pro Professor (Top 10)
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={getSWSBarChartData().slice(0, 10)}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={80} />
                  <YAxis />
                  <RechartsTooltip />
                  {/* @ts-ignore - recharts Legend type issue */}
                  <Legend />
                  <Bar dataKey="SWS" fill={COLORS.primary} />
                  <Bar dataKey="Durchschnitt" fill={COLORS.warning} />
                </BarChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>

          {/* Module Distribution */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom fontWeight={600}>
                📚 Module & ECTS pro Professor
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={getModuleBarChartData()}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={80} />
                  <YAxis yAxisId="left" />
                  <YAxis yAxisId="right" orientation="right" />
                  <RechartsTooltip />
                  {/* @ts-ignore - recharts Legend type issue */}
                  <Legend />
                  <Bar yAxisId="left" dataKey="Module" fill={COLORS.info} />
                  <Bar yAxisId="right" dataKey="ECTS" fill={COLORS.success} />
                </BarChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>
        </Grid>
      )}

      {tabValue === 1 && (
        <Grid container spacing={3}>
          {/* SWS Breakdown Stacked Bar */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom fontWeight={600}>
                📊 SWS-Aufteilung nach Lehrform (Top 10)
              </Typography>
              <ResponsiveContainer width="100%" height={400}>
                <BarChart data={getSWSBreakdownChartData()}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={80} />
                  <YAxis />
                  <RechartsTooltip />
                  {/* @ts-ignore - recharts Legend type issue */}
                  <Legend />
                  <Bar dataKey="Vorlesung" stackId="a" fill="#1976d2" />
                  <Bar dataKey="Übung" stackId="a" fill="#2e7d32" />
                  <Bar dataKey="Praktikum" stackId="a" fill="#ed6c02" />
                  <Bar dataKey="Seminar" stackId="a" fill="#9c27b0" />
                </BarChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>

          {/* SWS Distribution with Average Line */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom fontWeight={600}>
                📈 SWS-Verteilung mit Durchschnitt
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={getSWSBarChartData()}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" angle={-45} textAnchor="end" height={80} />
                  <YAxis />
                  <RechartsTooltip />
                  {/* @ts-ignore - recharts Legend type issue */}
                  <Legend />
                  <Line type="monotone" dataKey="SWS" stroke={COLORS.primary} strokeWidth={2} />
                  <Line type="monotone" dataKey="Durchschnitt" stroke={COLORS.error} strokeWidth={2} strokeDasharray="5 5" />
                </LineChart>
              </ResponsiveContainer>
            </Paper>
          </Grid>
        </Grid>
      )}

      {tabValue === 2 && (
        <Grid container spacing={3}>
          {/* Detailed Statistics Table */}
          <Grid item xs={12}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom fontWeight={600}>
                📋 Detaillierte Übersicht aller Dozenten
              </Typography>
              <Box sx={{ overflowX: 'auto' }}>
                <Box sx={{ display: 'grid', gridTemplateColumns: 'repeat(7, auto)', gap: 1, minWidth: 800 }}>
                  {/* Header */}
                  <Typography variant="subtitle2" fontWeight={700}>Name</Typography>
                  <Typography variant="subtitle2" fontWeight={700} textAlign="center">Status</Typography>
                  <Typography variant="subtitle2" fontWeight={700} textAlign="center">Module</Typography>
                  <Typography variant="subtitle2" fontWeight={700} textAlign="center">SWS</Typography>
                  <Typography variant="subtitle2" fontWeight={700} textAlign="center">ECTS</Typography>
                  <Typography variant="subtitle2" fontWeight={700} textAlign="center">vs. Ø</Typography>
                  <Typography variant="subtitle2" fontWeight={700} textAlign="center">Eingereicht</Typography>

                  {/* Rows */}
                  {dozenten.map(d => {
                    const diff = d.gesamt_sws - summary.durchschnitt_sws;
                    const diffPercent = summary.durchschnitt_sws > 0 ? (diff / summary.durchschnitt_sws) * 100 : 0;

                    return (
                      <React.Fragment key={d.id}>
                        <Typography variant="body2">{d.name_komplett}</Typography>
                        <Box sx={{ textAlign: 'center' }}>
                          {d.hat_planung ? (
                            <Chip
                              label={d.status}
                              size="small"
                              color={
                                d.status === 'freigegeben' ? 'success' :
                                d.status === 'eingereicht' ? 'warning' :
                                d.status === 'abgelehnt' ? 'error' : 'default'
                              }
                            />
                          ) : (
                            <Chip label="Keine" size="small" color="default" />
                          )}
                        </Box>
                        <Typography variant="body2" textAlign="center">{d.anzahl_module}</Typography>
                        <Typography variant="body2" textAlign="center" fontWeight={600}>
                          {d.gesamt_sws.toFixed(1)}
                        </Typography>
                        <Typography variant="body2" textAlign="center">{d.gesamt_ects}</Typography>
                        <Box sx={{ textAlign: 'center' }}>
                          <Chip
                            label={`${diffPercent > 0 ? '+' : ''}${diffPercent.toFixed(0)}%`}
                            size="small"
                            icon={diffPercent > 10 ? <TrendingUp /> : diffPercent < -10 ? <TrendingDown /> : undefined}
                            color={
                              diffPercent > 20 ? 'error' :
                              diffPercent > 10 ? 'warning' :
                              diffPercent < -20 ? 'info' :
                              diffPercent < -10 ? 'success' : 'default'
                            }
                          />
                        </Box>
                        <Typography variant="caption" textAlign="center" color="text.secondary">
                          {d.eingereicht_am ? new Date(d.eingereicht_am).toLocaleDateString('de-DE') : '-'}
                        </Typography>
                      </React.Fragment>
                    );
                  })}
                </Box>
              </Box>
            </Paper>
          </Grid>
        </Grid>
      )}

      {/* Tab 3: Phasen-Statistiken */}
      {tabValue === 3 && (
        <Paper sx={{ p: 3 }}>
          <PhasenStatistiken semesterId={semesterId} />
        </Paper>
      )}
    </Box>
  );
};

export default DekanStatistics;
