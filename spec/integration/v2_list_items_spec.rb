# frozen_string_literal: true

require "rails_helper"

describe "/v2/lists/:list_id/list_items", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  let(:list_item_configuration) { create(:list_item_configuration, user: user) }
  let!(:item) { create(:list_item, user: user, list: list, archived_at: nil) }
  let!(:other_item) { create(:list_item, user: user, list: list, archived_at: nil) }

  before do
    login user
    list.update!(list_item_configuration_id: list_item_configuration.id)
  end

  context "when list does not exist" do
    it "returns 404" do
      get v2_list_list_items_path("foobar"), headers: auth_params

      expect(response).to have_http_status :not_found
    end
  end

  context "when list does exist" do
    context "when user does not have access" do
      describe "when users list does not exist" do
        it "returns 404" do
          UsersList.find_by(list: list, user: user).destroy!
          get v2_list_list_items_path(list.id), headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      describe "when user has not accepted" do
        it "returns 404" do
          UsersList.find_by(list: list, user: user).update!(has_accepted: nil)
          get v2_list_list_items_path(list.id), headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      describe "when user has declined" do
        it "returns 404" do
          UsersList.find_by(list: list, user: user).update!(has_accepted: false)
          get v2_list_list_items_path(list.id), headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end
    end

    context "when user has access" do
      context "when user has read access" do
        before { UsersList.find_by(list: list, user: user).update!(permissions: "read") }

        describe "GET /" do
          it "returns list items" do
            get v2_list_list_items_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)

            expect(response_body).to eq(
              [
                {
                  "archived_at" => nil,
                  "completed" => item[:completed],
                  "created_at" => item[:created_at].iso8601(3),
                  "id" => item[:id],
                  "list_id" => list[:id],
                  "refreshed" => item[:refreshed],
                  "updated_at" => item[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                },
                {
                  "archived_at" => nil,
                  "completed" => other_item[:completed],
                  "created_at" => other_item[:created_at].iso8601(3),
                  "id" => other_item[:id],
                  "list_id" => list[:id],
                  "refreshed" => other_item[:refreshed],
                  "updated_at" => other_item[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              ]
            )
          end
        end

        describe "GET /;id" do
          context "when item does not exist" do
            it "returns 404" do
              get v2_list_list_item_path(list.id, "foobar"), headers: auth_params

              expect(response).to have_http_status :not_found
            end
          end

          context "when item does exist" do
            it "returns item" do
              get v2_list_list_item_path(list.id, item.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response_body).to eq(
                {
                  "archived_at" => nil,
                  "completed" => item[:completed],
                  "created_at" => item[:created_at].iso8601(3),
                  "id" => item[:id],
                  "list_id" => list[:id],
                  "refreshed" => item[:refreshed],
                  "updated_at" => item[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              )
            end
          end
        end

        describe "POST /" do
          it "returns 403" do
            post v2_list_list_items_path(list.id), headers: auth_params

            expect(response).to have_http_status :forbidden
          end
        end

        describe "GET /:id/edit" do
          it "returns 403" do
            get edit_v2_list_list_item_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :forbidden
          end
        end

        describe "PUT /:id" do
          it "returns 403" do
            put v2_list_list_item_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :forbidden
          end
        end

        describe "DELETE /:id" do
          it "returns 403" do
            delete v2_list_list_item_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :forbidden
          end
        end
      end

      context "when user has write access" do
        describe "GET /" do
          it "returns list items" do
            get v2_list_list_items_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)

            expect(response_body).to eq(
              [
                {
                  "archived_at" => nil,
                  "completed" => item[:completed],
                  "created_at" => item[:created_at].iso8601(3),
                  "id" => item[:id],
                  "list_id" => list[:id],
                  "refreshed" => item[:refreshed],
                  "updated_at" => item[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                },
                {
                  "archived_at" => nil,
                  "completed" => other_item[:completed],
                  "created_at" => other_item[:created_at].iso8601(3),
                  "id" => other_item[:id],
                  "list_id" => list[:id],
                  "refreshed" => other_item[:refreshed],
                  "updated_at" => other_item[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              ]
            )
          end
        end

        describe "GET /:id" do
          context "when item does not exist" do
            it "returns 404" do
              get v2_list_list_item_path(list.id, "foobar"), headers: auth_params

              expect(response).to have_http_status :not_found
            end
          end

          context "when item does exist" do
            it "returns item" do
              get v2_list_list_item_path(list.id, item.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response_body).to eq(
                {
                  "archived_at" => nil,
                  "completed" => item[:completed],
                  "created_at" => item[:created_at].iso8601(3),
                  "id" => item[:id],
                  "list_id" => list[:id],
                  "refreshed" => item[:refreshed],
                  "updated_at" => item[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              )
            end
          end
        end

        describe "POST /" do
          it "creates list item" do
            post v2_list_list_items_path(list.id), headers: auth_params

            list.reload
            response_body = JSON.parse(response.body)
            new_item = list.list_items.last

            expect(response).to have_http_status :ok
            expect(response_body).to eq(
              {
                "archived_at" => nil,
                "completed" => false,
                "created_at" => new_item[:created_at].iso8601(3),
                "id" => new_item[:id],
                "list_id" => list.id,
                "refreshed" => false,
                "updated_at" => new_item[:updated_at].iso8601(3),
                "user_id" => user.id
              }
            )
          end
        end

        describe "GET /:id/edit" do
          context "when item does not exist" do
            it "returns 404" do
              get edit_v2_list_list_item_path(list.id, "foobar"), headers: auth_params

              expect(response).to have_http_status :not_found
            end
          end

          context "when item does exist" do
            it "returns item" do
              get edit_v2_list_list_item_path(list.id, item.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response_body["item"]).to eq(
                {
                  "archived_at" => nil,
                  "completed" => item[:completed],
                  "created_at" => item[:created_at].iso8601(3),
                  "id" => item[:id],
                  "list_id" => list[:id],
                  "refreshed" => item[:refreshed],
                  "updated_at" => item[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              )
              expect(response_body["list"]).to eq(
                {
                  "archived_at" => nil,
                  "completed" => false,
                  "created_at" => list[:created_at].iso8601(3),
                  "id" => list[:id],
                  "list_item_configuration_id" => list[:list_item_configuration_id],
                  "name" => list[:name],
                  "owner_id" => list[:owner_id],
                  "refreshed" => false,
                  "updated_at" => list[:updated_at].iso8601(3),
                  "type" => list[:type] # TODO: remove when type is removed
                }
              )
              expect(response_body["list_users"]).to eq([user.email])
            end
          end
        end

        describe "PUT /:id" do
          context "when item does not exist" do
            it "returns 404" do
              put v2_list_list_item_path(list.id, "foobar"), headers: auth_params

              expect(response).to have_http_status :not_found
            end
          end

          context "when item does exist" do
            context "when params are not valid" do
              it "returns 422" do
                put v2_list_list_item_path(list.id, item.id),
                    headers: auth_params,
                    params: { list_item: { refreshed: nil } },
                    as: :json

                expect(response).to have_http_status :unprocessable_entity
              end
            end

            context "when params are valid" do
              it "updates list item" do
                expect(item.completed).to be false
                expect(item.refreshed).to be false

                put v2_list_list_item_path(list.id, item.id),
                    headers: auth_params,
                    params: { list_item: { refreshed: true, completed: true } },
                    as: :json

                item.reload

                expect(response).to have_http_status :ok
                expect(item.completed).to be true
                expect(item.refreshed).to be true
              end
            end
          end
        end

        describe "DELETE /:id" do
          context "when item does not exist" do
            it "returns 404" do
              delete v2_list_list_item_path(list.id, "foobar"), headers: auth_params

              expect(response).to have_http_status :not_found
            end
          end

          context "when item does exist" do
            it "archives list item" do
              expect(item.archived_at).to be_falsy

              delete v2_list_list_item_path(list.id, item.id), headers: auth_params

              item.reload

              expect(response).to have_http_status :no_content
              expect(item.archived_at).to be_truthy
            end
          end
        end
      end
    end
  end
end
