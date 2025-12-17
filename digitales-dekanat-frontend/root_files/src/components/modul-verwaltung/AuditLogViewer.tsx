import React, { useState, useEffect } from 'react';
import {
  Box,
  Paper,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Grid,
  CircularProgress,
  Alert,
  Tooltip,
  InputAdornment,
  Button,
  Stack
} from '@mui/material';
import {
  History,
  Add as AddIcon,
  Delete as DeleteIcon,
  SwapHoriz,
  Search,
  Refresh,
  FilterList
} from '@mui/icons-material';
import { format } from 'date-fns';
import { de } from 'date-fns/locale';
import modulVerwaltungService, { AuditLogEntry } from '../../services/modulVerwaltungService';

const AuditLogViewer: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [logs, setLogs] = useState<AuditLogEntry[]>([]);

  // Filters
  const [modulId] = useState<number | ''>('');
  const [dozentId] = useState<number | ''>('');
  const [limit, setLimit] = useState<number>(100);
  const [searchTerm, setSearchTerm] = useState<string>('');

  // Load logs on mount
  useEffect(() => {
    loadLogs();
  }, []);

  const loadLogs = async () => {
    setLoading(true);
    setError(null);

    try {
      const response = await modulVerwaltungService.getAuditLog({
        modul_id: modulId || undefined,
        dozent_id: dozentId || undefined,
        limit: limit
      });

      if (response.success) {
        setLogs(response.data || []);
      } else {
        setError(response.message || 'Fehler beim Laden des Audit Logs');
      }
    } catch (error: any) {
      setError(error.message || 'Ein Fehler ist aufgetreten');
    } finally {
      setLoading(false);
    }
  };

  // Filter logs by search term
  const filteredLogs = React.useMemo(() => {
    if (!searchTerm) return logs;

    const term = searchTerm.toLowerCase();
    return logs.filter(log =>
      log.modul?.kuerzel.toLowerCase().includes(term) ||
      log.modul?.bezeichnung_de.toLowerCase().includes(term) ||
      log.alter_dozent?.name.toLowerCase().includes(term) ||
      log.neuer_dozent?.name.toLowerCase().includes(term) ||
      log.geaendert_von?.name.toLowerCase().includes(term)
    );
  }, [logs, searchTerm]);

  // Render action icon
  const renderActionIcon = (aktion: string) => {
    switch (aktion) {
      case 'dozent_hinzugefuegt':
        return <AddIcon color="success" />;
      case 'dozent_entfernt':
        return <DeleteIcon color="error" />;
      case 'dozent_ersetzt':
        return <SwapHoriz color="primary" />;
      default:
        return <History />;
    }
  };

  // Render action text
  const renderActionText = (aktion: string) => {
    switch (aktion) {
      case 'dozent_hinzugefuegt':
        return 'Hinzugefügt';
      case 'dozent_entfernt':
        return 'Entfernt';
      case 'dozent_ersetzt':
        return 'Ersetzt';
      default:
        return aktion;
    }
  };

  // Render action chip
  const renderActionChip = (aktion: string) => {
    const colors: Record<string, any> = {
      dozent_hinzugefuegt: 'success',
      dozent_entfernt: 'error',
      dozent_ersetzt: 'primary'
    };

    return (
      <Chip
        label={renderActionText(aktion)}
        size="small"
        color={colors[aktion] || 'default'}
        icon={renderActionIcon(aktion)}
      />
    );
  };

  // Format date
  const formatDate = (dateString: string) => {
    try {
      const date = new Date(dateString);
      return format(date, 'dd.MM.yyyy HH:mm', { locale: de });
    } catch {
      return dateString;
    }
  };

  return (
    <Box>
      {/* Filters */}
      <Paper elevation={2} sx={{ p: 3, mb: 3 }}>
        <Grid container spacing={2} alignItems="center">
          <Grid item xs={12} md={4}>
            <TextField
              fullWidth
              variant="outlined"
              placeholder="Suche in Audit Log..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              InputProps={{
                startAdornment: (
                  <InputAdornment position="start">
                    <Search />
                  </InputAdornment>
                )
              }}
            />
          </Grid>

          <Grid item xs={12} md={2}>
            <FormControl fullWidth>
              <InputLabel>Limit</InputLabel>
              <Select
                value={limit}
                label="Limit"
                onChange={(e) => setLimit(e.target.value as number)}
              >
                <MenuItem value={50}>50 Einträge</MenuItem>
                <MenuItem value={100}>100 Einträge</MenuItem>
                <MenuItem value={200}>200 Einträge</MenuItem>
                <MenuItem value={500}>500 Einträge</MenuItem>
              </Select>
            </FormControl>
          </Grid>

          <Grid item xs={12} md={6}>
            <Stack direction="row" spacing={1} justifyContent="flex-end">
              <Button
                variant="outlined"
                startIcon={<FilterList />}
                onClick={loadLogs}
              >
                Filter anwenden
              </Button>
              <Tooltip title="Aktualisieren">
                <IconButton onClick={loadLogs} color="primary">
                  <Refresh />
                </IconButton>
              </Tooltip>
            </Stack>
          </Grid>
        </Grid>
      </Paper>

      {/* Error */}
      {error && (
        <Alert severity="error" sx={{ mb: 2 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      {/* Table */}
      <Paper elevation={2}>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell><strong>Zeitstempel</strong></TableCell>
                <TableCell><strong>Aktion</strong></TableCell>
                <TableCell><strong>Modul</strong></TableCell>
                <TableCell><strong>Alter Dozent</strong></TableCell>
                <TableCell><strong>Neuer Dozent</strong></TableCell>
                <TableCell><strong>Rolle</strong></TableCell>
                <TableCell><strong>Geändert von</strong></TableCell>
                <TableCell><strong>Bemerkung</strong></TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {loading ? (
                <TableRow>
                  <TableCell colSpan={8} align="center">
                    <Box py={4}>
                      <CircularProgress />
                    </Box>
                  </TableCell>
                </TableRow>
              ) : filteredLogs.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} align="center">
                    <Box py={4}>
                      <History sx={{ fontSize: 48, color: 'text.secondary', mb: 2 }} />
                      <Typography variant="body2" color="text.secondary">
                        Keine Audit Log Einträge gefunden
                      </Typography>
                    </Box>
                  </TableCell>
                </TableRow>
              ) : (
                filteredLogs.map((log) => (
                  <TableRow key={log.id} hover>
                    <TableCell>
                      <Typography variant="body2">
                        {formatDate(log.created_at)}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      {renderActionChip(log.aktion)}
                    </TableCell>
                    <TableCell>
                      {log.modul ? (
                        <Box>
                          <Typography variant="body2" fontWeight="bold">
                            {log.modul.kuerzel}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {log.modul.bezeichnung_de}
                          </Typography>
                        </Box>
                      ) : (
                        <Typography variant="caption" color="text.secondary">
                          N/A
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      {log.alter_dozent ? (
                        <Box>
                          <Typography variant="body2">
                            {log.alter_dozent.name}
                          </Typography>
                          {log.alte_rolle && (
                            <Typography variant="caption" color="text.secondary">
                              ({log.alte_rolle})
                            </Typography>
                          )}
                        </Box>
                      ) : (
                        <Typography variant="caption" color="text.secondary">
                          -
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      {log.neuer_dozent ? (
                        <Box>
                          <Typography variant="body2">
                            {log.neuer_dozent.name}
                          </Typography>
                          {log.neue_rolle && (
                            <Typography variant="caption" color="text.secondary">
                              ({log.neue_rolle})
                            </Typography>
                          )}
                        </Box>
                      ) : (
                        <Typography variant="caption" color="text.secondary">
                          -
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      {log.neue_rolle || log.alte_rolle || '-'}
                    </TableCell>
                    <TableCell>
                      {log.geaendert_von ? (
                        <Typography variant="body2">
                          {log.geaendert_von.name}
                        </Typography>
                      ) : (
                        <Typography variant="caption" color="text.secondary">
                          System
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      {log.bemerkung ? (
                        <Tooltip title={log.bemerkung}>
                          <Typography
                            variant="caption"
                            sx={{
                              maxWidth: 200,
                              overflow: 'hidden',
                              textOverflow: 'ellipsis',
                              whiteSpace: 'nowrap',
                              display: 'block'
                            }}
                          >
                            {log.bemerkung}
                          </Typography>
                        </Tooltip>
                      ) : (
                        <Typography variant="caption" color="text.secondary">
                          -
                        </Typography>
                      )}
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>

        {/* Summary */}
        <Box sx={{ p: 2, borderTop: 1, borderColor: 'divider' }}>
          <Typography variant="caption" color="text.secondary">
            {filteredLogs.length} von {logs.length} Einträgen
          </Typography>
        </Box>
      </Paper>
    </Box>
  );
};

export default AuditLogViewer;
