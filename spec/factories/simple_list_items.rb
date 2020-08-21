# frozen_string_literal: true

# == Schema Information
#
# Table name: simple_list_items
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  category    :string
#  completed   :boolean          default(FALSE), not null
#  content     :string           not null
#  refreshed   :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  list_id     :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_simple_list_items_on_list_id  (list_id)
#  index_simple_list_items_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :simple_list_item do
    user
    list { simple_list }
    content { "MyString" }
    completed { false }
    refreshed { false }
    archived_at { nil }
    category { "MyString" }
  end
end
