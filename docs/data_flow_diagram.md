# Ra Ecommerce Data Warehouse - Data Flow Diagram

This document contains Mermaid diagrams showing the data flow through the Ra Ecommerce Data Warehouse from sources through staging, integration, and warehouse layers using actual BigQuery table names.

## Overall Data Flow Architecture

```mermaid
graph TD
    %% Data Sources
    subgraph Sources ["🔌 Data Sources"]
        S1[Shopify<br/>Orders, Customers, Products]
        S2[Google Analytics 4<br/>Events, Sessions]
        S3[Google Ads<br/>Campaigns, Performance]
        S4[Facebook Ads<br/>Campaigns, Performance]
        S5[Pinterest Ads<br/>Campaigns, Performance]
        S6[Klaviyo<br/>Email Campaigns, Events]
        S7[Instagram Business<br/>Posts, Engagement]
    end

    %% Staging Layer - analytics_ecommerce_staging
    subgraph Staging ["🧹 Staging Layer<br/>Dataset: analytics_ecommerce_staging"]
        ST1[stg_shopify_ecommerce__*<br/>customers, orders, order_lines,<br/>products, transactions, discounts,<br/>inventory_levels, customer_cohorts,<br/>daily_shop]
        ST2[stg_ga4_events__*<br/>page_view, purchase, add_to_cart,<br/>add_to_cart_items, add_payment_info,<br/>add_shipping_info, begin_checkout,<br/>session_start, view_item]
        ST3[stg_google_ads__*<br/>campaigns, ad_groups, ads, keywords]
        ST4[stg_facebook_ads__*<br/>campaigns, ad_sets, ads]
        ST5[stg_pinterest_ads__*<br/>campaigns, ad_groups, advertisers]
        ST6[stg_klaviyo__*<br/>campaign, event, person]
        ST7[stg_instagram_business__*<br/>media_insights, users]
    end

    %% Integration Layer - analytics_ecommerce_integration
    subgraph Integration ["⚙️ Integration Layer<br/>Dataset: analytics_ecommerce_integration"]
        INT1[int_customers<br/>Customer metrics & segments]
        INT2[int_orders<br/>Order aggregations]
        INT3[int_products<br/>Product performance]
        INT4[int_sessions & int_ga4_sessions<br/>Website sessions]
        INT5[int_events<br/>Website events]
        INT6[int_campaigns<br/>Unified campaigns]
        INT7[int_customer_journey<br/>Attribution analysis]
        INT8[int_email_events &<br/>int_klaviyo_email_events<br/>Email engagement]
        INT9[int_email_campaign_performance &<br/>int_klaviyo_campaign_performance<br/>Email performance]
        INT10[int_data_pipeline_metadata<br/>Data quality monitoring]
        INT11[int_channels_enhanced &<br/>int_channels_working<br/>Channel mappings]
        INT12[int_categories_simple<br/>Product categories]
        INT13[int_inventory_simple<br/>Inventory status]
        INT14[int_customer_metrics_simple<br/>Customer KPIs]
    end

    %% Warehouse Layer - analytics_ecommerce_ecommerce
    subgraph Warehouse ["🏢 Warehouse Layer<br/>Dataset: analytics_ecommerce_ecommerce"]
        subgraph Dimensions ["📊 Dimensions"]
            D1[dim_customers<br/>SCD Type 2]
            D2[dim_products<br/>Product master]
            D3[dim_date<br/>Calendar dimension]
            D4[dim_channels<br/>Marketing channels]
            D5[dim_customer_metrics<br/>Customer analytics]
            D6[dim_categories<br/>Product hierarchy]
            D7[dim_social_content<br/>Social content]
        end
        
        subgraph Facts ["📈 Facts"]
            F1[fact_orders<br/>Order header grain]
            F2[fact_order_items<br/>Order line grain]
            F3[fact_sessions<br/>Website sessions]
            F4[fact_events<br/>User interactions]
            F5[fact_customer_journey<br/>Multi-touch attribution]
            F6[fact_marketing_performance<br/>Ad performance]
            F7[fact_email_marketing<br/>Email engagement]
            F8[fact_social_posts<br/>Social content]
            F9[fact_inventory<br/>Stock levels]
            F10[fact_ad_spend<br/>Daily ad costs]
            F11[fact_ad_attribution<br/>Ad conversions]
            F12[fact_data_quality<br/>Pipeline health]
        end
    end

    %% Data Flow Connections
    S1 --> ST1
    S2 --> ST2
    S3 --> ST3
    S4 --> ST4
    S5 --> ST5
    S6 --> ST6
    S7 --> ST7

    ST1 --> INT1
    ST1 --> INT2
    ST1 --> INT3
    ST1 --> INT13
    ST1 --> INT14
    ST2 --> INT4
    ST2 --> INT5
    ST3 --> INT6
    ST4 --> INT6
    ST5 --> INT6
    ST2 --> INT7
    ST1 --> INT7
    ST6 --> INT8
    ST6 --> INT9
    ST1 --> INT10
    ST2 --> INT10
    ST3 --> INT10
    ST4 --> INT10
    ST5 --> INT10
    ST6 --> INT10
    ST7 --> INT10
    ST1 --> INT11
    ST2 --> INT11
    ST1 --> INT12

    INT1 --> D1
    INT1 --> F1
    INT2 --> F1
    INT3 --> D2
    INT3 --> F1
    INT3 --> F2
    INT4 --> F3
    INT5 --> F4
    INT6 --> F6
    INT6 --> F10
    INT6 --> F11
    INT7 --> F5
    INT8 --> F7
    INT9 --> F7
    INT10 --> F12
    INT11 --> D4
    INT12 --> D6
    INT13 --> F9
    INT14 --> D5

    %% Cross-references
    D3 -.-> F1
    D3 -.-> F2
    D3 -.-> F3
    D3 -.-> F4
    D3 -.-> F5
    D3 -.-> F6
    D3 -.-> F7
    D3 -.-> F8
    D3 -.-> F9
    D3 -.-> F10
    D3 -.-> F11
    D3 -.-> F12
    D4 -.-> F1
    D4 -.-> F3
    D4 -.-> F5
    D4 -.-> F6
    D4 -.-> F10
    D4 -.-> F11

    classDef sourceStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef stagingStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef integrationStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef warehouseStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef dimensionStyle fill:#fff8e1,stroke:#f57f17,stroke-width:2px
    classDef factStyle fill:#fce4ec,stroke:#ad1457,stroke-width:2px

    class S1,S2,S3,S4,S5,S6,S7 sourceStyle
    class ST1,ST2,ST3,ST4,ST5,ST6,ST7 stagingStyle
    class INT1,INT2,INT3,INT4,INT5,INT6,INT7,INT8,INT9,INT10,INT11,INT12,INT13,INT14 integrationStyle
    class D1,D2,D3,D4,D5,D6,D7 dimensionStyle
    class F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12 factStyle
```

