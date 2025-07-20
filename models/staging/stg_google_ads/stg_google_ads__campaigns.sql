{{ config(
    materialized='table'
) }}

WITH campaign_history AS (
    SELECT * FROM {{ source('google_ads_raw', 'campaign_history') }}
),

campaign_stats AS (
    SELECT * FROM {{ source('google_ads_raw', 'campaign_stats') }}
),

campaigns_with_stats AS (
    SELECT
        h.id AS campaign_id,
        h.name AS campaign_name,
        h.status AS campaign_status,
        h.start_date,
        h.end_date,
        h.customer_id,
        h.advertising_channel_type,
        h.serving_status,
        
        -- Performance metrics from stats (aggregated)
        SUM(COALESCE(s.clicks, 0)) AS total_clicks,
        SUM(COALESCE(s.impressions, 0)) AS total_impressions,
        SUM(COALESCE(s.cost_micros, 0)) / 1000000.0 AS total_cost,
        SUM(COALESCE(s.conversions, 0)) AS total_conversions,
        SUM(COALESCE(s.conversions_value, 0)) AS total_conversion_value,
        
        -- Calculated metrics
        SAFE_DIVIDE(SUM(COALESCE(s.clicks, 0)), NULLIF(SUM(COALESCE(s.impressions, 0)), 0)) AS ctr,
        SAFE_DIVIDE(SUM(COALESCE(s.cost_micros, 0)) / 1000000.0, NULLIF(SUM(COALESCE(s.clicks, 0)), 0)) AS cpc,
        SAFE_DIVIDE(SUM(COALESCE(s.cost_micros, 0)) / 1000000.0, NULLIF(SUM(COALESCE(s.impressions, 0)), 0)) * 1000 AS cpm,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM campaign_history h
    LEFT JOIN campaign_stats s ON h.id = s.id
    GROUP BY 1,2,3,4,5,6,7,8
)

SELECT * FROM campaigns_with_stats
ORDER BY campaign_name