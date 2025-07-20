{{ config(
    materialized='table'
) }}

WITH user_history AS (
    SELECT * FROM {{ source('instagram_business_raw', 'user_history') }}
),

users_cleaned AS (
    SELECT
        id AS user_id,
        ig_id,
        name AS account_name,
        username,
        website,
        
        -- Account metrics
        followers_count,
        follows_count,
        media_count,
        
        -- Calculated metrics
        SAFE_DIVIDE(follows_count, NULLIF(followers_count, 0)) AS follows_to_followers_ratio,
        SAFE_DIVIDE(media_count, NULLIF(followers_count, 0)) * 1000 AS media_per_thousand_followers,
        
        -- Account classification
        CASE 
            WHEN followers_count >= 100000 THEN 'mega_influencer'
            WHEN followers_count >= 10000 THEN 'macro_influencer'
            WHEN followers_count >= 1000 THEN 'micro_influencer'
            ELSE 'nano_influencer'
        END AS influencer_tier,
        
        -- Engagement potential
        CASE 
            WHEN SAFE_DIVIDE(media_count, NULLIF(followers_count, 0)) > 0.1 THEN 'high_activity'
            WHEN SAFE_DIVIDE(media_count, NULLIF(followers_count, 0)) > 0.05 THEN 'medium_activity'
            ELSE 'low_activity'
        END AS content_activity_level,
        
        -- Metadata
        _fivetran_id,
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM user_history
)

SELECT * FROM users_cleaned
ORDER BY followers_count DESC