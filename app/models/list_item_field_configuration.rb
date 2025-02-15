# frozen_string_literal: true

# comment
class ListItemFieldConfiguration < ApplicationRecord
  belongs_to :list_item_configuration
  has_many :list_item_fields, dependent: nil

  validates :label, presence: true
  validates :data_type, inclusion: { in: %w[boolean date_time free_text number] }
end
