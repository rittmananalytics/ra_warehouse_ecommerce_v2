# Advanced Analytics User Guide

## Overview

This guide provides SQL queries and dashboard specifications for advanced analytical areas in the Ra Ecommerce Data Warehouse v2, focusing on inventory management, web analytics, data quality monitoring, and operational insights.

## Data Sources & Advanced Analytics Areas

The warehouse provides deep analytical capabilities across:
- **Inventory Management** - Stock levels, turnover, reorder optimization
- **Web Analytics** - Session behavior, conversion funnels, user journeys
- **Data Quality** - Pipeline health, data completeness, testing outcomes
- **Customer Journey** - Multi-touch attribution, conversion paths
- **Product Performance** - Category trends, profitability analysis
- **Operational Metrics** - System performance, data freshness

## ⚠️ Data Availability & Troubleshooting

**Important Notes:**
- Some queries may return zero rows if the underlying source data hasn't been loaded yet
- Inventory data depends on Shopify inventory levels being available in your source system
- Session data requires GA4 integration to be active
- Always check data availability first if queries return unexpected results

**Quick Data Check Queries:**
```sql
-- Check if main tables have data
SELECT 'fact_orders' as table_name, COUNT(*) as row_count FROM `analytics_ecommerce_ecommerce.fact_orders`
UNION ALL
SELECT 'fact_sessions', COUNT(*) FROM `analytics_ecommerce_ecommerce.fact_sessions`
UNION ALL  
SELECT 'fact_inventory', COUNT(*) FROM `analytics_ecommerce_ecommerce.fact_inventory`
UNION ALL
SELECT 'dim_customers', COUNT(*) FROM `analytics_ecommerce_ecommerce.dim_customers`
UNION ALL
SELECT 'dim_products', COUNT(*) FROM `analytics_ecommerce_ecommerce.dim_products`;
```

---

## 1. Inventory Management & Optimization

**Purpose:** Monitor stock levels, identify reorder needs, and optimize inventory investment.

### KPIs
- Inventory Turnover Ratio
- Days of Inventory Remaining
- Stock-out Risk Score
- Dead Stock Value
- Inventory Carrying Cost
- Reorder Point Analysis

### Visualizations & Queries

#### 📦 Inventory Turnover Analysis – Bar chart with trend line
```sql
-- First, check if inventory data exists
WITH data_check AS (
  SELECT COUNT(*) as inventory_count
  FROM `analytics_ecommerce_ecommerce.fact_inventory`
),
inventory_metrics AS (
  SELECT 
    p.product_type,
    p.product_title,
    i.current_stock,
    i.unit_cost,
    i.total_inventory_value,
    -- Use pre-computed fields from fact_inventory
    i.inventory_turnover_ratio,
    i.days_of_inventory_remaining,
    i.inventory_velocity,
    i.stock_status,
    i.inventory_efficiency_score,
    -- Calculate 90-day sales velocity from order items
    COALESCE(sales.units_sold_90d, 0) AS units_sold_90d,
    COALESCE(sales.revenue_90d, 0) AS revenue_90d
  FROM `analytics_ecommerce_ecommerce.fact_inventory` i
  JOIN `analytics_ecommerce_ecommerce.dim_products` p 
    ON i.product_id = p.product_id 
    AND p.is_current = true
  LEFT JOIN (
    SELECT 
      oi.product_id,
      SUM(oi.quantity) AS units_sold_90d,
      SUM(oi.line_total) AS revenue_90d
    FROM `analytics_ecommerce_ecommerce.fact_order_items` oi
    WHERE DATE(PARSE_DATE('%Y%m%d', CAST(oi.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
    GROUP BY oi.product_id
  ) sales ON i.product_id = sales.product_id
  WHERE i.current_stock > 0
)
SELECT 
  product_type,
  COUNT(*) AS products_in_category,
  ROUND(AVG(inventory_turnover_ratio), 2) AS avg_turnover_ratio,
  ROUND(AVG(days_of_inventory_remaining), 1) AS avg_days_of_stock,
  ROUND(SUM(total_inventory_value), 2) AS total_category_value,
  ROUND(AVG(inventory_efficiency_score), 1) AS avg_efficiency_score,
  COUNT(CASE WHEN stock_status = 'Low Stock' THEN 1 END) AS low_stock_products,
  COUNT(CASE WHEN stock_status = 'Excess Stock' THEN 1 END) AS excess_stock_products,
  COUNT(CASE WHEN stock_status = 'Out of Stock' THEN 1 END) AS out_of_stock_products
FROM inventory_metrics
GROUP BY product_type
ORDER BY avg_turnover_ratio DESC;

-- NOTE: If this returns zero rows, check data availability with:
-- SELECT COUNT(*) FROM `analytics_ecommerce_ecommerce.fact_inventory`;
-- SELECT COUNT(*) FROM `analytics_ecommerce_ecommerce.dim_products` WHERE is_current = true;
```

