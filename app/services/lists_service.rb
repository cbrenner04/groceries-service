# frozen_string_literal: true

# service object for Lists
# rubocop:disable Metrics/ModuleLength
module ListsService
  include UsersListsService

  def accept_user_list(list)
    UsersList.find_by(list: list).update!(has_accepted: true)
  end

  def create_users_list(user, list)
    UsersList.create!(user: user, list: list, has_accepted: true)
  end

  def index_response
    {
      accepted_lists: current_user.accepted_lists,
      pending_lists: current_user.pending_lists,
      current_user_id: current_user.id,
      current_list_permissions: current_user.current_list_permissions
    }
  end

  def show_response
    {
      current_user_id: current_user.id,
      list: @list,
      not_purchased_items: @not_purchased_items,
      purchased_items: @purchased_items,
      categories: @list.categories,
      list_users: list_users(@list.id),
      permissions: UsersList
        .find_by(list_id: @list.id, user_id: current_user.id).permissions
    }
  end

  def list_response(list, users_list)
    # return object needs to be updated to include the users_list as this is
    # what the client expects, similar to the index_response > accepted_lists
    list.attributes.merge!(
      has_accepted: true,
      user_id: current_user.id,
      users_list_id: users_list.id
    ).to_json
  end

  # rubocop:disable Metrics/MethodLength
  def build_new_list(params)
    new_list_params = params.merge!(owner: current_user)
    case new_list_params[:type]
    when "ToDoList"
      ToDoList.new(new_list_params)
    when "BookList"
      BookList.new(new_list_params)
    when "MusicList"
      MusicList.new(new_list_params)
    else
      GroceryList.new(new_list_params)
    end
  end
  # rubocop:enable Metrics/MethodLength

  def create_new_list_from(old_list)
    case old_list.type
    when "ToDoList"
      ToDoList.create!(name: old_list[:name], owner_id: old_list[:owner_id])
    when "BookList"
      BookList.create!(name: old_list[:name], owner_id: old_list[:owner_id])
    when "MusicList"
      MusicList.create!(name: old_list[:name], owner_id: old_list[:owner_id])
    else
      GroceryList.create!(name: old_list[:name], owner_id: old_list[:owner_id])
    end
  end

  def create_new_items(old_list, new_list)
    case old_list.type
    when "ToDoList"
      create_to_do_list_items(old_list, new_list)
    when "BookList"
      create_book_list_items(old_list, new_list)
    when "MusicList"
      create_music_list_items(old_list, new_list)
    else
      create_grocery_list_items(old_list, new_list)
    end
  end

  def set_items
    set_ordered_items
    set_not_purchased_items
    set_purchased_items
  end

  private

  def filtered_list(list)
    list_items(list).reject do |item|
      item_is_not_active =
        if list.type == "GroceryList" || list.type == "ToDoList"
          item.refreshed || item.archived_at.present?
        else
          item.archived_at.present?
        end

      item_is_not_active
    end
  end

  def create_to_do_list_items(old_list, new_list)
    filtered_list(old_list).each do |item|
      ToDoListItem.create!(
        user: current_user,
        to_do_list: new_list,
        task: item[:task],
        assignee_id: item[:assignee_id],
        due_by: item[:due_by],
        category: item[:category]
      )
    end
  end

  def create_book_list_items(old_list, new_list)
    filtered_list(old_list).each do |item|
      BookListItem.create!(
        user: current_user,
        book_list: new_list,
        author: item[:author],
        title: item[:title],
        category: item[:category]
      )
    end
  end

  def create_music_list_items(old_list, new_list)
    filtered_list(old_list).each do |item|
      MusicListItem.create!(
        user: current_user,
        music_list: new_list,
        title: item[:title],
        artist: item[:artist],
        album: item[:album],
        category: item[:category]
      )
    end
  end

  def create_grocery_list_items(old_list, new_list)
    filtered_list(old_list).each do |item|
      GroceryListItem.create!(
        user: current_user,
        grocery_list: new_list,
        product: item[:product],
        quantity: item[:quantity],
        category: item[:category]
      )
    end
  end

  def list_items(list)
    case list.type
    when "ToDoList"
      ToDoListItem.where(to_do_list: list)
    when "BookList"
      BookListItem.where(book_list: list)
    when "MusicList"
      MusicListItem.where(music_list: list)
    else
      GroceryListItem.where(grocery_list: list)
    end
  end

  def set_ordered_items
    @ordered_items = list_items(@list).not_archived.ordered
  end

  def set_not_purchased_items
    @not_purchased_items =
      if @list.type == "ToDoList"
        @ordered_items.not_completed
      else
        @ordered_items.not_purchased
      end
  end

  def set_purchased_items
    @purchased_items =
      if @list.type == "GroceryList"
        @ordered_items.purchased.not_refreshed
      elsif @list.type == "ToDoList"
        @ordered_items.completed.not_refreshed
      else
        @ordered_items.purchased
      end
  end
end
# rubocop:enable Metrics/ModuleLength
