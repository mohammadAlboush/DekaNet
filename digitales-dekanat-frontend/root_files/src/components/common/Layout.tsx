import React, { useState } from 'react';
import { Outlet, useNavigate, useLocation } from 'react-router-dom';
import {
  AppBar,
  Box,
  Toolbar,
  IconButton,
  Typography,
  Menu,
  Avatar,
  Tooltip,
  MenuItem,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Divider,
  useMediaQuery,
  useTheme,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Dashboard as DashboardIcon,
  Assignment,
  School,
  Group,
  Settings,
  AccountCircle,
  Logout,
  ChevronLeft,
  Calculate,
  WorkHistory,
  FileCopy,
} from '@mui/icons-material';
import useAuthStore from '../../store/authStore';
import { createContextLogger } from '../../utils/logger';

const log = createContextLogger('Layout');

/**
 * Layout Component
 * ================
 * Main Application Layout mit Navigation und Logout
 */

const drawerWidth = 240;

interface NavItem {
  title: string;
  path: string;
  icon: React.ReactNode;
  roles?: string[];
}

const Layout: React.FC = () => {
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const navigate = useNavigate();
  const location = useLocation();
  const { user, logout } = useAuthStore();

  const [mobileOpen, setMobileOpen] = useState(false);
  const [anchorElUser, setAnchorElUser] = useState<null | HTMLElement>(null);

  // Helper function to check user role (supports both string and object format)
  const hasRole = React.useMemo(() => {
    return (roleName: string): boolean => {
      if (!user) return false;
      if (typeof user.rolle === 'string') {
        return user.rolle === roleName;
      }
      return user.rolle?.name === roleName;
    };
  }, [user]);

  // Navigation Items based on Role
  const getNavItems = (): NavItem[] => {
    const baseItems: NavItem[] = [
      { title: 'Dashboard', path: '/dashboard', icon: <DashboardIcon /> },
    ];

    if (hasRole('dekan')) {
      return [
        ...baseItems,
        { title: 'Semesterplanung', path: '/dekan/planungen', icon: <Assignment />, roles: ['dekan'] },
        { title: 'Deputat-Verwaltung', path: '/dekan/deputat', icon: <Calculate />, roles: ['dekan'] },
        { title: 'Module', path: '/module', icon: <School /> },
        { title: 'Dozenten', path: '/dozenten', icon: <Group /> },
        // Semester-Link versteckt - Dekan wählt Semester bei Planungsphase-Start
        // { title: 'Semester', path: '/semester', icon: <CalendarMonth />, roles: ['dekan'] },
      ];
    }

    if (hasRole('professor') || hasRole('lehrbeauftragter')) {
      return [
        ...baseItems,
        { title: 'Semesterplanung', path: '/semesterplanung', icon: <Assignment /> },
        { title: 'Deputatsabrechnung', path: '/deputatsabrechnung', icon: <WorkHistory /> },
        { title: 'Templates', path: '/templates', icon: <FileCopy /> },
        { title: 'Module', path: '/module', icon: <School /> },
      ];
    }

    return baseItems;
  };

  const navItems = getNavItems();

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleOpenUserMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorElUser(event.currentTarget);
  };

  const handleCloseUserMenu = () => {
    setAnchorElUser(null);
  };

  const handleLogout = async () => {
    try {
      await logout();
      navigate('/login');
    } catch (error) {
      log.error('Logout error:', error);
    }
  };

  const handleNavigate = (path: string) => {
    navigate(path);
    if (isMobile) {
      setMobileOpen(false);
    }
  };

  // Helper to display user role
  const getUserRoleDisplay = (): string => {
    if (!user) return '';
    if (typeof user.rolle === 'string') {
      return user.rolle;
    }
    return user.rolle?.name || '';
  };

  // Drawer Content
  const drawer = (
    <Box>
      <Toolbar sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 600 }}>
          DekaNet
        </Typography>
        {isMobile && (
          <IconButton onClick={handleDrawerToggle}>
            <ChevronLeft />
          </IconButton>
        )}
      </Toolbar>
      <Divider />
      <List>
        {navItems.map((item) => (
          <ListItem key={item.path} disablePadding>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => handleNavigate(item.path)}
            >
              <ListItemIcon>{item.icon}</ListItemIcon>
              <ListItemText primary={item.title} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
      <Divider />
      <List>
        <ListItem disablePadding>
          <ListItemButton onClick={() => handleNavigate('/einstellungen')}>
            <ListItemIcon>
              <Settings />
            </ListItemIcon>
            <ListItemText primary="Einstellungen" />
          </ListItemButton>
        </ListItem>
      </List>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex' }}>
      {/* AppBar */}
      <AppBar
        position="fixed"
        sx={{
          width: { md: `calc(100% - ${drawerWidth}px)` },
          ml: { md: `${drawerWidth}px` },
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { md: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            {navItems.find(item => item.path === location.pathname)?.title || 'Dashboard'}
          </Typography>

          {/* User Info & Logout */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
            <Box sx={{ display: { xs: 'none', sm: 'block' } }}>
              <Typography variant="body2">
                {user?.name_komplett || user?.username}
              </Typography>
              <Typography variant="caption" color="inherit" sx={{ opacity: 0.8 }}>
                {getUserRoleDisplay()}
              </Typography>
            </Box>
            
            <Tooltip title="Account Menü">
              <IconButton onClick={handleOpenUserMenu} sx={{ p: 0 }}>
                <Avatar sx={{ bgcolor: 'secondary.main' }}>
                  {user?.vorname?.charAt(0) || user?.username?.charAt(0) || 'U'}
                </Avatar>
              </IconButton>
            </Tooltip>
          </Box>

          <Menu
            sx={{ mt: '45px' }}
            id="menu-appbar"
            anchorEl={anchorElUser}
            anchorOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
            keepMounted
            transformOrigin={{
              vertical: 'top',
              horizontal: 'right',
            }}
            open={Boolean(anchorElUser)}
            onClose={handleCloseUserMenu}
          >
            <MenuItem onClick={() => {
              handleCloseUserMenu();
              navigate('/profil');
            }}>
              <ListItemIcon>
                <AccountCircle fontSize="small" />
              </ListItemIcon>
              <Typography textAlign="center">Profil</Typography>
            </MenuItem>
            <MenuItem onClick={() => {
              handleCloseUserMenu();
              navigate('/einstellungen');
            }}>
              <ListItemIcon>
                <Settings fontSize="small" />
              </ListItemIcon>
              <Typography textAlign="center">Einstellungen</Typography>
            </MenuItem>
            <Divider />
            <MenuItem onClick={() => {
              handleCloseUserMenu();
              handleLogout();
            }}>
              <ListItemIcon>
                <Logout fontSize="small" />
              </ListItemIcon>
              <Typography textAlign="center">Abmelden</Typography>
            </MenuItem>
          </Menu>
        </Toolbar>
      </AppBar>

      {/* Drawer */}
      <Box
        component="nav"
        sx={{ width: { md: drawerWidth }, flexShrink: { md: 0 } }}
      >
        {/* Mobile Drawer */}
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true, // Better mobile performance
          }}
          sx={{
            display: { xs: 'block', md: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>

        {/* Desktop Drawer */}
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', md: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>

      {/* Main Content */}
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { md: `calc(100% - ${drawerWidth}px)` },
          mt: '64px',
          minHeight: 'calc(100vh - 64px)',
          backgroundColor: 'background.default',
        }}
      >
        <Outlet />
      </Box>
    </Box>
  );
};

export default Layout;