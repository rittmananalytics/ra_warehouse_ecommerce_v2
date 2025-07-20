{{ config(
    materialized='table',
    unique_key='category_key'
) }}

with categories as (

    select * from {{ ref('int_categories_simple') }}

),

final as (

    select
        -- Surrogate key (already generated in integration layer)
        category_key,
        
        -- Natural key
        category_name as original_category_name,
        
        -- Category attributes
        category_name,
        'product_type' as category_source,
        1 as category_level,
        'Beauty & Personal Care' as parent_category,
        
        -- Performance metrics
        product_count,
        vendor_count,
        
        -- Category characteristics
        category_size,
        case when vendor_count > 1 then true else false end as is_multi_vendor_category,
        true as is_primary_category,
        true as is_official_category,
        'Core' as category_strategy,
        
        -- Additional business categorization
        1 as strategy_priority,
        
        case
            when product_count >= 10 then 'Large'
            when product_count >= 5 then 'Medium'
            when product_count >= 2 then 'Small'
            else 'Minimal'
        end as category_scale,
        
        -- Category hierarchy indicators
        1 as parent_category_sort_order,
        
        'Primary Official' as category_classification,
        
        -- Business impact indicators
        case
            when product_count >= 5 then 'High Impact'
            when product_count >= 2 then 'Medium Impact'
            when product_count >= 1 then 'Low Impact'
            else 'Minimal Impact'
        end as business_impact,
        
        -- Data quality flags
        case when category_name is not null and category_name != '' then true else false end as has_valid_name,
        true as has_parent_category,
        case when product_count > 0 then true else false end as has_products,
        
        integration_updated_at as effective_from,
        cast('2999-12-31' as timestamp) as effective_to,
        true as is_current,
        current_timestamp() as warehouse_updated_at

    from categories

)

select * from final