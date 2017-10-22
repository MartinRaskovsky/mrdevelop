include FileNameHelper                                                                                     
include ImageHelper
include PostHelper

class MockupJob
  @user
  @params
  @mockup

  def initialize(user, params, mockup)
    @user = user
    @params = params
    @mockup = mockup
    logger = Logger.new(STDOUT)
  end

  def perform
    generate_mockup(@user, @params)
  end

  private
 
  def generate_mockup(user, params)
    logger = Logger.new(STDOUT)
    product_id = params['product_id']
    x = params['xpos_field'].to_i
    y = params['ypos_field'].to_i
    w = 1000
    mockup_url = nil

    vars = printfile_variants(product_id)

    details = printfile_details(product_id, vars)

    local_image = generate_image(user, base_image_name(params['image_id']), x, y, w)
    remote_image = local_to_url(local_image) #put_img(user,  local_image, 1)

    if remote_image == nil
      logger.debug "Failed to create remote image"
      return
    end

    # TEMPORARY until each detail gets its own image
    details.each do |detail|
      detail['printfile'].store("image_url", remote_image)
    end

    mockups = post_mockup(product_id, details)

    if !mockups
      logger.debug "Failed to create mockups"
      return
    end

    mockups.each do |mockup|

      main_image = mockup['mockup_url']

      # FIXME, we have only generated one image, we have not generated for others like back/label ...
      mockup_image = MockupImage.new({
        :mockup_id   => @mockup.id,
        :variant_ids => "",
        :image       => main_image,
        :title       => ""
      })
      if !mockup_image.save
        logger.debug "Failed to save main mockup_image"
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
        return
      end
      if mockup_url == nil
        mockup_url = main_image
      end
    end

    @mockup.update({
      :thumb_url   => generate_thumb(user, mockups[0]['mockup_url']),
      :mockup_url  => mockup_url
    })

  end

  def printfile_variants(product_id)
    products, variants = get_variants(product_id)
    if !variants
      return [ product_id ]
    end

    if variants.length > 1
      # TEMPORARY, since we dont have variant choice at GUI level, we choose the first two
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
          # TEMPORARY generated only for FIRST placement
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

end
