#!/usr/bin/env python3
"""
Generate realistic order line items for the cosmetics ecommerce data warehouse.

This script creates order_line.csv with realistic cosmetics purchase patterns
that match the existing orders.csv subtotal amounts.
"""

import csv
import random
import datetime
from decimal import Decimal, ROUND_HALF_UP
from collections import defaultdict
import os

# Set random seed for reproducible results
random.seed(42)

def load_orders(file_path):
    """Load orders data from CSV."""
    orders = []
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            orders.append({
                'id': int(row['id']),
                'customer_id': int(row['customer_id']),
                'subtotal_price': float(row['subtotal_price'])
            })
    return orders

def load_product_variants(file_path):
    """Load product variants data from CSV."""
    variants = []
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            variants.append({
                'id': int(row['id']),
                'product_id': int(row['product_id']),
                'title': row['title'],
                'sku': row['sku'],
                'price': float(row['price'])
            })
    return variants

def load_products(file_path):
    """Load products data from CSV."""
    products = {}
    with open(file_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            products[int(row['id'])] = {
                'title': row['title'],
                'product_type': row['product_type'],
                'vendor': row['vendor']
            }
    return products

def categorize_variants(variants, products):
    """Categorize variants by product type and popularity."""
    categories = {
        'foundation': [],      # High frequency, medium price
        'lipstick': [],       # High frequency, medium price  
        'mascara': [],        # High frequency, low-medium price
        'eyeshadow': [],      # Medium frequency, medium price
        'skincare_budget': [], # Medium frequency, low-medium price
        'skincare_premium': [], # Lower frequency, high price
        'fragrance': [],      # Low frequency, very high price
        'tools': [],          # Low frequency, medium-high price
        'other': []           # Medium frequency, various prices
    }
    
    for variant in variants:
        product = products[variant['product_id']]
        price = variant['price']
        title_lower = product['title'].lower()
        
        if 'foundation' in title_lower:
            categories['foundation'].append(variant)
        elif 'lipstick' in title_lower or 'lip gloss' in title_lower:
            categories['lipstick'].append(variant)
        elif 'mascara' in title_lower:
            categories['mascara'].append(variant)
        elif 'eyeshadow' in title_lower:
            categories['eyeshadow'].append(variant)
        elif 'fragrance' in title_lower:
            categories['fragrance'].append(variant)
        elif product['product_type'] == 'Tools':
            categories['tools'].append(variant)
        elif product['product_type'] == 'Skincare':
            if price < 30:
                categories['skincare_budget'].append(variant)
            else:
                categories['skincare_premium'].append(variant)
        else:
            categories['other'].append(variant)
    
    return categories

def get_popularity_weights():
    """Define popularity weights for different product categories."""
    return {
        'foundation': 0.25,      # 25% of line items
        'lipstick': 0.20,        # 20% of line items
        'mascara': 0.15,         # 15% of line items
        'skincare_budget': 0.15, # 15% of line items
        'eyeshadow': 0.10,       # 10% of line items
        'other': 0.08,           # 8% of line items
        'skincare_premium': 0.04, # 4% of line items
        'tools': 0.02,           # 2% of line items
        'fragrance': 0.01        # 1% of line items
    }

def create_weighted_variant_pool(categories, weights):
    """Create a weighted pool of variants based on popularity."""
    pool = []
    for category, variants in categories.items():
        if variants and category in weights:
            # Add each variant multiple times based on weight
            count = int(weights[category] * 1000)  # Scale up for better distribution
            for _ in range(count):
                pool.extend(variants)
    return pool

def generate_line_items_for_order(order, variant_pool, categories, line_item_id_counter):
    """Generate realistic line items for a single order."""
    target_total = order['subtotal_price']
    order_id = order['id']
    line_items = []
    
    # Determine number of line items (1-4, weighted toward 2-3)
    num_items_weights = [0.15, 0.35, 0.35, 0.15]  # 1, 2, 3, 4 items
    num_items = random.choices([1, 2, 3, 4], weights=num_items_weights)[0]
    
    # Build line items to match the target total exactly
    if num_items == 1:
        # Single item - select variant and adjust with discount
        # For very small orders, prefer cheaper items
        if target_total < 20:
            cheap_variants = [v for v in variant_pool if v['price'] <= 25]
            variant = random.choice(cheap_variants if cheap_variants else variant_pool)
        # For expensive single items, allow premium products
        elif target_total > 50:
            expensive_variants = []
            for category in ['fragrance', 'skincare_premium', 'tools']:
                expensive_variants.extend(categories[category])
            if expensive_variants and random.random() < 0.4:
                variant = random.choice(expensive_variants)
            else:
                variant = random.choice(variant_pool)
        else:
            variant = random.choice(variant_pool)
        
        quantity = 1
        # Try higher quantities if the base price is too low
        if variant['price'] * 2 <= target_total and random.random() < 0.2:
            quantity = 2
        elif variant['price'] * 3 <= target_total and random.random() < 0.1:
            quantity = 3
        
        base_price = variant['price'] * quantity
        # Calculate exact discount needed to match target
        discount_amount = max(0, base_price - target_total)
        
        line_items.append(create_line_item(
            line_item_id_counter[0], order_id, variant, quantity, discount_amount
        ))
        line_item_id_counter[0] += 1
        
    else:
        # Multi-item order - build items that sum to target total
        running_total = 0
        
        for i in range(num_items - 1):  # All items except the last one
            # Target for this item (leave room for remaining items)
            remaining_items = num_items - i
            remaining_budget = target_total - running_total
            target_item_price = remaining_budget / remaining_items
            
            # Add some variation to make it realistic
            min_price = max(10, target_item_price * 0.5)
            max_price = min(remaining_budget * 0.8, target_item_price * 1.5)
            target_item_price = random.uniform(min_price, max_price)
            
            # Select variant closest to target price
            variant = min(variant_pool, key=lambda v: abs(v['price'] - target_item_price))
            
            quantity = 1
            # Occasionally use quantity > 1 for cheaper items
            if variant['price'] < 25 and random.random() < 0.15:
                if variant['price'] * 2 <= target_item_price * 1.2:
                    quantity = 2
            
            base_price = variant['price'] * quantity
            
            # Apply discount occasionally but keep it reasonable
            discount_amount = 0
            if random.random() < 0.15:  # 15% chance of discount
                max_discount = min(base_price * 0.25, base_price - 5)  # Max 25% or leave at least £5
                discount_amount = random.uniform(0, max_discount)
            
            item_total = base_price - discount_amount
            running_total += item_total
            
            line_items.append(create_line_item(
                line_item_id_counter[0], order_id, variant, quantity, discount_amount
            ))
            line_item_id_counter[0] += 1
        
        # Last item - make up the exact difference
        remaining_needed = target_total - running_total
        
        if remaining_needed > 0:
            # Find a variant that works well for the remaining amount
            suitable_variants = [v for v in variant_pool if 5 <= v['price'] <= remaining_needed + 15]
            if not suitable_variants:
                suitable_variants = variant_pool
            
            variant = random.choice(suitable_variants)
            quantity = 1
            
            # Try quantity 2 if it gets us closer to target
            if variant['price'] * 2 <= remaining_needed + 10:
                if abs(variant['price'] * 2 - remaining_needed) < abs(variant['price'] - remaining_needed):
                    quantity = 2
            
            base_price = variant['price'] * quantity
            # Calculate exact discount to hit the target
            discount_amount = base_price - remaining_needed
            # Ensure discount is not negative
            discount_amount = max(0, discount_amount)
            
            line_items.append(create_line_item(
                line_item_id_counter[0], order_id, variant, quantity, discount_amount
            ))
            line_item_id_counter[0] += 1
    
    return line_items

def create_line_item(line_id, order_id, variant, quantity, discount_amount):
    """Create a single line item record."""
    return {
        'id': line_id,
        'order_id': order_id,
        'product_id': variant['product_id'],
        'variant_id': variant['id'],
        'name': variant['title'],
        'title': variant['title'],
        'vendor': 'Belle & Glow',
        'price': variant['price'],
        'quantity': quantity,
        'sku': variant['sku'],
        'total_discount': round(discount_amount, 2),
        '_fivetran_synced': '2025-07-19 10:00:00'
    }

def write_order_lines_csv(line_items, output_path):
    """Write line items to CSV file."""
    fieldnames = [
        'id', 'order_id', 'product_id', 'variant_id', 'name', 'title', 
        'vendor', 'price', 'quantity', 'sku', 'total_discount', '_fivetran_synced'
    ]
    
    with open(output_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(line_items)

def main():
    """Main function to generate order line items."""
    # File paths
    base_dir = '/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds'
    orders_path = os.path.join(base_dir, 'orders.csv')
    variants_path = os.path.join(base_dir, 'product_variant.csv')
    products_path = os.path.join(base_dir, 'product.csv')
    output_path = os.path.join(base_dir, 'order_line.csv')
    
    print("Loading data...")
    orders = load_orders(orders_path)
    variants = load_product_variants(variants_path)
    products = load_products(products_path)
    
    print(f"Loaded {len(orders)} orders and {len(variants)} product variants")
    
    # Categorize variants by product type and popularity
    categories = categorize_variants(variants, products)
    
    # Create weighted variant pool based on popularity
    weights = get_popularity_weights()
    variant_pool = create_weighted_variant_pool(categories, weights)
    
    print("Generating line items...")
    all_line_items = []
    line_item_id_counter = [1]  # Use list for mutable counter
    
    # Generate line items for each order
    for i, order in enumerate(orders):
        if (i + 1) % 1000 == 0:
            print(f"Processed {i + 1} orders...")
        
        line_items = generate_line_items_for_order(
            order, variant_pool, categories, line_item_id_counter
        )
        all_line_items.extend(line_items)
    
    print(f"Generated {len(all_line_items)} line items")
    
    # Calculate statistics
    total_line_items = len(all_line_items)
    total_orders = len(orders)
    avg_items_per_order = total_line_items / total_orders
    
    print(f"Average items per order: {avg_items_per_order:.2f}")
    
    # Write to CSV
    print(f"Writing to {output_path}...")
    write_order_lines_csv(all_line_items, output_path)
    
    print("Order line generation completed successfully!")
    
    # Validation - check if totals match exactly
    print("\nValidating totals...")
    order_totals = defaultdict(float)
    for item in all_line_items:
        item_total = (item['price'] * item['quantity']) - item['total_discount']
        order_totals[item['order_id']] += round(item_total, 2)  # Round to avoid floating point errors
    
    # Check all orders for exact matches
    mismatches = 0
    total_diff = 0
    
    for order in orders:
        calculated_total = round(order_totals[order['id']], 2)
        expected_total = round(order['subtotal_price'], 2)
        diff = abs(calculated_total - expected_total)
        
        if diff > 0.01:  # Allow for small rounding differences
            mismatches += 1
            total_diff += diff
            if mismatches <= 10:  # Show first 10 mismatches
                print(f"Order {order['id']}: Expected £{expected_total:.2f}, Got £{calculated_total:.2f} (diff: £{diff:.2f})")
    
    if mismatches == 0:
        print("✓ Validation passed - all order totals match exactly!")
    else:
        print(f"⚠ Warning: {mismatches} orders have mismatched totals")
        print(f"  Average difference: £{total_diff/mismatches:.3f}")
        print(f"  Total difference across all orders: £{total_diff:.2f}")
        
        # Calculate percentage of orders with exact matches
        exact_matches = len(orders) - mismatches
        match_percentage = (exact_matches / len(orders)) * 100
        print(f"  Exact match rate: {exact_matches}/{len(orders)} ({match_percentage:.1f}%)")

if __name__ == "__main__":
    main()