-- Enhanced channels model combining GA4 traffic sources and Shopify order sources
with ga4_traffic_sources as (

    select
        traffic_source,
        traffic_medium,
        traffic_campaign,
        count(distinct user_pseudo_id) as unique_users,
        count(distinct event_id) as total_events,
        count(distinct case when event_name = 'session_start' then user_pseudo_id end) as sessions,
        count(distinct case when event_name = 'page_view' then user_pseudo_id end) as page_view_users,
        count(distinct case when event_name = 'view_item' then user_pseudo_id end) as product_view_users,
        count(distinct case when event_name = 'add_to_cart' then user_pseudo_id end) as add_to_cart_users,
        count(distinct case when event_name = 'begin_checkout' then user_pseudo_id end) as checkout_users,
        count(distinct case when event_name = 'purchase' then user_pseudo_id end) as purchase_users,
        sum(case when event_name = 'purchase' then event_value else 0 end) as total_purchase_value,
        count(case when event_name = 'purchase' then 1 end) as purchase_events
    from {{ ref('int_events') }}
    where traffic_source is not null
    group by traffic_source, traffic_medium, traffic_campaign

),

shopify_order_sources as (

    select
        coalesce(source_name, 'unknown') as order_source,
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as unique_customers,
        sum(order_total_price) as total_revenue,
        avg(order_total_price) as avg_order_value,
        min(order_created_at) as first_order_date,
        max(order_created_at) as last_order_date
    from {{ ref('int_orders') }}
    group by source_name

),

-- Standardize and combine both data sources
channels_combined as (

    -- GA4 Traffic Sources
    select
        concat('ga4_', coalesce(traffic_source, 'unknown'), '_', coalesce(traffic_medium, 'none')) as channel_id,
        coalesce(traffic_source, 'unknown') as channel_source,
        coalesce(traffic_medium, 'none') as channel_medium,
        coalesce(traffic_campaign, '(not set)') as channel_campaign,
        'GA4 Analytics' as channel_data_source,
        
        -- Standardize channel groupings based on GA4 attribution
        case
            when traffic_medium = 'organic' then 'Organic Search'
            when traffic_medium in ('cpc', 'ppc', 'paid-search') then 'Paid Search'
            when traffic_medium = 'email' then 'Email Marketing'
            when traffic_medium = 'social' then 'Social Media'
            when traffic_medium = 'referral' then 'Referral'
            when traffic_medium = 'affiliate' then 'Affiliate'
            when traffic_medium = 'display' then 'Display Advertising'
            when traffic_medium = '(none)' and traffic_source = '(direct)' then 'Direct'
            when traffic_medium = '(none)' then 'Direct'
            else 'Other Digital'
        end as channel_group,
        
        -- Digital attribution category
        case
            when traffic_medium in ('cpc', 'ppc', 'paid-search', 'display') then 'Paid'
            when traffic_medium in ('organic', 'referral', 'social') then 'Earned'
            when traffic_medium in ('email', '(none)') then 'Owned'
            else 'Other'
        end as attribution_type,
        
        -- GA4 performance metrics
        unique_users,
        total_events,
        sessions,
        page_view_users,
        product_view_users,
        add_to_cart_users,
        checkout_users,
        purchase_users,
        total_purchase_value as ga4_purchase_value,
        purchase_events as ga4_purchases,
        
        -- Shopify metrics (null for GA4 records)
        null as total_orders,
        null as unique_customers,
        null as total_revenue,
        null as avg_order_value,
        null as first_order_date,
        null as last_order_date

    from ga4_traffic_sources
    
    union all
    
    -- Shopify Order Sources
    select
        concat('shopify_', coalesce(order_source, 'unknown')) as channel_id,
        coalesce(order_source, 'unknown') as channel_source,
        'shopify' as channel_medium,
        '(not applicable)' as channel_campaign,
        'Shopify Orders' as channel_data_source,
        
        -- Map Shopify sources to channel groups
        case
            when lower(coalesce(order_source, '')) like '%web%' then 'Direct'
            when lower(coalesce(order_source, '')) like '%online%' then 'Direct'
            when lower(coalesce(order_source, '')) like '%pos%' then 'In-Store'
            when lower(coalesce(order_source, '')) like '%mobile%' then 'Mobile App'
            when lower(coalesce(order_source, '')) like '%draft%' then 'Draft Orders'
            when lower(coalesce(order_source, '')) like '%admin%' then 'Admin/Manual'
            when coalesce(order_source, '') = 'unknown' then 'Unknown'
            else 'Other Commerce'
        end as channel_group,
        
        -- Commerce attribution category
        case
            when lower(coalesce(order_source, '')) like '%pos%' then 'Physical'
            when lower(coalesce(order_source, '')) like '%admin%' then 'Manual'
            else 'Digital'
        end as attribution_type,
        
        -- GA4 metrics (null for Shopify records)
        null as unique_users,
        null as total_events,
        null as sessions,
        null as page_view_users,
        null as product_view_users,
        null as add_to_cart_users,
        null as checkout_users,
        null as purchase_users,
        null as ga4_purchase_value,
        null as ga4_purchases,
        
        -- Shopify performance metrics
        total_orders,
        unique_customers,
        total_revenue,
        avg_order_value,
        first_order_date,
        last_order_date

    from shopify_order_sources

),

