#!/usr/bin/env python3
"""
Convert BigQuery DDL to Postgres Foreign Table DDL
"""

import json
import re
import sys

def convert_bigquery_type_to_postgres(bq_type):
    """Convert BigQuery data types to PostgreSQL data types"""
    type_mapping = {
        'INT64': 'BIGINT',
        'FLOAT64': 'DOUBLE PRECISION',
        'NUMERIC': 'NUMERIC',
        'STRING': 'TEXT',
        'BOOL': 'BOOLEAN',
        'TIMESTAMP': 'TIMESTAMP',
        'DATETIME': 'TIMESTAMP',
        'DATE': 'DATE',
        'TIME': 'TIME',
        'BYTES': 'BYTEA',
        'ARRAY': 'TEXT[]',  # Simplified array handling
        'STRUCT': 'JSONB',  # Simplified struct handling
        'GEOGRAPHY': 'TEXT',
        'JSON': 'JSONB'
    }
    
    # Handle parameterized types
    if '(' in bq_type:
        base_type = bq_type.split('(')[0]
        return type_mapping.get(base_type, bq_type)
    
    return type_mapping.get(bq_type, bq_type)

def parse_bigquery_ddl(ddl):
    """Parse BigQuery CREATE TABLE DDL and extract table info"""
    # Extract table name
    table_match = re.search(r'CREATE TABLE `[^.]+\.[^.]+\.([^`]+)`', ddl)
    if not table_match:
        return None, None
    
    table_name = table_match.group(1)
    
    # Extract column definitions
    columns_match = re.search(r'\((.*?)\)(?: CLUSTER BY.*)?;', ddl, re.DOTALL)
    if not columns_match:
        return table_name, None
    
    columns_str = columns_match.group(1)
    columns = []
    
    # Parse each column
    for line in columns_str.strip().split('\n'):
        line = line.strip().rstrip(',')
        if line:
            # Extract column name and type
            parts = line.split(maxsplit=1)
            if len(parts) >= 2:
                col_name = parts[0]
                col_type = parts[1]
                columns.append((col_name, col_type))
    
    return table_name, columns

def generate_foreign_table_ddl(table_name, columns):
    """Generate PostgreSQL foreign table DDL"""
    if not columns:
        return None
    
    # Start building the DDL
    ddl = f"DROP FOREIGN TABLE IF EXISTS {table_name} CASCADE;\n\n"
    ddl += f"CREATE FOREIGN TABLE {table_name} (\n"
    
    # Add column definitions
    col_defs = []
    for col_name, col_type in columns:
        pg_type = convert_bigquery_type_to_postgres(col_type)
        col_defs.append(f"    {col_name} {pg_type}")
    
    ddl += ",\n".join(col_defs)
    ddl += "\n)\n"
    
    # Add server options
    ddl += f"SERVER bigquery_server\n"
    ddl += f"OPTIONS (\n"
    ddl += f"    table '{table_name}',\n"
    ddl += f"    location 'europe-west2'\n"
    ddl += f");"
    
    return ddl

def main():
    """Main function to process BigQuery DDLs"""
    
    # Read the BigQuery DDL JSON from the bq query output
    with open('/tmp/bigquery_ddl.json', 'r') as f:
        data = json.load(f)
    
    # Generate foreign table DDLs
    all_ddls = []
    
    for item in data:
        table_name = item['table_name']
        bq_ddl = item['ddl']
        
        print(f"Processing {table_name}...")
        
        _, columns = parse_bigquery_ddl(bq_ddl)
        if columns:
            foreign_table_ddl = generate_foreign_table_ddl(table_name, columns)
            if foreign_table_ddl:
                all_ddls.append(f"-- Foreign table for {table_name}\n{foreign_table_ddl}")
    
    # Write all DDLs to a single file
    output_file = '/Users/markrittman/new/ra_warehouse_ecommerce_v2/scripts/supabase_foreign_tables/create_all_foreign_tables.sql'
    with open(output_file, 'w') as f:
        f.write("-- PostgreSQL Foreign Tables for BigQuery Analytics Warehouse\n")
        f.write("-- Generated from actual BigQuery table definitions\n\n")
        f.write("\n\n".join(all_ddls))
    
    print(f"\nGenerated {len(all_ddls)} foreign table DDLs")
    print(f"Output written to: {output_file}")

if __name__ == "__main__":
    main()