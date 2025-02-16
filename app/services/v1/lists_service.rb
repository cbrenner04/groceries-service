# frozen_string_literal: true

# service object for Lists
class V1::ListsService
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
        permissions: UsersList.find_by(list_id: list.id, user_id: user.id).permissions,
        lists_to_update: lists_to_update(list, user)
      }
    end

    def lists_to_update(list, user)
      user.write_lists.filter do |l_list|
        l_list.type == list.type && l_list.id != list.id
      end
    end

    def list_response(list, users_list, user)
      list.attributes.merge!(has_accepted: true, user_id: user.id, users_list_id: users_list.id).to_json
    end

    def build_new_list(params, user)
      list_type = params[:type] || "GroceryList"
      new_list_params = params.merge!(owner: user, type: list_type)
      List.new(new_list_params)
    end

    def create_new_list_from(old_list)
      list_type = old_list.type || "GroceryList"
      List.create!(name: old_list[:name], owner_id: old_list[:owner_id], type: list_type)
    end

    def create_new_items(old_list, new_list, user)
      create_new_list_items(old_list, new_list, user)
    end

    def create_new_items_from_multiple_lists(lists, new_list, user)
      lists.each { |old_list| create_new_list_items(old_list, new_list, user) }
    end

    def filtered_list(list)
      list_types = %w[GroceryList ToDoList SimpleList]
      list_items(list).reject do |item|
        item_is_not_active = if list_types.include?(list.type)
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
        MusicList: %i[title artist album], SimpleList: %i[content], ToDoList: %i[task assignee_id due_by]
      }[list_type.to_sym]
    end

    def create_new_list_items(old_list, new_list, user)
      list_type = old_list.type
      item_attrs = { user: user, list: new_list }
      filtered_list(old_list).each do |item|
        item_attrs[:category] = item[:category]
        new_item_attributes(list_type).each do |attr|
          item_attrs[attr] = item[attr]
        end
        "#{list_type}Item".constantize.create!(item_attrs)
      end
    end

    def list_items(list)
      "#{list.type}Item".constantize.where(list: list)
    end

    def ordered_items(list)
      list_items(list).not_archived.ordered
    end

    def not_purchased_items(list)
      if %w[ToDoList SimpleList].include?(list.type)
        ordered_items(list).not_completed
      else
        ordered_items(list).not_purchased
      end
    end

    def purchased_items(list)
      if list.type == "GroceryList"
        ordered_items(list).purchased.not_refreshed
      elsif %w[ToDoList SimpleList].include?(list.type)
        ordered_items(list).completed.not_refreshed
      else
        ordered_items(list).purchased
      end
    end
  end
end
