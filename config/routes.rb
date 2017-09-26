Rails.application.routes.draw do
  resources :product do
    resources :index
  end

  get '/products' => 'products#index'

  resources :x_users
  root to: 'visitors#index'
  devise_for :users
  resources :users
  mount ShopifyApp::Engine, at: '/'
  get "/shopify" => 'home#index'
end
