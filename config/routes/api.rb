Rails.application.routes.draw do
  namespace 'api' do
    resources 'calendars', only: %i(show update), param: :year do
      resources 'settings', only: %i(index destroy create update)
    end
    resources 'alignment', only: %i(create update delete)
  end
end
