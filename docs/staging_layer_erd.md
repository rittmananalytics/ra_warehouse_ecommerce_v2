# Staging Layer Entity Relationship Diagram

This diagram shows all staging layer tables from the `analytics_ecommerce_staging` BigQuery dataset and their relationships within each source system.

```mermaid
erDiagram
    %% Shopify Ecommerce Tables
    stg_shopify_ecommerce__customers {
        integer customer_id PK "Unique customer identifier"
        string customer_email "Customer email address"
        string customer_first_name "Customer first name"
        string customer_last_name "Customer last name"
        string customer_phone "Customer phone number"
        timestamp customer_created_at "Customer creation timestamp"
        boolean customer_accepts_marketing "Marketing consent"
        string customer_state "Account state"
        string customer_tags "Customer tags"
        integer orders_count "Number of orders"
        decimal total_spent "Total spent amount"
    }

    stg_shopify_ecommerce__orders {
        integer order_id PK "Unique order identifier"
        string order_name "Human-readable order name"
        integer customer_id FK "References customer"
        string customer_email "Customer email"
        timestamp order_created_at "Order creation timestamp"
        timestamp order_updated_at "Order update timestamp"
        timestamp processed_at "Order processing timestamp"
        string financial_status "Financial status"
        string fulfillment_status "Fulfillment status"
        float order_total_price "Total order price"
        float order_subtotal_price "Subtotal before taxes"
        float order_total_tax "Tax amount"
        float order_total_discount "Discount amount"
        float total_line_items_price "Total line items price"
        float shipping_cost "Shipping cost"
        float order_adjustment_amount "Order adjustments"
        numeric order_total_weight "Total weight"
        string currency_code "Currency code"
        string order_tags "Order tags"
        timestamp cancelled_at "Cancellation timestamp"
        string cancel_reason "Cancellation reason"
        numeric refund_amount "Refund amount"
        integer customer_order_sequence_number "Order sequence"
        string new_vs_repeat "New vs repeat customer"
        integer order_line_count "Number of line items"
        string source_name "Order source"
        string referring_site "Referrer"
        string landing_site_base_url "Landing page"
        string utm_source "UTM source"
        string utm_medium "UTM medium"
        string utm_campaign "UTM campaign"
    }

    stg_shopify_ecommerce__order_lines {
        bigint order_line_id PK "Unique line item identifier"
        bigint order_id FK "References order"
        bigint product_id FK "References product"
        bigint variant_id "Product variant"
        integer quantity "Quantity ordered"
        decimal price "Unit price"
        decimal total_discount "Line discount"
        decimal line_item_total "Line total amount"
    }

    stg_shopify_ecommerce__products {
        bigint product_id PK "Unique product identifier"
        string product_title "Product title"
        string product_handle "URL handle"
        string product_type "Product category"
        string vendor "Product vendor"
        timestamp product_created_at "Product creation timestamp"
        timestamp product_updated_at "Product update timestamp"
        string product_status "Product status"
        string tags "Product tags"
    }

    stg_shopify_ecommerce__transactions {
        bigint transaction_id PK "Unique transaction identifier"
        bigint order_id FK "References order"
        string kind "Transaction type"
        string gateway "Payment gateway"
        string status "Transaction status"
        decimal amount "Transaction amount"
        string currency "Currency code"
        timestamp created_at "Transaction timestamp"
        string source_name "Transaction source"
        string message "Transaction message"
        string error_code "Error code if failed"
    }

    stg_shopify_ecommerce__discounts {
        bigint discount_id PK "Unique discount identifier"
        string code "Discount code"
        string discount_type "Type of discount"
        string status "Discount status"
        timestamp starts_at "Start date"
        timestamp ends_at "End date"
        integer usage_limit "Usage limit"
        integer usage_count "Times used"
        decimal minimum_order_amount "Minimum order"
        decimal value "Discount value"
        string value_type "Value type (percentage/fixed)"
        string applies_to "What discount applies to"
        boolean applies_once "Single use flag"
        timestamp created_at "Creation timestamp"
        timestamp updated_at "Update timestamp"
    }

    stg_shopify_ecommerce__inventory_levels {
        bigint inventory_item_id PK "Unique inventory item"
        bigint location_id PK "Location identifier"
        bigint product_id FK "References product"
        integer available_quantity "Available stock"
        timestamp updated_at "Last update timestamp"
    }

    stg_shopify_ecommerce__customer_cohorts {
        integer customer_id FK "References customer"
        string cohort_month "Cohort month YYYY-MM"
        integer months_since_first_order "Months since first order"
        decimal revenue "Revenue in period"
        integer orders "Orders in period"
        float retention_rate "Retention percentage"
    }

    stg_shopify_ecommerce__daily_shop {
        date shop_date PK "Date"
        integer total_orders "Orders on date"
        decimal total_revenue "Revenue on date"
        integer new_customers "New customers"
        integer returning_customers "Returning customers"
        decimal avg_order_value "Average order value"
        integer total_sessions "Website sessions"
        float conversion_rate "Conversion rate"
    }

    %% GA4 Events Tables
    stg_ga4_events__page_view {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        string page_title "Page title"
        string page_location "Page URL"
        string page_referrer "Referrer URL"
        string traffic_source_source "Traffic source"
        string traffic_source_medium "Traffic medium"
        string traffic_source_campaign "Campaign name"
        string device_category "Device type"
        string geo_country "User country"
        string geo_region "User region"
        string geo_city "User city"
    }

    stg_ga4_events__purchase {
        string event_key PK "Unique event identifier"
        date event_date "Purchase date"
        timestamp event_timestamp "Purchase timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        string transaction_id "Transaction ID"
        decimal value "Purchase value"
        string currency "Currency code"
        decimal tax "Tax amount"
        decimal shipping "Shipping amount"
        string coupon "Coupon code"
    }

    stg_ga4_events__add_to_cart {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        decimal value "Cart value"
        string currency "Currency code"
    }

    stg_ga4_events__add_to_cart_items {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        string item_id "Item identifier"
        string item_name "Item name"
        string item_category "Item category"
        integer quantity "Quantity"
        decimal price "Item price"
    }

    stg_ga4_events__add_payment_info {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        string payment_type "Payment method"
        decimal value "Checkout value"
        string currency "Currency code"
    }

    stg_ga4_events__add_shipping_info {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        string shipping_tier "Shipping method"
        decimal value "Checkout value"
        string currency "Currency code"
    }

    stg_ga4_events__begin_checkout {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        decimal value "Checkout value"
        string currency "Currency code"
        string coupon "Coupon code"
    }

    stg_ga4_events__session_start {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        string traffic_source_source "Traffic source"
        string traffic_source_medium "Traffic medium"
        string traffic_source_campaign "Campaign"
        string device_category "Device type"
        string geo_country "Country"
    }

    stg_ga4_events__view_item {
        string event_key PK "Unique event identifier"
        date event_date "Event date"
        timestamp event_timestamp "Event timestamp"
        string user_pseudo_id "User pseudo ID"
        string session_id "Session identifier"
        string item_id "Item viewed"
        string item_name "Item name"
        string item_category "Item category"
        decimal price "Item price"
        string currency "Currency code"
    }

    %% Google Ads Tables (in analytics_ecommerce dataset)
    stg_google_ads__campaigns {
        bigint campaign_id PK "Unique campaign identifier"
        string campaign_name "Campaign name"
        string campaign_status "Campaign status"
        date start_date "Campaign start date"
        date end_date "Campaign end date"
        decimal total_cost "Total cost in micros"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
        decimal total_conversions "Total conversions"
        decimal ctr "Click-through rate"
        decimal cpc "Cost per click"
        decimal cpm "Cost per mille"
    }

    stg_google_ads__ad_groups {
        bigint ad_group_id PK "Unique ad group identifier"
        bigint campaign_id FK "References campaign"
        string ad_group_name "Ad group name"
        string ad_group_status "Ad group status"
        decimal max_cpc "Maximum CPC bid"
        decimal total_cost "Total cost"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
        decimal total_conversions "Total conversions"
    }

    stg_google_ads__ads {
        bigint ad_id PK "Unique ad identifier"
        bigint ad_group_id FK "References ad group"
        bigint campaign_id FK "References campaign"
        string ad_name "Ad name"
        string ad_status "Ad status"
        string ad_type "Ad type"
        decimal total_cost "Total cost"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
        decimal total_conversions "Total conversions"
    }

    stg_google_ads__keywords {
        bigint keyword_id PK "Unique keyword identifier"
        bigint ad_group_id FK "References ad group"
        bigint campaign_id FK "References campaign"
        string keyword_text "Keyword text"
        string match_type "Keyword match type"
        string keyword_status "Keyword status"
        decimal max_cpc "Maximum CPC"
        decimal total_cost "Total cost"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
        decimal total_conversions "Total conversions"
    }

    %% Facebook Ads Tables (in analytics_ecommerce dataset)
    stg_facebook_ads__campaigns {
        bigint campaign_id PK "Unique campaign identifier"
        string campaign_name "Campaign name"
        string campaign_status "Campaign status"
        timestamp start_time "Campaign start time"
        timestamp stop_time "Campaign stop time"
        decimal daily_budget "Daily budget"
        decimal total_spend "Total spend"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
    }

    stg_facebook_ads__ad_sets {
        bigint ad_set_id PK "Unique ad set identifier"
        bigint campaign_id FK "References campaign"
        string ad_set_name "Ad set name"
        string ad_set_status "Ad set status"
        timestamp start_time "Ad set start time"
        timestamp end_time "Ad set end time"
        decimal daily_budget "Daily budget"
        decimal total_spend "Total spend"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
    }

    stg_facebook_ads__ads {
        bigint ad_id PK "Unique ad identifier"
        bigint ad_set_id FK "References ad set"
        bigint campaign_id FK "References campaign"
        string ad_name "Ad name"
        string ad_status "Ad status"
        decimal total_spend "Total spend"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
    }

    %% Pinterest Ads Tables (in analytics_ecommerce dataset)
    stg_pinterest_ads__campaigns {
        bigint campaign_id PK "Unique campaign identifier"
        string campaign_name "Campaign name"
        string campaign_status "Campaign status"
        timestamp start_time "Campaign start time"
        timestamp end_time "Campaign end time"
        decimal daily_spend_cap "Daily spend cap"
        decimal total_spend "Total spend"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
    }

    stg_pinterest_ads__ad_groups {
        bigint ad_group_id PK "Unique ad group identifier"
        bigint campaign_id FK "References campaign"
        string ad_group_name "Ad group name"
        string ad_group_status "Ad group status"
        timestamp start_time "Ad group start time"
        timestamp end_time "Ad group end time"
        decimal total_spend "Total spend"
        integer total_clicks "Total clicks"
        integer total_impressions "Total impressions"
    }

    stg_pinterest_ads__advertisers {
        bigint advertiser_id PK "Unique advertiser identifier"
        string advertiser_name "Advertiser name"
        string advertiser_status "Advertiser status"
        timestamp created_time "Creation timestamp"
        timestamp updated_time "Update timestamp"
        string country "Advertiser country"
        string currency "Currency code"
    }

    %% Klaviyo Tables (in analytics_ecommerce dataset)
    stg_klaviyo__campaign {
        string campaign_id PK "Unique campaign identifier"
        string campaign_name "Campaign name"
        string campaign_subject "Email subject line"
        string from_email "Sender email"
        string from_name "Sender name"
        string campaign_type "Campaign type"
        string campaign_category "Campaign category"
        timestamp sent_at "Send timestamp"
        boolean has_emoji "Subject has emoji"
        boolean has_personalization "Subject has personalization"
    }

    stg_klaviyo__event {
        string event_id PK "Unique event identifier"
        string person_id FK "References person"
        string campaign_id FK "References campaign"
        timestamp event_timestamp "Event timestamp"
        date event_date "Event date"
        string event_category "Event category"
        string customer_tier_at_event "Customer tier"
    }

    stg_klaviyo__person {
        string person_id PK "Unique person identifier"
        string email "Email address"
        string first_name "First name"
        string last_name "Last name"
        string phone_number "Phone number"
        boolean accepts_marketing "Marketing consent"
        string customer_status "Customer status"
        decimal total_spent "Total spent"
        timestamp created_at "Creation timestamp"
        timestamp updated_at "Update timestamp"
    }

    %% Instagram Business Tables (in analytics_ecommerce dataset)
    stg_instagram_business__users {
        string user_id PK "Unique user identifier"
        string username "Instagram username"
        string account_type "Account type"
        string media_count "Media count"
        string followers_count "Followers count"
        string follows_count "Follows count"
        string name "Display name"
        string website "Website URL"
        string biography "Bio text"
    }

    stg_instagram_business__media_insights {
        string media_insight_id PK "Unique insight identifier"
        string user_id FK "References user"
        string media_id "Media identifier"
        string media_type "Media type"
        timestamp media_timestamp "Media timestamp"
        integer impressions "Impressions count"
        integer reach "Reach count"
        integer likes "Likes count"
        integer comments "Comments count"
        integer shares "Shares count"
        integer saves "Saves count"
        decimal engagement_rate "Engagement rate"
    }

    %% Relationships within Shopify
    stg_shopify_ecommerce__customers ||--o{ stg_shopify_ecommerce__orders : "places"
    stg_shopify_ecommerce__orders ||--o{ stg_shopify_ecommerce__order_lines : "contains"
    stg_shopify_ecommerce__products ||--o{ stg_shopify_ecommerce__order_lines : "sold_in"
    stg_shopify_ecommerce__orders ||--o{ stg_shopify_ecommerce__transactions : "has"
    stg_shopify_ecommerce__products ||--o{ stg_shopify_ecommerce__inventory_levels : "tracked_in"
    stg_shopify_ecommerce__customers ||--o{ stg_shopify_ecommerce__customer_cohorts : "analyzed_in"

    %% Relationships within Google Ads
    stg_google_ads__campaigns ||--o{ stg_google_ads__ad_groups : "contains"
    stg_google_ads__ad_groups ||--o{ stg_google_ads__ads : "contains"
    stg_google_ads__ad_groups ||--o{ stg_google_ads__keywords : "targets"
    stg_google_ads__campaigns ||--o{ stg_google_ads__ads : "contains"
    stg_google_ads__campaigns ||--o{ stg_google_ads__keywords : "targets"

    %% Relationships within Facebook Ads
    stg_facebook_ads__campaigns ||--o{ stg_facebook_ads__ad_sets : "contains"
    stg_facebook_ads__ad_sets ||--o{ stg_facebook_ads__ads : "contains"
    stg_facebook_ads__campaigns ||--o{ stg_facebook_ads__ads : "contains"

    %% Relationships within Pinterest Ads
    stg_pinterest_ads__campaigns ||--o{ stg_pinterest_ads__ad_groups : "contains"

    %% Relationships within Klaviyo
    stg_klaviyo__person ||--o{ stg_klaviyo__event : "performs"
    stg_klaviyo__campaign ||--o{ stg_klaviyo__event : "generates"

    %% Relationships within Instagram Business
    stg_instagram_business__users ||--o{ stg_instagram_business__media_insights : "owns"

    %% Styling
    classDef shopify fill:#e8f4f8,stroke:#1976d2,stroke-width:2px
    classDef ga4 fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef googleAds fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef facebookAds fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef pinterestAds fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef klaviyo fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef instagram fill:#fff8e1,stroke:#fbc02d,stroke-width:2px

    class stg_shopify_ecommerce__customers,stg_shopify_ecommerce__orders,stg_shopify_ecommerce__order_lines,stg_shopify_ecommerce__products,stg_shopify_ecommerce__transactions,stg_shopify_ecommerce__discounts,stg_shopify_ecommerce__inventory_levels,stg_shopify_ecommerce__customer_cohorts,stg_shopify_ecommerce__daily_shop shopify
    class stg_ga4_events__page_view,stg_ga4_events__purchase,stg_ga4_events__add_to_cart,stg_ga4_events__add_to_cart_items,stg_ga4_events__add_payment_info,stg_ga4_events__add_shipping_info,stg_ga4_events__begin_checkout,stg_ga4_events__session_start,stg_ga4_events__view_item ga4
    class stg_google_ads__campaigns,stg_google_ads__ad_groups,stg_google_ads__ads,stg_google_ads__keywords googleAds
    class stg_facebook_ads__campaigns,stg_facebook_ads__ad_sets,stg_facebook_ads__ads facebookAds
    class stg_pinterest_ads__campaigns,stg_pinterest_ads__ad_groups,stg_pinterest_ads__advertisers pinterestAds
    class stg_klaviyo__campaign,stg_klaviyo__event,stg_klaviyo__person klaviyo
    class stg_instagram_business__users,stg_instagram_business__media_insights instagram
```

