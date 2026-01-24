# frozen_string_literal: true

# service object for Lists
class ListsService
  class << self
    def index_response(user)
      {
        accepted_lists: user.accepted_lists,
        pending_lists: user.pending_lists,
        current_user_id: user.id,
        current_list_permissions: user.current_list_permissions,
        list_item_configurations: user.list_item_configurations
      }
    end

    def show_response(list, user)
      {
        current_user_id: user.id,
        list: list,
        not_completed_items: ordered_items(list, :not_completed),
        completed_items: ordered_items(list, :completed),
        list_users: UsersListsService.list_users(list.id),
        permissions: UsersList.find_by(list_id: list.id, user_id: user.id).permissions,
        lists_to_update: lists_to_update(list, user),
        list_item_configuration: list.list_item_configuration_id ? list.list_item_configuration : nil,
        list_item_field_configurations:
          list.list_item_configuration&.list_item_field_configurations&.order(:position) || []
      }
    end

    def ordered_items(list, additional_scope)
      items = fetch_items_with_fields(list, additional_scope)
      items.map { |item| build_item_response(item) }
    end

    def build_new_list(params, user)
      raise ArgumentError, "list_item_configuration_id required" unless params[:list_item_configuration_id]

      new_list_params = params.except(:user_id).merge!(owner: user)
      List.new(new_list_params)
    end

    def create_new_list_from(old_list)
      List.create!(name: old_list[:name], owner_id: old_list[:owner_id],
                   list_item_configuration_id: old_list[:list_item_configuration_id])
    end

    def create_new_list_items(old_list, new_list, user)
      items = old_list.list_items.reject { |item| item.refreshed || item.archived_at.present? }
      items.each do |item|
        new_item = new_list.list_items.create!(user: user)
        item.list_item_fields.each do |list_item_field|
          field_config = list_item_field.list_item_field_configuration
          # Only create field if data is present
          next if list_item_field.data.blank?

          new_item
            .list_item_fields
            .create!(user: user, data: list_item_field.data, list_item_field_configuration: field_config)
        end
      end
    end

    def create_new_items_from_multiple_lists(lists, new_list, user)
      lists.each { |old_list| create_new_list_items(old_list, new_list, user) }
    end

    def list_response(list, users_list, user)
      list.attributes.merge!(has_accepted: true, user_id: user.id, users_list_id: users_list.id)
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

    def build_item_response(item)
      item.attributes.merge(fields: build_fields_response(item.list_item_fields))
    end

    private

    def fetch_items_with_fields(list, additional_scope)
      list.list_items
          .not_archived
          .ordered
          .send(additional_scope)
          .includes(list_item_fields: :list_item_field_configuration)
    end

    def build_fields_response(fields)
      all_fields = fields.not_archived.map do |field|
        field.attributes.merge(
          label: field.list_item_field_configuration.label,
          position: field.list_item_field_configuration.position,
          data_type: field.list_item_field_configuration.data_type
        )
      end
      all_fields.sort_by { |field| field[:position] }
    end

    def lists_to_update(list, user)
      user.write_lists.filter do |l_list|
        l_list.list_item_configuration_id == list.list_item_configuration_id && l_list.id != list.id
      end
    end
  end
end
