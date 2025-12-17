import React, { useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Button,
  Grid,
  Card,
  CardContent,
  Divider,
  Chip,
  Alert,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  CircularProgress,
  List,
  ListItem,
  ListItemText,
} from '@mui/material';
import {
  NavigateBefore,
  Send,
  CheckCircle,
  Warning,
  CalendarMonth,
  School,
  Schedule,
  Person,
  EventNote,
  Info,
} from '@mui/icons-material';
import { StepZusammenfassungProps } from '../../../../types/StepProps.types';
import { GeplantesModul } from '../../../../types/planung.types';

const StepZusammenfassung: React.FC<StepZusammenfassungProps> = ({ 
  data, 
  onBack, 
  onSubmit,
  planungId 
}) => {
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      await onSubmit();
    } finally {
      setSubmitting(false);
    }
  };

  const calculateTotalSWS = () => {
    return data.geplantModule?.reduce((sum, gm) => sum + (gm.sws_gesamt || 0), 0) || 0;
  };

  const calculateTotalECTS = () => {
    return data.geplantModule?.reduce((sum, gm) => sum + (gm.modul?.leistungspunkte || 0), 0) || 0;
  };

  const getLehrformenText = (gm: GeplantesModul) => {
    const parts: string[] = [];
    if (gm.anzahl_vorlesungen > 0) parts.push(`${gm.anzahl_vorlesungen}V`);
    if (gm.anzahl_uebungen > 0) parts.push(`${gm.anzahl_uebungen}Ü`);
    if (gm.anzahl_praktika > 0) parts.push(`${gm.anzahl_praktika}P`);
    if (gm.anzahl_seminare > 0) parts.push(`${gm.anzahl_seminare}S`);
    return parts.join(' + ') || 'Keine Lehrformen';
  };

  const hasValidData = () => {
    return (
      data.semesterId &&
      data.geplantModule &&
      data.geplantModule.length > 0 &&
      calculateTotalSWS() > 0
    );
  };

  return (
    <Box>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h6" gutterBottom>
          Zusammenfassung Ihrer Planung
        </Typography>
        <Typography variant="body2" color="text.secondary">
          Überprüfen Sie alle Angaben vor dem Einreichen. Nach dem Einreichen können keine Änderungen mehr vorgenommen werden.
        </Typography>
      </Box>

      {/* Validation Warning */}
      {!hasValidData() && (
        <Alert severity="error" sx={{ mb: 3 }} icon={<Warning />}>
          <Typography variant="body2" fontWeight={600} gutterBottom>
            Ihre Planung ist unvollständig
          </Typography>
          <Typography variant="body2">
            {!data.semesterId && '• Kein Semester ausgewählt'}
          </Typography>
          <Typography variant="body2">
            {(!data.geplantModule || data.geplantModule.length === 0) && '• Keine Module hinzugefügt'}
          </Typography>
          <Typography variant="body2">
            {calculateTotalSWS() === 0 && '• Gesamt-SWS ist 0'}
          </Typography>
        </Alert>
      )}

      {/* Semester Information */}
      {data.semester && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
            <CalendarMonth color="primary" />
            <Typography variant="h6">
              Semester
            </Typography>
          </Box>
          <Grid container spacing={2}>
            <Grid item xs={12} md={6}>
              <Typography variant="body2" color="text.secondary">
                Bezeichnung
              </Typography>
              <Typography variant="body1" fontWeight={500}>
                {data.semester.bezeichnung}
              </Typography>
            </Grid>
            <Grid item xs={12} md={6}>
              <Typography variant="body2" color="text.secondary">
                Kürzel
              </Typography>
              <Typography variant="body1" fontWeight={500}>
                {data.semester.kuerzel}
              </Typography>
            </Grid>
            <Grid item xs={12} md={6}>
              <Typography variant="body2" color="text.secondary">
                Zeitraum
              </Typography>
              <Typography variant="body1" fontWeight={500}>
                {new Date(data.semester.start_datum).toLocaleDateString('de-DE')} - {new Date(data.semester.ende_datum).toLocaleDateString('de-DE')}
              </Typography>
            </Grid>
            <Grid item xs={12} md={6}>
              <Box sx={{ display: 'flex', gap: 1 }}>
                {data.semester.ist_aktiv && (
                  <Chip label="Aktiv" size="small" color="success" />
                )}
                {data.semester.ist_planungsphase && (
                  <Chip label="Planungsphase" size="small" color="primary" />
                )}
              </Box>
            </Grid>
          </Grid>
        </Paper>
      )}

      {/* Module Summary */}
      {data.geplantModule && data.geplantModule.length > 0 && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
            <School color="primary" />
            <Typography variant="h6">
              Geplante Module ({data.geplantModule.length})
            </Typography>
          </Box>

          {/* Statistics Cards */}
          <Grid container spacing={2} sx={{ mb: 3 }}>
            <Grid item xs={12} md={4}>
              <Card variant="outlined">
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                    <School color="action" />
                    <Typography variant="body2" color="text.secondary">
                      Anzahl Module
                    </Typography>
                  </Box>
                  <Typography variant="h4">
                    {data.geplantModule.length}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} md={4}>
              <Card variant="outlined">
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                    <Schedule color="action" />
                    <Typography variant="body2" color="text.secondary">
                      Gesamt SWS
                    </Typography>
                  </Box>
                  <Typography variant="h4">
                    {calculateTotalSWS().toFixed(1)}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
            <Grid item xs={12} md={4}>
              <Card variant="outlined">
                <CardContent>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                    <CheckCircle color="action" />
                    <Typography variant="body2" color="text.secondary">
                      Gesamt ECTS
                    </Typography>
                  </Box>
                  <Typography variant="h4">
                    {calculateTotalECTS()}
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>

          {/* Module Table */}
          <TableContainer>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell><strong>Kürzel</strong></TableCell>
                  <TableCell><strong>Bezeichnung</strong></TableCell>
                  <TableCell align="center"><strong>Lehrformen</strong></TableCell>
                  <TableCell align="center"><strong>SWS</strong></TableCell>
                  <TableCell align="center"><strong>ECTS</strong></TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {data.geplantModule.map((gm, index) => (
                  <TableRow key={gm.id || index}>
                    <TableCell>
                      <Typography variant="body2" fontWeight={600}>
                        {gm.modul?.kuerzel}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {gm.modul?.bezeichnung_de}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Chip 
                        label={getLehrformenText(gm)} 
                        size="small"
                        color="primary"
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="center">
                      <Typography variant="body2" fontWeight={600}>
                        {gm.sws_gesamt?.toFixed(1)}
                      </Typography>
                    </TableCell>
                    <TableCell align="center">
                      <Typography variant="body2">
                        {gm.modul?.leistungspunkte}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
                {/* Total Row */}
                <TableRow sx={{ bgcolor: 'background.default' }}>
                  <TableCell colSpan={3}>
                    <Typography variant="subtitle2" fontWeight={600}>
                      Gesamt
                    </Typography>
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="subtitle2" fontWeight={600}>
                      {calculateTotalSWS().toFixed(1)} SWS
                    </Typography>
                  </TableCell>
                  <TableCell align="center">
                    <Typography variant="subtitle2" fontWeight={600}>
                      {calculateTotalECTS()} ECTS
                    </Typography>
                  </TableCell>
                </TableRow>
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>
      )}

      {/* Additional Information */}
      {(data.anmerkungen || data.raumbedarf || (data.wunschFreieTage && data.wunschFreieTage.length > 0)) && (
        <Paper sx={{ p: 3, mb: 3 }}>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
            <Info color="primary" />
            <Typography variant="h6">
              Zusätzliche Informationen
            </Typography>
          </Box>

          {data.anmerkungen && (
            <Box sx={{ mb: 2 }}>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                Anmerkungen
              </Typography>
              <Paper variant="outlined" sx={{ p: 2, bgcolor: 'background.default' }}>
                <Typography variant="body2">
                  {data.anmerkungen}
                </Typography>
              </Paper>
            </Box>
          )}

          {data.raumbedarf && (
            <Box sx={{ mb: 2 }}>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                Raumbedarf
              </Typography>
              <Paper variant="outlined" sx={{ p: 2, bgcolor: 'background.default' }}>
                <Typography variant="body2">
                  {data.raumbedarf}
                </Typography>
              </Paper>
            </Box>
          )}

          {data.wunschFreieTage && data.wunschFreieTage.length > 0 && (
            <Box>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                Wunsch-freie Tage
              </Typography>
              <Paper variant="outlined" sx={{ p: 2, bgcolor: 'background.default' }}>
                <List dense>
                  {data.wunschFreieTage.map((tag, index) => {
                    // ✅ FIX: Handle invalid or missing dates
                    let dateText = 'Datum nicht angegeben';
                    if (tag.datum) {
                      const date = new Date(tag.datum);
                      if (!isNaN(date.getTime())) {
                        dateText = date.toLocaleDateString('de-DE', {
                          weekday: 'long',
                          year: 'numeric',
                          month: 'long',
                          day: 'numeric'
                        });
                      }
                    } else if (tag.wochentag) {
                      // Falls nur Wochentag vorhanden ist
                      dateText = tag.wochentag + (tag.zeitraum ? ` (${tag.zeitraum})` : '');
                    }

                    return (
                      <ListItem key={index}>
                        <ListItemText
                          primary={dateText}
                          secondary={tag.grund || 'Kein Grund angegeben'}
                        />
                      </ListItem>
                    );
                  })}
                </List>
              </Paper>
            </Box>
          )}
        </Paper>
      )}

      {/* Planung ID Info */}
      {planungId && (
        <Alert severity="info" sx={{ mb: 3 }}>
          <Typography variant="body2">
            Planung ID: <strong>{planungId}</strong>
          </Typography>
        </Alert>
      )}

      {/* Important Notice */}
      <Alert severity="warning" sx={{ mb: 3 }} icon={<Warning />}>
        <Typography variant="body2" fontWeight={600} gutterBottom>
          Wichtiger Hinweis
        </Typography>
        <Typography variant="body2">
          Nach dem Einreichen können keine Änderungen mehr vorgenommen werden. Die Planung wird an den Dekan zur Prüfung weitergeleitet.
        </Typography>
      </Alert>

      {/* Navigation Buttons */}
      <Box sx={{ mt: 4, display: 'flex', justifyContent: 'space-between' }}>
        <Button
          startIcon={<NavigateBefore />}
          onClick={onBack}
          disabled={submitting}
        >
          Zurück
        </Button>
        <Button
          variant="contained"
          color="success"
          size="large"
          endIcon={submitting ? <CircularProgress size={20} color="inherit" /> : <Send />}
          onClick={handleSubmit}
          disabled={!hasValidData() || submitting}
        >
          {submitting ? 'Wird eingereicht...' : 'Planung jetzt einreichen'}
        </Button>
      </Box>

      {/* Help Text */}
      <Box sx={{ mt: 3, textAlign: 'center' }}>
        <Typography variant="caption" color="text.secondary">
          Bei Fragen wenden Sie sich bitte an den Dekan oder die Verwaltung.
        </Typography>
      </Box>
    </Box>
  );
};

export default StepZusammenfassung;