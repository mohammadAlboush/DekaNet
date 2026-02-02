import React, { useState, useEffect, useMemo } from 'react';
import {
  Container, Paper, Typography, Box, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Chip, TextField,
  InputAdornment, CircularProgress, Alert, Tabs, Tab,
  Card, CardContent, Stack, TableSortLabel,
  FormControl, InputLabel, Select, MenuItem, SelectChangeEvent
} from '@mui/material';
import { Search, MenuBook } from '@mui/icons-material';
import { getModulhandbuecher, ModulhandbuchStudiengang, ModulhandbuchModul, ModulhandbucherResponse } from '../services/dashboardService';

interface TabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props;
  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && <Box sx={{ py: 2 }}>{children}</Box>}
    </div>
  );
}

const kategorieColors: Record<string, 'success' | 'warning' | 'info' | 'secondary' | 'error' | 'default'> = {
  pflicht: 'success',
  wahlpflicht: 'warning',
  wahlbereich: 'info',
  projekt: 'secondary',
  thesis: 'error',
};

const kategorieLabels: Record<string, string> = {
  pflicht: 'Pflicht',
  wahlpflicht: 'Wahlpflicht',
  wahlbereich: 'Wahlbereich',
  projekt: 'Projekt',
  thesis: 'Thesis',
  unbekannt: 'Unbekannt',
};

type SortField = 'kuerzel' | 'bezeichnung_de' | 'leistungspunkte' | 'sws_gesamt' | 'semester' | 'kategorie' | 'turnus' | 'verantwortlicher';
type SortDirection = 'asc' | 'desc';

function normalizeTurnus(turnus: string | null): string {
  if (!turnus) return 'Unbekannt';
  const t = turnus.toLowerCase();
  if (t.includes('wintersemester') && t.includes('sommersemester')) return 'Jedes Semester';
  if (t.includes('jedes semester')) return 'Jedes Semester';
  if (t.includes('wintersemester') || t.includes('winter')) return 'Wintersemester';
  if (t.includes('sommersemester') || t.includes('sommer')) return 'Sommersemester';
  if (t.includes('unregelmäßig') || t.includes('unregelm') || t.includes('bedarf')) return 'Bei Bedarf';
  return turnus;
}

function getTurnusColor(turnus: string | null): 'info' | 'warning' | 'success' | 'default' | 'secondary' {
  const normalized = normalizeTurnus(turnus);
  if (normalized === 'Wintersemester') return 'info';
  if (normalized === 'Sommersemester') return 'warning';
  if (normalized === 'Jedes Semester') return 'success';
  if (normalized === 'Bei Bedarf') return 'secondary';
  return 'default';
}

