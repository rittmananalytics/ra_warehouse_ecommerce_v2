'use client';

import {
  Paper,
  Box,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
  Chip,
  Typography,
  Divider,
} from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { AdapterDateFns } from '@mui/x-date-pickers/AdapterDateFns';
import { Refresh as RefreshIcon, FilterList as FilterIcon } from '@mui/icons-material';
import { useState } from 'react';

interface FilterBarProps {
  onFiltersChange: (filters: FilterState) => void;
  onRefresh: () => void;
  loading?: boolean;
}

export interface FilterState {
  dateRange: '7' | '30' | '90' | 'custom';
  startDate?: Date;
  endDate?: Date;
  channel?: string;
  platform?: string;
}

const dateRangeOptions = [
  { value: '7', label: 'Last 7 Days' },
  { value: '30', label: 'Last 30 Days' },
  { value: '90', label: 'Last 90 Days' },
  { value: 'custom', label: 'Custom Range' },
];

const channelOptions = [
  'All Channels',
  'Direct',
  'Organic Search',
  'Paid Search',
  'Social Media',
  'Email',
  'Referral',
];

const platformOptions = [
  'All Platforms',
  'Google Ads',
  'Facebook Ads',
  'Pinterest Ads',
  'Instagram',
];

export default function FilterBar({ onFiltersChange, onRefresh, loading = false }: FilterBarProps) {
  const [filters, setFilters] = useState<FilterState>({
    dateRange: '30',
  });

  const [activeFilters, setActiveFilters] = useState<string[]>(['Last 30 Days']);

  const handleFilterChange = (key: keyof FilterState, value: any) => {
    const newFilters = { ...filters, [key]: value };
    setFilters(newFilters);
    
    // Update active filters display
    const active = ['Last 30 Days']; // Default
    if (newFilters.dateRange !== '30') {
      active[0] = dateRangeOptions.find(opt => opt.value === newFilters.dateRange)?.label || 'Custom';
    }
    if (newFilters.channel && newFilters.channel !== 'All Channels') {
      active.push(newFilters.channel);
    }
    if (newFilters.platform && newFilters.platform !== 'All Platforms') {
      active.push(newFilters.platform);
    }
    
    setActiveFilters(active);
    onFiltersChange(newFilters);
  };

  const clearFilters = () => {
    const defaultFilters: FilterState = { dateRange: '30' };
    setFilters(defaultFilters);
    setActiveFilters(['Last 30 Days']);
    onFiltersChange(defaultFilters);
  };

  return (
    <LocalizationProvider dateAdapter={AdapterDateFns}>
      <Paper 
        sx={{ 
          p: 2, 
          mb: 3,
          backgroundColor: 'white',
          border: '1px solid #e0e0e0',
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
          <FilterIcon sx={{ mr: 1, color: 'text.secondary' }} />
          <Typography variant="h6" sx={{ flexGrow: 1 }}>
            Filters
          </Typography>
          <Button
            variant="outlined"
            startIcon={<RefreshIcon />}
            onClick={onRefresh}
            disabled={loading}
            size="small"
          >
            Refresh
          </Button>
        </Box>

        <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center' }}>
          {/* Date Range */}
          <FormControl size="small" sx={{ minWidth: 140 }}>
            <InputLabel>Date Range</InputLabel>
            <Select
              value={filters.dateRange}
              label="Date Range"
              onChange={(e) => handleFilterChange('dateRange', e.target.value)}
            >
              {dateRangeOptions.map((option) => (
                <MenuItem key={option.value} value={option.value}>
                  {option.label}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          {/* Custom Date Range */}
          {filters.dateRange === 'custom' && (
            <>
              <DatePicker
                label="Start Date"
                value={filters.startDate}
                onChange={(date) => handleFilterChange('startDate', date)}
                slotProps={{ textField: { size: 'small' } }}
              />
              <DatePicker
                label="End Date"
                value={filters.endDate}
                onChange={(date) => handleFilterChange('endDate', date)}
                slotProps={{ textField: { size: 'small' } }}
              />
            </>
          )}

          {/* Channel Filter */}
          <FormControl size="small" sx={{ minWidth: 140 }}>
            <InputLabel>Channel</InputLabel>
            <Select
              value={filters.channel || 'All Channels'}
              label="Channel"
              onChange={(e) => handleFilterChange('channel', e.target.value)}
            >
              {channelOptions.map((option) => (
                <MenuItem key={option} value={option}>
                  {option}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          {/* Platform Filter */}
          <FormControl size="small" sx={{ minWidth: 140 }}>
            <InputLabel>Platform</InputLabel>
            <Select
              value={filters.platform || 'All Platforms'}
              label="Platform"
              onChange={(e) => handleFilterChange('platform', e.target.value)}
            >
              {platformOptions.map((option) => (
                <MenuItem key={option} value={option}>
                  {option}
                </MenuItem>
              ))}
            </Select>
          </FormControl>

          <Button 
            variant="text" 
            size="small" 
            onClick={clearFilters}
            sx={{ ml: 'auto' }}
          >
            Clear All
          </Button>
        </Box>

        {/* Active Filters */}
        {activeFilters.length > 0 && (
          <>
            <Divider sx={{ my: 2 }} />
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, flexWrap: 'wrap' }}>
              <Typography variant="body2" color="text.secondary">
                Active filters:
              </Typography>
              {activeFilters.map((filter, index) => (
                <Chip
                  key={index}
                  label={filter}
                  size="small"
                  color="primary"
                  variant="outlined"
                />
              ))}
            </Box>
          </>
        )}
      </Paper>
    </LocalizationProvider>
  );
}