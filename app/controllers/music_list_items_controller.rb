# frozen_string_literal: true

# /lists/:list_id/music_list_items
class MusicListItemsController < ListItemsController
  # POST /
  def create
    new_item = MusicListItem.create(item_params.merge!(music_list_id: params[:list_id]))

    if new_item.save
      render json: new_item
    else
      render json: new_item.errors, status: :unprocessable_entity
    end
  end

  # GET /:id/edit
  def edit
    list = MusicList.find(item.music_list_id)
    categories = list.categories
    render json: { item: item, list: list, categories: categories }
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
      .require(:music_list_item)
      .permit(:user_id, :list_id, :title, :artist, :album, :purchased, :category)
  end

  def item
    @item ||= MusicListItem.find(params[:id])
  end
end
