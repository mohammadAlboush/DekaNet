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
  IconButton,
  Chip,
  Button,
  Tooltip,
  Alert,
} from '@mui/material';
import {
  Edit,
  Delete,
  Add,
  School,
  Group,
  MeetingRoom,
} from '@mui/icons-material';
import { TemplateModul } from '../../services/templateService';
import TemplateModulDialog from './TemplateModulDialog';
import templateService from '../../services/templateService';
import { useToastStore } from '../common/Toast';
import { createContextLogger } from '../../utils/logger';

const log = createContextLogger('TemplateModulList');

interface TemplateModulListProps {
  templateId: number;
  module: TemplateModul[];
  onModuleChange: () => void;
  readOnly?: boolean;
}

/**
 * TemplateModulList
 *
 * Zeigt eine Tabelle mit allen Modulen eines Templates.
 * Ermöglicht Hinzufügen, Bearbeiten und Löschen von Modulen.
 */
const TemplateModulList: React.FC<TemplateModulListProps> = ({
  templateId,
  module,
  onModuleChange,
  readOnly = false,
}) => {
  const showToast = useToastStore((state) => state.showToast);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingModul, setEditingModul] = useState<TemplateModul | null>(null);

  const handleAddModul = () => {
    setEditingModul(null);
    setDialogOpen(true);
  };

  const handleEditModul = (modul: TemplateModul) => {
    setEditingModul(modul);
    setDialogOpen(true);
  };

  const handleDeleteModul = async (modul: TemplateModul) => {
    if (!window.confirm(`Modul "${modul.modul?.kuerzel || modul.modul_id}" wirklich entfernen?`)) {
      return;
    }

    try {
      await templateService.removeModul(templateId, modul.id);
      showToast('Modul entfernt', 'success');
      onModuleChange();
    } catch (error: any) {
      log.error('Error removing module:', error);
      showToast(error.message || 'Fehler beim Entfernen', 'error');
    }
  };

  const handleDialogClose = () => {
    setDialogOpen(false);
    setEditingModul(null);
  };

  const handleDialogSave = () => {
    onModuleChange();
  };

  const getLehrformenText = (modul: TemplateModul): string => {
    const parts: string[] = [];
    if (modul.anzahl_vorlesungen > 0) parts.push(`${modul.anzahl_vorlesungen}V`);
    if (modul.anzahl_uebungen > 0) parts.push(`${modul.anzahl_uebungen}Ü`);
    if (modul.anzahl_praktika > 0) parts.push(`${modul.anzahl_praktika}P`);
    if (modul.anzahl_seminare > 0) parts.push(`${modul.anzahl_seminare}S`);
    return parts.join('+') || '-';
  };

  const hasRaumConfig = (modul: TemplateModul): boolean => {
    return !!(modul.raum_vorlesung || modul.raum_uebung || modul.raum_praktikum || modul.raum_seminar);
  };

  const getRaumInfo = (modul: TemplateModul): string => {
    const rooms: string[] = [];
    if (modul.raum_vorlesung) rooms.push(`V: ${modul.raum_vorlesung}`);
    if (modul.raum_uebung) rooms.push(`Ü: ${modul.raum_uebung}`);
    if (modul.raum_praktikum) rooms.push(`P: ${modul.raum_praktikum}`);
    if (modul.raum_seminar) rooms.push(`S: ${modul.raum_seminar}`);
    return rooms.join(', ') || 'Keine Raumwünsche';
  };

  return (
    <Box>
      {/* Header */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="subtitle1" fontWeight={600}>
          <School sx={{ mr: 1, verticalAlign: 'middle', fontSize: 20 }} />
          Module im Template ({module.length})
        </Typography>
        {!readOnly && (
          <Button
            variant="contained"
            size="small"
            startIcon={<Add />}
            onClick={handleAddModul}
          >
            Modul hinzufügen
          </Button>
        )}
      </Box>

      {/* Module Table */}
      {module.length > 0 ? (
        <TableContainer component={Paper} variant="outlined">
          <Table size="small">
            <TableHead>
              <TableRow sx={{ bgcolor: 'grey.50' }}>
                <TableCell><strong>Modul</strong></TableCell>
                <TableCell><strong>Bezeichnung</strong></TableCell>
                <TableCell align="center"><strong>Lehrformen</strong></TableCell>
                <TableCell align="center"><strong>Mitarbeiter</strong></TableCell>
                <TableCell align="center"><strong>Räume</strong></TableCell>
                {!readOnly && (
                  <TableCell align="right"><strong>Aktionen</strong></TableCell>
                )}
              </TableRow>
            </TableHead>
            <TableBody>
              {module.map((modul) => (
                <TableRow key={modul.id} hover>
                  <TableCell>
                    <Typography variant="body2" fontWeight={600} color="primary">
                      {modul.modul?.kuerzel || `ID: ${modul.modul_id}`}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" noWrap sx={{ maxWidth: 200 }}>
                      {modul.modul?.bezeichnung_de || '-'}
                    </Typography>
                    {modul.anmerkungen && (
                      <Typography variant="caption" color="text.secondary" display="block">
                        {modul.anmerkungen}
                      </Typography>
                    )}
                  </TableCell>
                  <TableCell align="center">
                    <Chip
                      size="small"
                      label={getLehrformenText(modul)}
                      color="primary"
                      variant="outlined"
                    />
                  </TableCell>
                  <TableCell align="center">
                    {modul.mitarbeiter_ids && modul.mitarbeiter_ids.length > 0 ? (
                      <Tooltip title={`${modul.mitarbeiter_ids.length} Mitarbeiter zugeordnet`}>
                        <Chip
                          size="small"
                          icon={<Group />}
                          label={modul.mitarbeiter_ids.length}
                          color="secondary"
                          variant="outlined"
                        />
                      </Tooltip>
                    ) : (
                      <Typography variant="caption" color="text.secondary">-</Typography>
                    )}
                  </TableCell>
                  <TableCell align="center">
                    {hasRaumConfig(modul) ? (
                      <Tooltip title={getRaumInfo(modul)}>
                        <Chip
                          size="small"
                          icon={<MeetingRoom />}
                          label="Ja"
                          color="success"
                          variant="outlined"
                        />
                      </Tooltip>
                    ) : (
                      <Typography variant="caption" color="text.secondary">-</Typography>
                    )}
                  </TableCell>
                  {!readOnly && (
                    <TableCell align="right">
                      <Tooltip title="Bearbeiten">
                        <IconButton
                          size="small"
                          onClick={() => handleEditModul(modul)}
                          color="primary"
                        >
                          <Edit fontSize="small" />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title="Entfernen">
                        <IconButton
                          size="small"
                          onClick={() => handleDeleteModul(modul)}
                          color="error"
                        >
                          <Delete fontSize="small" />
                        </IconButton>
                      </Tooltip>
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      ) : (
        <Alert severity="info">
          {readOnly
            ? 'Keine Module im Template definiert.'
            : 'Noch keine Module hinzugefügt. Klicken Sie auf "Modul hinzufügen", um Module zu konfigurieren.'
          }
        </Alert>
      )}

      {/* Modul Dialog */}
      <TemplateModulDialog
        open={dialogOpen}
        onClose={handleDialogClose}
        templateId={templateId}
        editingModul={editingModul}
        onSave={handleDialogSave}
      />
    </Box>
  );
};

export default TemplateModulList;
