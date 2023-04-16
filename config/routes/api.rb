Rails.application.routes.draw do
  namespace 'api' do
    resources 'calendars', only: %i(index destroy show update), param: :year do
      resources 'settings', only: %i(index destroy create update)
      resource 'alignment', only: %i(create destroy update)
    end
    post 'days/:year/:month', to: 'days#update'
    delete 'days/:year/:month/:date', to: 'days#destroy'
    resource 'users', only: %i(show)
    resource 'times', only: %i(update)
  end
end
