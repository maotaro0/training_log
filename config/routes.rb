Rails.application.routes.draw do
  devise_for :users
  root "dashboard#index"
  resource :profile, only: [:show, :edit, :update]
  get "/training_records", to: redirect("/workouts")
  resources :workouts
  resources :exercises, only: [:index, :new, :create, :edit, :update, :destroy]
  get "/up", to: "rails/health#show", as: :rails_health_check
end
