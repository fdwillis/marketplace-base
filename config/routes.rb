Rails.application.routes.draw do
  resources :orders
  resources :fundraising_goals

  resources :charges, only: [:create]
  resources :notifications, only: [:create, :update]

  resources :merchants, only: [:index, :show]
  resources :pending_products, only: [:index, :show]

  resources :plans, only: :index

  resources :purchases, only: [:create, :update]
  resources :refunds, only: [:index, :create, :update]
  
  resources :reports, only: :index
  resources :subscribe, only: [:update,:destroy]
  
  devise_for :users
  resources :users, only: [:update]

  get 'shipping_rates' => 'orders#shipping_rates'
  get 'select_label' => 'orders#select_label'
  put 'approve_product' => 'pending_products#approve_product'
  put 'approve_merchant' => 'merchants#approve_merchant'
  put 'active_order' => 'orders#active_order'
  put 'cancel_donation_plan' => 'fundraising_goals#cancel_donation_plan'
  post 'notifications' => 'notifications#create'
  post 'twilio/voice' => 'twilio#voice'

  root to: 'products#index'
  resources :products
end
