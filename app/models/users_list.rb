# frozen_string_literal: true

# == Schema Information
#
# Table name: users_lists
#
#  id           :uuid             not null, primary key
#  has_accepted :boolean
#  permissions  :string           default("write"), not null
#  list_id      :uuid             not null
#  next_id      :uuid
#  prev_id      :uuid
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
class UsersList < ApplicationRecord
  belongs_to :user
  belongs_to :list

  enum permissions: { read: "read", write: "write" }

  validates :user, uniqueness: { scope: :list }

  scope :accepted, (-> { where(has_accepted: true) })
  scope :pending, (-> { where(has_accepted: nil) })
  scope :refused, (-> { where(has_accepted: false) })
end
