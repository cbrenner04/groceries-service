# frozen_string_literal: true

# bulk update grocery list items
class GroceryListItemsBulkUpdateController < ListItemsController
  def show
    service = BulkUpdateService.new("grocery", params, {}, current_user)
    render json: service.show_body
  end

  def update
    update_service.update_current_items
    update_service.create_new_items if item_params[:move] || item_params[:copy]
    update_service.items.each(&:archive) if item_params[:move]

    head :no_content
  end

  private

  def item_params
    params
      .require(:grocery_list_items)
      .permit(:quantity, :clear_quantity, :category, :clear_category, :copy,
              :move, :existing_list_id, :new_list_name, :update_current_items)
  end

  def update_service
    @update_service ||=
      BulkUpdateService.new("grocery", params, item_params, current_user)
  end
end
