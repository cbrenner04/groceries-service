# frozen_string_literal: true

FactoryBot.define do
  factory :to_do_list do
    sequence(:name) { |n| "MyString#{n}" }
    association :owner, factory: :user
    type { "ToDoList" }
  end
end
