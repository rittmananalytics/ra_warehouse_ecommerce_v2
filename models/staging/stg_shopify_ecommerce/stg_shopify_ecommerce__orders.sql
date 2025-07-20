
with shopify_orders as (

    select * from {{ ref('shopify__orders') }}

),

final as (

    select
        order_id,
        name as order_name,
        customer_id,
        email as customer_email,
        created_timestamp as order_created_at,
        updated_timestamp as order_updated_at,
        processed_timestamp as processed_at,
        financial_status,
        fulfillment_status,
        total_price as order_total_price,
        subtotal_price as order_subtotal_price,
        total_tax as order_total_tax,
        total_discounts as order_total_discount,
        total_line_items_price,
        shipping_cost,
        order_adjustment_amount,
        total_weight as order_total_weight,
        currency as currency_code,
        order_tags,
        cancelled_timestamp as cancelled_at,
        cancel_reason,
        refund_subtotal as refund_amount,
        customer_order_seq_number as customer_order_sequence_number,
        new_vs_repeat,
        billing_address_latitude,
        billing_address_longitude,
        shipping_address_latitude,
        shipping_address_longitude,
        line_item_count as order_line_count,
        order_number as order_url_id,
        source_name,
        referring_site,
        landing_site_base_url

    from shopify_orders

)

select * from final