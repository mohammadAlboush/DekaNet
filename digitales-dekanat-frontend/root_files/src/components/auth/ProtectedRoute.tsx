import React, { useEffect } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { Box, CircularProgress } from '@mui/material';
import useAuthStore from '../../store/authStore';

/**
 * Protected Route Component
 * Schützt Routen die Authentication benötigen
 */

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRoles?: string[];
  redirectTo?: string;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ 
  children, 
  requiredRoles = [],
  redirectTo = '/login' 
}) => {
  const location = useLocation();
  const { isAuthenticated, user, isLoading, checkAuth } = useAuthStore();

  // Helper function to get role name (supports both string and object format)
  const getRoleName = React.useMemo(() => {
    if (!user) return '';
    if (typeof user.rolle === 'string') return user.rolle;
    return user.rolle?.name || '';
  }, [user]);

  useEffect(() => {
    // Check authentication status on mount
    if (!isAuthenticated) {
      checkAuth();
    }
  }, [checkAuth, isAuthenticated]);

  // Loading state
  if (isLoading) {
    return (
      <Box
        sx={{
          display: 'flex',
          justifyContent: 'center',
          alignItems: 'center',
          minHeight: '100vh',
        }}
      >
        <CircularProgress size={48} />
      </Box>
    );
  }

  // Not authenticated
  if (!isAuthenticated || !user) {
    return <Navigate to={redirectTo} state={{ from: location }} replace />;
  }

  // Check role requirements
  if (requiredRoles.length > 0 && !requiredRoles.includes(getRoleName)) {
    // User doesn't have required role - redirect to dashboard with error
    return <Navigate to="/dashboard" replace />;
  }

  // User is authenticated and has required role
  return <>{children}</>;
};

export default ProtectedRoute;