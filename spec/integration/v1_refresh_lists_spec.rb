# frozen_string_literal: true

require "rails_helper"

describe "/v1/lists/:list_id/refresh_list", type: :request do
  let(:user) { create(:user_with_lists) }
  let(:list) { user.lists.last }

  before { login user }

  describe "POST /" do
    context "when user is not owner" do
      it "responds with forbidden" do
        post v1_list_refresh_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      describe "when old list is a BookList" do
        it "creates new list and items" do
          list = BookList.create!(name: "NewBookList", owner: user, completed: true)
          BookListItem.create!(user: user, list: list, title: "foo", category: "foo")

          expect do
            post v1_list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by(1).and change(BookListItem, :count).by(1)
          new_list_item = BookListItem.last
          expect(new_list_item[:title]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end

      describe "when old list is a GroceryList" do
        it "creates new list and items" do
          list = GroceryList.create!(name: "NewGroceryList", owner: user, completed: true)
          GroceryListItem.create!(user: user, list: list, product: "foo", quantity: 1, category: "foo")

          expect do
            post v1_list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by(1).and change(GroceryListItem, :count).by(1)
          new_list_item = GroceryListItem.last
          expect(new_list_item[:product]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end

      describe "when old list is a MusicList" do
        it "creates new list and items" do
          list = MusicList.create!(name: "NewMusicList", owner: user, completed: true)
          MusicListItem.create!(user: user, list: list, title: "foo", category: "foo")

          expect do
            post v1_list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by(1).and change(MusicListItem, :count).by(1)
          new_list_item = MusicListItem.last
          expect(new_list_item[:title]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end

      describe "when old list is a SimpleList" do
        it "creates new list and items" do
          list = SimpleList.create!(name: "NewSimpleList", owner: user, completed: true)
          SimpleListItem.create!(user: user, list: list, content: "foo", category: "foo")

          expect do
            post v1_list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by(1).and change(SimpleListItem, :count).by(1)
          new_list_item = SimpleListItem.last
          expect(new_list_item[:content]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end

      describe "when old list is a ToDoList" do
        it "creates new list and items" do
          list = ToDoList.create!(name: "NewToDoList", owner: user, completed: true)
          ToDoListItem.create!(user: user, list: list, task: "foo", category: "foo")

          expect do
            post v1_list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by(1).and change(ToDoListItem, :count).by(1)
          new_list_item = ToDoListItem.last
          expect(new_list_item[:task]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end
    end
  end
end
