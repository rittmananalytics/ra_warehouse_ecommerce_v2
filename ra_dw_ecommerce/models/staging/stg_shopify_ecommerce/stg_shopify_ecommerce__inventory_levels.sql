
with shopify_inventory as (

    select * from {{ ref('shopify__inventory_levels') }}

),

final as (

    select
        inventory_item_id,
        location_id,
        location_name,
        available_quantity as inventory_available,
        updated_at as inventory_updated_at,
        sku,
        unit_cost_amount as inventory_cost,
        is_shipping_required as requires_shipping,
        is_inventory_quantity_tracked as tracked,
        country_code_of_origin,
        province_code_of_origin,
        harmonized_system_code,
        variant_id,
        variant_created_at,
        variant_updated_at,
        variant_title,
        variant_price,
        null as variant_compare_at_price, -- this field appears to be NULL in data
        variant_fulfillment_service,
        variant_inventory_management,
        variant_inventory_policy,
        variant_inventory_quantity,
        variant_option_1,
        variant_option_2,
        variant_option_3,
        is_variant_taxable as variant_taxable,
        variant_barcode,
        variant_grams,
        variant_weight,
        variant_weight_unit,
        product_id,
        null as product_title, -- not available in shopify__inventory_levels
        null as product_handle, -- not available in shopify__inventory_levels
        null as product_vendor, -- not available in shopify__inventory_levels
        null as product_type, -- not available in shopify__inventory_levels
        null as product_tags -- not available in shopify__inventory_levels

    from shopify_inventory

)

select * from final