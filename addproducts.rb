#!/bin/ruby
require 'shopify_api'
require 'json/pure'
require 'open-uri'

# Define authentication parameters. You should update these with the
# authentication details for your own shop and private application.
API_KEY='cfe835795aaa6dc0d65e5af342d89143'
PASSWORD='69fee530af393bc3a1446c55c08ba376'
SHOP_NAME='la-camiseta-loca'

def connect()
  #puts "Connecting ..."

  # Configure the Shopify API with our authentication credentials.
  shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"

  ShopifyAPI::Base.site = shop_url
end

def main()

  connect()

  ARGV.each do|name|
    if !File.exist?(name)
      puts "Failed to find json file: " + name
      return
    end
  end

  ARGV.each do|name|
    file = File.read(name)
    addme = JSON.parse(file)

    add_products(addme['products'])
  end

end

def add_products(products)
  if products == nil
    return
  end

  products.each do |product|
    pr = ShopifyAPI::Product.new(product)

    if pr.save
       puts "Created: " + pr.images.length.to_s + " thumbs in " + pr.title
    else
      puts "Failed to create: " + pr.title
      return
    end

  end

end

main()

