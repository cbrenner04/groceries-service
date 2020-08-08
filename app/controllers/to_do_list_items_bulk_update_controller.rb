# frozen_string_literal: true

# /lists/:list_id/to_do_list_items/bulk_update
class ToDoListItemsBulkUpdateController < ListItemsController
  # GET /
  def show
    service = BulkUpdateService.new("to_do", params, {}, current_user)
    render json: service.show_body.merge(list_users: UsersListsService.list_users(params[:list_id]))
  rescue ActiveRecord::RecordNotFound
    render json: "One or more items were not found", status: :not_found
  end

  # PUT /
  # rubocop:disable Metrics/AbcSize
  def update
    service = BulkUpdateService.new("to_do", params, item_params, current_user)
    service.update_current_items
    service.create_new_items if item_params[:move] || item_params[:copy]
    service.items.each(&:archive) if item_params[:move]

    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: "One or more items were not found", status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors.messages, status: :unprocessable_entity
  end
  # rubocop:enable Metrics/AbcSize

  private

  def item_params
    params
      .require(:to_do_list_items)
      .permit(:assignee_id, :clear_assignee, :due_by, :clear_due_by, :category, :clear_category, :copy, :move,
              :existing_list_id, :new_list_name, :update_current_items)
  end
end
