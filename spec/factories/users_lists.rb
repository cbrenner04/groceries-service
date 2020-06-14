# frozen_string_literal: true

FactoryBot.define do
  factory :users_list do
    association :user
    association :list
    has_accepted { true }
  end
end
