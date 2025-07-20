with traffic_sources as (

    -- Extract traffic sources from GA4 events
    select distinct
        json_extract_scalar(traffic_source, '$.source') as source,
        json_extract_scalar(traffic_source, '$.medium') as medium,
        json_extract_scalar(traffic_source, '$.campaign') as campaign,
        count(*) as event_count,
        count(distinct user_pseudo_id) as unique_users,
        sum(case when event_name = 'purchase' then 1 else 0 end) as conversions,
        sum(case when event_name = 'purchase' then value else 0 end) as revenue
    from {{ ref('int_events') }}
    where traffic_source is not null
    group by 1, 2, 3

),

order_sources as (

    -- Extract sources from orders (Shopify data)
    select distinct
        source_name,
        referring_site,
        landing_site_base_url,
        count(*) as order_count,
        count(distinct customer_id) as unique_customers,
        sum(order_total_price) as total_revenue,
        avg(order_total_price) as avg_order_value
    from {{ ref('int_orders') }}
    where source_name is not null
    group by 1, 2, 3

),

-- Combine and standardize channel information
channels_combined as (

    -- From GA4 traffic sources
    select
        coalesce(source, 'unknown') as source_raw,
        coalesce(medium, 'unknown') as medium_raw,
        coalesce(campaign, 'unknown') as campaign_raw,
        null as referring_site,
        null as landing_site,
        event_count as sessions,
        unique_users,
        conversions,
        revenue,
        null as order_count,
        null as avg_order_value
    from traffic_sources

    union all

    -- From Shopify order sources
    select
        coalesce(source_name, 'unknown') as source_raw,
        'unknown' as medium_raw,
        'unknown' as campaign_raw,
        referring_site,
        landing_site_base_url as landing_site,
        null as sessions,
        unique_customers as unique_users,
        null as conversions,
        total_revenue as revenue,
        order_count,
        avg_order_value
    from order_sources

),

-- Standardize and categorize channels
channels_standardized as (

    select
        source_raw,
        medium_raw,
        campaign_raw,
        referring_site,
        landing_site,
        
        -- Standardize source names
        case
            when lower(source_raw) in ('google', 'google.com', 'google.co.uk') then 'Google'
            when lower(source_raw) in ('facebook', 'facebook.com', 'fb') then 'Facebook'
            when lower(source_raw) in ('instagram', 'instagram.com', 'ig') then 'Instagram'
            when lower(source_raw) in ('twitter', 'twitter.com', 't.co') then 'Twitter'
            when lower(source_raw) in ('youtube', 'youtube.com') then 'YouTube'
            when lower(source_raw) in ('linkedin', 'linkedin.com') then 'LinkedIn'
            when lower(source_raw) in ('tiktok', 'tiktok.com') then 'TikTok'
            when lower(source_raw) in ('pinterest', 'pinterest.com') then 'Pinterest'
            when lower(source_raw) in ('email', 'newsletter', 'mailchimp') then 'Email'
            when lower(source_raw) in ('direct', '(direct)') then 'Direct'
            when lower(source_raw) in ('organic', 'seo') then 'Organic Search'
            when lower(source_raw) = 'unknown' then 'Unknown'
            else initcap(source_raw)
        end as source_standardized,
        
        -- Standardize medium
        case
            when lower(medium_raw) in ('cpc', 'ppc', 'paid') then 'Paid Search'
            when lower(medium_raw) in ('display', 'banner') then 'Display'
            when lower(medium_raw) in ('social', 'social-network') then 'Social'
            when lower(medium_raw) in ('email', 'newsletter') then 'Email'
            when lower(medium_raw) in ('organic', 'seo') then 'Organic'
            when lower(medium_raw) in ('referral', 'reference') then 'Referral'
            when lower(medium_raw) in ('direct', '(none)') then 'Direct'
            when lower(medium_raw) = 'unknown' then 'Unknown'
            else initcap(medium_raw)
        end as medium_standardized,
        
        -- Channel grouping
        case
            when lower(medium_raw) in ('cpc', 'ppc', 'paid') and lower(source_raw) like '%google%' then 'Google Ads'
            when lower(medium_raw) in ('cpc', 'ppc', 'paid') and lower(source_raw) like '%facebook%' then 'Facebook Ads'
            when lower(medium_raw) in ('cpc', 'ppc', 'paid') then 'Paid Search'
            when lower(medium_raw) in ('display', 'banner') then 'Display Advertising'
            when lower(medium_raw) in ('social', 'social-network') then 'Social Media'
            when lower(medium_raw) in ('email', 'newsletter') then 'Email Marketing'
            when lower(medium_raw) in ('organic', 'seo') then 'Organic Search'
            when lower(medium_raw) in ('referral', 'reference') then 'Referral'
            when lower(medium_raw) in ('direct', '(none)') or lower(source_raw) in ('direct', '(direct)') then 'Direct'
            else 'Other'
        end as channel_group,
        
        -- Aggregate metrics
        sum(coalesce(sessions, 0)) as total_sessions,
        sum(coalesce(unique_users, 0)) as total_unique_users,
        sum(coalesce(conversions, 0)) as total_conversions,
        sum(coalesce(revenue, 0)) as total_revenue,
        sum(coalesce(order_count, 0)) as total_orders,
        avg(avg_order_value) as avg_order_value

    from channels_combined
    group by 1, 2, 3, 4, 5

),

final as (

    select
        row_number() over (order by source_standardized, medium_standardized, campaign_raw) as channel_key,
        source_raw as original_source,
        medium_raw as original_medium,
        campaign_raw as original_campaign,
        source_standardized as source,
        medium_standardized as medium,
        campaign_raw as campaign,
        channel_group,
        referring_site,
        landing_site,
        
        -- Performance metrics
        total_sessions,
        total_unique_users,
        total_conversions,
        total_revenue,
        total_orders,
        avg_order_value,
        
        -- Calculated performance indicators
        case 
            when total_sessions > 0 then total_conversions / total_sessions 
            else 0 
        end as conversion_rate,
        
        case 
            when total_sessions > 0 then total_revenue / total_sessions 
            else 0 
        end as revenue_per_session,
        
        case 
            when total_conversions > 0 then total_revenue / total_conversions 
            else 0 
        end as revenue_per_conversion,
        
        -- Channel characteristics
        case
            when channel_group in ('Google Ads', 'Facebook Ads', 'Paid Search', 'Display Advertising') then 'Paid'
            when channel_group in ('Organic Search', 'Social Media', 'Referral') then 'Earned'
            when channel_group in ('Email Marketing', 'Direct') then 'Owned'
            else 'Other'
        end as channel_type,
        
        case
            when channel_group in ('Google Ads', 'Facebook Ads', 'Paid Search') then 'Performance Marketing'
            when channel_group in ('Display Advertising') then 'Brand Marketing'
            when channel_group in ('Social Media', 'Email Marketing') then 'Relationship Marketing'
            when channel_group in ('Organic Search', 'Referral') then 'Content Marketing'
            else 'Other'
        end as marketing_strategy,
        
        case
            when total_revenue >= 10000 then 'High Value'
            when total_revenue >= 5000 then 'Medium Value'
            when total_revenue >= 1000 then 'Low Value'
            when total_revenue > 0 then 'Minimal Value'
            else 'No Revenue'
        end as channel_value_tier,
        
        current_timestamp() as integration_updated_at

    from channels_standardized

)

select * from final