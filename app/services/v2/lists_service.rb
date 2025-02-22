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
        current_user_id: user.id,
        list: list,
        not_completed_items: ordered_items(list).not_completed,
        completed_items: ordered_items(list).completed.not_refreshed,
        # TODO: how we handling this moving forward?
        # categories: list.categories,
        list_users: UsersListsService.list_users(list.id),
        permissions: UsersList.find_by(list_id: list.id, user_id: user.id).permissions,
        lists_to_update: lists_to_update(list, user),
        available_list_item_configurations: user.available_list_item_configurations,
        list_item_configuration: list.list_item_configuration
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
      new_list_params = params.merge!(owner: user)
      List.new(new_list_params)
    end

    def update_previous_list(users_list)
      return unless users_list.prev_id

      UsersList.find(users_list.prev_id).update!(next_id: users_list.next_id)
    end

    def update_next_list(users_list)
      return unless users_list.next_id

      UsersList.find(users_list.next_id).update!(prev_id: users_list.prev_id)
    end

    def update_previous_and_next_list(users_list)
      update_previous_list(users_list)
      update_next_list(users_list)
      users_list.update!(prev_id: nil, next_id: nil)
    end

    def create_new_list_items(old_list, new_list, user)
      item_attrs = { user: user, list: new_list }
      items = old_list.list_items.reject { |item| item.refreshed || item.archived_at.present? }
      items.each do |item|
        new_item = new_list.list_items.create!(user: user)
        item.list_item_fields.each do |list_item_field|
          field_config = list_item_field.list_item_field_configuration
          new_item
            .list_item_fields
            .create!(user: user, data: list_item_field.data, list_item_field_configuration: field_config)
        end
      end
    end

    def create_new_items_from_multiple_lists(lists, new_list, user)
      lists.each { |old_list| create_new_list_items(old_list, new_list, user) }
    end
  end
end
