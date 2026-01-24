import React from 'react';
import { Paper, Typography, Box, Alert } from '@mui/material';
import { AccountCircle } from '@mui/icons-material';

const ProfileSettings: React.FC = () => (
  <Paper sx={{ p: 3 }}>
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 3 }}>
      <AccountCircle sx={{ fontSize: 40 }} />
      <Typography variant="h6">Profileinstellungen</Typography>
    </Box>
    <Alert severity="info">
      Profileinstellungen werden in einer zukünftigen Version verfügbar sein.
    </Alert>
  </Paper>
);

export default ProfileSettings;
