# GA4 Events Dataset

This directory contains Google Analytics 4 (GA4) events data for the ecommerce data warehouse.

## Files

### events_sample.csv
- **Size**: 16.2 MB (9,998 events)
- **Purpose**: Representative sample of GA4 events for development and testing
- **Content**: 
  - 333 complete purchase journeys (including all funnel events)
  - Proportional sampling of non-purchase sessions
  - Full date range maintained (July 2022 - July 2025)
  - All event types represented

### events.csv
- **Size**: 346 MB (209,112 events)  
- **Purpose**: Full GA4 events dataset
- **Content**: Complete dataset with 8,996 purchase events and full user journeys
- **Note**: Currently not used in dbt_project.yml due to size - use events_sample.csv instead

## Sample Dataset Details

The `events_sample.csv` was created using a smart sampling strategy that:

1. **Preserves Purchase Integrity**: Selected 333 complete purchase sessions (3.7% of all purchases) and included all their associated events
2. **Maintains Funnel Relationships**: Keeps all conversion funnel events (session_start → page_view → view_item → add_to_cart → begin_checkout → add_payment_info → add_shipping_info → purchase)
3. **Represents All Event Types**: Proportional sampling of non-purchase sessions to maintain realistic event distribution
4. **Preserves User Diversity**: Samples from different users to maintain demographic and behavioral diversity
5. **Maintains Time Range**: Full date range from July 19, 2022 to July 19, 2025

## Event Distribution in Sample

| Event Type | Count | Percentage |
|------------|-------|------------|
| page_view | 3,782 | 37.8% |
| view_item | 2,260 | 22.6% |
| session_start | 1,521 | 15.2% |
| add_to_cart | 1,103 | 11.0% |
| begin_checkout | 333 | 3.3% |
| add_shipping_info | 333 | 3.3% |
| add_payment_info | 333 | 3.3% |
| purchase | 333 | 3.3% |

## Usage in dbt

The sample dataset is configured in `dbt_project.yml` under `seeds.ra_dw_ecommerce.ga4.events_sample` with appropriate column type definitions.

To load the sample data:
```bash
dbt seed --select events_sample
```

## Performance Benefits

- **95.3% size reduction**: From 346 MB to 16.2 MB
- **95.2% event reduction**: From 209,112 to 9,998 events  
- **Faster dbt operations**: Seed time reduced from ~5-10 minutes to ~20 seconds
- **Development friendly**: Much faster iterations during model development

## Switching to Full Dataset

To use the full dataset in production:

1. Update `dbt_project.yml`:
   ```yaml
   seeds:
     ra_dw_ecommerce:
       ga4:
         events:  # Change from events_sample to events
           +column_types:
             # ... column definitions
   ```

2. Run the seed:
   ```bash
   dbt seed --select events
   ```

Note: The full dataset will take significantly longer to load and process.