# Ra Data Warehouse User Guide

## Overview

This guide provides comprehensive documentation for the Ra Ecommerce Data Warehouse v2, including available KPIs, example SQL queries, and visualization specifications for each business use case.

## Data Sources & Schema

The warehouse integrates data from:
- **Shopify** (orders, customers, products)
- **Google Analytics 4** (sessions, events, user behavior)
- **Google Ads, Facebook Ads, Pinterest Ads** (campaign performance)
- **Klaviyo** (email marketing)
- **Instagram Business** (social content)

### Core Fact Tables
- `fact_orders` - Order transactions and line items
- `fact_sessions` - Website session data
- `fact_events` - User interaction events
- `fact_marketing_performance` - Unified marketing metrics
- `fact_ad_spend` - Advertising spend and performance
- `fact_email_marketing` - Email campaign performance
- `fact_social_posts` - Social media content performance
- `fact_customer_journey` - Multi-touch attribution
- `fact_ad_attribution` - Attribution analysis
- `fact_data_quality` - Pipeline health monitoring

### Core Dimension Tables
- `dim_customers` - Customer profiles and segments
- `dim_products` - Product catalog and categories
- `dim_channels` - Marketing channel definitions
- `dim_email_campaigns` - Email campaign details

---

## 1. Executive Overview

**Purpose:** High-level business performance summary for C-level stakeholders.

### KPIs
- Total Revenue
- Total Orders  
- Average Order Value (AOV)
- Gross Margin %
- Customer Acquisition Cost (CAC)
- Return on Ad Spend (ROAS)
- Conversion Rate (Sessions to Purchase)

### Visualizations & Queries

#### 📈 Total Revenue (Last 30 Days vs. Previous 30 Days) – Line chart
```sql
WITH revenue_by_day AS (
  SELECT 
    DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) AS order_date,
    SUM(CAST(order_total_price AS FLOAT64)) AS daily_revenue,
    CASE 
      WHEN DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY) THEN 'current_30'
      WHEN DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY) THEN 'previous_30'
    END AS period
  FROM `analytics_ecommerce_ecommerce.fact_orders`
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY)
  GROUP BY order_date
)
SELECT 
  order_date,
  daily_revenue,
  period
FROM revenue_by_day
WHERE period IS NOT NULL
ORDER BY order_date;
```

#### 📊 Top 5 Channels by Revenue Contribution – Horizontal bar
```sql
SELECT 
  COALESCE(c.channel_group, 'Direct') AS channel_name,
  SUM(CAST(o.order_total_price AS FLOAT64)) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(AVG(CAST(o.order_total_price AS FLOAT64)), 2) AS avg_order_value
FROM `analytics_ecommerce_ecommerce.fact_orders` o
LEFT JOIN `analytics_ecommerce_ecommerce.fact_sessions` s
  ON o.customer_email = s.user_pseudo_id
  AND DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) = DATE(PARSE_DATE('%Y%m%d', CAST(s.session_date_key AS STRING)))
LEFT JOIN `analytics_ecommerce_ecommerce.dim_channels` c
  ON CONCAT(c.channel_source, '/', c.channel_medium) = 
     CONCAT(IFNULL(o.source_name, 'direct'), '/', IFNULL(o.referring_site, 'none'))
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY channel_name
ORDER BY total_revenue DESC
LIMIT 5;
```

#### 💸 Marketing Spend vs. ROAS by Platform – Scatter or bubble chart
```sql
SELECT 
  platform,
  SUM(spend_amount) AS total_spend,
  SUM(revenue) AS total_revenue,
  SAFE_DIVIDE(SUM(revenue), SUM(spend_amount)) AS roas,
  COUNT(DISTINCT content_name) AS campaign_count
FROM `analytics_ecommerce_ecommerce.fact_marketing_performance`
WHERE DATE(activity_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND spend_amount > 0
GROUP BY platform
ORDER BY total_spend DESC;
```

