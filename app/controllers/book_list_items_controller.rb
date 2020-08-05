# frozen_string_literal: true

# no doc
class BookListItemsController < ListItemsController
  def create
    new_item = BookListItem.create(item_params.merge!(book_list_id: params[:list_id]))
    if new_item.save
      render json: new_item
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  end

  def edit
    list = BookList.find(item.book_list_id)
    categories = list.categories
    render json: { item: item, list: list, categories: categories }
  end

  def update
    if item.update(item_params)
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    item.archive
    head :no_content
  end

  private

  def item_params
    params
      .require(:book_list_item)
      .permit(:user_id, :list_id, :author, :title, :purchased, :read, :number_in_series, :category)
  end

  def item
    @item ||= BookListItem.find(params[:id])
  end
end
