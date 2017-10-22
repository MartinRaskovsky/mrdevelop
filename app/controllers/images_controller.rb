include FileNameHelper
include PostHelper

class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update]
 
  def index
    form = Form.new(params[:form].permit!)
    ImageUploader.store_id = current_user.id
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
      make_mockup
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
      ImageUploader.store_id = current_user.id
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

  def make_mockup
    if !has_design 
      redirect_to :controller => 'product', :action => 'index', :id => params["product_id"]
      return
    end

    redirect_to :controller => 'mockups', :action => 'generate', :id => params["product_id"], :image_id => params['image_id']
  end

  def image_thumb(large_url)
    return thumb_image_name(large_url)
  end

end