## Detailed Staging Layer Tables

```mermaid
graph TD
    %% Shopify Staging Tables
    subgraph ShopifyStaging ["Shopify Staging Tables"]
        SHOP1[stg_shopify_ecommerce__customers<br/>Customer profiles]
        SHOP2[stg_shopify_ecommerce__orders<br/>Order headers with UTM data]
        SHOP3[stg_shopify_ecommerce__order_lines<br/>Line item details]
        SHOP4[stg_shopify_ecommerce__products<br/>Product catalog]
        SHOP5[stg_shopify_ecommerce__transactions<br/>Payment transactions]
        SHOP6[stg_shopify_ecommerce__discounts<br/>Discount codes]
        SHOP7[stg_shopify_ecommerce__inventory_levels<br/>Stock levels]
        SHOP8[stg_shopify_ecommerce__customer_cohorts<br/>Cohort analysis]
        SHOP9[stg_shopify_ecommerce__daily_shop<br/>Daily metrics]
    end

    %% GA4 Staging Tables
    subgraph GA4Staging ["GA4 Event Staging Tables"]
        GA1[stg_ga4_events__page_view<br/>Page views with traffic source]
        GA2[stg_ga4_events__purchase<br/>Ecommerce conversions]
        GA3[stg_ga4_events__add_to_cart<br/>Product interest]
        GA4[stg_ga4_events__add_to_cart_items<br/>Cart item details]
        GA5[stg_ga4_events__add_payment_info<br/>Checkout progress]
        GA6[stg_ga4_events__add_shipping_info<br/>Shipping selection]
        GA7[stg_ga4_events__begin_checkout<br/>Checkout initiation]
        GA8[stg_ga4_events__session_start<br/>Session initialization]
        GA9[stg_ga4_events__view_item<br/>Product views]
    end

    %% Ad Platform Staging
    subgraph AdStaging ["Advertising Platform Staging"]
        AD1[stg_google_ads__campaigns<br/>stg_google_ads__ad_groups<br/>stg_google_ads__ads<br/>stg_google_ads__keywords]
        AD2[stg_facebook_ads__campaigns<br/>stg_facebook_ads__ad_sets<br/>stg_facebook_ads__ads]
        AD3[stg_pinterest_ads__campaigns<br/>stg_pinterest_ads__ad_groups<br/>stg_pinterest_ads__advertisers]
    end

    %% Email & Social Staging
    subgraph EmailSocialStaging ["Email & Social Staging"]
        ES1[stg_klaviyo__campaign<br/>Email campaigns]
        ES2[stg_klaviyo__event<br/>Email events]
        ES3[stg_klaviyo__person<br/>Email subscribers]
        ES4[stg_instagram_business__media_insights<br/>Post performance]
        ES5[stg_instagram_business__users<br/>Account metrics]
    end

    classDef shopifyStyle fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px
    classDef ga4Style fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef adStyle fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef emailStyle fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px

    class SHOP1,SHOP2,SHOP3,SHOP4,SHOP5,SHOP6,SHOP7,SHOP8,SHOP9 shopifyStyle
    class GA1,GA2,GA3,GA4,GA5,GA6,GA7,GA8,GA9 ga4Style
    class AD1,AD2,AD3 adStyle
    class ES1,ES2,ES3,ES4,ES5 emailStyle
```

