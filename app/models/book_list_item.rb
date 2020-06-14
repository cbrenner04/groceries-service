# frozen_string_literal: true

# no doc
class BookListItem < ApplicationRecord
  belongs_to :user
  belongs_to :book_list

  scope :not_purchased, (-> { where(purchased: false) })
  scope :purchased, (-> { where(purchased: true) })
  scope :not_read, (-> { where(read: false) })
  scope :read, (-> { where(read: true) })
  scope :not_archived, (-> { where(archived_at: nil) })

  validates :user, :book_list, presence: true
  validates :author, presence: true, if: proc { |item| item.title.blank? }
  validates :title, presence: true, if: proc { |item| item.author.blank? }
  validates :read, inclusion: { in: [true, false] }
  validates :purchased, inclusion: { in: [true, false] }

  def self.ordered
    all.order(author: :asc, number_in_series: :asc, title: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