#### ⚖️ Inventory Value by Category (Current) – Tree map
```sql
SELECT 
  p.product_type AS category,
  COUNT(DISTINCT p.product_id) AS product_count,
  SUM(COALESCE(i.total_inventory_value, CAST(p.total_revenue AS FLOAT64))) AS inventory_value,
  AVG(CAST(p.avg_selling_price AS FLOAT64)) AS avg_product_price
FROM `analytics_ecommerce_ecommerce.dim_products` p
LEFT JOIN (
  SELECT 
    product_id,
    SUM(total_inventory_value) as total_inventory_value
  FROM `analytics_ecommerce_ecommerce.fact_inventory`
  GROUP BY product_id
) i
  ON p.product_id = i.product_id
WHERE p.product_status = 'active' 
  AND p.is_current = true
GROUP BY p.product_type
HAVING category IS NOT NULL
ORDER BY inventory_value DESC;
```

#### 🧲 Conversion Funnel (Sessions → Cart → Checkout → Purchase) – Funnel chart
```sql
WITH funnel_metrics AS (
  SELECT 
    COUNT(DISTINCT session_id) as sessions,
    COUNT(DISTINCT CASE WHEN viewed_products = true THEN session_id END) as product_views,
    COUNT(DISTINCT CASE WHEN added_to_cart = true THEN session_id END) as add_to_cart,
    COUNT(DISTINCT CASE WHEN began_checkout = true THEN session_id END) as begin_checkout,
    COUNT(DISTINCT CASE WHEN completed_purchase = true THEN session_id END) as purchases
  FROM `analytics_ecommerce_ecommerce.fact_sessions`
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
)
SELECT 
  'Sessions' AS stage, sessions AS count, 1 AS stage_order FROM funnel_metrics
UNION ALL
SELECT 'Product Views', product_views, 2 FROM funnel_metrics  
UNION ALL
SELECT 'Add to Cart', add_to_cart, 3 FROM funnel_metrics
UNION ALL
SELECT 'Begin Checkout', begin_checkout, 4 FROM funnel_metrics
UNION ALL
SELECT 'Purchase', purchases, 5 FROM funnel_metrics
ORDER BY stage_order;
```

---

## 2. Sales & Orders

**Purpose:** Track order and revenue performance.

### KPIs
- Net Order Value
- Total Quantity Sold
- Order Frequency
- Average Line Item Price
- Orders with Discounts %
- Refund Rate

### Visualizations & Queries

#### 📅 Daily Revenue & Orders Trend – Line + bar combo chart
```sql
SELECT 
  DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) AS order_date,
  COUNT(DISTINCT order_id) AS daily_orders,
  SUM(order_total_price) AS daily_revenue,
  ROUND(SUM(order_total_price) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM `analytics_ecommerce_ecommerce.fact_orders`
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY order_date
ORDER BY order_date;
```

#### 📦 Orders by Product Type – Stacked bar
```sql
SELECT 
  p.product_type,
  DATE_TRUNC(DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))), WEEK) AS week,
  COUNT(DISTINCT o.order_id) AS orders,
  SUM(o.line_item_quantity) AS quantity_sold,
  SUM(o.line_item_total_usd) AS revenue
FROM `analytics_ecommerce_ecommerce.fact_orders` o
JOIN `analytics_ecommerce_ecommerce.dim_products` p
  ON o.product_id = p.product_id
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 8 WEEK)
GROUP BY p.product_type, week
ORDER BY week, revenue DESC;
```

#### 🛒 Top 10 Products by Quantity Sold – Horizontal bar
```sql
SELECT 
  p.product_title,
  p.product_type,
  SUM(o.line_item_quantity) AS total_quantity,
  SUM(o.line_item_total_usd) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS orders_containing_product
FROM `analytics_ecommerce_ecommerce.fact_orders` o
JOIN `analytics_ecommerce_ecommerce.dim_products` p
  ON o.product_id = p.product_id
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY p.product_title, p.product_type
ORDER BY total_quantity DESC
LIMIT 10;
```

