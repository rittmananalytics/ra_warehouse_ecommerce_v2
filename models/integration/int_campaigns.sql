{{ config(
    materialized='table'
) }}

WITH google_ads_campaigns AS (
    SELECT
        campaign_id,
        campaign_name,
        'google_ads' AS platform,
        campaign_status AS status,
        start_date,
        end_date,
        0 AS budget_amount,
        'standard' AS budget_delivery_method,
        'unknown' AS bidding_strategy_type,
        total_cost AS cost,
        total_impressions AS impressions,
        total_clicks AS clicks,
        total_conversions AS conversions,
        total_conversion_value AS conversion_value,
        
        -- Calculated metrics
        total_cost AS cost_usd,
        COALESCE(ctr, 0) AS ctr,
        COALESCE(cpc, 0) AS cpc_usd,
        SAFE_DIVIDE(total_conversions, NULLIF(total_clicks, 0)) AS conversion_rate,
        SAFE_DIVIDE(total_conversion_value, NULLIF(total_conversions, 0)) AS value_per_conversion,
        
        created_at,
        updated_at
        
    FROM {{ ref('stg_google_ads__campaigns') }}
),

facebook_ads_campaigns AS (
    SELECT
        campaign_id,
        campaign_name,
        'facebook_ads' AS platform,
        campaign_status AS status,
        DATE(start_time) AS start_date,
        DATE(stop_time) AS end_date,
        daily_budget AS budget_amount,
        'standard' AS budget_delivery_method,
        'unknown' AS bidding_strategy_type,
        total_spend AS cost,
        total_impressions AS impressions,
        total_clicks AS clicks,
        0 AS conversions,
        0 AS conversion_value,
        
        -- Calculated metrics  
        total_spend AS cost_usd,
        COALESCE(ctr, 0) AS ctr,
        COALESCE(cpc, 0) AS cpc_usd,
        0 AS conversion_rate,
        0 AS value_per_conversion,
        
        created_at,
        updated_at
        
    FROM {{ ref('stg_facebook_ads__campaigns') }}
),

pinterest_ads_campaigns AS (
    SELECT
        campaign_id,
        campaign_name,
        'pinterest_ads' AS platform,
        campaign_status AS status,
        DATE(start_time) AS start_date,
        DATE(end_time) AS end_date,
        daily_spend_cap AS budget_amount,
        'standard' AS budget_delivery_method,
        'unknown' AS bidding_strategy_type,
        total_spend AS cost,
        total_impressions AS impressions,
        total_clicks AS clicks,
        0 AS conversions,
        0 AS conversion_value,
        
        -- Calculated metrics
        total_spend AS cost_usd,
        COALESCE(ctr, 0) AS ctr,
        COALESCE(cpc, 0) AS cpc_usd,
        0 AS conversion_rate,
        0 AS value_per_conversion,
        
        created_at,
        updated_at
        
    FROM {{ ref('stg_pinterest_ads__campaigns') }}
),

unified_campaigns AS (
    SELECT * FROM google_ads_campaigns
    UNION ALL
    SELECT * FROM facebook_ads_campaigns  
    UNION ALL
    SELECT * FROM pinterest_ads_campaigns
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['platform', 'campaign_id']) }} AS campaign_key,
        campaign_id,
        platform,
        campaign_name,
        status,
        start_date,
        end_date,
        budget_amount,
        budget_delivery_method,
        bidding_strategy_type,
        
        -- Performance metrics
        cost_usd,
        impressions,
        clicks,
        conversions,
        conversion_value,
        
        -- Calculated rates
        ctr,
        cpc_usd,
        conversion_rate,
        value_per_conversion,
        
        -- Performance classification
        CASE 
            WHEN ctr >= 0.05 THEN 'high_ctr'
            WHEN ctr >= 0.02 THEN 'medium_ctr'
            WHEN ctr > 0 THEN 'low_ctr'
            ELSE 'no_clicks'
        END AS ctr_performance,
        
        CASE 
            WHEN conversion_rate >= 0.05 THEN 'high_converting'
            WHEN conversion_rate >= 0.02 THEN 'medium_converting'
            WHEN conversion_rate > 0 THEN 'low_converting'
            ELSE 'no_conversions'
        END AS conversion_performance,
        
        -- Campaign categorization
        CASE 
            WHEN LOWER(campaign_name) LIKE '%brand%' THEN 'brand'
            WHEN LOWER(campaign_name) LIKE '%search%' THEN 'search'
            WHEN LOWER(campaign_name) LIKE '%display%' OR LOWER(campaign_name) LIKE '%audience%' THEN 'display'
            WHEN LOWER(campaign_name) LIKE '%shopping%' THEN 'shopping'
            WHEN LOWER(campaign_name) LIKE '%video%' THEN 'video'
            WHEN LOWER(campaign_name) LIKE '%remarketing%' OR LOWER(campaign_name) LIKE '%retarget%' THEN 'remarketing'
            ELSE 'other'
        END AS campaign_type,
        
        -- Budget efficiency score (0-100)
        LEAST(100, GREATEST(0, 
            COALESCE(ctr * 2000, 0) +
            COALESCE(conversion_rate * 1000, 0) +
            CASE WHEN cpc_usd <= 2.0 THEN 20 ELSE 0 END
        )) AS efficiency_score,
        
        -- Metadata
        created_at,
        updated_at,
        CURRENT_TIMESTAMP() AS integrated_at
        
    FROM unified_campaigns
)

SELECT * FROM final
ORDER BY cost_usd DESC, campaign_name