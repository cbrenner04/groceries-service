# frozen_string_literal: true

# no doc
class ToDoListItem < ApplicationRecord
  belongs_to :user
  belongs_to :to_do_list

  scope :not_completed, (-> { where(completed: false) })
  scope :completed, (-> { where(completed: true) })
  scope :not_archived, (-> { where(archived_at: nil) })
  scope :not_refreshed, (-> { where(refreshed: false) })
  scope :refreshed, (-> { where(refreshed: true) })

  validates :user, :to_do_list, :task, presence: true
  validates :completed, inclusion: { in: [true, false] }

  def self.ordered
    all.order(due_by: :asc, assignee_id: :asc, task: :asc)
  end

  def archive
    update archived_at: Time.zone.now
  end
end
