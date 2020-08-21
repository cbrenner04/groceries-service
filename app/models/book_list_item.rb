# frozen_string_literal: true

# == Schema Information
#
# Table name: book_list_items
#
#  id               :bigint           not null, primary key
#  archived_at      :datetime
#  author           :string
#  category         :string
#  number_in_series :integer
#  purchased        :boolean          default(FALSE), not null
#  read             :boolean          default(FALSE), not null
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  list_id          :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_book_list_items_on_list_id  (list_id)
#  index_book_list_items_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
class BookListItem < ApplicationRecord
  belongs_to :user
  belongs_to :list, class_name: "BookList", inverse_of: :book_list_items

  scope :not_purchased, (-> { where(purchased: false) })
  scope :purchased, (-> { where(purchased: true) })
  scope :not_read, (-> { where(read: false) })
  scope :read, (-> { where(read: true) })
  scope :not_archived, (-> { where(archived_at: nil) })

  validates :user, :list, presence: true
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
