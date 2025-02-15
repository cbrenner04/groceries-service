# == Route Map

Rails.application.routes.draw do
  list_items_routes = lambda do
    resources :list_items, only: [:create, :edit, :update, :destroy] do
      collection do
        resource :bulk_update, only: [:show, :update], controller: "list_items_bulk_update", as: :list_items_bulk_update
      end
    end
  end
  mount_devise_token_auth_for "User", at: "auth", skip: [:invitations]
  as :user do
    patch "/auth/invitation", to: "users/invitations#update"
    put "/auth/invitation", to: "users/invitations#update"
    post "/auth/invitation", to: "users/invitations#create"
  end
  resources :lists, only: [:index, :show, :create, :edit, :update, :destroy] do
    resource :refresh_list, only: [:create]
    collection { resource :merge_lists, only: [:create] }
    namespace :v1, &list_items_routes
    resources :users_lists, only: [:index, :create, :update, :destroy]
  end
  resources :completed_lists, only: :index
  root to: "lists#index"
  get "*unmatched_route", to: "application#route_not_found"
end