#### 🧾 Discount Rate vs Order Volume – Scatter plot
```sql
SELECT 
  DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) AS order_date,
  COUNT(DISTINCT order_id) AS order_volume,
  SAFE_DIVIDE(
    SUM(CASE WHEN total_discounts_usd > 0 THEN 1 ELSE 0 END),
    COUNT(DISTINCT order_id)
  ) * 100 AS discount_rate_pct,
  AVG(total_discounts_usd) AS avg_discount_amount
FROM `analytics_ecommerce_ecommerce.fact_orders`
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY order_date
ORDER BY order_date;
```

---

## 3. Marketing & Attribution

**Purpose:** Analyze performance across paid and organic channels.

### KPIs
- ROAS (Return on Ad Spend)
- CPA (Cost per Acquisition)
- CTR (Click Through Rate)
- CPC (Cost per Click)
- Revenue per Email
- Attribution Completeness Score

### Visualizations & Queries

#### 💹 Platform Spend vs Revenue – Line or bar comparison
```sql
SELECT 
  DATE_TRUNC(DATE(activity_date), WEEK) AS week,
  platform,
  SUM(spend_amount) AS weekly_spend,
  SUM(revenue) AS weekly_revenue,
  SAFE_DIVIDE(SUM(revenue), SUM(spend_amount)) AS weekly_roas
FROM `analytics_ecommerce_ecommerce.fact_marketing_performance`
WHERE DATE(activity_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 WEEK)
GROUP BY week, platform
ORDER BY week, weekly_spend DESC;
```

#### 🪧 Top Campaigns by ROAS – Table with color-coded metrics
```sql
SELECT 
  content_name,
  platform,
  SUM(spend_amount) AS total_spend,
  SUM(revenue) AS total_revenue,
  SAFE_DIVIDE(SUM(revenue), SUM(spend_amount)) AS roas,
  SUM(conversions) AS total_conversions,
  SAFE_DIVIDE(SUM(spend_amount), SUM(conversions)) AS cpa,
  performance_tier
FROM `analytics_ecommerce_ecommerce.fact_marketing_performance`
WHERE DATE(activity_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND spend_amount > 0
GROUP BY content_name, platform, performance_tier
ORDER BY roas DESC
LIMIT 20;
```

#### 🔁 Attribution-Weighted Conversions by Source – Donut chart
```sql
SELECT 
  attribution_source,
  SUM(attributed_conversions) AS total_attributed_conversions,
  SUM(attributed_revenue_usd) AS total_attributed_revenue,
  COUNT(DISTINCT customer_id) AS unique_customers
FROM `analytics_ecommerce_ecommerce.fact_ad_attribution`
WHERE DATE(conversion_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY attribution_source
ORDER BY total_attributed_revenue DESC;
```

#### 🔀 Multi-Touch Journey Timeline Samples – Sankey diagram
```sql
SELECT 
  journey_step,
  channel_source,
  next_channel_source,
  COUNT(*) AS transition_count,
  AVG(days_to_next_touch) AS avg_days_between
FROM `analytics_ecommerce_ecommerce.fact_customer_journey`
WHERE DATE(event_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND journey_step <= 5  -- Limit to first 5 touchpoints
GROUP BY journey_step, channel_source, next_channel_source
HAVING transition_count >= 10  -- Only show significant paths
ORDER BY journey_step, transition_count DESC;
```

---

## 4. Website & User Engagement

**Purpose:** Understand user interaction across sessions.

### KPIs
- Session Count
- View-to-Purchase Rate
- Bounce Rate
- Avg Session Duration
- Revenue per Session
- Time on Site

### Visualizations & Queries

