# Warehouse Layer Entity Relationship Diagram

This diagram shows all warehouse layer tables from the `analytics_ecommerce_ecommerce` BigQuery dataset with their primary key/foreign key relationships in the dimensional model.

```mermaid
erDiagram
    %% Dimension Tables
    dim_date {
        string date_key PK "Date key YYYYMMDD"
        date calendar_date "Calendar date"
        integer year "Year YYYY"
        integer quarter "Quarter 1-4"
        integer month "Month 1-12"
        integer week "Week of year 1-53"
        integer day_of_year "Day of year 1-366"
        integer day_of_month "Day of month 1-31"
        integer day_of_week "Day of week 1-7"
        string day_name "Day name"
        string month_name "Month name"
        string quarter_name "Quarter name"
        boolean is_weekend "Weekend indicator"
        boolean is_holiday "Holiday indicator"
        string holiday_name "Holiday name"
        integer fiscal_year "Fiscal year"
        integer fiscal_quarter "Fiscal quarter"
        integer fiscal_month "Fiscal month"
        boolean is_last_day_of_month "Last day of month"
        boolean is_last_day_of_quarter "Last day of quarter"
        boolean is_last_day_of_year "Last day of year"
    }

    dim_customers {
        integer customer_key PK "Surrogate customer key"
        integer customer_id "Business key from Shopify"
        string customer_email "Email address"
        string first_name "First name"
        string last_name "Last name"
        string full_name "Full name"
        integer phone "Phone number"
        timestamp customer_created_at "Creation timestamp"
        timestamp customer_updated_at "Update timestamp"
        string accepts_marketing "Marketing consent"
        numeric shopify_lifetime_value "Shopify LTV"
        integer shopify_order_count "Shopify orders"
        float calculated_lifetime_value "Calculated LTV"
        integer calculated_order_count "Calculated orders"
        float avg_order_value "Average order value"
        timestamp first_order_date "First order date"
        timestamp last_order_date "Last order date"
        integer days_since_first_order "Days since first"
        integer days_since_last_order "Days since last"
        string customer_segment "RFM segment"
        string customer_lifecycle_stage "Lifecycle stage"
        string customer_value_tier "Value tier"
        string recency_segment "Recency segment"
        string aov_segment "AOV segment"
        string region "Region"
        boolean has_email "Has email"
        boolean has_phone "Has phone"
        boolean has_address "Has address"
        boolean has_full_name "Has full name"
        timestamp effective_from "SCD valid from"
        timestamp effective_to "SCD valid to"
        boolean is_current "SCD current record"
        timestamp warehouse_updated_at "Warehouse update"
    }

    dim_products {
        string product_key PK "Surrogate product key"
        bigint product_id "Business key from Shopify"
        string product_title "Product title"
        string product_handle "URL handle"
        string product_type "Product category"
        string vendor "Product vendor"
        string product_status "Product status"
        string tags "Product tags"
        decimal price "Current price"
        decimal cost "Product cost"
        decimal gross_margin_usd "Gross margin per unit"
        decimal gross_margin_pct "Gross margin percentage"
        decimal total_revenue_usd "Historical revenue"
        integer total_orders "Total orders"
        integer total_quantity_sold "Total quantity"
        decimal avg_order_value_usd "Avg order value"
        string performance_tier "Performance tier"
        string revenue_tier "Revenue tier"
        integer days_since_last_sale "Days since last sale"
        boolean is_active_seller "Active seller"
        string inventory_status "Inventory status"
        integer reorder_point "Reorder threshold"
        timestamp valid_from "SCD valid from"
        timestamp valid_to "SCD valid to"
        boolean is_current "SCD current record"
    }

    dim_channels {
        integer channel_key PK "Surrogate channel key"
        string channel_source_medium "Source/medium combo"
        string channel_category "Channel category"
        string channel_name "Channel name"
        boolean is_paid_channel "Paid channel flag"
        timestamp warehouse_updated_at "Warehouse update"
    }

    dim_customer_metrics {
        integer customer_metrics_key PK "Surrogate metrics key"
        integer customer_id "Business key from Shopify"
        string customer_email "Email address"
        string customer_name "Full name"
        integer orders_count "Total orders"
        float total_spent "Total spent"
        float avg_order_value "Average order value"
        timestamp first_order_date "First order"
        timestamp last_order_date "Last order"
        integer days_since_first_order "Days since first"
        integer days_since_last_order "Days since last"
        string frequency_tier "Frequency tier"
        string monetary_tier "Monetary tier"
        string recency_tier "Recency tier"
        string customer_segment "RFM segment"
        string customer_value_tier "Value tier"
        integer recency_days "Recency days"
        float avg_days_between_orders "Avg days between"
        float churn_probability "Churn probability"
        float clv_predicted "Predicted CLV"
        integer days_until_next_order_prediction "Next order prediction"
        timestamp warehouse_updated_at "Warehouse update"
    }

    dim_categories {
        integer category_key PK "Surrogate category key"
        string category_name "Category name"
        string parent_category "Parent category"
        integer category_level "Hierarchy level"
        string category_path "Full path"
        boolean is_active "Active flag"
        timestamp warehouse_updated_at "Warehouse update"
    }

    dim_social_content {
        integer content_key PK "Surrogate content key"
        string content_id "Content identifier"
        string platform "Social platform"
        string content_type "Content type"
        string content_category "Content category"
        string content_theme "Content theme"
        boolean has_hashtags "Has hashtags"
        boolean has_mentions "Has mentions"
        boolean has_links "Has links"
        boolean is_video "Is video"
        boolean is_image "Is image"
        timestamp warehouse_updated_at "Warehouse update"
    }

    %% Fact Tables
    fact_orders {
        integer order_key PK "Surrogate order key"
        integer customer_key FK "FK to dim_customers"
        integer channel_key FK "FK to dim_channels"
        integer order_date_key FK "FK to dim_date"
        integer processed_date_key FK "FK to dim_date"
        integer cancelled_date_key FK "FK to dim_date"
        integer order_id "Business key from Shopify"
        string order_name "Order name"
        integer customer_id "Customer ID"
        string customer_email "Customer email"
        timestamp order_created_at "Created timestamp"
        timestamp order_updated_at "Updated timestamp"
        timestamp order_processed_at "Processed timestamp"
        timestamp order_cancelled_at "Cancelled timestamp"
        string financial_status "Financial status"
        string fulfillment_status "Fulfillment status"
        float order_total_price "Total price"
        float subtotal_price "Subtotal"
        float total_tax "Tax"
        float total_discounts "Discounts"
        float shipping_cost "Shipping"
        float order_adjustment_amount "Adjustments"
        numeric refund_subtotal "Refund subtotal"
        integer refund_tax "Refund tax"
        float calculated_order_total "Calculated total"
        float total_line_discounts "Line discounts"
        float total_discount_amount "Total discount"
        integer line_item_count "Line items"
        integer unique_product_count "Unique products"
        integer total_quantity "Total quantity"
        float avg_line_price "Avg line price"
        float max_line_price "Max line price"
        float min_line_price "Min line price"
        integer discount_count "Discount count"
        string order_value_category "Value category"
        string source_name "Source"
        string referring_site "Referrer"
        string landing_site_base_url "Landing page"
        string channel_source_medium "Source/medium"
        boolean is_cancelled "Cancelled flag"
        boolean has_refund "Refund flag"
        boolean is_multi_product_order "Multi-product"
        boolean has_discount "Discount flag"
        float discount_rate "Discount rate"
        float tax_rate "Tax rate"
        float shipping_rate "Shipping rate"
        float net_order_value "Net value"
        float net_subtotal "Net subtotal"
        float net_tax "Net tax"
        integer hours_to_process "Hours to process"
        integer hours_to_cancellation "Hours to cancel"
        string order_time_of_day "Time of day"
        string order_day_type "Day type"
        timestamp warehouse_updated_at "Warehouse update"
    }

    fact_order_items {
        string order_item_key PK "Surrogate item key"
        integer order_key FK "FK to fact_orders"
        integer product_key FK "FK to dim_products"
        integer customer_key FK "FK to dim_customers"
        integer order_date_key FK "FK to dim_date"
        integer order_id "Order ID"
        bigint line_item_id "Line item ID"
        bigint product_id "Product ID"
        bigint variant_id "Variant ID"
        string sku "Product SKU"
        integer quantity "Quantity"
        float unit_price "Unit price"
        float line_discount "Line discount"
        float line_total "Line total"
        float tax_amount "Tax amount"
        string fulfillment_status "Fulfillment status"
        boolean gift_card "Gift card flag"
        boolean requires_shipping "Requires shipping"
        boolean is_taxable "Taxable flag"
    }

    fact_sessions {
        string session_key PK "Surrogate session key"
        string session_id "Business key from GA4"
        string user_pseudo_id "User pseudo ID"
        string session_date_key FK "FK to dim_date"
        integer channel_key FK "FK to dim_channels"
        timestamp session_start_time "Session start"
        timestamp session_end_time "Session end"
        decimal session_duration_minutes "Duration minutes"
        string device_category "Device category"
        string browser "Browser"
        string operating_system "Operating system"
        string geo_country "User country"
        string geo_region "User region"
        string geo_city "User city"
        integer page_views "Page views"
        integer unique_pages_viewed "Unique pages"
        integer events_count "Events count"
        integer scroll_events "Scroll events"
        decimal engagement_time_seconds "Engagement time"
        boolean has_purchase "Purchase flag"
        boolean has_add_to_cart "Add to cart flag"
        boolean has_checkout "Checkout flag"
        decimal purchase_value_usd "Purchase value USD"
        string session_type "Session type"
        boolean is_bounce "Bounce flag"
        decimal engagement_score "Engagement score"
        decimal conversion_probability "Conversion probability"
    }

    fact_events {
        string event_key PK "Surrogate event key"
        string session_key FK "FK to fact_sessions"
        string event_date_key FK "FK to dim_date"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session ID"
        timestamp event_timestamp "Event timestamp"
        string event_name "Event name"
        string event_category "Event category"
        string page_path "Page path"
        string page_title "Page title"
        string page_referrer "Page referrer"
        integer scroll_depth_pct "Scroll depth %"
        decimal time_on_page_seconds "Time on page"
        decimal ecommerce_value_usd "Ecommerce value USD"
        string transaction_id "Transaction ID"
        integer item_count "Item count"
        decimal event_value "Event value"
        string custom_parameter_1 "Custom param 1"
        string custom_parameter_2 "Custom param 2"
        boolean is_conversion_event "Conversion flag"
        decimal engagement_weight "Engagement weight"
    }

    fact_customer_journey {
        string journey_key PK "Surrogate journey key"
        integer customer_key FK "FK to dim_customers"
        string order_key FK "FK to fact_orders"
        string session_key FK "FK to fact_sessions"
        integer channel_key FK "FK to dim_channels"
        string touchpoint_date_key FK "FK to dim_date"
        string conversion_date_key FK "FK to dim_date"
        integer touchpoint_sequence "Touchpoint sequence"
        integer days_to_conversion "Days to conversion"
        decimal session_duration_minutes "Session duration"
        integer page_views "Page views"
        decimal engagement_score "Engagement score"
        decimal conversion_value_usd "Conversion value USD"
        decimal attribution_weight "Attribution weight"
        decimal first_touch_attribution "First touch"
        decimal last_touch_attribution "Last touch"
        decimal linear_attribution "Linear"
        decimal time_decay_attribution "Time decay"
        decimal position_based_attribution "Position based"
        string journey_complexity "Journey complexity"
        string conversion_timeline "Conversion timeline"
        boolean is_converting_session "Converting session"
        boolean is_first_touch "First touch flag"
        boolean is_last_touch "Last touch flag"
    }

    fact_marketing_performance {
        string marketing_key PK "Surrogate marketing key"
        integer channel_key FK "FK to dim_channels"
        string report_date_key FK "FK to dim_date"
        string platform "Marketing platform"
        string campaign_id "Campaign ID"
        string campaign_name "Campaign name"
        string ad_group_id "Ad group ID"
        string ad_group_name "Ad group name"
        string ad_id "Ad ID"
        string keyword "Keyword"
        string match_type "Match type"
        string device_category "Device category"
        string geo_country "Geographic country"
        decimal cost_usd "Cost USD"
        integer impressions "Impressions"
        integer clicks "Clicks"
        decimal conversions "Conversions"
        decimal revenue "Revenue"
        decimal ctr "Click-through rate"
        decimal cpc_usd "Cost per click USD"
        decimal cpm_usd "Cost per mille USD"
        decimal conversion_rate "Conversion rate"
        decimal cpa_usd "Cost per acquisition USD"
        decimal roas "Return on ad spend"
        decimal quality_score "Quality score"
        string performance_tier "Performance tier"
        string campaign_type "Campaign type"
    }

    fact_email_marketing {
        string email_event_key PK "Surrogate email key"
        string campaign_id "Campaign ID"
        string person_id "Person ID"
        string event_date_key FK "FK to dim_date"
        string event_type "Event type"
        timestamp event_timestamp "Event timestamp"
        string email_address "Email address"
        string campaign_name "Campaign name"
        string campaign_subject "Subject line"
        string campaign_type "Campaign type"
        string flow_id "Flow ID"
        string flow_name "Flow name"
        boolean is_delivered "Delivered flag"
        boolean is_opened "Opened flag"
        boolean is_clicked "Clicked flag"
        boolean is_bounced "Bounced flag"
        boolean is_marked_spam "Spam flag"
        boolean is_unsubscribed "Unsubscribed flag"
        decimal attributed_revenue "Attributed revenue"
        string attributed_order_id "Attributed order"
        string device_type "Device type"
        string email_client "Email client"
        string geo_country "Country"
        decimal engagement_score "Engagement score"
    }

    fact_social_posts {
        string social_post_key PK "Surrogate social key"
        integer content_key FK "FK to dim_social_content"
        string post_date_key FK "FK to dim_date"
        string platform "Social platform"
        string post_id "Post ID"
        string account_id "Account ID"
        string post_type "Post type"
        timestamp post_created_at "Post creation"
        integer impressions "Impressions"
        integer reach "Reach"
        integer likes "Likes"
        integer comments "Comments"
        integer shares "Shares"
        integer saves "Saves"
        integer clicks "Clicks"
        integer video_views "Video views"
        decimal video_completion_rate "Video completion"
        decimal engagement_rate "Engagement rate"
        decimal virality_score "Virality score"
        decimal sentiment_score "Sentiment score"
        boolean is_promoted "Promoted flag"
        decimal promotion_spend_usd "Promotion spend"
        integer attributed_conversions "Conversions"
        decimal attributed_revenue_usd "Revenue"
    }

    fact_inventory {
        string inventory_key PK "Surrogate inventory key"
        integer product_key FK "FK to dim_products"
        string date_key FK "FK to dim_date"
        string location_id "Location ID"
        string location_name "Location name"
        bigint inventory_item_id "Inventory item ID"
        integer available_quantity "Available qty"
        integer committed_quantity "Committed qty"
        integer incoming_quantity "Incoming qty"
        integer on_hand_quantity "On hand qty"
        integer reorder_point "Reorder point"
        integer reorder_quantity "Reorder qty"
        integer days_of_supply "Days of supply"
        decimal stockout_risk_score "Stockout risk"
        decimal inventory_value_usd "Inventory value"
        decimal carrying_cost_usd "Carrying cost"
    }

    fact_ad_spend {
        string ad_spend_key PK "Surrogate spend key"
        integer channel_key FK "FK to dim_channels"
        string date_key FK "FK to dim_date"
        string platform "Ad platform"
        string account_id "Account ID"
        string campaign_id "Campaign ID"
        string campaign_name "Campaign name"
        string ad_group_id "Ad group ID"
        string ad_group_name "Ad group name"
        decimal spend_usd "Spend USD"
        integer impressions "Impressions"
        integer clicks "Clicks"
        decimal conversions "Conversions"
        decimal conversion_value_usd "Conversion value"
        decimal budget_usd "Budget USD"
        decimal budget_utilization_pct "Budget utilization"
    }

    fact_ad_attribution {
        string attribution_key PK "Surrogate attribution key"
        integer order_key FK "FK to fact_orders"
        integer channel_key FK "FK to dim_channels"
        integer customer_key FK "FK to dim_customers"
        string attribution_date_key FK "FK to dim_date"
        string platform "Attribution platform"
        string campaign_id "Campaign ID"
        string campaign_name "Campaign name"
        string ad_id "Ad ID"
        string click_id "Click ID"
        string attribution_model "Attribution model"
        decimal attribution_weight "Attribution weight"
        decimal attributed_revenue_usd "Attributed revenue"
        integer attributed_units "Attributed units"
        integer days_to_conversion "Days to conversion"
        boolean is_view_through "View-through flag"
        boolean is_click_through "Click-through flag"
    }

    fact_data_quality {
        string data_quality_key PK "Surrogate quality key"
        string report_date_key FK "FK to dim_date"
        string data_source "Data source"
        integer source_rows "Source rows"
        integer staging_rows "Staging rows"
        integer integration_rows "Integration rows"
        integer warehouse_rows "Warehouse rows"
        decimal staging_flow_pct "Staging flow %"
        decimal integration_flow_pct "Integration flow %"
        decimal warehouse_flow_pct "Warehouse flow %"
        decimal source_test_pass_rate "Source test pass"
        decimal staging_test_pass_rate "Staging test pass"
        decimal integration_test_pass_rate "Integration test pass"
        decimal warehouse_test_pass_rate "Warehouse test pass"
        decimal overall_test_pass_rate "Overall test pass"
        decimal data_completeness_pct "Data completeness"
        decimal data_freshness_hours "Data freshness"
        boolean schema_drift_detected "Schema drift"
        integer duplicate_records_count "Duplicate records"
        integer null_key_violations "Null key violations"
        integer referential_integrity_violations "RI violations"
        decimal overall_pipeline_health_score "Pipeline health"
        string data_quality_rating "Quality rating"
        string pipeline_efficiency_rating "Efficiency rating"
    }

    %% Primary Dimensional Relationships
    dim_customers ||--o{ fact_orders : "customer_key"
    dim_channels ||--o{ fact_orders : "channel_key"
    dim_date ||--o{ fact_orders : "order_date_key"
    dim_date ||--o{ fact_orders : "processed_date_key"
    dim_date ||--o{ fact_orders : "cancelled_date_key"
    
    fact_orders ||--o{ fact_order_items : "order_key"
    dim_products ||--o{ fact_order_items : "product_key"
    dim_customers ||--o{ fact_order_items : "customer_key"
    dim_date ||--o{ fact_order_items : "order_date_key"
    
    dim_date ||--o{ fact_sessions : "session_date_key"
    dim_channels ||--o{ fact_sessions : "channel_key"
    
    fact_sessions ||--o{ fact_events : "session_key"
    dim_date ||--o{ fact_events : "event_date_key"
    
    dim_customers ||--o{ fact_customer_journey : "customer_key"
    fact_orders ||--o{ fact_customer_journey : "order_key"
    fact_sessions ||--o{ fact_customer_journey : "session_key"
    dim_channels ||--o{ fact_customer_journey : "channel_key"
    dim_date ||--o{ fact_customer_journey : "touchpoint_date_key"
    dim_date ||--o{ fact_customer_journey : "conversion_date_key"
    
    dim_channels ||--o{ fact_marketing_performance : "channel_key"
    dim_date ||--o{ fact_marketing_performance : "report_date_key"
    
    dim_date ||--o{ fact_email_marketing : "event_date_key"
    
    dim_social_content ||--o{ fact_social_posts : "content_key"
    dim_date ||--o{ fact_social_posts : "post_date_key"
    
    dim_products ||--o{ fact_inventory : "product_key"
    dim_date ||--o{ fact_inventory : "date_key"
    
    dim_channels ||--o{ fact_ad_spend : "channel_key"
    dim_date ||--o{ fact_ad_spend : "date_key"
    
    fact_orders ||--o{ fact_ad_attribution : "order_key"
    dim_channels ||--o{ fact_ad_attribution : "channel_key"
    dim_customers ||--o{ fact_ad_attribution : "customer_key"
    dim_date ||--o{ fact_ad_attribution : "attribution_date_key"
    
    dim_date ||--o{ fact_data_quality : "report_date_key"

    %% Styling
    classDef dimension fill:#e8f4f8,stroke:#1976d2,stroke-width:3px
    classDef fact fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef bridge fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px

    class dim_date,dim_customers,dim_products,dim_channels,dim_customer_metrics,dim_categories,dim_social_content dimension
    class fact_orders,fact_order_items,fact_sessions,fact_events,fact_customer_journey,fact_marketing_performance,fact_email_marketing,fact_social_posts,fact_inventory,fact_ad_spend,fact_ad_attribution,fact_data_quality fact
```

