# Ra Ecommerce Data Warehouse - Data Flow Diagram

This document contains Mermaid diagrams showing the data flow through the Ra Ecommerce Data Warehouse from sources through staging, integration, and warehouse layers.

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

    %% Staging Layer
    subgraph Staging ["🧹 Staging Layer"]
        ST1[stg_shopify_ecommerce__*<br/>4 models]
        ST2[stg_ga4_events__*<br/>3 models]
        ST3[stg_google_ads__*<br/>4 models]
        ST4[stg_facebook_ads__*<br/>4 models]
        ST5[stg_pinterest_ads__*<br/>3 models]
        ST6[stg_klaviyo__*<br/>3 models]
        ST7[stg_instagram_business__*<br/>2 models]
    end

    %% Integration Layer
    subgraph Integration ["⚙️ Integration Layer"]
        INT1[int_customers<br/>Customer metrics & segments]
        INT2[int_orders<br/>Order aggregations]
        INT3[int_products<br/>Product performance]
        INT4[int_sessions<br/>Website sessions]
        INT5[int_events<br/>Website events]
        INT6[int_campaigns<br/>Unified campaigns]
        INT7[int_customer_journey<br/>Attribution analysis]
        INT8[int_email_events<br/>Email engagement]
        INT9[int_email_campaign_performance<br/>Email performance]
        INT10[int_data_pipeline_metadata<br/>Data quality monitoring]
    end

    %% Warehouse Layer
    subgraph Warehouse ["🏢 Warehouse Layer"]
        subgraph Dimensions ["📊 Dimensions"]
            D1[dim_customers<br/>SCD Type 2]
            D2[dim_products<br/>SCD Type 2]
            D3[dim_date<br/>Calendar dimension]
            D4[dim_channels_enhanced<br/>Marketing channels]
            D5[dim_email_campaigns<br/>Email campaigns]
        end
        
        subgraph Facts ["📈 Facts"]
            F1[fact_orders<br/>Order line items]
            F2[fact_sessions<br/>Website sessions]
            F3[fact_events<br/>User interactions]
            F4[fact_customer_journey<br/>Multi-touch attribution]
            F5[fact_marketing_performance<br/>Ad performance]
            F6[fact_email_marketing<br/>Email engagement]
            F7[fact_social_posts<br/>Social content]
            F8[fact_data_quality<br/>Pipeline health]
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

    INT1 --> D1
    INT1 --> F1
    INT2 --> F1
    INT3 --> D2
    INT3 --> F1
    INT4 --> F2
    INT5 --> F3
    INT6 --> F5
    INT7 --> F4
    INT8 --> F6
    INT9 --> D5
    INT9 --> F6
    INT10 --> F8

    %% Cross-references
    D3 --> F1
    D3 --> F2
    D3 --> F3
    D3 --> F4
    D3 --> F5
    D3 --> F6
    D3 --> F7
    D3 --> F8
    D4 --> F2
    D4 --> F4
    D4 --> F5

    classDef sourceStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef stagingStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef integrationStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef warehouseStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef dimensionStyle fill:#fff8e1,stroke:#f57f17,stroke-width:2px
    classDef factStyle fill:#fce4ec,stroke:#ad1457,stroke-width:2px

    class S1,S2,S3,S4,S5,S6,S7 sourceStyle
    class ST1,ST2,ST3,ST4,ST5,ST6,ST7 stagingStyle
    class INT1,INT2,INT3,INT4,INT5,INT6,INT7,INT8,INT9,INT10 integrationStyle
    class D1,D2,D3,D4,D5 dimensionStyle
    class F1,F2,F3,F4,F5,F6,F7,F8 factStyle
