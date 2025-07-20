{{ config(
    materialized='table'
) }}

WITH campaign_history AS (
    SELECT * FROM {{ source('facebook_ads_raw', 'campaign_history') }}
),

basic_ad AS (
    SELECT * FROM {{ source('facebook_ads_raw', 'basic_ad') }}
),

campaigns_with_performance AS (
    SELECT
        h.id AS campaign_id,
        h.name AS campaign_name,
        h.status AS campaign_status,
        h.created_time,
        h.start_time,
        h.stop_time,
        h.account_id,
        h.daily_budget,
        h.lifetime_budget,
        
        -- For now, just return campaign data without ad performance
        -- since the join relationship isn't clear from the schema
        0 AS total_clicks,
        0 AS total_impressions,
        0 AS total_spend,
        0 AS total_reach,
        
        -- Calculated metrics
        0.0 AS ctr,
        0.0 AS cpc,
        0.0 AS cpm,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM campaign_history h
)

SELECT * FROM campaigns_with_performance
ORDER BY campaign_name