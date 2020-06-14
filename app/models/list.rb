# frozen_string_literal: true

# no doc
class List < ApplicationRecord
  include ListsService

  has_many :users_lists, dependent: :destroy
  has_many :users, through: :users_lists, source: :user, dependent: :destroy
  belongs_to :owner, class_name: "User", inverse_of: :lists

  scope :descending, (-> { order(created_at: :desc) })
  scope :not_archived, (-> { where(archived_at: nil) })
  scope :not_refreshed, (-> { where(refreshed: false) })

  validates :name, presence: true

  def archive
    update archived_at: Time.zone.now
  end

  def as_json(options = {})
    super(options.merge(methods: :type))
  end
end
