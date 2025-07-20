{{ config(
    materialized='table',
    alias='fact_ad_spend'
) }}

WITH ad_level_data AS (
    -- Get ad-level data for platforms that support it (Facebook, Pinterest)
    SELECT
        date_day,
        platform,
        account_id,
        account_name,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        ad_id,
        ad_name,
        clicks,
        impressions,
        spend,
        conversions,
        conversions_value
    FROM {{ ref('ad_reporting__ad_report') }}
),

ad_group_only_data AS (
    -- Get ad group-level data for Google Ads (which doesn't have ad-level data)
    SELECT
        date_day,
        platform,
        account_id,
        account_name,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        CAST(NULL AS STRING) AS ad_id,
        CAST(NULL AS STRING) AS ad_name,
        clicks,
        impressions,
        spend,
        conversions,
        conversions_value
    FROM {{ ref('ad_reporting__ad_group_report') }}
    WHERE platform = 'google_ads'  -- Only get Google Ads from ad group report
),

ad_spend_daily AS (
    SELECT * FROM ad_level_data
    UNION ALL
    SELECT * FROM ad_group_only_data
),

ad_spend_with_utm AS (
    SELECT 
        ads.*,
        -- Map ad platform to UTM source/medium for attribution
        CASE 
            WHEN ads.platform = 'google_ads' THEN 'google'
            WHEN ads.platform = 'facebook_ads' THEN 'facebook'
            WHEN ads.platform = 'pinterest_ads' THEN 'pinterest'
            ELSE ads.platform
        END AS utm_source,
        CASE 
            WHEN ads.platform = 'google_ads' THEN 'cpc'
            WHEN ads.platform = 'facebook_ads' THEN 'social'
            WHEN ads.platform = 'pinterest_ads' THEN 'social'
            ELSE 'paid'
        END AS utm_medium,
        LOWER(ads.campaign_name) AS utm_campaign_mapped
    FROM ad_spend_daily ads
),

-- Aggregate to ad level for detailed attribution
ad_spend AS (
    SELECT
        date_day,
        platform,
        account_id,
        account_name,
        campaign_id,
        campaign_name,
        ad_group_id,
        ad_group_name,
        ad_id,
        ad_name,
        utm_source,
        utm_medium,
        utm_campaign_mapped,
        SUM(clicks) AS total_clicks,
        SUM(impressions) AS total_impressions,
        SUM(spend) AS total_spend,
        SUM(conversions) AS total_conversions,
        SUM(conversions_value) AS total_conversions_value,
        -- Calculate cost per click and other metrics
        SAFE_DIVIDE(SUM(spend), SUM(clicks)) AS cost_per_click,
        SAFE_DIVIDE(SUM(clicks), SUM(impressions)) AS click_through_rate,
        SAFE_DIVIDE(SUM(conversions_value), SUM(spend)) AS return_on_ad_spend_platform
    FROM ad_spend_with_utm
    GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
)

SELECT
    -- Generate surrogate key
    {{ dbt_utils.generate_surrogate_key(['date_day', 'platform', 'campaign_id', 'ad_group_id', 'ad_id']) }} AS ad_spend_key,
    date_day,
    platform,
    account_id,
    account_name,
    campaign_id,
    campaign_name,
    ad_group_id,
    ad_group_name,
    ad_id,
    ad_name,
    utm_source,
    utm_medium,
    utm_campaign_mapped,
    total_clicks,
    total_impressions,
    total_spend,
    total_conversions,
    total_conversions_value,
    cost_per_click,
    click_through_rate,
    return_on_ad_spend_platform,
    CURRENT_TIMESTAMP() AS created_at,
    CURRENT_TIMESTAMP() AS updated_at
FROM ad_spend
ORDER BY date_day DESC, total_spend DESC