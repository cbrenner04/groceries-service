# frozen_string_literal: true

FactoryBot.define do
  factory :list_item_configuration do
    user { user }
    name { "MyString" }
    allow_other_users_to_view { false }
  end
end
