view: fact_events {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_events` ;;
  
  # Primary Key
  dimension: event_key {
    primary_key: yes
    type: string
    sql: ${TABLE}.event_key ;;
    description: "Event surrogate key"
  }

  # Foreign Keys
  dimension: event_date_key {
    type: number
    sql: ${TABLE}.event_date_key ;;
    description: "Event date key (YYYYMMDD)"
    hidden: yes
  }

  # Event Identification
  dimension: event_id {
    type: string
    sql: ${TABLE}.event_id ;;
    description: "Unique event identifier"
  }

  dimension: user_pseudo_id {
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
    description: "User pseudo ID from GA4"
  }

  # Event Time
  dimension: event_timestamp {
    type: number
    sql: ${TABLE}.event_timestamp ;;
    description: "Event timestamp"
    hidden: yes
  }

  dimension_group: event {
    type: time
    timeframes: [raw, time, hour, date, week, month, quarter, year]
    sql: TIMESTAMP_MICROS(${event_timestamp}) ;;
    description: "Event timestamp as datetime"
  }

  dimension_group: event_date_only {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.event_date ;;
    description: "Event date from table"
  }

  # Event Attributes
  dimension: event_name {
    type: string
    sql: ${TABLE}.event_name ;;
    description: "GA4 event name"
  }

  dimension: event_category {
    type: string
    sql: ${TABLE}.event_category ;;
    description: "Event category"
  }

  dimension: event_action {
    type: string
    sql: ${TABLE}.event_action ;;
    description: "Event action"
  }

  dimension: event_label {
    type: string
    sql: ${TABLE}.event_label ;;
    description: "Event label"
  }

  dimension: event_value {
    type: number
    sql: ${TABLE}.event_value ;;
    description: "Event value"
  }

  dimension: currency {
    type: string
    sql: ${TABLE}.currency ;;
    description: "Currency code"
  }

  # Ecommerce Event Fields
  dimension: item_id {
    type: string
    sql: ${TABLE}.item_id ;;
    description: "Product ID for ecommerce events"
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}.item_name ;;
    description: "Product name for ecommerce events"
  }

  dimension: item_category {
    type: string
    sql: ${TABLE}.item_category ;;
    description: "Product category for ecommerce events"
  }

  # Device Information
  dimension: device_category {
    type: string
    sql: ${TABLE}.device_category ;;
    description: "Device category (desktop, mobile, tablet)"
  }

  dimension: device_brand {
    type: string
    sql: ${TABLE}.device_brand ;;
    description: "Device brand"
  }

  dimension: device_model {
    type: string
    sql: ${TABLE}.device_model ;;
    description: "Device model"
  }

  dimension: operating_system {
    type: string
    sql: ${TABLE}.operating_system ;;
    description: "Operating system"
  }

  dimension: browser {
    type: string
    sql: ${TABLE}.browser ;;
    description: "Browser name"
  }

  # Geographic Information
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    description: "Country"
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
    description: "Region/State"
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
    description: "City"
  }

  # Traffic Source
  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
    description: "Traffic source"
  }

  dimension: traffic_medium {
    type: string
    sql: ${TABLE}.traffic_medium ;;
    description: "Traffic medium"
  }

  dimension: traffic_campaign {
    type: string
    sql: ${TABLE}.traffic_campaign ;;
    description: "Traffic campaign"
  }

  # Event Classification
  dimension: funnel_stage {
    type: string
    sql: ${TABLE}.funnel_stage ;;
    description: "Funnel stage classification"
  }

  dimension: is_ecommerce_event {
    type: yesno
    sql: ${TABLE}.is_ecommerce_event ;;
    description: "Event is ecommerce related"
  }

  dimension: has_value {
    type: yesno
    sql: ${TABLE}.has_value ;;
    description: "Event has a value"
  }

  # Time Analysis
  # Note: event_hour is already included in the event dimension_group timeframes above

  dimension: event_time_of_day {
    type: string
    sql: ${TABLE}.event_time_of_day ;;
    description: "Time of day classification"
  }

  dimension: event_day_type {
    type: string
    sql: ${TABLE}.event_day_type ;;
    description: "Day type (weekday/weekend)"
  }

  # Categorizations
  dimension: device_type {
    type: string
    sql: ${TABLE}.device_type ;;
    description: "Device type categorization"
  }

  dimension: geographic_region {
    type: string
    sql: ${TABLE}.geographic_region ;;
    description: "Geographic region categorization"
  }

  dimension: traffic_type {
    type: string
    sql: ${TABLE}.traffic_type ;;
    description: "Traffic type categorization"
  }

  dimension: event_value_tier {
    type: string
    sql: ${TABLE}.event_value_tier ;;
    description: "Event value tier"
  }

  dimension_group: warehouse_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.warehouse_updated_at ;;
    description: "Warehouse update timestamp"
  }

  # Measures
  measure: event_count {
    type: count
    description: "Total number of events"
  }

  measure: unique_users {
    type: count_distinct
    sql: ${user_pseudo_id} ;;
    description: "Number of unique users"
  }

  measure: page_views {
    type: count
    filters: [event_name: "page_view"]
    description: "Total page views"
  }

  measure: add_to_cart_events {
    type: count
    filters: [event_name: "add_to_cart"]
    description: "Add to cart events"
  }

  measure: begin_checkout_events {
    type: count
    filters: [event_name: "begin_checkout"]
    description: "Begin checkout events"
  }

  measure: purchase_events {
    type: count
    filters: [event_name: "purchase"]
    description: "Purchase events"
  }

  measure: total_event_value {
    type: sum
    sql: ${event_value} ;;
    description: "Total event value"
  }

  measure: average_event_value {
    type: average
    sql: ${event_value} ;;
    description: "Average event value"
    value_format_name: decimal_2
  }

  measure: events_with_value {
    type: count
    filters: [has_value: "yes"]
    description: "Events that have a value"
  }

  measure: ecommerce_events {
    type: count
    filters: [is_ecommerce_event: "yes"]
    description: "Total ecommerce events"
  }

  measure: conversion_events {
    type: count
    filters: [event_name: "purchase, add_to_cart, begin_checkout, view_item"]
    description: "Key conversion events"
  }

  measure: events_per_user {
    type: number
    sql: ${event_count} / NULLIF(${unique_users}, 0) ;;
    description: "Average events per user"
    value_format_name: decimal_1
  }

  measure: mobile_event_percentage {
    type: number
    sql: COUNT(CASE WHEN ${device_category} = 'mobile' THEN 1 END) / NULLIF(${event_count}, 0) ;;
    description: "Percentage of events from mobile devices"
    value_format_name: percent_1
  }
}