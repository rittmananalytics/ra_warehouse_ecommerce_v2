{{ config(
    materialized='table'
) }}

WITH advertiser_history AS (
    SELECT * FROM {{ source('pinterest_ads_raw', 'advertiser_history') }}
),

advertisers_cleaned AS (
    SELECT
        id AS advertiser_id,
        name AS advertiser_name,
        country,
        currency,
        'active' AS status,
        
        -- Advertiser categorization
        CASE 
            WHEN LOWER(name) LIKE '%ecommerce%' OR LOWER(name) LIKE '%retail%' THEN 'ecommerce'
            WHEN LOWER(name) LIKE '%brand%' THEN 'brand'
            WHEN LOWER(name) LIKE '%agency%' THEN 'agency'
            ELSE 'other'
        END AS advertiser_type,
        
        CASE 
            WHEN country IN ('US', 'CA', 'GB', 'AU') THEN 'tier_1'
            WHEN country IN ('DE', 'FR', 'IT', 'ES', 'NL') THEN 'tier_2'
            ELSE 'tier_3'
        END AS market_tier,
        
        -- Account details
        created_time,
        updated_time,
        
        -- Metadata
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS model_updated_at
        
    FROM advertiser_history
)

SELECT * FROM advertisers_cleaned
ORDER BY created_time DESC