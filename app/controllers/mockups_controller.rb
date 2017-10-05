include PostHelper

class MockupsController < ShopifyApp::AuthenticatedController
  layout false
  layout 'application'
  before_action :set_mockup, only: [:show, :edit, :update, :destroy]

  # GET /mockups
  # GET /mockups.json
  def index
    @mockups = Mockup.all
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
    printful, variants = get_variants(printful_id.to_s)
    product = ShopifyAPI::Product.new
    product.title = ""
    #product.title << printful['brand'] if printful['brand']
    #product.title << " "
    product.title << printful['model'] if printful['model']
    product.body_html = printful['description']
    product.variants = []
    product.images = []
    variants.each do |variant|
      product.variants << ShopifyAPI::Variant.new(
       :title                => variant['name'],
       :price                => variant['price'],
       :option1              => variant['size'],
       :inventory_management => 'shopify',
       :inventory_quantity   => 1000
      )
      product.images << {
        # FIXME, we have only generated one image, we have not generated for variants
        "src" => mockup['mockup_url']
      }
    end
    response = product.save
    if response
      mockup.update(shopify_id: product.id)
      redirect_to mockups_url, notice: 'Shopify product  was successfully created.'
    else
      redirect_to mockups_url, notice: 'Failed to create Shopify product.'
    end
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
end
