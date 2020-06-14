# frozen_string_literal: true

# no doc
class BookListItemsController < ListItemsController
  def create
    @item = BookListItem
            .create(item_params.merge!(book_list_id: params[:list_id]))
    if @item.save
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def edit
    item = BookListItem.find(params[:id])
    list = BookList.find(item.book_list_id)
    categories = list.categories
    render json: { item: item, list: list, categories: categories }
  end

  def update
    @item = BookListItem.find(params[:id])
    if @item.update(item_params)
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @item = BookListItem.find(params[:id])
    @item.archive
    head :no_content
  end

  private

  def item_params
    params
      .require(:book_list_item)
      .permit(:user_id,
              :list_id,
              :author,
              :title,
              :purchased,
              :read,
              :number_in_series,
              :category)
  end
end
