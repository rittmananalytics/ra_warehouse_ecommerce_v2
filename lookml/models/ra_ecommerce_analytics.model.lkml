# Ra Ecommerce Analytics Model
# This model defines the explores and relationships for the ecommerce data warehouse

connection: "ra_ecommerce_bigquery"

# Project configurations
include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard.lookml"

datagroup: ra_ecommerce_default_datagroup {
  sql_trigger: SELECT MAX(last_updated) FROM `@{PROJECT_ID}.@{ECOMMERCE_DATASET}.wh_fact_data_quality` ;;
  max_cache_age: "1 hour"
}

persist_with: ra_ecommerce_default_datagroup

# Main Orders Explore - Central hub for order analysis
explore: orders {
  from: wh_fact_orders
  label: "Orders & Sales Analysis"
  description: "Comprehensive order and sales analysis with customer, product, and date dimensions"
  
  # Date dimension
  join: order_date {
    from: wh_dim_date
    type: left_outer
    sql_on: ${orders.order_date_key} = ${order_date.date_key} ;;
    relationship: many_to_one
    fields: [order_date.calendar_date, order_date.calendar_week, order_date.calendar_month, 
             order_date.calendar_quarter, order_date.calendar_year, order_date.day_of_week, 
             order_date.month_name, order_date.quarter_name, order_date.is_weekend, 
             order_date.is_holiday, order_date.season]
  }
  
  # Customer dimension
  join: customers {
    from: wh_dim_customers
    type: left_outer
    sql_on: ${orders.customer_sk} = ${customers.customer_sk} ;;
    relationship: many_to_one
    fields: [customers.customer_id, customers.email, customers.full_name, customers.city, 
             customers.province, customers.country, customers.accepts_marketing, 
             customers.total_spent, customers.orders_count, customers.customer_lifetime_value_tier,
             customers.order_frequency_tier, customers.is_current, customers.created_date]
  }
  
  # Product dimension
  join: products {
    from: wh_dim_products
    type: left_outer
    sql_on: ${orders.product_sk} = ${products.product_sk} ;;
    relationship: many_to_one
    fields: [products.product_id, products.title, products.vendor, products.product_type,
             products.price, products.cost, products.margin_percentage, products.inventory_quantity,
             products.price_tier, products.margin_category, products.inventory_status, 
             products.is_current]
  }
}

# Customer Analytics Explore
explore: customer_analytics {
  from: wh_dim_customers
  label: "Customer Analytics"
  description: "Customer behavior, segmentation, and lifetime value analysis"
  
  # Filter to current customers only by default
  sql_always_where: ${customer_analytics.is_current} = true ;;
  
  # Customer order history through orders
  join: customer_orders {
    from: wh_fact_orders
    type: left_outer
    sql_on: ${customer_analytics.customer_sk} = ${customer_orders.customer_sk} ;;
    relationship: one_to_many
    fields: [customer_orders.count_orders, customer_orders.total_revenue, 
             customer_orders.average_order_value, customer_orders.total_quantity_sold,
             customer_orders.total_gross_margin]
  }
  
  # Order dates for temporal analysis
  join: order_dates {
    from: wh_dim_date
    type: left_outer
    sql_on: ${customer_orders.order_date_key} = ${order_dates.date_key} ;;
    relationship: many_to_one
    fields: [order_dates.calendar_date, order_dates.calendar_month, 
             order_dates.calendar_quarter, order_dates.calendar_year]
  }
}

