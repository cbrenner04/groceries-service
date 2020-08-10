# frozen_string_literal: true

require "rails_helper"
require_relative "./shared_examples/list_items.rb"

describe "/lists/:list_id/book_list_items", type: :request do
  let(:user) { create :user }
  let(:list) { create :book_list, owner: user }
  let(:users_list) { create :users_list, user: user, list: list }
  let(:item) { create :book_list_item, book_list: list }

  required_attrs = %w[title author]
  item_attrs = %w[title author read number_in_series]

  it_behaves_like "a list item", "book_list", required_attrs, item_attrs
end
