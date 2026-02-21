# frozen_string_literal: true

# Helper module for managing list item configurations
module ListConfigurationHelper
  TEMPLATE_DEFINITIONS = {
    "grocery list template" => [
      { label: "product", data_type: "free_text", position: 1, primary: true },
      { label: "quantity", data_type: "free_text", position: 2 }
    ],
    "book list template" => [
      { label: "title", data_type: "free_text", position: 1, primary: true },
      { label: "author", data_type: "free_text", position: 2 },
      { label: "number in series", data_type: "number", position: 3 },
      { label: "read", data_type: "boolean", position: 4 }
    ],
    "music list template" => [
      { label: "title", data_type: "free_text", position: 1, primary: true },
      { label: "artist", data_type: "free_text", position: 2 },
      { label: "album", data_type: "free_text", position: 3 }
    ],
    "to do list template" => [
      { label: "task", data_type: "free_text", position: 1, primary: true },
      { label: "assignee", data_type: "free_text", position: 2 },
      { label: "due by", data_type: "date_time", position: 3 }
    ],
    "simple list with category template" => [
      { label: "content", data_type: "free_text", position: 1, primary: true }
    ]
  }.freeze

  GROCERY_DEFAULT_CATEGORIES = ["Baking", "Bakery", "Canned Goods", "Condiments", "Dairy", "Deli",
                                "Frozen", "Meat & Seafood", "Produce", "Snacks"].freeze

  class << self
    def create_all_default_configurations(user)
      TEMPLATE_DEFINITIONS.each_key do |template_name|
        create_configuration_by_name(user, template_name)
      end
    end

    def create_configuration_by_name(user, template_name)
      configuration = user.list_item_configurations.find_or_create_by!(name: template_name)
      create_field_configurations(configuration, template_name)
      configuration
    end

    private

    def create_field_configurations(configuration, template_name)
      field_definitions = TEMPLATE_DEFINITIONS[template_name]
      return unless field_definitions

      field_definitions.each do |field_def|
        create_field_config_if_missing(configuration, field_def)
      end
    end

    def create_field_config_if_missing(configuration, field_def)
      attrs = normalized_field_attrs(field_def)
      existing = configuration.list_item_field_configurations.find_by(label: attrs[:label])

      existing ? update_if_changed(existing, attrs) : create_field_config(configuration, attrs)
    rescue ActiveRecord::RecordInvalid => e
      handle_race_condition(configuration, attrs, e)
    end

    def normalized_field_attrs(field_def)
      { label: field_def[:label], data_type: field_def[:data_type],
        position: field_def[:position], primary: field_def[:primary] || false }
    end

    def update_if_changed(existing, attrs)
      return if existing.data_type == attrs[:data_type] &&
                existing.position == attrs[:position] &&
                existing.primary == attrs[:primary]

      existing.update!(attrs.except(:label))
    end

    def create_field_config(configuration, attrs)
      configuration.list_item_field_configurations.create!(attrs)
    end

    def handle_race_condition(configuration, attrs, error)
      Rails.logger.warn "Failed to create field config #{attrs[:label]}: #{error.message}"
      existing = configuration.list_item_field_configurations.find_by(label: attrs[:label])
      existing&.update!(attrs.except(:label))
    end
  end
end
