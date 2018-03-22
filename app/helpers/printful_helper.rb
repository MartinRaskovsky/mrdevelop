require 'set'

require './app/helpers/printful_names_helper'
include PrintfulNamesHelper

module PrintfulHelper

  def find_id_by_position(shopify_variants, position)
    shopify_variants.each do |shopify_variant|
      if shopify_variant.position == position
        return shopify_variant.id
      end
    end
    failed("Failed to find id by position " + position.to_s + " in " + shopify_variants.to_json)
    return nil
  end

  def mkmap(pr, variants)
    result = []
    shopify_variants = pr.variants
    variants.each do |variant|
      position = variant[:position]
      shopify_id = find_id_by_position(shopify_variants, position)
      result[position] = shopify_id
    end
    return result
  end
 
  def get_options(variants)
    size = []
    color = []
    variants.each do |variant|
      size << variant['size'] if variant['size']
      if variant['color']
        if color.length==0 or variant['color'] != color[0]
          color <<  variant['color']
        end
      end
    end
    result = []
    if size.length > 1
      option = { "name" => "Size", "values" => size }
      result << option
    end
    if color.length > 1
      option = { "name" => "Colour", "values" => color }
      result << option
    end
    return result
  end
  
  def get_ids(variants)                                                           
    result = []
    variants.each do |variant|
      result << variant['id']
    end
    return result
  end

  def get_printful_variants(product_id)

    product, variants = get_variants(product_id)
    mcolor = is_mcolor(product['model'])

    results = []

    color = nil
    variants.each do |variant|
      if (mcolor or color==nil or variant['color']==color)
          results << variant
          color = variant['color']
        end
      end

    return product, results
  end

  def find_position(vs, s)
    position = 0
    vs.each do |v|
      position = position + 1
      if (v == s)
        return position
      end
    end
    failed("Failed to find position for " + s + " in " + vs.to_s)
    return position
  end

  def find_var_printfile(printfiles, id)
    printfiles.each do |printfile|
      if printfile['variant_id'] == id
        return printfile
      end
    end
    failed("Failed to find variant_id " + id.to_s)
    return nil
  end

  def find_printfile(printfiles, id)
    printfiles.each do |printfile|
      if printfile['printfile_id'] == id
        return printfile
      end
    end
    failed("Failed to find print file with id=" + id.to_s + " in " + printfiles.to_s)
    return nil
  end

  def find_placement(available_placements, placements)
    available_placements.each do |key, value|
      printfile_id = placements[key]
      if printfile_id
        return key
      end
    end
    failed("Failed to find placement " + placements.to_json)
    return nil
  end

  def get_printfile_items(product_id, vars)
    set = Set.new([]) 
    items = get_printfile_details(product_id)
    #available_placements = items['available_placements']
    #printfiles           = items['printfiles']
    var_printfiles       = items['variant_printfiles']
    #options              = items['options']

    vars.each do |var|
      var_id = var['id']
      var_printfile = find_var_printfile(var_printfiles, var_id)
      if var_printfile
        placements = var_printfile['placements']
        placements.each do |key, value|
          set.add(value)
        end
      end
    end 
  
    return items, set.to_a
  end

  def add_printfiles(set, product_id)
    product, variants = get_printful_variants(product_id)
    items, printfile_ids = get_printfile_items(product_id, variants)
    printfiles           = items['printfiles']
    var_printfiles       = items['variant_printfiles']
 
    printfile_ids.each do |id|
      pf = find_printfile(printfiles, id)
      set.add(pf)
    end

    presult = get_presults(product_id, variants, var_printfiles)
  
    return set, presult
  end

  def find_prs(prs, pid, vid)
    result = []
    prs.each do |pr|
      if pr['product_id'] == pid and pr['var_id'] == vid
        result << pr
      end
    end
    if result.length==0
      failed("Failed to find pr: " + pr.to_json + " in prs " + prs.to_json)
      return nil
    end
    return result
  end

  def make_printfiles(set, prs, product_id)
    result = []
    product, variants = get_printful_variants(product_id)
    files = product['files']
    variants.each do |var|
      subset_prs = find_prs(prs, product_id, var['id'])
      if subset_prs
        subset_prs.each do |pr|
          pf, index = set_find_printfile(set, pr)
          if pf
            result << {
              "product_id" => product_id,
              "variant_id" => var['id'],
              "type"       => pr['type'],
              "file_type"  => files[index]['type'],
              "placement"  => pr['placement'],
              "width"      => pf[:width],
              "height"     => pf[:height],
              "dpi"        => pf[:dpi],
              "actual_w"   => pf[:actual_w],
              "actual_h"   => pf[:actual_h],
              "url"        => pf[:url],
              "lowurl"     => pf[:lowurl]
            }
          end
        end
      end
    end

   return result
  end

  def find_local_image(pfs, w, h)
    pfs.each do |pf|
      if pf[:actual_w] == w and pf[:actual_h] == h
        return pf
      end
    end

    return nil
  end

  def generate_mockup_image(image, pf)
    init("generate_mockup_image(" + image + ", " + pf.to_s + ")")
    #x = 0
    #y = 0
    #w = pf['width']
    #h = pf['height']
    #w, h = scale_to_fit(1000, w, h)
    #local_image = generate_image("1", base_image_name(image), x, y, w, h, pf)
    #url = local_to_url(local_image)
    #return url
    init("generate_mockup_image=" + pf["lowurl"] + ")")
    return pf["lowurl"]
  end

  def find_lowurl(placement, pfs)
    init("find_lowurl(" + placement + ")")
    pfs.each do |pf|
      if pf['type'] == placement
        init("find_lowurl=" + pf["lowurl"])
        return pf["lowurl"]
      end
    end
    fail("Failed to find " + placement + " in " + pfs.to_json)
    return nil
  end

  def get_mockup_images(product_id, pfs)
    result = {}
    items = get_printfile_details(product_id)
    available_placements = items['available_placements']
    available_placements.each do |placement, value|
      if !placement.start_with?("label")
        url = find_lowurl(placement, pfs)
        result.merge!(placement => url)
      end
    end
    return result
  end

  def generate_printfile(pfs, pf, image)
    init("generate_printfile(" + pf.to_json + ", " + image + ")")
    x = 0
    y = 0
    id = pf['printfile_id']
    w = pf['width']
    h = pf['height']
    dpi = pf['dpi']
    local_image = generate_image(1, image, x, y, w, h, pf)
    width, height = get_image_dimensions(local_image)

    found = find_local_image(pfs, width, height)
    if found
      File.delete(local_image) if File.exist?(local_image)
      hghurl = found[:url]
      lowurl = found[:lowurl]
    else
      hghurl = local_to_url(local_image)
      loww, lowh = scale_to_fit(1000, width, height)
      lowlocal = generate_lowimage(2, local_image, loww, lowh, pf)
      lowurl = local_to_url(lowlocal)
    end
    pf.merge!(width:    w)
    pf.merge!(height:   h)
    pf.merge!(dpi:      dpi)
    pf.merge!(url:      hghurl)
    pf.merge!(lowurl:   lowurl)
    pf.merge!(actual_w: width)
    pf.merge!(actual_h: height)
    message("HGH=" + hghurl)
    message("LOW=" + lowurl)
  end                    

  def generate_printfiles(image, pfs)
    pfs.each do |pf|
      generate_printfile(pfs, pf, image)
    end
  end

  private

  def set_find_printfile(printfiles, pr)                                                              
    printfiles.each_with_index do |pf, index|
      if pf['printfile_id'] == pr['printfile_id']
        return pf, index
      end
    end
    failed("Failed to find pr id: " + pr['printfile_id'] + " in set " + set.to_json)
    return nil
  end

  def get_presults(product_id, variants, var_printfiles)                                              
    presult = []
    variants.each do |variant|
      var_id = variant['id']
      var_printfile = find_var_printfile(var_printfiles, var_id)
      if var_printfile
        placements = var_printfile['placements']
        placements.each do |key, value|
          presult << {
             'product_id'   => product_id,
             'var_id'       => var_id,
             'printfile_id' => value,
             'type'         => key,
          }
        end
      end
    end

    return presult
  end

end
