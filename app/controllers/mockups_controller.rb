require 'json'

include FileNameHelper                                                                                            
include PostHelper

class MockupsController < ShopifyApp::AuthenticatedController
  layout false
  layout 'application'
  before_action :set_mockup, only: [:show, :edit, :update, :destroy]

  # GET /mockups
  # GET /mockups.json
  def index
    @mockups = Mockup.order('created_at DESC')
  end

  # GET /mockups/1
  # GET /mockups/1.json
  def show
  end

  # GET /status
  def status
    @mockups = Mockup.order('created_at DESC') if @mockups == nil

    all_done = true
    @mockups.each do |mockup|
      job_id = mockup.job_id
      if job_id && job_id > 0
        all_done = false
        job = DelayedJob.find_by_id(job_id)
        if job == nil
          mockup.update({:job_id => 0})
          render nothing: true, status: 403
          return
        end
      end
    end

    if all_done
      render nothing: true, status: 403
      return
    end

    render json: { :success => true }
  end

  # GET /mockups/generate
  def generate
    config.logger = Logger.new(STDOUT)

    product_id = params[:id]
    image_id = params['image_id']
    params['product_id'] = product_id


    product = get_product(product_id)
    @mockup = Mockup.new({
      :product_url => product['image'],
      :image_url   => image_thumb(image_id), 
      :thumb_url   => nil,
      :mockup_url  => nil,
      :printful_id => product_id.to_i,
      :shopify_id  => 0,
      :job_id      => 0
    })

    if !@mockup.save                                                                                       
      logger.debug "Failed to save mockup"
      redirect_to :controller => 'product', :action => 'index', :id => product_id, :image_id => image_id
      return
    end

    @job = Delayed::Job.enqueue MockupJob.new(current_user, params, @mockup)
    
    @mockup.update({:job_id => @job.id})
    redirect_to mockups_path, notice: "Mockup creation is in the background"
  end

  # GET /mockups/new
  def new
    mockup = Mockup.find(params[:id])
    if !mockup
      redirect_to mockups_url, notice: 'Failed to find mockup id ' + params[:id]
      return
    end
    printful_id = mockup['printful_id']
    printful, printful_variants = get_variants(printful_id.to_s)

    product = ShopifyAPI::Product.new
    product.title = ""
    #product.title << printful['brand'] if printful['brand']
    #product.title << " "
    product.title << printful['model'] if printful['model']
    product.body_html = printful['description']

    product.variants = []
    groups = MockupGroup.where('mockup_id' => mockup.id)
    groups.each do |group|
      variant_ids = JSON.parse(group.variant_ids)
      variant_ids.each do |variant_id|
        variant = find_printful_variant(printful_variants, variant_id)
        if variant == nil
          redirect_to mockups_url, notice: "Failed to find variant id " + variant_id.to_s
          return
        end
        product.variants << ShopifyAPI::Variant.new(
         :title                => variant['name'],
         :price                => variant['price'],
         :option1              => variant['size'],
         :inventory_management => 'shopify',
         :inventory_quantity   => 1000
        )
      end
    end

    product.images = [] 
    images = MockupImage.where('mockup_id' => mockup.id)
    images.each do |image|
      #variant_ids = JSON.parse(image.variant_ids)
      #variant_ids.each do |variant_id|
          product.images << {
            "src" => image['image']
          }
      #end
    end

    if !product.save
      redirect_to mockups_url, notice: 'Failed to save product.'
      return
    end

    mockup.update({:shopify_id => product.id})  
    redirect_to mockups_url, notice: 'Shopify product was successfully created.'
  end

  # GET /mockups/order
  def order
    config.logger = Logger.new(STDOUT)                                                                                       

    mockup = Mockup.find(params[:id])
    if !mockup
      redirect_to mockups_url, notice: 'Failed to find mockup id ' + params[:id]
      return
    end

    shopify_id = mockup.shopify_id
    product = ShopifyAPI::Product.find(shopify_id)
    if !product
      redirect_to mockups_url, notice: 'Failed to find associated Shopify product'
      return
    end

    line_items = []
    product.variants.each do |variant|
      line_items << ShopifyAPI::LineItem.new(
          :quantity      => 1,
          :variant_id    => variant.id
      )
    end

    customer = ShopifyAPI::Customer.new(
      :email         => current_user.email,
      :first_name    => current_user.name
    )

    ShopifyAPI::LineItem.new
    order = ShopifyAPI::Order.new(
      :line_items    => line_items,
      :email         => "martinr6969@gmail.com",
      :customer      => customer
    )

    #logger.debug order.to_json

    if !order.save
      redirect_to mockups_url, notice: 'Failed to save order.'
      return
    end
    logger.debug order.to_json

    mockup.update({:order_status_url => order.order_status_url}) 

    redirect_to mockups_url, notice: 'Product was successfully ordered.'
  end

  # GET /mockups/1/edit
  def edit
  end

  # POST /mockups
  # POST /mockups.json
  def create
    @mockup = Mockup.new(mockup_params)

    respond_to do |format|
      if @mockup.save
        format.html { redirect_to @mockup, notice: 'Mockup was successfully created.' }
        format.json { render :show, status: :created, location: @mockup }
      else
        format.html { render :new }
        format.json { render json: @mockup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mockups/1
  # PATCH/PUT /mockups/1.json
  def update
    respond_to do |format|
      if @mockup.update(mockup_params)
        format.html { redirect_to @mockup, notice: 'Mockup was successfully updated.' }
        format.json { render :show, status: :ok, location: @mockup }
      else
        format.html { render :edit }
        format.json { render json: @mockup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mockups/1
  # DELETE /mockups/1.json
  def destroy
    @mockup.destroy
    respond_to do |format|
      format.html { redirect_to mockups_url, notice: 'Mockup was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mockup
    @mockup = Mockup.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mockup_params
    params.require(:mockup).permit(:mockup_url, :placement, :variant_ids)
  end

  def find_printful_variant(variants, id)
    variants.each do |variant|
      if variant['id'] == id
        return variant
      end
    end
    return nil
  end

  def image_thumb(large_url)
    return thumb_image_name(large_url)
  end

end

