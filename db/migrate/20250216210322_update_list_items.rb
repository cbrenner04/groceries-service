class UpdateListItems < ActiveRecord::Migration[8.0]
  def up
    user = User.first # TODO: make sure to update production with my id
    puts "Starting"
    # add data for all existing book lists
    # configuration data first
    puts "book list configurations"
    book_list_configuration = ListItemConfiguration.create!(name: "book list template", allow_other_users_to_view: true,
                                                            user: user)
    author_field = ListItemFieldConfiguration.create!(list_item_configuration: book_list_configuration, label: "author",
                                                      data_type: "free_text")
    title_field = ListItemFieldConfiguration.create!(list_item_configuration: book_list_configuration, label: "title",
                                                      data_type: "free_text")
    number_in_series_field = ListItemFieldConfiguration.create!(list_item_configuration: book_list_configuration,
                                                                label: "number_in_series", data_type: "number")
    book_category_field = ListItemFieldConfiguration.create!(list_item_configuration: book_list_configuration,
                                                             label: "category", data_type: "free_text")
    read_field = ListItemFieldConfiguration.create!(list_item_configuration: book_list_configuration, label: "read",
                                                      data_type: "boolean")

    BookList.all.each do |book_list|
      # add list_item_configuration to list
      book_list.update!(list_item_configuration_id: book_list_configuration.id)
      # items data
      puts "book list items data"
      book_list.book_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = ListItem.create!(list: book_list, user: list_item.user, archived_at: list_item.archived_at,
                                         completed: list_item.purchased)
        if list_item.author && list_item.author.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: author_field,
                                user: list_item.user, archived_at: list_item.archived_at, data: list_item.author)
        end
        if list_item.title && list_item.title.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: title_field,
                                user: list_item.user, archived_at: list_item.archived_at, data: list_item.title)
        end
        if list_item.number_in_series
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: number_in_series_field,
                                user: list_item.user, archived_at: list_item.archived_at,
                                data: list_item.number_in_series)
        end
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: book_category_field,
                                user: list_item.user, archived_at: list_item.archived_at, data: list_item.category)
        end
        unless list_item.read&.nil? # empty string broke me here
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: read_field,
                                user: list_item.user, archived_at: list_item.archived_at, data: list_item.read)
        end
      end
    end

    # add data for all existing grocery lists
    # configuration data first
    puts "grocery list configurations"
    grocery_configuration = ListItemConfiguration.create!(name: "grocery list template",
                                                          allow_other_users_to_view: true, user: user)
    grocery_category_field = ListItemFieldConfiguration.create!(list_item_configuration: grocery_configuration,
                                                                label: "category", data_type: "free_text")
    product_field = ListItemFieldConfiguration.create!(list_item_configuration: grocery_configuration, label: "product",
                                                        data_type: "free_text")
    quantity_field = ListItemFieldConfiguration.create!(list_item_configuration: grocery_configuration,
                                                        label: "quantity", data_type: "free_text")
    GroceryList.all.each do |grocery_list|
      grocery_list.update!(list_item_configuration_id: grocery_configuration.id)
      # items data
      puts "grocery list items data"
      grocery_list.grocery_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = ListItem.create!(list: grocery_list, user: list_item.user, archived_at: list_item.archived_at,
                                         refreshed: list_item.refreshed, completed: list_item.purchased)
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: grocery_category_field,
                                user: list_item.user, data: list_item.category)
        end
        if list_item.product && list_item.product.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: product_field,
                                user: list_item.user, data: list_item.product)
        end
        if list_item.quantity && list_item.quantity.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, list_item_field_configuration: quantity_field,
                                user: list_item.user, data: list_item.quantity)
        end
      end
    end

    # add data for all existing music lists
    # configuration data first
    puts "music list configurations"
    music_configuration = ListItemConfiguration.create!(name: "music list template", allow_other_users_to_view: true,
                                                        user: user)
    music_category_field = ListItemFieldConfiguration.create!(list_item_configuration: music_configuration,
                                                              label: "category", data_type: "free_text")
    title_field = ListItemFieldConfiguration.create!(list_item_configuration: music_configuration, label: "title",
                                                     data_type: "free_text")
    artist_field = ListItemFieldConfiguration.create!(list_item_configuration: music_configuration, label: "artist",
                                                      data_type: "free_text")
    album_field = ListItemFieldConfiguration.create!(list_item_configuration: music_configuration, label: "album",
                                                     data_type: "free_text")
    MusicList.all.each do |music_list|
      music_list.update!(list_item_configuration_id: music_configuration.id)
      # items data
      puts "music list items data"
      music_list.music_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = ListItem.create!(list: music_list, user: list_item.user, archived_at: list_item.archived_at,
                                         completed: list_item.purchased)
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: music_category_field, data: list_item.category)
        end
        if list_item.title && list_item.title.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: title_field, data: list_item.title)
        end
        if list_item.artist && list_item.artist.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: artist_field, data: list_item.artist)
        end
        if list_item.album && list_item.album.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: album_field, data: list_item.album)
        end
      end
    end

    # add data for all existing simple lists
    # configuration data first
    puts "simple list configurations"
    # create a template for simple list with no category
    simple_no_category_configuration = ListItemConfiguration.create!(name: "simple list template",
                                                                     allow_other_users_to_view: true, user: user)
    ListItemFieldConfiguration.create!(list_item_configuration: simple_no_category_configuration,
                                                       label: "content", data_type: "free_text")

    # the current simple list is with category
    simple_configuration = ListItemConfiguration.create!(name: "simple list with category template",
                                                         allow_other_users_to_view: true, user: user)
    simple_category_field = ListItemFieldConfiguration.create!(list_item_configuration: simple_configuration,
                                                              label: "category", data_type: "free_text")
    content_field = ListItemFieldConfiguration.create!(list_item_configuration: simple_configuration, label: "content",
                                                      data_type: "free_text")
    SimpleList.all.each do |simple_list|
      simple_list.update!(list_item_configuration_id: simple_configuration.id)
      # items data
      puts "simple list items data"
      simple_list.simple_list_items.all.each do |list_item|
        next unless list_item
        new_list_item = ListItem.create!(list: simple_list, user: list_item.user, archived_at: list_item.archived_at,
                                         completed: list_item.completed, refreshed: list_item.refreshed)

        if list_item.category && list_item.category.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                               list_item_field_configuration: simple_category_field, data: list_item.category)
        end

        if list_item.content && list_item.content.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: content_field, data: list_item.content)
        end
      end
    end

    # add data for all existing to do lists
    # configuration data first
    puts "to do list configurations"
    to_do_configuration = ListItemConfiguration.create!(name: "to do list template", allow_other_users_to_view: true,
                                                        user: user)
    to_do_category_field = ListItemFieldConfiguration.create!(list_item_configuration: to_do_configuration,
                                                              label: "category", data_type: "free_text")
    due_by_field = ListItemFieldConfiguration.create!(list_item_configuration: to_do_configuration, label: "due_by",
                                                      data_type: "date_time")
    task_field = ListItemFieldConfiguration.create!(list_item_configuration: to_do_configuration, label: "task",
                                                    data_type: "free_text")
    assignee_field = ListItemFieldConfiguration.create!(list_item_configuration: to_do_configuration, label: "assignee",
                                                        data_type: "free_text")

    ToDoList.all.each do |to_do_list|
      to_do_list.update!(list_item_configuration_id: to_do_configuration.id)
      # items data
      puts "to do list items data"
      to_do_list.to_do_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = ListItem.create!(list: to_do_list, user: list_item.user, refreshed: list_item.refreshed,
                                         completed: list_item.completed, archived_at: list_item.archived_at)
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: to_do_category_field, data: list_item.category)
        end
        if list_item.due_by
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: due_by_field, data: list_item.due_by)
        end
        if list_item.task && list_item.task.length > 0 # empty string broke me here
          ListItemField.create!(list_item: new_list_item, user: list_item.user,
                                list_item_field_configuration: task_field, data: list_item.task)
        end
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
