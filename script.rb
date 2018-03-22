#!/bin/ruby
require 'shopify_api'

# Define authentication parameters. You should update these with the
# authentication details for your own shop and private application.
API_KEY='cfe835795aaa6dc0d65e5af342d89143'
PASSWORD='69fee530af393bc3a1446c55c08ba376'
SHOP_NAME='la-camiseta-loca'

# Configure the Shopify API with our authentication credentials.
shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"

ShopifyAPI::Base.site = shop_url

products = ShopifyAPI::Product.find(:all, params: { limit: 250 })
puts products;
