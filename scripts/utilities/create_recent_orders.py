import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import uuid

# Read current data
customers_df = pd.read_csv('seeds/shopify/customer.csv')
orders_df = pd.read_csv('seeds/shopify/order_enhanced.csv')
order_lines_df = pd.read_csv('seeds/shopify/order_lines.csv')
products_df = pd.read_csv('seeds/shopify/product.csv')

# Convert date columns
customers_df['created_at'] = pd.to_datetime(customers_df['created_at'])
orders_df['created_at'] = pd.to_datetime(orders_df['created_at'])

# Get recent customers (created in last 90 days)
today = pd.Timestamp.now()
recent_customers = customers_df[customers_df['created_at'] >= today - timedelta(days=90)]
print(f"Found {len(recent_customers)} recent customers (last 90 days)")

# Get the max order ID to continue from
max_order_id = orders_df['id'].max()
# Convert order_line_id to numeric and get max
order_lines_df['order_line_id'] = pd.to_numeric(order_lines_df['order_line_id'], errors='coerce')
max_order_line_id = order_lines_df['order_line_id'].max()

# Traffic source distributions
traffic_sources = [
    {'source_name': 'web', 'referring_site': 'google.com', 'utm_source': 'google', 'utm_medium': 'organic', 'weight': 0.25},
    {'source_name': 'web', 'referring_site': 'google.com', 'utm_source': 'google', 'utm_medium': 'cpc', 'utm_campaign': 'summer_sale', 'weight': 0.15},
    {'source_name': 'web', 'referring_site': 'facebook.com', 'utm_source': 'facebook', 'utm_medium': 'social', 'utm_campaign': 'beauty_tips', 'weight': 0.15},
    {'source_name': 'web', 'referring_site': 'instagram.com', 'utm_source': 'instagram', 'utm_medium': 'social', 'utm_campaign': 'influencer_campaign', 'weight': 0.10},
    {'source_name': 'email', 'referring_site': '', 'utm_source': 'email', 'utm_medium': 'email', 'utm_campaign': 'newsletter', 'weight': 0.10},
    {'source_name': 'web', 'referring_site': '', 'utm_source': '', 'utm_medium': '', 'weight': 0.25},  # Direct
]

# Create new orders for recent customers
new_orders = []
new_order_lines = []
order_id_counter = max_order_id + 1
order_line_id_counter = max_order_line_id + 1

