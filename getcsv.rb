#!/bin/ruby
require 'shopify_api'
require 'json/pure'
require 'open-uri'

#require "./app/helpers/post_helper"
#include PostHelper

#require "./app/helpers/image_helper"
#include ImageHelper

#require "./app/helpers/file_name_helper"
#include FileNameHelper

#require "./app/helpers/printful_helper"
#include PrintfulHelper

#require "./app/helpers/printful_size_helper"
#include PrintfulSizeHelper

#require "./app/helpers/shopify_product_helper"
#include ShopifyProductHelper

# Define authentication parameters. You should update these with the
# authentication details for your own shop and private application.
API_KEY='cfe835795aaa6dc0d65e5af342d89143'
PASSWORD='69fee530af393bc3a1446c55c08ba376'
SHOP_NAME='la-camiseta-loca'

VERBOSE = false

def connect()
  message("Connecting to Shopify ...")

  shop_url = "https://#{ENV['API_KEY']}:#{ENV['PASSWORD']}@#{ENV['SHOP_NAME']}.myshopify.com/admin"

  ShopifyAPI::Base.site = shop_url
end

def get_shopify_product(shopify_id)
  init("get_shopify_product(" + shopify_id + ")")

  product = ShopifyAPI::Product.find(shopify_id)
  return product
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

  connect()

  ARGV.each do|id|
    product  = get_shopify_product(id)
    add_product(product)
  end

end

def title2name(title) 
  if title.start_with?("Julio Hardy, ")
    return title.sub("Julio Hardy, ", "Julio_Hardy=").gsub(" ", "_")
  end
  return title
end

def frame2offset(frame)
  frames = [ "None",
             "White Mat",
             "Black Frame",
             "White Frame",
             "Black Frame White Mat",
             "White Frame White Mat",
             "Black Frame White Mat + Glazing",
             "White Frame White Mat + Glazing"
           ]
  offsets = [  0, 1, 2, 2, 3, 3, 4, 4 ]
  frames.each_with_index do |f,i|
    if frame == f
      return offsets[i]
    end
  end
  return frame
end

def size2tab(size)
  sizes = [ "Small: 8x10in or 8x8in",
           "Medium: 11x14in or 11x11in",
           "Large: 16x20in or 16x16in",
           "Extra Large: 24x30in or 24x24in",
           "Collector size: 30x40in or 30x30in"
         ]
  tabs = [  2, 7, 12, 17, 22 ]
  sizes.each_with_index do |s,i|
    if size == s
      return tabs[i]
    end
  end

  return size
end

def pr(str)
  print str
  $stdout.flush
end

def add_product(product)
  if product == nil
    return
  end

  row = []

  name = title2name(product.title)
  row[0] = name;
  row[1] = " ";

  variants = product.variants
  variants.each do |variant|
    frame = variant.option1
    #paper = variant.option2
    size = variant.option3
    price = variant.price

    offset = frame2offset(frame)
    tab = size2tab(size)
    index = tab + offset

    if row[index]
      if row[index] != price
        puts "Different value for " + name + "/" + frame + "/" + size 
      end
    else
      row[index] = price
    end
    
    #puts name + "," + index.to_s + "," + price
  end

  n = row.length
  row.each_with_index do |v,i|
    v = v.sub(".00", "")
    if i>0
      pr(",")
    end
    if i<2
      pr(v)
    else
      pr(v.to_i.to_s)
    end
  end

  while n < 27
    pr(", NA ")
    n = n + 1
  end

  pr("\n")
end

main()

