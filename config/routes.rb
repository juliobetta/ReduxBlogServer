Rails.application.routes.draw do

  devise_for :users

  namespace :api do

    resources :posts, defaults: { format: :json }
    resources :users, only: [:show, :create, :update, :destroy], defaults: { format: :json }

    namespace :sync do
      resources :posts_up, only: [], defaults: { format: :json } do
        collection { patch :update }
      end

      resources :posts_down, only: [:index], defaults: { format: :json }
    end


    devise_scope :user do
      post '/sessions' => 'sessions#create', defaults: { format: :json }
    end


  end

  root 'welcome#index'
end
