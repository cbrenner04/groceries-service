# frozen_string_literal: true

# TODO: should this be rethought?

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
  #       fields_to_update: {
  #         list_item_field_ids: string[],
  #         data: string,
  #       }[]
  #     }
  #   }

  # PUT /
  def update
    service = V2::BulkUpdateService.new(params, item_params, current_user)

    # Validate items exist before proceeding
    service.items

    service.execute
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: "One or more items were not found", status: :not_found
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def item_params
    @item_params ||= params.permit(
      list_items: [
        :copy, :move, :existing_list_id, :new_list_name, :update_current_items,
        { fields_to_update: %i[list_item_field_ids data] }
      ]
    )
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
