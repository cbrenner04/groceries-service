# frozen_string_literal: true

# comment
class ListItemConfiguration < ApplicationRecord
  belongs_to :user
  has_many :list_item_field_configuration, dependent: :destroy

  scope :public_configs, -> { where(allow_other_users_to_view: true) }

  validates :name, presence: true, uniqueness: true
  validates :allow_other_users_to_view, presence: true
end
