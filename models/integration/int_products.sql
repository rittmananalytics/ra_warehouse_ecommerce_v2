with shopify_products as (

    select * from {{ ref('stg_shopify_ecommerce__products') }}

),

order_lines as (

    select * from {{ ref('stg_shopify_ecommerce__order_lines') }}

),

product_performance as (

    select
        product_id,
        count(distinct order_id) as total_orders,
        count(distinct order_line_id) as total_line_items,
        sum(quantity) as total_quantity_sold,
        sum(line_price) as total_revenue,
        avg(line_price / quantity) as avg_selling_price,
        max(line_price / quantity) as max_selling_price,
        min(line_price / quantity) as min_selling_price,
        sum(total_discount) as total_discounts_given,
        avg(total_discount / line_price) * 100 as avg_discount_percent
    from order_lines
    where quantity > 0
    group by product_id

),

inventory_status as (

    select
        product_id,
        sum(inventory_available) as total_inventory,
        avg(inventory_available) as avg_variant_inventory,
        count(distinct variant_id) as variant_count
    from {{ ref('stg_shopify_ecommerce__inventory_levels') }}
    group by product_id

),

final as (

    select
        p.product_id,
        p.product_title,
        p.product_handle,
        p.product_type,
        p.product_vendor as vendor,
        p.product_created_at,
        p.product_updated_at,
        p.product_published_at,
        p.product_status,
        p.product_tags,
        null as option_1_name, -- not available in shopify__products
        null as option_1_value, -- not available in shopify__products  
        null as option_2_name, -- not available in shopify__products
        null as option_2_value, -- not available in shopify__products
        null as option_3_name, -- not available in shopify__products
        null as option_3_value, -- not available in shopify__products
        
        -- Performance metrics
        coalesce(perf.total_orders, 0) as total_orders,
        coalesce(perf.total_line_items, 0) as total_line_items,
        coalesce(perf.total_quantity_sold, 0) as total_quantity_sold,
        coalesce(perf.total_revenue, 0) as total_revenue,
        perf.avg_selling_price,
        perf.max_selling_price,
        perf.min_selling_price,
        coalesce(perf.total_discounts_given, 0) as total_discounts_given,
        perf.avg_discount_percent,
        
        -- Inventory metrics
        coalesce(inv.total_inventory, 0) as total_inventory,
        inv.avg_variant_inventory,
        coalesce(inv.variant_count, 0) as variant_count,
        
        -- Product categorization
        case 
            when perf.total_orders >= 50 then 'Best Seller'
            when perf.total_orders >= 20 then 'Popular'
            when perf.total_orders >= 5 then 'Moderate'
            when perf.total_orders >= 1 then 'Low Selling'
            else 'No Sales'
        end as product_performance_category,
        
        case
            when inv.total_inventory = 0 then 'Out of Stock'
            when inv.total_inventory <= 10 then 'Low Stock'
            when inv.total_inventory <= 50 then 'Medium Stock'
            else 'High Stock'
        end as inventory_status_category,
        
        -- Product status flags
        case when p.product_status = 'active' then true else false end as is_active,
        case when p.product_published_at is not null then true else false end as is_published,
        case when inv.total_inventory > 0 then true else false end as has_inventory,
        case when perf.total_orders > 0 then true else false end as has_sales,
        
        current_timestamp() as integration_updated_at

    from shopify_products p
    left join product_performance perf
        on p.product_id = perf.product_id
    left join inventory_status inv
        on p.product_id = inv.product_id

)

select * from final