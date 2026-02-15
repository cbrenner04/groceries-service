# frozen_string_literal: true

class AddCategoryToListItems < ActiveRecord::Migration[8.1]
  def change
    add_column :list_items, :category, :string
  end
end
