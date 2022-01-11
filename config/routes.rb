Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :projects, param: :code, only: %w[index show] #use code-slug as primary parameter instead of id for projects routing
    end
  end
end
