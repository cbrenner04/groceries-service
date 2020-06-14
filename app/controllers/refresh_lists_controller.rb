# frozen_string_literal: true

# /refresh_list
class RefreshListsController < ProtectedRouteController
  include ListsService

  before_action :require_list_owner, only: %i[create]

  def create
    set_list
    @list.update!(refreshed: true)
    new_list = create_new_list_from(@list)
    users_list = create_users_list(current_user, new_list)
    accept_user_list(new_list)
    create_new_items(@list, new_list)
    render json: list_response(new_list, users_list)
  end

  private

  def require_list_owner
    list = List.find(params[:list_id])
    return if list.owner == current_user

    head :forbidden
  end

  def set_list
    @list = List.find(params[:list_id])
  end
end