## Detailed Integration Layer Flow

```mermaid
graph TD
    %% Staging Inputs
    subgraph StagingInputs ["🧹 Staging Tables"]
        ST_SHOP[Shopify Tables<br/>9 staging tables]
        ST_GA4[GA4 Event Tables<br/>9 event types]
        ST_ADS[Ad Platform Tables<br/>Google, Facebook, Pinterest]
        ST_EMAIL[Klaviyo Tables<br/>Campaigns, Events, Persons]
        ST_SOCIAL[Instagram Tables<br/>Media, Users]
    end

    %% Integration Models
    subgraph CoreIntegration ["⚙️ Core Integration"]
        INT_CUST[int_customers<br/>- Customer segments<br/>- LTV calculations<br/>- Activity metrics]
        INT_ORD[int_orders<br/>- Order aggregations<br/>- Sequence analysis<br/>- Order classifications]
        INT_PROD[int_products<br/>- Performance metrics<br/>- Revenue tiers<br/>- Sales velocity]
        INT_SESS[int_sessions & int_ga4_sessions<br/>- Session metrics<br/>- Conversion indicators<br/>- Engagement scoring]
        INT_EVENTS[int_events<br/>- Event standardization<br/>- Business context]
    end

    subgraph MarketingIntegration ["📢 Marketing Integration"]
        INT_CAMP[int_campaigns<br/>- Multi-platform unification<br/>- Performance tiers<br/>- Efficiency scoring]
        INT_JOURNEY[int_customer_journey<br/>- Attribution weights<br/>- Journey complexity<br/>- Conversion paths]
        INT_EMAIL[int_email_events &<br/>int_klaviyo_email_events<br/>- Event unification<br/>- Customer context]
        INT_EMAIL_PERF[int_email_campaign_performance &<br/>int_klaviyo_campaign_performance<br/>- Aggregated metrics<br/>- Performance tiers]
        INT_CHAN[int_channels_enhanced &<br/>int_channels_working<br/>- Channel mapping<br/>- Attribution setup]
    end

    subgraph OperationalIntegration ["📦 Operational Integration"]
        INT_CAT[int_categories_simple<br/>- Category hierarchy<br/>- Product groupings]
        INT_INV[int_inventory_simple<br/>- Stock levels<br/>- Availability status]
        INT_METRICS[int_customer_metrics_simple<br/>- RFM calculations<br/>- Customer KPIs]
    end

    subgraph QualityIntegration ["🔍 Quality Integration"]
        INT_PIPELINE[int_data_pipeline_metadata<br/>- Flow percentages<br/>- Row counts by layer<br/>- Table counts]
    end

    %% Connections from Staging to Integration
    ST_SHOP --> INT_CUST
    ST_SHOP --> INT_ORD
    ST_SHOP --> INT_PROD
    ST_SHOP --> INT_JOURNEY
    ST_SHOP --> INT_CAT
    ST_SHOP --> INT_INV
    ST_SHOP --> INT_METRICS
    ST_SHOP --> INT_CHAN
    
    ST_GA4 --> INT_SESS
    ST_GA4 --> INT_EVENTS
    ST_GA4 --> INT_JOURNEY
    ST_GA4 --> INT_CHAN
    
    ST_ADS --> INT_CAMP
    
    ST_EMAIL --> INT_EMAIL
    ST_EMAIL --> INT_EMAIL_PERF
    
    ST_SHOP --> INT_PIPELINE
    ST_GA4 --> INT_PIPELINE
    ST_ADS --> INT_PIPELINE
    ST_EMAIL --> INT_PIPELINE
    ST_SOCIAL --> INT_PIPELINE

    %% Cross-integration dependencies
    INT_CUST --> INT_JOURNEY
    INT_ORD --> INT_JOURNEY
    INT_SESS --> INT_JOURNEY

    classDef stagingStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef coreStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef marketingStyle fill:#e3f2fd,stroke:#0d47a1,stroke-width:2px
    classDef operationalStyle fill:#fff9c4,stroke:#f9a825,stroke-width:2px
    classDef qualityStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px

    class ST_SHOP,ST_GA4,ST_ADS,ST_EMAIL,ST_SOCIAL stagingStyle
    class INT_CUST,INT_ORD,INT_PROD,INT_SESS,INT_EVENTS coreStyle
    class INT_CAMP,INT_JOURNEY,INT_EMAIL,INT_EMAIL_PERF,INT_CHAN marketingStyle
    class INT_CAT,INT_INV,INT_METRICS operationalStyle
    class INT_PIPELINE qualityStyle
```

