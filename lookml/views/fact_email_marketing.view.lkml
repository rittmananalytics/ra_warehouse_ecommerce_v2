view: fact_email_marketing {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_email_marketing` ;;
  
  # Primary Key
  dimension: email_marketing_key {
    primary_key: yes
    type: string
    sql: ${TABLE}.email_marketing_key ;;
    description: "Email marketing surrogate key"
  }

  # Date Dimensions
  dimension: event_date {
    type: date
    sql: ${TABLE}.event_date ;;
    description: "Date of email event"
  }

  dimension: date_key {
    type: number
    sql: ${TABLE}.date_key ;;
    description: "Date dimension key"
  }

  # Campaign Information
  dimension: campaign_id {
    type: string
    sql: ${TABLE}.campaign_id ;;
    description: "Campaign identifier"
  }

  dimension: flow_id {
    type: string
    sql: ${TABLE}.flow_id ;;
    description: "Flow identifier"
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}.campaign_name ;;
    description: "Campaign name"
  }

  dimension: campaign_subject {
    type: string
    sql: ${TABLE}.campaign_subject ;;
    description: "Email subject line"
  }

  # UTM Parameters
  dimension: utm_source {
    type: string
    sql: ${TABLE}.utm_source ;;
    description: "UTM source"
  }

  dimension: utm_medium {
    type: string
    sql: ${TABLE}.utm_medium ;;
    description: "UTM medium"
  }

  dimension: utm_campaign {
    type: string
    sql: ${TABLE}.utm_campaign ;;
    description: "UTM campaign"
  }

  dimension: marketing_type {
    type: string
    sql: ${TABLE}.marketing_type ;;
    description: "Type of marketing"
  }

  # Email Metrics
  dimension: emails_delivered {
    type: number
    sql: ${TABLE}.emails_delivered ;;
    description: "Number of emails delivered"
  }

  dimension: emails_opened {
    type: number
    sql: ${TABLE}.emails_opened ;;
    description: "Number of emails opened"
  }

  dimension: emails_clicked {
    type: number
    sql: ${TABLE}.emails_clicked ;;
    description: "Number of emails clicked"
  }

  dimension: emails_marked_spam {
    type: number
    sql: ${TABLE}.emails_marked_spam ;;
    description: "Number of emails marked as spam"
  }

  dimension: unsubscribes {
    type: number
    sql: ${TABLE}.unsubscribes ;;
    description: "Number of unsubscribes"
  }

  # Conversion Metrics
  dimension: orders {
    type: number
    sql: ${TABLE}.orders ;;
    description: "Number of orders generated"
  }

  dimension: product_orders {
    type: number
    sql: ${TABLE}.product_orders ;;
    description: "Number of product orders"
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}.revenue ;;
    description: "Revenue generated"
    value_format_name: usd
  }

  # Unique Metrics
  dimension: unique_recipients {
    type: number
    sql: ${TABLE}.unique_recipients ;;
    description: "Number of unique recipients"
  }

  dimension: unique_openers {
    type: number
    sql: ${TABLE}.unique_openers ;;
    description: "Number of unique openers"
  }

  dimension: unique_clickers {
    type: number
    sql: ${TABLE}.unique_clickers ;;
    description: "Number of unique clickers"
  }

  dimension: unique_converters {
    type: number
    sql: ${TABLE}.unique_converters ;;
    description: "Number of unique converters"
  }

  # Rate Metrics
  dimension: open_rate {
    type: number
    sql: ${TABLE}.open_rate ;;
    description: "Email open rate"
    value_format_name: percent_2
  }

  dimension: click_rate {
    type: number
    sql: ${TABLE}.click_rate ;;
    description: "Email click rate"
    value_format_name: percent_2
  }

  dimension: click_to_delivery_rate {
    type: number
    sql: ${TABLE}.click_to_delivery_rate ;;
    description: "Click to delivery rate"
    value_format_name: percent_2
  }

  dimension: conversion_rate {
    type: number
    sql: ${TABLE}.conversion_rate ;;
    description: "Conversion rate"
    value_format_name: percent_2
  }

  dimension: revenue_per_email {
    type: number
    sql: ${TABLE}.revenue_per_email ;;
    description: "Revenue per email"
    value_format_name: usd
  }

  dimension: average_order_value {
    type: number
    sql: ${TABLE}.average_order_value ;;
    description: "Average order value"
    value_format_name: usd
  }

  dimension: unique_open_rate {
    type: number
    sql: ${TABLE}.unique_open_rate ;;
    description: "Unique open rate"
    value_format_name: percent_2
  }

  dimension: unique_click_rate {
    type: number
    sql: ${TABLE}.unique_click_rate ;;
    description: "Unique click rate"
    value_format_name: percent_2
  }

  dimension: unique_conversion_rate {
    type: number
    sql: ${TABLE}.unique_conversion_rate ;;
    description: "Unique conversion rate"
    value_format_name: percent_2
  }

  # Performance Attributes
  dimension: performance_tier {
    type: string
    sql: ${TABLE}.performance_tier ;;
    description: "Performance tier of campaign"
  }

  dimension: email_type {
    type: string
    sql: ${TABLE}.email_type ;;
    description: "Type of email"
  }

  dimension: engagement_score {
    type: number
    sql: ${TABLE}.engagement_score ;;
    description: "Email engagement score"
    value_format_name: decimal_2
  }

  # System Fields
  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.created_at ;;
    description: "Record creation timestamp"
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.updated_at ;;
    description: "Record update timestamp"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [campaign_id, campaign_name, campaign_subject, email_type, performance_tier]
  }

  measure: count_campaigns {
    type: count_distinct
    sql: ${campaign_id} ;;
    description: "Count of unique campaigns"
  }

  measure: total_emails_delivered {
    type: sum
    sql: ${emails_delivered} ;;
    description: "Total emails delivered"
  }

  measure: total_emails_opened {
    type: sum
    sql: ${emails_opened} ;;
    description: "Total emails opened"
  }

  measure: total_emails_clicked {
    type: sum
    sql: ${emails_clicked} ;;
    description: "Total emails clicked"
  }

  measure: total_unsubscribes {
    type: sum
    sql: ${unsubscribes} ;;
    description: "Total unsubscribes"
  }

  measure: total_orders {
    type: sum
    sql: ${orders} ;;
    description: "Total orders generated"
  }

  measure: total_revenue {
    type: sum
    sql: ${revenue} ;;
    value_format_name: usd
    description: "Total revenue generated"
  }

  measure: average_open_rate {
    type: average
    sql: ${open_rate} ;;
    value_format_name: percent_2
    description: "Average open rate"
  }

  measure: average_click_rate {
    type: average
    sql: ${click_rate} ;;
    value_format_name: percent_2
    description: "Average click rate"
  }

  measure: average_conversion_rate {
    type: average
    sql: ${conversion_rate} ;;
    value_format_name: percent_2
    description: "Average conversion rate"
  }

  measure: average_revenue_per_email {
    type: average
    sql: ${revenue_per_email} ;;
    value_format_name: usd
    description: "Average revenue per email"
  }

  measure: average_engagement_score {
    type: average
    sql: ${engagement_score} ;;
    value_format_name: decimal_2
    description: "Average engagement score"
  }

  measure: overall_open_rate {
    type: number
    sql: ${total_emails_opened} / NULLIF(${total_emails_delivered}, 0) ;;
    value_format_name: percent_2
    description: "Overall open rate"
  }

  measure: overall_click_rate {
    type: number
    sql: ${total_emails_clicked} / NULLIF(${total_emails_delivered}, 0) ;;
    value_format_name: percent_2
    description: "Overall click rate"
  }

  measure: overall_conversion_rate {
    type: number
    sql: ${total_orders} / NULLIF(${total_emails_delivered}, 0) ;;
    value_format_name: percent_2
    description: "Overall conversion rate"
  }

  measure: overall_revenue_per_email {
    type: number
    sql: ${total_revenue} / NULLIF(${total_emails_delivered}, 0) ;;
    value_format_name: usd
    description: "Overall revenue per email"
  }
}