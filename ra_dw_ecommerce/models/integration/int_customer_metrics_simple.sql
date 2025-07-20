-- Simplified customer metrics model
with customers as (

    select * from {{ ref('int_customers') }}

),

orders as (

    select * from {{ ref('int_orders') }}

),

customer_journey as (

    select * from {{ ref('int_customer_journey') }}

),

-- Calculate basic customer order metrics
customer_order_metrics as (

    select
        customer_id,
        count(distinct order_id) as total_orders,
        sum(order_total_price) as total_revenue,
        avg(order_total_price) as avg_order_value,
        min(order_total_price) as min_order_value,
        max(order_total_price) as max_order_value,
        
        -- Timing metrics
        min(order_created_at) as first_order_date,
        max(order_created_at) as most_recent_order_date,
        date_diff(current_date(), date(min(order_created_at)), day) as days_since_first_order,
        date_diff(current_date(), date(max(order_created_at)), day) as days_since_last_order,
        date_diff(date(max(order_created_at)), date(min(order_created_at)), day) as customer_lifespan_days,
        
        -- Order frequency
        case
            when count(distinct order_id) > 1 and date_diff(date(max(order_created_at)), date(min(order_created_at)), day) > 0
            then date_diff(date(max(order_created_at)), date(min(order_created_at)), day) / (count(distinct order_id) - 1)
            else null
        end as avg_days_between_orders,
        
        -- Product behavior  
        sum(total_quantity) as total_items_purchased,
        avg(total_quantity) as avg_items_per_order,
        
        -- Return behavior
        sum(case when has_refund then 1 else 0 end) as orders_with_returns,
        sum(case when has_refund then refund_subtotal else 0 end) as total_refund_amount,
        
        -- Discount usage
        sum(case when has_discount then 1 else 0 end) as orders_with_discounts,
        sum(total_discount_amount) as total_discount_amount,
        avg(case when has_discount then total_discount_amount / order_total_price else 0 end) as avg_discount_rate

    from orders
    where customer_id is not null
    group by customer_id

),

-- Calculate digital engagement metrics (simplified)
customer_digital_metrics as (

    select
        shopify_customer_id as customer_id,
        count(distinct session_id) as total_sessions,
        count(distinct session_date) as total_active_days,
        sum(total_page_views) as total_page_views,
        sum(total_items_viewed) as total_items_viewed,
        sum(total_add_to_cart_events) as total_add_to_cart_events,
        sum(total_session_duration_minutes) as total_engagement_minutes,
        avg(total_sessions_to_conversion) as avg_sessions_to_convert,
        avg(days_from_first_touch_to_conversion) as avg_days_to_convert,
        
        -- Conversion efficiency
        count(distinct case when is_converting_session then session_id end) as converting_sessions,
        count(distinct shopify_order_id) as converted_orders

    from customer_journey
    group by shopify_customer_id

),

-- RFM Analysis (Recency, Frequency, Monetary)
customer_rfm as (

    select
        customer_id,
        
        -- Recency (days since last order)
        om.days_since_last_order as recency,
        ntile(5) over (order by om.days_since_last_order desc) as recency_score,
        
        -- Frequency (number of orders)
        om.total_orders as frequency,
        ntile(5) over (order by om.total_orders) as frequency_score,
        
        -- Monetary (total revenue)
        om.total_revenue as monetary,
        ntile(5) over (order by om.total_revenue) as monetary_score
        
    from customer_order_metrics om

),

-- Customer Lifetime Value prediction components (simplified)
customer_clv_components as (

    select
        om.customer_id,
        
        -- Historical CLV
        om.total_revenue as historical_clv,
        
        -- Purchase rate (orders per day)
        case
            when om.customer_lifespan_days > 0
            then om.total_orders / om.customer_lifespan_days
            else 0
        end as purchase_rate,
        
        -- Predicted annual orders
        case
            when om.avg_days_between_orders is not null and om.avg_days_between_orders > 0
            then 365.0 / om.avg_days_between_orders
            else 0
        end as predicted_annual_orders,
        
        -- Churn probability (simple heuristic)
        case
            when om.days_since_last_order > 365 then 0.9
            when om.days_since_last_order > 180 then 0.7
            when om.days_since_last_order > 90 then 0.4
            when om.days_since_last_order > 30 then 0.2
            else 0.1
        end as churn_probability

    from customer_order_metrics om

),

