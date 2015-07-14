Rails.application.routes.draw do
  resources :charges, only: [:create]
  root to: 'products#index'

  resources :merchants, only: [:index, :show]
  resources :pending_products, only: [:index, :show]

  resources :plans, only: :index
  resources :products

  resources :purchases, only: [:index]
  resources :refunds, only: [:index, :create, :update]
  
  resources :reports, only: :index
  resources :subscribe, only: [:update,:destroy]
  
  devise_for :users
  resources :users, only: [:update]

  put 'approve_product' => 'pending_products#approve_product'
end
