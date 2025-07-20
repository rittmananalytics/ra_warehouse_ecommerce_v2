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

async function checkMarketing() {
  const query = `
    SELECT 
      MIN(activity_date) as min_date,
      MAX(activity_date) as max_date,
      COUNT(*) as total_rows,
      COUNT(DISTINCT platform) as platforms,
      SUM(spend_amount) as total_spend,
      SUM(revenue) as total_revenue
    FROM \`${dataset}.fact_marketing_performance\`
  `;
  
  const [result] = await bigquery.query(query);
  console.log('Marketing data summary:');
  console.log(result[0]);
  
  // Check sample data
  const sampleQuery = `
    SELECT *
    FROM \`${dataset}.fact_marketing_performance\`
    WHERE spend_amount > 0
    LIMIT 3
  `;
  
  const [sample] = await bigquery.query(sampleQuery);
  console.log('\nSample marketing data with spend:');
  console.log(JSON.stringify(sample, null, 2));
}

checkMarketing().catch(console.error);