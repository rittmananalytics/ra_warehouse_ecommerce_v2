
with shopify_transactions as (

    select * from {{ ref('shopify__transactions') }}

),

final as (

    select
        transaction_id,
        order_id,
        refund_id,
        amount as transaction_amount,
        currency as transaction_currency,
        null as transaction_fee, -- not available in shopify__transactions
        currency_exchange_calculated_amount as transaction_net_amount,
        kind as transaction_kind,
        gateway as transaction_gateway,
        source_name as transaction_source_name,
        status as transaction_status,
        null as transaction_test, -- not available in shopify__transactions
        authorization_code as transaction_authorization,
        location_id as transaction_location_id,
        parent_id as transaction_parent_id,
        processed_timestamp as transaction_processed_at,
        device_id as transaction_device_id,
        created_timestamp as transaction_created_at,
        parent_created_timestamp as order_created_at,
        exchange_rate,
        currency_exchange_calculated_amount as exchange_calculated_amount

    from shopify_transactions

)

select * from final