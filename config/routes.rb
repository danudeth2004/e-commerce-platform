Rails.application.routes.draw do
  namespace :admin do
    devise_for :users, class_name: "Admin::User", controllers: {
      registrations: "admin/users/registrations",
      sessions: "admin/users/sessions"
    }

    resources :campaigns, except: [ :show ]

    resources :order_store_payouts, only: [ :index, :show ] do
      member do
        post :pay
      end
    end

    resources :stores do
      member do
        patch :toggle_status
      end
      resources :payouts do
        member do
          post :omise_transfer
        end
      end
    end

    root "home#index"
  end

  namespace :seller do
    devise_for :users, class_name: "Seller::User", controllers: {
      registrations: "seller/users/registrations",
      sessions: "seller/users/sessions"
    }
    
    resources :products, only: [ :new, :create, :edit, :update, :destroy ] do
      collection do
        get :choose
      end
    end
    resources :product_bundles, only: [ :new, :create, :edit, :update ]
    resources :stores, only: [ :new, :create, :edit, :update ]

    root "home#index"
  end

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  namespace :users do
    get "role", to: "role#index"
    get "profile", to: "profiles#show", as: :profile
    resources :orders, only: [ :index, :show ]
  end

  resource :checkout, only: [] do
    post  :create_order
    get   :payment
    post  :pay
    patch :cancel
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
  resource :cart, only: [ :show ] do
    post :add_item
    delete :remove_item
    patch :increase_item
    patch :decrease_item
  end
  get "products", to: "products#index", as: :products
  get "stores/:id", to: "stores#show", as: :store
  get "products/:id", to: "home#show", as: :product

  get "home/flash_sale", to: "home#flash_sale", as: :home_flash_sale

  match "*path", to: redirect("/"), via: :all, constraints: ->(req) { !req.path.start_with?("/rails/active_storage") }
end
