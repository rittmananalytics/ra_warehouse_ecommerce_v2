{{ config(
    materialized='table',
    unique_key='channel_key'
) }}

with channels as (

    select * from {{ ref('int_channels_enhanced') }}

),

final as (

    select
        -- Surrogate key (already generated in integration layer)
        channel_key,
        
        -- Natural keys and identifiers
        channel_id,
        channel_source,
        channel_medium,
        channel_campaign,
        channel_data_source,
        channel_group,
        attribution_type,
        
        -- Digital engagement metrics
        unique_users,
        total_events,
        sessions,
        page_view_users,
        product_view_users,
        add_to_cart_users,
        checkout_users,
        purchase_users,
        ga4_purchase_value,
        ga4_purchases,
        
        -- Commerce metrics
        total_orders,
        unique_customers,
        total_revenue,
        avg_order_value,
        first_order_date,
        last_order_date,
        
        -- Combined performance metrics
        combined_revenue,
        combined_transactions,
        
        -- Conversion rates and efficiency
        session_conversion_rate,
        cart_conversion_rate,
        user_conversion_rate,
        revenue_per_session,
        revenue_per_customer,
        
        -- Performance categorization
        channel_tier,
        traffic_volume_tier,
        
        -- Channel characteristics
        is_paid_channel,
        is_direct_channel,
        is_organic_channel,
        has_digital_attribution,
        has_commerce_attribution,
        
        -- Enhanced business categorization
        case
            when channel_group = 'Direct' then 1
            when channel_group in ('Organic Search', 'Social Media') then 2
            when channel_group in ('Email Marketing', 'Referral') then 3
            when channel_group = 'Paid Search' then 4
            when channel_group = 'Display Advertising' then 5
            else 6
        end as channel_priority_score,
        
        case
            when combined_revenue >= 100000 then 'Enterprise Channel'
            when combined_revenue >= 50000 then 'Strategic Channel'
            when combined_revenue >= 10000 then 'Growth Channel'
            when combined_revenue >= 1000 then 'Supporting Channel'
            when sessions > 100 or total_orders > 10 then 'Development Channel'
            else 'Emerging Channel'
        end as channel_maturity,
        
        case
            when attribution_type = 'Paid' and combined_revenue >= 10000 then 'High-ROI Paid'
            when attribution_type = 'Paid' and combined_revenue >= 1000 then 'Medium-ROI Paid'
            when attribution_type = 'Paid' then 'Low-ROI Paid'
            when attribution_type = 'Earned' and sessions >= 200 then 'High-Value Earned'
            when attribution_type = 'Earned' and sessions >= 50 then 'Medium-Value Earned'
            when attribution_type = 'Earned' then 'Low-Value Earned'
            when attribution_type = 'Owned' and combined_revenue >= 5000 then 'High-Performing Owned'
            when attribution_type = 'Owned' then 'Standard Owned'
            else 'Uncategorized'
        end as performance_segment,
        
        -- Digital marketing funnel analysis
        case
            when channel_data_source = 'GA4 Analytics' then
                case
                    when sessions > 0 and page_view_users > 0 and add_to_cart_users > 0 and purchase_users > 0 then 'Full Funnel'
                    when sessions > 0 and page_view_users > 0 and add_to_cart_users > 0 then 'Pre-Purchase'
                    when sessions > 0 and page_view_users > 0 then 'Awareness'
                    when sessions > 0 then 'Traffic Only'
                    else 'No Activity'
                end
            else 'Commerce Only'
        end as funnel_performance,
        
        -- Channel health indicators
        case
            when channel_data_source = 'GA4 Analytics' and sessions >= 100 and session_conversion_rate >= 2.0 then 'Healthy'
            when channel_data_source = 'GA4 Analytics' and sessions >= 50 and session_conversion_rate >= 1.0 then 'Good'
            when channel_data_source = 'GA4 Analytics' and sessions >= 10 then 'Developing'
            when channel_data_source = 'Shopify Orders' and total_orders >= 100 then 'Healthy'
            when channel_data_source = 'Shopify Orders' and total_orders >= 10 then 'Good'
            when total_orders > 0 or sessions > 0 then 'Emerging'
            else 'Inactive'
        end as channel_health,
        
        -- ROI and efficiency indicators
        case
            when is_paid_channel and revenue_per_session >= 50 then 'High ROI'
            when is_paid_channel and revenue_per_session >= 20 then 'Medium ROI'
            when is_paid_channel and revenue_per_session > 0 then 'Low ROI'
            when is_paid_channel then 'No ROI'
            when is_organic_channel and revenue_per_session >= 10 then 'High Efficiency'
            when is_organic_channel and revenue_per_session >= 5 then 'Medium Efficiency'
            when is_organic_channel and revenue_per_session > 0 then 'Low Efficiency'
            else 'Not Applicable'
        end as roi_efficiency,
        
        -- Attribution completeness score
        case
            when has_digital_attribution and has_commerce_attribution then 'Complete Attribution'
            when has_digital_attribution and not has_commerce_attribution then 'Digital Only'
            when not has_digital_attribution and has_commerce_attribution then 'Commerce Only'
            else 'No Attribution'
        end as attribution_completeness,
        
        -- Strategic importance
        case
            when channel_group in ('Direct', 'Organic Search') and combined_revenue >= 10000 then 'Critical'
            when channel_group = 'Paid Search' and combined_revenue >= 5000 then 'Critical'
            when channel_group in ('Email Marketing', 'Social Media') and combined_revenue >= 2000 then 'Important'
            when combined_revenue >= 1000 then 'Supporting'
            when sessions >= 100 or total_orders >= 10 then 'Monitoring'
            else 'Experimental'
        end as strategic_importance,
        
        -- Data quality flags
        case when channel_source != 'unknown' then true else false end as has_known_source,
        case when channel_medium not in ('(none)', 'unknown') then true else false end as has_known_medium,
        case when sessions > 0 then true else false end as has_digital_activity,
        case when total_orders > 0 then true else false end as has_commerce_activity,
        case when combined_revenue > 0 then true else false end as has_revenue_attribution,
        case when session_conversion_rate is not null then true else false end as has_conversion_data,
        
        integration_updated_at as effective_from,
        cast('2999-12-31' as timestamp) as effective_to,
        true as is_current,
        current_timestamp() as warehouse_updated_at

    from channels

)

select * from final