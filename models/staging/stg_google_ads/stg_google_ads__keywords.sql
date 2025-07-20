{{ config(
    materialized='table'
) }}

WITH keyword_stats AS (
    SELECT * FROM {{ source('google_ads_raw', 'keyword_stats') }}
),

keywords_performance AS (
    SELECT
        ad_group_criterion_criterion_id AS keyword_id,
        _fivetran_id AS keyword_ref_id,
        ad_group_id,
        campaign_id,
        customer_id,
        date AS performance_date,
        
        -- Performance metrics
        SUM(COALESCE(clicks, 0)) AS total_clicks,
        SUM(COALESCE(impressions, 0)) AS total_impressions,
        SUM(COALESCE(cost_micros, 0)) / 1000000.0 AS total_cost,
        SUM(COALESCE(conversions, 0)) AS total_conversions,
        SUM(COALESCE(conversions_value, 0)) AS total_conversion_value,
        
        -- Calculated metrics
        SAFE_DIVIDE(SUM(COALESCE(clicks, 0)), NULLIF(SUM(COALESCE(impressions, 0)), 0)) AS ctr,
        SAFE_DIVIDE(SUM(COALESCE(cost_micros, 0)) / 1000000.0, NULLIF(SUM(COALESCE(clicks, 0)), 0)) AS cpc,
        SAFE_DIVIDE(SUM(COALESCE(conversions, 0)), NULLIF(SUM(COALESCE(clicks, 0)), 0)) AS conversion_rate,
        
        -- Keyword performance classification
        CASE 
            WHEN SUM(COALESCE(conversions, 0)) > 0 THEN 'converting'
            WHEN SUM(COALESCE(clicks, 0)) > 10 THEN 'high_traffic'
            WHEN SUM(COALESCE(clicks, 0)) > 0 THEN 'low_traffic'
            ELSE 'no_traffic'
        END AS performance_tier,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM keyword_stats
    GROUP BY 1,2,3,4,5,6
)

SELECT * FROM keywords_performance
ORDER BY total_cost DESC