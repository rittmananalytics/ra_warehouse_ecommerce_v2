-- PostgreSQL Foreign Tables for BigQuery Analytics Warehouse
-- Generated from actual BigQuery table definitions

-- Foreign table for dim_categories
DROP FOREIGN TABLE IF EXISTS dim_categories CASCADE;

CREATE FOREIGN TABLE dim_categories (
    category_key BIGINT,
    original_category_name TEXT,
    category_name TEXT,
    category_source TEXT,
    category_level BIGINT,
    parent_category TEXT,
    product_count BIGINT,
    vendor_count BIGINT,
    category_size TEXT,
    is_multi_vendor_category BOOLEAN,
    is_primary_category BOOLEAN,
    is_official_category BOOLEAN,
    category_strategy TEXT,
    strategy_priority BIGINT,
    category_scale TEXT,
    parent_category_sort_order BIGINT,
    category_classification TEXT,
    business_impact TEXT,
    has_valid_name BOOLEAN,
    has_parent_category BOOLEAN,
    has_products BOOLEAN,
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'dim_categories',
    location 'europe-west2'
);

-- Foreign table for dim_channels
DROP FOREIGN TABLE IF EXISTS dim_channels CASCADE;

CREATE FOREIGN TABLE dim_channels (
    channel_key BIGINT,
    channel_id TEXT,
    channel_source TEXT,
    channel_medium TEXT,
    channel_campaign TEXT,
    channel_data_source TEXT,
    channel_group TEXT,
    attribution_type TEXT,
    unique_users BIGINT,
    total_events BIGINT,
    sessions BIGINT,
    page_view_users BIGINT,
    product_view_users BIGINT,
    add_to_cart_users BIGINT,
    checkout_users BIGINT,
    purchase_users BIGINT,
    ga4_purchase_value DOUBLE PRECISION,
    ga4_purchases BIGINT,
    total_orders BIGINT,
    unique_customers BIGINT,
    total_revenue DOUBLE PRECISION,
    avg_order_value DOUBLE PRECISION,
    first_order_date TIMESTAMP,
    last_order_date TIMESTAMP,
    combined_revenue DOUBLE PRECISION,
    combined_transactions BIGINT,
    session_conversion_rate DOUBLE PRECISION,
    cart_conversion_rate DOUBLE PRECISION,
    user_conversion_rate DOUBLE PRECISION,
    revenue_per_session DOUBLE PRECISION,
    revenue_per_customer DOUBLE PRECISION,
    channel_tier TEXT,
    traffic_volume_tier TEXT,
    is_paid_channel BOOLEAN,
    is_direct_channel BOOLEAN,
    is_organic_channel BOOLEAN,
    has_digital_attribution BOOLEAN,
    has_commerce_attribution BOOLEAN,
    channel_priority_score BIGINT,
    channel_maturity TEXT,
    performance_segment TEXT,
    funnel_performance TEXT,
    channel_health TEXT,
    roi_efficiency TEXT,
    attribution_completeness TEXT,
    strategic_importance TEXT,
    has_known_source BOOLEAN,
    has_known_medium BOOLEAN,
    has_digital_activity BOOLEAN,
    has_commerce_activity BOOLEAN,
    has_revenue_attribution BOOLEAN,
    has_conversion_data BOOLEAN,
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'dim_channels',
    location 'europe-west2'
);

-- Foreign table for dim_customer_metrics
DROP FOREIGN TABLE IF EXISTS dim_customer_metrics CASCADE;

