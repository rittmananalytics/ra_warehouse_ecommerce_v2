with shopify_orders as (

    select * from {{ ref('stg_shopify_ecommerce__orders') }}

),

order_lines as (

    select * from {{ ref('stg_shopify_ecommerce__order_lines') }}

),

order_aggregates as (

    select
        order_id,
        count(distinct order_line_id) as line_item_count,
        count(distinct product_id) as unique_product_count,
        sum(quantity) as total_quantity,
        sum(line_price) as calculated_order_total,
        sum(total_discount) as total_line_discounts,
        avg(line_price) as avg_line_price,
        max(line_price) as max_line_price,
        min(line_price) as min_line_price
    from order_lines
    group by order_id

),

-- Note: Shopify discounts are at the discount code level, not order level
-- We'll calculate discount information from the orders table itself

final as (

    select
        o.order_id,
        o.order_name,
        o.customer_id,
        o.customer_email,
        o.order_created_at,
        o.order_updated_at,
        o.processed_at as order_processed_at,
        o.cancelled_at as order_cancelled_at,
        o.financial_status,
        o.fulfillment_status,
        o.order_total_price,
        o.order_subtotal_price as subtotal_price,
        o.order_total_tax as total_tax,
        o.order_total_discount as total_discounts,
        o.shipping_cost,
        o.order_adjustment_amount,
        o.refund_amount as refund_subtotal,
        null as refund_tax, -- not available in staging
        o.source_name,
        null as processing_method, -- not available in staging
        o.referring_site,
        o.landing_site_base_url,
        null as order_note, -- not available in staging
        null as shipping_company, -- not available in staging
        null as tracking_company, -- not available in staging
        null as tracking_number, -- not available in staging
        null as shipping_address_first_name, -- not available in staging
        null as shipping_address_last_name, -- not available in staging
        null as shipping_address_company, -- not available in staging
        null as shipping_address_phone, -- not available in staging
        null as shipping_address_address_1, -- not available in staging
        null as shipping_address_address_2, -- not available in staging
        null as shipping_address_city, -- not available in staging
        null as shipping_address_province, -- not available in staging
        null as shipping_address_province_code, -- not available in staging
        null as shipping_address_country, -- not available in staging
        null as shipping_address_country_code, -- not available in staging
        null as shipping_address_zip, -- not available in staging
        
        -- Order line aggregates
        coalesce(agg.line_item_count, 0) as line_item_count,
        coalesce(agg.unique_product_count, 0) as unique_product_count,
        coalesce(agg.total_quantity, 0) as total_quantity,
        coalesce(agg.calculated_order_total, 0) as calculated_order_total,
        coalesce(agg.total_line_discounts, 0) as total_line_discounts,
        agg.avg_line_price,
        agg.max_line_price,
        agg.min_line_price,
        
        -- Discount information from order totals
        case when o.order_total_discount > 0 then 1 else 0 end as discount_count,
        coalesce(o.order_total_discount, 0) as total_discount_amount,
        
        -- Order flags and categorization
        case when o.cancelled_at is not null then true else false end as is_cancelled,
        case when o.refund_amount > 0 then true else false end as has_refund,
        case when agg.unique_product_count > 1 then true else false end as is_multi_product_order,
        case when o.order_total_discount > 0 then true else false end as has_discount,
        
        -- Order value categorization
        case 
            when o.order_total_price >= 200 then 'High Value'
            when o.order_total_price >= 100 then 'Medium Value'
            when o.order_total_price >= 50 then 'Low Value'
            else 'Very Low Value'
        end as order_value_category,
        
        current_timestamp() as integration_updated_at

    from shopify_orders o
    left join order_aggregates agg
        on o.order_id = agg.order_id

)

select * from final