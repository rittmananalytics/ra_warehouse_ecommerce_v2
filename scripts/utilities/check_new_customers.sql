-- Check customer creation dates
SELECT 
    'Last 30 days' as period,
    COUNT(DISTINCT customer_key) as new_customers
FROM `ra-development.analytics_ecommerce_ecommerce.dim_customers`
WHERE DATE_DIFF(CURRENT_DATE(), DATE(customer_created_at), DAY) <= 30

UNION ALL

SELECT 
    'Last 90 days' as period,
    COUNT(DISTINCT customer_key) as new_customers
FROM `ra-development.analytics_ecommerce_ecommerce.dim_customers`
WHERE DATE_DIFF(CURRENT_DATE(), DATE(customer_created_at), DAY) <= 90

UNION ALL

SELECT 
    'All time' as period,
    COUNT(DISTINCT customer_key) as new_customers
FROM `ra-development.analytics_ecommerce_ecommerce.dim_customers`;

-- Check orders by recent customers
WITH recent_customers AS (
    SELECT DISTINCT customer_key
    FROM `ra-development.analytics_ecommerce_ecommerce.dim_customers`
    WHERE DATE_DIFF(CURRENT_DATE(), DATE(customer_created_at), DAY) <= 30
)
SELECT 
    COUNT(DISTINCT o.order_key) as orders_by_recent_customers,
    COUNT(DISTINCT o.customer_key) as unique_recent_customers_with_orders,
    ROUND(SUM(o.order_total_price), 2) as total_revenue
FROM `ra-development.analytics_ecommerce_ecommerce.fact_orders` o
INNER JOIN recent_customers rc ON o.customer_key = rc.customer_key;

-- Check fact_order_items table
SELECT 
    COUNT(*) as total_order_items,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(DISTINCT customer_key) as unique_customers,
    ROUND(SUM(line_total), 2) as total_revenue
FROM `ra-development.analytics_ecommerce_ecommerce.fact_order_items`
WHERE DATE(order_created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY);