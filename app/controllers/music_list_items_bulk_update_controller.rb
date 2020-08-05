# frozen_string_literal: true

# bulk update music list items
class MusicListItemsBulkUpdateController < ListItemsController
  def show
    service = BulkUpdateService.new("music", params, {}, current_user)
    render json: service.show_body
  rescue ActiveRecord::RecordNotFound
    render json: "One or more items were not found", status: :not_found
  end

  # rubocop:disable Metrics/AbcSize
  def update
    service = BulkUpdateService.new("music", params, item_params, current_user)
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
      .require(:music_list_items)
      .permit(:artist, :clear_artist, :album, :clear_album, :category, :clear_category, :copy, :move, :existing_list_id,
              :new_list_name, :update_current_items)
  end
end
