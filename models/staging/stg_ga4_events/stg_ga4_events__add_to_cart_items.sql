with ga4_events as (

    select * from {{ source('fivetran_ga4_demo', 'events_sample') }}
    where event_name = 'add_to_cart'

),

items_unnested as (

    select
        event_date,
        event_timestamp,
        user_pseudo_id,
        
        -- Create parent event ID for referential integrity
        concat(user_pseudo_id, '_', cast(event_timestamp as string)) as parent_event_id,
        
        -- Unnest items array using JSON functions
        json_extract_scalar(item_data, '$.item_id') as item_id,
        json_extract_scalar(item_data, '$.item_name') as item_name,
        json_extract_scalar(item_data, '$.item_category') as item_category,
        json_extract_scalar(item_data, '$.item_variant') as item_variant,
        json_extract_scalar(item_data, '$.item_brand') as item_brand,
        cast(json_extract_scalar(item_data, '$.price') as float64) as price,
        json_extract_scalar(item_data, '$.currency') as currency,
        cast(json_extract_scalar(item_data, '$.quantity') as int64) as quantity,
        
        -- Row number for unique item identification within event
        row_number() over (
            partition by user_pseudo_id, event_timestamp 
            order by json_extract_scalar(item_data, '$.item_id')
        ) as item_sequence

    from ga4_events,
    unnest(json_extract_array(items)) as item_data

),

final as (

    select
        concat(parent_event_id, '_item_', cast(item_sequence as string)) as item_event_id,
        parent_event_id,
        event_date,
        event_timestamp,
        user_pseudo_id,
        item_sequence,
        item_id,
        item_name,
        item_category,
        item_variant,
        item_brand,
        price,
        currency,
        quantity,
        price * quantity as total_item_value

    from items_unnested

)

select * from final