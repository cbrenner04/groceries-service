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

  def update
    update_current_items
    create_new_items if item_params[:move] || item_params[:copy]
    items.each(&:archive) if item_params[:move]

    head :no_content
  end

  private

  def item_params
    @item_params ||= params
                     .require(:book_list_items)
                     .permit(:author, :clear_author, :category, :clear_category,
                             :copy, :move, :existing_list_id, :new_list_name,
                             :update_current_items)
  end

  def items
    @items ||= BookListItem.where(id: params[:item_ids].split(","))
  end

  def list
    @list ||= BookList.find(params[:list_id])
  end

  def lists
    current_user.write_lists.filter do |list|
      list.type == "BookList" && list.id != params[:list_id].to_i
    end
  end

  def update_author
    @update_author ||= item_params[:author] && !item_params[:clear_author]
  end

  def update_category
    @update_category ||= item_params[:category] && !item_params[:clear_category]
  end

  def update_current_author_params
    return {} unless item_params[:author] || item_params[:clear_author]

    { author: update_author ? item_params[:author] : nil }
  end

  def update_current_category_params
    return {} unless item_params[:category] || item_params[:clear_category]

    { category: update_category ? item_params[:category] : nil }
  end

  def update_current_items
    return unless item_params[:update_current_items]

    update_params = {}.merge(update_current_author_params,
                             update_current_category_params)
    items.update_all(update_params)
  end

  def author(item)
    return item[:author] unless item_params[:author] ||
                                item_params[:clear_author]

    update_author ? item_params[:author] : nil
  end

  def category(item)
    return item[:category] unless item_params[:category] ||
                                  item_params[:clear_category]

    update_category ? item_params[:category] : nil
  end

  def create_new_items
    list_id = item_params[:existing_list_id] || create_new_list
    items.each do |item|
      BookListItem.create!(user: current_user, book_list_id: list_id,
                           title: item[:title], author: author(item),
                           category: category(item))
    end
  end

  def create_new_list
    return unless item_params[:new_list_name]

    new_book_list = BookList.create!(name: item_params[:new_list_name],
                                     owner: current_user)
    UsersList.create!(user: current_user, list: new_book_list,
                      has_accepted: true)
    new_book_list.id
  end
end
