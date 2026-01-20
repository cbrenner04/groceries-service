# frozen_string_literal: true

require "rails_helper"

describe "/list_item_configurations", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:other_user) { create(:user) }
  let(:list) { user.lists.last }

  let!(:list_item_configuration) { create(:list_item_configuration, user: user) }

  before { login user }

  describe "GET /" do
    it "returns user's list item configurations" do
      get list_item_configurations_path, headers: auth_params

      response_body = JSON.parse(response.body)

      expect(response).to have_http_status :ok
      # User gets 5 default configs + 1 created in this test
      expect(response_body.count).to eq 6
      test_config = response_body.find { |c| c["id"] == list_item_configuration[:id] }
      expect(test_config).to eq(
        {
          "archived_at" => nil,
          "created_at" => list_item_configuration[:created_at].iso8601(3),
          "id" => list_item_configuration[:id],
          "name" => list_item_configuration[:name],
          "updated_at" => list_item_configuration[:updated_at].iso8601(3),
          "user_id" => user[:id]
        }
      )
    end
  end

  describe "POST /" do
    context "with bad params" do
      it "returns 422" do
        post list_item_configurations_path, headers: auth_params, params: { list_item_configuration: { name: nil } }

        expect(response).to have_http_status :unprocessable_content
        expect(JSON.parse(response.body)).to eq({ "name" => ["can't be blank"] })
      end
    end

    context "with good params" do
      it "creates configuration" do
        name = "foobar"
        post list_item_configurations_path, headers: auth_params, params: { list_item_configuration: { name: name } }

        new_configuration = user.list_item_configurations.last

        expect(response).to have_http_status :ok
        expect(new_configuration[:name]).to eq name
        expect(JSON.parse(response.body)).to eq(
          {
            "archived_at" => nil,
            "created_at" => new_configuration[:created_at].iso8601(3),
            "id" => new_configuration[:id],
            "name" => name,
            "updated_at" => new_configuration[:updated_at].iso8601(3),
            "user_id" => user[:id]
          }
        )
      end
    end
  end

  context "when configuration does not exist" do
    describe "GET /:id" do
      it "returns 404" do
        get list_item_configuration_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "GET /:id/edit" do
      it "returns 404" do
        get edit_list_item_configuration_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "PUT /:id" do
      it "returns 404" do
        put list_item_configuration_path("foobar"),
            headers: auth_params,
            params: {
              list_item_configuration: {
                name: "foobar"
              }
            }

        expect(response).to have_http_status :not_found
      end
    end

    describe "DELETE /:id" do
      it "returns 404" do
        delete list_item_configuration_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end
  end

  context "when configuration does exist" do
    context "when user is not owner of configuration" do
      before { list_item_configuration.update!(user: other_user) }

      describe "GET /:id" do
        it "returns 403" do
          get list_item_configuration_path(list_item_configuration.id), headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      describe "GET /:id/edit" do
        it "returns 403" do
          get edit_list_item_configuration_path(list_item_configuration.id), headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      describe "PUT /:id" do
        it "returns 403" do
          put list_item_configuration_path(list_item_configuration.id),
              headers: auth_params,
              params: {
                list_item_configuration: {
                  name: "foobar"
                }
              }

          expect(response).to have_http_status :forbidden
        end
      end

      describe "DELETE /:id" do
        it "returns 403" do
          delete list_item_configuration_path(list_item_configuration.id), headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end
    end

    context "when user is owner of configuration" do
      describe "GET /:id" do
        it "returns configuration" do
          get list_item_configuration_path(list_item_configuration.id), headers: auth_params

          expect(response).to have_http_status :ok
          expect(JSON.parse(response.body)).to eq(
            {
              "archived_at" => nil,
              "created_at" => list_item_configuration[:created_at].iso8601(3),
              "id" => list_item_configuration[:id],
              "name" => list_item_configuration[:name],
              "updated_at" => list_item_configuration[:updated_at].iso8601(3),
              "user_id" => user[:id]
            }
          )
        end
      end

      describe "GET /:id/edit" do
        it "returns configuration" do
          get edit_list_item_configuration_path(list_item_configuration.id), headers: auth_params

          expect(response).to have_http_status :ok
          expect(JSON.parse(response.body)).to eq(
            {
              "archived_at" => nil,
              "created_at" => list_item_configuration[:created_at].iso8601(3),
              "id" => list_item_configuration[:id],
              "name" => list_item_configuration[:name],
              "updated_at" => list_item_configuration[:updated_at].iso8601(3),
              "user_id" => user[:id]
            }
          )
        end
      end

      describe "PUT /:id" do
        context "with bad params" do
          it "returns 422" do
            put list_item_configuration_path(list_item_configuration.id),
                headers: auth_params,
                params: {
                  list_item_configuration: {
                    name: nil
                  }
                }

            expect(response).to have_http_status :unprocessable_content
            expect(JSON.parse(response.body)).to eq({ "name" => ["can't be blank"] })
          end
        end

        context "with good params" do
          it "updates configuration" do
            expect(list_item_configuration[:name]).to eq "MyString"

            put list_item_configuration_path(list_item_configuration.id),
                headers: auth_params,
                params: {
                  list_item_configuration: {
                    name: "foobar"
                  }
                }

            list_item_configuration.reload

            expect(response).to have_http_status :ok
            expect(JSON.parse(response.body)).to eq(
              {
                "archived_at" => nil,
                "created_at" => list_item_configuration[:created_at].iso8601(3),
                "id" => list_item_configuration[:id],
                "name" => "foobar",
                "updated_at" => list_item_configuration[:updated_at].iso8601(3),
                "user_id" => user[:id]
              }
            )
            expect(list_item_configuration[:name]).to eq "foobar"
          end
        end
      end

      describe "DELETE /:id" do
        it "archives the list item configuration and its related list item field configurations" do
          list_item_field_configuration =
            list_item_configuration.list_item_field_configurations.create!(label: "foo", data_type: "free_text",
                                                                           position: 1)

          expect(list_item_configuration.archived_at).to be_falsy
          expect(list_item_field_configuration.archived_at).to be_falsy

          delete list_item_configuration_path(list_item_configuration.id), headers: auth_params

          list_item_configuration.reload
          list_item_field_configuration.reload

          expect(response).to have_http_status :no_content
          expect(list_item_configuration.archived_at).to be_truthy
          expect(list_item_field_configuration.archived_at).to be_truthy
        end

        context "when archive fails due to validation errors" do
          it "returns 422 unprocessable_entity" do
            # Mock the archive method to raise validation error
            allow(ListItemConfiguration).to receive(:find).with(list_item_configuration.id.to_s)
                                                          .and_return(list_item_configuration)
            allow(list_item_configuration).to receive(:archive).and_raise(
              ActiveRecord::RecordInvalid.new(list_item_configuration)
            )

            delete list_item_configuration_path(list_item_configuration.id), headers: auth_params

            expect(response).to have_http_status :unprocessable_content
          end
        end
      end
    end
  end
end
