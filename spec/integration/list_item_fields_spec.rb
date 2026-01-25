# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/list_items/:list_item_id/list_item_fields", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  let(:list_item_configuration) { create(:list_item_configuration, user: user) }
  let!(:item) { create(:list_item, user: user, list: list, archived_at: nil) }

  let(:list_item_field_configuration) do
    create(:list_item_field_configuration, list_item_configuration: list_item_configuration)
  end
  let(:other_list_item_field_configuration) do
    create(:list_item_field_configuration, list_item_configuration: list_item_configuration, label: "OtherLabel")
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
      get list_list_item_list_item_fields_path("foobar", item.id), headers: auth_params

      expect(response).to have_http_status :not_found
    end
  end

  context "when list does exist" do
    context "when list item does not exist" do
      it "returns 404" do
        get list_list_item_list_item_fields_path(list.id, "foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    context "when list item does exist" do
      context "when user does not have access to the list" do
        describe "when users list does not exist" do
          it "returns 404" do
            UsersList.find_by(list: list, user: user).destroy!
            get list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end

        describe "when user has not accepted" do
          it "returns 404" do
            UsersList.find_by(list: list, user: user).update!(has_accepted: nil)
            get list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end

        describe "when user has declined" do
          it "returns 404" do
            UsersList.find_by(list: list, user: user).update!(has_accepted: false)
            get list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end
      end

      context "when user does have access to the list" do
        context "when user has read access" do
          before { UsersList.find_by(list: list, user: user).update!(permissions: "read") }

          describe "GET /" do
            it "returns the list items fields" do
              get list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response).to have_http_status :ok
              expect(response_body).to eq [
                {
                  "archived_at" => nil,
                  "created_at" => item_field[:created_at].iso8601(3),
                  "data" => item_field[:data],
                  "data_type" => list_item_field_configuration[:data_type],
                  "id" => item_field[:id],
                  "label" => list_item_field_configuration[:label],
                  "list_item_field_configuration_id" => list_item_field_configuration[:id],
                  "list_item_id" => item[:id],
                  "position" => list_item_field_configuration[:position],
                  "primary" => list_item_field_configuration[:primary],
                  "updated_at" => item_field[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              ]
            end
          end

          describe "GET /:id" do
            it "returns list item field" do
              get list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response).to have_http_status :ok
              expect(response_body).to eq(
                {
                  "archived_at" => nil,
                  "created_at" => item_field[:created_at].iso8601(3),
                  "data" => item_field[:data],
                  "data_type" => list_item_field_configuration[:data_type],
                  "id" => item_field[:id],
                  "label" => list_item_field_configuration[:label],
                  "list_item_field_configuration_id" => list_item_field_configuration[:id],
                  "list_item_id" => item[:id],
                  "position" => list_item_field_configuration[:position],
                  "primary" => list_item_field_configuration[:primary],
                  "updated_at" => item_field[:updated_at].iso8601(3),
                  "user_id" => user[:id]
                }
              )
            end
          end

          describe "GET /:id/edit" do
            it "returns 403" do
              get edit_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

              expect(response).to have_http_status :forbidden
            end
          end

          describe "POST /" do
            it "returns 403" do
              post list_list_item_list_item_fields_path(list.id, item.id),
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
              put list_list_item_list_item_field_path(list.id, item.id, item_field.id),
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
              delete list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

              expect(response).to have_http_status :forbidden
            end
          end
        end

        context "when user has write access" do
          describe "GET /" do
            it "returns the list items fields" do
              get list_list_item_list_item_fields_path(list.id, item.id), headers: auth_params

              response_body = JSON.parse(response.body)

              expect(response).to have_http_status :ok
              expect(response_body).to eq [
                {
                  "archived_at" => nil,
                  "created_at" => item_field[:created_at].iso8601(3),
                  "data" => item_field[:data],
                  "data_type" => list_item_field_configuration[:data_type],
                  "id" => item_field[:id],
                  "label" => list_item_field_configuration[:label],
                  "list_item_field_configuration_id" => list_item_field_configuration[:id],
                  "list_item_id" => item[:id],
                  "position" => list_item_field_configuration[:position],
                  "primary" => list_item_field_configuration[:primary],
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
                  post list_list_item_list_item_fields_path(list.id, item.id),
                       headers: auth_params,
                       params: {
                         list_item_field: {
                           list_item_field_configuration_id: "foobar",
                           data: "foobar"
                         }
                       }

                  expect(response).to have_http_status :unprocessable_content
                  expect(JSON.parse(response.body)).to eq({ "list_item_field_configuration" => ["must exist"] })
                end
              end

              describe "with bad data" do
                it "returns unprocessable entity" do
                  post list_list_item_list_item_fields_path(list.id, item.id),
                       headers: auth_params,
                       params: {
                         list_item_field: {
                           list_item_field_configuration_id: list_item_field_configuration.id,
                           data: nil
                         }
                       }

                  expect(response).to have_http_status :unprocessable_content
                  expect(JSON.parse(response.body)).to eq({ "data" => ["can't be blank"] })
                end
              end
            end

            context "with good params" do
              it "create list item field" do
                post list_list_item_list_item_fields_path(list.id, item.id),
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
                    "data_type" => list_item_field_configuration[:data_type],
                    "id" => new_item[:id],
                    "label" => list_item_field_configuration[:label],
                    "list_item_field_configuration_id" => list_item_field_configuration.id,
                    "list_item_id" => item.id,
                    "position" => list_item_field_configuration[:position],
                    "primary" => list_item_field_configuration[:primary],
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
                get list_list_item_list_item_field_path(list.id, item.id, "foobar"), headers: auth_params

                expect(response).to have_http_status :not_found
                expect(response.body).to eq ""
              end
            end

            describe "GET /:id/edit" do
              it "returns 404" do
                get edit_list_list_item_list_item_field_path(list.id, item.id, "foobar"), headers: auth_params

                expect(response).to have_http_status :not_found
                expect(response.body).to eq ""
              end
            end

            describe "PUT /:id" do
              it "returns 404" do
                put list_list_item_list_item_field_path(list.id, item.id, "foobar"),
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
                delete list_list_item_list_item_field_path(list.id, item.id, "foobar"), headers: auth_params

                expect(response).to have_http_status :not_found
              end
            end
          end

          context "when field does exist" do
            describe "GET /:id" do
              it "returns list item field" do
                get list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

                response_body = JSON.parse(response.body)

                expect(response).to have_http_status :ok
                expect(response_body).to eq(
                  {
                    "archived_at" => nil,
                    "created_at" => item_field[:created_at].iso8601(3),
                    "data" => item_field[:data],
                    "data_type" => list_item_field_configuration[:data_type],
                    "id" => item_field[:id],
                    "label" => list_item_field_configuration[:label],
                    "list_item_field_configuration_id" => list_item_field_configuration[:id],
                    "list_item_id" => item[:id],
                    "position" => list_item_field_configuration[:position],
                    "primary" => list_item_field_configuration[:primary],
                    "updated_at" => item_field[:updated_at].iso8601(3),
                    "user_id" => user[:id]
                  }
                )
              end
            end

            describe "GET /:id/edit" do
              it "returns field" do
                get edit_list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

                response_body = JSON.parse(response.body)

                expect(response).to have_http_status :ok
                expect(response_body["item_field"]).to eq(
                  {
                    "id" => item_field[:id],
                    "list_item_field_configuration_id" => list_item_field_configuration[:id],
                    "data" => item_field[:data],
                    "data_type" => list_item_field_configuration[:data_type],
                    "label" => list_item_field_configuration[:label],
                    "position" => list_item_field_configuration[:position],
                    "primary" => list_item_field_configuration[:primary],
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
                    put list_list_item_list_item_field_path(list.id, item.id, item_field.id),
                        headers: auth_params,
                        params: {
                          list_item_field: {
                            list_item_field_configuration_id: "foobar",
                            data: "foobar"
                          }
                        }

                    expect(response).to have_http_status :unprocessable_content
                    expect(JSON.parse(response.body)).to eq({ "list_item_field_configuration" => ["must exist"] })
                  end
                end

                describe "with bad data" do
                  it "returns unprocessable entity" do
                    put list_list_item_list_item_field_path(list.id, item.id, item_field.id),
                        headers: auth_params,
                        params: {
                          list_item_field: {
                            list_item_field_configuration_id: other_list_item_field_configuration.id,
                            data: nil
                          }
                        }

                    expect(response).to have_http_status :unprocessable_content
                    expect(JSON.parse(response.body)).to eq({ "data" => ["can't be blank"] })
                  end
                end
              end

              context "with good params" do
                it "updates field" do
                  expect(item_field[:list_item_field_configuration_id]).to eq list_item_field_configuration.id
                  expect(item_field[:data]).to eq "MyString"

                  put list_list_item_list_item_field_path(list.id, item.id, item_field.id),
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
                      "data_type" => other_list_item_field_configuration[:data_type],
                      "id" => item_field[:id],
                      "label" => other_list_item_field_configuration[:label],
                      "list_item_field_configuration_id" => other_list_item_field_configuration.id,
                      "list_item_id" => item.id,
                      "position" => other_list_item_field_configuration[:position],
                      "primary" => other_list_item_field_configuration[:primary],
                      "updated_at" => item_field[:updated_at].iso8601(3),
                      "user_id" => user[:id]
                    }
                  )
                end
              end
            end

            describe "DELETE /:id" do
              it "archives item field" do
                delete list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

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

                  delete list_list_item_list_item_field_path(list.id, item.id, item_field.id), headers: auth_params

                  expect(response).to have_http_status :unprocessable_content
                end
              end
            end
          end
        end
      end
    end
  end
end
