{{ config(
    materialized='table'
) }}

WITH ad_group_report AS (
    SELECT * FROM {{ source('pinterest_ads_raw', 'ad_group_report') }}
),

ad_groups_cleaned AS (
    SELECT
        ad_group_id,
        ad_group_name,
        campaign_id,
        ad_group_status AS status,
        
        -- Performance metrics
        impression_1 AS impressions,
        clickthrough_1 AS clicks,
        SAFE_DIVIDE(spend_in_micro_dollar, 1000000) AS spend,
        total_conversions AS conversions,
        
        -- Calculated metrics
        SAFE_DIVIDE(clickthrough_1, NULLIF(impression_1, 0)) AS ctr,
        SAFE_DIVIDE(SAFE_DIVIDE(spend_in_micro_dollar, 1000000), NULLIF(clickthrough_1, 0)) AS cpc,
        SAFE_DIVIDE(SAFE_DIVIDE(spend_in_micro_dollar, 1000000), NULLIF(impression_1, 0)) * 1000 AS cpm,
        SAFE_DIVIDE(total_conversions, NULLIF(clickthrough_1, 0)) AS conversion_rate,
        
        -- Performance classification
        CASE 
            WHEN SAFE_DIVIDE(spend_in_micro_dollar, 1000000) >= 50 THEN 'high_spend'
            WHEN SAFE_DIVIDE(spend_in_micro_dollar, 1000000) >= 20 THEN 'medium_spend'
            WHEN SAFE_DIVIDE(spend_in_micro_dollar, 1000000) > 0 THEN 'low_spend'
            ELSE 'no_spend'
        END AS spend_tier,
        
        CASE 
            WHEN SAFE_DIVIDE(clickthrough_1, NULLIF(impression_1, 0)) >= 0.02 THEN 'high_ctr'
            WHEN SAFE_DIVIDE(clickthrough_1, NULLIF(impression_1, 0)) >= 0.01 THEN 'medium_ctr'
            WHEN SAFE_DIVIDE(clickthrough_1, NULLIF(impression_1, 0)) > 0 THEN 'low_ctr'
            ELSE 'no_clicks'
        END AS ctr_performance,
        
        -- Targeting categorization
        CASE 
            WHEN LOWER(ad_group_name) LIKE '%interest%' THEN 'interest_targeting'
            WHEN LOWER(ad_group_name) LIKE '%lookalike%' THEN 'lookalike'
            WHEN LOWER(ad_group_name) LIKE '%custom%' THEN 'custom_audience'
            WHEN LOWER(ad_group_name) LIKE '%broad%' THEN 'broad_targeting'
            ELSE 'other'
        END AS targeting_type,
        
        -- Date fields
        date AS report_date,
        
        -- Metadata
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM ad_group_report
)

SELECT * FROM ad_groups_cleaned
ORDER BY spend DESC, ad_group_name