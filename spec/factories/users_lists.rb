# frozen_string_literal: true

# == Schema Information
#
# Table name: users_lists
#
#  id           :uuid             not null, primary key
#  has_accepted :boolean
#  permissions  :string           default("write"), not null
#  list_id      :uuid             not null
#  user_id      :uuid             not null
#
# Indexes
#
#  index_users_lists_on_list_id              (list_id)
#  index_users_lists_on_list_id_and_user_id  (list_id,user_id) UNIQUE
#  index_users_lists_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :users_list do
    association :user
    association :list
    has_accepted { true }
  end
end
