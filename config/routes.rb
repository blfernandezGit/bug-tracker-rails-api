Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
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
      resources :projects, param: :code do#use code-slug as primary parameter instead of id for projects routing
        resources :tickets, param: :ticket_no, path: ''
      end
        resources :users, param: :username
      post '/update_user_projects', to: 'project_memberships#update_user_projects', as: 'update_user_projects'
      post '/update_project_users', to: 'project_memberships#update_project_users', as: 'update_project_users'
    end
  end
end
