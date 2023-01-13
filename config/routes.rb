# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  devise_for :users
  draw :api
  post 'days/:year/:month', to: 'days#update'
  delete 'days/:year/:month/:date', to: 'days#destroy'
end
