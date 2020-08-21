# frozen_string_literal: true

require "rails_helper"

describe "/lists/merge_lists", type: :request do
  let(:user) { create :user_with_lists }

  before { login user }

  describe "POST /" do
    describe "when type is BookList" do
      it "creates a new list, users_list, and adds new items to the list" do
        first_list = BookList.create!(name: "FirstBookList", owner: user, completed: true)
        second_list = BookList.create!(name: "SecondBookList", owner: user, completed: true)
        BookListItem.create!(user: user, list: first_list, title: "foo", category: "foo")
        BookListItem.create!(user: user, list: second_list, title: "bar", category: "bar")
        expect do
          post merge_lists_path,
               params: { merge_lists: { list_ids: "#{first_list.id},#{second_list.id}", new_list_name: "foobar" } },
               headers: auth_params
        end.to change(BookList, :count).by(1).and change(BookListItem, :count).by(2).and change(UsersList, :count).by(1)
      end
    end

    describe "when type is GroceryList" do
      it "creates a new list, users_list, and adds new items to the list" do
        first_list = GroceryList.create!(name: "FirstGroceryList", owner: user, completed: true)
        second_list = GroceryList.create!(name: "SecondGroceryList", owner: user, completed: true)
        GroceryListItem.create!(user: user, list: first_list, product: "foo", category: "foo")
        GroceryListItem.create!(user: user, list: second_list, product: "bar", category: "bar")
        expect do
          post merge_lists_path,
               params: { merge_lists: { list_ids: "#{first_list.id},#{second_list.id}", new_list_name: "foobar" } },
               headers: auth_params
        end.to change(GroceryList, :count).by(1)
                                          .and change(GroceryListItem, :count).by(2)
                                                                              .and change(UsersList, :count).by(1)
      end
    end

    describe "when type is MusicList" do
      it "creates a new list, users_list, and adds new items to the list" do
        first_list = MusicList.create!(name: "FirstMusicList", owner: user, completed: true)
        second_list = MusicList.create!(name: "SecondMusicList", owner: user, completed: true)
        MusicListItem.create!(user: user, list: first_list, title: "foo", category: "foo")
        MusicListItem.create!(user: user, list: second_list, title: "bar", category: "bar")
        expect do
          post merge_lists_path,
               params: { merge_lists: { list_ids: "#{first_list.id},#{second_list.id}", new_list_name: "foobar" } },
               headers: auth_params
        end.to change(MusicList, :count).by(1)
                                        .and change(MusicListItem, :count).by(2)
                                                                          .and change(UsersList, :count).by(1)
      end
    end

    describe "when type is SimpleList" do
      it "creates a new list, users_list, and adds new items to the list" do
        first_list = SimpleList.create!(name: "FirstSimpleList", owner: user, completed: true)
        second_list = SimpleList.create!(name: "SecondSimpleList", owner: user, completed: true)
        SimpleListItem.create!(user: user, list: first_list, content: "foo", category: "foo")
        SimpleListItem.create!(user: user, list: second_list, content: "bar", category: "bar")
        expect do
          post merge_lists_path,
               params: { merge_lists: { list_ids: "#{first_list.id},#{second_list.id}", new_list_name: "foobar" } },
               headers: auth_params
        end.to change(SimpleList, :count).by(1)
                                         .and change(SimpleListItem, :count).by(2)
                                                                            .and change(UsersList, :count).by(1)
      end
    end

    describe "when type is ToDoList" do
      it "creates a new list, users_list, and adds new items to the list" do
        first_list = ToDoList.create!(name: "FirstToDoList", owner: user, completed: true)
        second_list = ToDoList.create!(name: "SecondToDoList", owner: user, completed: true)
        ToDoListItem.create!(user: user, list: first_list, task: "foo", category: "foo")
        ToDoListItem.create!(user: user, list: second_list, task: "bar", category: "bar")
        expect do
          post merge_lists_path,
               params: { merge_lists: { list_ids: "#{first_list.id},#{second_list.id}", new_list_name: "foobar" } },
               headers: auth_params
        end.to change(ToDoList, :count).by(1).and change(ToDoListItem, :count).by(2).and change(UsersList, :count).by(1)
      end
    end
  end
end
