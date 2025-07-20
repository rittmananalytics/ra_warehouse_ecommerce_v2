with ga4_events as (

    select * from {{ source('fivetran_ga4_demo', 'events_sample') }}
    where event_name = 'page_view'

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
        
        -- Extract common page view parameters
        json_extract_scalar(event_params, '$[0].value.string_value') as page_location,
        json_extract_scalar(event_params, '$[1].value.string_value') as page_title,
        json_extract_scalar(event_params, '$[2].value.string_value') as page_referrer,
        
        -- Create unique event ID
        concat(user_pseudo_id, '_', cast(event_timestamp as string)) as event_id

    from ga4_events

)

select * from final