## Detailed Warehouse Layer Flow

```mermaid
graph TD
    %% Integration Inputs
    subgraph IntegrationInputs ["⚙️ Integration Tables"]
        INT_CUST[int_customers]
        INT_ORD[int_orders]
        INT_PROD[int_products]
        INT_SESS[int_sessions/int_ga4_sessions]
        INT_EVENTS[int_events]
        INT_CAMP[int_campaigns]
        INT_JOURNEY[int_customer_journey]
        INT_EMAIL[int_email_events]
        INT_EMAIL_PERF[int_email_campaign_performance]
        INT_CHAN[int_channels_enhanced]
        INT_CAT[int_categories_simple]
        INT_INV[int_inventory_simple]
        INT_METRICS[int_customer_metrics_simple]
        INT_PIPELINE[int_data_pipeline_metadata]
    end

    %% Warehouse Dimensions
    subgraph Dimensions ["📊 Dimension Tables"]
        DIM_CUST[dim_customers<br/>- SCD Type 2<br/>- 40+ attributes<br/>- Segmentation]
        DIM_PROD[dim_products<br/>- Product master<br/>- Performance metrics]
        DIM_DATE[dim_date<br/>- Calendar attributes<br/>- Fiscal calendar]
        DIM_CHAN[dim_channels<br/>- Channel mapping<br/>- Attribution setup]
        DIM_METRICS[dim_customer_metrics<br/>- RFM segments<br/>- Predictive scores]
        DIM_CAT[dim_categories<br/>- Category hierarchy]
        DIM_SOCIAL[dim_social_content<br/>- Content attributes]
    end

    %% Warehouse Facts
    subgraph Facts ["📈 Fact Tables"]
        FACT_ORD[fact_orders<br/>- Order header grain<br/>- 68 columns<br/>- Comprehensive metrics]
        FACT_ITEMS[fact_order_items<br/>- Line item grain<br/>- Product detail]
        FACT_SESS[fact_sessions<br/>- Session grain<br/>- Engagement metrics]
        FACT_EVENTS[fact_events<br/>- Event grain<br/>- User interactions]
        FACT_JOURNEY[fact_customer_journey<br/>- Attribution analysis<br/>- Multi-touch models]
        FACT_MARKETING[fact_marketing_performance<br/>- Daily campaign metrics<br/>- Cross-platform]
        FACT_EMAIL[fact_email_marketing<br/>- Email event grain<br/>- Engagement tracking]
        FACT_SOCIAL[fact_social_posts<br/>- Post performance<br/>- Engagement metrics]
        FACT_INV[fact_inventory<br/>- Daily snapshots<br/>- Stock levels]
        FACT_SPEND[fact_ad_spend<br/>- Daily ad costs<br/>- Budget tracking]
        FACT_ATTR[fact_ad_attribution<br/>- Conversion attribution<br/>- Click/view through]
        FACT_QUALITY[fact_data_quality<br/>- Pipeline monitoring<br/>- Quality scores]
    end

    %% Integration to Dimensions
    INT_CUST --> DIM_CUST
    INT_PROD --> DIM_PROD
    INT_CHAN --> DIM_CHAN
    INT_CAT --> DIM_CAT
    INT_METRICS --> DIM_METRICS

    %% Integration to Facts
    INT_CUST --> FACT_ORD
    INT_ORD --> FACT_ORD
    INT_PROD --> FACT_ORD
    INT_PROD --> FACT_ITEMS
    INT_SESS --> FACT_SESS
    INT_EVENTS --> FACT_EVENTS
    INT_JOURNEY --> FACT_JOURNEY
    INT_CAMP --> FACT_MARKETING
    INT_CAMP --> FACT_SPEND
    INT_CAMP --> FACT_ATTR
    INT_EMAIL --> FACT_EMAIL
    INT_EMAIL_PERF --> FACT_EMAIL
    INT_INV --> FACT_INV
    INT_PIPELINE --> FACT_QUALITY

    %% Dimensional Relationships
    DIM_CUST -.-> FACT_ORD
    DIM_CUST -.-> FACT_ITEMS
    DIM_CUST -.-> FACT_JOURNEY
    DIM_CUST -.-> FACT_ATTR
    DIM_PROD -.-> FACT_ITEMS
    DIM_PROD -.-> FACT_INV
    DIM_DATE -.-> "All Facts"
    DIM_CHAN -.-> FACT_ORD
    DIM_CHAN -.-> FACT_SESS
    DIM_CHAN -.-> FACT_JOURNEY
    DIM_CHAN -.-> FACT_MARKETING
    DIM_CHAN -.-> FACT_SPEND
    DIM_CHAN -.-> FACT_ATTR
    DIM_SOCIAL -.-> FACT_SOCIAL

    classDef integrationStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef dimensionStyle fill:#fff8e1,stroke:#f57f17,stroke-width:2px
    classDef factStyle fill:#fce4ec,stroke:#ad1457,stroke-width:2px

    class INT_CUST,INT_ORD,INT_PROD,INT_SESS,INT_EVENTS,INT_CAMP,INT_JOURNEY,INT_EMAIL,INT_EMAIL_PERF,INT_CHAN,INT_CAT,INT_INV,INT_METRICS,INT_PIPELINE integrationStyle
    class DIM_CUST,DIM_PROD,DIM_DATE,DIM_CHAN,DIM_METRICS,DIM_CAT,DIM_SOCIAL dimensionStyle
    class FACT_ORD,FACT_ITEMS,FACT_SESS,FACT_EVENTS,FACT_JOURNEY,FACT_MARKETING,FACT_EMAIL,FACT_SOCIAL,FACT_INV,FACT_SPEND,FACT_ATTR,FACT_QUALITY factStyle
```

