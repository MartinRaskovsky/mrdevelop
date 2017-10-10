Rails.application.routes.draw do

  resources :mockups

  resources :product do
    resources :index
  end

  get '/products' => 'products#index'

  root to: 'mockups#index'
  devise_for :users
  resources :users
  resources :images
  mount ShopifyApp::Engine, at: '/'
  get "/shopify" => 'home#index'
  get "/mockups/new/:id"      => 'mockups#index'
  get "/mockups/generate/:id" => 'mockups#generate'
  get "/mockups/status/:id"   => 'mockups#status'
  get "/mockups/order/:id"    => 'mockups#order'
end
