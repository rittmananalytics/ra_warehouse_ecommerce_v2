-- Query to get DDL for all tables in the analytics_ecommerce_ecommerce dataset
SELECT
    table_name,
    ddl
FROM
    `ra-development`.analytics_ecommerce_ecommerce.INFORMATION_SCHEMA.TABLES
WHERE
    table_type = 'BASE TABLE'
ORDER BY
    table_name;