## BigQuery Dataset Organization

### Staging Layer Tables in `analytics_ecommerce_staging`:

#### Shopify Ecommerce (9 tables)
- `stg_shopify_ecommerce__customers` - Customer master data
- `stg_shopify_ecommerce__orders` - Order headers with UTM tracking
- `stg_shopify_ecommerce__order_lines` - Order line items
- `stg_shopify_ecommerce__products` - Product catalog
- `stg_shopify_ecommerce__transactions` - Payment transactions
- `stg_shopify_ecommerce__discounts` - Discount codes and usage
- `stg_shopify_ecommerce__inventory_levels` - Stock levels by location
- `stg_shopify_ecommerce__customer_cohorts` - Cohort analysis
- `stg_shopify_ecommerce__daily_shop` - Daily shop metrics

#### Google Analytics 4 (9 tables)
- `stg_ga4_events__page_view` - Page view events
- `stg_ga4_events__purchase` - Purchase conversions
- `stg_ga4_events__add_to_cart` - Cart additions
- `stg_ga4_events__add_to_cart_items` - Cart item details
- `stg_ga4_events__add_payment_info` - Payment info added
- `stg_ga4_events__add_shipping_info` - Shipping info added
- `stg_ga4_events__begin_checkout` - Checkout started
- `stg_ga4_events__session_start` - Session initialization
- `stg_ga4_events__view_item` - Product views

