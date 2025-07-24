view: fact_order_items {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_order_items` ;;
  
  # Primary Key
  dimension: order_item_key {
    primary_key: yes
    type: string
    sql: ${TABLE}.order_item_key ;;
    description: "Order item surrogate key"
  }

  # Natural Keys
  dimension: order_line_id {
    type: number
    sql: ${TABLE}.order_line_id ;;
    description: "Order line ID"
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    description: "Order ID"
  }

  # Foreign Keys
  dimension: product_key {
    type: number
    sql: ${TABLE}.product_key ;;
    description: "Product surrogate key"
    hidden: yes
  }

  dimension: customer_key {
    type: number
    sql: ${TABLE}.customer_key ;;
    description: "Customer surrogate key"
    hidden: yes
  }

  dimension: channel_key {
    type: number
    sql: ${TABLE}.channel_key ;;
    description: "Channel surrogate key"
    hidden: yes
  }

  dimension: order_date_key {
    type: number
    sql: ${TABLE}.order_date_key ;;
    description: "Order date key"
    hidden: yes
  }

  dimension: processed_date_key {
    type: number
    sql: ${TABLE}.processed_date_key ;;
    description: "Processed date key"
    hidden: yes
  }

  dimension: cancelled_date_key {
    type: number
    sql: ${TABLE}.cancelled_date_key ;;
    description: "Cancelled date key"
    hidden: yes
  }

  # Product Details
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

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
    description: "SKU"
  }

  dimension: product_title {
    type: string
    sql: ${TABLE}.product_title ;;
    description: "Product title"
  }

  dimension: variant_title {
    type: string
    sql: ${TABLE}.variant_title ;;
    description: "Variant title"
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
    description: "Product vendor"
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}.product_type ;;
    description: "Product type"
  }

  # Quantities and Amounts
  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
    description: "Quantity ordered"
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}.unit_price ;;
    value_format_name: usd
    description: "Unit price"
  }

  dimension: line_price {
    type: number
    sql: ${TABLE}.line_price ;;
    value_format_name: usd
    description: "Line price (quantity * unit price)"
  }

  dimension: line_discount {
    type: number
    sql: ${TABLE}.line_discount ;;
    value_format_name: usd
    description: "Line discount amount"
  }

  dimension: line_tax {
    type: number
    sql: ${TABLE}.line_tax ;;
    value_format_name: usd
    description: "Line tax amount"
  }

  dimension: line_total {
    type: number
    sql: ${TABLE}.line_total ;;
    value_format_name: usd
    description: "Line total (price - discount + tax)"
  }

  dimension: line_share_of_order {
    type: number
    sql: ${TABLE}.line_share_of_order ;;
    value_format_name: percent_2
    description: "Line item's share of order subtotal"
  }

  dimension: allocated_shipping {
    type: number
    sql: ${TABLE}.allocated_shipping ;;
    value_format_name: usd
    description: "Allocated shipping cost"
  }

  dimension: allocated_refund {
    type: number
    sql: ${TABLE}.allocated_refund ;;
    value_format_name: usd
    description: "Allocated refund amount"
  }

  # Product Attributes
  dimension: is_gift_card {
    type: yesno
    sql: ${TABLE}.is_gift_card ;;
    description: "Product is a gift card"
  }

  dimension: requires_shipping {
    type: yesno
    sql: ${TABLE}.requires_shipping ;;
    description: "Product requires shipping"
  }

  dimension: is_taxable {
    type: yesno
    sql: ${TABLE}.is_taxable ;;
    description: "Product is taxable"
  }

  # Fulfillment Information
  dimension: fulfillment_status {
    type: string
    sql: ${TABLE}.fulfillment_status ;;
    description: "Line item fulfillment status"
  }

  dimension: fulfillment_service {
    type: string
    sql: ${TABLE}.fulfillment_service ;;
    description: "Fulfillment service"
  }

  # Timestamps
  dimension_group: order_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.order_created_at ;;
    description: "Order creation timestamp"
  }

  dimension_group: order_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.order_updated_at ;;
    description: "Order updated timestamp"
  }

  dimension_group: processed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.processed_at ;;
    description: "Order processed timestamp"
  }

  dimension_group: cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.cancelled_at ;;
    description: "Order cancelled timestamp"
  }

  # Order Information
  dimension: financial_status {
    type: string
    sql: ${TABLE}.financial_status ;;
    description: "Order financial status"
  }

  dimension: order_fulfillment_status {
    type: string
    sql: ${TABLE}.order_fulfillment_status ;;
    description: "Order fulfillment status"
  }

  dimension: currency_code {
    type: string
    sql: ${TABLE}.currency_code ;;
    description: "Currency code"
  }

  dimension: customer_email {
    type: string
    sql: ${TABLE}.customer_email ;;
    description: "Customer email"
  }

  dimension: source_name {
    type: string
    sql: ${TABLE}.source_name ;;
    description: "Order source"
  }

  # Attribution Information
  dimension: referring_site {
    type: string
    sql: ${TABLE}.referring_site ;;
    description: "Referring site"
  }

  dimension: landing_site_base_url {
    type: string
    sql: ${TABLE}.landing_site_base_url ;;
    description: "Landing site base URL"
  }

  dimension: channel_source_medium {
    type: string
    sql: ${TABLE}.channel_source_medium ;;
    description: "Channel source/medium"
  }

  # Order Status Flags
  dimension: is_cancelled {
    type: yesno
    sql: ${TABLE}.is_cancelled ;;
    description: "Order is cancelled"
  }

  dimension: has_refund {
    type: yesno
    sql: ${TABLE}.has_refund ;;
    description: "Order has refund"
  }

  dimension: has_discount {
    type: yesno
    sql: ${TABLE}.has_discount ;;
    description: "Line has discount"
  }

  dimension: discount_rate {
    type: number
    sql: ${TABLE}.discount_rate ;;
    value_format_name: percent_2
    description: "Line discount rate"
  }

  # Metadata
  dimension_group: warehouse_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.warehouse_updated_at ;;
    description: "Warehouse updated timestamp"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [order_item_key, order_id, product_title]
  }

  measure: count_orders {
    type: count_distinct
    sql: ${order_id} ;;
    description: "Number of unique orders"
  }

  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
    description: "Total quantity sold"
  }

  measure: total_revenue {
    type: sum
    sql: ${line_total} ;;
    value_format_name: usd
    description: "Total revenue"
  }

  measure: total_product_revenue {
    type: sum
    sql: ${line_price} ;;
    value_format_name: usd
    description: "Total product revenue (before discounts)"
  }

  measure: total_discount {
    type: sum
    sql: ${line_discount} ;;
    value_format_name: usd
    description: "Total discounts"
  }

  measure: total_tax {
    type: sum
    sql: ${line_tax} ;;
    value_format_name: usd
    description: "Total tax"
  }

  measure: total_shipping {
    type: sum
    sql: ${allocated_shipping} ;;
    value_format_name: usd
    description: "Total allocated shipping"
  }

  measure: total_refunds {
    type: sum
    sql: ${allocated_refund} ;;
    value_format_name: usd
    description: "Total allocated refunds"
  }

  measure: average_unit_price {
    type: average
    sql: ${unit_price} ;;
    value_format_name: usd
    description: "Average unit price"
  }

  measure: average_quantity_per_line {
    type: average
    sql: ${quantity} ;;
    value_format_name: decimal_1
    description: "Average quantity per line"
  }

  measure: average_line_total {
    type: average
    sql: ${line_total} ;;
    value_format_name: usd
    description: "Average line total"
  }

  measure: discount_rate_overall {
    type: number
    sql: ${total_discount} / NULLIF(${total_product_revenue}, 0) ;;
    value_format_name: percent_2
    description: "Overall discount rate"
  }

  measure: items_with_discount {
    type: count
    filters: [has_discount: "yes"]
    description: "Number of items with discounts"
  }

  measure: gift_card_sales {
    type: sum
    sql: ${line_total} ;;
    filters: [is_gift_card: "yes"]
    value_format_name: usd
    description: "Gift card sales"
  }

  measure: cancelled_items {
    type: count
    filters: [is_cancelled: "yes"]
    description: "Number of cancelled items"
  }

  measure: refunded_items {
    type: count
    filters: [has_refund: "yes"]
    description: "Number of refunded items"
  }
}