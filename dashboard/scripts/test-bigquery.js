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

async function testBigQueryConnection() {
  console.log('Testing BigQuery connection...\n');
  
  // Log configuration
  console.log('Configuration:');
  console.log(`Project ID: ${process.env.GOOGLE_CLOUD_PROJECT_ID}`);
  console.log(`Credentials Path (raw): ${process.env.GOOGLE_APPLICATION_CREDENTIALS}`);
  console.log(`Credentials Path (expanded): ${expandPath(process.env.GOOGLE_APPLICATION_CREDENTIALS)}`);
  console.log(`Dataset: ${process.env.BIGQUERY_DATASET}\n`);
  
  try {
    // Initialize BigQuery client
    const bigquery = new BigQuery({
      projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
      keyFilename: expandPath(process.env.GOOGLE_APPLICATION_CREDENTIALS),
    });
    
    const dataset = process.env.BIGQUERY_DATASET || 'analytics_ecommerce_ecommerce';
    
    // Test query - check if we can access the dataset
    const query = `
      SELECT table_name 
      FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.INFORMATION_SCHEMA.TABLES\`
      LIMIT 5
    `;
    
    console.log('Running test query...\n');
    const [rows] = await bigquery.query(query);
    
    console.log('✅ BigQuery connection successful!\n');
    console.log('Tables found in dataset:');
    rows.forEach(row => console.log(`  - ${row.table_name}`));
    
  } catch (error) {
    console.error('❌ BigQuery connection failed!\n');
    console.error('Error details:', error.message);
    
    if (error.message.includes('Could not load the default credentials')) {
      console.error('\n💡 Tip: Make sure your service account key file exists at the specified path');
      console.error(`   Path: ${expandPath(process.env.GOOGLE_APPLICATION_CREDENTIALS)}`);
    }
    
    if (error.message.includes('Not found: Dataset')) {
      console.error('\n💡 Tip: Make sure the dataset exists in your BigQuery project');
      console.error(`   Dataset: ${process.env.BIGQUERY_DATASET}`);
      console.error(`   Project: ${process.env.GOOGLE_CLOUD_PROJECT_ID}`);
    }
    
    process.exit(1);
  }
}

// Run the test
testBigQueryConnection();