# Product Performance Explore
explore: product_performance {
  from: wh_dim_products
  label: "Product Performance"
  description: "Product sales performance, inventory, and profitability analysis"
  
  # Filter to current products only by default
  sql_always_where: ${product_performance.is_current} = true ;;
  
  # Product sales through orders
  join: product_sales {
    from: wh_fact_orders
    type: left_outer
    sql_on: ${product_performance.product_sk} = ${product_sales.product_sk} ;;
    relationship: one_to_many
    fields: [product_sales.count, product_sales.count_orders, product_sales.total_revenue,
             product_sales.total_quantity_sold, product_sales.total_gross_margin,
             product_sales.average_gross_margin_pct]
  }
  
  # Sales dates for temporal analysis
  join: sales_dates {
    from: wh_dim_date
    type: left_outer
    sql_on: ${product_sales.order_date_key} = ${sales_dates.date_key} ;;
    relationship: many_to_one
    fields: [sales_dates.calendar_date, sales_dates.calendar_month, 
             sales_dates.calendar_quarter, sales_dates.calendar_year]
  }
}

# Marketing Performance Explore
explore: marketing_performance {
  from: wh_fact_marketing_performance
  label: "Marketing Performance"
  description: "Marketing campaign performance, ROAS, and channel analysis"
  
  # Date dimension
  join: performance_date {
    from: wh_dim_date
    type: left_outer
    sql_on: ${marketing_performance.performance_date_key} = ${performance_date.date_key} ;;
    relationship: many_to_one
    fields: [performance_date.calendar_date, performance_date.calendar_week, 
             performance_date.calendar_month, performance_date.calendar_quarter, 
             performance_date.calendar_year, performance_date.day_of_week, 
             performance_date.month_name, performance_date.is_weekend]
  }
  
  # Channel dimension
  join: channels {
    from: wh_dim_channels_enhanced
    type: left_outer
    sql_on: ${marketing_performance.channel_sk} = ${channels.channel_sk} ;;
    relationship: many_to_one
    fields: [channels.channel_name, channels.channel_type, channels.platform,
             channels.channel_category, channels.is_paid, channels.is_organic,
             channels.is_social, channels.is_search, channels.cost_model,
             channels.avg_conversion_rate, channels.avg_order_value,
             channels.customer_quality_score, channels.performance_tier]
  }
}

# Website Analytics Explore
explore: website_analytics {
  from: wh_fact_ga4_sessions
  label: "Website Analytics"
  description: "Website traffic, user behavior, and conversion analysis"
  
  # Date dimension
  join: session_date {
    from: wh_dim_date
    type: left_outer
    sql_on: ${website_analytics.session_date_key} = ${session_date.date_key} ;;
    relationship: many_to_one
    fields: [session_date.calendar_date, session_date.calendar_week, 
             session_date.calendar_month, session_date.calendar_quarter, 
             session_date.calendar_year, session_date.day_of_week, 
             session_date.month_name, session_date.is_weekend, session_date.is_holiday]
  }
}

# Executive Dashboard Explore
explore: executive_overview {
  from: wh_fact_orders
  label: "Executive Overview"
  description: "High-level business metrics for executive reporting"
  
  # Date dimension
  join: exec_order_date {
    from: wh_dim_date
    type: left_outer
    sql_on: ${executive_overview.order_date_key} = ${exec_order_date.date_key} ;;
    relationship: many_to_one
    fields: [exec_order_date.calendar_date, exec_order_date.calendar_month, 
             exec_order_date.calendar_quarter, exec_order_date.calendar_year]
  }
  
  # Customer dimension for executive metrics
  join: exec_customers {
    from: wh_dim_customers
    type: left_outer
    sql_on: ${executive_overview.customer_sk} = ${exec_customers.customer_sk} ;;
    relationship: many_to_one
    fields: [exec_customers.count_current, exec_customers.average_total_spent,
             exec_customers.total_customer_value]
  }
  
  # Product dimension for executive metrics
  join: exec_products {
    from: wh_dim_products
    type: left_outer
    sql_on: ${executive_overview.product_sk} = ${exec_products.product_sk} ;;
    relationship: many_to_one
    fields: [exec_products.count_current, exec_products.total_inventory_value,
             exec_products.average_margin_percentage]
  }
  
  # Marketing performance for ROAS calculations
  join: exec_marketing {
    from: wh_fact_marketing_performance
    type: left_outer
    sql_on: ${exec_order_date.date_key} = ${exec_marketing.performance_date_key} ;;
    relationship: one_to_many
    fields: [exec_marketing.total_spend, exec_marketing.total_conversions,
             exec_marketing.overall_roas, exec_marketing.overall_cpa]
  }
  
  # Website analytics for conversion funnel
  join: exec_sessions {
    from: wh_fact_ga4_sessions
    type: left_outer
    sql_on: ${exec_order_date.date_key} = ${exec_sessions.session_date_key} ;;
    relationship: one_to_many
    fields: [exec_sessions.count, exec_sessions.total_conversions,
             exec_sessions.conversion_rate, exec_sessions.bounce_rate]
  }
}

