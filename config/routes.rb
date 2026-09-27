Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  resources :training_records,
            only: [:index, :new, :create, :edit, :update, :destroy]

  resources :exercises,
            only: [:index, :new, :create, :edit, :update, :destroy]
end