#### ⚠️ Stock Alert Dashboard – Traffic light table
```sql
WITH stock_analysis AS (
  SELECT 
    p.product_title,
    p.product_type,
    p.vendor,
    i.current_stock,
    i.unit_cost,
    i.total_inventory_value,
    -- Use pre-computed fields from fact_inventory
    i.stock_status,
    i.days_of_inventory_remaining,
    i.inventory_risk_level,
    i.needs_reorder_soon,
    i.potential_revenue,
    -- Calculate recent sales velocity for additional context
    COALESCE(recent_sales.units_sold_30d, 0) AS units_sold_30d,
    COALESCE(recent_sales.avg_daily_sales, 0) AS avg_daily_sales
  FROM `analytics_ecommerce_ecommerce.fact_inventory` i
  JOIN `analytics_ecommerce_ecommerce.dim_products` p 
    ON i.product_id = p.product_id 
    AND p.is_current = true
  LEFT JOIN (
    SELECT 
      oi.product_id,
      SUM(oi.quantity) AS units_sold_30d,
      SUM(oi.quantity) / 30.0 AS avg_daily_sales
    FROM `analytics_ecommerce_ecommerce.fact_order_items` oi
    WHERE DATE(PARSE_DATE('%Y%m%d', CAST(oi.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    GROUP BY oi.product_id
  ) recent_sales ON i.product_id = recent_sales.product_id
)
SELECT 
  product_title,
  product_type,
  vendor,
  current_stock,
  ROUND(days_of_inventory_remaining, 1) AS days_of_inventory,
  stock_status,
  inventory_risk_level,
  needs_reorder_soon,
  ROUND(potential_revenue, 2) AS potential_revenue_at_risk,
  ROUND(total_inventory_value, 2) AS inventory_value,
  units_sold_30d,
  ROUND(avg_daily_sales, 1) AS avg_daily_sales
FROM stock_analysis
WHERE stock_status IN ('Out of Stock', 'Low Stock', 'Critical Stock')
   OR inventory_risk_level IN ('High', 'Critical')
   OR needs_reorder_soon = true
ORDER BY 
  CASE 
    WHEN stock_status = 'Out of Stock' THEN 1
    WHEN stock_status = 'Critical Stock' THEN 2  
    WHEN stock_status = 'Low Stock' THEN 3
    WHEN needs_reorder_soon = true THEN 4
    ELSE 5
  END,
  potential_revenue_at_risk DESC;
```

#### 📈 Inventory Value Trends – Time series
```sql
SELECT 
  DATE(PARSE_DATE('%Y%m%d', CAST(i.snapshot_date_key AS STRING))) AS snapshot_date,
  p.product_type,
  SUM(i.total_inventory_value) AS total_inventory_value,
  SUM(i.current_stock) AS total_units_in_stock,
  COUNT(DISTINCT i.product_key) AS products_tracked,
  AVG(i.unit_cost) AS avg_unit_cost
FROM `analytics_ecommerce_ecommerce.fact_inventory` i
JOIN `analytics_ecommerce_ecommerce.dim_products` p 
  ON i.product_key = p.product_key
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(i.snapshot_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
  AND p.is_current = true
GROUP BY snapshot_date, p.product_type
ORDER BY snapshot_date, p.product_type;
```

---

## 2. Web Analytics & User Behavior

**Purpose:** Deep dive into user session behavior, conversion optimization, and website performance.

### KPIs
- Session Quality Score
- Micro-Conversion Rates
- User Engagement Depth
- Page Performance Metrics
- Attribution Path Analysis
- Cohort Retention

### Visualizations & Queries

