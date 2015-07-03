Rails.application.routes.draw do
  resources :subscribe, only: [:new, :update]
  resources :merchants
  devise_for :users
  resources :users, only: [:update]
  root to: 'products#index'
  resources :charges, only: [:new, :create]
  resources :refunds, only: [:create]
  resources :products
  resources :purchases, only: [:index]
end
