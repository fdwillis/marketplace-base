Rails.application.routes.draw do
  resources :charges, only: [:new, :create]
  resources :products
  resources :purchases, only: [:new, :create, :index]
  root to: 'products#index'
  devise_for :users
  resources :users, only: [:update]
end
