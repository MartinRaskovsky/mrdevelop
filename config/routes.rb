Rails.application.routes.draw do
  resources :mockups
  resources :product do
    resources :index
  end

  get '/products' => 'products#index'

  resources :x_users
  root to: 'visitors#index'
  devise_for :users
  resources :users
  resources :images
  mount ShopifyApp::Engine, at: '/'
  get "/shopify" => 'home#index'
end
