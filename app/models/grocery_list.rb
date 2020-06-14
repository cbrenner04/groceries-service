# frozen_string_literal: true

# no doc
class GroceryList < List
  has_many :grocery_list_items, dependent: :destroy

  def categories
    grocery_list_items.map(&:category).concat(
      [
        "alcohol", "baby", "bakery", "baking", "beverages",
        "canned goods & soups", "cereal", "cleaning supplies", "condiments",
        "dairy", "deli", "flowers", "frozen foods", "grains, pasta & sides",
        "health & beauty", "international", "meat & seafood", "paper products",
        "pet", "pharmacy", "produce", "snacks", "spices"
      ]
    ).uniq.compact.reject(&:empty?).sort
  end
end
