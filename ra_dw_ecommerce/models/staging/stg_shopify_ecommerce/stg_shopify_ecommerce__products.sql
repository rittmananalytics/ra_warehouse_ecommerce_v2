
with shopify_products as (

    select * from {{ ref('shopify__products') }}

),

final as (

    select
        product_id,
        title as product_title,
        handle as product_handle,
        null as product_description, -- not available in shopify__products
        vendor as product_vendor,
        product_type,
        tags as product_tags,
        status as product_status,
        created_timestamp as product_created_at,
        updated_timestamp as product_updated_at,
        published_timestamp as product_published_at,
        null as options, -- not available in shopify__products
        null as seo_title, -- not available in shopify__products
        null as seo_description, -- not available in shopify__products
        null as product_image_id, -- not available in shopify__products
        null as product_image_url, -- not available in shopify__products
        null as product_image_position, -- not available in shopify__products
        null as product_image_alt_text, -- not available in shopify__products
        count_variants as total_variants,
        null as total_inventory, -- not available in shopify__products
        null as avg_price, -- not available in shopify__products
        null as min_price, -- not available in shopify__products
        null as max_price, -- not available in shopify__products
        subtotal_sold as total_sales,
        total_quantity_sold as total_sales_uniq,
        avg_quantity_per_order_line as avg_quantity_sold,
        total_quantity_sold as quantity_sold

    from shopify_products

)

select * from final