#### 🔍 Session Quality Segmentation – Heatmap
```sql
WITH session_metrics AS (
  SELECT 
    s.session_id,
    s.session_duration_minutes,
    s.page_views,
    s.unique_pages_viewed,
    s.items_viewed,
    s.session_revenue,
    s.added_to_cart,
    s.began_checkout,
    s.completed_purchase,
    s.traffic_source,
    s.traffic_medium,
    s.engagement_score, -- Use pre-computed engagement score
    s.visitor_type,
    s.session_type,
    -- Engagement classification based on pre-computed score
    CASE 
      WHEN s.engagement_score >= 80 THEN 'High Engagement'
      WHEN s.engagement_score >= 60 THEN 'Medium Engagement'  
      WHEN s.engagement_score >= 30 THEN 'Low Engagement'
      ELSE 'Bounce/Minimal'
    END AS engagement_level,
    -- Conversion stage classification
    CASE
      WHEN s.completed_purchase = true THEN 'Converted'
      WHEN s.began_checkout = true THEN 'High Intent'
      WHEN s.added_to_cart = true THEN 'Medium Intent'
      WHEN s.viewed_products = true THEN 'Low Intent'
      ELSE 'No Intent'
    END AS conversion_stage
  FROM `analytics_ecommerce_ecommerce.fact_sessions` s
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(s.session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
)
SELECT 
  engagement_level,
  conversion_stage,
  COUNT(*) AS session_count,
  ROUND(AVG(session_duration_minutes), 1) AS avg_session_duration,
  ROUND(AVG(page_views), 1) AS avg_page_views,
  ROUND(AVG(session_revenue), 2) AS avg_session_revenue,
  ROUND(AVG(engagement_score), 1) AS avg_engagement_score,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage_of_sessions
FROM session_metrics
GROUP BY engagement_level, conversion_stage
ORDER BY engagement_level, conversion_stage;
```

#### 🛒 Conversion Funnel Analysis with Drop-off Points – Funnel chart
```sql
WITH funnel_data AS (
  SELECT 
    DATE_TRUNC(DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))), WEEK) AS week,
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN viewed_products = true THEN session_id END) AS sessions_viewed_products,
    COUNT(DISTINCT CASE WHEN added_to_cart = true THEN session_id END) AS sessions_added_to_cart,
    COUNT(DISTINCT CASE WHEN began_checkout = true THEN session_id END) AS sessions_began_checkout,
    COUNT(DISTINCT CASE WHEN completed_purchase = true THEN session_id END) AS sessions_completed_purchase
  FROM `analytics_ecommerce_ecommerce.fact_sessions`
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 WEEK)
  GROUP BY week
)
SELECT 
  week,
  total_sessions,
  sessions_viewed_products,
  sessions_added_to_cart,
  sessions_began_checkout,
  sessions_completed_purchase,
  -- Calculate conversion rates
  SAFE_DIVIDE(sessions_viewed_products, total_sessions) * 100 AS product_view_rate,
  SAFE_DIVIDE(sessions_added_to_cart, sessions_viewed_products) * 100 AS add_to_cart_rate,
  SAFE_DIVIDE(sessions_began_checkout, sessions_added_to_cart) * 100 AS checkout_rate,
  SAFE_DIVIDE(sessions_completed_purchase, sessions_began_checkout) * 100 AS purchase_completion_rate,
  -- Calculate drop-off rates
  SAFE_DIVIDE(sessions_viewed_products - sessions_added_to_cart, sessions_viewed_products) * 100 AS view_to_cart_dropout,
  SAFE_DIVIDE(sessions_added_to_cart - sessions_began_checkout, sessions_added_to_cart) * 100 AS cart_to_checkout_dropout,
  SAFE_DIVIDE(sessions_began_checkout - sessions_completed_purchase, sessions_began_checkout) * 100 AS checkout_to_purchase_dropout
FROM funnel_data
ORDER BY week;
```

