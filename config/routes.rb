Rails.application.routes.draw do
  resources :applications, only: [ :index, :show ]
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :compliance_reviews, only: [ :index, :edit, :update ] do
    resources :comments, only: [ :create ]
  end
  root "dashboard#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
