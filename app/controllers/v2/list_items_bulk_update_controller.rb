# frozen_string_literal: true

# /v2/lists/:list_id/list_items/bulk_update
# controller for bulk updating list items
class V2::ListItemsBulkUpdateController < ProtectedRouteController
  before_action :require_write_access

  # GET /
  def show
    service = V2::BulkUpdateService.new(params, {}, current_user)
    render json: service.show_body
  rescue ActiveRecord::RecordNotFound
    render json: "One or more items were not found", status: :not_found
  end

  #   request body for PUT /
  #   {
  #     item_ids: string[],
  #     list_id: string,
  #     list_items: {
  #       copy: boolean,
  #       move: boolean,
  #       existing_list_id: string,
  #       new_list_name: string,
  #       update_current_items: boolean,
  #       list_item_fields_attributes: {
  #         list_item_field_ids: string[],
  #         data: string, # although this may be a different data type depending on the field
  #       }[]
  #     }
  #   }

  # PUT /
  # rubocop:disable Metrics/AbcSize
  def update
    service = V2::BulkUpdateService.new(params, item_params, current_user)
    service.update_current_items
    service.create_new_items if item_params[:move] || item_params[:copy]
    service.items.each { |item| item[:item].archive } if item_params[:move]

    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: "One or more items were not found", status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: e.record.errors.messages, status: :unprocessable_entity
  end
  # rubocop:enable Metrics/AbcSize

  private

  def item_params
    @item_params ||= params
                     .expect(list_items: %i[copy move existing_list_id new_list_name update_current_items])
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