## BigQuery Dataset: `analytics_ecommerce_ecommerce`

### Dimension Tables (7 tables)
- **dim_customers** - SCD Type 2 customer dimension with 40+ attributes
- **dim_products** - Product master with performance metrics
- **dim_date** - Complete calendar dimension
- **dim_channels** - Marketing channel mappings
- **dim_customer_metrics** - Customer analytics and RFM segmentation
- **dim_categories** - Product category hierarchy
- **dim_social_content** - Social media content attributes

### Fact Tables (12 tables)
- **fact_orders** - Order header grain (68 columns)
- **fact_order_items** - Order line item grain
- **fact_sessions** - Website session metrics
- **fact_events** - User interaction events
- **fact_customer_journey** - Multi-touch attribution
- **fact_marketing_performance** - Cross-platform ad performance
- **fact_email_marketing** - Email engagement events
- **fact_social_posts** - Social media post performance
- **fact_inventory** - Daily inventory snapshots
- **fact_ad_spend** - Daily advertising costs
- **fact_ad_attribution** - Conversion attribution
- **fact_data_quality** - Pipeline health monitoring

## Key Relationships

### Core Dimensional Relationships
- **dim_date** is referenced by ALL fact tables for time-based analysis
- **dim_customers** drives customer-centric facts (orders, journey, attribution)
- **dim_products** provides product context for order items and inventory
- **dim_channels** enables attribution analysis across multiple facts

