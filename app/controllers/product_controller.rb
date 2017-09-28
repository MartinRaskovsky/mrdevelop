class ProductController < ApplicationController
  def index
    @images = Image.order('created_at DESC') if !@images
    @design = params['image_id']
    @design_index = 0
    if @design
      @dir = File.dirname(@design)
      @base = File.basename(@design)
      if @base.start_with?("large_")
        @base = @base[6, @base.length]
      end
      @name = @dir + "/" + @base
      @images.each_with_index {|img,i|
        if img.image.to_s == @name
          @design_index = i
          break
        end
      }
    end
    @id = params['id'].to_i
    @product = nil
    content = open("https://api.printful.com/products").read
    @toplevel = JSON.parse content
    if @toplevel['code'] == 200
      @products = @toplevel["result"]
      @products.each do |product|
        if product['id'] == @id
          @product = product
          break
        end
      end
    end
  end
end
