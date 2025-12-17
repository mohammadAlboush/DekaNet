import React from 'react';
import { Snackbar, Alert, AlertColor } from '@mui/material';
import { create } from 'zustand';

interface ToastState {
  open: boolean;
  message: string;
  severity: AlertColor;
  showToast: (message: string, severity?: AlertColor) => void;
  hideToast: () => void;
}

export const useToastStore = create<ToastState>((set) => ({
  open: false,
  message: '',
  severity: 'info',
  showToast: (message, severity = 'info') => 
    set({ open: true, message, severity }),
  hideToast: () => 
    set({ open: false }),
}));

const Toast: React.FC = () => {
  const { open, message, severity, hideToast } = useToastStore();

  return (
    <Snackbar
      open={open}
      autoHideDuration={6000}
      onClose={hideToast}
      anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
    >
      <Alert onClose={hideToast} severity={severity} sx={{ width: '100%' }}>
        {message}
      </Alert>
    </Snackbar>
  );
};

export default Toast;