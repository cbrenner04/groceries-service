# frozen_string_literal: true

# == Schema Information
#
# Table name: lists
#
#  id          :uuid             not null, primary key
#  archived_at :datetime
#  completed   :boolean          default(FALSE), not null
#  name        :string           not null
#  refreshed   :boolean          default(FALSE), not null
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :uuid             not null
#
# Indexes
#
#  index_lists_on_created_at  (created_at)
#  index_lists_on_owner_id    (owner_id)
#
class GroceryList < List
  has_many :grocery_list_items, foreign_key: "list_id", class_name: "GroceryListItem", inverse_of: :list,
                                dependent: :destroy

  def categories
    grocery_list_items.map(&:category).concat(
      [
        "alcohol", "baby", "bakery", "baking", "beverages", "canned goods & soups", "cereal", "cleaning supplies",
        "condiments", "dairy", "deli", "flowers", "frozen foods", "grains, pasta & sides", "health & beauty",
        "international", "meat & seafood", "paper products", "pet", "pharmacy", "produce", "snacks", "spices"
      ]
    ).uniq.compact.reject(&:empty?).sort
  end
end