#### 🎯 User Journey Path Analysis – Sankey diagram
```sql
WITH journey_paths AS (
  SELECT 
    cj.customer_key,
    cj.session_sequence_number,
    cj.traffic_source,
    cj.traffic_medium,
    cj.session_type,
    cj.hours_since_previous_session,
    cj.is_converting_session,
    cj.conversion_behavior_type,
    CONCAT(cj.traffic_source, ' / ', cj.traffic_medium) AS channel_source_medium,
    LEAD(CONCAT(cj.traffic_source, ' / ', cj.traffic_medium)) OVER (
      PARTITION BY cj.customer_key 
      ORDER BY cj.session_sequence_number
    ) AS next_channel,
    LEAD(cj.session_type) OVER (
      PARTITION BY cj.customer_key 
      ORDER BY cj.session_sequence_number  
    ) AS next_session_type
  FROM `analytics_ecommerce_ecommerce.fact_customer_journey` cj
  WHERE DATE(cj.session_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    AND cj.session_sequence_number <= 5 -- Focus on first 5 touchpoints
)
SELECT 
  CONCAT(channel_source_medium, ' → ', COALESCE(next_channel, 'CONVERSION/EXIT')) AS journey_path,
  CONCAT(session_type, ' → ', COALESCE(next_session_type, 'END')) AS session_flow,
  conversion_behavior_type,
  COUNT(*) AS path_frequency,
  ROUND(AVG(hours_since_previous_session), 1) AS avg_hours_between_sessions,
  COUNT(CASE WHEN is_converting_session = true THEN 1 END) AS conversions_on_path,
  ROUND(
    SAFE_DIVIDE(
      COUNT(CASE WHEN is_converting_session = true THEN 1 END), 
      COUNT(*)
    ) * 100, 2
  ) AS path_conversion_rate
FROM journey_paths
WHERE next_channel IS NOT NULL -- Exclude final touchpoints
GROUP BY journey_path, session_flow, conversion_behavior_type
HAVING path_frequency >= 5 -- Only show significant paths
ORDER BY path_frequency DESC
LIMIT 25;
```

---

## 3. Data Quality & Pipeline Monitoring

**Purpose:** Monitor data pipeline health, identify data quality issues, and ensure system reliability.

### KPIs
- Pipeline Success Rate
- Data Freshness Score  
- Row Count Variance
- Test Pass Rate by Source
- Processing Time Metrics
- Data Completeness %

### Visualizations & Queries

#### 🏥 Pipeline Health Overview – Status dashboard
```sql
SELECT 
  dq.data_source,
  dq.source_test_pass_rate,
  dq.staging_test_pass_rate,
  dq.integration_test_pass_rate,
  dq.warehouse_test_pass_rate,
  dq.overall_test_pass_rate,
  dq.data_completeness_pct,
  dq.overall_pipeline_health_score,
  dq.data_quality_rating,
  dq.pipeline_efficiency_rating,
  -- Health status classification
  CASE 
    WHEN dq.overall_pipeline_health_score >= 95 THEN 'EXCELLENT'
    WHEN dq.overall_pipeline_health_score >= 85 THEN 'GOOD'
    WHEN dq.overall_pipeline_health_score >= 70 THEN 'NEEDS_ATTENTION'
    ELSE 'CRITICAL'
  END AS health_status,
  -- Row processing efficiency
  SAFE_DIVIDE(dq.warehouse_rows, dq.source_rows) * 100 AS processing_efficiency_pct,
  -- Data flow percentages
  dq.staging_flow_pct,
  dq.integration_flow_pct,
  dq.warehouse_flow_pct
FROM `analytics_ecommerce_ecommerce.fact_data_quality` dq
ORDER BY dq.overall_pipeline_health_score DESC;
```

#### 📊 Data Completeness Trends – Line chart with alerts
```sql
WITH daily_completeness AS (
  SELECT 
    CURRENT_DATE() AS check_date,
    data_source,
    source_rows,
    warehouse_rows,
    data_completeness_pct,
    overall_test_pass_rate,
    LAG(data_completeness_pct) OVER (
      PARTITION BY data_source 
      ORDER BY check_date
    ) AS prev_completeness_pct,
    LAG(overall_test_pass_rate) OVER (
      PARTITION BY data_source 
      ORDER BY check_date  
    ) AS prev_test_pass_rate
  FROM `analytics_ecommerce_ecommerce.fact_data_quality`
)
SELECT 
  check_date,
  data_source,
  data_completeness_pct,
  overall_test_pass_rate,
  source_rows,
  warehouse_rows,
  -- Calculate changes from previous check
  ROUND(data_completeness_pct - COALESCE(prev_completeness_pct, data_completeness_pct), 2) AS completeness_change,
  ROUND(overall_test_pass_rate - COALESCE(prev_test_pass_rate, overall_test_pass_rate), 2) AS test_pass_change,
  -- Alert flags
  CASE 
    WHEN data_completeness_pct < 95 THEN 'COMPLETENESS_ALERT'
    WHEN overall_test_pass_rate < 90 THEN 'TEST_FAILURE_ALERT'
    WHEN ABS(data_completeness_pct - COALESCE(prev_completeness_pct, data_completeness_pct)) > 5 THEN 'VARIANCE_ALERT'
    ELSE 'OK'
  END AS alert_status
FROM daily_completeness
ORDER BY check_date DESC, data_source;
```

