view: fact_customer_journey {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_customer_journey` ;;
  
  # Primary Key
  dimension: journey_key {
    primary_key: yes
    type: number
    sql: ${TABLE}.journey_key ;;
    description: "Customer journey surrogate key"
  }

  # Foreign Keys
  dimension: customer_key {
    type: number
    sql: ${TABLE}.customer_key ;;
    description: "Customer surrogate key"
    hidden: yes
  }

  dimension: order_key {
    type: number
    sql: ${TABLE}.order_key ;;
    description: "Order surrogate key"
    hidden: yes
  }

  dimension: session_key {
    type: number
    sql: ${TABLE}.session_key ;;
    description: "Session surrogate key"
    hidden: yes
  }

  dimension: session_date_key {
    type: number
    sql: ${TABLE}.session_date_key ;;
    description: "Session date key"
    hidden: yes
  }

  dimension: order_date_key {
    type: number
    sql: ${TABLE}.order_date_key ;;
    description: "Order date key"
    hidden: yes
  }

  # Business Keys
  dimension: shopify_customer_id {
    type: number
    sql: ${TABLE}.shopify_customer_id ;;
    description: "Shopify customer ID"
  }

  dimension: shopify_order_id {
    type: number
    sql: ${TABLE}.shopify_order_id ;;
    description: "Shopify order ID"
  }

  dimension: ga4_transaction_id {
    type: string
    sql: ${TABLE}.ga4_transaction_id ;;
    description: "GA4 transaction ID"
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    description: "GA4 session ID"
  }

  dimension: converting_user_pseudo_id {
    type: string
    sql: ${TABLE}.converting_user_pseudo_id ;;
    description: "GA4 user pseudo ID that converted"
  }

  # Timestamps and Dates
  dimension_group: shopify_order {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.shopify_order_timestamp ;;
    description: "Shopify order timestamp"
  }

  dimension: ga4_purchase_timestamp {
    type: number
    sql: ${TABLE}.ga4_purchase_timestamp ;;
    description: "GA4 purchase timestamp (microseconds)"
  }

  dimension: session_date {
    type: date
    sql: ${TABLE}.session_date ;;
    description: "Session date"
  }

  dimension: session_start_timestamp {
    type: number
    sql: ${TABLE}.session_start_timestamp ;;
    description: "Session start timestamp (microseconds)"
  }

  # Journey Metrics
  dimension: days_to_conversion {
    type: number
    sql: ${TABLE}.days_to_conversion ;;
    description: "Days from session to conversion"
  }

  dimension: session_sequence_number {
    type: number
    sql: ${TABLE}.session_sequence_number ;;
    description: "Session sequence number in journey"
  }

  dimension: session_type {
    type: string
    sql: ${TABLE}.session_type ;;
    description: "Type of session"
  }

  dimension: session_duration_minutes {
    type: number
    sql: ${TABLE}.session_duration_minutes ;;
    description: "Session duration in minutes"
  }

  dimension: page_views {
    type: number
    sql: ${TABLE}.page_views ;;
    description: "Page views in session"
  }

  dimension: items_viewed {
    type: number
    sql: ${TABLE}.items_viewed ;;
    description: "Items viewed in session"
  }

  dimension: add_to_cart_events {
    type: number
    sql: ${TABLE}.add_to_cart_events ;;
    description: "Add to cart events in session"
  }

  dimension: begin_checkout_events {
    type: number
    sql: ${TABLE}.begin_checkout_events ;;
    description: "Begin checkout events in session"
  }

  dimension: session_revenue {
    type: number
    sql: ${TABLE}.session_revenue ;;
    value_format_name: usd
    description: "Revenue from session"
  }

  dimension: hours_since_previous_session {
    type: number
    sql: ${TABLE}.hours_since_previous_session ;;
    description: "Hours since previous session"
  }

  dimension: is_converting_session {
    type: yesno
    sql: ${TABLE}.is_converting_session ;;
    description: "Whether session led to conversion"
  }

  # Journey Totals
  dimension: total_sessions_to_conversion {
    type: number
    sql: ${TABLE}.total_sessions_to_conversion ;;
    description: "Total sessions before conversion"
  }

  dimension: total_days_active {
    type: number
    sql: ${TABLE}.total_days_active ;;
    description: "Total days active in journey"
  }

  dimension: total_page_views {
    type: number
    sql: ${TABLE}.total_page_views ;;
    description: "Total page views in journey"
  }

  dimension: total_items_viewed {
    type: number
    sql: ${TABLE}.total_items_viewed ;;
    description: "Total items viewed in journey"
  }

  dimension: total_add_to_cart_events {
    type: number
    sql: ${TABLE}.total_add_to_cart_events ;;
    description: "Total add to cart events in journey"
  }

  dimension: total_begin_checkout_events {
    type: number
    sql: ${TABLE}.total_begin_checkout_events ;;
    description: "Total begin checkout events in journey"
  }

  dimension: total_session_duration_minutes {
    type: number
    sql: ${TABLE}.total_session_duration_minutes ;;
    description: "Total session duration in journey"
  }

  # Journey Timeline Metrics
  dimension: days_from_first_touch_to_conversion {
    type: number
    sql: ${TABLE}.days_from_first_touch_to_conversion ;;
    description: "Days from first touch to conversion"
  }

  dimension: days_from_first_product_view {
    type: number
    sql: ${TABLE}.days_from_first_product_view ;;
    description: "Days from first product view"
  }

  dimension: days_from_first_add_to_cart {
    type: number
    sql: ${TABLE}.days_from_first_add_to_cart ;;
    description: "Days from first add to cart"
  }

  dimension: days_from_first_checkout_start {
    type: number
    sql: ${TABLE}.days_from_first_checkout_start ;;
    description: "Days from first checkout start"
  }

  # Journey Classification
  dimension: journey_complexity {
    type: string
    sql: ${TABLE}.journey_complexity ;;
    description: "Journey complexity classification"
  }

  dimension: conversion_timeline {
    type: string
    sql: ${TABLE}.conversion_timeline ;;
    description: "Conversion timeline classification"
  }

  # Order Metrics
  dimension: shopify_order_value {
    type: number
    sql: ${TABLE}.shopify_order_value ;;
    value_format_name: usd
    description: "Shopify order value"
  }

  # Journey Efficiency Metrics
  dimension: avg_pages_per_session {
    type: number
    sql: ${TABLE}.avg_pages_per_session ;;
    description: "Average pages per session"
  }

  dimension: avg_minutes_per_page {
    type: number
    sql: ${TABLE}.avg_minutes_per_page ;;
    description: "Average minutes per page"
  }

  dimension: revenue_per_session {
    type: number
    sql: ${TABLE}.revenue_per_session ;;
    value_format_name: usd
    description: "Revenue per session"
  }

  dimension: revenue_per_page_view {
    type: number
    sql: ${TABLE}.revenue_per_page_view ;;
    value_format_name: usd
    description: "Revenue per page view"
  }

  # Journey Conversion Rates
  dimension: journey_view_to_cart_rate {
    type: number
    sql: ${TABLE}.journey_view_to_cart_rate ;;
    value_format_name: percent_2
    description: "View to cart rate"
  }

  dimension: journey_cart_to_checkout_rate {
    type: number
    sql: ${TABLE}.journey_cart_to_checkout_rate ;;
    value_format_name: percent_2
    description: "Cart to checkout rate"
  }

  dimension: journey_checkout_to_purchase_rate {
    type: number
    sql: ${TABLE}.journey_checkout_to_purchase_rate ;;
    value_format_name: percent_2
    description: "Checkout to purchase rate"
  }

  dimension: journey_view_to_purchase_rate {
    type: number
    sql: ${TABLE}.journey_view_to_purchase_rate ;;
    value_format_name: percent_2
    description: "View to purchase rate"
  }

  dimension: conversion_behavior_type {
    type: string
    sql: ${TABLE}.conversion_behavior_type ;;
    description: "Conversion behavior type"
  }

  # Attribution
  dimension: attribution_weight {
    type: number
    sql: ${TABLE}.attribution_weight ;;
    description: "Attribution weight for this session"
  }

  dimension: normalized_attribution_weight {
    type: number
    sql: ${TABLE}.normalized_attribution_weight ;;
    description: "Normalized attribution weight"
  }

  # Metadata
  dimension_group: warehouse_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.warehouse_updated_at ;;
    description: "Warehouse update timestamp"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [journey_key, session_id, shopify_order_id]
  }

  measure: total_shopify_order_value {
    type: sum
    sql: ${shopify_order_value} ;;
    value_format_name: usd
    description: "Total Shopify order value"
  }

  measure: total_session_revenue {
    type: sum
    sql: ${session_revenue} ;;
    value_format_name: usd
    description: "Total session revenue"
  }

  measure: avg_sessions_to_conversion {
    type: average
    sql: ${total_sessions_to_conversion} ;;
    value_format_name: decimal_1
    description: "Average sessions to conversion"
  }

  measure: avg_days_to_conversion {
    type: average
    sql: ${days_from_first_touch_to_conversion} ;;
    value_format_name: decimal_1
    description: "Average days to conversion"
  }

  measure: conversion_count {
    type: count
    filters: [is_converting_session: "yes"]
    description: "Number of converting sessions"
  }

  measure: conversion_rate {
    type: number
    sql: ${conversion_count}*1.0 / NULLIF(${count},0) ;;
    value_format_name: percent_2
    description: "Session conversion rate"
  }
}