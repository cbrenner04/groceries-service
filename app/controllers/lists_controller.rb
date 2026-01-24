# frozen_string_literal: true

# /lists
class ListsController < ProtectedRouteController
  before_action :require_list_existence, only: %i[show edit update destroy]
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
    new_list = ListsService.build_new_list(create_params, current_user)
    if new_list.save
      users_list = UsersListsService.create_users_list(current_user, new_list)
      render json: ListsService.list_response(new_list, users_list, current_user)
    else
      render json: new_list.errors, status: :unprocessable_content
    end
  end

  # PUT /:id
  def update
    update_attrs = prepare_update_attributes(update_params.to_h)

    ListsService.update_previous_and_next_list(users_list) if update_attrs["completed"]

    if list.update(update_attrs)
      render json: list
    else
      render json: list.errors, status: :unprocessable_content
    end
  end

  # DELETE /:id
  def destroy
    ListsService.update_previous_and_next_list(users_list)
    list.list_items.each(&:archive)
    list.archive
    head :no_content
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors.messages, status: :unprocessable_content
  end

  private

  def list
    @list ||= List.find(params[:id])
  end

  def create_params
    @create_params ||= params.expect(list: %i[user_id name completed refreshed list_item_configuration_id])
  end

  def update_params
    @update_params ||= params.expect(list: %i[user_id name completed refreshed])
  end

  def users_list
    return @users_list if defined?(@users_list)

    @users_list = UsersList.find_by(list: list, user: current_user)
  end

  def require_list_existence
    list
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def require_list_access
    return if users_list&.has_accepted

    head :forbidden
  end

  def require_list_owner
    return if list.owner == current_user

    head :forbidden
  end

  def prepare_update_attributes(attrs)
    attrs["completed"] = ActiveModel::Type::Boolean.new.cast(attrs["completed"]) if attrs.key?("completed")
    attrs
  end
end
