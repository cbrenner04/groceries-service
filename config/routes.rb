Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:invitations]
  as :user do
    patch "/auth/invitation", to: "users/invitations#update"
    put "/auth/invitation", to: "users/invitations#update"
    post "/auth/invitation", to: "users/invitations#create"
  end
  resources :lists, only: [:index, :show, :create, :edit, :update, :destroy] do
    resource :refresh_list, only: [:create]
    resources :book_list_items, only: [:create, :edit, :update, :destroy]
    resources :grocery_list_items, only: [:create, :edit, :update, :destroy]
    resources :music_list_items, only: [:create, :edit, :update, :destroy]
    resources :to_do_list_items, only: [:create, :edit, :update, :destroy]
    resources :users_lists, only: [:index, :create, :update]
  end
  resources :completed_lists, only: :index
  root to: "lists#index"
  get '*unmatched_route', to: 'application#route_not_found'
end
