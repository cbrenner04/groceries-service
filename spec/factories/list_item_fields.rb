# frozen_string_literal: true

FactoryBot.define do
  factory :list_item_field do
    list_item_field_configuration { list_item_field_configuration }
    data { "MyString" }
    archived_at { "2025-02-09 15:14:01" }
    user { user }
    list_item { list_item }
  end
end
