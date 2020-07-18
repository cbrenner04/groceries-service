# frozen_string_literal: true

# bulk update music list items
class MusicListItemsBulkUpdateController < ListItemsController
  def show
    service = BulkUpdateService.new("music", params, {}, current_user)
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
      .require(:music_list_items)
      .permit(:artist, :clear_artist, :album, :clear_album, :category,
              :clear_category, :copy, :move, :existing_list_id, :new_list_name,
              :update_current_items)
  end

  def update_service
    @update_service ||=
      BulkUpdateService.new("music", params, item_params, current_user)
  end
end
