# frozen_string_literal: true

# Helper module for managing list item configurations
module V2::ListConfigurationHelper
  class << self
    def find_or_create_configuration_for_list_type(user, list_type)
      configuration_name = configuration_name_for_list_type(list_type)
      configuration = user.list_item_configurations.find_or_create_by!(name: configuration_name)

      create_field_configurations_for_list_type(configuration, list_type)
      configuration
    end

    private

    def configuration_name_for_list_type(list_type)
      case list_type
      when "BookList"
        "book list template"
      when "MusicList"
        "music list template"
      when "SimpleList"
        "simple list with category template"
      when "ToDoList"
        "to do list template"
      else # "GroceryList" or default
        "grocery list template" # default fallback
      end
    end

    # This is for parity with the v1 lists and list items
    # rubocop:disable Metrics/MethodLength
    def create_field_configurations_for_list_type(configuration, list_type)
      case list_type
      when "BookList"
        create_field_config_if_missing(configuration, "author", "free_text", 1)
        create_field_config_if_missing(configuration, "title", "free_text", 2)
        create_field_config_if_missing(configuration, "number_in_series", "number", 3)
        create_field_config_if_missing(configuration, "read", "boolean", 4)
        create_field_config_if_missing(configuration, "category", "free_text", 5)
      when "MusicList"
        create_field_config_if_missing(configuration, "title", "free_text", 1)
        create_field_config_if_missing(configuration, "artist", "free_text", 2)
        create_field_config_if_missing(configuration, "album", "free_text", 3)
        create_field_config_if_missing(configuration, "category", "free_text", 4)
      when "SimpleList"
        create_field_config_if_missing(configuration, "content", "free_text", 1)
        create_field_config_if_missing(configuration, "category", "free_text", 2)
      when "ToDoList"
        create_field_config_if_missing(configuration, "task", "free_text", 1)
        create_field_config_if_missing(configuration, "assignee", "free_text", 2)
        create_field_config_if_missing(configuration, "due_by", "date_time", 3)
        create_field_config_if_missing(configuration, "category", "free_text", 4)
      else # Default to GroceryList field configurations
        create_field_config_if_missing(configuration, "product", "free_text", 1)
        # this is how the quantity field is used in the v1 grocery list
        create_field_config_if_missing(configuration, "quantity", "free_text", 2)
        create_field_config_if_missing(configuration, "category", "free_text", 3)
      end
    end
    # rubocop:enable Metrics/MethodLength

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
    # :nocov:
    rescue ActiveRecord::RecordInvalid => e
      # If there's a validation error (like duplicate), try to find and update the existing one
      Rails.logger.warn "Failed to create field config #{label}: #{e.message}"
      existing_config = configuration.list_item_field_configurations.find_by(label: label)
      existing_config&.update!(data_type: data_type, position: position)
    end
    # :nocov:
  end
end