## Data Quality and Monitoring Flow

```mermaid
graph LR
    %% Data Sources
    subgraph Sources ["📥 Sources"]
        SRC[Source Tables<br/>Raw Data from<br/>7 platforms]
    end

    %% Pipeline Stages with BigQuery Datasets
    subgraph Pipeline ["🔄 Data Pipeline"]
        STG[Staging Layer<br/>analytics_ecommerce_staging<br/>18 table groups]
        INT[Integration Layer<br/>analytics_ecommerce_integration<br/>18 tables]
        WH[Warehouse Layer<br/>analytics_ecommerce_ecommerce<br/>7 dims + 12 facts]
    end

    %% Monitoring
    subgraph Monitoring ["📊 Data Quality Monitoring"]
        META[int_data_pipeline_metadata<br/>- Row counts by layer<br/>- Flow percentages<br/>- Table counts]
        QUALITY[fact_data_quality<br/>- Test pass rates<br/>- Completeness scores<br/>- Health ratings<br/>- Pipeline efficiency]
    end

    %% Flow with Monitoring
    SRC --> STG
    STG --> INT
    INT --> WH
    
    SRC -.-> META
    STG -.-> META
    INT -.-> META
    WH -.-> META
    
    META --> QUALITY
    
    %% Feedback Loop
    QUALITY -.-> SRC
    QUALITY -.-> STG
    QUALITY -.-> INT
    QUALITY -.-> WH

    classDef sourceStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef pipelineStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef monitoringStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px

    class SRC sourceStyle
    class STG,INT,WH pipelineStyle
    class META,QUALITY monitoringStyle
```

