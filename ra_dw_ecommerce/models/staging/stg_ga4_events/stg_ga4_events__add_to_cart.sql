with ga4_events as (

    select * from {{ source('fivetran_ga4_demo', 'events_sample') }}
    where event_name = 'add_to_cart'

),

final as (

    select
        event_date,
        event_timestamp,
        event_name,
        event_previous_timestamp,
        event_value_in_usd,
        event_bundle_sequence_id,
        event_server_timestamp_offset,
        user_id,
        user_pseudo_id,
        privacy_info,
        user_properties,
        user_first_touch_timestamp,
        user_ltv,
        device,
        geo,
        app_info,
        traffic_source,
        stream_id,
        platform,
        event_params,
        items,
        ecommerce,
        
        -- Extract ecommerce parameters
        json_extract_scalar(event_params, '$[0].value.string_value') as currency,
        cast(json_extract_scalar(event_params, '$[1].value.double_value') as float64) as value,
        
        -- Extract item information (first item from items array)
        json_extract_scalar(items, '$[0].item_id') as item_id,
        json_extract_scalar(items, '$[0].item_name') as item_name,
        json_extract_scalar(items, '$[0].item_category') as item_category,
        json_extract_scalar(items, '$[0].item_brand') as item_brand,
        cast(json_extract_scalar(items, '$[0].price') as float64) as item_price,
        cast(json_extract_scalar(items, '$[0].quantity') as int64) as item_quantity,
        
        -- Create unique event ID
        concat(user_pseudo_id, '_', cast(event_timestamp as string)) as event_id

    from ga4_events

)

select * from final