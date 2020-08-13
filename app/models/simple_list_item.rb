# frozen_string_literal: true

# == Schema Information
#
# Table name: simple_list_items
#
#  id             :bigint           not null, primary key
#  archived_at    :datetime
#  category       :string
#  completed      :boolean          default(FALSE), not null
#  content        :string           not null
#  refreshed      :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  simple_list_id :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_simple_list_items_on_simple_list_id  (simple_list_id)
#  index_simple_list_items_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (simple_list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
class SimpleListItem < ApplicationRecord
  belongs_to :user
  belongs_to :simple_list

  scope :not_completed, (-> { where(completed: false) })
  scope :completed, (-> { where(completed: true) })
  scope :not_archived, (-> { where(archived_at: nil) })
  scope :not_refreshed, (-> { where(refreshed: false) })
  scope :refreshed, (-> { where(refreshed: true) })

  validates :user, :simple_list, :content, presence: true
  validates :completed, :refreshed, inclusion: { in: [true, false] }

  def self.ordered
    all.order(created_at: :asc, content: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
