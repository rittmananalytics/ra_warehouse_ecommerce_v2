{{ config(
    materialized='table'
) }}

WITH klaviyo_campaigns AS (
    SELECT * FROM {{ ref('klaviyo__campaigns') }}
),

email_events AS (
    SELECT * FROM {{ ref('int_email_events') }}
),

campaign_metrics AS (
    SELECT
        campaign_id,
        campaign_name,
        
        -- Delivery metrics
        SUM(emails_delivered) AS total_emails_delivered,
        SUM(emails_opened) AS total_emails_opened,
        SUM(emails_clicked) AS total_emails_clicked,
        SUM(emails_marked_spam) AS total_emails_marked_spam,
        SUM(unsubscribes) AS total_unsubscribes,
        
        -- Conversion metrics
        SUM(orders) AS total_orders,
        SUM(product_orders) AS total_product_orders,
        SUM(revenue) AS total_revenue,
        
        -- Engagement rates
        SAFE_DIVIDE(SUM(emails_opened), NULLIF(SUM(emails_delivered), 0)) AS open_rate,
        SAFE_DIVIDE(SUM(emails_clicked), NULLIF(SUM(emails_opened), 0)) AS click_rate,
        SAFE_DIVIDE(SUM(emails_clicked), NULLIF(SUM(emails_delivered), 0)) AS click_to_delivery_rate,
        SAFE_DIVIDE(SUM(orders), NULLIF(SUM(emails_delivered), 0)) AS conversion_rate,
        SAFE_DIVIDE(SUM(revenue), NULLIF(SUM(emails_delivered), 0)) AS revenue_per_email,
        
        -- Unique recipients
        COUNT(DISTINCT person_id) AS unique_recipients,
        COUNT(DISTINCT CASE WHEN emails_opened > 0 THEN person_id END) AS unique_openers,
        COUNT(DISTINCT CASE WHEN emails_clicked > 0 THEN person_id END) AS unique_clickers,
        COUNT(DISTINCT CASE WHEN orders > 0 THEN person_id END) AS unique_converters,
        
        -- Campaign timing
        MIN(event_date) AS first_activity_date,
        MAX(event_date) AS last_activity_date
        
    FROM email_events
    WHERE campaign_id IS NOT NULL
    GROUP BY 1, 2
),

campaign_details AS (
    SELECT
        c.campaign_id,
        c.campaign_name,
        c.subject AS campaign_subject,
        c.from_email,
        c.from_name,
        c.campaign_type,
        c.sent_at,
        c.created_at,
        c.updated_at,
        
        -- Metrics from events
        COALESCE(m.total_emails_delivered, 0) AS total_emails_delivered,
        COALESCE(m.total_emails_opened, 0) AS total_emails_opened,
        COALESCE(m.total_emails_clicked, 0) AS total_emails_clicked,
        COALESCE(m.total_emails_marked_spam, 0) AS total_emails_marked_spam,
        COALESCE(m.total_unsubscribes, 0) AS total_unsubscribes,
        COALESCE(m.total_orders, 0) AS total_orders,
        COALESCE(m.total_product_orders, 0) AS total_product_orders,
        COALESCE(m.total_revenue, 0) AS total_revenue,
        
        COALESCE(m.open_rate, 0) AS open_rate,
        COALESCE(m.click_rate, 0) AS click_rate,
        COALESCE(m.click_to_delivery_rate, 0) AS click_to_delivery_rate,
        COALESCE(m.conversion_rate, 0) AS conversion_rate,
        COALESCE(m.revenue_per_email, 0) AS revenue_per_email,
        
        COALESCE(m.unique_recipients, 0) AS unique_recipients,
        COALESCE(m.unique_openers, 0) AS unique_openers,
        COALESCE(m.unique_clickers, 0) AS unique_clickers,
        COALESCE(m.unique_converters, 0) AS unique_converters,
        
        m.first_activity_date,
        m.last_activity_date,
        
        -- Performance categorization
        CASE 
            WHEN m.open_rate >= 0.25 THEN 'high_performing'
            WHEN m.open_rate >= 0.15 THEN 'medium_performing'
            WHEN m.open_rate > 0 THEN 'low_performing'
            ELSE 'no_engagement'
        END AS performance_tier
        
    FROM klaviyo_campaigns c
    LEFT JOIN campaign_metrics m ON c.campaign_id = m.campaign_id
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['campaign_id']) }} AS campaign_key,
        campaign_id,
        campaign_name,
        campaign_subject,
        from_email,
        from_name,
        campaign_type,
        sent_at,
        created_at AS campaign_created_at,
        updated_at AS campaign_updated_at,
        
        -- Delivery metrics
        total_emails_delivered,
        total_emails_opened,
        total_emails_clicked,
        total_emails_marked_spam,
        total_unsubscribes,
        
        -- Conversion metrics
        total_orders,
        total_product_orders,
        total_revenue,
        
        -- Rates
        open_rate,
        click_rate,
        click_to_delivery_rate,
        conversion_rate,
        revenue_per_email,
        
        -- Unique metrics
        unique_recipients,
        unique_openers,
        unique_clickers,
        unique_converters,
        
        -- Performance
        performance_tier,
        
        -- Activity dates
        first_activity_date,
        last_activity_date,
        
        -- Warehouse metadata
        CURRENT_TIMESTAMP() AS wh_created_at,
        CURRENT_TIMESTAMP() AS wh_updated_at
        
    FROM campaign_details
)

SELECT * FROM final
ORDER BY sent_at DESC