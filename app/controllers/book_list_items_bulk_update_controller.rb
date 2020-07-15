# frozen_string_literal: true

# bulk update book list items
class BookListItemsBulkUpdateController < ListItemsController
  def show
    items = BookListItem.find(params[:item_ids].split(","))
    list = BookList.find(params[:list_id])
    categories = list.categories
    lists = current_user.write_lists.filter do |list|
      list.type == "BookList" && list.id != params[:list_id].to_i
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
