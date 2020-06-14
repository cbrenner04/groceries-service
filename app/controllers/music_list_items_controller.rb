# frozen_string_literal: true

# no doc
class MusicListItemsController < ListItemsController
  def create
    @item = MusicListItem
            .create(item_params.merge!(music_list_id: params[:list_id]))

    if @item.save
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def edit
    item = MusicListItem.find(params[:id])
    list = MusicList.find(item.music_list_id)
    categories = list.categories
    render json: { item: item, list: list, categories: categories }
  end

  def update
    @item = MusicListItem.find(params[:id])
    if @item.update(item_params)
      render json: @item
    else
      render json: @item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @item = MusicListItem.find(params[:id])
    @item.archive
    head :no_content
  end

  private

  def item_params
    params
      .require(:music_list_item)
      .permit(:user_id,
              :list_id,
              :title,
              :artist,
              :album,
              :purchased,
              :category)
  end
end
