user_emails = %w(foo@ex.co bar@ex.co baz@ex.co)
foo, bar, baz = user_emails.map do |email|
  User.create!(
    email: email,
    password: 'asdfasdf',
    password_confirmation: 'asdfasdf',
    uid: email
  )
end

lists = %w(BookList GroceryList MusicList ToDoList).map do |list_type|
  foos = List.create!(name: "foo - #{list_type}", owner: foo, type: list_type)
  bars = List.create!(name: "bar - #{list_type}", owner: bar, type: list_type)
  completed = List.create!(
    name: "completed - #{list_type}",
    owner: foo,
    type: list_type,
    completed: true
  )
  [foos, bars, completed]
end

lists.each do |foos, bars, completed|
  UsersList.create!(
    user: foo,
    list: foos,
    has_accepted: true
  )
  UsersList.create!(
    user: bar,
    list: foos,
    has_accepted: true
  )
  UsersList.create!(
    user: baz,
    list: foos,
    has_accepted: true
  )
  UsersList.create!(
    user: foo,
    list: bars,
    has_accepted: true
  )
  UsersList.create!(
    user: bar,
    list: bars,
    has_accepted: true
  )
  UsersList.create!(
    user: foo,
    list: completed,
    has_accepted: true
  )
end

item_names = %w(apples bananas oranges chocolate beer)

item_names.each do |item|
  GroceryListItem.create!(
    user: foo,
    grocery_list: lists[1][0],
    product: item,
    quantity: "#{(1..10).to_a.sample} #{%w(bag bunch case).sample}"
  )
end