CREATE FOREIGN TABLE dim_customer_metrics (
    customer_metrics_key BIGINT,
    customer_key BIGINT,
    customer_id BIGINT,
    customer_email TEXT,
    full_name TEXT,
    customer_created_at TIMESTAMP,
    customer_segment TEXT,
    customer_lifecycle_stage TEXT,
    total_orders BIGINT,
    total_revenue NUMERIC,
    avg_order_value NUMERIC,
    min_order_value NUMERIC,
    max_order_value NUMERIC,
    order_value_std_dev BIGINT,
    first_order_date TIMESTAMP,
    most_recent_order_date TIMESTAMP,
    days_since_first_order BIGINT,
    days_since_last_order BIGINT,
    customer_lifespan_days BIGINT,
    avg_days_between_orders DOUBLE PRECISION,
    unique_products_purchased BIGINT,
    total_items_purchased BIGINT,
    avg_items_per_order DOUBLE PRECISION,
    orders_with_returns BIGINT,
    total_refund_amount NUMERIC,
    orders_with_discounts BIGINT,
    total_discount_amount DOUBLE PRECISION,
    avg_discount_rate DOUBLE PRECISION,
    total_sessions BIGINT,
    total_active_days BIGINT,
    total_page_views BIGINT,
    total_items_viewed BIGINT,
    total_add_to_cart_events BIGINT,
    total_engagement_minutes DOUBLE PRECISION,
    avg_sessions_to_convert DOUBLE PRECISION,
    avg_days_to_convert DOUBLE PRECISION,
    converting_sessions BIGINT,
    converted_orders BIGINT,
    most_common_journey_type BIGINT,
    most_common_conversion_timeline BIGINT,
    recency BIGINT,
    frequency BIGINT,
    monetary NUMERIC,
    recency_score BIGINT,
    frequency_score BIGINT,
    monetary_score BIGINT,
    rfm_segment TEXT,
    historical_clv NUMERIC,
    purchase_rate DOUBLE PRECISION,
    predicted_annual_orders DOUBLE PRECISION,
    churn_probability DOUBLE PRECISION,
    predicted_clv_2_year DOUBLE PRECISION,
    customer_value_tier TEXT,
    digital_engagement_level TEXT,
    at_risk_churn BOOLEAN,
    high_return_rate BOOLEAN,
    high_churn_risk BOOLEAN,
    one_time_buyer_risk BOOLEAN,
    rfm_customer_segment TEXT,
    clv_tier TEXT,
    customer_health_score BIGINT,
    recommended_marketing_action TEXT,
    acquisition_efficiency TEXT,
    cross_sell_upsell_potential TEXT,
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'dim_customer_metrics',
    location 'europe-west2'
);

-- Foreign table for dim_customers
DROP FOREIGN TABLE IF EXISTS dim_customers CASCADE;

CREATE FOREIGN TABLE dim_customers (
    customer_key BIGINT,
    customer_id BIGINT,
    customer_email TEXT,
    first_name TEXT,
    last_name TEXT,
    full_name TEXT,
    phone BIGINT,
    customer_created_at TIMESTAMP,
    customer_updated_at TIMESTAMP,
    customer_state BIGINT,
    city BIGINT,
    state_province BIGINT,
    state_province_code BIGINT,
    country BIGINT,
    country_code BIGINT,
    postal_code BIGINT,
    accepts_marketing TEXT,
    shopify_lifetime_value NUMERIC,
    shopify_order_count BIGINT,
    calculated_lifetime_value DOUBLE PRECISION,
    calculated_order_count BIGINT,
    avg_order_value DOUBLE PRECISION,
    first_order_date TIMESTAMP,
    last_order_date TIMESTAMP,
    days_since_first_order BIGINT,
    days_since_last_order BIGINT,
    customer_segment TEXT,
    customer_lifecycle_stage TEXT,
    customer_value_tier TEXT,
    recency_segment TEXT,
    aov_segment TEXT,
    region TEXT,
    has_email BOOLEAN,
    has_phone BOOLEAN,
    has_address BOOLEAN,
    has_full_name BOOLEAN,
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'dim_customers',
    location 'europe-west2'
);

-- Foreign table for dim_date
DROP FOREIGN TABLE IF EXISTS dim_date CASCADE;

CREATE FOREIGN TABLE dim_date (
    date_key BIGINT,
    date_actual TIMESTAMP,
    year_number BIGINT,
    year_name TEXT,
    quarter_number BIGINT,
    quarter_name TEXT,
    quarter_code TEXT,
    month_number BIGINT,
    month_name TEXT,
    month_short_name TEXT,
    month_year_name TEXT,
    month_year_code TEXT,
    week_number BIGINT,
    iso_week_number BIGINT,
    week_start_date TIMESTAMP,
    week_end_date TIMESTAMP,
    day_of_month BIGINT,
    day_of_year BIGINT,
    day_of_week_number BIGINT,
    day_of_week_name TEXT,
    day_of_week_short_name TEXT,
    is_weekday BOOLEAN,
    is_weekend BOOLEAN,
    is_current_day BOOLEAN,
    is_current_week BOOLEAN,
    is_current_month BOOLEAN,
    is_current_quarter BOOLEAN,
    is_current_year BOOLEAN,
    is_previous_day BOOLEAN,
    is_previous_week BOOLEAN,
    is_previous_month BOOLEAN,
    is_previous_quarter BOOLEAN,
    is_previous_year BOOLEAN,
    fiscal_year BIGINT,
    fiscal_quarter BIGINT,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'dim_date',
    location 'europe-west2'
);