# Data Quality Monitoring Explore
explore: data_quality {
  from: wh_fact_data_quality
  label: "Data Quality Monitoring"
  description: "Data pipeline health, quality metrics, and monitoring"
  
  # Date dimension
  join: quality_date {
    from: wh_dim_date
    type: left_outer
    sql_on: ${data_quality.report_date_key} = ${quality_date.date_key} ;;
    relationship: many_to_one
    fields: [quality_date.calendar_date, quality_date.calendar_week, 
             quality_date.calendar_month, quality_date.calendar_quarter, 
             quality_date.calendar_year, quality_date.day_of_week]
  }
}

# Channel Performance Explore
explore: channel_performance {
  from: wh_dim_channels_enhanced
  label: "Channel Performance"
  description: "Marketing channel definitions, capabilities, and benchmarks"
  
  # Marketing performance data
  join: channel_marketing {
    from: wh_fact_marketing_performance
    type: left_outer
    sql_on: ${channel_performance.channel_sk} = ${channel_marketing.channel_sk} ;;
    relationship: one_to_many
    fields: [channel_marketing.total_spend, channel_marketing.total_conversions,
             channel_marketing.overall_roas, channel_marketing.overall_ctr,
             channel_marketing.overall_conversion_rate, channel_marketing.count_campaigns]
  }
  
  # Performance dates
  join: channel_dates {
    from: wh_dim_date
    type: left_outer
    sql_on: ${channel_marketing.performance_date_key} = ${channel_dates.date_key} ;;
    relationship: many_to_one
    fields: [channel_dates.calendar_date, channel_dates.calendar_month, 
             channel_dates.calendar_quarter, channel_dates.calendar_year]
  }
}

# Advanced Analytics Explore - Multi-touch Attribution
explore: attribution_analysis {
  from: wh_fact_orders
  label: "Attribution Analysis"
  description: "Multi-touch attribution and customer journey analysis"
  
  # Order date
  join: attribution_date {
    from: wh_dim_date
    type: left_outer
    sql_on: ${attribution_analysis.order_date_key} = ${attribution_date.date_key} ;;
    relationship: many_to_one
  }
  
  # Customer journey through sessions
  join: customer_sessions {
    from: wh_fact_ga4_sessions
    type: left_outer
    sql_on: ${attribution_analysis.customer_email} = ${customer_sessions.user_pseudo_id} ;;
    relationship: one_to_many
    sql_where: ${customer_sessions.session_start_date} <= ${attribution_date.calendar_date} ;;
  }
  
  # Marketing touchpoints
  join: marketing_touchpoints {
    from: wh_fact_marketing_performance
    type: left_outer
    sql_on: ${customer_sessions.source} = ${marketing_touchpoints.platform} 
         AND ${customer_sessions.session_date_key} = ${marketing_touchpoints.performance_date_key} ;;
    relationship: many_to_one
  }
  
  # Channel definitions for touchpoint analysis
  join: touchpoint_channels {
    from: wh_dim_channels_enhanced
    type: left_outer
    sql_on: ${marketing_touchpoints.channel_sk} = ${touchpoint_channels.channel_sk} ;;
    relationship: many_to_one
  }
}