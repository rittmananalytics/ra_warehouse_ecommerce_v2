# React Dashboard Setup Guide

This guide provides comprehensive instructions for setting up and running the Ra Ecommerce Analytics Dashboard built with React, Next.js, and BigQuery.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Dashboard](#running-the-dashboard)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)
- [Architecture Overview](#architecture-overview)

## Prerequisites

Before setting up the dashboard, ensure you have the following:

### System Requirements
- **Node.js**: Version 18.x or higher
- **npm**: Version 8.x or higher (comes with Node.js)
- **Git**: For cloning the repository

### Google Cloud Requirements
- **Google Cloud Project**: With BigQuery enabled
- **Service Account**: With BigQuery Data Viewer permissions
- **Service Account Key**: JSON key file for authentication

### Data Requirements
- **Deployed dbt Project**: The Ra Ecommerce Data Warehouse v2 must be deployed to BigQuery
- **Dataset Access**: The service account must have access to the `analytics_ecommerce_ecommerce` dataset

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/rittman-analytics/ra_warehouse_ecommerce_v2.git
cd ra_warehouse_ecommerce_v2
```

### 2. Navigate to Dashboard Directory

```bash
cd dashboard
```

### 3. Install Dependencies

```bash
npm install
```

This will install all required packages including:
- Next.js 14
- React 18
- Material-UI 5
- Recharts
- @google-cloud/bigquery
- TypeScript

## Configuration

### 1. Create Environment File

Copy the example environment file:

```bash
cp .env.example .env.local
```

### 2. Configure Environment Variables

Edit `.env.local` with your configuration:

```env
# BigQuery Configuration
GOOGLE_CLOUD_PROJECT_ID=your-project-id-here
# Use absolute path or $HOME/path (will be expanded automatically)
GOOGLE_APPLICATION_CREDENTIALS=/Users/yourusername/path/to/service-account-key.json
# or
# GOOGLE_APPLICATION_CREDENTIALS=$HOME/path/to/service-account-key.json
BIGQUERY_DATASET=analytics_ecommerce_ecommerce

# Optional: Custom dataset names
# BIGQUERY_STAGING_DATASET=analytics_ecommerce_staging  
# BIGQUERY_INTEGRATION_DATASET=analytics_ecommerce_integration

# Next.js Configuration (optional)
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-random-secret-key

# Optional: Analytics
# GOOGLE_ANALYTICS_ID=GA_MEASUREMENT_ID
```

### 3. Service Account Setup

#### Option A: Local Development
1. Download your service account key from Google Cloud Console
2. Save it to a secure location on your machine
3. Update `GOOGLE_APPLICATION_CREDENTIALS` with the full path

#### Option B: Using Environment Variable Content
Instead of a file path, you can embed the JSON content directly:

```env
GOOGLE_APPLICATION_CREDENTIALS_JSON='{
  "type": "service_account",
  "project_id": "your-project",
  ...
}'
```

### 4. Verify BigQuery Access

Test your BigQuery connection:

```bash
npm run test:bigquery
```

## Running the Dashboard

### Development Mode

Start the development server:

```bash
npm run dev
```

The dashboard will be available at:
- **Local**: http://localhost:3000
- **Network**: http://[your-ip]:3000

### Production Build

Build for production:

```bash
npm run build
```

Start the production server:

```bash
npm start
```

### Linting and Type Checking

Run linting:

```bash
npm run lint
```

Type checking:

```bash
npm run type-check
```

## Deployment

### Vercel (Recommended)

1. **Install Vercel CLI**:
```bash
npm install -g vercel
```

2. **Deploy**:
```bash
vercel
```

3. **Configure Environment Variables**:
   - Go to your Vercel dashboard
   - Navigate to Project Settings → Environment Variables
   - Add all variables from `.env.local`
   - For the service account, paste the JSON content as a single environment variable

### Alternative Deployment Options

#### Docker

1. **Build the image**:
```bash
docker build -t ra-ecommerce-dashboard .
```

2. **Run the container**:
```bash
docker run -p 3000:3000 \
  -e GOOGLE_CLOUD_PROJECT_ID=your-project \
  -e GOOGLE_APPLICATION_CREDENTIALS_JSON='{"type":"service_account"...}' \
  ra-ecommerce-dashboard
```

#### Google Cloud Run

1. **Build and push image**:
```bash
gcloud builds submit --tag gcr.io/PROJECT-ID/ra-dashboard
```

2. **Deploy to Cloud Run**:
```bash
gcloud run deploy ra-dashboard \
  --image gcr.io/PROJECT-ID/ra-dashboard \
  --platform managed \
  --allow-unauthenticated
```

## Troubleshooting

### Common Issues

#### 1. BigQuery Authentication Error
```
Error: Could not load the default credentials
```

**Solution**:
- Verify the service account key path is correct
- Ensure the JSON file is valid
- Check file permissions

#### 2. BigQuery Permission Denied
```
Error: Permission denied on dataset
```

**Solution**:
- Verify service account has BigQuery Data Viewer role
- Check dataset permissions in BigQuery console
- Ensure correct project ID and dataset name

#### 3. Module Not Found
```
Error: Cannot find module '@/components/...'
```

**Solution**:
```bash
rm -rf node_modules
rm package-lock.json
npm install
```

#### 4. Port Already in Use
```
Error: Port 3000 is already in use
```

**Solution**:
```bash
# Use a different port
PORT=3001 npm run dev

# Or kill the process using port 3000
lsof -ti:3000 | xargs kill
```

### Debug Mode

Enable debug logging:

```bash
DEBUG=* npm run dev
```

### Check BigQuery Queries

View executed queries in BigQuery console:
1. Go to BigQuery Console
2. Navigate to Query History
3. Filter by service account email

## Architecture Overview

### Technology Stack
- **Frontend**: React 18 with TypeScript
- **Framework**: Next.js 14 (App Router)
- **UI Library**: Material-UI v5
- **Charts**: Recharts
- **Data Source**: Google BigQuery
- **Styling**: CSS Modules + Material-UI theming

### Project Structure
```
dashboard/
├── src/
│   ├── app/                 # Next.js App Router pages
│   │   ├── api/            # API route handlers
│   │   ├── layout.tsx      # Root layout with sidebar
│   │   └── page.tsx        # Executive overview page
│   ├── components/         # Reusable React components
│   │   ├── Charts/         # Chart components
│   │   ├── FilterBar.tsx   # Filter controls
│   │   ├── KPICard.tsx     # KPI display cards
│   │   └── Sidebar.tsx     # Navigation sidebar
│   └── lib/                # Utility libraries
│       ├── bigquery.ts     # BigQuery client
│       └── utils.ts        # Helper functions
├── public/                 # Static assets
├── .env.example           # Environment template
├── package.json           # Dependencies
└── tsconfig.json          # TypeScript config
```

### API Endpoints
- `/api/executive/kpis` - Key performance indicators
- `/api/executive/revenue` - Revenue comparison data
- `/api/executive/channels` - Channel performance
- `/api/executive/marketing` - Marketing metrics
- `/api/executive/inventory` - Inventory analysis
- `/api/executive/funnel` - Conversion funnel

### Performance Optimization
- Server-side rendering for initial load
- API route caching with appropriate headers
- Efficient BigQuery queries with proper indexing
- Component-level code splitting
- Optimized bundle size with tree shaking

## Next Steps

1. **Customize Dashboards**: Modify components in `src/components` to match your branding
2. **Add Authentication**: Implement NextAuth.js for user authentication
3. **Extend Analytics**: Add new API endpoints and visualizations
4. **Set Up Monitoring**: Configure error tracking and performance monitoring
5. **Implement Caching**: Add Redis for query result caching

## Support

For issues or questions:
1. Check the [troubleshooting section](#troubleshooting)
2. Review BigQuery logs in Google Cloud Console
3. Examine browser console for client-side errors
4. Check Next.js server logs for API errors

---

Copyright © 2025 Rittman Analytics. All rights reserved.