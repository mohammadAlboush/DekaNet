import React, { useState, useEffect } from 'react';
import {
  Paper,
  Typography,
  Box,
  LinearProgress,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Collapse,
  Stack,
  CircularProgress,
  Alert,
  Tooltip,
  TextField,
  InputAdornment,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
} from '@mui/material';
import {
  ExpandMore,
  ExpandLess,
  CheckCircle,
  Warning,
  Error as ErrorIcon,
  Search,
  FilterList,
  Person,
} from '@mui/icons-material';
import {
  getDozentenPlanungsfortschritt,
  DozentenPlanungsfortschrittResponse,
} from '../../services/dashboardService';
import { createContextLogger } from '../../utils/logger';
import { getErrorMessage } from '../../utils/errorUtils';

const log = createContextLogger('DozentenPlanungsfortschritt');

interface DozentenPlanungsfortschrittProps {
  semesterId?: number;
}

/**
 * DozentenPlanungsfortschritt - Zeigt den Planungsfortschritt aller Dozenten
 *
 * Features:
 * - Übersicht aller Dozenten mit Fortschrittsanzeige
 * - Filter nach Status (vollständig, teilweise, offen)
 * - Suche nach Dozentennamen
 * - Ausklappbare Details mit nicht geplanten Modulen
 */
