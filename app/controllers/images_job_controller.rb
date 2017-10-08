include FileNameHelper                                                                                     
include ImageHelper
include PostHelper

class ImagesJobController < Struct.new(:user, :params, :mockup)

  def perform
    self.params = params
    @mockup = mockup
    logger = Logger.new(STDOUT)
    generate_mockup(user)
  end

  private
 
  def generate_mockup(user)
    product_id = params['product_id']
    x = params['xpos_field'].to_i
    y = params['ypos_field'].to_i
    w = 1000
    mockup_url = nil

    vars = printfile_variants(product_id)
    details = printfile_details(product_id, vars)
      
    image_name = generate_image(user, base_image_name(params['image_id']), x, y, w)
    if true
      remote_image = put_img(user,  image_name, 1)
    else
      remote_image = "http://martinr.com/img/barcelona/Sagrada_Familia_I_DSC_5914-m.jpg"
    end
    if remote_image == nil
      #redirect_to :controller => 'product', :action => 'index', :id => params["product_id"], :image_id => params[:image_id]
      return
    end

    # TEMPORARY until each detail gets its own image
    details.each do |detail|
      detail['printfile'].store("image_url", remote_image)
    end

    mockups = post_mockup(product_id, details)
    if !mockups
      #redirect_to :controller => 'product', :action => 'index', :id => params["product_id"], :image_id => params[:image_id]
      return
    end

    mockups.each do |mockup|

      main_image = mockup['mockup_url'] #put_img(user, mockup['mockup_url'], 0)

      # FIXME, we have only generated one image, we have not generated for others like back/label ...
      mockup_image = MockupImage.new({
        :mockup_id   => @mockup.id,
        :variant_ids => "",
        :image       => main_image,
        :title       => ""
      })
      if !mockup_image.save
        logger.debug "Failed to save main mockup_image"
        #redirect_to :controller => '/mockups'
        return
      end

      if mockup['extra']
        mockup['extra'].each do |extra|

          mockup_image = MockupImage.new({
            :mockup_id   => @mockup.id,
            :variant_ids => mockup['variant_ids'].to_s,
            :image       => extra['url'],
            :title       => extra['title']
          })
          if !mockup_image.save
            logger.debug "Failed to save mockup_image"
            #redirect_to :controller => '/mockups'
            return
          end
        end
      end

      mockup_group = MockupGroup.new({
        :mockup_id   => @mockup.id,
        :variant_ids => mockup['variant_ids'].to_s,
        :placement   => mockup['placement'],
        :mockup_url  => main_image
      })
      if !mockup_group.save
        logger.debug "Failed to save mockup_group"
        #redirect_to :controller => '/mockups'
        return
      end
      if mockup_url == nil
        mockup_url = main_image
      end
    end

    @mockup.update({
      #:product_url => product_thumb(user, params['product_id']),
      #:image_url   => image_thumb(params['image_id']),
      :thumb_url   => generate_thumb(user, mockups[0]['mockup_url']),
      :mockup_url  => mockup_url,
      #:printful_id => params['product_id'].to_i,
      #:shopify_id  => 0
    })

    #redirect_to mockups_path, notice: "Mockup was successfully created."

  end

  def printfile_variants(product_id)
    products, variants = get_variants(product_id)
    if !variants
      return [ product_id ]
    end

    if variants.length > 1
      return [ variants[0]['id'], variants[1]['id'] ]
    end

    if variants.length == 1
      return [ variants[0]['id'] ]
    end

    return [ product_id ]
  end

  def find_var_printfile(printfiles, id)
    printfiles.each do |printfile|
      if printfile['variant_id'] == id
        return printfile
      end
    end
    logger.debug "Failed to find variant_id " + id.to_s
    return nil
  end

  def find_printfile(printfiles, id)
    printfiles.each do |printfile|
      if printfile['printfile_id'] == id
        return printfile
      end
    end
    logger.debug "Failed to find variant_id " + id.to_s
    return nil
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
    vars.each do |var_id|
      var_printfiles = details['variant_printfiles']
      printfiles = details['printfiles']
      var_printfile = find_var_printfile(var_printfiles, var_id)
      if var_printfile
        placements = var_printfile['placements']
        detail = find_detail(result, placements)
        if detail
          detail["variants"] << var_id
        else
          # TEMPORARY generated only for FIRTS placement
          placement_id = placements.values[0]
          printfile = find_printfile(printfiles, placement_id)
          add = { "variants" => [ var_id ], 'placements' => placements, "printfile" => printfile }
          result << add
        end
      end
    end

    return result
  end

  def generate_thumb(user, mockup_url)
    return scale_to_url_thumb(user, mockup_url);
  end

  def product_thumb(user, product_id)
    product = get_product(product_id)
    return scale_to_url_thumb(user, product['image']);
  end

  def image_thumb(large_url)
    return thumb_image_name(large_url)
  end
end
