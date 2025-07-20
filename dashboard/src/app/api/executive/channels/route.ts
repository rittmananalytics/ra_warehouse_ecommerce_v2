import { NextRequest, NextResponse } from 'next/server';
import { bigQueryService } from '@/lib/bigquery';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '5');

    const channelData = await bigQueryService.getTopChannels(limit);
    
    return NextResponse.json(channelData);
  } catch (error) {
    console.error('Error fetching channel data:', error);
    return NextResponse.json(
      { error: 'Failed to fetch channel data' },
      { status: 500 }
    );
  }
}