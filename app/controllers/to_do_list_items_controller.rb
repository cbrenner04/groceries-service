# frozen_string_literal: true

# no doc
class ToDoListItemsController < ListItemsController
  include UsersListsService

  def create
    @item = ToDoListItem
            .create(item_params.merge!(to_do_list_id: params[:list_id]))

    if @item.save
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def edit
    item = ToDoListItem.find(params[:id])
    list = ToDoList.find(item.to_do_list_id)
    categories = list.categories
    list_users = list_users(params[:list_id])
    render json: {
      item: item,
      list: list,
      categories: categories,
      list_users: list_users
    }
  end

  def update
    @item = ToDoListItem.find(params[:id])
    if @item.update(item_params)
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @item = ToDoListItem.find(params[:id])
    @item.archive
    head :no_content
  end

  private

  def item_params
    params
      .require(:to_do_list_item)
      .permit(:user_id,
              :list_id,
              :task,
              :assignee_id,
              :due_by,
              :completed,
              :refreshed,
              :category)
  end
end
