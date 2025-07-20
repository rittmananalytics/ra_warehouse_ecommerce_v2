{{ config(
    materialized='table',
    unique_key='journey_key'
) }}

with customer_journey as (

    select * from {{ ref('int_customer_journey') }}

),

customers as (

    select * from {{ ref('wh_dim_customers') }}

),

orders as (

    select * from {{ ref('wh_fact_orders') }}

),

sessions as (

    select * from {{ ref('wh_fact_ga4_sessions') }}

),

date_dim as (

    select * from {{ ref('wh_dim_date') }}

),

final as (

    select
        -- Surrogate keys
        row_number() over (order by cj.shopify_order_id, cj.session_id) as journey_key,
        coalesce(c.customer_key, -1) as customer_key,
        coalesce(o.order_key, -1) as order_key,
        coalesce(gs.session_key, -1) as session_key,
        coalesce(d_session.date_key, -1) as session_date_key,
        coalesce(d_order.date_key, -1) as order_date_key,
        
        -- Natural keys
        cj.shopify_customer_id,
        cj.shopify_order_id,
        cj.ga4_transaction_id,
        cj.session_id,
        cj.converting_user_pseudo_id,
        
        -- Journey timing
        cj.shopify_order_timestamp,
        cj.ga4_purchase_timestamp,
        cj.session_date,
        cj.session_start_timestamp,
        cj.days_to_conversion,
        
        -- Session details
        cj.session_sequence_number,
        cj.session_type,
        cj.session_duration_minutes,
        cj.page_views,
        cj.items_viewed,
        cj.add_to_cart_events,
        cj.begin_checkout_events,
        cj.session_revenue,
        cj.hours_since_previous_session,
        
        -- Journey flags
        cj.is_converting_session,
        
        -- Journey aggregates
        cj.total_sessions_to_conversion,
        cj.total_days_active,
        cj.total_page_views,
        cj.total_items_viewed,
        cj.total_add_to_cart_events,
        cj.total_begin_checkout_events,
        cj.total_session_duration_minutes,
        cj.days_from_first_touch_to_conversion,
        cj.days_from_first_product_view,
        cj.days_from_first_add_to_cart,
        cj.days_from_first_checkout_start,
        
        -- Journey classification
        cj.journey_complexity,
        cj.conversion_timeline,
        
        -- Order value context
        cj.shopify_order_value,
        
        -- Calculated journey metrics
        case when cj.total_sessions_to_conversion > 0 then cj.total_page_views / cj.total_sessions_to_conversion else 0 end as avg_pages_per_session,
        case when cj.total_page_views > 0 then cj.total_session_duration_minutes / cj.total_page_views else 0 end as avg_minutes_per_page,
        case when cj.total_sessions_to_conversion > 0 then cj.shopify_order_value / cj.total_sessions_to_conversion else 0 end as revenue_per_session,
        case when cj.total_page_views > 0 then cj.shopify_order_value / cj.total_page_views else 0 end as revenue_per_page_view,
        
        -- Conversion efficiency metrics
        case when cj.total_items_viewed > 0 then cj.total_add_to_cart_events / cj.total_items_viewed else 0 end as journey_view_to_cart_rate,
        case when cj.total_add_to_cart_events > 0 then cj.total_begin_checkout_events / cj.total_add_to_cart_events else 0 end as journey_cart_to_checkout_rate,
        case when cj.total_begin_checkout_events > 0 then 1.0 / cj.total_begin_checkout_events else 0 end as journey_checkout_to_purchase_rate,
        case when cj.total_items_viewed > 0 then 1.0 / cj.total_items_viewed else 0 end as journey_view_to_purchase_rate,
        
        -- Journey value scoring
        case
            when cj.total_sessions_to_conversion = 1 and cj.days_to_conversion = 0 then 'Immediate Convert'
            when cj.total_sessions_to_conversion <= 2 and cj.days_from_first_touch_to_conversion <= 1 then 'Quick Convert'
            when cj.total_sessions_to_conversion <= 5 and cj.days_from_first_touch_to_conversion <= 7 then 'Standard Convert'
            when cj.total_sessions_to_conversion <= 10 and cj.days_from_first_touch_to_conversion <= 30 then 'Considered Convert'
            else 'Long Journey Convert'
        end as conversion_behavior_type,
        
        -- Attribution weight (for multi-touch attribution)
        case
            when cj.is_converting_session then 0.4  -- Give 40% credit to converting session
            when cj.session_type = 'Added to Cart' then 0.3  -- 30% to cart additions
            when cj.session_type = 'Product Browsing' then 0.2  -- 20% to product views
            when cj.session_type = 'Checkout Started' then 0.35  -- 35% to checkout starts
            else 0.1  -- 10% to other sessions
        end as attribution_weight,
        
        -- Normalize attribution weight across the journey
        case
            when cj.is_converting_session then 0.4
            else 0.6 / nullif(cj.total_sessions_to_conversion - 1, 0)
        end as normalized_attribution_weight,
        
        current_timestamp() as warehouse_updated_at

    from customer_journey cj
    left join customers c
        on cj.shopify_customer_id = c.customer_id
        and c.is_current = true
    left join orders o
        on cj.shopify_order_id = o.order_id
    left join sessions gs
        on cj.session_id = gs.session_id
    left join date_dim d_session
        on cj.session_date = d_session.date_actual
    left join date_dim d_order
        on date(cj.shopify_order_timestamp) = d_order.date_actual

)

select * from final