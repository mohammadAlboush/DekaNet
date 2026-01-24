import React from 'react';
import { Box } from '@mui/material';

interface SettingsTabPanelProps {
  children?: React.ReactNode;
  index: number;
  value: number;
}

const SettingsTabPanel: React.FC<SettingsTabPanelProps> = ({ children, value, index }) => (
  <div role="tabpanel" hidden={value !== index}>
    {value === index && <Box sx={{ py: 3 }}>{children}</Box>}
  </div>
);

export default SettingsTabPanel;
