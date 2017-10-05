include FileNameHelper
include ImageHelper
include PostHelper

class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update]
 
  def index
    form = Form.new(params[:form].permit!)
    @images = Image.order('created_at DESC') if !@images
  end

  def show
  end
 
  def new
    @image = Image.new
  end
 
  def create
    commit = params[:commit]
    if commit == "Make Design"
      make_design
   elsif commit == "Upload Image"
      upload_image
   elsif commit == "Generate Mockup"
      generate_mockup
   else
      url = { :controller => 'product', :action => 'index', :id => params["product_id"] }
      redirect_to url
    end
  end
 
  def edit
  end
 
  def update
    if @image.update_attributes(image_params)
      redirect_to image_path(@image)
    else
      render :edit
    end
  end
 
  private
 
  def image_params
    params.require(:image).permit(:name, :image, :image_id, :id)
  end
 
  def set_image
    @image = Image.find(params[:id])
  end

  private

  def has_select_image
    if params.has_key?(:image)
      image = params['image']
      name = image["name"]
      if name && name.length>0
        return true
      end
    end
    return false
  end

  def has_upload_image
    if params.has_key?(:image)
      image = params['image']
      img = image["image"]
      if img
        return true
      end
    end
    return false
  end

  def has_design
    if params.has_key?(:image_id)
      return true
    end
    return false
  end

  def make_design
    if has_select_image
      image = params['image']
      @image_name  = large_image_name(image["name"])
      redirect_to :controller => 'product', :action => 'index', :id => params["product_id"], :image_id => @image_name
    else
      redirect_to :controller => 'product', :action => 'index', :id => params["product_id"]
    end
  end

  def upload_image
    if has_upload_image
      @image = Image.new(image_params)
      if @image.save
        redirect_to :controller => 'product', :action => 'index', :id => params["product_id"]
      else
        render :new
      end
    else
      redirect_to :controller => 'product', :action => 'index', :id => params["product_id"]
    end
  end

  def generate_mockup
    config.logger = Logger.new(STDOUT)
    if has_design
      product_id = params['product_id']
      x = params['xpos_field'].to_i
      y = params['ypos_field'].to_i
      w = 1000

      vars = printfile_variants(product_id)
      details = printfile_details(product_id, vars)
      
      image_name = generate_image(base_image_name(params['image_id']), x, y, w)
      remote_image = put_img(image_name, 0)

      details.each do |detail|
        detail['printfile'].store("image_url", remote_image)
      end

      mockups = post_mockup(product_id, details)
      if mockups
        mockups.each do |mockup|
          thumb_url  =  generate_thumb(mockup["mockup_url"])
          product_url = product_thumb(params["product_id"])
          image_url =   image_thumb(params['image_id'])
          args = {
            "variant_ids" => mockup["variant_ids"].to_s,
            "placement"   => mockup["placement"],
            "mockup_url"  => mockup["mockup_url"],
            "thumb_url"   => thumb_url,
            "product_url" => product_url,
            "image_url"   => image_url,
            "printful_id" => params["product_id"].to_i,
            "shopify_id"  => 0
         }
          logger.debug args['mockup_url']
          logger.debug params
          @mockup = Mockup.new(args)
          if !@mockup.save
            debug.logger "Failed to save mockup"
          end
        end
        redirect_to :controller => '/mockups'
      else
        redirect_to :controller => 'product', :action => 'index', :id => params["product_id"], :image_id => params[:image_id]
      end
    else
      redirect_to :controller => 'product', :action => 'index', :id => params["product_id"]
    end
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

    logger.debug result
    return result
  end

  def generate_thumb(mockup_url)
    return scale_to_url_thumb(mockup_url);
  end

  def product_thumb(product_id)
    product = get_product(product_id)
    return scale_to_url_thumb(product['image']);
  end

  def image_thumb(large_url)
    return thumb_image_name(large_url)
  end
end
