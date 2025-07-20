# LookML Project Documentation

This document provides comprehensive documentation for the Ra Ecommerce Analytics LookML project, including setup instructions, architecture overview, and usage guidelines.

## Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [View Files Documentation](#view-files-documentation)
- [Model and Explores](#model-and-explores)
- [Dashboards](#dashboards)
- [Best Practices](#best-practices)
- [Deployment Guide](#deployment-guide)

## Overview

The Ra Ecommerce Analytics LookML project provides a comprehensive business intelligence layer on top of the dbt-transformed data warehouse. It includes:

- **8 View Files**: Representing all warehouse tables with dimensions and measures
- **9 Explores**: Pre-configured analysis paths for different use cases
- **4 LookML Dashboards**: Executive, Sales, Marketing, and Data Quality monitoring
- **Advanced Features**: Attribution analysis, SCD Type 2 support, and data quality monitoring

## Project Structure

```
lookml/
├── manifest.lkml                    # Project configuration
├── models/
│   └── ra_ecommerce_analytics.model.lkml  # Model with explores
├── views/
│   ├── wh_dim_date.view.lkml      # Date dimension
│   ├── wh_dim_customers.view.lkml  # Customer dimension
│   ├── wh_dim_products.view.lkml   # Product dimension
│   ├── wh_fact_orders.view.lkml    # Orders fact table
│   ├── wh_fact_ga4_sessions.view.lkml     # Web analytics
│   ├── wh_fact_marketing_performance.view.lkml  # Marketing data
│   ├── wh_dim_channels_enhanced.view.lkml # Channel definitions
│   └── wh_fact_data_quality.view.lkml     # Data quality metrics
└── dashboards/
    ├── executive_overview.dashboard.lookml
    ├── sales_orders_analytics.dashboard.lookml
    ├── marketing_attribution.dashboard.lookml
    └── data_quality_monitoring.dashboard.lookml
```

## Setup Instructions

### Prerequisites

1. **Looker Instance**: Access to a Looker instance (cloud or on-premise)
2. **BigQuery Connection**: Configured connection named `ra_ecommerce_bigquery`
3. **Permissions**: 
   - Looker: Developer permissions
   - BigQuery: Data Viewer access to the warehouse dataset
4. **Data Warehouse**: Deployed Ra Ecommerce Data Warehouse v2

### Installation Steps

#### 1. Create New LookML Project

In Looker:
1. Navigate to **Develop** → **Manage LookML Projects**
2. Click **New LookML Project**
3. Name: `ra_ecommerce_analytics`
4. Starting Point: "Blank Project"

#### 2. Configure Git Connection

```bash
# In your local development environment
cd /path/to/lookml/project
git init
git remote add origin <your-git-repo-url>
```

#### 3. Create Project Structure

```bash
# Create directories
mkdir -p views models dashboards

# Copy all LookML files to appropriate directories
```

#### 4. Update Manifest Configuration

Edit `manifest.lkml`:
```lookml
project_name: "ra_ecommerce_analytics"

# Add constants for your environment
constant: PROJECT_ID {
  value: "your-bigquery-project-id"
}

constant: ECOMMERCE_DATASET {
  value: "analytics_ecommerce_ecommerce"
}
```

#### 5. Configure Database Connection

In Looker Admin:
1. Go to **Admin** → **Database** → **Connections**
2. Create new connection:
   - Name: `ra_ecommerce_bigquery`
   - Dialect: Google BigQuery Standard SQL
   - Project: Your GCP Project ID
   - Dataset: `analytics_ecommerce_ecommerce`

#### 6. Deploy and Validate

```bash
# Commit and deploy
git add .
git commit -m "Initial LookML project setup"
git push origin main

# In Looker
# Click "Deploy to Production"
# Run LookML Validator
```

## View Files Documentation

### Date Dimension (`wh_dim_date.view.lkml`)

Central time dimension for all date-based analysis:

**Key Dimensions:**
- `date_key`: Primary key (YYYYMMDD format)
- `calendar_date`: Full date with timeframes
- `fiscal_*`: Fiscal calendar dimensions
- `is_weekend`, `is_holiday`: Boolean flags
- `season`: Derived season based on month

**Key Measures:**
- `count_weekdays`: Business days count
- `count_holidays`: Holiday count

### Customer Dimension (`wh_dim_customers.view.lkml`)

SCD Type 2 customer dimension with lifetime metrics:

**Key Dimensions:**
- `customer_sk`: Surrogate key
- `customer_id`: Business key
- `customer_lifetime_value_tier`: Value-based segmentation
- `order_frequency_tier`: Behavior-based segmentation
- `is_current`: Current record indicator

**Key Measures:**
- `count_current`: Active customers
- `average_total_spent`: Average CLV
- `average_orders_per_customer`: Purchase frequency

### Product Dimension (`wh_dim_products.view.lkml`)

SCD Type 2 product catalog with inventory:

**Key Dimensions:**
- `product_sk`: Surrogate key
- `margin_percentage`: Calculated gross margin
- `inventory_status`: Stock level categorization
- `price_tier`: Price-based segmentation

**Key Measures:**
- `total_inventory_value`: Current inventory value
- `average_margin_percentage`: Portfolio margin
- `count_out_of_stock`: Stockout tracking

### Orders Fact (`wh_fact_orders.view.lkml`)

Granular order line item data:

**Key Dimensions:**
- `order_line_sk`: Primary key
- `order_size_category`: Order value segmentation
- `margin_category`: Profitability classification
- `is_high_value_order`: Premium order flag

**Key Measures:**
- `total_revenue`: Sales revenue
- `average_order_value`: AOV
- `units_per_order`: Basket size
- `return_rate`: Return/refund rate

### GA4 Sessions Fact (`wh_fact_ga4_sessions.view.lkml`)

Website behavior and conversion tracking:

**Key Dimensions:**
- `channel_grouping`: Derived traffic channels
- `user_type`: New vs returning
- `is_high_engagement`: Quality session indicator
- `device_category`: Device segmentation

**Key Measures:**
- `engagement_rate`: Session quality
- `bounce_rate`: Single-page sessions
- `conversion_rate`: Goal completions
- `sessions_per_user`: User frequency

### Marketing Performance Fact (`wh_fact_marketing_performance.view.lkml`)

Campaign and ad performance metrics:

**Key Dimensions:**
- `platform`: Ad platform
- `performance_category`: ROAS-based classification
- `spend_tier`: Budget segmentation
- `campaign_duration_days`: Campaign length

**Key Measures:**
- `overall_roas`: Return on ad spend
- `overall_cpa`: Cost per acquisition
- `overall_ctr`: Click-through rate
- `total_engagement`: Social interactions

### Channel Dimension (`wh_dim_channels_enhanced.view.lkml`)

Marketing channel taxonomy and attributes:

**Key Dimensions:**
- `channel_type`: Paid/organic classification
- `performance_tier`: Quality scoring
- `cac_efficiency`: Acquisition cost efficiency
- `supports_*`: Capability flags

**Key Measures:**
- `average_conversion_rate`: Channel effectiveness
- `average_cac`: Acquisition costs
- `premium_channels`: High-value channel count

### Data Quality Fact (`wh_fact_data_quality.view.lkml`)

Pipeline monitoring and data quality:

**Key Dimensions:**
- `quality_tier`: Test pass rate classification
- `health_status`: Pipeline health
- `freshness_status`: Data recency
- `requires_attention`: Alert flag

**Key Measures:**
- `data_quality_score`: Composite health metric
- `overall_test_pass_rate`: Quality percentage
- `sources_with_issues`: Problem source count
- `error_rate`: Error frequency

## Model and Explores

### Main Explores

#### 1. Orders (Central Hub)
```lookml
explore: orders {
  join: order_date {...}
  join: customers {...}
  join: products {...}
}
```
**Use Cases**: Sales analysis, product performance, customer purchase behavior

#### 2. Customer Analytics
```lookml
explore: customer_analytics {
  sql_always_where: ${is_current} = true ;;
  join: customer_orders {...}
}
```
**Use Cases**: CLV analysis, segmentation, retention

#### 3. Marketing Performance
```lookml
explore: marketing_performance {
  join: performance_date {...}
  join: channels {...}
}
```
**Use Cases**: ROAS analysis, campaign optimization, channel comparison

#### 4. Website Analytics
```lookml
explore: website_analytics {
  join: session_date {...}
}
```
**Use Cases**: Traffic analysis, conversion optimization, user behavior

#### 5. Executive Overview
Combines multiple fact tables for C-level reporting with cross-functional metrics.

#### 6. Attribution Analysis
Advanced explore for multi-touch attribution with customer journey mapping.

### Join Patterns

All explores follow consistent patterns:
- **Time joins**: Always through date dimension
- **Dimension joins**: Via surrogate keys
- **Cardinality**: Properly defined relationships
- **Field selection**: Curated field lists to avoid confusion

## Dashboards

### 1. Executive Overview Dashboard

**Purpose**: High-level business performance for C-suite

**Key Elements**:
- 7 KPI tiles (Revenue, Orders, AOV, Margin, CAC, ROAS, Conversion)
- Revenue trend analysis
- Top products by revenue
- Marketing efficiency scatter plot
- Conversion funnel

**Filters**: Date range (default: 30 days)

### 2. Sales & Orders Analytics

**Purpose**: Detailed sales performance analysis

**Key Elements**:
- Sales KPIs with period comparisons
- Daily sales trend (dual-axis)
- Geographic analysis
- Customer concentration
- Order size distribution

**Filters**: Date range, Product vendor, Country

### 3. Marketing & Attribution

**Purpose**: Marketing performance and attribution analysis

**Key Elements**:
- Marketing KPIs (Spend, Conversions, ROAS, CPA)
- Platform performance comparison
- Campaign performance matrix
- Attribution mix pie chart
- Top campaigns by ROAS

**Filters**: Date range, Platform, Campaign status

### 4. Data Quality Monitoring

**Purpose**: Pipeline health and data quality tracking

**Key Elements**:
- Quality KPIs with conditional formatting
- Pipeline health trend
- Source health status
- Data flow efficiency
- Error and warning summary

**Filters**: Date range, Data source, Data layer

## Best Practices

### Development Workflow

1. **Use Version Control**: Always develop in a Git branch
2. **Test Thoroughly**: Validate explores before deploying
3. **Document Changes**: Update view descriptions
4. **Follow Naming Conventions**: 
   - Views: `{layer}_{type}_{name}`
   - Dimensions: `snake_case`
   - Measures: `descriptive_names`

### Performance Optimization

1. **Use Persistent Derived Tables** for complex calculations
2. **Implement Datagroups** for caching:
```lookml
datagroup: nightly_refresh {
  sql_trigger: SELECT CURRENT_DATE() ;;
  max_cache_age: "24 hours"
}
```

3. **Aggregate Awareness**: Create aggregate tables for common queries
4. **Index Hints**: Add BigQuery clustering hints in SQL

### Security Best Practices

1. **Row-Level Security**: Implement access filters
```lookml
access_filter: {
  field: customers.country
  user_attribute: country
}
```

2. **Field-Level Security**: Use `hidden: yes` for sensitive fields
3. **Model Permissions**: Set appropriate model access

### Maintenance Guidelines

1. **Regular Validation**: Run LookML validator weekly
2. **Usage Analytics**: Monitor explore usage
3. **Performance Monitoring**: Track query execution times
4. **Documentation Updates**: Keep README current

## Deployment Guide

### Production Deployment Checklist

- [ ] **Validate LookML**: No errors in validator
- [ ] **Test All Explores**: Verify data accuracy
- [ ] **Check Permissions**: Appropriate access controls
- [ ] **Update Documentation**: Current with changes
- [ ] **Performance Test**: Large date ranges
- [ ] **Create Change Log**: Document modifications

### Deployment Steps

1. **Development Environment**:
```bash
git checkout -b feature/new-analysis
# Make changes
lookml validate
git add .
git commit -m "Add new analysis"
git push origin feature/new-analysis
```

2. **Pull Request Review**:
   - Code review by team lead
   - Test in Looker dev mode
   - Validate against production data

3. **Production Deployment**:
   - Merge to main branch
   - Deploy to production in Looker
   - Verify explores and dashboards
   - Monitor for errors

### Rollback Procedure

If issues arise:
1. Revert to previous commit in Git
2. Deploy previous version in Looker
3. Investigate issues in development
4. Re-deploy after fixes

## Advanced Features

### Custom Visualizations

Add custom visualizations:
```javascript
// In custom_visualizations/
looker.plugins.visualizations.add({
  id: "custom_funnel",
  label: "Custom Funnel",
  options: {...}
})
```

### API Integration

Access via Looker API:
```python
# Python example
import looker_sdk

sdk = looker_sdk.init40()
look = sdk.run_look(look_id=123, result_format="json")
```

### Scheduling and Alerts

Set up automated delivery:
1. Create Look or Dashboard
2. Set schedule (daily, weekly, monthly)
3. Configure alerts for thresholds
4. Set delivery format (PDF, CSV, Excel)

## Troubleshooting

### Common Issues

1. **"Unknown field" errors**: Check view includes in model
2. **Join errors**: Verify relationship cardinality
3. **Permission denied**: Check connection credentials
4. **Slow queries**: Review BigQuery execution plan

### Debug Mode

Enable SQL debugging:
```lookml
# In model file
sql_trigger_value: SELECT 1 ;; # Forces cache refresh
```

View generated SQL in Explore SQL tab.

## Support and Resources

- **LookML Reference**: https://docs.looker.com/reference/lookml-quick-reference
- **BigQuery Optimization**: Review clustering and partitioning
- **Community Forum**: Looker Community for best practices
- **Internal Support**: Contact your Looker administrator

---

Copyright © 2025 Rittman Analytics. All rights reserved.