### Staging Layer Tables in `analytics_ecommerce`:

#### Advertising Platforms
- `stg_google_ads__campaigns`, `stg_google_ads__ad_groups`, `stg_google_ads__ads`, `stg_google_ads__keywords`
- `stg_facebook_ads__campaigns`, `stg_facebook_ads__ad_sets`, `stg_facebook_ads__ads`
- `stg_pinterest_ads__campaigns`, `stg_pinterest_ads__ad_groups`, `stg_pinterest_ads__advertisers`

#### Email & Social
- `stg_klaviyo__campaign`, `stg_klaviyo__event`, `stg_klaviyo__person`
- `stg_instagram_business__users`, `stg_instagram_business__media_insights`

## Key Relationships by Source System

### Shopify Ecommerce
- **Customers** place multiple **Orders**
- **Orders** contain multiple **Order Lines** and **Transactions**
- **Products** are sold through **Order Lines**
- **Products** have **Inventory Levels** across locations
- **Customers** are analyzed in **Customer Cohorts**
- **Daily Shop** aggregates daily metrics

### Google Analytics 4
- All events linked by **session_id** and **user_pseudo_id**
- Events track the complete customer journey from page view to purchase
- Session start initializes tracking for all subsequent events

### Advertising Platforms
- Hierarchical structure maintained for each platform
- Google Ads: Campaign → Ad Group → Ads/Keywords
- Facebook Ads: Campaign → Ad Set → Ads
- Pinterest Ads: Advertiser → Campaign → Ad Group

### Email Marketing (Klaviyo)
- **Persons** (subscribers) perform **Events**
- **Campaigns** generate **Events**
- Events track complete email engagement lifecycle

### Social Media (Instagram)
- **Users** (accounts) own **Media Insights**
- Media insights track post-level performance metrics

## Data Types Legend
- **PK**: Primary Key
- **FK**: Foreign Key
- **integer/bigint**: Integer identifiers
- **string**: Text fields
- **float/decimal/numeric**: Numeric values
- **timestamp**: Date and time
- **date**: Date only
- **boolean**: True/false field