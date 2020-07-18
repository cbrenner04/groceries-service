# frozen_string_literal: true

# service object for builk update controllers
class BulkUpdateService
  def initialize(list_type, params, item_params, current_user)
    @list_type = list_type
    @params = params
    @item_params = item_params
    @current_user = current_user
  end

  def show_body
    { items: items, list: list, lists: lists, categories: list.categories }
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
      update_params =
        update_params.merge(update_current_attr_params(attr, clear_attr))
    end
    items.update_all(update_params)
  end

  def create_new_items
    list_id = @item_params[:existing_list_id] || create_new_list
    items.each { |item| item_class.create!(item_attributes(item, list_id)) }
  end

  private

  def list_class
    {
      book: BookList, grocery: GroceryList, music: MusicList, to_do: ToDoList
    }[@list_type.to_sym]
  end

  def item_class
    {
      book: BookListItem, grocery: GroceryListItem, music: MusicListItem,
      to_do: ToDoListItem
    }[@list_type.to_sym]
  end

  def list
    @list ||= list_class.find(@params[:list_id])
  end

  def lists
    @current_user.write_lists.filter do |list|
      list.type == list_class.to_s && list.id != @params[:list_id].to_i
    end
  end

  def update_item_attributes
    list_attrs = [%i[category clear_category]]

    if @list_type == "book"
      list_attrs.push(%i[author clear_author])
    elsif @list_type == "grocery"
      list_attrs.push(%i[quantity clear_quantity])
    elsif @list_type == "music"
      list_attrs.push(%i[artist clear_artist], %i[album clear_album])
    elsif @list_type == "to_do"
      list_attrs.push(%i[assignee_id clear_assignee], %i[due_by clear_due_by])
    end
  end

  def new_item_attributes
    {
      book: %i[title number_in_series],
      grocery: %i[product],
      music: %i[title],
      to_do: %i[task]
    }[@list_type.to_sym]
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
    new_list = list_class.create!(name: @item_params[:new_list_name],
                                  owner: @current_user)
    UsersList.create!(user: @current_user, list: new_list, has_accepted: true)
    new_list.id
  end

  def item_attributes(item, list_id)
    item_attrs = { user: @current_user, "#{@list_type}_list_id": list_id }

    new_item_attributes.each do |attr|
      item_attrs = item_attrs.merge(attr => item[attr])
    end

    update_item_attributes.each do |attr, clear_attr|
      item_attrs =
        item_attrs.merge(attr => new_attr_value(item, attr, clear_attr))
    end

    item_attrs
  end
end
