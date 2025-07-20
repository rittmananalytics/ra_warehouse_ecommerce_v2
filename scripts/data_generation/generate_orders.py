#!/usr/bin/env python3
"""
Generate realistic orders CSV dataset for Belle & Glow Cosmetics
Requirements:
- 36 months of data (July 19, 2022 to July 19, 2025)
- ~10,000 orders total
- 50 customers (IDs 1-50)
- 4 locations (with location 4 being online warehouse - 80% of orders)
- Seasonal patterns with growth over time
- Realistic pricing with 20% VAT
"""

import csv
import random
from datetime import datetime, timedelta
import math

# Customer emails from customer.csv
CUSTOMER_EMAILS = {
    1: "emma.thompson@gmail.com",
    2: "sophie.williams@hotmail.co.uk", 
    3: "charlotte.brown@outlook.com",
    4: "olivia.johnson@yahoo.co.uk",
    5: "amelia.jones@gmail.com",
    6: "isabella.miller@btinternet.com",
    7: "lily.davis@gmail.com",
    8: "grace.wilson@hotmail.co.uk",
    9: "ella.moore@outlook.com",
    10: "scarlett.taylor@gmail.com",
    11: "chloe.anderson@yahoo.co.uk",
    12: "mia.thomas@gmail.com",
    13: "ruby.jackson@hotmail.co.uk",
    14: "poppy.white@outlook.com",
    15: "freya.harris@gmail.com",
    16: "hannah.martin@btinternet.com",
    17: "evie.thompson@gmail.com",
    18: "aria.garcia@yahoo.co.uk",
    19: "ivy.martinez@hotmail.co.uk",
    20: "zoe.robinson@outlook.com",
    21: "maya.clark@gmail.com",
    22: "willow.rodriguez@btinternet.com",
    23: "phoebe.lewis@gmail.com",
    24: "violet.lee@yahoo.co.uk",
    25: "daisy.walker@hotmail.co.uk",
    26: "luna.hall@outlook.com",
    27: "rose.allen@gmail.com",
    28: "iris.young@btinternet.com",
    29: "jasmine.hernandez@gmail.com",
    30: "penelope.king@yahoo.co.uk",
    31: "aurora.wright@hotmail.co.uk",
    32: "nova.lopez@outlook.com",
    33: "hazel.hill@gmail.com",
    34: "alice.scott@btinternet.com",
    35: "eden.green@gmail.com",
    36: "matilda.adams@yahoo.co.uk",
    37: "lola.baker@hotmail.co.uk",
    38: "esme.gonzalez@outlook.com",
    39: "imogen.nelson@gmail.com",
    40: "florence.carter@btinternet.com",
    41: "arabella.mitchell@gmail.com",
    42: "bonnie.perez@yahoo.co.uk",
    43: "delilah.roberts@hotmail.co.uk",
    44: "robyn.turner@outlook.com",
    45: "lottie.phillips@gmail.com",
    46: "martha.campbell@btinternet.com",
    47: "amelie.parker@gmail.com",
    48: "orla.evans@yahoo.co.uk",
    49: "holly.edwards@hotmail.co.uk",
    50: "margot.collins@outlook.com"
}

def get_seasonal_multiplier(date):
    """Calculate seasonal multiplier based on date"""
    month = date.month
    day = date.day
    
    # Black Friday (last Friday of November) - 4x multiplier
    if month == 11 and day >= 22 and day <= 28 and date.weekday() == 4:  # Friday
        return 4.0
    
    # Christmas season (December) - 2.5x multiplier
    if month == 12:
        return 2.5
    
    # Valentine's Day period (Feb 10-16) - 2x multiplier
    if month == 2 and 10 <= day <= 16:
        return 2.0
    
    # Mother's Day (2nd Sunday of May in UK) - 1.8x multiplier  
    if month == 5 and 8 <= day <= 14 and date.weekday() == 6:  # Sunday
        return 1.8
    
    # General holiday seasons
    if month in [11, 12, 2, 5]:  # Nov, Dec, Feb, May
        return 1.3
    
    # Summer months (June-August) - slight increase
    if month in [6, 7, 8]:
        return 1.1
    
    return 1.0

def get_monthly_base_orders(date):
    """Calculate base number of orders per month based on business growth"""
    start_date = datetime(2022, 7, 19)
    months_since_start = (date.year - start_date.year) * 12 + (date.month - start_date.month)
    
    # Growth curve: start slow, accelerate in 2024-2025 
    # Adjusted to reach ~10,000 total orders over 36 months
    if months_since_start < 6:  # Jul-Dec 2022
        return random.randint(40, 55)
    elif months_since_start < 18:  # 2023
        return random.randint(60, 95) 
    elif months_since_start < 30:  # 2024
        return random.randint(200, 300)
    else:  # 2025
        return random.randint(400, 540)

