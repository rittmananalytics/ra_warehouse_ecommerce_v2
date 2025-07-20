{{ config(
    materialized='table'
) }}

WITH event_raw AS (
    SELECT * FROM {{ source('klaviyo_raw', 'event') }}
),

event_cleaned AS (
    SELECT
        id AS event_id,
        metric_id,
        person_id,
        campaign_id,
        flow_id,
        statistic_id,
        uuid AS event_uuid,
        timestamp AS event_timestamp,
        value AS event_value,
        
        -- Parse event properties (simplified due to special characters)
        event_properties AS event_properties_json,
        JSON_EXTRACT_SCALAR(event_properties, '$.campaign_name') AS event_campaign_name,
        
        -- Parse person properties
        person_properties AS person_properties_json,
        JSON_EXTRACT_SCALAR(person_properties, '$.email') AS person_email,
        JSON_EXTRACT_SCALAR(person_properties, '$.customer_status') AS person_customer_status,
        CAST(JSON_EXTRACT_SCALAR(person_properties, '$.total_spent') AS FLOAT64) AS person_total_spent,
        
        -- Event categorization based on metric lookup
        -- Note: This would normally join with metric table, but for simplicity using campaign context
        CASE 
            WHEN campaign_id IS NOT NULL THEN 'campaign_event'
            WHEN flow_id IS NOT NULL THEN 'flow_event'
            ELSE 'other_event'
        END AS event_category,
        
        -- Time-based analysis
        EXTRACT(DATE FROM timestamp) AS event_date,
        EXTRACT(HOUR FROM timestamp) AS event_hour,
        EXTRACT(DAYOFWEEK FROM timestamp) AS event_day_of_week,
        
        -- Email domain analysis (using person email as fallback)
        CASE 
            WHEN SPLIT(JSON_EXTRACT_SCALAR(person_properties, '$.email'), '@')[SAFE_OFFSET(1)] IN ('gmail.com', 'yahoo.com', 'hotmail.com') THEN 'consumer'
            WHEN SPLIT(JSON_EXTRACT_SCALAR(person_properties, '$.email'), '@')[SAFE_OFFSET(1)] LIKE '%.co.uk' THEN 'uk_business'
            WHEN SPLIT(JSON_EXTRACT_SCALAR(person_properties, '$.email'), '@')[SAFE_OFFSET(1)] LIKE '%.com' THEN 'business'
            ELSE 'other'
        END AS email_domain_category,
        
        -- Customer tier at time of event
        CASE 
            WHEN JSON_EXTRACT_SCALAR(person_properties, '$.customer_status') = 'vip' THEN 'vip'
            WHEN CAST(JSON_EXTRACT_SCALAR(person_properties, '$.total_spent') AS FLOAT64) >= 300 THEN 'high_value'
            WHEN CAST(JSON_EXTRACT_SCALAR(person_properties, '$.total_spent') AS FLOAT64) >= 100 THEN 'medium_value'
            ELSE 'low_value'
        END AS customer_tier_at_event,
        
        -- Metadata
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM event_raw
)

SELECT * FROM event_cleaned
ORDER BY event_timestamp DESC