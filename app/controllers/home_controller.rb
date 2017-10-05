class HomeController < ShopifyApp::AuthenticatedController
  def index
    @products = ShopifyAPI::Product.find(:all) #, params: { limit: 10 })
    @customers = ShopifyAPI::Customer.all
    @webhooks = ShopifyAPI::Webhook.find(:all)

    tagged_customers = []
    tagged_emails = []                                                                              
    @customers.each do |customer|
      if customer.orders_count > 1
        unless customer.tags.include?("repeat")
          customer.tags += "repeat"
          customer.save
        end
        tagged_customers << customer
        tagged_emails << customer.email
      end
    end

    @tagged_emails = tagged_emails
  end
end
