Rails.application.routes.draw do

  devise_for :users

  namespace :api do

    resources :posts, defaults: { format: :json }
    resources :users, only: [:create, :update, :destroy], defaults: { format: :json }

    devise_scope :user do
      match '/sessions' => 'sessions#create',  via: :post, defaults: { format: :json }
      match '/sessions' => 'sessions#destroy', via: :delete, defaults: { format: :json }
    end


  end

  root 'welcome#index'
end
