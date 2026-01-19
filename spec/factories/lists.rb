# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id          :uuid             not null, primary key
#  archived_at :datetime
#  completed   :boolean          default(FALSE), not null
#  name        :string           not null
#  refreshed   :boolean          default(FALSE), not null
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :uuid             not null
#
# Indexes
#
#  index_lists_on_created_at  (created_at)
#  index_lists_on_owner_id    (owner_id)
#
FactoryBot.define do
  factory :list do
    sequence(:name) { |n| "MyString#{n}" }
    owner factory: %i[user]
    type { "GroceryList" }
    list_item_configuration_id { nil }

    trait :book_list do
      type { "BookList" }
    end

    trait :grocery_list do
      type { "GroceryList" }
    end

    trait :music_list do
      type { "MusicList" }
    end

    trait :simple_list do
      type { "SimpleList" }
    end

    trait :to_do_list do
      type { "ToDoList" }
    end
  end
end
