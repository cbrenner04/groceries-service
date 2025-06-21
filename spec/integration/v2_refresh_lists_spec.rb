# frozen_string_literal: true

require "rails_helper"

describe "/v2/lists/:list_id/refresh_list", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  before { login user }

  describe "POST /" do
    context "when list does not exist" do
      it "responds with 404" do
        post v2_list_refresh_list_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    context "when list does exist" do
      context "when user is not owner" do
        it "responds with forbidden" do
          post v2_list_refresh_list_path(list.id), headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      context "when user is owner" do
        it "creates new list and items" do
          list_item_config = user.list_item_configurations.create!(name: "foo")
          list_item_field_config = list_item_config
                                   .list_item_field_configurations.create!(label: "foo", data_type: "free_text", position: 1)
          list = List.create!(name: "NewList", owner: user, completed: true,
                              list_item_configuration_id: list_item_config.id)
          list_item = ListItem.create!(user: user, list: list)
          list_item.list_item_fields.create!(user: user, data: "foo",
                                             list_item_field_configuration: list_item_field_config)

          expect do
            post v2_list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by(1).and change(ListItem, :count).by(1)
          new_list_item_field = ListItem.last.list_item_fields.first
          expect(new_list_item_field[:data]).to eq "foo"
        end
      end
    end
  end
end
