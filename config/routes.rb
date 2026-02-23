Rails.application.routes.draw do
  resources :applications, only: [ :index, :show, :new, :create ]
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resource :profile, only: [ :edit, :update ]

  resources :compliance_reviews, only: [ :index, :edit, :update ] do
    resources :comments, only: [ :create ]
  end
  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