## BigQuery Dataset Organization

### **analytics_ecommerce_staging**
- **Purpose**: Clean and standardize raw data
- **Tables**: 18+ staging tables across 7 data sources
- **Naming**: `stg_{source}__{entity}`
- **Key Features**: Data type casting, field renaming, basic calculations

### **analytics_ecommerce_integration**
- **Purpose**: Business logic and cross-source integration
- **Tables**: 18 integration tables
- **Naming**: `int_{business_concept}`
- **Key Features**: Calculated metrics, segmentation, attribution prep

### **analytics_ecommerce_ecommerce**
- **Purpose**: Analytics-ready dimensional model
- **Tables**: 7 dimensions + 12 fact tables
- **Naming**: `dim_{entity}` and `fact_{metric}`
- **Key Features**: SCD Type 2, conformed dimensions, comprehensive facts

## Key Data Flow Principles

### 1. **Layered Architecture**
- **Staging**: Clean, standardize, and validate raw data
- **Integration**: Apply business logic and create cross-source relationships
- **Warehouse**: Dimensional modeling optimized for analytics

### 2. **Source-Agnostic Integration**
- Multiple ad platforms unified into `int_campaigns`
- Email events standardized across campaign types
- Attribution analysis combines all touchpoints

### 3. **Comprehensive Monitoring**
- Every layer tracked for row counts and data flow
- Test pass rates monitored at each stage
- Quality scores calculated for pipeline health

### 4. **Dimensional Modeling**
- SCD Type 2 for customers (tracking changes over time)
- Conformed dimensions across fact tables
- Star schema optimized for BI tools

### 5. **Attribution & Journey Analysis**
- Multi-touch attribution with configurable models
- Customer journey complexity classification
- Cross-channel conversion analysis