# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/list_items", type: :request do
  describe "music_list_items" do
    let(:user) { create(:user) }
    let(:list) { create(:music_list, owner: user) }
    let(:users_list) { create(:users_list, user: user, list: list) }
    let(:item) { create(:music_list_item, list: list) }
    let(:required_attrs) { %w[title artist album] }
    let(:item_attrs) { %w[title artist album] }

    it_behaves_like "a list item", "music_list", required_attrs, item_attrs
  end
end
