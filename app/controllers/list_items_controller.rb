# frozen_string_literal: true

# wrapper for specific list items controllers
class ListItemsController < ProtectedRouteController
  before_action :require_write_access

  private

  def require_write_access
    list = List.find(params[:list_id])
    users_list = UsersList.find_by(list: list, user: current_user)
    return if users_list&.permissions == "write"

    head :forbidden
  end
end
