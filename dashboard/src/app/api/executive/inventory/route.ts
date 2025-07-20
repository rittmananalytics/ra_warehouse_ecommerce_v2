import { NextRequest, NextResponse } from 'next/server';
import { bigQueryService } from '@/lib/bigquery';

export async function GET() {
  try {
    const inventoryData = await bigQueryService.getInventoryValue();
    
    return NextResponse.json(inventoryData);
  } catch (error) {
    console.error('Error fetching inventory data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch inventory data' },
      { status: 500 }
    );
  }
}