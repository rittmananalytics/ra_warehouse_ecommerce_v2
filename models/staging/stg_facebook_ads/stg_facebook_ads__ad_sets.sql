{{ config(
    materialized='table'
) }}

WITH ad_set_history AS (
    SELECT * FROM {{ source('facebook_ads_raw', 'ad_set_history') }}
),

ad_sets AS (
    SELECT
        id AS ad_set_id,
        name AS ad_set_name,
        status AS ad_set_status,
        campaign_id,
        account_id,
        start_time,
        end_time,
        daily_budget,
        budget_remaining,
        optimization_goal,
        bid_strategy,
        
        -- Budget analysis
        CASE 
            WHEN daily_budget IS NOT NULL THEN 'daily_budget'
            ELSE 'no_budget_set'
        END AS budget_type,
        
        COALESCE(daily_budget, 0) AS budget_amount,
        
        -- Optimization classification
        CASE 
            WHEN optimization_goal IN ('LINK_CLICKS', 'LANDING_PAGE_VIEWS') THEN 'traffic_focused'
            WHEN optimization_goal IN ('CONVERSIONS', 'VALUE') THEN 'conversion_focused'
            WHEN optimization_goal IN ('REACH', 'IMPRESSIONS', 'BRAND_AWARENESS') THEN 'awareness_focused'
            ELSE 'other'
        END AS optimization_category,
        
        -- Metadata
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM ad_set_history
)

SELECT * FROM ad_sets
ORDER BY budget_amount DESC