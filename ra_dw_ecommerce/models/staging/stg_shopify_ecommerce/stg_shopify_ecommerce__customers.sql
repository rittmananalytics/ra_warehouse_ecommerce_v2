
with shopify_customers as (

    select * from {{ ref('shopify__customers') }}

),

final as (

    select
        customer_id,
        email as customer_email,
        created_timestamp as customer_created_at,
        updated_timestamp as customer_updated_at,
        first_name,
        last_name,
        lifetime_total_spent as customer_lifetime_value,
        lifetime_count_orders as customer_order_count,
        first_order_timestamp as first_order_date,
        most_recent_order_timestamp as most_recent_order_date,
        avg_order_value,
        avg_quantity_per_order,
        customer_tags,
        default_address_id,
        phone,
        marketing_consent_state as accepts_marketing,
        marketing_consent_updated_at as marketing_opt_in_at,
        marketing_consent_state as marketing_state,
        note,
        currency as currency_code,
        lifetime_total_spent as total_spent,
        is_tax_exempt as tax_exempt,
        is_verified_email as verified_email

    from shopify_customers

)

select * from final