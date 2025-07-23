view: dim_customer_metrics {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.dim_customer_metrics` ;;
  
  # Primary Key
  dimension: customer_metrics_key {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_metrics_key ;;
    description: "Customer metrics surrogate key"
  }

  # Customer Identifiers
  dimension: customer_key {
    type: number
    sql: ${TABLE}.customer_key ;;
    description: "Customer dimension key"
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
    description: "Original customer ID"
  }

  dimension: customer_email {
    type: string
    sql: ${TABLE}.customer_email ;;
    description: "Customer email address"
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
    description: "Customer full name"
  }

  dimension_group: customer_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.customer_created_at ;;
    description: "Customer creation date"
  }

  # Customer Segmentation
  dimension: customer_segment {
    type: string
    sql: ${TABLE}.customer_segment ;;
    description: "Customer segment"
  }

  dimension: customer_lifecycle_stage {
    type: string
    sql: ${TABLE}.customer_lifecycle_stage ;;
    description: "Customer lifecycle stage"
  }

  # Order Metrics
  dimension: total_orders {
    type: number
    sql: ${TABLE}.total_orders ;;
    description: "Total number of orders"
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}.total_revenue ;;
    description: "Total revenue from customer"
    value_format_name: usd
  }

  dimension: avg_order_value {
    type: number
    sql: ${TABLE}.avg_order_value ;;
    description: "Average order value"
    value_format_name: usd
  }

  dimension: min_order_value {
    type: number
    sql: ${TABLE}.min_order_value ;;
    description: "Minimum order value"
    value_format_name: usd
  }

  dimension: max_order_value {
    type: number
    sql: ${TABLE}.max_order_value ;;
    description: "Maximum order value"
    value_format_name: usd
  }

  dimension: order_value_std_dev {
    type: number
    sql: ${TABLE}.order_value_std_dev ;;
    description: "Standard deviation of order values"
  }

  # Order Timing
  dimension_group: first_order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.first_order_date ;;
    description: "Date of first order"
  }

  dimension_group: most_recent_order {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.most_recent_order_date ;;
    description: "Date of most recent order"
  }

  dimension: days_since_first_order {
    type: number
    sql: ${TABLE}.days_since_first_order ;;
    description: "Days since first order"
  }

  dimension: days_since_last_order {
    type: number
    sql: ${TABLE}.days_since_last_order ;;
    description: "Days since last order"
  }

  dimension: customer_lifespan_days {
    type: number
    sql: ${TABLE}.customer_lifespan_days ;;
    description: "Customer lifespan in days"
  }

  dimension: avg_days_between_orders {
    type: number
    sql: ${TABLE}.avg_days_between_orders ;;
    description: "Average days between orders"
    value_format_name: decimal_1
  }

  # Product Metrics
  dimension: unique_products_purchased {
    type: number
    sql: ${TABLE}.unique_products_purchased ;;
    description: "Number of unique products purchased"
  }

  dimension: total_items_purchased {
    type: number
    sql: ${TABLE}.total_items_purchased ;;
    description: "Total items purchased"
  }

  dimension: avg_items_per_order {
    type: number
    sql: ${TABLE}.avg_items_per_order ;;
    description: "Average items per order"
    value_format_name: decimal_1
  }

  # Returns and Discounts
  dimension: orders_with_returns {
    type: number
    sql: ${TABLE}.orders_with_returns ;;
    description: "Number of orders with returns"
  }

  dimension: total_refund_amount {
    type: number
    sql: ${TABLE}.total_refund_amount ;;
    description: "Total refund amount"
    value_format_name: usd
  }

  dimension: orders_with_discounts {
    type: number
    sql: ${TABLE}.orders_with_discounts ;;
    description: "Number of orders with discounts"
  }

  dimension: total_discount_amount {
    type: number
    sql: ${TABLE}.total_discount_amount ;;
    description: "Total discount amount"
    value_format_name: usd
  }

  dimension: avg_discount_rate {
    type: number
    sql: ${TABLE}.avg_discount_rate ;;
    description: "Average discount rate"
    value_format_name: percent_2
  }

  # Digital Engagement
  dimension: total_sessions {
    type: number
    sql: ${TABLE}.total_sessions ;;
    description: "Total website sessions"
  }

  dimension: total_active_days {
    type: number
    sql: ${TABLE}.total_active_days ;;
    description: "Total active days on site"
  }

  dimension: total_page_views {
    type: number
    sql: ${TABLE}.total_page_views ;;
    description: "Total page views"
  }

  dimension: total_items_viewed {
    type: number
    sql: ${TABLE}.total_items_viewed ;;
    description: "Total items viewed"
  }

  dimension: total_add_to_cart_events {
    type: number
    sql: ${TABLE}.total_add_to_cart_events ;;
    description: "Total add to cart events"
  }

  dimension: total_engagement_minutes {
    type: number
    sql: ${TABLE}.total_engagement_minutes ;;
    description: "Total engagement minutes"
    value_format_name: decimal_1
  }

  # Conversion Metrics
  dimension: avg_sessions_to_convert {
    type: number
    sql: ${TABLE}.avg_sessions_to_convert ;;
    description: "Average sessions to conversion"
    value_format_name: decimal_1
  }

  dimension: avg_days_to_convert {
    type: number
    sql: ${TABLE}.avg_days_to_convert ;;
    description: "Average days to conversion"
    value_format_name: decimal_1
  }

  dimension: converting_sessions {
    type: number
    sql: ${TABLE}.converting_sessions ;;
    description: "Number of converting sessions"
  }

  dimension: converted_orders {
    type: number
    sql: ${TABLE}.converted_orders ;;
    description: "Number of converted orders"
  }

  dimension: most_common_journey_type {
    type: number
    sql: ${TABLE}.most_common_journey_type ;;
    description: "Most common journey type"
  }

  dimension: most_common_conversion_timeline {
    type: number
    sql: ${TABLE}.most_common_conversion_timeline ;;
    description: "Most common conversion timeline"
  }

  # RFM Analysis
  dimension: recency {
    type: number
    sql: ${TABLE}.recency ;;
    description: "Recency value"
  }

  dimension: frequency {
    type: number
    sql: ${TABLE}.frequency ;;
    description: "Frequency value"
  }

  dimension: monetary {
    type: number
    sql: ${TABLE}.monetary ;;
    description: "Monetary value"
    value_format_name: usd
  }

  dimension: recency_score {
    type: number
    sql: ${TABLE}.recency_score ;;
    description: "Recency score (1-5)"
  }

  dimension: frequency_score {
    type: number
    sql: ${TABLE}.frequency_score ;;
    description: "Frequency score (1-5)"
  }

  dimension: monetary_score {
    type: number
    sql: ${TABLE}.monetary_score ;;
    description: "Monetary score (1-5)"
  }

  dimension: rfm_segment {
    type: string
    sql: ${TABLE}.rfm_segment ;;
    description: "RFM segment"
  }

  # Predictive Metrics
  dimension: historical_clv {
    type: number
    sql: ${TABLE}.historical_clv ;;
    description: "Historical customer lifetime value"
    value_format_name: usd
  }

  dimension: purchase_rate {
    type: number
    sql: ${TABLE}.purchase_rate ;;
    description: "Purchase rate"
    value_format_name: percent_2
  }

  dimension: predicted_annual_orders {
    type: number
    sql: ${TABLE}.predicted_annual_orders ;;
    description: "Predicted annual orders"
    value_format_name: decimal_1
  }

  dimension: churn_probability {
    type: number
    sql: ${TABLE}.churn_probability ;;
    description: "Churn probability"
    value_format_name: percent_2
  }

  dimension: predicted_clv_2_year {
    type: number
    sql: ${TABLE}.predicted_clv_2_year ;;
    description: "Predicted 2-year CLV"
    value_format_name: usd
  }

  # Customer Attributes
  dimension: customer_value_tier {
    type: string
    sql: ${TABLE}.customer_value_tier ;;
    description: "Customer value tier"
  }

  dimension: digital_engagement_level {
    type: string
    sql: ${TABLE}.digital_engagement_level ;;
    description: "Digital engagement level"
  }

  dimension: at_risk_churn {
    type: yesno
    sql: ${TABLE}.at_risk_churn ;;
    description: "Customer at risk of churning"
  }

  dimension: high_return_rate {
    type: yesno
    sql: ${TABLE}.high_return_rate ;;
    description: "Customer has high return rate"
  }

  dimension: high_churn_risk {
    type: yesno
    sql: ${TABLE}.high_churn_risk ;;
    description: "Customer has high churn risk"
  }

  dimension: one_time_buyer_risk {
    type: yesno
    sql: ${TABLE}.one_time_buyer_risk ;;
    description: "Customer at risk of being one-time buyer"
  }

  dimension: rfm_customer_segment {
    type: string
    sql: ${TABLE}.rfm_customer_segment ;;
    description: "RFM customer segment"
  }

  dimension: clv_tier {
    type: string
    sql: ${TABLE}.clv_tier ;;
    description: "CLV tier"
  }

  dimension: customer_health_score {
    type: number
    sql: ${TABLE}.customer_health_score ;;
    description: "Customer health score"
  }

  dimension: recommended_marketing_action {
    type: string
    sql: ${TABLE}.recommended_marketing_action ;;
    description: "Recommended marketing action"
  }

  dimension: acquisition_efficiency {
    type: string
    sql: ${TABLE}.acquisition_efficiency ;;
    description: "Acquisition efficiency"
  }

  dimension: cross_sell_upsell_potential {
    type: string
    sql: ${TABLE}.cross_sell_upsell_potential ;;
    description: "Cross-sell/upsell potential"
  }

  # SCD Type 2 Fields
  dimension_group: effective_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.effective_from ;;
    description: "Effective from date"
  }

  dimension_group: effective_to {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.effective_to ;;
    description: "Effective to date"
  }

  dimension: is_current {
    type: yesno
    sql: ${TABLE}.is_current ;;
    description: "Current record indicator"
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
  measure: count {
    type: count
    drill_fields: [customer_id, customer_email, full_name, customer_segment, rfm_segment, customer_value_tier]
  }

  measure: count_current {
    type: count
    filters: [is_current: "yes"]
    description: "Count of current records"
  }

  measure: average_clv {
    type: average
    sql: ${historical_clv} ;;
    value_format_name: usd
    description: "Average customer lifetime value"
  }

  measure: total_clv {
    type: sum
    sql: ${historical_clv} ;;
    value_format_name: usd
    description: "Total customer lifetime value"
  }

  measure: average_total_orders {
    type: average
    sql: ${total_orders} ;;
    value_format_name: decimal_1
    description: "Average total orders per customer"
  }

  measure: average_total_revenue {
    type: average
    sql: ${total_revenue} ;;
    value_format_name: usd
    description: "Average total revenue per customer"
  }

  measure: average_churn_probability {
    type: average
    sql: ${churn_probability} ;;
    value_format_name: percent_2
    description: "Average churn probability"
  }

  measure: high_value_customer_count {
    type: count
    filters: [customer_value_tier: "High", is_current: "yes"]
    description: "Count of high value customers"
  }

  measure: at_risk_customer_count {
    type: count
    filters: [at_risk_churn: "yes", is_current: "yes"]
    description: "Count of at-risk customers"
  }

  measure: high_churn_risk_percentage {
    type: number
    sql: COUNT(CASE WHEN ${high_churn_risk} AND ${is_current} THEN 1 END) / NULLIF(${count_current}, 0) ;;
    value_format_name: percent_1
    description: "Percentage of customers with high churn risk"
  }
}