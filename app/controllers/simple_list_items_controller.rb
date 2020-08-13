# frozen_string_literal: true

# /lists/:list_id/simple_list_items
class SimpleListItemsController < ListItemsController
  # POST /
  def create
    new_item = SimpleListItem.create(item_params.merge!(simple_list_id: params[:list_id]))

    if new_item.save
      render json: new_item
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  end

  # GET /:id/edit
  def edit
    list = SimpleList.find(item.simple_list_id)
    categories = list.categories
    list_users = UsersListsService.list_users(params[:list_id])
    render json: { item: item, list: list, categories: categories, list_users: list_users }
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # PUT /:id
  def update
    if item.update(item_params)
      render json: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  # DELETE /:id
  def destroy
    item.archive
    head :no_content
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  private

  def item_params
    params
      .require(:simple_list_item)
      .permit(:user_id, :list_id, :content, :completed, :refreshed, :category)
  end

  def item
    @item ||= SimpleListItem.find(params[:id])
  end
end
