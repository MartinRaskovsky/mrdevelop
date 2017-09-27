class ProductController < ApplicationController
  def index
    @images = Image.order('created_at DESC') if !@images  
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
