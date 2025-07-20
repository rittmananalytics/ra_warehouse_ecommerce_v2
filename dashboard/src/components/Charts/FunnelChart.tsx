'use client';

import { Card, CardContent, Typography, Box, Skeleton } from '@mui/material';
import { formatNumber, formatPercentage } from '@/lib/utils';

interface FunnelChartProps {
  data: Array<{
    stage: string;
    count: number;
    stage_order: number;
  }>;
  loading?: boolean;
}

export default function FunnelChart({ data, loading = false }: FunnelChartProps) {
  if (loading) {
    return (
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            🧲 Conversion Funnel
          </Typography>
          <Skeleton variant="rectangular" height={300} />
        </CardContent>
      </Card>
    );
  }

  // Sort data by stage order and calculate conversion rates
  const sortedData = [...data].sort((a, b) => a.stage_order - b.stage_order);
  const maxCount = Math.max(...sortedData.map(d => d.count));
  
  const funnelData = sortedData.map((item, index) => {
    const conversionRate = index === 0 ? 100 : (item.count / sortedData[0].count) * 100;
    const dropoffRate = index > 0 ? ((sortedData[index - 1].count - item.count) / sortedData[index - 1].count) * 100 : 0;
    
    return {
      ...item,
      conversionRate,
      dropoffRate,
      width: (item.count / maxCount) * 100,
    };
  });

  const colors = ['#1976d2', '#2196f3', '#64b5f6', '#90caf9'];

  return (
    <Card>
      <CardContent>
        <Typography variant="h6" gutterBottom>
          🧲 Conversion Funnel (Sessions → Cart → Checkout → Purchase)
        </Typography>
        
        <Box sx={{ mt: 3 }}>
          {funnelData.map((item, index) => (
            <Box key={item.stage} sx={{ mb: 2 }}>
              {/* Stage Bar */}
              <Box 
                sx={{ 
                  position: 'relative',
                  height: 60,
                  display: 'flex',
                  alignItems: 'center',
                  mb: 1,
                }}
              >
                <Box
                  sx={{
                    width: `${item.width}%`,
                    height: '100%',
                    background: `linear-gradient(90deg, ${colors[index]}, ${colors[index]}dd)`,
                    borderRadius: '4px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    position: 'relative',
                    boxShadow: 1,
                  }}
                >
                  <Typography 
                    variant="body1" 
                    sx={{ 
                      color: 'white', 
                      fontWeight: 'bold',
                      textShadow: '1px 1px 2px rgba(0,0,0,0.5)',
                    }}
                  >
                    {item.stage}
                  </Typography>
                </Box>
                
                {/* Metrics */}
                <Box sx={{ ml: 2, minWidth: 120 }}>
                  <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                    {formatNumber(item.count)}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    {formatPercentage(item.conversionRate)} conversion
                  </Typography>
                </Box>
              </Box>
              
              {/* Dropoff Indicator */}
              {index > 0 && item.dropoffRate > 0 && (
                <Box 
                  sx={{ 
                    display: 'flex', 
                    alignItems: 'center', 
                    mb: 1,
                    pl: 2,
                  }}
                >
                  <Box 
                    sx={{ 
                      width: 0, 
                      height: 0, 
                      borderLeft: '8px solid transparent',
                      borderRight: '8px solid transparent',
                      borderTop: '8px solid #f44336',
                      mr: 1,
                    }} 
                  />
                  <Typography variant="caption" sx={{ color: 'error.main' }}>
                    {formatPercentage(item.dropoffRate)} drop-off from previous stage
                  </Typography>
                </Box>
              )}
            </Box>
          ))}
        </Box>
        
        {/* Summary Stats */}
        <Box 
          sx={{ 
            mt: 3, 
            p: 2, 
            backgroundColor: 'grey.50',
            borderRadius: 1,
            display: 'flex',
            justifyContent: 'space-around',
            flexWrap: 'wrap',
            gap: 2,
          }}
        >
          <Box sx={{ textAlign: 'center' }}>
            <Typography variant="h6" color="primary">
              {formatPercentage(funnelData[funnelData.length - 1]?.conversionRate || 0)}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Overall Conversion
            </Typography>
          </Box>
          
          <Box sx={{ textAlign: 'center' }}>
            <Typography variant="h6" color="primary">
              {formatPercentage((funnelData[1]?.conversionRate || 0))}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Add to Cart Rate
            </Typography>
          </Box>
          
          <Box sx={{ textAlign: 'center' }}>
            <Typography variant="h6" color="primary">
              {formatPercentage((funnelData[2]?.count || 0) / (funnelData[1]?.count || 1) * 100)}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Cart to Checkout
            </Typography>
          </Box>
          
          <Box sx={{ textAlign: 'center' }}>
            <Typography variant="h6" color="primary">
              {formatPercentage((funnelData[3]?.count || 0) / (funnelData[2]?.count || 1) * 100)}
            </Typography>
            <Typography variant="caption" color="text.secondary">
              Checkout to Purchase
            </Typography>
          </Box>
        </Box>
      </CardContent>
    </Card>
  );
}