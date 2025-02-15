# frozen_string_literal: true

# comment
class ListItemConfiguration < ApplicationRecord
  belongs_to :list
  has_many :list_item_configuration_field, dependent: :destroy
end
