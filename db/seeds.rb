user_emails = %w(foo@example.com bar@example.com baz@example.com)
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
  completed = List.create!( name: "completed - #{list_type}", owner: foo, type: list_type, completed: true)
  [foos, bars, completed]
end

lists.each do |foos, bars, completed|
  UsersList.create!( user: foo, list: foos, has_accepted: true)
  UsersList.create!( user: bar, list: foos, has_accepted: true)
  UsersList.create!( user: baz, list: foos, has_accepted: true)
  UsersList.create!( user: foo, list: bars, has_accepted: nil)
  UsersList.create!( user: bar, list: bars, has_accepted: true)
  UsersList.create!( user: foo, list: completed, has_accepted: true)
end

item_names = %w(apples bananas oranges chocolate beer)

item_names.each do |item|
  GroceryListItem.create!(
    user: foo,
    list: lists[1][0],
    product: item,
    quantity: "#{(1..10).to_a.sample} #{%w(bag bunch case).sample}"
  )
end

User.all.each do |user|
  pending = user.pending_lists
  incomplete = user.accepted_lists[:not_completed_lists]
  complete = user.all_completed_lists

  [pending, incomplete, complete].each do |lists|
    lists.each_with_index do |list, index|
      before = index == 0 ? nil : lists[index - 1].id
      after = index == lists.count - 1 ? nil : lists[index + 1].id
      UsersList.find_by(user_id: user.id, list: list.id).update!(before_id: before, after_id: after)
    end
  end
end
