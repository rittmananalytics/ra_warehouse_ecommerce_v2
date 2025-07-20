{{ config(
    materialized='table'
) }}

WITH klaviyo_events AS (
    SELECT * FROM {{ ref('klaviyo__events') }}
),

email_engagement_events AS (
    SELECT
        event_id,
        person_id,
        person_email AS email,
        occurred_at,
        type AS event_name,
        campaign_id,
        flow_id,
        
        -- Campaign details
        campaign_name,
        '' AS campaign_subject,
        
        -- Event categorization
        CASE 
            WHEN type = 'Received Email' THEN 'delivery'
            WHEN type = 'Opened Email' THEN 'engagement'
            WHEN type = 'Clicked Email' THEN 'engagement'
            WHEN type = 'Marked Email as Spam' THEN 'negative'
            WHEN type = 'Unsubscribed' THEN 'negative'
            WHEN type = 'Placed Order' THEN 'conversion'
            WHEN type = 'Ordered Product' THEN 'conversion'
            ELSE 'other'
        END AS event_category,
        
        -- Revenue tracking
        numeric_value,
        
        -- UTM and attribution data
        CASE 
            WHEN campaign_id IS NOT NULL THEN 'klaviyo'
            WHEN flow_id IS NOT NULL THEN 'klaviyo_flow'
            ELSE 'klaviyo'
        END AS utm_source,
        
        'email' AS utm_medium,
        
        CASE 
            WHEN campaign_id IS NOT NULL THEN campaign_name
            WHEN flow_id IS NOT NULL THEN flow_name
            ELSE 'unknown'
        END AS utm_campaign,
        
        -- Email engagement metrics
        CASE WHEN type = 'Received Email' THEN 1 ELSE 0 END AS emails_delivered,
        CASE WHEN type = 'Opened Email' THEN 1 ELSE 0 END AS emails_opened,
        CASE WHEN type = 'Clicked Email' THEN 1 ELSE 0 END AS emails_clicked,
        CASE WHEN type = 'Marked Email as Spam' THEN 1 ELSE 0 END AS emails_marked_spam,
        CASE WHEN type = 'Unsubscribed' THEN 1 ELSE 0 END AS unsubscribes,
        CASE WHEN type = 'Placed Order' THEN 1 ELSE 0 END AS orders,
        CASE WHEN type = 'Ordered Product' THEN 1 ELSE 0 END AS product_orders,
        
        -- Timing and attribution
        DATE(occurred_at) AS event_date,
        EXTRACT(HOUR FROM occurred_at) AS event_hour,
        EXTRACT(DAYOFWEEK FROM occurred_at) AS day_of_week
        
    FROM klaviyo_events
),

final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['event_id']) }} AS email_event_key,
        event_id,
        person_id,
        email,
        occurred_at,
        event_date,
        event_hour,
        day_of_week,
        event_name,
        event_category,
        campaign_id,
        flow_id,
        campaign_name,
        campaign_subject,
        utm_source,
        utm_medium,
        utm_campaign,
        
        -- Metrics
        emails_delivered,
        emails_opened,
        emails_clicked,
        emails_marked_spam,
        unsubscribes,
        orders,
        product_orders,
        numeric_value AS revenue,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM email_engagement_events
)

SELECT * FROM final
ORDER BY occurred_at DESC