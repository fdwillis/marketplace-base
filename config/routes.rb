Rails.application.routes.draw do

  resources :orders
  resources :fundraising_goals

  resources :charges, only: [:create]
  resources :notifications, only: [:create, :update]

  resources :merchants, only: [:index, :show]
  resources :pending_products, only: [:index, :show]

  resources :plans, only: [:create, :destroy]

  resources :purchases, only: [:create, :update]
  resources :refunds, only: [:index, :create, :update]
  
  resources :reports, only: :index
  resources :subscribe, only: [:update,:destroy]
  
  devise_for :users
  resources :users, only: [:update]

  get 'shipping_rates' => 'orders#shipping_rates'
  get 'select_label' => 'orders#select_label'
  get 'donate' => 'donate#donate'

  put 'approve_product' => 'pending_products#approve_product'
  put 'approve_merchant' => 'merchants#approve_merchant'
  put 'active_order' => 'orders#active_order'
  put 'cancel_donation_plan' => 'fundraising_goals#cancel_donation_plan'
  put 'create_user' => 'donate#create_user'
  put 'twilio/text_blast' => 'twilio#text_blast'
  
  post 'notifications' => 'notifications#create'
  post 'notifications/twilio' => 'notifications#twilio'

  root to: 'products#index'
  resources :products
end
