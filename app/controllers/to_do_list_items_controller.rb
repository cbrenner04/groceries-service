# frozen_string_literal: true

# /lists/:list_id/to_do_list_items
class ToDoListItemsController < ListItemsController
  # POST /
  def create
    new_item = ToDoListItem.create(item_params.merge!(to_do_list_id: params[:list_id]))

    if new_item.save
      render json: new_item
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  end

  # GET /:id/edit
  def edit
    list = ToDoList.find(item.to_do_list_id)
    categories = list.categories
    list_users = UsersListsService.list_users(params[:list_id])
    render json: { item: item, list: list, categories: categories, list_users: list_users }
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
  end

  private

  def item_params
    params
      .require(:to_do_list_item)
      .permit(:user_id, :list_id, :task, :assignee_id, :due_by, :completed, :refreshed, :category)
  end

  def item
    @item ||= ToDoListItem.find(params[:id])
  end
end