#### 🔄 Conversion Funnel by Day – Sessions → Cart → Checkout → Purchase
```sql
SELECT 
  DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) AS session_date,
  COUNT(DISTINCT session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN has_add_to_cart THEN session_id END) AS sessions_with_cart,
  COUNT(DISTINCT CASE WHEN has_checkout THEN session_id END) AS sessions_with_checkout,
  COUNT(DISTINCT CASE WHEN has_purchase THEN session_id END) AS sessions_with_purchase,
  SAFE_DIVIDE(COUNT(DISTINCT CASE WHEN has_purchase THEN session_id END), COUNT(DISTINCT session_id)) * 100 AS conversion_rate
FROM `analytics_ecommerce_ecommerce.fact_sessions`
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING)))
ORDER BY DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING)));
```

#### ⏱️ Session Duration vs Conversion Probability – Scatter chart
```sql
SELECT 
  CASE 
    WHEN session_duration_minutes <= 1 THEN '0-1 min'
    WHEN session_duration_minutes <= 5 THEN '1-5 min'
    WHEN session_duration_minutes <= 15 THEN '5-15 min'
    WHEN session_duration_minutes <= 30 THEN '15-30 min'
    ELSE '30+ min'
  END AS duration_bucket,
  COUNT(DISTINCT session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN has_purchase THEN session_id END) AS converting_sessions,
  SAFE_DIVIDE(COUNT(DISTINCT CASE WHEN has_purchase THEN session_id END), COUNT(DISTINCT session_id)) * 100 AS conversion_rate,
  AVG(session_duration_minutes) AS avg_duration
FROM `analytics_ecommerce_ecommerce.fact_sessions`
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND session_duration_minutes > 0
GROUP BY duration_bucket
ORDER BY avg_duration;
```

#### 🌍 Top Pages Viewed & Avg Time – Heatmap
```sql
SELECT 
  page_path,
  COUNT(*) AS page_views,
  COUNT(DISTINCT session_id) AS unique_sessions,
  AVG(time_on_page_seconds) AS avg_time_on_page,
  SUM(CASE WHEN event_name = 'page_view' THEN 1 ELSE 0 END) AS total_pageviews
FROM `analytics_ecommerce_ecommerce.fact_events`
WHERE DATE(event_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND page_path IS NOT NULL
GROUP BY page_path
ORDER BY page_views DESC
LIMIT 20;
```

#### 📉 Bounce Rate Trend – Line chart
```sql
SELECT 
  DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) AS session_date,
  COUNT(DISTINCT session_id) AS total_sessions,
  COUNT(DISTINCT CASE WHEN is_bounce THEN session_id END) AS bounce_sessions,
  SAFE_DIVIDE(COUNT(DISTINCT CASE WHEN is_bounce THEN session_id END), COUNT(DISTINCT session_id)) * 100 AS bounce_rate,
  AVG(session_duration_minutes) AS avg_session_duration
FROM `analytics_ecommerce_ecommerce.fact_sessions`
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING)))
ORDER BY DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING)));
```

---

## 5. Customer Insights & Segments

**Purpose:** Profile customers, their value, and lifecycle stages.

### KPIs
- CLV (Historical and Predicted)
- Average Days Between Orders
- Churn Probability
- Purchase Frequency
- % of At-Risk Customers

### Visualizations & Queries

#### 🧬 RFM Segmentation Distribution – Grid or quadrant plot
```sql
SELECT 
  customer_segment,
  COUNT(DISTINCT customer_id) AS customer_count,
  AVG(total_spent_usd) AS avg_customer_value,
  AVG(order_count) AS avg_order_frequency,
  AVG(days_since_last_order) AS avg_days_since_last_order,
  SUM(total_spent_usd) AS segment_total_value
FROM `analytics_ecommerce_ecommerce.dim_customers`
WHERE customer_segment IS NOT NULL
GROUP BY customer_segment
ORDER BY segment_total_value DESC;
```

#### 👤 Customer Lifetime Value by Segment – Box plot
```sql
SELECT 
  customer_segment,
  customer_id,
  total_spent_usd AS historical_clv,
  predicted_ltv_usd,
  order_count,
  SAFE_DIVIDE(total_spent_usd, order_count) AS avg_order_value
FROM `analytics_ecommerce_ecommerce.dim_customers`
WHERE customer_segment IS NOT NULL
  AND total_spent_usd > 0
ORDER BY customer_segment, total_spent_usd DESC;
```

