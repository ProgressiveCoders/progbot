Rails.application.routes.draw do

  namespace :dashboard do
    root :to => 'base#index'
    get 'base/index'
    resource :user, only: [:edit, :update]
    resources :projects
  end

  scope :existing do
    resources :users, only: [:show]
  end

  get '/welcome/dashboard' => 'welcome#dashboard'
  get '/users/registration' => 'users#registration'
  get 'users/new/confirmation' => 'users#confirmation'
  put 'users/update' => 'users#update'
  get '/welcome/home' => 'welcome#home'

  unauthenticated do
    root :to => 'welcome#home'
  end

  authenticated do
   root :to => 'dashboard/base#index'
  end

  devise_for :users, except: [:index], controllers: {
        sessions: 'users/sessions', omniauth_callbacks: 'users/omniauth_callbacks', users: 'users'
      }, :path => 'devise'

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  resources :users, except: [:index, :destroy, :show]

  post 'slack/search'

  post 'slack/project_search'

  post 'slack/project_skills_search'

  post 'slack/project_list'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
