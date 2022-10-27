# frozen_string_literal: true

# /lists
class ListsController < ProtectedRouteController
  before_action :require_list_access, only: %i[show]
  before_action :require_list_owner, only: %i[edit update destroy]

  # GET /
  def index
    render json: ListsService.index_response(current_user)
  end

  # GET /:id
  def show
    render json: ListsService.show_response(list, current_user)
  end

  # GET /:id/edit
  def edit
    render json: list
  end

  # POST /
  def create
    new_list = ListsService.build_new_list(list_params, current_user)
    if new_list.save
      users_list = UsersListsService.create_users_list(current_user, new_list)
      render json: ListsService.list_response(new_list, users_list, current_user)
    else
      render json: new_list.errors, status: :unprocessable_entity
    end
  end

  # PUT /:id
  def update
    update_previous_and_next_list if list_params[:completed]
    if list.update(list_params)
      render json: list
    else
      render json: list.errors, status: :unprocessable_entity
    end
  end

  # DELETE /:id
  def destroy
    update_previous_and_next_list
    list.archive
    head :no_content
  end

  private

  def list_params
    @list_params ||= params.require(:list).permit(:user, :name, :completed, :refreshed, :type)
  end

  def require_list_access
    return if users_list&.has_accepted

    head :forbidden
  end

  def require_list_owner
    return if list.owner == current_user

    head :forbidden
  end

  def list
    @list ||= List.find(params[:id])
  end

  def users_list
    @users_list ||= UsersList.find_by(list: list, user: current_user)
  end

  def update_previous_list
    return unless users_list.prev_id

    UsersList.find(users_list.prev_id).update!(next_id: users_list.next_id)
  end

  def update_next_list
    return unless users_list.next_id

    UsersList.find(users_list.next_id).update!(prev_id: users_list.prev_id)
  end

  def update_previous_and_next_list
    update_previous_list
    update_next_list
    users_list.update!(prev_id: nil, next_id: nil)
  end
end
