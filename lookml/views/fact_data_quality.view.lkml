view: fact_data_quality {
  sql_table_name: `ra-development.analytics_ecommerce_ecommerce.fact_data_quality` ;;
  
  # Primary Key
  dimension: data_quality_key {
    primary_key: yes
    type: string
    sql: ${TABLE}.data_quality_key ;;
    description: "Data quality surrogate key"
  }

  # Data Source Information
  dimension: data_source {
    type: string
    sql: ${TABLE}.data_source ;;
    description: "Data source name"
  }

  # Row Count Metrics
  dimension: source_rows {
    type: number
    sql: ${TABLE}.source_rows ;;
    description: "Number of rows in source layer"
  }

  dimension: staging_rows {
    type: number
    sql: ${TABLE}.staging_rows ;;
    description: "Number of rows in staging layer"
  }

  dimension: integration_rows {
    type: number
    sql: ${TABLE}.integration_rows ;;
    description: "Number of rows in integration layer"
  }

  dimension: warehouse_rows {
    type: number
    sql: ${TABLE}.warehouse_rows ;;
    description: "Number of rows in warehouse layer"
  }

  # Table Count Metrics
  dimension: source_table_count {
    type: number
    sql: ${TABLE}.source_table_count ;;
    description: "Number of tables in source layer"
  }

  dimension: staging_table_count {
    type: number
    sql: ${TABLE}.staging_table_count ;;
    description: "Number of tables in staging layer"
  }

  dimension: integration_table_count {
    type: number
    sql: ${TABLE}.integration_table_count ;;
    description: "Number of tables in integration layer"
  }

  dimension: warehouse_table_count {
    type: number
    sql: ${TABLE}.warehouse_table_count ;;
    description: "Number of tables in warehouse layer"
  }

  # Data Flow Percentages
  dimension: staging_flow_pct {
    type: number
    sql: ${TABLE}.staging_flow_pct ;;
    value_format_name: percent_2
    description: "Percentage of source data flowing to staging"
  }

  dimension: integration_flow_pct {
    type: number
    sql: ${TABLE}.integration_flow_pct ;;
    value_format_name: percent_2
    description: "Percentage of staging data flowing to integration"
  }

  dimension: warehouse_flow_pct {
    type: number
    sql: ${TABLE}.warehouse_flow_pct ;;
    value_format_name: percent_2
    description: "Percentage of integration data flowing to warehouse"
  }

  # Test Pass Rates
  dimension: source_test_pass_rate {
    type: number
    sql: ${TABLE}.source_test_pass_rate ;;
    value_format_name: percent_2
    description: "Source layer test pass rate"
  }

  dimension: staging_test_pass_rate {
    type: number
    sql: ${TABLE}.staging_test_pass_rate ;;
    value_format_name: percent_2
    description: "Staging layer test pass rate"
  }

  dimension: integration_test_pass_rate {
    type: number
    sql: ${TABLE}.integration_test_pass_rate ;;
    value_format_name: percent_2
    description: "Integration layer test pass rate"
  }

  dimension: warehouse_test_pass_rate {
    type: number
    sql: ${TABLE}.warehouse_test_pass_rate ;;
    value_format_name: percent_2
    description: "Warehouse layer test pass rate"
  }

  # Quality Scores
  dimension: source_quality_score {
    type: number
    sql: ${TABLE}.source_quality_score ;;
    value_format_name: decimal_2
    description: "Source layer quality score"
  }

  dimension: staging_quality_score {
    type: number
    sql: ${TABLE}.staging_quality_score ;;
    value_format_name: decimal_2
    description: "Staging layer quality score"
  }

  dimension: integration_quality_score {
    type: number
    sql: ${TABLE}.integration_quality_score ;;
    value_format_name: decimal_2
    description: "Integration layer quality score"
  }

  dimension: warehouse_quality_score {
    type: number
    sql: ${TABLE}.warehouse_quality_score ;;
    value_format_name: decimal_2
    description: "Warehouse layer quality score"
  }

  dimension: overall_pipeline_health_score {
    type: number
    sql: ${TABLE}.overall_pipeline_health_score ;;
    value_format_name: decimal_2
    description: "Overall pipeline health score"
  }

  # Test Metrics
  dimension: total_tests_run {
    type: number
    sql: ${TABLE}.total_tests_run ;;
    description: "Total number of tests run"
  }

  dimension: total_tests_passed {
    type: number
    sql: ${TABLE}.total_tests_passed ;;
    description: "Total number of tests passed"
  }

  dimension: overall_test_pass_rate {
    type: number
    sql: ${TABLE}.overall_test_pass_rate ;;
    value_format_name: percent_2
    description: "Overall test pass rate"
  }

  # Completeness and Ratings
  dimension: data_completeness_pct {
    type: number
    sql: ${TABLE}.data_completeness_pct ;;
    value_format_name: percent_2
    description: "Data completeness percentage"
  }

  dimension: pipeline_efficiency_rating {
    type: string
    sql: ${TABLE}.pipeline_efficiency_rating ;;
    description: "Pipeline efficiency rating"
  }

  dimension: data_quality_rating {
    type: string
    sql: ${TABLE}.data_quality_rating ;;
    description: "Data quality rating"
  }

  # Date Dimensions
  dimension: report_date {
    type: date
    sql: ${TABLE}.report_date ;;
    description: "Report date"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
    description: "Created timestamp"
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.updated_at ;;
    description: "Updated timestamp"
  }

  # Derived Dimensions
  dimension: has_quality_issues {
    type: yesno
    sql: ${overall_test_pass_rate} < 0.90 OR ${data_completeness_pct} < 0.90 ;;
    description: "Has data quality issues"
  }

  dimension: health_status {
    type: string
    sql: CASE 
      WHEN ${overall_pipeline_health_score} >= 8.0 THEN 'Healthy'
      WHEN ${overall_pipeline_health_score} >= 6.0 THEN 'Warning'
      WHEN ${overall_pipeline_health_score} >= 4.0 THEN 'Critical'
      ELSE 'Failed'
    END ;;
    description: "Pipeline health status"
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [data_quality_key, data_source, report_date]
  }

  measure: avg_pipeline_health_score {
    type: average
    sql: ${overall_pipeline_health_score} ;;
    value_format_name: decimal_2
    description: "Average pipeline health score"
  }

  measure: avg_test_pass_rate {
    type: average
    sql: ${overall_test_pass_rate} ;;
    value_format_name: percent_2
    description: "Average test pass rate"
  }

  measure: total_source_rows {
    type: sum
    sql: ${source_rows} ;;
    description: "Total source rows"
  }

  measure: total_warehouse_rows {
    type: sum
    sql: ${warehouse_rows} ;;
    description: "Total warehouse rows"
  }

  measure: sources_with_issues {
    type: count
    filters: [has_quality_issues: "yes"]
    description: "Number of sources with quality issues"
  }

  measure: healthy_sources {
    type: count
    filters: [health_status: "Healthy"]
    description: "Number of healthy sources"
  }
}