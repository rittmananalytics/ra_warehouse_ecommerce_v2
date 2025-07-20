import { NextRequest, NextResponse } from 'next/server';
import { bigQueryService } from '@/lib/bigquery';

export async function GET() {
  try {
    const marketingData = await bigQueryService.getMarketingPerformance();
    
    return NextResponse.json(marketingData);
  } catch (error) {
    console.error('Error fetching marketing data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch marketing data' },
      { status: 500 }
    );
  }
}