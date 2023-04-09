# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  get 'calendar', to: 'calendars#index', as: 'calendar'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  draw :api
  post 'days/:year/:month', to: 'days#update'
  delete 'days/:year/:month/:date', to: 'days#destroy'
  get 'privacy_policy', to: 'home#privacy_policy', as: 'privacy_policy'
  get 'tos', to: 'home#tos', as: 'tos'
end