-- Foreign table for dim_products
DROP FOREIGN TABLE IF EXISTS dim_products CASCADE;

CREATE FOREIGN TABLE dim_products (
    product_key BIGINT,
    product_id BIGINT,
    product_title TEXT,
    product_handle TEXT,
    product_type TEXT,
    vendor TEXT,
    product_created_at TIMESTAMP,
    product_updated_at TIMESTAMP,
    product_published_at TIMESTAMP,
    product_status TEXT,
    product_tags TEXT,
    option_1_name BIGINT,
    option_1_value BIGINT,
    option_2_name BIGINT,
    option_2_value BIGINT,
    option_3_name BIGINT,
    option_3_value BIGINT,
    total_orders BIGINT,
    total_line_items BIGINT,
    total_quantity_sold BIGINT,
    total_revenue DOUBLE PRECISION,
    avg_selling_price DOUBLE PRECISION,
    max_selling_price DOUBLE PRECISION,
    min_selling_price DOUBLE PRECISION,
    total_discounts_given DOUBLE PRECISION,
    avg_discount_percent DOUBLE PRECISION,
    total_inventory BIGINT,
    avg_variant_inventory DOUBLE PRECISION,
    variant_count BIGINT,
    product_performance_category TEXT,
    inventory_status_category TEXT,
    is_active BOOLEAN,
    is_published BOOLEAN,
    has_inventory BOOLEAN,
    has_sales BOOLEAN,
    revenue_tier TEXT,
    price_tier TEXT,
    sales_volume_tier TEXT,
    discount_tier TEXT,
    product_lifecycle_stage TEXT,
    has_variants BOOLEAN,
    has_tags BOOLEAN,
    has_options BOOLEAN,
    has_vendor BOOLEAN,
    effective_from TIMESTAMP,
    effective_to TIMESTAMP,
    is_current BOOLEAN,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'dim_products',
    location 'europe-west2'
);

-- Foreign table for dim_social_content
DROP FOREIGN TABLE IF EXISTS dim_social_content CASCADE;

CREATE FOREIGN TABLE dim_social_content (
    content_key TEXT,
    post_id BIGINT,
    platform TEXT,
    media_type TEXT,
    content_category TEXT,
    caption_length_category TEXT,
    hashtag_strategy TEXT,
    mention_strategy TEXT,
    day_of_week BIGINT,
    day_type TEXT,
    time_of_day TEXT,
    hour_of_day BIGINT,
    is_story BOOLEAN,
    is_comment_enabled BOOLEAN,
    has_media BOOLEAN,
    has_thumbnail BOOLEAN,
    performance_tier TEXT,
    recency_category TEXT,
    days_since_posted BIGINT,
    caption_length BIGINT,
    hashtag_count BIGINT,
    mention_count BIGINT,
    total_engagement BIGINT,
    engagement_rate DOUBLE PRECISION,
    post_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'dim_social_content',
    location 'europe-west2'
);

-- Foreign table for fact_ad_attribution
DROP FOREIGN TABLE IF EXISTS fact_ad_attribution CASCADE;

CREATE FOREIGN TABLE fact_ad_attribution (
    attribution_key TEXT,
    attribution_date DATE,
    platform TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    campaign_names TEXT,
    campaign_count BIGINT,
    ad_spend DOUBLE PRECISION,
    ad_clicks BIGINT,
    ad_impressions BIGINT,
    shopify_orders BIGINT,
    shopify_revenue DOUBLE PRECISION,
    items_sold BIGINT,
    avg_order_value DOUBLE PRECISION,
    cost_per_click DOUBLE PRECISION,
    click_through_rate DOUBLE PRECISION,
    return_on_ad_spend DOUBLE PRECISION,
    cost_per_acquisition DOUBLE PRECISION,
    revenue_per_order DOUBLE PRECISION,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_ad_attribution',
    location 'europe-west2'
);

