ShopifyApp.configure do |config|
  config.application_name = "My Shopify App"

  #mrdevelop
  config.api_key = "bb560688edd363209f33d877a5cacf37"
  config.secret = "fc60f931b870090a0333b9ab758a93ce"

  config.scope = "read_orders, write_orders, read_products, write_products, read_customers"
  config.embedded_app = true
  config.after_authenticate_job = false
  config.session_repository = Shop
end
