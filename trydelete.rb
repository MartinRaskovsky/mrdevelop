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

LA_CAMISETA_LOCA="https://bf991e31.ngrok.io"
PRINTFUL_KEY="my7lpmh7-rjv2-dllg:7gh8-awd6jpazrhqf"
EPRINTFUL_KEY="bXk3bHBtaDctcmp2Mi1kbGxnOjdnaDgtYXdkNmpwYXpyaHFm"
USER_ID="1"
IMAGE_ID="public/images/1/medium_Sagrada_Familia_I_DSC_5914.jpg"

API_KEY='cfe835795aaa6dc0d65e5af342d89143'
PASSWORD='69fee530af393bc3a1446c55c08ba376'
SHOP_NAME='la-camiseta-loca'

def connect()
  message("Connecting to Shopify ...")

  shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"

  ShopifyAPI::Base.site = shop_url
end

def init(who)
  puts "init: " + who
end

def failed(why)
  puts "failed: " + why
end

def message(what)
  puts "message: " + what
end

def process_shopify()
  for i in 0..ARGV.length-1
    id = ARGV[i]
    puts "Deleting: " + id.to_s
    result = printfile_delete_product(id)
    puts result.to_s
  end
end

def main()
  ENV['LA_CAMISETA_LOCA'] = LA_CAMISETA_LOCA
  ENV['PRINTFUL_KEY']     = PRINTFUL_KEY
  ENV['EPRINTFUL_KEY']    = EPRINTFUL_KEY

  connect()

  process_shopify()
  
end

main()
