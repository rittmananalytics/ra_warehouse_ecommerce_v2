'use client';

import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';
import { Card, CardContent, Typography, Box, Skeleton } from '@mui/material';
import { formatCompactCurrency } from '@/lib/utils';

interface ChannelChartProps {
  data: Array<{
    channel_name: string;
    total_revenue: number;
    total_orders: number;
    avg_order_value: number;
  }>;
  loading?: boolean;
}

export default function ChannelChart({ data, loading = false }: ChannelChartProps) {
  if (loading) {
    return (
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            📊 Top 5 Channels by Revenue
          </Typography>
          <Skeleton variant="rectangular" height={300} />
        </CardContent>
      </Card>
    );
  }

  const customTooltip = ({ active, payload, label }: any) => {
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
            {label}
          </Typography>
          <Typography variant="body2">
            Revenue: {formatCompactCurrency(data.total_revenue)}
          </Typography>
          <Typography variant="body2">
            Orders: {data.total_orders.toLocaleString()}
          </Typography>
          <Typography variant="body2">
            AOV: {formatCompactCurrency(data.avg_order_value)}
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
          📊 Top 5 Channels by Revenue
        </Typography>
        <Box sx={{ width: '100%', height: 300 }}>
          <ResponsiveContainer>
            <BarChart 
              data={data} 
              layout="vericalLayout"
              margin={{ top: 20, right: 30, left: 20, bottom: 5 }}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
              <XAxis 
                type="number"
                tick={{ fontSize: 12 }}
                tickFormatter={(value) => formatCompactCurrency(value)}
              />
              <YAxis 
                type="category"
                dataKey="channel_name"
                tick={{ fontSize: 12 }}
                width={100}
              />
              <Tooltip content={customTooltip} />
              <Bar 
                dataKey="total_revenue" 
                fill="#1976d2"
                radius={[0, 4, 4, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </Box>
      </CardContent>
    </Card>
  );
}