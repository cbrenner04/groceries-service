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
# Join model for Users and Lists
class UsersList < ApplicationRecord
  belongs_to :user
  belongs_to :list

  enum permissions: { read: "read", write: "write" }

  validates :user, :list, presence: true
  validates :user, uniqueness: { scope: :list }

  scope :accepted, (-> { where(has_accepted: true) })
  scope :pending, (-> { where(has_accepted: nil) })
  scope :refused, (-> { where(has_accepted: false) })
end
