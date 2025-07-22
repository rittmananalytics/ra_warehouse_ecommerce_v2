-- Master script to execute all foreign table DDLs
-- This script creates all Supabase foreign tables for the BigQuery warehouse
-- 
-- Prerequisites:
-- 1. BigQuery FDW extension installed in Supabase
-- 2. Foreign server 'bigquery_server' configured with proper credentials
-- 3. Access to ra-development project in europe-west2 location
--
-- Usage:
-- Execute this script in Supabase SQL Editor or via psql
-- This will drop and recreate all foreign tables

-- Execute dimension table DDLs
\i 01_dim_tables.sql

-- Execute fact table DDLs  
\i 02_fact_tables.sql

-- Verify all tables were created
SELECT 
    foreign_table_schema,
    foreign_table_name,
    foreign_server_name
FROM information_schema.foreign_tables
WHERE foreign_table_schema = 'public'
ORDER BY 
    CASE 
        WHEN foreign_table_name LIKE 'dim_%' THEN 1
        WHEN foreign_table_name LIKE 'fact_%' THEN 2
        ELSE 3
    END,
    foreign_table_name;