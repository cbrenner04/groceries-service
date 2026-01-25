# frozen_string_literal: true

class SetPrimaryOnExistingFieldConfigurations < ActiveRecord::Migration[8.1]
  # Map template names to their primary field labels (matching ListConfigurationHelper::TEMPLATE_DEFINITIONS)
  TEMPLATE_PRIMARY_FIELDS = {
    "grocery list template" => "product",
    "book list template" => "title",
    "music list template" => "title",
    "to do list template" => "task",
    "simple list with category template" => "content"
  }.freeze

  def up
    puts "Setting primary: true on fields matching template definitions"

    ListItemConfiguration.find_each do |config|
      next if config.list_item_field_configurations.any?(&:primary)

      primary_field_label = TEMPLATE_PRIMARY_FIELDS[config.name]

      if primary_field_label
        # For known templates, set primary on the matching field
        primary_field = config.list_item_field_configurations.find_by(label: primary_field_label)
        if primary_field
          primary_field.update_column(:primary, true)
        else
          puts "Warning: Template '#{config.name}' missing expected primary field '#{primary_field_label}' (ID: #{config.id})"
        end
      else
        # For custom configurations, use first non-category field as fallback
        first_non_category_field = config.list_item_field_configurations
                                         .where.not(label: 'category')
                                         .order(:position)
                                         .first
        if first_non_category_field
          first_non_category_field.update_column(:primary, true)
        else
          puts "Warning: Configuration '#{config.name}' has no non-category fields (ID: #{config.id})"
        end
      end
    end

    puts "Completed setting primary fields"
  end

  def down
    puts "Migration cannot be safely reverted - primary fields will remain set"
  end
end
