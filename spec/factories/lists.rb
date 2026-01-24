# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id                         :uuid             not null, primary key
#  archived_at                :datetime
#  completed                  :boolean          default(FALSE), not null
#  name                       :string           not null
#  refreshed                  :boolean          default(FALSE), not null
#  list_item_configuration_id :uuid
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  owner_id                   :uuid             not null
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

    # Use owner's grocery list template by default
    after(:build) do |list|
      if list.list_item_configuration_id.nil? && list.owner
        config = list.owner.list_item_configurations.find_by(name: "grocery list template")
        list.list_item_configuration_id = config&.id
      end
    end

    trait :book_list do
      after(:build) do |list|
        config = list.owner.list_item_configurations.find_by(name: "book list template")
        list.list_item_configuration_id = config&.id
      end
    end

    trait :grocery_list do
      after(:build) do |list|
        config = list.owner.list_item_configurations.find_by(name: "grocery list template")
        list.list_item_configuration_id = config&.id
      end
    end

    trait :music_list do
      after(:build) do |list|
        config = list.owner.list_item_configurations.find_by(name: "music list template")
        list.list_item_configuration_id = config&.id
      end
    end

    trait :simple_list do
      after(:build) do |list|
        config = list.owner.list_item_configurations.find_by(name: "simple list with category template")
        list.list_item_configuration_id = config&.id
      end
    end

    trait :to_do_list do
      after(:build) do |list|
        config = list.owner.list_item_configurations.find_by(name: "to do list template")
        list.list_item_configuration_id = config&.id
      end
    end
  end
end
