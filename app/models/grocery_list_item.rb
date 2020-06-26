# frozen_string_literal: true

# == Schema Information
#
# Table name: grocery_list_items
#
#  id              :bigint           not null, primary key
#  archived_at     :datetime
#  category        :string
#  product         :string           not null
#  purchased       :boolean          default(FALSE), not null
#  quantity        :string
#  refreshed       :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  grocery_list_id :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_grocery_list_items_on_grocery_list_id  (grocery_list_id)
#  index_grocery_list_items_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (grocery_list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
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
