{{ config(
    materialized='table',
    unique_key='date_key'
) }}

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2020-01-01' as date)",
        end_date="cast('2030-12-31' as date)"
    ) }}

),

final as (

    select
        -- Surrogate key
        cast(format_date('%Y%m%d', date_day) as int64) as date_key,
        
        -- Natural key
        date_day as date_actual,
        
        -- Year attributes
        extract(year from date_day) as year_number,
        concat('Year ', extract(year from date_day)) as year_name,
        
        -- Quarter attributes
        extract(quarter from date_day) as quarter_number,
        concat('Q', extract(quarter from date_day), ' ', extract(year from date_day)) as quarter_name,
        concat(extract(year from date_day), '-Q', extract(quarter from date_day)) as quarter_code,
        
        -- Month attributes
        extract(month from date_day) as month_number,
        format_date('%B', date_day) as month_name,
        format_date('%b', date_day) as month_short_name,
        concat(format_date('%b', date_day), ' ', extract(year from date_day)) as month_year_name,
        format_date('%Y-%m', date_day) as month_year_code,
        
        -- Week attributes
        extract(week from date_day) as week_number,
        extract(isoweek from date_day) as iso_week_number,
        date_trunc(date_day, week(monday)) as week_start_date,
        date_add(date_trunc(date_day, week(monday)), interval 6 day) as week_end_date,
        
        -- Day attributes
        extract(day from date_day) as day_of_month,
        extract(dayofyear from date_day) as day_of_year,
        extract(dayofweek from date_day) as day_of_week_number,
        format_date('%A', date_day) as day_of_week_name,
        format_date('%a', date_day) as day_of_week_short_name,
        
        -- Business day flags
        case 
            when extract(dayofweek from date_day) in (1, 7) then false 
            else true 
        end as is_weekday,
        
        case 
            when extract(dayofweek from date_day) in (1, 7) then true 
            else false 
        end as is_weekend,
        
        -- Period flags relative to current date
        case when date_day = current_date() then true else false end as is_current_day,
        case when date_trunc(date_day, week(monday)) = date_trunc(current_date(), week(monday)) then true else false end as is_current_week,
        case when date_trunc(date_day, month) = date_trunc(current_date(), month) then true else false end as is_current_month,
        case when date_trunc(date_day, quarter) = date_trunc(current_date(), quarter) then true else false end as is_current_quarter,
        case when extract(year from date_day) = extract(year from current_date()) then true else false end as is_current_year,
        
        -- Previous period flags
        case when date_day = date_sub(current_date(), interval 1 day) then true else false end as is_previous_day,
        case when date_trunc(date_day, week(monday)) = date_sub(date_trunc(current_date(), week(monday)), interval 7 day) then true else false end as is_previous_week,
        case when date_trunc(date_day, month) = date_sub(date_trunc(current_date(), month), interval 1 month) then true else false end as is_previous_month,
        case when date_trunc(date_day, quarter) = date_sub(date_trunc(current_date(), quarter), interval 3 month) then true else false end as is_previous_quarter,
        case when extract(year from date_day) = extract(year from current_date()) - 1 then true else false end as is_previous_year,
        
        -- Fiscal year (assuming April 1 start)
        case 
            when extract(month from date_day) >= 4 then extract(year from date_day)
            else extract(year from date_day) - 1
        end as fiscal_year,
        
        case 
            when extract(month from date_day) >= 4 then extract(month from date_day) - 3
            else extract(month from date_day) + 9
        end as fiscal_quarter,
        
        current_timestamp() as warehouse_updated_at

    from date_spine

)

select * from final