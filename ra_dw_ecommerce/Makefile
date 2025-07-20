# Makefile for Belle & Glow Cosmetics Data Warehouse
# Provides standardized commands for data generation and dbt operations

.PHONY: help install generate-shopify generate-ga4 generate-all seed-all run-all test clean

# Default target
help:
	@echo "Available commands:"
	@echo "  install           Install Python dependencies"
	@echo "  generate-shopify  Generate Shopify sample data"
	@echo "  generate-ga4      Generate GA4 sample data"
	@echo "  generate-all      Generate all sample data"
	@echo "  seed-all          Load all seed data into BigQuery"
	@echo "  run-all           Run all dbt models"
	@echo "  test             Run dbt tests"
	@echo "  clean            Clean dbt artifacts"

# Install dependencies
install:
	pip install -r requirements.txt
	dbt deps

# Generate Shopify data
generate-shopify:
	@echo "Generating Shopify sample data..."
	python scripts/data_generation/generate_orders.py
	python scripts/data_generation/generate_order_lines_final.py
	@echo "Shopify data generation complete!"

# Generate GA4 data (sample version for development)
generate-ga4:
	@echo "Generating GA4 sample data..."
	python scripts/data_generation/create_ga4_sample.py
	@echo "GA4 data generation complete!"

# Generate GA4 full dataset (production)
generate-ga4-full:
	@echo "Generating full GA4 dataset (this may take several minutes)..."
	python scripts/data_generation/generate_ga4_events.py
	@echo "Full GA4 data generation complete!"

# Generate all sample data
generate-all: generate-shopify generate-ga4
	@echo "All sample data generated!"

# Load seed data
seed-shopify:
	dbt seed --select shopify

seed-ga4:
	dbt seed --select events_sample

seed-ga4-full:
	dbt seed --select events

seed-all: seed-shopify seed-ga4
	@echo "All seed data loaded!"

# Run dbt models
run-shopify:
	dbt run --select shopify

run-all:
	dbt run

# Test data quality
test:
	dbt test

# Analyze generated data
analyze-data:
	python scripts/data_generation/analyze_ga4_dataset.py

# Complete workflow: generate data, seed, and run models
full-refresh: generate-all seed-all run-all test
	@echo "Complete data refresh finished!"

# Development workflow: quick iteration
dev-refresh: generate-ga4 seed-ga4 run-all
	@echo "Development refresh complete!"

# Clean up dbt artifacts
clean:
	dbt clean
	rm -rf target/
	rm -rf dbt_packages/

# Create requirements.txt if it doesn't exist
requirements.txt:
	@echo "pandas>=1.5.0" > requirements.txt
	@echo "numpy>=1.21.0" >> requirements.txt
	@echo "faker>=15.0.0" >> requirements.txt
	@echo "dbt-bigquery>=1.5.0" >> requirements.txt