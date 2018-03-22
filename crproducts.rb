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

VERBOSE = true

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

def process_printful(index, image)
  set = Set.new([])
  prs = []
  for i in index..ARGV.length-1
    puts "Adding printfile: " + ARGV[i].to_s
    set, presult = add_printfiles(set, ARGV[i])
    presult.each do |pr|
      prs << pr
    end
  end

  puts "Generating printfiles"
  generate_printfiles(image, set)

  result = []
  for i in index..ARGV.length-1
    puts "Making printfile: " + ARGV[i].to_s
    pfs = make_printfiles(set, prs, ARGV[i])
    pfs.each do |pf|
      result << pf
    end
  end

  return result
end

def process_shopify(index, image, artist, name, tags, pfs)
  prs = []
  for i in index..ARGV.length-1
    id = ARGV[i]

    puts " "
    puts "Getting mockup images: " + id.to_s
    urls = get_mockup_images(id, pfs)

    puts "Generating product: " + id.to_s
    pr = generate_product(id, urls, artist, name, tags, pfs)
    if pr
      puts "Created: " + pr.images.length.to_s + " thumbs in " + pr.title
      prs << pr
    end
  end

  return prs
end

def main()

  puts " "

  artist = ARGV[0]
  name   = ARGV[1]
  tags   = ARGV[2]
  low    = ARGV[3]
  hgh    = ARGV[4]
  inx    = 5

  connect()

  pfs = process_printful(inx, hgh)
  prs = process_shopify(inx, low, artist, name, tags, pfs)

  File.write('products.json', prs.to_json)
  
end

main()
