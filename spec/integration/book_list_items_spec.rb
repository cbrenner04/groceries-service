# frozen_string_literal: true

require "rails_helper"
require_relative "./shared_examples/list_items"

describe "/lists/:list_id/list_items", type: :request do
  describe "book_list_items" do
    let(:user) { create :user }
    let(:list) { create :book_list, owner: user }
    let(:users_list) { create :users_list, user: user, list: list }
    let(:item) { create :book_list_item, book_list: list }

    required_attrs = %w[title author]
    item_attrs = %w[title author read number_in_series]

    it_behaves_like "a list item", "book_list", required_attrs, item_attrs
  end
end
