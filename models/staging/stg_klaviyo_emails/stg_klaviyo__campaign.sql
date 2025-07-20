{{ config(
    materialized='table'
) }}

WITH campaign_raw AS (
    SELECT * FROM {{ source('klaviyo_raw', 'campaign') }}
),

campaign_cleaned AS (
    SELECT
        id AS campaign_id,
        name AS campaign_name,
        subject AS campaign_subject,
        from_email,
        from_name,
        campaign_type,
        
        -- Campaign timing
        send_time,
        sent_at,
        created_at AS campaign_created_at,
        updated_at AS campaign_updated_at,
        
        -- Campaign status
        status_id,
        status_label,
        
        -- Segmentation info
        is_segmented,
        list_ids,
        segment_ids,
        
        -- Campaign categorization
        CASE 
            WHEN LOWER(name) LIKE '%welcome%' THEN 'welcome'
            WHEN LOWER(name) LIKE '%vip%' OR LOWER(name) LIKE '%exclusive%' THEN 'vip'
            WHEN LOWER(name) LIKE '%recommendation%' OR LOWER(name) LIKE '%suggest%' THEN 'product_recommendation'
            WHEN LOWER(name) LIKE '%cart%' OR LOWER(name) LIKE '%abandon%' THEN 'cart_recovery'
            WHEN LOWER(name) LIKE '%newsletter%' OR LOWER(name) LIKE '%weekly%' THEN 'newsletter'
            WHEN LOWER(name) LIKE '%sale%' OR LOWER(name) LIKE '%discount%' THEN 'promotional'
            ELSE 'other'
        END AS campaign_category,
        
        -- Subject line analysis
        CHAR_LENGTH(subject) AS subject_length,
        CASE 
            WHEN CHAR_LENGTH(subject) <= 30 THEN 'short'
            WHEN CHAR_LENGTH(subject) <= 50 THEN 'medium'
            ELSE 'long'
        END AS subject_length_category,
        
        -- Emoji detection in subject
        CASE WHEN REGEXP_CONTAINS(subject, r'[😀-🙏💯-🗿🦀-🦴🇦-🇿]') THEN TRUE ELSE FALSE END AS has_emoji,
        
        -- Personalization indicators
        CASE WHEN REGEXP_CONTAINS(LOWER(subject), r'\b(your|you)\b') THEN TRUE ELSE FALSE END AS has_personalization,
        
        -- Sender categorization
        CASE 
            WHEN from_email LIKE '%vip%' THEN 'vip'
            WHEN from_email LIKE '%recommend%' THEN 'product_team'
            WHEN from_email LIKE '%support%' THEN 'customer_service'
            ELSE 'marketing'
        END AS sender_category,
        
        -- Metadata
        _fivetran_synced,
        CURRENT_TIMESTAMP() AS created_at,
        CURRENT_TIMESTAMP() AS updated_at
        
    FROM campaign_raw
)

SELECT * FROM campaign_cleaned
ORDER BY sent_at DESC