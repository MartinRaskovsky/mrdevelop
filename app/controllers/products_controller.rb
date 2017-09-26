require 'json/pure'
require 'open-uri'

class ProductsController < ApplicationController
  def index
    @types = {}
    content = open("https://api.printful.com/products").read
    @toplevel = JSON.parse content
    if @toplevel['code'] == 200
      @code = @toplevel["code"]
      @products = @toplevel["result"]
      @products.each do |product|
        type = product['type']
        array = @types[type]
        if not array.kind_of?(Array)
          array = []
        end
        array << product
        @types[type] = array
      end
    else
      @products = []
    end
  end
end
