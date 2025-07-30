# frozen_string_literal: true

require "rails_helper"

describe "/v2/lists/:list_id/list_items/:list_item_id/list_item_fields", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  let(:list_item_configuration) { create(:list_item_configuration, user: user) }
  let!(:item) { create(:list_item, user: user, list: list, archived_at: nil) }

  let(:list_item_field_configuration) do
    create(:list_item_field_configuration, list_item_configuration: list_item_configuration)
  end
  let(:other_list_item_field_configuration) do
    create(:list_item_field_configuration, list_item_configuration: list_item_configuration)
  end
  let!(:item_field) do
    create(:list_item_field, user: user, list_item: item, list_item_field_configuration: list_item_field_configuration)
  end

  before do
    login user
    list.update!(list_item_configuration_id: list_item_configuration.id)
  end

  context "when list does not exist" do
    it "returns 404" do
      get v2_list_list_item_list_item_fields_path("foobar", item.id), headers: auth_params

      expect(response).to have_http_status :not_found
    end
  end

  context "when list does exist" do
    context "when list item does not exist" do
      it "returns 404" do
        get v2_list_list_item_list_item_fields_path(list.id, "foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    context "when list item does exist" do
      context "when user does not have access to the list" do
        describe "when users list does not exist" do
          it "returns 404" do
            UsersList.find_by(list: list, user: user).destroy!
            get v2_list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end

        describe "when user has not accepted" do
          it "returns 404" do
            UsersList.find_by(list: list, user: user).update!(has_accepted: nil)
            get v2_list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end

        describe "when user has declined" do
          it "returns 404" do
            UsersList.find_by(list: list, user: user).update!(has_accepted: false)
            get v2_list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end
      end

      context "when user does have access to the list" do
        context "when user has read access" do
          before { UsersList.find_by(list: list, user: user).update!(permissions: "read") }

          describe "GET /" do
            it "returns the list items fields" do
              get v2_list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response).to have_http_status :ok
              expect(response_body).to eq [
                {
                  "archived_at" => nil,
                  "created_at" => item_field[:created_at].iso8601(3),
                  "data" => item_field[:data],
                  "id" => item_field[:id],
                  "list_item_field_configuration_id" => list_item_field_configuration[:id],
                  "list_item_id" => item[:id],
                  "updated_at" => item_field[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              ]
            end
          end

          describe "GET /:id" do
            it "returns list item field" do
              get v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response).to have_http_status :ok
              expect(response_body).to eq(
                {
                  "archived_at" => nil,
                  "created_at" => item_field[:created_at].iso8601(3),
                  "data" => item_field[:data],
                  "id" => item_field[:id],
                  "list_item_field_configuration_id" => list_item_field_configuration[:id],
                  "list_item_id" => item[:id],
                  "updated_at" => item_field[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              )
            end
          end

          describe "GET /:id/edit" do
            it "returns 403" do
              get edit_v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

              expect(response).to have_http_status :forbidden
            end
          end

          describe "POST /" do
            it "returns 403" do
              post v2_list_list_item_list_item_fields_path(list.id, item.id),
                   headers: auth_params,
                   params: {
                     list_item_field: {
                       list_item_field_configuration_id: list_item_field_configuration.id,
                       data: "foobar"
                     }
                   }

              expect(response).to have_http_status :forbidden
            end
          end

          describe "PUT /:id" do
            it "returns 403" do
              put v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id),
                  headers: auth_params,
                  params: {
                    list_item_field: {
                      list_item_field_configuration_id: list_item_field_configuration.id,
                      data: "foobar"
                    }
                  }

              expect(response).to have_http_status :forbidden
            end
          end

          describe "DELETE /:id" do
            it "returns 403" do
              delete v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

              expect(response).to have_http_status :forbidden
            end
          end
        end

        context "when user has write access" do
          describe "GET /" do
            it "returns the list items fields" do
              get v2_list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response).to have_http_status :ok
              expect(response_body).to eq [
                {
                  "archived_at" => nil,
                  "created_at" => item_field[:created_at].iso8601(3),
                  "data" => item_field[:data],
                  "id" => item_field[:id],
                  "list_item_field_configuration_id" => list_item_field_configuration[:id],
                  "list_item_id" => item[:id],
                  "updated_at" => item_field[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              ]
            end
          end

          describe "POST /" do
            context "with bad params" do
              describe "with bad list item field configuration" do
                it "returns unprocessable entity" do
                  post v2_list_list_item_list_item_fields_path(list.id, item.id),
                       headers: auth_params,
                       params: {
                         list_item_field: {
                           list_item_field_configuration_id: "foobar",
                           data: "foobar"
                         }
                       }

                  expect(response).to have_http_status :unprocessable_entity
                  expect(JSON.parse(response.body)).to eq({ "list_item_field_configuration" => ["must exist"] })
                end
              end

              describe "with bad data" do
                it "returns unprocessable entity" do
                  post v2_list_list_item_list_item_fields_path(list.id, item.id),
                       headers: auth_params,
                       params: {
                         list_item_field: {
                           list_item_field_configuration_id: list_item_field_configuration.id,
                           data: nil
                         }
                       }

                  expect(response).to have_http_status :unprocessable_entity
                  expect(JSON.parse(response.body)).to eq({ "data" => ["can't be blank"] })
                end
              end
            end

            context "with good params" do
              it "create list item field" do
                post v2_list_list_item_list_item_fields_path(list.id, item.id),
                     headers: auth_params,
                     params: {
                       list_item_field: {
                         list_item_field_configuration_id: list_item_field_configuration.id,
                         data: "foobar"
                       }
                     }

                response_body = JSON.parse(response.body)
                item.reload
                new_item = item.list_item_fields.last

                expect(response).to have_http_status :ok
                expect(response_body).to eq(
                  {
                    "archived_at" => nil,
                    "created_at" => new_item[:created_at].iso8601(3),
                    "data" => "foobar",
                    "id" => new_item[:id],
                    "list_item_field_configuration_id" => list_item_field_configuration.id,
                    "list_item_id" => item.id,
                    "updated_at" => new_item[:updated_at].iso8601(3),
                    "user_id" => user[:id]
                  }
                )
              end
            end
          end

          context "when field does not exist" do
            describe "GET /:id" do
              it "returns 404" do
                get v2_list_list_item_list_item_field_path(list.id, item.id, "foobar"), headers: auth_params

                expect(response).to have_http_status :not_found
                expect(response.body).to eq ""
              end
            end

            describe "GET /:id/edit" do
              it "returns 404" do
                get edit_v2_list_list_item_list_item_field_path(list.id, item.id, "foobar"), headers: auth_params

                expect(response).to have_http_status :not_found
                expect(response.body).to eq ""
              end
            end

            describe "PUT /:id" do
              it "returns 404" do
                put v2_list_list_item_list_item_field_path(list.id, item.id, "foobar"),
                    headers: auth_params,
                    params: {
                      list_item_field: {
                        list_item_field_configuration_id: list_item_field_configuration.id,
                        data: "foobar"
                      }
                    }

                expect(response).to have_http_status :not_found
                expect(response.body).to eq ""
              end
            end

            describe "DELETE /:id" do
              it "returns 404" do
                delete v2_list_list_item_list_item_field_path(list.id, item.id, "foobar"), headers: auth_params

                expect(response).to have_http_status :not_found
              end
            end
          end

          context "when field does exist" do
            describe "GET /:id" do
              it "returns list item field" do
                get v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

                response_body = JSON.parse(response.body)

                expect(response).to have_http_status :ok
                expect(response_body).to eq(
                  {
                    "archived_at" => nil,
                    "created_at" => item_field[:created_at].iso8601(3),
                    "data" => item_field[:data],
                    "id" => item_field[:id],
                    "list_item_field_configuration_id" => list_item_field_configuration[:id],
                    "list_item_id" => item[:id],
                    "updated_at" => item_field[:updated_at].iso8601(3),
                    "user_id" => user[:id]
                  }
                )
              end
            end

            describe "GET /:id/edit" do
              it "returns field" do
                get edit_v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

                response_body = JSON.parse(response.body)

                expect(response).to have_http_status :ok
                expect(response_body["item_field"]).to eq(
                  {
                    "id" => item_field[:id],
                    "list_item_field_configuration_id" => list_item_field_configuration[:id],
                    "data" => item_field[:data],
                    "archived_at" => nil,
                    "user_id" => user[:id],
                    "list_item_id" => item[:id],
                    "created_at" => item_field[:created_at].iso8601(3),
                    "updated_at" => item_field[:updated_at].iso8601(3)
                  }
                )
                expect(response_body["list_users"]).to eq([user.email])
              end
            end

            describe "PUT /:id" do
              context "with bad params" do
                describe "with bad list item field configuration" do
                  it "returns unprocessable entity" do
                    put v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id),
                        headers: auth_params,
                        params: {
                          list_item_field: {
                            list_item_field_configuration_id: "foobar",
                            data: "foobar"
                          }
                        }

                    expect(response).to have_http_status :unprocessable_entity
                    expect(JSON.parse(response.body)).to eq({ "list_item_field_configuration" => ["must exist"] })
                  end
                end

                describe "with bad data" do
                  it "returns unprocessable entity" do
                    put v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id),
                        headers: auth_params,
                        params: {
                          list_item_field: {
                            list_item_field_configuration_id: other_list_item_field_configuration.id,
                            data: nil
                          }
                        }

                    expect(response).to have_http_status :unprocessable_entity
                    expect(JSON.parse(response.body)).to eq({ "data" => ["can't be blank"] })
                  end
                end
              end

              context "with good params" do
                it "updates field" do
                  expect(item_field[:list_item_field_configuration_id]).to eq list_item_field_configuration.id
                  expect(item_field[:data]).to eq "MyString"

                  put v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id),
                      headers: auth_params,
                      params: {
                        list_item_field: {
                          list_item_field_configuration_id: other_list_item_field_configuration.id,
                          data: "foobar"
                        }
                      }

                  response_body = JSON.parse(response.body)
                  item_field.reload

                  expect(response).to have_http_status :ok
                  expect(response_body).to eq(
                    {
                      "archived_at" => nil,
                      "created_at" => item_field[:created_at].iso8601(3),
                      "data" => "foobar",
                      "id" => item_field[:id],
                      "list_item_field_configuration_id" => other_list_item_field_configuration.id,
                      "list_item_id" => item.id,
                      "updated_at" => item_field[:updated_at].iso8601(3),
                      "user_id" => user[:id]
                    }
                  )
                end
              end
            end

            describe "DELETE /:id" do
              it "archives item field" do
                delete v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

                item_field.reload

                expect(response).to have_http_status :no_content
                expect(item_field[:archived_at]).to be_truthy
              end

              context "when archive fails due to validation errors" do
                it "returns 422 unprocessable_entity" do
                  # Mock the archive method to raise validation error
                  allow(ListItemField).to receive(:find).with(item_field.id.to_s).and_return(item_field)
                  allow(item_field).to receive(:archive).and_raise(
                    ActiveRecord::RecordInvalid.new(item_field)
                  )

                  delete v2_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

                  expect(response).to have_http_status :unprocessable_entity
                end
              end
            end
          end
        end
      end
    end
  end
end
