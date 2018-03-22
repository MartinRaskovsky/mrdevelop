require "./app/helpers/shopify_image_position.rb"
include ShopifyImagePosition

require "./app/helpers/sync_helper"                                                                 
include SyncHelper

ACTIVE = true

module ShopifyProductHelper

  def generate_product(product_id, urls, artist, name, tags, pfs)
    product, variants = get_printful_variants(product_id)
    title  = get_title(product['model'])
    tag    = get_tag  (product['model'])
    mcolor = is_mcolor(product['model'])
  
    items, printfile_ids = get_printfile_items(product_id, variants)
    available_placements = items['available_placements']
    printfiles           = items['printfiles']
    var_printfiles       = items['variant_printfiles']
  
    var_ids = get_ids(variants)
    #puts "Generating mockups for: " + var_ids.to_s
    mockups = _post_mockup(product_id, var_ids, available_placements, urls)
  
    shopify_options = []
    shopify_variants = []
    shopify_images = []
  
    shopify_title = "Art by " + artist + ", " + name
    shopify_title << ", " + title

    shopify_handle = "gift-" + shopify_title.gsub(",","").gsub(" ", "-").gsub("í","i").downcase
  
    shopify_body_html = product['description'].gsub("\r\n", "<br>").gsub("\n", "<br>")
  
    shopify_tags = tags + ", " + tag
  
    position = 0
    mockups.each do |mockup|
  
      position = position + 1
      shopify_images << {
        'src'      => mockup['mockup_url'],                                       
        'position' => position
      }
  
      if mockup['extra']
        mockup['extra'].each do |extra|
          #message("extra title = " + extra['title'])
          position = position + 1
          shopify_images << {
            'src'      => extra['url'],
            'position' => position
          }
        end
      end
    end
 
    position_images(title, tag, shopify_images)
 
    options = get_options(variants)
    hassize = false
    hascolor = false
    size_values = []
    color_values = []
    if options.length > 0
      options.each do |option|
        if option['name'] == "Size" and option['values'].length > 1
          hassize = true
          size_values = sort_sizes(option['values'])
          shopify_body_html << size_guide(title, tag, size_values)
        end
        if option['name'] == "Colour" and mcolor and option['values'].length > 1
          hascolor = true
        color_values = option['values']
          hassize = false # EXPERIMENTAL
        end
      end
    end
  
    position = 0
    if hassize
      position = position + 1
      shopify_options << {
        'name'     => 'Size',
        'position' => position,
        'values'   => size_values
      }
    end
    if hascolor
      position = position + 1
      shopify_options << {
        'name'     => 'Colour',
        'position' => position,
        'values'   => color_values
      }
    end
  
    position = 0;
    variants.each do |variant|
  
      # sortout order
      # this might not work in other situation, current situation is only Tote & Bags match this
      if hassize and not hascolor
        position = find_position(size_values, variant['size'])
      elsif hassize and hascolor
        position = position + 1
      else
        variant['size'] = nil
        position = position + 1
      end
      variant.merge!(position: position)
  
      # sortout options
      option1 = nil
      option2 = nil
      if hassize and hascolor
        option1 = variant['size']
        option2 = variant['color']
      elsif hassize
        option1 = variant['size']
      elsif hascolor
        option1 = variant['color']
      end
  
      shopify_variant = ShopifyAPI::Variant.new(
       :title                => variant['name'],
       :price                => variant['price'],
       :position             => position,
       :inventory_policy     => "deny",
       :fulfillment_service  => "manual",	# CHECKME: should be perhapps "Printful",
       :option1              => option1,
       :option2              => option2,
       :inventory_management => 'shopify',
       :inventory_quantity   => 20
      )
      shopify_variants[position-1] = shopify_variant
    end
  
    #puts "Generating product: " + shopify_title
    pr = ShopifyAPI::Product.new({
        'title'     => shopify_title,
        'body_html' => shopify_body_html,
        'vendor'    => "Artendipity",
        'handle'    => shopify_handle,
        'product_type' => "gift",         # is it useful ?
        'published' => "true",            # checkme
        'tags'      => shopify_tags,      # add more
        'variants'  => shopify_variants,
        'options'   => shopify_options,
        'images'    => shopify_images,
        'image'     => shopify_images[0]
        })
  
    #puts "============================================"
    #puts pr.to_json

    if ACTIVE  
      puts "Saving product: " + shopify_title
      if pr.save
         map = mkmap(pr, variants)
         sync_shopify_printful(product_id, pfs, pr, variants, map)
      else
        failed("Failed to create: " + pr.title)
        return nil
      end
    end
    
    #puts "---------------------------------------------"
    #puts pr.to_json
    #puts "============================================"
  
    return pr
  end

end

