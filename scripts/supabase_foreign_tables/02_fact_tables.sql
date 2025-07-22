-- Supabase Foreign Table DDLs for Fact Tables
-- Server: bigquery_server (configured with dataset analytics_ecommerce_ecommerce)
-- Project: ra-development
-- Location: europe-west2

-- Drop existing foreign tables if they exist
DROP FOREIGN TABLE IF EXISTS public.fact_orders CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_order_items CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_sessions CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_events CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_customer_journey CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_marketing_performance CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_email_marketing CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_social_posts CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_data_quality CASCADE;
DROP FOREIGN TABLE IF EXISTS public.fact_ad_spend CASCADE;

-- Create fact_orders foreign table (enhanced version)
CREATE FOREIGN TABLE public.fact_orders (
    order_key text,
    customer_key text,
    channel_key text,
    order_date_key text,
    processed_date_key text,
    cancelled_date_key text,
    order_id bigint,
    order_name text,
    customer_id bigint,
    customer_email text,
    order_created_at timestamp,
    order_updated_at timestamp,
    order_processed_at timestamp,
    order_cancelled_at timestamp,
    financial_status text,
    fulfillment_status text,
    order_total_price numeric,
    subtotal_price numeric,
    total_tax numeric,
    total_discounts numeric,
    shipping_cost numeric,
    order_adjustment_amount numeric,
    refund_subtotal numeric,
    refund_tax numeric,
    calculated_order_total numeric,
    total_line_discounts numeric,
    total_discount_amount numeric,
    line_item_count integer,
    unique_product_count integer,
    total_quantity integer,
    avg_line_price numeric,
    max_line_price numeric,
    min_line_price numeric,
    discount_count integer,
    order_value_category text,
    source_name text,
    processing_method text,
    referring_site text,
    landing_site_base_url text,
    order_note text,
    channel_source_medium text,
    shipping_company text,
    tracking_company text,
    tracking_number text,
    shipping_address_first_name text,
    shipping_address_last_name text,
    shipping_address_company text,
    shipping_address_phone text,
    shipping_address_address_1 text,
    shipping_address_address_2 text,
    shipping_address_city text,
    shipping_address_province text,
    shipping_address_province_code text,
    shipping_address_country text,
    shipping_address_country_code text,
    shipping_address_zip text,
    is_cancelled boolean,
    has_refund boolean,
    is_multi_product_order boolean,
    has_discount boolean,
    discount_rate numeric,
    tax_rate numeric,
    shipping_rate numeric,
    net_order_value numeric,
    net_subtotal numeric,
    net_tax numeric,
    hours_to_process numeric,
    hours_to_cancellation numeric,
    order_time_of_day text,
    order_day_type text,
    warehouse_updated_at timestamp
)
SERVER bigquery_server
OPTIONS (
    table 'fact_orders',
    location 'europe-west2'
);

-- Create fact_order_items foreign table (new granular table)
CREATE FOREIGN TABLE public.fact_order_items (
    order_item_key text,
    order_key text,
    order_id bigint,
    line_item_id bigint,
    customer_key text,
    product_key text,
    order_date_key text,
    channel_key text,
    order_number text,
    financial_status text,
    fulfillment_status text,
    utm_source text,
    utm_medium text,
    utm_campaign text,
    traffic_source text,
    device_category text,
    geo_country text,
    line_item_quantity integer,
    unit_price_usd numeric,
    line_item_total_usd numeric,
    line_item_discount_usd numeric,
    line_item_tax_usd numeric,
    product_cost_usd numeric,
    line_item_gross_margin_usd numeric,
    is_first_order boolean,
    order_sequence_number integer
)
SERVER bigquery_server
OPTIONS (
    table 'fact_order_items',
    location 'europe-west2'
);

-- Create fact_sessions foreign table (renamed from fact_ga4_sessions)
CREATE FOREIGN TABLE public.fact_sessions (
    session_key text,
    session_id text,
    user_pseudo_id text,
    session_date_key text,
    channel_key text,
    session_start_time timestamp,
    session_end_time timestamp,
    session_duration_minutes numeric,
    device_category text,
    browser text,
    operating_system text,
    geo_country text,
    geo_region text,
    geo_city text,
    page_views integer,
    unique_pages_viewed integer,
    events_count integer,
    scroll_events integer,
    engagement_time_seconds numeric,
    has_purchase boolean,
    has_add_to_cart boolean,
    has_checkout boolean,
    purchase_value_usd numeric,
    session_type text,
    is_bounce boolean,
    engagement_score numeric,
    conversion_probability numeric
)
SERVER bigquery_server
OPTIONS (
    table 'fact_sessions',
    location 'europe-west2'
);

-- Create fact_events foreign table
CREATE FOREIGN TABLE public.fact_events (
    event_key text,
    session_key text,
    event_date_key text,
    user_pseudo_id text,
    session_id text,
    event_timestamp timestamp,
    event_name text,
    event_category text,
    page_path text,
    page_title text,
    page_referrer text,
    scroll_depth_pct integer,
    time_on_page_seconds numeric,
    ecommerce_value_usd numeric,
    transaction_id text,
    item_count integer,
    event_value numeric,
    custom_parameter_1 text,
    custom_parameter_2 text,
    is_conversion_event boolean,
    engagement_weight numeric
)
SERVER bigquery_server
OPTIONS (
    table 'fact_events',
    location 'europe-west2'
);

