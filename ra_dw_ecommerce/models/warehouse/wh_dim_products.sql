{{ config(
    materialized='table',
    unique_key='product_key'
) }}

with products as (

    select * from {{ ref('int_products') }}

),

final as (

    select
        -- Surrogate key (sequential)
        row_number() over (order by product_id) as product_key,
        
        -- Natural key
        product_id,
        
        -- Product attributes
        product_title,
        product_handle,
        product_type,
        vendor,
        product_created_at,
        product_updated_at,
        product_published_at,
        product_status,
        product_tags,
        
        -- Product options
        option_1_name,
        option_1_value,
        option_2_name,
        option_2_value,
        option_3_name,
        option_3_value,
        
        -- Performance metrics
        total_orders,
        total_line_items,
        total_quantity_sold,
        total_revenue,
        avg_selling_price,
        max_selling_price,
        min_selling_price,
        total_discounts_given,
        avg_discount_percent,
        
        -- Inventory metrics
        total_inventory,
        avg_variant_inventory,
        variant_count,
        
        -- Product categorization
        product_performance_category,
        inventory_status_category,
        
        -- Product flags
        is_active,
        is_published,
        has_inventory,
        has_sales,
        
        -- Additional business categorizations
        case
            when total_revenue >= 10000 then 'Top Revenue Generator'
            when total_revenue >= 5000 then 'High Revenue'
            when total_revenue >= 1000 then 'Medium Revenue'
            when total_revenue > 0 then 'Low Revenue'
            else 'No Revenue'
        end as revenue_tier,
        
        case
            when avg_selling_price >= 200 then 'Premium'
            when avg_selling_price >= 100 then 'Mid-Range'
            when avg_selling_price >= 50 then 'Economy'
            else 'Budget'
        end as price_tier,
        
        case
            when total_quantity_sold >= 500 then 'High Volume'
            when total_quantity_sold >= 100 then 'Medium Volume'
            when total_quantity_sold >= 20 then 'Low Volume'
            when total_quantity_sold > 0 then 'Minimal Volume'
            else 'No Sales'
        end as sales_volume_tier,
        
        -- Margin indicators (assuming discounts impact margin)
        case
            when avg_discount_percent >= 30 then 'High Discount'
            when avg_discount_percent >= 15 then 'Medium Discount'
            when avg_discount_percent >= 5 then 'Low Discount'
            when avg_discount_percent > 0 then 'Minimal Discount'
            else 'No Discount'
        end as discount_tier,
        
        -- Product lifecycle
        case
            when product_published_at is null then 'Unpublished'
            when date_diff(current_date(), date(product_published_at), day) <= 30 then 'New'
            when date_diff(current_date(), date(product_published_at), day) <= 180 then 'Recent'
            when date_diff(current_date(), date(product_published_at), day) <= 365 then 'Established'
            else 'Mature'
        end as product_lifecycle_stage,
        
        -- Data quality indicators
        case when variant_count > 1 then true else false end as has_variants,
        case when product_tags is not null and length(product_tags) > 0 then true else false end as has_tags,
        case when option_1_name is not null then true else false end as has_options,
        case when vendor is not null and vendor != '' then true else false end as has_vendor,
        
        -- SCD Type 2 fields
        integration_updated_at as effective_from,
        cast('2999-12-31' as timestamp) as effective_to,
        true as is_current,
        current_timestamp() as warehouse_updated_at

    from products

)

select * from final