# frozen_string_literal: true

require "rails_helper"
require_relative "./shared_examples/list_items_bulk_update"

describe "/lists/:list_id/grocery_list_items/bulk_update", type: :request do
  let(:user) { create :user }
  let(:list) { create :grocery_list, owner: user }
  let(:users_list) { create :users_list, user: user, list: list }
  let(:item) { create :grocery_list_item, grocery_list: list }
  let(:other_item) { create :grocery_list_item, grocery_list: list }
  let(:item_ids) { [item.id, other_item.id].join(",") }

  new_item_attrs = %w[quantity product]
  update_attrs = ["quantity"]

  it_behaves_like "a list items bulk update", "grocery_list", new_item_attrs, update_attrs
end
