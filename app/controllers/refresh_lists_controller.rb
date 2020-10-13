# frozen_string_literal: true

# /lists/:list_id/refresh_list
class RefreshListsController < ProtectedRouteController
  before_action :require_list_owner, only: %i[create]

  # POST /
  # TODO: need to update users lists before_id and after_id
  def create
    list.update!(refreshed: true)
    new_list = ListsService.create_new_list_from list
    users_list = UsersListsService.create_users_list(current_user, new_list)
    UsersListsService.accept_user_list(new_list)
    ListsService.create_new_items(list, new_list, current_user)
    render json: ListsService.list_response(new_list, users_list, current_user)
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