#### ⏳ Churn Risk vs Engagement Score – Scatter or bubble chart
```sql
SELECT 
  churn_risk_score,
  engagement_score,
  COUNT(DISTINCT customer_id) AS customer_count,
  AVG(total_spent_usd) AS avg_customer_value,
  AVG(days_since_last_order) AS avg_days_since_last_order
FROM `analytics_ecommerce_ecommerce.dim_customers`
WHERE churn_risk_score IS NOT NULL 
  AND engagement_score IS NOT NULL
GROUP BY churn_risk_score, engagement_score
ORDER BY churn_risk_score, engagement_score;
```

#### 🔁 Repeat vs One-Time Buyers – Donut chart
```sql
SELECT 
  CASE 
    WHEN order_count = 1 THEN 'One-Time Buyer'
    WHEN order_count BETWEEN 2 AND 5 THEN 'Regular Customer'
    WHEN order_count > 5 THEN 'Loyal Customer'
  END AS customer_type,
  COUNT(DISTINCT customer_id) AS customer_count,
  SUM(total_spent_usd) AS total_revenue,
  AVG(total_spent_usd) AS avg_customer_value
FROM `analytics_ecommerce_ecommerce.dim_customers`
WHERE order_count > 0
GROUP BY customer_type
ORDER BY total_revenue DESC;
```

---

## 6. Product & Inventory

**Purpose:** Assess product performance, stock levels, and reorder need.

### KPIs
- Total Inventory Value
- Days of Inventory Remaining
- Product Profitability %
- Potential Revenue at Risk
- Reorder Priority Score

### Visualizations & Queries

#### 📦 Inventory Turnover Ratio by Product – Bar chart
```sql
WITH product_sales AS (
  SELECT 
    p.product_id,
    p.product_title,
    p.product_type,
    SUM(o.line_item_quantity) AS units_sold_30d,
    SUM(o.line_item_total_usd) AS revenue_30d
  FROM `analytics_ecommerce_ecommerce.fact_orders` o
  JOIN `analytics_ecommerce_ecommerce.dim_products` p ON o.product_id = p.product_id
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY p.product_id, p.product_title, p.product_type
)
SELECT 
  ps.product_title,
  ps.product_type,
  COALESCE(inv.current_stock, 0) AS current_inventory,
  ps.units_sold_30d,
  SAFE_DIVIDE(ps.units_sold_30d, NULLIF(inv.current_stock, 0)) AS turnover_ratio,
  CASE 
    WHEN inv.current_stock <= ps.units_sold_30d * 0.5 THEN 'Low Stock'
    WHEN inv.current_stock <= ps.units_sold_30d THEN 'Medium Stock'
    ELSE 'High Stock'
  END AS stock_level
FROM product_sales ps
LEFT JOIN `analytics_ecommerce_ecommerce.fact_inventory` inv 
  ON ps.product_id = inv.product_id
ORDER BY turnover_ratio DESC
LIMIT 20;
```

