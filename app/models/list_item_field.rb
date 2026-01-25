# frozen_string_literal: true

# comment
class ListItemField < ApplicationRecord
  belongs_to :list_item_field_configuration
  belongs_to :user
  belongs_to :list_item

  validates :data, presence: true

  scope :not_archived, -> { where(archived_at: nil) }

  def archive
    update archived_at: Time.zone.now
  end

  def as_json(options = {})
    super.merge(
      label: list_item_field_configuration.label,
      position: list_item_field_configuration.position,
      data_type: list_item_field_configuration.data_type,
      primary: list_item_field_configuration.primary
    )
  end
end