-- Create fact_customer_journey foreign table
CREATE FOREIGN TABLE public.fact_customer_journey (
    journey_key text,
    customer_key text,
    order_key text,
    session_key text,
    channel_key text,
    touchpoint_date_key text,
    conversion_date_key text,
    touchpoint_sequence integer,
    days_to_conversion integer,
    session_duration_minutes numeric,
    page_views integer,
    engagement_score numeric,
    conversion_value_usd numeric,
    attribution_weight numeric,
    first_touch_attribution numeric,
    last_touch_attribution numeric,
    linear_attribution numeric,
    time_decay_attribution numeric,
    position_based_attribution numeric,
    journey_complexity text,
    conversion_timeline text,
    is_converting_session boolean,
    is_first_touch boolean,
    is_last_touch boolean
)
SERVER bigquery_server
OPTIONS (
    table 'fact_customer_journey',
    location 'europe-west2'
);

-- Create fact_marketing_performance foreign table
CREATE FOREIGN TABLE public.fact_marketing_performance (
    marketing_key text,
    activity_date date,
    platform text,
    marketing_type text,
    content_type text,
    content_name text,
    utm_source text,
    utm_medium text,
    spend_amount numeric,
    revenue numeric,
    profit numeric,
    return_on_ad_spend numeric,
    impressions integer,
    clicks integer,
    conversions integer,
    likes integer,
    comments integer,
    shares integer,
    saves integer,
    total_interactions integer,
    overall_engagement_rate numeric,
    cost_per_click numeric,
    click_through_rate numeric,
    cost_per_acquisition numeric,
    engagement_rate numeric,
    performance_tier text,
    channel_category text,
    performance_score numeric,
    created_at timestamp,
    updated_at timestamp
)
SERVER bigquery_server
OPTIONS (
    table 'fact_marketing_performance',
    location 'europe-west2'
);

-- Create fact_email_marketing foreign table
CREATE FOREIGN TABLE public.fact_email_marketing (
    email_marketing_key text,
    campaign_key text,
    event_date_key text,
    person_id text,
    email_address text,
    event_type text,
    campaign_send_time timestamp,
    event_timestamp timestamp,
    emails_delivered integer,
    emails_opened integer,
    emails_clicked integer,
    emails_bounced integer,
    emails_marked_spam integer,
    unsubscribes integer,
    orders integer,
    revenue numeric,
    open_rate numeric,
    click_rate numeric,
    conversion_rate numeric,
    engagement_score numeric,
    customer_tier text,
    email_client text,
    device_category text,
    geo_country text
)
SERVER bigquery_server
OPTIONS (
    table 'fact_email_marketing',
    location 'europe-west2'
);

-- Create fact_social_posts foreign table
CREATE FOREIGN TABLE public.fact_social_posts (
    social_post_key text,
    post_date_key text,
    platform text,
    post_id text,
    account_id text,
    post_type text,
    content_type text,
    post_created_date timestamp,
    caption_text text,
    hashtag_count integer,
    mention_count integer,
    impressions integer,
    reach integer,
    likes integer,
    comments integer,
    shares integer,
    saves integer,
    total_engagements integer,
    engagement_rate numeric,
    video_views integer,
    video_completion_rate numeric,
    story_taps_forward integer,
    story_taps_back integer,
    story_exits integer,
    engagement_score numeric,
    performance_tier text,
    is_promoted boolean,
    promotion_spend_usd numeric
)
SERVER bigquery_server
OPTIONS (
    table 'fact_social_posts',
    location 'europe-west2'
);

-- Create fact_ad_spend foreign table
CREATE FOREIGN TABLE public.fact_ad_spend (
    ad_spend_key text,
    date_day date,
    platform text,
    account_id text,
    account_name text,
    campaign_id text,
    campaign_name text,
    ad_group_id text,
    ad_group_name text,
    ad_id text,
    ad_name text,
    utm_source text,
    utm_medium text,
    utm_campaign_mapped text,
    total_clicks integer,
    total_impressions integer,
    total_spend numeric,
    total_conversions numeric,
    total_conversions_value numeric,
    cost_per_click numeric,
    click_through_rate numeric,
    return_on_ad_spend_platform numeric,
    created_at timestamp,
    updated_at timestamp
)
SERVER bigquery_server
OPTIONS (
    table 'fact_ad_spend',
    location 'europe-west2'
);

-- Create fact_data_quality foreign table
CREATE FOREIGN TABLE public.fact_data_quality (
    data_quality_key text,
    report_date_key text,
    data_source text,
    source_rows integer,
    staging_rows integer,
    integration_rows integer,
    warehouse_rows integer,
    staging_flow_pct numeric,
    integration_flow_pct numeric,
    warehouse_flow_pct numeric,
    source_test_pass_rate numeric,
    staging_test_pass_rate numeric,
    integration_test_pass_rate numeric,
    warehouse_test_pass_rate numeric,
    overall_test_pass_rate numeric,
    data_completeness_pct numeric,
    data_freshness_hours numeric,
    schema_drift_detected boolean,
    duplicate_records_count integer,
    null_key_violations integer,
    referential_integrity_violations integer,
    overall_pipeline_health_score numeric,
    data_quality_rating text,
    pipeline_efficiency_rating text
)
SERVER bigquery_server
OPTIONS (
    table 'fact_data_quality',
    location 'europe-west2'
);