# frozen_string_literal: true

RSpec.shared_examples "a list item" do |list_type, required_attrs, item_attrs|
  list_item_class = {
    book_list: BookListItem,
    grocery_list: GroceryListItem,
    music_list: MusicListItem,
    simple_list: SimpleListItem,
    to_do_list: ToDoListItem
  }[list_type.to_sym]

  before { login user }

  describe "GET /:id/edit" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        get edit_list_list_item_path(list.id, item.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      describe "when item does not exist" do
        it "responds with 404" do
          get edit_list_list_item_path(list.id, "fake_id"), headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      describe "when item does exist" do
        it "responds with 200 and correct body" do
          get edit_list_list_item_path(list.id, item.id), headers: auth_params

          response_body = JSON.parse(response.body).to_h

          expect(response).to have_http_status :success
          # TODO: need to have list_users checked for ToDoListItems
          item_attrs.each do |item_attr|
            value = item_attr == "due_by" ? item[item_attr.to_sym].iso8601(3) : item[item_attr.to_sym]

            expect(response_body["item"][item_attr]).to eq value
          end
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
  end

  describe "POST /" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        post list_list_items_path(list.id),
             params: {
               list_item: {
                 list_id: list.id,
                 user_id: user.id,
                 required_attrs[0].to_sym => "foo",
                 category: "foo"
               }
             },
             headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      describe "when list does not exist" do
        it "returns 403" do
          post list_list_items_path("fake_id"),
               params: {
                 list_item: {
                   list_id: "fake_id",
                   user_id: user.id,
                   required_attrs[0].to_sym => "foo",
                   category: "foo"
                 }
               },
               headers: auth_params

          expect(response).to have_http_status :forbidden
        end
      end

      describe "when list does exist" do
        describe "with valid params" do
          it "creates a new item" do
            expect do
              post list_list_items_path(list.id),
                   params: {
                     list_item: {
                       list_id: list.id,
                       user_id: user.id,
                       required_attrs[0].to_sym => "foo",
                       category: "foo"
                     }
                   },
                   headers: auth_params
            end.to change(list_item_class, :count).by 1
          end
        end

        describe "with invalid params" do
          it "returns 422 and error message" do
            post list_list_items_path(list.id),
                 params: { list_item: { list_id: list.id, required_attrs[0].to_sym => nil } },
                 headers: auth_params

            expect(response).to have_http_status :unprocessable_entity
            expect(response.body).not_to be_blank
          end
        end
      end
    end
  end

  describe "PUT /:id" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        update_item = create(:"#{list_type}_item", required_attrs[0].to_sym => "foo", list: list)
        put list_list_item_path(list.id, update_item.id),
            params: { id: update_item.id, list_item: { required_attrs[0].to_sym => "bar" } },
            headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      describe "when item does not exist" do
        it "returns 404" do
          put list_list_item_path(list.id, "fake_id"),
              params: { list_item: { required_attrs[0].to_sym => "bar" } },
              headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      describe "when item does exist" do
        describe "with valid data" do
          it "updates item" do
            update_item = create(:"#{list_type}_item", required_attrs[0].to_sym => "foo", list: list)
            put list_list_item_path(list.id, update_item.id),
                params: { list_item: { required_attrs[0].to_sym => "bar" } },
                headers: auth_params
            update_item.reload

            expect(update_item[required_attrs[0].to_sym]).to eq "bar"
          end
        end

        describe "with invalid data" do
          it "return 422 and error message" do
            params = {}
            required_attrs.each { |attr| params[attr.to_sym] = "" }
            update_item = create(:"#{list_type}_item", required_attrs[0].to_sym => "foo", list: list)
            put list_list_item_path(list.id, update_item.id),
                params: { list_item: params },
                headers: auth_params

            expect(response).to have_http_status :unprocessable_entity
            expect(response.body).not_to be_blank
          end
        end
      end
    end
  end

  describe "DELETE /:id" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        delete_item = create(:"#{list_type}_item", required_attrs[0].to_sym => "foo", list: list)
        delete list_list_item_path(list.id, delete_item.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      describe "when item does not exist" do
        it "responds with 404" do
          delete list_list_item_path(list.id, "fake_id"), headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      describe "when item does exist" do
        it "destroys a item" do
          delete_item = create(:"#{list_type}_item", required_attrs[0].to_sym => "foo", list: list)
          delete list_list_item_path(list.id, delete_item.id), headers: auth_params
          delete_item.reload

          expect(list_item_class.not_archived).not_to include delete_item
          expect(delete_item.archived_at).not_to be_nil
        end
      end
    end
  end
end
