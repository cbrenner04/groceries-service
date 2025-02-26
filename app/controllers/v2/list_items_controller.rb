# frozen_string_literal: true

# /v2/lists/:list_id/list_items
# controller for accessing and manipulating list items
# NOTE: fields have their own controller
class V2::ListItemsController < ProtectedRouteController
  before_action :require_list_access
  before_action :require_write_access, only: %i[create edit update destroy]

  # GET /
  def index
    render json: list.list_items
  end

  # GET /:id
  def show
    render json: item
  end

  # GET /:id/edit
  def edit
    render json: { item: item, list: list, list_users: V2::UsersListsService.list_users(params[:list_id]) }
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # POST /
  def create
    # given no user supplied params, no reason to catch unprocessable entity
    render json: list.list_items.create!(user: current_user)
  end

  # PUT /:id
  def update
    if item.update(item_params)
      render json: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # DELETE /:id
  def destroy
    item.archive
    head :no_content
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

  def list
    @list ||= List.find(params[:list_id])
  end

  def item
    @item ||= ListItem.find(params[:id])
  end

  def item_params
    @item_params ||= params.expect(list_item: %i[refreshed completed])
  end

  def users_list
    @users_list ||= UsersList.find_by(list: list, user: current_user)
  end

  def require_list_access
    return head :not_found unless users_list

    return if users_list&.has_accepted

    head :not_found
  end

  def require_write_access
    return if users_list&.permissions == "write"

    head :forbidden
  end
end
