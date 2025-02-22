# frozen_string_literal: true

FactoryBot.define do
  factory :list_item_field_configuration do
    label { "MyString" }
    data_type { "free_text" }
    archived_at { "2025-02-09 15:04:05" }
    list_item_configuration factory: %i[list_item_configuration]
  end
end
