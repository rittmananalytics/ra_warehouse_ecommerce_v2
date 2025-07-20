{{ config(
    materialized='table',
    alias='dim_social_content'
) }}

WITH content_analysis AS (
    SELECT
        -- Content identification
        post_id,
        platform,
        media_type,
        content_category,
        
        -- Content characteristics
        caption_length,
        caption_length_category,
        hashtag_count,
        mention_count,
        
        -- Content strategy insights
        CASE 
            WHEN hashtag_count = 0 THEN 'no_hashtags'
            WHEN hashtag_count <= 3 THEN 'minimal_hashtags'
            WHEN hashtag_count <= 10 THEN 'moderate_hashtags'
            ELSE 'heavy_hashtags'
        END AS hashtag_strategy,
        
        CASE 
            WHEN mention_count = 0 THEN 'no_mentions'
            WHEN mention_count <= 2 THEN 'few_mentions'
            ELSE 'many_mentions'
        END AS mention_strategy,
        
        -- Post timing analysis
        post_date,
        EXTRACT(DAYOFWEEK FROM post_date) AS day_of_week,
        EXTRACT(HOUR FROM post_created_at) AS hour_of_day,
        CASE 
            WHEN EXTRACT(DAYOFWEEK FROM post_date) IN (1, 7) THEN 'weekend'
            ELSE 'weekday'
        END AS day_type,
        CASE 
            WHEN EXTRACT(HOUR FROM post_created_at) BETWEEN 6 AND 11 THEN 'morning'
            WHEN EXTRACT(HOUR FROM post_created_at) BETWEEN 12 AND 17 THEN 'afternoon'
            WHEN EXTRACT(HOUR FROM post_created_at) BETWEEN 18 AND 22 THEN 'evening'
            ELSE 'night'
        END AS time_of_day,
        
        -- Content features
        is_story,
        is_comment_enabled,
        CASE WHEN media_url IS NOT NULL THEN TRUE ELSE FALSE END AS has_media,
        CASE WHEN thumbnail_url IS NOT NULL THEN TRUE ELSE FALSE END AS has_thumbnail,
        
        -- Performance indicators
        performance_tier,
        total_engagement,
        engagement_rate,
        
        -- Content recency
        DATE_DIFF(CURRENT_DATE(), post_date, DAY) AS days_since_posted,
        CASE 
            WHEN DATE_DIFF(CURRENT_DATE(), post_date, DAY) <= 7 THEN 'last_week'
            WHEN DATE_DIFF(CURRENT_DATE(), post_date, DAY) <= 30 THEN 'last_month'
            WHEN DATE_DIFF(CURRENT_DATE(), post_date, DAY) <= 90 THEN 'last_quarter'
            ELSE 'older'
        END AS recency_category
        
    FROM {{ ref('wh_fact_social_posts') }}
),

content_dimensions AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['post_id']) }} AS content_key,
        post_id,
        platform,
        
        -- Content type dimensions
        media_type,
        content_category,
        
        -- Content strategy dimensions  
        caption_length_category,
        hashtag_strategy,
        mention_strategy,
        
        -- Timing dimensions
        day_of_week,
        day_type,
        time_of_day,
        hour_of_day,
        
        -- Feature dimensions
        is_story,
        is_comment_enabled,
        has_media,
        has_thumbnail,
        
        -- Performance dimensions
        performance_tier,
        recency_category,
        days_since_posted,
        
        -- Content metrics for analysis
        caption_length,
        hashtag_count,
        mention_count,
        total_engagement,
        engagement_rate,
        
        -- Metadata
        post_date,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM content_analysis
)

SELECT * FROM content_dimensions
ORDER BY post_date DESC