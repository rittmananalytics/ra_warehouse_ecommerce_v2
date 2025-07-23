view: dim_channels {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.dim_channels` ;;
  
  # Primary Key
  dimension: channel_key {
    primary_key: yes
    type: number
    sql: ${TABLE}.channel_key ;;
    description: "Channel surrogate key"
  }

  # Natural Keys and Identifiers
  dimension: channel_id {
    type: string
    sql: ${TABLE}.channel_id ;;
    description: "Channel business key"
  }

  dimension: channel_source {
    type: string
    sql: ${TABLE}.channel_source ;;
    description: "Traffic source"
  }

  dimension: channel_medium {
    type: string
    sql: ${TABLE}.channel_medium ;;
    description: "Traffic medium"
  }

  dimension: channel_campaign {
    type: string
    sql: ${TABLE}.channel_campaign ;;
    description: "Campaign name"
  }

  dimension: channel_data_source {
    type: string
    sql: ${TABLE}.channel_data_source ;;
    description: "Data source"
  }

  dimension: channel_group {
    type: string
    sql: ${TABLE}.channel_group ;;
    description: "Channel grouping"
  }

  dimension: attribution_type {
    type: string
    sql: ${TABLE}.attribution_type ;;
    description: "Attribution type"
  }

  # Digital Engagement Metrics
  dimension: unique_users {
    type: number
    sql: ${TABLE}.unique_users ;;
    description: "Unique users from this channel"
  }

  dimension: total_events {
    type: number
    sql: ${TABLE}.total_events ;;
    description: "Total events from this channel"
  }

  dimension: sessions {
    type: number
    sql: ${TABLE}.sessions ;;
    description: "Sessions from this channel"
  }

  dimension: page_view_users {
    type: number
    sql: ${TABLE}.page_view_users ;;
    description: "Users who viewed pages"
  }

  dimension: product_view_users {
    type: number
    sql: ${TABLE}.product_view_users ;;
    description: "Users who viewed products"
  }

  dimension: add_to_cart_users {
    type: number
    sql: ${TABLE}.add_to_cart_users ;;
    description: "Users who added to cart"
  }

  dimension: checkout_users {
    type: number
    sql: ${TABLE}.checkout_users ;;
    description: "Users who began checkout"
  }

  dimension: purchase_users {
    type: number
    sql: ${TABLE}.purchase_users ;;
    description: "Users who made purchases"
  }

  dimension: ga4_purchase_value {
    type: number
    sql: ${TABLE}.ga4_purchase_value ;;
    value_format_name: usd
    description: "Purchase value from GA4"
  }

  dimension: ga4_purchases {
    type: number
    sql: ${TABLE}.ga4_purchases ;;
    description: "Number of purchases from GA4"
  }

  # Commerce Metrics
  dimension: total_orders {
    type: number
    sql: ${TABLE}.total_orders ;;
    description: "Total orders from this channel"
  }

  dimension: unique_customers {
    type: number
    sql: ${TABLE}.unique_customers ;;
    description: "Unique customers from this channel"
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}.total_revenue ;;
    value_format_name: usd
    description: "Total revenue from this channel"
  }

  dimension: avg_order_value {
    type: number
    sql: ${TABLE}.avg_order_value ;;
    value_format_name: usd
    description: "Average order value"
  }

  dimension_group: first_order {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.first_order_date ;;
    description: "First order date from this channel"
  }

  dimension_group: last_order {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.last_order_date ;;
    description: "Last order date from this channel"
  }

  # Combined Performance Metrics
  dimension: combined_revenue {
    type: number
    sql: ${TABLE}.combined_revenue ;;
    value_format_name: usd
    description: "Combined revenue (GA4 + Shopify)"
  }

  dimension: combined_transactions {
    type: number
    sql: ${TABLE}.combined_transactions ;;
    description: "Combined transactions"
  }

  # Conversion Metrics
  dimension: session_conversion_rate {
    type: number
    sql: ${TABLE}.session_conversion_rate ;;
    value_format_name: percent_2
    description: "Session conversion rate"
  }

  dimension: cart_conversion_rate {
    type: number
    sql: ${TABLE}.cart_conversion_rate ;;
    value_format_name: percent_2
    description: "Cart conversion rate"
  }

  dimension: user_conversion_rate {
    type: number
    sql: ${TABLE}.user_conversion_rate ;;
    value_format_name: percent_2
    description: "User conversion rate"
  }

  dimension: revenue_per_session {
    type: number
    sql: ${TABLE}.revenue_per_session ;;
    value_format_name: usd
    description: "Revenue per session"
  }

  dimension: revenue_per_customer {
    type: number
    sql: ${TABLE}.revenue_per_customer ;;
    value_format_name: usd
    description: "Revenue per customer"
  }

  # Categorizations
  dimension: channel_tier {
    type: string
    sql: ${TABLE}.channel_tier ;;
    description: "Channel tier"
  }

  dimension: traffic_volume_tier {
    type: string
    sql: ${TABLE}.traffic_volume_tier ;;
    description: "Traffic volume tier"
  }

  dimension: is_paid_channel {
    type: yesno
    sql: ${TABLE}.is_paid_channel ;;
    description: "Is paid advertising channel"
  }

  dimension: is_direct_channel {
    type: yesno
    sql: ${TABLE}.is_direct_channel ;;
    description: "Is direct channel"
  }

  dimension: is_organic_channel {
    type: yesno
    sql: ${TABLE}.is_organic_channel ;;
    description: "Is organic channel"
  }

  dimension: has_digital_attribution {
    type: yesno
    sql: ${TABLE}.has_digital_attribution ;;
    description: "Has digital attribution"
  }

  dimension: has_commerce_attribution {
    type: yesno
    sql: ${TABLE}.has_commerce_attribution ;;
    description: "Has commerce attribution"
  }

  # Scoring and Classification
  dimension: channel_priority_score {
    type: number
    sql: ${TABLE}.channel_priority_score ;;
    description: "Channel priority score"
  }

  dimension: channel_maturity {
    type: string
    sql: ${TABLE}.channel_maturity ;;
    description: "Channel maturity"
  }

  dimension: performance_segment {
    type: string
    sql: ${TABLE}.performance_segment ;;
    description: "Performance segment"
  }

  dimension: funnel_performance {
    type: string
    sql: ${TABLE}.funnel_performance ;;
    description: "Funnel performance"
  }

  dimension: channel_health {
    type: string
    sql: ${TABLE}.channel_health ;;
    description: "Channel health"
  }

  dimension: roi_efficiency {
    type: string
    sql: ${TABLE}.roi_efficiency ;;
    description: "ROI efficiency"
  }

  dimension: attribution_completeness {
    type: string
    sql: ${TABLE}.attribution_completeness ;;
    description: "Attribution completeness"
  }

  dimension: strategic_importance {
    type: string
    sql: ${TABLE}.strategic_importance ;;
    description: "Strategic importance"
  }

  # Data Quality Flags
  dimension: has_known_source {
    type: yesno
    sql: ${TABLE}.has_known_source ;;
    description: "Has known source"
  }

  dimension: has_known_medium {
    type: yesno
    sql: ${TABLE}.has_known_medium ;;
    description: "Has known medium"
  }

  dimension: has_digital_activity {
    type: yesno
    sql: ${TABLE}.has_digital_activity ;;
    description: "Has digital activity"
  }

  dimension: has_commerce_activity {
    type: yesno
    sql: ${TABLE}.has_commerce_activity ;;
    description: "Has commerce activity"
  }

  dimension: has_revenue_attribution {
    type: yesno
    sql: ${TABLE}.has_revenue_attribution ;;
    description: "Has revenue attribution"
  }

  dimension: has_conversion_data {
    type: yesno
    sql: ${TABLE}.has_conversion_data ;;
    description: "Has conversion data"
  }

  # SCD Type 2 Dimensions
  dimension_group: effective_from {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.effective_from ;;
    description: "Effective from timestamp"
  }

  dimension_group: effective_to {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.effective_to ;;
    description: "Effective to timestamp"
  }

  dimension: is_current {
    type: yesno
    sql: ${TABLE}.is_current ;;
    description: "Is current record"
  }

  dimension_group: warehouse_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.warehouse_updated_at ;;
    description: "Warehouse update timestamp"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [channel_key, channel_id, channel_source, channel_medium]
  }

  measure: total_channel_revenue {
    type: sum
    sql: ${total_revenue} ;;
    value_format_name: usd
    description: "Total revenue across channels"
  }

  measure: total_channel_orders {
    type: sum
    sql: ${total_orders} ;;
    description: "Total orders across channels"
  }

  measure: total_channel_users {
    type: sum
    sql: ${unique_users} ;;
    description: "Total users across channels"
  }

  measure: total_sessions {
    type: sum
    sql: ${sessions} ;;
    description: "Total sessions across channels"
  }

  measure: avg_conversion_rate {
    type: average
    sql: ${user_conversion_rate} ;;
    value_format_name: percent_2
    description: "Average user conversion rate"
  }

  measure: paid_channels {
    type: count
    filters: [is_paid_channel: "yes"]
    description: "Number of paid channels"
  }

  measure: organic_channels {
    type: count
    filters: [is_organic_channel: "yes"]
    description: "Number of organic channels"
  }

  measure: current_channels {
    type: count
    filters: [is_current: "yes"]
    description: "Number of current channels"
  }

  measure: channels_with_revenue {
    type: count
    filters: [has_revenue_attribution: "yes"]
    description: "Channels with revenue attribution"
  }
}