# frozen_string_literal: true

# bulk update music list items
class MusicListItemsBulkUpdateController < ListItemsController
  def show
    items = MusicListItem.find(params[:item_ids].split(","))
    list = MusicList.find(params[:list_id])
    categories = list.categories
    lists = current_user.write_lists.filter do |list|
      list.type == "MusicList" && list.id != params[:list_id].to_i
    end
    render json: {
      items: items,
      list: list,
      lists: lists,
      categories: categories
    }
  end

  def update; end
end
