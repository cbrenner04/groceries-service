# frozen_string_literal: true

# /lists/:list_id/grocery_list_items
class GroceryListItemsController < ListItemsController
  # POST /
  def create
    new_item = GroceryListItem.create(item_params.merge!(grocery_list_id: params[:list_id]))

    if new_item.save
      render json: new_item
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  end

  # GET /:id/edit
  def edit
    list = GroceryList.find(item.grocery_list_id)
    categories = list.categories
    render json: { item: item, list: list, categories: categories }
  end

  # PUT /:id
  def update
    if item.update(item_params)
      render json: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /:id
  def destroy
    item.archive
    head :no_content
  end

  private

  def item_params
    params
      .require(:grocery_list_item)
      .permit(:user_id, :product, :list_id, :quantity, :purchased, :refreshed, :category)
  end

  def item
    @item ||= GroceryListItem.find(params[:id])
  end
end
