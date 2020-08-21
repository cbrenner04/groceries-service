# == Route Map
#
#                      Prefix Verb   URI Pattern                                      Controller#Action
#            new_user_session GET    /auth/sign_in(.:format)                          devise_token_auth/sessions#new
#                user_session POST   /auth/sign_in(.:format)                          devise_token_auth/sessions#create
#        destroy_user_session DELETE /auth/sign_out(.:format)                         devise_token_auth/sessions#destroy
#           new_user_password GET    /auth/password/new(.:format)                     devise_token_auth/passwords#new
#          edit_user_password GET    /auth/password/edit(.:format)                    devise_token_auth/passwords#edit
#               user_password PATCH  /auth/password(.:format)                         devise_token_auth/passwords#update
#                             PUT    /auth/password(.:format)                         devise_token_auth/passwords#update
#                             POST   /auth/password(.:format)                         devise_token_auth/passwords#create
#         auth_validate_token GET    /auth/validate_token(.:format)                   devise_token_auth/token_validations#validate_token
#             auth_invitation PATCH  /auth/invitation(.:format)                       users/invitations#update
#                             PUT    /auth/invitation(.:format)                       users/invitations#update
#                             POST   /auth/invitation(.:format)                       users/invitations#create
#           list_refresh_list POST   /lists/:list_id/refresh_list(.:format)           refresh_lists#create
#                 merge_lists POST   /lists/merge_lists(.:format)                     merge_lists#create
# list_list_items_bulk_update GET    /lists/:list_id/list_items/bulk_update(.:format) list_items_bulk_update#show
#                             PATCH  /lists/:list_id/list_items/bulk_update(.:format) list_items_bulk_update#update
#                             PUT    /lists/:list_id/list_items/bulk_update(.:format) list_items_bulk_update#update
#             list_list_items POST   /lists/:list_id/list_items(.:format)             list_items#create
#         edit_list_list_item GET    /lists/:list_id/list_items/:id/edit(.:format)    list_items#edit
#              list_list_item PATCH  /lists/:list_id/list_items/:id(.:format)         list_items#update
#                             PUT    /lists/:list_id/list_items/:id(.:format)         list_items#update
#                             DELETE /lists/:list_id/list_items/:id(.:format)         list_items#destroy
#            list_users_lists GET    /lists/:list_id/users_lists(.:format)            users_lists#index
#                             POST   /lists/:list_id/users_lists(.:format)            users_lists#create
#             list_users_list PATCH  /lists/:list_id/users_lists/:id(.:format)        users_lists#update
#                             PUT    /lists/:list_id/users_lists/:id(.:format)        users_lists#update
#                             DELETE /lists/:list_id/users_lists/:id(.:format)        users_lists#destroy
#                       lists GET    /lists(.:format)                                 lists#index
#                             POST   /lists(.:format)                                 lists#create
#                   edit_list GET    /lists/:id/edit(.:format)                        lists#edit
#                        list GET    /lists/:id(.:format)                             lists#show
#                             PATCH  /lists/:id(.:format)                             lists#update
#                             PUT    /lists/:id(.:format)                             lists#update
#                             DELETE /lists/:id(.:format)                             lists#destroy
#             completed_lists GET    /completed_lists(.:format)                       completed_lists#index
#                        root GET    /                                                lists#index
#                             GET    /*unmatched_route(.:format)                      application#route_not_found

Rails.application.routes.draw do
  mount_devise_token_auth_for "User", at: "auth", skip: [:invitations]
  as :user do
    patch "/auth/invitation", to: "users/invitations#update"
    put "/auth/invitation", to: "users/invitations#update"
    post "/auth/invitation", to: "users/invitations#create"
  end
  resources :lists, only: [:index, :show, :create, :edit, :update, :destroy] do
    resource :refresh_list, only: [:create]
    collection do
      resource :merge_lists, only: [:create]
    end
    resources :list_items, only: [:create, :edit, :update, :destroy] do
      collection do
        resource :bulk_update, only: [:show, :update], controller: "list_items_bulk_update", as: :list_items_bulk_update
      end
    end
    resources :users_lists, only: [:index, :create, :update, :destroy]
  end
  resources :completed_lists, only: :index
  root to: "lists#index"
  get "*unmatched_route", to: "application#route_not_found"
end
