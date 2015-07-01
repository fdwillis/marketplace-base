Rails.application.routes.draw do
  resources :charges, only: [:new, :create]
  resources :refunds, only: [:create]
  resources :products
  resources :purchases, only: [:index]
  root to: 'products#index'
  devise_for :users
  resources :users, only: [:update]
end
