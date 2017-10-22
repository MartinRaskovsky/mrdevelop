include FileNameHelper                                                                                     
include ImageHelper
include PostHelper

class PrintfileJob
  @user
  @params
  @printfile

  def initialize(user, params, printfile)
    @user = user
    @params = params
    @printfile = printfile
    logger = Logger.new(STDOUT)
  end

  def perform
    generate_printfile(@user, @params)
  end

  private
 
  def generate_printfile(user, params)
    logger = Logger.new(STDOUT)
    product_id = params['product_id']
    x = params['xpos_field'].to_i
    y = params['ypos_field'].to_i
    w = 0
    printfile_url = nil

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

    printfiles = post_mockup(product_id, details)

    if !printfiles
      logger.debug "Failed to create printfiles"
      return
    end

    printfiles.each do |printfile|

      main_image = main_image = local_to_url(printfile['mockup_url']) #put_img(user, printfile['mockup_url'], 0)

      # FIXME, we have only generated one image, we have not generated for others like back/label ...
      printfile_image = PrintfileImage.new({
        :printfile_id   => @printfile.id,
        :variant_ids => "",
        :image       => main_image,
        :title       => ""
      })
      if !printfile_image.save
        logger.debug "Failed to save main printfile"
        return
      end

      if printfile['extra']
        printfile['extra'].each do |extra|

          printfile_image = PrintfileImage.new({
            :printfile_id   => @printfile.id,
            :variant_ids => printfile['variant_ids'].to_s,
            :image       => extra['url'],
            :title       => extra['title']
          })
          if !printfile_image.save
            logger.debug "Failed to save printfile_image"
            return
          end
        end
      end

      printfile_group = PrintfileGroup.new({
        :printfile_id   => @printfile.id,
        :variant_ids => printfile['variant_ids'].to_s,
        :placement   => printfile['placement'],
        :printfile_url  => main_image
      })
      if !printfile_group.save
        logger.debug "Failed to save printfile_group"
        return
      end
      if printfile_url == nil
        printfile_url = main_image
      end
    end

    @printfile.update({
      :printfile_url  => printfile_url
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

end
