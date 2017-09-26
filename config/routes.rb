Rails.application.routes.draw do
  resources :x_users
  root to: 'visitors#index'
  devise_for :users
  resources :users
  mount ShopifyApp::Engine, at: '/'
  get "/shopify" => 'home#index'
end