-- Foreign table for fact_ad_spend
DROP FOREIGN TABLE IF EXISTS fact_ad_spend CASCADE;

CREATE FOREIGN TABLE fact_ad_spend (
    ad_spend_key TEXT,
    date_day DATE,
    platform TEXT,
    account_id TEXT,
    account_name TEXT,
    campaign_id TEXT,
    campaign_name TEXT,
    ad_group_id TEXT,
    ad_group_name TEXT,
    ad_id TEXT,
    ad_name TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign_mapped TEXT,
    total_clicks BIGINT,
    total_impressions BIGINT,
    total_spend DOUBLE PRECISION,
    total_conversions DOUBLE PRECISION,
    total_conversions_value DOUBLE PRECISION,
    cost_per_click DOUBLE PRECISION,
    click_through_rate DOUBLE PRECISION,
    return_on_ad_spend_platform DOUBLE PRECISION,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_ad_spend',
    location 'europe-west2'
);

-- Foreign table for fact_customer_journey
DROP FOREIGN TABLE IF EXISTS fact_customer_journey CASCADE;

CREATE FOREIGN TABLE fact_customer_journey (
    journey_key BIGINT,
    customer_key BIGINT,
    order_key BIGINT,
    session_key BIGINT,
    session_date_key BIGINT,
    order_date_key BIGINT,
    shopify_customer_id BIGINT,
    shopify_order_id BIGINT,
    ga4_transaction_id TEXT,
    session_id TEXT,
    converting_user_pseudo_id TEXT,
    shopify_order_timestamp TIMESTAMP,
    ga4_purchase_timestamp BIGINT,
    session_date DATE,
    session_start_timestamp BIGINT,
    days_to_conversion BIGINT,
    session_sequence_number BIGINT,
    session_type TEXT,
    session_duration_minutes DOUBLE PRECISION,
    page_views BIGINT,
    items_viewed BIGINT,
    add_to_cart_events BIGINT,
    begin_checkout_events BIGINT,
    session_revenue DOUBLE PRECISION,
    hours_since_previous_session DOUBLE PRECISION,
    is_converting_session BOOLEAN,
    total_sessions_to_conversion BIGINT,
    total_days_active BIGINT,
    total_page_views BIGINT,
    total_items_viewed BIGINT,
    total_add_to_cart_events BIGINT,
    total_begin_checkout_events BIGINT,
    total_session_duration_minutes DOUBLE PRECISION,
    days_from_first_touch_to_conversion BIGINT,
    days_from_first_product_view BIGINT,
    days_from_first_add_to_cart BIGINT,
    days_from_first_checkout_start BIGINT,
    journey_complexity TEXT,
    conversion_timeline TEXT,
    shopify_order_value NUMERIC,
    avg_pages_per_session DOUBLE PRECISION,
    avg_minutes_per_page DOUBLE PRECISION,
    revenue_per_session NUMERIC,
    revenue_per_page_view NUMERIC,
    journey_view_to_cart_rate DOUBLE PRECISION,
    journey_cart_to_checkout_rate DOUBLE PRECISION,
    journey_checkout_to_purchase_rate DOUBLE PRECISION,
    journey_view_to_purchase_rate DOUBLE PRECISION,
    conversion_behavior_type TEXT,
    attribution_weight DOUBLE PRECISION,
    normalized_attribution_weight DOUBLE PRECISION,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_customer_journey',
    location 'europe-west2'
);

-- Foreign table for fact_data_quality
DROP FOREIGN TABLE IF EXISTS fact_data_quality CASCADE;

CREATE FOREIGN TABLE fact_data_quality (
    data_quality_key TEXT,
    data_source TEXT,
    source_rows BIGINT,
    staging_rows BIGINT,
    integration_rows BIGINT,
    warehouse_rows BIGINT,
    source_table_count BIGINT,
    staging_table_count BIGINT,
    integration_table_count BIGINT,
    warehouse_table_count BIGINT,
    staging_flow_pct DOUBLE PRECISION,
    integration_flow_pct DOUBLE PRECISION,
    warehouse_flow_pct DOUBLE PRECISION,
    source_test_pass_rate DOUBLE PRECISION,
    staging_test_pass_rate DOUBLE PRECISION,
    integration_test_pass_rate DOUBLE PRECISION,
    warehouse_test_pass_rate DOUBLE PRECISION,
    source_quality_score DOUBLE PRECISION,
    staging_quality_score DOUBLE PRECISION,
    integration_quality_score DOUBLE PRECISION,
    warehouse_quality_score DOUBLE PRECISION,
    overall_pipeline_health_score DOUBLE PRECISION,
    total_tests_run BIGINT,
    total_tests_passed DOUBLE PRECISION,
    overall_test_pass_rate DOUBLE PRECISION,
    data_completeness_pct DOUBLE PRECISION,
    pipeline_efficiency_rating TEXT,
    data_quality_rating TEXT,
    report_date DATE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_data_quality',
    location 'europe-west2'
);

