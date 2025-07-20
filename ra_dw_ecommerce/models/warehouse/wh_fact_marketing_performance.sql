{{ config(
    materialized='table',
    alias='fact_marketing_performance'
) }}

WITH paid_advertising AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['attribution_date', 'platform', "'paid'", 'campaign_names']) }} AS marketing_key,
        attribution_date AS activity_date,
        platform,
        'paid_advertising' AS marketing_type,
        'campaign' AS content_type,
        campaign_names AS content_name,
        utm_source,
        utm_medium,
        
        -- Paid advertising metrics
        ad_spend AS spend_amount,
        ad_clicks AS clicks,
        ad_impressions AS impressions,
        shopify_orders AS conversions,
        shopify_revenue AS revenue,
        cost_per_click,
        click_through_rate,
        return_on_ad_spend,
        cost_per_acquisition,
        
        -- Social engagement metrics (null for paid ads)
        CAST(NULL AS INT64) AS likes,
        CAST(NULL AS INT64) AS comments,
        CAST(NULL AS INT64) AS shares,
        CAST(NULL AS INT64) AS saves,
        CAST(NULL AS FLOAT64) AS engagement_rate,
        CAST(NULL AS STRING) AS performance_tier,
        
        -- Metadata
        'ad_attribution' AS source_table
        
    FROM {{ ref('wh_fact_ad_attribution') }}
),

organic_social AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['post_date', 'platform', "'organic'", 'post_id']) }} AS marketing_key,
        post_date AS activity_date,
        platform,
        'organic_social' AS marketing_type,
        content_category AS content_type,
        CONCAT(media_type, ' - Post ', post_id) AS content_name,
        platform AS utm_source,
        'organic' AS utm_medium,
        
        -- Paid advertising metrics (null/0 for organic)
        0.0 AS spend_amount,
        CAST(NULL AS INT64) AS clicks,
        total_impressions AS impressions,
        CAST(NULL AS INT64) AS conversions,
        0.0 AS revenue,
        CAST(NULL AS FLOAT64) AS cost_per_click,
        CAST(NULL AS FLOAT64) AS click_through_rate,
        CAST(NULL AS FLOAT64) AS return_on_ad_spend,
        CAST(NULL AS FLOAT64) AS cost_per_acquisition,
        
        -- Social engagement metrics
        total_likes AS likes,
        total_comments AS comments,
        total_shares AS shares,
        total_saves AS saves,
        engagement_rate,
        performance_tier,
        
        -- Metadata
        'social_posts' AS source_table
        
    FROM {{ ref('wh_fact_social_posts') }}
),

unified_marketing AS (
    SELECT * FROM paid_advertising
    UNION ALL
    SELECT * FROM organic_social
),

marketing_performance AS (
    SELECT
        marketing_key,
        activity_date,
        platform,
        marketing_type,
        content_type,
        content_name,
        utm_source,
        utm_medium,
        
        -- Financial metrics
        spend_amount,
        revenue,
        revenue - spend_amount AS profit,
        SAFE_DIVIDE(revenue, NULLIF(spend_amount, 0)) AS return_on_ad_spend,
        
        -- Performance metrics
        impressions,
        clicks,
        conversions,
        likes,
        comments,
        shares,
        saves,
        
        -- Calculated engagement
        COALESCE(clicks, 0) + COALESCE(likes, 0) + COALESCE(comments, 0) + COALESCE(shares, 0) AS total_interactions,
        SAFE_DIVIDE(COALESCE(clicks, 0) + COALESCE(likes, 0) + COALESCE(comments, 0), NULLIF(impressions, 0)) AS overall_engagement_rate,
        
        -- Efficiency metrics
        cost_per_click,
        click_through_rate,
        cost_per_acquisition,
        engagement_rate,
        performance_tier,
        
        -- Channel classification
        CASE 
            WHEN platform = 'google_ads' THEN 'Search'
            WHEN platform IN ('facebook_ads', 'instagram') THEN 'Social'
            WHEN platform = 'pinterest_ads' THEN 'Discovery'
            ELSE 'Other'
        END AS channel_category,
        
        -- Performance scoring (1-100)
        CASE 
            WHEN marketing_type = 'paid_advertising' THEN
                LEAST(100, GREATEST(0, 
                    COALESCE(return_on_ad_spend * 20, 0) + 
                    COALESCE(click_through_rate * 1000, 0) +
                    COALESCE(conversions * 10, 0)
                ))
            ELSE
                LEAST(100, GREATEST(0,
                    COALESCE(engagement_rate * 100, 0) +
                    COALESCE((COALESCE(likes, 0) + COALESCE(comments, 0) + COALESCE(shares, 0)) / 10, 0)
                ))
        END AS performance_score,
        
        -- Metadata
        source_table,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM unified_marketing
)

SELECT * FROM marketing_performance
ORDER BY activity_date DESC, performance_score DESC