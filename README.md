# Ra Ecommerce Data Warehouse v2

A comprehensive dbt project for building a modern ecommerce data warehouse with multi-source integration, advanced analytics, and data quality monitoring.

[![dbt Version](https://img.shields.io/badge/dbt-1.10.4-blue.svg)](https://getdbt.com)
[![BigQuery](https://img.shields.io/badge/BigQuery-Supported-blue.svg)](https://cloud.google.com/bigquery)
[![Data Sources](https://img.shields.io/badge/Data%20Sources-8-green.svg)](#data-sources)

## 📋 Table of Contents

- [Overview](#overview)
- [Data Sources](#data-sources)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Data Loading](#data-loading)
- [Running the Project](#running-the-project)
- [Testing](#testing)
- [Data Quality Monitoring](#data-quality-monitoring)
- [Documentation](#documentation)
- [Project Structure](#project-structure)
- [Models Overview](#models-overview)
- [Business Use Cases](#business-use-cases)
- [Contributing](#contributing)

## 🎯 Overview

The Ra Ecommerce Data Warehouse v2 is a production-ready dbt project that integrates data from multiple ecommerce and marketing platforms to provide comprehensive business intelligence and analytics capabilities. The warehouse follows best practices for data modeling, includes extensive data quality monitoring, and provides pre-built analytics for common ecommerce use cases.

### Key Features

- **Multi-Source Integration**: Shopify, Google Analytics 4, Google/Facebook/Pinterest Ads, Klaviyo, Instagram Business
- **Layered Architecture**: Staging → Integration → Warehouse with clear separation of concerns
- **Data Quality Monitoring**: Comprehensive pipeline health tracking and data quality metrics
- **Attribution Analysis**: Multi-touch customer journey attribution across all touchpoints
- **Performance Analytics**: Campaign performance, customer segmentation, product analytics
- **SCD Type 2**: Slowly Changing Dimensions for customers and products
- **Comprehensive Testing**: 100+ data tests for data integrity and business rules
- **Documentation**: Full column-level documentation and business context

## 📊 Data Sources

| Source | Purpose | Tables | Status |
|--------|---------|--------|--------|
| **Shopify** | Ecommerce transactions | Orders, Customers, Products, Order Lines | ✅ Active |
| **Google Analytics 4** | Website behavior | Events, Sessions | ✅ Active |
| **Google Ads** | Paid search advertising | Campaigns, Ad Groups, Keywords, Ads | ✅ Active |
| **Facebook Ads** | Social media advertising | Campaigns, Ad Sets, Ads | ✅ Active |
| **Pinterest Ads** | Visual advertising | Campaigns, Ad Groups | ✅ Active |
| **Klaviyo** | Email marketing | Campaigns, Events, People | ✅ Active |
| **Instagram Business** | Social media content | Posts, Media Insights | ✅ Active |

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Raw Sources   │    │   Staging (stg) │    │ Integration(int)│
│                 │───▶│                 │───▶│                 │
│ • Shopify       │    │ • Cleaned       │    │ • Business      │
│ • GA4           │    │ • Standardized  │    │   Logic         │
│ • Ad Platforms  │    │ • Validated     │    │ • Calculations  │
│ • Email/Social  │    │                 │    │ • Joins         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                                        ▼
                                              ┌─────────────────┐
                                              │  Warehouse (wh) │
                                              │                 │
                                              │ • Dimensions    │
                                              │ • Facts         │
                                              │ • Aggregations  │
                                              │ • BI Ready      │
                                              └─────────────────┘
```

### Layer Descriptions

- **Staging**: Raw data cleaning, standardization, and basic validation
- **Integration**: Business logic application, cross-source joins, and metric calculations  
- **Warehouse**: Dimensional modeling with facts and dimensions optimized for analytics

## 🚀 Quick Start

### Prerequisites

- dbt Core 1.10+ 
- BigQuery project with billing enabled
- Python 3.8+
- Access to source data (or use provided seed data)

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ra_warehouse_ecommerce_v2

# Create and activate virtual environment
python -m venv dbt-ecomm-env
source dbt-ecomm-env/bin/activate  # On Windows: dbt-ecomm-env\Scripts\activate

# Install dependencies
pip install dbt-core dbt-bigquery
```

### 2. Configure dbt Profile

Create `~/.dbt/profiles.yml`:

```yaml
ra_dw_ecommerce:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: your-bigquery-project-id
      dataset: analytics_ecommerce
      keyfile: path/to/your/service-account.json
      threads: 4
      timeout_seconds: 300
      location: us-central1  # or your preferred location
```

### 3. Load Seed Data

```bash
# Load all seed data (demo datasets)
dbt seed

# Or load specific sources
dbt seed --select "shopify_demo"
dbt seed --select "ga4_demo" 
dbt seed --select "ad_platforms"
```

### 4. Run the Project

```bash
# Install dbt packages
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

## 💾 Data Loading

### Using Seed Data (Demo/Development)

The project includes comprehensive seed data for development and testing:

```bash
# Load all seed data
dbt seed

# Check what seeds are available
dbt ls --resource-type seed

# Load specific source seeds
dbt seed --select "tag:shopify"
dbt seed --select "tag:ga4"  
dbt seed --select "tag:marketing"
```

### Seed Data Included

- **Shopify**: 2,500+ orders, 500+ customers, 50+ products
- **GA4**: 10K+ events across 1K+ sessions
- **Ad Platforms**: Campaign performance data for Google/Facebook/Pinterest Ads
- **Klaviyo**: Email campaigns and engagement events
- **Instagram**: Social media posts and engagement metrics

### Production Data Sources

For production use, replace seed sources with your actual data sources:

1. Update `sources.yml` files in each staging folder
2. Replace `{{ source() }}` references with your actual table names
3. Configure your data pipeline to land data in the expected schemas

```yaml
# Example: models/staging/stg_shopify_ecommerce/sources.yml
sources:
  - name: shopify_raw
    description: Shopify production data
    schema: fivetran_shopify  # Your actual schema
    tables:
      - name: order
      - name: customer  
      - name: product
```

## 🏃‍♂️ Running the Project

### Basic Commands

```bash
# Run all models
dbt run

# Run specific layer
dbt run --select "staging"
dbt run --select "integration"  
dbt run --select "warehouse"

# Run specific source models
dbt run --select "+stg_shopify+"
dbt run --select "+int_customers+"

# Run with fail-fast
dbt run --fail-fast

# Run in parallel
dbt run --threads 8
```

### Incremental Runs

```bash
# Run only modified models and downstream dependencies
dbt run --select "state:modified+"

# Run models that failed in last run
dbt retry
```

### Development Workflow

```bash
# 1. Load/refresh seed data
dbt seed

# 2. Run staging models
dbt run --select "staging"

# 3. Run integration models  
dbt run --select "integration"

# 4. Run warehouse models
dbt run --select "warehouse"

# 5. Run tests
dbt test

# 6. Check data quality
dbt run --select "wh_fact_data_quality"
```

## 🧪 Testing

The project includes comprehensive testing at all layers:

### Test Categories

- **Schema Tests**: Uniqueness, not-null, relationships, accepted values
- **Data Tests**: Custom SQL tests for business logic validation
- **Quality Tests**: Data completeness, consistency, and integrity checks

### Running Tests

```bash
# Run all tests
dbt test

# Run tests for specific layers
dbt test --select "staging"
dbt test --select "integration" 
dbt test --select "warehouse"

# Run specific test types
dbt test --select "test_type:generic"
dbt test --select "test_type:singular"

# Run tests for specific model
dbt test --select "fact_orders"

# Store test results
dbt test --store-failures
```

### Key Tests

- **Referential Integrity**: Ensures all foreign keys have valid references
- **SCD Type 2 Integrity**: Validates slowly changing dimension logic
- **Attribution Weights**: Ensures customer journey attribution sums to 100%
- **Data Quality Metrics**: Validates pipeline health scores are within ranges
- **Business Rules**: Customer segments, product performance tiers, etc.

## 📊 Data Quality Monitoring

### Pipeline Health Dashboard

The warehouse includes comprehensive data quality monitoring through the `fact_data_quality` table:

```sql
-- Check overall pipeline health
SELECT 
    data_source,
    overall_pipeline_health_score,
    data_quality_rating,
    pipeline_efficiency_rating
FROM fact_data_quality
ORDER BY overall_pipeline_health_score DESC;
```

### Key Metrics Tracked

- **Data Flow Percentages**: Source → Staging → Integration → Warehouse
- **Test Pass Rates**: By layer and overall
- **Data Completeness**: Percentage of expected data present
- **Quality Scores**: 0-100 scoring across all dimensions
- **Pipeline Efficiency**: Performance and optimization ratings

### Quality Alerts

```sql
-- Identify data quality issues
SELECT data_source
FROM fact_data_quality
WHERE overall_pipeline_health_score < 85
   OR data_quality_rating = 'Poor'
   OR pipeline_efficiency_rating = 'Poor';
```

### Running Quality Checks

```bash
# Update data quality metrics
dbt run --select "int_data_pipeline_metadata"
dbt run --select "wh_fact_data_quality"

# Check quality test results  
dbt test --select "fact_data_quality"
```

## 📚 Documentation

### Generate Documentation

```bash
# Generate docs with model descriptions and lineage
dbt docs generate

# Serve documentation locally
dbt docs serve --port 8080
```

### Documentation Features

- **Model Descriptions**: Business purpose and context for each model
- **Column Documentation**: Detailed descriptions, data types, and constraints
- **Data Lineage**: Visual representation of model dependencies
- **Test Results**: Pass/fail status for all tests
- **Source Freshness**: Data recency checks

### User Guide

See [`docs/user_guide.md`](docs/user_guide.md) for:
- Business use cases and KPIs
- Pre-built SQL queries for common analytics
- Visualization specifications
- Dashboard creation guidance

## 📁 Project Structure

```
ra_warehouse_ecommerce_v2/
├── dbt_project.yml              # Project configuration
├── packages.yml                 # dbt package dependencies  
├── README.md                    # This file
├── docs/
│   └── user_guide.md           # Business user documentation
├── seeds/                       # Demo/reference data
│   ├── shopify_demo/           # Shopify seed data
│   ├── ga4_demo/               # GA4 seed data  
│   ├── google_ads/             # Google Ads seed data
│   ├── facebook_ads/           # Facebook Ads seed data
│   └── klaviyo/                # Email marketing seed data
├── models/
│   ├── staging/                # Data cleaning and standardization
│   │   ├── stg_shopify_ecommerce/
│   │   ├── stg_ga4_events/
│   │   ├── stg_google_ads/
│   │   ├── stg_facebook_ads/
│   │   ├── stg_pinterest_ads/
│   │   ├── stg_instagram_business/
│   │   └── stg_klaviyo_emails/
│   ├── integration/            # Business logic and cross-source joins
│   │   ├── int_customers.sql
│   │   ├── int_orders.sql
│   │   ├── int_products.sql
│   │   ├── int_sessions.sql
│   │   ├── int_campaigns.sql
│   │   ├── int_email_events.sql
│   │   └── int_customer_journey.sql
│   └── warehouse/              # Dimensional model (facts & dimensions)
│       ├── wh_dim_customers.sql
│       ├── wh_dim_products.sql
│       ├── wh_dim_date.sql
│       ├── fact_orders.sql
│       ├── fact_sessions.sql
│       ├── fact_customer_journey.sql
│       ├── fact_marketing_performance.sql
│       ├── fact_email_marketing.sql
│       └── fact_data_quality.sql
└── tests/                      # Custom SQL tests
```

## 🎯 Models Overview

### Staging Models (stg_)
Clean and standardize raw data with basic validation:

- **Shopify**: Orders, customers, products, order lines
- **GA4**: Page views, purchases, add-to-cart, session starts
- **Ad Platforms**: Campaigns, ad groups, ads with unified metrics
- **Klaviyo**: Email campaigns, events, person profiles
- **Instagram**: Social posts with engagement metrics

### Integration Models (int_)
Apply business logic and create cross-source relationships:

- **int_customers**: Customer metrics, segmentation, LTV calculations
- **int_orders**: Order aggregations, sequence analysis, classifications
- **int_products**: Product performance, inventory, revenue analysis
- **int_sessions**: Website session analysis with conversion indicators
- **int_campaigns**: Multi-platform campaign performance
- **int_customer_journey**: Cross-channel attribution and journey analysis
- **int_email_events**: Email engagement with customer context

### Warehouse Models (wh_)
Dimensional model optimized for analytics:

#### Dimensions
- **wh_dim_customers**: SCD Type 2 customer dimension with segments
- **wh_dim_products**: SCD Type 2 product dimension with performance metrics  
- **wh_dim_date**: Complete date dimension with fiscal calendar
- **wh_dim_channels_enhanced**: Marketing channel classifications
- **wh_dim_email_campaigns**: Email campaign details and categorization

#### Facts
- **fact_orders**: Order line items with full context and metrics
- **fact_sessions**: Website sessions with engagement and conversion data
- **fact_events**: Individual website events with context
- **fact_customer_journey**: Multi-touch attribution with weights
- **fact_marketing_performance**: Cross-platform advertising metrics
- **fact_email_marketing**: Email campaign performance and engagement
- **fact_social_posts**: Social media content performance
- **fact_data_quality**: Pipeline health and data quality monitoring

## 💼 Business Use Cases

The warehouse supports 9 comprehensive business use cases:

1. **Executive Overview**: High-level KPIs and business performance
2. **Sales & Orders**: Revenue tracking and order analysis
3. **Marketing & Attribution**: Cross-channel performance and ROI
4. **Website & User Engagement**: Session analysis and conversion funnels
5. **Customer Insights & Segments**: RFM analysis and customer lifetime value
6. **Product & Inventory**: Product performance and stock management
7. **Email & Campaign Performance**: Email marketing effectiveness
8. **Social Content Performance**: Social media engagement analysis
9. **Data Quality Monitoring**: Pipeline health and data completeness

See [`docs/user_guide.md`](docs/user_guide.md) for detailed queries and visualization specifications.

## 🔧 Configuration

### Key Configuration Files

- **dbt_project.yml**: Project settings, model configurations, variables
- **packages.yml**: External dbt package dependencies
- **sources.yml**: Source data definitions and freshness checks
- **schema.yml**: Model and column documentation with tests

### Environment Variables

```bash
# BigQuery project
export DBT_PROJECT_ID="your-project-id"

# Development vs production datasets  
export DBT_DATASET_SUFFIX="_dev"  # For development

# Data freshness settings
export DBT_SOURCE_FRESHNESS_WARN_AFTER="12 hours"
export DBT_SOURCE_FRESHNESS_ERROR_AFTER="24 hours"
```

### Model Materializations

- **Staging**: Tables (for performance with seed data)
- **Integration**: Tables (for complex transformations)
- **Warehouse**: Tables (for BI tool performance)
- **Large Facts**: Incremental (for production scale)

## 🤝 Contributing

### Development Workflow

1. **Branch**: Create feature branch from `main`
2. **Develop**: Make changes following project conventions
3. **Test**: Run `dbt test` and ensure all tests pass
4. **Document**: Update model documentation and README if needed  
5. **Quality**: Run `dbt run --select fact_data_quality` to check pipeline health
6. **PR**: Submit pull request with clear description

### Code Standards

- Follow dbt best practices for model organization
- Include comprehensive column-level documentation
- Add appropriate tests for all models
- Use consistent naming conventions
- Include business context in model descriptions

### Testing Requirements

- All models must have schema tests
- New business logic requires custom SQL tests  
- Maintain >95% test pass rate
- Update data quality monitoring when adding new sources

## 📞 Support

- **Documentation**: `dbt docs serve` for full model documentation
- **Issues**: Check data quality tables for pipeline health
- **Performance**: Use `dbt run --threads <n>` to adjust parallelism
- **Debugging**: Use `dbt --log-level debug` for detailed logging

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ using dbt and BigQuery**

*Ready to transform your ecommerce data into actionable insights!*