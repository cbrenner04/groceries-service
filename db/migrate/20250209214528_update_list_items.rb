class UpdateListItems < ActiveRecord::Migration[8.0]
  def up
    puts "Starting"
    # add data for all existing book lists
    BookList.all.each do |book_list|
      # configuration data first
      puts "book list configurations"
      configuration = ListItemConfiguration.create!(list: book_list)
      author_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "author",
                                                        data_type: "free_text")
      title_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "title",
                                                       data_type: "free_text")
      number_in_series_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration,
                                                                  label: "number_in_series", data_type: "number")
      category_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "category",
                                                          data_type: "free_text")
      read_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "read",
                                                      data_type: "boolean")

      # items data
      puts "book list items data"
      book_list.book_list_items.all.each do |list_item|
        new_list_item = ListItem.create!(list: book_list, user: list_item.user, archived_at: list_item.archived_at,
                                         completed: list_item.purchased)
        ListItemField.create!(list_item: new_list_item, list_item_field_configuration: author_field,
                              user: list_item.user, archived_at: list_item.archived_at, data: list_item.author)
        ListItemField.create!(list_item: new_list_item, list_item_field_configuration: title_field,
                              user: list_item.user, archived_at: list_item.archived_at, data: list_item.title)
        ListItemField.create!(list_item: new_list_item, list_item_field_configuration: number_in_series_field,
                              user: list_item.user, archived_at: list_item.archived_at,
                              data: list_item.number_in_series)
        ListItemField.create!(list_item: new_list_item, list_item_field_configuration: category_field,
                              user: list_item.user, archived_at: list_item.archived_at, data: list_item.category)
        ListItemField.create!(list_item: new_list_item, list_item_field_configuration: read_field,
                              user: list_item.user, archived_at: list_item.archived_at, data: list_item.read)
      end
    end

    # add data for all existing grocery lists
    GroceryList.all.each do |grocery_list|
      # configuration data first
      puts "grocery list configurations"
      configuration = ListItemConfiguration.create!(list: grocery_list)
      category_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "category",
                                                          data_type: "free_text")
      product_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "product",
                                                         data_type: "free_text")
      quantity_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "quantity",
                                                          data_type: "free_text")

      # items data
      puts "grocery list items data"
      grocery_list.grocery_list_items.all.each do |list_item|
        new_list_item = ListItem.create!(list: grocery_list, user: list_item.user, archived_at: list_item.archived_at,
                                         refreshed: list_item.refreshed, completed: list_item.purchased)
        if list_item.category
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: category_field,
                                user: list_item.user, data: list_item.category)
        end
        ListItemField.create!(list_item: new_list_item, list_item_field_configuration: product_field,
                              user: list_item.user, data: list_item.product)
        ListItemField.create!(list_item: new_list_item, list_item_field_configuration: quantity_field,
                              user: list_item.user, data: list_item.quantity)
      end
    end

    # add data for all existing music lists
    MusicList.all.each do |music_list|
      # configuration data first
      puts "music list configurations"
      configuration = ListItemConfiguration.create!(list: music_list)
      category_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "category",
                                                          data_type: "free_text")
      title_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "title",
                                                       data_type: "free_text")
      artist_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "artist",
                                                        data_type: "free_text")
      album_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "album",
                                                       data_type: "free_text")

      # items data
      puts "music list items data"
      music_list.music_list_items.all.each do |list_item|
        new_list_item = ListItem.create!(list: music_list, user: list_item.user, archived_at: list_item.archived_at,
                                         completed: list_item.purchased)
        ListItemField.create!(list_item: new_list_item, user: list_item.user,
                              list_item_field_configuration: category_field, data: list_item.category)
        ListItemField.create!(list_item: new_list_item, user: list_item.user,
                              list_item_field_configuration: title_field, data: list_item.title)
        ListItemField.create!(list_item: new_list_item, user: list_item.user,
                              list_item_field_configuration: artist_field, data: list_item.artist)
        ListItemField.create!(list_item: new_list_item, user: list_item.user,
                              list_item_field_configuration: album_field, data: list_item.album)
      end
    end

    # add data for all existing simple lists
    SimpleList.all.each do |simple_list|
      # configuration data first
      puts "simple list configurations"
      configuration = ListItemConfiguration.create!(list: simple_list)
      category_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "category",
                                                          data_type: "free_text")
      content_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "content",
                                                         data_type: "free_text")

      # items data
      puts "simple list items data"
      simple_list.simple_list_items.all.each do |list_item|
        new_list_item = ListItem.create!(list: simple_list, user: list_item.user, archived_at: list_item.archived_at,
                                         completed: list_item.completed, refreshed: list_item.refreshed)
        ListItemField.create!(list_item: new_list_item, user: list_item.user,
                              list_item_field_configuration: category_field, data: list_item.category)
        ListItemField.create!(list_item: new_list_item, user: list_item.user,
                              list_item_field_configuration: content_field, data: list_item.content)
      end
    end

    # add data for all existing to do lists
    ToDoList.all.each do |to_do_list|
      # configuration data first
      puts "to do list configurations"
      configuration = ListItemConfiguration.create!(list: to_do_list)
      category_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "category",
                                                          data_type: "free_text")
      due_by_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "due_by",
                                                        data_type: "date_time")
      task_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "task",
                                                      data_type: "free_text")
      assignee_field = ListItemFieldConfiguration.create!(list_item_configuration: configuration, label: "assignee",
                                                          data_type: "free_text")

      # items data
      puts "to do list items data"
      to_do_list.to_do_list_items.all.each do |list_item|
        new_list_item = ListItem.create!(list: to_do_list, user: list_item.user, refreshed: list_item.refreshed,
                                         completed: list_item.completed, archived_at: list_item.archived_at)
        if list_item.category.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: category_field, data: list_item.category)
        end
        if list_item.due_by
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: due_by_field, data: list_item.due_by)
        end
        ListItemField.create!(list_item: new_list_item, user: list_item.user,
                              list_item_field_configuration: task_field, data: list_item.task)
        if list_item.assignee_id
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: assignee_field,
                                data: User.find(list_item.assignee_id).email)
        end
      end
    end
  end

  def down
    ListItem.destroy_all
    ListItemConfiguration.destroy_all
  end
end
