# == Route Map

Rails.application.routes.draw do
  mount_devise_token_auth_for "User", at: "auth", skip: %i[invitations]
  as :user do
    patch "/auth/invitation", to: "users/invitations#update"
    put "/auth/invitation", to: "users/invitations#update"
    post "/auth/invitation", to: "users/invitations#create"
  end

  resources :lists, only: %i[index show create edit update destroy] do
    resource :refresh_list, only: %i[create]
    collection { resource :merge_lists, only: %i[create] }
    resources :list_items, only: %i[index show create edit update destroy] do
      collection do
        resource :bulk_update, only: %i[show update], controller: "list_items_bulk_update",
                               as: :list_items_bulk_update
      end
      resources :list_item_fields, only: %i[index show create edit update destroy]
    end
    resources :categories, only: %i[create]
    resources :users_lists, only: %i[index create update destroy]
  end
  resources :completed_lists, only: :index
  resources :list_item_configurations, only: %i[index show create edit update destroy] do
    resources :list_item_field_configurations, only: %i[index show create edit update destroy]
  end

  root to: "lists#index"
  get "*unmatched_route", to: "application#route_not_found"
end
