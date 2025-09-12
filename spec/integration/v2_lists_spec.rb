# frozen_string_literal: true

require "rails_helper"

describe "/v2/lists", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  before { login user }

  describe "GET /" do
    it "responds with success and correct payload" do
      get v2_lists_path, headers: auth_params

      response_body = JSON.parse(response.body)

      expect(response).to have_http_status :success
      expect(response_body["accepted_lists"].count).to eq user.accepted_lists.count
      expect(response_body["pending_lists"].count).to eq user.pending_lists.count
      expect(response_body["current_user_id"]).to eq user.id
    end
  end

  describe "GET /:id" do
    describe "when list does not exist" do
      it "responds with 404" do
        get v2_list_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "when a user has not been invited" do
      before { list.users_lists.delete_all }

      it "responds with forbidden" do
        get v2_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "when a user has been invited" do
      context "when invitee has not accepted" do
        before { list.users_lists.find_by(user: user).update!(has_accepted: nil) }

        it "responds with forbidden" do
          get v2_list_path(list.id), headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      context "when invitee has accepted" do
        let(:list) { List.create!(name: "foo", owner: user) }

        before do
          create(:users_list, user: user, list: list)
          list_item_configuration = user.list_item_configurations.create!(name: "foo")
          list.update!(list_item_configuration_id: list_item_configuration.id)
        end

        it "responds with success and correct payload" do
          ListItem.create!(user: user, list: list, completed: true)

          # Create a list item with fields to test field sorting
          list_item = ListItem.create!(user: user, list: list, completed: false)
          config1 = ListItemFieldConfiguration.create!(label: "A", data_type: "free_text", position: 2,
                                                       list_item_configuration: list.list_item_configuration)
          config2 = ListItemFieldConfiguration.create!(label: "B", data_type: "free_text", position: 1,
                                                       list_item_configuration: list.list_item_configuration)
          list_item.list_item_fields.create!(user: user, data: "foo", list_item_field_configuration: config1)
          list_item.list_item_fields.create!(user: user, data: "bar", list_item_field_configuration: config2)

          get v2_list_path(list.id), headers: auth_params

          expect(response).to be_successful

          response_body = JSON.parse(response.body)
          expect(response_body["current_user_id"]).to eq user.id
          expect(response_body["list"]).to include("id" => list.id, "name" => list.name)
          expect(response_body["list_users"]).to eq [user.email]
          expect(response_body["permissions"]).to eq "write"
          expect(response_body["lists_to_update"]).to eq []

          # Check that not_completed_items contains the non-completed item
          expect(response_body["not_completed_items"].length).to eq 1
          first_not_completed_item = ListItem.where(list: list).not_archived.ordered.not_completed.first.id
          expect(response_body["not_completed_items"].first["id"]).to eq(first_not_completed_item)

          # Check that completed_items contains the completed item
          expect(response_body["completed_items"].length).to eq 1
          first_completed_item = ListItem.where(list: list).not_archived.ordered.completed.first.id
          expect(response_body["completed_items"].first["id"]).to eq(first_completed_item)

          # Test that fields are sorted by position in not_completed_items
          fields = response_body["not_completed_items"].first["fields"]
          expect(fields.pluck("label")).to eq %w[B A]
          expect(fields.pluck("position")).to eq [1, 2]
        end

        context "when list was created via V1 API (no list_item_configuration_id)" do
          let(:v1_list) { List.create!(name: "v1 list", owner: user, list_item_configuration_id: nil) }

          before do
            create(:users_list, user: user, list: v1_list)
          end

          it "responds with success and handles nil list_item_configuration" do
            get v2_list_path(v1_list.id), headers: auth_params

            expect(response).to be_successful

            response_body = JSON.parse(response.body)
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include("id" => v1_list.id, "name" => v1_list.name)
            expect(response_body["list_item_configuration"]).to be_nil
            expect(response_body["not_completed_items"]).to eq []
            expect(response_body["completed_items"]).to eq []
          end
        end
      end
    end
  end

  describe "GET /:id/edit" do
    describe "when list does not exist" do
      it "responds with 404" do
        get edit_v2_list_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "when user is not owner" do
      it "responds with forbidden" do
        get edit_v2_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "when user is owner" do
      before { list.update!(owner: user) }

      it "responds with success and correct payload" do
        get edit_v2_list_path(list.id), headers: auth_params
        response_body = JSON.parse(response.body).to_h

        expect(response_body).to eq(
          "archived_at" => list[:archived_at],
          "completed" => list[:completed],
          "id" => list[:id],
          "name" => list[:name],
          "refreshed" => list[:refreshed],
          "created_at" => list[:created_at].iso8601(3),
          "updated_at" => list[:updated_at].iso8601(3),
          "owner_id" => list[:owner_id],
          "type" => list[:type],
          "list_item_configuration_id" => nil
        )
      end
    end
  end

  describe "POST /" do
    describe "with valid params" do
      it "creates a new list" do
        expect do
          post v2_lists_path, params: { list: { user_id: user.id, name: "foo" } },
                              headers: auth_params
        end.to change(List, :count).by(1)
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["name"]).to eq("foo")
        expect(List.find_by(id: json["id"]).owner).to eq user
      end
    end

    describe "with invalid params" do
      it "responds with error" do
        post v2_lists_path, params: { list: { name: nil } }, headers: auth_params

        expect(JSON.parse(response.body)).to eq("name" => ["can't be blank"])
      end
    end
  end

  describe "PUT /:id" do
    describe "when list does not exist" do
      it "responds with 404" do
        put v2_list_path("foobar"), params: { list: { name: "bar" } }, headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    context "when user is not owner" do
      it "responds with forbidden" do
        put v2_list_path(list.id), params: { list: { name: "bar" } }, headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      describe "with valid params" do
        describe "when list is completed" do
          context "when prev and next list exist" do
            it "updates list and updates before and after lists" do
              prev_list = create(:list, name: "foo", owner: user)
              prev_user_list = create(:users_list, user: user, list: prev_list)
              next_list = create(:list, name: "bar", owner: user)
              next_user_list = create(:users_list, user: user, list: next_list)
              update_list = create(:list, name: "baz", owner: user)
              update_users_list = create(:users_list,
                                         user: user,
                                         list: update_list,
                                         prev_id: prev_user_list.id,
                                         next_id: next_user_list.id)
              prev_user_list.update!(next_id: update_users_list.id)
              next_user_list.update!(prev_id: update_users_list.id)

              put v2_list_path(update_list.id), params: { list: { completed: true } }, headers: auth_params

              update_list.reload
              update_users_list.reload
              prev_user_list.reload
              next_user_list.reload

              expect(update_list.completed).to be true
              expect(update_users_list.prev_id).to be_nil
              expect(update_users_list.next_id).to be_nil
              expect(prev_user_list.next_id).not_to eq update_users_list.id
              expect(next_user_list.prev_id).not_to eq update_users_list.id
            end
          end

          context "when prev and next list do not exist" do
            it "updates list" do
              update_list = create(:list, name: "baz", owner: user)
              create(:users_list, user: user, list: update_list)

              put v2_list_path(update_list.id), params: { list: { completed: true } }, headers: auth_params

              update_list.reload

              expect(update_list.completed).to be true
            end
          end
        end

        describe "when list is not completed" do
          it "updates a list" do
            update_list = create(:list, name: "foo", owner: user)

            put v2_list_path(update_list.id), params: { list: { name: "bar" } }, headers: auth_params

            update_list.reload

            expect(update_list.name).to eq "bar"
          end
        end
      end

      describe "with invalid params" do
        it "responds with errors" do
          list = create(:list, owner: user)
          put v2_list_path(list.id), params: { id: list.id, list: { name: nil } }, headers: auth_params

          expect(JSON.parse(response.body)).to eq("name" => ["can't be blank"])
        end
      end
    end
  end

  describe "DELETE /:id" do
    describe "when list does not exist" do
      it "responds with 404" do
        delete v2_list_path("foobar"), headers: auth_params

        expect(response).to have_http_status :not_found
      end
    end

    describe "when user is not owner" do
      it "responds with forbidden" do
        delete v2_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "when user is owner" do
      context "when previous and next list exist" do
        it "destroys a list and updates previous and next list" do
          prev_list = create(:list, name: "foo", owner: user)
          prev_user_list = create(:users_list, user: user, list: prev_list)
          next_list = create(:list, name: "bar", owner: user)
          next_user_list = create(:users_list, user: user, list: next_list)
          delete_list = create(:list, name: "foo", owner: user)
          delete_list_item = delete_list.list_items.create!(user: user)
          delete_users_list = create(:users_list,
                                     list: delete_list,
                                     user: user,
                                     prev_id: prev_user_list.id,
                                     next_id: next_user_list.id)
          prev_user_list.update!(next_id: delete_users_list.id)
          next_user_list.update!(prev_id: delete_users_list.id)

          delete v2_list_path(delete_list.id), headers: auth_params

          delete_list.reload
          delete_list_item.reload
          delete_users_list.reload
          prev_user_list.reload
          next_user_list.reload

          expect(List.not_archived).not_to include delete_list
          expect(delete_list.archived_at).not_to be_nil
          expect(delete_list_item.archived_at).not_to be_nil
          expect(delete_users_list.prev_id).to be_nil
          expect(delete_users_list.next_id).to be_nil
          expect(prev_user_list.next_id).not_to eq delete_users_list.id
          expect(next_user_list.prev_id).not_to eq delete_users_list.id
        end
      end

      context "when previous and next list do not exist" do
        it "destroys a list" do
          delete_list = create(:list, name: "foo", owner: user)
          create(:users_list, list: delete_list, user: user)

          delete v2_list_path(delete_list.id), headers: auth_params

          delete_list.reload

          expect(List.not_archived).not_to include delete_list
          expect(delete_list.archived_at).not_to be_nil
        end
      end

      context "when archive fails due to validation errors" do
        it "returns 422 unprocessable_entity" do
          delete_list = create(:list, name: "foo", owner: user)
          create(:users_list, list: delete_list, user: user)

          # Mock the archive method to raise validation error
          allow(List).to receive(:find).with(delete_list.id.to_s).and_return(delete_list)
          allow(delete_list).to receive(:archive).and_raise(
            ActiveRecord::RecordInvalid.new(delete_list)
          )

          delete v2_list_path(delete_list.id), headers: auth_params

          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end
  end
end