#### 🛑 Out-of-Stock / Low-Stock Products – Highlight table
```sql
WITH recent_sales AS (
  SELECT 
    product_id,
    SUM(line_item_quantity) AS sold_last_30d,
    SAFE_DIVIDE(SUM(line_item_quantity), 30) AS avg_daily_sales
  FROM `analytics_ecommerce_ecommerce.fact_orders`
  WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  GROUP BY product_id
)
SELECT 
  p.product_title,
  p.product_type,
  COALESCE(inv.current_stock, 0) AS current_stock,
  rs.avg_daily_sales,
  SAFE_DIVIDE(inv.current_stock, NULLIF(rs.avg_daily_sales, 0)) AS days_of_inventory,
  CASE 
    WHEN inv.current_stock = 0 THEN 'Out of Stock'
    WHEN SAFE_DIVIDE(inv.current_stock, NULLIF(rs.avg_daily_sales, 0)) <= 7 THEN 'Low Stock'
    WHEN SAFE_DIVIDE(inv.current_stock, NULLIF(rs.avg_daily_sales, 0)) <= 14 THEN 'Medium Stock'
    ELSE 'Well Stocked'
  END AS stock_status,
  rs.sold_last_30d * CAST(p.avg_selling_price AS FLOAT64) AS potential_lost_revenue
FROM `analytics_ecommerce_ecommerce.dim_products` p
LEFT JOIN `analytics_ecommerce_ecommerce.fact_inventory` inv ON p.product_id = inv.product_id
LEFT JOIN recent_sales rs ON p.product_id = rs.product_id
WHERE rs.avg_daily_sales > 0  -- Only products with recent sales
ORDER BY days_of_inventory ASC;
```

#### 📈 Product Performance Category Trends – Line chart
```sql
SELECT 
  DATE_TRUNC(DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))), WEEK) AS week,
  p.product_type,
  SUM(o.line_item_quantity) AS units_sold,
  SUM(o.line_item_total_usd) AS revenue,
  COUNT(DISTINCT o.order_id) AS orders
FROM `analytics_ecommerce_ecommerce.fact_orders` o
JOIN `analytics_ecommerce_ecommerce.dim_products` p ON o.product_id = p.product_id
WHERE DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 WEEK)
GROUP BY week, p.product_type
ORDER BY week, revenue DESC;
```

#### 💰 Gross Margin per Unit by Product – Bubble chart
```sql
SELECT 
  p.product_title,
  p.product_type,
  CAST(p.avg_selling_price AS FLOAT64) AS selling_price,
  p.cost AS product_cost,
  CAST(p.avg_selling_price AS FLOAT64) - p.cost AS gross_margin_per_unit,
  SAFE_DIVIDE(CAST(p.avg_selling_price AS FLOAT64) - p.cost, CAST(p.avg_selling_price AS FLOAT64)) * 100 AS gross_margin_pct,
  SUM(o.line_item_quantity) AS units_sold_30d,
  SUM((CAST(p.avg_selling_price AS FLOAT64) - p.cost) * o.line_item_quantity) AS total_margin_30d
FROM `analytics_ecommerce_ecommerce.dim_products` p
LEFT JOIN `analytics_ecommerce_ecommerce.fact_orders` o 
  ON p.product_id = o.product_id 
  AND DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
WHERE CAST(p.avg_selling_price AS FLOAT64) > 0 AND p.cost > 0
GROUP BY p.product_title, p.product_type, CAST(p.avg_selling_price AS FLOAT64), p.cost
ORDER BY total_margin_30d DESC;
```

---

## 7. Email & Campaign Performance

**Purpose:** Analyze effectiveness of Klaviyo flows and campaigns.

### KPIs
- Open Rate
- Click Rate
- Conversion Rate
- Revenue per Email
- Unsubscribe & Spam Complaint Rate

### Visualizations & Queries

#### ✉️ Open, Click, Conversion Rates Over Time – Multi-line chart
```sql
SELECT 
  event_date,
  SUM(emails_delivered) AS emails_delivered,
  SUM(emails_opened) AS emails_opened,
  SUM(emails_clicked) AS emails_clicked,
  SUM(orders) AS conversions,
  SAFE_DIVIDE(SUM(emails_opened), SUM(emails_delivered)) * 100 AS open_rate,
  SAFE_DIVIDE(SUM(emails_clicked), SUM(emails_opened)) * 100 AS click_rate,
  SAFE_DIVIDE(SUM(orders), SUM(emails_delivered)) * 100 AS conversion_rate
FROM `analytics_ecommerce_ecommerce.fact_email_marketing`
WHERE event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY event_date
ORDER BY event_date;
```

