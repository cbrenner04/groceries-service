# frozen_string_literal: true

# service object for Lists
class V2::ListsService
  class << self
    def index_response(user)
      {
        accepted_lists: user.accepted_lists,
        pending_lists: user.pending_lists,
        current_user_id: user.id,
        current_list_permissions: user.current_list_permissions,
        available_list_item_configurations: user.available_list_item_configurations
      }
    end

    def show_response(list, user)
      {
        current_user_id: user.id, list: list, not_completed_items: ordered_items(list).not_completed,
        completed_items: ordered_items(list).completed.not_refreshed, categories: list.categories,
        list_users: UsersListsService.list_users(list.id),
        permissions: UsersList.find_by(list_id: list.id, user_id: user.id).permissions,
        lists_to_update: lists_to_update(list, user),
        available_list_item_configurations: user.available_list_item_configurations
      }
    end

    def ordered_items(list)
      list.list_items.not_archived.ordered
    end

    def lists_to_update(list, user)
      user.write_lists.filter do |l_list|
        l_list.list_item_configuration_id == list.list_item_configuration_id && l_list.id != list.id
      end
    end

    def list_response(list, users_list, user)
      list.attributes.merge!(has_accepted: true, user_id: user.id, users_list_id: users_list.id).to_json
    end

    def build_new_list(params, user)
      # TODO: remove when `type` attr is removed from List
      list_type = params[:type] || "GroceryList"
      # TODO: remove `type` when `type` attr is removed from List
      new_list_params = params.merge!(owner: user, type: list_type)
      List.new(new_list_params)
    end
  end
end
