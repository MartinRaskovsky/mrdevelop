include FileNameHelper
include PostHelper
include TemplateHelper

class ProductController < ApplicationController
  def index
    @images = Image.order('created_at DESC') if !@images
    @design = params['image_id']
    @design_index = 0
    if @images.length == 0
      @design = nil
    end
    if @design
      @name = base_image_name(@design)
      @images.each_with_index {|img,i|
        if img.image.to_s == @name
          @design_index = i
          break
        end
      }
    end
    @id = params['id'].to_i
    @product, @variants = get_variants(params['id'])
    if !@variants
      redirect_to :controller => 'products', :action => 'index'
    end

    template = get_template(@product['type'], @product['model'])
    if template == nil
      @overlay    = "/masks/leggings.png"
      @background = @background
    else
      #@overlay    = "/exported_templates/" + template.file_overlay
      #@background = "/exported_templates/" + template.file_background
      @overlay    = "/masks/" + template + ".png"
      @background = @overlay
    end

  end
end
