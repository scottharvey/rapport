Rapport::Engine.routes.draw do
  root to: "contacts#index"

  resources :contacts do
    member do
      post :touch
      post :merge
    end
    resources :notes, only: :create
    resources :interactions, only: :create
    resources :taggings, only: %i[create destroy]
    resource :custom_fields, only: :update
    resource :reminder, only: :update
    resources :email_addresses, only: :create
  end
  resources :companies
  resource :sweep, only: :create
end
