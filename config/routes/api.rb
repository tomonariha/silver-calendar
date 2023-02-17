Rails.application.routes.draw do
  namespace 'api' do
    resources 'calendars', only: %i(index show update), param: :year do
      resources 'settings', only: %i(index destroy create update)
      resource 'alignment', only: %i(create destroy update)
    end
  end
end
