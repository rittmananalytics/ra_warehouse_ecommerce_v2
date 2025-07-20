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
  // Get ALL columns from fact_sessions
  const query = `
    SELECT column_name, data_type 
    FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.INFORMATION_SCHEMA.COLUMNS\`
    WHERE table_name = 'fact_sessions'
    ORDER BY ordinal_position
  `;
  
  const [cols] = await bigquery.query(query);
  console.log('ALL fact_sessions columns:');
  cols.forEach(col => {
    console.log(`  - ${col.column_name}: ${col.data_type}`);
  });
  
  // Get sample data
  console.log('\n\nSample fact_sessions data:');
  const sampleQuery = `
    SELECT *
    FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.fact_sessions\`
    LIMIT 1
  `;
  
  const [sample] = await bigquery.query(sampleQuery);
  console.log(JSON.stringify(sample[0], null, 2));
}

checkColumns().catch(console.error);