{{ config(
    materialized='table',
    unique_key='session_key'
) }}

with sessions as (

    select * from {{ ref('int_sessions') }}

),

date_dim as (

    select * from {{ ref('wh_dim_date') }}

),

final as (

    select
        -- Surrogate keys
        row_number() over (order by s.session_id) as session_key,
        coalesce(d.date_key, -1) as session_date_key,
        
        -- Natural key
        s.session_id,
        
        -- User identification
        s.user_pseudo_id,
        
        -- Session timing
        s.session_date,
        s.session_start_timestamp,
        s.session_end_timestamp,
        s.session_sequence_number,
        s.hours_since_previous_session,
        
        -- Session duration metrics
        s.session_duration_seconds,
        s.session_duration_minutes,
        s.session_duration_category,
        
        -- Engagement metrics
        s.page_views,
        s.unique_pages_viewed,
        s.unique_page_locations,
        s.items_viewed,
        s.unique_items_viewed,
        s.add_to_cart_events,
        s.unique_items_added_to_cart,
        s.begin_checkout_events,
        s.purchase_events,
        
        -- Revenue metrics
        s.session_revenue,
        s.avg_purchase_value,
        
        -- Session behavioral flags
        s.viewed_products,
        s.added_to_cart,
        s.began_checkout,
        s.completed_purchase,
        
        -- Session classification
        s.session_type,
        
        -- Calculated engagement metrics
        case when s.page_views > 0 then s.session_duration_seconds / s.page_views else 0 end as avg_time_per_page,
        case when s.page_views > 1 then true else false end as is_multi_page_session,
        case when s.session_duration_seconds < 30 then true else false end as is_bounce,
        
        -- Conversion funnel metrics
        case when s.items_viewed > 0 then s.add_to_cart_events / s.items_viewed else 0 end as view_to_cart_rate,
        case when s.add_to_cart_events > 0 then s.begin_checkout_events / s.add_to_cart_events else 0 end as cart_to_checkout_rate,
        case when s.begin_checkout_events > 0 then s.purchase_events / s.begin_checkout_events else 0 end as checkout_to_purchase_rate,
        case when s.items_viewed > 0 then s.purchase_events / s.items_viewed else 0 end as view_to_purchase_rate,
        
        -- Session value metrics
        case when s.page_views > 0 then s.session_revenue / s.page_views else 0 end as revenue_per_page_view,
        case when s.items_viewed > 0 then s.session_revenue / s.items_viewed else 0 end as revenue_per_item_view,
        
        -- User journey context
        case
            when s.session_sequence_number = 1 then 'First Visit'
            when s.session_sequence_number = 2 then 'Second Visit'
            when s.session_sequence_number <= 5 then 'Early Visits'
            when s.session_sequence_number <= 10 then 'Regular Visitor'
            else 'Frequent Visitor'
        end as visitor_type,
        
        case
            when s.hours_since_previous_session is null then 'First Session'
            when s.hours_since_previous_session <= 1 then 'Same Hour Return'
            when s.hours_since_previous_session <= 24 then 'Same Day Return'
            when s.hours_since_previous_session <= 168 then 'Same Week Return'
            when s.hours_since_previous_session <= 720 then 'Same Month Return'
            else 'Long Gap Return'
        end as return_pattern,
        
        -- Session timing analysis
        case
            when extract(hour from timestamp_micros(s.session_start_timestamp)) between 6 and 11 then 'Morning'
            when extract(hour from timestamp_micros(s.session_start_timestamp)) between 12 and 17 then 'Afternoon'
            when extract(hour from timestamp_micros(s.session_start_timestamp)) between 18 and 21 then 'Evening'
            else 'Late Night'
        end as session_time_of_day,
        
        case
            when extract(dayofweek from timestamp_micros(s.session_start_timestamp)) in (1, 7) then 'Weekend'
            else 'Weekday'
        end as session_day_type,
        
        -- Engagement scoring
        case
            when s.completed_purchase then 100
            when s.began_checkout then 80
            when s.added_to_cart then 60
            when s.viewed_products then 40
            when s.page_views > 1 then 20
            else 10
        end as engagement_score,
        
        current_timestamp() as warehouse_updated_at

    from sessions s
    left join date_dim d
        on s.session_date = d.date_actual

)

select * from final