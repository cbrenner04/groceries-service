user_emails = %w(foo@example.com bar@example.com baz@example.com)
foo, bar, baz = user_emails.map do |email|
  User.create!(
    email: email,
    password: 'asdfasdf',
    password_confirmation: 'asdfasdf',
    uid: email
  )
end

# Create list item configurations for v2 system
def create_list_item_configurations(user)
  # Book list configuration
  book_config = user.list_item_configurations.create!(
    name: "book list template"
  )
  book_config.list_item_field_configurations.create!([
    { label: "author", data_type: "free_text", position: 1 },
    { label: "title", data_type: "free_text", position: 2 },
    { label: "number_in_series", data_type: "number", position: 3 },
    { label: "category", data_type: "free_text", position: 4 },
    { label: "read", data_type: "boolean", position: 5 }
  ])

  # Grocery list configuration
  grocery_config = user.list_item_configurations.create!(
    name: "grocery list template"
  )
  grocery_config.list_item_field_configurations.create!([
    { label: "product", data_type: "free_text", position: 1 },
    { label: "quantity", data_type: "free_text", position: 2 },
    { label: "category", data_type: "free_text", position: 3 }
  ])

  # Music list configuration
  music_config = user.list_item_configurations.create!(
    name: "music list template"
  )
  music_config.list_item_field_configurations.create!([
    { label: "title", data_type: "free_text", position: 1 },
    { label: "artist", data_type: "free_text", position: 2 },
    { label: "album", data_type: "free_text", position: 3 },
    { label: "category", data_type: "free_text", position: 4 }
  ])

  # ToDo list configuration
  todo_config = user.list_item_configurations.create!(
    name: "todo list template"
  )
  todo_config.list_item_field_configurations.create!([
    { label: "task", data_type: "free_text", position: 1 },
    { label: "assignee", data_type: "free_text", position: 2 },
    { label: "due_by", data_type: "date_time", position: 3 },
    { label: "category", data_type: "free_text", position: 4 }
  ])

  # Simple list configuration
  simple_config = user.list_item_configurations.create!(
    name: "simple list template"
  )
  simple_config.list_item_field_configurations.create!([
    { label: "content", data_type: "free_text", position: 1 },
    { label: "category", data_type: "free_text", position: 2 }
  ])

  [book_config, grocery_config, music_config, todo_config, simple_config]
end

# Create configurations for each user
foo_configs = create_list_item_configurations(foo)
bar_configs = create_list_item_configurations(bar)
baz_configs = create_list_item_configurations(baz)

# Create v1 lists (legacy system)
v1_lists = %w(BookList GroceryList MusicList ToDoList).map do |list_type|
  foos = List.create!(name: "foo - #{list_type} (v1)", owner: foo, type: list_type)
  bars = List.create!(name: "bar - #{list_type} (v1)", owner: bar, type: list_type)
  completed = List.create!(name: "completed - #{list_type} (v1)", owner: foo, type: list_type, completed: true)
  [foos, bars, completed]
end

# Create v2 lists (new system)
v2_lists = %w(BookList GroceryList MusicList ToDoList).map.with_index do |list_type, index|
  foos = List.create!(
    name: "foo - #{list_type} (v2)",
    owner: foo,
    type: list_type,
    list_item_configuration_id: foo_configs[index].id
  )
  bars = List.create!(
    name: "bar - #{list_type} (v2)",
    owner: bar,
    type: list_type,
    list_item_configuration_id: bar_configs[index].id
  )
  completed = List.create!(
    name: "completed - #{list_type} (v2)",
    owner: foo,
    type: list_type,
    completed: true,
    list_item_configuration_id: foo_configs[index].id
  )
  [foos, bars, completed]
end

# Create UsersList associations for v1 lists
v1_lists.each do |foos, bars, completed|
  UsersList.create!(user: foo, list: foos, has_accepted: true)
  UsersList.create!(user: bar, list: foos, has_accepted: true)
  UsersList.create!(user: baz, list: foos, has_accepted: true)
  UsersList.create!(user: foo, list: bars, has_accepted: nil)
  UsersList.create!(user: bar, list: bars, has_accepted: true)
  UsersList.create!(user: foo, list: completed, has_accepted: true)
end

# Create UsersList associations for v2 lists
v2_lists.each do |foos, bars, completed|
  UsersList.create!(user: foo, list: foos, has_accepted: true)
  UsersList.create!(user: bar, list: bars, has_accepted: true)
  UsersList.create!(user: foo, list: completed, has_accepted: true)
end

# Create v1 list items (legacy system)
item_names = %w(apples bananas oranges chocolate beer)

