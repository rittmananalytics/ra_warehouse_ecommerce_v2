'use client';

import { useState, useEffect, useCallback } from 'react';
import {
  Box,
  Grid,
  Typography,
  Alert,
  CircularProgress,
} from '@mui/material';
import {
  TrendingUp as RevenueIcon,
  ShoppingCart as OrdersIcon,
  AttachMoney as AOVIcon,
  Percent as MarginIcon,
  PersonAdd as CACIcon,
  CampaignOutlined as ROASIcon,
  TrendingUp as ConversionIcon,
} from '@mui/icons-material';

import KPICard from '@/components/KPICard';
import FilterBar, { FilterState } from '@/components/FilterBar';
import RevenueChart from '@/components/Charts/RevenueChart';
import ChannelChart from '@/components/Charts/ChannelChart';
import MarketingChart from '@/components/Charts/MarketingChart';
import InventoryChart from '@/components/Charts/InventoryChart';
import FunnelChart from '@/components/Charts/FunnelChart';

import {
  ExecutiveKPIs,
  RevenueData,
  ChannelData,
  MarketingData,
  InventoryData,
  FunnelData,
} from '@/lib/bigquery';

interface DashboardData {
  kpis: ExecutiveKPIs | null;
  revenueData: RevenueData[];
  channelData: ChannelData[];
  marketingData: MarketingData[];
  inventoryData: InventoryData[];
  funnelData: FunnelData[];
}

export default function ExecutiveOverview() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<FilterState>({ dateRange: '30' });
  const [data, setData] = useState<DashboardData>({
    kpis: null,
    revenueData: [],
    channelData: [],
    marketingData: [],
    inventoryData: [],
    funnelData: [],
  });

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    
    try {
      const dateRange = parseInt(filters.dateRange);
      
      // Fetch all data in parallel
      const [
        kpisResponse,
        revenueResponse,
        channelsResponse,
        marketingResponse,
        inventoryResponse,
        funnelResponse,
      ] = await Promise.all([
        fetch(`/api/executive/kpis?dateRange=${dateRange}`),
        fetch(`/api/executive/revenue?dateRange=${dateRange}`),
        fetch('/api/executive/channels?limit=5'),
        fetch('/api/executive/marketing'),
        fetch('/api/executive/inventory'),
        fetch('/api/executive/funnel'),
      ]);

      // Check for errors
      if (!kpisResponse.ok) throw new Error('Failed to fetch KPIs');
      if (!revenueResponse.ok) throw new Error('Failed to fetch revenue data');
      if (!channelsResponse.ok) throw new Error('Failed to fetch channel data');
      if (!marketingResponse.ok) throw new Error('Failed to fetch marketing data');
      if (!inventoryResponse.ok) throw new Error('Failed to fetch inventory data');
      if (!funnelResponse.ok) throw new Error('Failed to fetch funnel data');

      // Parse responses
      const [kpis, revenueData, channelData, marketingData, inventoryData, funnelData] = await Promise.all([
        kpisResponse.json(),
        revenueResponse.json(),
        channelsResponse.json(),
        marketingResponse.json(),
        inventoryResponse.json(),
        funnelResponse.json(),
      ]);

      setData({
        kpis,
        revenueData,
        channelData,
        marketingData,
        inventoryData,
        funnelData,
      });
    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      setError(err instanceof Error ? err.message : 'Failed to load dashboard data');
    } finally {
      setLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleFiltersChange = (newFilters: FilterState) => {
    setFilters(newFilters);
  };

  const handleRefresh = () => {
    fetchData();
  };

  return (
    <Box>
      {/* Page Header */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" component="h1" gutterBottom>
          Executive Overview
        </Typography>
        <Typography variant="body1" color="text.secondary">
          High-level business performance summary for C-level stakeholders
        </Typography>
      </Box>

      {/* Filters */}
      <FilterBar 
        onFiltersChange={handleFiltersChange}
        onRefresh={handleRefresh}
        loading={loading}
      />

      {/* Error Alert */}
      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {/* Loading State */}
      {loading && !data.kpis && (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}>
          <CircularProgress />
        </Box>
      )}

      {/* KPI Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <KPICard
            title="Total Revenue"
            value={data.kpis?.totalRevenue || 0}
            format="currency"
            subtitle={`Last ${filters.dateRange} days`}
            icon={<RevenueIcon />}
            loading={loading}
          />
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <KPICard
            title="Total Orders"
            value={data.kpis?.totalOrders || 0}
            format="number"
            subtitle={`Last ${filters.dateRange} days`}
            icon={<OrdersIcon />}
            loading={loading}
          />
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <KPICard
            title="Average Order Value"
            value={data.kpis?.avgOrderValue || 0}
            format="currency"
            subtitle="AOV"
            icon={<AOVIcon />}
            loading={loading}
          />
        </Grid>
        
        <Grid item xs={12} sm={6} md={3}>
          <KPICard
            title="Gross Margin %"
            value={data.kpis?.grossMarginPct || 0}
            format="percentage"
            subtitle="Overall margin"
            icon={<MarginIcon />}
            loading={loading}
          />
        </Grid>
        
        <Grid item xs={12} sm={6} md={4}>
          <KPICard
            title="Customer Acquisition Cost"
            value={data.kpis?.customerAcquisitionCost || 0}
            format="currency"
            subtitle="CAC"
            icon={<CACIcon />}
            loading={loading}
          />
        </Grid>
        
        <Grid item xs={12} sm={6} md={4}>
          <KPICard
            title="Return on Ad Spend"
            value={data.kpis?.returnOnAdSpend || 0}
            format="number"
            subtitle="ROAS"
            icon={<ROASIcon />}
            loading={loading}
          />
        </Grid>
        
        <Grid item xs={12} sm={6} md={4}>
          <KPICard
            title="Conversion Rate"
            value={data.kpis?.conversionRate || 0}
            format="percentage"
            subtitle="Sessions to Purchase"
            icon={<ConversionIcon />}
            loading={loading}
          />
        </Grid>
      </Grid>

      {/* Charts */}
      <Grid container spacing={3}>
        {/* Revenue Comparison Chart */}
        <Grid item xs={12} lg={8}>
          <RevenueChart 
            data={data.revenueData} 
            loading={loading}
          />
        </Grid>
        
        {/* Top Channels Chart */}
        <Grid item xs={12} lg={4}>
          <ChannelChart 
            data={data.channelData} 
            loading={loading}
          />
        </Grid>
        
        {/* Marketing Performance Chart */}
        <Grid item xs={12} md={6}>
          <MarketingChart 
            data={data.marketingData} 
            loading={loading}
          />
        </Grid>
        
        {/* Inventory Value Chart */}
        <Grid item xs={12} md={6}>
          <InventoryChart 
            data={data.inventoryData} 
            loading={loading}
          />
        </Grid>
        
        {/* Conversion Funnel Chart */}
        <Grid item xs={12}>
          <FunnelChart 
            data={data.funnelData} 
            loading={loading}
          />
        </Grid>
      </Grid>
    </Box>
  );
}