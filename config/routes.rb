Rails.application.routes.draw do
  post 'slack/search'

  post 'slack/project_search'

  post 'slack/project_skills_search'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'users#new'
  resource :users, except: [:index] 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
