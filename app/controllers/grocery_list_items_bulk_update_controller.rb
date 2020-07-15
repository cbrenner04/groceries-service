# frozen_string_literal: true

# bulk update grocery list items
class GroceryListItemsBulkUpdateController < ListItemsController
  def show
    items = GroceryListItem.find(params[:item_ids].split(","))
    list = GroceryList.find(params[:list_id])
    categories = list.categories
    lists = current_user.write_lists.filter do |list|
      list.type == "GroceryList" && list.id != params[:list_id].to_i
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
