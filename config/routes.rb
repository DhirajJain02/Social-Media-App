Rails.application.routes.draw do
  # get "home/index"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # root "posts#index"
  root "home#index"

  namespace :admin do
    get "dashboard", to: "dashboard#index", as: :dashboard
    get "managed_users", to: "dashboard#managed_users", as: "managed_users_dashboard"
    get "users/:id/activate", to: "dashboard#activate_user", as: "activate_user_dashboard"
    get "users/:id/deactivate", to: "dashboard#deactivate_user", as: "deactivate_user_dashboard"
    get "/dashboard/new", to: "dashboard#new", as: "new_dashboard"
    post "/dashboard/new", to: "dashboard#create", as: "create_dashboard"
    get "/dashboard/reports", to: "dashboard#reports"
  end

  resources :posts do
    resources :comments do
      member do
        post :like
      end
    end
    member do
      post :like
    end
  end
  get "profile", to: "posts#profile", as: "profile"
  get "admin/profile", to: "admin/dashboard#profile", as: "admin_profile"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
