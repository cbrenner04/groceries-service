# frozen_string_literal: true

FactoryBot.define do
  factory :music_list_item do
    user
    music_list
    title { "MyString" }
    artist { "MyString" }
    album { "MyString" }
    purchased { false }
    archived_at { nil }
    category { "MyString" }
  end
end
