# frozen_string_literal: true

class MigrateCategoryData < ActiveRecord::Migration[8.1]
  GROCERY_DEFAULT_CATEGORIES = %w[Baking Bakery Beverages Canned\ Goods Condiments Dairy Deli Frozen Meat Produce
                                  Snacks].freeze

  def up
    puts "Migrating category data from list_item_fields to list_items.category"

    # Step 1: Copy category field data to list_items.category
    category_field_configs = ListItemFieldConfiguration.where(label: "category").where(archived_at: nil)
    category_field_configs.find_each do |config|
      ListItemField.where(list_item_field_configuration_id: config.id, archived_at: nil).find_each do |field|
        next if field.data.blank?

        field.list_item.update_column(:category, field.data)
      end
    end

    # Step 2: Create categories records from unique category values per list
    List.not_archived.find_each do |list|
      category_values = list.list_items.not_archived.where.not(category: [nil, ""]).pluck(:category).uniq

      # If this is a grocery list, union with default categories
      if list.list_item_configuration&.name == "grocery list template"
        category_values = (category_values + GROCERY_DEFAULT_CATEGORIES).uniq
      end

      category_values.each do |name|
        Category.find_or_create_by!(list: list, name: name)
      rescue ActiveRecord::RecordNotUnique
        # Handle race condition
        next
      end
    end

    # Step 3: Archive category field configurations and their fields
    category_field_configs.each do |config|
      config.list_item_fields.where(archived_at: nil).update_all(archived_at: Time.zone.now)
      config.update_column(:archived_at, Time.zone.now)
    end

    puts "Completed migrating category data"
  end

  def down
    puts "Reverting category data migration"

    # Step 1: Unarchive category field configurations and their fields
    category_field_configs = ListItemFieldConfiguration.where(label: "category").where.not(archived_at: nil)
    category_field_configs.each do |config|
      config.list_item_fields.where.not(archived_at: nil).update_all(archived_at: nil)
      config.update_column(:archived_at, nil)
    end

    # Step 2: Remove categories records
    Category.delete_all

    # Step 3: Clear the category column on list_items
    ListItem.update_all(category: nil)

    puts "Completed reverting category data migration"
  end
end
