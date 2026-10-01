Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"
  resource :profile, only: [:show, :edit, :update]

  resources :training_records,
            only: [:index, :new, :create, :edit, :update, :destroy]

  resources :exercises,
            only: [:index, :new, :create, :edit, :update, :destroy]
end