# frozen_string_literal: true

require "rails_helper"

describe "v2/lists/merge_lists", type: :request do
  let(:user) { create(:user_with_lists) }

  before { login user }

  describe "POST /" do
    it "creates a new list, users_list, and adds new items to the list" do
      list_item_config = user.list_item_configurations.create!(name: "foo")
      list_item_field_config = list_item_config
                               .list_item_field_configurations.create!(label: "foo",
                                                                       data_type: "free_text", position: 1)
      first_list = List.create!(name: "FirstList", owner: user, completed: true,
                                list_item_configuration_id: list_item_config.id)
      second_list = List.create!(name: "SecondList", owner: user, completed: true,
                                 list_item_configuration_id: list_item_config.id)
      first_list_item = ListItem.create!(user: user, list: first_list)
      first_list_item.list_item_fields.create!(user: user, data: "foo",
                                               list_item_field_configuration: list_item_field_config)
      second_list_item = ListItem.create!(user: user, list: second_list)
      second_list_item.list_item_fields.create!(user: user, data: "bar",
                                                list_item_field_configuration: list_item_field_config)
      expect do
        post v2_merge_lists_path,
             params: { merge_lists: { list_ids: "#{first_list.id},#{second_list.id}", new_list_name: "foobar" } },
             headers: auth_params
      end.to change(List, :count).by(1).and change(ListItem, :count).by(2).and change(UsersList, :count).by(1)
    end
  end
end
