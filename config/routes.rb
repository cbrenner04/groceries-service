# == Route Map

Rails.application.routes.draw do
  refresh_list_routes = lambda { resource :refresh_list, only: %i[create] }
  merge_list_routes = lambda { collection { resource :merge_lists, only: %i[create] } }
  bulk_update_routes = lambda do
    collection do
      resource :bulk_update, only: %i[show update], controller: "list_items_bulk_update", as: :list_items_bulk_update
    end
  end
  users_lists_routes = lambda { resources :users_lists, only: %i[index create update destroy] }

  mount_devise_token_auth_for "User", at: "auth", skip: %i[invitations]
  as :user do
    patch "/auth/invitation", to: "users/invitations#update"
    put "/auth/invitation", to: "users/invitations#update"
    post "/auth/invitation", to: "users/invitations#create"
  end
  namespace :v1 do
    resources :lists, only: %i[index show create edit update destroy] do
      refresh_list_routes[]
      merge_list_routes[]
      resources :list_items, only: %i[create edit update destroy] do
        bulk_update_routes[]
      end
      users_lists_routes[]
    end
  end
  namespace :v2 do
    resources :lists, only: %i[index show create edit update destroy] do
      refresh_list_routes[]
      merge_list_routes[]
      resources :list_items, only: %i[index show create edit update destroy] do
        bulk_update_routes[]
        resources :list_item_fields, only: %i[index show create edit update destroy]
      end
      users_lists_routes[]
    end
  end
  resources :completed_lists, only: :index
  resources :list_item_configurations, only: %i[index show create edit update destroy] do
    resources :list_item_field_configurations, only: %i[index show create edit update destroy]
  end
  root to: "v1/lists#index"
  get "*unmatched_route", to: "application#route_not_found"
end
