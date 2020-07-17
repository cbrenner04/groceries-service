# frozen_string_literal: true

# TODO: needs a service object
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
    items.each(&:archive) if item_params[:move]

    head :no_content
  end

  private

  def item_params
    @item_params ||= params
                     .require(:to_do_list_items)
                     .permit(:assignee_id, :clear_assignee, :due_by,
                             :clear_due_by, :category, :clear_category, :copy,
                             :move, :existing_list_id, :new_list_name,
                             :update_current_items)
  end

  def items
    @items ||= ToDoListItem.where(id: params[:item_ids].split(","))
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

  def update_current_assignee_params
    return {} unless item_params[:assignee_id] || item_params[:clear_assignee]

    { assignee_id: update_assignee ? item_params[:assignee_id] : nil }
  end

  def update_current_due_by_params
    return {} unless item_params[:due_by] || item_params[:clear_due_by]

    { due_by: update_due_by ? item_params[:due_by] : nil }
  end

  def update_current_category_params
    return {} unless item_params[:category] || item_params[:clear_category]

    { category: update_category ? item_params[:category] : nil }
  end

  def update_current_items
    return unless item_params[:update_current_items]

    update_params = {}.merge(update_current_assignee_params,
                             update_current_due_by_params,
                             update_current_category_params)
    items.update_all(update_params)
  end

  def assignee_id(item)
    return item[:assignee_id] unless item_params[:assignee_id] ||
                                     item_params[:clear_assignee]

    update_assignee ? item_params[:assignee_id] : nil
  end

  def due_by(item)
    return item[:due_by] unless item_params[:due_by] || item[:clear_due_by]

    update_due_by ? item_params[:due_by] : nil
  end

  def category(item)
    return item[:category] unless item_params[:category] ||
                                  item_params[:clear_category]

    update_category ? item_params[:category] : nil
  end

  def create_new_items
    list_id = item_params[:existing_list_id] || create_new_list
    items.each do |item|
      ToDoListItem.create!(user: current_user, to_do_list_id: list_id,
                           task: item[:task], assignee_id: assignee_id(item),
                           due_by: due_by(item), category: category(item))
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
