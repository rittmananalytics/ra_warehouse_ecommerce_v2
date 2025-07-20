# Warehouse Layer Entity Relationship Diagram

This diagram shows all warehouse layer tables (dimensions and facts) with their primary key/foreign key relationships in the dimensional model.

```mermaid
erDiagram
    %% Dimension Tables
    wh_dim_date {
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

    wh_dim_customers {
        string customer_key PK "Surrogate customer key"
        bigint customer_id "Business key from Shopify"
        string customer_email "Email address"
        string customer_first_name "First name"
        string customer_last_name "Last name"
        string customer_full_name "Full name"
        timestamp customer_created_at "Creation timestamp"
        decimal total_spent_usd "Historical total spent"
        integer order_count "Total orders"
        decimal avg_order_value_usd "Average order value"
        integer days_since_first_order "Days since first order"
        integer days_since_last_order "Days since last order"
        string customer_segment "RFM segment"
        string customer_value_tier "Value tier"
        boolean is_active_customer "Active indicator"
        decimal churn_risk_score "Churn risk 0-100"
        decimal engagement_score "Engagement 0-100"
        decimal predicted_ltv_usd "Predicted LTV"
        string acquisition_channel "Acquisition channel"
        date first_order_date "First order date"
        date last_order_date "Last order date"
        timestamp valid_from "SCD valid from"
        timestamp valid_to "SCD valid to"
        boolean is_current "SCD current record"
    }

    wh_dim_products {
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

    wh_dim_channels_enhanced {
        string channel_key PK "Surrogate channel key"
        string utm_source "UTM source"
        string utm_medium "UTM medium"
        string utm_campaign "UTM campaign"
        string channel_name "Channel name"
        string channel_category "Channel category"
        string channel_type "Channel type"
        boolean is_paid_channel "Paid channel indicator"
        string attribution_model "Attribution model"
        boolean cost_tracking_enabled "Cost tracking enabled"
        boolean conversion_tracking_enabled "Conversion tracking enabled"
        string channel_description "Channel description"
    }

    wh_dim_email_campaigns {
        string campaign_key PK "Surrogate campaign key"
        string campaign_id "Business key from Klaviyo"
        string campaign_name "Campaign name"
        string campaign_subject "Subject line"
        string from_email "Sender email"
        string from_name "Sender name"
        string campaign_type "Campaign type"
        string campaign_category "Campaign category"
        string email_program_type "Program type"
        string audience_segment "Audience segment"
        string send_strategy "Send strategy"
        boolean has_emoji "Subject has emoji"
        boolean has_personalization "Subject personalized"
        string automation_trigger "Automation trigger"
        integer expected_send_volume "Expected volume"
        string campaign_goals "Campaign goals"
    }

    %% Fact Tables
    wh_fact_orders {
        string order_key PK "Surrogate order key"
        bigint order_id "Business key from Shopify"
        string customer_key FK "FK to dim_customers"
        string product_key FK "FK to dim_products"
        string order_date_key FK "FK to dim_date"
        string order_number "Order number"
        bigint line_item_id "Line item ID"
        string financial_status "Financial status"
        string fulfillment_status "Fulfillment status"
        string utm_source "UTM source"
        string utm_medium "UTM medium"
        string utm_campaign "UTM campaign"
        string traffic_source "Traffic source"
        string device_category "Device category"
        string geo_country "Customer country"
        integer line_item_quantity "Line quantity"
        decimal unit_price_usd "Unit price USD"
        decimal line_item_total_usd "Line total USD"
        decimal line_item_discount_usd "Line discount USD"
        decimal total_price_usd "Order total USD"
        decimal total_tax_usd "Tax USD"
        decimal total_discounts_usd "Discounts USD"
        decimal shipping_cost_usd "Shipping USD"
        decimal gross_margin_usd "Gross margin USD"
        boolean is_first_order "First order flag"
        integer order_sequence_number "Order sequence"
        integer days_since_previous_order "Days since previous"
        string order_type "Order type"
    }

    wh_fact_ga4_sessions {
        string session_key PK "Surrogate session key"
        string session_id "Business key from GA4"
        string user_pseudo_id "User pseudo ID"
        string session_date_key FK "FK to dim_date"
        string channel_key FK "FK to dim_channels_enhanced"
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

    wh_fact_events {
        string event_key PK "Surrogate event key"
        string session_key FK "FK to fact_ga4_sessions"
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

    wh_fact_customer_journey {
        string journey_key PK "Surrogate journey key"
        string customer_key FK "FK to dim_customers"
        string order_key FK "FK to fact_orders"
        string session_key FK "FK to fact_ga4_sessions"
        string channel_key FK "FK to dim_channels_enhanced"
        string touchpoint_date_key FK "FK to dim_date"
        string conversion_date_key FK "FK to dim_date"
        integer touchpoint_sequence "Touchpoint sequence"
        integer days_to_conversion "Days to conversion"
        decimal session_duration_minutes "Session duration"
        integer page_views "Page views"
        decimal engagement_score "Engagement score"
        decimal conversion_value_usd "Conversion value USD"
        decimal attribution_weight "Attribution weight"
        decimal first_touch_attribution "First touch attribution"
        decimal last_touch_attribution "Last touch attribution"
        decimal linear_attribution "Linear attribution"
        decimal time_decay_attribution "Time decay attribution"
        decimal position_based_attribution "Position based attribution"
        string journey_complexity "Journey complexity"
        string conversion_timeline "Conversion timeline"
        boolean is_converting_session "Converting session"
        boolean is_first_touch "First touch flag"
        boolean is_last_touch "Last touch flag"
    }

    wh_fact_marketing_performance {
        string marketing_key PK "Surrogate marketing key"
        string campaign_key "Campaign key"
        string channel_key FK "FK to dim_channels_enhanced"
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

    wh_fact_email_marketing {
        string email_marketing_key PK "Surrogate email key"
        string campaign_key FK "FK to dim_email_campaigns"
        string event_date_key FK "FK to dim_date"
        string person_id "Person ID"
        string email_address "Email address"
        string event_type "Event type"
        timestamp campaign_send_time "Campaign send time"
        timestamp event_timestamp "Event timestamp"
        integer emails_delivered "Emails delivered"
        integer emails_opened "Emails opened"
        integer emails_clicked "Emails clicked"
        integer emails_bounced "Emails bounced"
        integer emails_marked_spam "Emails marked spam"
        integer unsubscribes "Unsubscribes"
        integer orders "Orders"
        decimal revenue "Revenue"
        decimal open_rate "Open rate"
        decimal click_rate "Click rate"
        decimal conversion_rate "Conversion rate"
        decimal engagement_score "Engagement score"
        string customer_tier "Customer tier"
        string email_client "Email client"
        string device_category "Device category"
        string geo_country "Country"
    }

    wh_fact_social_posts {
        string social_post_key PK "Surrogate social key"
        string post_date_key FK "FK to dim_date"
        string platform "Social platform"
        string post_id "Post ID"
        string account_id "Account ID"
        string post_type "Post type"
        string content_type "Content type"
        timestamp post_created_date "Post creation"
        string caption_text "Caption text"
        integer hashtag_count "Hashtag count"
        integer mention_count "Mention count"
        integer impressions "Impressions"
        integer reach "Reach"
        integer likes "Likes"
        integer comments "Comments"
        integer shares "Shares"
        integer saves "Saves"
        integer total_engagements "Total engagements"
        decimal engagement_rate "Engagement rate"
        integer video_views "Video views"
        decimal video_completion_rate "Video completion rate"
        integer story_taps_forward "Story forward taps"
        integer story_taps_back "Story back taps"
        integer story_exits "Story exits"
        decimal engagement_score "Engagement score"
        string performance_tier "Performance tier"
        boolean is_promoted "Promoted flag"
        decimal promotion_spend_usd "Promotion spend USD"
    }

    wh_fact_data_quality {
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
        decimal source_test_pass_rate "Source test pass rate"
        decimal staging_test_pass_rate "Staging test pass rate"
        decimal integration_test_pass_rate "Integration test pass rate"
        decimal warehouse_test_pass_rate "Warehouse test pass rate"
        decimal overall_test_pass_rate "Overall test pass rate"
        decimal data_completeness_pct "Data completeness %"
        decimal data_freshness_hours "Data freshness hours"
        boolean schema_drift_detected "Schema drift detected"
        integer duplicate_records_count "Duplicate records"
        integer null_key_violations "Null key violations"
        integer referential_integrity_violations "RI violations"
        decimal overall_pipeline_health_score "Pipeline health score"
        string data_quality_rating "Quality rating"
        string pipeline_efficiency_rating "Efficiency rating"
    }

    %% Primary Dimensional Relationships
    wh_dim_customers ||--o{ wh_fact_orders : "customer_key"
    wh_dim_products ||--o{ wh_fact_orders : "product_key"
    wh_dim_date ||--o{ wh_fact_orders : "order_date_key"
    
    wh_dim_date ||--o{ wh_fact_ga4_sessions : "session_date_key"
    wh_dim_channels_enhanced ||--o{ wh_fact_ga4_sessions : "channel_key"
    
    wh_fact_ga4_sessions ||--o{ wh_fact_events : "session_key"
    wh_dim_date ||--o{ wh_fact_events : "event_date_key"
    
    wh_dim_customers ||--o{ wh_fact_customer_journey : "customer_key"
    wh_fact_orders ||--o{ wh_fact_customer_journey : "order_key"
    wh_fact_ga4_sessions ||--o{ wh_fact_customer_journey : "session_key"
    wh_dim_channels_enhanced ||--o{ wh_fact_customer_journey : "channel_key"
    wh_dim_date ||--o{ wh_fact_customer_journey : "touchpoint_date_key"
    wh_dim_date ||--o{ wh_fact_customer_journey : "conversion_date_key"
    
    wh_dim_channels_enhanced ||--o{ wh_fact_marketing_performance : "channel_key"
    wh_dim_date ||--o{ wh_fact_marketing_performance : "report_date_key"
    
    wh_dim_email_campaigns ||--o{ wh_fact_email_marketing : "campaign_key"
    wh_dim_date ||--o{ wh_fact_email_marketing : "event_date_key"
    
    wh_dim_date ||--o{ wh_fact_social_posts : "post_date_key"
    
    wh_dim_date ||--o{ wh_fact_data_quality : "report_date_key"

    %% Styling
    classDef dimension fill:#e8f4f8,stroke:#1976d2,stroke-width:3px
    classDef fact fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef bridge fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px

    class wh_dim_date,wh_dim_customers,wh_dim_products,wh_dim_channels_enhanced,wh_dim_email_campaigns dimension
    class wh_fact_orders,wh_fact_ga4_sessions,wh_fact_events,wh_fact_customer_journey,wh_fact_marketing_performance,wh_fact_email_marketing,wh_fact_social_posts,wh_fact_data_quality fact
```

