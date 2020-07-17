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

  def update
    update_current_items
    create_new_items if item_params[:move] || item_params[:copy]
    items.each(&:archive) if item_params[:move]

    head :no_content
  end

  private

  def item_params
    @item_params ||= params
                     .require(:grocery_list_items)
                     .permit(:quantity, :clear_quantity, :category,
                             :clear_category, :copy, :move, :existing_list_id,
                             :new_list_name, :update_current_items)
  end

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

  def update_quantity
    @update_quantity ||= item_params[:quantity] && !item_params[:clear_quantity]
  end

  def update_category
    @update_category ||= item_params[:category] && !item_params[:clear_category]
  end

  def update_current_quantity_params
    return {} unless item_params[:quantity] || item_params[:clear_quantity]

    { quantity: update_quantity ? item_params[:quantity] : nil }
  end

  def update_current_category_params
    return {} unless item_params[:category] || item_params[:clear_category]

    { category: update_category ? item_params[:category] : nil }
  end

  def update_current_items
    return unless item_params[:update_current_items]

    update_params = {}.merge(update_current_quantity_params,
                             update_current_category_params)
    items.update_all(update_params)
  end

  def quantity(item)
    return item[:quantity] unless item_params[:quantity] ||
                                  item_params[:clear_quantity]

    update_quantity ? item_params[:quantity] : nil
  end

  def category(item)
    return item[:category] unless item_params[:category] ||
                                  item_params[:clear_category]

    update_category ? item_params[:category] : nil
  end

  def create_new_items
    list_id = item_params[:existing_list_id] || create_new_list
    items.each do |item|
      GroceryListItem.create!(user: current_user, grocery_list_id: list_id,
                              product: item[:product], quantity: quantity(item),
                              category: category(item))
    end
  end

  def create_new_list
    return unless item_params[:new_list_name]

    new_grocery_list = GroceryList.create!(name: item_params[:new_list_name],
                                           owner: current_user)
    UsersList.create!(user: current_user, list: new_grocery_list,
                      has_accepted: true)
    new_grocery_list.id
  end
end
