import React, { useState, useMemo } from 'react';
import { Container, Paper, Typography, Box, Tabs, Tab } from '@mui/material';
import { Settings, Work, AccountCircle, DeleteForever } from '@mui/icons-material';
import useAuthStore from '../store/authStore';
import AuftraegeVerwaltung from './AuftraegeVerwaltung';
import SettingsTabPanel from '../components/settings/SettingsTabPanel';
import ProfileSettings from '../components/settings/ProfileSettings';
import ResetDatabaseSettings from '../components/settings/ResetDatabaseSettings';

interface TabConfig {
  label: string;
  icon: React.ReactElement;
  component: React.ReactNode;
  roles: string[];
}

const EinstellungenPage: React.FC = () => {
  const { user } = useAuthStore();
  const [activeTab, setActiveTab] = useState(0);

  const hasRole = (roleName: string): boolean => {
    if (!user) return false;
    if (typeof user.rolle === 'string') return user.rolle === roleName;
    return user.rolle?.name === roleName;
  };

  const isDekan = hasRole('dekan');

  const allTabs: TabConfig[] = useMemo(() => [
    {
      label: 'Semesteraufträge verwalten',
      icon: <Work />,
      component: <AuftraegeVerwaltung embedded />,
      roles: ['dekan'],
    },
    {
      label: 'Datenbank zurücksetzen',
      icon: <DeleteForever />,
      component: <ResetDatabaseSettings />,
      roles: ['dekan'],
    },
    {
      label: 'Profil & Einstellungen',
      icon: <AccountCircle />,
      component: <ProfileSettings />,
      roles: ['professor', 'lehrbeauftragter'],
    },
  ], []);

  const visibleTabs = useMemo(() =>
    allTabs.filter(tab => tab.roles.some(role => hasRole(role))),
  [allTabs, user]);

  return (
    <Container maxWidth="xl">
      {/* Header */}
      <Box sx={{ mb: 3 }}>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <Settings sx={{ fontSize: 36, color: 'primary.main' }} />
          <Box>
            <Typography variant="h4" fontWeight={600}>Einstellungen</Typography>
            <Typography variant="body2" color="text.secondary">
              {isDekan
                ? 'Verwalten Sie Semesteraufträge und Systemeinstellungen'
                : 'Verwalten Sie Ihre persönlichen Einstellungen'}
            </Typography>
          </Box>
        </Box>
      </Box>

      {/* Tabs - only show if multiple tabs visible */}
      {visibleTabs.length > 1 && (
        <Paper sx={{ mb: 3 }}>
          <Tabs value={activeTab} onChange={(_, v) => setActiveTab(v)}>
            {visibleTabs.map((tab, i) => (
              <Tab key={i} icon={tab.icon} iconPosition="start" label={tab.label} />
            ))}
          </Tabs>
        </Paper>
      )}

      {/* Tab Content */}
      {visibleTabs.map((tab, i) => (
        <SettingsTabPanel key={i} value={activeTab} index={i}>
          {tab.component}
        </SettingsTabPanel>
      ))}
    </Container>
  );
};

export default EinstellungenPage;
