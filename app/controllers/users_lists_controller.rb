# frozen_string_literal: true

# no doc
class UsersListsController < ProtectedRouteController
  before_action :require_list_access, only: %i[index update]
  before_action :require_write_access, only: %i[create]

  def index
    render json: index_response
  end

  def create
    new_users_list = UsersList.create(users_list_params)

    if new_users_list.save
      SharedListNotification.send_notification_for(current_user, users_list_params[:user_id])
      render json: new_users_list
    else
      render json: new_users_list.errors, status: :unprocessable_entity
    end
  end

  def update
    # the rescue here is in case a bad value is sent for `permissions`
    # `permissions` accepts `read` and `write` only
    users_list.update(users_list_params)
    render json: users_list
  rescue ArgumentError => e
    render json: e, status: :unprocessable_entity
  end

  def destroy
    users_list.destroy
    head :no_content
  end

  private

  def users_list_params
    params
      .require(:users_list)
      .permit(:user_id, :list_id, :has_accepted, :permissions)
  end

  def users_list
    @users_list ||= UsersList.find(params[:id])
  end

  def list
    @list ||= List.find(params[:list_id])
  end

  def users_list_by_list_and_user
    @users_list_by_list_and_user ||= UsersList.find_by(list: list, user: current_user)
  end

  def require_list_access
    return if users_list_by_list_and_user

    head :forbidden
  end

  def require_write_access
    return if users_list_by_list_and_user&.permissions == "write"

    head :forbidden
  end

  def index_response
    user_is_owner = list.owner == current_user
    invitable_users = current_user.users_that_list_can_be_shared_with(list)
    {
      list: list, invitable_users: invitable_users, accepted: accepted_lists, pending: pending_lists,
      refused: refused_lists, current_user_id: current_user.id, user_is_owner: user_is_owner
    }
  end

  def accepted_lists
    UsersListsService.list_users_by_status(params[:list_id], "accepted")
  end

  def pending_lists
    UsersListsService.list_users_by_status(params[:list_id], "pending")
  end

  def refused_lists
    UsersListsService.list_users_by_status(params[:list_id], "refused")
  end
end