### Fact-to-Fact Relationships
- **fact_sessions** drives **fact_events** (session-level to event-level)
- **fact_orders** drives **fact_order_items** (header to line detail)
- **fact_orders** and **fact_sessions** both feed **fact_customer_journey** for attribution
- **fact_orders** connects to **fact_ad_attribution** for conversion tracking

### SCD Type 2 Implementation
- **dim_customers** uses `effective_from`, `effective_to`, and `is_current` fields
- **dim_products** tracks changes over time with validity dates
- Surrogate keys ensure referential integrity across time periods

### Star Schema Design
- Clean star schema with facts surrounded by dimensions
- Conformed dimensions used across multiple fact tables
- Bridge tables (like customer journey) enable complex many-to-many relationships

## Fact Table Grains

- **fact_orders**: Order header level (one row per order)
- **fact_order_items**: Order line item level (one row per product per order)
- **fact_sessions**: Website session level  
- **fact_events**: Individual event level
- **fact_customer_journey**: Touchpoint level (session + conversion)
- **fact_marketing_performance**: Campaign/ad/keyword performance by day
- **fact_email_marketing**: Email event level
- **fact_social_posts**: Individual social post level
- **fact_inventory**: Product/location/day level
- **fact_ad_spend**: Campaign/day level
- **fact_ad_attribution**: Order/campaign attribution level
- **fact_data_quality**: Data source quality by day

## Data Types Legend
- **PK**: Primary Key
- **FK**: Foreign Key  
- **integer**: Integer values
- **bigint**: Large integer identifiers
- **string**: Text/varchar fields
- **float/decimal/numeric**: Numeric values with decimals
- **timestamp**: Date and time
- **date**: Date only
- **boolean**: True/false flags