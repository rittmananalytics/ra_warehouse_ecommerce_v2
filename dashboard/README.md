# Ra Ecommerce Analytics Dashboard

A modern, interactive dashboard built with Next.js and React for visualizing ecommerce analytics data from BigQuery.

## Features

- **Executive Overview**: High-level KPIs and business performance metrics
- **Multi-page Navigation**: Organized dashboard sections for different stakeholder needs
- **Real-time Data**: Direct BigQuery connectivity for up-to-date insights
- **Interactive Filters**: Date range, channel, and platform filtering
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Rich Visualizations**: Charts, KPI cards, and funnel analysis

## Architecture

```
Next.js App Router
├── Frontend (React + Material-UI)
├── API Routes (Server-side)
├── BigQuery Client
└── Chart Components (Recharts)
```

## Getting Started

### Prerequisites

1. **BigQuery Access**:
   - Google Cloud Project with BigQuery enabled
   - Service account with BigQuery Data Viewer permissions
   - Service account JSON key file

2. **dbt Data Warehouse**:
   - Deployed Ra Ecommerce Data Warehouse v2
   - Tables available in `analytics_ecommerce_ecommerce` dataset

### Installation

1. **Clone and Install**:
```bash
cd dashboard
npm install
```

2. **Configure Environment**:
```bash
cp .env.example .env.local
```

Edit `.env.local` with your configuration:
```env
GOOGLE_CLOUD_PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=path/to/service-account.json
BIGQUERY_DATASET=analytics_ecommerce_ecommerce
```

3. **Service Account Setup**:
   - Download service account JSON from Google Cloud Console
   - Place file in secure location
   - Update `GOOGLE_APPLICATION_CREDENTIALS` path in `.env.local`

4. **Run Development Server**:
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) to view the dashboard.

### Production Deployment

#### Vercel (Recommended)

1. **Deploy to Vercel**:
```bash
npm install -g vercel
vercel
```

2. **Configure Environment Variables**:
   - Add environment variables in Vercel dashboard
   - Upload service account JSON as environment variable content

3. **Set Build Settings**:
   - Build Command: `npm run build`
   - Output Directory: `.next`

#### Alternative Platforms

- **Netlify**: Configure build settings and environment variables
- **AWS Amplify**: Use amplify.yml for build configuration
- **Google Cloud Run**: Containerize with Docker

## Dashboard Pages

### 1. Executive Overview (✅ Implemented)
- **KPIs**: Revenue, Orders, AOV, Gross Margin %, CAC, ROAS, Conversion Rate
- **Charts**: 
  - Revenue comparison (current vs previous period)
  - Top 5 channels by revenue
  - Marketing spend vs ROAS scatter plot
  - Inventory value treemap
  - Conversion funnel analysis

### 2. Future Pages (Planned)
- Sales & Orders Analytics
- Marketing & Attribution Analysis  
- Customer Insights & Segmentation
- Website & User Engagement
- Product & Inventory Management
- Email Marketing Performance
- Social Content Analytics
- Data Quality Monitoring

## Data Sources

The dashboard connects to the following BigQuery tables:

### Warehouse Layer
- `wh_fact_orders` - Order transactions and line items
- `wh_fact_ga4_sessions` - Website session data
- `wh_fact_marketing_performance` - Marketing campaign metrics
- `wh_dim_customers` - Customer dimension (SCD Type 2)
- `wh_dim_products` - Product dimension (SCD Type 2)
- `wh_dim_channels_enhanced` - Marketing channel definitions
- `wh_fact_data_quality` - Pipeline health monitoring

## API Endpoints

### Executive Overview APIs
- `GET /api/executive/kpis` - Key performance indicators
- `GET /api/executive/revenue` - Revenue comparison data
- `GET /api/executive/channels` - Top channels by revenue
- `GET /api/executive/marketing` - Marketing performance by platform
- `GET /api/executive/inventory` - Inventory value by category
- `GET /api/executive/funnel` - Conversion funnel metrics

### Query Parameters
- `dateRange`: Number of days (7, 30, 90)
- `limit`: Number of results to return
- `startDate`/`endDate`: Custom date range (ISO format)

## Components

### Core Components
- **Sidebar**: Navigation menu with page descriptions
- **FilterBar**: Date range, channel, and platform filters
- **KPICard**: Reusable metric display cards
- **Charts**: Specialized chart components for different visualizations

### Chart Types
- **Line Charts**: Revenue trends and time series
- **Bar Charts**: Channel performance and comparisons
- **Scatter Plots**: Marketing spend vs ROAS analysis
- **Treemaps**: Inventory value by category
- **Funnel Charts**: Conversion analysis with drop-off rates

## Styling & Theme

- **Material-UI**: Component library and theming
- **Responsive Design**: Grid-based layout system
- **Color Palette**: Consistent brand colors throughout
- **Typography**: Roboto font family with hierarchical sizing

## Development

### Project Structure
```
src/
├── app/                 # Next.js App Router pages
│   ├── api/            # API route handlers
│   ├── layout.tsx      # Root layout with sidebar
│   └── page.tsx        # Executive overview page
├── components/         # Reusable React components
│   ├── Charts/         # Chart-specific components
│   ├── FilterBar.tsx   # Filter controls
│   ├── KPICard.tsx     # Metric display cards
│   └── Sidebar.tsx     # Navigation sidebar
└── lib/                # Utility libraries
    ├── bigquery.ts     # BigQuery client and queries
    └── utils.ts        # Formatting and helper functions
```

### Adding New Pages

1. **Create Page Component**:
```tsx
// src/app/new-page/page.tsx
export default function NewPage() {
  return <div>New Dashboard Page</div>;
}
```

2. **Add to Sidebar Navigation**:
```tsx
// src/components/Sidebar.tsx
const menuItems = [
  // ... existing items
  {
    text: 'New Page',
    icon: <NewIcon />,
    path: '/new-page',
    description: 'Description of new page',
  },
];
```

3. **Create API Endpoints**:
```tsx
// src/app/api/new-page/route.ts
export async function GET() {
  // Query BigQuery and return data
}
```

### Adding New Charts

1. **Create Chart Component**:
```tsx
// src/components/Charts/NewChart.tsx
export default function NewChart({ data, loading }) {
  // Implement chart using Recharts
}
```

2. **Add BigQuery Query**:
```tsx
// src/lib/bigquery.ts
async getNewChartData(): Promise<ChartData[]> {
  const query = `SELECT ... FROM ...`;
  return this.executeQuery<ChartData>(query);
}
```

## Performance Optimization

- **React Query**: Consider adding for caching and background updates
- **Code Splitting**: Lazy load chart components
- **BigQuery Optimization**: Use appropriate date partitioning
- **CDN**: Deploy static assets via CDN

## Security

- **Environment Variables**: Never commit credentials to version control
- **Service Account**: Use minimal required permissions
- **API Routes**: Add rate limiting and validation
- **Authentication**: Consider adding user authentication for production

## Monitoring

- **Error Handling**: Comprehensive error boundaries and logging
- **Performance**: Monitor BigQuery query costs and execution time
- **Analytics**: Track dashboard usage patterns

## Support

For questions or issues:
1. Check existing dbt warehouse documentation
2. Verify BigQuery permissions and connectivity
3. Review environment variable configuration
4. Check browser console for JavaScript errors

## License

Copyright © 2025 Rittman Analytics. All rights reserved.

---

**Built with ❤️ using Next.js, React, and BigQuery**