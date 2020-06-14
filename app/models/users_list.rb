# frozen_string_literal: true

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
