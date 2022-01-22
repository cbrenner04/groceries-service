# frozen_string_literal: true

# == Schema Information
#
# Table name: to_do_list_items
#
#  id          :uuid             not null, primary key
#  archived_at :datetime
#  category    :string
#  completed   :boolean          default(FALSE), not null
#  due_by      :datetime
#  refreshed   :boolean          default(FALSE), not null
#  task        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  assignee_id :uuid
#  list_id     :uuid             not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_to_do_list_items_on_assignee_id  (assignee_id)
#  index_to_do_list_items_on_created_at   (created_at)
#  index_to_do_list_items_on_list_id      (list_id)
#  index_to_do_list_items_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (list_id => lists.id)
#  fk_rails_...  (user_id => users.id)
#
class ToDoListItem < ApplicationRecord
  belongs_to :user
  belongs_to :list, class_name: "ToDoList", inverse_of: :to_do_list_items

  scope :not_completed, (-> { where(completed: false) })
  scope :completed, (-> { where(completed: true) })
  scope :not_archived, (-> { where(archived_at: nil) })
  scope :not_refreshed, (-> { where(refreshed: false) })
  scope :refreshed, (-> { where(refreshed: true) })

  validates :task, presence: true
  validates :completed, inclusion: { in: [true, false] }

  def self.ordered
    all.order(due_by: :asc, assignee_id: :asc, task: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
