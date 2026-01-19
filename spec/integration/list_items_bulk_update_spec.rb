# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/list_items/bulk_update", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  let(:list) { create(:list, owner: user) }
  let(:users_list) { create(:users_list, user: user, list: list) }

  let(:item) { create(:list_item, user: user, list: list, archived_at: nil) }
  let(:other_item) { create(:list_item, user: user, list: list, archived_at: nil) }
  let(:item_ids) { [item.id, other_item.id].join(",") }

  let(:list_item_configuration) { create(:list_item_configuration, user: user) }
  let(:first_list_item_field_configuration) do
    create(:list_item_field_configuration,
           list_item_configuration: list_item_configuration)
  end
  let(:second_list_item_field_configuration) do
    create(:list_item_field_configuration,
           list_item_configuration: list_item_configuration,
           label: "SecondLabel")
  end
  let!(:first_field) do
    create(:list_item_field, user: user, list_item: item,
                             list_item_field_configuration: first_list_item_field_configuration)
  end
  let!(:second_field) do
    create(:list_item_field, user: user, list_item: item,
                             list_item_field_configuration: second_list_item_field_configuration)
  end
  let!(:other_field) do
    create(:list_item_field, user: user, list_item: other_item,
                             list_item_field_configuration: first_list_item_field_configuration)
  end

  before do
    login user
    list.update!(list_item_configuration_id: list_item_configuration.id)
  end

  describe "GET /" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        get "#{list_list_items_bulk_update_path(list.id)}?item_ids=#{item_ids}", headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "when list does not exist" do
      it "responds with 403" do
        get "#{list_list_items_bulk_update_path('fake_id')}?item_ids=#{item_ids}", headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      context "when one item does not exist" do
        it "response with not found" do
          get "#{list_list_items_bulk_update_path(list.id)}?item_ids=#{[item.id, 'fake_id'].join(',')}",
              headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      context "when all items exist" do
        it "responds with 200 and correct body" do
          other_list = create(:list, owner: user, list_item_configuration_id: list_item_configuration.id)
          other_users_list = create(:users_list, user: user, list: other_list)
          # in order to get two list_users
          create(:users_list, user: other_user, list: list)

          get "#{list_list_items_bulk_update_path(list.id)}?item_ids=#{item_ids}", headers: auth_params

          response_body = JSON.parse(response.body).to_h

          expect(response).to have_http_status :success
          expect(response_body["list"]).to eq(
            "id" => list[:id],
            "name" => list[:name],
            "archived_at" => list[:archived_at],
            "completed" => list[:completed],
            "refreshed" => list[:refreshed],
            "type" => list[:type],
            "owner_id" => list[:owner_id],
            "created_at" => list[:created_at].iso8601(3),
            "updated_at" => list[:updated_at].iso8601(3),
            "list_item_configuration_id" => list_item_configuration.id
          )
          expect(response_body["lists"].count).to eq 2
          expect(response_body["lists"][0]).to eq(
            "id" => other_list[:id],
            "name" => other_list[:name],
            "completed" => other_list[:completed],
            "refreshed" => other_list[:refreshed],
            "type" => other_list[:type],
            "owner_id" => other_list[:owner_id],
            "created_at" => other_list[:created_at].iso8601(3),
            "has_accepted" => true,
            "user_id" => user.id,
            "users_list_id" => other_users_list.id,
            "list_item_configuration_id" => list_item_configuration.id
          )
          expect(response_body["list_users"].count).to eq 2
          expect(response_body["list_users"]).to eq [user.email, other_user.email]
          expect(response_body["items"].count).to eq 2
          expect(response_body["items"]).to eq(
            [
              {
                "id" => item[:id],
                "archived_at" => nil,
                "refreshed" => false,
                "completed" => false,
                "user_id" => user[:id],
                "list_id" => list[:id],
                "created_at" => item[:created_at].iso8601(3),
                "updated_at" => item[:updated_at].iso8601(3),
                "fields" => [
                  {
                    "id" => first_field[:id],
                    "list_item_field_configuration_id" => first_list_item_field_configuration[:id],
                    "data" => "MyString",
                    "archived_at" => nil,
                    "user_id" => user[:id],
                    "list_item_id" => item[:id],
                    "created_at" => first_field[:created_at].iso8601(3),
                    "updated_at" => first_field[:updated_at].iso8601(3),
                    "label" => "MyString"
                  },
                  {
                    "id" => second_field[:id],
                    "list_item_field_configuration_id" => second_list_item_field_configuration[:id],
                    "data" => "MyString",
                    "archived_at" => nil,
                    "user_id" => user[:id],
                    "list_item_id" => item[:id],
                    "created_at" => second_field[:created_at].iso8601(3),
                    "updated_at" => second_field[:updated_at].iso8601(3),
                    "label" => "SecondLabel"
                  }
                ]
              },
              {
                "id" => other_item[:id],
                "archived_at" => nil,
                "refreshed" => false,
                "completed" => false,
                "user_id" => user[:id],
                "list_id" => list[:id],
                "created_at" => other_item[:created_at].iso8601(3),
                "updated_at" => other_item[:updated_at].iso8601(3),
                "fields" => [
                  {
                    "id" => other_field[:id],
                    "list_item_field_configuration_id" => first_list_item_field_configuration[:id],
                    "data" => "MyString",
                    "archived_at" => nil,
                    "user_id" => user[:id],
                    "list_item_id" => other_item[:id],
                    "created_at" => other_field[:created_at].iso8601(3),
                    "updated_at" => other_field[:updated_at].iso8601(3),
                    "label" => "MyString"
                  }
                ]
              }
            ]
          )
        end
      end
    end
  end

  describe "PUT /" do
    update_params = {}
    before do
      update_params = {
        item_ids: [item[:id], other_item[:id]].join(","),
        list_id: list[:id],
        list_items: {
          copy: false,
          move: false,
          existing_list_id: list[:id],
          update_current_items: false,
          fields_to_update: [{
            label: "MyString",
            item_ids: [item[:id], other_item[:id]],
            data: "NewFieldData1"
          }, {
            label: "SecondLabel",
            item_ids: [item[:id]],
            data: "NewFieldData2"
          }]
        }
      }
    end

    describe "with read access" do
      before do
        users_list.update!(permissions: "read")
        update_params[:list_items][:copy] = true
      end

      it "responds with forbidden" do
        put list_list_items_bulk_update_path(list.id).to_s,
            headers: auth_params,
            params: update_params,
            as: :json

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      context "when one of the items does not exist" do
        it "responds with not found" do
          update_params[:list_items][:copy] = true
          update_params[:list_items][:new_list_name] = "bulk update list"
          put "#{list_list_items_bulk_update_path(list.id)}?item_ids=#{[item.id, 'fake_id'].join(',')}",
              headers: auth_params,
              params: update_params,
              as: :json

          expect(response).to have_http_status :not_found
          expect(response.body).to eq "One or more items were not found"
        end
      end

      context "when updating a field that doesn't exist on an item" do
        it "creates a new field for that item" do
          # Create an item without a specific field
          item_without_field = create(:list_item, user: user, list: list)
          # Don't create a field for second_list_item_field_configuration for this item

          update_params[:list_items][:update_current_items] = true
          update_params[:list_items][:fields_to_update] = [{
            label: "SecondLabel",
            item_ids: [item_without_field.id],
            data: "NewFieldData"
          }]

          expect do
            put list_list_items_bulk_update_path(list.id).to_s,
                headers: auth_params,
                params: update_params,
                as: :json
          end.to change(ListItemField, :count).by(1)

          new_field = item_without_field.list_item_fields.find_by(
            list_item_field_configuration: second_list_item_field_configuration
          )
          expect(new_field).to be_present
          expect(new_field.data).to eq "NewFieldData"
        end
      end

      context "when all items exist" do
        describe "with valid params" do
          context "when update current items is requested" do
            it "updates current items" do
              update_params[:list_items][:copy] = true
              update_params[:list_items][:update_current_items] = true

              expect(first_field.data).to eq "MyString"
              expect(other_field.data).to eq "MyString"
              expect(second_field.data).to eq "MyString"

              put list_list_items_bulk_update_path(list.id).to_s,
                  headers: auth_params,
                  params: update_params,
                  as: :json

              first_field.reload
              second_field.reload
              other_field.reload

              expect(response).to have_http_status :no_content
              expect(first_field.data).to eq "NewFieldData1"
              expect(other_field.data).to eq "NewFieldData1"
              expect(second_field.data).to eq "NewFieldData2"
            end

            it "clears fields when data is empty string" do
              update_params[:list_items][:update_current_items] = true
              update_params[:list_items][:fields_to_update] = [{
                label: "MyString",
                item_ids: [item[:id], other_item[:id]],
                data: "" # Empty data should clear the field
              }]

              expect(first_field.data).to eq "MyString"
              expect(other_field.data).to eq "MyString"

              put list_list_items_bulk_update_path(list.id).to_s,
                  headers: auth_params,
                  params: update_params,
                  as: :json

              # The fields should be destroyed when cleared
              expect { first_field.reload }.to raise_error(ActiveRecord::RecordNotFound)
              expect { other_field.reload }.to raise_error(ActiveRecord::RecordNotFound)

              expect(response).to have_http_status :no_content
            end
          end

          context "when update current items is not requested" do
            it "does not update current items" do
              update_params[:list_items][:copy] = true
              update_params[:list_items][:update_current_items] = false
              update_params[:list_items][:new_list_name] = "bulk update list"

              put "#{list_list_items_bulk_update_path(list.id)}?item_ids=#{item_ids}",
                  headers: auth_params,
                  params: update_params,
                  as: :json
              item.reload
              other_item.reload

              expect(response).to have_http_status :no_content
              expect(first_field.data).to eq "MyString"
              expect(other_field.data).to eq "MyString"
              expect(second_field.data).to eq "MyString"
            end
          end

          describe "when move is requested" do
            before { update_params[:list_items][:move] = true }

            describe "when new list is requested" do
              it "creates new list, new items, and archives current items" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                update_params[:list_items][:new_list_name] = "bulk update list"
                update_params[:list_items][:update_current_items] = false

                put list_list_items_bulk_update_path(list.id).to_s,
                    headers: auth_params,
                    params: update_params,
                    as: :json

                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update list")
                new_items = ListItem.where(list_id: new_list.id)

                expect(item.archived_at).to be_truthy
                expect(other_item.archived_at).to be_truthy
                expect(new_list).to be_truthy
                expect(new_items.count).to eq 2
                expect(new_items.first.list_item_fields.map(&:data)).to eq %w[NewFieldData1 NewFieldData2]
                expect(new_items.last.list_item_fields.map(&:data)).to eq ["NewFieldData1"]
              end
            end

            describe "when existing list is requested" do
              it "does not create list, creates new items, and archives current items" do
                other_list = create(:list, owner: user)
                create(:users_list, user: user, list: other_list)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                update_params[:list_items][:existing_list_id] = other_list.id

                put list_list_items_bulk_update_path(list.id).to_s,
                    headers: auth_params,
                    params: update_params,
                    as: :json

                item.reload
                other_item.reload
                new_items = ListItem.where(list_id: other_list.id)

                expect(item.archived_at).to be_truthy
                expect(other_item.archived_at).to be_truthy
                expect(new_items.count).to eq 2
                expect(new_items.first.list_item_fields.map(&:data)).to eq %w[NewFieldData1 NewFieldData2]
                expect(new_items.last.list_item_fields.map(&:data)).to eq ["NewFieldData1"]
              end
            end
          end

          describe "when copy is requested" do
            before { update_params[:list_items][:copy] = true }

            describe "when new list is requested" do
              it "does not archive items, creates new list and items" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(List.find_by(name: "new list")).to be_nil

                update_params[:list_items][:new_list_name] = "bulk update list"

                put list_list_items_bulk_update_path(list.id).to_s,
                    headers: auth_params,
                    params: update_params,
                    as: :json

                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update list")
                new_items = ListItem.where(list_id: new_list.id)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(new_list).to be_truthy
                expect(new_items.count).to eq 2
                expect(new_items.first.list_item_fields.map(&:data)).to eq %w[NewFieldData1 NewFieldData2]
                expect(new_items.last.list_item_fields.map(&:data)).to eq ["NewFieldData1"]
              end

              it "creates new items with original field data when fields_to_update is not provided" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                # Remove fields_to_update to test the uncovered line
                update_params[:list_items].delete(:fields_to_update)
                update_params[:list_items][:new_list_name] = "bulk update list no fields"

                put list_list_items_bulk_update_path(list.id).to_s,
                    headers: auth_params,
                    params: update_params,
                    as: :json

                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update list no fields")
                new_items = ListItem.where(list_id: new_list.id).includes(:list_item_fields)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(new_list).to be_truthy
                expect(new_items.count).to eq 2
                # Should use original field data when fields_to_update is not provided
                # Items are created in the order specified by item_ids: [item.id, other_item.id]
                # Find items by field count to avoid ordering issues
                item_with_two_fields = new_items.find { |i| i.list_item_fields.count == 2 }
                item_with_one_field = new_items.find { |i| i.list_item_fields.one? }
                expect(item_with_two_fields.list_item_fields.map(&:data)).to eq %w[MyString MyString]
                expect(item_with_one_field.list_item_fields.map(&:data)).to eq ["MyString"]
              end

              it "handles empty data in fields_to_update by preserving original field data" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                # Set one field to empty data and another to valid data
                update_params[:list_items][:fields_to_update] = [{
                  label: "MyString",
                  item_ids: [item[:id], other_item[:id]],
                  data: "" # Empty data
                }, {
                  label: "SecondLabel",
                  item_ids: [item[:id]],
                  data: "ValidData" # Valid data
                }]
                update_params[:list_items][:new_list_name] = "bulk update list empty data"

                put list_list_items_bulk_update_path(list.id).to_s,
                    headers: auth_params,
                    params: update_params,
                    as: :json

                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update list empty data")
                new_items = ListItem.where(list_id: new_list.id)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(new_list).to be_truthy
                expect(new_items.count).to eq 2

                # First item should have original data for "MyString" (since update was empty)
                # and "ValidData" for "SecondLabel"
                first_item_fields = new_items.first.list_item_fields
                expect(first_item_fields.find do |f|
                  f.list_item_field_configuration.label == "MyString"
                end.data).to eq "MyString"
                expect(first_item_fields.find do |f|
                  f.list_item_field_configuration.label == "SecondLabel"
                end.data).to eq "ValidData"

                # Second item should have original data for "MyString" (since update was empty)
                # and no "SecondLabel" field
                second_item_fields = new_items.last.list_item_fields
                expect(second_item_fields.find do |f|
                  f.list_item_field_configuration.label == "MyString"
                end.data).to eq "MyString"
                expect(second_item_fields.find { |f| f.list_item_field_configuration.label == "SecondLabel" }).to be_nil
              end
            end

            describe "when existing list is requested" do
              it "does not create list or archive items, creates new items" do
                other_list = create(:list, owner: user)
                create(:users_list, user: user, list: other_list)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                update_params[:list_items][:existing_list_id] = other_list.id

                put list_list_items_bulk_update_path(list.id).to_s,
                    headers: auth_params,
                    params: update_params,
                    as: :json

                item.reload
                other_item.reload
                new_items = ListItem.where(list_id: other_list.id)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(new_items.count).to eq 2
                field_data = new_items.map { |item| item.list_item_fields.map(&:data) }
                expect(field_data).to contain_exactly(%w[NewFieldData1 NewFieldData2], ["NewFieldData1"])
              end
            end
          end
        end

        describe "with invalid params" do
          it "returns unproccessable entity" do
            update_params[:list_items][:copy] = true
            update_params[:list_items][:existing_list_id] = nil

            put "#{list_list_items_bulk_update_path(list.id)}?item_ids=#{item_ids}",
                headers: auth_params,
                params: update_params,
                as: :json

            expect(response).to have_http_status :unprocessable_content
          end
        end
      end
    end
  end
end
