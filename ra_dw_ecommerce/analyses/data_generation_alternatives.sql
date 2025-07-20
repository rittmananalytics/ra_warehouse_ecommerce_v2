/*
  Data Generation Alternatives for dbt Projects
  
  This file documents different approaches for managing data generation
  scripts in a dbt project, following industry best practices.
*/

-- ============================================================================
-- APPROACH 1: dbt-native SQL Generation (Recommended for simple datasets)
-- ============================================================================

/*
  For simple datasets, you can generate data directly in SQL using dbt models.
  This keeps everything within the dbt ecosystem.
  
  Example: Generate a simple date dimension using dbt_utils.date_spine()
  See dbt_utils documentation for proper syntax.
*/


-- ============================================================================
-- APPROACH 2: dbt Hooks for Script Execution  
-- ============================================================================

/*
  Use dbt hooks to run Python scripts as part of the dbt workflow.
  Add to dbt_project.yml:
  
  on-run-start:
    - "python scripts/data_generation/generate_sample_data.py"
    
  This ensures scripts run before models, keeping data fresh.
*/


-- ============================================================================
-- APPROACH 3: dbt Python Models (dbt-core 1.3+)
-- ============================================================================

/*
  Convert Python scripts to dbt Python models.
  This integrates data generation directly into the dbt DAG.
  
  Example structure:
  models/staging/python/generate_ga4_events.py
  
  def model(dbt, session):
      import pandas as pd
      # Data generation logic here
      return df
*/


-- ============================================================================
-- APPROACH 4: External Tool Integration
-- ============================================================================

/*
  Use tools like:
  - dbt-external-tables for managing external data
  - Airflow/Prefect for orchestrating Python scripts
  - dbt Cloud jobs with Python environments
  - GitHub Actions for automated data generation
*/


-- ============================================================================
-- APPROACH 5: Makefile for Script Management
-- ============================================================================

/*
  Create a Makefile in the project root for standardized commands:
  
  # Makefile
  generate-shopify:
      python scripts/data_generation/generate_orders.py
      python scripts/data_generation/generate_order_lines.py
      dbt seed --select shopify
  
  generate-ga4:
      python scripts/data_generation/create_ga4_sample.py
      dbt seed --select events_sample
      
  generate-all: generate-shopify generate-ga4
      dbt run
*/


-- ============================================================================
-- CURRENT PROJECT STRUCTURE (Recommended)
-- ============================================================================

/*
  Our current approach follows dbt best practices:
  
  ra_dw_ecommerce/
  ├── dbt_project.yml              # Main configuration
  ├── analyses/                    # Documentation and guides
  │   ├── data_generation_guide.md
  │   └── data_generation_alternatives.sql
  ├── scripts/                     # Non-dbt scripts
  │   └── data_generation/         # Python data generators
  │       ├── README.md
  │       ├── generate_ga4_events.py
  │       ├── create_ga4_sample.py
  │       └── generate_orders.py
  ├── seeds/                       # CSV seed data
  │   ├── shopify/                 # Shopify source data
  │   └── ga4/                     # GA4 source data
  ├── models/                      # dbt transformations
  └── macros/                      # Reusable SQL macros
  
  Benefits:
  ✅ Clear separation of concerns
  ✅ Version controlled scripts
  ✅ Standard dbt directory structure
  ✅ Easy to find and maintain
  ✅ Compatible with dbt packages
  ✅ CI/CD friendly
*/