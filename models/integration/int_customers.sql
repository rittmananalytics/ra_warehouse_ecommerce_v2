with shopify_customers as (

    select * from {{ ref('stg_shopify_ecommerce__customers') }}

),

customer_metrics as (

    select
        customer_id,
        count(distinct order_id) as order_count,
        sum(order_total_price) as lifetime_value,
        min(order_created_at) as first_order_date,
        max(order_created_at) as last_order_date,
        date_diff(current_date(), date(min(order_created_at)), day) as days_since_first_order,
        date_diff(current_date(), date(max(order_created_at)), day) as days_since_last_order,
        avg(order_total_price) as avg_order_value
    from {{ ref('stg_shopify_ecommerce__orders') }}
    where customer_id is not null
    group by customer_id

),

final as (

    select
        c.customer_id,
        c.customer_email,
        c.first_name,
        c.last_name,
        c.phone,
        c.accepts_marketing,
        c.customer_created_at,
        c.customer_updated_at,
        c.customer_lifetime_value as shopify_lifetime_value,
        c.customer_order_count as shopify_order_count,
        null as customer_state, -- not available in shopify__customers
        null as default_address_city, -- not available in shopify__customers
        null as default_address_country, -- not available in shopify__customers
        null as default_address_country_code, -- not available in shopify__customers
        null as default_address_province, -- not available in shopify__customers
        null as default_address_province_code, -- not available in shopify__customers
        null as default_address_zip, -- not available in shopify__customers
        
        -- Calculated metrics from orders
        coalesce(m.order_count, 0) as calculated_order_count,
        coalesce(m.lifetime_value, 0) as calculated_lifetime_value,
        m.first_order_date,
        m.last_order_date,
        m.days_since_first_order,
        m.days_since_last_order,
        m.avg_order_value,
        
        -- Customer segmentation
        case 
            when m.order_count >= 5 then 'High Value'
            when m.order_count >= 2 then 'Repeat Customer'
            when m.order_count = 1 then 'One-time Customer'
            else 'No Orders'
        end as customer_segment,
        
        case
            when m.days_since_last_order <= 30 then 'Active'
            when m.days_since_last_order <= 90 then 'At Risk'
            when m.days_since_last_order <= 180 then 'Inactive'
            else 'Lost'
        end as customer_lifecycle_stage,
        
        current_timestamp() as integration_updated_at

    from shopify_customers c
    left join customer_metrics m
        on c.customer_id = m.customer_id

)

select * from final