# frozen_string_literal: true

# model for list item field configurations which sets how data is added to list items
class ListItemFieldConfiguration < ApplicationRecord
  belongs_to :list_item_configuration
  has_many :list_item_fields, dependent: nil

  scope :not_archived, -> { where(archived_at: nil) }

  validates :label, presence: true
  validates :position, presence: true, numericality: { only_integer: true }
  validates :data_type,
            presence: true,
            inclusion: { in: %w[boolean date_time free_text number],
                         message: I18n.t("list_item_field_configuration_data_type_error") }
  validates :label, uniqueness: { scope: :list_item_configuration_id }

  # set position prior to validation on create in order to avoid validation errors
  before_validation :set_position, on: :create

  def archive
    update archived_at: Time.zone.now
  end

  private

  def set_position
    return if position.present?

    max_position = list_item_configuration.list_item_field_configurations.maximum(:position) || 0
    self.position = max_position + 1
  end
end
