# frozen_string_literal: true

FactoryBot.define do
  factory :grocery_list do
    sequence(:name) { |n| "MyString#{n}" }
    association :owner, factory: :user
    type { "GroceryList" }
  end
end