#### 🔍 Data Quality Issue Deep Dive – Detailed table
```sql
WITH quality_details AS (
  SELECT 
    dq.data_source,
    -- Test failure analysis
    100 - dq.source_test_pass_rate AS source_failure_rate,
    100 - dq.staging_test_pass_rate AS staging_failure_rate,
    100 - dq.integration_test_pass_rate AS integration_failure_rate,
    100 - dq.warehouse_test_pass_rate AS warehouse_failure_rate,
    -- Row loss analysis
    dq.source_rows - dq.staging_rows AS source_to_staging_loss,
    dq.staging_rows - dq.integration_rows AS staging_to_integration_loss,
    dq.integration_rows - dq.warehouse_rows AS integration_to_warehouse_loss,
    -- Completeness issues
    100 - dq.data_completeness_pct AS incompleteness_pct,
    dq.source_rows,
    dq.warehouse_rows
  FROM `analytics_ecommerce_ecommerce.fact_data_quality` dq
)
SELECT 
  data_source,
  source_rows,
  warehouse_rows,
  ROUND((warehouse_rows::FLOAT / source_rows) * 100, 2) AS processing_success_rate,
  -- Identify primary issue areas
  CASE 
    WHEN source_failure_rate > 5 THEN 'SOURCE_DATA_ISSUES'
    WHEN staging_failure_rate > 5 THEN 'STAGING_TRANSFORMATION_ISSUES'
    WHEN integration_failure_rate > 5 THEN 'INTEGRATION_LOGIC_ISSUES'
    WHEN warehouse_failure_rate > 5 THEN 'WAREHOUSE_CONSTRAINT_ISSUES'
    WHEN incompleteness_pct > 5 THEN 'DATA_COMPLETENESS_ISSUES'
    ELSE 'HEALTHY'
  END AS primary_issue_type,
  -- Loss breakdown
  source_to_staging_loss,
  staging_to_integration_loss, 
  integration_to_warehouse_loss,
  incompleteness_pct
FROM quality_details
ORDER BY processing_success_rate ASC;
```

---

## 4. Product Performance Deep Dive

**Purpose:** Advanced product analytics for merchandising, pricing, and inventory optimization.

### KPIs
- Product Velocity Score
- Price Elasticity
- Cross-sell Affinity
- Seasonal Performance Index
- Margin Contribution
- Product Lifecycle Stage

### Visualizations & Queries

#### 💰 Product Profitability Matrix – Bubble chart
```sql
WITH product_performance AS (
  SELECT 
    p.product_title,
    p.product_type,
    p.vendor,
    CAST(p.avg_selling_price AS FLOAT64) AS avg_selling_price,
    p.cost AS product_cost,
    -- Recent sales data (30 days)
    COALESCE(recent.units_sold, 0) AS units_sold_30d,
    COALESCE(recent.revenue, 0) AS revenue_30d,
    COALESCE(recent.orders, 0) AS orders_30d,
    -- Profitability calculations
    CAST(p.avg_selling_price AS FLOAT64) - p.cost AS gross_margin_per_unit,
    SAFE_DIVIDE(CAST(p.avg_selling_price AS FLOAT64) - p.cost, CAST(p.avg_selling_price AS FLOAT64)) * 100 AS margin_percentage,
    (CAST(p.avg_selling_price AS FLOAT64) - p.cost) * COALESCE(recent.units_sold, 0) AS total_margin_contribution_30d
  FROM `analytics_ecommerce_ecommerce.dim_products` p
  LEFT JOIN (
    SELECT 
      oi.product_key,
      SUM(oi.quantity) AS units_sold,
      SUM(oi.line_total) AS revenue,
      COUNT(DISTINCT oi.order_id) AS orders
    FROM `analytics_ecommerce_ecommerce.fact_order_items` oi
    WHERE DATE(PARSE_DATE('%Y%m%d', CAST(oi.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    GROUP BY oi.product_key
  ) recent ON p.product_key = recent.product_key
  WHERE p.is_current = true
    AND CAST(p.avg_selling_price AS FLOAT64) > 0 
    AND p.cost > 0
)
SELECT 
  product_title,
  product_type,
  vendor,
  avg_selling_price,
  product_cost,
  gross_margin_per_unit,
  margin_percentage,
  units_sold_30d,
  revenue_30d,
  total_margin_contribution_30d,
  -- Performance classification
  CASE 
    WHEN units_sold_30d >= 10 AND margin_percentage >= 30 THEN 'STAR'
    WHEN units_sold_30d >= 10 AND margin_percentage < 30 THEN 'CASH_COW'
    WHEN units_sold_30d < 10 AND margin_percentage >= 30 THEN 'QUESTION_MARK'
    ELSE 'DOG'
  END AS performance_category
FROM product_performance
ORDER BY total_margin_contribution_30d DESC;
```

