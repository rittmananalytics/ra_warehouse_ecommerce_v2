{{ config(
    materialized='table',
    alias='fact_social_posts'
) }}

WITH instagram_posts AS (
    SELECT
        post_id,
        user_id,
        username,
        account_name,
        DATE(created_timestamp) AS post_date,
        created_timestamp AS post_created_at,
        media_type,
        is_story,
        is_comment_enabled,
        
        -- Content metrics
        post_caption,
        CHAR_LENGTH(post_caption) AS caption_length,
        ARRAY_LENGTH(REGEXP_EXTRACT_ALL(post_caption, r'#\w+')) AS hashtag_count,
        ARRAY_LENGTH(REGEXP_EXTRACT_ALL(post_caption, r'@\w+')) AS mention_count,
        
        -- Engagement metrics (consolidate across content types)
        COALESCE(like_count, 0) + COALESCE(reel_likes, 0) AS total_likes,
        COALESCE(comment_count, 0) + COALESCE(reel_comments, 0) AS total_comments,
        COALESCE(carousel_album_shares, 0) + COALESCE(video_photo_shares, 0) + 
        COALESCE(story_shares, 0) + COALESCE(reel_shares, 0) AS total_shares,
        COALESCE(carousel_album_saved, 0) + COALESCE(video_photo_saved, 0) AS total_saves,
        
        -- Reach and impression metrics
        COALESCE(carousel_album_reach, 0) + COALESCE(video_photo_reach, 0) + 
        COALESCE(story_reach, 0) + COALESCE(reel_reach, 0) AS total_reach,
        COALESCE(carousel_album_impressions, 0) + COALESCE(video_photo_impressions, 0) + 
        COALESCE(story_impressions, 0) AS total_impressions,
        
        -- View metrics (video-specific)
        COALESCE(carousel_album_views, 0) + COALESCE(video_photo_views, 0) + 
        COALESCE(story_views, 0) + COALESCE(reel_views, 0) + 
        COALESCE(video_views, 0) + COALESCE(reel_plays, 0) AS total_views,
        
        -- Story-specific metrics
        COALESCE(story_exits, 0) AS story_exits,
        COALESCE(story_replies, 0) AS story_replies,
        COALESCE(story_taps_back, 0) AS story_taps_back,
        COALESCE(story_taps_forward, 0) AS story_taps_forward,
        
        -- Raw individual metrics for detailed analysis
        like_count,
        comment_count,
        carousel_album_engagement,
        video_photo_engagement,
        reel_total_interactions,
        
        -- URLs and identifiers
        media_url,
        post_url,
        shortcode,
        thumbnail_url
        
    FROM {{ ref('instagram_business__posts') }}
),

social_posts_enhanced AS (
    SELECT
        -- Generate surrogate key
        {{ dbt_utils.generate_surrogate_key(['post_id', 'user_id']) }} AS social_post_key,
        
        -- Platform and account info
        'instagram' AS platform,
        'organic' AS content_type,
        user_id,
        username,
        account_name,
        
        -- Post details
        post_id,
        post_date,
        post_created_at,
        media_type,
        CASE 
            WHEN is_story THEN 'story'
            WHEN media_type = 'VIDEO' THEN 'video'
            WHEN media_type = 'CAROUSEL_ALBUM' THEN 'carousel'
            ELSE 'image'
        END AS content_category,
        is_story,
        is_comment_enabled,
        
        -- Content analysis
        caption_length,
        hashtag_count,
        mention_count,
        CASE 
            WHEN caption_length = 0 THEN 'no_caption'
            WHEN caption_length < 50 THEN 'short'
            WHEN caption_length < 150 THEN 'medium'
            ELSE 'long'
        END AS caption_length_category,
        
        -- Core engagement metrics
        total_likes,
        total_comments,
        total_shares,
        total_saves,
        total_reach,
        total_impressions,
        total_views,
        
        -- Calculated engagement rates
        SAFE_DIVIDE(total_likes + total_comments + total_shares, total_reach) AS engagement_rate,
        SAFE_DIVIDE(total_likes + total_comments, total_impressions) AS engagement_rate_impressions,
        SAFE_DIVIDE(total_views, total_impressions) AS view_rate,
        SAFE_DIVIDE(total_saves, total_reach) AS save_rate,
        
        -- Story-specific
        story_exits,
        story_replies,
        story_taps_back,
        story_taps_forward,
        CASE WHEN is_story THEN SAFE_DIVIDE(story_exits, total_views) END AS story_exit_rate,
        
        -- Total engagement score
        total_likes + total_comments + total_shares + total_saves AS total_engagement,
        
        -- Content performance tier
        CASE 
            WHEN total_likes + total_comments >= 200 THEN 'high_performing'
            WHEN total_likes + total_comments >= 100 THEN 'medium_performing' 
            ELSE 'low_performing'
        END AS performance_tier,
        
        -- URLs for reference
        media_url,
        post_url,
        shortcode,
        thumbnail_url,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM instagram_posts
)

SELECT * FROM social_posts_enhanced
ORDER BY post_created_at DESC