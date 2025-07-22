import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import json

# Read the updated order data
orders_df = pd.read_csv('seeds/shopify/order_enhanced_updated.csv')
order_lines_df = pd.read_csv('seeds/shopify/order_lines_updated.csv')
customers_df = pd.read_csv('seeds/shopify/customer.csv')
products_df = pd.read_csv('seeds/shopify/product.csv')

# Read existing GA4 events
purchase_events_df = pd.read_csv('seeds/ga4/purchase_events.csv')
funnel_events_df = pd.read_csv('seeds/ga4/ecommerce_funnel_events.csv')

# Convert dates
orders_df['created_at'] = pd.to_datetime(orders_df['created_at'])
customers_df['created_at'] = pd.to_datetime(customers_df['created_at'])

# Get only new orders (those not in existing purchase events)
existing_order_ids = purchase_events_df['transaction_id'].unique()
new_orders = orders_df[~orders_df['id'].isin(existing_order_ids)]

print(f"Found {len(new_orders)} new orders to create GA4 events for")

# Create purchase events for new orders
new_purchase_events = []
new_funnel_events = []

for _, order in new_orders.iterrows():
    # Get customer info
    customer = customers_df[customers_df['id'] == order['customer_id']].iloc[0]
    
    # Create user_id from email
    user_id = customer['email'].replace('@', '_').replace('.', '_')
    
    # Get order lines for this order
    order_items = order_lines_df[order_lines_df['order_id'] == order['id']]
    
    # Create items array for the purchase event
    items = []
    for _, item in order_items.iterrows():
        product = products_df[products_df['id'] == item['product_id']].iloc[0]
        items.append({
            'item_id': str(item['product_id']),
            'item_name': item['product_title'],
            'item_category': item['product_type'],
            'item_brand': item['vendor'],
            'price': float(item['price']),
            'quantity': int(item['quantity'])
        })
    
    # Purchase event
    purchase_event = {
        'event_date': order['created_at'].strftime('%Y-%m-%d'),
        'event_timestamp': int(order['created_at'].timestamp() * 1000000),
        'event_name': 'purchase',
        'user_id': user_id,
        'user_pseudo_id': f"user_{order['customer_id']}",
        'transaction_id': str(order['id']),
        'value': float(order['total_price']),
        'currency': order['currency'],
        'items': json.dumps(items),
        'tax': float(order['total_tax']),
        'shipping': '0',  # Not in order data - string for seed compatibility
        'affiliation': 'Belle & Glow',
        'coupon': 'SUMMER10' if any(order_items['total_discount'] > 0) else '',
        'payment_type': 'card',
        'traffic_source': order['source_name'],
        'traffic_medium': order['utm_medium'] if order['utm_medium'] else '(none)',
        'traffic_campaign': order['utm_campaign'] if order['utm_campaign'] else '(none)',
        'page_location': 'https://belleandglow.co.uk/checkout/thank-you',
        'user_first_touch_timestamp': int(customer['created_at'].timestamp() * 1000000),
        'device_category': 'web',
        'platform': 'web',
        'hostname': 'belleandglow.co.uk'
    }
    new_purchase_events.append(purchase_event)
    
    # Create funnel events leading up to purchase
    # Work backwards from purchase time
    purchase_time = order['created_at']
    
    # begin_checkout (5-15 minutes before purchase)
    begin_checkout_time = purchase_time - timedelta(minutes=random.randint(5, 15))
    begin_checkout_event = {
        'event_date': begin_checkout_time.strftime('%Y-%m-%d'),
        'event_timestamp': int(begin_checkout_time.timestamp() * 1000000),
        'event_name': 'begin_checkout',
        'user_id': user_id,
        'user_pseudo_id': f"user_{order['customer_id']}",
        'value': float(order['subtotal_price']),
        'currency': order['currency'],
        'items': json.dumps(items),
        'coupon': '',
        'page_location': 'https://belleandglow.co.uk/checkout',
        'traffic_source': order['source_name'],
        'traffic_medium': order['utm_medium'] if order['utm_medium'] else '(none)',
        'user_first_touch_timestamp': int(customer['created_at'].timestamp() * 1000000),
        'device_category': 'web'
    }
    new_funnel_events.append(begin_checkout_event)
    
    # add_to_cart events (10-30 minutes before checkout)
    for idx, item in enumerate(items):
        add_to_cart_time = begin_checkout_time - timedelta(minutes=random.randint(10, 30))
        add_to_cart_event = {
            'event_date': add_to_cart_time.strftime('%Y-%m-%d'),
            'event_timestamp': int(add_to_cart_time.timestamp() * 1000000),
            'event_name': 'add_to_cart',
            'user_id': user_id,
            'user_pseudo_id': f"user_{order['customer_id']}",
            'value': item['price'] * item['quantity'],
            'currency': order['currency'],
            'items': json.dumps([item]),
            'coupon': '',
            'page_location': f'https://belleandglow.co.uk/products/{item["item_name"].lower().replace(" ", "-")}',
            'traffic_source': order['source_name'],
            'traffic_medium': order['utm_medium'] if order['utm_medium'] else '(none)',
            'user_first_touch_timestamp': int(customer['created_at'].timestamp() * 1000000),
            'device_category': 'web'
        }
        new_funnel_events.append(add_to_cart_event)
        
        # view_item events (5-10 minutes before add_to_cart)
        view_item_time = add_to_cart_time - timedelta(minutes=random.randint(5, 10))
        view_item_event = {
            'event_date': view_item_time.strftime('%Y-%m-%d'),
            'event_timestamp': int(view_item_time.timestamp() * 1000000),
            'event_name': 'view_item',
            'user_id': user_id,
            'user_pseudo_id': f"user_{order['customer_id']}",
            'value': item['price'],
            'currency': order['currency'],
            'items': json.dumps([item]),
            'coupon': '',
            'page_location': f'https://belleandglow.co.uk/products/{item["item_name"].lower().replace(" ", "-")}',
            'traffic_source': order['source_name'],
            'traffic_medium': order['utm_medium'] if order['utm_medium'] else '(none)',
            'user_first_touch_timestamp': int(customer['created_at'].timestamp() * 1000000),
            'device_category': 'web'
        }
        new_funnel_events.append(view_item_event)

# Append to existing data
if new_purchase_events:
    new_purchase_events_df = pd.DataFrame(new_purchase_events)
    updated_purchase_events_df = pd.concat([purchase_events_df, new_purchase_events_df], ignore_index=True)
    updated_purchase_events_df.to_csv('seeds/ga4/purchase_events_updated.csv', index=False)
    print(f"Created {len(new_purchase_events)} new purchase events")

if new_funnel_events:
    new_funnel_events_df = pd.DataFrame(new_funnel_events)
    updated_funnel_events_df = pd.concat([funnel_events_df, new_funnel_events_df], ignore_index=True)
    updated_funnel_events_df.to_csv('seeds/ga4/ecommerce_funnel_events_updated.csv', index=False)
    print(f"Created {len(new_funnel_events)} new funnel events")

print("\nGA4 events created successfully!")