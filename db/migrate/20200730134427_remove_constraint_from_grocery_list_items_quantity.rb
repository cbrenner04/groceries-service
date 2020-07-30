class RemoveConstraintFromGroceryListItemsQuantity < ActiveRecord::Migration[6.0]
  def change
    change_column :grocery_list_items, :quantity, :string, null: true
    change_column_default :grocery_list_items, :quantity, nil
  end
end
