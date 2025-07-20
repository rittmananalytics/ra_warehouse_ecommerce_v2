view: wh_fact_ga4_sessions {
  sql_table_name: `@{PROJECT_ID}.@{ECOMMERCE_DATASET}.wh_fact_ga4_sessions` ;;
  
  # Primary Key
  dimension: session_sk {
    primary_key: yes
    type: string
    sql: ${TABLE}.session_sk ;;
    description: "Session surrogate key"
  }

  # Foreign Keys
  dimension: session_date_key {
    type: string
    sql: ${TABLE}.session_date_key ;;
    description: "Session date key (YYYYMMDD)"
    hidden: yes
  }

  # Session Identification
  dimension: user_pseudo_id {
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
    description: "User pseudo ID from GA4"
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    description: "Session ID"
  }

  dimension: ga_session_id {
    type: string
    sql: ${TABLE}.ga_session_id ;;
    description: "GA4 session ID"
  }

  # Session Metrics
  dimension: page_views {
    type: number
    sql: ${TABLE}.page_views ;;
    description: "Number of page views in session"
  }

  dimension: screen_page_views {
    type: number
    sql: ${TABLE}.screen_page_views ;;
    description: "Number of screen/page views"
  }

  dimension: engaged_sessions {
    type: number
    sql: ${TABLE}.engaged_sessions ;;
    description: "Number of engaged sessions"
  }

  dimension: session_engaged {
    type: yesno
    sql: ${engaged_sessions} > 0 ;;
    description: "Session was engaged"
  }

  dimension: engagement_time_msec {
    type: number
    sql: ${TABLE}.engagement_time_msec ;;
    description: "Engagement time in milliseconds"
  }

  dimension: engagement_time_seconds {
    type: number
    sql: ${engagement_time_msec} / 1000 ;;
    description: "Engagement time in seconds"
    value_format_name: decimal_1
  }

  dimension: engagement_time_minutes {
    type: number
    sql: ${engagement_time_msec} / 60000 ;;
    description: "Engagement time in minutes"
    value_format_name: decimal_1
  }

  # Bounce and Conversion
  dimension: bounced_sessions {
    type: number
    sql: ${TABLE}.bounced_sessions ;;
    description: "Number of bounced sessions"
  }

  dimension: session_bounced {
    type: yesno
    sql: ${bounced_sessions} > 0 ;;
    description: "Session bounced"
  }

  dimension: session_conversion_events {
    type: number
    sql: ${TABLE}.session_conversion_events ;;
    description: "Number of conversion events in session"
  }

  dimension: session_converted {
    type: yesno
    sql: ${session_conversion_events} > 0 ;;
    description: "Session had conversions"
  }

  # Traffic Source
  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
    description: "Traffic source"
  }

  dimension: medium {
    type: string
    sql: ${TABLE}.medium ;;
    description: "Traffic medium"
  }

  dimension: campaign {
    type: string
    sql: ${TABLE}.campaign ;;
    description: "Campaign name"
  }

  dimension: source_medium {
    type: string
    sql: CONCAT(${source}, ' / ', ${medium}) ;;
    description: "Source/Medium combination"
  }

  dimension: channel_grouping {
    type: string
    sql: CASE 
      WHEN ${source} = '(direct)' AND ${medium} IN ('(not set)', '(none)') THEN 'Direct'
      WHEN ${medium} = 'organic' THEN 'Organic Search'
      WHEN ${medium} IN ('cpc', 'ppc') THEN 'Paid Search'
      WHEN ${medium} IN ('display', 'banner') THEN 'Display'
      WHEN ${medium} = 'social' THEN 'Social'
      WHEN ${medium} = 'email' THEN 'Email'
      WHEN ${medium} = 'referral' THEN 'Referral'
      WHEN ${medium} = 'affiliate' THEN 'Affiliate'
      ELSE 'Other'
    END ;;
    description: "Channel grouping"
  }

  # Geographic Information
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    description: "User country"
    map_layer_name: countries
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
    description: "User region/state"
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
    description: "User city"
  }

  # Device Information
  dimension: device_category {
    type: string
    sql: ${TABLE}.device_category ;;
    description: "Device category (desktop, mobile, tablet)"
  }

  dimension: device_operating_system {
    type: string
    sql: ${TABLE}.device_operating_system ;;
    description: "Device operating system"
  }

  dimension: device_browser {
    type: string
    sql: ${TABLE}.device_browser ;;
    description: "Device browser"
  }

  dimension: device_web_info_browser {
    type: string
    sql: ${TABLE}.device_web_info_browser ;;
    description: "Web browser information"
  }

  dimension: device_web_info_browser_version {
    type: string
    sql: ${TABLE}.device_web_info_browser_version ;;
    description: "Browser version"
  }

  # Page Information
  dimension: landing_page {
    type: string
    sql: ${TABLE}.landing_page ;;
    description: "Landing page path"
  }

  dimension: landing_page_hostname {
    type: string
    sql: ${TABLE}.landing_page_hostname ;;
    description: "Landing page hostname"
  }

  # Time Dimensions
  dimension_group: session_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year, day_of_week, hour_of_day]
    sql: ${TABLE}.session_start_timestamp ;;
    description: "Session start time"
  }

  dimension_group: first_visit {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.first_visit_timestamp ;;
    description: "User's first visit time"
  }

  # User Type
  dimension: is_new_user {
    type: yesno
    sql: DATE(${session_start_raw}) = DATE(${first_visit_raw}) ;;
    description: "Is new user (first visit same day as session)"
  }

  dimension: user_type {
    type: string
    sql: CASE WHEN ${is_new_user} THEN 'New' ELSE 'Returning' END ;;
    description: "User type (New/Returning)"
  }

  # Session Quality Metrics
  dimension: session_duration_tier {
    type: tier
    tiers: [0, 30, 60, 180, 300, 600]
    style: relational
    sql: ${engagement_time_seconds} ;;
    description: "Session duration tier (seconds)"
  }

  dimension: pageview_tier {
    type: tier
    tiers: [0, 1, 2, 5, 10, 20]
    style: relational
    sql: ${page_views} ;;
    description: "Page views tier"
  }

  dimension: is_high_engagement {
    type: yesno
    sql: ${engagement_time_seconds} >= 60 AND ${page_views} >= 2 ;;
    description: "High engagement session (>60s and >1 page)"
  }

  # Measures
  measure: count {
    type: count
    description: "Number of sessions"
    drill_fields: [session_start_date, source_medium, device_category, page_views, engagement_time_seconds]
  }

  measure: count_users {
    type: count_distinct
    sql: ${user_pseudo_id} ;;
    description: "Number of unique users"
  }

  measure: total_page_views {
    type: sum
    sql: ${page_views} ;;
    description: "Total page views"
  }

  measure: total_engaged_sessions {
    type: sum
    sql: ${engaged_sessions} ;;
    description: "Total engaged sessions"
  }

  measure: total_bounced_sessions {
    type: sum
    sql: ${bounced_sessions} ;;
    description: "Total bounced sessions"
  }

  measure: engagement_rate {
    type: number
    sql: ${total_engaged_sessions} / NULLIF(${count}, 0) ;;
    description: "Engagement rate"
    value_format_name: percent_1
  }

  measure: bounce_rate {
    type: number
    sql: ${total_bounced_sessions} / NULLIF(${count}, 0) ;;
    description: "Bounce rate"
    value_format_name: percent_1
  }

  measure: average_engagement_time {
    type: average
    sql: ${engagement_time_seconds} ;;
    description: "Average engagement time per session"
    value_format_name: decimal_1
  }

  measure: average_page_views {
    type: average
    sql: ${page_views} ;;
    description: "Average page views per session"
    value_format_name: decimal_1
  }

  measure: total_conversions {
    type: sum
    sql: ${session_conversion_events} ;;
    description: "Total conversion events"
  }

  measure: conversion_rate {
    type: number
    sql: ${total_conversions} / NULLIF(${count}, 0) ;;
    description: "Session conversion rate"
    value_format_name: percent_2
  }

  measure: new_user_rate {
    type: number
    sql: COUNT(CASE WHEN ${is_new_user} THEN 1 END) / NULLIF(${count}, 0) ;;
    description: "New user rate"
    value_format_name: percent_1
  }

  measure: sessions_per_user {
    type: number
    sql: ${count} / NULLIF(${count_users}, 0) ;;
    description: "Average sessions per user"
    value_format_name: decimal_1
  }

  measure: count_mobile_sessions {
    type: count
    filters: [device_category: "mobile"]
    description: "Mobile sessions count"
  }

  measure: mobile_traffic_share {
    type: number
    sql: ${count_mobile_sessions} / NULLIF(${count}, 0) ;;
    description: "Mobile traffic share"
    value_format_name: percent_1
  }
}