import { NextRequest, NextResponse } from 'next/server';
import { bigQueryService } from '@/lib/bigquery';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const dateRange = parseInt(searchParams.get('dateRange') || '30');

    const revenueData = await bigQueryService.getRevenueComparison(dateRange);
    
    return NextResponse.json(revenueData);
  } catch (error) {
    console.error('Error fetching revenue data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch revenue data' },
      { status: 500 }
    );
  }
}