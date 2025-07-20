
with shopify_discounts as (

    select * from {{ ref('shopify__discounts') }}

),

final as (

    select
        discount_code_id,
        code as discount_code,
        discount_type as discount_code_type,
        status as discount_status,
        value as discount_value,
        value_type as discount_value_type,
        usage_limit,
        usage_count as discount_usage_count,
        null as minimum_amount, -- not available in shopify__discounts
        customer_selection_all_customers as customer_selection,
        target_type,
        target_selection,
        allocation_method as discount_allocation_method,
        created_at as discount_created_at,
        updated_at as discount_updated_at,
        starts_at as discount_starts_at,
        ends_at as discount_ends_at,
        total_order_discount_amount as total_discount_amount_order_level,
        count_orders as count_order_level_discounts,
        null as total_discount_amount_line_level, -- not available in shopify__discounts
        null as count_line_level_discounts, -- not available in shopify__discounts
        count_orders as total_discounted_orders,
        avg_order_discount_amount as avg_discount_amount_per_order,
        total_order_line_items_price as total_gross_revenue,
        total_order_discount_amount as total_discount_amount,
        total_order_line_items_price - total_order_discount_amount as total_net_revenue

    from shopify_discounts

)

select * from final