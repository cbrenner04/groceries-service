# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id          :uuid             not null, primary key
#  archived_at :datetime
#  completed   :boolean          default(FALSE), not null
#  name        :string           not null
#  refreshed   :boolean          default(FALSE), not null
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :uuid             not null
#
# Indexes
#
#  index_lists_on_created_at  (created_at)
#  index_lists_on_owner_id    (owner_id)
#
class List < ApplicationRecord
  has_many :users_lists, dependent: :destroy
  has_many :users, through: :users_lists, source: :user, dependent: :destroy
  belongs_to :owner, class_name: "User", inverse_of: :lists
  has_many :list_items, dependent: :destroy

  scope :descending, -> { order(created_at: :desc) }
  scope :not_archived, -> { where(archived_at: nil) }
  scope :not_refreshed, -> { where(refreshed: false) }

  validates :name, presence: true

  def archive
    update archived_at: Time.zone.now
  end

  def as_json(options = {})
    super(options.merge(methods: :type))
  end

  def list_item_configuration
    ListItemConfiguration.find(list_item_configuration_id)
  end
end
