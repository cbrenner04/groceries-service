# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/refresh_list", type: :request do
  let(:user) { create :user_with_lists }
  let(:list) { user.lists.last }

  before { login user }

  describe "POST /" do
    context "when user is not owner" do
      it "responds with forbidden" do
        post list_refresh_list_path(list.id), headers: auth_params

        expect(response).to have_http_status :forbidden
      end
    end

    context "when user is owner" do
      describe "when old list is a BookList" do
        it "creates new list" do
          list = BookList.create!(name: "NewBookList",
                                  owner: user,
                                  completed: true)
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by 1
        end

        it "creates new items" do
          list = BookList.create!(name: "NewBookList",
                                  owner: user,
                                  completed: true)
          BookListItem.create!(
            user: user,
            book_list: list,
            title: "foo",
            category: "foo"
          )
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(BookListItem, :count).by 1
          new_list_item = BookListItem.last
          expect(new_list_item[:title]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end

      describe "when old list is a GroceryList" do
        it "creates new list" do
          list = GroceryList.create!(name: "NewGroceryList",
                                     owner: user,
                                     completed: true)
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by 1
        end

        it "creates new items" do
          list = GroceryList.create!(name: "NewGroceryList",
                                     owner: user,
                                     completed: true)
          GroceryListItem.create!(
            user: user,
            grocery_list: list,
            product: "foo",
            quantity: 1,
            category: "foo"
          )
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(GroceryListItem, :count).by 1
          new_list_item = GroceryListItem.last
          expect(new_list_item[:product]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end

      describe "when old list is a MusicList" do
        it "creates new list" do
          list = MusicList.create!(name: "NewMusicList",
                                   owner: user,
                                   completed: true)
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by 1
        end

        it "creates new items" do
          list = MusicList.create!(name: "NewMusicList",
                                   owner: user,
                                   completed: true)
          MusicListItem.create!(
            user: user,
            music_list: list,
            title: "foo",
            category: "foo"
          )
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(MusicListItem, :count).by 1
          new_list_item = MusicListItem.last
          expect(new_list_item[:title]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end

      describe "when old list is a ToDoList" do
        it "creates new list" do
          list = ToDoList.create!(name: "NewToDoList",
                                  owner: user,
                                  completed: true)
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(List, :count).by 1
        end

        it "creates new items" do
          list = ToDoList.create!(name: "NewToDoList",
                                  owner: user,
                                  completed: true)
          ToDoListItem.create!(
            user: user,
            to_do_list: list,
            task: "foo",
            category: "foo"
          )
          expect do
            post list_refresh_list_path(list.id), headers: auth_params
          end.to change(ToDoListItem, :count).by 1
          new_list_item = ToDoListItem.last
          expect(new_list_item[:task]).to eq "foo"
          expect(new_list_item[:category]).to eq "foo"
        end
      end
    end
  end
end
