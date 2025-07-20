with ga4_purchases as (

    select * from {{ ref('stg_ga4_events__purchase') }}

),

shopify_orders as (

    select * from {{ ref('int_orders') }}

),

sessions as (

    select * from {{ ref('int_sessions') }}

),

-- Match GA4 purchases to Shopify orders based on timing and value
purchase_matching as (

    select
        g.user_pseudo_id,
        g.event_timestamp as ga4_purchase_timestamp,
        g.transaction_id as ga4_transaction_id,
        g.value as ga4_purchase_value,
        g.currency as ga4_currency,
        
        s.order_id as shopify_order_id,
        s.customer_id as shopify_customer_id,
        s.customer_email,
        s.order_created_at as shopify_order_timestamp,
        s.order_total_price as shopify_order_value,
        
        -- Calculate timestamp differences (in hours)
        abs(timestamp_diff(
            timestamp_micros(g.event_timestamp), 
            s.order_created_at, 
            hour
        )) as timestamp_diff_hours,
        
        -- Calculate value differences (absolute percentage)
        abs(g.value - s.order_total_price) / s.order_total_price * 100 as value_diff_percent,
        
        -- Ranking for best matches
        row_number() over (
            partition by g.user_pseudo_id, g.event_timestamp 
            order by 
                abs(timestamp_diff(timestamp_micros(g.event_timestamp), s.order_created_at, hour)),
                abs(g.value - s.order_total_price) / s.order_total_price
        ) as match_rank

    from ga4_purchases g
    left join shopify_orders s
        on abs(timestamp_diff(
            timestamp_micros(g.event_timestamp), 
            s.order_created_at, 
            hour
        )) <= 2  -- Within 2 hours
        and abs(g.value - s.order_total_price) / s.order_total_price <= 0.05  -- Within 5% value difference

),

-- Get the best matches
best_matches as (

    select *
    from purchase_matching
    where match_rank = 1
      and timestamp_diff_hours <= 1  -- Tighten to 1 hour for best matches
      and value_diff_percent <= 2    -- Tighten to 2% for best matches

),

-- Create customer journey with all GA4 sessions leading up to conversion
customer_journeys as (

    select
        bm.shopify_customer_id,
        bm.customer_email,
        bm.shopify_order_id,
        bm.ga4_transaction_id,
        bm.user_pseudo_id as converting_user_pseudo_id,
        bm.shopify_order_timestamp,
        bm.ga4_purchase_timestamp,
        bm.shopify_order_value,
        
        -- Get all sessions for this user leading up to conversion
        gs.session_id,
        gs.session_date,
        gs.session_start_timestamp,
        gs.session_sequence_number,
        gs.session_type,
        gs.session_duration_minutes,
        gs.page_views,
        gs.items_viewed,
        gs.add_to_cart_events,
        gs.begin_checkout_events,
        gs.session_revenue,
        gs.hours_since_previous_session,
        
        -- Calculate days from session to conversion
        date_diff(
            date(bm.shopify_order_timestamp),
            gs.session_date,
            day
        ) as days_to_conversion,
        
        -- Flag the converting session
        case 
            when date(timestamp_micros(gs.session_start_timestamp)) = date(bm.shopify_order_timestamp)
            then true else false 
        end as is_converting_session,
        
        current_timestamp() as integration_updated_at

    from best_matches bm
    inner join sessions gs
        on bm.user_pseudo_id = gs.user_pseudo_id
        and gs.session_date <= date(bm.shopify_order_timestamp)
        and gs.session_date >= date_sub(date(bm.shopify_order_timestamp), interval 30 day)  -- Look back 30 days

),

-- Add journey-level aggregates
journey_aggregates as (

    select
        shopify_customer_id,
        shopify_order_id,
        count(distinct session_id) as total_sessions_to_conversion,
        count(distinct session_date) as total_days_active,
        sum(page_views) as total_page_views,
        sum(items_viewed) as total_items_viewed,
        sum(add_to_cart_events) as total_add_to_cart_events,
        sum(begin_checkout_events) as total_begin_checkout_events,
        sum(session_duration_minutes) as total_session_duration_minutes,
        max(days_to_conversion) as days_from_first_touch_to_conversion,
        min(case when session_type = 'Product Browsing' then days_to_conversion end) as days_from_first_product_view,
        min(case when session_type = 'Added to Cart' then days_to_conversion end) as days_from_first_add_to_cart,
        min(case when session_type = 'Checkout Started' then days_to_conversion end) as days_from_first_checkout_start
    from customer_journeys
    group by shopify_customer_id, shopify_order_id

)

select
    cj.*,
    ja.total_sessions_to_conversion,
    ja.total_days_active,
    ja.total_page_views,
    ja.total_items_viewed,
    ja.total_add_to_cart_events,
    ja.total_begin_checkout_events,
    ja.total_session_duration_minutes,
    ja.days_from_first_touch_to_conversion,
    ja.days_from_first_product_view,
    ja.days_from_first_add_to_cart,
    ja.days_from_first_checkout_start,
    
    -- Journey classification
    case 
        when ja.total_sessions_to_conversion = 1 then 'Single Session'
        when ja.total_sessions_to_conversion <= 3 then 'Short Journey'
        when ja.total_sessions_to_conversion <= 7 then 'Medium Journey'
        else 'Long Journey'
    end as journey_complexity,
    
    case
        when ja.days_from_first_touch_to_conversion = 0 then 'Same Day'
        when ja.days_from_first_touch_to_conversion <= 3 then 'Within 3 Days'
        when ja.days_from_first_touch_to_conversion <= 7 then 'Within 1 Week'
        when ja.days_from_first_touch_to_conversion <= 30 then 'Within 1 Month'
        else 'Long Consideration'
    end as conversion_timeline

from customer_journeys cj
inner join journey_aggregates ja
    on cj.shopify_customer_id = ja.shopify_customer_id
    and cj.shopify_order_id = ja.shopify_order_id