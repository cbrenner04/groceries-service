user_emails = %w(foo@ex.co bar@ex.co baz@ex.co)
user_emails.each do |email|
  User.create!(
    email: email,
    password: 'asdfasdf',
    password_confirmation: 'asdfasdf',
    uid: email
  )
end

GroceryList.create!(name: 'foobar', owner: User.find_by(email: 'foo@ex.co'))
GroceryList.create!(name: 'foobaz', owner: User.find_by(email: 'bar@ex.co'))

UsersList.create!(
  user: User.find_by(email: 'foo@ex.co'),
  list: List.find_by(name: 'foobar'),
  has_accepted: true
)

UsersList.create!(
  user: User.find_by(email: 'bar@ex.co'),
  list: List.find_by(name: 'foobar'),
  has_accepted: true
)

UsersList.create!(
  user: User.find_by(email: 'baz@ex.co'),
  list: List.find_by(name: 'foobar'),
  has_accepted: true
)

UsersList.create!(
  user: User.find_by(email: 'foo@ex.co'),
  list: List.find_by(name: 'foobaz'),
  has_accepted: true
)

UsersList.create!(
  user: User.find_by(email: 'bar@ex.co'),
  list: List.find_by(name: 'foobaz'),
  has_accepted: true
)

item_names = %w(apples bananas oranges chocolate beer)

item_names.each do |item|
  GroceryListItem.create!(
    user: User.find_by(email: 'foo@ex.co'),
    grocery_list: GroceryList.find_by(name: 'foobar'),
    product: item,
    quantity: "#{(1..10).to_a.sample} #{%w(bag bunch case).sample}"
  )
end
