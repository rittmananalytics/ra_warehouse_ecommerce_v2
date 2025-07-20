import { NextRequest, NextResponse } from 'next/server';
import { BigQuery } from '@google-cloud/bigquery';
import * as os from 'os';

function expandPath(filePath: string | undefined): string | undefined {
  if (!filePath) return undefined;
  
  if (filePath.includes('$HOME')) {
    return filePath.replace('$HOME', os.homedir());
  }
  
  if (filePath.startsWith('~')) {
    return os.homedir() + filePath.slice(1);
  }
  
  return filePath;
}

export async function GET(request: NextRequest) {
  try {
    console.log('Test BigQuery endpoint called');
    console.log('Environment vars:', {
      projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
      credentialsPath: process.env.GOOGLE_APPLICATION_CREDENTIALS,
      dataset: process.env.BIGQUERY_DATASET
    });

    const bigquery = new BigQuery({
      projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
      keyFilename: expandPath(process.env.GOOGLE_APPLICATION_CREDENTIALS),
    });

    const dataset = process.env.BIGQUERY_DATASET || 'analytics_ecommerce_ecommerce';

    // Simple test query
    const query = `
      SELECT 
        COUNT(*) as count,
        MIN(order_date_key) as min_date,
        MAX(order_date_key) as max_date
      FROM \`${dataset}.fact_orders\`
    `;

    console.log('Running query:', query);
    const [rows] = await bigquery.query(query);
    console.log('Query result:', rows);

    return NextResponse.json({
      success: true,
      result: rows[0],
      config: {
        projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
        dataset: dataset
      }
    });
  } catch (error) {
    console.error('Test BigQuery error:', error);
    return NextResponse.json(
      { 
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined
      },
      { status: 500 }
    );
  }
}