-- Foreign table for fact_email_marketing
DROP FOREIGN TABLE IF EXISTS fact_email_marketing CASCADE;

CREATE FOREIGN TABLE fact_email_marketing (
    email_marketing_key TEXT,
    event_date DATE,
    date_key BIGINT,
    campaign_id TEXT,
    flow_id TEXT,
    campaign_name TEXT,
    campaign_subject TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,
    marketing_type TEXT,
    emails_delivered BIGINT,
    emails_opened BIGINT,
    emails_clicked BIGINT,
    emails_marked_spam BIGINT,
    unsubscribes BIGINT,
    orders BIGINT,
    product_orders BIGINT,
    revenue NUMERIC,
    unique_recipients BIGINT,
    unique_openers BIGINT,
    unique_clickers BIGINT,
    unique_converters BIGINT,
    open_rate DOUBLE PRECISION,
    click_rate DOUBLE PRECISION,
    click_to_delivery_rate DOUBLE PRECISION,
    conversion_rate DOUBLE PRECISION,
    revenue_per_email NUMERIC,
    average_order_value NUMERIC,
    unique_open_rate DOUBLE PRECISION,
    unique_click_rate DOUBLE PRECISION,
    unique_conversion_rate DOUBLE PRECISION,
    performance_tier TEXT,
    email_type TEXT,
    engagement_score DOUBLE PRECISION,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_email_marketing',
    location 'europe-west2'
);

-- Foreign table for fact_events
DROP FOREIGN TABLE IF EXISTS fact_events CASCADE;

CREATE FOREIGN TABLE fact_events (
    event_key BIGINT,
    event_date_key BIGINT,
    event_id TEXT,
    user_pseudo_id TEXT,
    event_timestamp BIGINT,
    event_date TEXT,
    event_name TEXT,
    event_category TEXT,
    event_action TEXT,
    event_label TEXT,
    event_value DOUBLE PRECISION,
    currency TEXT,
    item_id TEXT,
    item_name TEXT,
    item_category TEXT,
    device_category TEXT,
    device_brand TEXT,
    device_model TEXT,
    operating_system TEXT,
    browser TEXT,
    country TEXT,
    region TEXT,
    city TEXT,
    traffic_source TEXT,
    traffic_medium TEXT,
    traffic_campaign TEXT,
    funnel_stage TEXT,
    is_ecommerce_event BOOLEAN,
    has_value BOOLEAN,
    event_hour BIGINT,
    event_time_of_day TEXT,
    event_day_type TEXT,
    device_type TEXT,
    geographic_region TEXT,
    traffic_type TEXT,
    event_value_tier TEXT,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_events',
    location 'europe-west2'
);

-- Foreign table for fact_inventory
DROP FOREIGN TABLE IF EXISTS fact_inventory CASCADE;

