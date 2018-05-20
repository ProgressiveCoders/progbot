Rails.application.routes.draw do
  root to: 'welcome#home'

  get '/welcome/dashboard' => 'welcome#dashboard'

  get '/auth/slack/callback' => 'sessions#create'

  get '/logout' => 'sessions#destroy'

  get '/users/register' => 'users#register'

  post 'slack/search'

  post 'slack/project_search'

  post 'slack/project_skills_search'

  post 'slack/project_list'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resource :users, except: [:index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
