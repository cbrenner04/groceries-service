# frozen_string_literal: true

# bulk update grocery list items
class GroceryListItemsBulkUpdateController < ListItemsController
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
    @items ||= GroceryListItem.where(id: params[:item_ids].split(","))
  end

  def list
    @list ||= GroceryList.find(params[:list_id])
  end

  def lists
    current_user.write_lists.filter do |list|
      list.type == "GroceryList" && list.id != params[:list_id].to_i
    end
  end
end
