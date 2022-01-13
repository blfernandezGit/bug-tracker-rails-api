Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :projects, param: :code #use code-slug as primary parameter instead of id for projects routing
      devise_for :users,
      path: '',
      path_names: {
        sign_in: 'login',
        sign_out: 'logout',
        sign_up: 'signup'
      },
      controllers: {
        registrations: 'api/v1/authorization/registrations',
        sessions: 'api/v1/authorization/sessions',
      }
    end
  end
end
