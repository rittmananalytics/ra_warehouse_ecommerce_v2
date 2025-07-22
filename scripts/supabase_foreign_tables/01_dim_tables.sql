-- Supabase Foreign Table DDLs for Dimension Tables
-- Server: bigquery_server (configured with dataset analytics_ecommerce_ecommerce)
-- Project: ra-development
-- Location: europe-west2

-- Drop existing foreign tables if they exist
DROP FOREIGN TABLE IF EXISTS public.dim_date CASCADE;
DROP FOREIGN TABLE IF EXISTS public.dim_customers CASCADE;
DROP FOREIGN TABLE IF EXISTS public.dim_products CASCADE;
DROP FOREIGN TABLE IF EXISTS public.dim_channels CASCADE;
DROP FOREIGN TABLE IF EXISTS public.dim_email_campaigns CASCADE;

-- Create dim_date foreign table
CREATE FOREIGN TABLE public.dim_date (
    date_key text,
    calendar_date date,
    year integer,
    quarter integer,
    month_number integer,
    week integer,
    day_of_year integer,
    day_of_month integer,
    day_of_week integer,
    day_name text,
    month_name text,
    quarter_name text,
    is_weekend boolean,
    is_holiday boolean,
    holiday_name text,
    fiscal_year integer,
    fiscal_quarter integer,
    fiscal_month integer,
    is_last_day_of_month boolean,
    is_last_day_of_quarter boolean,
    is_last_day_of_year boolean
)
SERVER bigquery_server
OPTIONS (
    table 'dim_date',
    location 'europe-west2'
);

-- Create dim_customers foreign table with SCD Type 2 columns
CREATE FOREIGN TABLE public.dim_customers (
    customer_key text,
    customer_id bigint,
    customer_email text,
    customer_first_name text,
    customer_last_name text,
    customer_full_name text,
    customer_created_at timestamp,
    total_spent_usd numeric,
    order_count integer,
    avg_order_value_usd numeric,
    days_since_first_order integer,
    days_since_last_order integer,
    customer_segment text,
    customer_value_tier text,
    is_active_customer boolean,
    churn_risk_score numeric,
    engagement_score numeric,
    predicted_ltv_usd numeric,
    acquisition_channel text,
    first_order_date date,
    last_order_date date,
    valid_from timestamp,
    valid_to timestamp,
    is_current boolean
)
SERVER bigquery_server
OPTIONS (
    table 'dim_customers',
    location 'europe-west2'
);

-- Create dim_products foreign table with SCD Type 2 columns
CREATE FOREIGN TABLE public.dim_products (
    product_key text,
    product_id bigint,
    product_title text,
    product_handle text,
    product_type text,
    vendor text,
    product_status text,
    tags text,
    price numeric,
    cost numeric,
    gross_margin_usd numeric,
    gross_margin_pct numeric,
    total_revenue_usd numeric,
    total_orders integer,
    total_quantity_sold integer,
    avg_order_value_usd numeric,
    performance_tier text,
    revenue_tier text,
    days_since_last_sale integer,
    is_active_seller boolean,
    inventory_status text,
    reorder_point integer,
    valid_from timestamp,
    valid_to timestamp,
    is_current boolean
)
SERVER bigquery_server
OPTIONS (
    table 'dim_products',
    location 'europe-west2'
);

-- Create dim_channels foreign table (renamed from dim_channels_enhanced)
CREATE FOREIGN TABLE public.dim_channels (
    channel_key text,
    utm_source text,
    utm_medium text,
    utm_campaign text,
    channel_name text,
    channel_category text,
    channel_type text,
    is_paid_channel boolean,
    attribution_model text,
    cost_tracking_enabled boolean,
    conversion_tracking_enabled boolean,
    channel_description text
)
SERVER bigquery_server
OPTIONS (
    table 'dim_channels',
    location 'europe-west2'
);

-- Create dim_email_campaigns foreign table
CREATE FOREIGN TABLE public.dim_email_campaigns (
    campaign_key text,
    campaign_id text,
    campaign_name text,
    campaign_subject text,
    from_email text,
    from_name text,
    campaign_type text,
    campaign_category text,
    email_program_type text,
    audience_segment text,
    send_strategy text,
    has_emoji boolean,
    has_personalization boolean,
    automation_trigger text,
    expected_send_volume integer,
    campaign_goals text
)
SERVER bigquery_server
OPTIONS (
    table 'dim_email_campaigns',
    location 'europe-west2'
);