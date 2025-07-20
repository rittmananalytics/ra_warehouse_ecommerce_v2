'use client';

import { 
  ScatterChart, 
  Scatter, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  Cell
} from 'recharts';
import { Card, CardContent, Typography, Box, Skeleton } from '@mui/material';
import { formatCompactCurrency, getRandomColor } from '@/lib/utils';

interface MarketingChartProps {
  data: Array<{
    platform: string;
    total_spend: number;
    total_revenue: number;
    roas: number;
    campaign_count: number;
  }>;
  loading?: boolean;
}

export default function MarketingChart({ data, loading = false }: MarketingChartProps) {
  if (loading) {
    return (
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            💸 Marketing Spend vs ROAS by Platform
          </Typography>
          <Skeleton variant="rectangular" height={300} />
        </CardContent>
      </Card>
    );
  }

  const customTooltip = ({ active, payload }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload;
      return (
        <Box 
          sx={{ 
            backgroundColor: 'white', 
            p: 1.5, 
            border: '1px solid #ccc',
            borderRadius: 1,
            boxShadow: 2,
          }}
        >
          <Typography variant="body2" sx={{ fontWeight: 'bold', mb: 1 }}>
            {data.platform}
          </Typography>
          <Typography variant="body2">
            Spend: {formatCompactCurrency(data.total_spend)}
          </Typography>
          <Typography variant="body2">
            ROAS: {data.roas.toFixed(2)}x
          </Typography>
          <Typography variant="body2">
            Campaigns: {data.campaign_count}
          </Typography>
          <Typography variant="body2">
            Revenue: {formatCompactCurrency(data.total_revenue)}
          </Typography>
        </Box>
      );
    }
    return null;
  };

  return (
    <Card>
      <CardContent>
        <Typography variant="h6" gutterBottom>
          💸 Marketing Spend vs ROAS by Platform
        </Typography>
        <Box sx={{ width: '100%', height: 300 }}>
          <ResponsiveContainer>
            <ScatterChart
              margin={{ top: 20, right: 20, bottom: 20, left: 20 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis 
                type="number" 
                dataKey="total_spend"
                name="Spend"
                tick={{ fontSize: 12 }}
                tickFormatter={(value) => formatCompactCurrency(value)}
              />
              <YAxis 
                type="number" 
                dataKey="roas"
                name="ROAS"
                tick={{ fontSize: 12 }}
                tickFormatter={(value) => `${value.toFixed(1)}x`}
              />
              <Tooltip content={customTooltip} />
              <Scatter data={data} fill="#1976d2">
                {data.map((entry, index) => (
                  <Cell 
                    key={`cell-${index}`} 
                    fill={getRandomColor(index)}
                  />
                ))}
              </Scatter>
            </ScatterChart>
          </ResponsiveContainer>
        </Box>
        
        {/* Legend */}
        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 2, mt: 2 }}>
          {data.map((item, index) => (
            <Box key={item.platform} sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Box 
                sx={{ 
                  width: 12, 
                  height: 12, 
                  backgroundColor: getRandomColor(index),
                  borderRadius: '50%' 
                }} 
              />
              <Typography variant="caption">
                {item.platform}
              </Typography>
            </Box>
          ))}
        </Box>
      </CardContent>
    </Card>
  );
}