def generate_order_price():
    """Generate realistic order price (subtotal before tax)"""
    # Use weighted distribution for more realistic pricing
    price_ranges = [
        (15, 30, 0.3),    # Budget range - 30% 
        (30, 50, 0.4),    # Mid range - 40%
        (50, 80, 0.2),    # Higher range - 20%
        (80, 150, 0.1)    # Premium range - 10%
    ]
    
    rand = random.random()
    cumulative = 0
    
    for min_price, max_price, weight in price_ranges:
        cumulative += weight
        if rand <= cumulative:
            return round(random.uniform(min_price, max_price), 2)
    
    return round(random.uniform(15, 150), 2)

def get_financial_status():
    """Generate financial status with realistic distribution"""
    rand = random.random()
    if rand < 0.85:
        return "paid"
    elif rand < 0.95:
        return "pending"
    else:
        return "refunded"

def get_fulfillment_status():
    """Generate fulfillment status with realistic distribution"""
    rand = random.random()
    if rand < 0.80:
        return "fulfilled"
    elif rand < 0.90:
        return "partial"
    else:
        return "pending"

def get_location_id():
    """Generate location ID with 80% online, 20% in-store distribution"""
    if random.random() < 0.8:
        return 4  # Online warehouse
    else:
        return random.randint(1, 3)  # Physical stores

def generate_orders():
    """Generate the complete orders dataset"""
    orders = []
    order_id = 1
    
    # Generate orders from July 19, 2022 to July 19, 2025
    start_date = datetime(2022, 7, 19)
    end_date = datetime(2025, 7, 19)
    
    current_date = start_date
    
    while current_date <= end_date:
        # Get base orders for this month
        base_monthly_orders = get_monthly_base_orders(current_date)
        
        # Apply seasonal multiplier
        seasonal_mult = get_seasonal_multiplier(current_date)
        daily_orders = int((base_monthly_orders * seasonal_mult) / 30)
        
        # Add some randomness to daily orders
        daily_orders = max(1, daily_orders + random.randint(-2, 3))
        
        # Generate orders for this day
        for _ in range(daily_orders):
            customer_id = random.randint(1, 50)
            email = CUSTOMER_EMAILS[customer_id]
            
            # Create order timestamp (business hours: 8 AM - 8 PM)
            hour = random.randint(8, 20)
            minute = random.randint(0, 59)
            second = random.randint(0, 59)
            
            created_at = current_date.replace(hour=hour, minute=minute, second=second)
            
            # Processed at: 30 minutes to 4 hours after creation
            processing_delay = timedelta(minutes=random.randint(30, 240))
            processed_at = created_at + processing_delay
            
            # Generate pricing
            subtotal_price = generate_order_price()
            total_tax = round(subtotal_price * 0.2, 2)  # 20% VAT
            total_price = round(subtotal_price + total_tax, 2)
            
            # Generate statuses
            financial_status = get_financial_status()
            fulfillment_status = get_fulfillment_status()
            location_id = get_location_id()
            
            order = {
                'id': order_id,
                'customer_id': customer_id,
                'email': email,
                'created_at': created_at.strftime('%Y-%m-%d %H:%M:%S'),
                'processed_at': processed_at.strftime('%Y-%m-%d %H:%M:%S'),
                'currency': 'GBP',
                'total_price': total_price,
                'subtotal_price': subtotal_price,
                'total_tax': total_tax,
                'financial_status': financial_status,
                'fulfillment_status': fulfillment_status,
                'location_id': location_id,
                '_fivetran_synced': '2025-07-19 10:00:00'
            }
            
            orders.append(order)
            order_id += 1
            
            # Stop if we've reached our target of ~10,000 orders
            if len(orders) >= 10000:
                break
        
        if len(orders) >= 10000:
            break
            
        # Move to next day
        current_date += timedelta(days=1)
    
    return orders

def save_orders_csv(orders, filename='seeds/orders.csv'):
    """Save orders to CSV file"""
    fieldnames = [
        'id', 'customer_id', 'email', 'created_at', 'processed_at', 'currency',
        'total_price', 'subtotal_price', 'total_tax', 'financial_status',
        'fulfillment_status', 'location_id', '_fivetran_synced'
    ]
    
    with open(filename, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(orders)
    
    print(f"Generated {len(orders)} orders and saved to {filename}")
    
    # Print some statistics
    total_revenue = sum(order['total_price'] for order in orders)
    avg_order_value = total_revenue / len(orders)
    online_orders = sum(1 for order in orders if order['location_id'] == 4)
    online_percentage = (online_orders / len(orders)) * 100
    
    print(f"Total Revenue: £{total_revenue:,.2f}")
    print(f"Average Order Value: £{avg_order_value:.2f}")
    print(f"Online Orders: {online_percentage:.1f}%")
    
    # Monthly breakdown
    monthly_counts = {}
    for order in orders:
        month_key = order['created_at'][:7]  # YYYY-MM
        monthly_counts[month_key] = monthly_counts.get(month_key, 0) + 1
    
    print("\nMonthly Order Counts:")
    for month in sorted(monthly_counts.keys()):
        print(f"{month}: {monthly_counts[month]} orders")

if __name__ == "__main__":
    print("Generating orders dataset for Belle & Glow Cosmetics...")
    orders = generate_orders()
    save_orders_csv(orders)
    print("Orders dataset generation complete!")