Rails.application.routes.draw do
  root to: 'welcome#home'

  get '/welcome/dashboard' => 'welcome#dashboard'

  devise_for :users, except: [:index], controllers: {
        sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks'
      }, :path => 'devise'

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :users, except: [:index, :destroy]

  post 'slack/search'

  post 'slack/project_search'

  post 'slack/project_skills_search'

  post 'slack/project_list'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
