# frozen_string_literal: true

# comment
class ListItem < ApplicationRecord
  belongs_to :user
  belongs_to :list
  has_many :list_item_fields, dependent: :destroy
  accepts_nested_attributes_for :list_item_fields

  scope :not_completed, -> { where(completed: false) }
  scope :completed, -> { where(completed: true).where(refreshed: false) }
  scope :not_archived, -> { where(archived_at: nil) }
  scope :not_refreshed, -> { where(refreshed: false) }
  scope :refreshed, -> { where(refreshed: true) }

  # this is kind of weird but without it you'll get a 500 and an error from the database if `nil` is supplied
  validates :completed, inclusion: { in: [true, false] }, allow_nil: false
  validates :refreshed, inclusion: { in: [true, false] }, allow_nil: false

  # TODO: currently `ordered` is different based on the item configuration. do we continue this?
  def self.ordered
    order(created_at: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
