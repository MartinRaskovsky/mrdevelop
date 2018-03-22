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

  # Configure the Shopify API with our authentication credentials.
  shop_url = "https://#{API_KEY}:#{PASSWORD}@#{SHOP_NAME}.myshopify.com/admin"

  ShopifyAPI::Base.site = shop_url
end

def init(who)                                                                           
  #puts "init: " + who
end

def failed(why)
  puts "failed: " + why
end

def message(what)
  puts "message: " + what
end

def generate_mockup(user_id, product_id, image_id)
  x = 0
  y = 0

  # for MOCKUPS
  w = 1000
  # for PRINTFILE use w=0 and check that scaling is done proportionally
  #w = 0

  mockup_url = nil

  product, variants = get_printful_variants(product_id) 

  details = printfile_details(product_id, variants)

  local_image = generate_image(user_id, "public" + base_image_name(image_id), x, y, w, w-1, 300)
  remote_image = local_to_url(local_image) #put_img(user_id,  local_image, 1)

  message("local_image  = " + local_image)
  message("remote_image = " + remote_image)

  if remote_image == nil
    failed("Failed to create remote image")
    return
  end

  # TEMPORARY until each detail gets its own image
  details.each do |detail|
    detail['printfile'].store("image_url", remote_image)
  end

  mockups = PostHelper::post_mockup(product_id, details)

  if !mockups
    failed("Failed to create mockups")
    return
  end

#puts "+++++++++++++++++++++++++++++++++++++++++"
#puts mockups.to_json
#puts "+++++++++++++++++++++++++++++++++++++++++"

  mockups.each do |mockup|

    shopify_options = []
    shopify_options_values = []

    shopify_variants = []
    shopify_images = []

    shopify_title = ""
    shopify_title << product['model'] if product['model']
    shopify_body_html = product['description']

    shopify_images << {
      'src'      => mockup['mockup_url'],
      'position' => 1
    }

    position = 0;
    variants.each do |variant|
      position = position + 1
      shopify_options_values << variant['size']
      shopify_variants << ShopifyAPI::Variant.new(
       :title                => variant['name'],
       :price                => variant['price'],
       :position             => position,
       :inventory_policy     => "deny",
       :fulfillment_service  => "manual",	# FIXME
       :option1              => variant['size'],
       :inventory_management => 'shopify',
       :inventory_quantity   => 1000
      )
    end

    shopify_options << {
      'name'     => 'Size',
      'position' => 1,
      'values'   => shopify_options_values
    }

    if mockup['extra']
      position = 1
      mockup['extra'].each do |extra|
        position = position + 1
        message("extra title = " + extra['title'])
        message("extra url   = " + extra['url'])
        shopify_images << {
          'src'      => extra['url'],
          'position' => position
        }
      end
    end

    if mockup_url == nil
      mockup_url = mockup['mockup_url']
    end

    pr = ShopifyAPI::Product.new({
      'title'     => shopify_title,
      'body_html' => shopify_body_html,
      'vendor'    => "Printfull",	# checkme
      'handle'    => "handle",		# generate
      'product_type' => "gift",		# is it useful ?
      'published' => "true",		# checkme
      'tags'      => "gift",		# add more
      'variants'  => shopify_variants,
      'options'   => shopify_options,
      'images'    => shopify_images,
      'image'     => shopify_images[0]
    })

    puts "============================================"
    puts pr.to_json

    #if pr.save
    #   puts "Created: " + pr.images.length.to_s + " thumbs in " + pr.title
    #   # CREATE PRINT FILE with w=0 ( see above) and SYNC product to printfile
    #else
    #  failed("Failed to create: " + pr.title)
    #  return
    #end
 # 
 #   puts "---------------------------------------------"
 #   puts pr.to_json
    puts "============================================"

  end

end

def find_detail(details, placements)
  details.each do |detail|
    if detail["placements"] == placements
      return detail
    end
  end
  return nil
end

def printfile_details(product_id, vars)
  result = []
  details = get_printfile_details(product_id)
puts "details: " + details.to_json
  vars.each do |var|
    var_printfiles = details['variant_printfiles']
    printfiles = details['printfiles']

    var_id = var['id']
    var_printfile = find_var_printfile(var_printfiles, var_id)
    if var_printfile
      placements = var_printfile['placements']
      detail = find_detail(result, placements)
puts "detail: " + detail.to_json
      if detail
        detail["variants"] << var_id
      else
        # TEMPORARY generated only for FIRST placement
        placement_id = placements.values[0]
        printfile = find_printfile(printfiles, placement_id)
        add = { "variants" => [ var_id ], 'placements' => placements, "printfile" => printfile }
puts "add: " + add.to_json
        result << add
      end
    end
  end

puts "result: " + result.to_json
  return result
end

def p_get(id)
  result = ""
  p_url = "https://api.printful.com/products/" + id
  content = open(p_url).read
  toplevel = JSON.parse content
  code = toplevel["code"]
  if code == 200                                                           
    result = toplevel["result"]
  else
    puts "Failed to open: " + p_url + "; code=" + code.to_s
  end
  return result
end

def main()
  ENV['LA_CAMISETA_LOCA'] = LA_CAMISETA_LOCA
  ENV['PRINTFUL_KEY']     = PRINTFUL_KEY
  ENV['EPRINTFUL_KEY']    = EPRINTFUL_KEY

  connect()

  ARGV.each do|id|
    #puts p_get(id)
    #puts get_printfile_details(id)
    generate_mockup(USER_ID, id, IMAGE_ID)
  end

end

main()

