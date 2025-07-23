view: dim_products {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.dim_products` ;;
  
  # Primary Key
  dimension: product_key {
    primary_key: yes
    type: number
    sql: ${TABLE}.product_key ;;
    description: "Product surrogate key"
  }

  # Business Key
  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
    description: "Original product business key"
  }

  # Product Identification
  dimension: product_title {
    type: string
    sql: ${TABLE}.product_title ;;
    description: "Product title"
  }

  dimension: product_handle {
    type: string
    sql: ${TABLE}.product_handle ;;
    description: "Product URL handle"
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}.product_type ;;
    description: "Product type/category"
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
    description: "Product vendor/brand"
  }

  # Product Timestamps
  dimension_group: product_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.product_created_at ;;
    description: "Product creation date"
  }

  dimension_group: product_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.product_updated_at ;;
    description: "Product last update date"
  }

  dimension_group: product_published {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.product_published_at ;;
    description: "Product publish date"
  }

  # Product Status
  dimension: product_status {
    type: string
    sql: ${TABLE}.product_status ;;
    description: "Product status (active, draft, archived)"
  }

  dimension: product_tags {
    type: string
    sql: ${TABLE}.product_tags ;;
    description: "Product tags (comma-separated)"
  }

  # Product Options - Note: These are INTEGER in BigQuery
  dimension: option_1_name {
    type: number
    sql: ${TABLE}.option_1_name ;;
    description: "Option 1 name"
  }

  dimension: option_1_value {
    type: number
    sql: ${TABLE}.option_1_value ;;
    description: "Option 1 value"
  }

  dimension: option_2_name {
    type: number
    sql: ${TABLE}.option_2_name ;;
    description: "Option 2 name"
  }

  dimension: option_2_value {
    type: number
    sql: ${TABLE}.option_2_value ;;
    description: "Option 2 value"
  }

  dimension: option_3_name {
    type: number
    sql: ${TABLE}.option_3_name ;;
    description: "Option 3 name"
  }

  dimension: option_3_value {
    type: number
    sql: ${TABLE}.option_3_value ;;
    description: "Option 3 value"
  }

  # Sales Metrics
  dimension: total_orders {
    type: number
    sql: ${TABLE}.total_orders ;;
    description: "Total orders containing this product"
  }

  dimension: total_line_items {
    type: number
    sql: ${TABLE}.total_line_items ;;
    description: "Total line items for this product"
  }

  dimension: total_quantity_sold {
    type: number
    sql: ${TABLE}.total_quantity_sold ;;
    description: "Total quantity sold"
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}.total_revenue ;;
    description: "Total revenue generated"
    value_format_name: usd
  }

  dimension: avg_selling_price {
    type: number
    sql: ${TABLE}.avg_selling_price ;;
    description: "Average selling price"
    value_format_name: usd
  }

  dimension: max_selling_price {
    type: number
    sql: ${TABLE}.max_selling_price ;;
    description: "Maximum selling price"
    value_format_name: usd
  }

  dimension: min_selling_price {
    type: number
    sql: ${TABLE}.min_selling_price ;;
    description: "Minimum selling price"
    value_format_name: usd
  }

  dimension: total_discounts_given {
    type: number
    sql: ${TABLE}.total_discounts_given ;;
    description: "Total discounts given"
    value_format_name: usd
  }

  dimension: avg_discount_percent {
    type: number
    sql: ${TABLE}.avg_discount_percent ;;
    description: "Average discount percentage"
    value_format_name: percent_2
  }

  # Inventory Metrics
  dimension: total_inventory {
    type: number
    sql: ${TABLE}.total_inventory ;;
    description: "Total inventory across all locations"
  }

  dimension: avg_variant_inventory {
    type: number
    sql: ${TABLE}.avg_variant_inventory ;;
    description: "Average inventory per variant"
    value_format_name: decimal_1
  }

  dimension: variant_count {
    type: number
    sql: ${TABLE}.variant_count ;;
    description: "Number of variants"
  }

  # Performance Categories
  dimension: product_performance_category {
    type: string
    sql: ${TABLE}.product_performance_category ;;
    description: "Product performance category"
  }

  dimension: inventory_status_category {
    type: string
    sql: ${TABLE}.inventory_status_category ;;
    description: "Inventory status category"
  }

  # Product Flags
  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active ;;
    description: "Product is active"
  }

  dimension: is_published {
    type: yesno
    sql: ${TABLE}.is_published ;;
    description: "Product is published"
  }

  dimension: has_inventory {
    type: yesno
    sql: ${TABLE}.has_inventory ;;
    description: "Product has inventory"
  }

  dimension: has_sales {
    type: yesno
    sql: ${TABLE}.has_sales ;;
    description: "Product has sales"
  }

  # Product Tiers
  dimension: revenue_tier {
    type: string
    sql: ${TABLE}.revenue_tier ;;
    description: "Revenue tier"
  }

  dimension: price_tier {
    type: string
    sql: ${TABLE}.price_tier ;;
    description: "Price tier"
  }

  dimension: sales_volume_tier {
    type: string
    sql: ${TABLE}.sales_volume_tier ;;
    description: "Sales volume tier"
  }

  dimension: discount_tier {
    type: string
    sql: ${TABLE}.discount_tier ;;
    description: "Discount tier"
  }

  dimension: product_lifecycle_stage {
    type: string
    sql: ${TABLE}.product_lifecycle_stage ;;
    description: "Product lifecycle stage"
  }

  # Product Attributes
  dimension: has_variants {
    type: yesno
    sql: ${TABLE}.has_variants ;;
    description: "Product has variants"
  }

  dimension: has_tags {
    type: yesno
    sql: ${TABLE}.has_tags ;;
    description: "Product has tags"
  }

  dimension: has_options {
    type: yesno
    sql: ${TABLE}.has_options ;;
    description: "Product has options"
  }

  dimension: has_vendor {
    type: yesno
    sql: ${TABLE}.has_vendor ;;
    description: "Product has vendor"
  }

  # SCD Type 2 Fields
  dimension_group: effective_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.effective_from ;;
    description: "Effective from date for SCD Type 2"
  }

  dimension_group: effective_to {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.effective_to ;;
    description: "Effective to date for SCD Type 2"
  }

  dimension: is_current {
    type: yesno
    sql: ${TABLE}.is_current ;;
    description: "Current version indicator"
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
    drill_fields: [product_id, product_title, vendor, product_type, revenue_tier]
  }

  measure: count_current {
    type: count
    filters: [is_current: "yes"]
    description: "Count of current product records"
  }

  measure: count_active {
    type: count
    filters: [is_active: "yes", is_current: "yes"]
    description: "Count of active products"
  }

  measure: count_published {
    type: count
    filters: [is_published: "yes", is_current: "yes"]
    description: "Count of published products"
  }

  measure: count_with_inventory {
    type: count
    filters: [has_inventory: "yes", is_current: "yes"]
    description: "Count of products with inventory"
  }

  measure: count_with_sales {
    type: count
    filters: [has_sales: "yes", is_current: "yes"]
    description: "Count of products with sales"
  }

  measure: sum_total_revenue {
    type: sum
    sql: ${total_revenue} ;;
    value_format_name: usd
    description: "Total revenue across all products"
  }

  measure: average_revenue_per_product {
    type: average
    sql: ${total_revenue} ;;
    value_format_name: usd
    description: "Average revenue per product"
  }

  measure: sum_total_quantity_sold {
    type: sum
    sql: ${total_quantity_sold} ;;
    description: "Total quantity sold across all products"
  }

  measure: average_selling_price_overall {
    type: average
    sql: ${avg_selling_price} ;;
    value_format_name: usd
    description: "Average selling price across all products"
  }

  measure: sum_total_inventory {
    type: sum
    sql: ${total_inventory} ;;
    description: "Total inventory across all products"
  }

  measure: average_discount_percentage {
    type: average
    sql: ${avg_discount_percent} ;;
    value_format_name: percent_2
    description: "Average discount percentage"
  }

  measure: average_variant_count {
    type: average
    sql: ${variant_count} ;;
    value_format_name: decimal_1
    description: "Average number of variants per product"
  }
}