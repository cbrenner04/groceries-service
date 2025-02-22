# frozen_string_literal: true

# /v2/lists
class V2::ListsController < ProtectedRouteController
  before_action :require_list_access, only: %i[show]
  before_action :require_list_owner, only: %i[edit update destroy]

  # GET /
  def index
    render json: V2::ListsService.index_response(current_user)
  end

  # GET /:id
  def show
    render json: V2::ListsService.show_response(list, current_user)
  end

  # GET /:id/edit
  def edit
    render json: list
  end

  # POST /
  def create
    new_list = V2::ListsService.build_new_list(list_params, current_user)
    if new_list.save
      users_list = UsersListsService.create_users_list(current_user, new_list)
      render json: V2::ListsService.list_response(new_list, users_list, current_user)
    else
      render json: new_list.errors, status: :unprocessable_entity
    end
  end

  # PUT /:id
  def update
    V2::ListsService.update_previous_and_next_list(users_list) if list_params[:completed]
    if list.update(list_params)
      render json: list
    else
      render json: list.errors, status: :unprocessable_entity
    end
  end

  # DELETE /:id
  def destroy
    V2::ListsService.update_previous_and_next_list(users_list)
    list.list_items.each(&:archive)
    list.archive
    head :no_content
  end

  private

  def list
    @list ||= List.find(params[:id])
  end

  def list_params
    # TODO: remove `type` when `type` attr is removed from List
    @list_params ||= params.expect(list: %i[user name completed refreshed type list_item_configuration_id])
  end

  def users_list
    @users_list ||= UsersList.find_by(list: list, user: current_user)
  end

  def require_list_access
    return if users_list&.has_accepted

    head :forbidden
  end

  def require_list_owner
    return if list.owner == current_user

    head :forbidden
  end
end
