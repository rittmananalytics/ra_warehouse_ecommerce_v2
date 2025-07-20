'use client';

import { Card, CardContent, Typography, Box, Skeleton } from '@mui/material';
import { formatCurrency, formatNumber, formatPercentage } from '@/lib/utils';

interface KPICardProps {
  title: string;
  value: number | string;
  format?: 'currency' | 'number' | 'percentage';
  subtitle?: string;
  icon?: React.ReactNode;
  loading?: boolean;
  trend?: {
    value: number;
    isPositive: boolean;
  };
}

export default function KPICard({
  title,
  value,
  format = 'number',
  subtitle,
  icon,
  loading = false,
  trend,
}: KPICardProps) {
  const formatValue = (val: number | string) => {
    if (typeof val === 'string') return val;
    
    switch (format) {
      case 'currency':
        return formatCurrency(val);
      case 'percentage':
        return formatPercentage(val);
      default:
        return formatNumber(val);
    }
  };

  if (loading) {
    return (
      <Card sx={{ height: '140px' }}>
        <CardContent>
          <Skeleton variant="text" width="60%" height={24} />
          <Skeleton variant="text" width="80%" height={36} sx={{ mt: 1 }} />
          <Skeleton variant="text" width="40%" height={20} sx={{ mt: 1 }} />
        </CardContent>
      </Card>
    );
  }

  return (
    <Card 
      sx={{ 
        height: '140px',
        transition: 'transform 0.2s, box-shadow 0.2s',
        '&:hover': {
          transform: 'translateY(-2px)',
          boxShadow: 3,
        },
      }}
    >
      <CardContent>
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', mb: 1 }}>
          <Typography variant="body2" color="text.secondary" sx={{ fontWeight: 500 }}>
            {title}
          </Typography>
          {icon && (
            <Box sx={{ color: 'primary.main' }}>
              {icon}
            </Box>
          )}
        </Box>
        
        <Typography variant="h4" component="div" sx={{ fontWeight: 'bold', mb: 0.5 }}>
          {formatValue(value)}
        </Typography>
        
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          {subtitle && (
            <Typography variant="caption" color="text.secondary">
              {subtitle}
            </Typography>
          )}
          
          {trend && (
            <Box 
              sx={{ 
                display: 'flex', 
                alignItems: 'center',
                color: trend.isPositive ? 'success.main' : 'error.main',
              }}
            >
              <Typography variant="caption" sx={{ fontWeight: 500 }}>
                {trend.isPositive ? '+' : ''}{formatPercentage(trend.value)}
              </Typography>
            </Box>
          )}
        </Box>
      </CardContent>
    </Card>
  );
}