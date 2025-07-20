import { NextRequest, NextResponse } from 'next/server';
import { bigQueryService } from '@/lib/bigquery';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const dateRange = parseInt(searchParams.get('dateRange') || '30');

    console.log('Fetching KPIs for date range:', dateRange);
    const kpis = await bigQueryService.getExecutiveKPIs(dateRange);
    console.log('KPIs fetched successfully:', kpis);
    
    return NextResponse.json(kpis);
  } catch (error) {
    console.error('Error fetching executive KPIs:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json(
      { 
        error: 'Failed to fetch executive KPIs',
        details: errorMessage,
        stack: error instanceof Error ? error.stack : undefined
      },
      { status: 500 }
    );
  }
}