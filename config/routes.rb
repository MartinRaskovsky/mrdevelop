Rails.application.routes.draw do

  resources :mockups

  resources :product do
    resources :index
  end

  root to: 'mockups#index'
  devise_for :users
  resources :users
  resources :images
  mount ShopifyApp::Engine, at: '/'

  get "/shopify"                => 'home#index'
  get '/products'               => 'products#index'
  get "/mockups/new/:id"        => 'mockups#index'
  get "/mockups/generate/:id"   => 'mockups#generate'
  get "/mockups/status/:id"     => 'mockups#status'
  get "/mockups/order/:id"      => 'mockups#order'

  post "/note/checkoutcreation" => 'notes#checkoutcreation'
  post "/note/ordercreation"    => 'notes#ordercreation'
end
