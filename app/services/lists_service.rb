# frozen_string_literal: true

# service object for Lists
class ListsService
  class << self
    def index_response(user)
      {
        accepted_lists: user.accepted_lists, pending_lists: user.pending_lists, current_user_id: user.id,
        current_list_permissions: user.current_list_permissions
      }
    end

    def show_response(list, user)
      {
        current_user_id: user.id, list: list, not_purchased_items: not_purchased_items(list),
        purchased_items: purchased_items(list), categories: list.categories,
        list_users: UsersListsService.list_users(list.id),
        permissions: UsersList.find_by(list_id: list.id, user_id: user.id).permissions
      }
    end

    def list_response(list, users_list, user)
      # return object needs to be updated to include the users_list as this is
      # what the client expects, similar to the index_response > accepted_lists
      list.attributes.merge!(has_accepted: true, user_id: user.id, users_list_id: users_list.id).to_json
    end

    def build_new_list(params, user)
      new_list_params = params.merge!(owner: user)
      list_type = new_list_params[:type] || "GroceryList"
      list_type.constantize.new(new_list_params)
    end

    def create_new_list_from(old_list)
      list_type = old_list.type || "GroceryList"
      list_type.constantize.create!(name: old_list[:name], owner_id: old_list[:owner_id])
    end

    def create_new_items(old_list, new_list, user)
      create_new_list_items(old_list, new_list, user)
    end

    def create_new_items_from_multiple_lists(lists, new_list, user)
      lists.each { |old_list| create_new_list_items(old_list, new_list, user) }
    end

    def filtered_list(list)
      list_items(list).reject do |item|
        item_is_not_active = if list.type == "GroceryList" || list.type == "ToDoList"
                               item.refreshed || item.archived_at.present?
                             else
                               item.archived_at.present?
                             end

        item_is_not_active
      end
    end

    def new_item_attributes(list_type)
      {
        BookList: %i[author title number_in_series], GroceryList: %i[product quantity],
        MusicList: %i[title artist album], ToDoList: %i[task assignee_id due_by]
      }[list_type.to_sym]
    end

    def create_new_list_items(old_list, new_list, user)
      list_type = old_list.type
      list_type_key = list_type.to_s.tableize.singularize
      item_attrs = { user: user, list_type_key => new_list }
      filtered_list(old_list).each do |item|
        item_attrs.merge!(category: item[:category])
        new_item_attributes(list_type).each do |attr|
          item_attrs.merge!(attr => item[attr])
        end
        "#{list_type}Item".constantize.create!(item_attrs)
      end
    end

    def list_items(list)
      list_type = list.type
      list_type_key = list_type.to_s.tableize.singularize
      "#{list_type}Item".constantize.where(list_type_key => list)
    end

    def ordered_items(list)
      list_items(list).not_archived.ordered
    end

    def not_purchased_items(list)
      list.type == "ToDoList" ? ordered_items(list).not_completed : ordered_items(list).not_purchased
    end

    def purchased_items(list)
      if list.type == "GroceryList"
        ordered_items(list).purchased.not_refreshed
      elsif list.type == "ToDoList"
        ordered_items(list).completed.not_refreshed
      else
        ordered_items(list).purchased
      end
    end
  end
end
