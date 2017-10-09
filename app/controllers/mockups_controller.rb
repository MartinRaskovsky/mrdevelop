require 'json'

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

  # GET /mockups/new
  def new
    mockup = Mockup.find(params[:id])
    if !mockup
      redirect_to mockups_url, notice: 'Failed to find mockup id ' + params[:id]
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

    mockup.update(shopify_id: product.id)
    redirect_to mockups_url, notice: 'Shopify product was successfully created.'
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

end

