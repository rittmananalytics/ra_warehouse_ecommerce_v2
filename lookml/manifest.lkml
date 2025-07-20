project_name: "ra_ecommerce_analytics"

# Use local_dependency: To enable referencing of another project
# on this instance with include: statements

# local_dependency: {
#   project: "name_of_other_project"
# }

application: ra_ecommerce_dashboard {
  label: "Ra Ecommerce Analytics Dashboard"
  url: "https://localhost:8080/bundle.js"
  # file: "bundle.js"
  entitlements: {
    core_api_methods: ["lookml_model_explore","create_sql_query","run_sql_query","run_query","create_query"]
    navigation: yes
    use_embeds: yes
    use_iframes: yes
    new_window: yes
    new_window_external_urls: ["https://www.google.com/*"]
    local_storage: yes
    external_api_urls: ["https://api.analytics.rittmananalytics.com/*"]
  }
}