{{ config(
    materialized='table',
    unique_key='order_key'
) }}

with orders as (

    select * from {{ ref('int_orders') }}

),

customers as (

    select * from {{ ref('wh_dim_customers') }}

),

date_dim as (

    select * from {{ ref('wh_dim_date') }}

),

final as (

    select
        -- Surrogate keys
        row_number() over (order by o.order_id) as order_key,
        coalesce(c.customer_key, -1) as customer_key,
        coalesce(d_created.date_key, -1) as order_date_key,
        coalesce(d_processed.date_key, -1) as processed_date_key,
        coalesce(d_cancelled.date_key, -1) as cancelled_date_key,
        
        -- Natural key
        o.order_id,
        
        -- Order identifiers
        o.order_name,
        o.customer_id,
        o.customer_email,
        
        -- Dates and timestamps
        o.order_created_at,
        o.order_updated_at,
        o.order_processed_at,
        o.order_cancelled_at,
        
        -- Status fields
        o.financial_status,
        o.fulfillment_status,
        
        -- Financial metrics
        o.order_total_price,
        o.subtotal_price,
        o.total_tax,
        o.total_discounts,
        o.shipping_cost,
        o.order_adjustment_amount,
        o.refund_subtotal,
        o.refund_tax,
        
        -- Calculated metrics
        o.calculated_order_total,
        o.total_line_discounts,
        o.total_discount_amount,
        
        -- Order composition
        o.line_item_count,
        o.unique_product_count,
        o.total_quantity,
        o.avg_line_price,
        o.max_line_price,
        o.min_line_price,
        o.discount_count,
        
        -- Order characteristics
        o.order_value_category,
        o.source_name,
        o.processing_method,
        o.referring_site,
        o.landing_site_base_url,
        o.order_note,
        
        -- Shipping information
        o.shipping_company,
        o.tracking_company,
        o.tracking_number,
        o.shipping_address_first_name,
        o.shipping_address_last_name,
        o.shipping_address_company,
        o.shipping_address_phone,
        o.shipping_address_address_1,
        o.shipping_address_address_2,
        o.shipping_address_city,
        o.shipping_address_province,
        o.shipping_address_province_code,
        o.shipping_address_country,
        o.shipping_address_country_code,
        o.shipping_address_zip,
        
        -- Order flags
        o.is_cancelled,
        o.has_refund,
        o.is_multi_product_order,
        o.has_discount,
        
        -- Additional business metrics
        case when o.total_discounts > 0 then o.total_discounts / o.order_total_price else 0 end as discount_rate,
        case when o.subtotal_price > 0 then o.total_tax / o.subtotal_price else 0 end as tax_rate,
        case when o.order_total_price > 0 then o.shipping_cost / o.order_total_price else 0 end as shipping_rate,
        
        -- Net amounts (after refunds)
        o.order_total_price - coalesce(o.refund_subtotal, 0) - coalesce(o.refund_tax, 0) as net_order_value,
        o.subtotal_price - coalesce(o.refund_subtotal, 0) as net_subtotal,
        o.total_tax - coalesce(o.refund_tax, 0) as net_tax,
        
        -- Time-based calculations
        case 
            when o.order_processed_at is not null and o.order_created_at is not null
            then timestamp_diff(o.order_processed_at, o.order_created_at, hour)
        end as hours_to_process,
        
        case
            when o.order_cancelled_at is not null and o.order_created_at is not null
            then timestamp_diff(o.order_cancelled_at, o.order_created_at, hour)
        end as hours_to_cancellation,
        
        -- Order timing classifications
        case
            when extract(hour from o.order_created_at) between 6 and 11 then 'Morning'
            when extract(hour from o.order_created_at) between 12 and 17 then 'Afternoon'
            when extract(hour from o.order_created_at) between 18 and 21 then 'Evening'
            else 'Late Night'
        end as order_time_of_day,
        
        case
            when extract(dayofweek from o.order_created_at) in (1, 7) then 'Weekend'
            else 'Weekday'
        end as order_day_type,
        
        current_timestamp() as warehouse_updated_at

    from orders o
    left join customers c
        on o.customer_id = c.customer_id
        and c.is_current = true
    left join date_dim d_created
        on date(o.order_created_at) = d_created.date_actual
    left join date_dim d_processed
        on date(o.order_processed_at) = d_processed.date_actual
    left join date_dim d_cancelled
        on date(o.order_cancelled_at) = d_cancelled.date_actual

)

select * from final