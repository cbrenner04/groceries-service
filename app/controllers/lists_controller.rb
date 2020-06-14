# frozen_string_literal: true

# /lists
class ListsController < ProtectedRouteController
  include ListsService

  before_action :require_list_access, only: %i[show]
  before_action :require_list_owner, only: %i[edit update destroy]

  def index
    render json: index_response
  end

  def create
    @list = build_new_list(list_params)
    if @list.save
      users_list = create_users_list(current_user, @list)
      render json: list_response(@list, users_list)
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  def show
    set_list
    set_items
    render json: show_response
  end

  def edit
    set_list
    render json: @list
  end

  def update
    set_list
    if @list.update(list_params)
      render json: @list
    else
      render json: @list.errors, status: :unprocessable_entity
    end
  end

  def destroy
    set_list
    @list.archive
    head :no_content
  end

  private

  def list_params
    params.require(:list).permit(:user, :name, :completed, :refreshed, :type)
  end

  def require_list_access
    list = List.find(params[:id])
    users_list = UsersList.find_by(list: list, user: current_user)
    return if users_list&.has_accepted

    head :forbidden
  end

  def require_list_owner
    list = List.find(params[:id])
    return if list.owner == current_user

    head :forbidden
  end

  def set_list
    @list = List.find(params[:id])
  end
end
