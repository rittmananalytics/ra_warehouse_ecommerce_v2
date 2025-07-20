-- Simplified inventory model based on available data
with inventory_levels as (

    select * from {{ ref('stg_shopify_ecommerce__inventory_levels') }}

),

products as (

    select * from {{ ref('int_products') }}

),

order_lines as (

    select * from {{ ref('stg_shopify_ecommerce__order_lines') }}

),

orders as (

    select * from {{ ref('int_orders') }}

),

-- Calculate product demand from order data
product_demand as (

    select
        ol.product_id,
        ol.variant_id,
        count(distinct ol.order_id) as orders_with_product,
        sum(ol.quantity) as total_quantity_ordered,
        sum(ol.line_price) as total_revenue,
        avg(ol.quantity) as avg_quantity_per_order,
        max(o.order_created_at) as last_order_date,
        min(o.order_created_at) as first_order_date,
        count(distinct date(o.order_created_at)) as days_with_orders
    from order_lines ol
    inner join orders o on ol.order_id = o.order_id
    group by ol.product_id, ol.variant_id

),

-- Calculate inventory performance
inventory_performance as (

    select
        i.product_id,
        i.variant_id,
        i.location_id,
        i.location_name,
        i.inventory_available as current_stock,
        i.inventory_cost as unit_cost,
        i.inventory_cost * i.inventory_available as total_inventory_value,
        i.requires_shipping,
        i.tracked as is_tracked,
        i.variant_price as selling_price,
        i.variant_price - i.inventory_cost as gross_margin_per_unit,
        
        -- Demand metrics
        coalesce(d.total_quantity_ordered, 0) as total_quantity_sold,
        coalesce(d.total_revenue, 0) as total_revenue,
        coalesce(d.orders_with_product, 0) as order_frequency,
        coalesce(d.avg_quantity_per_order, 0) as avg_quantity_per_order,
        d.last_order_date,
        d.first_order_date,
        coalesce(d.days_with_orders, 0) as days_with_sales,
        
        -- Calculate inventory turnover
        case
            when i.inventory_available > 0 and d.total_quantity_ordered > 0
            then d.total_quantity_ordered / i.inventory_available
            else 0
        end as inventory_turnover_ratio,
        
        -- Calculate days of inventory (simplified)
        case
            when d.total_quantity_ordered > 0 and d.days_with_orders > 0
            then i.inventory_available / (d.total_quantity_ordered / d.days_with_orders)
            else null
        end as days_of_inventory_remaining,
        
        -- Stock status
        case
            when i.inventory_available = 0 then 'Out of Stock'
            when i.inventory_available <= 5 then 'Low Stock'
            when i.inventory_available <= 20 then 'Medium Stock'
            else 'High Stock'
        end as stock_status,
        
        -- Velocity classification (simplified)
        case
            when d.total_quantity_ordered = 0 then 'No Movement'
            when d.total_quantity_ordered >= 100 then 'Fast Moving'
            when d.total_quantity_ordered >= 50 then 'Medium Moving'
            when d.total_quantity_ordered >= 10 then 'Slow Moving'
            else 'Very Slow Moving'
        end as inventory_velocity,
        
        current_timestamp() as integration_updated_at

    from inventory_levels i
    left join product_demand d
        on i.product_id = d.product_id
        and i.variant_id = d.variant_id

),

-- Add product information
final as (

    select
        i.*,
        p.product_title,
        p.product_type,
        p.vendor,
        p.product_status,
        p.product_performance_category,
        p.is_active as is_product_active,
        
        -- Business categorization
        case
            when i.stock_status = 'Out of Stock' and i.inventory_velocity in ('Fast Moving', 'Medium Moving') then 'Urgent Restock'
            when i.stock_status = 'Low Stock' and i.inventory_velocity = 'Fast Moving' then 'Priority Restock'
            when i.stock_status = 'High Stock' and i.inventory_velocity = 'No Movement' then 'Overstock Risk'
            when i.stock_status = 'High Stock' and i.inventory_velocity = 'Very Slow Moving' then 'Dead Stock Risk'
            when i.inventory_velocity = 'Fast Moving' then 'Healthy Turnover'
            else 'Normal'
        end as inventory_action_needed,
        
        -- Financial impact
        case
            when i.total_inventory_value >= 1000 then 'High Value'
            when i.total_inventory_value >= 500 then 'Medium Value'
            when i.total_inventory_value >= 100 then 'Low Value'
            else 'Minimal Value'
        end as inventory_value_tier,
        
        -- Performance flags
        case when i.inventory_turnover_ratio >= 1.0 then true else false end as is_high_turnover,
        case when i.current_stock = 0 then true else false end as is_out_of_stock,
        case when i.current_stock <= 5 then true else false end as is_low_stock,
        case when i.days_of_inventory_remaining <= 7 then true else false end as needs_reorder_soon,
        case when i.gross_margin_per_unit > 0 then true else false end as is_profitable

    from inventory_performance i
    left join products p
        on i.product_id = p.product_id

)

select * from final