item_names.each do |item|
  GroceryListItem.create!(
    user: foo,
    list: v1_lists[1][0], # foo's grocery list
    product: item,
    quantity: "#{(1..10).to_a.sample} #{%w(bag bunch case).sample}"
  )
end

# Create v2 list items (new system)
def create_v2_list_items(list, user, field_configurations, sample_data)
  sample_data.each do |data|
    # Create the list item
    list_item = list.list_items.create!(user: user)

    # Create fields for the item
    data.each do |field_label, field_value|
      field_config = field_configurations.find { |fc| fc.label == field_label }
      if field_config
        list_item.list_item_fields.create!(
          user: user,
          data: field_value.to_s,
          list_item_field_configuration: field_config
        )
      end
    end
  end
end

# Sample data for different list types
book_sample_data = [
  { "author" => "J.R.R. Tolkien", "title" => "The Hobbit", "number_in_series" => "1", "category" => "Fantasy", "read" => "false" },
  { "author" => "George R.R. Martin", "title" => "A Game of Thrones", "number_in_series" => "1", "category" => "Fantasy", "read" => "true" },
  { "author" => "Patrick Rothfuss", "title" => "The Name of the Wind", "number_in_series" => "1", "category" => "Fantasy", "read" => "false" }
]

grocery_sample_data = [
  { "category" => "Fruits", "product" => "Apples", "quantity" => "6 bag", "purchased" => "false" },
  { "category" => "Fruits", "product" => "Bananas", "quantity" => "1 bunch", "purchased" => "false" },
  { "category" => "Dairy", "product" => "Milk", "quantity" => "1 gallon", "purchased" => "true" },
  { "category" => "Beverages", "product" => "Coffee", "quantity" => "1 bag", "purchased" => "false" }
]

music_sample_data = [
  { "title" => "Bohemian Rhapsody", "artist" => "Queen", "album" => "A Night at the Opera", "category" => "Rock", "purchased" => "false" },
  { "title" => "Hotel California", "artist" => "Eagles", "album" => "Hotel California", "category" => "Rock", "purchased" => "true" },
  { "title" => "Imagine", "artist" => "John Lennon", "album" => "Imagine", "category" => "Pop", "purchased" => "false" }
]

todo_sample_data = [
  { "task" => "Buy groceries", "assignee_id" => foo.id, "due_by" => "2024-12-25T18:00:00Z", "category" => "Shopping", "completed" => "false" },
  { "task" => "Call dentist", "assignee_id" => bar.id, "due_by" => "2024-12-20T17:00:00Z", "category" => "Health", "completed" => "true" },
  { "task" => "Review project proposal", "assignee_id" => foo.id, "due_by" => "2024-12-22T16:00:00Z", "category" => "Work", "completed" => "false" }
]

simple_sample_data = [
  { "content" => "Remember to water plants", "category" => "Home", "completed" => "false" },
  { "content" => "Pick up dry cleaning", "category" => "Errands", "completed" => "true" },
  { "content" => "Schedule oil change", "category" => "Car", "completed" => "false" }
]

# Create v2 list items for each user
create_v2_list_items(v2_lists[0][0], foo, foo_configs[0].list_item_field_configurations, book_sample_data)
create_v2_list_items(v2_lists[1][0], foo, foo_configs[1].list_item_field_configurations, grocery_sample_data)
create_v2_list_items(v2_lists[2][0], foo, foo_configs[2].list_item_field_configurations, music_sample_data)
create_v2_list_items(v2_lists[3][0], foo, foo_configs[3].list_item_field_configurations, todo_sample_data)

create_v2_list_items(v2_lists[0][1], bar, bar_configs[0].list_item_field_configurations, book_sample_data.reverse)
create_v2_list_items(v2_lists[1][1], bar, bar_configs[1].list_item_field_configurations, grocery_sample_data.reverse)
create_v2_list_items(v2_lists[2][1], bar, bar_configs[2].list_item_field_configurations, music_sample_data.reverse)
create_v2_list_items(v2_lists[3][1], bar, bar_configs[3].list_item_field_configurations, todo_sample_data.reverse)

# Update prev_id and next_id for all users
User.all.each do |user|
  pending = user.pending_lists
  incomplete = user.accepted_lists[:not_completed_lists]
  complete = user.all_completed_lists

  [pending, incomplete, complete].each do |lists|
    lists.each_with_index do |list, index|
      prev_id = index == 0 ? nil : lists[index - 1].users_list_id
      next_id = index == lists.count - 1 ? nil : lists[index + 1].users_list_id
      UsersList.find_by(user_id: user.id, list: list.id).update!(prev_id: prev_id, next_id: next_id)
    end
  end
end
