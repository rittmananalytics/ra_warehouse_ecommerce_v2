{{ config(
    materialized='table',
    unique_key='event_key'
) }}

with events as (

    select * from {{ ref('int_events') }}

),

date_dim as (

    select * from {{ ref('wh_dim_date') }}

),

final as (

    select
        -- Surrogate keys
        row_number() over (order by e.event_id) as event_key,
        coalesce(d.date_key, -1) as event_date_key,
        
        -- Natural key
        e.event_id,
        
        -- Event identification
        e.user_pseudo_id,
        e.event_timestamp,
        e.event_date,
        e.event_name,
        e.event_category,
        e.event_action,
        e.event_label,
        e.event_value,
        e.currency,
        
        -- Product information
        e.item_id,
        e.item_name,
        e.item_category,
        
        -- Device and location
        e.device_category,
        e.device_brand,
        e.device_model,
        e.operating_system,
        e.browser,
        e.country,
        e.region,
        e.city,
        
        -- Traffic source
        e.traffic_source,
        e.traffic_medium,
        e.traffic_campaign,
        
        -- Event classification
        e.funnel_stage,
        e.is_ecommerce_event,
        e.has_value,
        
        -- Calculated fields
        case
            when e.event_timestamp is not null
            then extract(hour from timestamp_micros(e.event_timestamp))
        end as event_hour,
        
        case
            when extract(hour from timestamp_micros(e.event_timestamp)) between 6 and 11 then 'Morning'
            when extract(hour from timestamp_micros(e.event_timestamp)) between 12 and 17 then 'Afternoon'
            when extract(hour from timestamp_micros(e.event_timestamp)) between 18 and 21 then 'Evening'
            else 'Late Night'
        end as event_time_of_day,
        
        case
            when extract(dayofweek from timestamp_micros(e.event_timestamp)) in (1, 7) then 'Weekend'
            else 'Weekday'
        end as event_day_type,
        
        -- Device categorization
        case
            when e.device_category = 'mobile' then 'Mobile'
            when e.device_category = 'tablet' then 'Tablet'
            when e.device_category = 'desktop' then 'Desktop'
            else 'Other'
        end as device_type,
        
        -- Geographic grouping
        case
            when e.country in ('United States', 'Canada') then 'North America'
            when e.country in ('United Kingdom', 'Germany', 'France', 'Italy', 'Spain', 'Netherlands') then 'Europe'
            when e.country in ('Australia', 'New Zealand') then 'Oceania'
            when e.country in ('Japan', 'South Korea', 'China', 'Singapore', 'Hong Kong') then 'Asia Pacific'
            else 'Other'
        end as geographic_region,
        
        -- Traffic source grouping
        case
            when e.traffic_medium = 'Paid Search' then 'Paid'
            when e.traffic_medium in ('Organic', 'Referral') then 'Earned'
            when e.traffic_medium in ('Email', 'Direct') then 'Owned'
            else 'Other'
        end as traffic_type,
        
        -- Event value categorization
        case
            when e.event_value >= 100 then 'High Value'
            when e.event_value >= 50 then 'Medium Value'
            when e.event_value > 0 then 'Low Value'
            else 'No Value'
        end as event_value_tier,
        
        current_timestamp() as warehouse_updated_at

    from events e
    left join date_dim d
        on parse_date('%Y%m%d', e.event_date) = d.date_actual

)

select * from final