# frozen_string_literal: true

# Helper module for managing list item configurations
module ListConfigurationHelper
  TEMPLATE_DEFINITIONS = {
    "grocery list template" => [
      { label: "product", data_type: "free_text", position: 1 },
      { label: "quantity", data_type: "free_text", position: 2 },
      { label: "category", data_type: "free_text", position: 3 }
    ],
    "book list template" => [
      { label: "author", data_type: "free_text", position: 1 },
      { label: "title", data_type: "free_text", position: 2 },
      { label: "number_in_series", data_type: "number", position: 3 },
      { label: "read", data_type: "boolean", position: 4 },
      { label: "category", data_type: "free_text", position: 5 }
    ],
    "music list template" => [
      { label: "title", data_type: "free_text", position: 1 },
      { label: "artist", data_type: "free_text", position: 2 },
      { label: "album", data_type: "free_text", position: 3 },
      { label: "category", data_type: "free_text", position: 4 }
    ],
    "to do list template" => [
      { label: "task", data_type: "free_text", position: 1 },
      { label: "assignee", data_type: "free_text", position: 2 },
      { label: "due_by", data_type: "date_time", position: 3 },
      { label: "category", data_type: "free_text", position: 4 }
    ],
    "simple list with category template" => [
      { label: "content", data_type: "free_text", position: 1 },
      { label: "category", data_type: "free_text", position: 2 }
    ]
  }.freeze

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
        create_field_config_if_missing(configuration, field_def[:label], field_def[:data_type], field_def[:position])
      end
    end

    def create_field_config_if_missing(configuration, label, data_type, position)
      # First, try to find an existing field config with this label
      existing_config = configuration.list_item_field_configurations.find_by(label: label)

      if existing_config
        # Update the existing config if needed
        if existing_config.data_type != data_type || existing_config.position != position
          existing_config.update!(data_type: data_type,
                                  position: position)
        end
      else
        # Create a new one if it doesn't exist
        configuration.list_item_field_configurations.create!(label: label, data_type: data_type, position: position)
      end
    rescue ActiveRecord::RecordInvalid => e
      # If there's a validation error (like duplicate), try to find and update the existing one
      Rails.logger.warn "Failed to create field config #{label}: #{e.message}"
      existing_config = configuration.list_item_field_configurations.find_by(label: label)
      existing_config&.update!(data_type: data_type, position: position)
    end
  end
end