## Key Relationships

### Core Dimensional Relationships
- **wh_dim_date** is referenced by ALL fact tables for time-based analysis
- **wh_dim_customers** drives customer-centric facts (orders, journey)
- **wh_dim_products** provides product context for order facts
- **wh_dim_channels_enhanced** enables attribution analysis across multiple facts

### Fact-to-Fact Relationships
- **wh_fact_ga4_sessions** drives **wh_fact_events** (session-level to event-level)
- **wh_fact_orders** and **wh_fact_ga4_sessions** both feed **wh_fact_customer_journey** for attribution
- **wh_fact_customer_journey** creates the bridge between website behavior and ecommerce conversion

### SCD Type 2 Implementation
- **wh_dim_customers** and **wh_dim_products** implement Slowly Changing Dimensions Type 2
- Uses `valid_from`, `valid_to`, and `is_current` fields for historical tracking
- Surrogate keys ensure referential integrity across time

### Star Schema Design
- Clean star schema with facts surrounded by dimensions
- Conformed dimensions used across multiple fact tables
- Bridge tables (like customer journey) enable complex many-to-many relationships

## Model Grain

### Fact Table Grains
- **wh_fact_orders**: Order line item level
- **wh_fact_ga4_sessions**: Website session level  
- **wh_fact_events**: Individual event level
- **wh_fact_customer_journey**: Touchpoint level (session + conversion)
- **wh_fact_marketing_performance**: Campaign/ad/keyword performance by day
- **wh_fact_email_marketing**: Email event level
- **wh_fact_social_posts**: Individual social post level
- **wh_fact_data_quality**: Data source quality by day

### Dimension Grain
- **wh_dim_date**: Daily grain with calendar and fiscal attributes
- **wh_dim_customers**: Customer level with SCD Type 2 for changes
- **wh_dim_products**: Product level with SCD Type 2 for changes
- **wh_dim_channels_enhanced**: Channel combination level
- **wh_dim_email_campaigns**: Email campaign level

## Data Types Legend
- **PK**: Primary Key
- **FK**: Foreign Key  
- **string**: Text/varchar field
- **decimal**: Numeric with decimals
- **integer**: Whole number
- **timestamp**: Date and time
- **date**: Date only
- **boolean**: True/false flag