Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :projects, param: :code, only: %w[index show] #use code-slug as primary parameter instead of id for projects routing
      devise_for :users,
      path: '',
      controllers: {
        registrations: 'api/v1/overrides/registrations',
        sessions: 'api/v1/overrides/sessions',
      }
    end
  end
end