#### 🧠 Engagement Score by Campaign Type – Table
```sql
SELECT 
  ec.campaign_category,
  COUNT(DISTINCT ec.campaign_id) AS campaign_count,
  AVG(em.open_rate) * 100 AS avg_open_rate,
  AVG(em.click_rate) * 100 AS avg_click_rate,
  AVG(em.conversion_rate) * 100 AS avg_conversion_rate,
  AVG(em.engagement_score) AS avg_engagement_score,
  SUM(em.revenue) AS total_revenue
FROM `analytics_ecommerce_ecommerce.dim_email_campaigns` ec
JOIN `analytics_ecommerce_ecommerce.fact_email_marketing` em
  ON ec.campaign_key = em.email_marketing_key
WHERE em.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY ec.campaign_category
ORDER BY avg_engagement_score DESC;
```

#### 📈 Revenue per Email by Campaign – Bar chart
```sql
SELECT 
  ec.content_name,
  ec.campaign_category,
  ec.email_program_type,
  SUM(em.emails_delivered) AS total_emails_delivered,
  SUM(em.revenue) AS total_revenue,
  SAFE_DIVIDE(SUM(em.revenue), SUM(em.emails_delivered)) AS revenue_per_email,
  AVG(em.engagement_score) AS avg_engagement_score
FROM `analytics_ecommerce_ecommerce.dim_email_campaigns` ec
JOIN `analytics_ecommerce_ecommerce.fact_email_marketing` em
  ON ec.campaign_key = em.email_marketing_key
WHERE em.event_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND em.emails_delivered > 0
GROUP BY ec.content_name, ec.campaign_category, ec.email_program_type
ORDER BY revenue_per_email DESC
LIMIT 20;
```

---

## 8. Social Content Performance

**Purpose:** Measure how organic social content supports performance.

### KPIs
- Total Engagements
- Engagement Rate
- Content Reach & Impressions
- Story Tap Forward/Back/Exit Rates
- Content Performance Tier

### Visualizations & Queries

#### 📸 Engagement Rate by Content Type & Platform – Grouped bar
```sql
SELECT 
  content_type,
  'Instagram' AS platform,
  COUNT(DISTINCT post_id) AS post_count,
  SUM(total_engagements) AS total_engagements,
  SUM(impressions) AS total_impressions,
  SAFE_DIVIDE(SUM(total_engagements), SUM(impressions)) * 100 AS engagement_rate,
  AVG(engagement_score) AS avg_engagement_score
FROM `analytics_ecommerce_ecommerce.fact_social_posts`
WHERE DATE(post_created_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY content_type
ORDER BY engagement_rate DESC;
```

#### 🕓 Post Timing vs Engagement Outcome – Heatmap
```sql
SELECT 
  EXTRACT(HOUR FROM post_created_date) AS post_hour,
  EXTRACT(DAYOFWEEK FROM post_created_date) AS day_of_week,
  COUNT(DISTINCT post_id) AS post_count,
  AVG(engagement_rate) AS avg_engagement_rate,
  AVG(total_engagements) AS avg_engagements,
  CASE 
    WHEN EXTRACT(DAYOFWEEK FROM post_created_date) = 1 THEN 'Sunday'
    WHEN EXTRACT(DAYOFWEEK FROM post_created_date) = 2 THEN 'Monday'
    WHEN EXTRACT(DAYOFWEEK FROM post_created_date) = 3 THEN 'Tuesday'
    WHEN EXTRACT(DAYOFWEEK FROM post_created_date) = 4 THEN 'Wednesday'
    WHEN EXTRACT(DAYOFWEEK FROM post_created_date) = 5 THEN 'Thursday'
    WHEN EXTRACT(DAYOFWEEK FROM post_created_date) = 6 THEN 'Friday'
    WHEN EXTRACT(DAYOFWEEK FROM post_created_date) = 7 THEN 'Saturday'
  END AS day_name
FROM `analytics_ecommerce_ecommerce.fact_social_posts`
WHERE DATE(post_created_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY post_hour, day_of_week
ORDER BY day_of_week, post_hour;
```

