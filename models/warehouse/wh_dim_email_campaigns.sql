{{ config(
    materialized='table',
    alias='dim_email_campaigns'
) }}

WITH campaign_performance AS (
    SELECT * FROM {{ ref('int_email_campaign_performance') }}
),

klaviyo_flows AS (
    SELECT * FROM {{ ref('klaviyo__flows') }}
),

flow_metrics AS (
    SELECT
        flow_id,
        
        -- Aggregate metrics for flows
        SUM(emails_delivered) AS total_emails_delivered,
        SUM(emails_opened) AS total_emails_opened,
        SUM(emails_clicked) AS total_emails_clicked,
        SUM(orders) AS total_orders,
        SUM(revenue) AS total_revenue,
        
        SAFE_DIVIDE(SUM(emails_opened), NULLIF(SUM(emails_delivered), 0)) AS open_rate,
        SAFE_DIVIDE(SUM(emails_clicked), NULLIF(SUM(emails_opened), 0)) AS click_rate,
        SAFE_DIVIDE(SUM(orders), NULLIF(SUM(emails_delivered), 0)) AS conversion_rate,
        
        COUNT(DISTINCT person_id) AS unique_recipients,
        MIN(event_date) AS first_activity_date,
        MAX(event_date) AS last_activity_date
        
    FROM {{ ref('int_email_events') }}
    WHERE flow_id IS NOT NULL
    GROUP BY 1
),

campaigns_dim AS (
    SELECT
        campaign_key,
        campaign_id,
        campaign_name,
        campaign_subject,
        from_email,
        from_name,
        campaign_type,
        sent_at,
        campaign_created_at,
        campaign_updated_at,
        
        -- Performance metrics
        total_emails_delivered,
        total_emails_opened,
        total_emails_clicked,
        total_emails_marked_spam,
        total_unsubscribes,
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
        
        performance_tier,
        first_activity_date,
        last_activity_date,
        
        -- Campaign classification
        'campaign' AS email_program_type,
        campaign_id AS program_id,
        campaign_name AS program_name,
        
        -- Campaign characteristics
        CASE 
            WHEN LOWER(campaign_name) LIKE '%welcome%' THEN 'welcome'
            WHEN LOWER(campaign_name) LIKE '%sale%' OR LOWER(campaign_name) LIKE '%discount%' THEN 'promotional'
            WHEN LOWER(campaign_name) LIKE '%cart%' OR LOWER(campaign_name) LIKE '%abandon%' THEN 'retention'
            WHEN LOWER(campaign_name) LIKE '%vip%' OR LOWER(campaign_name) LIKE '%exclusive%' THEN 'vip'
            WHEN LOWER(campaign_name) LIKE '%newsletter%' OR LOWER(campaign_name) LIKE '%weekly%' THEN 'newsletter'
            WHEN LOWER(campaign_name) LIKE '%birthday%' THEN 'lifecycle'
            WHEN LOWER(campaign_name) LIKE '%back%' OR LOWER(campaign_name) LIKE '%stock%' THEN 'transactional'
            ELSE 'other'
        END AS campaign_category,
        
        CASE
            WHEN from_email LIKE '%promotion%' OR from_email LIKE '%deal%' THEN 'promotional'
            WHEN from_email LIKE '%vip%' THEN 'vip'
            WHEN from_email LIKE '%newsletter%' THEN 'editorial'
            WHEN from_email LIKE '%alert%' THEN 'transactional'
            ELSE 'general'
        END AS sender_category,
        
        -- Subject line analysis
        CHAR_LENGTH(campaign_subject) AS subject_length,
        CASE 
            WHEN CHAR_LENGTH(campaign_subject) <= 30 THEN 'short'
            WHEN CHAR_LENGTH(campaign_subject) <= 50 THEN 'medium'
            ELSE 'long'
        END AS subject_length_category,
        
        CASE WHEN REGEXP_CONTAINS(campaign_subject, r'[!🎉💄✨👑🛒📰🎂🌞]') THEN TRUE ELSE FALSE END AS has_emoji,
        CASE WHEN REGEXP_CONTAINS(UPPER(campaign_subject), r'[%OFF|SALE|FREE|DISCOUNT]') THEN TRUE ELSE FALSE END AS has_promotion
        
    FROM campaign_performance
),

