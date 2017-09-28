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
    config.logger = Logger.new(STDOUT)
    commit = params[:commit]
    logger.debug commit
    if commit == "Select Image"
      image = params['image']
      @file_name = image["name"]
      @dir = File.dirname(@file_name)
      @base = File.basename(@file_name)
      @image_name  = @dir + "/" + "large_" + @base
      logger.debug @image_name
      url = { :controller => 'product', :action => 'index', :id => params["product_id"], :image_id => @image_name }
      redirect_to url
   elsif commit == "Upload Image"
      @image = Image.new(image_params)
      if @image.save
        url = { :controller => 'product', :action => 'index', :id => params["product_id"] }
        redirect_to url
      else
        render :new
      end
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
end
