# frozen_string_literal: true

FactoryBot.define do
  factory :list_item do
    archived_at { "2025-02-09 15:09:53" }
    user { user }
    list { list }
    completed { false }
    refreshed { false }
  end
end
