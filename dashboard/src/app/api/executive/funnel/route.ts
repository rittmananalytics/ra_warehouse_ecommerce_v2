import { NextRequest, NextResponse } from 'next/server';
import { bigQueryService } from '@/lib/bigquery';

export async function GET() {
  try {
    const funnelData = await bigQueryService.getConversionFunnel();
    
    return NextResponse.json(funnelData);
  } catch (error) {
    console.error('Error fetching funnel data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch funnel data' },
      { status: 500 }
    );
  }
}