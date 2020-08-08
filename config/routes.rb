# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # QuickAuth
  get '/quickauth/user1' => 'quick_auth#user1_auth'
  get '/quickauth/club1' => 'quick_auth#club1_auth'

  # Users
  post 'users/register'
  put '/users/current_user/link_stripe_acc' => 'users#link_stripe'
  get 'users/current_user_profile' => 'users#show_current'
  get 'users/current_user' => 'users#show_current'
  get 'users/:id' => 'users#show'
  put 'users/:id' => 'users#edit'
  delete 'users/:id' => 'users#delete'

  # Authentication
  post 'authenticate' => 'authentication#authenticate'

  # General Reservations
  get 'reservations' => 'reservations#filter'

  resource 'current_user' do
    # Current User Reservations
    resources :reservations, only: %i[create update destroy index show]
    post 'reservations/batch' => 'reservations#create_batch'

    # Schedule Configs
    get 'scheduleConfigs' => 'schedule_configs#show_current'
    post 'scheduleConfigs' => 'schedule_configs#create'
    put 'scheduleConfigs' => 'schedule_configs#edit'

    # Schedule Exceptions
    post 'scheduleExceptions' => 'schedule_exceptions#create'
    put 'scheduleExceptions/:id' => 'schedule_exceptions#edit'
    delete 'scheduleExceptions/:id' => 'schedule_exceptions#delete'
  end
end
