# frozen_string_literal: true

require "rails_helper"
require_relative "./shared_examples/list_items_bulk_update"

describe "/lists/:list_id/list_items/bulk_update", type: :request do
  describe "music_list_items" do
    let(:user) { create :user }
    let(:list) { create :music_list, owner: user }
    let(:users_list) { create :users_list, user: user, list: list }
    let(:item) { create :music_list_item, list: list }
    let(:other_item) { create :music_list_item, list: list }
    let(:item_ids) { [item.id, other_item.id].join(",") }

    new_item_attrs = %w[artist album title]
    update_attrs = %w[artist album]

    it_behaves_like "a list items bulk update", "music_list", new_item_attrs, update_attrs
  end
end
