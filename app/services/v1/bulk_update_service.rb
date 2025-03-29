# frozen_string_literal: true

# service object for builk update controllers
class V1::BulkUpdateService
  def initialize(params, item_params, current_user)
    @params = params
    @item_params = item_params
    @current_user = current_user
  end

  def show_body
    body = { items: items, list: list, lists: lists, categories: list.categories }
    body[:list_users] = V1::UsersListsService.list_users(list.id) if list_type == "ToDoList"
    body
  end

  def items
    return @items if @items

    item_ids = @params[:item_ids].split(",")
    items = item_class.where(id: item_ids)

    raise ActiveRecord::RecordNotFound unless item_ids.count == items.count

    @items = items
  end

  def update_current_items
    return unless @item_params[:update_current_items]

    update_params = {}
    update_item_attributes.each do |attr, clear_attr|
      update_params.merge!(update_current_attr_params(attr, clear_attr))
    end
    items.each { |item| item.update!(update_params) }
  end

  def create_new_items
    list_id = @item_params[:existing_list_id] || create_new_list
    items.each { |item| item_class.create!(item_attributes(item, list_id)) }
  end

  private

  def list
    @list ||= List.find(@params[:list_id])
  end

  def list_type
    @list_type ||= list.type
  end

  def item_class
    @item_class ||= "#{list_type}Item".constantize
  end

  def lists
    @current_user.write_lists.filter do |list|
      list.type == list_type && list.id != @params[:list_id]
    end
  end

  # rubocop:disable Metrics/MethodLength
  def update_item_attributes
    list_attrs = [%i[category clear_category]]

    case list_type
    when "BookList"
      list_attrs.push(%i[author clear_author])
    when "GroceryList"
      list_attrs.push(%i[quantity clear_quantity])
    when "MusicList"
      list_attrs.push(%i[artist clear_artist], %i[album clear_album])
    when "SimpleList"
      list_attrs
    when "ToDoList"
      list_attrs.push(%i[assignee_id clear_assignee], %i[due_by clear_due_by])
    end
  end
  # rubocop:enable Metrics/MethodLength

  def new_item_attributes
    {
      BookList: %i[title number_in_series], GroceryList: %i[product], MusicList: %i[title], SimpleList: %i[content],
      ToDoList: %i[task]
    }[list_type.to_sym]
  end

  def should_update_attr(attr, clear_attr)
    @item_params[attr] && !@item_params[clear_attr]
  end

  def update_current_attr_params(attr, clear_attr)
    return {} unless @item_params[attr] || @item_params[clear_attr]

    { attr => should_update_attr(attr, clear_attr) ? @item_params[attr] : nil }
  end

  def new_attr_value(item, attr, clear_attr)
    return item[attr] unless @item_params[attr] || @item_params[clear_attr]

    should_update_attr(attr, clear_attr) ? @item_params[attr] : nil
  end

  def create_new_list
    new_list = List.create!(name: @item_params[:new_list_name], owner: @current_user, type: list_type)
    UsersList.create!(user: @current_user, list: new_list, has_accepted: true)
    new_list.id
  end

  def item_attributes(item, list_id)
    item_attrs = { user: @current_user, list_id: list_id }

    new_item_attributes.each do |attr|
      item_attrs.merge!(attr => item[attr])
    end

    update_item_attributes.each do |attr, clear_attr|
      item_attrs.merge!(attr => new_attr_value(item, attr, clear_attr))
    end

    item_attrs
  end
end
