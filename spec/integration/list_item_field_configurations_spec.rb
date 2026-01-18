# frozen_string_literal: true

require "rails_helper"

describe "/list_item_configurations/:list_item_configuration_id/list_item_field_configurations", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:other_user) { create(:user) }
  let(:list) { user.lists.last }

  let(:list_item_configuration) { create(:list_item_configuration, user: user) }
  let!(:list_item_field_configuration) do
    create(:list_item_field_configuration, list_item_configuration: list_item_configuration)
  end

  before { login user }

  context "when list item configuration does not exist" do
    describe "GET /" do
      it "returns 404" do
        get list_item_configuration_list_item_field_configurations_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "GET /:id" do
      it "returns 404" do
        get list_item_configuration_list_item_field_configuration_path("foobar", list_item_field_configuration.id),
            headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "GET /:id/edit" do
      it "returns 404" do
        get edit_list_item_configuration_list_item_field_configuration_path("foobar", list_item_field_configuration.id),
            headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "POST /" do
      it "returns 404" do
        post list_item_configuration_list_item_field_configurations_path("foobar"),
             headers: auth_params,
             params: {
               list_item_field_configuration: {
                 label: "foo",
                 data_type: "free_text"
               }
             }

        expect(response).to have_http_status :not_found
      end
    end

    describe "PUT /:id" do
      it "returns 404" do
        put list_item_configuration_list_item_field_configuration_path("foobar", list_item_field_configuration.id),
            headers: auth_params,
            params: {
              label: "foo",
              data_type: "boolean"
            }

        expect(response).to have_http_status :not_found
      end
    end

    describe "DELETE /:id" do
      it "returns 404" do
        delete list_item_configuration_list_item_field_configuration_path("foobar", list_item_field_configuration.id),
               headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end
  end

  context "when list item configuration does exist" do
    context "when user is not owner of list item configuration" do
      before { list_item_configuration.update!(user: other_user) }

      describe "GET /" do
        it "returns 403" do
          get list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
              headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      describe "GET /:id" do
        it "returns 403" do
          get list_item_configuration_list_item_field_configuration_path(
            list_item_configuration.id,
            list_item_field_configuration.id
          ),
              headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      describe "GET /:id/edit" do
        it "returns 403" do
          get edit_list_item_configuration_list_item_field_configuration_path(
            list_item_configuration.id,
            list_item_field_configuration.id
          ),
              headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      describe "POST /" do
        it "returns 403" do
          post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
               headers: auth_params,
               params: {
                 list_item_field_configuration: {
                   label: "foo",
                   data_type: "free_text"
                 }
               }

          expect(response).to have_http_status :forbidden
        end
      end

      describe "PUT /:id" do
        it "returns 403" do
          put list_item_configuration_list_item_field_configuration_path(
            list_item_configuration.id,
            list_item_field_configuration.id
          ),
              headers: auth_params,
              params: {
                label: "foo",
                data_type: "boolean"
              }

          expect(response).to have_http_status :forbidden
        end
      end

      describe "DELETE /:id" do
        it "returns 403" do
          delete list_item_configuration_list_item_field_configuration_path(
            list_item_configuration.id,
            list_item_field_configuration.id
          ),
                 headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end
    end

    context "when user has write permissions on lists using the configuration" do
      let(:list_using_config) { create(:list, list_item_configuration_id: list_item_configuration.id) }

      before do
        list_item_configuration.update!(user: other_user)
        create(:users_list, list: list_using_config, user: user, permissions: "write")
      end

      describe "GET /" do
        it "returns list item configuration's list item field configurations" do
          get list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
              headers: auth_params

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status :ok
          expect(response_body.count).to eq 1
          expect(response_body.first).to eq(
            {
              "archived_at" => nil,
              "created_at" => list_item_field_configuration[:created_at].iso8601(3),
              "data_type" => list_item_field_configuration[:data_type],
              "id" => list_item_field_configuration[:id],
              "label" => list_item_field_configuration[:label],
              "list_item_configuration_id" => list_item_configuration[:id],
              "position" => list_item_field_configuration[:position],
              "updated_at" => list_item_field_configuration[:updated_at].iso8601(3)
            }
          )
        end
      end

      describe "POST /" do
        it "creates a list item field configuration" do
          post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
               headers: auth_params,
               params: {
                 list_item_field_configuration: {
                   label: "foo",
                   data_type: "free_text",
                   position: 1
                 }
               }

          new_list_item_field_configuration = list_item_configuration.list_item_field_configurations.last

          expect(response).to have_http_status :ok
          expect(JSON.parse(response.body)).to eq(
            {
              "archived_at" => nil,
              "created_at" => new_list_item_field_configuration[:created_at].iso8601(3),
              "data_type" => "free_text",
              "id" => new_list_item_field_configuration[:id],
              "label" => "foo",
              "list_item_configuration_id" => list_item_configuration[:id],
              "position" => new_list_item_field_configuration[:position],
              "updated_at" => new_list_item_field_configuration[:updated_at].iso8601(3)
            }
          )
        end
      end

      describe "PUT /:id" do
        it "updates the list item field configuration" do
          put list_item_configuration_list_item_field_configuration_path(
            list_item_configuration.id,
            list_item_field_configuration.id
          ), headers: auth_params,
             params: {
               list_item_field_configuration: {
                 label: "foo",
                 data_type: "boolean"
               }
             }

          list_item_field_configuration.reload

          expect(response).to have_http_status :ok
          expect(JSON.parse(response.body)).to eq(
            {
              "archived_at" => nil,
              "created_at" => list_item_field_configuration[:created_at].iso8601(3),
              "data_type" => "boolean",
              "id" => list_item_field_configuration[:id],
              "label" => "foo",
              "list_item_configuration_id" => list_item_configuration[:id],
              "position" => list_item_field_configuration[:position],
              "updated_at" => list_item_field_configuration[:updated_at].iso8601(3)
            }
          )
        end
      end

      describe "DELETE /:id" do
        it "archives the list item field configuration" do
          expect(list_item_field_configuration.archived_at).to be_falsy

          delete list_item_configuration_list_item_field_configuration_path(
            list_item_configuration.id,
            list_item_field_configuration.id
          ), headers: auth_params

          list_item_field_configuration.reload

          expect(response).to have_http_status :no_content
          expect(list_item_field_configuration.archived_at).to be_truthy
        end
      end
    end

    context "when user has read permissions on lists using the configuration" do
      let(:list_using_config) { create(:list, list_item_configuration_id: list_item_configuration.id) }

      before do
        list_item_configuration.update!(user: other_user)
        create(:users_list, list: list_using_config, user: user, permissions: "read")
      end

      describe "GET /" do
        it "returns 403" do
          get list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
              headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      describe "POST /" do
        it "returns 403" do
          post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
               headers: auth_params,
               params: {
                 list_item_field_configuration: {
                   label: "foo",
                   data_type: "free_text",
                   position: 1
                 }
               }

          expect(response).to have_http_status :forbidden
        end
      end
    end

    context "when user is owner of list item configuration" do
      describe "GET /" do
        it "returns list item configuration's list item field configurations" do
          get list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
              headers: auth_params

          response_body = JSON.parse(response.body)

          expect(response).to have_http_status :ok
          expect(response_body.count).to eq 1
          expect(response_body.first).to eq(
            {
              "archived_at" => nil,
              "created_at" => list_item_field_configuration[:created_at].iso8601(3),
              "data_type" => list_item_field_configuration[:data_type],
              "id" => list_item_field_configuration[:id],
              "label" => list_item_field_configuration[:label],
              "list_item_configuration_id" => list_item_configuration[:id],
              "position" => list_item_field_configuration[:position],
              "updated_at" => list_item_field_configuration[:updated_at].iso8601(3)
            }
          )
        end
      end

      describe "POST /" do
        context "with bad params" do
          describe "when label is blank" do
            it "returns 422" do
              post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
                   headers: auth_params,
                   params: {
                     list_item_field_configuration: {
                       label: nil,
                       data_type: "free_text",
                       position: 1
                     }
                   }

              expect(response).to have_http_status :unprocessable_content
              expect(JSON.parse(response.body)).to eq({ "label" => ["can't be blank"] })
            end

            describe "when position is blank" do
              it "auto-assigns position and creates successfully" do
                post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
                     headers: auth_params,
                     params: {
                       list_item_field_configuration: {
                         label: "foo",
                         data_type: "free_text"
                       }
                     }

                new_list_item_field_configuration = list_item_configuration.list_item_field_configurations.last

                expect(response).to have_http_status :ok
                expect(JSON.parse(response.body)).to eq(
                  {
                    "archived_at" => nil,
                    "created_at" => new_list_item_field_configuration[:created_at].iso8601(3),
                    "data_type" => "free_text",
                    "id" => new_list_item_field_configuration[:id],
                    "label" => "foo",
                    "list_item_configuration_id" => list_item_configuration[:id],
                    "position" => new_list_item_field_configuration[:position],
                    "updated_at" => new_list_item_field_configuration[:updated_at].iso8601(3)
                  }
                )
                expect(new_list_item_field_configuration[:position]).to be > 0
              end
            end
          end

          describe "when data_type is blank" do
            it "returns 422" do
              post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
                   headers: auth_params,
                   params: {
                     list_item_field_configuration: {
                       label: "foo",
                       data_type: nil,
                       position: 1
                     }
                   }

              expect(response).to have_http_status :unprocessable_content
              expect(JSON.parse(response.body)).to eq(
                {
                  "data_type" => ["can't be blank", " is not one of [boolean, data_time, free_text, number]"]
                }
              )
            end
          end

          describe "when data_type is not one of the options" do
            it "returns 422" do
              post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
                   headers: auth_params,
                   params: {
                     list_item_field_configuration: {
                       label: "foo",
                       data_type: "bar",
                       position: 1
                     }
                   }

              expect(response).to have_http_status :unprocessable_content
              expect(JSON.parse(response.body)).to eq(
                {
                  "data_type" => ["bar is not one of [boolean, data_time, free_text, number]"]
                }
              )
            end
          end

          describe "when position is not a number" do
            it "returns 422" do
              post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
                   headers: auth_params,
                   params: {
                     list_item_field_configuration: {
                       label: "foo",
                       data_type: "free_text",
                       position: "bar"
                     }
                   }

              expect(response).to have_http_status :unprocessable_content
              expect(JSON.parse(response.body)).to eq({ "position" => ["is not a number"] })
            end
          end
        end

        context "with good params" do
          it "creates a list item field configuration" do
            post list_item_configuration_list_item_field_configurations_path(list_item_configuration.id),
                 headers: auth_params,
                 params: {
                   list_item_field_configuration: {
                     label: "foo",
                     data_type: "free_text",
                     position: 1
                   }
                 }

            new_list_item_field_configuration = list_item_configuration.list_item_field_configurations.last

            expect(response).to have_http_status :ok
            expect(JSON.parse(response.body)).to eq(
              {
                "archived_at" => nil,
                "created_at" => new_list_item_field_configuration[:created_at].iso8601(3),
                "data_type" => "free_text",
                "id" => new_list_item_field_configuration[:id],
                "label" => "foo",
                "list_item_configuration_id" => list_item_configuration[:id],
                "position" => new_list_item_field_configuration[:position],
                "updated_at" => new_list_item_field_configuration[:updated_at].iso8601(3)
              }
            )
          end
        end
      end

      context "when list item field configuration does not exist" do
        describe "GET /:id" do
          it "returns 404" do
            get list_item_configuration_list_item_field_configuration_path(list_item_configuration.id, "foobar"),
                headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end

        describe "GET /:id/edit" do
          it "returns 404" do
            get edit_list_item_configuration_list_item_field_configuration_path(list_item_configuration.id, "foobar"),
                headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end

        describe "PUT /:id" do
          it "returns 404" do
            put list_item_configuration_list_item_field_configuration_path(list_item_configuration.id, "foobar"),
                headers: auth_params,
                params: {
                  list_item_field_configuration: {
                    label: "foobar",
                    data_type: "boolean"
                  }
                }

            expect(response).to have_http_status :not_found
          end
        end

        describe "DELETE /:id" do
          it "returns 404" do
            delete list_item_configuration_list_item_field_configuration_path(list_item_configuration.id, "foobar"),
                   headers: auth_params

            expect(response).to have_http_status :not_found
          end
        end
      end

      context "when list item field configuration does exist" do
        describe "GET /:id" do
          it "returns the list item field configuration" do
            get list_item_configuration_list_item_field_configuration_path(
              list_item_configuration.id,
              list_item_field_configuration.id
            ), headers: auth_params

            expect(response).to have_http_status :ok
            expect(JSON.parse(response.body)).to eq(
              {
                "archived_at" => nil,
                "created_at" => list_item_field_configuration[:created_at].iso8601(3),
                "data_type" => list_item_field_configuration[:data_type],
                "id" => list_item_field_configuration[:id],
                "label" => list_item_field_configuration[:label],
                "list_item_configuration_id" => list_item_configuration[:id],
                "position" => list_item_field_configuration[:position],
                "updated_at" => list_item_field_configuration[:updated_at].iso8601(3)
              }
            )
          end
        end

        describe "GET /:id/edit" do
          it "returns the list item field configuration" do
            get edit_list_item_configuration_list_item_field_configuration_path(
              list_item_configuration.id,
              list_item_field_configuration.id
            ), headers: auth_params

            expect(response).to have_http_status :ok
            expect(JSON.parse(response.body)).to eq(
              {
                "archived_at" => nil,
                "created_at" => list_item_field_configuration[:created_at].iso8601(3),
                "data_type" => list_item_field_configuration[:data_type],
                "id" => list_item_field_configuration[:id],
                "label" => list_item_field_configuration[:label],
                "list_item_configuration_id" => list_item_configuration[:id],
                "position" => list_item_field_configuration[:position],
                "updated_at" => list_item_field_configuration[:updated_at].iso8601(3)
              }
            )
          end
        end

        describe "PUT /:id" do
          context "with bad params" do
            describe "when label is blank" do
              it "returns 422" do
                put list_item_configuration_list_item_field_configuration_path(
                  list_item_configuration.id,
                  list_item_field_configuration.id
                ), headers: auth_params,
                   params: {
                     list_item_field_configuration: {
                       label: nil,
                       data_type: "free_text"
                     }
                   }

                expect(response).to have_http_status :unprocessable_content
                expect(JSON.parse(response.body)).to eq({ "label" => ["can't be blank"] })
              end
            end

            describe "when data_type is blank" do
              it "returns 422" do
                put list_item_configuration_list_item_field_configuration_path(
                  list_item_configuration.id,
                  list_item_field_configuration.id
                ), headers: auth_params,
                   params: {
                     list_item_field_configuration: {
                       label: "foo",
                       data_type: nil
                     }
                   }

                expect(response).to have_http_status :unprocessable_content
                expect(JSON.parse(response.body)).to eq(
                  {
                    "data_type" => ["can't be blank", " is not one of [boolean, data_time, free_text, number]"]
                  }
                )
              end
            end

            describe "when data_type is not one of the options" do
              it "returns 422" do
                put list_item_configuration_list_item_field_configuration_path(
                  list_item_configuration.id,
                  list_item_field_configuration.id
                ), headers: auth_params,
                   params: {
                     list_item_field_configuration: {
                       label: "foo",
                       data_type: "bar"
                     }
                   }

                expect(response).to have_http_status :unprocessable_content
                expect(JSON.parse(response.body)).to eq(
                  {
                    "data_type" => ["bar is not one of [boolean, data_time, free_text, number]"]
                  }
                )
              end
            end
          end

          context "with good params" do
            it "updates the list item field configuration" do
              expect(list_item_field_configuration[:label]).to eq "MyString"
              expect(list_item_field_configuration[:data_type]).to eq "free_text"

              put list_item_configuration_list_item_field_configuration_path(
                list_item_configuration.id,
                list_item_field_configuration.id
              ), headers: auth_params,
                 params: {
                   list_item_field_configuration: {
                     label: "foo",
                     data_type: "boolean"
                   }
                 }

              list_item_field_configuration.reload

              expect(response).to have_http_status :ok
              expect(JSON.parse(response.body)).to eq(
                {
                  "archived_at" => nil,
                  "created_at" => list_item_field_configuration[:created_at].iso8601(3),
                  "data_type" => "boolean",
                  "id" => list_item_field_configuration[:id],
                  "label" => "foo",
                  "list_item_configuration_id" => list_item_configuration[:id],
                  "position" => list_item_field_configuration[:position],
                  "updated_at" => list_item_field_configuration[:updated_at].iso8601(3)
                }
              )
            end
          end
        end

        describe "DELETE /:id" do
          it "archives the list item field configuration" do
            expect(list_item_field_configuration.archived_at).to be_falsy

            delete list_item_configuration_list_item_field_configuration_path(
              list_item_configuration.id,
              list_item_field_configuration.id
            ), headers: auth_params

            list_item_field_configuration.reload

            expect(response).to have_http_status :no_content
            expect(list_item_field_configuration.archived_at).to be_truthy
          end

          context "when archive fails due to validation errors" do
            it "returns 422 unprocessable_entity" do
              # Mock the archive method to raise validation error
              allow(ListItemFieldConfiguration).to receive(:find).with(list_item_field_configuration.id.to_s)
                                                                 .and_return(list_item_field_configuration)
              allow(list_item_field_configuration).to receive(:archive).and_raise(
                ActiveRecord::RecordInvalid.new(list_item_field_configuration)
              )

              delete list_item_configuration_list_item_field_configuration_path(
                list_item_configuration.id,
                list_item_field_configuration.id
              ), headers: auth_params

              expect(response).to have_http_status :unprocessable_content
            end
          end
        end
      end
    end
  end
end