# Ensure each recent customer has at least one order
for _, customer in recent_customers.iterrows():
    # Number of orders for this customer (1-3)
    num_orders = random.randint(1, 3)
    
    for order_num in range(num_orders):
        # Order date should be after customer creation
        days_after_creation = random.randint(0, min(30, (today - customer['created_at']).days))
        order_date = customer['created_at'] + timedelta(days=days_after_creation)
        
        # Skip if order date is in the future
        if order_date > today:
            continue
            
        # Select traffic source
        traffic_source = random.choices(traffic_sources, weights=[ts['weight'] for ts in traffic_sources])[0]
        
        # Create order
        order = {
            'id': order_id_counter,
            'customer_id': customer['id'],
            'email': customer['email'],
            'created_at': order_date.strftime('%Y-%m-%d %H:%M:%S'),
            'processed_at': (order_date + timedelta(hours=random.randint(1, 3))).strftime('%Y-%m-%d %H:%M:%S'),
            'currency': 'GBP',
            'total_price': 0,  # Will calculate later
            'subtotal_price': 0,
            'total_tax': 0,
            'financial_status': 'paid',
            'fulfillment_status': 'fulfilled',
            'location_id': random.choice([1, 4]),
            'source_name': traffic_source['source_name'],
            'referring_site': traffic_source.get('referring_site', ''),
            'landing_site_ref': f"https://{traffic_source.get('referring_site', '')}" if traffic_source.get('referring_site') else '',
            'browser_ip': f"192.168.1.{random.randint(200, 250)}",
            'accepts_marketing': random.choice([True, False]),
            'tags': '',
            'name': f"#{order_id_counter}",
            'note': '',
            'checkout_token': str(uuid.uuid4()),
            'reference': f"REF{order_id_counter}",
            'source_identifier': f"SRC{order_id_counter}",
            'source_url': 'https://belleandglow.co.uk/',
            'device_id': f"device{order_id_counter}",
            'checkout_id': f"checkout{order_id_counter}",
            'user_agent': random.choice([
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
                "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15"
            ]),
            'customer_locale': 'en-GB',
            'app_id': 1,
            'landing_site': 'https://belleandglow.co.uk/',
            'referring_site_domain': traffic_source.get('referring_site', '').replace('www.', ''),
            'utm_source': traffic_source.get('utm_source', ''),
            'utm_medium': traffic_source.get('utm_medium', ''),
            'utm_campaign': traffic_source.get('utm_campaign', ''),
            'utm_term': '',
            'utm_content': '',
            '_fivetran_synced': '2025-07-19 10:00:00'
        }
        
        # Create order lines (1-4 products per order)
        num_products = random.randint(1, 4)
        selected_products = products_df.sample(n=num_products)
        
        order_subtotal = 0
        for _, product in selected_products.iterrows():
            quantity = random.randint(1, 3)
            # Generate realistic prices
            unit_price = round(random.uniform(15, 60), 2)
            line_price = round(unit_price * quantity, 2)
            discount = round(line_price * random.uniform(0, 0.15), 2) if random.random() < 0.3 else 0
            
            order_line = {
                'order_line_id': order_line_id_counter,
                'order_id': order_id_counter,
                'product_id': product['id'],
                'variant_id': f"{product['id']}001",  # Simple variant ID
                'sku': f"SKU-{product['id']:03d}",
                'product_title': product['title'],
                'variant_title': 'Default',
                'quantity': quantity,
                'price': unit_price,
                'total_discount': discount,
                'tax_amount': round((line_price - discount) * 0.2, 2),  # 20% VAT
                'fulfillment_status': 'fulfilled',
                'vendor': product['vendor'],
                'product_type': product['product_type'],
                'requires_shipping': 'true',
                'taxable': 'true',
                'gift_card': 'false',
                'name': f"{product['title']} - Default",
                'variant_inventory_management': 'shopify',
                'properties': '[]',
                'product_exists': 'true',
                'fulfillable_quantity': quantity,
                'grams': 150,
                'pre_tax_price': str(line_price - discount),
                'tax_lines': f'[{{"price": "{round((line_price - discount) * 0.2, 2)}", "rate": 0.20, "title": "VAT"}}]',
                'total_discount_set': f'[{{"shop_money": {{"amount": "{discount}", "currency_code": "GBP"}}}}]',
                'discount_allocations': f'[{{"amount": "{discount}", "discount_application": {{"type": "discount_code", "title": "SUMMER10"}}}}]' if discount > 0 else '[]',
                'duties': '[]',
                'admin_graphql_api_id': f'gid://shopify/LineItem/{order_line_id_counter}'
            }
            
            new_order_lines.append(order_line)
            order_line_id_counter += 1
            order_subtotal += line_price - discount
        
        # Update order totals
        order['subtotal_price'] = round(order_subtotal, 2)
        order['total_tax'] = round(order_subtotal * 0.2, 2)
        order['total_price'] = round(order_subtotal + order['total_tax'], 2)
        
        new_orders.append(order)
        order_id_counter += 1

print(f"\nCreated {len(new_orders)} new orders")
print(f"Created {len(new_order_lines)} new order lines")

# Append to existing data
if new_orders:
    new_orders_df = pd.DataFrame(new_orders)
    updated_orders_df = pd.concat([orders_df, new_orders_df], ignore_index=True)
    updated_orders_df.to_csv('seeds/shopify/order_enhanced_updated.csv', index=False)
    print(f"Saved updated orders to order_enhanced_updated.csv")
    
    # Also create regular order.csv
    order_columns = ['id', 'customer_id', 'email', 'created_at', 'processed_at', 'currency', 
                     'total_price', 'subtotal_price', 'total_tax', 'financial_status', 
                     'fulfillment_status', 'location_id', '_fivetran_synced']
    orders_regular_df = pd.read_csv('seeds/shopify/order.csv')
    new_orders_regular_df = new_orders_df[order_columns]
    updated_orders_regular_df = pd.concat([orders_regular_df, new_orders_regular_df], ignore_index=True)
    updated_orders_regular_df.to_csv('seeds/shopify/order_updated.csv', index=False)
    print(f"Saved updated orders to order_updated.csv")

if new_order_lines:
    new_order_lines_df = pd.DataFrame(new_order_lines)
    updated_order_lines_df = pd.concat([order_lines_df, new_order_lines_df], ignore_index=True)
    updated_order_lines_df.to_csv('seeds/shopify/order_lines_updated.csv', index=False)
    print(f"Saved updated order lines to order_lines_updated.csv")

# Print summary
print(f"\nOrder summary:")
print(f"Recent customers with orders: {len(new_orders_df['customer_id'].unique())}")
print(f"Orders in last 30 days: {len(new_orders_df[pd.to_datetime(new_orders_df['created_at']) >= today - timedelta(days=30)])}")
print(f"Orders in last 90 days: {len(new_orders_df[pd.to_datetime(new_orders_df['created_at']) >= today - timedelta(days=90)])}")