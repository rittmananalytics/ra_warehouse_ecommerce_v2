with session_starts as (

    select * from {{ ref('stg_ga4_events__session_start') }}

),

page_views as (

    select * from {{ ref('stg_ga4_events__page_view') }}

),

view_items as (

    select * from {{ ref('stg_ga4_events__view_item') }}

),

add_to_carts as (

    select * from {{ ref('stg_ga4_events__add_to_cart') }}

),

begin_checkouts as (

    select * from {{ ref('stg_ga4_events__begin_checkout') }}

),

purchases as (

    select * from {{ ref('stg_ga4_events__purchase') }}

),

-- Create session-level aggregates
session_aggregates as (

    select
        user_pseudo_id,
        date(timestamp_micros(event_timestamp)) as session_date,
        min(event_timestamp) as session_start_timestamp,
        max(event_timestamp) as session_end_timestamp,
        
        -- Page view metrics
        count(case when event_name = 'page_view' then 1 end) as page_views,
        count(distinct case when event_name = 'page_view' then page_title end) as unique_pages_viewed,
        count(distinct case when event_name = 'page_view' then page_location end) as unique_page_locations,
        
        -- Product interaction metrics
        count(case when event_name = 'view_item' then 1 end) as items_viewed,
        count(distinct case when event_name = 'view_item' then item_id end) as unique_items_viewed,
        count(case when event_name = 'add_to_cart' then 1 end) as add_to_cart_events,
        count(distinct case when event_name = 'add_to_cart' then item_id end) as unique_items_added_to_cart,
        
        -- Conversion events
        count(case when event_name = 'begin_checkout' then 1 end) as begin_checkout_events,
        count(case when event_name = 'purchase' then 1 end) as purchase_events,
        
        -- Revenue metrics
        sum(case when event_name = 'purchase' then value else 0 end) as session_revenue,
        avg(case when event_name = 'purchase' then value end) as avg_purchase_value,
        
        -- Session duration
        (max(event_timestamp) - min(event_timestamp)) / 1000000 as session_duration_seconds

    from (
        select event_timestamp, user_pseudo_id, event_name, page_title, page_location, null as item_id, null as value from page_views
        union all
        select event_timestamp, user_pseudo_id, event_name, null as page_title, null as page_location, item_id, null as value from view_items
        union all
        select event_timestamp, user_pseudo_id, event_name, null as page_title, null as page_location, item_id, value from add_to_carts
        union all
        select event_timestamp, user_pseudo_id, event_name, null as page_title, null as page_location, null as item_id, value from begin_checkouts
        union all
        select event_timestamp, user_pseudo_id, event_name, null as page_title, null as page_location, null as item_id, value from purchases
    )
    group by user_pseudo_id, date(timestamp_micros(event_timestamp))

),

-- Add session sequence numbers
sessions_with_sequence as (

    select
        *,
        row_number() over (
            partition by user_pseudo_id 
            order by session_start_timestamp
        ) as session_sequence_number,
        
        -- Calculate time between sessions
        lag(session_end_timestamp) over (
            partition by user_pseudo_id 
            order by session_start_timestamp
        ) as previous_session_end_timestamp

    from session_aggregates

),

final as (

    select
        concat(user_pseudo_id, '_', session_date) as session_id,
        user_pseudo_id,
        session_date,
        session_start_timestamp,
        session_end_timestamp,
        session_sequence_number,
        
        -- Time calculations
        case 
            when previous_session_end_timestamp is not null 
            then (session_start_timestamp - previous_session_end_timestamp) / 1000000 / 3600
        end as hours_since_previous_session,
        
        session_duration_seconds,
        session_duration_seconds / 60.0 as session_duration_minutes,
        
        -- Engagement metrics
        page_views,
        unique_pages_viewed,
        unique_page_locations,
        items_viewed,
        unique_items_viewed,
        add_to_cart_events,
        unique_items_added_to_cart,
        begin_checkout_events,
        purchase_events,
        
        -- Revenue metrics
        session_revenue,
        avg_purchase_value,
        
        -- Conversion flags
        case when items_viewed > 0 then true else false end as viewed_products,
        case when add_to_cart_events > 0 then true else false end as added_to_cart,
        case when begin_checkout_events > 0 then true else false end as began_checkout,
        case when purchase_events > 0 then true else false end as completed_purchase,
        
        -- Session classification
        case 
            when purchase_events > 0 then 'Converting'
            when begin_checkout_events > 0 then 'Checkout Started'
            when add_to_cart_events > 0 then 'Added to Cart'
            when items_viewed > 0 then 'Product Browsing'
            else 'General Browsing'
        end as session_type,
        
        case
            when session_duration_seconds < 30 then 'Bounce'
            when session_duration_seconds < 300 then 'Short'
            when session_duration_seconds < 1800 then 'Medium'
            else 'Long'
        end as session_duration_category,
        
        current_timestamp() as integration_updated_at

    from sessions_with_sequence

)

select * from final