# frozen_string_literal: true

# comment
class ListItemField < ApplicationRecord
  belongs_to :list_item_field_configuration
  belongs_to :user
  belongs_to :list_item

  validates :data, presence: true

  def archive
    update archived_at: Time.zone.now
  end
end
