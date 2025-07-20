view: wh_fact_orders {
  sql_table_name: `@{PROJECT_ID}.@{ECOMMERCE_DATASET}.wh_fact_orders` ;;
  
  # Primary Key
  dimension: order_line_sk {
    primary_key: yes
    type: string
    sql: ${TABLE}.order_line_sk ;;
    description: "Order line surrogate key"
  }

  # Foreign Keys
  dimension: order_id {
    type: string
    sql: ${TABLE}.order_id ;;
    description: "Order business key"
  }

  dimension: customer_sk {
    type: string
    sql: ${TABLE}.customer_sk ;;
    description: "Customer surrogate key"
    hidden: yes
  }

  dimension: product_sk {
    type: string
    sql: ${TABLE}.product_sk ;;
    description: "Product surrogate key"
    hidden: yes
  }

  dimension: order_date_key {
    type: string
    sql: ${TABLE}.order_date_key ;;
    description: "Order date key (YYYYMMDD)"
    hidden: yes
  }

  # Order Details
  dimension: order_number {
    type: number
    sql: ${TABLE}.order_number ;;
    description: "Order number"
  }

  dimension: line_item_id {
    type: string
    sql: ${TABLE}.line_item_id ;;
    description: "Line item ID"
  }

  dimension: variant_id {
    type: string
    sql: ${TABLE}.variant_id ;;
    description: "Product variant ID"
  }

  dimension: variant_title {
    type: string
    sql: ${TABLE}.variant_title ;;
    description: "Product variant title"
  }

  # Financial Metrics
  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
    description: "Quantity ordered"
  }

  dimension: price {
    type: number
    sql: ${TABLE}.price ;;
    description: "Unit price"
    value_format_name: usd
  }

  dimension: total_discount {
    type: number
    sql: ${TABLE}.total_discount ;;
    description: "Total discount amount"
    value_format_name: usd
  }

  dimension: line_item_total {
    type: number
    sql: ${TABLE}.line_item_total ;;
    description: "Line item total (price * quantity - discount)"
    value_format_name: usd
  }

  dimension: product_cost {
    type: number
    sql: ${TABLE}.product_cost ;;
    description: "Product cost per unit"
    value_format_name: usd
  }

  dimension: gross_margin {
    type: number
    sql: ${TABLE}.gross_margin ;;
    description: "Gross margin (revenue - cost)"
    value_format_name: usd
  }

  dimension: gross_margin_pct {
    type: number
    sql: ${TABLE}.gross_margin_pct ;;
    description: "Gross margin percentage"
    value_format_name: percent_1
  }

  # Order-level Financial Data
  dimension: order_subtotal {
    type: number
    sql: ${TABLE}.order_subtotal ;;
    description: "Order subtotal"
    value_format_name: usd
  }

  dimension: order_total_tax {
    type: number
    sql: ${TABLE}.order_total_tax ;;
    description: "Order total tax"
    value_format_name: usd
  }

  dimension: order_total_shipping {
    type: number
    sql: ${TABLE}.order_total_shipping ;;
    description: "Order total shipping"
    value_format_name: usd
  }

  dimension: order_total_discounts {
    type: number
    sql: ${TABLE}.order_total_discounts ;;
    description: "Order total discounts"
    value_format_name: usd
  }

  dimension: order_total_price {
    type: number
    sql: ${TABLE}.order_total_price ;;
    description: "Order total price"
    value_format_name: usd
  }

  # Order Status and Fulfillment
  dimension: financial_status {
    type: string
    sql: ${TABLE}.financial_status ;;
    description: "Financial status (paid, pending, refunded, etc.)"
  }

  dimension: fulfillment_status {
    type: string
    sql: ${TABLE}.fulfillment_status ;;
    description: "Fulfillment status (fulfilled, partial, unfulfilled)"
  }

  dimension: cancelled_at {
    type: date_time
    sql: ${TABLE}.cancelled_at ;;
    description: "Order cancellation timestamp"
  }

  dimension: is_cancelled {
    type: yesno
    sql: ${cancelled_at} IS NOT NULL ;;
    description: "Order is cancelled"
  }

  # Product Information
  dimension: product_title {
    type: string
    sql: ${TABLE}.product_title ;;
    description: "Product title"
  }

  dimension: product_vendor {
    type: string
    sql: ${TABLE}.product_vendor ;;
    description: "Product vendor"
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}.product_type ;;
    description: "Product type"
  }

  # Customer Information
  dimension: customer_email {
    type: string
    sql: ${TABLE}.customer_email ;;
    description: "Customer email"
  }

  # Geographic Information
  dimension: shipping_country {
    type: string
    sql: ${TABLE}.shipping_country ;;
    description: "Shipping country"
    map_layer_name: countries
  }

  dimension: shipping_province {
    type: string
    sql: ${TABLE}.shipping_province ;;
    description: "Shipping province/state"
  }

  dimension: shipping_city {
    type: string
    sql: ${TABLE}.shipping_city ;;
    description: "Shipping city"
  }

  dimension: billing_country {
    type: string
    sql: ${TABLE}.billing_country ;;
    description: "Billing country"
    map_layer_name: countries
  }

  dimension: billing_province {
    type: string
    sql: ${TABLE}.billing_province ;;
    description: "Billing province/state"
  }

  # Time Dimensions
  dimension_group: order {
    type: time
    timeframes: [raw, date, week, month, quarter, year, day_of_week, hour_of_day]
    sql: ${TABLE}.order_created_at ;;
    description: "Order creation time"
  }

  dimension_group: processed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.processed_at ;;
    description: "Order processed time"
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.updated_at ;;
    description: "Order last update time"
  }

  # Calculated Dimensions
  dimension: days_to_fulfill {
    type: number
    sql: DATE_DIFF(${processed_date}, ${order_date}, DAY) ;;
    description: "Days from order to fulfillment"
  }

  dimension: is_high_value_order {
    type: yesno
    sql: ${order_total_price} >= 200 ;;
    description: "High value order (>= $200)"
  }

  dimension: order_size_category {
    type: string
    sql: CASE 
      WHEN ${order_total_price} < 50 THEN 'Small'
      WHEN ${order_total_price} < 150 THEN 'Medium'
      WHEN ${order_total_price} < 300 THEN 'Large'
      ELSE 'Enterprise'
    END ;;
    description: "Order size category"
  }

  dimension: margin_category {
    type: string
    sql: CASE 
      WHEN ${gross_margin_pct} < 20 THEN 'Low Margin'
      WHEN ${gross_margin_pct} < 40 THEN 'Medium Margin'
      ELSE 'High Margin'
    END ;;
    description: "Margin category"
  }

  # Measures
  measure: count {
    type: count
    description: "Number of order line items"
    drill_fields: [order_id, product_title, quantity, line_item_total]
  }

  measure: count_orders {
    type: count_distinct
    sql: ${order_id} ;;
    description: "Number of unique orders"
    drill_fields: [order_id, order_date, customer_email, order_total_price]
  }

  measure: total_revenue {
    type: sum
    sql: ${line_item_total} ;;
    description: "Total revenue"
    value_format_name: usd
    drill_fields: [order_date, product_title, line_item_total]
  }

  measure: total_quantity_sold {
    type: sum
    sql: ${quantity} ;;
    description: "Total quantity sold"
  }

  measure: total_gross_margin {
    type: sum
    sql: ${gross_margin} ;;
    description: "Total gross margin"
    value_format_name: usd
  }

  measure: average_order_value {
    type: number
    sql: ${total_revenue} / NULLIF(${count_orders}, 0) ;;
    description: "Average order value"
    value_format_name: usd
  }

  measure: average_gross_margin_pct {
    type: average
    sql: ${gross_margin_pct} ;;
    description: "Average gross margin percentage"
    value_format_name: percent_1
  }

  measure: total_discounts {
    type: sum
    sql: ${total_discount} ;;
    description: "Total discounts given"
    value_format_name: usd
  }

  measure: discount_rate {
    type: number
    sql: ${total_discounts} / (${total_revenue} + ${total_discounts}) ;;
    description: "Discount rate (discounts / gross revenue)"
    value_format_name: percent_1
  }

  measure: units_per_order {
    type: number
    sql: ${total_quantity_sold} / NULLIF(${count_orders}, 0) ;;
    description: "Average units per order"
    value_format_name: decimal_1
  }

  measure: return_rate {
    type: number
    sql: COUNT(CASE WHEN ${financial_status} = 'refunded' THEN 1 END) / NULLIF(${count}, 0) ;;
    description: "Return/refund rate"
    value_format_name: percent_1
  }

  measure: total_tax {
    type: sum
    sql: ${order_total_tax} / ${quantity} ;;
    description: "Total tax collected (prorated by line item)"
    value_format_name: usd
  }

  measure: total_shipping {
    type: sum
    sql: ${order_total_shipping} / ${quantity} ;;
    description: "Total shipping charges (prorated by line item)"
    value_format_name: usd
  }
}