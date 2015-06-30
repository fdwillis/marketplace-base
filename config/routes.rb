Rails.application.routes.draw do
  resources :products
  root to: 'home#home'
  devise_for :users
end
