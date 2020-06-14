# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "foo#{n}@bar.com" }
    password { "foobar!" }
    password_confirmation { "foobar!" }

    factory :user_with_lists do
      transient do
        lists_count { 5 }
      end

      after(:create) do |user, evaluator|
        create_list(:users_list, evaluator.lists_count, user: user)
      end
    end
  end
end
