view: fact_inventory {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_inventory` ;;
  
  # Primary Key
  dimension: inventory_key {
    primary_key: yes
    type: number
    sql: ${TABLE}.inventory_key ;;
    description: "Inventory surrogate key"
  }

  # Foreign Keys
  dimension: product_key {
    type: number
    sql: ${TABLE}.product_key ;;
    description: "Product surrogate key"
    hidden: yes
  }

  dimension: snapshot_date_key {
    type: number
    sql: ${TABLE}.snapshot_date_key ;;
    description: "Snapshot date key"
    hidden: yes
  }

  # Product Identifiers
  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
    description: "Product ID"
  }

  dimension: variant_id {
    type: number
    sql: ${TABLE}.variant_id ;;
    description: "Product variant ID"
  }

  # Location Information
  dimension: location_id {
    type: number
    sql: ${TABLE}.location_id ;;
    description: "Location ID"
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}.location_name ;;
    description: "Location name"
  }

  # Inventory Metrics
  dimension: current_stock {
    type: number
    sql: ${TABLE}.current_stock ;;
    description: "Current stock on hand"
  }

  dimension: unit_cost {
    type: number
    sql: ${TABLE}.unit_cost ;;
    value_format_name: usd
    description: "Unit cost"
  }

  dimension: total_inventory_value {
    type: number
    sql: ${TABLE}.total_inventory_value ;;
    value_format_name: usd
    description: "Total value of inventory on hand"
  }

  dimension: selling_price {
    type: number
    sql: ${TABLE}.selling_price ;;
    value_format_name: usd
    description: "Selling price"
  }

  dimension: gross_margin_per_unit {
    type: number
    sql: ${TABLE}.gross_margin_per_unit ;;
    value_format_name: usd
    description: "Gross margin per unit"
  }

  # Product Attributes
  dimension: requires_shipping {
    type: yesno
    sql: ${TABLE}.requires_shipping ;;
    description: "Whether product requires shipping"
  }

  dimension: is_tracked {
    type: yesno
    sql: ${TABLE}.is_tracked ;;
    description: "Whether inventory is tracked"
  }

  # Sales Metrics
  dimension: total_quantity_sold {
    type: number
    sql: ${TABLE}.total_quantity_sold ;;
    description: "Total quantity sold"
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}.total_revenue ;;
    value_format_name: usd
    description: "Total revenue"
  }

  dimension: order_frequency {
    type: number
    sql: ${TABLE}.order_frequency ;;
    description: "Order frequency"
  }

  dimension: avg_quantity_per_order {
    type: number
    sql: ${TABLE}.avg_quantity_per_order ;;
    description: "Average quantity per order"
  }

  dimension_group: last_order {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.last_order_date ;;
    description: "Last order date"
  }

  dimension_group: first_order {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.first_order_date ;;
    description: "First order date"
  }

  dimension: days_with_sales {
    type: number
    sql: ${TABLE}.days_with_sales ;;
    description: "Days with sales"
  }

  # Inventory Performance
  dimension: inventory_turnover_ratio {
    type: number
    sql: ${TABLE}.inventory_turnover_ratio ;;
    value_format_name: decimal_2
    description: "Inventory turnover ratio"
  }

  dimension: days_of_inventory_remaining {
    type: number
    sql: ${TABLE}.days_of_inventory_remaining ;;
    description: "Days of inventory remaining"
  }

  # Status and Classification
  dimension: stock_status {
    type: string
    sql: ${TABLE}.stock_status ;;
    description: "Stock status"
  }

  dimension: inventory_velocity {
    type: string
    sql: ${TABLE}.inventory_velocity ;;
    description: "Inventory velocity classification"
  }

  dimension: inventory_action_needed {
    type: string
    sql: ${TABLE}.inventory_action_needed ;;
    description: "Inventory action needed"
  }

  dimension: inventory_value_tier {
    type: string
    sql: ${TABLE}.inventory_value_tier ;;
    description: "Inventory value tier"
  }

  # Product Details
  dimension: product_title {
    type: string
    sql: ${TABLE}.product_title ;;
    description: "Product title"
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}.product_type ;;
    description: "Product type"
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
    description: "Vendor"
  }

  dimension: product_status {
    type: string
    sql: ${TABLE}.product_status ;;
    description: "Product status"
  }

  dimension: product_performance_category {
    type: string
    sql: ${TABLE}.product_performance_category ;;
    description: "Product performance category"
  }

  # Boolean Flags
  dimension: is_product_active {
    type: yesno
    sql: ${TABLE}.is_product_active ;;
    description: "Whether product is active"
  }

  dimension: is_high_turnover {
    type: yesno
    sql: ${TABLE}.is_high_turnover ;;
    description: "Whether product has high turnover"
  }

  dimension: is_out_of_stock {
    type: yesno
    sql: ${TABLE}.is_out_of_stock ;;
    description: "Whether product is out of stock"
  }

  dimension: is_low_stock {
    type: yesno
    sql: ${TABLE}.is_low_stock ;;
    description: "Whether product has low stock"
  }

  dimension: needs_reorder_soon {
    type: yesno
    sql: ${TABLE}.needs_reorder_soon ;;
    description: "Whether product needs reorder soon"
  }

  dimension: is_profitable {
    type: yesno
    sql: ${TABLE}.is_profitable ;;
    description: "Whether product is profitable"
  }

  # Potential Metrics
  dimension: potential_revenue {
    type: number
    sql: ${TABLE}.potential_revenue ;;
    value_format_name: usd
    description: "Potential revenue"
  }

  dimension: potential_gross_margin {
    type: number
    sql: ${TABLE}.potential_gross_margin ;;
    value_format_name: usd
    description: "Potential gross margin"
  }

  # Risk and Priority
  dimension: inventory_risk_level {
    type: string
    sql: ${TABLE}.inventory_risk_level ;;
    description: "Inventory risk level"
  }

  dimension: inventory_efficiency_score {
    type: number
    sql: ${TABLE}.inventory_efficiency_score ;;
    description: "Inventory efficiency score"
  }

  dimension: financial_impact_tier {
    type: string
    sql: ${TABLE}.financial_impact_tier ;;
    description: "Financial impact tier"
  }

  dimension: reorder_priority {
    type: number
    sql: ${TABLE}.reorder_priority ;;
    description: "Reorder priority"
  }

  # Date Dimensions
  dimension: snapshot_date {
    type: date
    sql: ${TABLE}.snapshot_date ;;
    description: "Inventory snapshot date"
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
    drill_fields: [inventory_key, product_id, product_title, location_name]
  }

  measure: total_stock_on_hand {
    type: sum
    sql: ${current_stock} ;;
    description: "Total units in stock"
  }

  measure: inventory_value {
    type: sum
    sql: ${total_inventory_value} ;;
    value_format_name: usd
    description: "Total inventory value"
  }

  measure: out_of_stock_count {
    type: count
    filters: [is_out_of_stock: "yes"]
    description: "Number of out of stock items"
  }

  measure: low_stock_count {
    type: count
    filters: [is_low_stock: "yes"]
    description: "Number of low stock items"
  }

  measure: needs_reorder_count {
    type: count
    filters: [needs_reorder_soon: "yes"]
    description: "Number of items needing reorder"
  }

  measure: avg_turnover_ratio {
    type: average
    sql: ${inventory_turnover_ratio} ;;
    value_format_name: decimal_2
    description: "Average inventory turnover ratio"
  }

  measure: avg_days_remaining {
    type: average
    sql: ${days_of_inventory_remaining} ;;
    value_format_name: decimal_1
    description: "Average days of inventory remaining"
  }

  measure: total_potential_revenue {
    type: sum
    sql: ${potential_revenue} ;;
    value_format_name: usd
    description: "Total potential revenue"
  }

  measure: total_potential_margin {
    type: sum
    sql: ${potential_gross_margin} ;;
    value_format_name: usd
    description: "Total potential gross margin"
  }

  measure: profitable_products {
    type: count
    filters: [is_profitable: "yes"]
    description: "Number of profitable products"
  }

  measure: high_turnover_products {
    type: count
    filters: [is_high_turnover: "yes"]
    description: "Number of high turnover products"
  }
}