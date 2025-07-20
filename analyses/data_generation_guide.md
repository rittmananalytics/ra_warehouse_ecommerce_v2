# Data Generation Guide

This document explains how to regenerate the sample datasets for Belle & Glow Cosmetics.

## Overview

This dbt project includes comprehensive sample datasets for:
- **Shopify ecommerce data** (orders, customers, products, etc.)
- **Google Analytics 4 web analytics data** (events, sessions, user journeys)

## Scripts Location

All data generation scripts are located in:
```
scripts/data_generation/
├── generate_ga4_events.py      # Full GA4 dataset (209k events)
├── create_ga4_sample.py        # GA4 sample dataset (10k events) 
├── analyze_ga4_dataset.py      # GA4 data quality analysis
├── generate_orders.py          # Shopify orders generation
├── generate_order_lines*.py    # Shopify order lines generation
└── README.md                   # Detailed documentation
```

## Regenerating Data

### Prerequisites
```bash
# Activate dbt environment
source dbt-ecomm-env/bin/activate

# Install required Python packages
pip install pandas numpy faker
```

### Shopify Data
```bash
# Generate new orders (updates orders CSV)
python scripts/data_generation/generate_orders.py

# Generate corresponding order lines  
python scripts/data_generation/generate_order_lines_final.py

# Load into BigQuery
dbt seed --select shopify
```

### GA4 Data
```bash
# Generate full GA4 dataset (warning: large file)
python scripts/data_generation/generate_ga4_events.py

# Generate sample dataset (recommended for development)
python scripts/data_generation/create_ga4_sample.py

# Load sample into BigQuery
dbt seed --select events_sample

# Analyze data quality
python scripts/data_generation/analyze_ga4_dataset.py
```

## Data Relationships

The datasets are designed to work together:
- GA4 purchase events match Shopify orders exactly
- Customer emails align between systems
- Product IDs and prices are consistent
- Revenue totals match across platforms

## File Sizes

| Dataset | Events/Records | File Size | Load Time |
|---------|---------------|-----------|-----------|
| Shopify (all tables) | ~30k | ~2MB | ~30s |
| GA4 Full | 209k | 346MB | ~10min |
| GA4 Sample | 10k | 16MB | ~20s |

## Development vs Production

- **Development**: Use GA4 sample dataset for fast iterations
- **Production**: Switch to full GA4 dataset for complete analytics

## Customization

Scripts can be modified to:
- Change date ranges
- Adjust event volumes
- Modify customer demographics  
- Update product catalogs
- Alter conversion rates