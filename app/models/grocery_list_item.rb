# frozen_string_literal: true

# no doc
class GroceryListItem < ApplicationRecord
  belongs_to :user
  belongs_to :grocery_list

  scope :not_purchased, (-> { where(purchased: false) })
  scope :purchased, (-> { where(purchased: true) })
  scope :not_archived, (-> { where(archived_at: nil) })
  scope :not_refreshed, (-> { where(refreshed: false) })
  scope :refreshed, (-> { where(refreshed: true) })

  validates :user, :grocery_list, :product, presence: true
  validates :purchased, inclusion: { in: [true, false] }

  def self.ordered
    all.order(product: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