const ModulhandbucherPage: React.FC = () => {
  const [data, setData] = useState<ModulhandbucherResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [tabIndex, setTabIndex] = useState(0);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterKategorie, setFilterKategorie] = useState<string>('alle');
  const [filterTurnus, setFilterTurnus] = useState<string>('alle');
  const [sortField, setSortField] = useState<SortField>('kuerzel');
  const [sortDirection, setSortDirection] = useState<SortDirection>('asc');

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await getModulhandbuecher();
        if (response.data) {
          setData(response.data);
        }
      } catch (err) {
        setError('Fehler beim Laden der Modulhandbücher.');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  const handleSort = (field: SortField) => {
    if (sortField === field) {
      setSortDirection(prev => prev === 'asc' ? 'desc' : 'asc');
    } else {
      setSortField(field);
      setSortDirection('asc');
    }
  };

  const filterAndSort = useMemo(() => {
    return (module: ModulhandbuchModul[]): ModulhandbuchModul[] => {
      let filtered = module;

      // Text search
      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase();
        filtered = filtered.filter(m =>
          m.kuerzel.toLowerCase().includes(q) ||
          m.bezeichnung_de.toLowerCase().includes(q) ||
          (m.verantwortlicher && m.verantwortlicher.toLowerCase().includes(q)) ||
          (m.kategorie && kategorieLabels[m.kategorie]?.toLowerCase().includes(q))
        );
      }

      // Kategorie filter
      if (filterKategorie !== 'alle') {
        filtered = filtered.filter(m => (m.kategorie || 'unbekannt') === filterKategorie);
      }

      // Turnus filter
      if (filterTurnus !== 'alle') {
        filtered = filtered.filter(m => {
          const normalized = normalizeTurnus(m.turnus);
          return normalized === filterTurnus;
        });
      }

      // Sort
      const sorted = [...filtered].sort((a, b) => {
        const dir = sortDirection === 'asc' ? 1 : -1;
        const valA = a[sortField];
        const valB = b[sortField];

        if (valA == null && valB == null) return 0;
        if (valA == null) return 1;
        if (valB == null) return -1;

        if (typeof valA === 'number' && typeof valB === 'number') {
          return (valA - valB) * dir;
        }

        return String(valA).localeCompare(String(valB), 'de') * dir;
      });

      return sorted;
    };
  }, [searchQuery, filterKategorie, filterTurnus, sortField, sortDirection]);

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '50vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  if (error || !data) {
    return (
      <Container maxWidth="lg" sx={{ mt: 2 }}>
        <Alert severity="error">{error || 'Keine Daten verfügbar.'}</Alert>
      </Container>
    );
  }

  const ohneZuordnung = data.nicht_zugeordnet?.module || [];

  const renderStatCards = () => (
    <Stack direction="row" spacing={2} sx={{ mb: 3, flexWrap: 'wrap', gap: 1 }}>
      <Card sx={{ minWidth: 140 }}>
        <CardContent sx={{ py: 1.5, '&:last-child': { pb: 1.5 } }}>
          <Typography variant="caption" color="text.secondary">Module gesamt</Typography>
          <Typography variant="h5" fontWeight={600}>{data.gesamt_statistik.alle_module}</Typography>
        </CardContent>
      </Card>
      <Card sx={{ minWidth: 140 }}>
        <CardContent sx={{ py: 1.5, '&:last-child': { pb: 1.5 } }}>
          <Typography variant="caption" color="text.secondary">Zugeordnet</Typography>
          <Typography variant="h5" fontWeight={600} color="success.main">{data.gesamt_statistik.zugeordnet}</Typography>
        </CardContent>
      </Card>
      {data.gesamt_statistik.nicht_zugeordnet > 0 && (
        <Card sx={{ minWidth: 140 }}>
          <CardContent sx={{ py: 1.5, '&:last-child': { pb: 1.5 } }}>
            <Typography variant="caption" color="text.secondary">Ohne Zuordnung</Typography>
            <Typography variant="h5" fontWeight={600} color="warning.main">{data.gesamt_statistik.nicht_zugeordnet}</Typography>
          </CardContent>
        </Card>
      )}
      <Card sx={{ minWidth: 140 }}>
        <CardContent sx={{ py: 1.5, '&:last-child': { pb: 1.5 } }}>
          <Typography variant="caption" color="text.secondary">Studiengänge</Typography>
          <Typography variant="h5" fontWeight={600}>{data.gesamt_statistik.studiengaenge}</Typography>
        </CardContent>
      </Card>
    </Stack>
  );

  const renderStudiengangStats = (sg: ModulhandbuchStudiengang) => (
    <Stack direction="row" spacing={1} sx={{ mb: 2, flexWrap: 'wrap', gap: 0.5 }}>
      <Chip label={`${sg.statistik.anzahl_module} Module`} size="small" />
      <Chip label={`${sg.statistik.ects_summe} ECTS`} size="small" variant="outlined" />
      {Object.entries(sg.statistik.kategorien).map(([kat, count]) => (
        <Chip
          key={kat}
          label={`${kategorieLabels[kat] || kat}: ${count}`}
          size="small"
          color={kategorieColors[kat] || 'default'}
          variant="outlined"
        />
      ))}
      {sg.statistik.turnus_verteilung && Object.entries(sg.statistik.turnus_verteilung)
        .filter(([key]) => key !== 'unbekannt')
        .map(([key, count]) => {
          const labels: Record<string, string> = {
            wintersemester: 'WS',
            sommersemester: 'SS',
            jedes_semester: 'WS+SS',
            sonstige: 'Sonstige',
          };
          return (
            <Chip
              key={`turnus-${key}`}
              label={`${labels[key] || key}: ${count}`}
              size="small"
              variant="outlined"
              color={key === 'wintersemester' ? 'info' : key === 'sommersemester' ? 'warning' : key === 'jedes_semester' ? 'success' : 'default'}
            />
          );
        })}
    </Stack>
  );

  const renderFilters = () => (
    <Stack direction="row" spacing={2} sx={{ mb: 2, flexWrap: 'wrap', gap: 1, alignItems: 'center' }}>
      <TextField
        size="small"
        placeholder="Module suchen (Kürzel, Name, Verantwortlicher...)"
        value={searchQuery}
        onChange={(e) => setSearchQuery(e.target.value)}
        sx={{ width: 350 }}
        InputProps={{
          startAdornment: (
            <InputAdornment position="start"><Search /></InputAdornment>
          ),
        }}
      />
      <FormControl size="small" sx={{ minWidth: 160 }}>
        <InputLabel>Kategorie</InputLabel>
        <Select
          value={filterKategorie}
          label="Kategorie"
          onChange={(e: SelectChangeEvent) => setFilterKategorie(e.target.value)}
        >
          <MenuItem value="alle">Alle Kategorien</MenuItem>
          <MenuItem value="pflicht">Pflicht</MenuItem>
          <MenuItem value="wahlpflicht">Wahlpflicht</MenuItem>
          <MenuItem value="wahlbereich">Wahlbereich</MenuItem>
          <MenuItem value="projekt">Projekt</MenuItem>
          <MenuItem value="thesis">Thesis</MenuItem>
          <MenuItem value="unbekannt">Unbekannt</MenuItem>
        </Select>
      </FormControl>
      <FormControl size="small" sx={{ minWidth: 180 }}>
        <InputLabel>Turnus</InputLabel>
        <Select
          value={filterTurnus}
          label="Turnus"
          onChange={(e: SelectChangeEvent) => setFilterTurnus(e.target.value)}
        >
          <MenuItem value="alle">Alle Turnus</MenuItem>
          <MenuItem value="Wintersemester">Wintersemester</MenuItem>
          <MenuItem value="Sommersemester">Sommersemester</MenuItem>
          <MenuItem value="Jedes Semester">Jedes Semester</MenuItem>
          <MenuItem value="Bei Bedarf">Bei Bedarf</MenuItem>
          <MenuItem value="Unbekannt">Unbekannt</MenuItem>
        </Select>
      </FormControl>
    </Stack>
  );

  const sortableHeader = (field: SortField, label: string, align?: 'center' | 'left') => (
    <TableCell align={align} sx={{ fontWeight: 600 }}>
      <TableSortLabel
        active={sortField === field}
        direction={sortField === field ? sortDirection : 'asc'}
        onClick={() => handleSort(field)}
      >
        {label}
      </TableSortLabel>
    </TableCell>
  );

  const renderModuleTable = (module: ModulhandbuchModul[]) => {
    const processed = filterAndSort(module);
    if (processed.length === 0) {
      return <Alert severity="info" sx={{ mt: 1 }}>Keine Module gefunden.</Alert>;
    }
    return (
      <>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
          {processed.length} von {module.length} Module{processed.length !== module.length ? ' (gefiltert)' : ''}
        </Typography>
        <TableContainer component={Paper} variant="outlined">
          <Table size="small">
            <TableHead>
              <TableRow>
                {sortableHeader('kuerzel', 'Kürzel')}
                {sortableHeader('bezeichnung_de', 'Bezeichnung')}
                {sortableHeader('leistungspunkte', 'LP', 'center')}
                {sortableHeader('sws_gesamt', 'SWS', 'center')}
                {sortableHeader('semester', 'Sem.', 'center')}
                {sortableHeader('kategorie', 'Kategorie')}
                {sortableHeader('turnus', 'Turnus')}
                {sortableHeader('verantwortlicher', 'Verantwortlich')}
              </TableRow>
            </TableHead>
            <TableBody>
              {processed.map((modul) => (
                <TableRow key={modul.id} hover>
                  <TableCell>
                    <Typography variant="body2" fontWeight={600}>{modul.kuerzel}</Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">{modul.bezeichnung_de}</Typography>
                    {modul.bezeichnung_en && (
                      <Typography variant="caption" color="text.secondary">{modul.bezeichnung_en}</Typography>
                    )}
                  </TableCell>
                  <TableCell align="center">{modul.leistungspunkte || '–'}</TableCell>
                  <TableCell align="center">{modul.sws_gesamt || '–'}</TableCell>
                  <TableCell align="center">{modul.semester || '–'}</TableCell>
                  <TableCell>
                    {modul.kategorie ? (
                      <Chip
                        label={kategorieLabels[modul.kategorie] || modul.kategorie}
                        size="small"
                        color={kategorieColors[modul.kategorie] || 'default'}
                      />
                    ) : (
                      <Typography variant="caption" color="text.secondary">–</Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    {modul.turnus ? (
                      <Chip
                        label={normalizeTurnus(modul.turnus)}
                        size="small"
                        color={getTurnusColor(modul.turnus)}
                        variant="outlined"
                      />
                    ) : (
                      <Typography variant="caption" color="text.secondary">–</Typography>
                    )}
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">{modul.verantwortlicher || '–'}</Typography>
                    {modul.lehrpersonen && modul.lehrpersonen.length > 0 && (
                      <Typography variant="caption" color="text.secondary" display="block">
                        + {modul.lehrpersonen.join(', ')}
                      </Typography>
                    )}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
      </>
    );
  };

  return (
    <Container maxWidth="xl" sx={{ mt: 1 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
        <MenuBook color="primary" />
        <Typography variant="h5" fontWeight={600}>Modulhandbücher</Typography>
        <Typography variant="body2" color="text.secondary" sx={{ ml: 1 }}>
          PO 2023
        </Typography>
      </Box>

      {renderStatCards()}
      {renderFilters()}

      <Paper sx={{ width: '100%' }}>
        <Tabs
          value={tabIndex}
          onChange={(_, newVal) => setTabIndex(newVal)}
          variant="scrollable"
          scrollButtons="auto"
          sx={{ borderBottom: 1, borderColor: 'divider' }}
        >
          {data.studiengaenge.map((sg) => (
            <Tab
              key={sg.id}
              label={
                <Box sx={{ textAlign: 'center' }}>
                  <Typography variant="body2" fontWeight={600}>
                    {sg.kuerzel}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {sg.abschluss} ({sg.statistik.anzahl_module})
                  </Typography>
                </Box>
              }
            />
          ))}
          {ohneZuordnung.length > 0 && (
            <Tab label={`Ohne Zuordnung (${ohneZuordnung.length})`} />
          )}
        </Tabs>

        {data.studiengaenge.map((sg, idx) => (
          <TabPanel key={sg.id} value={tabIndex} index={idx}>
            <Box sx={{ px: 2 }}>
              <Typography variant="h6" gutterBottom>
                {sg.bezeichnung} ({sg.kuerzel})
                {sg.abschluss && <Typography component="span" variant="body2" color="text.secondary"> – {sg.abschluss}</Typography>}
              </Typography>
              {sg.ects_gesamt && (
                <Typography variant="body2" color="text.secondary" gutterBottom>
                  Regelstudienzeit: {sg.regelstudienzeit || '–'} Semester | {sg.ects_gesamt} ECTS
                </Typography>
              )}
              {renderStudiengangStats(sg)}
              {renderModuleTable(sg.module)}
            </Box>
          </TabPanel>
        ))}

        {ohneZuordnung.length > 0 && (
          <TabPanel value={tabIndex} index={data.studiengaenge.length}>
            <Box sx={{ px: 2 }}>
              <Typography variant="h6" gutterBottom>Module ohne Studiengang-Zuordnung</Typography>
              <Alert severity="warning" sx={{ mb: 2 }}>
                Diese {ohneZuordnung.length} Module sind keinem Studiengang zugeordnet.
              </Alert>
              {renderModuleTable(ohneZuordnung)}
            </Box>
          </TabPanel>
        )}
      </Paper>
    </Container>
  );
};

export default ModulhandbucherPage;
