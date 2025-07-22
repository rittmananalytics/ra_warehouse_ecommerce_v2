# Supabase Foreign Table DDLs

This directory contains the DDL scripts to create Supabase foreign tables that connect to the BigQuery data warehouse.

## Files

1. **01_dim_tables.sql** - Creates all dimension table foreign tables:
   - dim_date
   - dim_customers (with SCD Type 2 columns)
   - dim_products (with SCD Type 2 columns)
   - dim_channels (renamed from dim_channels_enhanced)
   - dim_email_campaigns

2. **02_fact_tables.sql** - Creates all fact table foreign tables:
   - fact_orders (enhanced with channel attribution)
   - fact_order_items (new granular order line items table)
   - fact_sessions (renamed from fact_ga4_sessions)
   - fact_events
   - fact_customer_journey
   - fact_marketing_performance
   - fact_email_marketing
   - fact_social_posts
   - fact_data_quality

3. **03_execute_all.sql** - Master script to execute all DDLs in order

## Configuration

All foreign tables are configured with:
- **Server**: bigquery_server (must be pre-configured with dataset analytics_ecommerce_ecommerce)
- **Project**: ra-development  
- **Location**: europe-west2

Note: The dataset is specified in the server configuration, not in the individual table OPTIONS.

## Key Changes from Previous Version

1. **New Tables Added**:
   - `fact_order_items` - Granular order line item details
   - `dim_email_campaigns` - Email campaign dimensions

2. **Tables Renamed**:
   - `fact_ga4_sessions` → `fact_sessions`
   - `dim_channels_enhanced` → `dim_channels`

3. **Tables Removed**:
   - `fact_orders_enhanced` - Merged enhancements into main `fact_orders` table

4. **Enhanced Columns**:
   - `fact_orders` now includes `channel_key` for direct channel attribution
   - SCD Type 2 columns added to `dim_customers` and `dim_products`

## Usage

To create all foreign tables in Supabase:

```sql
-- Option 1: Execute the master script
\i /path/to/03_execute_all.sql

-- Option 2: Execute individual scripts
\i /path/to/01_dim_tables.sql
\i /path/to/02_fact_tables.sql
```

## Verification

After creating the foreign tables, verify they're accessible:

```sql
-- Check all foreign tables
SELECT 
    foreign_table_schema,
    foreign_table_name,
    foreign_server_name
FROM information_schema.foreign_tables
WHERE foreign_table_schema = 'public'
ORDER BY foreign_table_name;

-- Test a sample query
SELECT COUNT(*) FROM public.fact_orders;
```