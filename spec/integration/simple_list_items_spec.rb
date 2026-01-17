# frozen_string_literal: true

require "rails_helper"

describe "/lists/:list_id/list_items", type: :request do
  describe "simple_list_items" do
    let(:user) { create(:user) }
    let(:list) { create(:simple_list, owner: user) }
    let(:users_list) { create(:users_list, user: user, list: list) }
    let(:item) { create(:simple_list_item, list: list, content: "foobar") }
    let(:required_attrs) { %w[content] }
    let(:item_attrs) { %w[content] }

    it_behaves_like "a list item", "simple_list", required_attrs, item_attrs
  end
end