#### 📅 Seasonal Performance Analysis – Heat map by week/month
```sql
WITH weekly_sales AS (
  SELECT 
    p.product_type,
    EXTRACT(WEEK FROM DATE(PARSE_DATE('%Y%m%d', CAST(oi.order_date_key AS STRING)))) AS week_of_year,
    EXTRACT(MONTH FROM DATE(PARSE_DATE('%Y%m%d', CAST(oi.order_date_key AS STRING)))) AS month,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.line_total) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders
  FROM `analytics_ecommerce_ecommerce.fact_order_items` oi
  JOIN `analytics_ecommerce_ecommerce.dim_products` p 
    ON oi.product_key = p.product_key
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(oi.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)
    AND p.is_current = true
  GROUP BY p.product_type, week_of_year, month
),
seasonal_baseline AS (
  SELECT 
    product_type,
    AVG(units_sold) AS avg_weekly_units,
    AVG(revenue) AS avg_weekly_revenue
  FROM weekly_sales
  GROUP BY product_type
)
SELECT 
  ws.product_type,
  ws.week_of_year,
  ws.month,
  CASE ws.month
    WHEN 1 THEN 'January'
    WHEN 2 THEN 'February' 
    WHEN 3 THEN 'March'
    WHEN 4 THEN 'April'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'June'
    WHEN 7 THEN 'July'
    WHEN 8 THEN 'August'
    WHEN 9 THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
  END AS month_name,
  ws.units_sold,
  ws.revenue,
  -- Seasonal index (baseline = 100)
  ROUND((ws.units_sold / sb.avg_weekly_units) * 100, 1) AS seasonal_index_units,
  ROUND((ws.revenue / sb.avg_weekly_revenue) * 100, 1) AS seasonal_index_revenue,
  -- Performance vs baseline
  CASE 
    WHEN (ws.units_sold / sb.avg_weekly_units) >= 1.5 THEN 'PEAK_SEASON'
    WHEN (ws.units_sold / sb.avg_weekly_units) >= 1.1 THEN 'ABOVE_AVERAGE'
    WHEN (ws.units_sold / sb.avg_weekly_units) >= 0.9 THEN 'AVERAGE'
    ELSE 'BELOW_AVERAGE'
  END AS seasonal_performance
FROM weekly_sales ws
JOIN seasonal_baseline sb ON ws.product_type = sb.product_type
ORDER BY ws.product_type, ws.week_of_year;
```

---

## 5. Customer Behavior Deep Dive

**Purpose:** Advanced customer segmentation, lifetime value prediction, and behavioral analysis.

### KPIs
- Customer Lifetime Value (CLV)
- Churn Probability Score
- Purchase Frequency Trends
- Customer Acquisition Cost by Cohort
- Engagement Decay Analysis
- Reactivation Success Rate

### Visualizations & Queries

