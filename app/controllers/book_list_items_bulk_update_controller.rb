# frozen_string_literal: true

# bulk update book list items
class BookListItemsBulkUpdateController < ListItemsController
  def show
    service = BulkUpdateService.new("book", params, {}, current_user)
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
      .require(:book_list_items)
      .permit(:author, :clear_author, :category, :clear_category, :copy, :move,
              :existing_list_id, :new_list_name, :update_current_items)
  end

  def update_service
    @update_service ||=
      BulkUpdateService.new("book", params, item_params, current_user)
  end
end
