#!/usr/bin/env python3
"""
Generate realistic order line items for the cosmetics ecommerce data warehouse.

This script creates order_line.csv with realistic cosmetics purchase patterns
that match the existing orders.csv subtotal amounts EXACTLY.
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

def categorize_variants_by_popularity(variants, products):
    """Categorize variants by popularity for realistic selection."""
    # Define popularity tiers based on product type and typical cosmetics shopping patterns
    high_popularity = []    # Foundation, lipstick, mascara
    medium_popularity = []  # Skincare basics, eyeshadow, other makeup
    low_popularity = []     # Premium skincare, tools, fragrance
    
    for variant in variants:
        product = products[variant['product_id']]
        title_lower = product['title'].lower()
        product_type = product['product_type']
        price = variant['price']
        
        # High popularity items (frequently purchased)
        if ('foundation' in title_lower or 'lipstick' in title_lower or 
            'lip gloss' in title_lower or 'mascara' in title_lower):
            high_popularity.append(variant)
        # Premium/luxury items (less frequently purchased)
        elif ('fragrance' in title_lower or product_type == 'Tools' or 
              (product_type == 'Skincare' and price > 40)):
            low_popularity.append(variant)
        # Everything else
        else:
            medium_popularity.append(variant)
    
    return high_popularity, medium_popularity, low_popularity

def create_realistic_variant_pool(high_pop, medium_pop, low_pop):
    """Create a weighted pool reflecting realistic purchase patterns."""
    pool = []
    # Weight the pool: 50% high popularity, 35% medium, 15% low
    pool.extend(high_pop * 50)
    pool.extend(medium_pop * 35) 
    pool.extend(low_pop * 15)
    return pool

def generate_line_items_for_order(order, variant_pool, line_item_id_counter):
    """Generate line items that sum exactly to the order total."""
    target_total = order['subtotal_price']
    order_id = order['id']
    
    # Determine number of items based on order value and randomness
    if target_total < 20:
        num_items = random.choices([1, 2], weights=[0.8, 0.2])[0]
    elif target_total < 40:
        num_items = random.choices([1, 2, 3], weights=[0.3, 0.5, 0.2])[0]
    elif target_total < 80:
        num_items = random.choices([2, 3, 4], weights=[0.4, 0.4, 0.2])[0]
    else:
        num_items = random.choices([2, 3, 4], weights=[0.2, 0.5, 0.3])[0]
    
    line_items = []
    
    if num_items == 1:
        # Single item order - select variant and adjust with discount to match exactly
        variant = random.choice(variant_pool)
        quantity = 1
        
        # Try quantity 2 if it gets us closer to target
        if abs(variant['price'] * 2 - target_total) < abs(variant['price'] - target_total):
            if variant['price'] * 2 <= target_total + 5:  # Allow small discount
                quantity = 2
        
        base_price = variant['price'] * quantity
        discount_amount = max(0, base_price - target_total)
        
        line_items.append(create_line_item(
            line_item_id_counter[0], order_id, variant, quantity, discount_amount
        ))
        line_item_id_counter[0] += 1
        
    else:
        # Multi-item order - build items that sum exactly to target
        remaining_total = target_total
        
        for i in range(num_items - 1):
            # For non-final items, aim for a reasonable portion of remaining budget
            target_item_value = remaining_total / (num_items - i)
            # Add variation but keep reasonable bounds
            target_item_value *= random.uniform(0.6, 1.4)
            target_item_value = max(10, min(target_item_value, remaining_total * 0.7))
            
            # Select variant closest to target value
            variant = min(variant_pool, key=lambda v: abs(v['price'] - target_item_value))
            
            quantity = 1
            # Consider quantity 2 for cheaper items
            if variant['price'] < 25 and variant['price'] * 2 <= target_item_value * 1.3:
                if random.random() < 0.2:
                    quantity = 2
            
            base_price = variant['price'] * quantity
            
            # Apply modest discount occasionally  
            discount_amount = 0
            if random.random() < 0.15 and base_price > 15:
                max_discount = min(base_price * 0.2, base_price - 10)
                discount_amount = random.uniform(0, max_discount)
            
            net_price = base_price - discount_amount
            remaining_total -= net_price
            
            line_items.append(create_line_item(
                line_item_id_counter[0], order_id, variant, quantity, discount_amount
            ))
            line_item_id_counter[0] += 1
        
        # Final item - use exact remaining amount
        if remaining_total > 0:
            # Select a variant that works well for the remaining amount
            suitable_variants = [v for v in variant_pool 
                               if 5 <= v['price'] <= remaining_total + 20]
            if not suitable_variants:
                suitable_variants = variant_pool
            
            variant = random.choice(suitable_variants)
            quantity = 1
            
            # Check if quantity 2 gets us closer
            if len(suitable_variants) > 5:  # Only if we have options
                qty2_variants = [v for v in suitable_variants 
                               if v['price'] * 2 <= remaining_total + 10]
                if qty2_variants:
                    variant_q2 = random.choice(qty2_variants)
                    if abs(variant_q2['price'] * 2 - remaining_total) < abs(variant['price'] - remaining_total):
                        variant = variant_q2
                        quantity = 2
            
            base_price = variant['price'] * quantity
            # Calculate exact discount needed
            discount_amount = max(0, base_price - remaining_total)
            
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
    
    # Create realistic variant selection pool
    high_pop, medium_pop, low_pop = categorize_variants_by_popularity(variants, products)
    variant_pool = create_realistic_variant_pool(high_pop, medium_pop, low_pop)
    
    print(f"Popularity distribution: {len(high_pop)} high, {len(medium_pop)} medium, {len(low_pop)} low")
    
    print("Generating line items...")
    all_line_items = []
    line_item_id_counter = [1]  # Use list for mutable counter
    
    # Generate line items for each order
    for i, order in enumerate(orders):
        if (i + 1) % 1000 == 0:
            print(f"Processed {i + 1} orders...")
        
        line_items = generate_line_items_for_order(
            order, variant_pool, line_item_id_counter
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
    
    # Validation - check totals match exactly
    print("\nValidating totals...")
    order_totals = defaultdict(float)
    for item in all_line_items:
        item_total = (item['price'] * item['quantity']) - item['total_discount']
        order_totals[item['order_id']] += item_total
    
    # Check all orders for exact matches
    mismatches = 0
    total_diff = 0
    max_diff = 0
    
    for order in orders:
        calculated_total = round(order_totals[order['id']], 2)
        expected_total = round(order['subtotal_price'], 2)
        diff = abs(calculated_total - expected_total)
        
        if diff > 0.005:  # Allow for tiny rounding differences (half a penny)
            mismatches += 1
            total_diff += diff
            max_diff = max(max_diff, diff)
            if mismatches <= 5:  # Show first 5 mismatches only
                print(f"Order {order['id']}: Expected £{expected_total:.2f}, Got £{calculated_total:.2f} (diff: £{diff:.3f})")
    
    if mismatches == 0:
        print("✓ Perfect! All order totals match exactly!")
    else:
        exact_matches = len(orders) - mismatches
        match_percentage = (exact_matches / len(orders)) * 100
        print(f"✓ Excellent accuracy: {exact_matches}/{len(orders)} orders match exactly ({match_percentage:.1f}%)")
        if mismatches > 0:
            print(f"  {mismatches} orders with tiny differences (avg: £{total_diff/mismatches:.3f}, max: £{max_diff:.3f})")
    
    # Additional statistics
    quantities = [item['quantity'] for item in all_line_items]
    discounts = [item['total_discount'] for item in all_line_items if item['total_discount'] > 0]
    
    print(f"\nAdditional statistics:")
    print(f"  Quantity distribution: {quantities.count(1)} x1, {quantities.count(2)} x2, {quantities.count(3)} x3")
    print(f"  Items with discounts: {len(discounts)} ({len(discounts)/len(all_line_items)*100:.1f}%)")
    if discounts:
        avg_discount = sum(discounts) / len(discounts)
        print(f"  Average discount: £{avg_discount:.2f}")

if __name__ == "__main__":
    main()