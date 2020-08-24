# frozen_string_literal: true

# == Schema Information
#
# Table name: book_list_items
#
#  id               :uuid             not null, primary key
#  archived_at      :datetime
#  author           :string
#  category         :string
#  number_in_series :integer
#  purchased        :boolean          default(FALSE), not null
#  read             :boolean          default(FALSE), not null
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  list_id          :uuid             not null
#  user_id          :uuid             not null
#
# Indexes
#
#  index_book_list_items_on_created_at  (created_at)
#  index_book_list_items_on_list_id     (list_id)
#  index_book_list_items_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :book_list_item do
    user
    list { book_list }
    author { "MyString" }
    title { "MyString" }
    purchased { false }
    read { false }
    archived_at { nil }
    number_in_series { 1 }
    category { "MyString" }
  end
end
