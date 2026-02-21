# frozen_string_literal: true

# Seeds default categories for grocery lists
class DefaultCategorySeeder
  class << self
    def seed(list)
      return unless list.list_item_configuration&.name == "grocery list template"

      ListConfigurationHelper::GROCERY_DEFAULT_CATEGORIES.each do |name|
        list.categories.find_or_create_by!(name: name)
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end
end
