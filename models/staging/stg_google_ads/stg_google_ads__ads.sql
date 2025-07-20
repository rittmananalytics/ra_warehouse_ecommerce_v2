{{ config(
    materialized='table'
) }}

WITH ad_history AS (
    SELECT * FROM {{ source('google_ads_raw', 'ad_history') }}
),

ad_stats AS (
    SELECT * FROM {{ source('google_ads_raw', 'ad_stats') }}
),

ads_with_performance AS (
    SELECT
        h.id AS ad_id,
        h.ad_group_id,
        h.status AS ad_status,
        h.type AS ad_type,
        h.display_url,
        h.final_urls,
        h.updated_at,
        
        -- Performance metrics from stats (aggregated)
        SUM(COALESCE(s.clicks, 0)) AS total_clicks,
        SUM(COALESCE(s.impressions, 0)) AS total_impressions,
        SUM(COALESCE(s.cost_micros, 0)) / 1000000.0 AS total_cost,
        SUM(COALESCE(s.conversions, 0)) AS total_conversions,
        
        -- Calculated metrics
        SAFE_DIVIDE(SUM(COALESCE(s.clicks, 0)), NULLIF(SUM(COALESCE(s.impressions, 0)), 0)) AS ctr,
        SAFE_DIVIDE(SUM(COALESCE(s.cost_micros, 0)) / 1000000.0, NULLIF(SUM(COALESCE(s.clicks, 0)), 0)) AS cpc,
        SAFE_DIVIDE(SUM(COALESCE(s.cost_micros, 0)) / 1000000.0, NULLIF(SUM(COALESCE(s.impressions, 0)), 0)) * 1000 AS cpm,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS model_updated_at
        
    FROM ad_history h
    LEFT JOIN ad_stats s ON h.id = s.ad_id
    GROUP BY 1,2,3,4,5,6,7
)

SELECT * FROM ads_with_performance
ORDER BY total_impressions DESC