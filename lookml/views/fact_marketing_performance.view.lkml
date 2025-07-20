view: fact_marketing_performance {
  sql_table_name: `@{PROJECT_ID}.@{ECOMMERCE_DATASET}.fact_marketing_performance` ;;
  
  # Primary Key
  dimension: marketing_performance_sk {
    primary_key: yes
    type: string
    sql: ${TABLE}.marketing_performance_sk ;;
    description: "Marketing performance surrogate key"
  }

  # Foreign Keys
  dimension: performance_date_key {
    type: string
    sql: ${TABLE}.performance_date_key ;;
    description: "Performance date key (YYYYMMDD)"
    hidden: yes
  }

  dimension: channel_sk {
    type: string
    sql: ${TABLE}.channel_sk ;;
    description: "Channel surrogate key"
    hidden: yes
  }

  # Campaign Identification
  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source ;;
    description: "Marketing data source (google_ads, facebook_ads, etc.)"
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
    description: "Advertising platform"
  }

  dimension: campaign_id {
    type: string
    sql: ${TABLE}.campaign_id ;;
    description: "Campaign ID"
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}.campaign_name ;;
    description: "Campaign name"
  }

  dimension: ad_group_id {
    type: string
    sql: ${TABLE}.ad_group_id ;;
    description: "Ad group ID"
  }

  dimension: ad_group_name {
    type: string
    sql: ${TABLE}.ad_group_name ;;
    description: "Ad group name"
  }

  dimension: ad_id {
    type: string
    sql: ${TABLE}.ad_id ;;
    description: "Ad ID"
  }

  dimension: ad_name {
    type: string
    sql: ${TABLE}.ad_name ;;
    description: "Ad name"
  }

  # Campaign Attributes
  dimension: campaign_type {
    type: string
    sql: ${TABLE}.campaign_type ;;
    description: "Campaign type"
  }

  dimension: campaign_status {
    type: string
    sql: ${TABLE}.campaign_status ;;
    description: "Campaign status (active, paused, etc.)"
  }

  dimension: ad_status {
    type: string
    sql: ${TABLE}.ad_status ;;
    description: "Ad status"
  }

  dimension: objective {
    type: string
    sql: ${TABLE}.objective ;;
    description: "Campaign objective"
  }

  dimension: bid_strategy {
    type: string
    sql: ${TABLE}.bid_strategy ;;
    description: "Bidding strategy"
  }

  # Performance Metrics - Impressions & Reach
  dimension: impressions {
    type: number
    sql: ${TABLE}.impressions ;;
    description: "Number of impressions"
  }

  dimension: reach {
    type: number
    sql: ${TABLE}.reach ;;
    description: "Number of unique users reached"
  }

  dimension: frequency {
    type: number
    sql: ${TABLE}.frequency ;;
    description: "Average frequency per user"
    value_format_name: decimal_2
  }

  # Performance Metrics - Engagement
  dimension: clicks {
    type: number
    sql: ${TABLE}.clicks ;;
    description: "Number of clicks"
  }

  dimension: link_clicks {
    type: number
    sql: ${TABLE}.link_clicks ;;
    description: "Number of link clicks"
  }

  dimension: likes {
    type: number
    sql: ${TABLE}.likes ;;
    description: "Number of likes"
  }

  dimension: shares {
    type: number
    sql: ${TABLE}.shares ;;
    description: "Number of shares"
  }

  dimension: comments {
    type: number
    sql: ${TABLE}.comments ;;
    description: "Number of comments"
  }

  dimension: video_views {
    type: number
    sql: ${TABLE}.video_views ;;
    description: "Number of video views"
  }

  # Performance Metrics - Costs
  dimension: spend {
    type: number
    sql: ${TABLE}.spend ;;
    description: "Total spend/cost"
    value_format_name: usd
  }

  dimension: cost_per_click {
    type: number
    sql: ${TABLE}.cost_per_click ;;
    description: "Cost per click (CPC)"
    value_format_name: usd
  }

  dimension: cost_per_mille {
    type: number
    sql: ${TABLE}.cost_per_mille ;;
    description: "Cost per thousand impressions (CPM)"
    value_format_name: usd
  }

  # Performance Metrics - Conversions
  dimension: conversions {
    type: number
    sql: ${TABLE}.conversions ;;
    description: "Number of conversions"
  }

  dimension: conversion_value {
    type: number
    sql: ${TABLE}.conversion_value ;;
    description: "Total conversion value"
    value_format_name: usd
  }

  dimension: cost_per_conversion {
    type: number
    sql: ${TABLE}.cost_per_conversion ;;
    description: "Cost per conversion"
    value_format_name: usd
  }

  # Calculated Performance Metrics
  dimension: click_through_rate {
    type: number
    sql: CASE WHEN ${impressions} > 0 THEN ${clicks} / ${impressions} ELSE 0 END ;;
    description: "Click-through rate (CTR)"
    value_format_name: percent_2
  }

  dimension: conversion_rate {
    type: number
    sql: CASE WHEN ${clicks} > 0 THEN ${conversions} / ${clicks} ELSE 0 END ;;
    description: "Conversion rate"
    value_format_name: percent_2
  }

  dimension: return_on_ad_spend {
    type: number
    sql: CASE WHEN ${spend} > 0 THEN ${conversion_value} / ${spend} ELSE 0 END ;;
    description: "Return on ad spend (ROAS)"
    value_format_name: decimal_2
  }

  dimension: cost_per_acquisition {
    type: number
    sql: CASE WHEN ${conversions} > 0 THEN ${spend} / ${conversions} ELSE 0 END ;;
    description: "Cost per acquisition (CPA)"
    value_format_name: usd
  }

  # Performance Tiers
  dimension: spend_tier {
    type: tier
    tiers: [0, 10, 50, 100, 500, 1000, 5000]
    style: relational
    sql: ${spend} ;;
    description: "Spend tier categorization"
  }

  dimension: roas_tier {
    type: tier
    tiers: [0, 1, 2, 3, 4, 5, 10]
    style: relational
    sql: ${return_on_ad_spend} ;;
    description: "ROAS tier categorization"
  }

  dimension: performance_category {
    type: string
    sql: CASE 
      WHEN ${return_on_ad_spend} >= 4 THEN 'High Performer'
      WHEN ${return_on_ad_spend} >= 2 THEN 'Good Performer'
      WHEN ${return_on_ad_spend} >= 1 THEN 'Break Even'
      ELSE 'Underperformer'
    END ;;
    description: "Performance category based on ROAS"
  }

  dimension: ctr_category {
    type: string
    sql: CASE 
      WHEN ${click_through_rate} >= 0.02 THEN 'High CTR'
      WHEN ${click_through_rate} >= 0.01 THEN 'Medium CTR'
      ELSE 'Low CTR'
    END ;;
    description: "CTR category"
  }

  # Time Dimensions
  dimension_group: performance {
    type: time
    timeframes: [raw, date, week, month, quarter, year, day_of_week]
    sql: ${TABLE}.performance_date ;;
    description: "Performance date"
  }

  dimension_group: campaign_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.campaign_start_date ;;
    description: "Campaign start date"
  }

  dimension_group: campaign_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.campaign_end_date ;;
    description: "Campaign end date"
  }

  dimension: campaign_duration_days {
    type: number
    sql: DATE_DIFF(${campaign_end_date}, ${campaign_start_date}, DAY) ;;
    description: "Campaign duration in days"
  }

  # Measures
  measure: count {
    type: count
    description: "Number of performance records"
    drill_fields: [performance_date, platform, campaign_name, spend, conversions, return_on_ad_spend]
  }

  measure: total_impressions {
    type: sum
    sql: ${impressions} ;;
    description: "Total impressions"
    drill_fields: [platform, campaign_name, total_impressions]
  }

  measure: total_clicks {
    type: sum
    sql: ${clicks} ;;
    description: "Total clicks"
    drill_fields: [platform, campaign_name, total_clicks]
  }

  measure: total_spend {
    type: sum
    sql: ${spend} ;;
    description: "Total spend"
    value_format_name: usd
    drill_fields: [platform, campaign_name, total_spend]
  }

  measure: total_conversions {
    type: sum
    sql: ${conversions} ;;
    description: "Total conversions"
    drill_fields: [platform, campaign_name, total_conversions]
  }

  measure: total_conversion_value {
    type: sum
    sql: ${conversion_value} ;;
    description: "Total conversion value"
    value_format_name: usd
    drill_fields: [platform, campaign_name, total_conversion_value]
  }

  measure: overall_ctr {
    type: number
    sql: ${total_clicks} / NULLIF(${total_impressions}, 0) ;;
    description: "Overall click-through rate"
    value_format_name: percent_2
  }

  measure: overall_conversion_rate {
    type: number
    sql: ${total_conversions} / NULLIF(${total_clicks}, 0) ;;
    description: "Overall conversion rate"
    value_format_name: percent_2
  }

  measure: overall_roas {
    type: number
    sql: ${total_conversion_value} / NULLIF(${total_spend}, 0) ;;
    description: "Overall return on ad spend"
    value_format_name: decimal_2
  }

  measure: overall_cpa {
    type: number
    sql: ${total_spend} / NULLIF(${total_conversions}, 0) ;;
    description: "Overall cost per acquisition"
    value_format_name: usd
  }

  measure: average_cpc {
    type: average
    sql: ${cost_per_click} ;;
    description: "Average cost per click"
    value_format_name: usd
  }

  measure: average_cpm {
    type: average
    sql: ${cost_per_mille} ;;
    description: "Average cost per thousand impressions"
    value_format_name: usd
  }

  measure: count_campaigns {
    type: count_distinct
    sql: ${campaign_id} ;;
    description: "Number of unique campaigns"
  }

  measure: count_ad_groups {
    type: count_distinct
    sql: ${ad_group_id} ;;
    description: "Number of unique ad groups"
  }

  measure: count_ads {
    type: count_distinct
    sql: ${ad_id} ;;
    description: "Number of unique ads"
  }

  measure: total_reach {
    type: sum
    sql: ${reach} ;;
    description: "Total reach"
  }

  measure: average_frequency {
    type: average
    sql: ${frequency} ;;
    description: "Average frequency"
    value_format_name: decimal_2
  }

  measure: total_video_views {
    type: sum
    sql: ${video_views} ;;
    description: "Total video views"
  }

  measure: total_engagement {
    type: sum
    sql: ${likes} + ${shares} + ${comments} ;;
    description: "Total engagement (likes + shares + comments)"
  }
}