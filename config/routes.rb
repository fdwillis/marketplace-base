Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:update]
  root to: 'products#index'
  resources :charges, only: [:new, :create]
  resources :refunds, only: [:create]
  resources :products
  resources :purchases, only: [:index]
end
