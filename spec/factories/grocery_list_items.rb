# frozen_string_literal: true

# == Schema Information
#
# Table name: grocery_list_items
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  category    :string
#  product     :string           not null
#  purchased   :boolean          default(FALSE), not null
#  quantity    :string
#  refreshed   :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  list_id     :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_grocery_list_items_on_list_id  (list_id)
#  index_grocery_list_items_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :grocery_list_item do
    user
    list { grocery_list }
    product { "MyString" }
    quantity { 1 }
    purchased { false }
    category { "MyString" }
  end
end
