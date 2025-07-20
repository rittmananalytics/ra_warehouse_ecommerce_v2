#!/usr/bin/env node

// Load environment variables
require('dotenv').config({ path: '.env.local' });

const { BigQuery } = require('@google-cloud/bigquery');
const os = require('os');
const path = require('path');

// Helper function to expand environment variables in paths
function expandPath(filePath) {
  if (!filePath) return undefined;
  
  // Replace $HOME with actual home directory
  if (filePath.includes('$HOME')) {
    return filePath.replace('$HOME', os.homedir());
  }
  
  // Replace ~ with home directory
  if (filePath.startsWith('~')) {
    return path.join(os.homedir(), filePath.slice(1));
  }
  
  return filePath;
}

async function checkTableSchema() {
  console.log('Checking table schemas in BigQuery...\n');
  
  try {
    // Initialize BigQuery client
    const bigquery = new BigQuery({
      projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
      keyFilename: expandPath(process.env.GOOGLE_APPLICATION_CREDENTIALS),
    });
    
    const dataset = process.env.BIGQUERY_DATASET || 'analytics_ecommerce_ecommerce';
    
    // Check fact_orders table schema
    console.log('fact_orders schema:');
    const ordersQuery = `
      SELECT column_name, data_type 
      FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.INFORMATION_SCHEMA.COLUMNS\`
      WHERE table_name = 'fact_orders'
      ORDER BY ordinal_position
    `;
    
    const [ordersColumns] = await bigquery.query(ordersQuery);
    ordersColumns.forEach(col => {
      console.log(`  - ${col.column_name}: ${col.data_type}`);
    });
    
    console.log('\n\nSample data from fact_orders:');
    const sampleQuery = `
      SELECT * FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.fact_orders\`
      LIMIT 3
    `;
    
    const [sampleRows] = await bigquery.query(sampleQuery);
    console.log(JSON.stringify(sampleRows, null, 2));
    
  } catch (error) {
    console.error('❌ Error checking schema!\n');
    console.error('Error details:', error.message);
    process.exit(1);
  }
}

// Run the check
checkTableSchema();