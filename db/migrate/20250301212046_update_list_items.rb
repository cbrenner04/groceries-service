class UpdateListItems < ActiveRecord::Migration[8.0]
  def up
    puts "Starting"
    # create "templates" for each user
    User.all.each do |user|
      puts "#{user.email} configurations"
      puts "book list configuration"
      item_config = user.list_item_configurations.create!(name: "book list template")
      item_config.list_item_field_configurations.create!(label: "author", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "title", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "number_in_series", data_type: "number")
      item_config.list_item_field_configurations.create!(label: "category", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "read", data_type: "boolean")

      puts "grocery list configuration"
      item_config = user.list_item_configurations.create!(name: "grocery list template")
      item_config.list_item_field_configurations.create!(label: "category", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "product", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "quantity", data_type: "free_text")


      puts "music list configuration"
      item_config = user.list_item_configurations.create!(name: "music list template")
      item_config.list_item_field_configurations.create!(label: "category", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "title", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "artist", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "album", data_type: "free_text")

      puts "simple list configurations"
      # create a template for simple list with no category
      item_config = user.list_item_configurations.create!(name: "simple list template")
      item_config.list_item_field_configurations.create!(label: "content", data_type: "free_text")

      # the current simple list is with category
      item_config = user.list_item_configurations.create!(name: "simple list with category template")
      item_config.list_item_field_configurations.create!(label: "category", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "content", data_type: "free_text")

      puts "to do list configuration"
      item_config = user.list_item_configurations.create!(name: "to do list template")
      item_config.list_item_field_configurations.create!(label: "category", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "due_by", data_type: "date_time")
      item_config.list_item_field_configurations.create!(label: "task", data_type: "free_text")
      item_config.list_item_field_configurations.create!(label: "assignee", data_type: "free_text")
    end

    # add data for all existing book lists
    BookList.all.each do |book_list|
      list_owner = User.find(book_list.owner_id)
      book_list_configuration = list_owner.list_item_configurations.find_by(name: "book list template")
      author_field_configuration = book_list_configuration.list_item_field_configurations.find_by(label: "author")
      title_field_configuration = book_list_configuration.list_item_field_configurations.find_by(label: "title")
      number_in_series_field_configuration =
        book_list_configuration.list_item_field_configurations.find_by(label: "number_in_series")
      category_field_configuration = book_list_configuration.list_item_field_configurations.find_by(label: "category")
      read_field_configuration = book_list_configuration.list_item_field_configurations.find_by(label: "read")
      # add list_item_configuration to list
      book_list.update!(list_item_configuration_id: book_list_configuration.id)
      # items data
      puts "book list items data"
      book_list.book_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = book_list.list_items.create!(user: list_item.user, archived_at: list_item.archived_at,
                                                     completed: list_item.purchased)
        if list_item.author && list_item.author.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(list_item_field_configuration: author_field_configuration,
                                                 user: list_item.user, archived_at: list_item.archived_at,
                                                 data: list_item.author)
        end
        if list_item.title && list_item.title.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(list_item_field_configuration: title_field_configuration,
                                                 user: list_item.user, archived_at: list_item.archived_at,
                                                 data: list_item.title)
        end
        if list_item.number_in_series
          new_list_item.list_item_fields.create!(list_item_field_configuration: number_in_series_field_configuration,
                                                 user: list_item.user, archived_at: list_item.archived_at,
                                                 data: list_item.number_in_series)
        end
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(list_item_field_configuration: category_field_configuration,
                                                 user: list_item.user, archived_at: list_item.archived_at,
                                                 data: list_item.category)
        end
        unless list_item.read&.nil? # empty string broke me here
          new_list_item.list_item_fields.create!(list_item_field_configuration: read_field_configuration,
                                                 user: list_item.user, archived_at: list_item.archived_at,
                                                 data: list_item.read)
        end
      end
    end

    # add data for all existing grocery lists
    GroceryList.all.each do |grocery_list|
      list_owner = User.find(grocery_list.owner_id)
      grocery_list_configuration = list_owner.list_item_configurations.find_by(name: "grocery list template")
      category_field_configuration =
        grocery_list_configuration.list_item_field_configurations.find_by(label: "category")
      product_field_configuration = grocery_list_configuration.list_item_field_configurations.find_by(label: "product")
      quantity_field_configuration =
        grocery_list_configuration.list_item_field_configurations.find_by(label: "quantity")
      grocery_list.update!(list_item_configuration_id: grocery_list_configuration.id)
      # items data
      puts "grocery list items data"
      grocery_list.grocery_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = grocery_list.list_items.create!(user: list_item.user, archived_at: list_item.archived_at,
                                                        refreshed: list_item.refreshed, completed: list_item.purchased)
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(list_item_field_configuration: category_field_configuration,
                                                 user: list_item.user, data: list_item.category)
        end
        if list_item.product && list_item.product.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(list_item_field_configuration: product_field_configuration,
                                                 user: list_item.user, data: list_item.product)
        end
        if list_item.quantity && list_item.quantity.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(list_item_field_configuration: quantity_field_configuration,
                                                 user: list_item.user, data: list_item.quantity)
        end
      end
    end

    # add data for all existing music lists
    MusicList.all.each do |music_list|
      list_owner = User.find(music_list.owner_id)
      music_list_configuration = list_owner.list_item_configurations.find_by(name: "music list template")
      category_field_configuration = music_list_configuration.list_item_field_configurations.find_by(label: "category")
      title_field_configuration = music_list_configuration.list_item_field_configurations.find_by(label: "title")
      artist_field_configuration = music_list_configuration.list_item_field_configurations.find_by(label: "artist")
      album_field_configuration = music_list_configuration.list_item_field_configurations.find_by(label: "album")
      music_list.update!(list_item_configuration_id: music_list_configuration.id)
      # items data
      puts "music list items data"
      music_list.music_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = music_list.list_items.create!(user: list_item.user, archived_at: list_item.archived_at,
                                                      completed: list_item.purchased)
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.category,
                                                 list_item_field_configuration: category_field_configuration)
        end
        if list_item.title && list_item.title.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.title,
                                                 list_item_field_configuration: title_field_configuration)
        end
        if list_item.artist && list_item.artist.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.artist,
                                                 list_item_field_configuration: artist_field_configuration)
        end
        if list_item.album && list_item.album.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.album,
                                                 list_item_field_configuration: album_field_configuration)
        end
      end
    end

    # add data for all existing simple lists
    SimpleList.all.each do |simple_list|
      list_owner = User.find(simple_list.owner_id)
      simple_list_configuration = list_owner.list_item_configurations.find_by(name: "simple list with category template")
      category_field_configuration = simple_list_configuration.list_item_field_configurations.find_by(label: "category")
      content_field_configuration = simple_list_configuration.list_item_field_configurations.find_by(label: "content")
      simple_list.update!(list_item_configuration_id: simple_list_configuration.id)
      # items data
      puts "simple list items data"
      simple_list.simple_list_items.all.each do |list_item|
        next unless list_item
        new_list_item = simple_list.list_items.create!(user: list_item.user, archived_at: list_item.archived_at,
                                                       completed: list_item.completed, refreshed: list_item.refreshed)

        if list_item.category && list_item.category.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.category,
                                                 list_item_field_configuration: category_field_configuration)
        end

        if list_item.content && list_item.content.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.content,
                                                 list_item_field_configuration: content_field_configuration)
        end
      end
    end

    # add data for all existing to do lists
    ToDoList.all.each do |to_do_list|
      list_owner = User.find(to_do_list.owner_id)
      to_do_list_configuration = list_owner.list_item_configurations.find_by(name: "to do list template")
      category_field_configuration = to_do_list_configuration.list_item_field_configurations.find_by(label: "category")
      due_by_field_configuration = to_do_list_configuration.list_item_field_configurations.find_by(label: "due_by")
      task_field_configuration = to_do_list_configuration.list_item_field_configurations.find_by(label: "task")
      assignee_field_configuration = to_do_list_configuration.list_item_field_configurations.find_by(label: "assignee")
      to_do_list.update!(list_item_configuration_id: to_do_list_configuration.id)
      # items data
      puts "to do list items data"
      to_do_list.to_do_list_items.all.each do |list_item|
        next unless list_item

        new_list_item = to_do_list.list_items.create!(user: list_item.user, refreshed: list_item.refreshed,
                                                      completed: list_item.completed,
                                                      archived_at: list_item.archived_at)
        if list_item.category && list_item.category.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.category,
                                                 list_item_field_configuration: category_field_configuration)
        end
        if list_item.due_by
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.due_by,
                                                 list_item_field_configuration: due_by_field_configuration)
        end
        if list_item.task && list_item.task.length > 0 # empty string broke me here
          new_list_item.list_item_fields.create!(user: list_item.user, data: list_item.task,
                                                 list_item_field_configuration: task_field_configuration,)
        end
        if list_item.assignee_id
          new_list_item.list_item_fields.create!(user: list_item.user, data: User.find(list_item.assignee_id).email,
                                                 list_item_field_configuration: assignee_field_configuration)
        end
      end
    end
  end

  def down
    ListItem.destroy_all
    ListItemConfiguration.destroy_all
  end
end
