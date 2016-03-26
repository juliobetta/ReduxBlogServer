Rails.application.routes.draw do

  devise_for :users

  namespace :api do

    resources :posts, defaults: { format: :json }
    resources :users, only: [:show, :create, :update, :destroy], defaults: { format: :json }

    devise_scope :user do
      post '/sessions' => 'sessions#create', defaults: { format: :json }
    end


  end

  root 'welcome#index'
end
