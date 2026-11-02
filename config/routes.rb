Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }
  post "/guest_sign_in", to: "guest_sessions#create", as: :guest_sign_in
  root "dashboard#index"
  resource :profile, only: [:show, :edit, :update] do
    get :avatar
  end
  resource :analysis, only: :show
  get "/training_records", to: redirect("/workouts")
  resources :workouts
  resources :exercises, only: [:index, :new, :create, :edit, :update, :destroy]
  get "/up", to: "rails/health#show", as: :rails_health_check
end
