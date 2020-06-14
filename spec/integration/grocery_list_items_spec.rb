# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/grocery_list_items", type: :request do
  let(:user) { create :user }
  let(:list) { create :grocery_list, owner: user }
  let!(:users_list) { create :users_list, user: user, list: list }
  let(:item) { create :grocery_list_item, grocery_list: list }

  before { login user }

  describe "GET /:id/edit" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "redirects to lists_path" do
        get edit_list_grocery_list_item_path(list.id, item.id),
            headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      it "responds with success and correct payload" do
        get edit_list_grocery_list_item_path(list.id, item.id),
            headers: auth_params

        expect(response).to be_successful
        response_body = JSON.parse(response.body).to_h
        expect(response_body["item"]).to eq(
          "archived_at" => item[:archived_at],
          "id" => item[:id],
          "grocery_list_id" => item[:grocery_list_id],
          "product" => item[:product],
          "purchased" => item[:purchased],
          "quantity" => item[:quantity],
          "refreshed" => item[:refreshed],
          "user_id" => item[:user_id],
          "category" => item[:category],
          "created_at" => item[:created_at].iso8601(3),
          "updated_at" => item[:updated_at].iso8601(3)
        )
        expect(response_body["list"]).to eq(
          "id" => list[:id],
          "name" => list[:name],
          "archived_at" => list[:archived_at],
          "completed" => list[:completed],
          "refreshed" => list[:refreshed],
          "type" => list[:type],
          "owner_id" => list[:owner_id],
          "created_at" => list[:created_at].iso8601(3),
          "updated_at" => list[:updated_at].iso8601(3)
        )
        expect(response_body["categories"]).to eq(list.categories)
      end
    end
  end

  describe "POST /" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        post list_grocery_list_items_path(list.id),
             params: {
               grocery_list_item: {
                 grocery_list_id: list.id,
                 user_id: user.id,
                 product: "foo",
                 category: "foo"
               }
             },
             headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      describe "with valid params" do
        it "creates a new item" do
          expect do
            post list_grocery_list_items_path(list.id),
                 params: {
                   grocery_list_item: {
                     grocery_list_id: list.id,
                     user_id: user.id,
                     product: "foo",
                     category: "foo"
                   }
                 },
                 headers: auth_params
          end.to change(GroceryListItem, :count).by 1
        end
      end

      describe "with invalid params" do
        it "returns 422 and error message" do
          post list_grocery_list_items_path(list.id),
               params: {
                 grocery_list_item: {
                   grocery_list_id: list.id,
                   product: nil
                 }
               },
               headers: auth_params

          expect(response.status).to eq 422
          expect(response.body).not_to be_blank
        end
      end
    end
  end

  describe "PUT /:id" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        update_item = create :grocery_list_item, product: "foo"
        put list_grocery_list_item_path(list.id, update_item.id),
            params: {
              grocery_list_item: {
                product: "bar"
              }
            },
            headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      describe "with valid params" do
        it "updates a item" do
          update_item = create :grocery_list_item, product: "foo"
          put list_grocery_list_item_path(list.id, update_item.id),
              params: {
                grocery_list_item: {
                  product: "bar"
                }
              },
              headers: auth_params
          update_item.reload

          expect(update_item.product).to eq "bar"
        end
      end

      describe "with invalid params" do
        it "returns 422 and error message" do
          update_item = create :grocery_list_item
          put list_grocery_list_item_path(list.id, update_item.id),
              params: {
                grocery_list_item: {
                  product: nil
                }
              },
              headers: auth_params

          expect(response.status).to eq 422
          expect(response.body).not_to be_blank
        end
      end
    end
  end

  describe "DELETE /:id" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        delete_item = create :grocery_list_item, product: "foo"
        delete list_grocery_list_item_path(list.id, delete_item.id),
               headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      it "destroys a item" do
        delete_item = create :grocery_list_item, product: "foo"
        delete list_grocery_list_item_path(list.id, delete_item.id),
               headers: auth_params
        delete_item.reload

        expect(GroceryListItem.not_archived).not_to include delete_item
        expect(delete_item.archived_at).not_to be_nil
      end
    end
  end
end