flows_dim AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['f.flow_id']) }} AS campaign_key,
        f.flow_id AS campaign_id,
        f.flow_name AS campaign_name,
        NULL AS campaign_subject,
        NULL AS from_email,
        NULL AS from_name,
        f.trigger_type AS campaign_type,
        NULL AS sent_at,
        f.created_at AS campaign_created_at,
        f.updated_at AS campaign_updated_at,
        
        -- Performance metrics from flow_metrics
        COALESCE(m.total_emails_delivered, 0) AS total_emails_delivered,
        COALESCE(m.total_emails_opened, 0) AS total_emails_opened,
        COALESCE(m.total_emails_clicked, 0) AS total_emails_clicked,
        CAST(0 AS INT64) AS total_emails_marked_spam,
        CAST(0 AS INT64) AS total_unsubscribes,
        COALESCE(m.total_orders, 0) AS total_orders,
        CAST(0 AS INT64) AS total_product_orders,
        COALESCE(m.total_revenue, 0) AS total_revenue,
        
        -- Rates
        COALESCE(m.open_rate, 0) AS open_rate,
        COALESCE(m.click_rate, 0) AS click_rate,
        0 AS click_to_delivery_rate,
        COALESCE(m.conversion_rate, 0) AS conversion_rate,
        SAFE_DIVIDE(COALESCE(m.total_revenue, 0), NULLIF(COALESCE(m.total_emails_delivered, 0), 0)) AS revenue_per_email,
        
        -- Unique metrics
        COALESCE(m.unique_recipients, 0) AS unique_recipients,
        CAST(0 AS INT64) AS unique_openers,
        CAST(0 AS INT64) AS unique_clickers,
        CAST(0 AS INT64) AS unique_converters,
        
        CASE 
            WHEN m.open_rate >= 0.25 THEN 'high_performing'
            WHEN m.open_rate >= 0.15 THEN 'medium_performing'
            WHEN m.open_rate > 0 THEN 'low_performing'
            ELSE 'no_engagement'
        END AS performance_tier,
        
        m.first_activity_date,
        m.last_activity_date,
        
        -- Flow classification
        'flow' AS email_program_type,
        f.flow_id AS program_id,
        f.flow_name AS program_name,
        
        -- Flow characteristics
        CASE 
            WHEN LOWER(f.flow_name) LIKE '%welcome%' THEN 'welcome'
            WHEN LOWER(f.flow_name) LIKE '%cart%' OR LOWER(f.flow_name) LIKE '%abandon%' THEN 'retention'
            WHEN LOWER(f.flow_name) LIKE '%post%' OR LOWER(f.flow_name) LIKE '%follow%' THEN 'lifecycle'
            WHEN LOWER(f.flow_name) LIKE '%vip%' THEN 'vip'
            WHEN LOWER(f.flow_name) LIKE '%win%' OR LOWER(f.flow_name) LIKE '%back%' THEN 'retention'
            WHEN LOWER(f.flow_name) LIKE '%birthday%' THEN 'lifecycle'
            ELSE 'other'
        END AS campaign_category,
        
        'automated' AS sender_category,
        
        -- Subject line analysis (not applicable for flows)
        NULL AS subject_length,
        NULL AS subject_length_category,
        NULL AS has_emoji,
        NULL AS has_promotion
        
    FROM klaviyo_flows f
    LEFT JOIN flow_metrics m ON f.flow_id = m.flow_id
),

unified_campaigns AS (
    SELECT * FROM campaigns_dim
    UNION ALL
    SELECT * FROM flows_dim
),

final AS (
    SELECT
        campaign_key,
        campaign_id,
        program_id,
        program_name,
        email_program_type,
        
        -- Campaign details
        campaign_name,
        campaign_subject,
        subject_length,
        subject_length_category,
        has_emoji,
        has_promotion,
        
        -- Sender details
        from_email,
        from_name,
        sender_category,
        
        -- Campaign classification
        campaign_type,
        campaign_category,
        
        -- Performance metrics
        total_emails_delivered,
        total_emails_opened,
        total_emails_clicked,
        total_emails_marked_spam,
        total_unsubscribes,
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
        
        -- Dates
        sent_at,
        campaign_created_at,
        campaign_updated_at,
        first_activity_date,
        last_activity_date,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM unified_campaigns
)

SELECT * FROM final
ORDER BY campaign_created_at DESC