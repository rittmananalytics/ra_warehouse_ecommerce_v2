// Utility functions for formatting numbers and data

export const formatCurrency = (value: number, currency: string = 'USD'): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency,
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(value);
};

export const formatNumber = (value: number): string => {
  if (value >= 1000000) {
    return (value / 1000000).toFixed(1) + 'M';
  }
  if (value >= 1000) {
    return (value / 1000).toFixed(1) + 'K';
  }
  return value.toLocaleString();
};

export const formatPercentage = (value: number, decimals: number = 1): string => {
  return `${value.toFixed(decimals)}%`;
};

export const formatCompactCurrency = (value: number, currency: string = 'USD'): string => {
  if (value >= 1000000) {
    return `$${(value / 1000000).toFixed(1)}M`;
  }
  if (value >= 1000) {
    return `$${(value / 1000).toFixed(1)}K`;
  }
  return formatCurrency(value, currency);
};

export const getRandomColor = (index: number): string => {
  const colors = [
    '#1976d2', '#f57c00', '#388e3c', '#d32f2f', '#7b1fa2',
    '#00796b', '#303f9f', '#f57c00', '#c2185b', '#455a64'
  ];
  return colors[index % colors.length];
};

export const calculateTrend = (current: number, previous: number): { value: number; isPositive: boolean } => {
  if (previous === 0) return { value: 0, isPositive: true };
  const trend = ((current - previous) / previous) * 100;
  return {
    value: Math.abs(trend),
    isPositive: trend >= 0,
  };
};