# frozen_string_literal: true

# model for configurations for list items
# connects lists and list item fields configurations which set how fields are added to items added to lists
class ListItemConfiguration < ApplicationRecord
  belongs_to :user
  has_many :list_item_field_configurations, dependent: :destroy

  scope :public_configs, -> { where(allow_other_users_to_view: true) }

  validates :name, presence: true, uniqueness: true

  def archive
    update archived_at: Time.zone.now
  end
end
