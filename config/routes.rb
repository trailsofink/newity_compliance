Rails.application.routes.draw do
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :compliance_reviews, only: [:index, :edit, :update]
  root 'dashboard#index'

  get "up" => "rails/health#show", as: :rails_health_check
end
