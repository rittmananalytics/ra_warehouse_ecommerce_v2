{{ config(
    materialized='table',
    unique_key='inventory_key'
) }}

with inventory as (

    select * from {{ ref('int_inventory_simple') }}

),

products as (

    select * from {{ ref('wh_dim_products') }}

),

date_dim as (

    select * from {{ ref('wh_dim_date') }}

),

final as (

    select
        -- Surrogate keys
        row_number() over (order by i.product_id, i.variant_id, i.location_id) as inventory_key,
        coalesce(p.product_key, -1) as product_key,
        coalesce(d.date_key, -1) as snapshot_date_key,
        
        -- Natural keys
        i.product_id,
        i.variant_id,
        i.location_id,
        
        -- Location information
        i.location_name,
        
        -- Current inventory status
        i.current_stock,
        i.unit_cost,
        i.total_inventory_value,
        i.selling_price,
        i.gross_margin_per_unit,
        
        -- Inventory characteristics
        i.requires_shipping,
        i.is_tracked,
        
        -- Demand and performance metrics
        i.total_quantity_sold,
        i.total_revenue,
        i.order_frequency,
        i.avg_quantity_per_order,
        i.last_order_date,
        i.first_order_date,
        i.days_with_sales,
        
        -- Inventory performance indicators
        i.inventory_turnover_ratio,
        i.days_of_inventory_remaining,
        i.stock_status,
        i.inventory_velocity,
        i.inventory_action_needed,
        i.inventory_value_tier,
        
        -- Product information
        i.product_title,
        i.product_type,
        i.vendor,
        i.product_status,
        i.product_performance_category,
        i.is_product_active,
        
        -- Business flags
        i.is_high_turnover,
        i.is_out_of_stock,
        i.is_low_stock,
        i.needs_reorder_soon,
        i.is_profitable,
        
        -- Additional calculated metrics
        case
            when i.current_stock > 0 and i.selling_price > 0
            then i.current_stock * i.selling_price
            else 0
        end as potential_revenue,
        
        case
            when i.current_stock > 0 and i.gross_margin_per_unit > 0
            then i.current_stock * i.gross_margin_per_unit
            else 0
        end as potential_gross_margin,
        
        -- Inventory risk assessment
        case
            when i.is_out_of_stock and i.inventory_velocity = 'Fast Moving' then 'Critical Stock Out'
            when i.is_low_stock and i.inventory_velocity = 'Fast Moving' then 'High Risk Stock Out'
            when i.current_stock > 50 and i.inventory_velocity = 'No Movement' then 'Overstock Risk'
            when i.days_of_inventory_remaining > 365 then 'Dead Stock Risk'
            when i.needs_reorder_soon then 'Reorder Alert'
            else 'Normal'
        end as inventory_risk_level,
        
        -- Inventory efficiency score (0-100)
        least(100, greatest(0,
            case
                when i.inventory_velocity = 'Fast Moving' and not i.is_low_stock then 90
                when i.inventory_velocity = 'Medium Moving' and not i.is_low_stock then 70
                when i.inventory_velocity = 'Slow Moving' and not i.is_out_of_stock then 50
                when i.inventory_velocity = 'Very Slow Moving' and not i.is_out_of_stock then 30
                when i.inventory_velocity = 'No Movement' then 10
                else 0
            end +
            case when i.is_profitable then 10 else 0 end -
            case when i.is_out_of_stock then 20 else 0 end -
            case when i.is_low_stock then 10 else 0 end
        )) as inventory_efficiency_score,
        
        -- Financial impact categorization
        case
            when i.total_inventory_value >= 5000 then 'High Financial Impact'
            when i.total_inventory_value >= 1000 then 'Medium Financial Impact'
            when i.total_inventory_value >= 100 then 'Low Financial Impact'
            else 'Minimal Financial Impact'
        end as financial_impact_tier,
        
        -- Reorder priority
        case
            when i.is_out_of_stock and i.inventory_velocity in ('Fast Moving', 'Medium Moving') then 1
            when i.is_low_stock and i.inventory_velocity = 'Fast Moving' then 2
            when i.needs_reorder_soon and i.inventory_velocity in ('Fast Moving', 'Medium Moving') then 3
            when i.is_low_stock and i.inventory_velocity = 'Medium Moving' then 4
            else 5
        end as reorder_priority,
        
        -- Snapshot information
        current_date() as snapshot_date,
        current_timestamp() as warehouse_updated_at

    from inventory i
    left join products p
        on i.product_id = p.product_id
        and p.is_current = true
    left join date_dim d
        on current_date() = d.date_actual

)

select * from final