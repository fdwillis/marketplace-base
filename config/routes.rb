Rails.application.routes.draw do

  resources :reports, only: :index, defaults: { format: 'html' }
  resources :purchases, only: [:create, :update]
  resources :plans, only: [:create, :destroy, :index]
  resources :bank_accounts, only: [:create, :destroy, :update]
  resources :subscribe, only: [:update,:destroy]

  resources :pending_goals, only: :index
  resources :fundraising_goals

  resources :orders
  resources :notifications, only: [:create, :update]

  resources :merchants, only: [:index, :show]
  resources :pending_products, only: [:index, :show]
  resources :refunds, only: [:index, :create, :update]
  
  resources :notifications, only: [:create, :destroy]
  
  devise_for :users
  resources :users, only: [:update]

  get 'shipping_rates' => 'orders#shipping_rates'
  get 'select_label' => 'orders#select_label'
  get 'donate' => 'donate#donate'

  put 'approve_product' => 'pending_products#approve_product'
  put 'approve_goal' => 'pending_goals#approve_goal'
  put 'approve_account' => 'merchants#approve_account'
  put 'active_order' => 'orders#active_order'
  put 'cancel_donation_plan' => 'fundraising_goals#cancel_donation_plan'
  put 'create_user' => 'donate#create_user'
  put 'twilio/text_blast' => 'twilio#text_blast'
  put 'twilio/email_blast' => 'twilio#email_blast'
  
  post 'notifications/twilio' => 'notifications#twilio'
  post 'notifications/import_numbers' => 'notifications#import_numbers'
  post 'notifications/import_emails' => 'notifications#import_emails'
  post 'notifications/remove_text' => 'notifications#remove_text'
  post 'notifications/remove_email' => 'notifications#remove_email'

  root to: 'products#index'
  resources :products
end
