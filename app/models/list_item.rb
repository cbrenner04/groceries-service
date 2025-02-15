# frozen_string_literal: true

# comment
class ListItem < ApplicationRecord
  belongs_to :user
  belongs_to :list
  has_many :list_item_fields, dependent: :destroy
end