```

## Detailed Integration Layer Flow

```mermaid
graph TD
    %% Staging Inputs
    subgraph StagingInputs ["🧹 Staging Models"]
        ST_SHOP[stg_shopify_ecommerce__*<br/>customers, orders, order_lines, products]
        ST_GA4[stg_ga4_events__*<br/>page_view, purchase, add_to_cart]
        ST_GAD[stg_google_ads__campaigns]
        ST_FB[stg_facebook_ads__campaigns]
        ST_PIN[stg_pinterest_ads__campaigns]
        ST_KLAV[stg_klaviyo__*<br/>campaign, event, person]
        ST_INSTA[stg_instagram_business__*]
    end

    %% Integration Models
    subgraph CoreIntegration ["⚙️ Core Integration"]
        INT_CUST[int_customers<br/>- Customer segments<br/>- LTV calculations<br/>- Churn risk scoring]
        INT_ORD[int_orders<br/>- Order aggregations<br/>- Sequence analysis<br/>- Order classifications]
        INT_PROD[int_products<br/>- Performance metrics<br/>- Revenue tiers<br/>- Inventory status]
        INT_SESS[int_sessions<br/>- Session metrics<br/>- Conversion indicators<br/>- Engagement scoring]
        INT_EVENTS[int_events<br/>- Event standardization<br/>- Business context<br/>- Custom parameters]
    end

    subgraph MarketingIntegration ["📢 Marketing Integration"]
        INT_CAMP[int_campaigns<br/>- Multi-platform unification<br/>- Performance tiers<br/>- Campaign classification]
        INT_JOURNEY[int_customer_journey<br/>- Attribution weights<br/>- Journey complexity<br/>- Conversion timeline]
        INT_EMAIL_EVENTS[int_email_events<br/>- Event unification<br/>- Customer context<br/>- UTM attribution]
        INT_EMAIL_PERF[int_email_campaign_performance<br/>- Aggregated metrics<br/>- Performance tiers<br/>- Effectiveness indicators]
    end

    subgraph QualityIntegration ["🔍 Quality Integration"]
        INT_PIPELINE[int_data_pipeline_metadata<br/>- Flow percentages<br/>- Row counts by layer<br/>- Table counts]
    end

    %% Connections from Staging to Integration
    ST_SHOP --> INT_CUST
    ST_SHOP --> INT_ORD
    ST_SHOP --> INT_PROD
    ST_SHOP --> INT_JOURNEY
    
    ST_GA4 --> INT_SESS
    ST_GA4 --> INT_EVENTS
    ST_GA4 --> INT_JOURNEY
    
    ST_GAD --> INT_CAMP
    ST_FB --> INT_CAMP
    ST_PIN --> INT_CAMP
    
    ST_KLAV --> INT_EMAIL_EVENTS
    ST_KLAV --> INT_EMAIL_PERF
    
    ST_SHOP --> INT_PIPELINE
    ST_GA4 --> INT_PIPELINE
    ST_GAD --> INT_PIPELINE
    ST_FB --> INT_PIPELINE
    ST_PIN --> INT_PIPELINE
    ST_KLAV --> INT_PIPELINE
    ST_INSTA --> INT_PIPELINE

    %% Cross-integration dependencies
    INT_CUST --> INT_JOURNEY
    INT_ORD --> INT_JOURNEY
    INT_SESS --> INT_JOURNEY

    classDef stagingStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef coreStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef marketingStyle fill:#e3f2fd,stroke:#0d47a1,stroke-width:2px
    classDef qualityStyle fill:#fff3e0,stroke:#e65100,stroke-width:2px

    class ST_SHOP,ST_GA4,ST_GAD,ST_FB,ST_PIN,ST_KLAV,ST_INSTA stagingStyle
    class INT_CUST,INT_ORD,INT_PROD,INT_SESS,INT_EVENTS coreStyle
    class INT_CAMP,INT_JOURNEY,INT_EMAIL_EVENTS,INT_EMAIL_PERF marketingStyle
    class INT_PIPELINE qualityStyle
