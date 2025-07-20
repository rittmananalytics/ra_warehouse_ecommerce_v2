{{ config(
    materialized='table',
    alias='fact_email_marketing'
) }}

WITH email_events AS (
    SELECT * FROM {{ ref('int_email_events') }}
),

daily_email_metrics AS (
    SELECT
        event_date,
        campaign_id,
        flow_id,
        utm_campaign,
        utm_source,
        utm_medium,
        
        -- Aggregate daily metrics
        SUM(emails_delivered) AS emails_delivered,
        SUM(emails_opened) AS emails_opened,
        SUM(emails_clicked) AS emails_clicked,
        SUM(emails_marked_spam) AS emails_marked_spam,
        SUM(unsubscribes) AS unsubscribes,
        SUM(orders) AS orders,
        SUM(product_orders) AS product_orders,
        SUM(revenue) AS revenue,
        
        -- Unique counts
        COUNT(DISTINCT person_id) AS unique_recipients,
        COUNT(DISTINCT CASE WHEN emails_opened > 0 THEN person_id END) AS unique_openers,
        COUNT(DISTINCT CASE WHEN emails_clicked > 0 THEN person_id END) AS unique_clickers,
        COUNT(DISTINCT CASE WHEN orders > 0 THEN person_id END) AS unique_converters,
        
        -- Campaign info
        MAX(campaign_name) AS campaign_name,
        MAX(campaign_subject) AS campaign_subject
        
    FROM email_events
    GROUP BY 1, 2, 3, 4, 5, 6
),

email_marketing_facts AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['event_date', 'campaign_id', 'flow_id', 'utm_campaign']) }} AS email_marketing_key,
        
        -- Date and campaign identifiers
        event_date,
        CAST(FORMAT_DATE('%Y%m%d', event_date) AS INT64) AS date_key,
        campaign_id,
        flow_id,
        
        -- Campaign details
        campaign_name,
        campaign_subject,
        
        -- Channel attribution
        utm_source,
        utm_medium,
        utm_campaign,
        'email_marketing' AS marketing_type,
        
        -- Email metrics
        emails_delivered,
        emails_opened,
        emails_clicked,
        emails_marked_spam,
        unsubscribes,
        
        -- Conversion metrics
        orders,
        product_orders,
        revenue,
        
        -- Unique metrics
        unique_recipients,
        unique_openers,
        unique_clickers,
        unique_converters,
        
        -- Calculated rates
        SAFE_DIVIDE(emails_opened, NULLIF(emails_delivered, 0)) AS open_rate,
        SAFE_DIVIDE(emails_clicked, NULLIF(emails_opened, 0)) AS click_rate,
        SAFE_DIVIDE(emails_clicked, NULLIF(emails_delivered, 0)) AS click_to_delivery_rate,
        SAFE_DIVIDE(orders, NULLIF(emails_delivered, 0)) AS conversion_rate,
        SAFE_DIVIDE(revenue, NULLIF(emails_delivered, 0)) AS revenue_per_email,
        SAFE_DIVIDE(revenue, NULLIF(orders, 0)) AS average_order_value,
        
        -- Engagement rates
        SAFE_DIVIDE(unique_openers, NULLIF(unique_recipients, 0)) AS unique_open_rate,
        SAFE_DIVIDE(unique_clickers, NULLIF(unique_openers, 0)) AS unique_click_rate,
        SAFE_DIVIDE(unique_converters, NULLIF(unique_recipients, 0)) AS unique_conversion_rate,
        
        -- Performance indicators
        CASE 
            WHEN SAFE_DIVIDE(emails_opened, NULLIF(emails_delivered, 0)) >= 0.25 THEN 'high_performing'
            WHEN SAFE_DIVIDE(emails_opened, NULLIF(emails_delivered, 0)) >= 0.15 THEN 'medium_performing'
            WHEN SAFE_DIVIDE(emails_opened, NULLIF(emails_delivered, 0)) > 0 THEN 'low_performing'
            ELSE 'no_engagement'
        END AS performance_tier,
        
        -- Campaign type classification
        CASE 
            WHEN campaign_id IS NOT NULL AND flow_id IS NULL THEN 'one_time_campaign'
            WHEN campaign_id IS NULL AND flow_id IS NOT NULL THEN 'automated_flow'
            WHEN campaign_id IS NOT NULL AND flow_id IS NOT NULL THEN 'flow_campaign'
            ELSE 'unknown'
        END AS email_type,
        
        -- Engagement score (0-100)
        LEAST(100, GREATEST(0, 
            COALESCE(SAFE_DIVIDE(emails_opened, NULLIF(emails_delivered, 0)) * 40, 0) +
            COALESCE(SAFE_DIVIDE(emails_clicked, NULLIF(emails_delivered, 0)) * 30, 0) +
            COALESCE(SAFE_DIVIDE(orders, NULLIF(emails_delivered, 0)) * 30, 0)
        )) AS engagement_score,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM daily_email_metrics
)

SELECT * FROM email_marketing_facts
ORDER BY event_date DESC, emails_delivered DESC