Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Versioned API
  namespace :api do
    namespace :v1 do
      resources :users, only: [:show] do
        collection do
          get :demo      # => GET /api/v1/users/demo
        end
        resources :redemptions, only: [:index]
      end

      resources :rewards, only: [:index]
      resources :redemptions, only: [:create]
    end
  end
  
  # POST /redemptions -> RedemptionsController#create (queues RedemptionJob)
  resources :redemptions, only: [:create]
end