final as (

    select
        c.customer_id,
        c.customer_email,
        concat(coalesce(c.first_name, ''), ' ', coalesce(c.last_name, '')) as full_name,
        c.customer_created_at,
        c.customer_segment,
        c.customer_lifecycle_stage,
        
        -- Order metrics
        coalesce(om.total_orders, 0) as total_orders,
        coalesce(om.total_revenue, 0) as total_revenue,
        om.avg_order_value,
        om.min_order_value,
        om.max_order_value,
        om.first_order_date,
        om.most_recent_order_date,
        om.days_since_first_order,
        om.days_since_last_order,
        om.customer_lifespan_days,
        om.avg_days_between_orders,
        om.total_items_purchased,
        om.avg_items_per_order,
        om.orders_with_returns,
        om.total_refund_amount,
        om.orders_with_discounts,
        om.total_discount_amount,
        om.avg_discount_rate,
        
        -- Digital engagement metrics
        coalesce(dm.total_sessions, 0) as total_sessions,
        coalesce(dm.total_active_days, 0) as total_active_days,
        coalesce(dm.total_page_views, 0) as total_page_views,
        coalesce(dm.total_items_viewed, 0) as total_items_viewed,
        coalesce(dm.total_add_to_cart_events, 0) as total_add_to_cart_events,
        coalesce(dm.total_engagement_minutes, 0) as total_engagement_minutes,
        dm.avg_sessions_to_convert,
        dm.avg_days_to_convert,
        dm.converting_sessions,
        dm.converted_orders,
        
        -- RFM scores
        rfm.recency,
        rfm.frequency,
        rfm.monetary,
        rfm.recency_score,
        rfm.frequency_score,
        rfm.monetary_score,
        concat(rfm.recency_score, rfm.frequency_score, rfm.monetary_score) as rfm_segment,
        
        -- CLV components
        clv.historical_clv,
        clv.purchase_rate,
        clv.predicted_annual_orders,
        clv.churn_probability,
        
        -- Predicted CLV (simplified 2-year horizon)
        case
            when clv.churn_probability < 1.0
            then om.avg_order_value * clv.predicted_annual_orders * (1 - clv.churn_probability) * 2
            else 0
        end as predicted_clv_2_year,
        
        -- Customer value tiers
        case
            when coalesce(om.total_revenue, 0) >= 2000 then 'VIP'
            when coalesce(om.total_revenue, 0) >= 1000 then 'High Value'
            when coalesce(om.total_revenue, 0) >= 500 then 'Medium Value'
            when coalesce(om.total_revenue, 0) >= 100 then 'Low Value'
            else 'New/Minimal'
        end as customer_value_tier,
        
        -- Engagement level
        case
            when coalesce(dm.total_sessions, 0) >= 20 then 'Highly Engaged'
            when coalesce(dm.total_sessions, 0) >= 10 then 'Moderately Engaged'
            when coalesce(dm.total_sessions, 0) >= 3 then 'Low Engagement'
            when coalesce(dm.total_sessions, 0) > 0 then 'Minimal Engagement'
            else 'No Digital Engagement'
        end as digital_engagement_level,
        
        -- Risk flags
        case when om.days_since_last_order > 365 then true else false end as at_risk_churn,
        case when om.orders_with_returns > om.total_orders * 0.5 then true else false end as high_return_rate,
        case when clv.churn_probability > 0.7 then true else false end as high_churn_risk,
        case when om.total_orders = 1 and om.days_since_first_order > 90 then true else false end as one_time_buyer_risk,
        
        current_timestamp() as integration_updated_at

    from customers c
    left join customer_order_metrics om on c.customer_id = om.customer_id
    left join customer_digital_metrics dm on c.customer_id = dm.customer_id
    left join customer_rfm rfm on c.customer_id = rfm.customer_id
    left join customer_clv_components clv on c.customer_id = clv.customer_id

)

select * from final