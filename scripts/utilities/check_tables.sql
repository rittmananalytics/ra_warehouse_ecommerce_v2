-- Check wh_fact_order_items table
SELECT 
    'wh_fact_order_items' as table_name,
    COUNT(*) as row_count,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(DISTINCT product_key) as unique_products
FROM `ra-development.analytics_ecommerce_ecommerce.wh_fact_order_items`

UNION ALL

-- Check other warehouse tables
SELECT 
    'fact_orders' as table_name,
    COUNT(*) as row_count,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(DISTINCT product_key) as unique_products
FROM `ra-development.analytics_ecommerce_ecommerce.fact_orders`

UNION ALL

SELECT 
    'dim_products' as table_name,
    COUNT(*) as row_count,
    0 as unique_orders,
    COUNT(DISTINCT product_key) as unique_products
FROM `ra-development.analytics_ecommerce_ecommerce.dim_products`

UNION ALL

SELECT 
    'dim_customers' as table_name,
    COUNT(*) as row_count,
    0 as unique_orders,
    0 as unique_products
FROM `ra-development.analytics_ecommerce_ecommerce.dim_customers`

ORDER BY table_name;