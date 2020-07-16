# frozen_string_literal: true

# bulk update to do list items
class ToDoListItemsBulkUpdateController < ListItemsController
  include UsersListsService

  def show
    render json: {
      items: items, list: list, lists: lists, categories: list.categories,
      list_users: list_users(params[:list_id])
    }
  end

  def update
    update_current_items
    create_new_items if item_params[:move] || item_params[:copy]

    head :no_content
  end

  private

  def item_params
    params
      .require(:to_do_list_items)
      .permit(:assignee_id, :clear_assignee, :due_by, :clear_due_by, :category,
              :clear_category, :copy, :move, :existing_list_id, :new_list_name,
              :update_current_items)
  end

  def items
    @items ||= ToDoListItem.where(params[:item_ids].split(","))
  end

  def list
    @list ||= ToDoList.find(params[:list_id])
  end

  def lists
    current_user.write_lists.filter do |list|
      list.type == "ToDoList" && list.id != params[:list_id].to_i
    end
  end

  def update_assignee
    @update_assignee ||= item_params[:assignee_id] &&
                         !item_params[:clear_assignee]
  end

  def update_due_by
    @update_due_by ||= item_params[:due_by] && !item_params[:clear_due_by]
  end

  def update_category
    @update_category ||= item_params[:category] && !item_params[:clear_category]
  end

  def update_current_items
    return unless item_params[:update_current_items]

    update_params = {}
    update_params[:assignee_id] = item_params[:assignee_id] if update_assignee
    update_params[:due_by] = item_params[:due_by] if update_due_by
    update_params[:category] = item_params[:category] if update_category

    items.update_all(update_params)
  end

  def assignee_id
    if update_assignee
      item_params[:assignee_id]
    elsif item_params[:clear_assignee]
      nil
    else
      item[:assignee_id]
    end
  end

  def due_by
    if update_due_by
      item_params[:due_by]
    elsif item_params[:clear_due_by]
      nil
    else
      item[:due_by]
    end
  end

  def category
    if update_category
      item_params[:category]
    elsif item_params[:clear_category]
      nil
    else
      item[:category]
    end
  end

  def create_new_items
    list_id = item_params[:existing_list_id] || create_new_list
    items.each do |item|
      ToDoListItem.create!(
        user: current_user, to_do_list_id: list_id, task: item[:task],
        assignee_id: assignee_id, due_by: due_by, category: category
      )
    end
  end

  def create_new_list
    return unless item_params[:new_list_name]

    new_todo_list = ToDoList.create!(name: item_params[:new_list_name],
                                     owner: current_user)
    UsersList.create!(user: current_user, list: new_todo_list,
                      has_accepted: true)
    new_todo_list.id
  end
end
