{{
    config(
        materialized='incremental',
        on_schema_change='sync_all_columns',
        unique_key='order_item_key',
        cluster_by=['order_date_key', 'product_key'],
        alias='fact_order_items'
    )
}}

with order_lines as (
    select * from {{ ref('stg_shopify_ecommerce__order_lines') }}
),

orders as (
    select * from {{ ref('stg_shopify_ecommerce__orders') }}
),

products as (
    select * from {{ ref('wh_dim_products') }}
),

customers as (
    select * from {{ ref('wh_dim_customers') }}
),

channels as (
    select * from {{ ref('wh_dim_channels_enhanced') }}
),

dates as (
    select * from {{ ref('wh_dim_date') }}
),

-- Get the enhanced order data with traffic source
order_enhanced as (
    select 
        o.*,
        -- Map traffic source to channel
        case
            when o.source_name = 'web' and o.referring_site like '%google%' and o.landing_site_base_url like '%organic%' then 'google / organic'
            when o.source_name = 'web' and o.referring_site like '%google%' then 'google / cpc'
            when o.source_name = 'web' and o.referring_site like '%facebook%' then 'facebook / social'
            when o.source_name = 'web' and o.referring_site like '%instagram%' then 'instagram / social'
            when o.source_name = 'web' and o.referring_site like '%pinterest%' then 'pinterest / social'
            when o.source_name = 'web' and o.referring_site like '%tiktok%' then 'tiktok / social'
            when o.source_name = 'email' then 'email / email'
            when o.source_name = 'web' and (o.referring_site is null or o.referring_site = '') then '(direct) / (none)'
            else coalesce(o.source_name || ' / ' || o.referring_site, '(direct) / (none)')
        end as channel_source_medium
    from orders o
),

final as (
    select
        -- Surrogate keys
        {{ dbt_utils.generate_surrogate_key(['ol.order_line_id', 'ol.order_id']) }} as order_item_key,
        ol.order_line_id,
        ol.order_id,
        
        -- Foreign keys
        coalesce(p.product_key, -1) as product_key,
        coalesce(c.customer_key, -1) as customer_key,
        coalesce(ch.channel_key, -1) as channel_key,
        cast(format_date('%Y%m%d', date(o.order_created_at)) as int64) as order_date_key,
        cast(format_date('%Y%m%d', date(o.processed_at)) as int64) as processed_date_key,
        case when o.cancelled_at is not null 
            then cast(format_date('%Y%m%d', date(o.cancelled_at)) as int64) 
            else null 
        end as cancelled_date_key,
        
        -- Order line details
        ol.product_id,
        ol.variant_id,
        ol.sku,
        ol.product_title,
        ol.variant_title,
        ol.vendor,
        ol.product_type,
        
        -- Quantities and amounts
        ol.quantity,
        ol.price as unit_price,
        ol.line_price,
        ol.total_discount as line_discount,
        ol.tax_amount as line_tax,
        ol.line_price - ol.total_discount + ol.tax_amount as line_total,
        
        -- Calculate line item share of order totals
        case when o.order_subtotal_price > 0 
            then ol.line_price / o.order_subtotal_price 
            else 0 
        end as line_share_of_order,
        
        -- Allocated order-level amounts to line items
        case when o.order_subtotal_price > 0 
            then (ol.line_price / o.order_subtotal_price) * o.shipping_cost 
            else 0 
        end as allocated_shipping,
        
        case when o.order_subtotal_price > 0 
            then (ol.line_price / o.order_subtotal_price) * o.refund_amount 
            else 0 
        end as allocated_refund,
        
        -- Product attributes
        ol.is_gift_card,
        ol.requires_shipping,
        ol.is_taxable,
        ol.fulfillment_status,
        ol.fulfillment_service,
        
        -- Order attributes
        o.order_created_at,
        o.order_updated_at,
        o.processed_at,
        o.cancelled_at,
        o.financial_status,
        o.fulfillment_status as order_fulfillment_status,
        o.currency_code,
        o.customer_email,
        
        -- Traffic source from order
        o.source_name,
        o.referring_site,
        o.landing_site_base_url,
        oe.channel_source_medium,
        
        -- Flags
        case when o.cancelled_at is not null then true else false end as is_cancelled,
        case when o.refund_amount > 0 then true else false end as has_refund,
        case when ol.total_discount > 0 then true else false end as has_discount,
        
        -- Discount rate
        case when ol.line_price > 0 
            then ol.total_discount / ol.line_price 
            else 0 
        end as discount_rate,
        
        -- Metadata
        current_timestamp() as warehouse_updated_at

    from order_lines ol
    inner join order_enhanced oe on ol.order_id = oe.order_id
    inner join orders o on ol.order_id = o.order_id
    left join products p on ol.product_id = p.product_id and p.is_current = true
    left join customers c on o.customer_id = c.customer_id and c.is_current = true
    left join channels ch on oe.channel_source_medium = ch.channel_id and ch.is_current = true
    
    {% if is_incremental() %}
        where o.order_updated_at > (select max(order_updated_at) from {{ this }})
    {% endif %}
)

select * from final