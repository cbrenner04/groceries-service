# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/NestedGroups
describe "/lists/:list_id/to_do_list_items/bulk_update", type: :request do
  let(:user) { create :user }
  let(:list) { create :to_do_list, owner: user }
  let(:users_list) { create :users_list, user: user, list: list }
  let(:item) { create :to_do_list_item, to_do_list: list }
  let(:other_item) { create :to_do_list_item, to_do_list: list }
  let(:other_user) { create :user }
  let(:item_ids) { [item.id, other_item.id].join(",") }

  before { login user }

  describe "GET /" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        get "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
          item_ids
        }", headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      context "when one item does not exist" do
        it "response with not found" do
          get "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
            [item.id, 'bogus_id'].join(',')
          }", headers: auth_params

          expect(response).to have_http_status :not_found
        end
      end

      context "when all items exist" do
        it "responds with 200 and correct body" do
          other_list = create :to_do_list, owner: user
          other_users_list = create :users_list, user: user, list: other_list

          get "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
            item_ids
          }", headers: auth_params

          response_body = JSON.parse(response.body).to_h

          expect(response).to have_http_status :success
          expect(response_body["items"].count).to eq 2
          expect(response_body["items"][0]).to eq(
            "archived_at" => item[:archived_at],
            "id" => item[:id],
            "to_do_list_id" => item[:to_do_list_id],
            "assignee_id" => item[:assignee_id],
            "completed" => item[:completed],
            "refreshed" => item[:refreshed],
            "task" => item[:task],
            "due_by" => item[:due_by].iso8601(3),
            "user_id" => item[:user_id],
            "category" => item[:category],
            "created_at" => item[:created_at].iso8601(3),
            "updated_at" => item[:updated_at].iso8601(3)
          )
          expect(response_body["items"][1]).to eq(
            "archived_at" => other_item[:archived_at],
            "id" => other_item[:id],
            "to_do_list_id" => other_item[:to_do_list_id],
            "assignee_id" => other_item[:assignee_id],
            "completed" => other_item[:completed],
            "refreshed" => other_item[:refreshed],
            "task" => other_item[:task],
            "due_by" => other_item[:due_by].iso8601(3),
            "user_id" => other_item[:user_id],
            "category" => other_item[:category],
            "created_at" => other_item[:created_at].iso8601(3),
            "updated_at" => other_item[:updated_at].iso8601(3)
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
          expect(response_body["list_users"].count).to eq 1
          user.reload # user gets updated with log in so needs to be reloaded
          expect(response_body["list_users"][0]).to eq(
            "allow_password_change" => user[:allow_password_change],
            "created_at" => user[:created_at].iso8601(3),
            "email" => user[:email],
            "id" => user[:id],
            "is_test_account" => user[:is_test_account],
            "provider" => user[:provider],
            "uid" => user[:email],
            "updated_at" => user[:updated_at].iso8601(3)
          )
        end
      end
    end
  end

  describe "PUT /" do
    describe "with read access" do
      before { users_list.update!(permissions: "read") }

      it "responds with forbidden" do
        put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
          item_ids
        }", headers: auth_params, params: {
          to_do_list_items: {
            assignee_id: other_user.id,
            clear_assignee: false,
            due_by: nil,
            clear_due_by: false,
            category: "foo",
            clear_category: false,
            copy: true,
            new_list_name: "sweet new list",
            update_current_items: true
          }
        }, as: :json

        expect(response).to have_http_status :forbidden
      end
    end

    describe "with write access" do
      before { users_list.update!(permissions: "write") }

      context "when one of the items does not exist" do
        it "responds with not found" do
          put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
            [item.id, 'bogus_id'].join(',')
          }", headers: auth_params, params: {
            to_do_list_items: {
              assignee_id: other_user.id,
              clear_assignee: false,
              due_by: nil,
              clear_due_by: false,
              category: "foo",
              clear_category: false,
              copy: true,
              new_list_name: "sweet new list",
              update_current_items: true
            }
          }, as: :json

          expect(response).to have_http_status :not_found
          expect(response.body).to eq "One or more items were not found"
        end
      end

      context "when all items exist" do
        describe "with valid params" do
          context "when update current items is requsted" do
            it "updates current items" do
              initial_assignee_id = item.assignee_id
              initial_category = item.category
              initial_due_by = item.due_by
              initial_other_assignee_id = other_item.assignee_id
              initial_other_category = other_item.category
              initial_other_due_by = other_item.due_by

              expect(item.assignee_id).to eq(initial_assignee_id)
              expect(item.category).to eq(initial_category)
              expect(other_item.assignee_id).to eq(initial_other_assignee_id)
              expect(other_item.category).to eq(initial_other_category)

              put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
                item_ids
              }", headers: auth_params, params: {
                to_do_list_items: {
                  assignee_id: other_user.id,
                  clear_assignee: false,
                  due_by: nil,
                  clear_due_by: false,
                  category: "update category",
                  clear_category: true,
                  update_current_items: true
                }
              }, as: :json
              item.reload
              other_item.reload

              expect(response).to have_http_status :no_content
              expect(item.assignee_id).not_to eq(initial_assignee_id)
              expect(item.due_by).to eq(initial_due_by)
              expect(item.category).not_to eq(initial_category)
              expect(other_item.assignee_id).not_to eq(initial_other_assignee_id)
              expect(other_item.due_by).to eq(initial_other_due_by)
              expect(other_item.category).not_to eq(initial_other_category)
              expect(item.assignee_id).to eq(other_user.id)
              expect(item.category).to eq(nil)
              expect(other_item.assignee_id).to eq(other_user.id)
              expect(other_item.category).to eq(nil)
            end
          end

          context "when update current items is not requested" do
            it "does not update current items" do
              initial_assignee_id = item.assignee_id
              initial_category = item.category
              initial_due_by = item.due_by
              initial_other_assignee_id = other_item.assignee_id
              initial_other_category = other_item.category
              initial_other_due_by = other_item.due_by

              expect(item.assignee_id).to eq(item.assignee_id)
              expect(item.category).to eq(item.category)
              expect(other_item.assignee_id).to eq(other_item.assignee_id)
              expect(other_item.category).to eq(other_item.category)

              put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
                item_ids
              }", headers: auth_params, params: {
                to_do_list_items: {
                  assignee_id: other_user.id,
                  clear_assignee: false,
                  due_by: nil,
                  clear_due_by: false,
                  category: "update category",
                  clear_category: true,
                  update_current_items: false
                }
              }, as: :json
              item.reload
              other_item.reload

              expect(response).to have_http_status :no_content
              expect(item.assignee_id).to eq(initial_assignee_id)
              expect(item.category).to eq(initial_category)
              expect(item.due_by).to eq(initial_due_by)
              expect(other_item.assignee_id).to eq(initial_other_assignee_id)
              expect(other_item.due_by).to eq(initial_other_due_by)
              expect(other_item.category).to eq(initial_other_category)
              expect(item.assignee_id).not_to eq(other_user.id)
              expect(item.category).not_to eq(nil)
              expect(other_item.assignee_id).not_to eq(other_user.id)
              expect(other_item.category).not_to eq(nil)
            end
          end

          describe "when move is requested" do
            describe "when new list is requested" do
              it "creates new list, new items, and archives current items" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(List.find_by(name: "new to_do list")).to be_nil

                put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
                  item_ids
                }", headers: auth_params, params: {
                  to_do_list_items: {
                    assignee_id: other_user.id,
                    clear_assignee: false,
                    due_by: nil,
                    clear_due_by: false,
                    category: "update category",
                    clear_category: true,
                    update_current_items: false,
                    move: true,
                    new_list_name: "bulk update to_do list"
                  }
                }, as: :json
                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update to_do list")
                new_items = ToDoListItem.where(to_do_list_id: new_list.id)

                expect(item.archived_at).to be_truthy
                expect(other_item.archived_at).to be_truthy
                expect(new_list).to be_truthy
                expect(new_items[0].task).to eq item.task
                expect(new_items[0].due_by).to eq item.due_by
                expect(new_items[0].assignee_id).to eq other_user.id
                expect(new_items[0].category).to eq nil
                expect(new_items[1].task).to eq other_item.task
                expect(new_items[1].due_by).to eq other_item.due_by
                expect(new_items[1].assignee_id).to eq other_user.id
                expect(new_items[1].category).to eq nil
              end
            end

            describe "when existing list is requested" do
              it "does not create list, creates new items, and archives current items" do
                other_list = create :to_do_list, owner: user
                create :users_list, user: user, list: other_list

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
                  item_ids
                }", headers: auth_params, params: {
                  to_do_list_items: {
                    assignee_id: other_user.id,
                    clear_assignee: false,
                    category: "update category",
                    clear_category: true,
                    update_current_items: false,
                    move: true,
                    existing_list_id: other_list.id
                  }
                }, as: :json
                item.reload
                other_item.reload
                new_items = ToDoListItem.where(to_do_list_id: other_list.id)

                expect(item.archived_at).to be_truthy
                expect(other_item.archived_at).to be_truthy
                expect(new_items[0].task).to eq item.task
                expect(new_items[0].due_by).to eq item.due_by
                expect(new_items[0].assignee_id).to eq other_user.id
                expect(new_items[0].category).to eq nil
                expect(new_items[1].task).to eq other_item.task
                expect(new_items[1].due_by).to eq other_item.due_by
                expect(new_items[1].assignee_id).to eq other_user.id
                expect(new_items[1].category).to eq nil
              end
            end
          end

          describe "when copy is requested" do
            describe "when new list is requested" do
              it "does not archive items, creates new list and items" do
                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(List.find_by(name: "new to_do list")).to be_nil

                put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
                  item_ids
                }", headers: auth_params, params: {
                  to_do_list_items: {
                    assignee_id: other_user.id,
                    clear_assignee: false,
                    category: "update category",
                    clear_category: true,
                    update_current_items: false,
                    copy: true,
                    new_list_name: "bulk update to_do list"
                  }
                }, as: :json
                item.reload
                other_item.reload
                new_list = List.find_by(name: "bulk update to_do list")
                new_items = ToDoListItem.where(to_do_list_id: new_list.id)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(new_list).to be_truthy
                expect(new_items[0].task).to eq item.task
                expect(new_items[0].due_by).to eq item.due_by
                expect(new_items[0].assignee_id).to eq other_user.id
                expect(new_items[0].category).to eq nil
                expect(new_items[1].task).to eq other_item.task
                expect(new_items[1].due_by).to eq other_item.due_by
                expect(new_items[1].assignee_id).to eq other_user.id
                expect(new_items[1].category).to eq nil
              end
            end

            describe "when existing list is requested" do
              it "does not create list or archive items, creates new items" do
                other_list = create :to_do_list, owner: user
                create :users_list, user: user, list: other_list

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil

                put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
                  item_ids
                }", headers: auth_params, params: {
                  to_do_list_items: {
                    assignee_id: other_user.id,
                    clear_assignee: false,
                    category: "update category",
                    clear_category: true,
                    update_current_items: false,
                    copy: true,
                    existing_list_id: other_list.id
                  }
                }, as: :json
                item.reload
                other_item.reload
                new_items = ToDoListItem.where(to_do_list_id: other_list.id)

                expect(item.archived_at).to be_nil
                expect(other_item.archived_at).to be_nil
                expect(new_items[0].task).to eq item.task
                expect(new_items[0].due_by).to eq item.due_by
                expect(new_items[0].assignee_id).to eq other_user.id
                expect(new_items[0].category).to eq nil
                expect(new_items[1].task).to eq other_item.task
                expect(new_items[1].due_by).to eq other_item.due_by
                expect(new_items[1].assignee_id).to eq other_user.id
                expect(new_items[1].category).to eq nil
              end
            end
          end
        end

        describe "with invalid params" do
          it "returns unproccessable entity" do
            other_list = create :to_do_list, owner: user
            create :users_list, user: user, list: other_list

            put "#{list_to_do_list_items_bulk_update_path(list.id)}?item_ids=#{
              item_ids
            }", headers: auth_params, params: {
              to_do_list_items: {
                assignee_id: other_user.id,
                clear_assignee: false,
                category: "update category",
                clear_category: true,
                update_current_items: false,
                copy: true
              }
            }, as: :json

            expect(response).to have_http_status :unprocessable_entity
          end
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
