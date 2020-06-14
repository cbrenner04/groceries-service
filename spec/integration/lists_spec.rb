# frozen_string_literal: true

require "rails_helper"

describe "/lists", type: :request do
  let(:user) { create :user_with_lists }
  let(:list) { user.lists.last }

  before { login user }

  describe "GET /" do
    it "responds with success and correct payload" do
      get lists_path, headers: auth_params

      response_body = JSON.parse(response.body)
      expect(response).to have_http_status :success
      expect(response_body["accepted_lists"].count)
        .to eq user.accepted_lists.count
      expect(response_body["pending_lists"].count)
        .to eq user.pending_lists.count
      expect(response_body["current_user_id"]).to eq user.id
    end
  end

  describe "GET /:id" do
    context "when a user has not been invited" do
      before { list.users_lists.delete_all }

      it "responds with forbidden" do
        get list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when a user has been invited" do
      context "when invitee has not accepted" do
        before do
          list.users_lists.find_by(user: user).update!(has_accepted: nil)
        end

        it "responds with forbidden" do
          get list_path(list.id), headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      context "when invitee has accepted" do
        before { create :users_list, user: user, list: list }

        describe "when BookList" do
          let(:list) { BookList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            BookListItem.create!(
              user_id: user.id,
              book_list_id: list.id,
              title: "foo",
              purchased: false,
              category: "foo"
            )
            BookListItem.create!(
              user_id: user.id,
              book_list_id: list.id,
              title: "foobar",
              purchased: true
            )
            get list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include(
              "id" => list.id,
              "name" => list.name
            )
            expect(response_body["not_purchased_items"].first["id"]).to eq(
              BookListItem.where(book_list: list)
              .not_archived.ordered.not_purchased.first.id
            )
            expect(response_body["purchased_items"].first["id"]).to eq(
              BookListItem.where(book_list: list)
              .not_archived.ordered.purchased.first.id
            )
            expect(response_body["categories"]).to include "foo"
          end
        end

        describe "when GroceryList" do
          let(:list) { GroceryList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            GroceryListItem.create!(
              user_id: user.id,
              grocery_list_id: list.id,
              product: "foo",
              quantity: 1,
              purchased: false,
              category: "foo"
            )
            GroceryListItem.create!(
              user_id: user.id,
              grocery_list_id: list.id,
              product: "foobar",
              quantity: 1,
              purchased: true,
              refreshed: false
            )
            GroceryListItem.create!(
              user_id: user.id,
              grocery_list_id: list.id,
              product: "foobar",
              quantity: 1,
              purchased: true,
              refreshed: true
            )
            get list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include(
              "id" => list.id,
              "name" => list.name
            )
            expect(response_body["not_purchased_items"].first["id"]).to eq(
              GroceryListItem.where(grocery_list: list)
              .not_archived.ordered.not_purchased.first.id
            )
            expect(response_body["purchased_items"].first["id"]).to eq(
              GroceryListItem.where(grocery_list: list)
              .not_archived.ordered.purchased.not_refreshed.first.id
            )
            expect(response_body["categories"]).to include "foo"
          end
        end

        describe "when MusicList" do
          let(:list) { MusicList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            MusicListItem.create!(
              user_id: user.id,
              music_list_id: list.id,
              title: "foo",
              purchased: false,
              category: "foo"
            )
            MusicListItem.create!(
              user_id: user.id,
              music_list_id: list.id,
              title: "foobar",
              purchased: true
            )
            get list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include(
              "id" => list.id,
              "name" => list.name
            )
            expect(response_body["not_purchased_items"].first["id"]).to eq(
              MusicListItem.where(music_list: list)
              .not_archived.ordered.not_purchased.first.id
            )
            expect(response_body["purchased_items"].first["id"]).to eq(
              MusicListItem.where(music_list: list)
              .not_archived.ordered.purchased.first.id
            )
            expect(response_body["categories"]).to include "foo"
          end
        end

        describe "when ToDoList" do
          let(:list) { ToDoList.create!(name: "foo", owner: user) }

          it "responds with success and correct payload" do
            ToDoListItem.create!(
              user_id: user.id,
              to_do_list_id: list.id,
              task: "foo",
              completed: false,
              category: "foo"
            )
            ToDoListItem.create!(
              user_id: user.id,
              to_do_list_id: list.id,
              task: "foobar",
              completed: true,
              refreshed: false
            )
            ToDoListItem.create!(
              user_id: user.id,
              to_do_list_id: list.id,
              task: "foobar",
              completed: true,
              refreshed: true
            )
            get list_path(list.id), headers: auth_params

            response_body = JSON.parse(response.body)
            expect(response).to be_successful
            expect(response_body["current_user_id"]).to eq user.id
            expect(response_body["list"]).to include(
              "id" => list.id,
              "name" => list.name
            )
            expect(response_body["not_purchased_items"].first["id"]).to eq(
              ToDoListItem.where(to_do_list: list)
              .not_archived.ordered.not_completed.first.id
            )
            expect(response_body["purchased_items"].first["id"]).to eq(
              ToDoListItem.where(to_do_list: list)
              .not_archived.ordered.completed.not_refreshed.first.id
            )
            expect(response_body["categories"]).to include "foo"
          end
        end
      end
    end
  end

  describe "GET /:id/edit" do
    context "when user is not owner" do
      it "responds with forbidden" do
        get edit_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      before { list.update!(owner: user) }

      it "responds with success and correct payload" do
        get edit_list_path(list.id), headers: auth_params
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
          "type" => list[:type]
        )
      end
    end
  end

  describe "POST /" do
    describe "with valid params" do
      describe "when type is ToDoList" do
        it "creates a new list" do
          expect do
            post lists_path,
                 params: {
                   list: {
                     user_id: user.id,
                     name: "foo",
                     type: "ToDoList"
                   }
                 },
                 headers: auth_params
          end.to change(ToDoList, :count).by 1
          expect(ToDoList.last.owner).to eq user
        end
      end

      describe "when type is BookList" do
        it "creates a new list" do
          expect do
            post lists_path,
                 params: {
                   list: {
                     user_id: user.id,
                     name: "foo",
                     type: "BookList"
                   }
                 },
                 headers: auth_params
          end.to change(BookList, :count).by 1
          expect(BookList.last.owner).to eq user
        end
      end

      describe "when type is MusicList" do
        it "creates a new list" do
          expect do
            post lists_path,
                 params: {
                   list: {
                     user_id: user.id,
                     name: "foo",
                     type: "MusicList"
                   }
                 },
                 headers: auth_params
          end.to change(MusicList, :count).by 1
          expect(MusicList.last.owner).to eq user
        end
      end

      describe "when type is GroceryList" do
        it "creates a new list" do
          expect do
            post lists_path,
                 params: {
                   list: {
                     user_id: user.id,
                     name: "foo",
                     type: "GroceryList"
                   }
                 },
                 headers: auth_params
          end.to change(GroceryList, :count).by 1
          expect(GroceryList.last.owner).to eq user
        end
      end

      describe "when type is not present" do
        it "creates a new list" do
          expect do
            post lists_path,
                 params: {
                   list: {
                     user_id: user.id,
                     name: "foo"
                   }
                 },
                 headers: auth_params
          end.to change(GroceryList, :count).by 1
        end
      end
    end

    describe "with invalid params" do
      it "responds with error" do
        post lists_path,
             params: {
               list: {
                 name: nil
               }
             },
             headers: auth_params

        expect(JSON.parse(response.body))
          .to eq("name" => ["can't be blank"])
      end
    end
  end

  describe "PUT /:id" do
    context "when user is not owner" do
      it "responds with forbidden" do
        put list_path(list.id),
            params: {
              list: {
                name: "bar"
              }
            },
            headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      describe "with valid params" do
        it "updates a list" do
          update_list = create :list, name: "foo", owner: user
          put list_path(update_list.id),
              params: {
                list: {
                  name: "bar"
                }
              },
              headers: auth_params
          update_list.reload

          expect(update_list.name).to eq "bar"
        end
      end

      describe "with invalid params" do
        it "responds with errors" do
          list = create :list, owner: user
          put list_path(list.id),
              params: {
                id: list.id,
                list: {
                  name: nil
                }
              },
              headers: auth_params

          expect(JSON.parse(response.body))
            .to eq("name" => ["can't be blank"])
        end
      end
    end
  end

  describe "DELETE /:id" do
    context "when user is not owner" do
      it "responds with forbidden" do
        delete list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      it "destroys a list" do
        delete_list = create :list, name: "foo", owner: user
        delete list_path(delete_list.id), headers: auth_params
        delete_list.reload

        expect(List.not_archived).not_to include delete_list
        expect(delete_list.archived_at).not_to be_nil
      end
    end
  end
end
