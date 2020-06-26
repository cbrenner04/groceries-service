# frozen_string_literal: true

# == Schema Information
#
# Table name: users_lists
#
#  id           :bigint           not null, primary key
#  has_accepted :boolean
#  permissions  :string           default("write"), not null
#  list_id      :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_users_lists_on_list_id              (list_id)
#  index_users_lists_on_user_id              (user_id)
#  index_users_lists_on_user_id_and_list_id  (user_id,list_id) UNIQUE
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
