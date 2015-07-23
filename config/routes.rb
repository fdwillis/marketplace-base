Rails.application.routes.draw do
  resources :charges, only: [:create]
  resources :notifications, only: [:create, :update]


  resources :merchants, only: [:index, :show]
  resources :pending_products, only: [:index, :show]

  resources :plans, only: :index
  resources :products
  resources :orders, only: [:update, :index, :create]

  resources :purchases, only: [:index, :create, :update]
  resources :refunds, only: [:index, :create, :update]
  
  resources :reports, only: :index
  resources :subscribe, only: [:update,:destroy]
  
  devise_for :users
  resources :users, only: [:update]

  put 'approve_product' => 'pending_products#approve_product'
  post 'notifications' => 'notifications#create'
  root to: 'products#index'
end