final as (

    select
        row_number() over (order by 
            coalesce(total_revenue, 0) + coalesce(ga4_purchase_value, 0) desc,
            coalesce(sessions, 0) desc
        ) as channel_key,
        
        channel_id,
        channel_source,
        channel_medium,
        channel_campaign,
        channel_data_source,
        channel_group,
        attribution_type,
        
        -- Digital engagement metrics
        coalesce(unique_users, 0) as unique_users,
        coalesce(total_events, 0) as total_events,
        coalesce(sessions, 0) as sessions,
        coalesce(page_view_users, 0) as page_view_users,
        coalesce(product_view_users, 0) as product_view_users,
        coalesce(add_to_cart_users, 0) as add_to_cart_users,
        coalesce(checkout_users, 0) as checkout_users,
        coalesce(purchase_users, 0) as purchase_users,
        coalesce(ga4_purchase_value, 0) as ga4_purchase_value,
        coalesce(ga4_purchases, 0) as ga4_purchases,
        
        -- Commerce metrics
        coalesce(total_orders, 0) as total_orders,
        coalesce(unique_customers, 0) as unique_customers,
        coalesce(total_revenue, 0) as total_revenue,
        avg_order_value,
        first_order_date,
        last_order_date,
        
        -- Combined performance metrics
        coalesce(total_revenue, 0) + coalesce(ga4_purchase_value, 0) as combined_revenue,
        coalesce(total_orders, 0) + coalesce(ga4_purchases, 0) as combined_transactions,
        
        -- Conversion rates and efficiency
        case
            when sessions > 0 and ga4_purchases > 0
            then round(ga4_purchases / sessions * 100, 2)
            else null
        end as session_conversion_rate,
        
        case
            when add_to_cart_users > 0 and purchase_users > 0
            then round(purchase_users / add_to_cart_users * 100, 2)
            else null
        end as cart_conversion_rate,
        
        case
            when unique_users > 0 and purchase_users > 0
            then round(purchase_users / unique_users * 100, 2)
            else null
        end as user_conversion_rate,
        
        -- Revenue efficiency
        case
            when sessions > 0 and ga4_purchase_value > 0
            then round(ga4_purchase_value / sessions, 2)
            else null
        end as revenue_per_session,
        
        case
            when unique_customers > 0 and total_revenue > 0
            then round(total_revenue / unique_customers, 2)
            else null
        end as revenue_per_customer,
        
        -- Performance categorization
        case
            when coalesce(total_revenue, 0) + coalesce(ga4_purchase_value, 0) >= 50000 then 'Tier 1 - Strategic'
            when coalesce(total_revenue, 0) + coalesce(ga4_purchase_value, 0) >= 25000 then 'Tier 2 - High Value'
            when coalesce(total_revenue, 0) + coalesce(ga4_purchase_value, 0) >= 10000 then 'Tier 3 - Important'
            when coalesce(total_revenue, 0) + coalesce(ga4_purchase_value, 0) >= 1000 then 'Tier 4 - Supporting'
            else 'Tier 5 - Emerging'
        end as channel_tier,
        
        case
            when coalesce(sessions, 0) >= 1000 then 'High Volume'
            when coalesce(sessions, 0) >= 500 then 'Medium Volume'
            when coalesce(sessions, 0) >= 100 then 'Low Volume'
            when coalesce(sessions, 0) > 0 then 'Minimal Volume'
            else 'No Digital Activity'
        end as traffic_volume_tier,
        
        -- Channel efficiency flags
        case 
            when attribution_type = 'Paid' then true 
            else false 
        end as is_paid_channel,
        
        case 
            when channel_group = 'Direct' then true 
            else false 
        end as is_direct_channel,
        
        case 
            when attribution_type in ('Earned', 'Owned') then true 
            else false 
        end as is_organic_channel,
        
        case 
            when channel_data_source = 'GA4 Analytics' then true 
            else false 
        end as has_digital_attribution,
        
        case 
            when channel_data_source = 'Shopify Orders' then true 
            else false 
        end as has_commerce_attribution,
        
        current_timestamp() as integration_updated_at

    from channels_combined

)

select * from final