const DozentenPlanungsfortschritt: React.FC<DozentenPlanungsfortschrittProps> = ({
  semesterId,
}) => {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<DozentenPlanungsfortschrittResponse | null>(null);
  const [expandedRows, setExpandedRows] = useState<Set<number>>(new Set());
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<'alle' | 'vollständig' | 'teilweise' | 'offen'>('alle');

  useEffect(() => {
    loadData();
  }, [semesterId]);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await getDozentenPlanungsfortschritt(semesterId);
      if (response.success && response.data) {
        setData(response.data);
      } else {
        setError(response.message || 'Fehler beim Laden der Daten');
      }
    } catch (err: unknown) {
      log.error('Error loading Dozenten Planungsfortschritt:', { err });
      setError(getErrorMessage(err, 'Fehler beim Laden der Daten'));
    } finally {
      setLoading(false);
    }
  };

  const toggleRow = (dozentId: number) => {
    const newExpanded = new Set(expandedRows);
    if (newExpanded.has(dozentId)) {
      newExpanded.delete(dozentId);
    } else {
      newExpanded.add(dozentId);
    }
    setExpandedRows(newExpanded);
  };

  const getStatusColor = (status: string): 'success' | 'warning' | 'error' => {
    switch (status) {
      case 'vollständig':
        return 'success';
      case 'teilweise':
        return 'warning';
      case 'offen':
        return 'error';
      default:
        return 'warning';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'vollständig':
        return <CheckCircle fontSize="small" color="success" />;
      case 'teilweise':
        return <Warning fontSize="small" color="warning" />;
      case 'offen':
        return <ErrorIcon fontSize="small" color="error" />;
      default:
        return null;
    }
  };

  const getProgressColor = (percent: number): 'success' | 'warning' | 'error' => {
    if (percent >= 100) return 'success';
    if (percent >= 50) return 'warning';
    return 'error';
  };

  // Filter und Suche anwenden
  const filteredDozenten = data?.dozenten.filter((dozent) => {
    // Status Filter
    if (statusFilter !== 'alle' && dozent.status !== statusFilter) {
      return false;
    }
    // Suche
    if (searchTerm && !dozent.name.toLowerCase().includes(searchTerm.toLowerCase())) {
      return false;
    }
    return true;
  }) || [];

  if (loading) {
    return (
      <Paper elevation={2} sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', py: 4 }}>
          <CircularProgress />
          <Typography sx={{ ml: 2 }}>Lade Planungsfortschritt...</Typography>
        </Box>
      </Paper>
    );
  }

  if (error) {
    return (
      <Paper elevation={2} sx={{ p: 3 }}>
        <Alert severity="error">{error}</Alert>
      </Paper>
    );
  }

  if (!data || data.dozenten.length === 0) {
    return (
      <Paper elevation={2} sx={{ p: 3 }}>
        <Alert severity="info">Keine Dozenten mit zu planenden Modulen gefunden.</Alert>
      </Paper>
    );
  }

  return (
    <Paper elevation={2} sx={{ p: 3 }}>
      {/* Header */}
      <Box sx={{ mb: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <Person sx={{ color: 'primary.main' }} />
            <Typography variant="h6">Planungsfortschritt der Dozenten</Typography>
          </Box>
          {!data.planungsphase_aktiv && (
            <Chip label="Keine aktive Planungsphase" color="warning" size="small" />
          )}
        </Box>

        {/* Statistik-Chips */}
        <Stack direction="row" spacing={1} flexWrap="wrap" sx={{ mb: 2 }}>
          <Chip
            icon={<CheckCircle />}
            label={`${data.statistik.vollstaendig} vollständig`}
            color="success"
            size="small"
            variant="outlined"
          />
          <Chip
            icon={<Warning />}
            label={`${data.statistik.teilweise} teilweise`}
            color="warning"
            size="small"
            variant="outlined"
          />
          <Chip
            icon={<ErrorIcon />}
            label={`${data.statistik.offen} offen`}
            color="error"
            size="small"
            variant="outlined"
          />
          <Chip
            label={`Ø ${data.statistik.durchschnitt_prozent.toFixed(0)}% geplant`}
            color="primary"
            size="small"
          />
        </Stack>

        {/* Filter */}
        <Stack direction="row" spacing={2}>
          <TextField
            size="small"
            placeholder="Dozent suchen..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search fontSize="small" />
                </InputAdornment>
              ),
            }}
            sx={{ minWidth: 200 }}
          />
          <FormControl size="small" sx={{ minWidth: 150 }}>
            <InputLabel>Status</InputLabel>
            <Select
              value={statusFilter}
              label="Status"
              onChange={(e) => setStatusFilter(e.target.value as 'alle' | 'vollständig' | 'teilweise' | 'offen')}
              startAdornment={<FilterList sx={{ mr: 1, color: 'action.active' }} />}
            >
              <MenuItem value="alle">Alle</MenuItem>
              <MenuItem value="vollständig">Vollständig</MenuItem>
              <MenuItem value="teilweise">Teilweise</MenuItem>
              <MenuItem value="offen">Offen</MenuItem>
            </Select>
          </FormControl>
        </Stack>
      </Box>

      {/* Tabelle */}
      <TableContainer>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell width={40}></TableCell>
              <TableCell>Dozent</TableCell>
              <TableCell align="center">Geplant</TableCell>
              <TableCell align="center" sx={{ minWidth: 200 }}>Fortschritt</TableCell>
              <TableCell align="center">Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredDozenten.map((dozent) => (
              <React.Fragment key={dozent.dozent_id}>
                <TableRow
                  hover
                  sx={{
                    cursor: dozent.nicht_geplante_module.length > 0 ? 'pointer' : 'default',
                    bgcolor: expandedRows.has(dozent.dozent_id) ? 'action.selected' : 'inherit',
                  }}
                  onClick={() => dozent.nicht_geplante_module.length > 0 && toggleRow(dozent.dozent_id)}
                >
                  <TableCell>
                    {dozent.nicht_geplante_module.length > 0 && (
                      <IconButton size="small">
                        {expandedRows.has(dozent.dozent_id) ? <ExpandLess /> : <ExpandMore />}
                      </IconButton>
                    )}
                  </TableCell>
                  <TableCell>
                    <Box>
                      <Typography variant="body2" fontWeight={500}>
                        {dozent.name}
                      </Typography>
                      {dozent.email && (
                        <Typography variant="caption" color="text.secondary">
                          {dozent.email}
                        </Typography>
                      )}
                    </Box>
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="body2">
                      {dozent.anzahl_geplant} / {dozent.anzahl_zu_planen}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <LinearProgress
                        variant="determinate"
                        value={dozent.prozent_geplant}
                        color={getProgressColor(dozent.prozent_geplant)}
                        sx={{ flexGrow: 1, height: 8, borderRadius: 4 }}
                      />
                      <Typography variant="body2" fontWeight={500} sx={{ minWidth: 45 }}>
                        {dozent.prozent_geplant.toFixed(0)}%
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell align="center">
                    <Tooltip title={dozent.status}>
                      <Chip
                        icon={getStatusIcon(dozent.status) || undefined}
                        label={dozent.status}
                        color={getStatusColor(dozent.status)}
                        size="small"
                        variant="outlined"
                      />
                    </Tooltip>
                  </TableCell>
                </TableRow>

                {/* Erweiterte Zeile: Nicht geplante Module */}
                {dozent.nicht_geplante_module.length > 0 && (
                  <TableRow>
                    <TableCell colSpan={5} sx={{ py: 0 }}>
                      <Collapse in={expandedRows.has(dozent.dozent_id)} timeout="auto" unmountOnExit>
                        <Box sx={{ py: 2, px: 4, bgcolor: 'grey.50' }}>
                          <Typography variant="subtitle2" color="error.main" gutterBottom>
                            Nicht geplante Module ({dozent.anzahl_offen}):
                          </Typography>
                          <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                            {dozent.nicht_geplante_module.map((modul) => (
                              <Chip
                                key={modul.id}
                                label={`${modul.kuerzel} - ${modul.bezeichnung}`}
                                size="small"
                                variant="outlined"
                                color="error"
                                sx={{ mb: 1 }}
                              />
                            ))}
                          </Stack>
                        </Box>
                      </Collapse>
                    </TableCell>
                  </TableRow>
                )}
              </React.Fragment>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {filteredDozenten.length === 0 && (
        <Box sx={{ py: 4, textAlign: 'center' }}>
          <Typography color="text.secondary">
            Keine Dozenten gefunden mit den gewählten Filtern.
          </Typography>
        </Box>
      )}
    </Paper>
  );
};

export default DozentenPlanungsfortschritt;
