-- Check all fact tables in the warehouse
SELECT 
    table_name,
    row_count,
    size_bytes,
    ROUND(size_bytes / 1024.0 / 1024.0, 2) as size_mb
FROM `ra-development.analytics_ecommerce_ecommerce.__TABLES__`
WHERE table_name LIKE 'fact_%'
ORDER BY table_name;

-- Show sample from fact_order_items
SELECT 
    order_id,
    order_line_id,
    product_title,
    channel_source_medium,
    quantity,
    unit_price,
    line_total
FROM `ra-development.analytics_ecommerce_ecommerce.fact_order_items`
LIMIT 5;