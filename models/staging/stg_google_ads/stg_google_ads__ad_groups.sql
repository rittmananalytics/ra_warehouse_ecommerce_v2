{{ config(
    materialized='table'
) }}

WITH ad_group_history AS (
    SELECT * FROM {{ source('google_ads_raw', 'ad_group_history') }}
),

ad_groups AS (
    SELECT
        id AS ad_group_id,
        name AS ad_group_name,
        status AS ad_group_status,
        campaign_id,
        type AS ad_group_type,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM ad_group_history
)

SELECT * FROM ad_groups
ORDER BY campaign_id, ad_group_name