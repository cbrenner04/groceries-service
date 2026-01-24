# frozen_string_literal: true

class MoveQuantityToFirstPositionInGroceryTemplate < ActiveRecord::Migration[8.0]
  def up
    puts "Moving quantity to first position in grocery list template"

    User.find_each do |user|
      grocery_config = user.list_item_configurations.find_by(name: "grocery list template")
      next unless grocery_config

      quantity_field = grocery_config.list_item_field_configurations.find_by(label: "quantity")
      product_field = grocery_config.list_item_field_configurations.find_by(label: "product")
      category_field = grocery_config.list_item_field_configurations.find_by(label: "category")

      if quantity_field && product_field && category_field
        # Update positions: quantity -> 1, product -> 2, category stays at 3
        quantity_field.update_column(:position, 1)
        product_field.update_column(:position, 2)
        category_field.update_column(:position, 3) if category_field.position != 3
      end
    end

    puts "Completed moving quantity to first position"
  end

  def down
    puts "Reverting quantity position in grocery list template"

    User.find_each do |user|
      grocery_config = user.list_item_configurations.find_by(name: "grocery list template")
      next unless grocery_config

      quantity_field = grocery_config.list_item_field_configurations.find_by(label: "quantity")
      product_field = grocery_config.list_item_field_configurations.find_by(label: "product")
      category_field = grocery_config.list_item_field_configurations.find_by(label: "category")

      if quantity_field && product_field && category_field
        # Revert: product -> 1, quantity -> 2, category stays at 3
        product_field.update_column(:position, 1)
        quantity_field.update_column(:position, 2)
        category_field.update_column(:position, 3) if category_field.position != 3
      end
    end

    puts "Completed reverting quantity position"
  end
end
