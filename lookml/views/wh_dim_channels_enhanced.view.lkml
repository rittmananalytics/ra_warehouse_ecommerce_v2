view: wh_dim_channels_enhanced {
  sql_table_name: `@{PROJECT_ID}.@{ECOMMERCE_DATASET}.wh_dim_channels_enhanced` ;;
  
  # Primary Key
  dimension: channel_sk {
    primary_key: yes
    type: string
    sql: ${TABLE}.channel_sk ;;
    description: "Channel surrogate key"
  }

  # Channel Identification
  dimension: channel_id {
    type: string
    sql: ${TABLE}.channel_id ;;
    description: "Channel business key"
  }

  dimension: channel_name {
    type: string
    sql: ${TABLE}.channel_name ;;
    description: "Channel name"
  }

  dimension: channel_type {
    type: string
    sql: ${TABLE}.channel_type ;;
    description: "Channel type (paid, organic, direct, etc.)"
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
    description: "Platform name (Google, Facebook, Email, etc.)"
  }

  # Channel Classification
  dimension: channel_category {
    type: string
    sql: ${TABLE}.channel_category ;;
    description: "High-level channel category"
  }

  dimension: channel_subcategory {
    type: string
    sql: ${TABLE}.channel_subcategory ;;
    description: "Channel subcategory"
  }

  dimension: is_paid {
    type: yesno
    sql: ${TABLE}.is_paid ;;
    description: "Channel is paid advertising"
  }

  dimension: is_organic {
    type: yesno
    sql: ${TABLE}.is_organic ;;
    description: "Channel is organic/unpaid"
  }

  dimension: is_social {
    type: yesno
    sql: ${TABLE}.is_social ;;
    description: "Channel is social media"
  }

  dimension: is_search {
    type: yesno
    sql: ${TABLE}.is_search ;;
    description: "Channel is search-based"
  }

  dimension: is_display {
    type: yesno
    sql: ${TABLE}.is_display ;;
    description: "Channel is display advertising"
  }

  dimension: is_email {
    type: yesno
    sql: ${TABLE}.is_email ;;
    description: "Channel is email marketing"
  }

  dimension: is_direct {
    type: yesno
    sql: ${TABLE}.is_direct ;;
    description: "Channel is direct traffic"
  }

  # Attribution & Cost Models
  dimension: default_attribution_model {
    type: string
    sql: ${TABLE}.default_attribution_model ;;
    description: "Default attribution model for channel"
  }

  dimension: cost_model {
    type: string
    sql: ${TABLE}.cost_model ;;
    description: "Cost model (CPC, CPM, CPA, flat fee)"
  }

  dimension: typical_cac_range_low {
    type: number
    sql: ${TABLE}.typical_cac_range_low ;;
    description: "Typical customer acquisition cost - low range"
    value_format_name: usd
  }

  dimension: typical_cac_range_high {
    type: number
    sql: ${TABLE}.typical_cac_range_high ;;
    description: "Typical customer acquisition cost - high range"
    value_format_name: usd
  }

  dimension: typical_cac_midpoint {
    type: number
    sql: (${typical_cac_range_low} + ${typical_cac_range_high}) / 2 ;;
    description: "Typical CAC midpoint"
    value_format_name: usd
  }

  # Channel Performance Characteristics
  dimension: avg_conversion_rate {
    type: number
    sql: ${TABLE}.avg_conversion_rate ;;
    description: "Average conversion rate for channel"
    value_format_name: percent_2
  }

  dimension: avg_order_value {
    type: number
    sql: ${TABLE}.avg_order_value ;;
    description: "Average order value from channel"
    value_format_name: usd
  }

  dimension: avg_customer_lifetime_value {
    type: number
    sql: ${TABLE}.avg_customer_lifetime_value ;;
    description: "Average customer lifetime value from channel"
    value_format_name: usd
  }

  dimension: customer_quality_score {
    type: number
    sql: ${TABLE}.customer_quality_score ;;
    description: "Customer quality score (1-10)"
    value_format_name: decimal_1
  }

  # Channel Targeting & Audience
  dimension: primary_audience {
    type: string
    sql: ${TABLE}.primary_audience ;;
    description: "Primary target audience"
  }

  dimension: age_targeting {
    type: string
    sql: ${TABLE}.age_targeting ;;
    description: "Age targeting capabilities"
  }

  dimension: geo_targeting {
    type: string
    sql: ${TABLE}.geo_targeting ;;
    description: "Geographic targeting capabilities"
  }

  dimension: interest_targeting {
    type: string
    sql: ${TABLE}.interest_targeting ;;
    description: "Interest-based targeting capabilities"
  }

  dimension: device_targeting {
    type: string
    sql: ${TABLE}.device_targeting ;;
    description: "Device targeting capabilities"
  }

  # Channel Capabilities
  dimension: supports_remarketing {
    type: yesno
    sql: ${TABLE}.supports_remarketing ;;
    description: "Channel supports remarketing"
  }

  dimension: supports_lookalike {
    type: yesno
    sql: ${TABLE}.supports_lookalike ;;
    description: "Channel supports lookalike audiences"
  }

  dimension: supports_video {
    type: yesno
    sql: ${TABLE}.supports_video ;;
    description: "Channel supports video ads"
  }

  dimension: supports_dynamic_ads {
    type: yesno
    sql: ${TABLE}.supports_dynamic_ads ;;
    description: "Channel supports dynamic product ads"
  }

  dimension: real_time_bidding {
    type: yesno
    sql: ${TABLE}.real_time_bidding ;;
    description: "Channel supports real-time bidding"
  }

  # Channel Metrics & Benchmarks
  dimension: benchmark_ctr {
    type: number
    sql: ${TABLE}.benchmark_ctr ;;
    description: "Industry benchmark CTR"
    value_format_name: percent_2
  }

  dimension: benchmark_cpc {
    type: number
    sql: ${TABLE}.benchmark_cpc ;;
    description: "Industry benchmark CPC"
    value_format_name: usd
  }

  dimension: benchmark_roas {
    type: number
    sql: ${TABLE}.benchmark_roas ;;
    description: "Industry benchmark ROAS"
    value_format_name: decimal_2
  }

  # Channel Status & Operations
  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active ;;
    description: "Channel is currently active"
  }

  dimension: priority_level {
    type: number
    sql: ${TABLE}.priority_level ;;
    description: "Channel priority level (1-5, 1=highest)"
  }

  dimension: budget_allocation_pct {
    type: number
    sql: ${TABLE}.budget_allocation_pct ;;
    description: "Recommended budget allocation percentage"
    value_format_name: percent_1
  }

  # Channel Performance Categories
  dimension: performance_tier {
    type: string
    sql: CASE 
      WHEN ${customer_quality_score} >= 8 THEN 'Premium'
      WHEN ${customer_quality_score} >= 6 THEN 'Good'
      WHEN ${customer_quality_score} >= 4 THEN 'Average'
      ELSE 'Below Average'
    END ;;
    description: "Performance tier based on quality score"
  }

  dimension: cac_efficiency {
    type: string
    sql: CASE 
      WHEN ${typical_cac_midpoint} <= 25 THEN 'Highly Efficient'
      WHEN ${typical_cac_midpoint} <= 50 THEN 'Efficient'
      WHEN ${typical_cac_midpoint} <= 100 THEN 'Moderate'
      ELSE 'Expensive'
    END ;;
    description: "CAC efficiency category"
  }

  dimension: conversion_performance {
    type: string
    sql: CASE 
      WHEN ${avg_conversion_rate} >= 0.05 THEN 'High Converting'
      WHEN ${avg_conversion_rate} >= 0.02 THEN 'Medium Converting'
      ELSE 'Low Converting'
    END ;;
    description: "Conversion performance category"
  }

  # Time Dimensions
  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
    description: "Channel definition creation date"
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.updated_at ;;
    description: "Channel definition last update date"
  }

  dimension_group: last_active {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.last_active_date ;;
    description: "Last active date for channel"
  }

  # Measures
  measure: count {
    type: count
    description: "Number of channels"
    drill_fields: [channel_name, platform, channel_type, is_active]
  }

  measure: count_active {
    type: count
    filters: [is_active: "yes"]
    description: "Number of active channels"
  }

  measure: count_paid {
    type: count
    filters: [is_paid: "yes"]
    description: "Number of paid channels"
  }

  measure: count_organic {
    type: count
    filters: [is_organic: "yes"]
    description: "Number of organic channels"
  }

  measure: average_conversion_rate {
    type: average
    sql: ${avg_conversion_rate} ;;
    description: "Average conversion rate across channels"
    value_format_name: percent_2
  }

  measure: average_order_value_all {
    type: average
    sql: ${avg_order_value} ;;
    description: "Average AOV across channels"
    value_format_name: usd
  }

  measure: average_cac {
    type: average
    sql: ${typical_cac_midpoint} ;;
    description: "Average CAC across channels"
    value_format_name: usd
  }

  measure: average_quality_score {
    type: average
    sql: ${customer_quality_score} ;;
    description: "Average customer quality score"
    value_format_name: decimal_1
  }

  measure: total_budget_allocation {
    type: sum
    sql: ${budget_allocation_pct} ;;
    description: "Total budget allocation percentage"
    value_format_name: percent_1
  }

  measure: count_remarketing_capable {
    type: count
    filters: [supports_remarketing: "yes"]
    description: "Channels supporting remarketing"
  }

  measure: count_video_capable {
    type: count
    filters: [supports_video: "yes"]
    description: "Channels supporting video ads"
  }

  measure: premium_channels {
    type: count
    filters: [performance_tier: "Premium"]
    description: "Number of premium performance channels"
  }

  measure: efficient_channels {
    type: count
    filters: [cac_efficiency: "Highly Efficient,Efficient"]
    description: "Number of CAC-efficient channels"
  }
}