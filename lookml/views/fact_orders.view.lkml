view: fact_orders {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_orders` ;;
  
  # Primary Key
  dimension: order_key {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_key ;;
    description: "Order surrogate key"
  }

  # Foreign Keys
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

  # Natural Key
  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    description: "Order business key"
  }

  # Order Identifiers
  dimension: order_name {
    type: string
    sql: ${TABLE}.order_name ;;
    description: "Order name/number"
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
    description: "Customer ID"
  }

  dimension: customer_email {
    type: string
    sql: ${TABLE}.customer_email ;;
    description: "Customer email"
  }

  # Dates and Timestamps
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
    description: "Order update timestamp"
  }

  dimension_group: order_processed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.order_processed_at ;;
    description: "Order processed timestamp"
  }

  dimension_group: order_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.order_cancelled_at ;;
    description: "Order cancelled timestamp"
  }

  dimension_group: warehouse_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.warehouse_updated_at ;;
    description: "Warehouse update timestamp"
  }

  # Status Fields
  dimension: financial_status {
    type: string
    sql: ${TABLE}.financial_status ;;
    description: "Financial status (paid, pending, refunded, etc.)"
  }

  dimension: fulfillment_status {
    type: string
    sql: ${TABLE}.fulfillment_status ;;
    description: "Fulfillment status"
  }

  # Financial Metrics
  dimension: order_total_price {
    type: number
    sql: ${TABLE}.order_total_price ;;
    description: "Total order price"
    value_format_name: usd
  }

  dimension: subtotal_price {
    type: number
    sql: ${TABLE}.subtotal_price ;;
    description: "Subtotal price"
    value_format_name: usd
  }

  dimension: total_tax {
    type: number
    sql: ${TABLE}.total_tax ;;
    description: "Total tax amount"
    value_format_name: usd
  }

  dimension: total_discounts {
    type: number
    sql: ${TABLE}.total_discounts ;;
    description: "Total discounts"
    value_format_name: usd
  }

  dimension: shipping_cost {
    type: number
    sql: ${TABLE}.shipping_cost ;;
    description: "Shipping cost"
    value_format_name: usd
  }

  dimension: order_adjustment_amount {
    type: number
    sql: ${TABLE}.order_adjustment_amount ;;
    description: "Order adjustment amount"
    value_format_name: usd
  }

  dimension: refund_subtotal {
    type: number
    sql: ${TABLE}.refund_subtotal ;;
    description: "Refund subtotal"
    value_format_name: usd
  }

  dimension: refund_tax {
    type: number
    sql: ${TABLE}.refund_tax ;;
    description: "Refund tax"
    value_format_name: usd
  }

  # Calculated Metrics
  dimension: calculated_order_total {
    type: number
    sql: ${TABLE}.calculated_order_total ;;
    description: "Calculated order total"
    value_format_name: usd
  }

  dimension: total_line_discounts {
    type: number
    sql: ${TABLE}.total_line_discounts ;;
    description: "Total line item discounts"
    value_format_name: usd
  }

  dimension: total_discount_amount {
    type: number
    sql: ${TABLE}.total_discount_amount ;;
    description: "Total discount amount"
    value_format_name: usd
  }

  # Order Composition
  dimension: line_item_count {
    type: number
    sql: ${TABLE}.line_item_count ;;
    description: "Number of line items"
  }

  dimension: unique_product_count {
    type: number
    sql: ${TABLE}.unique_product_count ;;
    description: "Number of unique products"
  }

  dimension: total_quantity {
    type: number
    sql: ${TABLE}.total_quantity ;;
    description: "Total quantity ordered"
  }

  dimension: avg_line_price {
    type: number
    sql: ${TABLE}.avg_line_price ;;
    description: "Average line item price"
    value_format_name: usd
  }

  dimension: max_line_price {
    type: number
    sql: ${TABLE}.max_line_price ;;
    description: "Maximum line item price"
    value_format_name: usd
  }

  dimension: min_line_price {
    type: number
    sql: ${TABLE}.min_line_price ;;
    description: "Minimum line item price"
    value_format_name: usd
  }

  dimension: discount_count {
    type: number
    sql: ${TABLE}.discount_count ;;
    description: "Number of discounts applied"
  }

  dimension: order_value_category {
    type: string
    sql: ${TABLE}.order_value_category ;;
    description: "Order value category"
  }
  
  # Order size category based on total quantity
  dimension: order_size_category {
    type: string
    sql: CASE 
      WHEN ${total_quantity} = 1 THEN 'Single Item'
      WHEN ${total_quantity} BETWEEN 2 AND 3 THEN '2-3 Items'
      WHEN ${total_quantity} BETWEEN 4 AND 5 THEN '4-5 Items'
      WHEN ${total_quantity} BETWEEN 6 AND 10 THEN '6-10 Items'
      WHEN ${total_quantity} > 10 THEN '11+ Items'
      ELSE 'Unknown'
    END ;;
    description: "Order size category based on quantity"
  }

  # Order Source Information
  dimension: source_name {
    type: string
    sql: ${TABLE}.source_name ;;
    description: "Order source name"
  }

  dimension: processing_method {
    type: string
    sql: ${TABLE}.processing_method ;;
    description: "Order processing method"
  }

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

  dimension: order_note {
    type: string
    sql: ${TABLE}.order_note ;;
    description: "Order notes"
  }

  dimension: channel_source_medium {
    type: string
    sql: ${TABLE}.channel_source_medium ;;
    description: "Channel source/medium"
  }

  # Shipping Information
  dimension: shipping_company {
    type: string
    sql: ${TABLE}.shipping_company ;;
    description: "Shipping company"
  }

  dimension: tracking_company {
    type: string
    sql: ${TABLE}.tracking_company ;;
    description: "Tracking company"
  }

  dimension: tracking_number {
    type: string
    sql: ${TABLE}.tracking_number ;;
    description: "Tracking number"
  }

  # Shipping Address
  dimension: shipping_address_first_name {
    type: string
    sql: ${TABLE}.shipping_address_first_name ;;
    description: "Shipping first name"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_last_name {
    type: string
    sql: ${TABLE}.shipping_address_last_name ;;
    description: "Shipping last name"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_company {
    type: string
    sql: ${TABLE}.shipping_address_company ;;
    description: "Shipping company name"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_phone {
    type: string
    sql: ${TABLE}.shipping_address_phone ;;
    description: "Shipping phone"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_address_1 {
    type: string
    sql: ${TABLE}.shipping_address_address_1 ;;
    description: "Shipping address line 1"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_address_2 {
    type: string
    sql: ${TABLE}.shipping_address_address_2 ;;
    description: "Shipping address line 2"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_city {
    type: string
    sql: ${TABLE}.shipping_address_city ;;
    description: "Shipping city"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_province {
    type: string
    sql: ${TABLE}.shipping_address_province ;;
    description: "Shipping province/state"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_province_code {
    type: string
    sql: ${TABLE}.shipping_address_province_code ;;
    description: "Shipping province/state code"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_country {
    type: string
    sql: ${TABLE}.shipping_address_country ;;
    description: "Shipping country"
    group_label: "Shipping Address"
  }
  
  # Alias for shipping_country to match dashboard references
  dimension: shipping_country {
    type: string
    sql: ${TABLE}.shipping_address_country ;;
    description: "Shipping country"
  }

  dimension: shipping_address_country_code {
    type: string
    sql: ${TABLE}.shipping_address_country_code ;;
    description: "Shipping country code"
    group_label: "Shipping Address"
  }

  dimension: shipping_address_zip {
    type: string
    sql: ${TABLE}.shipping_address_zip ;;
    description: "Shipping ZIP/postal code"
    group_label: "Shipping Address"
  }

  # Order Flags
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

  dimension: is_multi_product_order {
    type: yesno
    sql: ${TABLE}.is_multi_product_order ;;
    description: "Order contains multiple products"
  }

  dimension: has_discount {
    type: yesno
    sql: ${TABLE}.has_discount ;;
    description: "Order has discount"
  }

  # Rate Metrics
  dimension: discount_rate {
    type: number
    sql: ${TABLE}.discount_rate ;;
    description: "Discount rate"
    value_format_name: percent_2
  }

  dimension: tax_rate {
    type: number
    sql: ${TABLE}.tax_rate ;;
    description: "Tax rate"
    value_format_name: percent_2
  }

  dimension: shipping_rate {
    type: number
    sql: ${TABLE}.shipping_rate ;;
    description: "Shipping rate"
    value_format_name: percent_2
  }

  # Net Values
  dimension: net_order_value {
    type: number
    sql: ${TABLE}.net_order_value ;;
    description: "Net order value"
    value_format_name: usd
  }

  dimension: net_subtotal {
    type: number
    sql: ${TABLE}.net_subtotal ;;
    description: "Net subtotal"
    value_format_name: usd
  }

  dimension: net_tax {
    type: number
    sql: ${TABLE}.net_tax ;;
    description: "Net tax"
    value_format_name: usd
  }

  # Processing Time Metrics
  dimension: hours_to_process {
    type: number
    sql: ${TABLE}.hours_to_process ;;
    description: "Hours to process order"
  }

  dimension: hours_to_cancellation {
    type: number
    sql: ${TABLE}.hours_to_cancellation ;;
    description: "Hours to cancellation"
  }

  # Time Analysis
  dimension: order_time_of_day {
    type: string
    sql: ${TABLE}.order_time_of_day ;;
    description: "Time of day when order was placed"
  }

  dimension: order_day_type {
    type: string
    sql: ${TABLE}.order_day_type ;;
    description: "Day type (weekday/weekend)"
  }

  # Measures
  measure: count {
    type: count
    description: "Number of orders"
    drill_fields: [order_detail*]
  }

  measure: total_revenue {
    type: sum
    sql: ${calculated_order_total} ;;
    description: "Total revenue"
    value_format_name: usd
  }

  measure: average_order_value {
    type: average
    sql: ${calculated_order_total} ;;
    description: "Average order value"
    value_format_name: usd
  }

  measure: total_items_ordered {
    type: sum
    sql: ${total_quantity} ;;
    description: "Total items ordered"
  }

  measure: average_items_per_order {
    type: average
    sql: ${total_quantity} ;;
    description: "Average items per order"
    value_format_name: decimal_1
  }

  measure: total_discount_given {
    type: sum
    sql: ${total_discount_amount} ;;
    description: "Total discounts given"
    value_format_name: usd
  }

  measure: average_discount_rate {
    type: average
    sql: ${discount_rate} ;;
    description: "Average discount rate"
    value_format_name: percent_2
  }

  measure: cancellation_rate {
    type: number
    sql: COUNT(CASE WHEN ${is_cancelled} THEN 1 END) / NULLIF(${count}, 0) ;;
    description: "Order cancellation rate"
    value_format_name: percent_2
  }

  measure: refund_rate {
    type: number
    sql: COUNT(CASE WHEN ${has_refund} THEN 1 END) / NULLIF(${count}, 0) ;;
    description: "Order refund rate"
    value_format_name: percent_2
  }

  measure: orders_with_discount {
    type: count
    filters: [has_discount: "yes"]
    description: "Number of orders with discounts"
  }

  measure: multi_product_order_rate {
    type: number
    sql: COUNT(CASE WHEN ${is_multi_product_order} THEN 1 END) / NULLIF(${count}, 0) ;;
    description: "Percentage of multi-product orders"
    value_format_name: percent_2
  }

  measure: average_processing_hours {
    type: average
    sql: ${hours_to_process} ;;
    description: "Average hours to process"
    value_format_name: decimal_1
  }

  measure: total_shipping_revenue {
    type: sum
    sql: ${shipping_cost} ;;
    description: "Total shipping revenue"
    value_format_name: usd
  }

  measure: total_tax_collected {
    type: sum
    sql: ${total_tax} ;;
    description: "Total tax collected"
    value_format_name: usd
  }

  # Drill fields
  set: order_detail {
    fields: [
      order_id,
      order_name,
      customer_email,
      order_created_date,
      calculated_order_total,
      total_quantity,
      financial_status,
      fulfillment_status
    ]
  }
}