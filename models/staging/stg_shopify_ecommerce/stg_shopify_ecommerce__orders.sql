
with shopify_orders as (

    select * from {{ ref('shopify__orders') }}

),

order_enhanced as (

    select * from {{ source('shopify', 'order_enhanced') }}

),

final as (

    select
        o.order_id,
        o.name as order_name,
        o.customer_id,
        o.email as customer_email,
        o.created_timestamp as order_created_at,
        o.updated_timestamp as order_updated_at,
        o.processed_timestamp as processed_at,
        o.financial_status,
        o.fulfillment_status,
        o.total_price as order_total_price,
        o.subtotal_price as order_subtotal_price,
        o.total_tax as order_total_tax,
        o.total_discounts as order_total_discount,
        o.total_line_items_price,
        o.shipping_cost,
        o.order_adjustment_amount,
        o.total_weight as order_total_weight,
        o.currency as currency_code,
        o.order_tags,
        o.cancelled_timestamp as cancelled_at,
        o.cancel_reason,
        o.refund_subtotal as refund_amount,
        o.customer_order_seq_number as customer_order_sequence_number,
        o.new_vs_repeat,
        o.billing_address_latitude,
        o.billing_address_longitude,
        o.shipping_address_latitude,
        o.shipping_address_longitude,
        o.line_item_count as order_line_count,
        o.order_number as order_url_id,
        coalesce(e.source_name, 'unknown') as source_name,
        e.referring_site,
        e.landing_site_ref as landing_site_base_url,
        e.utm_source,
        e.utm_medium,
        e.utm_campaign

    from shopify_orders o
    left join order_enhanced e
        on o.order_id = e.id

)

select * from final