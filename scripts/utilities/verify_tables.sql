-- List all tables in the dataset that start with 'fact_' or contain 'order_items'
SELECT 
    table_name,
    row_count,
    ROUND(size_bytes / 1024.0 / 1024.0, 2) as size_mb,
    TIMESTAMP_MILLIS(creation_time) as created_at
FROM `ra-development.analytics_ecommerce_ecommerce.__TABLES__`
WHERE table_name LIKE '%fact_%' 
   OR table_name LIKE '%order_items%'
ORDER BY table_name;