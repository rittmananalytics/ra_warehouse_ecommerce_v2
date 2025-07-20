'use client';

import {
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Typography,
  Box,
  Divider,
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  TrendingUp as TrendingUpIcon,
  Campaign as CampaignIcon,
  People as PeopleIcon,
  Inventory as InventoryIcon,
  Email as EmailIcon,
  Share as ShareIcon,
  Assessment as AssessmentIcon,
  BusinessCenter as BusinessIcon,
} from '@mui/icons-material';
import { usePathname, useRouter } from 'next/navigation';

const drawerWidth = 280;

const menuItems = [
  {
    text: 'Executive Overview',
    icon: <BusinessIcon />,
    path: '/',
    description: 'High-level KPIs and performance',
  },
  {
    text: 'Sales & Orders',
    icon: <TrendingUpIcon />,
    path: '/sales',
    description: 'Revenue and order analytics',
  },
  {
    text: 'Marketing & Attribution',
    icon: <CampaignIcon />,
    path: '/marketing',
    description: 'Campaign performance and ROI',
  },
  {
    text: 'Customer Insights',
    icon: <PeopleIcon />,
    path: '/customers',
    description: 'Customer segments and LTV',
  },
  {
    text: 'Website & Engagement',
    icon: <DashboardIcon />,
    path: '/website',
    description: 'Session analysis and funnels',
  },
  {
    text: 'Product & Inventory',
    icon: <InventoryIcon />,
    path: '/products',
    description: 'Product performance and stock',
  },
  {
    text: 'Email Marketing',
    icon: <EmailIcon />,
    path: '/email',
    description: 'Campaign and engagement metrics',
  },
  {
    text: 'Social Content',
    icon: <ShareIcon />,
    path: '/social',
    description: 'Social media performance',
  },
  {
    text: 'Data Quality',
    icon: <AssessmentIcon />,
    path: '/data-quality',
    description: 'Pipeline health monitoring',
  },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  return (
    <Drawer
      variant="permanent"
      sx={{
        width: drawerWidth,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: drawerWidth,
          boxSizing: 'border-box',
          backgroundColor: '#1a1a1a',
          color: 'white',
        },
      }}
    >
      <Box sx={{ p: 3 }}>
        <Typography variant="h6" component="div" sx={{ fontWeight: 'bold', color: '#1976d2' }}>
          Ra Analytics
        </Typography>
        <Typography variant="body2" sx={{ color: 'rgba(255, 255, 255, 0.7)', mt: 0.5 }}>
          Ecommerce Dashboard
        </Typography>
      </Box>
      
      <Divider sx={{ borderColor: 'rgba(255, 255, 255, 0.12)' }} />
      
      <List sx={{ px: 1, pt: 2 }}>
        {menuItems.map((item) => (
          <ListItem key={item.text} disablePadding sx={{ mb: 1 }}>
            <ListItemButton
              selected={pathname === item.path}
              onClick={() => router.push(item.path)}
              sx={{
                borderRadius: '8px',
                mx: 1,
                '&.Mui-selected': {
                  backgroundColor: '#1976d2',
                  '&:hover': {
                    backgroundColor: '#1565c0',
                  },
                },
                '&:hover': {
                  backgroundColor: 'rgba(255, 255, 255, 0.08)',
                },
              }}
            >
              <ListItemIcon sx={{ color: 'inherit', minWidth: '40px' }}>
                {item.icon}
              </ListItemIcon>
              <Box>
                <ListItemText 
                  primary={item.text}
                  primaryTypographyProps={{
                    fontSize: '0.9rem',
                    fontWeight: pathname === item.path ? 600 : 400,
                  }}
                />
                <Typography 
                  variant="caption" 
                  sx={{ 
                    color: 'rgba(255, 255, 255, 0.6)',
                    display: 'block',
                    lineHeight: 1.2,
                  }}
                >
                  {item.description}
                </Typography>
              </Box>
            </ListItemButton>
          </ListItem>
        ))}
      </List>
      
      <Box sx={{ mt: 'auto', p: 2 }}>
        <Typography variant="caption" sx={{ color: 'rgba(255, 255, 255, 0.5)' }}>
          © 2025 Rittman Analytics
        </Typography>
      </Box>
    </Drawer>
  );
}