#### 🎯 RFM Analysis with Advanced Segmentation – Grid plot
```sql
WITH customer_metrics AS (
  SELECT 
    c.customer_key,
    c.customer_email,
    c.first_order_date,
    c.last_order_date,
    c.calculated_order_count AS frequency,
    c.calculated_lifetime_value AS monetary_value,
    DATE_DIFF(CURRENT_DATE(), DATE(c.last_order_date), DAY) AS recency_days,
    c.customer_segment,
    c.customer_lifecycle_stage,
    -- Calculate percentiles for RFM scoring
    NTILE(5) OVER (ORDER BY DATE_DIFF(CURRENT_DATE(), DATE(c.last_order_date), DAY) DESC) AS recency_score,
    NTILE(5) OVER (ORDER BY c.calculated_order_count) AS frequency_score,
    NTILE(5) OVER (ORDER BY c.calculated_lifetime_value) AS monetary_score
  FROM `analytics_ecommerce_ecommerce.dim_customers` c
  WHERE c.is_current = true
    AND c.calculated_order_count > 0
),
rfm_segments AS (
  SELECT 
    *,
    CONCAT(recency_score, frequency_score, monetary_score) AS rfm_score,
    -- Advanced segmentation
    CASE 
      WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
      WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'Loyal Customers'
      WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
      WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score <= 2 THEN 'Potential Loyalists'
      WHEN recency_score >= 3 AND frequency_score <= 2 AND monetary_score <= 2 THEN 'Promising'
      WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 'At Risk'
      WHEN recency_score <= 2 AND frequency_score >= 2 AND monetary_score >= 2 THEN 'Cannot Lose Them'
      WHEN recency_score <= 1 AND frequency_score >= 2 THEN 'Hibernating'
      ELSE 'Lost'
    END AS advanced_segment
  FROM customer_metrics
)
SELECT 
  advanced_segment,
  COUNT(*) AS customer_count,
  ROUND(AVG(monetary_value), 2) AS avg_customer_value,
  ROUND(AVG(frequency), 1) AS avg_order_frequency,
  ROUND(AVG(recency_days), 1) AS avg_days_since_last_order,
  ROUND(SUM(monetary_value), 2) AS total_segment_value,
  ROUND(AVG(recency_score), 1) AS avg_recency_score,
  ROUND(AVG(frequency_score), 1) AS avg_frequency_score,  
  ROUND(AVG(monetary_score), 1) AS avg_monetary_score,
  -- Segment health metrics
  COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS segment_percentage
FROM rfm_segments
GROUP BY advanced_segment
ORDER BY total_segment_value DESC;
```

#### 🔄 Customer Cohort Retention Analysis – Cohort table
```sql
WITH customer_orders AS (
  SELECT 
    o.customer_key,
    o.customer_email,
    DATE_TRUNC(DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))), MONTH) AS order_month,
    MIN(DATE_TRUNC(DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))), MONTH)) OVER (PARTITION BY o.customer_key) AS first_order_month,
    o.calculated_order_total
  FROM `analytics_ecommerce_ecommerce.fact_orders` o
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
),
cohort_data AS (
  SELECT 
    first_order_month AS cohort_month,
    order_month,
    DATE_DIFF(order_month, first_order_month, MONTH) AS months_since_first_order,
    COUNT(DISTINCT customer_key) AS customers_in_period,
    SUM(calculated_order_total) AS cohort_revenue
  FROM customer_orders
  GROUP BY first_order_month, order_month, months_since_first_order
),
cohort_sizes AS (
  SELECT 
    cohort_month,
    COUNT(DISTINCT customer_key) AS cohort_size,
    SUM(calculated_order_total) AS cohort_initial_revenue
  FROM customer_orders
  WHERE order_month = first_order_month
  GROUP BY cohort_month
)
SELECT 
  cd.cohort_month,
  cs.cohort_size,
  cd.months_since_first_order,
  cd.customers_in_period,
  ROUND((cd.customers_in_period * 100.0) / cs.cohort_size, 2) AS retention_rate,
  ROUND(cd.cohort_revenue / cd.customers_in_period, 2) AS avg_revenue_per_retained_customer,
  cd.cohort_revenue AS total_cohort_revenue
FROM cohort_data cd
JOIN cohort_sizes cs ON cd.cohort_month = cs.cohort_month
WHERE cd.months_since_first_order <= 11 -- Show up to 12 months of retention
ORDER BY cd.cohort_month, cd.months_since_first_order;
```

---

## 6. Operational Performance Metrics

**Purpose:** Monitor system performance, query optimization, and operational efficiency.

### KPIs
- Query Performance Metrics
- Data Processing Times  
- Storage Utilization
- Cost per Query/Analysis
- Dashboard Usage Analytics
- Alert Response Times

### Visualizations & Queries

