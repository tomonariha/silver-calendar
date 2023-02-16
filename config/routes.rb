# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  draw :api
  post 'days/:year/:month', to: 'days#update'
  delete 'days/:year/:month/:date', to: 'days#destroy'
  post 'api/alignment/calendars/:year', to: 'api/alignment#create'
  delete 'api/alignment/calendars/:year', to: 'api/alignment#destroy'
  put 'api/alignment/calendars/:year', to: 'api/alignment#update'
end
