# frozen_string_literal: true

FactoryBot.define do
  factory :music_list do
    sequence(:name) { |n| "MyString#{n}" }
    association :owner, factory: :user
    type { "MusicList" }
  end
end
