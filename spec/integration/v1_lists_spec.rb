# frozen_string_literal: true

require "rails_helper"

describe "/v1/lists", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  before { login user }

  describe "GET /" do
    it "responds with success and correct payload" do
      get v1_lists_path, headers: auth_params

      response_body = JSON.parse(response.body)
      expect(response).to have_http_status :success
      expect(response_body["accepted_lists"].count).to eq user.accepted_lists.count
      expect(response_body["pending_lists"].count).to eq user.pending_lists.count
      expect(response_body["current_user_id"]).to eq user.id
    end
  end

  describe "GET /:id" do
    context "when a user has not been invited" do
      before { list.users_lists.delete_all }

      it "responds with forbidden" do
        get v1_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when a user has been invited" do
      context "when invitee has not accepted" do
        before do
          list.users_lists.find_by(user: user).update!(has_accepted: nil)
        end

        it "responds with forbidden" do
          get v1_list_path(list.id), headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      context "when invitee has accepted" do
        before { create(:users_list, user: user, list: list) }

        describe "when BookList" do
          let(:list) { BookList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            BookListItem.create!(
              user: user,
              list: list,
              title: "foo",
              purchased: false,
              category: "foo"
            )
            BookListItem.create!(user: user, list: list, title: "foobar", purchased: true)
            get v1_list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include("id" => list.id, "name" => list.name)
            expect(response_body["not_purchased_items"].first["id"])
              .to eq(BookListItem.where(list: list).not_archived.ordered.not_purchased.first.id)
            expect(response_body["purchased_items"].first["id"])
              .to eq(BookListItem.where(list: list).not_archived.ordered.purchased.first.id)
            expect(response_body["categories"]).to include "foo"
            expect(response_body["lists_to_update"]).to eq []
          end
        end

        describe "when GroceryList" do
          let(:list) { GroceryList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            GroceryListItem.create!(
              user: user,
              list: list,
              product: "foo",
              quantity: 1,
              purchased: false,
              category: "foo"
            )
            GroceryListItem.create!(
              user: user,
              list: list,
              product: "foobar",
              quantity: 1,
              purchased: true,
              refreshed: false
            )
            GroceryListItem.create!(
              user: user,
              list: list,
              product: "foobar",
              quantity: 1,
              purchased: true,
              refreshed: true
            )
            get v1_list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include("id" => list.id, "name" => list.name)
            expect(response_body["not_purchased_items"].first["id"])
              .to eq(GroceryListItem.where(list: list).not_archived.ordered.not_purchased.first.id)
            expect(response_body["purchased_items"].first["id"])
              .to eq(GroceryListItem.where(list: list).not_archived.ordered.purchased.not_refreshed.first.id)
            expect(response_body["categories"]).to include "foo"
            # curent list is not included in the lists_to_update array
            expect(response_body["lists_to_update"].count).to eq user.write_lists.count - 1
          end
        end

        describe "when MusicList" do
          let(:list) { MusicList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            MusicListItem.create!(
              user: user,
              list: list,
              title: "foo",
              purchased: false,
              category: "foo"
            )
            MusicListItem.create!(
              user: user,
              list: list,
              title: "foobar",
              purchased: true
            )
            get v1_list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include("id" => list.id, "name" => list.name)
            expect(response_body["not_purchased_items"].first["id"])
              .to eq(MusicListItem.where(list: list).not_archived.ordered.not_purchased.first.id)
            expect(response_body["purchased_items"].first["id"])
              .to eq(MusicListItem.where(list: list).not_archived.ordered.purchased.first.id)
            expect(response_body["categories"]).to include "foo"
            expect(response_body["lists_to_update"]).to eq []
          end
        end

        describe "when SimpleList" do
          let(:list) { SimpleList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            SimpleListItem.create!(
              user: user,
              list: list,
              content: "foo",
              completed: false,
              category: "foo"
            )
            SimpleListItem.create!(
              user: user,
              list: list,
              content: "foobar",
              completed: true
            )
            get v1_list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include("id" => list.id, "name" => list.name)
            expect(response_body["not_purchased_items"].first["id"])
              .to eq(SimpleListItem.where(list: list).not_archived.ordered.not_completed.first.id)
            expect(response_body["purchased_items"].first["id"])
              .to eq(SimpleListItem.where(list: list).not_archived.ordered.completed.first.id)
            expect(response_body["categories"]).to include "foo"
            expect(response_body["lists_to_update"]).to eq []
          end
        end

        describe "when ToDoList" do
          let(:list) { ToDoList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            ToDoListItem.create!(
              user: user,
              list: list,
              task: "foo",
              completed: false,
              category: "foo"
            )
            ToDoListItem.create!(
              user: user,
              list: list,
              task: "foobar",
              completed: true,
              refreshed: false
            )
            ToDoListItem.create!(
              user: user,
              list: list,
              task: "foobar",
              completed: true,
              refreshed: true
            )
            get v1_list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include("id" => list.id, "name" => list.name)
            expect(response_body["not_purchased_items"].first["id"])
              .to eq(ToDoListItem.where(list: list).not_archived.ordered.not_completed.first.id)
            expect(response_body["purchased_items"].first["id"])
              .to eq(ToDoListItem.where(list: list).not_archived.ordered.completed.not_refreshed.first.id)
            expect(response_body["categories"]).to include "foo"
            expect(response_body["lists_to_update"]).to eq []
          end
        end
      end
    end
  end

  describe "GET /:id/edit" do
    context "when user is not owner" do
      it "responds with forbidden" do
        get edit_v1_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      before { list.update!(owner: user) }

      it "responds with success and correct payload" do
        get edit_v1_list_path(list.id), headers: auth_params
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
      describe "when type is ToDoList" do
        it "creates a new list" do
          expect do
            post v1_lists_path, params: { list: { user_id: user.id, name: "foo", type: "ToDoList" } },
                                headers: auth_params
          end.to change(ToDoList, :count).by 1
          expect(ToDoList.last.owner).to eq user
        end
      end

      describe "when type is BookList" do
        it "creates a new list" do
          expect do
            post v1_lists_path, params: { list: { user_id: user.id, name: "foo", type: "BookList" } },
                                headers: auth_params
          end.to change(BookList, :count).by 1
          expect(BookList.last.owner).to eq user
        end
      end

      describe "when type is MusicList" do
        it "creates a new list" do
          expect do
            post v1_lists_path,
                 params: { list: { user_id: user.id, name: "foo", type: "MusicList" } },
                 headers: auth_params
          end.to change(MusicList, :count).by 1
          expect(MusicList.last.owner).to eq user
        end
      end

      describe "when type is GroceryList" do
        it "creates a new list" do
          expect do
            post v1_lists_path,
                 params: { list: { user_id: user.id, name: "foo", type: "GroceryList" } },
                 headers: auth_params
          end.to change(GroceryList, :count).by 1
          expect(GroceryList.last.owner).to eq user
        end
      end

      describe "when type is SimpleList" do
        it "creates a new list" do
          expect do
            post v1_lists_path,
                 params: { list: { user_id: user.id, name: "foo", type: "SimpleList" } },
                 headers: auth_params
          end.to change(SimpleList, :count).by 1
          expect(SimpleList.last.owner).to eq user
        end
      end

      describe "when type is not present" do
        it "creates a new list" do
          expect do
            post v1_lists_path, params: { list: { user_id: user.id, name: "foo" } }, headers: auth_params
          end.to change(GroceryList, :count).by 1
        end
      end
    end

    describe "with invalid params" do
      it "responds with error" do
        post v1_lists_path, params: { list: { name: nil } }, headers: auth_params

        expect(JSON.parse(response.body)).to eq("name" => ["can't be blank"])
      end
    end
  end

  describe "PUT /:id" do
    context "when user is not owner" do
      it "responds with forbidden" do
        put v1_list_path(list.id), params: { list: { name: "bar" } }, headers: auth_params

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
              put v1_list_path(update_list.id), params: { list: { completed: true } }, headers: auth_params
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

          context "when preiv and next list do not exist" do
            it "updates list" do
              update_list = create(:list, name: "baz", owner: user)
              create(:users_list, user: user, list: update_list)
              put v1_list_path(update_list.id), params: { list: { completed: true } }, headers: auth_params
              update_list.reload

              expect(update_list.completed).to be true
            end
          end
        end

        describe "when list is not completed" do
          it "updates a list" do
            update_list = create(:list, name: "foo", owner: user)
            put v1_list_path(update_list.id), params: { list: { name: "bar" } }, headers: auth_params
            update_list.reload

            expect(update_list.name).to eq "bar"
          end
        end
      end

      describe "with invalid params" do
        it "responds with errors" do
          list = create(:list, owner: user)
          put v1_list_path(list.id), params: { id: list.id, list: { name: nil } }, headers: auth_params

          expect(JSON.parse(response.body)).to eq("name" => ["can't be blank"])
        end
      end
    end
  end

  describe "DELETE /:id" do
    context "when user is not owner" do
      it "responds with forbidden" do
        delete v1_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      context "when previous and next list exist" do
        it "destroys a list and updates previous and next list" do
          prev_list = create(:list, name: "foo", owner: user)
          prev_user_list = create(:users_list, user: user, list: prev_list)
          next_list = create(:list, name: "bar", owner: user)
          next_user_list = create(:users_list, user: user, list: next_list)
          delete_list = create(:list, name: "foo", owner: user)
          delete_users_list = create(:users_list,
                                     list: delete_list,
                                     user: user,
                                     prev_id: prev_user_list.id,
                                     next_id: next_user_list.id)
          prev_user_list.update!(next_id: delete_users_list.id)
          next_user_list.update!(prev_id: delete_users_list.id)
          delete v1_list_path(delete_list.id), headers: auth_params
          delete_list.reload
          delete_users_list.reload
          prev_user_list.reload
          next_user_list.reload

          expect(List.not_archived).not_to include delete_list
          expect(delete_list.archived_at).not_to be_nil
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
          delete v1_list_path(delete_list.id), headers: auth_params
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

          delete v1_list_path(delete_list.id), headers: auth_params

          expect(response).to have_http_status :unprocessable_entity
        end
      end
    end
  end
end
