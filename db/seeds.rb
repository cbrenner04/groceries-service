# frozen_string_literal: true

# Users are created with default configurations via after_create callback
user_emails = %w[foo@example.com bar@example.com baz@example.com]
foo, bar, baz = user_emails.map do |email|
  User.create!(
    email: email,
    password: "asdfasdf",
    password_confirmation: "asdfasdf",
    uid: email
  )
end

# Get configurations for each user (created via after_create callback)
def get_user_configs(user)
  [
    user.list_item_configurations.find_by(name: "book list template"),
    user.list_item_configurations.find_by(name: "grocery list template"),
    user.list_item_configurations.find_by(name: "music list template"),
    user.list_item_configurations.find_by(name: "to do list template"),
    user.list_item_configurations.find_by(name: "simple list with category template")
  ]
end

foo_configs = get_user_configs(foo)
bar_configs = get_user_configs(bar)

# Create lists using configurations
config_names = %w[book grocery music todo simple]
lists = config_names.map.with_index do |config_name, index|
  foos = List.create!(
    name: "foo - #{config_name} list",
    owner: foo,
    list_item_configuration_id: foo_configs[index].id
  )
  bars = List.create!(
    name: "bar - #{config_name} list",
    owner: bar,
    list_item_configuration_id: bar_configs[index].id
  )
  completed = List.create!(
    name: "completed - #{config_name} list",
    owner: foo,
    completed: true,
    list_item_configuration_id: foo_configs[index].id
  )
  [foos, bars, completed]
end

# Create UsersList associations for lists
lists.each do |foos, bars, completed|
  UsersList.create!(user: foo, list: foos, has_accepted: true)
  UsersList.create!(user: bar, list: bars, has_accepted: true)
  UsersList.create!(user: foo, list: completed, has_accepted: true)
end

# Create list items (new system)
def create_list_items(list, user, field_configurations, sample_data)
  sample_data.each do |data|
    # Create the list item
    list_item = list.list_items.create!(user: user)

    # Create fields for the item
    data.each do |field_label, field_value|
      field_config = field_configurations.find { |fc| fc.label == field_label }
      next unless field_config

      list_item.list_item_fields.create!(
        user: user,
        data: field_value.to_s,
        list_item_field_configuration: field_config
      )
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

# Create list items for each user
create_list_items(lists[0][0], foo, foo_configs[0].list_item_field_configurations, book_sample_data)
create_list_items(lists[1][0], foo, foo_configs[1].list_item_field_configurations, grocery_sample_data)
create_list_items(lists[2][0], foo, foo_configs[2].list_item_field_configurations, music_sample_data)
create_list_items(lists[3][0], foo, foo_configs[3].list_item_field_configurations, todo_sample_data)
create_list_items(lists[4][0], foo, foo_configs[4].list_item_field_configurations, simple_sample_data)

create_list_items(lists[0][1], bar, bar_configs[0].list_item_field_configurations, book_sample_data.reverse)
create_list_items(lists[1][1], bar, bar_configs[1].list_item_field_configurations, grocery_sample_data.reverse)
create_list_items(lists[2][1], bar, bar_configs[2].list_item_field_configurations, music_sample_data.reverse)
create_list_items(lists[3][1], bar, bar_configs[3].list_item_field_configurations, todo_sample_data.reverse)
create_list_items(lists[4][1], bar, bar_configs[4].list_item_field_configurations, simple_sample_data.reverse)

# Update prev_id and next_id for all users
User.find_each do |user|
  pending = user.pending_lists
  incomplete = user.accepted_lists[:not_completed_lists]
  complete = user.all_completed_lists

  [pending, incomplete, complete].each do |lists|
    lists.each_with_index do |list, index|
      prev_id = index.zero? ? nil : lists[index - 1].users_list_id
      next_id = index == lists.count - 1 ? nil : lists[index + 1].users_list_id
      UsersList.find_by(user_id: user.id, list: list.id).update!(prev_id: prev_id, next_id: next_id)
    end
  end
end
