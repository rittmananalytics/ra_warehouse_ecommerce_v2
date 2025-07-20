'use client';

import { 
  Treemap, 
  ResponsiveContainer,
  Tooltip
} from 'recharts';
import { Card, CardContent, Typography, Box, Skeleton } from '@mui/material';
import { formatCompactCurrency, getRandomColor } from '@/lib/utils';

interface InventoryChartProps {
  data: Array<{
    category: string;
    product_count: number;
    inventory_value: number;
    avg_product_price: number;
  }>;
  loading?: boolean;
}

export default function InventoryChart({ data, loading = false }: InventoryChartProps) {
  if (loading) {
    return (
      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            ⚖️ Inventory Value by Category
          </Typography>
          <Skeleton variant="rectangular" height={300} />
        </CardContent>
      </Card>
    );
  }

  // Transform data for treemap
  const treemapData = data.map((item, index) => ({
    name: item.category,
    size: item.inventory_value,
    product_count: item.product_count,
    avg_price: item.avg_product_price,
    fill: getRandomColor(index),
  }));

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
            {data.name}
          </Typography>
          <Typography variant="body2">
            Inventory Value: {formatCompactCurrency(data.size)}
          </Typography>
          <Typography variant="body2">
            Products: {data.product_count}
          </Typography>
          <Typography variant="body2">
            Avg Price: {formatCompactCurrency(data.avg_price)}
          </Typography>
        </Box>
      );
    }
    return null;
  };

  const CustomizedContent = (props: any) => {
    const { root, depth, x, y, width, height, index, payload, colors, rank, name } = props;

    return (
      <g>
        <rect
          x={x}
          y={y}
          width={width}
          height={height}
          style={{
            fill: payload?.fill || getRandomColor(index),
            stroke: '#fff',
            strokeWidth: 2,
          }}
        />
        {width > 60 && height > 40 && (
          <>
            <text 
              x={x + width / 2} 
              y={y + height / 2 - 10} 
              textAnchor="middle"
              fill="white"
              fontSize="12"
              fontWeight="bold"
            >
              {name}
            </text>
            <text 
              x={x + width / 2} 
              y={y + height / 2 + 10} 
              textAnchor="middle"
              fill="white"
              fontSize="10"
            >
              {formatCompactCurrency(payload?.size || 0)}
            </text>
          </>
        )}
      </g>
    );
  };

  return (
    <Card>
      <CardContent>
        <Typography variant="h6" gutterBottom>
          ⚖️ Inventory Value by Category
        </Typography>
        <Box sx={{ width: '100%', height: 300 }}>
          <ResponsiveContainer>
            <Treemap
              data={treemapData}
              dataKey="size"
              aspectRatio={4 / 3}
              stroke="#fff"
              content={<CustomizedContent />}
            >
              <Tooltip content={customTooltip} />
            </Treemap>
          </ResponsiveContainer>
        </Box>
      </CardContent>
    </Card>
  );
}