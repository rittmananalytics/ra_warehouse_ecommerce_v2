#!/bin/bash

# LookML Validation Script
echo "Validating LookML files..."
echo "========================="

# Check for required directories
if [ ! -d "views" ] || [ ! -d "models" ] || [ ! -d "dashboards" ]; then
    echo "ERROR: Missing required directories (views, models, or dashboards)"
    exit 1
fi

# Validate view files
echo ""
echo "Checking view files..."
echo "---------------------"
for file in views/*.view.lkml; do
    if [ -f "$file" ]; then
        echo -n "Checking $file... "
        # Check for required elements
        if grep -q "^view:" "$file" && grep -q "sql_table_name:" "$file"; then
            echo "✓"
        else
            echo "✗ Missing required elements"
        fi
    fi
done

# Validate model files
echo ""
echo "Checking model files..."
echo "----------------------"
for file in models/*.model.lkml; do
    if [ -f "$file" ]; then
        echo -n "Checking $file... "
        # Check for required elements
        if grep -q "^connection:" "$file" && grep -q "^explore:" "$file"; then
            echo "✓"
        else
            echo "✗ Missing required elements"
        fi
    fi
done

# Validate dashboard files
echo ""
echo "Checking dashboard files..."
echo "--------------------------"
for file in dashboards/*.dashboard.lookml; do
    if [ -f "$file" ]; then
        echo -n "Checking $file... "
        # Check for required elements
        if grep -q "^- dashboard:" "$file" && grep -q "title:" "$file"; then
            echo "✓"
        else
            echo "✗ Missing required elements"
        fi
    fi
done

# Check for consistent table references
echo ""
echo "Checking table references..."
echo "---------------------------"
# Extract all table references from views
grep -h "sql_table_name:" views/*.view.lkml | sed 's/.*\.//' | sed 's/`.*//' | sort | uniq > /tmp/lookml_tables.txt

echo "Tables referenced in LookML views:"
cat /tmp/lookml_tables.txt

# Check for explore-view consistency
echo ""
echo "Checking explore-view consistency..."
echo "-----------------------------------"
# Get all explores from model
grep -h "from:" models/*.model.lkml | awk '{print $2}' | sort | uniq > /tmp/lookml_explores.txt

# Get all views
ls views/*.view.lkml | xargs -n1 basename | sed 's/.view.lkml//' | sort > /tmp/lookml_views.txt

echo "Explores without matching views:"
comm -23 /tmp/lookml_explores.txt /tmp/lookml_views.txt

echo ""
echo "Validation complete!"