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

async function listTables() {
  const query = `
    SELECT table_name 
    FROM \`${process.env.GOOGLE_CLOUD_PROJECT_ID}.${dataset}.INFORMATION_SCHEMA.TABLES\`
    ORDER BY table_name
  `;
  
  const [tables] = await bigquery.query(query);
  console.log('Tables in dataset:');
  tables.forEach(t => console.log('  -', t.table_name));
}

listTables();