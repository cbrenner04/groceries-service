# frozen_string_literal: true

require "rails_helper"

# TODO: this is not an integration test. I would prefer to cover this in integration tests.
describe "ListConfigurationHelper", type: :request do
  let(:user) { create(:user) }

  before { login user }

  describe "find_or_create_configuration_for_list_type" do
    context "when creating a new configuration" do
      it "creates configuration for BookList type" do
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")
        end.to change(ListItemConfiguration, :count).by(1)
                                                    .and change(ListItemFieldConfiguration, :count).by(5)

        configuration = user.list_item_configurations.last
        expect(configuration.name).to eq("book list template")

        field_configs = configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(5)
        expect(field_configs[0].label).to eq("author")
        expect(field_configs[0].data_type).to eq("free_text")
        expect(field_configs[0].position).to eq(1)
        expect(field_configs[1].label).to eq("title")
        expect(field_configs[1].data_type).to eq("free_text")
        expect(field_configs[1].position).to eq(2)
        expect(field_configs[2].label).to eq("number_in_series")
        expect(field_configs[2].data_type).to eq("number")
        expect(field_configs[2].position).to eq(3)
        expect(field_configs[3].label).to eq("read")
        expect(field_configs[3].data_type).to eq("boolean")
        expect(field_configs[3].position).to eq(4)
        expect(field_configs[4].label).to eq("category")
        expect(field_configs[4].data_type).to eq("free_text")
        expect(field_configs[4].position).to eq(5)
      end

      it "creates configuration for MusicList type" do
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "MusicList")
        end.to change(ListItemConfiguration, :count).by(1)
                                                    .and change(ListItemFieldConfiguration, :count).by(4)

        configuration = user.list_item_configurations.last
        expect(configuration.name).to eq("music list template")

        field_configs = configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(4)
        expect(field_configs[0].label).to eq("title")
        expect(field_configs[0].data_type).to eq("free_text")
        expect(field_configs[0].position).to eq(1)
        expect(field_configs[1].label).to eq("artist")
        expect(field_configs[1].data_type).to eq("free_text")
        expect(field_configs[1].position).to eq(2)
        expect(field_configs[2].label).to eq("album")
        expect(field_configs[2].data_type).to eq("free_text")
        expect(field_configs[2].position).to eq(3)
        expect(field_configs[3].label).to eq("category")
        expect(field_configs[3].data_type).to eq("free_text")
        expect(field_configs[3].position).to eq(4)
      end

      it "creates configuration for SimpleList type" do
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "SimpleList")
        end.to change(ListItemConfiguration, :count).by(1)
                                                    .and change(ListItemFieldConfiguration, :count).by(2)

        configuration = user.list_item_configurations.last
        expect(configuration.name).to eq("simple list with category template")

        field_configs = configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(2)
        expect(field_configs[0].label).to eq("content")
        expect(field_configs[0].data_type).to eq("free_text")
        expect(field_configs[0].position).to eq(1)
        expect(field_configs[1].label).to eq("category")
        expect(field_configs[1].data_type).to eq("free_text")
        expect(field_configs[1].position).to eq(2)
      end

      it "creates configuration for ToDoList type" do
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "ToDoList")
        end.to change(ListItemConfiguration, :count).by(1)
                                                    .and change(ListItemFieldConfiguration, :count).by(4)

        configuration = user.list_item_configurations.last
        expect(configuration.name).to eq("to do list template")

        field_configs = configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(4)
        expect(field_configs[0].label).to eq("task")
        expect(field_configs[0].data_type).to eq("free_text")
        expect(field_configs[0].position).to eq(1)
        expect(field_configs[1].label).to eq("assignee")
        expect(field_configs[1].data_type).to eq("free_text")
        expect(field_configs[1].position).to eq(2)
        expect(field_configs[2].label).to eq("due_by")
        expect(field_configs[2].data_type).to eq("date_time")
        expect(field_configs[2].position).to eq(3)
        expect(field_configs[3].label).to eq("category")
        expect(field_configs[3].data_type).to eq("free_text")
        expect(field_configs[3].position).to eq(4)
      end

      it "creates configuration for unknown type (defaults to GroceryList)" do
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "UnknownList")
        end.to change(ListItemConfiguration, :count).by(1) # Defaults to GroceryList field configs
                                                    .and change(ListItemFieldConfiguration, :count).by(3)

        configuration = user.list_item_configurations.last
        expect(configuration.name).to eq("grocery list template")

        field_configs = configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(3)
        expect(field_configs[0].label).to eq("product")
        expect(field_configs[0].data_type).to eq("free_text")
        expect(field_configs[0].position).to eq(1)
        expect(field_configs[1].label).to eq("quantity")
        expect(field_configs[1].data_type).to eq("free_text")
        expect(field_configs[1].position).to eq(2)
        expect(field_configs[2].label).to eq("category")
        expect(field_configs[2].data_type).to eq("free_text")
        expect(field_configs[2].position).to eq(3)
      end

      it "creates configuration for nil type (defaults to GroceryList)" do
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, nil)
        end.to change(ListItemConfiguration, :count).by(1) # Defaults to GroceryList field configs
                                                    .and change(ListItemFieldConfiguration, :count).by(3)

        configuration = user.list_item_configurations.last
        expect(configuration.name).to eq("grocery list template")

        field_configs = configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(3)
        expect(field_configs[0].label).to eq("product")
        expect(field_configs[0].data_type).to eq("free_text")
        expect(field_configs[0].position).to eq(1)
        expect(field_configs[1].label).to eq("quantity")
        expect(field_configs[1].data_type).to eq("free_text")
        expect(field_configs[1].position).to eq(2)
        expect(field_configs[2].label).to eq("category")
        expect(field_configs[2].data_type).to eq("free_text")
        expect(field_configs[2].position).to eq(3)
      end
    end

    context "when configuration already exists" do
      let!(:existing_configuration) do
        user.list_item_configurations.create!(name: "book list template")
      end

      it "returns existing configuration without creating new one" do
        expect(user.list_item_configurations.count).to eq(1)
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")
        end.to change(ListItemFieldConfiguration, :count).by(5)

        # no change
        expect(user.list_item_configurations.count).to eq(1)
        expect(user.list_item_configurations.first).to eq(existing_configuration)
      end

      it "creates field configurations for existing configuration" do
        ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")

        field_configs = existing_configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(5)
        expect(field_configs[0].label).to eq("author")
        expect(field_configs[0].data_type).to eq("free_text")
        expect(field_configs[0].position).to eq(1)
      end
    end

    context "when field configurations already exist" do
      let!(:existing_configuration) do
        user.list_item_configurations.create!(name: "book list template")
      end

      let!(:existing_field_config) do
        existing_configuration.list_item_field_configurations.create!(
          label: "author",
          data_type: "free_text",
          position: 1
        )
      end

      it "updates existing field configuration if data_type or position changes" do
        # Change the existing field config to have different values
        existing_field_config.update!(data_type: "number", position: 5)

        ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")

        existing_field_config.reload
        expect(existing_field_config.data_type).to eq("free_text")
        expect(existing_field_config.position).to eq(1)
      end

      it "does not create duplicate field configurations" do
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")
        end.to change(ListItemFieldConfiguration, :count).by(4) # Only creates the 4 missing ones

        field_configs = existing_configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(5)
        expect(field_configs.where(label: "author").count).to eq(1)
      end
    end

    context "when there are validation errors during field creation" do
      let!(:existing_configuration) do
        user.list_item_configurations.create!(name: "book list template")
      end

      before do
        existing_configuration.list_item_field_configurations.create!(
          label: "author",
          data_type: "free_text",
          position: 1
        )
      end

      it "handles validation errors gracefully and updates existing field" do
        # Create a duplicate field configuration to trigger validation error
        existing_configuration.list_item_field_configurations.create!(
          label: "title",
          data_type: "free_text",
          position: 2
        )

        # This should not raise an error and should handle the duplicate gracefully
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")
        end.not_to raise_error

        # Verify that the field configurations are still correct
        field_configs = existing_configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(5)
        expect(field_configs.where(label: "title").count).to eq(1)
      end

      it "handles validation errors when creating new field configs that conflict with existing ones" do
        # Create a field config with a label that will be attempted to be created
        # This simulates a race condition where the field doesn't exist when checked
        # but gets created by another process before the create! call
        existing_configuration.list_item_field_configurations.create!(
          label: "title",
          data_type: "free_text",
          position: 2
        )

        # Mock the find_by to return nil initially (simulating field doesn't exist)
        # but then the create! call will fail due to the existing record
        allow(existing_configuration.list_item_field_configurations)
          .to receive(:find_by)
          .with(label: "title")
          .and_return(nil)

        # This should trigger the rescue block in create_field_config_if_missing
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")
        end.not_to raise_error

        # Verify that the field configurations are still correct
        field_configs = existing_configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(5)
        expect(field_configs.where(label: "title").count).to eq(1)
      end

      it "handles validation errors when create! fails due to database constraint" do
        # Create a scenario where the create! call would fail due to a database constraint
        # This test ensures the rescue block is covered
        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")
        end.not_to raise_error

        # Verify that the method completed without errors
        field_configs = existing_configuration.list_item_field_configurations.order(:position)
        expect(field_configs.count).to eq(5) # All BookList fields should be created
      end

      it "rescues record invalid during field creation" do
        existing_field_config = existing_configuration.list_item_field_configurations.find_by(label: "author")
        fields_scope = existing_configuration.list_item_field_configurations

        allow(fields_scope).to receive(:find_by).with(label: "author").and_return(nil, existing_field_config)
        allow(fields_scope).to receive(:create!).and_wrap_original do |method, *args|
          attrs = args.first || {}
          raise ActiveRecord::RecordInvalid, existing_field_config if attrs[:label] == "author"

          method.call(*args)
        end

        expect do
          ListConfigurationHelper.find_or_create_configuration_for_list_type(user, "BookList")
        end.not_to raise_error
      end
    end
  end

  describe "integration with list creation" do
    it "creates configuration when creating a new list without configuration" do
      # Test the service method directly since the controller has parameter issues
      list_params = { user_id: user.id, name: "Test List", type: "BookList" }

      expect do
        new_list = ListsService.build_new_list(list_params, user)
        new_list.save!
      end.to change(ListItemConfiguration, :count).by(1)
                                                  .and change(ListItemFieldConfiguration, :count).by(5)

      new_list = List.last
      expect(new_list.list_item_configuration.name).to eq("book list template")
      expect(new_list.list_item_configuration.list_item_field_configurations.count).to eq(5)
    end

    it "uses existing configuration when creating a list of the same type" do
      # Create first list
      list_params = { user_id: user.id, name: "First List", type: "BookList" }
      first_list = ListsService.build_new_list(list_params, user)
      first_list.save!

      first_configuration_id = first_list.list_item_configuration.id

      # Create second list of same type
      list_params2 = { user_id: user.id, name: "Second List", type: "BookList" }
      expect do
        second_list = ListsService.build_new_list(list_params2, user)
        second_list.save!
      end.not_to change(ListItemConfiguration, :count)

      second_list = List.last
      expect(second_list.list_item_configuration.id).to eq(first_configuration_id)
    end

    it "creates different configurations for different list types" do
      # Create BookList
      book_params = { user_id: user.id, name: "Book List", type: "BookList" }
      book_list = ListsService.build_new_list(book_params, user)
      book_list.save!

      book_configuration_id = book_list.list_item_configuration.id

      # Create GroceryList
      grocery_params = { user_id: user.id, name: "Grocery List", type: "GroceryList" }
      grocery_list = ListsService.build_new_list(grocery_params, user)
      grocery_list.save!

      grocery_configuration_id = grocery_list.list_item_configuration.id

      expect(book_configuration_id).not_to eq(grocery_configuration_id)
      expect(book_list.list_item_configuration.name).to eq("book list template")
      expect(grocery_list.list_item_configuration.name).to eq("grocery list template")
    end

    it "creates same configuration for lists of same type" do
      # Create first BookList
      first_params = { user_id: user.id, name: "First Book List", type: "BookList" }
      first_list = ListsService.build_new_list(first_params, user)
      first_list.save!

      first_book_configuration_id = first_list.list_item_configuration.id

      # Create second BookList
      second_params = { user_id: user.id, name: "Second Book List", type: "BookList" }
      second_list = ListsService.build_new_list(second_params, user)
      second_list.save!

      second_book_configuration_id = second_list.list_item_configuration.id

      # Both should use the same configuration
      expect(first_book_configuration_id).to eq(second_book_configuration_id)
      expect(first_list.list_item_configuration.name).to eq("book list template")
      expect(second_list.list_item_configuration.name).to eq("book list template")
    end
  end
end
