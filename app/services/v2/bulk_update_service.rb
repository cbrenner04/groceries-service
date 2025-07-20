# frozen_string_literal: true

# service object for list item bulk updates
# rubocop:disable Metrics/ClassLength
class V2::BulkUpdateService
  def initialize(params, item_params, current_user)
    @params = params
    @item_params = item_params
    @current_user = current_user
  end

  def show_body
    {
      items: items_with_fields,
      list: list,
      lists: lists,
      list_users: V2::UsersListsService.list_users(list.id),
      list_item_configuration: list.list_item_configuration || nil,
      list_item_field_configurations:
        list.list_item_configuration&.list_item_field_configurations&.order(:position) || [],
      categories: list.categories
    }
  end

  def execute
    validate_operation_params
    update_current_items if should_update_current_items?
    create_new_items if should_create_new_items?
    archive_original_items if should_archive_items?
  end

  def items
    @items ||= fetch_items
  end

  private

  def validate_operation_params
    return unless copy_or_move_requested?

    return if new_list_name? || existing_list_id?

    raise ArgumentError, "Either new_list_name or existing_list_id must be provided when copying or moving items"
  end

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength
  def update_current_items
    return unless update_current_items? && list.list_item_configuration_id && fields_to_update.any?

    fields_to_update.each do |field_update|
      field_config = list.list_item_configuration.list_item_field_configurations.find_by(label: field_update[:label])
      next unless field_config

      items = ListItem.where(id: field_update[:item_ids])

      items.each do |item|
        existing_field = item.list_item_fields.find_by(list_item_field_configuration: field_config)

        if field_update[:data].blank?
          # Clear the field by deleting it or setting data to nil
          existing_field&.destroy
        elsif existing_field
          # Update or create the field with the new data
          existing_field.update!(data: field_update[:data])
        else
          item.list_item_fields.create!(data: field_update[:data], user: @current_user,
                                        list_item_field_configuration: field_config)
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength

  def create_new_items
    target_list_id = determine_target_list_id
    items_with_fields.each do |item_data|
      create_new_item_with_fields(item_data, target_list_id)
    end
  end

  def create_new_item_with_fields(item_data, target_list_id)
    new_item = ListItem.create!(list_id: target_list_id, user: @current_user)

    item_data[:fields].each do |field_data|
      field_config = ListItemFieldConfiguration.find(field_data["list_item_field_configuration_id"])
      data = determine_field_data(field_data, fields_to_update)

      # Only create the field if data is present (not nil or blank)
      next if data.blank?

      new_item.list_item_fields.create!(
        data: data,
        user: @current_user,
        list_item_field_configuration: field_config
      )
    end
  end

  def determine_field_data(field_data, fields_to_update)
    return field_data["data"] if fields_to_update.blank?

    # Find the field configuration to get the label
    field_config = ListItemFieldConfiguration.find(field_data["list_item_field_configuration_id"])

    # Look for a matching update by label and check if this item is in the item_ids
    matching_update = fields_to_update.find do |update|
      update[:label] == field_config.label && update[:item_ids].include?(field_data["list_item_id"])
    end

    # If there's a matching update, use its data
    # For copy operations, if the update data is blank, preserve the original data
    # For update operations, blank data means clear the field
    matching_update[:data].presence || field_data["data"]
  end

  def determine_target_list_id
    if new_list_name?
      create_new_list
    else
      existing_list_id
    end
  end

  def create_new_list
    new_list = List.create!(
      name: new_list_name,
      owner: @current_user,
      list_item_configuration_id: list.list_item_configuration_id,
      type: list.type
    )
    UsersList.create!(user: @current_user, list: new_list, has_accepted: true)
    new_list.id
  end

  def archive_original_items
    return unless move_requested?

    items.each { |item| ListItem.find(item["id"]).archive }
  end

  def fetch_items
    item_ids = @params[:item_ids].split(",")
    items = ListItem.where(id: item_ids)

    raise ActiveRecord::RecordNotFound unless item_ids.count == items.count

    items
  end

  def items_with_fields
    @items_with_fields ||= fetch_items_with_fields
  end

  def fetch_items_with_fields
    items.includes(list_item_fields: :list_item_field_configuration).map do |item|
      fields = item.list_item_fields.map do |field|
        field.attributes.merge(label: field.list_item_field_configuration.label)
      end
      item.attributes.merge(fields: fields)
    end
  end

  def fields_to_update
    @fields_to_update ||= extract_fields_to_update
  end

  def extract_fields_to_update
    # Use raw params for fields_to_update to avoid strong parameter issues
    fields = @params.dig(:list_items, :fields_to_update)
    return nil if fields.blank?

    # Convert ActionController::Parameters to regular hashes
    fields.map(&:to_unsafe_h)
  end

  # Helper methods for cleaner conditionals
  def copy_or_move_requested?
    copy_requested? || move_requested?
  end

  def copy_requested?
    @item_params.dig(:list_items, :copy) == true
  end

  def move_requested?
    @item_params.dig(:list_items, :move) == true
  end

  def update_current_items?
    @item_params.dig(:list_items, :update_current_items) == true
  end

  def should_update_current_items?
    update_current_items?
  end

  def should_create_new_items?
    copy_or_move_requested?
  end

  def should_archive_items?
    move_requested?
  end

  def new_list_name?
    new_list_name.present?
  end

  def existing_list_id?
    existing_list_id.present?
  end

  def new_list_name
    @item_params.dig(:list_items, :new_list_name)
  end

  def existing_list_id
    @item_params.dig(:list_items, :existing_list_id)
  end

  def list
    @list ||= List.find(@params[:list_id])
  end

  def lists
    list_item_config_id = list.list_item_configuration_id
    @current_user.write_lists.filter { |l| l.list_item_configuration_id == list_item_config_id }
  end
end
# rubocop:enable Metrics/ClassLength
