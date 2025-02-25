# frozen_string_literal: true

# /v2/lists/:list_id/refresh_list
class V2::RefreshListsController < ProtectedRouteController
  before_action :require_list_owner, only: %i[create]

  # POST /
  def create
    list.update!(refreshed: true)
    new_list = V2::ListsService.create_new_list_from(list)
    new_list.update!(list_item_configuration_id: list.list_item_configuration_id)
    users_list = V2::UsersListsService.create_users_list(current_user, new_list)
    V2::ListsService.create_new_items(list, new_list, current_user)
    render json: V2::ListsService.list_response(new_list, users_list, current_user)
  end

  private

  def require_list_owner
    return if list.owner == current_user

    head :forbidden
  end

  def list
    @list ||= List.find(params[:list_id])
  end
end
