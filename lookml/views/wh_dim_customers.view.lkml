view: wh_dim_customers {
  sql_table_name: `@{PROJECT_ID}.@{ECOMMERCE_DATASET}.wh_dim_customers` ;;
  
  # Primary Key
  dimension: customer_sk {
    primary_key: yes
    type: string
    sql: ${TABLE}.customer_sk ;;
    description: "Customer surrogate key"
  }

  # Business Key
  dimension: customer_id {
    type: string
    sql: ${TABLE}.customer_id ;;
    description: "Original customer business key"
  }

  # Customer Attributes
  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
    description: "Customer email address"
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
    description: "Customer first name"
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
    description: "Customer last name"
  }

  dimension: full_name {
    type: string
    sql: CONCAT(${first_name}, ' ', ${last_name}) ;;
    description: "Customer full name"
  }

  dimension: phone {
    type: string
    sql: ${TABLE}.phone ;;
    description: "Customer phone number"
  }

  # Address Information
  dimension: address1 {
    type: string
    sql: ${TABLE}.address1 ;;
    description: "Primary address line"
  }

  dimension: address2 {
    type: string
    sql: ${TABLE}.address2 ;;
    description: "Secondary address line"
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
    description: "City"
  }

  dimension: province {
    type: string
    sql: ${TABLE}.province ;;
    description: "Province or state"
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    description: "Country"
  }

  dimension: zip {
    type: string
    sql: ${TABLE}.zip ;;
    description: "Postal/ZIP code"
  }

  # Customer Status
  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
    description: "Customer account state"
  }

  dimension: accepts_marketing {
    type: yesno
    sql: ${TABLE}.accepts_marketing ;;
    description: "Customer accepts marketing communications"
  }

  dimension: tax_exempt {
    type: yesno
    sql: ${TABLE}.tax_exempt ;;
    description: "Customer is tax exempt"
  }

  dimension: verified_email {
    type: yesno
    sql: ${TABLE}.verified_email ;;
    description: "Customer email is verified"
  }

  # Customer Lifetime Metrics
  dimension: total_spent {
    type: number
    sql: ${TABLE}.total_spent ;;
    description: "Total amount spent by customer"
    value_format_name: usd
  }

  dimension: orders_count {
    type: number
    sql: ${TABLE}.orders_count ;;
    description: "Total number of orders placed"
  }

  # Customer Segmentation
  dimension: customer_lifetime_value_tier {
    type: tier
    tiers: [0, 100, 500, 1000, 2500, 5000]
    style: relational
    sql: ${total_spent} ;;
    description: "Customer LTV tier based on total spent"
  }

  dimension: order_frequency_tier {
    type: tier
    tiers: [0, 1, 3, 5, 10, 20]
    style: relational
    sql: ${orders_count} ;;
    description: "Order frequency tier"
  }

  # SCD Type 2 Fields
  dimension_group: valid_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.valid_from ;;
    description: "Valid from date for SCD Type 2"
  }

  dimension_group: valid_to {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.valid_to ;;
    description: "Valid to date for SCD Type 2"
  }

  dimension: is_current {
    type: yesno
    sql: ${TABLE}.is_current ;;
    description: "Current version indicator"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.created_at ;;
    description: "Customer creation date"
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: timestamp
    sql: ${TABLE}.updated_at ;;
    description: "Customer last update date"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [customer_id, full_name, email, total_spent, orders_count]
  }

  measure: count_current {
    type: count
    filters: [is_current: "yes"]
    description: "Count of current customer records"
  }

  measure: count_accepts_marketing {
    type: count
    filters: [accepts_marketing: "yes", is_current: "yes"]
    description: "Count of customers accepting marketing"
  }

  measure: average_total_spent {
    type: average
    sql: ${total_spent} ;;
    value_format_name: usd
    description: "Average customer lifetime value"
  }

  measure: total_customer_value {
    type: sum
    sql: ${total_spent} ;;
    value_format_name: usd
    description: "Total customer value"
  }

  measure: average_orders_per_customer {
    type: average
    sql: ${orders_count} ;;
    value_format_name: decimal_1
    description: "Average orders per customer"
  }
}