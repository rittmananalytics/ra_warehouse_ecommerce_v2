
with shopify_daily_shop as (

    select * from {{ ref('shopify__daily_shop') }}

),

final as (

    select
        date_day,
        shop_id,
        count_orders as orders_placed,
        order_adjusted_total as gross_sales,
        refund_subtotal as order_line_refunds,
        order_adjusted_total - refund_subtotal as net_sales,
        shipping_cost as shipping,
        null as taxes, -- not available in shopify__daily_shop
        total_discounts,
        order_adjusted_total as total_sales,
        avg_order_value,
        avg_quantity_sold as avg_quantity_per_order,
        null as new_customers, -- not available in shopify__daily_shop
        null as returning_customers, -- not available in shopify__daily_shop
        count_customers as total_customers,
        null as new_customer_revenue, -- not available in shopify__daily_shop
        null as returning_customer_revenue, -- not available in shopify__daily_shop
        refund_subtotal as refund_amount,
        null as abandoned_checkouts, -- not available in shopify__daily_shop
        null as taxes_included -- not available in shopify__daily_shop

    from shopify_daily_shop

)

select * from final