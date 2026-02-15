# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.uuid :list_id, null: false
      t.string :name, null: false
      t.timestamps
    end

    add_index :categories, [:list_id, :name], unique: true
    add_index :categories, :list_id
    add_foreign_key :categories, :lists
  end
end
