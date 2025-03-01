# frozen_string_literal: true

FactoryBot.define do
  factory :list_item_field do
    list_item_field_configuration { list_item_field_configuration }
    data { "MyString" }
    archived_at { nil }
    user { user }
    list_item { list_item }
  end
end
