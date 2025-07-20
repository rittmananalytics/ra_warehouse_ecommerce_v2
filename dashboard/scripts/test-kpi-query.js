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

async function testKPIQuery() {
  console.log('Testing KPI query...\n');
  
  const dateRange = 30;
  
  try {
    // First, test a simple query to ensure connection works
    console.log('1. Testing simple order count:');
    const simpleQuery = `
      SELECT COUNT(*) as count
      FROM \`${dataset}.fact_orders\`
    `;
    const [simpleResult] = await bigquery.query(simpleQuery);
    console.log('Total orders in table:', simpleResult[0].count);
    
    // Test date parsing
    console.log('\n2. Testing date parsing:');
    const dateQuery = `
      SELECT 
        MIN(order_date_key) as min_date_key,
        MAX(order_date_key) as max_date_key,
        MIN(DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING)))) as min_date,
        MAX(DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING)))) as max_date
      FROM \`${dataset}.fact_orders\`
    `;
    const [dateResult] = await bigquery.query(dateQuery);
    console.log('Date range:', dateResult[0]);
    
    // Test order metrics
    console.log('\n3. Testing order metrics:');
    const orderMetricsQuery = `
      SELECT 
        COUNT(DISTINCT order_id) as total_orders,
        SUM(CAST(order_total_price AS FLOAT64)) as total_revenue,
        AVG(CAST(order_total_price AS FLOAT64)) as avg_order_value
      FROM \`${dataset}.fact_orders\`
      WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
    `;
    const [orderResult] = await bigquery.query(orderMetricsQuery);
    console.log('Order metrics:', orderResult[0]);
    
    // Test session metrics
    console.log('\n4. Testing session metrics:');
    const sessionMetricsQuery = `
      SELECT 
        COUNT(DISTINCT session_id) as total_sessions,
        COUNT(DISTINCT CASE WHEN completed_purchase THEN session_id END) as converting_sessions
      FROM \`${dataset}.fact_sessions\`
      WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
    `;
    const [sessionResult] = await bigquery.query(sessionMetricsQuery);
    console.log('Session metrics:', sessionResult[0]);
    
    // Test marketing metrics
    console.log('\n5. Testing marketing metrics:');
    const marketingMetricsQuery = `
      SELECT 
        SUM(spend_amount) as total_marketing_spend,
        SUM(revenue) as total_marketing_revenue
      FROM \`${dataset}.fact_marketing_performance\`
      WHERE DATE(activity_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
    `;
    const [marketingResult] = await bigquery.query(marketingMetricsQuery);
    console.log('Marketing metrics:', marketingResult[0]);
    
    // Test the full KPI query
    console.log('\n6. Testing full KPI query:');
    const fullQuery = `
      WITH order_metrics AS (
        SELECT 
          COUNT(DISTINCT order_id) as total_orders,
          SUM(CAST(order_total_price AS FLOAT64)) as total_revenue,
          AVG(CAST(order_total_price AS FLOAT64)) as avg_order_value,
          SUM(CAST(order_total_price AS FLOAT64) * 0.3) as total_gross_margin
        FROM \`${dataset}.fact_orders\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      ),
      session_metrics AS (
        SELECT 
          COUNT(DISTINCT session_id) as total_sessions,
          COUNT(DISTINCT CASE WHEN completed_purchase THEN session_id END) as converting_sessions
        FROM \`${dataset}.fact_sessions\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      ),
      marketing_metrics AS (
        SELECT 
          SUM(spend_amount) as total_marketing_spend,
          SUM(revenue) as total_marketing_revenue
        FROM \`${dataset}.fact_marketing_performance\`
        WHERE DATE(activity_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      )
      SELECT 
        om.total_revenue,
        om.total_orders,
        om.avg_order_value,
        30.0 as gross_margin_pct,
        SAFE_DIVIDE(mm.total_marketing_spend, om.total_orders) as customer_acquisition_cost,
        SAFE_DIVIDE(mm.total_marketing_revenue, mm.total_marketing_spend) as return_on_ad_spend,
        SAFE_DIVIDE(sm.converting_sessions, sm.total_sessions) * 100 as conversion_rate
      FROM order_metrics om
      CROSS JOIN session_metrics sm  
      CROSS JOIN marketing_metrics mm
    `;
    
    const [fullResult] = await bigquery.query(fullQuery);
    console.log('Full KPI result:', JSON.stringify(fullResult[0], null, 2));
    
  } catch (error) {
    console.error('❌ Query failed!');
    console.error('Error:', error.message);
    if (error.errors) {
      console.error('Detailed errors:', JSON.stringify(error.errors, null, 2));
    }
  }
}

testKPIQuery();