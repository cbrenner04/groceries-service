# frozen_string_literal: true

# wrapper for specific list items controllers
class ListItemsController < ProtectedRouteController
  before_action :require_write_access

  # POST /
  def edit
    categories = list.categories
    response_body = { item: item, list: list, categories: categories }
    if list.type == "ToDoList"
      list_users = UsersListsService.list_users(params[:list_id])
      response_body[:list_users] = list_users
    end
    render json: response_body
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # GET /:id/edit
  def create
    new_item = item_class.create(item_params.merge!(list_id: params[:list_id]))
    if new_item.save
      render json: new_item
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  end

  # PUT /:id
  def update
    if item.update(item_params)
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
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

  def item_class
    "#{list.type}Item".constantize
  end

  def item
    @item ||= item_class.find(params[:id])
  end

  def item_params
    generic_params = %i[user_id category]
    specific_params = {
      BookList: %i[author title read number_in_series purchased],
      GroceryList: %i[product quantity purchased refreshed],
      MusicList: %i[title artist album purchased],
      SimpleList: %i[content completed refreshed],
      ToDoList: %i[task assignee_id due_by completed refreshed]
    }[list.type.to_sym]
    params.require(:list_item).permit(generic_params.concat(specific_params))
  end

  def require_write_access
    list = List.find(params[:list_id])
    users_list = UsersList.find_by(list: list, user: current_user)
    return if users_list&.permissions == "write"

    head :forbidden
  rescue ActiveRecord::RecordNotFound
    head :forbidden
  end
end
