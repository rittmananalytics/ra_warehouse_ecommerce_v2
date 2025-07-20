{{ config(
    materialized='table',
    unique_key='customer_metrics_key'
) }}

with customer_metrics as (

    select * from {{ ref('int_customer_metrics_simple') }}

),

customers as (

    select * from {{ ref('wh_dim_customers') }}

),

final as (

    select
        -- Surrogate keys
        row_number() over (order by cm.customer_id) as customer_metrics_key,
        coalesce(c.customer_key, -1) as customer_key,
        
        -- Natural key
        cm.customer_id,
        
        -- Basic customer information
        cm.customer_email,
        cm.full_name,
        cm.customer_created_at,
        cm.customer_segment,
        cm.customer_lifecycle_stage,
        
        -- Order behavior metrics
        cm.total_orders,
        cm.total_revenue,
        cm.avg_order_value,
        cm.min_order_value,
        cm.max_order_value,
        null as order_value_std_dev,
        cm.first_order_date,
        cm.most_recent_order_date,
        cm.days_since_first_order,
        cm.days_since_last_order,
        cm.customer_lifespan_days,
        cm.avg_days_between_orders,
        
        -- Product and purchase behavior
        null as unique_products_purchased,
        cm.total_items_purchased,
        cm.avg_items_per_order,
        cm.orders_with_returns,
        cm.total_refund_amount,
        cm.orders_with_discounts,
        cm.total_discount_amount,
        cm.avg_discount_rate,
        
        -- Digital engagement metrics
        cm.total_sessions,
        cm.total_active_days,
        cm.total_page_views,
        cm.total_items_viewed,
        cm.total_add_to_cart_events,
        cm.total_engagement_minutes,
        cm.avg_sessions_to_convert,
        cm.avg_days_to_convert,
        cm.converting_sessions,
        cm.converted_orders,
        null as most_common_journey_type,
        null as most_common_conversion_timeline,
        
        -- RFM Analysis
        cm.recency,
        cm.frequency,
        cm.monetary,
        cm.recency_score,
        cm.frequency_score,
        cm.monetary_score,
        cm.rfm_segment,
        
        -- CLV and predictive metrics
        cm.historical_clv,
        cm.purchase_rate,
        cm.predicted_annual_orders,
        cm.churn_probability,
        cm.predicted_clv_2_year,
        
        -- Customer tiers and classifications
        cm.customer_value_tier,
        cm.digital_engagement_level,
        
        -- Risk flags
        cm.at_risk_churn,
        cm.high_return_rate,
        cm.high_churn_risk,
        cm.one_time_buyer_risk,
        
        -- Advanced customer categorization
        case
            when cm.rfm_segment in ('555', '554', '544', '545', '454', '455', '445') then 'Champions'
            when cm.rfm_segment in ('543', '444', '435', '355') then 'Loyal Customers'
            when cm.rfm_segment in ('512', '511', '422', '421', '412', '411') then 'Potential Loyalists'
            when cm.rfm_segment in ('221', '231', '241', '251') then 'New Customers'
            when cm.rfm_segment in ('155', '154', '144', '214', '215', '115', '114') then 'Promising'
            when cm.rfm_segment in ('512', '511', '412', '411') then 'Need Attention'
            when cm.rfm_segment in ('331', '321', '231', '241', '251') then 'About to Sleep'
            when cm.rfm_segment in ('111', '112', '121', '131', '141', '151') then 'At Risk'
            when cm.rfm_segment in ('155', '154', '144', '214', '215', '115') then 'Cannot Lose Them'
            when cm.rfm_segment in ('132', '123', '122', '212', '211') then 'Hibernating'
            else 'Others'
        end as rfm_customer_segment,
        
        -- Lifetime value tiers
        case
            when cm.predicted_clv_2_year >= 5000 then 'Ultra High CLV'
            when cm.predicted_clv_2_year >= 2000 then 'High CLV'
            when cm.predicted_clv_2_year >= 1000 then 'Medium CLV'
            when cm.predicted_clv_2_year >= 500 then 'Low CLV'
            when cm.predicted_clv_2_year > 0 then 'Minimal CLV'
            else 'Negative CLV'
        end as clv_tier,
        
        -- Customer health score (0-100)
        least(100, greatest(0,
            -- Base score from order behavior (40 points max)
            case
                when cm.total_orders >= 10 then 40
                when cm.total_orders >= 5 then 30
                when cm.total_orders >= 2 then 20
                when cm.total_orders = 1 then 10
                else 0
            end +
            -- Recency bonus/penalty (30 points max)
            case
                when cm.days_since_last_order <= 30 then 30
                when cm.days_since_last_order <= 90 then 20
                when cm.days_since_last_order <= 180 then 10
                when cm.days_since_last_order <= 365 then 5
                else 0
            end +
            -- Engagement bonus (20 points max)
            case
                when cm.total_sessions >= 20 then 20
                when cm.total_sessions >= 10 then 15
                when cm.total_sessions >= 5 then 10
                when cm.total_sessions > 0 then 5
                else 0
            end +
            -- Value bonus (10 points max)
            case
                when cm.avg_order_value >= 200 then 10
                when cm.avg_order_value >= 100 then 7
                when cm.avg_order_value >= 50 then 5
                else 0
            end -
            -- Risk penalties
            case when cm.high_return_rate then 10 else 0 end -
            case when cm.high_churn_risk then 15 else 0 end
        )) as customer_health_score,
        
        -- Marketing recommendations
        case
            when cm.rfm_segment in ('555', '554', '544', '545') and cm.high_churn_risk = false then 'VIP Treatment'
            when cm.rfm_segment in ('444', '435', '355') then 'Loyalty Programs'
            when cm.rfm_segment in ('221', '231', '241', '251') then 'Onboarding Campaign'
            when cm.at_risk_churn then 'Win-back Campaign'
            when cm.one_time_buyer_risk then 'Second Purchase Campaign'
            when cm.high_return_rate then 'Product Quality Review'
            when cm.customer_value_tier in ('VIP', 'High Value') then 'Premium Services'
            else 'Standard Marketing'
        end as recommended_marketing_action,
        
        -- Customer acquisition cost efficiency (simplified)
        case
            when cm.digital_engagement_level = 'Highly Engaged' and cm.total_orders >= 3 then 'High Efficiency'
            when cm.digital_engagement_level in ('Moderately Engaged', 'Low Engagement') and cm.total_orders >= 2 then 'Medium Efficiency'
            when cm.total_orders >= 1 then 'Low Efficiency'
            else 'No Conversion'
        end as acquisition_efficiency,
        
        -- Cross-sell/upsell potential
        case
            when cm.total_orders >= 5 and cm.avg_order_value >= 100 then 'High Cross-sell Potential'
            when cm.total_orders >= 3 and cm.total_orders >= 3 then 'Medium Cross-sell Potential'
            when cm.avg_order_value < cm.max_order_value * 0.7 then 'Upsell Potential'
            else 'Standard'
        end as cross_sell_upsell_potential,
        
        integration_updated_at as effective_from,
        cast('2999-12-31' as timestamp) as effective_to,
        true as is_current,
        current_timestamp() as warehouse_updated_at

    from customer_metrics cm
    left join customers c
        on cm.customer_id = c.customer_id
        and c.is_current = true

)

select * from final