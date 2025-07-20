#!/usr/bin/env node

require('dotenv').config({ path: '.env.local' });

const { BigQuery } = require('@google-cloud/bigquery');
const os = require('os');

function expandPath(filePath) {
  if (!filePath) return undefined;
  if (filePath.includes('$HOME')) {
    return filePath.replace('$HOME', os.homedir());
  }
  return filePath;
}

const bigquery = new BigQuery({
  projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
  keyFilename: expandPath(process.env.GOOGLE_APPLICATION_CREDENTIALS),
});

const dataset = process.env.BIGQUERY_DATASET || 'analytics_ecommerce_ecommerce';

async function checkColumns() {
  console.log('Checking table schemas...\n');
  
  // Check fact_sessions columns
  console.log('fact_sessions columns:');
  const sessionsQuery = `
    SELECT column_name, data_type 
    FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.INFORMATION_SCHEMA.COLUMNS\`
    WHERE table_name = 'fact_sessions'
    ORDER BY ordinal_position
    LIMIT 20
  `;
  
  const [sessionsCols] = await bigquery.query(sessionsQuery);
  sessionsCols.forEach(col => {
    console.log(`  - ${col.column_name}: ${col.data_type}`);
  });
  
  // Check fact_marketing_performance columns
  console.log('\n\nfact_marketing_performance columns:');
  const marketingQuery = `
    SELECT column_name, data_type 
    FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.INFORMATION_SCHEMA.COLUMNS\`
    WHERE table_name = 'fact_marketing_performance'
    ORDER BY ordinal_position
    LIMIT 20
  `;
  
  const [marketingCols] = await bigquery.query(marketingQuery);
  marketingCols.forEach(col => {
    console.log(`  - ${col.column_name}: ${col.data_type}`);
  });
  
  // Check dim_channels columns
  console.log('\n\ndim_channels columns:');
  const channelsQuery = `
    SELECT column_name, data_type 
    FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.INFORMATION_SCHEMA.COLUMNS\`
    WHERE table_name = 'dim_channels'
    ORDER BY ordinal_position
    LIMIT 10
  `;
  
  const [channelsCols] = await bigquery.query(channelsQuery);
  channelsCols.forEach(col => {
    console.log(`  - ${col.column_name}: ${col.data_type}`);
  });
}

checkColumns().catch(console.error);