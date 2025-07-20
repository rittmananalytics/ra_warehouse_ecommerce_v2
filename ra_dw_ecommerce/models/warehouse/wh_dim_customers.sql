{{ config(
    materialized='table',
    unique_key='customer_key'
) }}

with customers as (

    select * from {{ ref('int_customers') }}

),

final as (

    select
        -- Surrogate key (sequential)
        row_number() over (order by customer_id) as customer_key,
        
        -- Natural key
        customer_id,
        
        -- Customer attributes
        customer_email,
        first_name,
        last_name,
        coalesce(concat(first_name, ' ', last_name), customer_email) as full_name,
        phone,
        customer_created_at,
        customer_updated_at,
        customer_state,
        
        -- Address attributes
        default_address_city as city,
        default_address_province as state_province,
        default_address_province_code as state_province_code,
        default_address_country as country,
        default_address_country_code as country_code,
        default_address_zip as postal_code,
        
        -- Marketing attributes
        accepts_marketing,
        
        -- Customer metrics
        shopify_lifetime_value,
        shopify_order_count,
        calculated_lifetime_value,
        calculated_order_count,
        avg_order_value,
        first_order_date,
        last_order_date,
        days_since_first_order,
        days_since_last_order,
        
        -- Customer segmentation
        customer_segment,
        customer_lifecycle_stage,
        
        -- Additional calculated fields
        case
            when calculated_lifetime_value >= 1000 then 'VIP'
            when calculated_lifetime_value >= 500 then 'High Value'
            when calculated_lifetime_value >= 200 then 'Medium Value'
            when calculated_lifetime_value >= 50 then 'Low Value'
            else 'Minimal Value'
        end as customer_value_tier,
        
        case
            when days_since_last_order is null then 'New Customer'
            when days_since_last_order <= 30 then 'Very Active'
            when days_since_last_order <= 90 then 'Active'
            when days_since_last_order <= 180 then 'Moderately Active'
            when days_since_last_order <= 365 then 'Inactive'
            else 'Very Inactive'
        end as recency_segment,
        
        case
            when avg_order_value >= 200 then 'High AOV'
            when avg_order_value >= 100 then 'Medium AOV'
            when avg_order_value >= 50 then 'Low AOV'
            else 'Very Low AOV'
        end as aov_segment,
        
        -- Geography groupings
        case
            when default_address_country_code is null then 'Unknown'
            when cast(default_address_country_code as string) in ('US', 'CA') then 'North America'
            when cast(default_address_country_code as string) in ('GB', 'DE', 'FR', 'IT', 'ES', 'NL') then 'Europe'
            when cast(default_address_country_code as string) in ('AU', 'NZ') then 'Oceania'
            when cast(default_address_country_code as string) in ('JP', 'KR', 'CN', 'SG', 'HK') then 'Asia Pacific'
            else 'Other'
        end as region,
        
        -- Data quality flags
        case when customer_email is not null then true else false end as has_email,
        case when phone is not null then true else false end as has_phone,
        case when default_address_city is not null then true else false end as has_address,
        case when first_name is not null and last_name is not null then true else false end as has_full_name,
        
        -- SCD Type 2 fields
        integration_updated_at as effective_from,
        cast('2999-12-31' as timestamp) as effective_to,
        true as is_current,
        current_timestamp() as warehouse_updated_at

    from customers

)

select * from final