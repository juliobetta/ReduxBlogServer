Rails.application.routes.draw do
  devise_for :users

  namespace :api do
    resources :posts, defaults: {format: :json}

    devise_scope :user do
      match '/sessions' => 'sessions#create',  via: :post
      match '/sessions' => 'sessions#destroy', via: :delete
    end
  end

  root 'welcome#index'
end
