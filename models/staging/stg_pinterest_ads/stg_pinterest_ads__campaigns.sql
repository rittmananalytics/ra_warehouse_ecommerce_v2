{{ config(
    materialized='table'
) }}

WITH campaign_history AS (
    SELECT * FROM {{ source('pinterest_ads_raw', 'campaign_history') }}
),

ad_group_report AS (
    SELECT * FROM {{ source('pinterest_ads_raw', 'ad_group_report') }}
),

campaigns_with_performance AS (
    SELECT
        h.id AS campaign_id,
        h.name AS campaign_name,
        h.status AS campaign_status,
        h.created_time,
        h.advertiser_id,
        h.objective_type,
        h.start_time,
        h.end_time,
        h.daily_spend_cap_in_micro_currency / 1000000.0 AS daily_spend_cap,
        h.lifetime_spend_cap_in_micro_currency / 1000000.0 AS lifetime_spend_cap,
        
        -- For now, simple campaign data without complex joins
        0 AS total_clicks,
        0 AS total_impressions,
        0 AS total_spend,
        
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