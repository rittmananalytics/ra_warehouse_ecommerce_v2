import { BigQuery } from '@google-cloud/bigquery';
import * as path from 'path';
import * as os from 'os';

// Helper function to expand environment variables in paths
function expandPath(filePath: string | undefined): string | undefined {
  if (!filePath) return undefined;
  
  // Replace $HOME with actual home directory
  if (filePath.includes('$HOME')) {
    return filePath.replace('$HOME', os.homedir());
  }
  
  // Replace ~ with home directory
  if (filePath.startsWith('~')) {
    return path.join(os.homedir(), filePath.slice(1));
  }
  
  return filePath;
}

// Initialize BigQuery client
const bigquery = new BigQuery({
  projectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
  keyFilename: expandPath(process.env.GOOGLE_APPLICATION_CREDENTIALS),
});

const dataset = process.env.BIGQUERY_DATASET || 'analytics_ecommerce_ecommerce';

export interface ExecutiveKPIs {
  totalRevenue: number;
  totalOrders: number;
  avgOrderValue: number;
  grossMarginPct: number;
  customerAcquisitionCost: number;
  returnOnAdSpend: number;
  conversionRate: number;
}

export interface RevenueData {
  date: string;
  current_period: number;
  previous_period: number;
}

export interface ChannelData {
  channel_name: string;
  total_revenue: number;
  total_orders: number;
  avg_order_value: number;
}

export interface MarketingData {
  platform: string;
  total_spend: number;
  total_revenue: number;
  roas: number;
  campaign_count: number;
}

export interface InventoryData {
  category: string;
  product_count: number;
  inventory_value: number;
  avg_product_price: number;
}

export interface FunnelData {
  stage: string;
  count: number;
  stage_order: number;
}

export class BigQueryService {
  
  async executeQuery<T>(query: string): Promise<T[]> {
    try {
      const [rows] = await bigquery.query({
        query,
        location: 'US',
      });
      return rows as T[];
    } catch (error) {
      console.error('BigQuery error:', error);
      throw new Error(`Failed to execute query: ${error}`);
    }
  }

  async getExecutiveKPIs(dateRange: number = 30): Promise<ExecutiveKPIs> {
    const query = `
      WITH order_metrics AS (
        SELECT 
          COUNT(DISTINCT order_id) as total_orders,
          SUM(CAST(order_total_price AS FLOAT64)) as total_revenue,
          AVG(CAST(order_total_price AS FLOAT64)) as avg_order_value,
          SUM(CAST(order_total_price AS FLOAT64) - CAST(subtotal_price AS FLOAT64)) as total_gross_margin
        FROM \`${dataset}.fact_orders\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      ),
      session_metrics AS (
        SELECT 
          COUNT(DISTINCT session_id) as total_sessions,
          COUNT(DISTINCT CASE WHEN has_purchase THEN session_id END) as converting_sessions
        FROM \`${dataset}.fact_ga4_sessions\`
        WHERE DATE(session_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      ),
      marketing_metrics AS (
        SELECT 
          SUM(cost_usd) as total_marketing_spend,
          SUM(revenue) as total_marketing_revenue,
          COUNT(DISTINCT CASE WHEN conversions > 0 THEN campaign_id END) as acquiring_campaigns
        FROM \`${dataset}.fact_marketing_performance\`
        WHERE DATE(report_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      )
      SELECT 
        om.total_revenue,
        om.total_orders,
        om.avg_order_value,
        SAFE_DIVIDE(om.total_gross_margin, om.total_revenue) * 100 as gross_margin_pct,
        SAFE_DIVIDE(mm.total_marketing_spend, om.total_orders) as customer_acquisition_cost,
        SAFE_DIVIDE(mm.total_marketing_revenue, mm.total_marketing_spend) as return_on_ad_spend,
        SAFE_DIVIDE(sm.converting_sessions, sm.total_sessions) * 100 as conversion_rate
      FROM order_metrics om
      CROSS JOIN session_metrics sm  
      CROSS JOIN marketing_metrics mm
    `;

    const results = await this.executeQuery<any>(query);
    const data = results[0] || {};
    
    return {
      totalRevenue: data.total_revenue || 0,
      totalOrders: data.total_orders || 0,
      avgOrderValue: data.avg_order_value || 0,
      grossMarginPct: data.gross_margin_pct || 0,
      customerAcquisitionCost: data.customer_acquisition_cost || 0,
      returnOnAdSpend: data.return_on_ad_spend || 0,
      conversionRate: data.conversion_rate || 0,
    };
  }

