#!/bin/bash

# Fix LookML files to use correct table aliases and hardcoded values

echo "Fixing LookML files..."

# First, update the model file to define constants
cat > /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/models/ra_ecommerce_analytics.model.lkml << 'EOF'
# Ra Ecommerce Analytics Model
# This model defines the explores and relationships for the ecommerce data warehouse

connection: "ra_ecommerce_bigquery"

# Define constants for the project
constant: PROJECT_ID {
  value: "ra-development"
}

constant: ECOMMERCE_DATASET {
  value: "analytics_ecommerce_ecommerce"
}

# Project configurations
include: "/views/*.view.lkml"
include: "/dashboards/*.dashboard.lookml"

datagroup: ra_ecommerce_default_datagroup {
  sql_trigger: SELECT MAX(last_updated) FROM `ra-development.analytics_ecommerce_ecommerce.fact_data_quality` ;;
  max_cache_age: "1 hour"
}

persist_with: ra_ecommerce_default_datagroup

# Main Orders Explore - Central hub for order analysis
explore: orders {
  from: fact_orders
  label: "Orders & Sales Analysis"
  description: "Comprehensive order and sales analysis with customer, product, and date dimensions"
  
  # Date dimension
  join: order_date {
    from: dim_date
    type: left_outer
    sql_on: ${orders.order_date_key} = ${order_date.date_key} ;;
    relationship: many_to_one
    fields: [order_date.calendar_date, order_date.calendar_week, order_date.calendar_month, 
             order_date.calendar_quarter, order_date.calendar_year, order_date.day_of_week, 
             order_date.day_of_month, order_date.is_weekend]
  }
  
  # Customer dimension
  join: customers {
    from: dim_customers
    type: left_outer
    sql_on: ${orders.customer_sk} = ${customers.customer_sk} ;;
    relationship: many_to_one
  }
  
  # Product dimension  
  join: products {
    from: dim_products
    type: left_outer
    sql_on: ${orders.product_sk} = ${products.product_sk} ;;
    relationship: many_to_one
  }
  
  # Channel dimension
  join: channels {
    from: dim_channels
    type: left_outer
    sql_on: ${orders.channel_sk} = ${channels.channel_sk} ;;
    relationship: many_to_one
  }
}

# Sessions Explore - Web analytics focus
explore: sessions {
  from: fact_sessions
  label: "Web Sessions & Events"
  description: "Website behavior analysis including sessions, events, and conversions"
  
  # Date dimension
  join: session_date {
    from: dim_date
    type: left_outer
    sql_on: ${sessions.session_date_key} = ${session_date.date_key} ;;
    relationship: many_to_one
  }
  
  # Channel dimension
  join: channels {
    from: dim_channels
    type: left_outer
    sql_on: ${sessions.channel_sk} = ${channels.channel_sk} ;;
    relationship: many_to_one
  }
  
  # Events
  join: events {
    from: fact_events
    type: left_outer
    sql_on: ${sessions.session_id} = ${events.session_id} ;;
    relationship: one_to_many
  }
}

# Marketing Performance Explore  
explore: marketing_performance {
  from: fact_marketing_performance
  label: "Marketing Performance"
  description: "Unified marketing campaign performance across all platforms"
  
  # Date dimension
  join: activity_date {
    from: dim_date
    type: left_outer
    sql_on: ${marketing_performance.activity_date_key} = ${activity_date.date_key} ;;
    relationship: many_to_one
  }
}

# Customer Journey Explore
explore: customer_journey {
  from: fact_customer_journey
  label: "Customer Journey"
  description: "Multi-touch attribution and customer path analysis"
  
  # Date dimension
  join: event_date {
    from: dim_date
    type: left_outer
    sql_on: ${customer_journey.event_date_key} = ${event_date.date_key} ;;
    relationship: many_to_one
  }
  
  # Channel dimension
  join: channels {
    from: dim_channels
    type: left_outer
    sql_on: ${customer_journey.channel_sk} = ${channels.channel_sk} ;;
    relationship: many_to_one
  }
  
  # Customer dimension
  join: customers {
    from: dim_customers
    type: left_outer
    sql_on: ${customer_journey.customer_sk} = ${customers.customer_sk} ;;
    relationship: many_to_one
  }
}

