#!/bin/ruby                                                                                                                                                                      
require 'shopify_api'
require 'json/pure'
require 'open-uri'
require 'net/http'                                                                                          
require 'uri'
require 'json'
require 'base64'
require 'openssl'
require "mini_magick"
require "set"

require "./app/helpers/post_helper"
include PostHelper

require "./app/helpers/image_helper"
include ImageHelper

require "./app/helpers/file_name_helper"
include FileNameHelper

require "./app/helpers/printful_helper"
include PrintfulHelper

require "./app/helpers/printful_size_helper"
include PrintfulSizeHelper

require "./app/helpers/shopify_product_helper"
include ShopifyProductHelper

VERBOSE = false

def connect()
  message("Connecting to Shopify ...")

  shop_url = "https://#{ENV['API_KEY']}:#{ENV['PASSWORD']}@#{ENV['SHOP_NAME']}.myshopify.com/admin"

  ShopifyAPI::Base.site = shop_url
end

def init(who)
  if (VERBOSE)
    puts "init: " + who
  end
end

def failed(why)
  puts "failed: " + why
end

def message(what)
  if VERBOSE
    puts "message: " + what
  end
end

def main()

  if false
  shopify_product_id = 469613346853
  shopify_variant_id = 5217307688997

  shopify_product_id = 0
  shopify_variant_id = 5215358418981

  syncinp = find_sync_variant(shopify_product_id, shopify_variant_id)
  if !syncinp
    return
  end

  url = "https://01aa7db1.ngrok.io/mockups/1/1516520203_lava_view_dsc_0739d.png"
  file = { "type" => "default", "url"  => url }
  files = syncinp['sync_variant']['files']
  files[0] = file

  id = syncinp['sync_variant']['id']

  if false
    inp = [{ "files" => files }]
  else
    inp = syncinp
  end
  else
    id = 4831 # 5217856782373
    url = "https://01aa7db1.ngrok.io/mockups/1/1516539046_lava_view_dsc_0739d.png"
    inp = []
    inp << '{'
    inp << '    "variant_id": 4831,'
    inp << '    "files":['
    inp << '    {'
    inp << '      "type": "default",'
    inp << '      "url": "' + url + '"'
    inp << '    }'
    inp << '  ],'
    inp << '  "options": []'
    inp << '}'
  end
  puts "INP: " + inp.to_json
  out = post_sync(id, inp)
  puts "OUT: " + out.to_json
  
end

main()