#### ⚡ System Performance Summary – KPI tiles
```sql
WITH performance_summary AS (
  SELECT 
    -- Data volume metrics
    (SELECT COUNT(*) FROM `analytics_ecommerce_ecommerce.fact_orders`) AS total_orders,
    (SELECT COUNT(*) FROM `analytics_ecommerce_ecommerce.fact_sessions`) AS total_sessions,
    (SELECT COUNT(*) FROM `analytics_ecommerce_ecommerce.fact_events`) AS total_events,
    (SELECT COUNT(DISTINCT customer_key) FROM `analytics_ecommerce_ecommerce.dim_customers`) AS total_customers,
    (SELECT COUNT(DISTINCT product_key) FROM `analytics_ecommerce_ecommerce.dim_products`) AS total_products,
    -- Data freshness (assuming we have metadata tables)
    CURRENT_TIMESTAMP() AS last_refresh_time,
    -- Quality metrics
    (SELECT AVG(overall_pipeline_health_score) FROM `analytics_ecommerce_ecommerce.fact_data_quality`) AS avg_pipeline_health,
    (SELECT AVG(data_completeness_pct) FROM `analytics_ecommerce_ecommerce.fact_data_quality`) AS avg_data_completeness
)
SELECT 
  'ORDERS' as metric_name, 
  FORMAT('%,d', total_orders) as metric_value,
  'Total orders processed' as description
FROM performance_summary
UNION ALL
SELECT 
  'SESSIONS', 
  FORMAT('%,d', total_sessions),
  'Website sessions tracked'
FROM performance_summary  
UNION ALL
SELECT 
  'EVENTS',
  FORMAT('%,d', total_events), 
  'User events captured'
FROM performance_summary
UNION ALL
SELECT 
  'CUSTOMERS',
  FORMAT('%,d', total_customers),
  'Unique customers profiled'
FROM performance_summary
UNION ALL
SELECT 
  'PRODUCTS', 
  FORMAT('%,d', total_products),
  'Products in catalog'
FROM performance_summary
UNION ALL
SELECT 
  'PIPELINE_HEALTH',
  FORMAT('%.1f%%', avg_pipeline_health),
  'Average pipeline health score'  
FROM performance_summary
UNION ALL
SELECT 
  'DATA_COMPLETENESS',
  FORMAT('%.1f%%', avg_data_completeness),
  'Average data completeness'
FROM performance_summary;
```

---

## Best Practices for Advanced Analytics

### Query Optimization
1. **Use appropriate date partitioning** - Always filter on date columns first
2. **Leverage clustering** - Use clustered columns in WHERE clauses  
3. **Aggregate early** - Push aggregations down in CTEs
4. **Monitor query costs** - Track slot usage and bytes scanned

### Dashboard Design
1. **Progressive disclosure** - Start with high-level metrics, drill down to details
2. **Real-time vs batch** - Use appropriate refresh frequencies
3. **Mobile optimization** - Ensure dashboards work on tablets/phones
4. **Performance monitoring** - Track dashboard load times and usage

### Data Governance
1. **Access controls** - Implement role-based access to sensitive data
2. **Data lineage** - Document data sources and transformations
3. **Change management** - Version control for queries and dashboards
4. **Documentation** - Maintain up-to-date field definitions

### Alert Management
1. **Threshold-based alerts** - Set meaningful boundaries for KPIs
2. **Escalation procedures** - Define response workflows
3. **Alert fatigue prevention** - Tune sensitivity to avoid noise
4. **Root cause analysis** - Link alerts to actionable insights

## Common Advanced Analytics Patterns

### Time-Series Analysis
```sql
-- Example: 7-day moving average
SELECT 
  date_column,
  metric_value,
  AVG(metric_value) OVER (
    ORDER BY date_column 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) AS moving_avg_7d
FROM your_table
ORDER BY date_column;
```

### Percentile Analysis
```sql
-- Example: Customer value percentiles
SELECT 
  customer_segment,
  PERCENTILE_CONT(customer_value, 0.25) OVER (PARTITION BY customer_segment) AS q1,
  PERCENTILE_CONT(customer_value, 0.5) OVER (PARTITION BY customer_segment) AS median,
  PERCENTILE_CONT(customer_value, 0.75) OVER (PARTITION BY customer_segment) AS q3,
  PERCENTILE_CONT(customer_value, 0.95) OVER (PARTITION BY customer_segment) AS p95
FROM customer_metrics;
```

### Cohort Analysis Pattern
```sql
-- Generic cohort framework
WITH cohorts AS (
  SELECT 
    entity_id,
    first_activity_date,
    current_activity_date,
    DATE_DIFF(current_activity_date, first_activity_date, MONTH) AS months_since_first
  FROM activity_data
)
SELECT 
  first_activity_date AS cohort_date,
  months_since_first,
  COUNT(DISTINCT entity_id) AS active_entities,
  -- Add retention calculations
FROM cohorts
GROUP BY cohort_date, months_since_first;
```

This advanced analytics guide provides comprehensive SQL queries for deep analysis across inventory, web analytics, data quality, product performance, customer behavior, and operational metrics. Each query is designed to work with the current BigQuery schema and can be customized further based on specific business requirements.