CREATE FOREIGN TABLE fact_inventory (
    inventory_key BIGINT,
    product_key BIGINT,
    snapshot_date_key BIGINT,
    product_id BIGINT,
    variant_id BIGINT,
    location_id BIGINT,
    location_name TEXT,
    current_stock BIGINT,
    unit_cost DOUBLE PRECISION,
    total_inventory_value DOUBLE PRECISION,
    selling_price NUMERIC,
    gross_margin_per_unit DOUBLE PRECISION,
    requires_shipping BOOLEAN,
    is_tracked BOOLEAN,
    total_quantity_sold BIGINT,
    total_revenue NUMERIC,
    order_frequency BIGINT,
    avg_quantity_per_order DOUBLE PRECISION,
    last_order_date TIMESTAMP,
    first_order_date TIMESTAMP,
    days_with_sales BIGINT,
    inventory_turnover_ratio DOUBLE PRECISION,
    days_of_inventory_remaining DOUBLE PRECISION,
    stock_status TEXT,
    inventory_velocity TEXT,
    inventory_action_needed TEXT,
    inventory_value_tier TEXT,
    product_title TEXT,
    product_type TEXT,
    vendor TEXT,
    product_status TEXT,
    product_performance_category TEXT,
    is_product_active BOOLEAN,
    is_high_turnover BOOLEAN,
    is_out_of_stock BOOLEAN,
    is_low_stock BOOLEAN,
    needs_reorder_soon BOOLEAN,
    is_profitable BOOLEAN,
    potential_revenue NUMERIC,
    potential_gross_margin DOUBLE PRECISION,
    inventory_risk_level TEXT,
    inventory_efficiency_score BIGINT,
    financial_impact_tier TEXT,
    reorder_priority BIGINT,
    snapshot_date DATE,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_inventory',
    location 'europe-west2'
);

-- Foreign table for fact_marketing_performance
DROP FOREIGN TABLE IF EXISTS fact_marketing_performance CASCADE;

CREATE FOREIGN TABLE fact_marketing_performance (
    marketing_key TEXT,
    activity_date DATE,
    platform TEXT,
    marketing_type TEXT,
    content_type TEXT,
    content_name TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    spend_amount DOUBLE PRECISION,
    revenue DOUBLE PRECISION,
    profit DOUBLE PRECISION,
    return_on_ad_spend DOUBLE PRECISION,
    impressions BIGINT,
    clicks BIGINT,
    conversions BIGINT,
    likes BIGINT,
    comments BIGINT,
    shares BIGINT,
    saves BIGINT,
    total_interactions BIGINT,
    overall_engagement_rate DOUBLE PRECISION,
    cost_per_click DOUBLE PRECISION,
    click_through_rate DOUBLE PRECISION,
    cost_per_acquisition DOUBLE PRECISION,
    engagement_rate DOUBLE PRECISION,
    performance_tier TEXT,
    channel_category TEXT,
    performance_score DOUBLE PRECISION,
    source_table TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_marketing_performance',
    location 'europe-west2'
);

-- Foreign table for fact_orders
DROP FOREIGN TABLE IF EXISTS fact_orders CASCADE;

CREATE FOREIGN TABLE fact_orders (
    order_key BIGINT,
    customer_key BIGINT,
    channel_key BIGINT,
    order_date_key BIGINT,
    processed_date_key BIGINT,
    cancelled_date_key BIGINT,
    order_id BIGINT,
    order_name TEXT,
    customer_id BIGINT,
    customer_email TEXT,
    order_created_at TIMESTAMP,
    order_updated_at TIMESTAMP,
    order_processed_at TIMESTAMP,
    order_cancelled_at TIMESTAMP,
    financial_status TEXT,
    fulfillment_status TEXT,
    order_total_price DOUBLE PRECISION,
    subtotal_price DOUBLE PRECISION,
    total_tax DOUBLE PRECISION,
    total_discounts DOUBLE PRECISION,
    shipping_cost DOUBLE PRECISION,
    order_adjustment_amount DOUBLE PRECISION,
    refund_subtotal NUMERIC,
    refund_tax BIGINT,
    calculated_order_total DOUBLE PRECISION,
    total_line_discounts DOUBLE PRECISION,
    total_discount_amount DOUBLE PRECISION,
    line_item_count BIGINT,
    unique_product_count BIGINT,
    total_quantity BIGINT,
    avg_line_price DOUBLE PRECISION,
    max_line_price DOUBLE PRECISION,
    min_line_price DOUBLE PRECISION,
    discount_count BIGINT,
    order_value_category TEXT,
    source_name TEXT,
    processing_method BIGINT,
    referring_site TEXT,
    landing_site_base_url TEXT,
    order_note BIGINT,
    channel_source_medium TEXT,
    shipping_company BIGINT,
    tracking_company BIGINT,
    tracking_number BIGINT,
    shipping_address_first_name BIGINT,
    shipping_address_last_name BIGINT,
    shipping_address_company BIGINT,
    shipping_address_phone BIGINT,
    shipping_address_address_1 BIGINT,
    shipping_address_address_2 BIGINT,
    shipping_address_city BIGINT,
    shipping_address_province BIGINT,
    shipping_address_province_code BIGINT,
    shipping_address_country BIGINT,
    shipping_address_country_code BIGINT,
    shipping_address_zip BIGINT,
    is_cancelled BOOLEAN,
    has_refund BOOLEAN,
    is_multi_product_order BOOLEAN,
    has_discount BOOLEAN,
    discount_rate DOUBLE PRECISION,
    tax_rate DOUBLE PRECISION,
    shipping_rate DOUBLE PRECISION,
    net_order_value DOUBLE PRECISION,
    net_subtotal DOUBLE PRECISION,
    net_tax DOUBLE PRECISION,
    hours_to_process BIGINT,
    hours_to_cancellation BIGINT,
    order_time_of_day TEXT,
    order_day_type TEXT,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_orders',
    location 'europe-west2'
);

