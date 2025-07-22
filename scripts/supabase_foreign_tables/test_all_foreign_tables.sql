-- Test all foreign tables
-- This script will test each foreign table to ensure data retrieval works

DO $$
DECLARE
    test_table RECORD;
    row_count INTEGER;
    test_results TEXT := '';
BEGIN
    -- Array of tables to test
    FOR test_table IN 
        SELECT unnest(ARRAY[
            'dim_categories',
            'dim_channels', 
            'dim_customer_metrics',
            'dim_customers',
            'dim_date',
            'dim_products',
            'dim_social_content',
            'fact_ad_attribution',
            'fact_ad_spend',
            'fact_customer_journey',
            'fact_data_quality',
            'fact_email_marketing',
            'fact_events',
            'fact_inventory',
            'fact_marketing_performance',
            'fact_order_items',
            'fact_orders',
            'fact_sessions',
            'fact_social_posts'
        ]) AS table_name
    LOOP
        BEGIN
            -- Test each table
            EXECUTE format('SELECT COUNT(*) FROM %I', test_table.table_name) INTO row_count;
            test_results := test_results || format('✓ %s: %s rows%s', test_table.table_name, row_count, E'\n');
        EXCEPTION
            WHEN OTHERS THEN
                test_results := test_results || format('✗ %s: ERROR - %s%s', test_table.table_name, SQLERRM, E'\n');
        END;
    END LOOP;
    
    -- Output results
    RAISE NOTICE E'Foreign Table Test Results:\n%', test_results;
END $$;