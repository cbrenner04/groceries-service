# frozen_string_literal: true

# bulk update book list items
class BookListItemsBulkUpdateController < ListItemsController
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
    @items ||= BookListItem.where(params[:item_ids].split(","))
  end

  def list
    @list ||= BookList.find(params[:list_id])
  end

  def lists
    current_user.write_lists.filter do |list|
      list.type == "BookList" && list.id != params[:list_id].to_i
    end
  end
end
