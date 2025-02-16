# frozen_string_literal: true

# comment
class ListItem < ApplicationRecord
  belongs_to :user
  belongs_to :list
  has_many :list_item_fields, dependent: :destroy

  scope :not_completed, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }
  scope :not_archived, -> { where(archived_at: nil) }
  scope :not_refreshed, -> { where(refreshed: false) }
  scope :refreshed, -> { where(refreshed: true) }

  # TODO: currently `ordered` is different based on the item configuration. do we continue this?
  def self.ordered
    order(created_at: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
