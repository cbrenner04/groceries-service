# frozen_string_literal: true

FactoryBot.define do
  factory :list_item_field do
    list_item_configuration_field { nil }
    data { "MyString" }
    archived_at { "2025-02-09 15:14:01" }
    user { nil }
    list_item { nil }
  end
end
