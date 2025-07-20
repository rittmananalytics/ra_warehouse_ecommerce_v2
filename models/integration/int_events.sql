with ga4_events_union as (

    -- Page view events
    select
        event_id,
        user_pseudo_id,
        event_timestamp,
        event_date,
        'page_view' as event_name,
        page_title as event_category,
        page_location as event_action,
        null as event_label,
        null as event_value,
        null as currency,
        null as item_id,
        null as item_name,
        null as item_category,
        device,
        geo,
        traffic_source,
        current_timestamp() as integration_updated_at
    from {{ ref('stg_ga4_events__page_view') }}

    union all

    -- View item events
    select
        event_id,
        user_pseudo_id,
        event_timestamp,
        event_date,
        'view_item' as event_name,
        'ecommerce' as event_category,
        'view_item' as event_action,
        item_name as event_label,
        value as event_value,
        currency,
        item_id,
        item_name,
        item_category,
        device,
        geo,
        traffic_source,
        current_timestamp() as integration_updated_at
    from {{ ref('stg_ga4_events__view_item') }}

    union all

    -- Add to cart events
    select
        event_id,
        user_pseudo_id,
        event_timestamp,
        event_date,
        'add_to_cart' as event_name,
        'ecommerce' as event_category,
        'add_to_cart' as event_action,
        item_name as event_label,
        value as event_value,
        currency,
        item_id,
        item_name,
        item_category,
        device,
        geo,
        traffic_source,
        current_timestamp() as integration_updated_at
    from {{ ref('stg_ga4_events__add_to_cart') }}

    union all

    -- Begin checkout events
    select
        event_id,
        user_pseudo_id,
        event_timestamp,
        event_date,
        'begin_checkout' as event_name,
        'ecommerce' as event_category,
        'begin_checkout' as event_action,
        null as event_label,
        value as event_value,
        currency,
        null as item_id,
        null as item_name,
        null as item_category,
        device,
        geo,
        traffic_source,
        current_timestamp() as integration_updated_at
    from {{ ref('stg_ga4_events__begin_checkout') }}

    union all

    -- Purchase events
    select
        event_id,
        user_pseudo_id,
        event_timestamp,
        event_date,
        'purchase' as event_name,
        'ecommerce' as event_category,
        'purchase' as event_action,
        transaction_id as event_label,
        value as event_value,
        currency,
        null as item_id,
        null as item_name,
        null as item_category,
        device,
        geo,
        traffic_source,
        current_timestamp() as integration_updated_at
    from {{ ref('stg_ga4_events__purchase') }}

    union all

    -- Session start events
    select
        event_id,
        user_pseudo_id,
        event_timestamp,
        event_date,
        'session_start' as event_name,
        'engagement' as event_category,
        'session_start' as event_action,
        null as event_label,
        null as event_value,
        null as currency,
        null as item_id,
        null as item_name,
        null as item_category,
        device,
        geo,
        traffic_source,
        current_timestamp() as integration_updated_at
    from {{ ref('stg_ga4_events__session_start') }}

),

final as (

    select
        event_id,
        user_pseudo_id,
        event_timestamp,
        event_date,
        event_name,
        event_category,
        event_action,
        event_label,
        event_value,
        currency,
        item_id,
        item_name,
        item_category,
        
        -- Parse device information
        json_extract_scalar(device, '$.category') as device_category,
        json_extract_scalar(device, '$.mobile_brand_name') as device_brand,
        json_extract_scalar(device, '$.mobile_model_name') as device_model,
        json_extract_scalar(device, '$.operating_system') as operating_system,
        json_extract_scalar(device, '$.browser') as browser,
        
        -- Parse geo information
        json_extract_scalar(geo, '$.country') as country,
        json_extract_scalar(geo, '$.region') as region,
        json_extract_scalar(geo, '$.city') as city,
        
        -- Parse traffic source
        json_extract_scalar(traffic_source, '$.source') as traffic_source,
        json_extract_scalar(traffic_source, '$.medium') as traffic_medium,
        json_extract_scalar(traffic_source, '$.campaign') as traffic_campaign,
        
        -- Event categorization
        case 
            when event_name in ('purchase') then 'conversion'
            when event_name in ('begin_checkout', 'add_to_cart') then 'consideration'
            when event_name in ('view_item') then 'interest'
            when event_name in ('page_view') then 'awareness'
            when event_name in ('session_start') then 'engagement'
            else 'other'
        end as funnel_stage,
        
        case
            when event_name in ('purchase', 'begin_checkout', 'add_to_cart', 'view_item') then true
            else false
        end as is_ecommerce_event,
        
        case
            when event_value > 0 then true
            else false
        end as has_value,
        
        integration_updated_at

    from ga4_events_union

)

select * from final