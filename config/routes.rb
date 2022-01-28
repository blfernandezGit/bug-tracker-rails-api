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
        resources :tickets, param: :ticket_no do
          resources :photos, only: [:create]
          resources :comments
        end
      end

      resources :users, param: :username
      get '/current_user_projects', to: 'projects#get_current_user_projects', as: 'get_current_user_projects'
      get '/tickets', to: 'tickets#get_all', as: 'get_all_tickets'
      post '/update_user_projects', to: 'project_memberships#update_user_projects', as: 'update_user_projects'
      post '/update_project_users', to: 'project_memberships#update_project_users', as: 'update_project_users'
      post '/projects/:project_code/tickets/:ticket_ticket_no/add_related_ticket', to: 'ticket_relations#add_related_ticket', as: 'add_related_ticket'
      delete '/projects/:project_code/tickets/:ticket_ticket_no/delete_related_ticket', to: 'ticket_relations#delete_related_ticket', as: 'delete_related_ticket'
    end
  end
end
