Rails.application.routes.draw do
  root to: 'home#home'
  devise_for :users
end
