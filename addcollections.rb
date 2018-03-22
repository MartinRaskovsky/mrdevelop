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
    add_collection(name)
  end

end

def add_collection(name)
  c = ShopifyAPI::SmartCollection.new(
    {
	"title"      => name,
	"sort_order" => "alpha-asc",
	"rules"      => [
	  { "column" => "tag", "relation" => "equals", "condition" => name },
	  { "column" => "tag", "relation" => "equals", "condition" => "Fine Art" }
	]
    })
  if c.save
       puts "Created: " + c.title
  else
      puts "Failed to create: " + c.title
    return
  end

end

main()

