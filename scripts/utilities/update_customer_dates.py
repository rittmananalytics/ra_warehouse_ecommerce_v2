import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Read current customer data
customers_df = pd.read_csv('seeds/shopify/customer.csv')
orders_df = pd.read_csv('seeds/shopify/order.csv')

# Convert date columns to datetime
customers_df['created_at'] = pd.to_datetime(customers_df['created_at'])
orders_df['created_at'] = pd.to_datetime(orders_df['created_at'])

# Get the date range from orders
min_order_date = orders_df['created_at'].min()
max_order_date = orders_df['created_at'].max()

print(f"Order date range: {min_order_date} to {max_order_date}")
print(f"Current customer date range: {customers_df['created_at'].min()} to {customers_df['created_at'].max()}")

# Redistribute customer creation dates across the full order period
# Keep 30% of customers as "old" customers (created in first 6 months)
# Distribute the rest evenly across the remaining period

total_customers = len(customers_df)
old_customers_count = int(total_customers * 0.3)

# Calculate the full time range
days_range = (max_order_date - min_order_date).days

# Create new creation dates
new_created_dates = []

# Old customers (first 6 months)
for i in range(old_customers_count):
    days_offset = random.randint(0, 180)
    new_date = min_order_date + timedelta(days=days_offset)
    new_created_dates.append(new_date)

# New customers (distributed across remaining period)
remaining_customers = total_customers - old_customers_count
for i in range(remaining_customers):
    # Distribute evenly with some randomness
    days_offset = random.randint(180, days_range - 7)  # Leave last week for very new customers
    new_date = min_order_date + timedelta(days=days_offset)
    new_created_dates.append(new_date)

# Ensure we have some very recent customers (last 30 days)
recent_customer_count = max(5, int(total_customers * 0.1))  # At least 5 or 10% of customers
for i in range(recent_customer_count):
    # Replace some of the last customers with very recent dates
    days_offset = random.randint(0, 30)
    new_date = max_order_date - timedelta(days=days_offset)
    new_created_dates[-(i+1)] = new_date

# Shuffle and assign
random.shuffle(new_created_dates)
customers_df['created_at'] = new_created_dates

# Sort by ID to maintain consistency
customers_df = customers_df.sort_values('id')

# Format dates back to string
customers_df['created_at'] = customers_df['created_at'].dt.strftime('%Y-%m-%d %H:%M:%S')

# Save updated customer data
customers_df.to_csv('seeds/shopify/customer_updated.csv', index=False)

print(f"\nUpdated customer creation dates:")
print(f"New date range: {min(new_created_dates)} to {max(new_created_dates)}")
print(f"Customers in last 30 days: {sum(1 for d in new_created_dates if d >= max_order_date - timedelta(days=30))}")
print(f"Customers in last 90 days: {sum(1 for d in new_created_dates if d >= max_order_date - timedelta(days=90))}")
print(f"Customers in last year: {sum(1 for d in new_created_dates if d >= max_order_date - timedelta(days=365))}")

# Also check which customers have orders
customer_ids_with_orders = orders_df['customer_id'].unique()
print(f"\nCustomers with orders: {len(customer_ids_with_orders)} out of {total_customers}")

# Create a summary of new vs returning customers by month
orders_df['order_month'] = pd.to_datetime(orders_df['created_at']).dt.to_period('M')
monthly_summary = []

for month in orders_df['order_month'].unique():
    month_orders = orders_df[orders_df['order_month'] == month]
    month_customers = month_orders['customer_id'].unique()
    
    # Count new customers (created in same month or within 30 days before)
    month_start = pd.to_datetime(str(month))
    new_customers_count = 0
    
    for cust_id in month_customers:
        if cust_id in customers_df['id'].values:
            cust_created = pd.to_datetime(customers_df[customers_df['id'] == cust_id]['created_at'].iloc[0])
            if cust_created >= month_start - timedelta(days=30) and cust_created <= month_start + timedelta(days=31):
                new_customers_count += 1
    
    monthly_summary.append({
        'month': str(month),
        'total_customers': len(month_customers),
        'new_customers': new_customers_count
    })

summary_df = pd.DataFrame(monthly_summary)
print("\nMonthly customer summary (sample):")
print(summary_df.tail(12))  # Last 12 months