require "json"

module TemplateHelper

  def get_template(type, model)

    product_title = nil
    case type
      when "CUT-SEW"
        if model.include? "Leggings"
          product_title = "leggings"
        elsif model.include? "Mini Skirts"
          product_title = "mini_skirts"
        elsif model.include? "Crop Top"
          product_title = "crop_top"
        elsif model.include? "Tank Top"
          product_title = "tank_top"
        elsif model.include? "Pencil Skirts"
          product_title = "pencil_skirts"
        end
      when "FRAMED-POSTER"
        product_title = "8x10"
      when "MUG"
        product_title = "11oz"
    end
    
    if !product_title
      #config.logger = Logger.new(STDOUT)
      logger.debug "type=" + type + "; model=" + model
      return nil
    end

    return product_title

    #if ProductTemplate.count == 0
    #  update
    #end

    #product_templates = ProductTemplate.where({"product_title" => product_title})
    #if product_templates.length == 0
    #  return nil
    #end 

    #template = TemplateDatum.where({"product_id" => product_templates[0]['product_id']})
    #if template.length == 0
    #  return nil
    #end

    #return template[0]
  end

  private

  def update
    file = File.read('public/exported_templates/templates.json')
    items = JSON.parse(file)
    items.each do |item|
      product = ProductTemplate.new
      product.product_title = item["product_title"]
      product.product_id = item["product_id"]
      product.save

      templates = item["templates"]
      templates.each do |src|
        dst = TemplateDatum.new
        dst.product_id       = item["product_id"] 
        dst.title            = src['title']
        dst.group            = src['group']
        dst.width            = src['width']
        dst.height           = src['height']
        dst.placement        = src['placement']
        dst.hashdata         = src['hash']
        dst.area_width       = src['area_width']
        dst.area_height      = src['area_height']
        dst.area_x           = src['area_x']
        dst.area_y           = src['area_y']
        dst.safe_area_width  = src['safe_area_width']
        dst.safe_area_height = src['safe_area_height']
        dst.safe_area_x      = src['safe_area_x']
        dst.safe_area_y      = src['safe_area_y']
        dst.order            = src['order']
        dst.file_background  = src['file_background']
        dst.file_overlay     = src['file_overlay']
        dst.save
      end
    end
  end
end
