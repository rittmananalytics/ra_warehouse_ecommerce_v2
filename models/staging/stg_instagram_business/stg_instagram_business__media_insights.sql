{{ config(
    materialized='table'
) }}

WITH media_insights AS (
    SELECT * FROM {{ source('instagram_business_raw', 'media_insights') }}
),

media_insights_cleaned AS (
    SELECT
        id AS media_id,
        like_count,
        comment_count,
        carousel_album_engagement,
        carousel_album_reach,
        carousel_album_saved,
        
        -- Calculated engagement metrics
        like_count + comment_count AS total_engagement,
        SAFE_DIVIDE(comment_count, NULLIF(like_count, 0)) AS comment_to_like_ratio,
        
        -- Media performance classification
        CASE 
            WHEN like_count + comment_count >= 200 THEN 'high_performing'
            WHEN like_count + comment_count >= 100 THEN 'medium_performing'
            WHEN like_count + comment_count >= 50 THEN 'low_performing'
            ELSE 'poor_performing'
        END AS performance_tier,
        
        -- Engagement type analysis
        CASE 
            WHEN SAFE_DIVIDE(comment_count, NULLIF(like_count, 0)) > 0.3 THEN 'conversation_driven'
            WHEN SAFE_DIVIDE(comment_count, NULLIF(like_count, 0)) > 0.1 THEN 'balanced_engagement'
            ELSE 'like_heavy'
        END AS engagement_type,
        
        -- Carousel specific metrics (if applicable)
        CASE WHEN carousel_album_engagement IS NOT NULL THEN TRUE ELSE FALSE END AS is_carousel,
        COALESCE(carousel_album_engagement, 0) AS carousel_engagement,
        COALESCE(carousel_album_reach, 0) AS carousel_reach,
        COALESCE(carousel_album_saved, 0) AS carousel_saves,
        
        -- Metadata
        _fivetran_id,
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM media_insights
)

SELECT * FROM media_insights_cleaned
ORDER BY total_engagement DESC