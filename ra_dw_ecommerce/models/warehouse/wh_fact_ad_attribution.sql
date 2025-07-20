{{ config(
    materialized='table',
    alias='fact_ad_attribution'
) }}

WITH ad_spend AS (
    SELECT 
        date_day AS spend_date,
        platform,
        utm_source,
        utm_medium,
        -- Aggregate ad-level data to daily platform totals for attribution
        SUM(total_spend) AS total_spend,
        SUM(total_clicks) AS total_clicks,
        SUM(total_impressions) AS total_impressions,
        COUNT(DISTINCT campaign_name) AS campaign_count,
        STRING_AGG(DISTINCT campaign_name, ', ' ORDER BY campaign_name) AS campaign_names
    FROM {{ ref('wh_fact_ad_spend') }}
    GROUP BY 1, 2, 3, 4
),

shopify_orders AS (
    SELECT
        DATE(order_created_at) AS order_date,
        source_name,
        COUNT(*) AS total_orders,
        SUM(order_total_price) AS total_revenue,
        SUM(line_item_count) AS total_items_sold,
        AVG(order_total_price) AS avg_order_value
    FROM {{ ref('wh_fact_orders') }}
    WHERE source_name IN ('google', 'facebook', 'pinterest')
    GROUP BY 1, 2
),

-- Simple date-based attribution for demonstration
attribution_base AS (
    SELECT 
        COALESCE(ads.spend_date, orders.order_date) AS attribution_date,
        COALESCE(ads.platform, 
                CASE WHEN orders.source_name = 'google' THEN 'google_ads'
                     WHEN orders.source_name = 'facebook' THEN 'facebook_ads'
                     WHEN orders.source_name = 'pinterest' THEN 'pinterest_ads'
                END) AS platform,
        COALESCE(ads.utm_source, orders.source_name) AS utm_source,
        ads.utm_medium,
        ads.campaign_names,
        ads.campaign_count,
        
        -- Ad metrics
        COALESCE(ads.total_spend, 0) AS ad_spend,
        COALESCE(ads.total_clicks, 0) AS ad_clicks,
        COALESCE(ads.total_impressions, 0) AS ad_impressions,
        
        -- Shopify metrics
        COALESCE(orders.total_orders, 0) AS shopify_orders,
        COALESCE(orders.total_revenue, 0) AS shopify_revenue,
        COALESCE(orders.total_items_sold, 0) AS items_sold,
        COALESCE(orders.avg_order_value, 0) AS avg_order_value
        
    FROM ad_spend ads
    FULL OUTER JOIN shopify_orders orders
        ON ads.spend_date = orders.order_date
        AND ((ads.utm_source = 'google' AND orders.source_name = 'google')
             OR (ads.utm_source = 'facebook' AND orders.source_name = 'facebook')
             OR (ads.utm_source = 'pinterest' AND orders.source_name = 'pinterest'))
),

final_attribution AS (
    SELECT
        attribution_date,
        platform,
        utm_source,
        utm_medium,
        campaign_names,
        campaign_count,
        ad_spend,
        ad_clicks,
        ad_impressions,
        shopify_orders,
        shopify_revenue,
        items_sold,
        avg_order_value,
        
        -- Calculate key performance metrics
        SAFE_DIVIDE(ad_spend, ad_clicks) AS cost_per_click,
        SAFE_DIVIDE(ad_clicks, ad_impressions) AS click_through_rate,
        SAFE_DIVIDE(shopify_revenue, ad_spend) AS return_on_ad_spend,
        SAFE_DIVIDE(ad_spend, shopify_orders) AS cost_per_acquisition,
        SAFE_DIVIDE(shopify_revenue, shopify_orders) AS revenue_per_order
        
    FROM attribution_base
    WHERE attribution_date IS NOT NULL
)

SELECT
    -- Generate surrogate key
    {{ dbt_utils.generate_surrogate_key(['attribution_date', 'platform']) }} AS attribution_key,
    attribution_date,
    platform,
    utm_source,
    utm_medium,
    campaign_names,
    campaign_count,
    ad_spend,
    ad_clicks,
    ad_impressions,
    shopify_orders,
    shopify_revenue,
    items_sold,
    avg_order_value,
    cost_per_click,
    click_through_rate,
    return_on_ad_spend,
    cost_per_acquisition,
    revenue_per_order,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM final_attribution
ORDER BY attribution_date DESC, ad_spend DESC