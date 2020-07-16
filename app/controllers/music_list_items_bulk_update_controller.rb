# frozen_string_literal: true

# bulk update music list items
class MusicListItemsBulkUpdateController < ListItemsController
  def show
    render json: {
      items: items,
      list: list,
      lists: lists,
      categories: list.categories
    }
  end

  def update; end

  private

  def items
    @items ||= MusicListItem.where(id: params[:item_ids].split(","))
  end

  def list
    @list ||= MusicList.find(params[:list_id])
  end

  def lists
    current_user.write_lists.filter do |list|
      list.type == "MusicList" && list.id != params[:list_id].to_i
    end
  end
end
