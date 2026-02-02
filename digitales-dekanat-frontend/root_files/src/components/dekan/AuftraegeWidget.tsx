import React, { useEffect, useState } from 'react';
import {
  Paper,
  Typography,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  Button,
  CircularProgress,
  Alert,
  Tooltip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from '@mui/material';
import {
  CheckCircle,
  Cancel,
  Assignment,
  Refresh,
  Settings,
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import auftragService from '../../services/auftragService';
import { SemesterAuftrag, Auftrag } from '../../types/auftrag.types';
import { useToastStore } from '../common/Toast';
import useAuftragStore from '../../store/auftragStore';
import { createContextLogger } from '../../utils/logger';
import { getErrorMessage } from '../../utils/errorUtils';

const log = createContextLogger('AuftraegeWidget');

interface AuftraegeWidgetProps {
  semesterId: number;
  semesterBezeichnung: string;
}

/**
 * Aufträge-Widget für Dekan-Dashboard
 * ====================================
 * Zeigt Semesteraufträge an und ermöglicht Genehmigung/Ablehnung
 *
 * Features:
 * - Liste aller beantragten Aufträge
 * - Genehmigen/Ablehnen direkt im Dashboard
 * - Statistik (Gesamt, Beantragt, Genehmigt, Abgelehnt)
 * - Auto-Refresh alle 30 Sekunden
 * - Synchronisation mit Planung
 */
const AuftraegeWidget: React.FC<AuftraegeWidgetProps> = ({
  semesterId,
  semesterBezeichnung,
}) => {
  const navigate = useNavigate();
  const showToast = useToastStore((state) => state.showToast);

  // Use Auftrag Store for synchronization
  const {
    semesterAuftraege: storeAuftraege,
    isLoading: storeLoading,
    loadAuftraege,
    triggerRefresh,
  } = useAuftragStore();

  const [loading, setLoading] = useState(false);
  const [alleAuftraege, setAlleAuftraege] = useState<Auftrag[]>([]);
  const [selectedAuftrag, setSelectedAuftrag] = useState<SemesterAuftrag | null>(null);
  const [ablehnungDialog, setAblehnungDialog] = useState(false);
  const [ablehnungsgrund, setAblehnungsgrund] = useState('');

  // Get auftraege from store
  const semesterAuftraege = storeAuftraege[semesterId] || [];

  useEffect(() => {
    loadData();

    // Auto-refresh alle 30 Sekunden
    const interval = setInterval(loadData, 30000);
    return () => clearInterval(interval);
  }, [semesterId]);

  const loadData = async () => {
    try {
      log.debug(' Loading data for semester:', semesterId);
      setLoading(true);

      // Lade alle Aufträge (für Mapping)
      const auftraege = await auftragService.getAlleAuftraege(true);
      setAlleAuftraege(auftraege);

      // Lade Semester-Aufträge über Store (für Synchronisation)
      await loadAuftraege(semesterId);

      log.debug(' Loaded:', {
        auftraege: auftraege.length,
      });
    } catch (error) {
      log.error(' Error loading data:', error);
      showToast('Fehler beim Laden der Aufträge', 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleGenehmigen = async (auftragId: number) => {
    if (!window.confirm('Möchten Sie diesen Auftrag wirklich genehmigen?')) {
      return;
    }

    try {
      setLoading(true);
      await auftragService.genehmigAuftrag(auftragId);
      showToast('Auftrag genehmigt', 'success');

      // Trigger Store refresh for synchronization
      await triggerRefresh(semesterId);
    } catch (error: unknown) {
      log.error(' Error approving:', { error });
      showToast(getErrorMessage(error, 'Fehler beim Genehmigen'), 'error');
    } finally {
      setLoading(false);
    }
  };

  const handleAblehnenClick = (auftrag: SemesterAuftrag) => {
    setSelectedAuftrag(auftrag);
    setAblehnungsgrund('');
    setAblehnungDialog(true);
  };

  const handleAblehnenConfirm = async () => {
    if (!selectedAuftrag) return;

    if (!ablehnungsgrund.trim()) {
      showToast('Bitte geben Sie einen Ablehnungsgrund an', 'warning');
      return;
    }

    try {
      setLoading(true);
      await auftragService.lehneAuftragAb(selectedAuftrag.id, ablehnungsgrund);
      showToast('Auftrag abgelehnt', 'success');
      setAblehnungDialog(false);
      setSelectedAuftrag(null);
      setAblehnungsgrund('');

      // Trigger Store refresh for synchronization
      await triggerRefresh(semesterId);
    } catch (error: unknown) {
      log.error(' Error rejecting:', { error });
      showToast(getErrorMessage(error, 'Fehler beim Ablehnen'), 'error');
    } finally {
      setLoading(false);
    }
  };

  const getStatusChip = (status: string) => {
    const config: Record<string, { label: string; color: 'default' | 'warning' | 'success' | 'error' }> = {
      beantragt: { label: 'Beantragt', color: 'warning' },
      genehmigt: { label: 'Genehmigt', color: 'success' },
      abgelehnt: { label: 'Abgelehnt', color: 'error' },
    };

    const { label, color } = config[status] || { label: status, color: 'default' };
    return <Chip label={label} color={color} size="small" />;
  };

  const getAuftragName = (auftragId: number): string => {
    const auftrag = alleAuftraege.find(a => a.id === auftragId);
    return auftrag?.name || `Auftrag #${auftragId}`;
  };

  const stats = {
    gesamt: semesterAuftraege.length,
    beantragt: semesterAuftraege.filter(a => a.status === 'beantragt').length,
    genehmigt: semesterAuftraege.filter(a => a.status === 'genehmigt').length,
    abgelehnt: semesterAuftraege.filter(a => a.status === 'abgelehnt').length,
    gesamt_sws: semesterAuftraege
      .filter(a => a.status === 'genehmigt')
      .reduce((sum, a) => sum + a.sws, 0),
  };

  const isLoading = loading || storeLoading;

  if (isLoading && semesterAuftraege.length === 0) {
    return (
      <Paper sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: 200 }}>
          <CircularProgress />
        </Box>
      </Paper>
    );
  }

  return (
    <>
      <Paper sx={{ p: 3 }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
          <Typography variant="h6" fontWeight={600}>
            📋 Semesteraufträge ({semesterBezeichnung})
          </Typography>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <Tooltip title="Aufträge verwalten (Master-Liste)">
              <IconButton onClick={() => navigate('/dekan/auftraege')} color="primary">
                <Settings />
              </IconButton>
            </Tooltip>
            <Tooltip title="Aktualisieren">
              <IconButton onClick={loadData} disabled={isLoading}>
                <Refresh />
              </IconButton>
            </Tooltip>
          </Box>
        </Box>

        {/* Statistik */}
        <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
          <Chip
            label={`Gesamt: ${stats.gesamt}`}
            color="primary"
            variant="outlined"
          />
          <Chip
            label={`Beantragt: ${stats.beantragt}`}
            color="warning"
            variant={stats.beantragt > 0 ? "filled" : "outlined"}
          />
          <Chip
            label={`Genehmigt: ${stats.genehmigt}`}
            color="success"
            variant="outlined"
          />
          <Chip
            label={`Abgelehnt: ${stats.abgelehnt}`}
            color="error"
            variant="outlined"
          />
          <Chip
            label={`Gesamt SWS: ${stats.gesamt_sws.toFixed(1)}`}
            color="info"
            variant="outlined"
          />
        </Box>

        {/* Warnung bei beantragten Aufträgen */}
        {stats.beantragt > 0 && (
          <Alert severity="warning" sx={{ mb: 2 }}>
            <Typography variant="subtitle2">
              ⚠️ {stats.beantragt} Auftrag(e) warten auf Ihre Genehmigung
            </Typography>
          </Alert>
        )}

        {/* Tabelle */}
        {semesterAuftraege.length === 0 ? (
          <Box sx={{ textAlign: 'center', py: 4 }}>
            <Assignment sx={{ fontSize: 64, color: 'text.disabled', mb: 2 }} />
            <Typography variant="h6" color="text.secondary" gutterBottom>
              Keine Aufträge vorhanden
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Sobald Dozenten Aufträge beantragen, erscheinen sie hier.
            </Typography>
          </Box>
        ) : (
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell><strong>Auftrag</strong></TableCell>
                  <TableCell><strong>Dozent</strong></TableCell>
                  <TableCell align="center"><strong>SWS</strong></TableCell>
                  <TableCell><strong>Status</strong></TableCell>
                  <TableCell><strong>Anmerkung</strong></TableCell>
                  <TableCell align="center"><strong>Aktionen</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {semesterAuftraege.map((auftrag) => (
                  <TableRow
                    key={auftrag.id}
                    sx={{
                      bgcolor: auftrag.status === 'beantragt' ? 'warning.lighter' : 'inherit',
                    }}
                  >
                    <TableCell>
                      <Typography variant="body2" fontWeight={500}>
                        {auftrag.auftrag?.name || getAuftragName(auftrag.auftrag_id)}
                      </Typography>
                      {auftrag.auftrag?.beschreibung && (
                        <Typography variant="caption" color="text.secondary">
                          {auftrag.auftrag.beschreibung}
                        </Typography>
                      )}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {auftrag.dozent?.name || `Dozent #${auftrag.dozent_id}`}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Chip
                        label={auftrag.sws.toFixed(1)}
                        size="small"
                        color="primary"
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell>
                      {getStatusChip(auftrag.status)}
                    </TableCell>
                    <TableCell>
                      <Typography variant="caption" color="text.secondary">
                        {auftrag.anmerkung || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Box sx={{ display: 'flex', gap: 0.5, justifyContent: 'center' }}>
                        {auftrag.status === 'beantragt' && (
                          <>
                            <Tooltip title="Genehmigen">
                              <IconButton
                                size="small"
                                color="success"
                                onClick={() => handleGenehmigen(auftrag.id)}
                              >
                                <CheckCircle />
                              </IconButton>
                            </Tooltip>
                            <Tooltip title="Ablehnen">
                              <IconButton
                                size="small"
                                color="error"
                                onClick={() => handleAblehnenClick(auftrag)}
                              >
                                <Cancel />
                              </IconButton>
                            </Tooltip>
                          </>
                        )}
                        {auftrag.status !== 'beantragt' && (
                          <Typography variant="caption" color="text.secondary">
                            -
                          </Typography>
                        )}
                      </Box>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        )}
      </Paper>

      {/* Ablehnungs-Dialog */}
      <Dialog
        open={ablehnungDialog}
        onClose={() => setAblehnungDialog(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Auftrag ablehnen</DialogTitle>
        <DialogContent>
          <Alert severity="warning" sx={{ mb: 2 }}>
            Der Auftrag wird abgelehnt und der Dozent kann ihn überarbeiten oder zurückziehen.
          </Alert>
          <TextField
            autoFocus
            multiline
            rows={4}
            fullWidth
            label="Ablehnungsgrund"
            placeholder="Bitte geben Sie einen Grund für die Ablehnung an..."
            value={ablehnungsgrund}
            onChange={(e) => setAblehnungsgrund(e.target.value)}
            required
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setAblehnungDialog(false)}>
            Abbrechen
          </Button>
          <Button
            onClick={handleAblehnenConfirm}
            color="error"
            variant="contained"
            disabled={!ablehnungsgrund.trim()}
          >
            Ablehnen
          </Button>
        </DialogActions>
      </Dialog>
    </>
  );
};

export default AuftraegeWidget;
