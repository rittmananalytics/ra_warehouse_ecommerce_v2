#!/usr/bin/env python3
"""
GA4 Dataset Analysis Script
Provides summary statistics and data quality checks for the generated GA4 events dataset.
"""

import pandas as pd
import json
from datetime import datetime
import numpy as np

def analyze_ga4_dataset():
    """Analyze the generated GA4 events dataset"""
    print("GA4 Dataset Analysis")
    print("=" * 50)
    
    # Load the dataset
    df = pd.read_csv('/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/ga4/events.csv')
    
    print(f"Dataset Overview:")
    print(f"  Total events: {len(df):,}")
    print(f"  File size: 346 MB")
    print(f"  Columns: {len(df.columns)}")
    print()
    
    # Event breakdown
    print("Event Type Distribution:")
    event_counts = df['event_name'].value_counts()
    for event_name, count in event_counts.items():
        percentage = (count / len(df)) * 100
        print(f"  {event_name}: {count:,} ({percentage:.1f}%)")
    print()
    
    # Date range analysis
    df['event_date'] = pd.to_datetime(df['event_date'], format='%Y%m%d')
    print("Date Range Analysis:")
    print(f"  Start date: {df['event_date'].min().strftime('%Y-%m-%d')}")
    print(f"  End date: {df['event_date'].max().strftime('%Y-%m-%d')}")
    print(f"  Total days: {(df['event_date'].max() - df['event_date'].min()).days}")
    print()
    
    # User analysis
    print("User Analysis:")
    unique_pseudo_ids = df['user_pseudo_id'].nunique()
    print(f"  Unique user_pseudo_ids: {unique_pseudo_ids:,}")
    
    registered_users = df[df['user_id'].notna()]
    print(f"  Events from registered users: {len(registered_users):,} ({len(registered_users)/len(df)*100:.1f}%)")
    print(f"  Unique registered users: {registered_users['user_id'].nunique()}")
    print()
    
    # Session analysis
    session_starts = df[df['event_name'] == 'session_start']
    print("Session Analysis:")
    print(f"  Total sessions: {len(session_starts):,}")
    print(f"  Sessions with purchases: {df['event_name'].value_counts().get('purchase', 0):,}")
    conversion_rate = (df['event_name'].value_counts().get('purchase', 0) / len(session_starts)) * 100
    print(f"  Conversion rate: {conversion_rate:.2f}%")
    print()
    
    # Device analysis
    print("Device Analysis:")
    sample_device_info = df[df['device'].notna()].sample(1000)['device'].apply(json.loads)
    device_categories = [device.get('category', 'unknown') for device in sample_device_info]
    device_dist = pd.Series(device_categories).value_counts()
    for category, count in device_dist.items():
        percentage = (count / len(device_categories)) * 100
        print(f"  {category}: {percentage:.1f}%")
    print()
    
    # Traffic source analysis
    print("Traffic Source Analysis:")
    sample_traffic = df[df['traffic_source'].notna()].sample(1000)['traffic_source'].apply(json.loads)
    traffic_mediums = [traffic.get('medium', 'unknown') for traffic in sample_traffic]
    traffic_dist = pd.Series(traffic_mediums).value_counts()
    for medium, count in traffic_dist.items():
        percentage = (count / len(traffic_mediums)) * 100
        print(f"  {medium}: {percentage:.1f}%")
    print()
    
    # Revenue analysis
    purchase_events = df[df['event_name'] == 'purchase']
    if len(purchase_events) > 0:
        revenue_values = purchase_events['event_value_in_usd'].dropna().astype(float)
        print("Revenue Analysis:")
        print(f"  Total transactions: {len(purchase_events):,}")
        print(f"  Total revenue: £{revenue_values.sum():,.2f}")
        print(f"  Average order value: £{revenue_values.mean():.2f}")
        print(f"  Median order value: £{revenue_values.median():.2f}")
        print()
    
    # Geographic analysis
    print("Geographic Analysis:")
    sample_geo = df[df['geo'].notna()].sample(1000)['geo'].apply(json.loads)
    geo_cities = [geo.get('city', 'unknown') for geo in sample_geo]
    geo_dist = pd.Series(geo_cities).value_counts().head(5)
    for city, count in geo_dist.items():
        percentage = (count / len(geo_cities)) * 100
        print(f"  {city}: {percentage:.1f}%")
    print()
    
    # Ecommerce items analysis
    ecommerce_events = df[df['items'] != '[]']
    if len(ecommerce_events) > 0:
        print("Ecommerce Analysis:")
        print(f"  Events with items: {len(ecommerce_events):,}")
        
        # Sample items analysis
        sample_items = ecommerce_events.sample(min(100, len(ecommerce_events)))['items'].apply(json.loads)
        total_items = sum(len(items) for items in sample_items)
        print(f"  Average items per event: {total_items / len(sample_items):.1f}")
        print()
    
    # Data quality checks
    print("Data Quality Checks:")
    print(f"  Events with missing user_pseudo_id: {df['user_pseudo_id'].isna().sum()}")
    print(f"  Events with missing event_timestamp: {df['event_timestamp'].isna().sum()}")
    print(f"  Events with invalid JSON in device field: {count_invalid_json(df, 'device')}")
    print(f"  Events with invalid JSON in traffic_source field: {count_invalid_json(df, 'traffic_source')}")
    print()
    
    print("✅ Dataset analysis complete!")
    print("\nNext steps:")
    print("1. Run: dbt seed --select ga4.events")
    print("2. Create GA4 staging models in dbt")
    print("3. Build marts joining Shopify and GA4 data")

def count_invalid_json(df, column):
    """Count rows with invalid JSON in a column"""
    invalid_count = 0
    sample_size = min(1000, len(df))
    sample_df = df.sample(sample_size)
    
    for value in sample_df[column].dropna():
        try:
            json.loads(value)
        except (json.JSONDecodeError, TypeError):
            invalid_count += 1
    
    # Scale up the count
    return int(invalid_count * (len(df) / sample_size))

if __name__ == "__main__":
    analyze_ga4_dataset()