-- Foreign table for fact_sessions
DROP FOREIGN TABLE IF EXISTS fact_sessions CASCADE;

CREATE FOREIGN TABLE fact_sessions (
    session_key BIGINT,
    session_date_key BIGINT,
    session_id TEXT,
    user_pseudo_id TEXT,
    session_date DATE,
    session_start_timestamp BIGINT,
    session_end_timestamp BIGINT,
    session_sequence_number BIGINT,
    hours_since_previous_session DOUBLE PRECISION,
    session_duration_seconds DOUBLE PRECISION,
    session_duration_minutes DOUBLE PRECISION,
    session_duration_category TEXT,
    page_views BIGINT,
    unique_pages_viewed BIGINT,
    unique_page_locations BIGINT,
    items_viewed BIGINT,
    unique_items_viewed BIGINT,
    add_to_cart_events BIGINT,
    unique_items_added_to_cart BIGINT,
    begin_checkout_events BIGINT,
    purchase_events BIGINT,
    session_revenue DOUBLE PRECISION,
    avg_purchase_value DOUBLE PRECISION,
    viewed_products BOOLEAN,
    added_to_cart BOOLEAN,
    began_checkout BOOLEAN,
    completed_purchase BOOLEAN,
    session_type TEXT,
    avg_time_per_page DOUBLE PRECISION,
    is_multi_page_session BOOLEAN,
    is_bounce BOOLEAN,
    view_to_cart_rate DOUBLE PRECISION,
    cart_to_checkout_rate DOUBLE PRECISION,
    checkout_to_purchase_rate DOUBLE PRECISION,
    view_to_purchase_rate DOUBLE PRECISION,
    revenue_per_page_view DOUBLE PRECISION,
    revenue_per_item_view DOUBLE PRECISION,
    visitor_type TEXT,
    return_pattern TEXT,
    session_time_of_day TEXT,
    session_day_type TEXT,
    engagement_score BIGINT,
    warehouse_updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_sessions',
    location 'europe-west2'
);

-- Foreign table for fact_social_posts
DROP FOREIGN TABLE IF EXISTS fact_social_posts CASCADE;

CREATE FOREIGN TABLE fact_social_posts (
    social_post_key TEXT,
    platform TEXT,
    content_type TEXT,
    user_id BIGINT,
    username TEXT,
    account_name TEXT,
    post_id BIGINT,
    post_date DATE,
    post_created_at TIMESTAMP,
    media_type TEXT,
    content_category TEXT,
    is_story BOOLEAN,
    is_comment_enabled BOOLEAN,
    caption_length BIGINT,
    hashtag_count BIGINT,
    mention_count BIGINT,
    caption_length_category TEXT,
    total_likes BIGINT,
    total_comments BIGINT,
    total_shares BIGINT,
    total_saves BIGINT,
    total_reach BIGINT,
    total_impressions BIGINT,
    total_views BIGINT,
    engagement_rate DOUBLE PRECISION,
    engagement_rate_impressions DOUBLE PRECISION,
    view_rate DOUBLE PRECISION,
    save_rate DOUBLE PRECISION,
    story_exits BIGINT,
    story_replies BIGINT,
    story_taps_back BIGINT,
    story_taps_forward BIGINT,
    story_exit_rate DOUBLE PRECISION,
    total_engagement BIGINT,
    performance_tier TEXT,
    media_url TEXT,
    post_url TEXT,
    shortcode TEXT,
    thumbnail_url TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
SERVER bigquery_server
OPTIONS (
    table 'fact_social_posts',
    location 'europe-west2'
);