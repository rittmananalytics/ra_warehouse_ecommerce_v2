{{ config(
    materialized='table'
) }}

-- This model provides a simple summary of our data pipeline
WITH data_summary AS (
    -- Count key source tables
    SELECT 'Shopify' AS data_source, 'source' AS layer, 
           (SELECT COUNT(*) FROM {{ ref('order') }}) +
           (SELECT COUNT(*) FROM {{ ref('customer') }}) +
           (SELECT COUNT(*) FROM {{ ref('product') }}) +
           (SELECT COUNT(*) FROM {{ ref('order_line') }}) AS total_rows,
           4 AS table_count
    
    UNION ALL
    SELECT 'Google Analytics 4', 'source', 
           (SELECT COUNT(*) FROM {{ ref('events_sample') }}) AS total_rows,
           1 AS table_count
    
    UNION ALL
    SELECT 'Google Ads', 'source',
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_google_ads.campaign_history`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_google_ads.ad_group_history`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_google_ads.campaign_stats`) AS total_rows,
           3 AS table_count
    
    UNION ALL
    SELECT 'Facebook Ads', 'source',
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_facebook_ads.account_history`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_facebook_ads.campaign_history`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_facebook_ads.basic_ad`) AS total_rows,
           3 AS table_count
           
    UNION ALL
    SELECT 'Pinterest Ads', 'source',
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_pinterest_ads.advertiser_history`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_pinterest_ads.campaign_history`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_pinterest_ads.ad_group_report`) AS total_rows,
           3 AS table_count
           
    UNION ALL
    SELECT 'Instagram Business', 'source',
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_instagram_business.user_history`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_instagram_business.media_insights`) AS total_rows,
           2 AS table_count
           
    UNION ALL
    SELECT 'Klaviyo', 'source',
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_klaviyo.person`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_klaviyo.campaign`) +
           (SELECT COUNT(*) FROM `{{ target.project }}.analytics_ecommerce_klaviyo.event`) AS total_rows,
           3 AS table_count
    
    -- Count staging tables
    UNION ALL
    SELECT 'Shopify', 'staging',
           (SELECT COUNT(*) FROM {{ ref('stg_shopify_ecommerce__orders') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_shopify_ecommerce__customers') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_shopify_ecommerce__products') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_shopify_ecommerce__order_lines') }}) AS total_rows,
           4 AS table_count
    
    UNION ALL
    SELECT 'Google Analytics 4', 'staging',
           (SELECT COUNT(*) FROM {{ ref('stg_ga4_events__page_view') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_ga4_events__purchase') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_ga4_events__add_to_cart') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_ga4_events__view_item') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_ga4_events__begin_checkout') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_ga4_events__session_start') }}) AS total_rows,
           6 AS table_count
    
    UNION ALL
    SELECT 'Google Ads', 'staging',
           (SELECT COUNT(*) FROM {{ ref('stg_google_ads__campaigns') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_google_ads__ad_groups') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_google_ads__ads') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_google_ads__keywords') }}) AS total_rows,
           4 AS table_count
    
    UNION ALL
    SELECT 'Facebook Ads', 'staging',
           (SELECT COUNT(*) FROM {{ ref('stg_facebook_ads__campaigns') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_facebook_ads__ad_sets') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_facebook_ads__ads') }}) AS total_rows,
           3 AS table_count
    
    UNION ALL
    SELECT 'Pinterest Ads', 'staging',
           (SELECT COUNT(*) FROM {{ ref('stg_pinterest_ads__campaigns') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_pinterest_ads__ad_groups') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_pinterest_ads__advertisers') }}) AS total_rows,
           3 AS table_count
    
    UNION ALL
    SELECT 'Instagram Business', 'staging',
           (SELECT COUNT(*) FROM {{ ref('stg_instagram_business__users') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_instagram_business__media_insights') }}) AS total_rows,
           2 AS table_count
    
    UNION ALL
    SELECT 'Klaviyo', 'staging',
           (SELECT COUNT(*) FROM {{ ref('stg_klaviyo__event') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_klaviyo__campaign') }}) +
           (SELECT COUNT(*) FROM {{ ref('stg_klaviyo__person') }}) AS total_rows,
           3 AS table_count
    
    -- Count integration tables
    UNION ALL
    SELECT 'Shopify', 'integration',
           (SELECT COUNT(*) FROM {{ ref('int_orders') }}) +
           (SELECT COUNT(*) FROM {{ ref('int_customers') }}) AS total_rows,
           2 AS table_count
    
    UNION ALL
    SELECT 'Google Analytics 4', 'integration',
           (SELECT COUNT(*) FROM {{ ref('int_events') }}) +
           (SELECT COUNT(*) FROM {{ ref('int_sessions') }}) AS total_rows,
           2 AS table_count
    
    UNION ALL
    SELECT 'Klaviyo', 'integration',
           (SELECT COUNT(*) FROM {{ ref('int_email_events') }}) +
           (SELECT COUNT(*) FROM {{ ref('int_email_campaign_performance') }}) AS total_rows,
           2 AS table_count
           
    UNION ALL
    SELECT 'Google Ads', 'integration',
           (SELECT COUNT(*) FROM {{ ref('int_campaigns') }} WHERE platform = 'google_ads') AS total_rows,
           1 AS table_count
           
    UNION ALL
    SELECT 'Facebook Ads', 'integration',
           (SELECT COUNT(*) FROM {{ ref('int_campaigns') }} WHERE platform = 'facebook_ads') AS total_rows,
           1 AS table_count
           
    UNION ALL
    SELECT 'Pinterest Ads', 'integration',
           (SELECT COUNT(*) FROM {{ ref('int_campaigns') }} WHERE platform = 'pinterest_ads') AS total_rows,
           1 AS table_count
           
    UNION ALL
    SELECT 'Multi-Source', 'integration',
           (SELECT COUNT(*) FROM {{ ref('int_channels_enhanced') }}) AS total_rows,
           1 AS table_count
    
    -- Count warehouse tables
    UNION ALL
    SELECT 'Shopify', 'warehouse',
           (SELECT COUNT(*) FROM {{ ref('wh_fact_orders') }}) +
           (SELECT COUNT(*) FROM {{ ref('wh_dim_customers') }}) +
           (SELECT COUNT(*) FROM {{ ref('wh_dim_products') }}) AS total_rows,
           3 AS table_count
    
    UNION ALL
    SELECT 'Google Analytics 4', 'warehouse',
           (SELECT COUNT(*) FROM {{ ref('wh_fact_ga4_sessions') }}) +
           (SELECT COUNT(*) FROM {{ ref('wh_fact_events') }}) +
           (SELECT COUNT(*) FROM {{ ref('wh_fact_customer_journey') }}) AS total_rows,
           3 AS table_count
           
    UNION ALL
    SELECT 'Instagram Business', 'warehouse',
           (SELECT COUNT(*) FROM {{ ref('wh_fact_social_posts') }}) AS total_rows,
           1 AS table_count
           
    UNION ALL
    SELECT 'Klaviyo', 'warehouse',
           (SELECT COUNT(*) FROM {{ ref('wh_fact_email_marketing') }}) AS total_rows,
           1 AS table_count
           
    UNION ALL
    SELECT 'Multi-Source', 'warehouse',
           (SELECT COUNT(*) FROM {{ ref('wh_fact_ad_spend') }}) +
           (SELECT COUNT(*) FROM {{ ref('wh_fact_ad_attribution') }}) +
           (SELECT COUNT(*) FROM {{ ref('wh_fact_marketing_performance') }}) +
           (SELECT COUNT(*) FROM {{ ref('wh_dim_channels_enhanced') }}) AS total_rows,
           4 AS table_count
),

-- Pivot the data to get source, staging, integration, warehouse by data source
pivoted_data AS (
    SELECT
        data_source,
        SUM(CASE WHEN layer = 'source' THEN total_rows ELSE 0 END) AS source_rows,
        SUM(CASE WHEN layer = 'staging' THEN total_rows ELSE 0 END) AS staging_rows,
        SUM(CASE WHEN layer = 'integration' THEN total_rows ELSE 0 END) AS integration_rows,
        SUM(CASE WHEN layer = 'warehouse' THEN total_rows ELSE 0 END) AS warehouse_rows,
        
        SUM(CASE WHEN layer = 'source' THEN table_count ELSE 0 END) AS source_table_count,
        SUM(CASE WHEN layer = 'staging' THEN table_count ELSE 0 END) AS staging_table_count,
        SUM(CASE WHEN layer = 'integration' THEN table_count ELSE 0 END) AS integration_table_count,
        SUM(CASE WHEN layer = 'warehouse' THEN table_count ELSE 0 END) AS warehouse_table_count
    FROM data_summary
    GROUP BY data_source
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['data_source']) }} AS pipeline_metadata_key,
        data_source,
        
        -- Row counts
        source_rows,
        staging_rows,
        integration_rows,
        warehouse_rows,
        
        -- Table counts  
        source_table_count,
        staging_table_count,
        integration_table_count,
        warehouse_table_count,
        
        -- Flow-through percentages
        CASE WHEN source_rows > 0 THEN ROUND(100.0 * staging_rows / source_rows, 2) ELSE 0 END AS staging_flow_pct,
        CASE WHEN source_rows > 0 THEN ROUND(100.0 * integration_rows / source_rows, 2) ELSE 0 END AS integration_flow_pct,
        CASE WHEN source_rows > 0 THEN ROUND(100.0 * warehouse_rows / source_rows, 2) ELSE 0 END AS warehouse_flow_pct,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM pivoted_data
)

SELECT * FROM final
ORDER BY source_rows DESC