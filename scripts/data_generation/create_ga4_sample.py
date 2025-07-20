#!/usr/bin/env python3
"""
GA4 Sample Dataset Creator v3
Creates a representative sample of approximately 10,000 GA4 events while maintaining
critical business relationships.
"""

import pandas as pd
import json
import numpy as np
from datetime import datetime

def create_ga4_sample():
    """Create a representative sample of the GA4 events dataset"""
    print("Creating GA4 Sample Dataset (Smart Sampling)")
    print("=" * 60)
    
    # Load the full dataset
    print("Loading full dataset...")
    df = pd.read_csv('/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/ga4/events.csv')
    print(f"Original dataset: {len(df):,} events")
    
    # Strategy: Sample purchase sessions + representative non-purchase sessions
    target_total = 10000
    
    # Step 1: Select a subset of purchase sessions (not all)
    print(f"\n1. Selecting subset of purchase sessions...")
    purchase_events = df[df['event_name'] == 'purchase'].copy()
    all_purchase_sessions = purchase_events['user_pseudo_id'].unique()
    
    # Calculate how many purchase sessions we can include
    # Assumption: Each purchase session has ~15 events on average
    avg_events_per_purchase_session = 15
    max_purchase_sessions = target_total // (avg_events_per_purchase_session * 2)  # Keep some budget for non-purchase
    
    selected_purchase_sessions = min(max_purchase_sessions, len(all_purchase_sessions))
    sampled_purchase_sessions = np.random.choice(all_purchase_sessions, 
                                               size=selected_purchase_sessions, 
                                               replace=False)
    
    print(f"Selected {selected_purchase_sessions:,} purchase sessions from {len(all_purchase_sessions):,} total")
    
    # Step 2: Get all events from selected purchase sessions
    print(f"2. Getting events from selected purchase sessions...")
    purchase_session_events = df[df['user_pseudo_id'].isin(sampled_purchase_sessions)].copy()
    print(f"Purchase session events: {len(purchase_session_events):,}")
    
    remaining_budget = target_total - len(purchase_session_events)
    print(f"Remaining budget: {remaining_budget:,} events")
    
    # Step 3: Sample from non-purchase sessions
    print(f"3. Sampling from non-purchase sessions...")
    non_purchase_events = df[~df['user_pseudo_id'].isin(all_purchase_sessions)].copy()
    
    if remaining_budget > 0 and len(non_purchase_events) > 0:
        # Sample proportionally by event type
        non_purchase_event_counts = non_purchase_events['event_name'].value_counts()
        
        sampled_non_purchase = []
        allocated_budget = 0
        
        for event_type, count in non_purchase_event_counts.items():
            if allocated_budget >= remaining_budget:
                break
                
            # Calculate proportional allocation
            proportion = count / len(non_purchase_events)
            allocated = max(1, int(remaining_budget * proportion))  # At least 1 of each type
            allocated = min(allocated, remaining_budget - allocated_budget)
            
            if allocated > 0:
                event_df = non_purchase_events[non_purchase_events['event_name'] == event_type]
                
                # Sample with user diversity
                if allocated < len(event_df):
                    unique_users = event_df['user_pseudo_id'].unique()
                    if len(unique_users) >= allocated:
                        # Sample different users
                        sample_users = np.random.choice(unique_users, size=allocated, replace=False)
                        # Get one event per selected user for this event type
                        sampled = event_df.groupby('user_pseudo_id').first().loc[sample_users].reset_index()
                    else:
                        # Random sample if not enough users
                        sampled = event_df.sample(n=allocated, random_state=42)
                else:
                    sampled = event_df
                
                sampled_non_purchase.append(sampled)
                allocated_budget += len(sampled)
                print(f"  {event_type}: {len(sampled):,} events")
        
        # Combine sampled non-purchase events
        if sampled_non_purchase:
            non_purchase_sample = pd.concat(sampled_non_purchase, ignore_index=True)
        else:
            non_purchase_sample = pd.DataFrame()
    else:
        non_purchase_sample = pd.DataFrame()
    
    # Step 4: Combine all events
    print(f"\n4. Combining final sample...")
    components = [purchase_session_events]
    if len(non_purchase_sample) > 0:
        components.append(non_purchase_sample)
    
    final_sample = pd.concat(components, ignore_index=True)
    
    # Sort by timestamp to maintain chronological order
    final_sample = final_sample.sort_values('event_timestamp').reset_index(drop=True)
    
    print(f"Final sample: {len(final_sample):,} events")
    
    # Step 5: Verify sample quality
    print(f"\n5. Sample Quality Verification:")
    sample_event_counts = final_sample['event_name'].value_counts()
    for event_name, count in sample_event_counts.items():
        percentage = (count / len(final_sample)) * 100
        print(f"  {event_name}: {count:,} ({percentage:.1f}%)")
    
    # Key validations
    purchase_count = sample_event_counts.get('purchase', 0)
    print(f"\n✓ Purchase events in sample: {purchase_count:,}")
    print(f"✓ Purchase sessions sampled: {selected_purchase_sessions:,} of {len(all_purchase_sessions):,}")
    
    unique_users = final_sample['user_pseudo_id'].nunique()
    registered_users = final_sample[final_sample['user_id'].notna()]
    print(f"✓ Unique users in sample: {unique_users:,}")
    print(f"✓ Events from registered users: {len(registered_users):,} ({len(registered_users)/len(final_sample)*100:.1f}%)")
    
    # Check conversion funnel integrity for sampled purchases
    funnel_events = ['session_start', 'page_view', 'view_item', 'add_to_cart', 
                    'begin_checkout', 'add_payment_info', 'add_shipping_info', 'purchase']
    print(f"✓ Event funnel in sample:")
    for event in funnel_events:
        count = sample_event_counts.get(event, 0)
        if count > 0:
            print(f"    {event}: {count:,}")
    
    # Check date range
    final_sample['event_date_parsed'] = pd.to_datetime(final_sample['event_date'], format='%Y%m%d')
    date_range = (final_sample['event_date_parsed'].max() - final_sample['event_date_parsed'].min()).days
    start_date = final_sample['event_date_parsed'].min().strftime('%Y-%m-%d')
    end_date = final_sample['event_date_parsed'].max().strftime('%Y-%m-%d')
    print(f"✓ Date range: {start_date} to {end_date} ({date_range} days)")
    
    # Step 6: Save the sample
    print(f"\n6. Saving sample dataset...")
    output_path = '/Users/markrittman/new/ra_warehouse_ecommerce_v2/ra_dw_ecommerce/seeds/ga4/events_sample.csv'
    final_sample.drop('event_date_parsed', axis=1).to_csv(output_path, index=False)
    
    # Check file size
    import os
    file_size_mb = os.path.getsize(output_path) / (1024 * 1024)
    print(f"✓ Sample saved to: {output_path}")
    print(f"✓ File size: {file_size_mb:.1f} MB")
    
    print(f"\n✅ GA4 sample dataset created successfully!")
    print(f"Original: 209,112 events (346 MB)")
    print(f"Sample: {len(final_sample):,} events ({file_size_mb:.1f} MB)")
    print(f"Event reduction: {(1 - len(final_sample)/209112)*100:.1f}%")
    print(f"Size reduction: {(1 - file_size_mb/346)*100:.1f}%")
    
    # Estimate dbt seed time improvement
    time_improvement = (346 - file_size_mb) / 346 * 100
    print(f"Estimated dbt seed time improvement: {time_improvement:.1f}%")

if __name__ == "__main__":
    # Set random seed for reproducibility
    np.random.seed(42)
    create_ga4_sample()