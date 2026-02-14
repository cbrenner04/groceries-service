# frozen_string_literal: true

# == Schema Information
#
# Table name: categories
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  list_id    :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_categories_on_list_id  (list_id)
#  index_categories_on_name     (name) UNIQUE
#
class Category < ApplicationRecord
  belongs_to :list

  validates :name, presence: true, uniqueness: { scope: :list_id }
end
