# frozen_string_literal: true

# service object for list item bulk updates
class V2::BulkUpdateService
  def initialize(params, item_params, current_user)
    @params = params
    @item_params = item_params
    @current_user = current_user
  end

  # TODO: `list_users` is legacy functionality for "ToDo Lists", not entirely sure how we will mimic this in UX
  def show_body
    { items: items, list: list, lists: lists, list_users: V2::UsersListsService.list_users(list.id) }
  end

  def update_current_items
    return unless @item_params[:update_current_items]

    fields_to_update = @params[:list_items][:fields_to_update]
    fields_to_update.each do |field_to_update|
      field_to_update[:list_item_field_ids].each do |list_item_field_id|
        ListItemField.find(list_item_field_id).update!(data: field_to_update[:data])
      end
    end
  end

  # TODO: split this up
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_new_items
    # TODO: this won't haunt me. nope nope nope
    # should we just have an explicit param for whether or not to create a new list?
    list_id = @item_params[:new_list_name] ? create_new_list : @item_params[:existing_list_id]
    items.each do |item|
      list_item = ListItem.create!(list_id: list_id, user: @current_user)
      fields_to_update = @params[:list_items][:fields_to_update]
      item[:fields].each do |field_to_create|
        field_config = field_to_create.list_item_field_configuration
        field_to_update = fields_to_update.find { |f| f[:list_item_field_ids].include?(field_to_create.id) }
        data = field_to_update ? field_to_update[:data] : field_to_create.data
        list_item.list_item_fields.create!(data: data, user: @current_user, list_item_field_configuration: field_config)
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def items
    return @items if @items

    item_ids = @params[:item_ids].split(",")
    items = ListItem.where(id: item_ids).map do |item|
      {
        item: item,
        fields: item.list_item_fields
      }
    end

    raise ActiveRecord::RecordNotFound unless item_ids.count == items.count

    @items = items
  end

  private

  def list
    @list ||= List.find(@params[:list_id])
  end

  # list of `list`s with the same configuration
  def lists
    list_item_config_id = list.list_item_configuration_id
    @current_user.write_lists.filter { |l| l.list_item_configuration_id == list_item_config_id }
  end

  def create_new_list
    list_item_config = List.find(@item_params[:existing_list_id]).list_item_configuration_id
    new_list = List.create!(name: @item_params[:new_list_name], owner: @current_user,
                            list_item_configuration_id: list_item_config)
    UsersList.create!(user: @current_user, list: new_list, has_accepted: true)
    new_list.id
  end
end
