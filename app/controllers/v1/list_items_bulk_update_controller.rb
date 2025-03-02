# frozen_string_literal: true

# /v1/lists/:list_id/list_items/bulk_update
# generic controller for bulk updating list items
class V1::ListItemsBulkUpdateController < ProtectedRouteController
  before_action :require_write_access

  # GET /
  def show
    service = V1::BulkUpdateService.new(params, {}, current_user)
    render json: service.show_body
  rescue ActiveRecord::RecordNotFound
    render json: "One or more items were not found", status: :not_found
  end

  # PUT /
  # rubocop:disable Metrics/AbcSize
  def update
    service = V1::BulkUpdateService.new(params, item_params, current_user)
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
      .expect(list_items: %i[author clear_author quantity clear_quantity artist clear_artist album clear_album
                             assignee_id clear_assignee due_by clear_due_by category clear_category copy move
                             existing_list_id new_list_name update_current_items])
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
