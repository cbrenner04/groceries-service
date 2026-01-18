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

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity
  def update_current_items
    return unless update_current_items? && list.list_item_configuration_id && fields_to_update.any?

    fields_to_update.each do |field_update|
      field_config = list.list_item_configuration.list_item_field_configurations.find_by(label: field_update[:label])
      next unless field_config

      update_item_ids = Array(field_update[:item_ids]).map(&:to_s)
      items = ListItem.where(id: update_item_ids)

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
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/CyclomaticComplexity

  def create_new_items
    target_list_id = determine_target_list_id
    items_with_fields.each do |item_data|
      create_new_item_with_fields(item_data, target_list_id)
    end
  end

  def create_new_item_with_fields(item_data, target_list_id)
    new_item = ListItem.create!(list_id: target_list_id, user: @current_user)

    # Handle both symbol and string keys for fields
    fields = item_data[:fields] || item_data["fields"] || []

    fields.each do |field_data|
      field_config_id = field_data["list_item_field_configuration_id"] || field_data[:list_item_field_configuration_id]
      field_config = ListItemFieldConfiguration.find(field_config_id)
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

  # rubocop:disable Metrics/AbcSize
  def determine_field_data(field_data, fields_to_update)
    # Handle both string and symbol keys for data
    original_data = field_data["data"] || field_data[:data]
    return original_data if fields_to_update.blank?

    # Find the field configuration to get the label
    field_config_id = field_data["list_item_field_configuration_id"] || field_data[:list_item_field_configuration_id]
    field_config = ListItemFieldConfiguration.find(field_config_id)

    # Look for a matching update by label and check if this item is in the item_ids
    list_item_id = field_data["list_item_id"] || field_data[:list_item_id]
    list_item_id = list_item_id.to_s
    matching_update = fields_to_update.find do |update|
      update_item_ids = Array(update[:item_ids]).map(&:to_s)
      update[:label] == field_config.label && update_item_ids.include?(list_item_id)
    end

    # If there's a matching update, use its data
    # For copy operations, if the update data is blank, preserve the original data
    # For update operations, blank data means clear the field
    return original_data unless matching_update

    matching_update[:data].presence || original_data
  end
  # rubocop:enable Metrics/AbcSize

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

    items.each(&:archive)
  end

  def fetch_items
    item_ids = item_ids_order
    items_relation = ListItem.where(id: item_ids)

    # Load items to verify they all exist
    loaded_items = items_relation.to_a

    raise ActiveRecord::RecordNotFound unless item_ids.count == loaded_items.count

    # Return relation for use in other methods
    items_relation
  end

  def items_with_fields
    @items_with_fields ||= fetch_items_with_fields
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def fetch_items_with_fields
    # items call ensures @item_ids_order is set via fetch_items
    # Eager load fields and their configurations to avoid N+1 queries
    items_with_associations = items.includes(list_item_fields: :list_item_field_configuration)
    items_hash = items_with_associations.index_by(&:id)

    # Preserve the order from item_ids parameter
    item_ids_order.map do |item_id|
      item = items_hash[item_id]
      # Get all fields for this item - ensure we get all fields by reloading association if needed
      # Convert to array to ensure we have all fields loaded
      all_fields = if item.association(:list_item_fields).loaded?
                     item.list_item_fields.to_a
                   else
                     item.list_item_fields.includes(:list_item_field_configuration).to_a
                   end

      fields = all_fields.map do |field|
        field.attributes.merge(
          label: field.list_item_field_configuration.label,
          list_item_id: item.id
        )
      end
      item.attributes.merge(fields: fields)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def item_ids_order
    @item_ids_order ||= begin
      ids = @params[:item_ids] || @params["item_ids"]
      raise ActiveRecord::RecordNotFound if ids.blank?

      ids.to_s.split(",").map(&:strip).compact_blank
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
