Rails.application.routes.draw do

  root :to => 'welcome#home'

  namespace :dashboard do
    root :to => 'base#index'
    get 'base/index'
    post "/search", to: "base#search"
    get "/search", to: "base#search"
    resource :user, only: [:edit, :update]
    resources :skills, only: [:index, :show]
    resources :projects do
      get 'all', :on => :collection
    end
    resources :volunteerings, only: [:index, :create, :update, :edit]
  end

  # scope :existing do
  #   resources :users, only: [:show]
  # end

  get 'dashboard/volunteerings/new_signup' => 'dashboard/volunteerings#new_signup'

  get 'dashboard/volunteerings/new_recruit' => 'dashboard/volunteerings#new_recruit'

  # get '/welcome/dashboard' => 'welcome#dashboard'
  get '/users/registration' => 'users#registration'
  get 'users/new/confirmation' => 'users#confirmation'
  put 'users/update' => 'users#update'
  get '/welcome/home' => 'welcome#home'


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

  get '/admin/projects/upload_csv', to: 'admin/projects#upload_csv', as: :admin_projects_upload_csv

  get '/admin/users/upload_csv', to: 'admin/users#upload_csv', as: :admin_users_upload_csv

  post 'admin/projects/import_data', to: 'admin/projects#import_data', as: :admin_projects_import_data
        
  post 'admin/users/import_data', to: 'admin/users#import_data', as: :admin_users_import_data

  post 'admin/projects/bulk_post', to: 'admin/projects#bulk_post', as: :admin_projects_bulk_post

  post 'admin/users/bulk_post', to: 'admin/users#bulk_post', as: :admin_users_bulk_post

  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
