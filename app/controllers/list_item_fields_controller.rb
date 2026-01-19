# frozen_string_literal: true

# /lists/:list_id/list_items/:list_item_id/list_item_fields
# controller for list item fields
class ListItemFieldsController < ProtectedRouteController
  before_action :require_list_access
  before_action :require_write_access, only: %i[create edit update destroy]
  before_action :require_field_existence, only: %i[show edit update destroy]

  # GET /
  def index
    render json: item.list_item_fields
  end

  # GET /:id
  def show
    render json: item_field
  end

  # GET /:id/edit
  def edit
    render json: { item_field: item_field, list_users: UsersListsService.list_users(list.id) }
  end

  # POST /
  def create
    new_field = item.list_item_fields.create(item_field_params.merge(user: current_user))
    if new_field.save
      render json: new_field
    else
      render json: new_field.errors, status: :unprocessable_content
    end
  end

  # PUT /:id
  def update
    if item_field.update(item_field_params)
      render json: item_field
    else
      render json: item_field.errors, status: :unprocessable_content
    end
  end

  # DELETE /:id
  def destroy
    item_field.archive
    head :no_content
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors.messages, status: :unprocessable_content
  end

  private

  def list
    @list ||= List.find(params[:list_id])
  end

  def item
    @item ||= ListItem.find(params[:list_item_id])
  end

  def item_field
    @item_field ||= ListItemField.find(params[:id])
  end

  def item_field_params
    @item_field_params ||= params.expect(list_item_field: %i[list_item_field_configuration_id data])
  end

  def users_list
    return @users_list if defined?(@users_list)

    @users_list = UsersList.find_by(list: list, user: current_user)
  end

  def require_list_access
    return head :not_found unless list && users_list

    head :not_found unless users_list&.has_accepted
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def require_write_access
    head :forbidden unless users_list&.permissions == "write"
  end

  def require_field_existence
    item_field
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end
end
