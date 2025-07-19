# frozen_string_literal: true

# /v2/lists/:list_id/list_items
# controller for accessing and manipulating list items
# NOTE: fields have their own controller
class V2::ListItemsController < ProtectedRouteController
  before_action :require_list_access
  before_action :require_write_access, only: %i[create edit update destroy]
  before_action :require_item_existence, only: %i[show edit update destroy]

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
    render json: {
      item: V2::ListsService.build_item_response(item),
      list: list,
      list_users: V2::UsersListsService.list_users(params[:list_id]),
      list_item_configuration: list.list_item_configuration || nil,
      list_item_field_configurations:
        list.list_item_configuration&.list_item_field_configurations&.order(:position) || []
    }
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
  end

  # DELETE /:id
  def destroy
    item.archive
    head :no_content
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors.messages, status: :unprocessable_entity
  end

  private

  def list
    @list ||= List.find(params[:list_id])
  end

  def item
    @item ||= ListItem.includes(list_item_fields: :list_item_field_configuration).find(params[:id])
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
    head :forbidden unless users_list&.permissions == "write"
  end

  def require_item_existence
    item
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
