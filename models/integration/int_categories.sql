with product_categories as (

    select
        product_id,
        product_type,
        vendor,
        product_tags
    from {{ ref('int_products') }}

),

-- Extract categories from product_type and tags
categories_parsed as (

    select
        product_id,
        product_type as primary_category,
        vendor,
        product_tags,
        
        -- Parse tags into individual categories (assuming comma-separated)
        case when product_tags is not null then split(product_tags, ',') else [] end as tag_array
        
    from product_categories
    where product_type is not null or product_tags is not null

),

-- Create individual category records
categories_flattened as (

    -- Primary categories from product_type
    select
        product_id,
        trim(coalesce(product_type, '')) as category_name,
        'product_type' as category_source,
        vendor,
        1 as category_level,
        true as is_primary_category
    from categories_parsed
    where coalesce(product_type, '') is not null and trim(coalesce(product_type, '')) != ''

    union all

    -- Secondary categories from tags
    select
        product_id,
        trim(tag) as category_name,
        'product_tag' as category_source,
        vendor,
        2 as category_level,
        false as is_primary_category
    from categories_parsed,
    unnest(tag_array) as tag
    where tag is not null and trim(tag) != ''

),

-- Create category hierarchy and standardization
categories_standardized as (

    select
        category_name,
        category_source,
        category_level,
        
        -- Standardize category names
        case
            when lower(category_name) in ('makeup', 'cosmetics', 'beauty') then 'Cosmetics'
            when lower(category_name) in ('skincare', 'skin care', 'skin-care') then 'Skincare'
            when lower(category_name) in ('fragrance', 'perfume', 'cologne') then 'Fragrance'
            when lower(category_name) in ('haircare', 'hair care', 'hair-care') then 'Hair Care'
            when lower(category_name) in ('tools', 'accessories', 'applicators') then 'Tools & Accessories'
            else initcap(category_name)
        end as category_name_standardized,
        
        -- Create category hierarchy
        case
            when lower(category_name) in ('makeup', 'cosmetics', 'beauty', 'skincare', 'skin care', 'skin-care', 
                                         'fragrance', 'perfume', 'cologne', 'haircare', 'hair care', 'hair-care') then 'Beauty & Personal Care'
            when lower(category_name) in ('tools', 'accessories', 'applicators') then 'Beauty Tools'
            when lower(category_name) in ('gift', 'set', 'bundle', 'kit') then 'Gift Sets'
            when lower(category_name) in ('sale', 'clearance', 'discount') then 'Promotional'
            else 'Other'
        end as parent_category,
        
        count(distinct product_id) as product_count,
        count(distinct vendor) as vendor_count,
        min(category_level) as min_level,
        max(category_level) as max_level
        
    from categories_flattened
    group by category_name, category_source, category_level

),

-- Create final category dimension
final as (

    select
        row_number() over (order by category_name_standardized) as category_key,
        category_name as original_category_name,
        category_name_standardized as category_name,
        category_source,
        category_level,
        parent_category,
        product_count,
        vendor_count,
        
        -- Category metrics and flags
        case
            when product_count >= 10 then 'High Volume'
            when product_count >= 5 then 'Medium Volume'
            when product_count >= 2 then 'Low Volume'
            else 'Single Product'
        end as category_size,
        
        case
            when vendor_count > 1 then true
            else false
        end as is_multi_vendor_category,
        
        case
            when category_level = 1 then true
            else false
        end as is_primary_category,
        
        case
            when category_source = 'product_type' then true
            else false
        end as is_official_category,
        
        -- Category performance indicators (to be enhanced with sales data)
        case
            when lower(parent_category) = 'beauty & personal care' then 'Core'
            when lower(parent_category) = 'gift sets' then 'Seasonal'
            when lower(parent_category) = 'promotional' then 'Clearance'
            else 'Support'
        end as category_strategy,
        
        current_timestamp() as integration_updated_at

    from categories_standardized

)

select * from final