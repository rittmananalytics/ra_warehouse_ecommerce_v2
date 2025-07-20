{{ config(
    materialized='table'
) }}

WITH person_raw AS (
    SELECT * FROM {{ source('klaviyo_raw', 'person') }}
),

person_cleaned AS (
    SELECT
        id AS person_id,
        email,
        first_name,
        last_name,
        CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')) AS full_name,
        phone_number,
        
        -- Location data
        city,
        country,
        region,
        zip AS postal_code,
        timezone,
        
        -- Parse properties JSON for key metrics
        JSON_EXTRACT_SCALAR(properties, '$.accepts_marketing') = 'true' AS accepts_marketing,
        JSON_EXTRACT_SCALAR(properties, '$.customer_status') AS customer_status,
        CAST(JSON_EXTRACT_SCALAR(properties, '$.total_spent') AS FLOAT64) AS total_spent,
        
        -- Customer segmentation
        CASE 
            WHEN JSON_EXTRACT_SCALAR(properties, '$.customer_status') = 'vip' THEN 'vip'
            WHEN CAST(JSON_EXTRACT_SCALAR(properties, '$.total_spent') AS FLOAT64) >= 300 THEN 'high_value'
            WHEN CAST(JSON_EXTRACT_SCALAR(properties, '$.total_spent') AS FLOAT64) >= 100 THEN 'medium_value'
            WHEN CAST(JSON_EXTRACT_SCALAR(properties, '$.total_spent') AS FLOAT64) > 0 THEN 'low_value'
            ELSE 'no_purchase'
        END AS customer_tier,
        
        -- Email domain analysis
        SPLIT(email, '@')[OFFSET(1)] AS email_domain,
        CASE 
            WHEN SPLIT(email, '@')[OFFSET(1)] IN ('gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com') THEN 'personal'
            WHEN SPLIT(email, '@')[OFFSET(1)] LIKE '%.co.uk' OR SPLIT(email, '@')[OFFSET(1)] LIKE '%.com' THEN 'business'
            ELSE 'other'
        END AS email_domain_type,
        
        -- Dates
        created AS person_created_at,
        updated AS person_updated_at,
        _fivetran_synced,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM person_raw
)

SELECT * FROM person_cleaned
ORDER BY total_spent DESC, person_created_at DESC