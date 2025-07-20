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
          SUM(CAST(order_total_price AS FLOAT64) * 0.3) as total_gross_margin -- Assuming 30% margin
        FROM \`${dataset}.fact_orders\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      ),
      session_metrics AS (
        SELECT 
          COUNT(DISTINCT session_id) as total_sessions,
          COUNT(DISTINCT CASE WHEN completed_purchase THEN session_id END) as converting_sessions
        FROM \`${dataset}.fact_sessions\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      ),
      marketing_metrics AS (
        SELECT 
          COALESCE(SUM(spend_amount), 0) as total_marketing_spend,
          COALESCE(SUM(revenue), 0) as total_marketing_revenue
        FROM \`${dataset}.fact_marketing_performance\`
        WHERE DATE(activity_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange} DAY)
      )
      SELECT 
        om.total_revenue,
        om.total_orders,
        om.avg_order_value,
        30.0 as gross_margin_pct, -- Hardcoded for now
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
          DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) AS order_date,
          SUM(CAST(order_total_price AS FLOAT64)) AS daily_revenue
        FROM \`${dataset}.fact_orders\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL ${dateRange * 2} DAY)
        GROUP BY order_date
      ),
      date_range AS (
        SELECT DATE_SUB(CURRENT_DATE(), INTERVAL n DAY) as date
        FROM UNNEST(GENERATE_ARRAY(0, ${dateRange - 1})) as n
      )
      SELECT 
        FORMAT_DATE('%Y-%m-%d', dr.date) as date,
        COALESCE(current.daily_revenue, 0) as current_period,
        COALESCE(previous.daily_revenue, 0) as previous_period
      FROM date_range dr
      LEFT JOIN revenue_by_day current 
        ON dr.date = current.order_date
      LEFT JOIN revenue_by_day previous 
        ON DATE_ADD(dr.date, INTERVAL ${dateRange} DAY) = previous.order_date
      ORDER BY dr.date
    `;

    return this.executeQuery<RevenueData>(query);
  }

  async getTopChannels(limit: number = 5): Promise<ChannelData[]> {
    const query = `
      WITH channel_orders AS (
        SELECT 
          COALESCE(c.channel_group, 'Direct') as channel_name,
          SUM(CAST(o.order_total_price AS FLOAT64)) AS total_revenue,
          COUNT(DISTINCT o.order_id) AS total_orders,
          AVG(CAST(o.order_total_price AS FLOAT64)) AS avg_order_value
        FROM \`${dataset}.fact_orders\` o
        LEFT JOIN \`${dataset}.fact_sessions\` s
          ON o.customer_email = s.user_pseudo_id
          AND DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) = s.session_date
        LEFT JOIN \`${dataset}.dim_channels\` c
          ON CONCAT(c.channel_source, '/', c.channel_medium) = 
             CONCAT(IFNULL(o.source_name, 'direct'), '/', IFNULL(o.referring_site, 'none'))
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(o.order_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
        GROUP BY channel_name
      )
      SELECT 
        channel_name,
        total_revenue,
        total_orders,
        ROUND(avg_order_value, 2) AS avg_order_value
      FROM channel_orders
      ORDER BY total_revenue DESC
      LIMIT ${limit}
    `;

    return this.executeQuery<ChannelData>(query);
  }

  async getMarketingPerformance(): Promise<MarketingData[]> {
    const query = `
      SELECT 
        platform,
        SUM(spend_amount) AS total_spend,
        SUM(revenue) AS total_revenue,
        SAFE_DIVIDE(SUM(revenue), SUM(spend_amount)) AS roas,
        COUNT(DISTINCT content_name) AS campaign_count
      FROM \`${dataset}.fact_marketing_performance\`
      WHERE DATE(activity_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
        AND spend_amount > 0
      GROUP BY platform
      ORDER BY total_spend DESC
    `;

    return this.executeQuery<MarketingData>(query);
  }

  async getInventoryValue(): Promise<InventoryData[]> {
    const query = `
      WITH inventory_summary AS (
        SELECT 
          p.product_type AS category,
          COUNT(DISTINCT p.product_id) AS product_count,
          AVG(CAST(p.price AS FLOAT64)) AS avg_product_price,
          SUM(i.quantity_on_hand * CAST(p.price AS FLOAT64)) AS inventory_value
        FROM \`${dataset}.dim_products\` p
        LEFT JOIN \`${dataset}.fact_inventory\` i
          ON p.product_id = i.product_id
        WHERE p.product_status = 'active'
        GROUP BY p.product_type
        HAVING category IS NOT NULL
      )
      SELECT 
        category,
        product_count,
        inventory_value,
        avg_product_price
      FROM inventory_summary
      WHERE inventory_value > 0
      ORDER BY inventory_value DESC
      LIMIT 10
    `;

    return this.executeQuery<InventoryData>(query);
  }

  async getConversionFunnel(): Promise<FunnelData[]> {
    const query = `
      WITH funnel_metrics AS (
        SELECT 
          1 as stage_order,
          'Sessions' as stage,
          COUNT(DISTINCT session_id) as count
        FROM \`${dataset}.fact_sessions\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
        
        UNION ALL
        
        SELECT 
          2 as stage_order,
          'Product Views' as stage,
          COUNT(DISTINCT session_id) as count
        FROM \`${dataset}.fact_sessions\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
          AND viewed_products = true
        
        UNION ALL
        
        SELECT 
          3 as stage_order,
          'Add to Cart' as stage,
          COUNT(DISTINCT session_id) as count
        FROM \`${dataset}.fact_sessions\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
          AND added_to_cart = true
        
        UNION ALL
        
        SELECT 
          4 as stage_order,
          'Checkout' as stage,
          COUNT(DISTINCT session_id) as count
        FROM \`${dataset}.fact_sessions\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
          AND began_checkout = true
        
        UNION ALL
        
        SELECT 
          5 as stage_order,
          'Purchase' as stage,
          COUNT(DISTINCT session_id) as count
        FROM \`${dataset}.fact_sessions\`
        WHERE DATE(PARSE_DATE('%Y%m%d', CAST(session_date_key AS STRING))) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
          AND completed_purchase = true
      )
      SELECT * FROM funnel_metrics
      ORDER BY stage_order
    `;

    return this.executeQuery<FunnelData>(query);
  }
}

// Create singleton instance
export const bigQueryService = new BigQueryService();