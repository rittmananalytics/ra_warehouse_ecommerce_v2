
with shopify_customer_cohorts as (

    select * from {{ ref('shopify__customer_cohorts') }}

),

final as (

    select
        customer_id,
        null as customer_email, -- not available in shopify__customer_cohorts
        first_order_timestamp as first_order_date,
        cohort_month,
        cohort_month_number as period_number,
        cohort_month_number as months_since_first_order,
        null as order_seq_global, -- not available in shopify__customer_cohorts
        null as order_seq_customer, -- not available in shopify__customer_cohorts
        date_month as order_date_month,
        null as order_id, -- not available in shopify__customer_cohorts
        total_price_lifetime as customer_lifetime_value,
        order_count_lifetime as total_orders,
        total_price_lifetime as total_amount,
        case when order_count_lifetime > 0 then total_price_lifetime / order_count_lifetime else 0 end as avg_order_value,
        total_price_in_month as order_total_price,
        case when cohort_month_number = 1 then 'new' else 'repeat' end as new_vs_repeat

    from shopify_customer_cohorts

)

select * from final