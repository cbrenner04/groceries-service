# frozen_string_literal: true

# == Schema Information
#
# Table name: book_list_items
#
#  id               :bigint           not null, primary key
#  archived_at      :datetime
#  author           :string
#  category         :string
#  number_in_series :integer
#  purchased        :boolean          default(FALSE), not null
#  read             :boolean          default(FALSE), not null
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  book_list_id     :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_book_list_items_on_book_list_id  (book_list_id)
#  index_book_list_items_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :book_list_item do
    user
    book_list
    author { "MyString" }
    title { "MyString" }
    purchased { false }
    read { false }
    archived_at { nil }
    number_in_series { 1 }
    category { "MyString" }
  end
end
