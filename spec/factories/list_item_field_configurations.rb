# frozen_string_literal: true

FactoryBot.define do
  factory :list_item_field_configuration do
    label { "MyString" }
    data_type { "free_text" }
    position { 1 }
    primary { false }
    archived_at { nil }
    list_item_configuration factory: %i[list_item_configuration]
  end
end