  async getRevenueComparison(dateRange: number = 30): Promise<RevenueData[]> {
    const query = `
      WITH revenue_by_day AS (
        SELECT 
          DATE(order_date_key) AS order_date,
          SUM(total_price_usd) AS daily_revenue,
          CASE 
            WHEN DATE(order_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY) THEN 'current_30'
            WHEN DATE(order_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange * 2} DAY) THEN 'previous_30'
          END AS period
        FROM \`${dataset}.fact_orders\`
        WHERE DATE(order_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange * 2} DAY)
        GROUP BY order_date
      ),
      current_period AS (
        SELECT 
          order_date,
          daily_revenue as current_period,
          0 as previous_period
        FROM revenue_by_day
        WHERE period = 'current_30'
      ),
      previous_period AS (
        SELECT 
          DATE_ADD(order_date, INTERVAL ${dateRange} DAY) as order_date,
          0 as current_period,
          daily_revenue as previous_period
        FROM revenue_by_day
        WHERE period = 'previous_30'
      ),
      combined AS (
        SELECT * FROM current_period
        UNION ALL
        SELECT * FROM previous_period
      )
      SELECT 
        FORMAT_DATE('%Y-%m-%d', order_date) as date,
        SUM(current_period) as current_period,
        SUM(previous_period) as previous_period
      FROM combined
      WHERE order_date >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      GROUP BY order_date
      ORDER BY order_date
    `;

    return this.executeQuery<RevenueData>(query);
  }

  async getTopChannels(limit: number = 5): Promise<ChannelData[]> {
    const query = `
      SELECT 
        COALESCE(c.channel_name, 'Direct') as channel_name,
        SUM(o.total_price_usd) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(AVG(o.total_price_usd), 2) AS avg_order_value
      FROM \`${dataset}.fact_orders\` o
      LEFT JOIN \`${dataset}.dim_channels_enhanced\` c
        ON o.utm_source = c.utm_source
      WHERE DATE(o.order_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
      GROUP BY c.channel_name
      ORDER BY total_revenue DESC
      LIMIT ${limit}
    `;

    return this.executeQuery<ChannelData>(query);
  }

  async getMarketingPerformance(): Promise<MarketingData[]> {
    const query = `
      SELECT 
        platform,
        SUM(cost_usd) AS total_spend,
        SUM(revenue) AS total_revenue,
        SAFE_DIVIDE(SUM(revenue), SUM(cost_usd)) AS roas,
        COUNT(DISTINCT campaign_name) AS campaign_count
      FROM \`${dataset}.fact_marketing_performance\`
      WHERE DATE(report_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
        AND cost_usd > 0
      GROUP BY platform
      ORDER BY total_spend DESC
    `;

    return this.executeQuery<MarketingData>(query);
  }

  async getInventoryValue(): Promise<InventoryData[]> {
    const query = `
      WITH product_inventory AS (
        SELECT 
          p.product_type AS category,
          COUNT(DISTINCT p.product_id) AS product_count,
          AVG(p.price) AS avg_product_price,
          -- Simulated inventory since we don't have real inventory data
          SUM(p.price * (50 + MOD(ABS(FARM_FINGERPRINT(p.product_title)), 200))) AS inventory_value
        FROM \`${dataset}.dim_products\` p
        WHERE p.is_current = true 
          AND p.product_status = 'active'
        GROUP BY p.product_type
      )
      SELECT 
        category,
        product_count,
        ROUND(inventory_value, 2) as inventory_value,
        ROUND(avg_product_price, 2) as avg_product_price
      FROM product_inventory
      ORDER BY inventory_value DESC
      LIMIT 10
    `;

    return this.executeQuery<InventoryData>(query);
  }

  async getConversionFunnel(): Promise<FunnelData[]> {
    const query = `
      WITH funnel_metrics AS (
        SELECT 
          COUNT(DISTINCT session_id) AS sessions,
          COUNT(DISTINCT CASE WHEN has_add_to_cart THEN session_id END) AS add_to_cart,
          COUNT(DISTINCT CASE WHEN has_checkout THEN session_id END) AS begin_checkout,
          COUNT(DISTINCT CASE WHEN has_purchase THEN session_id END) AS purchases
        FROM \`${dataset}.fact_ga4_sessions\`
        WHERE DATE(session_date_key) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
      )
      SELECT 'Sessions' AS stage, sessions AS count, 1 AS stage_order FROM funnel_metrics
      UNION ALL
      SELECT 'Add to Cart', add_to_cart, 2 FROM funnel_metrics  
      UNION ALL
      SELECT 'Begin Checkout', begin_checkout, 3 FROM funnel_metrics
      UNION ALL
      SELECT 'Purchase', purchases, 4 FROM funnel_metrics
      ORDER BY stage_order
    `;

    return this.executeQuery<FunnelData>(query);
  }
}

export const bigQueryService = new BigQueryService();