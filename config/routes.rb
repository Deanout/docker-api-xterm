Rails.application.routes.draw do
  put '/containers/:id/start', to: 'containers#start', as: 'start_container'
  put '/containers/:id/stop', to: 'containers#stop', as: 'stop_container'

  resources :containers
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "containers#index"
end
