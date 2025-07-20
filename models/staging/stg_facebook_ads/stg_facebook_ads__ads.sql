{{ config(
    materialized='table'
) }}

WITH ad_history AS (
    SELECT * FROM {{ source('facebook_ads_raw', 'ad_history') }}
),

basic_ad AS (
    SELECT * FROM {{ source('facebook_ads_raw', 'basic_ad') }}
),

ads_simple AS (
    SELECT
        ad_id,
        ad_name,
        0 AS ad_set_id,
        0 AS campaign_id,
        0 AS creative_id,
        account_id,
        '' AS conversion_domain,
        date AS updated_time,
        
        -- Performance metrics from basic_ad
        impressions,
        inline_link_clicks AS clicks,
        spend,
        reach,
        frequency,
        0 AS conversions,
        0 AS conversion_value,
        
        -- Calculated metrics
        SAFE_DIVIDE(inline_link_clicks, NULLIF(impressions, 0)) AS ctr,
        SAFE_DIVIDE(spend, NULLIF(inline_link_clicks, 0)) AS cpc,
        SAFE_DIVIDE(spend, NULLIF(impressions, 0)) * 1000 AS cpm,
        
        -- Performance classification
        CASE 
            WHEN spend >= 100 THEN 'high_spend'
            WHEN spend >= 50 THEN 'medium_spend'
            WHEN spend > 0 THEN 'low_spend'
            ELSE 'no_spend'
        END AS spend_tier,
        
        -- Metadata
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS model_updated_at
        
    FROM basic_ad
)

SELECT * FROM ads_simple
ORDER BY ad_id