# frozen_string_literal: true

# TODO: needs a service object
# bulk update to do list items
class ToDoListItemsBulkUpdateController < ListItemsController
  include UsersListsService

  def show
    service = BulkUpdateService.new("to_do", params, {}, current_user)
    render json: service
      .show_body
      .merge(list_users: list_users(params[:list_id]))
  end

  def update
    service.update_current_items
    service.create_new_items if item_params[:move] || item_params[:copy]
    service.items.each(&:archive) if item_params[:move]

    head :no_content
  end

  private

  def item_params
    params
      .require(:to_do_list_items)
      .permit(:assignee_id, :clear_assignee, :due_by,
              :clear_due_by, :category, :clear_category, :copy,
              :move, :existing_list_id, :new_list_name,
              :update_current_items)
  end

  def update_service
    @update_service ||=
      BulkUpdateService.new("to_do", params, item_params, current_user)
  end
end