# Inventory Explore
explore: inventory {
  from: fact_inventory
  label: "Inventory Management"
  description: "Product inventory levels and stock management"
  
  # Product dimension
  join: products {
    from: dim_products
    type: left_outer
    sql_on: ${inventory.product_id} = ${products.product_id} ;;
    relationship: many_to_one
  }
}

# Data Quality Explore
explore: data_quality {
  from: fact_data_quality
  label: "Data Quality Monitoring"
  description: "Monitor pipeline health and data quality metrics"
}
EOF

# Now fix the view files to use correct table names
echo "Updating view files to use table aliases..."

# Update fact_orders view
sed -i '' 's/wh_fact_orders/fact_orders/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_fact_orders.view.lkml

# Update fact_sessions view  
sed -i '' 's/wh_fact_ga4_sessions/fact_sessions/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_fact_ga4_sessions.view.lkml

# Update fact_marketing_performance view
sed -i '' 's/wh_fact_marketing_performance/fact_marketing_performance/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_fact_marketing_performance.view.lkml

# Update fact_data_quality view
sed -i '' 's/wh_fact_data_quality/fact_data_quality/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_fact_data_quality.view.lkml

# Update dim_products view
sed -i '' 's/wh_dim_products/dim_products/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_dim_products.view.lkml

# Update dim_customers view
sed -i '' 's/wh_dim_customers/dim_customers/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_dim_customers.view.lkml

# Update dim_channels view
sed -i '' 's/wh_dim_channels_enhanced/dim_channels/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_dim_channels_enhanced.view.lkml

# Update dim_date view
sed -i '' 's/wh_dim_date/dim_date/g' /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/wh_dim_date.view.lkml

# Rename view files to match table aliases
echo "Renaming view files..."
cd /Users/markrittman/new/ra_warehouse_ecommerce_v2/lookml/views/

mv wh_fact_orders.view.lkml fact_orders.view.lkml 2>/dev/null || true
mv wh_fact_ga4_sessions.view.lkml fact_sessions.view.lkml 2>/dev/null || true
mv wh_fact_marketing_performance.view.lkml fact_marketing_performance.view.lkml 2>/dev/null || true
mv wh_fact_data_quality.view.lkml fact_data_quality.view.lkml 2>/dev/null || true
mv wh_dim_products.view.lkml dim_products.view.lkml 2>/dev/null || true
mv wh_dim_customers.view.lkml dim_customers.view.lkml 2>/dev/null || true
mv wh_dim_channels_enhanced.view.lkml dim_channels.view.lkml 2>/dev/null || true
mv wh_dim_date.view.lkml dim_date.view.lkml 2>/dev/null || true

# Update view names inside the files
echo "Updating view names inside files..."
sed -i '' 's/view: wh_fact_orders/view: fact_orders/g' fact_orders.view.lkml 2>/dev/null || true
sed -i '' 's/view: wh_fact_ga4_sessions/view: fact_sessions/g' fact_sessions.view.lkml 2>/dev/null || true
sed -i '' 's/view: wh_fact_marketing_performance/view: fact_marketing_performance/g' fact_marketing_performance.view.lkml 2>/dev/null || true
sed -i '' 's/view: wh_fact_data_quality/view: fact_data_quality/g' fact_data_quality.view.lkml 2>/dev/null || true
sed -i '' 's/view: wh_dim_products/view: dim_products/g' dim_products.view.lkml 2>/dev/null || true
sed -i '' 's/view: wh_dim_customers/view: dim_customers/g' dim_customers.view.lkml 2>/dev/null || true
sed -i '' 's/view: wh_dim_channels_enhanced/view: dim_channels/g' dim_channels.view.lkml 2>/dev/null || true
sed -i '' 's/view: wh_dim_date/view: dim_date/g' dim_date.view.lkml 2>/dev/null || true

echo "LookML files have been fixed!"