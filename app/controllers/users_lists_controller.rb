# frozen_string_literal: true

# /lists/:list_id/users_lists
class UsersListsController < ProtectedRouteController
  before_action :require_list_access, only: %i[index update]
  before_action :require_write_access, only: %i[create]

  # GET /
  def index
    render json: index_response
  end

  # POST /
  # rubocop:disable Metrics/AbcSize
  def create
    after_list = current_user.users_lists.find_by(has_accepted: nil, prev_id: nil)
    users_list_params[:next_id] = after_list&.id # nil if no after_list
    new_users_list = UsersList.create(users_list_params)

    if new_users_list.save
      after_list&.update!(prev_id: new_users_list.id)
      SharedListNotification.send_notification_for(current_user, users_list_params[:user_id])
      render json: new_users_list
    else
      render json: new_users_list.errors, status: :unprocessable_entity
    end
  end
  # rubocop:enable Metrics/AbcSize

  # PUT /:id
  def update
    # the rescue here is in case a bad value is sent for `permissions`
    # `permissions` accepts `read` and `write` only
    update_lists_and_params
    users_list_params[:prev_id] = nil
    users_list.update(users_list_params)
    render json: users_list
  rescue ArgumentError => e
    render json: e, status: :unprocessable_entity
  end

  # DELETE /:id
  def destroy
    update_previous_and_next_list
    users_list.destroy
    head :no_content
  end

  private

  def users_list_params
    @users_list_params ||= params
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

  def first_incomplete_users_list_id
    first_incomplete_users_list = current_user.accepted_lists[:not_completed_lists].find do |l|
      UsersList.find_by(list: l, user: current_user).prev_id.nil?
    end
    @first_incomplete_users_list_id ||= first_incomplete_users_list.users_list_id
  end

  # rubocop:disable Metrics/AbcSize
  def update_lists_and_params
    if users_list.has_accepted.nil? && users_list_params[:has_accepted] == true
      # accepting list share
      update_prev_id_of_first_incomplete_list
      users_list_params[:next_id] = first_incomplete_users_list_id
    elsif users_list.has_accepted && users_list_params[:has_accepted] == false
      # rejecting previously accepted list share
      update_previous_and_next_list
      users_list_params[:next_id] = nil
    end
  end
  # rubocop:enable Metrics/AbcSize

  def update_prev_id_of_first_incomplete_list
    UsersList.find_by(list_id: first_incomplete_users_list_id, user: current_user)&.update!(prev_id: users_list.id)
  end

  def update_previous_and_next_list
    UsersList.find(users_list.prev_id).update!(next_id: users_list.next_id) if users_list.prev_id
    UsersList.find(users_list.next_id).update!(prev_id: users_list.prev_id) if users_list.next_id
  end
end
