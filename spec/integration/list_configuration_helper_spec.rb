# frozen_string_literal: true

require "rails_helper"

describe "ListConfigurationHelper", type: :request do
  # Create user without callbacks to test configuration creation in isolation
  let(:user) { User.create!(email: "test@example.com", password: "password123") }

  before { login user }

  describe "create_all_default_configurations" do
    it "creates all 5 default templates for a user" do
      # Clear any configurations created by callbacks
      user.list_item_configurations.destroy_all

      expect do
        ListConfigurationHelper.create_all_default_configurations(user)
      end.to change(ListItemConfiguration, :count).by(5)

      configurations = user.list_item_configurations.reload
      config_names = configurations.pluck(:name).sort
      expect(config_names).to eq([
                                   "book list template",
                                   "grocery list template",
                                   "music list template",
                                   "simple list with category template",
                                   "to do list template"
                                 ])
    end

    it "creates correct field configurations for grocery template" do
      user.list_item_configurations.destroy_all
      ListConfigurationHelper.create_all_default_configurations(user)

      config = user.list_item_configurations.find_by(name: "grocery list template")
      fields = config.list_item_field_configurations.order(:position)

      expect(fields.count).to eq(3)
      expect(fields[0]).to have_attributes(label: "product", data_type: "free_text", position: 1, primary: true)
      expect(fields[1]).to have_attributes(label: "quantity", data_type: "free_text", position: 2, primary: false)
      expect(fields[2]).to have_attributes(label: "category", data_type: "free_text", position: 3, primary: false)
    end

    it "creates correct field configurations for book template" do
      user.list_item_configurations.destroy_all
      ListConfigurationHelper.create_all_default_configurations(user)

      config = user.list_item_configurations.find_by(name: "book list template")
      fields = config.list_item_field_configurations.order(:position)

      expect(fields.count).to eq(5)
      expect(fields[0]).to have_attributes(label: "title", data_type: "free_text", position: 1, primary: true)
      expect(fields[1]).to have_attributes(label: "author", data_type: "free_text", position: 2, primary: false)
      expect(fields[2]).to have_attributes(label: "number_in_series", data_type: "number", position: 3, primary: false)
      expect(fields[3]).to have_attributes(label: "read", data_type: "boolean", position: 4, primary: false)
      expect(fields[4]).to have_attributes(label: "category", data_type: "free_text", position: 5, primary: false)
    end

    it "creates correct field configurations for music template" do
      user.list_item_configurations.destroy_all
      ListConfigurationHelper.create_all_default_configurations(user)

      config = user.list_item_configurations.find_by(name: "music list template")
      fields = config.list_item_field_configurations.order(:position)

      expect(fields.count).to eq(4)
      expect(fields[0]).to have_attributes(label: "title", data_type: "free_text", position: 1, primary: true)
      expect(fields[1]).to have_attributes(label: "artist", data_type: "free_text", position: 2, primary: false)
      expect(fields[2]).to have_attributes(label: "album", data_type: "free_text", position: 3, primary: false)
      expect(fields[3]).to have_attributes(label: "category", data_type: "free_text", position: 4, primary: false)
    end

    it "creates correct field configurations for to do template" do
      user.list_item_configurations.destroy_all
      ListConfigurationHelper.create_all_default_configurations(user)

      config = user.list_item_configurations.find_by(name: "to do list template")
      fields = config.list_item_field_configurations.order(:position)

      expect(fields.count).to eq(4)
      expect(fields[0]).to have_attributes(label: "task", data_type: "free_text", position: 1, primary: true)
      expect(fields[1]).to have_attributes(label: "assignee", data_type: "free_text", position: 2, primary: false)
      expect(fields[2]).to have_attributes(label: "due_by", data_type: "date_time", position: 3, primary: false)
      expect(fields[3]).to have_attributes(label: "category", data_type: "free_text", position: 4, primary: false)
    end

    it "creates correct field configurations for simple template" do
      user.list_item_configurations.destroy_all
      ListConfigurationHelper.create_all_default_configurations(user)

      config = user.list_item_configurations.find_by(name: "simple list with category template")
      fields = config.list_item_field_configurations.order(:position)

      expect(fields.count).to eq(2)
      expect(fields[0]).to have_attributes(label: "content", data_type: "free_text", position: 1, primary: true)
      expect(fields[1]).to have_attributes(label: "category", data_type: "free_text", position: 2, primary: false)
    end

    it "is idempotent - does not duplicate configurations" do
      user.list_item_configurations.destroy_all
      ListConfigurationHelper.create_all_default_configurations(user)

      expect do
        ListConfigurationHelper.create_all_default_configurations(user)
      end.not_to change(ListItemConfiguration, :count)
    end
  end

  describe "create_configuration_by_name" do
    before { user.list_item_configurations.destroy_all }

    it "creates a single configuration by name" do
      expect do
        ListConfigurationHelper.create_configuration_by_name(user, "book list template")
      end.to change(ListItemConfiguration, :count).by(1)

      config = user.list_item_configurations.find_by(name: "book list template")
      expect(config).to be_present
      expect(config.list_item_field_configurations.count).to eq(5)
    end

    it "returns existing configuration without creating duplicates" do
      config1 = ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")

      expect do
        config2 = ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")
        expect(config2.id).to eq(config1.id)
      end.not_to change(ListItemConfiguration, :count)
    end

    it "returns nil for unknown template names" do
      config = ListConfigurationHelper.create_configuration_by_name(user, "unknown template")
      expect(config).to be_present
      expect(config.list_item_field_configurations.count).to eq(0)
    end
  end

  describe "create_field_config_if_missing" do
    before { user.list_item_configurations.destroy_all }

    it "updates existing field config when data_type differs" do
      config = ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")
      field = config.list_item_field_configurations.find_by(label: "product")

      # Manually change the data_type to simulate a mismatch
      field.update!(data_type: "number")
      expect(field.reload.data_type).to eq("number")

      # Re-run configuration creation - should update the field
      ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")

      expect(field.reload.data_type).to eq("free_text")
    end

    it "updates existing field config when position differs" do
      config = ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")
      field = config.list_item_field_configurations.find_by(label: "product")

      # Manually change the position to simulate a mismatch
      field.update!(position: 99)
      expect(field.reload.position).to eq(99)

      # Re-run configuration creation - should update the field
      ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")

      expect(field.reload.position).to eq(1)
    end

    it "updates existing field config when primary differs" do
      config = ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")
      field = config.list_item_field_configurations.find_by(label: "product")

      # Manually change the primary to simulate a mismatch
      field.update!(primary: false)
      expect(field.reload.primary).to be(false)

      # Re-run configuration creation - should update the field
      ListConfigurationHelper.create_configuration_by_name(user, "grocery list template")

      expect(field.reload.primary).to be(true)
    end

    it "handles race condition when create fails with RecordInvalid" do
      config = user.list_item_configurations.create!(name: "test config")

      # Create a field that will be found by the rescue block
      existing_field = config.list_item_field_configurations.create!(
        label: "new_field", data_type: "number", position: 99
      )

      field_def = { label: "new_field", data_type: "free_text", position: 1, primary: false }

      # Stub find_by to return nil first (simulating race), then return the existing field
      call_count = 0
      allow(config.list_item_field_configurations).to receive(:find_by).with(label: "new_field") do
        call_count += 1
        call_count == 1 ? nil : existing_field
      end

      # Stub create! to raise RecordInvalid, simulating a race condition where
      # another process created the record between our find_by and create!
      allow(config.list_item_field_configurations).to receive(:create!)
        .and_raise(ActiveRecord::RecordInvalid.new(ListItemFieldConfiguration.new))

      allow(Rails.logger).to receive(:warn)

      # This should not raise, thanks to the rescue block
      expect do
        ListConfigurationHelper.send(:create_field_config_if_missing, config, field_def)
      end.not_to raise_error

      expect(Rails.logger).to have_received(:warn).with(/Failed to create field config/)

      # The rescue block should have updated the existing field
      expect(existing_field.reload.data_type).to eq("free_text")
      expect(existing_field.position).to eq(1)
    end
  end

  describe "TEMPLATE_DEFINITIONS constant" do
    it "defines all 5 expected templates" do
      expect(ListConfigurationHelper::TEMPLATE_DEFINITIONS.keys).to contain_exactly(
        "grocery list template",
        "book list template",
        "music list template",
        "to do list template",
        "simple list with category template"
      )
    end
  end

  describe "user after_create callback" do
    it "creates default configurations when a new user is created" do
      new_user = User.create!(email: "new@example.com", password: "password123")

      expect(new_user.list_item_configurations.count).to eq(5)
      config_names = new_user.list_item_configurations.pluck(:name).sort
      expect(config_names).to eq([
                                   "book list template",
                                   "grocery list template",
                                   "music list template",
                                   "simple list with category template",
                                   "to do list template"
                                 ])
    end
  end

  describe "integration with list creation" do
    it "creates list with existing configuration" do
      config = user.list_item_configurations.find_by(name: "book list template")

      list_params = { name: "Test List", list_item_configuration_id: config.id }

      expect do
        new_list = ListsService.build_new_list(list_params, user)
        new_list.save!
      end.not_to change(ListItemConfiguration, :count)

      new_list = List.last
      expect(new_list.list_item_configuration.name).to eq("book list template")
    end

    it "raises error when creating list without configuration" do
      expect do
        ListsService.build_new_list({ name: "Test List" }, user)
      end.to raise_error(ArgumentError, "list_item_configuration_id required")
    end

    it "uses same configuration for multiple lists" do
      config = user.list_item_configurations.find_by(name: "grocery list template")

      list1 = ListsService.build_new_list({ name: "List 1", list_item_configuration_id: config.id }, user)
      list1.save!

      list2 = ListsService.build_new_list({ name: "List 2", list_item_configuration_id: config.id }, user)
      list2.save!

      expect(list1.list_item_configuration_id).to eq(list2.list_item_configuration_id)
    end
  end
end