#### 🧮 Hashtag/Mention Strategy vs Performance Tier – Table
```sql
SELECT 
  performance_tier,
  COUNT(DISTINCT post_id) AS post_count,
  AVG(hashtag_count) AS avg_hashtag_count,
  AVG(mention_count) AS avg_mention_count,
  AVG(engagement_rate) AS avg_engagement_rate,
  AVG(total_engagements) AS avg_total_engagements,
  SUM(total_engagements) AS total_engagements
FROM `analytics_ecommerce_ecommerce.fact_social_posts`
WHERE DATE(post_created_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
  AND performance_tier IS NOT NULL
GROUP BY performance_tier
ORDER BY avg_engagement_rate DESC;
```

---

## 9. Data Quality Monitoring

**Purpose:** Monitor pipeline health and completeness.

### KPIs
- Source Test Pass Rate
- Integration Flow %
- Data Completeness %
- Pipeline Health Score

### Visualizations & Queries

#### 🧪 Test Pass Rates by Pipeline Stage – Stacked bar
```sql
SELECT 
  data_source,
  source_test_pass_rate,
  staging_test_pass_rate,
  integration_test_pass_rate,
  warehouse_test_pass_rate,
  overall_test_pass_rate
FROM `analytics_ecommerce_ecommerce.fact_data_quality`
ORDER BY overall_test_pass_rate DESC;
```

#### 🧹 Data Completeness & Flow % – Line chart
```sql
SELECT 
  data_source,
  source_rows,
  staging_rows,
  integration_rows,
  warehouse_rows,
  staging_flow_pct,
  integration_flow_pct,
  warehouse_flow_pct,
  data_completeness_pct
FROM `analytics_ecommerce_ecommerce.fact_data_quality`
ORDER BY source_rows DESC;
```

#### ⚙️ Overall Quality Score Trend – Gauge or line
```sql
SELECT 
  data_source,
  overall_pipeline_health_score,
  data_quality_rating,
  pipeline_efficiency_rating,
  CASE 
    WHEN overall_pipeline_health_score >= 95 THEN 'Excellent'
    WHEN overall_pipeline_health_score >= 85 THEN 'Good'
    WHEN overall_pipeline_health_score >= 70 THEN 'Needs Attention'
    ELSE 'Critical'
  END AS health_status
FROM `analytics_ecommerce_ecommerce.fact_data_quality`
ORDER BY overall_pipeline_health_score DESC;
```

---

## Best Practices

### Query Optimization
1. **Always use date filters** to limit data scanned
2. **Use appropriate aggregation levels** (daily/weekly/monthly)
3. **Leverage dimensional tables** for enrichment
4. **Apply WHERE clauses early** in CTEs

### Visualization Guidelines
1. **Color coding**: Use consistent colors across dashboards
2. **Date ranges**: Standardize on 30-day, 90-day periods
3. **Drill-down capability**: Enable users to explore details
4. **Mobile responsive**: Ensure charts work on all devices

### Performance Monitoring
- Monitor query execution times
- Set up alerts for data freshness
- Track dashboard usage metrics
- Regular performance reviews

### Common Table References

#### Project and Dataset Structure
```sql
-- Primary warehouse dataset
analytics_ecommerce_ecommerce

-- Integration dataset  
analytics_ecommerce_integration

-- Staging dataset
analytics_ecommerce_staging
```

#### Key Join Patterns
```sql
-- Orders with Products
FROM fact_orders o
JOIN dim_products p ON o.product_id = p.product_id

-- Orders with Customers
FROM fact_orders o  
JOIN dim_customers c ON o.customer_id = c.customer_id

-- Marketing with Channels
FROM fact_marketing_performance m
JOIN dim_channels ch ON m.source_name = ch.source_name

-- Events with Sessions
FROM fact_events e
JOIN fact_sessions s ON e.session_id = s.session_id
```

This guide provides a comprehensive foundation for analyzing your ecommerce business performance using the Ra Data Warehouse. Each query can be customized further based on specific business requirements.