```

## Detailed Warehouse Layer Flow

```mermaid
graph TD
    %% Integration Inputs
    subgraph IntegrationInputs ["⚙️ Integration Models"]
        INT_CUST[int_customers]
        INT_ORD[int_orders]
        INT_PROD[int_products]
        INT_SESS[int_sessions]
        INT_EVENTS[int_events]
        INT_CAMP[int_campaigns]
        INT_JOURNEY[int_customer_journey]
        INT_EMAIL_EVENTS[int_email_events]
        INT_EMAIL_PERF[int_email_campaign_performance]
        INT_PIPELINE[int_data_pipeline_metadata]
    end

    %% Warehouse Dimensions
    subgraph Dimensions ["📊 Dimension Tables"]
        DIM_CUST[dim_customers<br/>- SCD Type 2<br/>- Customer segments<br/>- Predictive analytics<br/>- Churn risk scoring]
        DIM_PROD[dim_products<br/>- SCD Type 2<br/>- Performance tiers<br/>- Profitability analysis<br/>- Inventory status]
        DIM_DATE[dim_date<br/>- Calendar attributes<br/>- Fiscal calendar<br/>- Holiday indicators<br/>- Business periods]
        DIM_CHAN[dim_channels_enhanced<br/>- Channel categorization<br/>- Attribution models<br/>- Cost tracking flags]
        DIM_EMAIL[dim_email_campaigns<br/>- Campaign categorization<br/>- Strategy attributes<br/>- Audience segments]
    end

    %% Warehouse Facts
    subgraph Facts ["📈 Fact Tables"]
        FACT_ORD[fact_orders<br/>- Line item grain<br/>- Full dimensional context<br/>- Attribution fields<br/>- Profitability metrics]
        FACT_SESS[fact_sessions<br/>- Session grain<br/>- Engagement metrics<br/>- Conversion indicators<br/>- Predictive scores]
        FACT_EVENTS[fact_events<br/>- Event grain<br/>- Interaction details<br/>- Custom parameters<br/>- Engagement weights]
        FACT_JOURNEY[fact_customer_journey<br/>- Touchpoint grain<br/>- Multi-touch attribution<br/>- Journey complexity<br/>- Conversion analysis]
        FACT_MARKETING[fact_marketing_performance<br/>- Campaign performance<br/>- Unified metrics<br/>- ROI calculations<br/>- Platform comparisons]
        FACT_EMAIL[fact_email_marketing<br/>- Email engagement<br/>- Campaign attribution<br/>- Customer segmentation<br/>- Performance metrics]
        FACT_SOCIAL[fact_social_posts<br/>- Content performance<br/>- Engagement analysis<br/>- Timing optimization<br/>- Audience insights]
        FACT_QUALITY[fact_data_quality<br/>- Pipeline health<br/>- Data completeness<br/>- Test pass rates<br/>- Quality scoring]
    end

    %% Integration to Dimensions
    INT_CUST --> DIM_CUST
    INT_PROD --> DIM_PROD
    INT_EMAIL_PERF --> DIM_EMAIL

    %% Integration to Facts
    INT_CUST --> FACT_ORD
    INT_ORD --> FACT_ORD
    INT_PROD --> FACT_ORD
    INT_SESS --> FACT_SESS
    INT_EVENTS --> FACT_EVENTS
    INT_JOURNEY --> FACT_JOURNEY
    INT_CAMP --> FACT_MARKETING
    INT_EMAIL_EVENTS --> FACT_EMAIL
    INT_EMAIL_PERF --> FACT_EMAIL
    INT_PIPELINE --> FACT_QUALITY

    %% Dimensional Relationships
    DIM_CUST --> FACT_ORD
    DIM_CUST --> FACT_JOURNEY
    DIM_PROD --> FACT_ORD
    DIM_DATE --> FACT_ORD
    DIM_DATE --> FACT_SESS
    DIM_DATE --> FACT_EVENTS
    DIM_DATE --> FACT_JOURNEY
    DIM_DATE --> FACT_MARKETING
    DIM_DATE --> FACT_EMAIL
    DIM_DATE --> FACT_SOCIAL
    DIM_DATE --> FACT_QUALITY
    DIM_CHAN --> FACT_SESS
    DIM_CHAN --> FACT_JOURNEY
    DIM_CHAN --> FACT_MARKETING
    DIM_EMAIL --> FACT_EMAIL

    %% Fact to Fact Relationships
    FACT_SESS --> FACT_EVENTS
    FACT_SESS --> FACT_JOURNEY
    FACT_ORD --> FACT_JOURNEY

    classDef integrationStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef dimensionStyle fill:#fff8e1,stroke:#f57f17,stroke-width:2px
    classDef factStyle fill:#fce4ec,stroke:#ad1457,stroke-width:2px

    class INT_CUST,INT_ORD,INT_PROD,INT_SESS,INT_EVENTS,INT_CAMP,INT_JOURNEY,INT_EMAIL_EVENTS,INT_EMAIL_PERF,INT_PIPELINE integrationStyle
    class DIM_CUST,DIM_PROD,DIM_DATE,DIM_CHAN,DIM_EMAIL dimensionStyle
    class FACT_ORD,FACT_SESS,FACT_EVENTS,FACT_JOURNEY,FACT_MARKETING,FACT_EMAIL,FACT_SOCIAL,FACT_QUALITY factStyle
```

## Data Quality and Monitoring Flow

```mermaid
graph LR
    %% Data Sources
    subgraph Sources ["📥 Sources"]
        SRC[Source Tables<br/>Raw Data]
    end

    %% Pipeline Stages
    subgraph Pipeline ["🔄 Data Pipeline"]
        STG[Staging Layer<br/>Clean & Standardize]
        INT[Integration Layer<br/>Business Logic]
        WH[Warehouse Layer<br/>Analytics Ready]
    end

    %% Monitoring
    subgraph Monitoring ["📊 Data Quality Monitoring"]
        META[int_data_pipeline_metadata<br/>- Row counts by layer<br/>- Flow percentages<br/>- Table counts]
        QUALITY[fact_data_quality<br/>- Test pass rates<br/>- Completeness scores<br/>- Health ratings]
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
- SCD Type 2 for customers and products
- Conformed dimensions across fact tables
- Star schema optimized for BI tools

### 5. **Attribution & Journey Analysis**
- Multi-touch attribution with configurable models
- Customer journey complexity classification
- Cross-channel conversion analysis