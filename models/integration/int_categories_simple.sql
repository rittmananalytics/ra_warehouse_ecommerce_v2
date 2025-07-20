-- Simplified categories model based on available product data
with products as (

    select
        product_id,
        product_type,
        vendor,
        product_tags,
        total_revenue,
        total_orders,
        product_performance_category
    from {{ ref('int_products') }}
    where product_type is not null

),

categories_with_metrics as (

    select
        product_type as category_name,
        vendor,
        count(distinct product_id) as product_count,
        count(distinct vendor) as vendor_count,
        sum(total_revenue) as category_revenue,
        sum(total_orders) as category_orders,
        avg(total_revenue) as avg_product_revenue,
        
        -- Category performance classification
        case
            when sum(total_revenue) >= 50000 then 'High Revenue'
            when sum(total_revenue) >= 20000 then 'Medium Revenue'
            when sum(total_revenue) >= 5000 then 'Low Revenue'
            else 'Minimal Revenue'
        end as revenue_tier,
        
        case
            when count(distinct product_id) >= 10 then 'Large Category'
            when count(distinct product_id) >= 5 then 'Medium Category'
            when count(distinct product_id) >= 2 then 'Small Category'
            else 'Single Product'
        end as category_size,
        
        current_timestamp() as integration_updated_at

    from products
    group by product_type, vendor

),

final as (

    select
        row_number() over (order by category_revenue desc) as category_key,
        category_name,
        vendor,
        product_count,
        vendor_count,
        category_revenue,
        category_orders,
        avg_product_revenue,
        revenue_tier,
        category_size,
        
        -- Standardize category names for beauty business
        case
            when lower(category_name) in ('skincare', 'skin care') then 'Skincare'
            when lower(category_name) in ('makeup', 'cosmetics') then 'Cosmetics'
            when lower(category_name) in ('fragrance', 'perfume') then 'Fragrance'
            when lower(category_name) in ('haircare', 'hair care') then 'Hair Care'
            else category_name
        end as standardized_category,
        
        integration_updated_at

    from categories_with_metrics

)

select * from final