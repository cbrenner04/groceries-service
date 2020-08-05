# frozen_string_literal: true

# no doc
class MusicListItemsController < ListItemsController
  def create
    new_item = MusicListItem.create(item_params.merge!(music_list_id: params[:list_id]))

    if new_item.save
      render json: new_item
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  end

  def edit
    list = MusicList.find(item.music_list_id)
    categories = list.categories
    render json: { item: item, list: list, categories: categories }
  end

  def update
    if item.update(item_params)
      render json: item
    else
      render json: item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    item.archive
    head :no_content
  end

  private

  def item_params
    params
      .require(:music_list_item)
      .permit(:user_id, :list_id, :title, :artist, :album, :purchased, :category)
  end

  def item
    @item ||= MusicListItem.find(params[:id])
  end
end
