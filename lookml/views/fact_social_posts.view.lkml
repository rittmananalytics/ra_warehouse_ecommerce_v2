view: fact_social_posts {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_social_posts` ;;
  
  # Primary Key
  dimension: social_post_key {
    primary_key: yes
    type: string
    sql: ${TABLE}.social_post_key ;;
    description: "Social post surrogate key"
  }

  # Platform and Account Information
  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
    description: "Social media platform"
  }

  dimension: content_type {
    type: string
    sql: ${TABLE}.content_type ;;
    description: "Type of content"
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
    description: "User ID on platform"
  }

  dimension: username {
    type: string
    sql: ${TABLE}.username ;;
    description: "Username on platform"
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.account_name ;;
    description: "Account name"
  }

  # Post Identifiers
  dimension: post_id {
    type: number
    sql: ${TABLE}.post_id ;;
    description: "Original post ID"
  }

  dimension_group: post {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.post_date ;;
    description: "Date of post"
  }

  dimension_group: post_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.post_created_at ;;
    description: "Post creation timestamp"
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
    description: "Content category"
  }

  dimension: is_story {
    type: yesno
    sql: ${TABLE}.is_story ;;
    description: "Post is a story"
  }

  dimension: is_comment_enabled {
    type: yesno
    sql: ${TABLE}.is_comment_enabled ;;
    description: "Comments are enabled"
  }

  dimension: caption_length {
    type: number
    sql: ${TABLE}.caption_length ;;
    description: "Caption length in characters"
  }

  dimension: hashtag_count {
    type: number
    sql: ${TABLE}.hashtag_count ;;
    description: "Number of hashtags"
  }

  dimension: mention_count {
    type: number
    sql: ${TABLE}.mention_count ;;
    description: "Number of mentions"
  }

  dimension: caption_length_category {
    type: string
    sql: ${TABLE}.caption_length_category ;;
    description: "Caption length category"
  }

  # Engagement Metrics
  dimension: total_likes {
    type: number
    sql: ${TABLE}.total_likes ;;
    description: "Total likes"
  }

  dimension: total_comments {
    type: number
    sql: ${TABLE}.total_comments ;;
    description: "Total comments"
  }

  dimension: total_shares {
    type: number
    sql: ${TABLE}.total_shares ;;
    description: "Total shares"
  }

  dimension: total_saves {
    type: number
    sql: ${TABLE}.total_saves ;;
    description: "Total saves"
  }

  dimension: total_reach {
    type: number
    sql: ${TABLE}.total_reach ;;
    description: "Total reach"
  }

  dimension: total_impressions {
    type: number
    sql: ${TABLE}.total_impressions ;;
    description: "Total impressions"
  }

  dimension: total_views {
    type: number
    sql: ${TABLE}.total_views ;;
    description: "Total views"
  }

  dimension: engagement_rate {
    type: number
    sql: ${TABLE}.engagement_rate ;;
    description: "Engagement rate"
    value_format_name: percent_2
  }

  dimension: engagement_rate_impressions {
    type: number
    sql: ${TABLE}.engagement_rate_impressions ;;
    description: "Engagement rate based on impressions"
    value_format_name: percent_2
  }

  dimension: view_rate {
    type: number
    sql: ${TABLE}.view_rate ;;
    description: "View rate"
    value_format_name: percent_2
  }

  dimension: save_rate {
    type: number
    sql: ${TABLE}.save_rate ;;
    description: "Save rate"
    value_format_name: percent_2
  }

  # Story-specific Metrics
  dimension: story_exits {
    type: number
    sql: ${TABLE}.story_exits ;;
    description: "Number of story exits"
  }

  dimension: story_replies {
    type: number
    sql: ${TABLE}.story_replies ;;
    description: "Number of story replies"
  }

  dimension: story_taps_back {
    type: number
    sql: ${TABLE}.story_taps_back ;;
    description: "Number of taps back"
  }

  dimension: story_taps_forward {
    type: number
    sql: ${TABLE}.story_taps_forward ;;
    description: "Number of taps forward"
  }

  dimension: story_exit_rate {
    type: number
    sql: ${TABLE}.story_exit_rate ;;
    description: "Story exit rate"
    value_format_name: percent_2
  }

  # Performance Attributes
  dimension: total_engagement {
    type: number
    sql: ${TABLE}.total_engagement ;;
    description: "Total engagement count"
  }

  dimension: performance_tier {
    type: string
    sql: ${TABLE}.performance_tier ;;
    description: "Performance tier"
  }

  # URLs
  dimension: media_url {
    type: string
    sql: ${TABLE}.media_url ;;
    description: "Media URL"
  }

  dimension: post_url {
    type: string
    sql: ${TABLE}.post_url ;;
    description: "Post URL"
  }

  dimension: shortcode {
    type: string
    sql: ${TABLE}.shortcode ;;
    description: "Post shortcode"
  }

  dimension: thumbnail_url {
    type: string
    sql: ${TABLE}.thumbnail_url ;;
    description: "Thumbnail URL"
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
    drill_fields: [post_id, platform, username, media_type, content_category, performance_tier]
  }

  measure: count_posts {
    type: count_distinct
    sql: ${post_id} ;;
    description: "Count of unique posts"
  }

  measure: count_accounts {
    type: count_distinct
    sql: ${user_id} ;;
    description: "Count of unique accounts"
  }

  measure: sum_likes {
    type: sum
    sql: ${total_likes} ;;
    description: "Total likes across all posts"
  }

  measure: sum_comments {
    type: sum
    sql: ${total_comments} ;;
    description: "Total comments across all posts"
  }

  measure: sum_shares {
    type: sum
    sql: ${total_shares} ;;
    description: "Total shares across all posts"
  }

  measure: sum_saves {
    type: sum
    sql: ${total_saves} ;;
    description: "Total saves across all posts"
  }

  measure: sum_reach {
    type: sum
    sql: ${total_reach} ;;
    description: "Total reach across all posts"
  }

  measure: sum_impressions {
    type: sum
    sql: ${total_impressions} ;;
    description: "Total impressions across all posts"
  }

  measure: sum_engagement {
    type: sum
    sql: ${total_engagement} ;;
    description: "Total engagement across all posts"
  }

  measure: average_engagement_rate {
    type: average
    sql: ${engagement_rate} ;;
    value_format_name: percent_2
    description: "Average engagement rate"
  }

  measure: average_likes_per_post {
    type: average
    sql: ${total_likes} ;;
    value_format_name: decimal_1
    description: "Average likes per post"
  }

  measure: average_comments_per_post {
    type: average
    sql: ${total_comments} ;;
    value_format_name: decimal_1
    description: "Average comments per post"
  }

  measure: average_reach_per_post {
    type: average
    sql: ${total_reach} ;;
    value_format_name: decimal_0
    description: "Average reach per post"
  }

  measure: story_percentage {
    type: number
    sql: COUNT(CASE WHEN ${is_story} THEN 1 END) / NULLIF(${count}, 0) ;;
    value_format_name: percent_1
    description: "Percentage of posts that are stories"
  }

  measure: average_hashtag_count {
    type: average
    sql: ${hashtag_count} ;;
    value_format_name: decimal_1
    description: "Average hashtags per post"
  }
}