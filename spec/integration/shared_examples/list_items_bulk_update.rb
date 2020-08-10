# frozen_string_literal: true

RSpec.shared_examples "a list items bulk update" do |list_type, new_item_attrs, update_attrs|
  list_item_class = {
    book_list: BookListItem,
    grocery_list: GroceryListItem,
    music_list: MusicListItem,
    to_do_list: ToDoListItem
  }[list_type.to_sym]

  before { login user }

  describe "GET /" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        get "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}", headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      context "when one item does not exist" do
        it "response with not found" do
          get "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{[item.id, 'fake_id'].join(',')}",
              headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      context "when all items exist" do
        it "responds with 200 and correct body" do
          other_list = create list_type.to_sym, owner: user
          other_users_list = create :users_list, user: user, list: other_list

          get "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}", headers: auth_params

          response_body = JSON.parse(response.body).to_h
          complete_attr = list_type == "to_do_list" ? "completed" : "purchased"
          item_attrs = new_item_attrs.concat(["id", "#{list_type}_id", complete_attr, "user_id", "category"])

          expect(response).to have_http_status :success
          expect(response_body["items"].count).to eq 2
          item_attrs.each do |item_attr|
            if item_attr == "due_by"
              expect(response_body["items"][0][item_attr]).to eq item[item_attr.to_sym].iso8601(3)
              expect(response_body["items"][1][item_attr]).to eq other_item[item_attr.to_sym].iso8601(3)
            else
              expect(response_body["items"][0][item_attr]).to eq item[item_attr.to_sym]
              expect(response_body["items"][1][item_attr]).to eq other_item[item_attr.to_sym]
            end
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
          expect(response_body["lists"].count).to eq 1
          expect(response_body["lists"][0]).to eq(
            "id" => other_list[:id],
            "name" => other_list[:name],
            "completed" => other_list[:completed],
            "refreshed" => other_list[:refreshed],
            "type" => other_list[:type],
            "owner_id" => other_list[:owner_id],
            "created_at" => other_list[:created_at].iso8601(3),
            "has_accepted" => true,
            "user_id" => user.id,
            "users_list_id" => other_users_list.id
          )
        end
      end
    end
  end

  describe "PUT /" do
    update_params = {}
    due_by_date = DateTime.new(2020, 0o2, 0o2)

    before do
      update_params = {
        "#{list_type}_items": {
          category: "updated category",
          clear_category: true
        }
      }
      update_attrs.each do |attr|
        update_params["#{list_type}_items".to_sym][attr.to_sym] = if attr == "assignee_id"
                                                                    other_user.id
                                                                  elsif attr == "due_by"
                                                                    due_by_date
                                                                  else
                                                                    "updated #{attr}"
                                                                  end
        update_params["#{list_type}_items".to_sym]["clear_#{attr}".to_sym] = false
      end
    end

    describe "with read access" do
      before do
        users_list.update!(permissions: "read")
        update_params["#{list_type}_items".to_sym][:copy] = true
      end

      it "responds with forbidden" do
        put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
            headers: auth_params,
            params: update_params,
            as: :json

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      context "when one of the items does not exist" do
        it "responds with not found" do
          update_params["#{list_type}_items".to_sym][:copy] = true
          update_params["#{list_type}_items".to_sym][:new_list_name] = "bulk update list"
          put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{[item.id, 'fake_id'].join(',')}",
              headers: auth_params,
              params: update_params,
              as: :json

          puts response.body

          expect(response).to have_http_status :not_found
          expect(response.body).to eq "One or more items were not found"
        end
      end

      context "when all items exist" do
        describe "with valid params" do
          context "when update current items is requsted" do
            it "updates current items" do
              initial_item_values = {
                category: item.category
              }
              initial_other_item_values = {
                category: other_item.category
              }
              update_attrs.each do |attr|
                initial_item_values[attr.to_sym] = item[attr.to_sym]
                initial_other_item_values[attr.to_sym] = other_item[attr.to_sym]
              end
              update_params["#{list_type}_items".to_sym][:copy] = true
              update_params["#{list_type}_items".to_sym][:update_current_items] = true
              update_params["#{list_type}_items".to_sym][:new_list_name] = "bulk update list"

              put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
                  headers: auth_params,
                  params: update_params,
                  as: :json
              item.reload
              other_item.reload

              expect(response).to have_http_status :no_content
              update_attrs.each do |attr|
                expect(item[attr.to_sym]).not_to eq(initial_item_values[attr.to_sym])
                expect(other_item[attr.to_sym]).not_to eq(initial_other_item_values[attr.to_sym])
                if attr == "assignee_id"
                  expect(item[attr.to_sym]).to eq other_user.id
                  expect(other_item[attr.to_sym]).to eq other_user.id
                elsif attr == "due_by"
                  expect(item[attr.to_sym]).to eq due_by_date.iso8601(3)
                  expect(other_item[attr.to_sym]).to eq due_by_date.iso8601(3)
                else
                  expect(item[attr.to_sym]).to eq "updated #{attr}"
                  expect(other_item[attr.to_sym]).to eq "updated #{attr}"
                end
              end
              expect(item.category).not_to eq(initial_item_values[:category])
              expect(other_item.category).not_to eq(initial_other_item_values[:category])
              expect(item.category).to eq(nil)
              expect(other_item.category).to eq(nil)
            end
          end

          context "when update current items is not requested" do
            it "does not update current items" do
              initial_item_values = {
                category: item.category
              }
              initial_other_item_values = {
                category: other_item.category
              }
              update_attrs.each do |attr|
                initial_item_values[attr.to_sym] = item[attr.to_sym]
                initial_other_item_values[attr.to_sym] = other_item[attr.to_sym]
              end
              update_params["#{list_type}_items".to_sym][:copy] = true
              update_params["#{list_type}_items".to_sym][:update_current_items] = false
              update_params["#{list_type}_items".to_sym][:new_list_name] = "bulk update list"

              put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
                  headers: auth_params,
                  params: update_params,
                  as: :json
              item.reload
              other_item.reload

              expect(response).to have_http_status :no_content
              update_attrs.each do |attr|
                expect(item[attr.to_sym]).to eq(initial_item_values[attr.to_sym])
                expect(other_item[attr.to_sym]).to eq(initial_other_item_values[attr.to_sym])
                if attr == "assignee_id"
                  expect(item[attr.to_sym]).not_to eq other_user.id
                  expect(other_item[attr.to_sym]).not_to eq other_user.id
                elsif attr == "due_by"
                  expect(item[attr.to_sym]).not_to eq due_by_date.iso8601(3)
                  expect(other_item[attr.to_sym]).not_to eq due_by_date.iso8601(3)
                else
                  expect(item[attr.to_sym]).not_to eq "updated #{attr}"
                  expect(other_item[attr.to_sym]).not_to eq "updated #{attr}"
                end
              end
              expect(item.category).to eq(initial_item_values[:category])
              expect(other_item.category).to eq(initial_other_item_values[:category])
              expect(item.category).not_to eq(nil)
              expect(other_item.category).not_to eq(nil)
            end
          end

          describe "when move is requested" do
            before { update_params["#{list_type}_items".to_sym][:move] = true }

            describe "when new list is requested" do
              it "creates new list, new items, and archives current items" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                update_params["#{list_type}_items".to_sym][:new_list_name] = "bulk update list"
                update_params["#{list_type}_items".to_sym][:update_current_items] = false

                put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
                    headers: auth_params,
                    params: update_params,
                    as: :json
                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update list")
                new_items = list_item_class.where("#{list_type}_id": new_list.id)

                expect(item.archived_at).to be_truthy
                expect(other_item.archived_at).to be_truthy
                expect(new_list).to be_truthy
                attrs_to_skip = ["id", "user_id", "#{list_type}_id", "category"]
                new_item_attrs.each do |item_attr|
                  next if update_attrs.include?(item_attr) || attrs_to_skip.include?(item_attr)

                  expect(new_items[0][item_attr.to_sym]).to eq item[item_attr.to_sym]
                  expect(new_items[1][item_attr.to_sym]).to eq other_item[item_attr.to_sym]
                end
                update_attrs.each do |attr|
                  if attr == "assignee_id"
                    expect(new_items[0][attr.to_sym]).to eq other_user.id
                    expect(new_items[1][attr.to_sym]).to eq other_user.id
                  elsif attr == "due_by"
                    expect(new_items[0][attr.to_sym]).to eq due_by_date.iso8601(3)
                    expect(new_items[1][attr.to_sym]).to eq due_by_date.iso8601(3)
                  else
                    expect(new_items[0][attr.to_sym]).to eq "updated #{attr}"
                    expect(new_items[1][attr.to_sym]).to eq "updated #{attr}"
                  end
                end
                expect(new_items[0].category).to eq nil
                expect(new_items[1].category).to eq nil
              end
            end

            describe "when existing list is requested" do
              it "does not create list, creates new items, and archives current items" do
                other_list = create list_type.to_sym, owner: user
                create :users_list, user: user, list: other_list

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                update_params["#{list_type}_items".to_sym][:existing_list_id] = other_list.id

                put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
                    headers: auth_params,
                    params: update_params,
                    as: :json
                item.reload
                other_item.reload
                new_items = list_item_class.where("#{list_type}_id": other_list.id)

                expect(item.archived_at).to be_truthy
                expect(other_item.archived_at).to be_truthy
                attrs_to_skip = ["id", "user_id", "#{list_type}_id", "category"]
                new_item_attrs.each do |item_attr|
                  next if update_attrs.include?(item_attr) || attrs_to_skip.include?(item_attr)

                  expect(new_items[0][item_attr.to_sym]).to eq item[item_attr.to_sym]
                  expect(new_items[1][item_attr.to_sym]).to eq other_item[item_attr.to_sym]
                end
                update_attrs.each do |attr|
                  if attr == "assignee_id"
                    expect(new_items[0][attr.to_sym]).to eq other_user.id
                    expect(new_items[1][attr.to_sym]).to eq other_user.id
                  elsif attr == "due_by"
                    expect(new_items[0][attr.to_sym]).to eq due_by_date.iso8601(3)
                    expect(new_items[1][attr.to_sym]).to eq due_by_date.iso8601(3)
                  else
                    expect(new_items[0][attr.to_sym]).to eq "updated #{attr}"
                    expect(new_items[1][attr.to_sym]).to eq "updated #{attr}"
                  end
                end
                expect(new_items[0].category).to eq nil
                expect(new_items[1].category).to eq nil
              end
            end
          end

          describe "when copy is requested" do
            before { update_params["#{list_type}_items".to_sym][:copy] = true }

            describe "when new list is requested" do
              it "does not archive items, creates new list and items" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(List.find_by(name: "new list")).to be_nil

                update_params["#{list_type}_items".to_sym][:new_list_name] = "bulk update list"

                put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
                    headers: auth_params,
                    params: update_params,
                    as: :json
                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update list")
                new_items = list_item_class.where("#{list_type}_id": new_list.id)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(new_list).to be_truthy
                attrs_to_skip = ["id", "user_id", "#{list_type}_id", "category"]
                new_item_attrs.each do |item_attr|
                  next if update_attrs.include?(item_attr) || attrs_to_skip.include?(item_attr)

                  expect(new_items[0][item_attr.to_sym]).to eq item[item_attr.to_sym]
                  expect(new_items[1][item_attr.to_sym]).to eq other_item[item_attr.to_sym]
                end
                update_attrs.each do |attr|
                  if attr == "assignee_id"
                    expect(new_items[0][attr.to_sym]).to eq other_user.id
                    expect(new_items[1][attr.to_sym]).to eq other_user.id
                  elsif attr == "due_by"
                    expect(new_items[0][attr.to_sym]).to eq due_by_date.iso8601(3)
                    expect(new_items[1][attr.to_sym]).to eq due_by_date.iso8601(3)
                  else
                    expect(new_items[0][attr.to_sym]).to eq "updated #{attr}"
                    expect(new_items[1][attr.to_sym]).to eq "updated #{attr}"
                  end
                end
                expect(new_items[0].category).to eq nil
                expect(new_items[1].category).to eq nil
              end
            end

            describe "when existing list is requested" do
              it "does not create list or archive items, creates new items" do
                other_list = create list_type.to_sym, owner: user
                create :users_list, user: user, list: other_list

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                update_params["#{list_type}_items".to_sym][:existing_list_id] = other_list.id

                put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
                    headers: auth_params,
                    params: update_params,
                    as: :json
                item.reload
                other_item.reload
                new_items = list_item_class.where("#{list_type}_id": other_list.id)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                attrs_to_skip = ["id", "user_id", "#{list_type}_id", "category"]
                new_item_attrs.each do |item_attr|
                  next if update_attrs.include?(item_attr) || attrs_to_skip.include?(item_attr)

                  expect(new_items[0][item_attr.to_sym]).to eq item[item_attr.to_sym]
                  expect(new_items[1][item_attr.to_sym]).to eq other_item[item_attr.to_sym]
                end
                update_attrs.each do |attr|
                  if attr == "assignee_id"
                    expect(new_items[0][attr.to_sym]).to eq other_user.id
                    expect(new_items[1][attr.to_sym]).to eq other_user.id
                  elsif attr == "due_by"
                    expect(new_items[0][attr.to_sym]).to eq due_by_date.iso8601(3)
                    expect(new_items[1][attr.to_sym]).to eq due_by_date.iso8601(3)
                  else
                    expect(new_items[0][attr.to_sym]).to eq "updated #{attr}"
                    expect(new_items[1][attr.to_sym]).to eq "updated #{attr}"
                  end
                end
                expect(new_items[0].category).to eq nil
                expect(new_items[1].category).to eq nil
              end
            end
          end
        end

        describe "with invalid params" do
          it "returns unproccessable entity" do
            other_list = create list_type.to_sym, owner: user
            create :users_list, user: user, list: other_list

            update_params["#{list_type}_items".to_sym][:copy] = true

            put "#{send("list_#{list_type}_items_bulk_update_path", list.id)}?item_ids=#{item_ids}",
                headers: auth_params,
                params: update_params,
                as: :json

            expect(response).to have_http_status :unprocessable_entity
          end
        end
      end
    end
  end
end
