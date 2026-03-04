Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "rsvp/:token", to: "rsvps#show"
      patch "rsvp/:token", to: "rsvps#update"

      resources :gifts, only: [:index] do
        post "select", on: :member
      end

      get "guests/search", to: "guests#search"
    end
  end

  get "up", to: "rails/health#show", as: :rails_health_check
end
