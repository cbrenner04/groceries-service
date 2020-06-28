# frozen_string_literal: true

# no doc
class UsersListsController < ProtectedRouteController
  include UsersListsService

  before_action :require_list_access, only: %i[index update]
  before_action :require_write_access, only: %i[create]

  def index
    render json: index_response
  end

  def create
    @list = List.find(params[:list_id])
    @users_list = UsersList.create(users_list_params)

    if @users_list.save
      SharedListNotification
        .send_notification_for(current_user, users_list_params[:user_id])
      render json: @users_list
    else
      render json: @users_list.errors, status: :unprocessable_entity
    end
  end

  def update
    @users_list = UsersList.find(params[:id])
    # the rescue here is in case a bad value is sent for `permissions`
    # `permissions` accepts `read` and `write` only
    begin
      @users_list.update(users_list_params)
      render json: @users_list
    rescue ArgumentError => e
      render json: e, status: :unprocessable_entity
    end
  end

  def destroy
    @users_list = UsersList.find(params[:id])
    @users_list.destroy
    head :no_content
  end

  private

  def users_list_params
    params
      .require(:users_list)
      .permit(:user_id, :list_id, :has_accepted, :permissions)
  end

  def require_list_access
    list = List.find(params[:list_id])
    users_list = UsersList.find_by(list: list, user: current_user)
    return if users_list

    head :forbidden
  end

  def require_write_access
    list = List.find(params[:list_id])
    users_list = UsersList.find_by(list: list, user: current_user)
    return if users_list&.permissions == "write"

    head :forbidden
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def index_response
    list = List.find(params[:list_id])
    user_is_owner = list.owner == current_user
    invitable_users = current_user.users_that_list_can_be_shared_with(list)
    {
      list: list,
      invitable_users: invitable_users,
      accepted: list_users_by_status(params[:list_id], "accepted"),
      pending: list_users_by_status(params[:list_id], "pending"),
      refused: list_users_by_status(params[:list_id], "refused"),
      current_user_id: current_user.id,
      user_is_owner: user_is_owner
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
