# frozen_string_literal: true

# bulk update music list items
class MusicListItemsBulkUpdateController < ListItemsController
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
                     .require(:music_list_items)
                     .permit(:artist, :clear_artist, :album, :clear_album,
                             :category, :clear_category, :copy, :move,
                             :existing_list_id, :new_list_name,
                             :update_current_items)
  end

  def items
    @items ||= MusicListItem.where(id: params[:item_ids].split(","))
  end

  def list
    @list ||= MusicList.find(params[:list_id])
  end

  def lists
    current_user.write_lists.filter do |list|
      list.type == "MusicList" && list.id != params[:list_id].to_i
    end
  end

  def update_artist
    @update_artist ||= item_params[:artist] &&
                       !item_params[:clear_artist]
  end

  def update_album
    @update_album ||= item_params[:album] && !item_params[:clear_album]
  end

  def update_category
    @update_category ||= item_params[:category] && !item_params[:clear_category]
  end

  def update_current_artist_params
    return {} unless item_params[:artist] || item_params[:clear_artist]

    { artist: update_artist ? item_params[:artist] : nil }
  end

  def update_current_album_params
    return {} unless item_params[:album] || item_params[:clear_album]

    { album: update_album ? item_params[:album] : nil }
  end

  def update_current_category_params
    return {} unless item_params[:category] || item_params[:clear_category]

    { category: update_category ? item_params[:category] : nil }
  end

  def update_current_items
    return unless item_params[:update_current_items]

    update_params = {}.merge(update_current_artist_params,
                             update_current_album_params,
                             update_current_category_params)
    items.update_all(update_params)
  end

  def artist(item)
    return item[:artist] unless item_params[:artist] ||
                                item_params[:clear_artist]

    update_artist ? item_params[:artist] : nil
  end

  def album(item)
    return item[:album] unless item_params[:album] || item[:clear_album]

    update_album ? item_params[:album] : nil
  end

  def category(item)
    return item[:category] unless item_params[:category] ||
                                  item_params[:clear_category]

    update_category ? item_params[:category] : nil
  end

  def create_new_items
    list_id = item_params[:existing_list_id] || create_new_list
    items.each do |item|
      MusicListItem.create!(user: current_user, music_list_id: list_id,
                            title: item[:title], artist: artist(item),
                            album: album(item), category: category(item))
    end
  end

  def create_new_list
    return unless item_params[:new_list_name]

    new_music_list = MusicList.create!(name: item_params[:new_list_name],
                                       owner: current_user)
    UsersList.create!(user: current_user, list: new_music_list,
                      has_accepted: true)
    new_music_list.id
  end
end
