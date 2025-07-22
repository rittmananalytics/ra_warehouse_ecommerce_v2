from google.cloud import bigquery
import os

# Initialize BigQuery client
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = os.path.expanduser('~/key/ra-development-d2f1e76c4b2e.json')
client = bigquery.Client(project='ra-development')

# Query to check the fact_order_items table
query = """
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT order_id) as unique_orders,
    COUNT(DISTINCT product_key) as unique_products,
    COUNT(DISTINCT customer_key) as unique_customers,
    COUNT(DISTINCT channel_key) as unique_channels,
    SUM(quantity) as total_quantity,
    ROUND(SUM(line_total), 2) as total_revenue
FROM `ra-development.analytics_ecommerce_ecommerce.wh_fact_order_items`
"""

print("Checking wh_fact_order_items table...")
result = client.query(query, location='europe-west2').result()

for row in result:
    print(f"\nTable Summary:")
    print(f"Total rows: {row.total_rows}")
    print(f"Unique orders: {row.unique_orders}")
    print(f"Unique products: {row.unique_products}")
    print(f"Unique customers: {row.unique_customers}")
    print(f"Unique channels: {row.unique_channels}")
    print(f"Total quantity sold: {row.total_quantity}")
    print(f"Total revenue: £{row.total_revenue}")

# Sample some data
sample_query = """
SELECT 
    order_id,
    product_title,
    channel_source_medium,
    quantity,
    ROUND(line_total, 2) as line_total
FROM `ra-development.analytics_ecommerce_ecommerce.wh_fact_order_items`
LIMIT 10
"""

print("\n\nSample rows:")
result = client.query(sample_query, location='europe-west2').result()

for row in result:
    print(f"Order {row.order_id}: {row.product_title} | Channel: {row.channel_source_medium} | Qty: {row.quantity} | Total: £{row.line_total}")