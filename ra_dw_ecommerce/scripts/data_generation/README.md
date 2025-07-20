# Data Generation Scripts

This directory contains all Python scripts for generating sample datasets for the Belle & Glow Cosmetics data warehouse.

## Directory Structure

```
scripts/data_generation/
├── README.md                      # This file
├── generate_ga4_events.py         # Full GA4 dataset generator
├── create_ga4_sample.py           # GA4 sample dataset generator  
├── analyze_ga4_dataset.py         # GA4 data quality analyzer
├── generate_orders.py             # Shopify orders generator
├── generate_order_lines_final.py  # Shopify order lines generator
└── [legacy files]                 # Previous versions for reference
```

## Script Descriptions

### GA4 Scripts

**`generate_ga4_events.py`**
- Generates complete GA4 events dataset (209k events, 346MB)
- Creates realistic user journeys with proper event sequencing
- Includes all GA4 event types and ecommerce tracking
- Output: `seeds/ga4/events.csv`

**`create_ga4_sample.py`** 
- Creates smaller sample dataset (10k events, 16MB)
- Maintains data relationships and proportions
- Faster loading for development work
- Output: `seeds/ga4/events_sample.csv`

**`analyze_ga4_dataset.py`**
- Validates data quality and relationships
- Generates summary statistics
- Checks revenue consistency with Shopify data

### Shopify Scripts

**`generate_orders.py`**
- Creates realistic ecommerce orders with seasonal patterns
- Generates 8,996 orders over 36 months
- Includes proper growth curves and holiday spikes
- Output: `seeds/shopify/order.csv`

**`generate_order_lines_final.py`**
- Creates order line items matching the orders
- Ensures revenue consistency
- Realistic product combinations and quantities
- Output: `seeds/shopify/order_line.csv`

## Usage Patterns

### Development Workflow
```bash
# Quick iteration with sample data
python scripts/data_generation/create_ga4_sample.py
dbt seed --select events_sample
dbt run --select shopify
```

### Production Deployment
```bash
# Full dataset generation
python scripts/data_generation/generate_ga4_events.py
dbt seed --select events
dbt run --select shopify
```

### Data Validation
```bash
# Check data quality
python scripts/data_generation/analyze_ga4_dataset.py
```

## Script Standards

All scripts follow these conventions:
- **Configurable parameters** at the top of each file
- **Clear logging** of progress and completion
- **Error handling** for file operations
- **Consistent output formats** compatible with dbt seeds
- **Documentation** within each script

## Dependencies

Required Python packages:
```bash
pip install pandas numpy faker random datetime json
```

## Customization

Each script can be modified to:
- Adjust date ranges and volumes
- Change business parameters (conversion rates, AOV, etc.)
- Modify product catalogs and customer segments
- Update geographic and demographic distributions

## File Outputs

All scripts output CSV files to the appropriate seeds directories:
- `seeds/shopify/` - Shopify ecommerce data
- `seeds/ga4/` - Google Analytics 4 event data

## Best Practices

1. **Version Control**: Keep scripts in version control
2. **Documentation**: Update this README when adding new scripts
3. **Testing**: Run `analyze_ga4_dataset.py` after generation
4. **Backup**: Keep previous versions of generated data
5. **Consistency**: Ensure cross-platform data relationships are maintained