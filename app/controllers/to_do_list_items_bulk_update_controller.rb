# frozen_string_literal: true

# bulk update to do list items
class ToDoListItemsBulkUpdateController < ListItemsController
  include UsersListsService

  def show
    items = ToDoListItem.find(params[:item_ids].split(","))
    list = ToDoList.find(params[:list_id])
    categories = list.categories
    lists = current_user.write_lists.filter do |list|
      list.type == "ToDoList" && list.id != params[:list_id].to_i
    end
    list_users = list_users(params[:list_id])
    render json: {
      items: items,
      list: list,
      lists: lists,
      categories: categories,
      list_users: list_users
    }
  end

  def update
    current_list_items = ToDoListItem.where(id: params[:item_ids].split(","))
    update_params = {}
    if item_params[:update_current_items]
      if item_params[:assignee_id] && !item_params[:clear_assignee]
        update_params[:assignee_id] = item_params[:assignee_id]
      end
      if item_params[:due_by] && !item_params[:clear_due_by]
        update_params[:due_by] = item_params[:due_by]
      end
      if item_params[:category] && !item_params[:clear_category]
        update_params[:category] = item_params[:category]
      end
      current_list_items.update_all(update_params)
    end
    if item_params[:move] || item_params[:copy]
      if item_params[:new_list_name]
        new_todo_list = ToDoList.create!(name: item_params[:new_list_name], owner: current_user)
        UsersList.create!(user: current_user, list: new_todo_list, has_accepted: true)
        current_list_items.each do |item|
          ToDoListItem.create!(
            user: current_user,
            to_do_list: new_todo_list,
            task: item[:task],
            assignee_id: item_params[:assignee_id] && !item_params[:clear_assignee] ? item_params[:assignee_id] : item_params[:clear_assignee] ? nil : item[:assignee_id],
            due_by: item_params[:due_by] && !item_params[:clear_due_by] ? item_params[:due_by] : item_params[:clear_due_by] ? Date.today : item[:due_by],
            category: item_params[:category] && !item_params[:clear_category] ? item_params[:category] : item_params[:clear_category] ? nil : item[:category]
          )
        end
      end
      if item_params[:existing_list_id]
        current_list_items.each do |item|
          ToDoListItem.create!(
            user: current_user,
            to_do_list_id: item_params[:existing_list_id],
            task: item[:task],
            assignee_id: item_params[:assignee_id] && !item_params[:clear_assignee] ? item_params[:assignee_id] : item_params[:clear_assignee] ? nil : item[:assignee_id],
            due_by: item_params[:due_by] && !item_params[:clear_due_by] ? item_params[:due_by] : item_params[:clear_due_by] ? Date.today : item[:due_by],
            category: item_params[:category] && !item_params[:clear_category] ? item_params[:category] : item_params[:clear_category] ? nil : item[:category]
          )
        end
      end
    end
    current_list_items.each(&:archive) if item_params[:move]
  end

  private

  def item_params
    params
      .require(:to_do_list_items)
      .permit(:assignee_id,
              :clear_assignee,
              :due_by,
              :clear_due_by,
              :category,
              :clear_category,
              :copy,
              :move,
              :existing_list_id,
              :new_list_name,
              :update_current_items)
  end
end
