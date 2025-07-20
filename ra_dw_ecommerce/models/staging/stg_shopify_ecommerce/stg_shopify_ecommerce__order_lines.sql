
with shopify_order_lines as (

    select * from {{ ref('shopify__order_lines') }}

),

final as (

    select
        order_line_id,
        order_id,
        null as order_created_at, -- not available in shopify__order_lines
        variant_id,
        product_id,
        sku,
        vendor,
        null as product_type, -- not available in shopify__order_lines
        variant_title,
        title as product_title,
        quantity,
        price,
        total_discount,
        price as line_price, -- using price as line_price
        is_taxable,
        order_line_tax as tax_amount,
        is_gift_card,
        null as gift_card_id, -- not available in shopify__order_lines
        fulfillment_status,
        variant_fulfillment_service as fulfillment_service,
        is_shipping_required as requires_shipping,
        variant_created_at,
        variant_updated_at,
        inventory_item_id as variant_inventory_item_id,
        variant_inventory_policy,
        variant_inventory_management,
        variant_barcode,
        variant_compare_at_price,
        variant_weight,
        variant_weight_unit,
        null as product_handle, -- not available in shopify__order_lines
        null as product_tags, -- not available in shopify__order_lines
        vendor as product_vendor,
        null as product_category, -- not available in shopify__order_lines
        null as product_created_at, -- not available in shopify__order_lines
        null as product_updated_at, -- not available in shopify__order_lines
        null as product_published_at -- not available in shopify__order_lines

    from shopify_order_lines

)

select * from final