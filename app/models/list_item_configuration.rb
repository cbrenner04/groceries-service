# frozen_string_literal: true

# model for configurations for list items
# connects lists and list item fields configurations which set how fields are added to items added to lists
class ListItemConfiguration < ApplicationRecord
  belongs_to :user
  has_many :list_item_field_configurations, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validate :at_least_one_primary_field

  def archive
    update archived_at: Time.zone.now
  end

  private

  def at_least_one_primary_field
    # Skip validation if no fields exist yet (fields are created after configuration)
    return if list_item_field_configurations.where(archived_at: nil).empty?
    # Skip validation if configuration is being archived (all fields will be archived)
    return if archived_at.present? || will_save_change_to_archived_at?
    # Validation passes if at least one field is primary
    return if list_item_field_configurations.where(archived_at: nil).any?(&:primary)

    errors.add(:base, I18n.t("list_item_configuration.requires_primary_field"))
  end
end
