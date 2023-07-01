# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  get 'calendar', to: 'calendars#index', as: 'calendar'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  namespace :api do
    namespace :v1 do
      resources :calendars, only: %i(index destroy show update), param: :year do
        resources :settings, only: %i(index destroy create update)
        resource :alignment, only: %i(create destroy update)
      end
      post 'days/:year/:month', to: 'days#update'
      delete 'days/:year/:month/:date', to: 'days#destroy'
      resource :users, only: %i(show)
      resource :times, only: %i(update)
    end
  end
  get 'privacy_policy', to: 'home#privacy_policy', as: 'privacy_policy'
  get 'tos', to: 'home#tos', as: 'tos'
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
