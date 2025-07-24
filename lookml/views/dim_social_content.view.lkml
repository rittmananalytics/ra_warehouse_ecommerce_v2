view: dim_social_content {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.dim_social_content` ;;
  
  # Primary Key
  dimension: content_key {
    primary_key: yes
    type: string
    sql: ${TABLE}.content_key ;;
    description: "Content surrogate key"
  }

  # Content Identifiers
  dimension: post_id {
    type: number
    sql: ${TABLE}.post_id ;;
    description: "Original post ID"
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
    description: "Social media platform"
  }

  # Content Attributes
  dimension: media_type {
    type: string
    sql: ${TABLE}.media_type ;;
    description: "Type of media (image, video, etc.)"
  }

  dimension: content_category {
    type: string
    sql: ${TABLE}.content_category ;;
    description: "Content category or type"
  }

  dimension: caption_length_category {
    type: string
    sql: ${TABLE}.caption_length_category ;;
    description: "Caption length category (short, medium, long)"
  }

  dimension: hashtag_strategy {
    type: string
    sql: ${TABLE}.hashtag_strategy ;;
    description: "Hashtag usage strategy"
  }

  dimension: mention_strategy {
    type: string
    sql: ${TABLE}.mention_strategy ;;
    description: "Mention usage strategy"
  }

  # Temporal Attributes
  dimension: day_of_week {
    type: number
    sql: ${TABLE}.day_of_week ;;
    description: "Day of week (1-7)"
  }

  dimension: day_type {
    type: string
    sql: ${TABLE}.day_type ;;
    description: "Type of day (weekday, weekend)"
  }

  dimension: time_of_day {
    type: string
    sql: ${TABLE}.time_of_day ;;
    description: "Time of day category"
  }

  dimension: hour_of_day {
    type: number
    sql: ${TABLE}.hour_of_day ;;
    description: "Hour of day (0-23)"
  }

  # Content Flags
  dimension: is_story {
    type: yesno
    sql: ${TABLE}.is_story ;;
    description: "Content is a story"
  }

  dimension: is_comment_enabled {
    type: yesno
    sql: ${TABLE}.is_comment_enabled ;;
    description: "Comments are enabled"
  }

  dimension: has_media {
    type: yesno
    sql: ${TABLE}.has_media ;;
    description: "Content has media attached"
  }

  dimension: has_thumbnail {
    type: yesno
    sql: ${TABLE}.has_thumbnail ;;
    description: "Content has thumbnail"
  }

  # Performance Attributes
  dimension: performance_tier {
    type: string
    sql: ${TABLE}.performance_tier ;;
    description: "Performance tier of content"
  }

  dimension: recency_category {
    type: string
    sql: ${TABLE}.recency_category ;;
    description: "How recent the content is"
  }

  dimension: days_since_posted {
    type: number
    sql: ${TABLE}.days_since_posted ;;
    description: "Days since content was posted"
  }

  # Content Metrics
  dimension: caption_length {
    type: number
    sql: ${TABLE}.caption_length ;;
    description: "Length of caption in characters"
  }

  dimension: hashtag_count {
    type: number
    sql: ${TABLE}.hashtag_count ;;
    description: "Number of hashtags used"
  }

  dimension: mention_count {
    type: number
    sql: ${TABLE}.mention_count ;;
    description: "Number of mentions in content"
  }

  dimension: total_engagement {
    type: number
    sql: ${TABLE}.total_engagement ;;
    description: "Total engagement count"
  }

  dimension: engagement_rate {
    type: number
    sql: ${TABLE}.engagement_rate ;;
    description: "Engagement rate percentage"
    value_format_name: percent_2
  }

  # Date Dimensions
  dimension_group: post {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.post_date ;;
    description: "Date content was posted"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.created_at ;;
    description: "Content creation timestamp"
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.updated_at ;;
    description: "Content update timestamp"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [post_id, platform, media_type, content_category, performance_tier]
  }

  measure: average_engagement_rate {
    type: average
    sql: ${engagement_rate} ;;
    value_format_name: percent_2
    description: "Average engagement rate"
  }

  measure: total_engagements {
    type: sum
    sql: ${total_engagement} ;;
    description: "Total engagements across all content"
  }

  measure: average_caption_length {
    type: average
    sql: ${caption_length} ;;
    value_format_name: decimal_0
    description: "Average caption length"
  }

  measure: average_hashtag_count {
    type: average
    sql: ${hashtag_count} ;;
    value_format_name: decimal_1
    description: "Average hashtags per post"
  }

  measure: average_mention_count {
    type: average
    sql: ${mention_count} ;;
    value_format_name: decimal_1
    description: "Average mentions per post"
  }

  measure: story_percentage {
    type: number
    sql: COUNT(CASE WHEN ${is_story} THEN 1 END) / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
    description: "Percentage of content that are stories"
  }

  measure: comments_enabled_percentage {
    type: number
    sql: COUNT(CASE WHEN ${is_comment_enabled} THEN 1 END) / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
    description: "Percentage of content with comments enabled"
  }
}